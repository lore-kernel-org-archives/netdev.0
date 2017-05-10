From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 2/2] xdp: disallow use of native and generic hook at once
Date: Wed, 10 May 2017 03:31:31 +0200
Message-ID: <f8405a8769dca09a0f21d11eab3793e30f608531.1494379046.git.daniel@iogearbox.net>
References: <cover.1494379046.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54341 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751060AbdEJBbg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 21:31:36 -0400
In-Reply-To: <cover.1494379046.git.daniel@iogearbox.net>
In-Reply-To: <cover.1494379046.git.daniel@iogearbox.net>
References: <cover.1494379046.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While working on the iproute2 generic XDP frontend, I noticed that
as of right now it's possible to have native *and* generic XDP
programs loaded both at the same time for the case when a driver
supports native XDP.

The intended model for generic XDP from b5cdae3291f7 ("net: Generic
XDP") is, however, that only one out of the two can be present at
once which is also indicated as such in the XPD netlink dump part.
The main rationale for generic XDP is to ease accessibility (in
case a driver does not yet have XDP support) and to generically
provide a semantical model as an example for driver developers
wanting to add XDP support. The generic XDP option for an XDP
aware driver can still be useful for comparing and testing both
implementations.

However, it is not intended to have a second XDP processing stage
or layer with exactly the same functionality of the first native
stage. Only reason would be to have a partial fallback for future
XDP features that are not supported yet in the native implementation
and we probably also shouldn't strive for such fallback and instead
encourage native feature support in the first place. Given there's
currently no such fallback issue or use case, lets not go there
yet if we don't need to.

Therefore, change semantics for loading XDP and bail out if the
user tries to load a generic XDP program when a native one is
present and vice versa. Another alternative to bailing out would
be to handle the transition from one flavor to another gracefully,
but that would require to bring the device down, exchange both
types of programs, and bring it up again in order to avoid a tiny
window where a packet could hit both hooks. Given this complicates
the logic a bit more for just a debugging feature, I went with the
simpler variant.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/netdevice.h | 15 +++++++++++--
 net/core/dev.c            | 55 +++++++++++++++++++++++++++++++----------------
 net/core/rtnetlink.c      | 14 +++++-------
 3 files changed, 54 insertions(+), 30 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9c23bd2..abedec7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3296,11 +3296,22 @@ int dev_get_phys_port_id(struct net_device *dev,
 int dev_get_phys_port_name(struct net_device *dev,
 			   char *name, size_t len);
 int dev_change_proto_down(struct net_device *dev, bool proto_down);
-int dev_change_xdp_fd(struct net_device *dev, struct netlink_ext_ack *extack,
-		      int fd, u32 flags);
 struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *dev);
 struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 				    struct netdev_queue *txq, int *ret);
+
+typedef int (*xdp_op_t)(struct net_device *dev, struct netdev_xdp *xdp);
+int dev_change_xdp_fd(struct net_device *dev, struct netlink_ext_ack *extack,
+		      int fd, u32 flags);
+bool __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op);
+
+static inline bool dev_xdp_attached(struct net_device *dev)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	return ops->ndo_xdp && __dev_xdp_attached(dev, ops->ndo_xdp);
+}
+
 int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
 int dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
 bool is_skb_forwardable(const struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index 61443f0..d25f847 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6851,6 +6851,32 @@ int dev_change_proto_down(struct net_device *dev, bool proto_down)
 }
 EXPORT_SYMBOL(dev_change_proto_down);
 
