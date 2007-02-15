From: Maxim <maximlevitsky@gmail.com>
Subject: Subject:  [PATCH 2.6.20 003/005] [RESEND v2]  dmfe: Fix link detection
Date: Thu, 15 Feb 2007 23:08:20 +0200
Message-ID: <200702152308.21026.maximlevitsky@gmail.com>
References: <200702152253.53680.maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161302AbXBOVI2@vger.kernel.org>
In-Reply-To: <200702152253.53680.maximlevitsky@gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject:  [PATCH 2.6.20 003/005] [RESEND v2]  dmfe: Fix link detection

Add link detection

Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>

---

--- linux-2.6.20-mod/drivers/net/tulip/dmfe.c	2007-02-15 18:00:58.000000000 +0200
+++ linux-2.6.20-test/drivers/net/tulip/dmfe.c	2007-02-15 18:21:28.000000000 +0200
@@ -248,7 +248,6 @@ struct dmfe_board_info {
 	u8 media_mode;			/* user specify media mode */
 	u8 op_mode;			/* real work media mode */
 	u8 phy_addr;
-	u8 link_failed;			/* Ever link failed */
 	u8 wait_reset;			/* Hardware failed, need to reset */
 	u8 dm910x_chk_mode;		/* Operating mode check */
 	u8 first_in_callback;		/* Flag to record state */
@@ -447,6 +446,7 @@ static int __devinit dmfe_init_one (stru
 	dev->poll_controller = &poll_dmfe;
 #endif
 	dev->ethtool_ops = &netdev_ethtool_ops;
+	netif_carrier_off(dev);
 	spin_lock_init(&db->lock);
 
 	pci_read_config_dword(pdev, 0x50, &pci_pmr);
@@ -541,7 +541,6 @@ static int dmfe_open(struct DEVICE *dev)
 	db->tx_packet_cnt = 0;
 	db->tx_queue_cnt = 0;
 	db->rx_avail_cnt = 0;
-	db->link_failed = 1;
 	db->wait_reset = 0;
 
 	db->first_in_callback = 0;
@@ -1082,6 +1081,7 @@ static void netdev_get_drvinfo(struct ne
 
 static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo		= netdev_get_drvinfo,
+	.get_link               = ethtool_op_get_link,
 };
 
 /*
@@ -1097,6 +1097,8 @@ static void dmfe_timer(unsigned long dat
 	struct dmfe_board_info *db = netdev_priv(dev);
  	unsigned long flags;
 
+	int link_ok, link_ok_phy;
+
 	DMFE_DBUG(0, "dmfe_timer()", 0);
 	spin_lock_irqsave(&db->lock, flags);
 
@@ -1168,15 +1170,35 @@ static void dmfe_timer(unsigned long dat
 		(db->chip_revision == 0x02000010)) ) {
 		/* DM9102A Chip */
 		if (tmp_cr12 & 2)
-			tmp_cr12 = 0x0;		/* Link failed */
+			link_ok = 0;
 		else
-			tmp_cr12 = 0x3;	/* Link OK */
+			link_ok = 1;
 	}
+	else
+		/*0x43 is used instead of 0x3 because bit 6 should represent  
+			link status of external PHY */
+		link_ok = (tmp_cr12 & 0x43) ? 1 : 0;
+
+
+	/* If chip reports that link is failed it could be because external 
+		PHY link status pin is not conected correctly to chip
+		To be sure ask PHY too.
+	*/
+
+	/* need a dummy read because of PHY's register latch*/
+	phy_read (db->ioaddr, db->phy_addr, 1, db->chip_id); 
+	link_ok_phy = (phy_read (db->ioaddr, 
+		       db->phy_addr, 1, db->chip_id) & 0x4) ? 1 : 0;
+
+	if (link_ok_phy != link_ok) {
+		DMFE_DBUG (0, "PHY and chip report different link status", 0);
+		link_ok = link_ok | link_ok_phy;
+ 	}
 
-	if ( !(tmp_cr12 & 0x3) && !db->link_failed ) {
+	if ( !link_ok && netif_carrier_ok(dev)) {
 		/* Link Failed */
 		DMFE_DBUG(0, "Link Failed", tmp_cr12);
-		db->link_failed = 1;
+		netif_carrier_off(dev);
 
 		/* For Force 10/100M Half/Full mode: Enable Auto-Nego mode */
 		/* AUTO or force 1M Homerun/Longrun don't need */
@@ -1191,19 +1213,19 @@ static void dmfe_timer(unsigned long dat
 			db->cr6_data&=~0x00000200;	/* bit9=0, HD mode */
 			update_cr6(db->cr6_data, db->ioaddr);
 		}
-	} else
-		if ((tmp_cr12 & 0x3) && db->link_failed) {
-			DMFE_DBUG(0, "Link link OK", tmp_cr12);
-			db->link_failed = 0;
-
-			/* Auto Sense Speed */
-			if ( (db->media_mode & DMFE_AUTO) &&
-				dmfe_sense_speed(db) )
-				db->link_failed = 1;
-			dmfe_process_mode(db);
-			/* SHOW_MEDIA_TYPE(db->op_mode); */
+	} else	if (!netif_carrier_ok(dev)) {
+		
+		DMFE_DBUG(0, "Link link OK", tmp_cr12);
+
+		/* Auto Sense Speed */
+		if ( !(db->media_mode & DMFE_AUTO) || !dmfe_sense_speed(db)) {
+			netif_carrier_on(dev);
+			SHOW_MEDIA_TYPE(db->op_mode);
 		}
 
+		dmfe_process_mode(db);
+	}
+
 	/* HPNA remote command check */
 	if (db->HPNA_command & 0xf00) {
 		db->HPNA_timer--;
@@ -1248,7 +1270,7 @@ static void dmfe_dynamic_reset(struct DE
 	db->tx_packet_cnt = 0;
 	db->tx_queue_cnt = 0;
 	db->rx_avail_cnt = 0;
-	db->link_failed = 1;
+	netif_carrier_off(dev);
 	db->wait_reset = 0;
 
 	/* Re-initilize DM910X board */
