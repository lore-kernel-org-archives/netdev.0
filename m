From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net 2/2]  8139cp: reset BQL when ring tx ring cleared
Date: Fri, 18 Sep 2015 01:44:49 +0200
Message-ID: <20150917234449.GA25782@electric-eye.fr.zoreil.com>
References: <20130520095443.2d18b2cb@nehalam.linuxnetplumber.net>
 <20130520213728.GA28252@electric-eye.fr.zoreil.com>
 <20130520172749.2a4447b6@nehalam.linuxnetplumber.net>
 <1442232308.30875.6.camel@infradead.org>
 <20150914215913.GA24962@electric-eye.fr.zoreil.com>
 <1442489793.131189.142.camel@infradead.org>
 <1442502391.131189.160.camel@infradead.org>
 <20150917204449.GA22105@electric-eye.fr.zoreil.com>
 <1442528065.97487.6.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60330 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbbIQXqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 19:46:25 -0400
Content-Disposition: inline
In-Reply-To: <1442528065.97487.6.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse <dwmw2@infradead.org> :
[...]
> And of course, even if I fix the TX timeout handling, I'd still like to
> know why it's happening in the first place...

So do I.

The TxDmaOkLowDesc register may tell if the Tx dma part is still making
any progress. I have added a TxPoll request. See below.

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index d79e33b..963d2a2 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -129,6 +129,9 @@ MODULE_PARM_DESC (multicast_filter_limit, "8139cp: maximum number of filtered mu
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT		(6*HZ)
 
+/* TODO: calibrate. It ought to be related to the PCI bus frequency. */
+#define CP_EARLY_TIMEOUT	(16 * 1024)
+
 /* hardware minimum and maximum for a single frame's data payload */
 #define CP_MIN_MTU		60	/* TODO: allow lower, but pad */
 #define CP_MAX_MTU		4096
@@ -146,9 +149,11 @@ enum {
 	TxConfig	= 0x40, /* Tx configuration */
 	ChipVersion	= 0x43, /* 8-bit chip version, inside TxConfig */
 	RxConfig	= 0x44, /* Rx configuration */
+	TimerCount	= 0x48, /* 32 bit general purpose timer. */
 	RxMissed	= 0x4C,	/* 24 bits valid, write clears */
 	Cfg9346		= 0x50, /* EEPROM select/control; Cfg reg [un]lock */
 	Config1		= 0x52, /* Config1 */
+	TimerInt	= 0x54, /* TimerCount IRQ triggering timeout value */
 	Config3		= 0x59, /* Config3 */
 	Config4		= 0x5A, /* Config4 */
 	MultiIntr	= 0x5C, /* Multiple interrupt select */
@@ -157,6 +162,7 @@ enum {
 	NWayAdvert	= 0x66, /* MII ADVERTISE */
 	NWayLPAR	= 0x68, /* MII LPA */
 	NWayExpansion	= 0x6A, /* MII Expansion */
+	TxDmaOkLowDesc	= 0x82,	/* Low 16 bit address of a Tx descriptor. */
 	Config5		= 0xD8,	/* Config5 */
 	TxPoll		= 0xD9,	/* Tell chip to check Tx descriptors for work */
 	RxMaxSize	= 0xDA, /* Max size of an Rx packet (8169 only) */
@@ -283,7 +289,8 @@ enum {
 	LANWake         = (1 << 1),  /* Enable LANWake signal */
 	PMEStatus	= (1 << 0),  /* PME status can be reset by PCI RST# */
 
-	cp_norx_intr_mask = PciErr | LinkChg | TxOK | TxErr | TxEmpty,
+	cp_norx_intr_mask = PciErr | TimerIntr | LinkChg |
+			    TxOK | TxErr | TxEmpty,
 	cp_rx_intr_mask = RxOK | RxErr | RxEmpty | RxFIFOOvr,
 	cp_intr_mask = cp_rx_intr_mask | cp_norx_intr_mask,
 };
@@ -608,6 +615,18 @@ static irqreturn_t cp_interrupt (int irq, void *dev_instance)
 
 	if (status & (TxOK | TxErr | TxEmpty | SWInt))
 		cp_tx(cp);
+
+	if ((status & TimerIntr) && (cp->tx_head != cp->tx_tail)) {
+		if (net_ratelimit()) {
+			netdev_info(dev, "Timeout head=%08x, tail=%08x desc=%04x\n",
+				    cp->tx_head, cp->tx_tail,
+				    cpr16(TxDmaOkLowDesc));
+		}
+		cp_tx(cp);
+		if (cp->tx_head != cp->tx_tail)
+			cpw8_f(TxPoll, NormalTxPoll);
+	}
+
 	if (status & LinkChg)
 		mii_check_media(&cp->mii_if, netif_msg_link(cp), false);
 
@@ -885,6 +904,8 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 out_unlock:
 	spin_unlock_irqrestore(&cp->lock, intr_flags);
 
+	cpw32(TimerCount, CP_EARLY_TIMEOUT);
+
 	cpw8(TxPoll, NormalTxPoll);
 
 	return NETDEV_TX_OK;
@@ -1064,6 +1085,8 @@ static void cp_init_hw (struct cp_private *cp)
 
 	cpw16(MultiIntr, 0);
 
+	cpw32(TimerInt, CP_EARLY_TIMEOUT);
+
 	cpw8_f(Cfg9346, Cfg9346_Lock);
 }
 
