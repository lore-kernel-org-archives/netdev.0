From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: [PATCH] Revert "ath10k: Search SMBIOS for OEM board file extension"
Date: Tue, 21 Feb 2017 21:47:06 +0200
Message-ID: <1487706426-31172-1-git-send-email-kvalo@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This reverts commit f2593cb1b29185d38db706cbcbe22ed538720ae1.

Paul reported that this patch with older board-2.bin ath10k initialisation
fails on Dell XPS 13:

ath10k_pci 0000:3a:00.0: failed to fetch board data for bus=pci,vendor=168c,
device=003e,subsystem-vendor=1a56,subsystem-device=1535,variant=RV_0520 from
ath10k/QCA6174/hw3.0/board-2.bin

The reason is that the older board-2.bin does not have the variant version of
the image name and ath10k does not fallback to the older naming scheme.

Reported-by: Paul Menzel <pmenzel-KUpvgZVWgV9o1qOY/usvUg@public.gmane.org>
Link: https://bugzilla.kernel.org/show_bug.cgi?id=185621#c9
Fixes: f2593cb1b291 ("ath10k: Search SMBIOS for OEM board file extension")
Signed-off-by: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
---

Dave, please take this directly if you can.

 drivers/net/wireless/ath/ath10k/core.c | 84 ++--------------------------------
 drivers/net/wireless/ath/ath10k/core.h | 19 --------
 2 files changed, 3 insertions(+), 100 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/core.c b/drivers/net/wireless/ath/ath10k/core.c
index 59729aa8cd82..dd902b43f8f7 100644
--- a/drivers/net/wireless/ath/ath10k/core.c
+++ b/drivers/net/wireless/ath/ath10k/core.c
@@ -18,8 +18,6 @@
 #include <linux/module.h>
 #include <linux/firmware.h>
 #include <linux/of.h>
-#include <linux/dmi.h>
-#include <linux/ctype.h>
 #include <asm/byteorder.h>
 
 #include "core.h"
@@ -713,72 +711,6 @@ static int ath10k_core_get_board_id_from_otp(struct ath10k *ar)
 	return 0;
 }
 
