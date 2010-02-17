From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] cassini: convert to use netdev_for_each_mc_addr
Date: Wed, 17 Feb 2010 21:43:33 +0100
Message-ID: <20100217204332.GB2635@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7661 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754924Ab0BQUni (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 15:43:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduced a new function to do the mc list processing, makes code clearer after
transition.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/cassini.c |   72 +++++++++++++++++++++++-------------------------
 1 files changed, 35 insertions(+), 37 deletions(-)

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index ad47e51..f90cac4 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2999,6 +2999,40 @@ static inline void cas_init_dma(struct cas *cp)
 	cas_init_rx_dma(cp);
 }
 
+static void cas_process_mc_list(struct cas *cp)
+{
+	u16 hash_table[16];
+	u32 crc;
+	struct dev_mc_list *dmi;
+	int i = 1;
+
+	memset(hash_table, 0, sizeof(hash_table));
+	netdev_for_each_mc_addr(dmi, cp->dev) {
+		if (i <= CAS_MC_EXACT_MATCH_SIZE) {
+			/* use the alternate mac address registers for the
+			 * first 15 multicast addresses
+			 */
+			writel((dmi->dmi_addr[4] << 8) | dmi->dmi_addr[5],
+			       cp->regs + REG_MAC_ADDRN(i*3 + 0));
+			writel((dmi->dmi_addr[2] << 8) | dmi->dmi_addr[3],
+			       cp->regs + REG_MAC_ADDRN(i*3 + 1));
+			writel((dmi->dmi_addr[0] << 8) | dmi->dmi_addr[1],
+			       cp->regs + REG_MAC_ADDRN(i*3 + 2));
+			i++;
+		}
+		else {
+			/* use hw hash table for the next series of
+			 * multicast addresses
+			 */
+			crc = ether_crc_le(ETH_ALEN, dmi->dmi_addr);
+			crc >>= 24;
+			hash_table[crc >> 4] |= 1 << (15 - (crc & 0xf));
+		}
+	}
+	for (i = 0; i < 16; i++)
+		writel(hash_table[i], cp->regs + REG_MAC_HASH_TABLEN(i));
+}
+
 /* Must be invoked under cp->lock. */
 static u32 cas_setup_multicast(struct cas *cp)
 {
@@ -3014,43 +3048,7 @@ static u32 cas_setup_multicast(struct cas *cp)
 		rxcfg |= MAC_RX_CFG_HASH_FILTER_EN;
 
 	} else {
-		u16 hash_table[16];
-		u32 crc;
-		struct dev_mc_list *dmi = cp->dev->mc_list;
-		int i;
-
-		/* use the alternate mac address registers for the
-		 * first 15 multicast addresses
-		 */
-		for (i = 1; i <= CAS_MC_EXACT_MATCH_SIZE; i++) {
-			if (!dmi) {
-				writel(0x0, cp->regs + REG_MAC_ADDRN(i*3 + 0));
-				writel(0x0, cp->regs + REG_MAC_ADDRN(i*3 + 1));
-				writel(0x0, cp->regs + REG_MAC_ADDRN(i*3 + 2));
-				continue;
-			}
-			writel((dmi->dmi_addr[4] << 8) | dmi->dmi_addr[5],
-			       cp->regs + REG_MAC_ADDRN(i*3 + 0));
-			writel((dmi->dmi_addr[2] << 8) | dmi->dmi_addr[3],
-			       cp->regs + REG_MAC_ADDRN(i*3 + 1));
-			writel((dmi->dmi_addr[0] << 8) | dmi->dmi_addr[1],
-			       cp->regs + REG_MAC_ADDRN(i*3 + 2));
-			dmi = dmi->next;
-		}
-
-		/* use hw hash table for the next series of
-		 * multicast addresses
-		 */
-		memset(hash_table, 0, sizeof(hash_table));
-		while (dmi) {
- 			crc = ether_crc_le(ETH_ALEN, dmi->dmi_addr);
-			crc >>= 24;
-			hash_table[crc >> 4] |= 1 << (15 - (crc & 0xf));
-			dmi = dmi->next;
-		}
-	    	for (i=0; i < 16; i++)
-			writel(hash_table[i], cp->regs +
-			       REG_MAC_HASH_TABLEN(i));
+		cas_process_mc_list(cp);
 		rxcfg |= MAC_RX_CFG_HASH_FILTER_EN;
 	}
 
-- 
1.6.6

