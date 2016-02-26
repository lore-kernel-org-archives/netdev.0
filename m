From: Lada Trimasova <Lada.Trimasova@synopsys.com>
Subject: [PATCH] net: ezchip: adapt driver to little endian architecture
Date: Fri, 26 Feb 2016 22:05:09 +0300
Message-ID: <1456513509-30844-1-git-send-email-ltrimas@synopsys.com>
Cc: linux-kernel@vger.kernel.org,
	Lada Trimasova <Lada.Trimasova@synopsys.com>,
	Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	Noam Camus <noamc@ezchip.com>, Tal Zilcer <talz@ezchip.com>,
	Arnd Bergmann <arnd@arndb.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:55426 "EHLO
	smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422808AbcBZTFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 14:05:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since ezchip network driver is written with big endian EZChip platform it
is necessary to add support for little endian architecture.

The first issue is that big endian machines pack bitfields from
most significant byte to least as against little endian ones.
So this patch provides reversed order of bitfields defined in header file
in case of not defined "CONFIG_CPU_BIG_ENDIAN".

And the second one is that network byte order is big endian.
For example, data on ethernet is transmitted with most-significant
octet (byte) first. So in case of little endian architecture
it is important to swap data byte order when we read it from
register. For this we should use function "be32_to_cpu" as we read from
peripheral to CPU.
And then when we are going to write data to register we need to restore
byte order using the function "cpu_to_be32" as we write from CPU to
peripheral.

The last little fix is a space between a type and a pointer to observe
coding style.

Signed-off-by: Lada Trimasova <ltrimas@synopsys.com>
Cc: Alexey Brodkin <abrodkin@synopsys.com>
Cc: Noam Camus <noamc@ezchip.com>
Cc: Tal Zilcer <talz@ezchip.com>
Cc: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/ezchip/nps_enet.c | 15 ++++--
 drivers/net/ethernet/ezchip/nps_enet.h | 99 ++++++++++++++++++++++++++++++++++
 2 files changed, 110 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ezchip/nps_enet.c b/drivers/net/ethernet/ezchip/nps_enet.c
