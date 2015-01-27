From: Praveen Madhavan <praveenm@chelsio.com>
Subject: [PATCH] csiostor:T5 Firmware fix and cleanup.
Date: Tue, 27 Jan 2015 19:46:37 +0530
Message-ID: <1422368197-22086-1-git-send-email-praveenm@chelsio.com>
Cc: davem@davemloft.net, JBottomley@parallels.com, hch@infradead.org,
	hariprasad@chelsio.com, praveenm@chelsio.com, varun@chelsio.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:29529 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758341AbbA0ORR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 09:17:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fix is to use default firmware configuration files
present in the adapter incase if not available in standard
/lib/firmware/* dir. Additional cleanup is done to reuse flash
related defines from cxgb4 header file.

Please apply over net-next since it depends on previous commit.

Signed-off-by: Praveen Madhavan <praveenm@chelsio.com>
---
 drivers/scsi/csiostor/csio_hw.c      | 342 +++++++++++++----------------------
 drivers/scsi/csiostor/csio_hw.h      |  40 +---
 drivers/scsi/csiostor/csio_hw_chip.h |   1 -
 3 files changed, 127 insertions(+), 256 deletions(-)

diff --git a/drivers/scsi/csiostor/csio_hw.c b/drivers/scsi/csiostor/csio_hw.c
index 35c5f83..c81b06b 100644
--- a/drivers/scsi/csiostor/csio_hw.c
+++ b/drivers/scsi/csiostor/csio_hw.c
@@ -636,7 +636,7 @@ csio_hw_print_fw_version(struct csio_hw *hw, char *str)
 static int
 csio_hw_get_fw_version(struct csio_hw *hw, uint32_t *vers)
 {
-	return csio_hw_read_flash(hw, FW_IMG_START +
+	return csio_hw_read_flash(hw, FLASH_FW_START +
 				  offsetof(struct fw_hdr, fw_ver), 1,
 				  vers, 0);
 }
@@ -696,9 +696,9 @@ csio_hw_fw_dload(struct csio_hw *hw, uint8_t *fw_data, uint32_t size)
 		return -EINVAL;
 	}
 
-	if (size > FW_MAX_SIZE) {
+	if (size > FLASH_FW_MAX_SIZE) {
 		csio_err(hw, "FW image too large, max is %u bytes\n",
-			    FW_MAX_SIZE);
+			    FLASH_FW_MAX_SIZE);
 		return -EINVAL;
 	}
 
@@ -714,10 +714,10 @@ csio_hw_fw_dload(struct csio_hw *hw, uint8_t *fw_data, uint32_t size)
 	i = DIV_ROUND_UP(size, sf_sec_size);        /* # of sectors spanned */
 
 	csio_dbg(hw, "Erasing sectors... start:%d end:%d\n",
-			  FW_START_SEC, FW_START_SEC + i - 1);
+			  FLASH_FW_START_SEC, FLASH_FW_START_SEC + i - 1);
 
