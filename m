From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 07/12] xdp: add trace event for xdp redirect
Date: Fri, 07 Jul 2017 10:36:51 -0700
Message-ID: <20170707173651.9984.98397.stgit@john-Precision-Tower-5810>
References: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, john.fastabend@gmail.com, andy@greyhouse.net,
        daniel@iogearbox.net, ast@fb.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36114 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751023AbdGGRhG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 13:37:06 -0400
Received: by mail-pf0-f193.google.com with SMTP id z6so5411956pfk.3
        for <netdev@vger.kernel.org>; Fri, 07 Jul 2017 10:37:06 -0700 (PDT)
In-Reply-To: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a trace event for xdp redirect which may help when debugging
XDP programs that use redirect bpf commands.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
 include/linux/filter.h                        |    4 ++-
 include/trace/events/xdp.h                    |   31 ++++++++++++++++++++++++-
 net/core/filter.c                             |   13 +++++++---
 4 files changed, 43 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3db0473..38f7ff9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2232,7 +2232,7 @@ static struct sk_buff *ixgbe_run_xdp(struct ixgbe_adapter *adapter,
 		result = ixgbe_xmit_xdp_ring(adapter, xdp);
 		break;
 	case XDP_REDIRECT:
-		err = xdp_do_redirect(adapter->netdev, xdp);
+		err = xdp_do_redirect(adapter->netdev, xdp, xdp_prog);
 		if (!err)
 			result = IXGBE_XDP_TX;
 		else
diff --git a/include/linux/filter.h b/include/linux/filter.h
index ccb73d8..997b9c9 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -669,7 +669,9 @@ struct bpf_prog *bpf_patch_insn_single(struct bpf_prog *prog, u32 off,
 				       const struct bpf_insn *patch, u32 len);
 
 int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb);
-int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp);
+int xdp_do_redirect(struct net_device *dev,
+		    struct xdp_buff *xdp,
+		    struct bpf_prog *prog);
 
 void bpf_warn_invalid_xdp_action(u32 act);
 void bpf_warn_invalid_xdp_redirect(u32 ifindex);
diff --git a/include/trace/events/xdp.h b/include/trace/events/xdp.h
index 1b61357..7b1eb7b 100644
--- a/include/trace/events/xdp.h
+++ b/include/trace/events/xdp.h
@@ -12,7 +12,8 @@
 	FN(ABORTED)		\
 	FN(DROP)		\
 	FN(PASS)		\
-	FN(TX)
+	FN(TX)			\
+	FN(REDIRECT)
 
 #define __XDP_ACT_TP_FN(x)	\
 	TRACE_DEFINE_ENUM(XDP_##x);
@@ -48,6 +49,34 @@
 		  __print_symbolic(__entry->act, __XDP_ACT_SYM_TAB))
 );
 
+TRACE_EVENT(xdp_redirect,
+
+	TP_PROTO(const struct net_device *from,
+		 const struct net_device *to,
+		 const struct bpf_prog *xdp, u32 act),
+
+	TP_ARGS(from, to, xdp, act),
+
+	TP_STRUCT__entry(
+		__string(name_from, from->name)
+		__string(name_to, to->name)
+		__array(u8, prog_tag, 8)
+		__field(u32, act)
+	),
+
+	TP_fast_assign(
+		BUILD_BUG_ON(sizeof(__entry->prog_tag) != sizeof(xdp->tag));
+		memcpy(__entry->prog_tag, xdp->tag, sizeof(xdp->tag));
+		__assign_str(name_from, from->name);
+		__assign_str(name_to, to->name);
+		__entry->act = act;
+	),
+
+	TP_printk("prog=%s from=%s to=%s action=%s",
+		  __print_hex_str(__entry->prog_tag, 8),
+		  __get_str(name_from), __get_str(name_to),
+		  __print_symbolic(__entry->act, __XDP_ACT_SYM_TAB))
+);
 #endif /* _TRACE_XDP_H */
 
 #include <trace/define_trace.h>
diff --git a/net/core/filter.c b/net/core/filter.c
index 1fbe079..441abbb 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -54,6 +54,7 @@
 #include <net/dst.h>
 #include <net/sock_reuseport.h>
 #include <net/busy_poll.h>
+#include <linux/bpf_trace.h>
 
 /**
  *	sk_filter_trim_cap - run a packet through a socket filter
@@ -2308,18 +2309,22 @@ static int __bpf_tx_xdp(struct net_device *dev, struct xdp_buff *xdp)
 	return -EOPNOTSUPP;
 }
 
-int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp)
+int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp,
+		    struct bpf_prog *xdp_prog)
 {
 	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
+	struct net_device *fwd;
 
-	dev = dev_get_by_index_rcu(dev_net(dev), ri->ifindex);
+	fwd = dev_get_by_index_rcu(dev_net(dev), ri->ifindex);
 	ri->ifindex = 0;
-	if (unlikely(!dev)) {
+	if (unlikely(!fwd)) {
 		bpf_warn_invalid_xdp_redirect(ri->ifindex);
 		return -EINVAL;
 	}
 
-	return __bpf_tx_xdp(dev, xdp);
+	trace_xdp_redirect(dev, fwd, xdp_prog, XDP_REDIRECT);
+
+	return __bpf_tx_xdp(fwd, xdp);
 }
 EXPORT_SYMBOL_GPL(xdp_do_redirect);
 
