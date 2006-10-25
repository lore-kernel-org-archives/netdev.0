From: Anders Grafstrom <grfstrm@users.sourceforge.net>
Subject: e100: Wait for PHY reset to complete?
Date: Wed, 25 Oct 2006 19:22:18 +0200
Message-ID: <453F9D4A.8090306@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([212.247.11.2]:23045 "HELO
	ernst.netinsight.se") by vger.kernel.org with SMTP id S932253AbWJYRVi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 13:21:38 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shouldn't the e100 driver wait for PHY reset to complete before
proceeding in e100_set_settings()?

I'm asking because the interface (82551) sometimes ends up in loopback
when I try to set AUTONEG.

I'm thinking something like this patch.

Anders

--- linux-2.6.18.orig/drivers/net/e100.c	2006-09-20 05:42:06.000000000 +0200
+++ linux-2.6.18/drivers/net/e100.c	2006-10-17 17:43:47.000000000 +0200
@@ -2201,8 +2201,16 @@ static int e100_set_settings(struct net_
 {
 	struct nic *nic = netdev_priv(netdev);
 	int err;
+	int counter = 50;
 
 	mdio_write(netdev, nic->mii.phy_id, MII_BMCR, BMCR_RESET);
+
+	/* wait for possibly (ouch) 500ms */
+	while (mdio_read(netdev, nic->mii.phy_id, MII_BMCR) & BMCR_RESET) {
+		msleep(10);
+		if (!--counter) break;
+	}
+
 	err = mii_ethtool_sset(&nic->mii, cmd);
 	e100_exec_cb(nic, NULL, e100_configure);
 
