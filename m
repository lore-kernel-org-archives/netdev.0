From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net 2/2]  8139cp: reset BQL when ring tx ring cleared
Date: Mon, 14 Sep 2015 23:59:13 +0200
Message-ID: <20150914215913.GA24962@electric-eye.fr.zoreil.com>
References: <20130520095443.2d18b2cb@nehalam.linuxnetplumber.net>
 <20130520213728.GA28252@electric-eye.fr.zoreil.com>
 <20130520172749.2a4447b6@nehalam.linuxnetplumber.net>
 <1442232308.30875.6.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49267 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752565AbbINWAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2015 18:00:15 -0400
Content-Disposition: inline
In-Reply-To: <1442232308.30875.6.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse <dwmw2@infradead.org> :
[...]
> Did you ever work this out ?

Not specifically.

> I'm seeing something similar on the inward -facing interface on my ho=
me
> router under high load =E2=80=94 and it doesn't automatically recover=
=2E
[...]
> [308309.457239] Pid: 0, comm: swapper Not tainted 3.7.1 #1

It's unrelated but you may have already noticed=20
7fe0ee099ad5e3dea88d4ee1b6f20246b1ca57c3 ("net: 8139cp: fix a BUG_ON
triggered by wrong bytes_compl").

[...]
> [308309.574551] 8139cp 0000:00:0b.0 eth1: Transmit timeout, status  c=
   2b    0 80ff

Rx and Tx are enabled.

Instant (untested) hack below.

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethern=
et/realtek/8139cp.c
index d79e33b..09ee6fd 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -129,6 +129,9 @@ MODULE_PARM_DESC (multicast_filter_limit, "8139cp: =
maximum number of filtered mu
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT		(6*HZ)
=20
+/* TODO: calibrate. It ought to be related to the PCI bus frequency. *=
/
+#define CP_EARLY_TIMEOUT	(8 * 1024)
+
 /* hardware minimum and maximum for a single frame's data payload */
 #define CP_MIN_MTU		60	/* TODO: allow lower, but pad */
 #define CP_MAX_MTU		4096
@@ -146,9 +149,11 @@ enum {
 	TxConfig	=3D 0x40, /* Tx configuration */
 	ChipVersion	=3D 0x43, /* 8-bit chip version, inside TxConfig */
 	RxConfig	=3D 0x44, /* Rx configuration */
+	TimerCount	=3D 0x48, /* 32 bit general purpose timer. */
 	RxMissed	=3D 0x4C,	/* 24 bits valid, write clears */
 	Cfg9346		=3D 0x50, /* EEPROM select/control; Cfg reg [un]lock */
 	Config1		=3D 0x52, /* Config1 */
+	TimerInt	=3D 0x54, /* TimerCount IRQ triggering timeout value */
 	Config3		=3D 0x59, /* Config3 */
 	Config4		=3D 0x5A, /* Config4 */
 	MultiIntr	=3D 0x5C, /* Multiple interrupt select */
@@ -283,7 +288,8 @@ enum {
 	LANWake         =3D (1 << 1),  /* Enable LANWake signal */
 	PMEStatus	=3D (1 << 0),  /* PME status can be reset by PCI RST# */
=20
-	cp_norx_intr_mask =3D PciErr | LinkChg | TxOK | TxErr | TxEmpty,
+	cp_norx_intr_mask =3D PciErr | TimerIntr | LinkChg |
+			    TxOK | TxErr | TxEmpty,
 	cp_rx_intr_mask =3D RxOK | RxErr | RxEmpty | RxFIFOOvr,
 	cp_intr_mask =3D cp_rx_intr_mask | cp_norx_intr_mask,
 };
@@ -608,6 +614,15 @@ static irqreturn_t cp_interrupt (int irq, void *de=
v_instance)
=20
 	if (status & (TxOK | TxErr | TxEmpty | SWInt))
 		cp_tx(cp);
+
+	if ((status & TimerIntr) && (cp->tx_head !=3D cp->tx_tail)) {
+		if (net_ratelimit()) {
+			netdev_info(dev, "Timeout head=3D%08x, tail=3D%08x\n",
+				    cp->tx_head, cp->tx_tail);
+		}
+		cp_tx(cp);
+	}
+
 	if (status & LinkChg)
 		mii_check_media(&cp->mii_if, netif_msg_link(cp), false);
=20
@@ -885,6 +900,8 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *s=
kb,
 out_unlock:
 	spin_unlock_irqrestore(&cp->lock, intr_flags);
=20
+	cpw32(TimerCount, CP_EARLY_TIMEOUT);
+
 	cpw8(TxPoll, NormalTxPoll);
=20
 	return NETDEV_TX_OK;
@@ -1064,6 +1081,8 @@ static void cp_init_hw (struct cp_private *cp)
=20
 	cpw16(MultiIntr, 0);
=20
+	cpw32(TimerInt, CP_EARLY_TIMEOUT);
+
 	cpw8_f(Cfg9346, Cfg9346_Lock);
 }
=20
