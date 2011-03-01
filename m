From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 3/8] sfc: Read MC firmware version when
 requested through ethtool
Date: Tue, 01 Mar 2011 01:22:37 +0000
Message-ID: <1298942557.3069.182.camel@localhost>
References: <1298942169.3069.179.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12027 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755010Ab1CABWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 20:22:41 -0500
In-Reply-To: <1298942169.3069.179.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently make no use of siena_nic_data::fw_{version,build} except
to format the firmware version for ethtool_get_drvinfo().  Since we
only read the version at start of day, this information is incorrect
after an MC firmware update.  Remove the cached version information
and read it via MCDI whenever it is requested.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c |    4 ++--
 drivers/net/sfc/mcdi.c    |   21 ++++++---------------
 drivers/net/sfc/mcdi.h    |    2 +-
 drivers/net/sfc/nic.h     |    6 ------
 drivers/net/sfc/siena.c   |   17 -----------------
 5 files changed, 9 insertions(+), 41 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 272cfe7..3e974b1 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -237,8 +237,8 @@ static void efx_ethtool_get_drvinfo(struct net_device *net_dev,
 	strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
 	strlcpy(info->version, EFX_DRIVER_VERSION, sizeof(info->version));
 	if (efx_nic_rev(efx) >= EFX_REV_SIENA_A0)
-		siena_print_fwver(efx, info->fw_version,
-				  sizeof(info->fw_version));
+		efx_mcdi_print_fwver(efx, info->fw_version,
+				     sizeof(info->fw_version));
 	strlcpy(info->bus_info, pci_name(efx->pci_dev), sizeof(info->bus_info));
 }
 
diff --git a/drivers/net/sfc/mcdi.c b/drivers/net/sfc/mcdi.c
index b716e82..88e786b 100644
--- a/drivers/net/sfc/mcdi.c
+++ b/drivers/net/sfc/mcdi.c
@@ -602,7 +602,7 @@ void efx_mcdi_process_event(struct efx_channel *channel,
  **************************************************************************
  */
 
-int efx_mcdi_fwver(struct efx_nic *efx, u64 *version, u32 *build)
+void efx_mcdi_print_fwver(struct efx_nic *efx, char *buf, size_t len)
 {
 	u8 outbuf[ALIGN(MC_CMD_GET_VERSION_V1_OUT_LEN, 4)];
 	size_t outlength;
@@ -616,29 +616,20 @@ int efx_mcdi_fwver(struct efx_nic *efx, u64 *version, u32 *build)
 	if (rc)
 		goto fail;
 
-	if (outlength == MC_CMD_GET_VERSION_V0_OUT_LEN) {
-		*version = 0;
-		*build = MCDI_DWORD(outbuf, GET_VERSION_OUT_FIRMWARE);
-		return 0;
-	}
-
 	if (outlength < MC_CMD_GET_VERSION_V1_OUT_LEN) {
 		rc = -EIO;
 		goto fail;
 	}
 
 	ver_words = (__le16 *)MCDI_PTR(outbuf, GET_VERSION_OUT_VERSION);
-	*version = (((u64)le16_to_cpu(ver_words[0]) << 48) |
-		    ((u64)le16_to_cpu(ver_words[1]) << 32) |
-		    ((u64)le16_to_cpu(ver_words[2]) << 16) |
-		    le16_to_cpu(ver_words[3]));
-	*build = MCDI_DWORD(outbuf, GET_VERSION_OUT_FIRMWARE);
-
-	return 0;
+	snprintf(buf, len, "%u.%u.%u.%u",
+		 le16_to_cpu(ver_words[0]), le16_to_cpu(ver_words[1]),
+		 le16_to_cpu(ver_words[2]), le16_to_cpu(ver_words[3]));
+	return;
 
 fail:
 	netif_err(efx, probe, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
-	return rc;
+	buf[0] = 0;
 }
 
 int efx_mcdi_drv_attach(struct efx_nic *efx, bool driver_operating,
diff --git a/drivers/net/sfc/mcdi.h b/drivers/net/sfc/mcdi.h
index c792f1d..9bac250 100644
--- a/drivers/net/sfc/mcdi.h
+++ b/drivers/net/sfc/mcdi.h
@@ -93,7 +93,7 @@ extern void efx_mcdi_process_event(struct efx_channel *channel,
 #define MCDI_EVENT_FIELD(_ev, _field)			\
 	EFX_QWORD_FIELD(_ev, MCDI_EVENT_ ## _field)
 
-extern int efx_mcdi_fwver(struct efx_nic *efx, u64 *version, u32 *build);
+extern void efx_mcdi_print_fwver(struct efx_nic *efx, char *buf, size_t len);
 extern int efx_mcdi_drv_attach(struct efx_nic *efx, bool driver_operating,
 			       bool *was_attached_out);
 extern int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
diff --git a/drivers/net/sfc/nic.h b/drivers/net/sfc/nic.h
index eb05869..17407ea 100644
--- a/drivers/net/sfc/nic.h
+++ b/drivers/net/sfc/nic.h
@@ -142,20 +142,14 @@ static inline struct falcon_board *falcon_board(struct efx_nic *efx)
 
 /**
  * struct siena_nic_data - Siena NIC state
- * @fw_version: Management controller firmware version
- * @fw_build: Firmware build number
  * @mcdi: Management-Controller-to-Driver Interface
  * @wol_filter_id: Wake-on-LAN packet filter id
  */
 struct siena_nic_data {
-	u64 fw_version;
-	u32 fw_build;
 	struct efx_mcdi_iface mcdi;
 	int wol_filter_id;
 };
 
-extern void siena_print_fwver(struct efx_nic *efx, char *buf, size_t len);
-
 extern struct efx_nic_type falcon_a1_nic_type;
 extern struct efx_nic_type falcon_b0_nic_type;
 extern struct efx_nic_type siena_a0_nic_type;
diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index bf84561..07b59a8 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -227,13 +227,6 @@ static int siena_probe_nic(struct efx_nic *efx)
 	if (rc)
 		goto fail1;
 
-	rc = efx_mcdi_fwver(efx, &nic_data->fw_version, &nic_data->fw_build);
-	if (rc) {
-		netif_err(efx, probe, efx->net_dev,
-			  "Failed to read MCPU firmware version - rc %d\n", rc);
-		goto fail1; /* MCPU absent? */
-	}
-
 	/* Let the BMC know that the driver is now in charge of link and
 	 * filter settings. We must do this before we reset the NIC */
 	rc = efx_mcdi_drv_attach(efx, true, &already_attached);
@@ -514,16 +507,6 @@ static void siena_stop_nic_stats(struct efx_nic *efx)
 	efx_mcdi_mac_stats(efx, efx->stats_buffer.dma_addr, 0, 0, 0);
 }
 
-void siena_print_fwver(struct efx_nic *efx, char *buf, size_t len)
-{
-	struct siena_nic_data *nic_data = efx->nic_data;
-	snprintf(buf, len, "%u.%u.%u.%u",
-		 (unsigned int)(nic_data->fw_version >> 48),
-		 (unsigned int)(nic_data->fw_version >> 32 & 0xffff),
-		 (unsigned int)(nic_data->fw_version >> 16 & 0xffff),
-		 (unsigned int)(nic_data->fw_version & 0xffff));
-}
-
 /**************************************************************************
  *
  * Wake on LAN
-- 
1.5.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

