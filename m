From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 05/11] staging: r8188eu: Remove wrappers around spin_unlock_irqrestore
Date: Thu, 19 Dec 2013 22:38:37 -0600
Message-ID: <1387514323-4486-6-git-send-email-Larry.Finger@lwfinger.net>
References: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:56099 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895Ab3LTEkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 23:40:40 -0500
Received: by mail-pb0-f46.google.com with SMTP id md12so2080165pbc.19
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 20:40:40 -0800 (PST)
In-Reply-To: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Again there are two - _exit_critical() and _exit_critical_ex().

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_cmd.c          |  4 ++--
 drivers/staging/rtl8188eu/core/rtw_recv.c         |  4 ++--
 drivers/staging/rtl8188eu/core/rtw_xmit.c         |  8 ++++----
 drivers/staging/rtl8188eu/include/osdep_service.h | 10 ----------
 drivers/staging/rtl8188eu/os_dep/usb_ops_linux.c  |  2 +-
 5 files changed, 9 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_cmd.c b/drivers/staging/rtl8188eu/core/rtw_cmd.c
index 4561ffe..d40ee08 100644
--- a/drivers/staging/rtl8188eu/core/rtw_cmd.c
+++ b/drivers/staging/rtl8188eu/core/rtw_cmd.c
@@ -157,7 +157,7 @@ _func_enter_;
 
 	rtw_list_insert_tail(&obj->list, &queue->queue);
 
-	_exit_critical(&queue->lock, &irqL);
+	spin_unlock_irqrestore(&queue->lock, irqL);
 
 exit:
 
@@ -181,7 +181,7 @@ _func_enter_;
 		rtw_list_delete(&obj->list);
 	}
 
-	_exit_critical(&queue->lock, &irqL);
+	spin_unlock_irqrestore(&queue->lock, irqL);
 
 _func_exit_;
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index bf8f6e5a..a1bd84c 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -331,7 +331,7 @@ int rtw_enqueue_recvbuf(struct recv_buf *precvbuf, struct __queue *queue)
 	rtw_list_delete(&precvbuf->list);
 
 	rtw_list_insert_tail(&precvbuf->list, get_list_head(queue));
-	_exit_critical_ex(&queue->lock, &irqL);
+	spin_unlock_irqrestore(&queue->lock, irqL);
 	return _SUCCESS;
 }
 
@@ -355,7 +355,7 @@ struct recv_buf *rtw_dequeue_recvbuf (struct __queue *queue)
 		rtw_list_delete(&precvbuf->list);
 	}
 
-	_exit_critical_ex(&queue->lock, &irqL);
+	spin_unlock_irqrestore(&queue->lock, irqL);
 
 	return precvbuf;
 }
diff --git a/drivers/staging/rtl8188eu/core/rtw_xmit.c b/drivers/staging/rtl8188eu/core/rtw_xmit.c
index e805a4b..bf01c30 100644
--- a/drivers/staging/rtl8188eu/core/rtw_xmit.c
+++ b/drivers/staging/rtl8188eu/core/rtw_xmit.c
@@ -1299,7 +1299,7 @@ _func_enter_;
 		}
 	}
 
-	_exit_critical(&pfree_queue->lock, &irql);
+	spin_unlock_irqrestore(&pfree_queue->lock, irql);
 
 _func_exit_;
 
@@ -1323,7 +1323,7 @@ _func_enter_;
 	rtw_list_insert_tail(&(pxmitbuf->list), get_list_head(pfree_queue));
 	pxmitpriv->free_xmit_extbuf_cnt++;
 
-	_exit_critical(&pfree_queue->lock, &irql);
+	spin_unlock_irqrestore(&pfree_queue->lock, irql);
 
 _func_exit_;
 
@@ -1363,7 +1363,7 @@ _func_enter_;
 			rtw_sctx_done_err(&pxmitbuf->sctx, RTW_SCTX_DONE_BUF_ALLOC);
 		}
 	}
-	_exit_critical(&pfree_xmitbuf_queue->lock, &irql);
+	spin_unlock_irqrestore(&pfree_xmitbuf_queue->lock, irql);
 
 _func_exit_;
 
@@ -1394,7 +1394,7 @@ _func_enter_;
 		rtw_list_insert_tail(&(pxmitbuf->list), get_list_head(pfree_xmitbuf_queue));
 
 		pxmitpriv->free_xmitbuf_cnt++;
-		_exit_critical(&pfree_xmitbuf_queue->lock, &irql);
+		spin_unlock_irqrestore(&pfree_xmitbuf_queue->lock, irql);
 	}
 
 _func_exit_;
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index 8fd9387..a42c554 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -76,16 +76,6 @@ static inline struct list_head *get_list_head(struct __queue *queue)
 #define LIST_CONTAINOR(ptr, type, member) \
 	((type *)((char *)(ptr)-(size_t)(&((type *)0)->member)))
 
-static inline void _exit_critical(spinlock_t *plock, unsigned long *pirqL)
-{
-	spin_unlock_irqrestore(plock, *pirqL);
-}
-
-static inline void _exit_critical_ex(spinlock_t *plock, unsigned long *pirqL)
-{
-	spin_unlock_irqrestore(plock, *pirqL);
-}
-
 static inline int _enter_critical_mutex(struct mutex *pmutex,
 					unsigned long *pirqL)
 {
diff --git a/drivers/staging/rtl8188eu/os_dep/usb_ops_linux.c b/drivers/staging/rtl8188eu/os_dep/usb_ops_linux.c
index a621b80..93fc5ee 100644
--- a/drivers/staging/rtl8188eu/os_dep/usb_ops_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/usb_ops_linux.c
@@ -213,7 +213,7 @@ _func_enter_;
 		break;
 	}
 
-	_exit_critical(&pxmitpriv->lock, &irqL);
+	spin_unlock_irqrestore(&pxmitpriv->lock, irqL);
 
 	purb	= pxmitbuf->pxmit_urb[0];
 
-- 
1.8.4