-	ret = csio_hw_flash_erase_sectors(hw, FW_START_SEC,
-					  FW_START_SEC + i - 1);
+	ret = csio_hw_flash_erase_sectors(hw, FLASH_FW_START_SEC,
+					  FLASH_FW_START_SEC + i - 1);
 	if (ret) {
 		csio_err(hw, "Flash Erase failed\n");
 		goto out;
@@ -730,14 +730,14 @@ csio_hw_fw_dload(struct csio_hw *hw, uint8_t *fw_data, uint32_t size)
 	 */
 	memcpy(first_page, fw_data, SF_PAGE_SIZE);
 	((struct fw_hdr *)first_page)->fw_ver = htonl(0xffffffff);
-	ret = csio_hw_write_flash(hw, FW_IMG_START, SF_PAGE_SIZE, first_page);
+	ret = csio_hw_write_flash(hw, FLASH_FW_START, SF_PAGE_SIZE, first_page);
 	if (ret)
 		goto out;
 
 	csio_dbg(hw, "Writing Flash .. start:%d end:%d\n",
 		    FW_IMG_START, FW_IMG_START + size);
 
-	addr = FW_IMG_START;
+	addr = FLASH_FW_START;
 	for (size -= SF_PAGE_SIZE; size; size -= SF_PAGE_SIZE) {
 		addr += SF_PAGE_SIZE;
 		fw_data += SF_PAGE_SIZE;
@@ -747,7 +747,7 @@ csio_hw_fw_dload(struct csio_hw *hw, uint8_t *fw_data, uint32_t size)
 	}
 
 	ret = csio_hw_write_flash(hw,
-				  FW_IMG_START +
+				  FLASH_FW_START +
 					offsetof(struct fw_hdr, fw_ver),
 				  sizeof(hdr->fw_ver),
 				  (const uint8_t *)&hdr->fw_ver);
@@ -1250,116 +1250,6 @@ csio_hw_fw_upgrade(struct csio_hw *hw, uint32_t mbox,
 	return csio_hw_fw_restart(hw, mbox, reset);
 }
 
-
-/*
- *	csio_hw_fw_config_file - setup an adapter via a Configuration File
- *	@hw: the HW module
- *	@mbox: mailbox to use for the FW command
- *	@mtype: the memory type where the Configuration File is located
- *	@maddr: the memory address where the Configuration File is located
- *	@finiver: return value for CF [fini] version
- *	@finicsum: return value for CF [fini] checksum
- *	@cfcsum: return value for CF computed checksum
- *
- *	Issue a command to get the firmware to process the Configuration
- *	File located at the specified mtype/maddress.  If the Configuration
- *	File is processed successfully and return value pointers are
- *	provided, the Configuration File "[fini] section version and
- *	checksum values will be returned along with the computed checksum.
- *	It's up to the caller to decide how it wants to respond to the
- *	checksums not matching but it recommended that a prominant warning
- *	be emitted in order to help people rapidly identify changed or
- *	corrupted Configuration Files.
- *
- *	Also note that it's possible to modify things like "niccaps",
- *	"toecaps",etc. between processing the Configuration File and telling
- *	the firmware to use the new configuration.  Callers which want to
- *	do this will need to "hand-roll" their own CAPS_CONFIGS commands for
- *	Configuration Files if they want to do this.
- */
-static int
-csio_hw_fw_config_file(struct csio_hw *hw,
-		      unsigned int mtype, unsigned int maddr,
-		      uint32_t *finiver, uint32_t *finicsum, uint32_t *cfcsum)
-{
-	struct csio_mb	*mbp;
-	struct fw_caps_config_cmd *caps_cmd;
-	int rv = -EINVAL;
-	enum fw_retval ret;
-
-	mbp = mempool_alloc(hw->mb_mempool, GFP_ATOMIC);
-	if (!mbp) {
-		CSIO_INC_STATS(hw, n_err_nomem);
-		return -ENOMEM;
-	}
-	/*
-	 * Tell the firmware to process the indicated Configuration File.
-	 * If there are no errors and the caller has provided return value
-	 * pointers for the [fini] section version, checksum and computed
-	 * checksum, pass those back to the caller.
-	 */
-	caps_cmd = (struct fw_caps_config_cmd *)(mbp->mb);
-	CSIO_INIT_MBP(mbp, caps_cmd, CSIO_MB_DEFAULT_TMO, hw, NULL, 1);
-	caps_cmd->op_to_write =
-		htonl(FW_CMD_OP_V(FW_CAPS_CONFIG_CMD) |
-		      FW_CMD_REQUEST_F |
-		      FW_CMD_READ_F);
-	caps_cmd->cfvalid_to_len16 =
-		htonl(FW_CAPS_CONFIG_CMD_CFVALID_F |
-		      FW_CAPS_CONFIG_CMD_MEMTYPE_CF_V(mtype) |
-		      FW_CAPS_CONFIG_CMD_MEMADDR64K_CF_V(maddr >> 16) |
-		      FW_LEN16(*caps_cmd));
-
-	if (csio_mb_issue(hw, mbp)) {
-		csio_err(hw, "Issue of FW_CAPS_CONFIG_CMD failed!\n");
-		goto out;
-	}
-
-	ret = csio_mb_fw_retval(mbp);
-	if (ret != FW_SUCCESS) {
-		csio_dbg(hw, "FW_CAPS_CONFIG_CMD returned %d!\n", rv);
-		goto out;
-	}
-
-	if (finiver)
-		*finiver = ntohl(caps_cmd->finiver);
-	if (finicsum)
-		*finicsum = ntohl(caps_cmd->finicsum);
-	if (cfcsum)
-		*cfcsum = ntohl(caps_cmd->cfcsum);
-
-	/* Validate device capabilities */
-	if (csio_hw_validate_caps(hw, mbp)) {
-		rv = -ENOENT;
-		goto out;
-	}
-
-	/*
-	 * And now tell the firmware to use the configuration we just loaded.
-	 */
-	caps_cmd->op_to_write =
-		htonl(FW_CMD_OP_V(FW_CAPS_CONFIG_CMD) |
-		      FW_CMD_REQUEST_F |
-		      FW_CMD_WRITE_F);
-	caps_cmd->cfvalid_to_len16 = htonl(FW_LEN16(*caps_cmd));
-
-	if (csio_mb_issue(hw, mbp)) {
-		csio_err(hw, "Issue of FW_CAPS_CONFIG_CMD failed!\n");
-		goto out;
-	}
-
-	ret = csio_mb_fw_retval(mbp);
-	if (ret != FW_SUCCESS) {
-		csio_dbg(hw, "FW_CAPS_CONFIG_CMD returned %d!\n", rv);
-		goto out;
-	}
-
-	rv = 0;
-out:
-	mempool_free(mbp, hw->mb_mempool);
-	return rv;
-}
-
 /*
  * csio_get_device_params - Get device parameters.
  * @hw: HW module
@@ -1762,11 +1652,13 @@ leave:
 static int
 csio_hw_use_fwconfig(struct csio_hw *hw, int reset, u32 *fw_cfg_param)
 {
+	struct csio_mb	*mbp = NULL;
+	struct fw_caps_config_cmd *caps_cmd;
 	unsigned int mtype, maddr;
-	int rv;
+	int rv = -EINVAL;
 	uint32_t finiver = 0, finicsum = 0, cfcsum = 0;
-	int using_flash;
 	char path[64];
+	char *config_name = NULL;
 
 	/*
 	 * Reset device if necessary
@@ -1786,51 +1678,106 @@ csio_hw_use_fwconfig(struct csio_hw *hw, int reset, u32 *fw_cfg_param)
 	rv = csio_hw_flash_config(hw, fw_cfg_param, path);
 	spin_lock_irq(&hw->lock);
 	if (rv != 0) {
-		if (rv == -ENOENT) {
-			/*
-			 * config file was not found. Use default
-			 * config file from flash.
-			 */
-			mtype = FW_MEMTYPE_CF_FLASH;
-			maddr = hw->chip_ops->chip_flash_cfg_addr(hw);
-			using_flash = 1;
-		} else {
-			/*
-			 * we revert back to the hardwired config if
-			 * flashing failed.
-			 */
-			goto bye;
-		}
+		/*
+		 * config file was not found. Use default
+		 * config file from flash.
+		 */
+		config_name = "On FLASH";
+		mtype = FW_MEMTYPE_CF_FLASH;
+		maddr = hw->chip_ops->chip_flash_cfg_addr(hw);
 	} else {
+		config_name = path;
 		mtype = FW_PARAMS_PARAM_Y_G(*fw_cfg_param);
 		maddr = FW_PARAMS_PARAM_Z_G(*fw_cfg_param) << 16;
-		using_flash = 0;
 	}
 