+bool __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op)
+{
+	struct netdev_xdp xdp;
+
+	memset(&xdp, 0, sizeof(xdp));
+	xdp.command = XDP_QUERY_PROG;
+
+	/* Query must always succeed. */
+	WARN_ON(xdp_op(dev, &xdp) < 0);
+	return xdp.prog_attached;
+}
+
+static int dev_xdp_install(struct net_device *dev, xdp_op_t xdp_op,
+			   struct netlink_ext_ack *extack,
+			   struct bpf_prog *prog)
+{
+	struct netdev_xdp xdp;
+
+	memset(&xdp, 0, sizeof(xdp));
+	xdp.command = XDP_SETUP_PROG;
+	xdp.extack = extack;
+	xdp.prog = prog;
+
+	return xdp_op(dev, &xdp);
+}
+
 /**
  *	dev_change_xdp_fd - set or clear a bpf program for a device rx path
  *	@dev: device
@@ -6863,43 +6889,34 @@ int dev_change_proto_down(struct net_device *dev, bool proto_down)
 int dev_change_xdp_fd(struct net_device *dev, struct netlink_ext_ack *extack,
 		      int fd, u32 flags)
 {
-	int (*xdp_op)(struct net_device *dev, struct netdev_xdp *xdp);
 	const struct net_device_ops *ops = dev->netdev_ops;
 	struct bpf_prog *prog = NULL;
-	struct netdev_xdp xdp;
+	xdp_op_t xdp_op, xdp_chk;
 	int err;
 
 	ASSERT_RTNL();
 
-	xdp_op = ops->ndo_xdp;
+	xdp_op = xdp_chk = ops->ndo_xdp;
 	if (!xdp_op && (flags & XDP_FLAGS_DRV_MODE))
 		return -EOPNOTSUPP;
 	if (!xdp_op || (flags & XDP_FLAGS_SKB_MODE))
 		xdp_op = generic_xdp_install;
+	if (xdp_op == xdp_chk)
+		xdp_chk = generic_xdp_install;
 
 	if (fd >= 0) {
-		if (flags & XDP_FLAGS_UPDATE_IF_NOEXIST) {
-			memset(&xdp, 0, sizeof(xdp));
-			xdp.command = XDP_QUERY_PROG;
-
-			err = xdp_op(dev, &xdp);
-			if (err < 0)
-				return err;
-			if (xdp.prog_attached)
-				return -EBUSY;
-		}
+		if (xdp_chk && __dev_xdp_attached(dev, xdp_chk))
+			return -EEXIST;
+		if ((flags & XDP_FLAGS_UPDATE_IF_NOEXIST) &&
+		    __dev_xdp_attached(dev, xdp_op))
+			return -EBUSY;
 
 		prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_XDP);
 		if (IS_ERR(prog))
 			return PTR_ERR(prog);
 	}
 
-	memset(&xdp, 0, sizeof(xdp));
-	xdp.command = XDP_SETUP_PROG;
-	xdp.extack = extack;
-	xdp.prog = prog;
-
-	err = xdp_op(dev, &xdp);
+	err = dev_xdp_install(dev, xdp_op, extack, prog);
 	if (err < 0 && prog)
 		bpf_prog_put(prog);
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index dda9f16..99320f0 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1251,24 +1251,20 @@ static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
 {
 	struct nlattr *xdp;
 	u32 xdp_flags = 0;
-	u8 val = 0;
 	int err;
+	u8 val;
 
 	xdp = nla_nest_start(skb, IFLA_XDP);
 	if (!xdp)
 		return -EMSGSIZE;
+
 	if (rcu_access_pointer(dev->xdp_prog)) {
 		xdp_flags = XDP_FLAGS_SKB_MODE;
 		val = 1;
-	} else if (dev->netdev_ops->ndo_xdp) {
-		struct netdev_xdp xdp_op = {};
-
-		xdp_op.command = XDP_QUERY_PROG;
-		err = dev->netdev_ops->ndo_xdp(dev, &xdp_op);
-		if (err)
-			goto err_cancel;
-		val = xdp_op.prog_attached;
+	} else {
+		val = dev_xdp_attached(dev);
 	}
+
 	err = nla_put_u8(skb, IFLA_XDP_ATTACHED, val);
 	if (err)
 		goto err_cancel;
-- 
1.9.3
