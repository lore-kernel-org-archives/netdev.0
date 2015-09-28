From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 03/11] net: Add support for l3mdev ops to VRF driver
Date: Mon, 28 Sep 2015 10:16:53 -0700
Message-ID: <1443460621-24855-4-git-send-email-dsa@cumulusnetworks.com>
References: <1443460621-24855-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33331 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934374AbbI1RRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 13:17:15 -0400
Received: by pacex6 with SMTP id ex6so179727478pac.0
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 10:17:15 -0700 (PDT)
In-Reply-To: <1443460621-24855-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/Kconfig |  1 +
 drivers/net/vrf.c   | 29 +++++++++++++++++++++++++++++
 2 files changed, 30 insertions(+)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index d18eb607bee6..b9ebd0d18a52 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -299,6 +299,7 @@ config NLMON
 config NET_VRF
 	tristate "Virtual Routing and Forwarding (Lite)"
 	depends on IP_MULTIPLE_TABLES && IPV6_MULTIPLE_TABLES
+	depends on NET_L3_MASTER_DEV
 	---help---
 	  This option enables the support for mapping interfaces into VRF's. The
 	  support enables VRF devices.
diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 2d7418e0b908..72f1892ebad0 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -35,6 +35,7 @@
 #include <net/route.h>
 #include <net/addrconf.h>
 #include <net/vrf.h>
+#include <net/l3mdev.h>
 
 #define DRV_NAME	"vrf"
 #define DRV_VERSION	"1.0"
@@ -529,6 +530,33 @@ static const struct net_device_ops vrf_netdev_ops = {
 	.ndo_del_slave		= vrf_del_slave,
 };
 
+static u32 vrf_fib_table(const struct net_device *dev)
+{
+	struct net_vrf *vrf = netdev_priv(dev);
+
+	return vrf->tb_id;
+}
+
+static struct rtable *vrf_get_rtable(const struct net_device *dev,
+				     const struct flowi4 *fl4)
+{
+	struct rtable *rth = NULL;
+
+	if (!(fl4->flowi4_flags & FLOWI_FLAG_VRFSRC)) {
+		struct net_vrf *vrf = netdev_priv(dev);
+
+		rth = vrf->rth;
+		atomic_inc(&rth->dst.__refcnt);
+	}
+
+	return rth;
+}
+
+static const struct l3mdev_ops vrf_l3mdev_ops = {
+	.l3mdev_fib_table	= vrf_fib_table,
+	.l3mdev_get_rtable	= vrf_get_rtable,
+};
+
 static void vrf_get_drvinfo(struct net_device *dev,
 			    struct ethtool_drvinfo *info)
 {
@@ -546,6 +574,7 @@ static void vrf_setup(struct net_device *dev)
 
 	/* Initialize the device structure. */
 	dev->netdev_ops = &vrf_netdev_ops;
+	dev->l3mdev_ops = &vrf_l3mdev_ops;
 	dev->ethtool_ops = &vrf_ethtool_ops;
 	dev->destructor = free_netdev;
 
-- 
1.9.1
