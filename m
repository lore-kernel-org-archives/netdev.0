From: Ben Dooks <ben-linux@fluff.org>
Subject: [PATCH 01/24 for-2.6.25] DM9000: Fix endian-ness of data accesses. Patch from: Laurent Pinchart <laurentp@cse-semaphore.com>
Date: Tue, 05 Feb 2008 00:02:00 +0000
Message-ID: <20080205000814.539308209@fluff.org.uk>
References: <20080205000159.432081941@fluff.org.uk>
Cc: jeff@garzik.org, akpm@linux-foundation.org, daniel@caiaq.de,
	laurentp@cse-semaphore.com, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:58728 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758834AbYBEAIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 19:08:23 -0500
Content-Disposition: inline; filename=thirdparty/dm9000-fix-8bit.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch splits the receive status in 8bit wide fields and convert the
packet length from little endian to CPU byte order.

Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.24-git5-dm9k/drivers/net/dm9000.c
===================================================================
--- linux-2.6.24-git5-dm9k.orig/drivers/net/dm9000.c
+++ linux-2.6.24-git5-dm9k/drivers/net/dm9000.c
@@ -867,7 +867,8 @@ dm9000_timer(unsigned long data)
 }
 
 struct dm9000_rxhdr {
-	u16	RxStatus;
+	u8	RxPktReady;
+	u8	RxStatus;
 	u16	RxLen;
 } __attribute__((__packed__));
 
@@ -908,7 +909,7 @@ dm9000_rx(struct net_device *dev)
 
 		(db->inblk)(db->io_data, &rxhdr, sizeof(rxhdr));
 
-		RxLen = rxhdr.RxLen;
+		RxLen = le16_to_cpu(rxhdr.RxLen);
 
 		/* Packet Status check */
 		if (RxLen < 0x40) {
@@ -920,17 +921,17 @@ dm9000_rx(struct net_device *dev)
 			PRINTK1("RST: RX Len:%x\n", RxLen);
 		}
 
-		if (rxhdr.RxStatus & 0xbf00) {
+		if (rxhdr.RxStatus & 0xbf) {
 			GoodPacket = false;
-			if (rxhdr.RxStatus & 0x100) {
+			if (rxhdr.RxStatus & 0x01) {
 				PRINTK1("fifo error\n");
 				dev->stats.rx_fifo_errors++;
 			}
-			if (rxhdr.RxStatus & 0x200) {
+			if (rxhdr.RxStatus & 0x02) {
 				PRINTK1("crc error\n");
 				dev->stats.rx_crc_errors++;
 			}
-			if (rxhdr.RxStatus & 0x8000) {
+			if (rxhdr.RxStatus & 0x80) {
 				PRINTK1("length error\n");
 				dev->stats.rx_length_errors++;
 			}

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