-	hw->cfg_store = (uint8_t)mtype;
+	mbp = mempool_alloc(hw->mb_mempool, GFP_ATOMIC);
+	if (!mbp) {
+		CSIO_INC_STATS(hw, n_err_nomem);
+		return -ENOMEM;
+	}
+	/*
+	 * Tell the firmware to process the indicated Configuration File.
+	 * If there are no errors and the caller has provided return value
+	 * pointers for the [fini] section version, checksum and computed
+	 * checksum, pass those back to the caller.
+	 */
+	caps_cmd = (struct fw_caps_config_cmd *)(mbp->mb);
+	CSIO_INIT_MBP(mbp, caps_cmd, CSIO_MB_DEFAULT_TMO, hw, NULL, 1);
+	caps_cmd->op_to_write =
+		htonl(FW_CMD_OP_V(FW_CAPS_CONFIG_CMD) |
+		      FW_CMD_REQUEST_F |
+		      FW_CMD_READ_F);
+	caps_cmd->cfvalid_to_len16 =
+		htonl(FW_CAPS_CONFIG_CMD_CFVALID_F |
+		      FW_CAPS_CONFIG_CMD_MEMTYPE_CF_V(mtype) |
+		      FW_CAPS_CONFIG_CMD_MEMADDR64K_CF_V(maddr >> 16) |
+		      FW_LEN16(*caps_cmd));
+
+	if (csio_mb_issue(hw, mbp)) {
+		rv = -EINVAL;
+		goto bye;
+	}
+
+	rv = csio_mb_fw_retval(mbp);
+	 /* If the CAPS_CONFIG failed with an ENOENT (for a Firmware
+	  * Configuration File in FLASH), our last gasp effort is to use the
+	  * Firmware Configuration File which is embedded in the
+	  * firmware.  A very few early versions of the firmware didn't
+	  * have one embedded but we can ignore those.
+	  */
+	if (rv == ENOENT) {
+		CSIO_INIT_MBP(mbp, caps_cmd, CSIO_MB_DEFAULT_TMO, hw, NULL, 1);
+		caps_cmd->op_to_write = htonl(FW_CMD_OP_V(FW_CAPS_CONFIG_CMD) |
+					      FW_CMD_REQUEST_F |
+					      FW_CMD_READ_F);
+		caps_cmd->cfvalid_to_len16 = htonl(FW_LEN16(*caps_cmd));
+
+		if (csio_mb_issue(hw, mbp)) {
+			rv = -EINVAL;
+			goto bye;
+		}
+
+		rv = csio_mb_fw_retval(mbp);
+		config_name = "Firmware Default";
+	}
+	if (rv != FW_SUCCESS)
+		goto bye;
+
+	finiver = ntohl(caps_cmd->finiver);
+	finicsum = ntohl(caps_cmd->finicsum);
+	cfcsum = ntohl(caps_cmd->cfcsum);
 
 	/*
-	 * Issue a Capability Configuration command to the firmware to get it
-	 * to parse the Configuration File.
+	 * And now tell the firmware to use the configuration we just loaded.
 	 */
