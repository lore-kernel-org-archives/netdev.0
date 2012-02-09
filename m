From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 2/2] stmmac: do not discard frame on dribbling bit assert
Date: Thu,  9 Feb 2012 08:55:14 +0100
Message-ID: <1328774114-28894-2-git-send-email-peppe.cavallaro@st.com>
References: <1328774114-28894-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:59829 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750790Ab2BIHzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 02:55:39 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 98744C8
	for <netdev@vger.kernel.org>; Thu,  9 Feb 2012 07:55:29 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 5C1191B47
	for <netdev@vger.kernel.org>; Thu,  9 Feb 2012 07:55:29 +0000 (GMT)
In-Reply-To: <1328774114-28894-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If this bit is set and the CRC error is reset, then the packet is valid.
Only report this as stat info.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |    1 +
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |    2 +-
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |    2 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    7 ++++++-
 4 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index d0b814e..0319d64 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -67,6 +67,7 @@ struct stmmac_extra_stats {
 	unsigned long ipc_csum_error;
 	unsigned long rx_collision;
 	unsigned long rx_crc;
+	unsigned long dribbling_bit;
 	unsigned long rx_length;
 	unsigned long rx_mii;
 	unsigned long rx_multicast;
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
index d879763..ad1b627 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -201,7 +201,7 @@ static int enh_desc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 
 	if (unlikely(p->des01.erx.dribbling)) {
 		CHIP_DBG(KERN_ERR "GMAC RX: dribbling error\n");
-		ret = discard_frame;
+		x->dribbling_bit++;
 	}
 	if (unlikely(p->des01.erx.sa_filter_fail)) {
 		CHIP_DBG(KERN_ERR "GMAC RX : Source Address filter fail\n");
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index fda5d2b..25953bb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -104,7 +104,7 @@ static int ndesc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 		ret = discard_frame;
 	}
 	if (unlikely(p->des01.rx.dribbling))
-		ret = discard_frame;
+		x->dribbling_bit++;
 
 	if (unlikely(p->des01.rx.length_error)) {
 		x->rx_length++;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 9573303..f98e151 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -47,23 +47,25 @@ struct stmmac_stats {
 	offsetof(struct stmmac_priv, xstats.m)}
 
 static const struct stmmac_stats stmmac_gstrings_stats[] = {
+	/* Transmit errors */
 	STMMAC_STAT(tx_underflow),
 	STMMAC_STAT(tx_carrier),
 	STMMAC_STAT(tx_losscarrier),
 	STMMAC_STAT(vlan_tag),
 	STMMAC_STAT(tx_deferred),
 	STMMAC_STAT(tx_vlan),
-	STMMAC_STAT(rx_vlan),
 	STMMAC_STAT(tx_jabber),
 	STMMAC_STAT(tx_frame_flushed),
 	STMMAC_STAT(tx_payload_error),
 	STMMAC_STAT(tx_ip_header_error),
+	/* Receive errors */
 	STMMAC_STAT(rx_desc),
 	STMMAC_STAT(sa_filter_fail),
 	STMMAC_STAT(overflow_error),
 	STMMAC_STAT(ipc_csum_error),
 	STMMAC_STAT(rx_collision),
 	STMMAC_STAT(rx_crc),
+	STMMAC_STAT(dribbling_bit),
 	STMMAC_STAT(rx_length),
 	STMMAC_STAT(rx_mii),
 	STMMAC_STAT(rx_multicast),
@@ -73,6 +75,8 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(sa_rx_filter_fail),
 	STMMAC_STAT(rx_missed_cntr),
 	STMMAC_STAT(rx_overflow_cntr),
+	STMMAC_STAT(rx_vlan),
+	/* Tx/Rx IRQ errors */
 	STMMAC_STAT(tx_undeflow_irq),
 	STMMAC_STAT(tx_process_stopped_irq),
 	STMMAC_STAT(tx_jabber_irq),
@@ -82,6 +86,7 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(rx_watchdog_irq),
 	STMMAC_STAT(tx_early_irq),
 	STMMAC_STAT(fatal_bus_error_irq),
+	/* Extra info */
 	STMMAC_STAT(threshold),
 	STMMAC_STAT(tx_pkt_n),
 	STMMAC_STAT(rx_pkt_n),
-- 
1.7.4.4
