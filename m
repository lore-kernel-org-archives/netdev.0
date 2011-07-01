From: "Sebastian =?ISO-8859-1?Q?P=F6hn?=" <sebastian.belden@googlemail.com>
Subject: [PATCH] gianfar: code cleanups
Date: Fri, 01 Jul 2011 11:00:43 +0200
Message-ID: <1309510843.10177.10.camel@DENEC1DT0191>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	Sebastian =?ISO-8859-1?Q?P=F6hn?= <sebastian.poehn@belden.com>
To: Linux Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:50334 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755516Ab1GAJAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 05:00:51 -0400
Received: by gyh3 with SMTP id 3so1225239gyh.19
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2011 02:00:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch:
# moves if_vlan.h include from gianfar.c to gianfar.h
# improves readability of some gianfar nfc code

Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>
---

 drivers/net/gianfar.c         |    1 -
 drivers/net/gianfar.h         |    2 +
 drivers/net/gianfar_ethtool.c |   51 +++++++++++++++++++++-------------------
 3 files changed, 29 insertions(+), 25 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 3321d71..d55cdf2 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -76,7 +76,6 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
-#include <linux/if_vlan.h>
 #include <linux/spinlock.h>
 #include <linux/mm.h>
 #include <linux/of_mdio.h>
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 76f14d0..9c0e56c 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -38,6 +38,7 @@
 #include <linux/mm.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
+#include <linux/if_vlan.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -409,6 +410,7 @@ extern const char gfar_driver_version[];
 #define RQFCR_HASHTBL_2		0x00060000
 #define RQFCR_HASHTBL_3		0x00080000
 #define RQFCR_HASH		0x00010000
+#define RQFCR_QUEUE		0x0000FC00
 #define RQFCR_CLE		0x00000200
 #define RQFCR_RJE		0x00000100
 #define RQFCR_AND		0x00000080
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index 2ecdc9a..da856ba 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -883,7 +883,7 @@ static void gfar_set_attribute(u32 value, u32 mask, u32 flag,
 		struct filer_table *tab)
 {
 	switch (flag) {
-	/* 3bit */
+		/* 3bit */
 	case RQFCR_PID_PRI:
 		if (!(value | mask))
 			return;
@@ -1051,17 +1051,17 @@ static int gfar_convert_to_filer(struct ethtool_rx_flow_spec *rule,
 		vlan_mask = RQFPR_VLN;
 
 		/* Separate the fields */
-		id = rule->h_ext.vlan_tci & 0xFFF;
-		id_mask = rule->m_ext.vlan_tci & 0xFFF;
-		cfi = (rule->h_ext.vlan_tci >> 12) & 1;
-		cfi_mask = (rule->m_ext.vlan_tci >> 12) & 1;
-		prio = (rule->h_ext.vlan_tci >> 13) & 0x7;
-		prio_mask = (rule->m_ext.vlan_tci >> 13) & 0x7;
-
-		if (cfi == 1 && cfi_mask == 1) {
+		id = rule->h_ext.vlan_tci & VLAN_VID_MASK;
+		id_mask = rule->m_ext.vlan_tci & VLAN_VID_MASK;
+		cfi = rule->h_ext.vlan_tci & VLAN_CFI_MASK;
+		cfi_mask = rule->m_ext.vlan_tci & VLAN_CFI_MASK;
+		prio = (rule->h_ext.vlan_tci & VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT;
+		prio_mask = (rule->m_ext.vlan_tci & VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT;
+
+		if (cfi == VLAN_TAG_PRESENT && cfi_mask == VLAN_TAG_PRESENT) {
 			vlan |= RQFPR_CFI;
 			vlan_mask |= RQFPR_CFI;
-		} else if (cfi == 0 && cfi_mask == 1) {
+		} else if (cfi != VLAN_TAG_PRESENT && cfi_mask == VLAN_TAG_PRESENT) {
 			vlan_mask |= RQFPR_CFI;
 		}
 	}
@@ -1262,21 +1262,21 @@ static void gfar_cluster_filer(struct filer_table *tab)
 	}
 }
 
-/* Swaps the 0xFF80 masked bits of a1<>a2 and b1<>b2 */
-static void gfar_swap_ff80_bits(struct gfar_filer_entry *a1,
+/* Swaps the masked bits of a1<>a2 and b1<>b2 */
+static void gfar_swap_bits(struct gfar_filer_entry *a1,
 		struct gfar_filer_entry *a2, struct gfar_filer_entry *b1,
-		struct gfar_filer_entry *b2)
+		struct gfar_filer_entry *b2, u32 mask)
 {
 	u32 temp[4];
-	temp[0] = a1->ctrl & 0xFF80;
-	temp[1] = a2->ctrl & 0xFF80;
-	temp[2] = b1->ctrl & 0xFF80;
-	temp[3] = b2->ctrl & 0xFF80;
+	temp[0] = a1->ctrl & mask;
+	temp[1] = a2->ctrl & mask;
+	temp[2] = b1->ctrl & mask;
+	temp[3] = b2->ctrl & mask;
 
-	a1->ctrl &= ~0xFF80;
-	a2->ctrl &= ~0xFF80;
-	b1->ctrl &= ~0xFF80;
-	b2->ctrl &= ~0xFF80;
+	a1->ctrl &= ~mask;
+	a2->ctrl &= ~mask;
+	b1->ctrl &= ~mask;
+	b2->ctrl &= ~mask;
 
 	a1->ctrl |= temp[1];
 	a2->ctrl |= temp[0];
@@ -1305,7 +1305,7 @@ static u32 gfar_generate_mask_table(struct gfar_mask_entry *mask_table,
 				mask_table[and_index - 1].end = i - 1;
 			and_index++;
 		}
-		/* cluster starts will be separated because they should
+		/* cluster starts and ends will be separated because they should
 		 * hold their position */
 		if (tab->fe[i].ctrl & RQFCR_CLE)
 			block_index++;
@@ -1356,10 +1356,13 @@ static void gfar_sort_mask_table(struct gfar_mask_entry *mask_table,
 			new_first = mask_table[start].start + 1;
 			new_last = mask_table[i - 1].end;
 
-			gfar_swap_ff80_bits(&temp_table->fe[new_first],
+			gfar_swap_bits(&temp_table->fe[new_first],
 					&temp_table->fe[old_first],
 					&temp_table->fe[new_last],
-					&temp_table->fe[old_last]);
+					&temp_table->fe[old_last],
+					RQFCR_QUEUE | RQFCR_CLE |
+						RQFCR_RJE | RQFCR_AND
+					);
 
 			start = i;
 			size = 0;


