From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/3] staging: r8712u: Check pointer before use
Date: Fri,  3 Jun 2016 20:17:35 -0500
Message-ID: <1465003057-2590-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1465003057-2590-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:35440 "EHLO
	mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838AbcFDBRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 21:17:54 -0400
Received: by mail-oi0-f67.google.com with SMTP id h125so20057320oib.2
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 18:17:54 -0700 (PDT)
In-Reply-To: <1465003057-2590-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Routine r8712_usb_read_port() dereferences "precvbuf" before testing it
for NULL.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8712/usb_ops_linux.c | 72 ++++++++++++++++-----------------
 1 file changed, 34 insertions(+), 38 deletions(-)

diff --git a/drivers/staging/rtl8712/usb_ops_linux.c b/drivers/staging/rtl8712/usb_ops_linux.c
index 6f12345..a79c35e 100644
--- a/drivers/staging/rtl8712/usb_ops_linux.c
+++ b/drivers/staging/rtl8712/usb_ops_linux.c
@@ -270,51 +270,47 @@ u32 r8712_usb_read_port(struct intf_hdl *pintfhdl, u32 addr, u32 cnt, u8 *rmem)
 	struct usb_device *pusbd = pdvobj->pusbdev;
 
 	if (adapter->bDriverStopped || adapter->bSurpriseRemoved ||
-	    adapter->pwrctrlpriv.pnp_bstop_trx)
+	    adapter->pwrctrlpriv.pnp_bstop_trx || !precvbuf)
 		return _FAIL;
 	if (precvbuf->reuse || !precvbuf->pskb) {
 		precvbuf->pskb = skb_dequeue(&precvpriv->free_recv_skb_queue);
 		if (precvbuf->pskb != NULL)
 			precvbuf->reuse = true;
 	}
-	if (precvbuf != NULL) {
-		r8712_init_recvbuf(adapter, precvbuf);
-		/* re-assign for linux based on skb */
-		if (!precvbuf->reuse || !precvbuf->pskb) {
-			precvbuf->pskb = netdev_alloc_skb(adapter->pnetdev,
-					 MAX_RECVBUF_SZ + RECVBUFF_ALIGN_SZ);
-			if (!precvbuf->pskb)
-				return _FAIL;
-			tmpaddr = (addr_t)precvbuf->pskb->data;
-			alignment = tmpaddr & (RECVBUFF_ALIGN_SZ - 1);
-			skb_reserve(precvbuf->pskb,
-				    (RECVBUFF_ALIGN_SZ - alignment));
-			precvbuf->phead = precvbuf->pskb->head;
-			precvbuf->pdata = precvbuf->pskb->data;
-			precvbuf->ptail = skb_tail_pointer(precvbuf->pskb);
-			precvbuf->pend = skb_end_pointer(precvbuf->pskb);
-			precvbuf->pbuf = precvbuf->pskb->data;
-		} else { /* reuse skb */
-			precvbuf->phead = precvbuf->pskb->head;
-			precvbuf->pdata = precvbuf->pskb->data;
-			precvbuf->ptail = skb_tail_pointer(precvbuf->pskb);
-			precvbuf->pend = skb_end_pointer(precvbuf->pskb);
-			precvbuf->pbuf = precvbuf->pskb->data;
-			precvbuf->reuse = false;
-		}
-		purb = precvbuf->purb;
-		/* translate DMA FIFO addr to pipehandle */
-		pipe = ffaddr2pipehdl(pdvobj, addr);
-		usb_fill_bulk_urb(purb, pusbd, pipe,
-				  precvbuf->pbuf, MAX_RECVBUF_SZ,
-				  r8712_usb_read_port_complete,
-				  precvbuf);
-		err = usb_submit_urb(purb, GFP_ATOMIC);
-		if ((err) && (err != (-EPERM)))
-			ret = _FAIL;
-	} else {
-		ret = _FAIL;
+	r8712_init_recvbuf(adapter, precvbuf);
+	/* re-assign for linux based on skb */
+	if (!precvbuf->reuse || !precvbuf->pskb) {
+		precvbuf->pskb = netdev_alloc_skb(adapter->pnetdev,
+				 MAX_RECVBUF_SZ + RECVBUFF_ALIGN_SZ);
+		if (!precvbuf->pskb)
+			return _FAIL;
+		tmpaddr = (addr_t)precvbuf->pskb->data;
+		alignment = tmpaddr & (RECVBUFF_ALIGN_SZ - 1);
+		skb_reserve(precvbuf->pskb,
+			    (RECVBUFF_ALIGN_SZ - alignment));
+		precvbuf->phead = precvbuf->pskb->head;
+		precvbuf->pdata = precvbuf->pskb->data;
+		precvbuf->ptail = skb_tail_pointer(precvbuf->pskb);
+		precvbuf->pend = skb_end_pointer(precvbuf->pskb);
+		precvbuf->pbuf = precvbuf->pskb->data;
+	} else { /* reuse skb */
+		precvbuf->phead = precvbuf->pskb->head;
+		precvbuf->pdata = precvbuf->pskb->data;
+		precvbuf->ptail = skb_tail_pointer(precvbuf->pskb);
+		precvbuf->pend = skb_end_pointer(precvbuf->pskb);
+		precvbuf->pbuf = precvbuf->pskb->data;
+		precvbuf->reuse = false;
 	}
+	purb = precvbuf->purb;
+	/* translate DMA FIFO addr to pipehandle */
+	pipe = ffaddr2pipehdl(pdvobj, addr);
+	usb_fill_bulk_urb(purb, pusbd, pipe,
+			  precvbuf->pbuf, MAX_RECVBUF_SZ,
+			  r8712_usb_read_port_complete,
+			  precvbuf);
+	err = usb_submit_urb(purb, GFP_ATOMIC);
+	if ((err) && (err != (-EPERM)))
+		ret = _FAIL;
 	return ret;
 }
 
-- 
2.1.4