-	rv = csio_hw_fw_config_file(hw, mtype, maddr, &finiver,
-		&finicsum, &cfcsum);
-	if (rv != 0)
+	caps_cmd->op_to_write =
+		htonl(FW_CMD_OP_V(FW_CAPS_CONFIG_CMD) |
+		      FW_CMD_REQUEST_F |
+		      FW_CMD_WRITE_F);
+	caps_cmd->cfvalid_to_len16 = htonl(FW_LEN16(*caps_cmd));
+
+	if (csio_mb_issue(hw, mbp)) {
+		rv = -EINVAL;
 		goto bye;
+	}
 
-	hw->cfg_finiver		= finiver;
-	hw->cfg_finicsum	= finicsum;
-	hw->cfg_cfcsum		= cfcsum;
-	hw->cfg_csum_status	= true;
+	rv = csio_mb_fw_retval(mbp);
+	if (rv != FW_SUCCESS) {
+		csio_dbg(hw, "FW_CAPS_CONFIG_CMD returned %d!\n", rv);
+		goto bye;
+	}
 
+	mempool_free(mbp, hw->mb_mempool);
 	if (finicsum != cfcsum) {
 		csio_warn(hw,
 		      "Config File checksum mismatch: csum=%#x, computed=%#x\n",
 		      finicsum, cfcsum);
-
-		hw->cfg_csum_status = false;
 	}
 
+	/* Validate device capabilities */
+	if (csio_hw_validate_caps(hw, mbp))
+		goto bye;
 	/*
 	 * Note that we're operating with parameters
 	 * not supplied by the driver, rather than from hard-wired
@@ -1853,55 +1800,19 @@ csio_hw_use_fwconfig(struct csio_hw *hw, int reset, u32 *fw_cfg_param)
 	/* Post event to notify completion of configuration */
 	csio_post_event(&hw->sm, CSIO_HWE_INIT);
 
-	csio_info(hw,
-	 "Firmware Configuration File %s, version %#x, computed checksum %#x\n",
-		  (using_flash ? "in device FLASH" : path), finiver, cfcsum);
-
+	csio_info(hw, "Successfully configure using Firmware "
+		  "Configuration File %s, version %#x, computed checksum %#x\n",
+		  config_name, finiver, cfcsum);
 	return 0;
 
 	/*
 	 * Something bad happened.  Return the error ...
 	 */
 bye:
