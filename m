From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 07/22] staging: rtl8723bs: Fix potential usage while NULL error in hal/rtl8723b_hal_init.c
Date: Sat,  8 Apr 2017 11:07:30 -0500
Message-ID: <20170408160745.14328-8-Larry.Finger@lwfinger.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        hdegoede@redhat.com, hadess@hadess.net, jes.sorensen@gmail.com,
        Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34832 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752491AbdDHQIN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 12:08:13 -0400
Received: by mail-oi0-f68.google.com with SMTP id g204so6268765oib.2
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 09:08:08 -0700 (PDT)
In-Reply-To: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch logs the following:

  CHECK   drivers/staging/rtl8723bs/hal/rtl8723b_hal_init.c
drivers/staging/rtl8723bs/hal/rtl8723b_hal_init.c:518 rtl8723b_FirmwareDownload() error: we previously assumed 'pFirmware' could be null (see line 382)

Fixing this error required a rewrite of the error exits from this routine.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8723bs/hal/rtl8723b_hal_init.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/rtl8723bs/hal/rtl8723b_hal_init.c b/drivers/staging/rtl8723bs/hal/rtl8723b_hal_init.c
index b7f6dc7ce318..d40ad03e99a3 100644
--- a/drivers/staging/rtl8723bs/hal/rtl8723b_hal_init.c
+++ b/drivers/staging/rtl8723bs/hal/rtl8723b_hal_init.c
@@ -377,13 +377,13 @@ s32 rtl8723b_FirmwareDownload(struct adapter *padapter, bool  bUsedWoWLANFw)
 	RT_TRACE(_module_hal_init_c_, _drv_notice_, ("+%s, bUsedWoWLANFw:%d\n", __func__, bUsedWoWLANFw));
 #endif
 	pFirmware = kzalloc(sizeof(struct rt_firmware), GFP_KERNEL);
+	if (!pFirmware)
+		return _FAIL;
 	pBTFirmware = kzalloc(sizeof(struct rt_firmware), GFP_KERNEL);
-
-	if (!pFirmware || !pBTFirmware) {
-		rtStatus = _FAIL;
-		goto exit;
+	if (!pBTFirmware) {
+		kfree(pFirmware);
+		return _FAIL;
 	}
-
 	tmp_ps = rtw_read8(padapter, 0xa3);
 	tmp_ps &= 0xf8;
 	tmp_ps |= 0x02;
@@ -441,7 +441,7 @@ s32 rtl8723b_FirmwareDownload(struct adapter *padapter, bool  bUsedWoWLANFw)
 	if (pFirmware->ulFwLength > FW_8723B_SIZE) {
 		rtStatus = _FAIL;
 		DBG_871X_LEVEL(_drv_emerg_, "Firmware size:%u exceed %u\n", pFirmware->ulFwLength, FW_8723B_SIZE);
-		goto exit;
+		goto release_fw1;
 	}
 
 	pFirmwareBuf = pFirmware->szFwBuffer;
@@ -517,6 +517,7 @@ s32 rtl8723b_FirmwareDownload(struct adapter *padapter, bool  bUsedWoWLANFw)
 exit:
 	kfree(pFirmware->szFwBuffer);
 	kfree(pFirmware);
+release_fw1:
 	kfree(pBTFirmware);
 	DBG_871X(" <=== rtl8723b_FirmwareDownload()\n");
 	return rtStatus;
-- 
2.12.0
