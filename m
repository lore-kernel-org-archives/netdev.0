From: Praveen Madhavan <praveenm@chelsio.com>
Subject: [PATCH] csiostor:firmware upgrade fix
Date: Wed,  7 Jan 2015 19:16:28 +0530
Message-ID: <1420638388-9074-1-git-send-email-praveenm@chelsio.com>
Cc: davem@davemloft.net, JBottomley@parallels.com, hch@infradead.org,
	hariprasad@chelsio.com, praveenm@chelsio.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes removes older means of upgrading Firmware using MAJOR version
and adds newer interface version checking mechanism.

Please apply this patch on net-next since it depends on previous commits.

Signed-off-by: Praveen Madhavan <praveenm@chelsio.com>
---
 drivers/scsi/csiostor/csio_hw.c      | 277 +++++++++++++++++++++++++----------
 drivers/scsi/csiostor/csio_hw.h      |   5 +-
 drivers/scsi/csiostor/csio_hw_chip.h |  47 +++++-
 3 files changed, 247 insertions(+), 82 deletions(-)

diff --git a/drivers/scsi/csiostor/csio_hw.c b/drivers/scsi/csiostor/csio_hw.c
index 6602835..b70c15f 100644
--- a/drivers/scsi/csiostor/csio_hw.c
+++ b/drivers/scsi/csiostor/csio_hw.c
@@ -682,43 +682,6 @@ csio_hw_get_tp_version(struct csio_hw *hw, u32 *vers)
 }
 
 /*
- *	csio_hw_check_fw_version - check if the FW is compatible with
- *				   this driver
- *	@hw: HW module
- *
- *	Checks if an adapter's FW is compatible with the driver.  Returns 0
- *	if there's exact match, a negative error if the version could not be
- *	read or there's a major/minor version mismatch/minor.
- */
-static int
-csio_hw_check_fw_version(struct csio_hw *hw)
-{
-	int ret, major, minor, micro;
-
-	ret = csio_hw_get_fw_version(hw, &hw->fwrev);
-	if (!ret)
-		ret = csio_hw_get_tp_version(hw, &hw->tp_vers);
-	if (ret)
-		return ret;
-
-	major = FW_HDR_FW_VER_MAJOR_G(hw->fwrev);
-	minor = FW_HDR_FW_VER_MINOR_G(hw->fwrev);
-	micro = FW_HDR_FW_VER_MICRO_G(hw->fwrev);
-
-	if (major != FW_VERSION_MAJOR(hw)) {	/* major mismatch - fail */
-		csio_err(hw, "card FW has major version %u, driver wants %u\n",
-			 major, FW_VERSION_MAJOR(hw));
-		return -EINVAL;
-	}
-
-	if (minor == FW_VERSION_MINOR(hw) && micro == FW_VERSION_MICRO(hw))
-		return 0;        /* perfect match */
-
-	/* Minor/micro version mismatch */
-	return -EINVAL;
-}
-
-/*
  * csio_hw_fw_dload - download firmware.
  * @hw: HW module
  * @fw_data: firmware image to write.
@@ -1967,6 +1930,170 @@ out:
 	return rv;
 }
 
+/* Is the given firmware API compatible with the one the driver was compiled
+ * with?
+ */
+static int fw_compatible(const struct fw_hdr *hdr1, const struct fw_hdr *hdr2)
+{
+
+	/* short circuit if it's the exact same firmware version */
+	if (hdr1->chip == hdr2->chip && hdr1->fw_ver == hdr2->fw_ver)
+		return 1;
+
+#define SAME_INTF(x) (hdr1->intfver_##x == hdr2->intfver_##x)
+	if (hdr1->chip == hdr2->chip && SAME_INTF(nic) && SAME_INTF(vnic) &&
+	    SAME_INTF(ri) && SAME_INTF(iscsi) && SAME_INTF(fcoe))
+		return 1;
+#undef SAME_INTF
+
+	return 0;
+}
+
+/* The firmware in the filesystem is usable, but should it be installed?
+ * This routine explains itself in detail if it indicates the filesystem
+ * firmware should be installed.
+ */
+static int csio_should_install_fs_fw(struct csio_hw *hw, int card_fw_usable,
+				int k, int c)
+{
+	const char *reason;
+
+	if (!card_fw_usable) {
+		reason = "incompatible or unusable";
+		goto install;
+	}
+
+	if (k > c) {
+		reason = "older than the version supported with this driver";
+		goto install;
+	}
+
+	return 0;
+
+install:
+	csio_err(hw, "firmware on card (%u.%u.%u.%u) is %s, "
+		"installing firmware %u.%u.%u.%u on card.\n",
+		FW_HDR_FW_VER_MAJOR_G(c), FW_HDR_FW_VER_MINOR_G(c),
+		FW_HDR_FW_VER_MICRO_G(c), FW_HDR_FW_VER_BUILD_G(c), reason,
+		FW_HDR_FW_VER_MAJOR_G(k), FW_HDR_FW_VER_MINOR_G(k),
+		FW_HDR_FW_VER_MICRO_G(k), FW_HDR_FW_VER_BUILD_G(k));
+
+	return 1;
+}
+
+static struct fw_info fw_info_array[] = {
+	{
+		.chip = CHELSIO_T5,
+		.fs_name = FW_CFG_NAME_T5,
+		.fw_mod_name = FW_FNAME_T5,
+		.fw_hdr = {
+			.chip = FW_HDR_CHIP_T5,
+			.fw_ver = __cpu_to_be32(FW_VERSION(T5)),
+			.intfver_nic = FW_INTFVER(T5, NIC),
+			.intfver_vnic = FW_INTFVER(T5, VNIC),
+			.intfver_ri = FW_INTFVER(T5, RI),
+			.intfver_iscsi = FW_INTFVER(T5, ISCSI),
+			.intfver_fcoe = FW_INTFVER(T5, FCOE),
+		},
+	}
+};
+
+static struct fw_info *find_fw_info(int chip)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(fw_info_array); i++) {
+		if (fw_info_array[i].chip == chip)
+			return &fw_info_array[i];
+	}
+	return NULL;
+}
+
+int csio_hw_prep_fw(struct csio_hw *hw, struct fw_info *fw_info,
+	       const u8 *fw_data, unsigned int fw_size,
+	       struct fw_hdr *card_fw, enum csio_dev_state state,
+	       int *reset)
+{
+	int ret, card_fw_usable, fs_fw_usable;
+	const struct fw_hdr *fs_fw;
+	const struct fw_hdr *drv_fw;
+
+	drv_fw = &fw_info->fw_hdr;
+
+	/* Read the header of the firmware on the card */
+	ret = csio_hw_read_flash(hw, FLASH_FW_START,
+			    sizeof(*card_fw) / sizeof(uint32_t),
+			    (uint32_t *)card_fw, 1);
+	if (ret == 0) {
+		card_fw_usable = fw_compatible(drv_fw, (const void *)card_fw);
+	} else {
+		csio_err(hw,
+			"Unable to read card's firmware header: %d\n", ret);
+		card_fw_usable = 0;
+	}
+
+	if (fw_data != NULL) {
+		fs_fw = (const void *)fw_data;
+		fs_fw_usable = fw_compatible(drv_fw, fs_fw);
+	} else {
+		fs_fw = NULL;
+		fs_fw_usable = 0;
+	}
+
+	if (card_fw_usable && card_fw->fw_ver == drv_fw->fw_ver &&
+	    (!fs_fw_usable || fs_fw->fw_ver == drv_fw->fw_ver)) {
+		/* Common case: the firmware on the card is an exact match and
+		 * the filesystem one is an exact match too, or the filesystem
+		 * one is absent/incompatible.
+		 */
+	} else if (fs_fw_usable && state == CSIO_DEV_STATE_UNINIT &&
+		   csio_should_install_fs_fw(hw, card_fw_usable,
+					be32_to_cpu(fs_fw->fw_ver),
+					be32_to_cpu(card_fw->fw_ver))) {
+		ret = csio_hw_fw_upgrade(hw, hw->pfn, fw_data,
+				     fw_size, 0);
+		if (ret != 0) {
+			csio_err(hw,
+				"failed to install firmware: %d\n", ret);
+			goto bye;
+		}
+
+		/* Installed successfully, update the cached header too. */
+		memcpy(card_fw, fs_fw, sizeof(*card_fw));
+		card_fw_usable = 1;
+		*reset = 0;	/* already reset as part of load_fw */
+	}
+
+	if (!card_fw_usable) {
+		uint32_t d, c, k;
+
+		d = be32_to_cpu(drv_fw->fw_ver);
+		c = be32_to_cpu(card_fw->fw_ver);
+		k = fs_fw ? be32_to_cpu(fs_fw->fw_ver) : 0;
+
+		csio_err(hw, "Cannot find a usable firmware: "
+			"chip state %d, "
+			"driver compiled with %d.%d.%d.%d, "
+			"card has %d.%d.%d.%d, filesystem has %d.%d.%d.%d\n",
+			state,
+			FW_HDR_FW_VER_MAJOR_G(d), FW_HDR_FW_VER_MINOR_G(d),
+			FW_HDR_FW_VER_MICRO_G(d), FW_HDR_FW_VER_BUILD_G(d),
+			FW_HDR_FW_VER_MAJOR_G(c), FW_HDR_FW_VER_MINOR_G(c),
+			FW_HDR_FW_VER_MICRO_G(c), FW_HDR_FW_VER_BUILD_G(c),
+			FW_HDR_FW_VER_MAJOR_G(k), FW_HDR_FW_VER_MINOR_G(k),
+			FW_HDR_FW_VER_MICRO_G(k), FW_HDR_FW_VER_BUILD_G(k));
+		ret = EINVAL;
+		goto bye;
+	}
+
+	/* We're using whatever's on the card and it's known to be good. */
+	hw->fwrev = be32_to_cpu(card_fw->fw_ver);
+	hw->tp_vers = be32_to_cpu(card_fw->tp_microcode_ver);
+
+bye:
+	return ret;
+}
+
 /*
  * Returns -EINVAL if attempts to flash the firmware failed
  * else returns 0,
@@ -1974,14 +2101,27 @@ out:
  * latest firmware ECANCELED is returned
  */
 static int
