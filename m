From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 4/5] sfc: Clean up validation of datapath capabilities
Date: Tue, 17 Sep 2013 01:13:03 +0100
Message-ID: <1379376783.1945.15.camel@bwh-desktop.uk.level5networks.com>
References: <1379376611.1945.11.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:21870 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787Ab3IQANH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 20:13:07 -0400
In-Reply-To: <1379376611.1945.11.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename efx_ef10_init_capabilities() to the more specific
efx_ef10_init_datapath_caps().

Stop accepting short responses to MC_CMD_GET_CAPABILITIES; we
don't need to support pre-production firmware.

Move the check for RX prefix support from efx_ef10_probe() into
efx_ef10_init_datapath_caps() and use consistent error messages
for missing TSO support and missing RX prefix support.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 41 ++++++++++++++++++++++-------------------
 1 file changed, 22 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 80a6eea..a4956b8 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -94,7 +94,7 @@ static unsigned int efx_ef10_mem_map_size(struct efx_nic *efx)
 	return resource_size(&efx->pci_dev->resource[EFX_MEM_BAR]);
 }
 
-static int efx_ef10_init_capabilities(struct efx_nic *efx)
+static int efx_ef10_init_datapath_caps(struct efx_nic *efx)
 {
 	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_CAPABILITIES_OUT_LEN);
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
@@ -107,16 +107,27 @@ static int efx_ef10_init_capabilities(struct efx_nic *efx)
 			  outbuf, sizeof(outbuf), &outlen);
 	if (rc)
 		return rc;
+	if (outlen < sizeof(outbuf)) {
+		netif_err(efx, drv, efx->net_dev,
+			  "unable to read datapath firmware capabilities\n");
+		return -EIO;
+	}
 
-	if (outlen >= sizeof(outbuf)) {
-		nic_data->datapath_caps =
-			MCDI_DWORD(outbuf, GET_CAPABILITIES_OUT_FLAGS1);
-		if (!(nic_data->datapath_caps &
-		     (1 << MC_CMD_GET_CAPABILITIES_OUT_TX_TSO_LBN))) {
-			netif_err(efx, drv, efx->net_dev,
-				  "Capabilities don't indicate TSO support.\n");
-			return -ENODEV;
-		}
+	nic_data->datapath_caps =
+		MCDI_DWORD(outbuf, GET_CAPABILITIES_OUT_FLAGS1);
+
+	if (!(nic_data->datapath_caps &
+	      (1 << MC_CMD_GET_CAPABILITIES_OUT_TX_TSO_LBN))) {
+		netif_err(efx, drv, efx->net_dev,
+			  "current firmware does not support TSO\n");
+		return -ENODEV;
+	}
+
+	if (!(nic_data->datapath_caps &
+	      (1 << MC_CMD_GET_CAPABILITIES_OUT_RX_PREFIX_LEN_14_LBN))) {
+		netif_err(efx, probe, efx->net_dev,
+			  "current firmware does not support an RX prefix\n");
+		return -ENODEV;
 	}
 
 	return 0;
@@ -217,21 +228,13 @@ static int efx_ef10_probe(struct efx_nic *efx)
 	if (rc)
 		goto fail3;
 
-	rc = efx_ef10_init_capabilities(efx);
+	rc = efx_ef10_init_datapath_caps(efx);
 	if (rc < 0)
 		goto fail3;
 
 	efx->rx_packet_len_offset =
 		ES_DZ_RX_PREFIX_PKTLEN_OFST - ES_DZ_RX_PREFIX_SIZE;
 
-	if (!(nic_data->datapath_caps &
-	      (1 << MC_CMD_GET_CAPABILITIES_OUT_RX_PREFIX_LEN_14_LBN))) {
-		netif_err(efx, probe, efx->net_dev,
-			  "current firmware does not support an RX prefix\n");
-		rc = -ENODEV;
-		goto fail3;
-	}
-
 	rc = efx_mcdi_port_get_number(efx);
 	if (rc < 0)
 		goto fail3;


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
