From: kan.liang@intel.com
Subject: [RFC V3 PATCH 19/26] net/netpolicy: tc bpf extension to pick Tx queue
Date: Mon, 12 Sep 2016 07:55:52 -0700
Message-ID: <1473692159-4017-20-git-send-email-kan.liang@intel.com>
References: <1473692159-4017-1-git-send-email-kan.liang@intel.com>
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
        peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net,
        akpm@linux-foundation.org, keescook@chromium.org,
        viro@zeniv.linux.org.uk, gorcunov@openvz.org,
        john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
        decot@googlers.com, fw@strlen.de, alexander.duyck@gmail.com,
        daniel@iogearbox.net, tom@herbertland.com, rdunlap@infradead.org,
        xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
        stephen@networkplumber.org, alexei.starovoitov@gmail.com,
        jesse.brandeburg@intel.com, andi@firstfloor.org,
        Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:7470 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759603AbcILO4r (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Sep 2016 10:56:47 -0400
In-Reply-To: <1473692159-4017-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

This patch extends the netpolicy to support tc bpf when selecting Tx
queue. It implements a bpf classifier for clsact qdisc. The classifier
will pick up the proper queue from net policy subsystem. This queue
selection from tc is not compatible with XPS. So XPS will be invalid.

Currently, tc bpf extension only supports the queue selection on egress.
To enable the extension, the following command must be applied.
 # ./tc qdisc add dev $DEVNAME clsact
 # ./tc filter add dev $DEVNAME egress bpf obj netpolicy_kern.o

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/uapi/linux/bpf.h  |  8 ++++++++
 net/core/dev.c            |  4 ++--
 net/core/filter.c         | 36 ++++++++++++++++++++++++++++++++++++
 samples/bpf/Makefile      |  1 +
 samples/bpf/bpf_helpers.h |  2 ++
 5 files changed, 49 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index f896dfa..9c7d847 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -398,6 +398,14 @@ enum bpf_func_id {
 	 */
 	BPF_FUNC_skb_change_tail,
 
+	/**
+	 * bpf_netpolicy(skb)
+	 * Netpolicy tc extension. Search for proper Tx queue
+	 * @skb: pointer to skb
+	 * Return: 0 on success or negative error
+	 */
+	BPF_FUNC_netpolicy,
+
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/net/core/dev.c b/net/core/dev.c
index b9a8044..82304ce 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3285,8 +3285,8 @@ struct netdev_queue *netdev_pick_tx(struct net_device *dev,
 #ifdef CONFIG_NETPOLICY
 			struct netpolicy_instance *instance;
 
-			queue_index = -1;
-			if (dev->netpolicy && sk) {
+			queue_index = sk_tx_queue_get(sk);
+			if ((queue_index < 0) && dev->netpolicy && sk) {
 				instance = netpolicy_find_instance(sk);
 				if (instance) {
 					if (!instance->dev)
diff --git a/net/core/filter.c b/net/core/filter.c
index a83766b..ce32288 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2351,6 +2351,38 @@ static const struct bpf_func_proto bpf_skb_set_tunnel_opt_proto = {
 	.arg3_type	= ARG_CONST_STACK_SIZE,
 };
 
+#ifdef CONFIG_NETPOLICY
+static u64 bpf_netpolicy(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	struct sk_buff *skb = (struct sk_buff *) (unsigned long) r1;
+	struct netpolicy_instance *instance;
+	struct net_device *dev = skb->dev;
+	struct sock *sk = skb->sk;
+	int queue_index;
+
+	if (dev->netpolicy && sk) {
+		instance = netpolicy_find_instance(sk);
+		if (instance) {
+			if (!instance->dev)
+				instance->dev = dev;
+			queue_index = netpolicy_pick_queue(instance, false);
+			if ((queue_index >= 0) && sk_fullsock(sk) &&
+			    rcu_access_pointer(sk->sk_dst_cache))
+				sk_tx_queue_set(sk, queue_index);
+		}
+	}
+
+	return 0;
+}
+
+static const struct bpf_func_proto bpf_netpolicy_proto = {
+	.func		= bpf_netpolicy,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+};
+#endif
+
 static const struct bpf_func_proto *
 bpf_get_skb_set_tunnel_proto(enum bpf_func_id which)
 {
@@ -2515,6 +2547,10 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 		return &bpf_get_smp_processor_id_proto;
 	case BPF_FUNC_skb_under_cgroup:
 		return &bpf_skb_under_cgroup_proto;
+#ifdef CONFIG_NETPOLICY
+	case BPF_FUNC_netpolicy:
+		return &bpf_netpolicy_proto;
+#endif
 	default:
 		return sk_filter_func_proto(func_id);
 	}
diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 12b7304..4aedbb9 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -85,6 +85,7 @@ always += xdp2_kern.o
 always += test_current_task_under_cgroup_kern.o
 always += trace_event_kern.o
 always += sampleip_kern.o
+always += netpolicy_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 90f44bd..b295bbc 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -88,6 +88,8 @@ static int (*bpf_l4_csum_replace)(void *ctx, int off, int from, int to, int flag
 	(void *) BPF_FUNC_l4_csum_replace;
 static int (*bpf_skb_under_cgroup)(void *ctx, void *map, int index) =
 	(void *) BPF_FUNC_skb_under_cgroup;
+static int (*bpf_netpolicy)(void *ctx) =
+	(void *) BPF_FUNC_netpolicy;
 
 #if defined(__x86_64__)
 
-- 
2.5.5
