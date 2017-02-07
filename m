From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH v2 net-next 6/9] sunvnet: straighten up message event handling logic
Date: Tue,  7 Feb 2017 14:12:59 -0800
Message-ID: <1486505582-76823-7-git-send-email-shannon.nelson@oracle.com>
References: <1486505582-76823-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
        Shannon Nelson <shannon.nelson@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486505582-76823-1-git-send-email-shannon.nelson@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The use of gotos for handling the incoming events made this code
harder to read and support than it should be.  This patch straightens
out and clears up the logic.

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet_common.c |   94 ++++++++++++++---------------
 1 files changed, 45 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
index 6cb625a..d2aed2c 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -764,41 +764,37 @@ static int vnet_event_napi(struct vnet_port *port, int budget)
 	struct vio_driver_state *vio = &port->vio;
 	int tx_wakeup, err;
 	int npkts = 0;
-	int event = (port->rx_event & LDC_EVENT_RESET);
-
-ldc_ctrl:
-	if (unlikely(event == LDC_EVENT_RESET ||
-		     event == LDC_EVENT_UP)) {
-		vio_link_state_change(vio, event);
-
-		if (event == LDC_EVENT_RESET) {
-			vnet_port_reset(port);
-			vio_port_up(vio);
-
-			/* If the device is running but its tx queue was
-			 * stopped (due to flow control), restart it.
-			 * This is necessary since vnet_port_reset()
-			 * clears the tx drings and thus we may never get
-			 * back a VIO_TYPE_DATA ACK packet - which is
-			 * the normal mechanism to restart the tx queue.
-			 */
-			if (netif_running(dev))
-				maybe_tx_wakeup(port);
-		}
+
+	/* we don't expect any other bits */
+	BUG_ON(port->rx_event & ~(LDC_EVENT_DATA_READY |
+				  LDC_EVENT_RESET |
+				  LDC_EVENT_UP));
+
+	/* RESET takes precedent over any other event */
+	if (port->rx_event & LDC_EVENT_RESET) {
+		vio_link_state_change(vio, LDC_EVENT_RESET);
+		vnet_port_reset(port);
+		vio_port_up(vio);
+
+		/* If the device is running but its tx queue was
+		 * stopped (due to flow control), restart it.
+		 * This is necessary since vnet_port_reset()
+		 * clears the tx drings and thus we may never get
+		 * back a VIO_TYPE_DATA ACK packet - which is
+		 * the normal mechanism to restart the tx queue.
+		 */
+		if (netif_running(dev))
+			maybe_tx_wakeup(port);
+
 		port->rx_event = 0;
 		return 0;
 	}
-	/* We may have multiple LDC events in rx_event. Unroll send_events() */
-	event = (port->rx_event & LDC_EVENT_UP);
-	port->rx_event &= ~(LDC_EVENT_RESET | LDC_EVENT_UP);
-	if (event == LDC_EVENT_UP)
-		goto ldc_ctrl;
-	event = port->rx_event;
-	if (!(event & LDC_EVENT_DATA_READY))
-		return 0;
 
-	/* we dont expect any other bits than RESET, UP, DATA_READY */
-	BUG_ON(event != LDC_EVENT_DATA_READY);
+	if (port->rx_event & LDC_EVENT_UP) {
+		vio_link_state_change(vio, LDC_EVENT_UP);
+		port->rx_event = 0;
+		return 0;
+	}
 
 	err = 0;
 	tx_wakeup = 0;
@@ -821,25 +817,25 @@ static int vnet_event_napi(struct vnet_port *port, int budget)
 			pkt->start_idx = vio_dring_next(dr,
 							port->napi_stop_idx);
 			pkt->end_idx = -1;
-			goto napi_resume;
-		}
-		err = ldc_read(vio->lp, &msgbuf, sizeof(msgbuf));
-		if (unlikely(err < 0)) {
-			if (err == -ECONNRESET)
-				vio_conn_reset(vio);
-			break;
+		} else {
+			err = ldc_read(vio->lp, &msgbuf, sizeof(msgbuf));
+			if (unlikely(err < 0)) {
+				if (err == -ECONNRESET)
+					vio_conn_reset(vio);
+				break;
+			}
+			if (err == 0)
+				break;
+			viodbg(DATA, "TAG [%02x:%02x:%04x:%08x]\n",
+			       msgbuf.tag.type,
+			       msgbuf.tag.stype,
+			       msgbuf.tag.stype_env,
+			       msgbuf.tag.sid);
+			err = vio_validate_sid(vio, &msgbuf.tag);
+			if (err < 0)
+				break;
 		}
-		if (err == 0)
-			break;
-		viodbg(DATA, "TAG [%02x:%02x:%04x:%08x]\n",
-		       msgbuf.tag.type,
-		       msgbuf.tag.stype,
-		       msgbuf.tag.stype_env,
-		       msgbuf.tag.sid);
-		err = vio_validate_sid(vio, &msgbuf.tag);
-		if (err < 0)
-			break;
-napi_resume:
+
 		if (likely(msgbuf.tag.type == VIO_TYPE_DATA)) {
 			if (msgbuf.tag.stype == VIO_SUBTYPE_INFO) {
 				if (!sunvnet_port_is_up_common(port)) {
-- 
1.7.1
