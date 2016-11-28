From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf, xdp: allow to pass flags to dev_change_xdp_fd
Date: Mon, 28 Nov 2016 23:16:54 +0100
Message-ID: <cd0871f11c476f8d7fee1cb356940a13cf7d4807.1480370617.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54657 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751660AbcK1WQ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 17:16:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an IFLA_XDP_FLAGS attribute that can be passed for setting up
XDP along with IFLA_XDP_FD, which eventually allows user space to
implement typical add/replace/delete logic for programs. Right now,
calling into dev_change_xdp_fd() will always replace previous programs.

When passed XDP_FLAGS_UPDATE_IF_NOEXIST, we can handle this more
graceful when requested by returning -EBUSY in case we try to
attach a new program, but we find that another one is already
attached. This will be used by upcoming front-end for iproute2 as
well.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/netdevice.h    |  2 +-
 include/uapi/linux/if_link.h |  4 ++++
 net/core/dev.c               | 20 ++++++++++++++++++--
 net/core/rtnetlink.c         | 14 +++++++++++++-
 4 files changed, 36 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4ffcd87..3755317 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3253,7 +3253,7 @@ int dev_get_phys_port_id(struct net_device *dev,
 int dev_get_phys_port_name(struct net_device *dev,
 			   char *name, size_t len);
 int dev_change_proto_down(struct net_device *dev, bool proto_down);
-int dev_change_xdp_fd(struct net_device *dev, int fd);
+int dev_change_xdp_fd(struct net_device *dev, int fd, u32 flags);
 struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *dev);
 struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 				    struct netdev_queue *txq, int *ret);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 92b2d49..6b13e59 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -876,10 +876,14 @@ enum {
 
 /* XDP section */
 
+#define XDP_FLAGS_UPDATE_IF_NOEXIST	(1U << 0)
+#define XDP_FLAGS_MASK			(XDP_FLAGS_UPDATE_IF_NOEXIST)
+
 enum {
 	IFLA_XDP_UNSPEC,
 	IFLA_XDP_FD,
 	IFLA_XDP_ATTACHED,
+	IFLA_XDP_FLAGS,
 	__IFLA_XDP_MAX,
 };
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 048b46b..a44aefe 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6692,26 +6692,42 @@ int dev_change_proto_down(struct net_device *dev, bool proto_down)
  *	dev_change_xdp_fd - set or clear a bpf program for a device rx path
  *	@dev: device
  *	@fd: new program fd or negative value to clear
+ *	@flags: xdp-related flags
  *
  *	Set or clear a bpf program for a device
  */
-int dev_change_xdp_fd(struct net_device *dev, int fd)
+int dev_change_xdp_fd(struct net_device *dev, int fd, u32 flags)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 	struct bpf_prog *prog = NULL;
-	struct netdev_xdp xdp = {};
+	struct netdev_xdp xdp;
 	int err;
 
+	ASSERT_RTNL();
+
 	if (!ops->ndo_xdp)
 		return -EOPNOTSUPP;
 	if (fd >= 0) {
+		if (flags & XDP_FLAGS_UPDATE_IF_NOEXIST) {
+			memset(&xdp, 0, sizeof(xdp));
+			xdp.command = XDP_QUERY_PROG;
+
+			err = ops->ndo_xdp(dev, &xdp);
+			if (err < 0)
+				return err;
+			if (xdp.prog_attached)
+				return -EBUSY;
+		}
+
 		prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_XDP);
 		if (IS_ERR(prog))
 			return PTR_ERR(prog);
 	}
 
+	memset(&xdp, 0, sizeof(xdp));
 	xdp.command = XDP_SETUP_PROG;
 	xdp.prog = prog;
+
 	err = ops->ndo_xdp(dev, &xdp);
 	if (err < 0 && prog)
 		bpf_prog_put(prog);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 4e60525..bd85570 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1505,6 +1505,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 static const struct nla_policy ifla_xdp_policy[IFLA_XDP_MAX + 1] = {
 	[IFLA_XDP_FD]		= { .type = NLA_S32 },
 	[IFLA_XDP_ATTACHED]	= { .type = NLA_U8 },
+	[IFLA_XDP_FLAGS]	= { .type = NLA_U32 },
 };
 
 static const struct rtnl_link_ops *linkinfo_to_kind_ops(const struct nlattr *nla)
@@ -2164,6 +2165,7 @@ static int do_setlink(const struct sk_buff *skb,
 
 	if (tb[IFLA_XDP]) {
 		struct nlattr *xdp[IFLA_XDP_MAX + 1];
+		u32 xdp_flags = 0;
 
 		err = nla_parse_nested(xdp, IFLA_XDP_MAX, tb[IFLA_XDP],
 				       ifla_xdp_policy);
@@ -2174,9 +2176,19 @@ static int do_setlink(const struct sk_buff *skb,
 			err = -EINVAL;
 			goto errout;
 		}
+
+		if (xdp[IFLA_XDP_FLAGS]) {
+			xdp_flags = nla_get_u32(xdp[IFLA_XDP_FLAGS]);
+			if (xdp_flags & ~XDP_FLAGS_MASK) {
+				err = -EINVAL;
+				goto errout;
+			}
+		}
+
 		if (xdp[IFLA_XDP_FD]) {
 			err = dev_change_xdp_fd(dev,
-						nla_get_s32(xdp[IFLA_XDP_FD]));
+						nla_get_s32(xdp[IFLA_XDP_FD]),
+						xdp_flags);
 			if (err)
 				goto errout;
 			status |= DO_SETLINK_NOTIFY;
-- 
1.9.3
