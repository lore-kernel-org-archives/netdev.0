From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 13/36] bnx2x: Removing old PHY FW upgrade code
Date: Wed, 12 Aug 2009 21:23:14 +0300
Message-ID: <1250101394.27379.165.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3711 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753115AbZHLSYF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:24:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code should not have resided in the driver. Now that we have a new
interface, this logic can reside in the application that whishes to upgrade the
PHY FW

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |  427 ----------------------------------------------
 drivers/net/bnx2x_link.h |    2 -
 2 files changed, 0 insertions(+), 429 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 98e3e8f..dc3b69e 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -5471,59 +5471,6 @@ static u8 bnx2x_format_ver(u32 num, u8 *str, u16 len)
 	return 0;
 }
 
-
-static void bnx2x_turn_on_ef(struct bnx2x *bp, u8 port, u8 ext_phy_addr,
-			   u32 ext_phy_type)
-{
-	u32 cnt = 0;
-	u16 ctrl = 0;
-	/* Enable EMAC0 in to enable MDIO */
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_SET,
-	       (MISC_REGISTERS_RESET_REG_2_RST_EMAC0_HARD_CORE << port));
-	msleep(5);
-
-	/* take ext phy out of reset */
-	bnx2x_set_gpio(bp,
-			  MISC_REGISTERS_GPIO_2,
-			  MISC_REGISTERS_GPIO_HIGH,
-			  port);
-
-	bnx2x_set_gpio(bp,
-			  MISC_REGISTERS_GPIO_1,
-			  MISC_REGISTERS_GPIO_HIGH,
-			  port);
-
-	/* wait for 5ms */
-	msleep(5);
-
-	for (cnt = 0; cnt < 1000; cnt++) {
-		msleep(1);
-		bnx2x_cl45_read(bp, port,
-			      ext_phy_type,
-			      ext_phy_addr,
-			      MDIO_PMA_DEVAD,
-			      MDIO_PMA_REG_CTRL,
-			      &ctrl);
-		if (!(ctrl & (1<<15))) {
-			DP(NETIF_MSG_LINK, "Reset completed\n\n");
-				break;
-		}
-	}
-}
-
-static void bnx2x_turn_off_sf(struct bnx2x *bp, u8 port)
-{
-	/* put sf to reset */
-	bnx2x_set_gpio(bp,
-			  MISC_REGISTERS_GPIO_1,
-			  MISC_REGISTERS_GPIO_LOW,
-			  port);
-	bnx2x_set_gpio(bp,
-			  MISC_REGISTERS_GPIO_2,
-			  MISC_REGISTERS_GPIO_LOW,
-			  port);
-}
-
 u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
 			      u8 *version, u16 len)
 {
@@ -6743,377 +6690,3 @@ void bnx2x_sfx7101_sp_sw_reset(struct bnx2x *bp, u8 port, u8 phy_addr)
 			break;
 	}
 }