index b102668..43cf9d3 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.c
+++ b/drivers/net/ethernet/ezchip/nps_enet.c
@@ -44,11 +44,15 @@ static void nps_enet_read_rx_fifo(struct net_device *ndev,
 
 	/* In case dst is not aligned we need an intermediate buffer */
 	if (dst_is_aligned)
-		for (i = 0; i < len; i++, reg++)
+		for (i = 0; i < len; i++, reg++) {
 			*reg = nps_enet_reg_get(priv, NPS_ENET_REG_RX_BUF);
+			/* In case of LE we need to swap bytes */
+			*reg = be32_to_cpu(*reg);
+		}
 	else { /* !dst_is_aligned */
 		for (i = 0; i < len; i++, reg++) {
 			u32 buf = nps_enet_reg_get(priv, NPS_ENET_REG_RX_BUF);
+			buf = be32_to_cpu(buf);
 			put_unaligned(buf, reg);
 		}
 	}
@@ -56,7 +60,8 @@ static void nps_enet_read_rx_fifo(struct net_device *ndev,
 	/* copy last bytes (if any) */
 	if (last) {
 		u32 buf = nps_enet_reg_get(priv, NPS_ENET_REG_RX_BUF);
-		memcpy((u8*)reg, &buf, last);
+		buf = be32_to_cpu(buf);
+		memcpy((u8 *)reg, &buf, last);
 	}
 }
 
@@ -368,11 +373,13 @@ static void nps_enet_send_frame(struct net_device *ndev,
 	/* In case src is not aligned we need an intermediate buffer */
 	if (src_is_aligned)
 		for (i = 0; i < len; i++, src++)
-			nps_enet_reg_set(priv, NPS_ENET_REG_TX_BUF, *src);
+			/* Restore endian swapped during register reading */
+			nps_enet_reg_set(priv, NPS_ENET_REG_TX_BUF,
+					 cpu_to_be32(*src));
 	else /* !src_is_aligned */
 		for (i = 0; i < len; i++, src++)
 			nps_enet_reg_set(priv, NPS_ENET_REG_TX_BUF,
-					 get_unaligned(src));
+					 cpu_to_be32(get_unaligned(src)));
 
 	/* Write the length of the Frame */
 	tx_ctrl.nt = length;
diff --git a/drivers/net/ethernet/ezchip/nps_enet.h b/drivers/net/ethernet/ezchip/nps_enet.h
index 6703674..2d068ad 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.h
+++ b/drivers/net/ethernet/ezchip/nps_enet.h
@@ -52,12 +52,23 @@ struct nps_enet_tx_ctl {
 		 * nt: Length in bytes of Tx frame loaded to Tx buffer
 		 */
 		struct {
+#ifdef CONFIG_CPU_BIG_ENDIAN
 			u32
 			__reserved_1:16,
 			ct:1,
 			et:1,
 			__reserved_2:3,
 			nt:11;
+
+#else
+			u32
+			nt:11,
+			__reserved_2:3,
+			et:1,
+			ct:1,
+			__reserved_1:16;
+
+#endif
 		};
 
 		u32 value;
@@ -75,6 +86,7 @@ struct nps_enet_rx_ctl {
 		 * nr:  Length in bytes of Rx frame loaded by MAC to Rx buffer
 		 */
 		struct {
+#ifdef CONFIG_CPU_BIG_ENDIAN
 			u32
 			__reserved_1:16,
 			cr:1,
@@ -82,6 +94,15 @@ struct nps_enet_rx_ctl {
 			crc:1,
 			__reserved_2:2,
 			nr:11;
+#else
+			u32
+			nr:11,
+			__reserved_2:2,
+			crc:1,
+			er:1,
+			cr:1,
+			__reserved_1:16;
+#endif
 		};
 
 		u32 value;
@@ -97,10 +118,17 @@ struct nps_enet_buf_int_enable {
 		 *          was read from TX buffer
 		 */
 		struct {
+#ifdef CONFIG_CPU_BIG_ENDIAN
 			u32
 			__reserved:30,
 			tx_done:1,
 			rx_rdy:1;
+#else
+			u32
+			rx_rdy:1,
+			tx_done:1,
+			__reserved:30;
+#endif
 		};
 
 		u32 value;
@@ -128,6 +156,7 @@ struct nps_enet_ge_mac_cfg_0 {
 		 * rx_en:              Receive Enable
 		 */
 		struct {
+#ifdef CONFIG_CPU_BIG_ENDIAN
 			u32
 			tx_pr_len:4,
 			tx_ifg_nib:4,
@@ -145,6 +174,25 @@ struct nps_enet_ge_mac_cfg_0 {
 			tx_fc_en:1,
 			tx_en:1,
 			rx_en:1;
+#else
+			u32
+			rx_en:1,
+			tx_en:1,
+			tx_fc_en:1,
+			tx_pad_en:1,
+			tx_crc_en:1,
+			rx_fc_en:1,
+			rx_crc_strip:1,
+			rx_crc_ignore:1,
+			rx_length_check_en:1,
+			tx_fc_retr:3,
+			rx_ifg:4,
+			tx_ifg:6,
+			rx_pr_check_en:1,
+			nib_mode:1,
+			tx_ifg_nib:4,
+			tx_pr_len:4;
+#endif
 		};
 
 		u32 value;
@@ -160,11 +208,19 @@ struct nps_enet_ge_mac_cfg_1 {
 		 * octet_0: MAC address octet 0
 		 */
 		struct {
+#ifdef CONFIG_CPU_BIG_ENDIAN
 			u32
 			octet_3:8,
 			octet_2:8,
 			octet_1:8,
 			octet_0:8;
+#else
+			u32
+			octet_0:8,
+			octet_1:8,
+			octet_2:8,
+			octet_3:8;
+#endif
 		};
 
 		u32 value;
@@ -184,6 +240,7 @@ struct nps_enet_ge_mac_cfg_2 {
 		 * octet_4:           MAC address octet 4
 		 */
 		struct {
+#ifdef CONFIG_CPU_BIG_ENDIAN
 			u32
 			transmit_flush_en:1,
 			__reserved_1:5,
@@ -195,6 +252,19 @@ struct nps_enet_ge_mac_cfg_2 {
 			__reserved_3:4,
 			octet_5:8,
 			octet_4:8;
+#else
+			u32
+			octet_4:8,
+			octet_5:8,
+			__reserved_3:4,
+			disc_mc:1,
+			disc_bc:1,
+			disc_da:1,
+			__reserved_2:1,
+			stat_en:2,
+			__reserved_1:5,
+			transmit_flush_en:1;
+#endif
 		};
 
 		u32 value;
@@ -219,6 +289,7 @@ struct nps_enet_ge_mac_cfg_3 {
 		 * tm_hd_mode:        TM header mode
 		 */
 		struct {
+#ifdef CONFIG_CPU_BIG_ENDIAN
 			u32
 			ext_oob_cbfc_sel:2,
 			max_len:14,
@@ -230,6 +301,19 @@ struct nps_enet_ge_mac_cfg_3 {
 			rx_cbfc_redir_en:1,
 			rx_cbfc_en:1,
 			tm_hd_mode:1;
+#else
+			u32
+			tm_hd_mode:1,
+			rx_cbfc_en:1,
+			rx_cbfc_redir_en:1,
+			redirect_cbfc_sel:2,
+			cf_drop:1,
+			cf_timeout:4,
+			rx_ifg_th:5,
+			tx_cbfc_en:1,
+			max_len:14,
+			ext_oob_cbfc_sel:2;
+#endif
 		};
 
 		u32 value;
@@ -243,11 +327,19 @@ struct nps_enet_ge_rst {
 		 * spcs_0: SGMII PCS reset
 		 */
 		struct {
+#ifdef CONFIG_CPU_BIG_ENDIAN
 			u32
 			__reserved_1:23,
 			gmac_0:1,
 			__reserved_2:7,
 			spcs_0:1;
+#else
+			u32
+			spcs_0:1,
+			__reserved_2:7,
+			gmac_0:1,
+			__reserved_1:23;
+#endif
 		};
 
 		u32 value;
@@ -261,10 +353,17 @@ struct nps_enet_phase_fifo_ctl {
 		 * rst:  reset serdes TX phase sync FIFO
 		 */
 		struct {
+#ifdef CONFIG_CPU_BIG_ENDIAN
 			u32
 			__reserved:30,
 			init:1,
 			rst:1;
+#else
+			u32
+			rst:1,
+			init:1,
+			__reserved:30;
+#endif
 		};
 
 		u32 value;
-- 
2.5.0
