From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] dm9000: Support promisc and all-multi modes
Date: Tue, 18 Mar 2008 23:17:16 +0100
Message-ID: <1205878636-29109-1-git-send-email-jacmet@sunsite.dk>
Cc: Peter Korsgaard <jacmet@sunsite.dk>
To: jeff@garzik.org, ben-linux@fluff.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:26711 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S939634AbYCSWIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 18:08:22 -0400
Received: by nf-out-0910.google.com with SMTP id g13so359137nfb.21
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2008 15:08:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 drivers/net/dm9000.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 1fe305c..b09a53d 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -798,8 +798,6 @@ dm9000_init_dm9000(struct net_device *dev)
 	/* Set address filter table */
 	dm9000_hash_table(dev);
 
-	/* Activate DM9000 */
-	iow(db, DM9000_RCR, RCR_DIS_LONG | RCR_DIS_CRC | RCR_RXEN);
 	/* Enable TX/RX interrupt mask */
 	iow(db, DM9000_IMR, IMR_PAR | IMR_PTM | IMR_PRM);
 
@@ -1197,6 +1195,7 @@ dm9000_hash_table(struct net_device *dev)
 	int i, oft;
 	u32 hash_val;
 	u16 hash_table[4];
+	u8 rcr = RCR_DIS_LONG | RCR_DIS_CRC | RCR_RXEN;
 	unsigned long flags;
 
 	dm9000_dbg(db, 1, "entering %s\n", __func__);
@@ -1213,6 +1212,12 @@ dm9000_hash_table(struct net_device *dev)
 	/* broadcast address */
 	hash_table[3] = 0x8000;
 
+	if (dev->flags & IFF_PROMISC)
+		rcr |= RCR_PRMSC;
+
+	if (dev->flags & IFF_ALLMULTI)
+		rcr |= RCR_ALL;
+
 	/* the multicast address in Hash Table : 64 bits */
 	for (i = 0; i < mc_cnt; i++, mcptr = mcptr->next) {
 		hash_val = ether_crc_le(6, mcptr->dmi_addr) & 0x3f;
@@ -1225,6 +1230,7 @@ dm9000_hash_table(struct net_device *dev)
 		iow(db, oft++, hash_table[i] >> 8);
 	}
 
+	iow(db, DM9000_RCR, rcr);
 	spin_unlock_irqrestore(&db->lock, flags);
 }
 
-- 
1.5.4.1

