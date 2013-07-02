From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2] nlmon: use standard rtnetlink link api for add/del devices
Date: Tue,  2 Jul 2013 10:55:31 +0200
Message-ID: <1372755331-1267-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, dborkman@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:38359 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753612Ab3GBIzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 04:55:38 -0400
Received: by mail-wg0-f45.google.com with SMTP id j13so4592131wgh.12
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 01:55:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is not nice when netdev is created right after module load and with
some implicit name. So rather change nlmon to use standard rtnl link API.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>

---
v1->v2: added forgotten nt.dev initialization

 drivers/net/nlmon.c | 49 ++++++++++++++++++++++++++++---------------------
 1 file changed, 28 insertions(+), 21 deletions(-)

diff --git a/drivers/net/nlmon.c b/drivers/net/nlmon.c
index a0baf56..b57ce5f 100644
--- a/drivers/net/nlmon.c
+++ b/drivers/net/nlmon.c
@@ -4,6 +4,7 @@
 #include <linux/netlink.h>
 #include <net/net_namespace.h>
 #include <linux/if_arp.h>
+#include <net/rtnetlink.h>
 
 struct pcpu_lstats {
 	u64 packets;
@@ -56,16 +57,24 @@ static void nlmon_dev_uninit(struct net_device *dev)
 	free_percpu(dev->lstats);
 }
 
-static struct netlink_tap nlmon_tap;
+struct nlmon {
+	struct netlink_tap nt;
+};
 
 static int nlmon_open(struct net_device *dev)
 {
-	return netlink_add_tap(&nlmon_tap);
+	struct nlmon *nlmon = netdev_priv(dev);
+
+	nlmon->nt.dev = dev;
+	nlmon->nt.module = THIS_MODULE;
+	return netlink_add_tap(&nlmon->nt);
 }
 
 static int nlmon_close(struct net_device *dev)
 {
-	return netlink_remove_tap(&nlmon_tap);
+	struct nlmon *nlmon = netdev_priv(dev);
+
+	return netlink_remove_tap(&nlmon->nt);
 }
 
 static struct rtnl_link_stats64 *
@@ -119,10 +128,6 @@ static const struct net_device_ops nlmon_ops = {
 	.ndo_change_mtu = nlmon_change_mtu,
 };
 
-static struct netlink_tap nlmon_tap __read_mostly = {
-	.module = THIS_MODULE,
-};
-
 static void nlmon_setup(struct net_device *dev)
 {
 	dev->type = ARPHRD_NETLINK;
@@ -142,27 +147,28 @@ static void nlmon_setup(struct net_device *dev)
 	dev->mtu = NLMSG_GOODSIZE;
 }
 
-static __init int nlmon_register(void)
+static int nlmon_validate(struct nlattr *tb[], struct nlattr *data[])
 {
-	int err;
-	struct net_device *nldev;
-
-	nldev = nlmon_tap.dev = alloc_netdev(0, "netlink", nlmon_setup);
-	if (unlikely(nldev == NULL))
-		return -ENOMEM;
+	if (tb[IFLA_ADDRESS])
+		return -EINVAL;
+	return 0;
+}
 
-	err = register_netdev(nldev);
-	if (unlikely(err))
-		free_netdev(nldev);
+static struct rtnl_link_ops nlmon_link_ops __read_mostly = {
+	.kind			= "nlmon",
+	.priv_size		= sizeof(struct nlmon),
+	.setup			= nlmon_setup,
+	.validate		= nlmon_validate,
+};
 
-	return err;
+static __init int nlmon_register(void)
+{
+	return rtnl_link_register(&nlmon_link_ops);
 }
 
 static __exit void nlmon_unregister(void)
 {
-	struct net_device *nldev = nlmon_tap.dev;
-
-	unregister_netdev(nldev);
+	rtnl_link_unregister(&nlmon_link_ops);
 }
 
 module_init(nlmon_register);
@@ -172,3 +178,4 @@ MODULE_LICENSE("GPL v2");
 MODULE_AUTHOR("Daniel Borkmann <dborkman@redhat.com>");
 MODULE_AUTHOR("Mathieu Geli <geli@enseirb.fr>");
 MODULE_DESCRIPTION("Netlink monitoring device");
+MODULE_ALIAS_RTNL_LINK("nlmon");
-- 
1.8.1.4
