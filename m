From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] bpf: introduce bpf_clone_redirect() helper
Date: Tue,  2 Jun 2015 16:03:14 -0700
Message-ID: <1433286194-5246-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:35379 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443AbbFBXDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 19:03:22 -0400
Received: by qkhq76 with SMTP id q76so81502647qkh.2
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 16:03:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow eBPF programs attached to classifier/actions to call
bpf_clone_redirect(skb, ifindex, flags) helper which will
mirror or redirect the packet by dynamic ifindex selection
from within the program to a target device either at ingress
or at egress. Can be used for various scenarios, for example,
to load balance skbs into veths, split parts of the traffic
to local taps, etc.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/uapi/linux/bpf.h |   10 ++++++++++
 net/core/filter.c        |   40 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 50 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 72f3080afa1e..42aa19abab86 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -220,6 +220,16 @@ enum bpf_func_id {
 	 * Return: 0 on success
 	 */
 	BPF_FUNC_tail_call,
+
+	/**
+	 * bpf_clone_redirect(skb, ifindex, flags) - redirect to another netdev
+	 * @skb: pointer to skb
+	 * @ifindex: ifindex of the net device
+	 * @flags: bit 0 - if set, redirect to ingress instead of egress
+	 *         other bits - reserved
+	 * Return: 0 on success
+	 */
+	BPF_FUNC_clone_redirect,
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/net/core/filter.c b/net/core/filter.c
index b78a010a957f..64c121c09655 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -46,6 +46,7 @@
 #include <linux/seccomp.h>
 #include <linux/if_vlan.h>
 #include <linux/bpf.h>
+#include <net/sch_generic.h>
 
 /**
  *	sk_filter - run a packet through a socket filter
@@ -1407,6 +1408,43 @@ const struct bpf_func_proto bpf_l4_csum_replace_proto = {
 	.arg5_type	= ARG_ANYTHING,
 };
 
+#define BPF_IS_REDIRECT_INGRESS(flags)	((flags) & 1)
+
+static u64 bpf_clone_redirect(u64 r1, u64 ifindex, u64 flags, u64 r4, u64 r5)
+{
+	struct sk_buff *skb = (struct sk_buff *) (long) r1, *skb2;
+	struct net_device *dev;
+
+	dev = dev_get_by_index_rcu(dev_net(skb->dev), ifindex);
+	if (unlikely(!dev))
+		return -EINVAL;
+
+	if (unlikely(!(dev->flags & IFF_UP)))
+		return -EINVAL;
+
+	skb2 = skb_clone(skb, GFP_ATOMIC);
+	if (unlikely(!skb2))
+		return -ENOMEM;
+
+	if (G_TC_AT(skb2->tc_verd) & AT_INGRESS)
+		skb_push(skb2, skb2->mac_len);
+
+	if (BPF_IS_REDIRECT_INGRESS(flags))
+		return dev_forward_skb(dev, skb2);
+
+	skb2->dev = dev;
+	return dev_queue_xmit(skb2);
+}
+
+const struct bpf_func_proto bpf_clone_redirect_proto = {
+	.func           = bpf_clone_redirect,
+	.gpl_only       = false,
+	.ret_type       = RET_INTEGER,
+	.arg1_type      = ARG_PTR_TO_CTX,
+	.arg2_type      = ARG_ANYTHING,
+	.arg3_type      = ARG_ANYTHING,
+};
+
 static const struct bpf_func_proto *
 sk_filter_func_proto(enum bpf_func_id func_id)
 {
@@ -1440,6 +1478,8 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 		return &bpf_l3_csum_replace_proto;
 	case BPF_FUNC_l4_csum_replace:
 		return &bpf_l4_csum_replace_proto;
+	case BPF_FUNC_clone_redirect:
+		return &bpf_clone_redirect_proto;
 	default:
 		return sk_filter_func_proto(func_id);
 	}
-- 
1.7.9.5
