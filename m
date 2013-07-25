From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH v1 1/1 net] net: fec: workaround stop tx during errata ERR006358
Date: Thu, 25 Jul 2013 14:05:53 +0800
Message-ID: <1374732353-6505-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Frank Li <Frank.Li@freescale.com>
To: <davem@davemloft.net>, <shawn.guo@linaro.org>,
	<netdev@vger.kernel.org>, <B38611@freescale.com>,
	<l.stach@pengutronix.de>, <r.schwebel@pengutronix.de>,
	<lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0252.outbound.messaging.microsoft.com ([213.199.154.252]:20366
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751745Ab3GYHzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 03:55:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the ready bit in the transmit buffer descriptor (TxBD[R])
is previously detected as not set during a prior frame transmission,
then the ENET_TDAR[TDAR] bit is cleared at a later time, even if
additional TxBDs were added to the ring and the ENET_TDAR[TDAR]
bit is set. This results in frames not being transmitted until
there is a 0-to-1 transition on ENET_TDAR[TDAR].

Workarounds:
code can use the transmit frame interrupt flag (ENET_EIR[TXF])
as a method to detect whether the ENET has completed transmission
and the ENET_TDAR[TDAR] has been cleared. If ENET_TDAR[TDAR] is
detected as cleared when packets are queued and waiting for transmit,
then a write to the TDAR bit will restart TxBD processing.

This case main happen when loading is light. A ethernet package may
not send out utile next package put into tx queue.

How to test:
while [ true ]
do
	ping <IP> -s 10000 -w 4
	ping <IP> -s 6000 -w 2
	ping <IP> -s 4000 -w 2
	ping <IP> -s 10000 -w 2
done

You will see below result in overnight test.

6008 bytes from 10.192.242.116: seq=1 ttl=128 time=0.722 ms
4008 bytes from 10.192.242.116: seq=0 ttl=128 time=1001.008 ms
4008 bytes from 10.192.242.116: seq=1 ttl=128 time=1.010 ms
10008 bytes from 10.192.242.116: seq=0 ttl=128 time=0.896 ms

After apply this patch, >1000ms delay disappear.

Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec.h      |    1 +
 drivers/net/ethernet/freescale/fec_main.c |   32 +++++++++++++++++++++++++++-
 2 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 2b0a0ea..ae23600 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -259,6 +259,7 @@ struct bufdesc_ex {
 struct fec_enet_delayed_work {
 	struct delayed_work delay_work;
 	bool timeout;
+	bool trig_tx;
 };
 
 /* The FEC buffer descriptors track the ring buffers.  The rx_bd_base and
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index d3ad5ea..dbc1881 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -93,6 +93,20 @@ static void set_multicast_list(struct net_device *ndev);
 #define FEC_QUIRK_HAS_CSUM		(1 << 5)
 /* Controller has hardware vlan support */
 #define FEC_QUIRK_HAS_VLAN		(1 << 6)
+/* ENET IP errata ERR006358
+ *
+ * If the ready bit in the transmit buffer descriptor (TxBD[R]) is previously
+ * detected as not set during a prior frame transmission, then the
+ * ENET_TDAR[TDAR] bit is cleared at a later time, even if additional TxBDs
+ * were added to the ring and the ENET_TDAR[TDAR] bit is set. This results in
+ * If the ready bit in the transmit buffer descriptor (TxBD[R]) is previously
+ * detected as not set during a prior frame transmission, then the
+ * ENET_TDAR[TDAR] bit is cleared at a later time, even if additional TxBDs
+ * were added to the ring and the ENET_TDAR[TDAR] bit is set. This results in
+ * frames not being transmitted until there is a 0-to-1 transition on
+ * ENET_TDAR[TDAR].
+ */
+#define FEC_QUIRK_ERR006358            (1 << 7)
 
 static struct platform_device_id fec_devtype[] = {
 	{
@@ -112,7 +126,7 @@ static struct platform_device_id fec_devtype[] = {
 		.name = "imx6q-fec",
 		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT |
 				FEC_QUIRK_HAS_BUFDESC_EX | FEC_QUIRK_HAS_CSUM |
-				FEC_QUIRK_HAS_VLAN,
+				FEC_QUIRK_HAS_VLAN | FEC_QUIRK_ERR006358,
 	}, {
 		.name = "mvf600-fec",
 		.driver_data = FEC_QUIRK_ENET_MAC,
@@ -275,7 +289,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	const struct platform_device_id *id_entry =
 				platform_get_device_id(fep->pdev);
-	struct bufdesc *bdp;
+	struct bufdesc *bdp, *bdp_pre;
 	void *bufaddr;
 	unsigned short	status;
 	unsigned int index;
@@ -370,6 +384,15 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 				ebdp->cbd_esc |= BD_ENET_TX_PINS;
 		}
 	}
+
+	bdp_pre = fec_enet_get_prevdesc(bdp, fep->bufdesc_ex);
+	if ((id_entry->driver_data & FEC_QUIRK_ERR006358) &&
+	    !(bdp_pre->cbd_sc & BD_ENET_TX_READY)) {
+		fep->delay_work.trig_tx = true;
+		schedule_delayed_work(&(fep->delay_work.delay_work),
+					msecs_to_jiffies(1));
+	}
+
 	/* If this was the last BD in the ring, start at the beginning again. */
 	if (status & BD_ENET_TX_WRAP)
 		bdp = fep->tx_bd_base;
@@ -689,6 +712,11 @@ static void fec_enet_work(struct work_struct *work)
 		fec_restart(fep->netdev, fep->full_duplex);
 		netif_wake_queue(fep->netdev);
 	}
+
+	if (fep->delay_work.trig_tx) {
+		fep->delay_work.trig_tx = false;
+		writel(0, fep->hwp + FEC_X_DES_ACTIVE);
+	}
 }
 
 static void
-- 
1.7.1
