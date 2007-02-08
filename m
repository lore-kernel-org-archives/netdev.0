From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: [PATCH 2.6.20 3/5] dmfe: Fix link detection
Date: Thu, 8 Feb 2007 23:13:23 +0200
Message-ID: <200702082313.24158.maximlevitsky@gmail.com>
References: <200702082305.26735.maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:35134 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423389AbXBHVQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 16:16:37 -0500
Received: by ug-out-1314.google.com with SMTP id 44so583260uga
        for <netdev@vger.kernel.org>; Thu, 08 Feb 2007 13:16:36 -0800 (PST)
In-Reply-To: <200702082305.26735.maximlevitsky@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: [PATCH 2.6.20 3/5] dmfe: Fix link detection

Remove unused 'link_failed' and fix link detection on cards that use external
PHY

Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>

---

--- linux-2.6.20-mod/drivers/net/tulip/dmfe.c	2007-02-08 20:49:05.000000000 
+0200
+++ linux-2.6.20-test/drivers/net/tulip/dmfe.c	2007-02-08 21:47:37.000000000 
+0200
@@ -248,7 +248,6 @@ struct dmfe_board_info {
 	u8 media_mode;			/* user specify media mode */
 	u8 op_mode;			/* real work media mode */
 	u8 phy_addr;
-	u8 link_failed;			/* Ever link failed */
 	u8 wait_reset;			/* Hardware failed, need to reset */
 	u8 dm910x_chk_mode;		/* Operating mode check */
 	u8 first_in_callback;		/* Flag to record state */
@@ -544,7 +543,6 @@ static int dmfe_open(struct DEVICE *dev)
 	db->tx_packet_cnt = 0;
 	db->tx_queue_cnt = 0;
 	db->rx_avail_cnt = 0;
-	db->link_failed = 1;
 	db->wait_reset = 0;
 
 	db->first_in_callback = 0;
@@ -1101,6 +1099,8 @@ static void dmfe_timer(unsigned long dat
 	struct dmfe_board_info *db = netdev_priv(dev);
  	unsigned long flags;
 
+	int link_ok, link_ok_phy;
+
 	DMFE_DBUG(0, "dmfe_timer()", 0);
 	spin_lock_irqsave(&db->lock, flags);
 
@@ -1166,22 +1166,43 @@ static void dmfe_timer(unsigned long dat
 	else
 		tmp_cr12 = inb(db->ioaddr + DCR12);	/* DM9102/DM9102A */
 
+	
 	if ( ((db->chip_id == PCI_DM9102_ID) &&
 		(db->chip_revision == 0x02000030)) ||
 		((db->chip_id == PCI_DM9132_ID) &&
 		(db->chip_revision == 0x02000010)) ) {
 		/* DM9102A Chip */
 		if (tmp_cr12 & 2)
-			tmp_cr12 = 0x0;		/* Link failed */
+			link_ok = 0;
 		else
-			tmp_cr12 = 0x3;	/* Link OK */
+			link_ok = 1;
+	}
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
 	}
 
-	if ( !(tmp_cr12 & 0x3) && !db->link_failed ) {
+	if ( !link_ok && netif_carrier_ok(dev) ) {
 		/* Link Failed */
 		DMFE_DBUG(0, "Link Failed", tmp_cr12);
-		db->link_failed = 1;
-		netif_carrier_off(db->dev);
+		
+		netif_carrier_off(dev);
 
 		/* For Force 10/100M Half/Full mode: Enable Auto-Nego mode */
 		/* AUTO or force 1M Homerun/Longrun don't need */
@@ -1196,19 +1217,17 @@ static void dmfe_timer(unsigned long dat
 			db->cr6_data&=~0x00000200;	/* bit9=0, HD mode */
 			update_cr6(db->cr6_data, db->ioaddr);
 		}
-	} else
-		if ((tmp_cr12 & 0x3) && db->link_failed) {
-			DMFE_DBUG(0, "Link link OK", tmp_cr12);
-			db->link_failed = 0;
+		
+	} else if (!netif_carrier_ok(dev)) {
+		
+		DMFE_DBUG(0, "Link OK", tmp_cr12);
 
 			/* Auto Sense Speed */
-			if ( (db->media_mode & DMFE_AUTO) &&
-				dmfe_sense_speed(db) )
-				db->link_failed = 1;
-			else
-				netif_carrier_on(db->dev);
+		if (! (db->media_mode & DMFE_AUTO) || !dmfe_sense_speed(db)) {
+			netif_carrier_on(dev);
+			SHOW_MEDIA_TYPE(db->op_mode);
+		}
 			dmfe_process_mode(db);
-			/* SHOW_MEDIA_TYPE(db->op_mode); */
 		}
 
 	/* HPNA remote command check */
@@ -1255,7 +1274,7 @@ static void dmfe_dynamic_reset(struct DE
 	db->tx_packet_cnt = 0;
 	db->tx_queue_cnt = 0;
 	db->rx_avail_cnt = 0;
-	db->link_failed = 1;
+	netif_carrier_off(dev);
 	db->wait_reset = 0;
 
 	/* Re-initilize DM910X board */
