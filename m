From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 10/13] staging: r8188eu: Remove wrapper _enter_critical_mutex()
Date: Fri, 14 Feb 2014 16:54:14 -0600
Message-ID: <1392418457-3203-11-git-send-email-Larry.Finger@lwfinger.net>
References: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:63884 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753058AbaBNWy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 17:54:59 -0500
Received: by mail-oa0-f49.google.com with SMTP id i7so15057266oag.8
        for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 14:54:59 -0800 (PST)
In-Reply-To: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This wrapper returned the result of mutex_lock_interruptible(); however,
none of the callers checked the returned value.

As a result of a gcc upgrade to version 4.8.1, two false unitialized variable
warnings appeared. To silence the warnings, they are initialized to 0.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_mlme_ext.c     | 3 ++-
 drivers/staging/rtl8188eu/hal/usb_ops_linux.c     | 8 +++++---
 drivers/staging/rtl8188eu/include/osdep_service.h | 9 ---------
 drivers/staging/rtl8188eu/os_dep/os_intfs.c       | 3 ++-
 4 files changed, 9 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
index c197b22..e95a1ba 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
@@ -4429,7 +4429,8 @@ s32 dump_mgntframe_and_wait_ack(struct adapter *padapter, struct xmit_frame *pmg
 	if (padapter->bSurpriseRemoved || padapter->bDriverStopped)
 		return -1;
 
-	_enter_critical_mutex(&pxmitpriv->ack_tx_mutex, NULL);
+	if (mutex_lock_interruptible(&pxmitpriv->ack_tx_mutex))
+		return -1;
 	pxmitpriv->ack_tx = true;
 
 	pmgntframe->ack_report = 1;
diff --git a/drivers/staging/rtl8188eu/hal/usb_ops_linux.c b/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
index 1fa5370..d5f6a32 100644
--- a/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
+++ b/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
@@ -49,7 +49,9 @@ static int usbctrl_vendorreq(struct intf_hdl *pintfhdl, u8 request, u16 value, u
 		goto exit;
 	}
 
-	_enter_critical_mutex(&dvobjpriv->usb_vendor_req_mutex, NULL);
+	if (mutex_lock_interruptible(&dvobjpriv->usb_vendor_req_mutex))
+		status = -ENOMEM;
+		goto exit;
 
 	/*  Acquire IO memory for vendorreq */
 	pIo_buf = dvobjpriv->usb_vendor_req_buf;
@@ -147,7 +149,7 @@ static u16 usb_read16(struct intf_hdl *pintfhdl, u32 addr)
 	u16 wvalue;
 	u16 index;
 	u16 len;
-	__le32 data;
+	__le32 data = 0;
 
 	request = 0x05;
 	requesttype = 0x01;/* read_in */
@@ -166,7 +168,7 @@ static u32 usb_read32(struct intf_hdl *pintfhdl, u32 addr)
 	u16 wvalue;
 	u16 index;
 	u16 len;
-	__le32 data;
+	__le32 data = 0;
 
 
 	request = 0x05;
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index 5cf13a6..64a7c34 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -67,15 +67,6 @@ static inline struct list_head *get_list_head(struct __queue *queue)
 	return &(queue->queue);
 }
 
-static inline int _enter_critical_mutex(struct mutex *pmutex,
-					unsigned long *pirqL)
-{
-	int ret;
-
-	ret = mutex_lock_interruptible(pmutex);
-	return ret;
-}
-
 static inline void rtw_list_delete(struct list_head *plist)
 {
 	list_del_init(plist);
diff --git a/drivers/staging/rtl8188eu/os_dep/os_intfs.c b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
index bc9ae1d..0cd39ca 100644
--- a/drivers/staging/rtl8188eu/os_dep/os_intfs.c
+++ b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
@@ -1109,7 +1109,8 @@ int netdev_open(struct net_device *pnetdev)
 	int ret;
 	struct adapter *padapter = (struct adapter *)rtw_netdev_priv(pnetdev);
 
-	_enter_critical_mutex(padapter->hw_init_mutex, NULL);
+	if (mutex_lock_interruptible(padapter->hw_init_mutex))
+		return -1;
 	ret = _netdev_open(pnetdev);
 	mutex_unlock(padapter->hw_init_mutex);
 	return ret;
-- 
1.8.4.5
