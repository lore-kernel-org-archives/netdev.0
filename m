From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 2/6] amd-xgbe: VLAN Tx tag insertion fix
Date: Tue, 24 Jun 2014 16:19:12 -0500
Message-ID: <20140624211912.20681.99354.stgit@tlendack-t1.amdoffice.net>
References: <20140624211900.20681.46554.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [207.46.163.207] ([207.46.163.207]:22904 "EHLO
	na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754051AbaFXVUC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2014 17:20:02 -0400
In-Reply-To: <20140624211900.20681.46554.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MAC_VLAN_Incl register (0x0060) must be set to indicate
that the VLAN tag to be inserted comes from a Tx context
descriptor and not the MAC_VLAN_Incl register.  Also, even
though it is the default, explicitly set the type of tag to
be inserted as a CTAG.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-common.h |    4 ++++
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c    |    4 ++++
 2 files changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-common.h b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
index bf462ee8..129d322 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-common.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
@@ -427,6 +427,10 @@
 #define MAC_TCR_SS_WIDTH		2
 #define MAC_TCR_TE_INDEX		0
 #define MAC_TCR_TE_WIDTH		1
+#define MAC_VLANIR_VLTI_INDEX		20
+#define MAC_VLANIR_VLTI_WIDTH		1
+#define MAC_VLANIR_CSVL_INDEX		19
+#define MAC_VLANIR_CSVL_WIDTH		1
 #define MAC_VLANTR_DOVLTC_INDEX		20
 #define MAC_VLANTR_DOVLTC_WIDTH		1
 #define MAC_VLANTR_ERSVLM_INDEX		19
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 864af2d..b239b21 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1541,6 +1541,10 @@ static void xgbe_config_checksum_offload(struct xgbe_prv_data *pdata)
 
 static void xgbe_config_vlan_support(struct xgbe_prv_data *pdata)
 {
+	/* Indicate that VLAN Tx CTAGs come from context descriptors */
+	XGMAC_IOWRITE_BITS(pdata, MAC_VLANIR, CSVL, 0);
+	XGMAC_IOWRITE_BITS(pdata, MAC_VLANIR, VLTI, 1);
+
 	if (pdata->netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
 		xgbe_enable_rx_vlan_stripping(pdata);
 	else
