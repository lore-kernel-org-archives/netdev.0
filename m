From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 13/13] staging: r8188eu: Make firmware buffer persistent
Date: Fri, 14 Feb 2014 16:54:17 -0600
Message-ID: <1392418457-3203-14-git-send-email-Larry.Finger@lwfinger.net>
References: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:53850 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753091AbaBNWzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 17:55:09 -0500
Received: by mail-oa0-f43.google.com with SMTP id h16so15401035oag.30
        for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 14:55:09 -0800 (PST)
In-Reply-To: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stas Sergeev <stsp@users.sourceforge.net>

The present code reloads the firmware file from the disk every time the interface
re-inits. Change to hold the firmware in memory, and only download to the
device.

Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c | 80 +++++++++++++----------
 drivers/staging/rtl8188eu/include/drv_types.h     |  6 ++
 drivers/staging/rtl8188eu/include/rtl8188e_hal.h  | 11 ----
 drivers/staging/rtl8188eu/os_dep/os_intfs.c       |  4 ++
 4 files changed, 54 insertions(+), 47 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c b/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
index 13c0619..f9d5558 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
@@ -584,59 +584,70 @@ static s32 _FWFreeToGo(struct adapter *padapter)
 
 #define IS_FW_81xxC(padapter)	(((GET_HAL_DATA(padapter))->FirmwareSignature & 0xFFF0) == 0x88C0)
 
-s32 rtl8188e_FirmwareDownload(struct adapter *padapter)
+static int load_firmware(struct rt_firmware *pFirmware, struct device *device)
 {
-	s32	rtStatus = _SUCCESS;
-	u8 writeFW_retry = 0;
-	u32 fwdl_start_time;
-	struct hal_data_8188e *pHalData = GET_HAL_DATA(padapter);
-	struct dvobj_priv *dvobj = adapter_to_dvobj(padapter);
-	struct device *device = dvobj_to_dev(dvobj);
-	struct rt_firmware *pFirmware = NULL;
+	int rtstatus = _SUCCESS;
 	const struct firmware *fw;
-	struct rt_firmware_hdr *pFwHdr = NULL;
-	u8 *pFirmwareBuf;
-	u32 FirmwareLen;
-	char fw_name[] = "rtlwifi/rtl8188eufw.bin";
-	static int log_version;
-
-	RT_TRACE(_module_hal_init_c_, _drv_info_, ("+%s\n", __func__));
-	pFirmware = (struct rt_firmware *)rtw_zmalloc(sizeof(struct rt_firmware));
-	if (!pFirmware) {
-		rtStatus = _FAIL;
-		goto Exit;
-	}
+	const char fw_name[] = "rtlwifi/rtl8188eufw.bin";
 
 	if (request_firmware(&fw, fw_name, device)) {
-		rtStatus = _FAIL;
-		goto Exit;
+		rtstatus = _FAIL;
+		goto exit;
 	}
 	if (!fw) {
 		pr_err("Firmware %s not available\n", fw_name);
-		rtStatus = _FAIL;
-		goto Exit;
+		rtstatus = _FAIL;
+		goto exit;
 	}
 	if (fw->size > FW_8188E_SIZE) {
-		rtStatus = _FAIL;
-		RT_TRACE(_module_hal_init_c_, _drv_err_, ("Firmware size exceed 0x%X. Check it.\n", FW_8188E_SIZE));
-		goto Exit;
+		rtstatus = _FAIL;
+		RT_TRACE(_module_hal_init_c_, _drv_err_,
+			 ("Firmware size exceed 0x%X. Check it.\n",
+			 FW_8188E_SIZE));
+		goto exit;
 	}
 
 	pFirmware->szFwBuffer = kzalloc(FW_8188E_SIZE, GFP_KERNEL);
 	if (!pFirmware->szFwBuffer) {
-		rtStatus = _FAIL;
-		goto Exit;
+		rtstatus = _FAIL;
+		goto exit;
 	}
 	memcpy(pFirmware->szFwBuffer, fw->data, fw->size);
 	pFirmware->ulFwLength = fw->size;
-	pFirmwareBuf = pFirmware->szFwBuffer;
-	FirmwareLen = pFirmware->ulFwLength;
 	release_firmware(fw);
 
-	DBG_88E_LEVEL(_drv_info_, "+%s: !bUsedWoWLANFw, FmrmwareLen:%d+\n", __func__, FirmwareLen);
+	DBG_88E_LEVEL(_drv_info_,
+		      "+%s: !bUsedWoWLANFw, FmrmwareLen:%d+\n", __func__,
+		      pFirmware->ulFwLength);
+exit:
+	return rtstatus;
+}
+
+s32 rtl8188e_FirmwareDownload(struct adapter *padapter)
+{
+	s32	rtStatus = _SUCCESS;
+	u8 writeFW_retry = 0;
+	u32 fwdl_start_time;
+	struct hal_data_8188e *pHalData = GET_HAL_DATA(padapter);
+	struct dvobj_priv *dvobj = adapter_to_dvobj(padapter);
+	struct device *device = dvobj_to_dev(dvobj);
+	struct rt_firmware_hdr *pFwHdr = NULL;
+	u8 *pFirmwareBuf;
+	u32 FirmwareLen;
+	static int log_version;
+
+	RT_TRACE(_module_hal_init_c_, _drv_info_, ("+%s\n", __func__));
+	if (!dvobj->firmware.szFwBuffer)
+		rtStatus = load_firmware(&dvobj->firmware, device);
+	if (rtStatus == _FAIL) {
+		dvobj->firmware.szFwBuffer = NULL;
+		goto Exit;
+	}
+	pFirmwareBuf = dvobj->firmware.szFwBuffer;
+	FirmwareLen = dvobj->firmware.ulFwLength;
 
 	/*  To Check Fw header. Added by tynli. 2009.12.04. */
-	pFwHdr = (struct rt_firmware_hdr *)pFirmware->szFwBuffer;
+	pFwHdr = (struct rt_firmware_hdr *)dvobj->firmware.szFwBuffer;
 
 	pHalData->FirmwareVersion =  le16_to_cpu(pFwHdr->Version);
 	pHalData->FirmwareSubVersion = pFwHdr->Subversion;
@@ -688,10 +699,7 @@ s32 rtl8188e_FirmwareDownload(struct adapter *padapter)
 		goto Exit;
 	}
 	RT_TRACE(_module_hal_init_c_, _drv_info_, ("Firmware is ready to run!\n"));
