From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net v2 2/2] xdp: refine xdp api with regards to generic xdp
Date: Fri, 12 May 2017 01:04:46 +0200
Message-ID: <fe08e3c98d6c473d77b14a323abbd41c1e7d8f6d.1494542162.git.daniel@iogearbox.net>
References: <cover.1494542162.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, kubakici@wp.pl,
        john.fastabend@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59589 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756531AbdEKXE5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 19:04:57 -0400
In-Reply-To: <cover.1494542162.git.daniel@iogearbox.net>
In-Reply-To: <cover.1494542162.git.daniel@iogearbox.net>
References: <cover.1494542162.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While working on the iproute2 generic XDP frontend, I noticed that
as of right now it's possible to have native *and* generic XDP
programs loaded both at the same time for the case when a driver
supports native XDP.

The intended model for generic XDP from b5cdae3291f7 ("net: Generic
XDP") is, however, that only one out of the two can be present at
once which is also indicated as such in the XDP netlink dump part.
The main rationale for generic XDP is to ease accessibility (in
case a driver does not yet have XDP support) and to generically
provide a semantical model as an example for driver developers
wanting to add XDP support. The generic XDP option for an XDP
aware driver can still be useful for comparing and testing both
implementations.

However, it is not intended to have a second XDP processing stage
or layer with exactly the same functionality of the first native
stage. Only reason could be to have a partial fallback for future
XDP features that are not supported yet in the native implementation
and we probably also shouldn't strive for such fallback and instead
encourage native feature support in the first place. Given there's
currently no such fallback issue or use case, lets not go there yet
if we don't need to.

Therefore, change semantics for loading XDP and bail out if the
user tries to load a generic XDP program when a native one is
present and vice versa. Another alternative to bailing out would
be to handle the transition from one flavor to another gracefully,
but that would require to bring the device down, exchange both
types of programs, and bring it up again in order to avoid a tiny
window where a packet could hit both hooks. Given this complicates
the logic for just a debugging feature in the native case, I went
with the simpler variant.

For the dump, remove IFLA_XDP_FLAGS that was added with b5cdae3291f7
and reuse IFLA_XDP_ATTACHED for indicating the mode. Dumping all
or just a subset of flags that were used for loading the XDP prog
is suboptimal in the long run since not all flags are useful for
dumping and if we start to reuse the same flag definitions for
load and dump, then we'll waste bit space. What we really just
want is to dump the mode for now.

Current IFLA_XDP_ATTACHED semantics are: nothing was installed (0),
a program is running at the native driver layer (1). Thus, add a
mode that says that a program is running at generic XDP layer (2).
Applications will handle this fine in that older binaries will
just indicate that something is attached at XDP layer, effectively
this is similar to IFLA_XDP_FLAGS attr that we would have had
modulo the redundancy.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/netdevice.h    |  8 +++++--
 include/uapi/linux/if_link.h |  7 ++++++
 net/core/dev.c               | 55 +++++++++++++++++++++++++++++---------------
 net/core/rtnetlink.c         | 40 +++++++++++++++-----------------
 4 files changed, 67 insertions(+), 43 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9c23bd2..3f39d27 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3296,11 +3296,15 @@ int dev_get_phys_port_id(struct net_device *dev,
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
 int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
 int dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
 bool is_skb_forwardable(const struct net_device *dev,
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 549ac8a..15ac203 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -894,6 +894,13 @@ enum {
 					 XDP_FLAGS_SKB_MODE | \
 					 XDP_FLAGS_DRV_MODE)
 
+/* These are stored into IFLA_XDP_ATTACHED on dump. */
+enum {
+	XDP_ATTACHED_NONE = 0,
+	XDP_ATTACHED_DRV,
+	XDP_ATTACHED_SKB,
+};
+
 enum {
 	IFLA_XDP_UNSPEC,
 	IFLA_XDP_FD,
diff --git a/net/core/dev.c b/net/core/dev.c
index e56cb71..fca407b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6852,6 +6852,32 @@ int dev_change_proto_down(struct net_device *dev, bool proto_down)
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
@@ -6864,43 +6890,34 @@ int dev_change_proto_down(struct net_device *dev, bool proto_down)
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
index dda9f16..d7f82c3 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -899,8 +899,7 @@ static size_t rtnl_port_size(const struct net_device *dev,
 static size_t rtnl_xdp_size(void)
 {
 	size_t xdp_size = nla_total_size(0) +	/* nest IFLA_XDP */
-			  nla_total_size(1) +	/* XDP_ATTACHED */
-			  nla_total_size(4);	/* XDP_FLAGS */
+			  nla_total_size(1);	/* XDP_ATTACHED */
 
 	return xdp_size;
 }
@@ -1247,37 +1246,34 @@ static int rtnl_fill_link_ifmap(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static u8 rtnl_xdp_attached_mode(struct net_device *dev)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	ASSERT_RTNL();
+
+	if (rcu_access_pointer(dev->xdp_prog))
+		return XDP_ATTACHED_SKB;
+	if (ops->ndo_xdp && __dev_xdp_attached(dev, ops->ndo_xdp))
+		return XDP_ATTACHED_DRV;
+
+	return XDP_ATTACHED_NONE;
+}
+
 static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
 {
 	struct nlattr *xdp;
-	u32 xdp_flags = 0;
-	u8 val = 0;
 	int err;
 
 	xdp = nla_nest_start(skb, IFLA_XDP);
 	if (!xdp)
 		return -EMSGSIZE;
-	if (rcu_access_pointer(dev->xdp_prog)) {
-		xdp_flags = XDP_FLAGS_SKB_MODE;
-		val = 1;
-	} else if (dev->netdev_ops->ndo_xdp) {
-		struct netdev_xdp xdp_op = {};
-
-		xdp_op.command = XDP_QUERY_PROG;
-		err = dev->netdev_ops->ndo_xdp(dev, &xdp_op);
-		if (err)
-			goto err_cancel;
-		val = xdp_op.prog_attached;
-	}
-	err = nla_put_u8(skb, IFLA_XDP_ATTACHED, val);
+
+	err = nla_put_u8(skb, IFLA_XDP_ATTACHED,
+			 rtnl_xdp_attached_mode(dev));
 	if (err)
 		goto err_cancel;
 
-	if (xdp_flags) {
-		err = nla_put_u32(skb, IFLA_XDP_FLAGS, xdp_flags);
-		if (err)
-			goto err_cancel;
-	}
 	nla_nest_end(skb, xdp);
 	return 0;
 
-- 
1.9.3
