From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 2/3] staging: r8712u: Fix leak of skb
Date: Fri,  3 Jun 2016 20:17:36 -0500
Message-ID: <1465003057-2590-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1465003057-2590-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1465003057-2590-1-git-send-email-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

There are two types of messages queued for RX. The major type, which does
I/O on the device, was being handled properly. The skbs that communicated
with the firmware were being leaked.

While rewriting the code that sets up the skb, it was possible to remove
the private variable indicating that the old skb could be reused.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8712/recv_linux.c    |  1 -
 drivers/staging/rtl8712/rtl8712_recv.h  |  1 -
 drivers/staging/rtl8712/usb_ops_linux.c | 24 ++++++++----------------
 3 files changed, 8 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/rtl8712/recv_linux.c b/drivers/staging/rtl8712/recv_linux.c
index 735a0ea..576c15d 100644
--- a/drivers/staging/rtl8712/recv_linux.c
+++ b/drivers/staging/rtl8712/recv_linux.c
@@ -60,7 +60,6 @@ int r8712_os_recvbuf_resource_alloc(struct _adapter *padapter,
 	if (!precvbuf->purb)
 		res = _FAIL;
 	precvbuf->pskb = NULL;
-	precvbuf->reuse = false;
 	precvbuf->pallocated_buf = NULL;
 	precvbuf->pbuf = NULL;
 	precvbuf->pdata = NULL;
diff --git a/drivers/staging/rtl8712/rtl8712_recv.h b/drivers/staging/rtl8712/rtl8712_recv.h
index fd9e3fc..925ec74 100644
--- a/drivers/staging/rtl8712/rtl8712_recv.h
+++ b/drivers/staging/rtl8712/rtl8712_recv.h
@@ -103,7 +103,6 @@ struct recv_buf {
 	struct _adapter  *adapter;
 	struct urb *purb;
 	_pkt *pskb;
-	u8 reuse;
 	u8  irp_pending;
 	u32  transfer_len;
 	uint  len;
diff --git a/drivers/staging/rtl8712/usb_ops_linux.c b/drivers/staging/rtl8712/usb_ops_linux.c
index a79c35e..9a54c3b 100644
--- a/drivers/staging/rtl8712/usb_ops_linux.c
+++ b/drivers/staging/rtl8712/usb_ops_linux.c
@@ -202,26 +202,23 @@ static void r8712_usb_read_port_complete(struct urb *purb)
 	if (purb->status == 0) { /* SUCCESS */
 		if ((purb->actual_length > (MAX_RECVBUF_SZ)) ||
 		    (purb->actual_length < RXDESC_SIZE)) {
-			precvbuf->reuse = true;
 			r8712_read_port(padapter, precvpriv->ff_hwaddr, 0,
 				  (unsigned char *)precvbuf);
 		} else {
+			_pkt *pskb = precvbuf->pskb;
+
 			precvbuf->transfer_len = purb->actual_length;
 			pbuf = (uint *)precvbuf->pbuf;
 			isevt = le32_to_cpu(*(pbuf + 1)) & 0x1ff;
 			if ((isevt & 0x1ff) == 0x1ff) {
 				r8712_rxcmd_event_hdl(padapter, pbuf);
-				precvbuf->reuse = true;
+				skb_queue_tail(&precvpriv->rx_skb_queue, pskb);
 				r8712_read_port(padapter, precvpriv->ff_hwaddr,
 						0, (unsigned char *)precvbuf);
 			} else {
-				_pkt *pskb = precvbuf->pskb;
-
 				skb_put(pskb, purb->actual_length);
 				skb_queue_tail(&precvpriv->rx_skb_queue, pskb);
 				tasklet_hi_schedule(&precvpriv->recv_tasklet);
-				precvbuf->pskb = NULL;
-				precvbuf->reuse = false;
 				r8712_read_port(padapter, precvpriv->ff_hwaddr,
 						0, (unsigned char *)precvbuf);
 			}
@@ -241,7 +238,6 @@ static void r8712_usb_read_port_complete(struct urb *purb)
 			}
 			/* Fall through. */
 		case -EPROTO:
-			precvbuf->reuse = true;
 			r8712_read_port(padapter, precvpriv->ff_hwaddr, 0,
 				  (unsigned char *)precvbuf);
 			break;
@@ -272,14 +268,11 @@ u32 r8712_usb_read_port(struct intf_hdl *pintfhdl, u32 addr, u32 cnt, u8 *rmem)
 	if (adapter->bDriverStopped || adapter->bSurpriseRemoved ||
 	    adapter->pwrctrlpriv.pnp_bstop_trx || !precvbuf)
 		return _FAIL;
-	if (precvbuf->reuse || !precvbuf->pskb) {
-		precvbuf->pskb = skb_dequeue(&precvpriv->free_recv_skb_queue);
-		if (precvbuf->pskb != NULL)
-			precvbuf->reuse = true;
-	}
 	r8712_init_recvbuf(adapter, precvbuf);
-	/* re-assign for linux based on skb */
-	if (!precvbuf->reuse || !precvbuf->pskb) {
+	/* Try to use skb from the free queue */
+	precvbuf->pskb = skb_dequeue(&precvpriv->free_recv_skb_queue);
+
+	if (!precvbuf->pskb) {
 		precvbuf->pskb = netdev_alloc_skb(adapter->pnetdev,
 				 MAX_RECVBUF_SZ + RECVBUFF_ALIGN_SZ);
 		if (!precvbuf->pskb)
@@ -293,13 +286,12 @@ u32 r8712_usb_read_port(struct intf_hdl *pintfhdl, u32 addr, u32 cnt, u8 *rmem)
 		precvbuf->ptail = skb_tail_pointer(precvbuf->pskb);
 		precvbuf->pend = skb_end_pointer(precvbuf->pskb);
 		precvbuf->pbuf = precvbuf->pskb->data;
-	} else { /* reuse skb */
+	} else { /* skb is reused */
 		precvbuf->phead = precvbuf->pskb->head;
 		precvbuf->pdata = precvbuf->pskb->data;
 		precvbuf->ptail = skb_tail_pointer(precvbuf->pskb);
 		precvbuf->pend = skb_end_pointer(precvbuf->pskb);
 		precvbuf->pbuf = precvbuf->pskb->data;
-		precvbuf->reuse = false;
 	}
 	purb = precvbuf->purb;
 	/* translate DMA FIFO addr to pipehandle */
-- 
2.1.4
