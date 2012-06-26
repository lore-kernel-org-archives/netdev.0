From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] bridge: Assign rtnl_link_ops to bridge devices created via ioctl()
Date: Tue, 26 Jun 2012 10:56:15 +0200
Message-ID: <692d04316b78401b0256598155caae190d3f27c9.1340700973.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38403 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752981Ab2FZI4T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 04:56:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ensures that bridges created with brctl(8) or ioctl(2) directly
also carry IFLA_LINKINFO when dumped over netlink. This also allows
to create a bridge with ioctl(2) and delete it with RTM_DELLINK.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/bridge/br_if.c      |    1 +
 net/bridge/br_netlink.c |    5 +++++
 net/bridge/br_private.h |    1 +
 3 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 0a942fb..490aae0 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -240,6 +240,7 @@ int br_add_bridge(struct net *net, const char *name)
 		return -ENOMEM;
 
 	dev_net_set(dev, net);
+	br_assign_rtnl_link_ops(dev);
 
 	res = register_netdev(dev);
 	if (res)
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 2080485..8679b03 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -216,6 +216,11 @@ static struct rtnl_link_ops br_link_ops __read_mostly = {
 	.dellink	= br_dev_delete,
 };
 
+void br_assign_rtnl_link_ops(struct net_device *dev)
+{
+	dev->rtnl_link_ops = &br_link_ops;
+}
+
 int __init br_netlink_init(void)
 {
 	int err;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 1a8ad4f..bf205e5 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -552,6 +552,7 @@ extern int (*br_fdb_test_addr_hook)(struct net_device *dev, unsigned char *addr)
 extern int br_netlink_init(void);
 extern void br_netlink_fini(void);
 extern void br_ifinfo_notify(int event, struct net_bridge_port *port);
+extern void br_assign_rtnl_link_ops(struct net_device *dev);
 
 #ifdef CONFIG_SYSFS
 /* br_sysfs_if.c */
-- 
1.7.7.6
