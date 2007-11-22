From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] smc911x: Fix multicast handling
Date: Thu, 22 Nov 2007 12:25:13 +0100
Message-ID: <E1IvB6F-0004BQ-L4@nanv.dk>
To: netdev@vger.kernel.org, jeff@garzik.org, dustin@sensoria.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps.korsgaard.com ([64.79.194.204]:51790 "EHLO nanv.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750696AbXKVMYJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2007 07:24:09 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

smc911x_set_multicast_list fails to fill out the multicast hash table
correctly; Bit 1 was used rather than bit 5 to decide if the lower or
upper register should be used.

The function is at the same time cleaned up by calling ether_crc rather
than using it's own bit reversal table.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 drivers/net/smc911x.c |   17 ++++-------------
 1 files changed, 4 insertions(+), 13 deletions(-)

diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index dd18af0..b6c6c99 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -1379,13 +1379,6 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 	unsigned int multicast_table[2];
 	unsigned int mcr, update_multicast = 0;
 	unsigned long flags;
-	/* table for flipping the order of 5 bits */
-	static const unsigned char invert5[] =
-		{0x00, 0x10, 0x08, 0x18, 0x04, 0x14, 0x0C, 0x1C,
-		 0x02, 0x12, 0x0A, 0x1A, 0x06, 0x16, 0x0E, 0x1E,
-		 0x01, 0x11, 0x09, 0x19, 0x05, 0x15, 0x0D, 0x1D,
-		 0x03, 0x13, 0x0B, 0x1B, 0x07, 0x17, 0x0F, 0x1F};
-
 
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
 
@@ -1432,7 +1425,7 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 
 		cur_addr = dev->mc_list;
 		for (i = 0; i < dev->mc_count; i++, cur_addr = cur_addr->next) {
-			int position;
+			u32 position;
 
 			/* do we have a pointer here? */
 			if (!cur_addr)
@@ -1442,12 +1435,10 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 			if (!(*cur_addr->dmi_addr & 1))
 				 continue;
 
-			/* only use the low order bits */
-			position = crc32_le(~0, cur_addr->dmi_addr, 6) & 0x3f;
+			/* upper 6 bits are used as hash index */
+			position = ether_crc(ETH_ALEN, cur_addr->dmi_addr)>>26;
 
-			/* do some messy swapping to put the bit in the right spot */
-			multicast_table[invert5[position&0x1F]&0x1] |=
-				(1<<invert5[(position>>1)&0x1F]);
+			multicast_table[position>>5] |= 1 << (position&0x1f);
 		}
 
 		/* be sure I get rid of flags I might have set */
-- 
1.5.3.5