+	if (mbp)
+		mempool_free(mbp, hw->mb_mempool);
 	hw->flags &= ~CSIO_HWF_USING_SOFT_PARAMS;
-	csio_dbg(hw, "Configuration file error %d\n", rv);
-	return rv;
-}
-
-/*
- * Attempt to initialize the adapter via hard-coded, driver supplied
- * parameters ...
- */
-static int
-csio_hw_no_fwconfig(struct csio_hw *hw, int reset)
-{
-	int		rv;
-	/*
-	 * Reset device if necessary
-	 */
-	if (reset) {
-		rv = csio_do_reset(hw, true);
-		if (rv != 0)
-			goto out;
-	}
-
-	/* Get and set device capabilities */
-	rv = csio_config_device_caps(hw);
-	if (rv != 0)
-		goto out;
-
-	/* device parameters */
-	rv = csio_get_device_params(hw);
-	if (rv != 0)
-		goto out;
-
-	/* Configure SGE */
-	csio_wr_sge_init(hw);
-
-	/* Post event to notify completion of configuration */
-	csio_post_event(&hw->sm, CSIO_HWE_INIT);
-
-out:
+	csio_warn(hw, "Configuration file error %d\n", rv);
 	return rv;
 }
 
@@ -2101,7 +2012,9 @@ csio_hw_flash_fw(struct csio_hw *hw, int *reset)
 	if (request_firmware(&fw, FW_FNAME_T5, dev) < 0) {
 		csio_err(hw, "could not find firmware image %s, err: %d\n",
 			 FW_FNAME_T5, ret);
-		return -EINVAL;
+	} else {
+		fw_data = fw->data;
+		fw_size = fw->size;
 	}
 
 	/* allocate memory to read the header of the firmware on the
@@ -2109,9 +2022,6 @@ csio_hw_flash_fw(struct csio_hw *hw, int *reset)
 	 */
 	card_fw = kmalloc(sizeof(*card_fw), GFP_KERNEL);
 
-	fw_data = fw->data;
-	fw_size = fw->size;
-
 	/* upgrade FW logic */
 	ret = csio_hw_prep_fw(hw, fw_info, fw_data, fw_size, card_fw,
 			 hw->fw_state, reset);
@@ -2190,31 +2100,31 @@ csio_hw_configure(struct csio_hw *hw)
 		if (rv != 0)
 			goto out;
 
-		/*
-		 * If the firmware doesn't support Configuration
-		 * Files, use the old Driver-based, hard-wired
-		 * initialization.  Otherwise, try using the
-		 * Configuration File support and fall back to the
-		 * Driver-based initialization if there's no
-		 * Configuration File found.
+		/* If the firmware doesn't support Configuration Files,
+		 * return an error.
 		 */
