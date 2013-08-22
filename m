From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 06/32] sfc: Introduce and use MCDI_DECLARE_BUF macro
Date: Thu, 22 Aug 2013 13:46:34 +0100
Message-ID: <1377175594.1703.11.camel@bwh-desktop.uk.level5networks.com>
References: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:13555 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753172Ab3HVMqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 08:46:37 -0400
In-Reply-To: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MCDI_DECLARE_BUF declares a variable as an MCDI buffer of the
requested length, adding any necessary padding.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c        | 52 ++++++++++++++++++----------------
 drivers/net/ethernet/sfc/mcdi.h        |  3 ++
 drivers/net/ethernet/sfc/mcdi_mac.c    | 17 +++++++----
 drivers/net/ethernet/sfc/mcdi_mon.c    |  4 +--
 drivers/net/ethernet/sfc/mcdi_phy.c    | 26 ++++++++---------
 drivers/net/ethernet/sfc/ptp.c         | 16 +++++------
 drivers/net/ethernet/sfc/siena_sriov.c |  4 +--
 7 files changed, 66 insertions(+), 56 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 97dd8f18..d65b562 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -606,7 +606,7 @@ void efx_mcdi_process_event(struct efx_channel *channel,
 
 void efx_mcdi_print_fwver(struct efx_nic *efx, char *buf, size_t len)
 {
-	u8 outbuf[ALIGN(MC_CMD_GET_VERSION_OUT_LEN, 4)];
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_VERSION_OUT_LEN);
 	size_t outlength;
 	const __le16 *ver_words;
 	int rc;
@@ -637,8 +637,8 @@ fail:
 int efx_mcdi_drv_attach(struct efx_nic *efx, bool driver_operating,
 			bool *was_attached)
 {
-	u8 inbuf[MC_CMD_DRV_ATTACH_IN_LEN];
-	u8 outbuf[MC_CMD_DRV_ATTACH_OUT_LEN];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_DRV_ATTACH_IN_LEN);
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_DRV_ATTACH_OUT_LEN);
 	size_t outlen;
 	int rc;
 
@@ -667,7 +667,7 @@ fail:
 int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
 			   u16 *fw_subtype_list, u32 *capabilities)
 {
-	uint8_t outbuf[MC_CMD_GET_BOARD_CFG_OUT_LENMAX];
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_BOARD_CFG_OUT_LENMAX);
 	size_t outlen, offset, i;
 	int port_num = efx_port_num(efx);
 	int rc;
@@ -721,7 +721,7 @@ fail:
 
 int efx_mcdi_log_ctrl(struct efx_nic *efx, bool evq, bool uart, u32 dest_evq)
 {
-	u8 inbuf[MC_CMD_LOG_CTRL_IN_LEN];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_LOG_CTRL_IN_LEN);
 	u32 dest = 0;
 	int rc;
 
@@ -749,7 +749,7 @@ fail:
 
 int efx_mcdi_nvram_types(struct efx_nic *efx, u32 *nvram_types_out)
 {
-	u8 outbuf[MC_CMD_NVRAM_TYPES_OUT_LEN];
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_NVRAM_TYPES_OUT_LEN);
 	size_t outlen;
 	int rc;
 
@@ -777,8 +777,8 @@ int efx_mcdi_nvram_info(struct efx_nic *efx, unsigned int type,
 			size_t *size_out, size_t *erase_size_out,
 			bool *protected_out)
 {
-	u8 inbuf[MC_CMD_NVRAM_INFO_IN_LEN];
-	u8 outbuf[MC_CMD_NVRAM_INFO_OUT_LEN];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_NVRAM_INFO_IN_LEN);
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_NVRAM_INFO_OUT_LEN);
 	size_t outlen;
 	int rc;
 
@@ -806,7 +806,7 @@ fail:
 
 int efx_mcdi_nvram_update_start(struct efx_nic *efx, unsigned int type)
 {
-	u8 inbuf[MC_CMD_NVRAM_UPDATE_START_IN_LEN];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_NVRAM_UPDATE_START_IN_LEN);
 	int rc;
 
 	MCDI_SET_DWORD(inbuf, NVRAM_UPDATE_START_IN_TYPE, type);
