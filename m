From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 2/2] bpf: add bpf_redirect() helper
Date: Tue, 15 Sep 2015 23:05:43 -0700
Message-ID: <1442383543-4720-3-git-send-email-ast@plumgrid.com>
References: <1442383543-4720-1-git-send-email-ast@plumgrid.com>
Cc: John Fastabend <john.fastabend@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34255 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588AbbIPGFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 02:05:55 -0400
Received: by padhy16 with SMTP id hy16so199232631pad.1
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 23:05:55 -0700 (PDT)
In-Reply-To: <1442383543-4720-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Existing bpf_clone_redirect() helper clones skb before redirecting
it to RX or TX of destination netdev.
Introduce bpf_redirect() helper that does that without cloning.

Benchmarked with two hosts using 10G ixgbe NICs.
One host is doing line rate pktgen.
Another host is configured as:
$ tc qdisc add dev $dev ingress
$ tc filter add dev $dev root pref 10 u32 match u32 0 0 flowid 1:2 \
   action bpf run object-file tcbpf1_kern.o section clone_redirect_xmit drop
so it receives the packet on $dev and immediately xmits it on $dev + 1
The section 'clone_redirect_xmit' in tcbpf1_kern.o file has the program
that does bpf_clone_redirect() and performance is 2.0 Mpps

$ tc filter add dev $dev root pref 10 u32 match u32 0 0 flowid 1:2 \
   action bpf run object-file tcbpf1_kern.o section redirect_xmit drop
which is using bpf_redirect() - 2.4 Mpps

and using cls_bpf with integrated actions as:
$ tc filter add dev $dev root pref 10 \
  bpf run object-file tcbpf1_kern.o section redirect_xmit integ_act classid 1
performance is 2.5 Mpps

To summarize:
u32+act_bpf using clone_redirect - 2.0 Mpps
u32+act_bpf using redirect - 2.4 Mpps
cls_bpf using redirect - 2.5 Mpps

