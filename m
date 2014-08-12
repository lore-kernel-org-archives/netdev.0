From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 2/3] sunvnet: Do not spin in an infinite loop when
 vio_ldc_send() returns EAGAIN
Date: Tue, 12 Aug 2014 10:33:10 -0400
Message-ID: <20140812143310.GI2404@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com, davem@davemloft.net,
	raghuram.kothakota@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25160 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753096AbaHLOdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 10:33:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


ldc_rx -> vnet_rx -> .. -> vnet_walk_rx->vnet_send_ack should not
spin into an infinite loop waiting  EAGAIN to lift.

The sender could have sent us a burst, and gone to lunch without
doing any more ldc_read()'s. That should not cause the receiver to
loop infinitely till soft-lockup kicks in.

Similarly __vnet_tx_trigger should only loop on EAGAIN a finite
number of times. The caller (vnet_start_xmit()) already has code
to reset the dring state and bail on errors from __vnet_tx_trigger

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Acked-by: Raghuram Kothakota <raghuram.kothakota@oracle.com>

---
 drivers/net/ethernet/sun/sunvnet.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index b489dd0..39c39bf 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -32,6 +32,11 @@ MODULE_DESCRIPTION("Sun LDOM virtual network driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
 
+/* Heuristic for the number of times to exponentially backoff and
+ * retry sending an LDC trigger when EAGAIN is encountered
+ */
+#define	VNET_MAX_RETRIES	10
+
 /* Ordered from largest major to lowest */
 static struct vio_version vnet_versions[] = {
 	{ .major = 1, .minor = 0 },
@@ -260,6 +265,7 @@ static int vnet_send_ack(struct vnet_port *port, struct vio_dring_state *dr,
 		.state			= vio_dring_state,
 	};
 	int err, delay;
+	int retries = 0;
 
 	hdr.seq = dr->snd_nxt;
 	delay = 1;
@@ -272,6 +278,13 @@ static int vnet_send_ack(struct vnet_port *port, struct vio_dring_state *dr,
 		udelay(delay);
 		if ((delay <<= 1) > 128)
 			delay = 128;
+		if (retries++ > VNET_MAX_RETRIES) {
+			pr_info("ECONNRESET %x:%x:%x:%x:%x:%x\n",
+				port->raddr[0], port->raddr[1],
+				port->raddr[2], port->raddr[3],
+				port->raddr[4], port->raddr[5]);
+			err = -ECONNRESET;
+		}
 	} while (err == -EAGAIN);
 
 	return err;
@@ -593,6 +607,7 @@ static int __vnet_tx_trigger(struct vnet_port *port)
 		.end_idx		= (u32) -1,
 	};
 	int err, delay;
+	int retries = 0;
 
 	hdr.seq = dr->snd_nxt;
 	delay = 1;
@@ -605,6 +620,8 @@ static int __vnet_tx_trigger(struct vnet_port *port)
 		udelay(delay);
 		if ((delay <<= 1) > 128)
 			delay = 128;
+		if (retries++ > VNET_MAX_RETRIES)
+			break;
 	} while (err == -EAGAIN);
 
 	return err;
-- 
1.8.4.2
