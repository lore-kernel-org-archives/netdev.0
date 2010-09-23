From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 6/7] ethtool: Update sfc register dump
Date: Thu, 23 Sep 2010 22:50:00 +0100
Message-ID: <1285278600.7794.33.camel@achroite.uk.solarflarecom.com>
References: <1285278428.7794.27.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:54710 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755167Ab0IWVuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 17:50:03 -0400
In-Reply-To: <1285278428.7794.27.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add length checks to allow for extensions to the register dump without
changing the version number.

Show the RX IP filter table if present.

Fix address field definitions for the MAC filter tables.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 sfc.c |   25 ++++++++++++++-----------
 1 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/sfc.c b/sfc.c
index 2e4735f..c8ca74a 100644
--- a/sfc.c
+++ b/sfc.c
@@ -2420,8 +2420,8 @@
 #define	FRF_CZ_RMFT_RXQ_ID_WIDTH 12
 #define	FRF_CZ_RMFT_WILDCARD_MATCH_LBN 60
 #define	FRF_CZ_RMFT_WILDCARD_MATCH_WIDTH 1
-#define	FRF_CZ_RMFT_DEST_MAC_LBN 16
-#define	FRF_CZ_RMFT_DEST_MAC_WIDTH 44
+#define	FRF_CZ_RMFT_DEST_MAC_LBN 12
+#define	FRF_CZ_RMFT_DEST_MAC_WIDTH 48
 #define	FRF_CZ_RMFT_VLAN_ID_LBN 0
 #define	FRF_CZ_RMFT_VLAN_ID_WIDTH 12
 
@@ -2497,8 +2497,8 @@
 #define	FRF_CZ_TMFT_TXQ_ID_WIDTH 12
 #define	FRF_CZ_TMFT_WILDCARD_MATCH_LBN 60
 #define	FRF_CZ_TMFT_WILDCARD_MATCH_WIDTH 1
-#define	FRF_CZ_TMFT_SRC_MAC_LBN 16
-#define	FRF_CZ_TMFT_SRC_MAC_WIDTH 44
+#define	FRF_CZ_TMFT_SRC_MAC_LBN 12
+#define	FRF_CZ_TMFT_SRC_MAC_WIDTH 48
 #define	FRF_CZ_TMFT_VLAN_ID_LBN 0
 #define	FRF_CZ_TMFT_VLAN_ID_WIDTH 12
 
@@ -3445,9 +3445,11 @@ static const struct efx_nic_reg_field efx_nic_reg_fields_BUF_FULL_TBL[] = {
 };
 #define efx_nic_reg_fields_BUF_FULL_TBL_KER efx_nic_reg_fields_BUF_FULL_TBL
 static const struct efx_nic_reg_field efx_nic_reg_fields_RX_FILTER_TBL0[] = {
-	REGISTER_FIELD_BZ(SRC_TCP_DEST_UDP),
+	/* Source port for full match; destination port for UDP wild match */
+	REGISTER_FIELD_BZ_RENAME(SRC_TCP_DEST_UDP, "SRC_PORT"),
 	REGISTER_FIELD_BZ(SRC_IP),
-	REGISTER_FIELD_BZ(DEST_PORT_TCP),
+	/* Destination port for full match or TCP wild match */
+	REGISTER_FIELD_BZ_RENAME(DEST_PORT_TCP, "DEST_PORT"),
 	REGISTER_FIELD_BZ(DEST_IP),
 	REGISTER_FIELD_BZ(RXQ_ID),
 	REGISTER_FIELD_BZ(TCP_UDP),
@@ -3663,8 +3665,7 @@ static const struct efx_nic_reg_table efx_nic_reg_tables[] = {
 	REGISTER_TABLE_BB_CZ(TX_DESC_PTR_TBL),
 	REGISTER_TABLE_AA(EVQ_PTR_TBL_KER),
 	REGISTER_TABLE_BB_CZ(EVQ_PTR_TBL),
-	/* The register buffer is allocated with slab, so we can't
-	 * reasonably read all of the buffer table (up to 8MB!).
+	/* We can't reasonably read all of the buffer table (up to 8MB!).
 	 * However this driver will only use a few entries.  Reading
 	 * 1K entries allows for some expansion of queue count and
 	 * size before we need to change the version. */
@@ -3672,7 +3673,6 @@ static const struct efx_nic_reg_table efx_nic_reg_tables[] = {
 				  A, A, 8, 1024),
 	REGISTER_TABLE_DIMENSIONS(BUF_FULL_TBL, FR_BZ_BUF_FULL_TBL,
 				  B, Z, 8, 1024),
-	/* RX_FILTER_TBL{0,1} is huge and not used by this driver */
 	REGISTER_TABLE_CZ(RX_MAC_FILTER_TBL0),
 	REGISTER_TABLE_BB_CZ(TIMER_TBL),
 	REGISTER_TABLE_BB_CZ(TX_PACE_TBL),
@@ -3682,6 +3682,7 @@ static const struct efx_nic_reg_table efx_nic_reg_tables[] = {
 	REGISTER_TABLE_CZ(MC_TREG_SMEM),
 	/* MSIX_PBA_TABLE is not mapped */
 	/* SRM_DBG is not mapped (and is redundant with BUF_FLL_TBL) */
+	REGISTER_TABLE_BZ(RX_FILTER_TBL0),
 };
 
 static size_t column_width(const struct efx_nic_reg_field *field)
@@ -3830,12 +3831,13 @@ sfc_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 	const struct efx_nic_reg_table *table;
 	unsigned revision = regs->version;
 	const void *buf = regs->data;
+	const void *end = regs->data + regs->len;
 
 	if (revision > REGISTER_REVISION_Z)
 		return -1;
 
 	for (reg = efx_nic_regs;	
-	     reg < efx_nic_regs + ARRAY_SIZE(efx_nic_regs);
+	     reg < efx_nic_regs + ARRAY_SIZE(efx_nic_regs) && buf < end;
 	     reg++) {
 		if (revision >= reg->min_revision &&
 		    revision <= reg->max_revision)
@@ -3843,7 +3845,8 @@ sfc_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 	}
 
 	for (table = efx_nic_reg_tables;
-	     table < efx_nic_reg_tables + ARRAY_SIZE(efx_nic_reg_tables);
+	     table < efx_nic_reg_tables + ARRAY_SIZE(efx_nic_reg_tables) &&
+		     buf < end;
 	     table++) {
 		if (revision >= table->min_revision &&
 		    revision <= table->max_revision) {
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