-	kfree(pFirmware->szFwBuffer);
 Exit:
-
-	kfree(pFirmware);
 	return rtStatus;
 }
 
diff --git a/drivers/staging/rtl8188eu/include/drv_types.h b/drivers/staging/rtl8188eu/include/drv_types.h
index a492a1c..936c196 100644
--- a/drivers/staging/rtl8188eu/include/drv_types.h
+++ b/drivers/staging/rtl8188eu/include/drv_types.h
@@ -159,9 +159,15 @@ struct registry_priv {
 
 #define MAX_CONTINUAL_URB_ERR		4
 
+struct rt_firmware {
+	u8			*szFwBuffer;
+	u32			ulFwLength;
+};
+
 struct dvobj_priv {
 	struct adapter *if1;
 	struct adapter *if2;
+	struct rt_firmware firmware;
 
 	/* For 92D, DMDP have 2 interface. */
 	u8	InterfaceNumber;
diff --git a/drivers/staging/rtl8188eu/include/rtl8188e_hal.h b/drivers/staging/rtl8188eu/include/rtl8188e_hal.h
index 161f1e5..75e41c4 100644
--- a/drivers/staging/rtl8188eu/include/rtl8188e_hal.h
+++ b/drivers/staging/rtl8188eu/include/rtl8188e_hal.h
@@ -76,17 +76,6 @@
 	(le16_to_cpu(_pFwHdr->Signature)&0xFFF0) == 0x2300 ||	\
 	(le16_to_cpu(_pFwHdr->Signature)&0xFFF0) == 0x88E0)
 
-enum firmware_source {
-	FW_SOURCE_IMG_FILE = 0,
-	FW_SOURCE_HEADER_FILE = 1,		/* from header file */
-};
-
-struct rt_firmware {
-	enum firmware_source	eFWSource;
-	u8			*szFwBuffer;
-	u32			ulFwLength;
-};
-
 /*  This structure must be careful with byte-ordering */
 
 struct rt_firmware_hdr {
diff --git a/drivers/staging/rtl8188eu/os_dep/os_intfs.c b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
index 0cd39ca..d388d4d 100644
--- a/drivers/staging/rtl8188eu/os_dep/os_intfs.c
+++ b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
@@ -1205,6 +1205,7 @@ int pm_netdev_open(struct net_device *pnetdev, u8 bnormal)
 int netdev_close(struct net_device *pnetdev)
 {
 	struct adapter *padapter = (struct adapter *)rtw_netdev_priv(pnetdev);
+	struct dvobj_priv *dvobj = adapter_to_dvobj(padapter);
 
 	RT_TRACE(_module_os_intfs_c_, _drv_info_, ("+88eu_drv - drv_close\n"));
 
@@ -1243,6 +1244,9 @@ int netdev_close(struct net_device *pnetdev)
 	rtw_p2p_enable(padapter, P2P_ROLE_DISABLE);
 #endif /* CONFIG_88EU_P2P */
 
+	kfree(dvobj->firmware.szFwBuffer);
+	dvobj->firmware.szFwBuffer = NULL;
+
 	RT_TRACE(_module_os_intfs_c_, _drv_info_, ("-88eu_drv - drv_close\n"));
 	DBG_88E("-88eu_drv - drv_close, bup =%d\n", padapter->bup);
 	return 0;
-- 
1.8.4.5