-		if (csio_hw_check_fwconfig(hw, param) == 0) {
-			rv = csio_hw_use_fwconfig(hw, reset, param);
-			if (rv == -ENOENT)
-				goto out;
-			if (rv != 0) {
-				csio_info(hw,
-				    "No Configuration File present "
-				    "on adapter.  Using hard-wired "
-				    "configuration parameters.\n");
-				rv = csio_hw_no_fwconfig(hw, reset);
-			}
-		} else {
-			rv = csio_hw_no_fwconfig(hw, reset);
+		rv = csio_hw_check_fwconfig(hw, param);
+		if (rv != 0) {
+			csio_info(hw, "Firmware doesn't support "
+				  "Firmware Configuration files\n");
+			goto out;
 		}
 
-		if (rv != 0)
+		/* The firmware provides us with a memory buffer where we can
+		 * load a Configuration File from the host if we want to
+		 * override the Configuration File in flash.
+		 */
+		rv = csio_hw_use_fwconfig(hw, reset, param);
+		if (rv == -ENOENT) {
+			csio_info(hw, "Could not initialize "
+				  "adapter, error%d\n", rv);
 			goto out;
+		}
+		if (rv != 0) {
+			csio_info(hw, "Could not initialize "
+				  "adapter, error%d\n", rv);
+			goto out;
+		}
 
 	} else {
 		if (hw->fw_state == CSIO_DEV_STATE_INIT) {
diff --git a/drivers/scsi/csiostor/csio_hw.h b/drivers/scsi/csiostor/csio_hw.h
index 1fe8fde..029bef8 100644
--- a/drivers/scsi/csiostor/csio_hw.h
+++ b/drivers/scsi/csiostor/csio_hw.h
@@ -48,6 +48,7 @@
 #include <scsi/scsi_device.h>
 #include <scsi/scsi_transport_fc.h>
 
+#include "t4_hw.h"
 #include "csio_hw_chip.h"
 #include "csio_wr.h"
 #include "csio_mb.h"
@@ -174,16 +175,12 @@ struct csio_evt_msg {
 };
 
 enum {
-	EEPROMVSIZE    = 32768, /* Serial EEPROM virtual address space size */
 	SERNUM_LEN     = 16,    /* Serial # length */
 	EC_LEN         = 16,    /* E/C length */
 	ID_LEN         = 16,    /* ID length */
-	TRACE_LEN      = 112,   /* length of trace data and mask */
 };
 
 enum {
-	SF_PAGE_SIZE = 256,           /* serial flash page size */
-	SF_SEC_SIZE = 64 * 1024,      /* serial flash sector size */
 	SF_SIZE = SF_SEC_SIZE * 16,   /* serial flash size */
 };
 
@@ -199,38 +196,8 @@ enum {
 	SF_RD_DATA_FAST = 0xb,        /* read flash */
 	SF_RD_ID	= 0x9f,	      /* read ID */
 	SF_ERASE_SECTOR = 0xd8,       /* erase sector */
-
-	FW_START_SEC = 8,             /* first flash sector for FW */
-	FW_IMG_START = FW_START_SEC * SF_SEC_SIZE,
-	FW_MAX_SIZE = 16 * SF_SEC_SIZE,
-
-	FLASH_CFG_MAX_SIZE    = 0x10000 , /* max size of the flash config file*/
-	FLASH_CFG_OFFSET      = 0x1f0000,
-	FLASH_CFG_START_SEC   = FLASH_CFG_OFFSET / SF_SEC_SIZE,
 };
 
-/*
- * Flash layout.
- */
-#define FLASH_START(start)	((start) * SF_SEC_SIZE)
-#define FLASH_MAX_SIZE(nsecs)	((nsecs) * SF_SEC_SIZE)
-
-enum {
-	/*
-	 * Location of firmware image in FLASH.
-	 */
-	FLASH_FW_START_SEC = 8,
-	FLASH_FW_NSECS = 16,
-	FLASH_FW_START = FLASH_START(FLASH_FW_START_SEC),
-	FLASH_FW_MAX_SIZE = FLASH_MAX_SIZE(FLASH_FW_NSECS),
-
-	/* Location of Firmware Configuration File in FLASH. */
-	FLASH_CFG_START = FLASH_START(FLASH_CFG_START_SEC),
-};
-
-#undef FLASH_START
-#undef FLASH_MAX_SIZE
-
 /* Management module */
 enum {
 	CSIO_MGMT_EQ_WRSIZE = 512,
@@ -481,11 +448,6 @@ struct csio_hw {
 	uint32_t		tp_vers;
 	char			chip_ver;
 	uint16_t		chip_id;		/* Tells T4/T5 chip */
-	uint32_t		cfg_finiver;
-	uint32_t		cfg_finicsum;
-	uint32_t		cfg_cfcsum;
-	uint8_t			cfg_csum_status;
-	uint8_t			cfg_store;
 	enum csio_dev_state	fw_state;
 	struct csio_vpd		vpd;
 
diff --git a/drivers/scsi/csiostor/csio_hw_chip.h b/drivers/scsi/csiostor/csio_hw_chip.h
index e962d3d..a5f624f 100644
--- a/drivers/scsi/csiostor/csio_hw_chip.h
+++ b/drivers/scsi/csiostor/csio_hw_chip.h
@@ -95,7 +95,6 @@ enum { MEM_EDC0, MEM_EDC1, MEM_MC, MEM_MC0 = MEM_MC, MEM_MC1 };
 enum {
 	MEMWIN_APERTURE = 2048,
 	MEMWIN_BASE     = 0x1b800,
-	MEMWIN_CSIOSTOR = 6,		/* PCI-e Memory Window access */
 };
 
 /* Slow path handlers */
-- 
2.0.2