-#define RESERVED_SIZE 256
-/* max application is 160K bytes - data at end of RAM */
-#define MAX_APP_SIZE (160*1024 - RESERVED_SIZE)
-
-/* Header is 14 bytes */
-#define HEADER_SIZE 14
-#define DATA_OFFSET HEADER_SIZE
-
-#define SPI_START_TRANSFER(bp, port, ext_phy_addr) \
-	bnx2x_cl45_write(bp, port, PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101, \
-			ext_phy_addr, \
-			MDIO_PCS_DEVAD, \
-			MDIO_PCS_REG_7101_SPI_CTRL_ADDR, 1)
-
-/* Programs an image to DSP's flash via the SPI port*/
-static u8 bnx2x_sfx7101_flash_download(struct bnx2x *bp, u8 port,
-				     u8 ext_phy_addr,
-				     char data[], u32 size)
-{
-	const u16 num_trans = size/4; /* 4 bytes can be sent at a time */
-	/* Doesn't include last trans!*/
-	const u16 last_trans_size = size%4; /* Num bytes on last trans */
-	u16 trans_cnt, byte_cnt;
-	u32 data_index;
-	u16 tmp;
-	u16 code_started = 0;
-	u16 image_revision1, image_revision2;
-	u16 cnt;
-
-	DP(NETIF_MSG_LINK, "bnx2x_sfx7101_flash_download file_size=%d\n", size);
-	/* Going to flash*/
-	if ((size-HEADER_SIZE) > MAX_APP_SIZE) {
-		/* This very often will be the case, because the image is built
-		with 160Kbytes size whereas the total image size must actually
-		be 160Kbytes-RESERVED_SIZE */
-		DP(NETIF_MSG_LINK, "Warning, file size was %d bytes "
-			 "truncated to %d bytes\n", size, MAX_APP_SIZE);
-		size = MAX_APP_SIZE+HEADER_SIZE;
-	}
-	DP(NETIF_MSG_LINK, "File version is %c%c\n", data[0x14e], data[0x14f]);
-	DP(NETIF_MSG_LINK, "  	      %c%c\n", data[0x150], data[0x151]);
-	/* Put the DSP in download mode by setting FLASH_CFG[2] to 1
-	   and issuing a reset.*/
-
-	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_0,
-			  MISC_REGISTERS_GPIO_HIGH, port);
-
-	bnx2x_sfx7101_sp_sw_reset(bp, port, ext_phy_addr);
-
-	/* wait 0.5 sec */
-	for (cnt = 0; cnt < 100; cnt++)
-		msleep(5);
-
-	/* Make sure we can access the DSP
-	   And it's in the correct mode (waiting for download) */
-
-	bnx2x_cl45_read(bp, port,
-		      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-		      ext_phy_addr,
-		      MDIO_PCS_DEVAD,
-		      MDIO_PCS_REG_7101_DSP_ACCESS, &tmp);
-
-	if (tmp != 0x000A) {
-		DP(NETIF_MSG_LINK, "DSP is not in waiting on download mode. "
-			 "Expected 0x000A, read 0x%04X\n", tmp);
-		DP(NETIF_MSG_LINK, "Download failed\n");
-		return -EINVAL;
-	}
-
-	/* Mux the SPI interface away from the internal processor */
-	bnx2x_cl45_write(bp, port,
-		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-		       ext_phy_addr,
-		       MDIO_PCS_DEVAD,
-		       MDIO_PCS_REG_7101_SPI_MUX, 1);
-
-	/* Reset the SPI port */
-	bnx2x_cl45_write(bp, port,
-		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-		       ext_phy_addr,
-		       MDIO_PCS_DEVAD,
-		       MDIO_PCS_REG_7101_SPI_CTRL_ADDR, 0);
-	bnx2x_cl45_write(bp, port,
-		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-		       ext_phy_addr,
-		       MDIO_PCS_DEVAD,
-		       MDIO_PCS_REG_7101_SPI_CTRL_ADDR,
-		       (1<<MDIO_PCS_REG_7101_SPI_RESET_BIT));
-	bnx2x_cl45_write(bp, port,
-		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-		       ext_phy_addr,
-		       MDIO_PCS_DEVAD,
-		       MDIO_PCS_REG_7101_SPI_CTRL_ADDR, 0);
-
-	/* Erase the flash */
-	bnx2x_cl45_write(bp, port,
-		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-		       ext_phy_addr,
-		       MDIO_PCS_DEVAD,
-		       MDIO_PCS_REG_7101_SPI_FIFO_ADDR,
-		       MDIO_PCS_REG_7101_SPI_FIFO_ADDR_WRITE_ENABLE_CMD);
-
-	bnx2x_cl45_write(bp, port,
-		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-		       ext_phy_addr,
-		       MDIO_PCS_DEVAD,
-		       MDIO_PCS_REG_7101_SPI_BYTES_TO_TRANSFER_ADDR,
-		       1);
-
-	SPI_START_TRANSFER(bp, port, ext_phy_addr);
-	bnx2x_cl45_write(bp, port,
-		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-		       ext_phy_addr,
-		       MDIO_PCS_DEVAD,
-		       MDIO_PCS_REG_7101_SPI_FIFO_ADDR,
-		       MDIO_PCS_REG_7101_SPI_FIFO_ADDR_BULK_ERASE_CMD);
-
-	bnx2x_cl45_write(bp, port,
-		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-		       ext_phy_addr,
-		       MDIO_PCS_DEVAD,
-		       MDIO_PCS_REG_7101_SPI_BYTES_TO_TRANSFER_ADDR,
-		       1);
-	SPI_START_TRANSFER(bp, port, ext_phy_addr);
-
-	/* Wait 10 seconds, the maximum time for the erase to complete */
-	DP(NETIF_MSG_LINK, "Erasing flash, this takes 10 seconds...\n");
-	for (cnt = 0; cnt < 1000; cnt++)
-		msleep(10);
-
-	DP(NETIF_MSG_LINK, "Downloading flash, please wait...\n");
-	data_index = 0;
-	for (trans_cnt = 0; trans_cnt < num_trans; trans_cnt++) {
-		bnx2x_cl45_write(bp, port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-			     ext_phy_addr,
-			     MDIO_PCS_DEVAD,
-			     MDIO_PCS_REG_7101_SPI_FIFO_ADDR,
-			     MDIO_PCS_REG_7101_SPI_FIFO_ADDR_WRITE_ENABLE_CMD);
-
-		bnx2x_cl45_write(bp, port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-			       ext_phy_addr,
-			       MDIO_PCS_DEVAD,
-			       MDIO_PCS_REG_7101_SPI_BYTES_TO_TRANSFER_ADDR,
-			       1);
-		SPI_START_TRANSFER(bp, port, ext_phy_addr);
-
-		bnx2x_cl45_write(bp, port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-			       ext_phy_addr,
-			       MDIO_PCS_DEVAD,
-			       MDIO_PCS_REG_7101_SPI_FIFO_ADDR,
-			     MDIO_PCS_REG_7101_SPI_FIFO_ADDR_PAGE_PROGRAM_CMD);
-
-		/* Bits 23-16 of address */
-		bnx2x_cl45_write(bp, port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-			       ext_phy_addr,
-			       MDIO_PCS_DEVAD,
-			       MDIO_PCS_REG_7101_SPI_FIFO_ADDR,
-			       (data_index>>16));
-		/* Bits 15-8 of address */
-		bnx2x_cl45_write(bp, port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-			       ext_phy_addr,
-			       MDIO_PCS_DEVAD,
-			       MDIO_PCS_REG_7101_SPI_FIFO_ADDR,
-			       (data_index>>8));
-
-		/* Bits 7-0 of address */
-		bnx2x_cl45_write(bp, port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-			       ext_phy_addr,
-			       MDIO_PCS_DEVAD,
-			       MDIO_PCS_REG_7101_SPI_FIFO_ADDR,
-			       ((u16)data_index));
-
-		byte_cnt = 0;
-		while (byte_cnt < 4 && data_index < size) {
-			bnx2x_cl45_write(bp, port,
-				       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-				       ext_phy_addr,
-			       MDIO_PCS_DEVAD,
-			       MDIO_PCS_REG_7101_SPI_FIFO_ADDR,
-			       data[data_index++]);
-			byte_cnt++;
-		}
-
-		bnx2x_cl45_write(bp, port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-			       ext_phy_addr,
-			       MDIO_PCS_DEVAD,
-			       MDIO_PCS_REG_7101_SPI_BYTES_TO_TRANSFER_ADDR,
-			       byte_cnt+4);
-
-		SPI_START_TRANSFER(bp, port, ext_phy_addr);
-		msleep(5); /* Wait 5 ms minimum between transs */
-
-		/* Let the user know something's going on.*/
-		/* a pacifier ever 4K */
-		if ((data_index % 1023) == 0)
-			DP(NETIF_MSG_LINK, "Download %d%%\n", data_index/size);
-	}
-
-	DP(NETIF_MSG_LINK, "\n");
-	/* Transfer the last block if there is data remaining */
-	if (last_trans_size) {
-		bnx2x_cl45_write(bp, port,
-			PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-			ext_phy_addr,
-			MDIO_PCS_DEVAD,
-			MDIO_PCS_REG_7101_SPI_FIFO_ADDR,
-			MDIO_PCS_REG_7101_SPI_FIFO_ADDR_WRITE_ENABLE_CMD);
-
-		bnx2x_cl45_write(bp, port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-			       ext_phy_addr,
-			       MDIO_PCS_DEVAD,
-			       MDIO_PCS_REG_7101_SPI_BYTES_TO_TRANSFER_ADDR,
-			       1);
-
-		SPI_START_TRANSFER(bp, port, ext_phy_addr);
-
-		bnx2x_cl45_write(bp, port,
-			     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-			     ext_phy_addr,
-			     MDIO_PCS_DEVAD,
-			     MDIO_PCS_REG_7101_SPI_FIFO_ADDR,
-			     MDIO_PCS_REG_7101_SPI_FIFO_ADDR_PAGE_PROGRAM_CMD);
-
-		/* Bits 23-16 of address */
-		bnx2x_cl45_write(bp, port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-			       ext_phy_addr,
-			       MDIO_PCS_DEVAD,
-			       MDIO_PCS_REG_7101_SPI_FIFO_ADDR,
-			       (data_index>>16));
-		/* Bits 15-8 of address */
-		bnx2x_cl45_write(bp, port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-			       ext_phy_addr,
-			       MDIO_PCS_DEVAD,
-			       MDIO_PCS_REG_7101_SPI_FIFO_ADDR,
-			       (data_index>>8));
-
-		/* Bits 7-0 of address */
-		bnx2x_cl45_write(bp, port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-			       ext_phy_addr,
-			       MDIO_PCS_DEVAD,
-			       MDIO_PCS_REG_7101_SPI_FIFO_ADDR,
-			       ((u16)data_index));
-
-		byte_cnt = 0;
-		while (byte_cnt < last_trans_size && data_index < size) {
-			/* Bits 7-0 of address */
-			bnx2x_cl45_write(bp, port,
-				PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-				ext_phy_addr,
-				MDIO_PCS_DEVAD,
-				MDIO_PCS_REG_7101_SPI_FIFO_ADDR,
-				data[data_index++]);
-			byte_cnt++;
-		}
-
-		bnx2x_cl45_write(bp, port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-			       ext_phy_addr,
-			       MDIO_PCS_DEVAD,
-			       MDIO_PCS_REG_7101_SPI_BYTES_TO_TRANSFER_ADDR,
-			       byte_cnt+4);
-
-		SPI_START_TRANSFER(bp, port, ext_phy_addr);
-	}
-
-	/* DSP Remove Download Mode */
-	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_0,
-			  MISC_REGISTERS_GPIO_LOW, port);
-
-	bnx2x_sfx7101_sp_sw_reset(bp, port, ext_phy_addr);
-
-	/* wait 0.5 sec to allow it to run */
-	for (cnt = 0; cnt < 100; cnt++)
-		msleep(5);
-
-	bnx2x_ext_phy_hw_reset(bp, port);
-
-	for (cnt = 0; cnt < 100; cnt++)
-		msleep(5);
-
-	/* Check that the code is started. In case the download
-	checksum failed, the code won't be started. */
-	bnx2x_cl45_read(bp, port,
-		      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-		      ext_phy_addr,
-		      MDIO_PCS_DEVAD,
-		      MDIO_PCS_REG_7101_DSP_ACCESS,
-		      &tmp);
-
-	code_started = (tmp & (1<<4));
-	if (!code_started) {
-		DP(NETIF_MSG_LINK, "Download failed. Please check file.\n");
-		return -EINVAL;
-	}
-
-	/* Verify that the file revision is now equal to the image
-	revision within the DSP */
-	bnx2x_cl45_read(bp, port,
-		      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-		      ext_phy_addr,
-		      MDIO_PMA_DEVAD,
-		      MDIO_PMA_REG_7101_VER1,
-		      &image_revision1);
-
-	bnx2x_cl45_read(bp, port,
-		      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-		      ext_phy_addr,
-		      MDIO_PMA_DEVAD,
-		      MDIO_PMA_REG_7101_VER2,
-		      &image_revision2);
-
-	if (data[0x14e] != (image_revision2&0xFF) ||
-	    data[0x14f] != ((image_revision2&0xFF00)>>8) ||
-	    data[0x150] != (image_revision1&0xFF) ||
-	    data[0x151] != ((image_revision1&0xFF00)>>8)) {
-		DP(NETIF_MSG_LINK, "Download failed.\n");
-		return -EINVAL;
-	}
-	DP(NETIF_MSG_LINK, "Download %d%%\n", data_index/size);
-	return 0;
-}
-
-u8 bnx2x_flash_download(struct bnx2x *bp, u8 port, u32 ext_phy_config,
-		      u8 driver_loaded, char data[], u32 size)
-{
-	u8 rc = 0;
-	u32 ext_phy_type;
-	u8 ext_phy_addr;
-	ext_phy_addr = ((ext_phy_config &
-			PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-			PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
-
-	ext_phy_type = XGXS_EXT_PHY_TYPE(ext_phy_config);
-
-	switch (ext_phy_type) {
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
-		DP(NETIF_MSG_LINK,
-			"Flash download not supported for this ext phy\n");
-		rc = -EINVAL;
-		break;
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
-		/* Take ext phy out of reset */
-		if (!driver_loaded)
-			bnx2x_turn_on_ef(bp, port, ext_phy_addr, ext_phy_type);
-		rc = bnx2x_sfx7101_flash_download(bp, port, ext_phy_addr,
-						data, size);
-		if (!driver_loaded)
-			bnx2x_turn_off_sf(bp, port);
-		break;
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN:
-	default:
-		DP(NETIF_MSG_LINK, "Invalid ext phy type\n");
-		rc = -EINVAL;
-		break;
-	}
-	return rc;
-}
-
diff --git a/drivers/net/bnx2x_link.h b/drivers/net/bnx2x_link.h
index 9805d21..6d26d6c 100644
--- a/drivers/net/bnx2x_link.h
+++ b/drivers/net/bnx2x_link.h
@@ -174,8 +174,6 @@ u8 bnx2x_set_led(struct bnx2x *bp, u8 port, u8 mode, u32 speed,
 
 u8 bnx2x_override_led_value(struct bnx2x *bp, u8 port, u32 led_idx, u32 value);
 
-u8 bnx2x_flash_download(struct bnx2x *bp, u8 port, u32 ext_phy_config,
-		      u8 driver_loaded, char data[], u32 size);
 /* bnx2x_handle_module_detect_int should be called upon module detection
    interrupt */
 void bnx2x_handle_module_detect_int(struct link_params *params);
-- 
1.5.4.3




