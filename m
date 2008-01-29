From: Mitch Williams <mitch.a.williams@intel.com>
Subject: [PATCH 2.6.24] e1000e: add new wakeup cababilities
Date: Tue, 29 Jan 2008 12:43:02 -0800
Message-ID: <1201639382.11148.8.camel@strongmad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.com, jgarzik@pobox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:8410 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751574AbYA2U7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 15:59:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ethtool supports wake-on-ARP and wake-on-link, and so does the hardware
supported by e1000e.  This patch just introduces the two.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>

diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index f2175ea..6232c3e 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -63,6 +63,7 @@
 #define E1000_WUFC_EX   0x00000004 /* Directed Exact Wakeup Enable */
 #define E1000_WUFC_MC   0x00000008 /* Directed Multicast Wakeup Enable */
 #define E1000_WUFC_BC   0x00000010 /* Broadcast Wakeup Enable */
+#define E1000_WUFC_ARP  0x00000020 /* ARP Request Packet Wakeup Enable */
 
 /* Extended Device Control */
 #define E1000_CTRL_EXT_SDP7_DATA 0x00000080 /* Value of SW Defineable Pin 7 */
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 6d9c27f..9fab444 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1632,7 +1632,8 @@ static void e1000_get_wol(struct net_device *netdev,
 		return;
 
 	wol->supported = WAKE_UCAST | WAKE_MCAST |
-			 WAKE_BCAST | WAKE_MAGIC;
+	                 WAKE_BCAST | WAKE_MAGIC |
+	                 WAKE_PHY | WAKE_ARP;
 
 	/* apply any specific unsupported masks here */
 	if (adapter->flags & FLAG_NO_WAKE_UCAST) {
@@ -1651,6 +1652,10 @@ static void e1000_get_wol(struct net_device *netdev,
 		wol->wolopts |= WAKE_BCAST;
 	if (adapter->wol & E1000_WUFC_MAG)
 		wol->wolopts |= WAKE_MAGIC;
+	if (adapter->wol & E1000_WUFC_LNKC)
+		wol->wolopts |= WAKE_PHY;
+	if (adapter->wol & E1000_WUFC_ARP)
+		wol->wolopts |= WAKE_ARP;
 }
 
 static int e1000_set_wol(struct net_device *netdev,
@@ -1658,7 +1663,7 @@ static int e1000_set_wol(struct net_device *netdev,
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	if (wol->wolopts & (WAKE_PHY | WAKE_ARP | WAKE_MAGICSECURE))
+	if (wol->wolopts & WAKE_MAGICSECURE)
 		return -EOPNOTSUPP;
 
 	if (!(adapter->flags & FLAG_HAS_WOL))
@@ -1675,6 +1680,10 @@ static int e1000_set_wol(struct net_device *netdev,
 		adapter->wol |= E1000_WUFC_BC;
 	if (wol->wolopts & WAKE_MAGIC)
 		adapter->wol |= E1000_WUFC_MAG;
+	if (wol->wolopts & WAKE_PHY)
+		adapter->wol |= E1000_WUFC_LNKC;
+	if (wol->wolopts & WAKE_ARP)
+		adapter->wol |= E1000_WUFC_ARP;
 
 	return 0;
 }


