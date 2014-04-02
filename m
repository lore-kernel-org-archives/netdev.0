From: "Nekludov, Max" <Max.Nekludov@elster.com>
Subject: RE: ks8851: reset on RX failure and TX timeout
Date: Wed, 2 Apr 2014 06:31:23 +0000
Message-ID: <e095559e0b69441eb44fecc7e8639a71@DB3PR02MB202.eurprd02.prod.outlook.com>
References: <9525F3D6E0E9E64DA832F2587811AD6A200C24@USRAL1WVEXC01.elt.lcl>
	<b703c70840da4780bc93beed79a8503b@DB3PR02MB202.eurprd02.prod.outlook.com>,<20140401.181355.1375673242692769955.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sboyd@codeaurora.org" <sboyd@codeaurora.org>,
	"mjr@cs.wisc.edu" <mjr@cs.wisc.edu>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"trivial@rustcorp.com.au" <trivial@rustcorp.com.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1lp0014.outbound.protection.outlook.com ([213.199.154.14]:15939
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756144AbaDBGb1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 02:31:27 -0400
In-Reply-To: <20140401.181355.1375673242692769955.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Electromagnetic noise can make device to not send TX interrupts.
As result outgoing queue will be suspended forever.
Also EMI can raise RX interrupt with zero value in KS_RXFC register.

Signed-off-by: Max Nekludov <Max.Nekludov@elster.com>
---
 drivers/net/ethernet/micrel/ks8851.c | 67 +++++++++++++++++++++++++++++++++++-
 1 file changed, 66 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index e0c92e0..4f0e5e7 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -123,6 +123,7 @@ struct ks8851_net {
 
 	struct work_struct	tx_work;
 	struct work_struct	rxctrl_work;
+	struct delayed_work	wdt_work;
 
 	struct sk_buff_head	txq;
 
@@ -140,6 +141,9 @@ static int msg_enable;
 /* shift for byte-enable data */
 #define BYTE_EN(_x)	((_x) << 2)
 
+#define KS8851_TX_QUEUE_SIZE 6144
+#define KS8851_TX_TIMEOUT_MS 100
+
 /* turn register number and byte-enable mask into data for start of packet */
 #define MK_OP(_byteen, _reg) (BYTE_EN(_byteen) | (_reg)  << (8+2) | (_reg) >> 6)
 
@@ -495,6 +499,7 @@ static void ks8851_dbg_dumpkkt(struct ks8851_net *ks, u8 *rxpkt)
 		   rxpkt[8], rxpkt[9], rxpkt[10], rxpkt[11],
 		   rxpkt[12], rxpkt[13], rxpkt[14], rxpkt[15]);
 }
+static void ks8851_reset(struct ks8851_net *ks);
 
 /**
  * ks8851_rx_pkts - receive packets from the host
@@ -517,6 +522,12 @@ static void ks8851_rx_pkts(struct ks8851_net *ks)
 
 	netif_dbg(ks, rx_status, ks->netdev,
 		  "%s: %d packets\n", __func__, rxfc);
+	
+	if (rxfc == 0) {
+		mdelay(1);
+		/* RX interrupt but no data in buffer. Which means hardware failure condition. Reset. */
+		ks8851_reset(ks);
+	}
 
 	/* Currently we're issuing a read per packet, but we could possibly
 	 * improve the code by issuing a single read, getting the receive
@@ -619,6 +630,10 @@ static irqreturn_t ks8851_irq(int irq, void *_ks)
 
 	if (status & IRQ_TXI) {
 		handled |= IRQ_TXI;
+		
+		mutex_unlock(&ks->lock);
+		cancel_delayed_work_sync(&ks->wdt_work);
+		mutex_lock(&ks->lock);
 
 		/* no lock here, tx queue should have been stopped */
 
@@ -749,6 +764,18 @@ static void ks8851_done_tx(struct ks8851_net *ks, struct sk_buff *txb)
 	dev_kfree_skb(txb);
 }
 