-csio_hw_flash_fw(struct csio_hw *hw)
+csio_hw_flash_fw(struct csio_hw *hw, int *reset)
 {
 	int ret = -ECANCELED;
 	const struct firmware *fw;
-	const struct fw_hdr *hdr;
-	u32 fw_ver;
+	struct fw_info *fw_info;
+	struct fw_hdr *card_fw;
 	struct pci_dev *pci_dev = hw->pdev;
 	struct device *dev = &pci_dev->dev ;
+	const u8 *fw_data = NULL;
+	unsigned int fw_size = 0;
+
+	/* This is the firmware whose headers the driver was compiled
+	 * against
+	 */
+	fw_info = find_fw_info(CHELSIO_CHIP_VERSION(hw->chip_id));
+	if (fw_info == NULL) {
+		csio_err(hw,
+			"unable to get firmware info for chip %d.\n",
+			CHELSIO_CHIP_VERSION(hw->chip_id));
+		return -EINVAL;
+	}
 
 	if (request_firmware(&fw, CSIO_FW_FNAME(hw), dev) < 0) {
 		csio_err(hw, "could not find firmware image %s, err: %d\n",
@@ -1989,33 +2129,25 @@ csio_hw_flash_fw(struct csio_hw *hw)
 		return -EINVAL;
 	}
 
-	hdr = (const struct fw_hdr *)fw->data;
-	fw_ver = ntohl(hdr->fw_ver);
-	if (FW_HDR_FW_VER_MAJOR_G(fw_ver) != FW_VERSION_MAJOR(hw))
-		return -EINVAL;      /* wrong major version, won't do */
-
-	/*
-	 * If the flash FW is unusable or we found something newer, load it.
+	/* allocate memory to read the header of the firmware on the
+	 * card
 	 */
-	if (FW_HDR_FW_VER_MAJOR_G(hw->fwrev) != FW_VERSION_MAJOR(hw) ||
-	    fw_ver > hw->fwrev) {
-		ret = csio_hw_fw_upgrade(hw, hw->pfn, fw->data, fw->size,
-				    /*force=*/false);
-		if (!ret)
-			csio_info(hw,
-				  "firmware upgraded to version %pI4 from %s\n",
-				  &hdr->fw_ver, CSIO_FW_FNAME(hw));
-		else
-			csio_err(hw, "firmware upgrade failed! err=%d\n", ret);
-	} else
-		ret = -EINVAL;
+	card_fw = kmalloc(sizeof(*card_fw), GFP_KERNEL);
 
-	release_firmware(fw);
+	fw_data = fw->data;
+	fw_size = fw->size;
 
+	/* upgrade FW logic */
+	ret = csio_hw_prep_fw(hw, fw_info, fw_data, fw_size, card_fw,
+			 hw->fw_state, reset);
+
+	/* Cleaning up */
+	if (fw != NULL)
+		release_firmware(fw);
+	kfree(card_fw);
 	return ret;
 }
 
-
 /*
  * csio_hw_configure - Configure HW
  * @hw - HW module
@@ -2071,25 +2203,18 @@ csio_hw_configure(struct csio_hw *hw)
 	if (rv != 0)
 		goto out;
 
+	csio_hw_get_fw_version(hw, &hw->fwrev);
+	csio_hw_get_tp_version(hw, &hw->tp_vers);
 	if (csio_is_hw_master(hw) && hw->fw_state != CSIO_DEV_STATE_INIT) {
-		rv = csio_hw_check_fw_version(hw);
-		if (rv == -EINVAL) {
 
 			/* Do firmware update */
-			spin_unlock_irq(&hw->lock);
-			rv = csio_hw_flash_fw(hw);
-			spin_lock_irq(&hw->lock);
+		spin_unlock_irq(&hw->lock);
+		rv = csio_hw_flash_fw(hw, &reset);
+		spin_lock_irq(&hw->lock);
+
+		if (rv != 0)
+			goto out;
 
-			if (rv == 0) {
-				reset = 0;
-				/*
-				 * Note that the chip was reset as part of the
-				 * firmware upgrade so we don't reset it again
-				 * below and grab the new firmware version.
-				 */
-				rv = csio_hw_check_fw_version(hw);
-			}
-		}
 		/*
 		 * If the firmware doesn't support Configuration
 		 * Files, use the old Driver-based, hard-wired
diff --git a/drivers/scsi/csiostor/csio_hw.h b/drivers/scsi/csiostor/csio_hw.h
index bd97204..1fe8fde 100644
--- a/drivers/scsi/csiostor/csio_hw.h
+++ b/drivers/scsi/csiostor/csio_hw.h
@@ -201,9 +201,8 @@ enum {
 	SF_ERASE_SECTOR = 0xd8,       /* erase sector */
 
 	FW_START_SEC = 8,             /* first flash sector for FW */
