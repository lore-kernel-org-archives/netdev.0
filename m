From: Bryan Wu <bryan.wu@analog.com>
Subject: [PATCH 3/8] [Blackfin] EMAC driver: bf537 MAC multicast hash filtering patch
Date: Wed, 30 Jan 2008 16:52:23 +0800
Message-ID: <1201683148-23931-4-git-send-email-bryan.wu@analog.com>
References: <1201683148-23931-1-git-send-email-bryan.wu@analog.com>
Cc: linux-kernel@vger.kernel.org, Aidan Williams <aidan@nicta.com.au>,
	Bryan Wu <bryan.wu@analog.com>
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:46159 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754980AbYA3Iwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 03:52:37 -0500
In-Reply-To: <1201683148-23931-1-git-send-email-bryan.wu@analog.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aidan Williams <aidan@nicta.com.au>

The bf537 Ethernet MAC driver in the 2007R1.1-RC3 kernel (and the
current kernel) do not implement multicast hash filtering. This
is a performance problem if you have lots of multicast on your network.

This patch plugs the right bits into the multicast hash registers.

Signed-off-by: Aidan Williams <aidan@nicta.com.au>
Signed-off-by: Bryan Wu <bryan.wu@analog.com>
---
 drivers/net/bfin_mac.c |   42 +++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 41 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index ee39819..c6586cd 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -11,6 +11,7 @@
  * Description:
  *
  * Modified:
+ * 		2006-12-19 Aidan Williams, multicast hash support
  *		Copyright 2004-2006 Analog Devices Inc.
  *
  * Bugs:	Enter bugs at http://blackfin.uclinux.org/
@@ -800,6 +801,39 @@ static void bf537mac_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
+static void bf537mac_multicast_hash(struct net_device *dev)
+{
+	u32 emac_hashhi, emac_hashlo;
+	struct dev_mc_list *dmi = dev->mc_list;
+	char *addrs;
+	int i;
+	u32 crc;
+
+	emac_hashhi = emac_hashlo = 0;
+
+	for (i = 0; i < dev->mc_count; i++) {
+		addrs = dmi->dmi_addr;
+		dmi = dmi->next;
+
+		/* skip non-multicast addresses */
+		if (!(*addrs & 1))
+			continue;
+
+		crc = ether_crc(ETH_ALEN, addrs);
+		crc >>= 26;
+
+		if (crc & 0x20)
+			emac_hashhi |= 1 << (crc & 0x1f);
+		else
+			emac_hashlo |= 1 << (crc & 0x1f);
+	}
+
+	bfin_write_EMAC_HASHHI(emac_hashhi);
+	bfin_write_EMAC_HASHLO(emac_hashlo);
+
+	return;
+}
+
 /*
  * This routine will, depending on the values passed to it,
  * either make it accept multicast packets, go into
@@ -815,11 +849,17 @@ static void bf537mac_set_multicast_list(struct net_device *dev)
 		sysctl = bfin_read_EMAC_OPMODE();
 		sysctl |= RAF;
 		bfin_write_EMAC_OPMODE(sysctl);
-	} else if (dev->flags & IFF_ALLMULTI || dev->mc_count) {
+	} else if (dev->flags & IFF_ALLMULTI) {
 		/* accept all multicast */
 		sysctl = bfin_read_EMAC_OPMODE();
 		sysctl |= PAM;
 		bfin_write_EMAC_OPMODE(sysctl);
+	} else if (dev->mc_count) {
+		/* set up multicast hash table */
+		sysctl = bfin_read_EMAC_OPMODE();
+		sysctl |= HM;
+		bfin_write_EMAC_OPMODE(sysctl);
+		bf537mac_multicast_hash(dev);
 	} else {
 		/* clear promisc or multicast mode */
 		sysctl = bfin_read_EMAC_OPMODE();
-- 
1.5.3.4
