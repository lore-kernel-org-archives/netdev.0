From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 2/4] xdp: propagate extended ack to XDP setup
Date: Sun, 30 Apr 2017 21:46:46 -0700
Message-ID: <20170501044648.13022-3-jakub.kicinski@netronome.com>
References: <20170501044648.13022-1-jakub.kicinski@netronome.com>
Cc: davem@davemloft.net, johannes@sipsolutions.net,
        dsa@cumulusnetworks.com, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, bblanco@gmail.com,
        john.fastabend@gmail.com, kubakici@wp.pl,
        oss-drivers@netronome.com, brouer@redhat.com, jhs@mojatatu.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:34604 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951834AbdEAErR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 00:47:17 -0400
Received: by mail-pg0-f54.google.com with SMTP id v1so41039782pgv.1
        for <netdev@vger.kernel.org>; Sun, 30 Apr 2017 21:47:16 -0700 (PDT)
In-Reply-To: <20170501044648.13022-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers usually have a number of restrictions for running XDP
- most common being buffer sizes, LRO and number of rings.
Even though some drivers try to be helpful and print error
messages experience shows that users don't often consult
kernel logs on netlink errors.  Try to use the new extended
ack mechanism to carry the message back to user space.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 include/linux/netdevice.h | 10 ++++++++--
 net/core/dev.c            |  5 ++++-
 net/core/rtnetlink.c      | 13 ++++++++-----
 3 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6847714a5ae3..9c23bd2efb56 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -813,11 +813,16 @@ enum xdp_netdev_command {
 	XDP_QUERY_PROG,
 };
 
+struct netlink_ext_ack;
+
 struct netdev_xdp {
 	enum xdp_netdev_command command;
 	union {
 		/* XDP_SETUP_PROG */
-		struct bpf_prog *prog;
+		struct {
+			struct bpf_prog *prog;
+			struct netlink_ext_ack *extack;
+		};
 		/* XDP_QUERY_PROG */
 		bool prog_attached;
 	};
@@ -3291,7 +3296,8 @@ int dev_get_phys_port_id(struct net_device *dev,
 int dev_get_phys_port_name(struct net_device *dev,
 			   char *name, size_t len);
 int dev_change_proto_down(struct net_device *dev, bool proto_down);
-int dev_change_xdp_fd(struct net_device *dev, int fd, u32 flags);
+int dev_change_xdp_fd(struct net_device *dev, struct netlink_ext_ack *extack,
+		      int fd, u32 flags);
 struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *dev);
 struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 				    struct netdev_queue *txq, int *ret);
diff --git a/net/core/dev.c b/net/core/dev.c
index 8371a01eee87..35a06cebb282 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6854,12 +6854,14 @@ EXPORT_SYMBOL(dev_change_proto_down);
 /**
  *	dev_change_xdp_fd - set or clear a bpf program for a device rx path
  *	@dev: device
+ *	@extact: netlink extended ack
  *	@fd: new program fd or negative value to clear
  *	@flags: xdp-related flags
  *
  *	Set or clear a bpf program for a device
  */
-int dev_change_xdp_fd(struct net_device *dev, int fd, u32 flags)
+int dev_change_xdp_fd(struct net_device *dev, struct netlink_ext_ack *extack,
+		      int fd, u32 flags)
 {
 	int (*xdp_op)(struct net_device *dev, struct netdev_xdp *xdp);
 	const struct net_device_ops *ops = dev->netdev_ops;
@@ -6892,6 +6894,7 @@ int dev_change_xdp_fd(struct net_device *dev, int fd, u32 flags)
 
 	memset(&xdp, 0, sizeof(xdp));
 	xdp.command = XDP_SETUP_PROG;
+	xdp.extack = extack;
 	xdp.prog = prog;
 
 	err = xdp_op(dev, &xdp);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9031a6c8bfa7..6e67315ec368 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1919,6 +1919,7 @@ static int do_set_master(struct net_device *dev, int ifindex)
 #define DO_SETLINK_NOTIFY	0x03
 static int do_setlink(const struct sk_buff *skb,
 		      struct net_device *dev, struct ifinfomsg *ifm,
+		      struct netlink_ext_ack *extack,
 		      struct nlattr **tb, char *ifname, int status)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
@@ -2201,7 +2202,7 @@ static int do_setlink(const struct sk_buff *skb,
 		}
 
 		if (xdp[IFLA_XDP_FD]) {
-			err = dev_change_xdp_fd(dev,
+			err = dev_change_xdp_fd(dev, extack,
 						nla_get_s32(xdp[IFLA_XDP_FD]),
 						xdp_flags);
 			if (err)
@@ -2261,7 +2262,7 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (err < 0)
 		goto errout;
 
-	err = do_setlink(skb, dev, ifm, tb, ifname, 0);
+	err = do_setlink(skb, dev, ifm, extack, tb, ifname, 0);
 errout:
 	return err;
 }
@@ -2423,6 +2424,7 @@ EXPORT_SYMBOL(rtnl_create_link);
 static int rtnl_group_changelink(const struct sk_buff *skb,
 		struct net *net, int group,
 		struct ifinfomsg *ifm,
+		struct netlink_ext_ack *extack,
 		struct nlattr **tb)
 {
 	struct net_device *dev, *aux;
@@ -2430,7 +2432,7 @@ static int rtnl_group_changelink(const struct sk_buff *skb,
 
 	for_each_netdev_safe(net, dev, aux) {
 		if (dev->group == group) {
-			err = do_setlink(skb, dev, ifm, tb, NULL, 0);
+			err = do_setlink(skb, dev, ifm, extack, tb, NULL, 0);
 			if (err < 0)
 				return err;
 		}
@@ -2576,14 +2578,15 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 				status |= DO_SETLINK_NOTIFY;
 			}
 
-			return do_setlink(skb, dev, ifm, tb, ifname, status);
+			return do_setlink(skb, dev, ifm, extack, tb, ifname,
+					  status);
 		}
 
 		if (!(nlh->nlmsg_flags & NLM_F_CREATE)) {
 			if (ifm->ifi_index == 0 && tb[IFLA_GROUP])
 				return rtnl_group_changelink(skb, net,
 						nla_get_u32(tb[IFLA_GROUP]),
-						ifm, tb);
+						ifm, extack, tb);
 			return -ENODEV;
 		}
 
-- 
2.11.0
