From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [RFC PATCH 2/2] refactor full duplex flow control resolution
Date: Sun, 14 Dec 2008 12:38:21 +0000
Message-ID: <1229258301-5073-3-git-send-email-steve.glendinning@smsc.com>
References: <1229258301-5073-1-git-send-email-steve.glendinning@smsc.com>
 <1229258301-5073-2-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:59732 "EHLO
	drevil2.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752315AbYLNMiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2008 07:38:15 -0500
In-Reply-To: <1229258301-5073-2-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These 4 drivers have identical full duplex flow control resolution
functions.  This patch changes them all to use one common function.

The function in question decides whether a device should enable TX and
RX flow control in a standard way (IEEE 802.3-2005 table 28B-3), so this
should also be useful for other drivers.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c     |   24 +-----------------------
 drivers/net/smsc9420.c     |   24 +-----------------------
 drivers/net/tg3.c          |   24 +-----------------------
 drivers/net/usb/smsc95xx.c |   24 +-----------------------
 include/linux/mii.h        |   29 +++++++++++++++++++++++++++++
 5 files changed, 33 insertions(+), 92 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index ae32716..fa28542 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -642,28 +642,6 @@ static int smsc911x_phy_loopbacktest(struct net_device *dev)
 }
 #endif				/* USE_PHY_WORK_AROUND */
 