+static void ks8851_wdt_work(struct delayed_work *work)
+{
+	struct ks8851_net *ks = container_of(work, struct ks8851_net, wdt_work);
+
+	mutex_lock(&ks->lock);
+
+	mdelay(1);
+	ks8851_reset(ks);
+
+	mutex_unlock(&ks->lock);
+}
+
 /**
  * ks8851_tx_work - process tx packet(s)
  * @work: The work strucutre what was scheduled.
@@ -778,6 +805,8 @@ static void ks8851_tx_work(struct work_struct *work)
 		}
 	}
 
+	schedule_delayed_work(&ks->wdt_work, msecs_to_jiffies(KS8851_TX_TIMEOUT_MS));
+
 	mutex_unlock(&ks->lock);
 }
 
@@ -858,6 +887,40 @@ static int ks8851_net_open(struct net_device *dev)
 	return 0;
 }
 
+static void ks8851_reset(struct ks8851_net *ks)
+{
+	netif_stop_queue(ks->netdev);
+
+	/* turn off the IRQs and ack any outstanding */
+	ks8851_wrreg16(ks, KS_IER, 0x0000);
+	ks8851_wrreg16(ks, KS_ISR, 0xffff);
+
+	/* shutdown RX process */
+	ks8851_wrreg16(ks, KS_RXCR1, 0x0000);
+
+	/* shutdown TX process */
+	ks8851_wrreg16(ks, KS_TXCR, 0x0000);
+
+	ks->tx_space = KS8851_TX_QUEUE_SIZE;
+
+	mutex_unlock(&ks->lock);
+	
+	/* ensure any queued tx buffers are dumped */
+	while (!skb_queue_empty(&ks->txq)) {
+		struct sk_buff *txb = skb_dequeue(&ks->txq);
+
+		netif_dbg(ks, ifdown, ks->netdev,
+			  "%s: freeing txb %p\n", __func__, txb);
+
+		dev_kfree_skb(txb);
+	}
+
+	/* reopen device */
+	ks8851_net_open(ks->netdev);
+
+	mutex_lock(&ks->lock);
+}
+
 /**
  * ks8851_net_stop - close network device
  * @dev: The device being closed.
@@ -883,6 +946,7 @@ static int ks8851_net_stop(struct net_device *dev)
 	/* stop any outstanding work */
 	flush_work(&ks->tx_work);
 	flush_work(&ks->rxctrl_work);
+	cancel_delayed_work_sync(&ks->wdt_work);
 
 	mutex_lock(&ks->lock);
 	/* shutdown RX process */
@@ -1415,7 +1479,7 @@ static int ks8851_probe(struct spi_device *spi)
 
 	ks->netdev = ndev;
 	ks->spidev = spi;
-	ks->tx_space = 6144;
+	ks->tx_space = KS8851_TX_QUEUE_SIZE;
 
 	ks->vdd_reg = regulator_get_optional(&spi->dev, "vdd");
 	if (IS_ERR(ks->vdd_reg)) {
@@ -1437,6 +1501,7 @@ static int ks8851_probe(struct spi_device *spi)
 
 	INIT_WORK(&ks->tx_work, ks8851_tx_work);
 	INIT_WORK(&ks->rxctrl_work, ks8851_rxctrl_work);
+	INIT_DELAYED_WORK(&ks->wdt_work, ks8851_wdt_work);
 
 	/* initialise pre-made spi transfer messages */
 
-- 
1.8.3.2


________________________________________
From: David Miller <davem@davemloft.net>
Sent: Wednesday, April 2, 2014 2:13 AM
To: Nekludov, Max
Cc: torvalds@linux-foundation.org; netdev@vger.kernel.org; sboyd@codeaurora.org; mjr@cs.wisc.edu; jiri@resnulli.us; linux-kernel@vger.kernel.org; trivial@rustcorp.com.au
Subject: Re: Bug in ks8851.c

From: "Nekludov, Max" <Max.Nekludov@elster.com>
Date: Tue, 1 Apr 2014 15:41:58 +0000

> Reset on RX failure and TX timeout.
>
> Electromagnetic noice can make device to not send TX interrupts.
> As result outgoing queue will be suspended forever.
> Also EMI can raise RX interrupt with zero value in KS_RXFC register.
>
> Patch attached.

netdev@vger.kernel.org and the driver maintainer (as listed in
MAINTAINERS) is sufficient for submitting this patch, lists
such as 'trivial' and sending such patches to Linus directly
is not really appropriate.

As per your patch, please do not submit it as an attachment,
as per Documentation/SubmittingPatches, it should be the main
content with the commit message header line being in your
Subject.

Furthermore, in:

+static void ks8851_wdt_work(struct delayed_work *work)
+{
+       struct ks8851_net *ks = container_of(work, struct ks8851_net, wdt_work);
+       mutex_lock(&ks->lock);

You should have an empty line beteen local variable declarations
and where real code starts.
