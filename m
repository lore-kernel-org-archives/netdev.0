From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] bridge: Assign rtnl_link_ops to bridge devices created via
 ioctl (v2)
Date: Tue, 26 Jun 2012 08:48:45 -0700
Message-ID: <20120626084845.0578fcb8@nehalam.linuxnetplumber.net>
References: <692d04316b78401b0256598155caae190d3f27c9.1340700973.git.tgraf@suug.ch>
	<20120626075940.099521a7@nehalam.linuxnetplumber.net>
	<20120626151311.GB31808@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37043 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758580Ab2FZPsz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 11:48:55 -0400
In-Reply-To: <20120626151311.GB31808@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ensures that bridges created with brctl(8) or ioctl(2) directly
also carry IFLA_LINKINFO when dumped over netlink. This also allows
to create a bridge with ioctl(2) and delete it with RTM_DELLINK.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
v2 - Minor change to Thomas's original patch.
This is a bug fix, should go to stable as well.

 net/bridge/br_if.c      |    1 +
 net/bridge/br_netlink.c |    2 +-
 net/bridge/br_private.h |    1 +
 3 files changed, 3 insertions(+), 1 deletion(-)

--- a/net/bridge/br_netlink.c	2012-06-26 08:07:18.459760113 -0700
+++ b/net/bridge/br_netlink.c	2012-06-26 08:30:16.729918150 -0700
@@ -208,7 +208,7 @@ static int br_validate(struct nlattr *tb
 	return 0;
 }
 
-static struct rtnl_link_ops br_link_ops __read_mostly = {
+struct rtnl_link_ops br_link_ops __read_mostly = {
 	.kind		= "bridge",
 	.priv_size	= sizeof(struct net_bridge),
 	.setup		= br_dev_setup,
--- a/net/bridge/br_private.h	2012-06-26 08:07:18.459760113 -0700
+++ b/net/bridge/br_private.h	2012-06-26 08:30:16.729918150 -0700
@@ -549,6 +549,7 @@ extern int (*br_fdb_test_addr_hook)(stru
 #endif
 
 /* br_netlink.c */
+extern struct rtnl_link_ops br_link_ops;
 extern int br_netlink_init(void);
 extern void br_netlink_fini(void);
 extern void br_ifinfo_notify(int event, struct net_bridge_port *port);
--- a/net/bridge/br_if.c	2012-06-26 08:07:18.459760113 -0700
+++ b/net/bridge/br_if.c	2012-06-26 08:30:37.653708011 -0700
@@ -240,6 +240,7 @@ int br_add_bridge(struct net *net, const
 		return -ENOMEM;
 
 	dev_net_set(dev, net);
+	dev->rtnl_link_ops = &br_link_ops;
 
 	res = register_netdev(dev);
 	if (res)
