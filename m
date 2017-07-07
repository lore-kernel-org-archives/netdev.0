From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 03/12] xdp: add bpf_redirect helper function
Date: Fri, 07 Jul 2017 10:35:23 -0700
Message-ID: <20170707173522.9984.73677.stgit@john-Precision-Tower-5810>
References: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, john.fastabend@gmail.com, andy@greyhouse.net,
        daniel@iogearbox.net, ast@fb.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34008 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750726AbdGGRfl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 13:35:41 -0400
Received: by mail-pf0-f193.google.com with SMTP id c24so5409591pfe.1
        for <netdev@vger.kernel.org>; Fri, 07 Jul 2017 10:35:41 -0700 (PDT)
In-Reply-To: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for a bpf_redirect helper function to the XDP
infrastructure. For now this only supports redirecting to the egress
path of a port.

In order to support drivers handling a xdp_buff natively this patches
uses a new ndo operation ndo_xdp_xmit() that takes pushes a xdp_buff
to the specified device.

If the program specifies either (a) an unknown device or (b) a device
that does not support the operation a BPF warning is thrown and the
XDP_ABORTED error code is returned.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/filter.h    |    4 +++
 include/linux/netdevice.h |    6 +++++
 include/uapi/linux/bpf.h  |    1 +
 net/core/filter.c         |   53 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 64 insertions(+)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 1fa26dc..d0a1279 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -667,7 +667,11 @@ int sk_get_filter(struct sock *sk, struct sock_filter __user *filter,
 
 struct bpf_prog *bpf_patch_insn_single(struct bpf_prog *prog, u32 off,
 				       const struct bpf_insn *patch, u32 len);
+
+int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp);
+
 void bpf_warn_invalid_xdp_action(u32 act);
+void bpf_warn_invalid_xdp_redirect(u32 ifindex);
 
 #ifdef CONFIG_BPF_JIT
 extern int bpf_jit_enable;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 85f01d6..49e8c12 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -66,6 +66,7 @@
 /* UDP Tunnel offloads */
 struct udp_tunnel_info;
 struct bpf_prog;
+struct xdp_buff;
 
 void netdev_set_default_ethtool_ops(struct net_device *dev,
 				    const struct ethtool_ops *ops);
@@ -1138,6 +1139,9 @@ struct xfrmdev_ops {
  * int (*ndo_xdp)(struct net_device *dev, struct netdev_xdp *xdp);
  *	This function is used to set or query state related to XDP on the
  *	netdevice. See definition of enum xdp_netdev_command for details.
+ * int (*ndo_xdp_xmit)(struct net_device *dev, struct xdp_buff *xdp);
+ *	This function is used to submit a XDP packet for transmit on a
+ *	netdevice.
  *
  */
 struct net_device_ops {
@@ -1323,6 +1327,8 @@ struct net_device_ops {
 						       int needed_headroom);
 	int			(*ndo_xdp)(struct net_device *dev,
 					   struct netdev_xdp *xdp);
+	int			(*ndo_xdp_xmit)(struct net_device *dev,
+						struct xdp_buff *xdp);
 };
 
 /**
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index f94b48b..e1f3827 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -689,6 +689,7 @@ enum xdp_action {
 	XDP_DROP,
 	XDP_PASS,
 	XDP_TX,
+	XDP_REDIRECT,
 };
 
 /* user accessible metadata for XDP packet hook
diff --git a/net/core/filter.c b/net/core/filter.c
index b39c869..5c9fe3e 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2298,6 +2298,51 @@ static int bpf_skb_trim_rcsum(struct sk_buff *skb, unsigned int new_len)
 	.arg2_type	= ARG_ANYTHING,
 };
 
+static int __bpf_tx_xdp(struct net_device *dev, struct xdp_buff *xdp)
+{
+	if (dev->netdev_ops->ndo_xdp_xmit) {
+		dev->netdev_ops->ndo_xdp_xmit(dev, xdp);
+		return 0;
+	}
+	bpf_warn_invalid_xdp_redirect(dev->ifindex);
+	return -EOPNOTSUPP;
+}
+
+int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp)
+{
+	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
+
+	dev = dev_get_by_index_rcu(dev_net(dev), ri->ifindex);
+	ri->ifindex = 0;
+	if (unlikely(!dev)) {
+		bpf_warn_invalid_xdp_redirect(ri->ifindex);
+		return -EINVAL;
+	}
+
+	return __bpf_tx_xdp(dev, xdp);
+}
+EXPORT_SYMBOL_GPL(xdp_do_redirect);
+
+BPF_CALL_2(bpf_xdp_redirect, u32, ifindex, u64, flags)
+{
+	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
+
+	if (unlikely(flags))
+		return XDP_ABORTED;
+
+	ri->ifindex = ifindex;
+	ri->flags = flags;
+	return XDP_REDIRECT;
+}
+
+static const struct bpf_func_proto bpf_xdp_redirect_proto = {
+	.func           = bpf_xdp_redirect,
+	.gpl_only       = false,
+	.ret_type       = RET_INTEGER,
+	.arg1_type      = ARG_ANYTHING,
+	.arg2_type      = ARG_ANYTHING,
+};
+
 bool bpf_helper_changes_pkt_data(void *func)
 {
 	if (func == bpf_skb_vlan_push ||
@@ -2790,6 +2835,8 @@ static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
 		return &bpf_get_smp_processor_id_proto;
 	case BPF_FUNC_xdp_adjust_head:
 		return &bpf_xdp_adjust_head_proto;
+	case BPF_FUNC_redirect:
+		return &bpf_xdp_redirect_proto;
 	default:
 		return bpf_base_func_proto(func_id);
 	}
@@ -3110,6 +3157,12 @@ void bpf_warn_invalid_xdp_action(u32 act)
 }
 EXPORT_SYMBOL_GPL(bpf_warn_invalid_xdp_action);
 
+void bpf_warn_invalid_xdp_redirect(u32 ifindex)
+{
+	WARN_ONCE(1, "Illegal XDP redirect to unsupported device ifindex(%i)\n", ifindex);
+}
+EXPORT_SYMBOL_GPL(bpf_warn_invalid_xdp_redirect);
+
 static u32 bpf_convert_ctx_access(enum bpf_access_type type,
 				  const struct bpf_insn *si,
 				  struct bpf_insn *insn_buf,
