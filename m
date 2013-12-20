From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 04/11] staging: r8188eu: Remove wrappers for spin_lock_irqsave
Date: Thu, 19 Dec 2013 22:38:36 -0600
Message-ID: <1387514323-4486-5-git-send-email-Larry.Finger@lwfinger.net>
References: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:44932 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895Ab3LTEk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 23:40:28 -0500
Received: by mail-pb0-f47.google.com with SMTP id um1so2085238pbc.34
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 20:40:28 -0800 (PST)
In-Reply-To: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two such wrappers - _enter_critical() and _enter_critical_ex().

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_cmd.c          |  4 ++--
 drivers/staging/rtl8188eu/core/rtw_recv.c         |  4 ++--
 drivers/staging/rtl8188eu/core/rtw_xmit.c         |  8 ++++----
 drivers/staging/rtl8188eu/include/osdep_service.h | 11 -----------
 drivers/staging/rtl8188eu/os_dep/usb_ops_linux.c  |  2 +-
 5 files changed, 9 insertions(+), 20 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_cmd.c b/drivers/staging/rtl8188eu/core/rtw_cmd.c
index 5e9b8a5..4561ffe 100644
--- a/drivers/staging/rtl8188eu/core/rtw_cmd.c
+++ b/drivers/staging/rtl8188eu/core/rtw_cmd.c
@@ -153,7 +153,7 @@ _func_enter_;
 	if (obj == NULL)
 		goto exit;
 
-	_enter_critical(&queue->lock, &irqL);
+	spin_lock_irqsave(&queue->lock, irqL);
 
 	rtw_list_insert_tail(&obj->list, &queue->queue);
 
@@ -173,7 +173,7 @@ struct	cmd_obj	*_rtw_dequeue_cmd(struct __queue *queue)
 
 _func_enter_;
 
-	_enter_critical(&queue->lock, &irqL);
+	spin_lock_irqsave(&queue->lock, irqL);
 	if (rtw_is_list_empty(&(queue->queue))) {
 		obj = NULL;
 	} else {
diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index f77b3aa..bf8f6e5a 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -326,7 +326,7 @@ int rtw_enqueue_recvbuf_to_head(struct recv_buf *precvbuf, struct __queue *queue
 int rtw_enqueue_recvbuf(struct recv_buf *precvbuf, struct __queue *queue)
 {
 	unsigned long irqL;
-	_enter_critical_ex(&queue->lock, &irqL);
+	spin_lock_irqsave(&queue->lock, irqL);
 
 	rtw_list_delete(&precvbuf->list);
 
@@ -341,7 +341,7 @@ struct recv_buf *rtw_dequeue_recvbuf (struct __queue *queue)
 	struct recv_buf *precvbuf;
 	struct list_head *plist, *phead;
 
-	_enter_critical_ex(&queue->lock, &irqL);
+	spin_lock_irqsave(&queue->lock, irqL);
 
 	if (_rtw_queue_empty(queue)) {
 		precvbuf = NULL;
diff --git a/drivers/staging/rtl8188eu/core/rtw_xmit.c b/drivers/staging/rtl8188eu/core/rtw_xmit.c
index b57ed45..e805a4b 100644
--- a/drivers/staging/rtl8188eu/core/rtw_xmit.c
+++ b/drivers/staging/rtl8188eu/core/rtw_xmit.c
@@ -1273,7 +1273,7 @@ struct xmit_buf *rtw_alloc_xmitbuf_ext(struct xmit_priv *pxmitpriv)
 
 _func_enter_;
 
-	_enter_critical(&pfree_queue->lock, &irql);
+	spin_lock_irqsave(&pfree_queue->lock, irql);
 
 	if (_rtw_queue_empty(pfree_queue) == true) {
 		pxmitbuf = NULL;
@@ -1316,7 +1316,7 @@ _func_enter_;
 	if (pxmitbuf == NULL)
 		return _FAIL;
 
-	_enter_critical(&pfree_queue->lock, &irql);
+	spin_lock_irqsave(&pfree_queue->lock, irql);
 
 	rtw_list_delete(&pxmitbuf->list);
 
@@ -1341,7 +1341,7 @@ _func_enter_;
 
 	/* DBG_88E("+rtw_alloc_xmitbuf\n"); */
 
-	_enter_critical(&pfree_xmitbuf_queue->lock, &irql);
+	spin_lock_irqsave(&pfree_xmitbuf_queue->lock, irql);
 
 	if (_rtw_queue_empty(pfree_xmitbuf_queue) == true) {
 		pxmitbuf = NULL;
@@ -1387,7 +1387,7 @@ _func_enter_;
 	if (pxmitbuf->ext_tag) {
 		rtw_free_xmitbuf_ext(pxmitpriv, pxmitbuf);
 	} else {
-		_enter_critical(&pfree_xmitbuf_queue->lock, &irql);
+		spin_lock_irqsave(&pfree_xmitbuf_queue->lock, irql);
 
 		rtw_list_delete(&pxmitbuf->list);
 
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index c39c226..8fd9387 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -76,22 +76,11 @@ static inline struct list_head *get_list_head(struct __queue *queue)
 #define LIST_CONTAINOR(ptr, type, member) \
 	((type *)((char *)(ptr)-(size_t)(&((type *)0)->member)))
 
-
-static inline void _enter_critical(spinlock_t *plock, unsigned long *pirqL)
-{
-	spin_lock_irqsave(plock, *pirqL);
-}
-
 static inline void _exit_critical(spinlock_t *plock, unsigned long *pirqL)
 {
 	spin_unlock_irqrestore(plock, *pirqL);
 }
 
-static inline void _enter_critical_ex(spinlock_t *plock, unsigned long *pirqL)
-{
-	spin_lock_irqsave(plock, *pirqL);
-}
-
 static inline void _exit_critical_ex(spinlock_t *plock, unsigned long *pirqL)
 {
 	spin_unlock_irqrestore(plock, *pirqL);
diff --git a/drivers/staging/rtl8188eu/os_dep/usb_ops_linux.c b/drivers/staging/rtl8188eu/os_dep/usb_ops_linux.c
index 4c71e3b..a621b80 100644
--- a/drivers/staging/rtl8188eu/os_dep/usb_ops_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/usb_ops_linux.c
@@ -186,7 +186,7 @@ _func_enter_;
 		goto exit;
 	}
 
-	_enter_critical(&pxmitpriv->lock, &irqL);
+	spin_lock_irqsave(&pxmitpriv->lock, irqL);
 
 	switch (addr) {
 	case VO_QUEUE_INX:
-- 
1.8.4
