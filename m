From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 3/7] gianfar: Cleanup and optimize struct gfar_private
Date: Thu, 14 Feb 2013 17:00:03 +0200
Message-ID: <1360854007-11094-4-git-send-email-claudiu.manoil@freescale.com>
References: <1360854007-11094-1-git-send-email-claudiu.manoil@freescale.com>
 <1360854007-11094-2-git-send-email-claudiu.manoil@freescale.com>
 <1360854007-11094-3-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe002.messaging.microsoft.com ([216.32.181.182]:8669
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758873Ab3BNPAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 10:00:18 -0500
In-Reply-To: <1360854007-11094-3-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Group run-time critical fields within the 1st cacheline (32B)
followed by the tx|rx_queue reference arrays and the interrupt
group instances (gfargrp), all cacheline aligned.

This has several benefits. Firstly comes the performance benefit
by having the members required by the driver's hot path re-grouped
in the structure's first cache lines, whereas the unimportant
members were pushed towards the end of the struct.
Another benefit comes from eliminating a 24 byte memory hole that
was rendering gfar_priv's 2nd cacheline useless. The default gcc
layout of gfar_private leaves an implicit 24 byte hole after the
errata (enum) member. This patch fixes it.

The uchar bitfields were pushed towards the end of the struct
as these are not run-time performance critical (used for init
time operations). Because there is no other 2 byte member
around to couple the uchar bitfields memeber with, we will
have an addititnal 2 byte hole after the bitfields. This is
unsignificant however, and it doesn't influence gfar_priv's
size, because the whole structure is padded to be a 32B multiple.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.h |   93 +++++++++++++++--------------
 1 files changed, 48 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 8b27e5f..1e2ce8b 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -1049,28 +1049,64 @@ enum gfar_errata {
  * the buffer descriptor determines the actual condition.
  */
 struct gfar_private {
-
-	/* Indicates how many tx, rx queues are enabled */
-	unsigned int num_tx_queues;
 	unsigned int num_rx_queues;
-	unsigned int num_grps;
-	unsigned int mode;
-
-	/* The total tx and rx ring size for the enabled queues */
-	unsigned int total_tx_ring_size;
-	unsigned int total_rx_ring_size;
 
 	struct device *dev;
 	struct net_device *ndev;
-	struct platform_device *ofdev;
 	enum gfar_errata errata;
+	unsigned int rx_buffer_size;
+
+	u16 padding;
+
+	/* HW time stamping enabled flag */
+	int hwts_rx_en;
+	int hwts_tx_en;
 
-	struct gfar_priv_grp gfargrp[MAXGROUPS];
 	struct gfar_priv_tx_q *tx_queue[MAX_TX_QS];
 	struct gfar_priv_rx_q *rx_queue[MAX_RX_QS];
+	struct gfar_priv_grp gfargrp[MAXGROUPS];
+
+	u32 device_flags;
+
+	unsigned int mode;
+	unsigned int num_tx_queues;
+	unsigned int num_grps;
+
+	/* Network Statistics */
+	struct gfar_extra_stats extra_stats;
+
+	/* PHY stuff */
+	phy_interface_t interface;
+	struct device_node *phy_node;
+	struct device_node *tbi_node;
+	struct phy_device *phydev;
+	struct mii_bus *mii_bus;
+	int oldspeed;
+	int oldduplex;
+	int oldlink;
+
+	/* Bitfield update lock */
+	spinlock_t bflock;
+
+	uint32_t msg_enable;
+
+	struct work_struct reset_task;
+
+	struct platform_device *ofdev;
+	unsigned char
+		extended_hash:1,
+		bd_stash_en:1,
+		rx_filer_enable:1,
+		/* Wake-on-LAN enabled */
+		wol_en:1,
+		/* Enable priorty based Tx scheduling in Hw */
+		prio_sched_en:1;
+
+	/* The total tx and rx ring size for the enabled queues */
+	unsigned int total_tx_ring_size;
+	unsigned int total_rx_ring_size;
 
 	/* RX per device parameters */
-	unsigned int rx_buffer_size;
 	unsigned int rx_stash_size;
 	unsigned int rx_stash_index;
 
@@ -1089,39 +1125,6 @@ struct gfar_private {
 	unsigned int fifo_starve;
 	unsigned int fifo_starve_off;
 
-	/* Bitfield update lock */
-	spinlock_t bflock;
-
-	phy_interface_t interface;
-	struct device_node *phy_node;
-	struct device_node *tbi_node;
-	u32 device_flags;
-	unsigned char
-		extended_hash:1,
-		bd_stash_en:1,
-		rx_filer_enable:1,
-		wol_en:1, /* Wake-on-LAN enabled */
-		prio_sched_en:1; /* Enable priorty based Tx scheduling in Hw */
-	unsigned short padding;
-
-	/* PHY stuff */
-	struct phy_device *phydev;
-	struct mii_bus *mii_bus;
-	int oldspeed;
-	int oldduplex;
-	int oldlink;
-
-	uint32_t msg_enable;
-
-	struct work_struct reset_task;
-
-	/* Network Statistics */
-	struct gfar_extra_stats extra_stats;
-
-	/* HW time stamping enabled flag */
-	int hwts_rx_en;
-	int hwts_tx_en;
-
 	/*Filer table*/
 	unsigned int ftp_rqfpr[MAX_FILER_IDX + 1];
 	unsigned int ftp_rqfcr[MAX_FILER_IDX + 1];
-- 
1.7.7.4