-	FW_END_SEC = 15,              /* last flash sector for FW */
 	FW_IMG_START = FW_START_SEC * SF_SEC_SIZE,
-	FW_MAX_SIZE = (FW_END_SEC - FW_START_SEC + 1) * SF_SEC_SIZE,
+	FW_MAX_SIZE = 16 * SF_SEC_SIZE,
 
 	FLASH_CFG_MAX_SIZE    = 0x10000 , /* max size of the flash config file*/
 	FLASH_CFG_OFFSET      = 0x1f0000,
@@ -221,7 +220,7 @@ enum {
 	 * Location of firmware image in FLASH.
 	 */
 	FLASH_FW_START_SEC = 8,
-	FLASH_FW_NSECS = 8,
+	FLASH_FW_NSECS = 16,
 	FLASH_FW_START = FLASH_START(FLASH_FW_START_SEC),
 	FLASH_FW_MAX_SIZE = FLASH_MAX_SIZE(FLASH_FW_NSECS),
 
diff --git a/drivers/scsi/csiostor/csio_hw_chip.h b/drivers/scsi/csiostor/csio_hw_chip.h
index 70c0bdd..eec98f5 100644
--- a/drivers/scsi/csiostor/csio_hw_chip.h
+++ b/drivers/scsi/csiostor/csio_hw_chip.h
@@ -50,6 +50,36 @@
 #define FW_CFG_NAME_T4				"cxgb4/t4-config.txt"
 #define FW_CFG_NAME_T5				"cxgb4/t5-config.txt"
 
+#define T4FW_VERSION_MAJOR 0x01
+#define T4FW_VERSION_MINOR 0x0B
+#define T4FW_VERSION_MICRO 0x1B
+#define T4FW_VERSION_BUILD 0x00
+
+#define T5FW_VERSION_MAJOR 0x01
+#define T5FW_VERSION_MINOR 0x0B
+#define T5FW_VERSION_MICRO 0x1B
+#define T5FW_VERSION_BUILD 0x00
+
+#define CHELSIO_CHIP_CODE(version, revision) (((version) << 4) | (revision))
+#define CHELSIO_CHIP_FPGA          0x100
+#define CHELSIO_CHIP_VERSION(code) (((code) >> 12) & 0xf)
+#define CHELSIO_CHIP_RELEASE(code) ((code) & 0xf)
+
+#define CHELSIO_T4		0x4
+#define CHELSIO_T5		0x5
+
+enum chip_type {
+	T4_A1 = CHELSIO_CHIP_CODE(CHELSIO_T4, 1),
+	T4_A2 = CHELSIO_CHIP_CODE(CHELSIO_T4, 2),
+	T4_FIRST_REV	= T4_A1,
+	T4_LAST_REV	= T4_A2,
+
+	T5_A0 = CHELSIO_CHIP_CODE(CHELSIO_T5, 0),
+	T5_A1 = CHELSIO_CHIP_CODE(CHELSIO_T5, 1),
+	T5_FIRST_REV	= T5_A0,
+	T5_LAST_REV	= T5_A1,
+};
+
 /* Define static functions */
 static inline int csio_is_t4(uint16_t chip)
 {
@@ -80,10 +110,21 @@ static inline int csio_is_t5(uint16_t chip)
 	(csio_is_t4(hw->chip_id) ? (PORT_REG(port, XGMAC_PORT_INT_CAUSE_A)) : \
 				(T5_PORT_REG(port, MAC_PORT_INT_CAUSE_A)))
 
-#define FW_VERSION_MAJOR(hw) (csio_is_t4(hw->chip_id) ? 1 : 0)
-#define FW_VERSION_MINOR(hw) (csio_is_t4(hw->chip_id) ? 2 : 0)
-#define FW_VERSION_MICRO(hw) (csio_is_t4(hw->chip_id) ? 8 : 0)
+#include "t4fw_api.h"
 
+#define FW_VERSION(chip) ( \
+		FW_HDR_FW_VER_MAJOR_G(chip##FW_VERSION_MAJOR) | \
+		FW_HDR_FW_VER_MINOR_G(chip##FW_VERSION_MINOR) | \
+		FW_HDR_FW_VER_MICRO_G(chip##FW_VERSION_MICRO) | \
+		FW_HDR_FW_VER_BUILD_G(chip##FW_VERSION_BUILD))
+#define FW_INTFVER(chip, intf) (FW_HDR_INTFVER_##intf)
+
+struct fw_info {
+	u8 chip;
+	char *fs_name;
+	char *fw_mod_name;
+	struct fw_hdr fw_hdr;
+};
 #define CSIO_FW_FNAME(hw)						\
 	(csio_is_t4(hw->chip_id) ? FW_FNAME_T4 : FW_FNAME_T5)
 
-- 
2.0.2