@@ -828,8 +828,9 @@ fail:
 int efx_mcdi_nvram_read(struct efx_nic *efx, unsigned int type,
 			loff_t offset, u8 *buffer, size_t length)
 {
-	u8 inbuf[MC_CMD_NVRAM_READ_IN_LEN];
-	u8 outbuf[MC_CMD_NVRAM_READ_OUT_LEN(EFX_MCDI_NVRAM_LEN_MAX)];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_NVRAM_READ_IN_LEN);
+	MCDI_DECLARE_BUF(outbuf,
+			 MC_CMD_NVRAM_READ_OUT_LEN(EFX_MCDI_NVRAM_LEN_MAX));
 	size_t outlen;
 	int rc;
 
@@ -853,7 +854,8 @@ fail:
 int efx_mcdi_nvram_write(struct efx_nic *efx, unsigned int type,
 			   loff_t offset, const u8 *buffer, size_t length)
 {
-	u8 inbuf[MC_CMD_NVRAM_WRITE_IN_LEN(EFX_MCDI_NVRAM_LEN_MAX)];
+	MCDI_DECLARE_BUF(inbuf,
+			 MC_CMD_NVRAM_WRITE_IN_LEN(EFX_MCDI_NVRAM_LEN_MAX));
 	int rc;
 
 	MCDI_SET_DWORD(inbuf, NVRAM_WRITE_IN_TYPE, type);
@@ -879,7 +881,7 @@ fail:
 int efx_mcdi_nvram_erase(struct efx_nic *efx, unsigned int type,
 			 loff_t offset, size_t length)
 {
-	u8 inbuf[MC_CMD_NVRAM_ERASE_IN_LEN];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_NVRAM_ERASE_IN_LEN);
 	int rc;
 
 	MCDI_SET_DWORD(inbuf, NVRAM_ERASE_IN_TYPE, type);
@@ -902,7 +904,7 @@ fail:
 
 int efx_mcdi_nvram_update_finish(struct efx_nic *efx, unsigned int type)
 {
-	u8 inbuf[MC_CMD_NVRAM_UPDATE_FINISH_IN_LEN];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_NVRAM_UPDATE_FINISH_IN_LEN);
 	int rc;
 
 	MCDI_SET_DWORD(inbuf, NVRAM_UPDATE_FINISH_IN_TYPE, type);
@@ -923,8 +925,8 @@ fail:
 
 static int efx_mcdi_nvram_test(struct efx_nic *efx, unsigned int type)
 {
-	u8 inbuf[MC_CMD_NVRAM_TEST_IN_LEN];
-	u8 outbuf[MC_CMD_NVRAM_TEST_OUT_LEN];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_NVRAM_TEST_IN_LEN);
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_NVRAM_TEST_OUT_LEN);
 	int rc;
 
 	MCDI_SET_DWORD(inbuf, NVRAM_TEST_IN_TYPE, type);
@@ -976,8 +978,8 @@ fail1:
 
 static int efx_mcdi_read_assertion(struct efx_nic *efx)
 {
-	u8 inbuf[MC_CMD_GET_ASSERTS_IN_LEN];
-	u8 outbuf[MC_CMD_GET_ASSERTS_OUT_LEN];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_GET_ASSERTS_IN_LEN);
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_ASSERTS_OUT_LEN);
 	unsigned int flags, index, ofst;
 	const char *reason;
 	size_t outlen;
