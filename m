From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 2/2] sfc: report 4-tuple UDP hashing to ethtool, if
 it's enabled
Date: Thu, 3 Nov 2016 22:12:58 +0000
Message-ID: <aefd2a6f-5081-6ef6-cfcc-db47ffa8f6a2@solarflare.com>
References: <ba5aa0bc-277b-5b47-89f8-fad1010b77f9@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
        <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:50066 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754034AbcKCWNI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 18:13:08 -0400
In-Reply-To: <ba5aa0bc-277b-5b47-89f8-fad1010b77f9@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       |  6 ++++--
 drivers/net/ethernet/sfc/ethtool.c    | 12 ++++++++----
 drivers/net/ethernet/sfc/net_driver.h |  2 ++
 3 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 9f6d769..e61807e 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -2319,8 +2319,10 @@ static void efx_ef10_set_rss_flags(struct efx_nic *efx, u32 context)
 	flags |= RSS_MODE_HASH_PORTS << MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_UDP_IPV4_RSS_MODE_LBN;
 	flags |= RSS_MODE_HASH_PORTS << MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_UDP_IPV6_RSS_MODE_LBN;
 	MCDI_SET_DWORD(inbuf, RSS_CONTEXT_SET_FLAGS_IN_FLAGS, flags);
-	efx_mcdi_rpc(efx, MC_CMD_RSS_CONTEXT_SET_FLAGS, inbuf, sizeof(inbuf),
-		     NULL, 0, NULL);
+	if (!efx_mcdi_rpc(efx, MC_CMD_RSS_CONTEXT_SET_FLAGS, inbuf, sizeof(inbuf),
+			  NULL, 0, NULL))
+		/* Succeeded, so UDP 4-tuple is now enabled */
+		efx->rx_hash_udp_4tuple = true;
 }
 
 static int efx_ef10_alloc_rss_context(struct efx_nic *efx, u32 *context,
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 445ccdb..bf126f9 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -968,20 +968,24 @@ efx_ethtool_get_rxnfc(struct net_device *net_dev,
 
 		info->data = 0;
 		switch (info->flow_type) {
+		case UDP_V4_FLOW:
+			if (efx->rx_hash_udp_4tuple)
+				/* fall through */
 		case TCP_V4_FLOW:
-			info->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+				info->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
 			/* fall through */
-		case UDP_V4_FLOW:
 		case SCTP_V4_FLOW:
 		case AH_ESP_V4_FLOW:
 		case IPV4_FLOW:
 			info->data |= RXH_IP_SRC | RXH_IP_DST;
 			min_revision = EFX_REV_FALCON_B0;
 			break;
+		case UDP_V6_FLOW:
+			if (efx->rx_hash_udp_4tuple)
+				/* fall through */
 		case TCP_V6_FLOW:
-			info->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+				info->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
 			/* fall through */
-		case UDP_V6_FLOW:
 		case SCTP_V6_FLOW:
 		case AH_ESP_V6_FLOW:
 		case IPV6_FLOW:
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 99d8c82..fec51c4 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -853,6 +853,7 @@ struct vfdi_status;
  * @rx_hash_key: Toeplitz hash key for RSS
  * @rx_indir_table: Indirection table for RSS
  * @rx_scatter: Scatter mode enabled for receives
+ * @rx_hash_udp_4tuple: UDP 4-tuple hashing enabled
  * @int_error_count: Number of internal errors seen recently
  * @int_error_expire: Time at which error count will be expired
  * @irq_soft_enabled: Are IRQs soft-enabled? If not, IRQ handler will
@@ -990,6 +991,7 @@ struct efx_nic {
 	u8 rx_hash_key[40];
 	u32 rx_indir_table[128];
 	bool rx_scatter;
+	bool rx_hash_udp_4tuple;
 
 	unsigned int_error_count;
 	unsigned long int_error_expire;