-static u8 smsc95xx_resolve_flowctrl_fulldplx(u16 lcladv, u16 rmtadv)
-{
-	u8 cap = 0;
-
-	if (lcladv & ADVERTISE_PAUSE_CAP) {
-		if (lcladv & ADVERTISE_PAUSE_ASYM) {
-			if (rmtadv & LPA_PAUSE_CAP)
-				cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
-			else if (rmtadv & LPA_PAUSE_ASYM)
-				cap = FLOW_CTRL_RX;
-		} else {
-			if (rmtadv & LPA_PAUSE_CAP)
-				cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
-		}
-	} else if (lcladv & ADVERTISE_PAUSE_ASYM) {
-		if ((rmtadv & LPA_PAUSE_CAP) && (rmtadv & LPA_PAUSE_ASYM))
-			cap = FLOW_CTRL_TX;
-	}
-
-	return cap;
-}
-
 static void smsc911x_phy_update_flowcontrol(struct smsc911x_data *pdata)
 {
 	struct phy_device *phy_dev = pdata->phy_dev;
@@ -674,7 +652,7 @@ static void smsc911x_phy_update_flowcontrol(struct smsc911x_data *pdata)
 	if (phy_dev->duplex == DUPLEX_FULL) {
 		u16 lcladv = phy_read(phy_dev, MII_ADVERTISE);
 		u16 rmtadv = phy_read(phy_dev, MII_LPA);
-		u8 cap = smsc95xx_resolve_flowctrl_fulldplx(lcladv, rmtadv);
+		u8 cap = mii_resolve_flowctrl_fdx(lcladv, rmtadv);
 
 		if (cap & FLOW_CTRL_RX)
 			flow = 0xFFFF0002;
diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index 2a8e9b7..47450d4 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -1055,28 +1055,6 @@ static void smsc9420_set_multicast_list(struct net_device *dev)
 	smsc9420_pci_flush_write(pd);
 }
 
-static u8 smsc9420_resolve_flowctrl_fulldplx(u16 lcladv, u16 rmtadv)
-{
-	u8 cap = 0;
-
-	if (lcladv & ADVERTISE_PAUSE_CAP) {
-		if (lcladv & ADVERTISE_PAUSE_ASYM) {
-			if (rmtadv & LPA_PAUSE_CAP)
-				cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
-			else if (rmtadv & LPA_PAUSE_ASYM)
-				cap = FLOW_CTRL_RX;
-		} else {
-			if (rmtadv & LPA_PAUSE_CAP)
-				cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
-		}
-	} else if (lcladv & ADVERTISE_PAUSE_ASYM) {
-		if ((rmtadv & LPA_PAUSE_CAP) && (rmtadv & LPA_PAUSE_ASYM))
-			cap = FLOW_CTRL_TX;
-	}
-
-	return cap;
-}
-
 static void smsc9420_phy_update_flowcontrol(struct smsc9420_pdata *pd)
 {
 	struct phy_device *phy_dev = pd->phy_dev;
@@ -1085,7 +1063,7 @@ static void smsc9420_phy_update_flowcontrol(struct smsc9420_pdata *pd)
 	if (phy_dev->duplex == DUPLEX_FULL) {
 		u16 lcladv = phy_read(phy_dev, MII_ADVERTISE);
 		u16 rmtadv = phy_read(phy_dev, MII_LPA);
-		u8 cap = smsc9420_resolve_flowctrl_fulldplx(lcladv, rmtadv);
+		u8 cap = mii_resolve_flowctrl_fdx(lcladv, rmtadv);
 
 		if (cap & FLOW_CTRL_RX)
 			flow = 0xFFFF0002;
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index f353f69..06bd2f4 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1227,28 +1227,6 @@ static u16 tg3_advert_flowctrl_1000X(u8 flow_ctrl)
 	return miireg;
 }
 
-static u8 tg3_resolve_flowctrl_1000T(u16 lcladv, u16 rmtadv)
-{
-	u8 cap = 0;
-
-	if (lcladv & ADVERTISE_PAUSE_CAP) {
-		if (lcladv & ADVERTISE_PAUSE_ASYM) {
-			if (rmtadv & LPA_PAUSE_CAP)
-				cap = TG3_FLOW_CTRL_TX | TG3_FLOW_CTRL_RX;
-			else if (rmtadv & LPA_PAUSE_ASYM)
-				cap = TG3_FLOW_CTRL_RX;
-		} else {
-			if (rmtadv & LPA_PAUSE_CAP)
-				cap = TG3_FLOW_CTRL_TX | TG3_FLOW_CTRL_RX;
-		}
-	} else if (lcladv & ADVERTISE_PAUSE_ASYM) {
-		if ((rmtadv & LPA_PAUSE_CAP) && (rmtadv & LPA_PAUSE_ASYM))
-			cap = TG3_FLOW_CTRL_TX;
-	}
-
-	return cap;
-}
-
 static u8 tg3_resolve_flowctrl_1000X(u16 lcladv, u16 rmtadv)
 {
 	u8 cap = 0;
@@ -1288,7 +1266,7 @@ static void tg3_setup_flow_control(struct tg3 *tp, u32 lcladv, u32 rmtadv)
 		if (tp->tg3_flags2 & TG3_FLG2_ANY_SERDES)
 			flowctrl = tg3_resolve_flowctrl_1000X(lcladv, rmtadv);
 		else
-			flowctrl = tg3_resolve_flowctrl_1000T(lcladv, rmtadv);
+			flowctrl = mii_resolve_flowctrl_fdx(lcladv, rmtadv);
 	} else
 		flowctrl = tp->link_config.flowctrl;
 
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index ee2eac3..fed22ff 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -435,28 +435,6 @@ static void smsc95xx_set_multicast(struct net_device *netdev)
 	smsc95xx_write_reg_async(dev, MAC_CR, &pdata->mac_cr);
 }
 
-static u8 smsc95xx_resolve_flowctrl_fulldplx(u16 lcladv, u16 rmtadv)
-{
-	u8 cap = 0;
-
-	if (lcladv & ADVERTISE_PAUSE_CAP) {
-		if (lcladv & ADVERTISE_PAUSE_ASYM) {
-			if (rmtadv & LPA_PAUSE_CAP)
-				cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
-			else if (rmtadv & LPA_PAUSE_ASYM)
-				cap = FLOW_CTRL_RX;
-		} else {
-			if (rmtadv & LPA_PAUSE_CAP)
-				cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
-		}
-	} else if (lcladv & ADVERTISE_PAUSE_ASYM) {
-		if ((rmtadv & LPA_PAUSE_CAP) && (rmtadv & LPA_PAUSE_ASYM))
-			cap = FLOW_CTRL_TX;
-	}
-
-	return cap;
-}
-
 static void smsc95xx_phy_update_flowcontrol(struct usbnet *dev, u8 duplex,
 					    u16 lcladv, u16 rmtadv)
 {
@@ -469,7 +447,7 @@ static void smsc95xx_phy_update_flowcontrol(struct usbnet *dev, u8 duplex,
 	}
 
 	if (duplex == DUPLEX_FULL) {
-		u8 cap = smsc95xx_resolve_flowctrl_fulldplx(lcladv, rmtadv);
+		u8 cap = mii_resolve_flowctrl_fdx(lcladv, rmtadv);
 
 		if (cap & FLOW_CTRL_RX)
 			flow = 0xFFFF0002;
diff --git a/include/linux/mii.h b/include/linux/mii.h
index 4a376e0..ad74858 100644
--- a/include/linux/mii.h
+++ b/include/linux/mii.h
@@ -239,5 +239,34 @@ static inline unsigned int mii_duplex (unsigned int duplex_lock,
 	return 0;
 }
 
+/**
+ * mii_resolve_flowctrl_fdx
+ * @lcladv: value of MII ADVERTISE register
+ * @rmtadv: value of MII LPA register
+ *
+ * Resolve full duplex flow control as per IEEE 802.3-2005 table 28B-3
+ */
+static inline u8 mii_resolve_flowctrl_fdx(u16 lcladv, u16 rmtadv)
+{
+	u8 cap = 0;
+
+	if (lcladv & ADVERTISE_PAUSE_CAP) {
+		if (lcladv & ADVERTISE_PAUSE_ASYM) {
+			if (rmtadv & LPA_PAUSE_CAP)
+				cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
+			else if (rmtadv & LPA_PAUSE_ASYM)
+				cap = FLOW_CTRL_RX;
+		} else {
+			if (rmtadv & LPA_PAUSE_CAP)
+				cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
+		}
+	} else if (lcladv & ADVERTISE_PAUSE_ASYM) {
+		if ((rmtadv & LPA_PAUSE_CAP) && (rmtadv & LPA_PAUSE_ASYM))
+			cap = FLOW_CTRL_TX;
+	}
+
+	return cap;
+}
+
 #endif /* __KERNEL__ */
 #endif /* __LINUX_MII_H__ */
-- 
1.6.0.4