For comparison linux bridge in this setup is doing 2.1 Mpps
and ixgbe rx + drop in ip_rcv - 7.8 Mpps

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
This approach is using per_cpu scratch area to store ifindex and flags.
The other alternatives discussed at plumbers are slower and more intrusive.
v1->v2: dropped redundant iff_up check

 include/net/sch_generic.h    |    1 +
 include/uapi/linux/bpf.h     |    8 ++++++++
 include/uapi/linux/pkt_cls.h |    1 +
 net/core/dev.c               |    8 ++++++++
 net/core/filter.c            |   44 ++++++++++++++++++++++++++++++++++++++++++
 net/sched/act_bpf.c          |    1 +
 net/sched/cls_bpf.c          |    1 +
 samples/bpf/bpf_helpers.h    |    4 ++++
 samples/bpf/tcbpf1_kern.c    |   24 ++++++++++++++++++++++-
 9 files changed, 91 insertions(+), 1 deletion(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index da61febb9091..4c79ce8c1f92 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -402,6 +402,7 @@ void __qdisc_calculate_pkt_len(struct sk_buff *skb,
 			       const struct qdisc_size_table *stab);
 bool tcf_destroy(struct tcf_proto *tp, bool force);
 void tcf_destroy_chain(struct tcf_proto __rcu **fl);
+int skb_do_redirect(struct sk_buff *);
 
 /* Reset all TX qdiscs greater then index of a device.  */
 static inline void qdisc_reset_all_tx_gt(struct net_device *dev, unsigned int i)
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 2fbd1c71fa3b..4ec0b5488294 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -272,6 +272,14 @@ enum bpf_func_id {
 	BPF_FUNC_skb_get_tunnel_key,
 	BPF_FUNC_skb_set_tunnel_key,
 	BPF_FUNC_perf_event_read,	/* u64 bpf_perf_event_read(&map, index) */
+	/**
+	 * bpf_redirect(ifindex, flags) - redirect to another netdev
+	 * @ifindex: ifindex of the net device
+	 * @flags: bit 0 - if set, redirect to ingress instead of egress
+	 *         other bits - reserved
+	 * Return: TC_ACT_REDIRECT
+	 */
+	BPF_FUNC_redirect,
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 0a262a83f9d4..439873775d49 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -87,6 +87,7 @@ enum {
 #define TC_ACT_STOLEN		4
 #define TC_ACT_QUEUED		5
 #define TC_ACT_REPEAT		6
+#define TC_ACT_REDIRECT		7
 #define TC_ACT_JUMP		0x10000000
 
 /* Action type identifiers*/
diff --git a/net/core/dev.c b/net/core/dev.c
index 877c84834d81..d6a492e57874 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3668,6 +3668,14 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 	case TC_ACT_QUEUED:
 		kfree_skb(skb);
 		return NULL;
+	case TC_ACT_REDIRECT:
+		/* skb_mac_header check was done by cls/act_bpf, so
+		 * we can safely push the L2 header back before
+		 * redirecting to another netdev
+		 */
+		__skb_push(skb, skb->mac_len);
+		skb_do_redirect(skb);
+		return NULL;
 	default:
 		break;
 	}
diff --git a/net/core/filter.c b/net/core/filter.c
index 971d6ba89758..da3f3d94d6e9 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1427,6 +1427,48 @@ const struct bpf_func_proto bpf_clone_redirect_proto = {
 	.arg3_type      = ARG_ANYTHING,
 };
 
+struct redirect_info {
+	u32 ifindex;
+	u32 flags;
+};
+
+static DEFINE_PER_CPU(struct redirect_info, redirect_info);
+static u64 bpf_redirect(u64 ifindex, u64 flags, u64 r3, u64 r4, u64 r5)
+{
+	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
+
+	ri->ifindex = ifindex;
+	ri->flags = flags;
+	return TC_ACT_REDIRECT;
+}
+
+int skb_do_redirect(struct sk_buff *skb)
+{
+	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
+	struct net_device *dev;
+
+	dev = dev_get_by_index_rcu(dev_net(skb->dev), ri->ifindex);
+	ri->ifindex = 0;
+	if (unlikely(!dev)) {
+		kfree_skb(skb);
+		return -EINVAL;
+	}
+
+	if (BPF_IS_REDIRECT_INGRESS(ri->flags))
+		return dev_forward_skb(dev, skb);
+
+	skb->dev = dev;
+	return dev_queue_xmit(skb);
+}
+
+const struct bpf_func_proto bpf_redirect_proto = {
+	.func           = bpf_redirect,
+	.gpl_only       = false,
+	.ret_type       = RET_INTEGER,
+	.arg1_type      = ARG_ANYTHING,
+	.arg2_type      = ARG_ANYTHING,
+};
+
 static u64 bpf_get_cgroup_classid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 {
 	return task_get_classid((struct sk_buff *) (unsigned long) r1);
@@ -1607,6 +1649,8 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 		return &bpf_skb_get_tunnel_key_proto;
 	case BPF_FUNC_skb_set_tunnel_key:
 		return bpf_get_skb_set_tunnel_key_proto();
+	case BPF_FUNC_redirect:
+		return &bpf_redirect_proto;
 	default:
 		return sk_filter_func_proto(func_id);
 	}
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index 559bfa011bda..0bc6f912f870 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -72,6 +72,7 @@ static int tcf_bpf(struct sk_buff *skb, const struct tc_action *act,
 	case TC_ACT_PIPE:
 	case TC_ACT_RECLASSIFY:
 	case TC_ACT_OK:
+	case TC_ACT_REDIRECT:
 		action = filter_res;
 		break;
 	case TC_ACT_SHOT:
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 77b0ef148256..0590816ab7b0 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -70,6 +70,7 @@ static int cls_bpf_exec_opcode(int code)
 	case TC_ACT_PIPE:
 	case TC_ACT_STOLEN:
 	case TC_ACT_QUEUED:
+	case TC_ACT_REDIRECT:
 	case TC_ACT_UNSPEC:
 		return code;
 	default:
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 3a44d3a272af..21aa1b44c30c 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -33,6 +33,10 @@ static int (*bpf_get_current_comm)(void *buf, int buf_size) =
 	(void *) BPF_FUNC_get_current_comm;
 static int (*bpf_perf_event_read)(void *map, int index) =
 	(void *) BPF_FUNC_perf_event_read;
+static int (*bpf_clone_redirect)(void *ctx, int ifindex, int flags) =
+	(void *) BPF_FUNC_clone_redirect;
+static int (*bpf_redirect)(int ifindex, int flags) =
+	(void *) BPF_FUNC_redirect;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
diff --git a/samples/bpf/tcbpf1_kern.c b/samples/bpf/tcbpf1_kern.c
index 9bfb2eb34563..fa051b3d53ee 100644
--- a/samples/bpf/tcbpf1_kern.c
+++ b/samples/bpf/tcbpf1_kern.c
@@ -5,7 +5,7 @@
 #include <uapi/linux/in.h>
 #include <uapi/linux/tcp.h>
 #include <uapi/linux/filter.h>
-
+#include <uapi/linux/pkt_cls.h>
 #include "bpf_helpers.h"
 
 /* compiler workaround */
@@ -64,4 +64,26 @@ int bpf_prog1(struct __sk_buff *skb)
 
 	return 0;
 }
+SEC("redirect_xmit")
+int _redirect_xmit(struct __sk_buff *skb)
+{
+	return bpf_redirect(skb->ifindex + 1, 0);
+}
+SEC("redirect_recv")
+int _redirect_recv(struct __sk_buff *skb)
+{
+	return bpf_redirect(skb->ifindex + 1, 1);
+}
+SEC("clone_redirect_xmit")
+int _clone_redirect_xmit(struct __sk_buff *skb)
+{
+	bpf_clone_redirect(skb, skb->ifindex + 1, 0);
+	return TC_ACT_SHOT;
+}
+SEC("clone_redirect_recv")
+int _clone_redirect_recv(struct __sk_buff *skb)
+{
+	bpf_clone_redirect(skb, skb->ifindex + 1, 1);
+	return TC_ACT_SHOT;
+}
 char _license[] SEC("license") = "GPL";
-- 
1.7.9.5
