From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH] dummy: add support for ethtool get_drvinfo
Date: Fri,  5 Dec 2014 22:13:24 -0200
Message-ID: <1417824804-20634-1-git-send-email-fbl@redhat.com>
Cc: Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40683 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752287AbaLFAN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2014 19:13:28 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sB60DShD030000
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Fri, 5 Dec 2014 19:13:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The command 'ethtool -i' is useful to find details
about the interface like the device driver being used.
This was missing for dummy driver.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 drivers/net/dummy.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index ff435fb..413ca4f 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -38,6 +38,9 @@
 #include <net/rtnetlink.h>
 #include <linux/u64_stats_sync.h>
 
+#define DRV_NAME	"dummy"
+#define DRV_VERSION	"1.0"
+
 static int numdummies = 1;
 
 /* fake multicast ability */
@@ -120,12 +123,24 @@ static const struct net_device_ops dummy_netdev_ops = {
 	.ndo_change_carrier	= dummy_change_carrier,
 };
 
+static void dummy_get_drvinfo(struct net_device *dev,
+			      struct ethtool_drvinfo *info)
+{
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+}
+
+static const struct ethtool_ops dummy_ethtool_ops = {
+	.get_drvinfo            = dummy_get_drvinfo,
+};
+
 static void dummy_setup(struct net_device *dev)
 {
 	ether_setup(dev);
 
 	/* Initialize the device structure. */
 	dev->netdev_ops = &dummy_netdev_ops;
+	dev->ethtool_ops = &dummy_ethtool_ops;
 	dev->destructor = free_netdev;
 
 	/* Fill in device structure with ethernet-generic values. */
@@ -150,7 +165,7 @@ static int dummy_validate(struct nlattr *tb[], struct nlattr *data[])
 }
 
 static struct rtnl_link_ops dummy_link_ops __read_mostly = {
-	.kind		= "dummy",
+	.kind		= DRV_NAME,
 	.setup		= dummy_setup,
 	.validate	= dummy_validate,
 };
@@ -209,4 +224,4 @@ static void __exit dummy_cleanup_module(void)
 module_init(dummy_init_module);
 module_exit(dummy_cleanup_module);
 MODULE_LICENSE("GPL");
-MODULE_ALIAS_RTNL_LINK("dummy");
+MODULE_ALIAS_RTNL_LINK(DRV_NAME);
-- 
1.9.3