-static void ath10k_core_check_bdfext(const struct dmi_header *hdr, void *data)
-{
-	struct ath10k *ar = data;
-	const char *bdf_ext;
-	const char *magic = ATH10K_SMBIOS_BDF_EXT_MAGIC;
-	u8 bdf_enabled;
-	int i;
-
-	if (hdr->type != ATH10K_SMBIOS_BDF_EXT_TYPE)
-		return;
-
-	if (hdr->length != ATH10K_SMBIOS_BDF_EXT_LENGTH) {
-		ath10k_dbg(ar, ATH10K_DBG_BOOT,
-			   "wrong smbios bdf ext type length (%d).\n",
-			   hdr->length);
-		return;
-	}
-
-	bdf_enabled = *((u8 *)hdr + ATH10K_SMBIOS_BDF_EXT_OFFSET);
-	if (!bdf_enabled) {
-		ath10k_dbg(ar, ATH10K_DBG_BOOT, "bdf variant name not found.\n");
-		return;
-	}
-
-	/* Only one string exists (per spec) */
-	bdf_ext = (char *)hdr + hdr->length;
-
-	if (memcmp(bdf_ext, magic, strlen(magic)) != 0) {
-		ath10k_dbg(ar, ATH10K_DBG_BOOT,
-			   "bdf variant magic does not match.\n");
-		return;
-	}
-
-	for (i = 0; i < strlen(bdf_ext); i++) {
-		if (!isascii(bdf_ext[i]) || !isprint(bdf_ext[i])) {
-			ath10k_dbg(ar, ATH10K_DBG_BOOT,
-				   "bdf variant name contains non ascii chars.\n");
-			return;
-		}
-	}
-
-	/* Copy extension name without magic suffix */
-	if (strscpy(ar->id.bdf_ext, bdf_ext + strlen(magic),
-		    sizeof(ar->id.bdf_ext)) < 0) {
-		ath10k_dbg(ar, ATH10K_DBG_BOOT,
-			   "bdf variant string is longer than the buffer can accommodate (variant: %s)\n",
-			    bdf_ext);
-		return;
-	}
-
-	ath10k_dbg(ar, ATH10K_DBG_BOOT,
-		   "found and validated bdf variant smbios_type 0x%x bdf %s\n",
-		   ATH10K_SMBIOS_BDF_EXT_TYPE, bdf_ext);
-}
-
-static int ath10k_core_check_smbios(struct ath10k *ar)
-{
-	ar->id.bdf_ext[0] = '\0';
-	dmi_walk(ath10k_core_check_bdfext, ar);
-
-	if (ar->id.bdf_ext[0] == '\0')
-		return -ENODATA;
-
-	return 0;
-}
-
 static int ath10k_download_and_run_otp(struct ath10k *ar)
 {
 	u32 result, address = ar->hw_params.patch_load_addr;
@@ -1125,9 +1057,6 @@ static int ath10k_core_fetch_board_data_api_n(struct ath10k *ar,
 static int ath10k_core_create_board_name(struct ath10k *ar, char *name,
 					 size_t name_len)
 {
-	/* strlen(',variant=') + strlen(ar->id.bdf_ext) */
-	char variant[9 + ATH10K_SMBIOS_BDF_EXT_STR_LENGTH] = { 0 };
-
 	if (ar->id.bmi_ids_valid) {
 		scnprintf(name, name_len,
 			  "bus=%s,bmi-chip-id=%d,bmi-board-id=%d",
@@ -1137,15 +1066,12 @@ static int ath10k_core_create_board_name(struct ath10k *ar, char *name,
 		goto out;
 	}
 
-	if (ar->id.bdf_ext[0] != '\0')
-		scnprintf(variant, sizeof(variant), ",variant=%s",
-			  ar->id.bdf_ext);
-
 	scnprintf(name, name_len,
-		  "bus=%s,vendor=%04x,device=%04x,subsystem-vendor=%04x,subsystem-device=%04x%s",
+		  "bus=%s,vendor=%04x,device=%04x,subsystem-vendor=%04x,subsystem-device=%04x",
 		  ath10k_bus_str(ar->hif.bus),
 		  ar->id.vendor, ar->id.device,
-		  ar->id.subsystem_vendor, ar->id.subsystem_device, variant);
+		  ar->id.subsystem_vendor, ar->id.subsystem_device);
+
 out:
 	ath10k_dbg(ar, ATH10K_DBG_BOOT, "boot using board name '%s'\n", name);
 
@@ -2202,10 +2128,6 @@ static int ath10k_core_probe_fw(struct ath10k *ar)
 		goto err_free_firmware_files;
 	}
 
-	ret = ath10k_core_check_smbios(ar);
-	if (ret)
-		ath10k_dbg(ar, ATH10K_DBG_BOOT, "bdf variant name not set.\n");
-
 	ret = ath10k_core_fetch_board_file(ar);
 	if (ret) {
 		ath10k_err(ar, "failed to fetch board file: %d\n", ret);
diff --git a/drivers/net/wireless/ath/ath10k/core.h b/drivers/net/wireless/ath/ath10k/core.h
index 88d14be7fcce..757242ef52ac 100644
--- a/drivers/net/wireless/ath/ath10k/core.h
+++ b/drivers/net/wireless/ath/ath10k/core.h
@@ -69,23 +69,6 @@
 #define ATH10K_NAPI_BUDGET      64
 #define ATH10K_NAPI_QUOTA_LIMIT 60
 
-/* SMBIOS type containing Board Data File Name Extension */
-#define ATH10K_SMBIOS_BDF_EXT_TYPE 0xF8
-
-/* SMBIOS type structure length (excluding strings-set) */
-#define ATH10K_SMBIOS_BDF_EXT_LENGTH 0x9
-
-/* Offset pointing to Board Data File Name Extension */
-#define ATH10K_SMBIOS_BDF_EXT_OFFSET 0x8
-
-/* Board Data File Name Extension string length.
- * String format: BDF_<Customer ID>_<Extension>\0
- */
-#define ATH10K_SMBIOS_BDF_EXT_STR_LENGTH 0x20
-
-/* The magic used by QCA spec */
-#define ATH10K_SMBIOS_BDF_EXT_MAGIC "BDF_"
-
 struct ath10k;
 
 enum ath10k_bus {
@@ -815,8 +798,6 @@ struct ath10k {
 		bool bmi_ids_valid;
 		u8 bmi_board_id;
 		u8 bmi_chip_id;