@@ -1032,7 +1034,7 @@ static int efx_mcdi_read_assertion(struct efx_nic *efx)
 
 static void efx_mcdi_exit_assertion(struct efx_nic *efx)
 {
-	u8 inbuf[MC_CMD_REBOOT_IN_LEN];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_REBOOT_IN_LEN);
 
 	/* If the MC is running debug firmware, it might now be
 	 * waiting for a debugger to attach, but we just want it to
@@ -1062,7 +1064,7 @@ int efx_mcdi_handle_assertion(struct efx_nic *efx)
 
 void efx_mcdi_set_id_led(struct efx_nic *efx, enum efx_led_mode mode)
 {
-	u8 inbuf[MC_CMD_SET_ID_LED_IN_LEN];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_SET_ID_LED_IN_LEN);
 	int rc;
 
 	BUILD_BUG_ON(EFX_LED_OFF != MC_CMD_LED_OFF);
@@ -1091,7 +1093,7 @@ int efx_mcdi_reset_port(struct efx_nic *efx)
 
 int efx_mcdi_reset_mc(struct efx_nic *efx)
 {
-	u8 inbuf[MC_CMD_REBOOT_IN_LEN];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_REBOOT_IN_LEN);
 	int rc;
 
 	BUILD_BUG_ON(MC_CMD_REBOOT_OUT_LEN != 0);
@@ -1110,8 +1112,8 @@ int efx_mcdi_reset_mc(struct efx_nic *efx)
 static int efx_mcdi_wol_filter_set(struct efx_nic *efx, u32 type,
 				   const u8 *mac, int *id_out)
 {
-	u8 inbuf[MC_CMD_WOL_FILTER_SET_IN_LEN];
-	u8 outbuf[MC_CMD_WOL_FILTER_SET_OUT_LEN];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_WOL_FILTER_SET_IN_LEN);
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_WOL_FILTER_SET_OUT_LEN);
 	size_t outlen;
 	int rc;
 
@@ -1151,7 +1153,7 @@ efx_mcdi_wol_filter_set_magic(struct efx_nic *efx,  const u8 *mac, int *id_out)
 
 int efx_mcdi_wol_filter_get_magic(struct efx_nic *efx, int *id_out)
 {
-	u8 outbuf[MC_CMD_WOL_FILTER_GET_OUT_LEN];
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_WOL_FILTER_GET_OUT_LEN);
 	size_t outlen;
 	int rc;
 
@@ -1178,7 +1180,7 @@ fail:
 
 int efx_mcdi_wol_filter_remove(struct efx_nic *efx, int id)
 {
-	u8 inbuf[MC_CMD_WOL_FILTER_REMOVE_IN_LEN];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_WOL_FILTER_REMOVE_IN_LEN);
 	int rc;
 
 	MCDI_SET_DWORD(inbuf, WOL_FILTER_REMOVE_IN_FILTER_ID, (u32)id);
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 3ba2e5b..c881118 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -85,6 +85,9 @@ extern void efx_mcdi_process_event(struct efx_channel *channel,
 				   efx_qword_t *event);
 extern void efx_mcdi_sensor_event(struct efx_nic *efx, efx_qword_t *ev);
 
+#define MCDI_DECLARE_BUF(_name, _len)					\
+	u8 _name[ALIGN(_len, 4)]
+
 #define MCDI_PTR2(_buf, _ofst)						\
 	(((u8 *)_buf) + _ofst)
 #define MCDI_SET_DWORD2(_buf, _ofst, _value)				\
diff --git a/drivers/net/ethernet/sfc/mcdi_mac.c b/drivers/net/ethernet/sfc/mcdi_mac.c
index 1003f30..fafdc8e 100644
--- a/drivers/net/ethernet/sfc/mcdi_mac.c
+++ b/drivers/net/ethernet/sfc/mcdi_mac.c
@@ -15,7 +15,7 @@
 int efx_mcdi_set_mac(struct efx_nic *efx)
 {
 	u32 reject, fcntl;
-	u8 cmdbytes[MC_CMD_SET_MAC_IN_LEN];
+	MCDI_DECLARE_BUF(cmdbytes, MC_CMD_SET_MAC_IN_LEN);
 
 	memcpy(cmdbytes + MC_CMD_SET_MAC_IN_ADDR_OFST,
 	       efx->net_dev->dev_addr, ETH_ALEN);
@@ -55,7 +55,7 @@ int efx_mcdi_set_mac(struct efx_nic *efx)
 
 bool efx_mcdi_mac_check_fault(struct efx_nic *efx)
 {
-	u8 outbuf[MC_CMD_GET_LINK_OUT_LEN];
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_LINK_OUT_LEN);
 	size_t outlength;
 	int rc;
 
@@ -75,7 +75,7 @@ bool efx_mcdi_mac_check_fault(struct efx_nic *efx)
 int efx_mcdi_mac_stats(struct efx_nic *efx, dma_addr_t dma_addr,
 		       u32 dma_len, int enable, int clear)
 {
-	u8 inbuf[MC_CMD_MAC_STATS_IN_LEN];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_MAC_STATS_IN_LEN);
 	int rc;
 	efx_dword_t *cmd_ptr;
 	int period = enable ? 1000 : 0;
@@ -115,16 +115,21 @@ fail:
 
 int efx_mcdi_mac_reconfigure(struct efx_nic *efx)
 {
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_SET_MCAST_HASH_IN_LEN);
 	int rc;
 
+	BUILD_BUG_ON(MC_CMD_SET_MCAST_HASH_IN_LEN !=
+		     MC_CMD_SET_MCAST_HASH_IN_HASH0_OFST +
+		     sizeof(efx->multicast_hash));
+
 	WARN_ON(!mutex_is_locked(&efx->mac_lock));
 
 	rc = efx_mcdi_set_mac(efx);
 	if (rc != 0)
 		return rc;
 
+	memcpy(MCDI_PTR(inbuf, SET_MCAST_HASH_IN_HASH0),
+	       efx->multicast_hash.byte, sizeof(efx->multicast_hash));
 	return efx_mcdi_rpc(efx, MC_CMD_SET_MCAST_HASH,
-			    efx->multicast_hash.byte,
-			    sizeof(efx->multicast_hash),
-			    NULL, 0, NULL);
+			    inbuf, sizeof(inbuf), NULL, 0, NULL);
 }
diff --git a/drivers/net/ethernet/sfc/mcdi_mon.c b/drivers/net/ethernet/sfc/mcdi_mon.c
index fe42c3b..4e8a138 100644
--- a/drivers/net/ethernet/sfc/mcdi_mon.c
+++ b/drivers/net/ethernet/sfc/mcdi_mon.c
@@ -92,7 +92,7 @@ struct efx_mcdi_mon_attribute {
 static int efx_mcdi_mon_update(struct efx_nic *efx)
 {
 	struct efx_mcdi_mon *hwmon = efx_mcdi_mon(efx);
-	u8 inbuf[MC_CMD_READ_SENSORS_IN_LEN];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_READ_SENSORS_IN_LEN);
 	int rc;
 
 	MCDI_SET_DWORD(inbuf, READ_SENSORS_IN_DMA_ADDR_LO,
@@ -236,7 +236,7 @@ int efx_mcdi_mon_probe(struct efx_nic *efx)
 {
 	struct efx_mcdi_mon *hwmon = efx_mcdi_mon(efx);
 	unsigned int n_attrs, n_temp = 0, n_cool = 0, n_in = 0;
-	u8 outbuf[MC_CMD_SENSOR_INFO_OUT_LENMAX];
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_SENSOR_INFO_OUT_LENMAX);
 	size_t outlen;
 	char name[12];
 	u32 mask;
diff --git a/drivers/net/ethernet/sfc/mcdi_phy.c b/drivers/net/ethernet/sfc/mcdi_phy.c
index 13cb40f..37b6ed9 100644
--- a/drivers/net/ethernet/sfc/mcdi_phy.c
+++ b/drivers/net/ethernet/sfc/mcdi_phy.c
@@ -36,7 +36,7 @@ struct efx_mcdi_phy_data {
 static int
 efx_mcdi_get_phy_cfg(struct efx_nic *efx, struct efx_mcdi_phy_data *cfg)
 {
-	u8 outbuf[MC_CMD_GET_PHY_CFG_OUT_LEN];
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_PHY_CFG_OUT_LEN);
 	size_t outlen;
 	int rc;
 
@@ -78,7 +78,7 @@ static int efx_mcdi_set_link(struct efx_nic *efx, u32 capabilities,
 			     u32 flags, u32 loopback_mode,
 			     u32 loopback_speed)
 {
-	u8 inbuf[MC_CMD_SET_LINK_IN_LEN];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_SET_LINK_IN_LEN);
 	int rc;
 
 	BUILD_BUG_ON(MC_CMD_SET_LINK_OUT_LEN != 0);
@@ -102,7 +102,7 @@ fail:
 
 static int efx_mcdi_loopback_modes(struct efx_nic *efx, u64 *loopback_modes)
 {
-	u8 outbuf[MC_CMD_GET_LOOPBACK_MODES_OUT_LEN];
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_LOOPBACK_MODES_OUT_LEN);
 	size_t outlen;
 	int rc;
 
@@ -129,8 +129,8 @@ int efx_mcdi_mdio_read(struct efx_nic *efx, unsigned int bus,
 			 unsigned int prtad, unsigned int devad, u16 addr,
 			 u16 *value_out, u32 *status_out)
 {
-	u8 inbuf[MC_CMD_MDIO_READ_IN_LEN];
-	u8 outbuf[MC_CMD_MDIO_READ_OUT_LEN];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_MDIO_READ_IN_LEN);
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_MDIO_READ_OUT_LEN);
 	size_t outlen;
 	int rc;
 
@@ -157,8 +157,8 @@ int efx_mcdi_mdio_write(struct efx_nic *efx, unsigned int bus,
 			  unsigned int prtad, unsigned int devad, u16 addr,
 			  u16 value, u32 *status_out)
 {
-	u8 inbuf[MC_CMD_MDIO_WRITE_IN_LEN];
-	u8 outbuf[MC_CMD_MDIO_WRITE_OUT_LEN];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_MDIO_WRITE_IN_LEN);
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_MDIO_WRITE_OUT_LEN);
 	size_t outlen;
 	int rc;
 
@@ -307,7 +307,7 @@ static u32 mcdi_to_ethtool_media(u32 media)
 static int efx_mcdi_phy_probe(struct efx_nic *efx)
 {
 	struct efx_mcdi_phy_data *phy_data;
-	u8 outbuf[MC_CMD_GET_LINK_OUT_LEN];
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_LINK_OUT_LEN);
 	u32 caps;
 	int rc;
 
@@ -472,7 +472,7 @@ void efx_mcdi_phy_check_fcntl(struct efx_nic *efx, u32 lpa)
 static bool efx_mcdi_phy_poll(struct efx_nic *efx)
 {
 	struct efx_link_state old_state = efx->link_state;
-	u8 outbuf[MC_CMD_GET_LINK_OUT_LEN];
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_LINK_OUT_LEN);
 	int rc;
 
 	WARN_ON(!mutex_is_locked(&efx->mac_lock));
@@ -507,7 +507,7 @@ static void efx_mcdi_phy_remove(struct efx_nic *efx)
 static void efx_mcdi_phy_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 {
 	struct efx_mcdi_phy_data *phy_cfg = efx->phy_data;
-	u8 outbuf[MC_CMD_GET_LINK_OUT_LEN];
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_LINK_OUT_LEN);
 	int rc;
 
 	ecmd->supported =
@@ -579,7 +579,7 @@ static int efx_mcdi_phy_set_settings(struct efx_nic *efx, struct ethtool_cmd *ec
 
 static int efx_mcdi_phy_test_alive(struct efx_nic *efx)
 {
-	u8 outbuf[MC_CMD_GET_PHY_STATE_OUT_LEN];
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_PHY_STATE_OUT_LEN);
 	size_t outlen;
 	int rc;
 
@@ -744,8 +744,8 @@ static const char *efx_mcdi_phy_test_name(struct efx_nic *efx,
 static int efx_mcdi_phy_get_module_eeprom(struct efx_nic *efx,
 					  struct ethtool_eeprom *ee, u8 *data)
 {
-	u8 outbuf[MC_CMD_GET_PHY_MEDIA_INFO_OUT_LENMAX];
-	u8 inbuf[MC_CMD_GET_PHY_MEDIA_INFO_IN_LEN];
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_PHY_MEDIA_INFO_OUT_LENMAX);
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_GET_PHY_MEDIA_INFO_IN_LEN);
 	size_t outlen;
 	int rc;
 	unsigned int payload_len;
diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index b495394..f79f6fb 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -311,7 +311,7 @@ static int efx_phc_enable(struct ptp_clock_info *ptp,
 /* Enable MCDI PTP support. */
 static int efx_ptp_enable(struct efx_nic *efx)
 {
-	u8 inbuf[MC_CMD_PTP_IN_ENABLE_LEN];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_PTP_IN_ENABLE_LEN);
 
 	MCDI_SET_DWORD(inbuf, PTP_IN_OP, MC_CMD_PTP_OP_ENABLE);
 	MCDI_SET_DWORD(inbuf, PTP_IN_ENABLE_QUEUE,
@@ -329,7 +329,7 @@ static int efx_ptp_enable(struct efx_nic *efx)
  */
 static int efx_ptp_disable(struct efx_nic *efx)
 {
-	u8 inbuf[MC_CMD_PTP_IN_DISABLE_LEN];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_PTP_IN_DISABLE_LEN);
 
 	MCDI_SET_DWORD(inbuf, PTP_IN_OP, MC_CMD_PTP_OP_DISABLE);
 	return efx_mcdi_rpc(efx, MC_CMD_PTP, inbuf, sizeof(inbuf),
@@ -518,7 +518,7 @@ static int efx_ptp_process_times(struct efx_nic *efx, u8 *synch_buf,
 static int efx_ptp_synchronize(struct efx_nic *efx, unsigned int num_readings)
 {
 	struct efx_ptp_data *ptp = efx->ptp_data;
-	u8 synch_buf[MC_CMD_PTP_OUT_SYNCHRONIZE_LENMAX];
+	MCDI_DECLARE_BUF(synch_buf, MC_CMD_PTP_OUT_SYNCHRONIZE_LENMAX);
 	size_t response_length;
 	int rc;
 	unsigned long timeout;
@@ -569,7 +569,7 @@ static int efx_ptp_xmit_skb(struct efx_nic *efx, struct sk_buff *skb)
 	int rc = -EIO;
 	/* MCDI driver requires word aligned lengths */
 	size_t len = ALIGN(MC_CMD_PTP_IN_TRANSMIT_LEN(skb->len), 4);
-	u8 txtime[MC_CMD_PTP_OUT_TRANSMIT_LEN];
+	MCDI_DECLARE_BUF(txtime, MC_CMD_PTP_OUT_TRANSMIT_LEN);
 
 	MCDI_SET_DWORD(txbuf, PTP_IN_OP, MC_CMD_PTP_OP_TRANSMIT);
 	MCDI_SET_DWORD(txbuf, PTP_IN_TRANSMIT_LENGTH, skb->len);
@@ -1359,7 +1359,7 @@ static int efx_phc_adjfreq(struct ptp_clock_info *ptp, s32 delta)
 						     struct efx_ptp_data,
 						     phc_clock_info);
 	struct efx_nic *efx = ptp_data->channel->efx;
-	u8 inadj[MC_CMD_PTP_IN_ADJUST_LEN];
+	MCDI_DECLARE_BUF(inadj, MC_CMD_PTP_IN_ADJUST_LEN);
 	s64 adjustment_ns;
 	int rc;
 
@@ -1394,7 +1394,7 @@ static int efx_phc_adjtime(struct ptp_clock_info *ptp, s64 delta)
 						     phc_clock_info);
 	struct efx_nic *efx = ptp_data->channel->efx;
 	struct timespec delta_ts = ns_to_timespec(delta);
-	u8 inbuf[MC_CMD_PTP_IN_ADJUST_LEN];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_PTP_IN_ADJUST_LEN);
 
 	MCDI_SET_DWORD(inbuf, PTP_IN_OP, MC_CMD_PTP_OP_ADJUST);
 	MCDI_SET_DWORD(inbuf, PTP_IN_ADJUST_FREQ_LO, 0);
@@ -1411,8 +1411,8 @@ static int efx_phc_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
 						     struct efx_ptp_data,
 						     phc_clock_info);
 	struct efx_nic *efx = ptp_data->channel->efx;
-	u8 inbuf[MC_CMD_PTP_IN_READ_NIC_TIME_LEN];
-	u8 outbuf[MC_CMD_PTP_OUT_READ_NIC_TIME_LEN];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_PTP_IN_READ_NIC_TIME_LEN);
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_PTP_OUT_READ_NIC_TIME_LEN);
 	int rc;
 
 	MCDI_SET_DWORD(inbuf, PTP_IN_OP, MC_CMD_PTP_OP_READ_NIC_TIME);
diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index 90f8d16..8e46fac 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -197,8 +197,8 @@ static unsigned abs_index(struct efx_vf *vf, unsigned index)
 static int efx_sriov_cmd(struct efx_nic *efx, bool enable,
 			 unsigned *vi_scale_out, unsigned *vf_total_out)
 {
-	u8 inbuf[MC_CMD_SRIOV_IN_LEN];
-	u8 outbuf[MC_CMD_SRIOV_OUT_LEN];
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_SRIOV_IN_LEN);
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_SRIOV_OUT_LEN);
 	unsigned vi_scale, vf_total;
 	size_t outlen;
 	int rc;


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
