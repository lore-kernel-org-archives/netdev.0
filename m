From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 03/12] xdp: add bpf_redirect helper function
Date: Mon, 17 Jul 2017 09:27:07 -0700
Message-ID: <20170717162707.24315.96244.stgit@john-Precision-Tower-5810>
References: <20170717160759.24315.7464.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ast@fb.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com, brouer@redhat.com, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36286 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751284AbdGQQ1W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 12:27:22 -0400
Received: by mail-pf0-f195.google.com with SMTP id a11so3821692pfj.3
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 09:27:22 -0700 (PDT)
In-Reply-To: <20170717160759.24315.7464.stgit@john-Precision-Tower-5810>
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
Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/linux/filter.h    |    4 +++
 include/linux/netdevice.h |    6 +++++
 include/uapi/linux/bpf.h  |    1 +
 net/core/filter.c         |   52 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 63 insertions(+)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index bfef1e5..64cae7a 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -711,7 +711,11 @@ int sk_get_filter(struct sock *sk, struct sock_filter __user *filter,
 
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
index 779b235..77f5376 100644
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
index e99e3e6..4dbb7a3 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -717,6 +717,7 @@ enum xdp_action {
 	XDP_DROP,
 	XDP_PASS,
 	XDP_TX,
+	XDP_REDIRECT,
 };
 
 /* user accessible metadata for XDP packet hook
diff --git a/net/core/filter.c b/net/core/filter.c
index c7f7370..d606a66 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2412,6 +2412,51 @@ static int bpf_skb_trim_rcsum(struct sk_buff *skb, unsigned int new_len)
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
@@ -3011,6 +3056,8 @@ static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
 		return &bpf_get_smp_processor_id_proto;
 	case BPF_FUNC_xdp_adjust_head:
 		return &bpf_xdp_adjust_head_proto;
+	case BPF_FUNC_redirect:
+		return &bpf_xdp_redirect_proto;
 	default:
 		return bpf_base_func_proto(func_id);
 	}
@@ -3310,6 +3357,11 @@ void bpf_warn_invalid_xdp_action(u32 act)
 }
 EXPORT_SYMBOL_GPL(bpf_warn_invalid_xdp_action);
 
+void bpf_warn_invalid_xdp_redirect(u32 ifindex)
+{
+	WARN_ONCE(1, "Illegal XDP redirect to unsupported device ifindex(%i)\n", ifindex);
+}
+
 static bool __is_valid_sock_ops_access(int off, int size)
 {
 	if (off < 0 || off >= sizeof(struct bpf_sock_ops))
