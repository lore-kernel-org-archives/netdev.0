From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH net 2/2]  8139cp: reset BQL when ring tx ring cleared
Date: Fri, 18 Sep 2015 23:42:09 +0100
Message-ID: <1442616129.97487.78.camel@infradead.org>
References: <20130520095443.2d18b2cb@nehalam.linuxnetplumber.net>
	 <20130520213728.GA28252@electric-eye.fr.zoreil.com>
	 <20130520172749.2a4447b6@nehalam.linuxnetplumber.net>
	 <1442232308.30875.6.camel@infradead.org>
	 <20150914215913.GA24962@electric-eye.fr.zoreil.com>
	 <1442489793.131189.142.camel@infradead.org>
	 <1442502391.131189.160.camel@infradead.org>
	 <20150917204449.GA22105@electric-eye.fr.zoreil.com>
	 <1442528065.97487.6.camel@infradead.org>
	 <20150917234449.GA25782@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha-1"; protocol="application/x-pkcs7-signature";
	boundary="=-lthvq/g+3psanALD+W8A"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48117 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754643AbbIRWmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 18:42:14 -0400
In-Reply-To: <20150917234449.GA25782@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-lthvq/g+3psanALD+W8A
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-09-18 at 01:44 +0200, Francois Romieu wrote:
> The TxDmaOkLowDesc register may tell if the Tx dma part is still=20
> making any progress. I have added a TxPoll request. See below.

It isn't making any progress. And TxPoll doesn't help. The only thing
I've found that restarts it is to clear and then set the TxOn bit in
the Cmd register, which resets the entire ring.

I briefly wondered if it was triggered by our constantly banging on the
TxPoll register even when the ring is already running, so I put in an
optimisation to avoid that except in the case where we've had a TxEmpty
(0x80) interrupt. That doesn't help either.

When the problem happens, we've put a new descriptor into the ring and
written to TxPoll to start the processing. We get a TxEmpty interrupt
*without* TxDone, while the descriptor is still marked as being owned
by the hardware.

At other times we do get a TxEmpty without TxDone, but usually the
TxDone happens shortly thereafter. In the problematic case, the TxDone
never happens =E2=80=94 and the offending descriptor is never given back.

(Note that I also fixed the off-by-one in the 'tx queued' debugging
message)

[35322.861870] 8139cp 0000:00:0b.0 eth1: tx queued, slot 13, skblen 1294
[35322.861870] 8139cp 0000:00:0b.0 eth1: tx kicking tx_poll, head 14 tail 1=
3 desc 54c0 poll 00
[35322.861870] 8139cp 0000:00:0b.0 eth1: intr, status 0484 cmd 0c cpcmd 002=
b
[35322.861870] 8139cp 0000:00:0b.0 eth1: tx done, slot 13, status 0x30003a6=
e dec 54d0
[35322.861870] 8139cp 0000:00:0b.0 eth1: irq not kicking tx_poll, head 14 t=
ail 14 desc 54d0 poll 00
[35322.875014] 8139cp 0000:00:0b.0 eth1: intr, status 0001 cmd 0c cpcmd 002=
b
[35322.913285] 8139cp 0000:00:0b.0 eth1: intr, status 0001 cmd 0c cpcmd 002=
b
[35322.917250] 8139cp 0000:00:0b.0 eth1: intr, status 0001 cmd 0c cpcmd 002=
b
[35322.943075] 8139cp 0000:00:0b.0 eth1: tx queued, slot 14, skblen 70
[35322.943103] 8139cp 0000:00:0b.0 eth1: tx kicking tx_poll, head 15 tail 1=
4 desc 54d0 poll 00
[35322.943138] 8139cp 0000:00:0b.0 eth1: intr, status 0484 cmd 0c cpcmd 002=
b
[35322.943164] 8139cp 0000:00:0b.0 eth1: tx done, slot 14, status 0x3000800=
1 dec 54e0
[35322.943190] 8139cp 0000:00:0b.0 eth1: irq not kicking tx_poll, head 15 t=
ail 15 desc 54e0 poll 00
[35322.947071] 8139cp 0000:00:0b.0 eth1: intr, status 0001 cmd 0c cpcmd 002=
b
[35322.959487] 8139cp 0000:00:0b.0 eth1: intr, status 0001 cmd 0c cpcmd 002=
b
[35323.001723] 8139cp 0000:00:0b.0 eth1: intr, status 0001 cmd 0c cpcmd 002=
b
[35323.041541] 8139cp 0000:00:0b.0 eth1: intr, status 0001 cmd 0c cpcmd 002=
b
[35323.041541] 8139cp 0000:00:0b.0 eth1: intr, status 0001 cmd 0c cpcmd 002=
b
[35323.052386] 8139cp 0000:00:0b.0 eth1: intr, status 0001 cmd 0c cpcmd 002=
b
[35323.113828] 8139cp 0000:00:0b.0 eth1: intr, status 0001 cmd 0c cpcmd 002=
b
[35323.114824] 8139cp 0000:00:0b.0 eth1: tx queued, slot 15, skblen 1294
[35323.114851] 8139cp 0000:00:0b.0 eth1: tx kicking tx_poll, head 16 tail 1=
5 desc 54e0 poll 00
[35323.114887] 8139cp 0000:00:0b.0 eth1: intr, status 0080 cmd 0c cpcmd 002=
b
[35323.114921] 8139cp 0000:00:0b.0 eth1: Invalid TxEmpty, should have seen =
15 at ddea54f0 status  c   2b    0 80ff desc 54e0 poll 00
[35323.124559] 8139cp 0000:00:0b.0 eth1: irq kicking tx_poll, head 16 tail =
15 desc 54e0 poll 00
[35323.126775] 8139cp 0000:00:0b.0 eth1: tx queued, slot 16, skblen 1294
[35323.126803] 8139cp 0000:00:0b.0 eth1: tx not kicking tx_poll, head 17 ta=
il 15 desc 54e0 poll 00
[35323.127154] 8139cp 0000:00:0b.0 eth1: tx queued, slot 17, skblen 1294
[35323.127181] 8139cp 0000:00:0b.0 eth1: tx not kicking tx_poll, head 18 ta=
il 15 desc 54e0 poll 00
[35323.127776] 8139cp 0000:00:0b.0 eth1: tx queued, slot 18, skblen 1294
[35323.127802] 8139cp 0000:00:0b.0 eth1: tx not kicking tx_poll, head 19 ta=
il 15 desc 54e0 poll 00
[35323.147218] 8139cp 0000:00:0b.0 eth1: intr, status 0001 cmd 0c cpcmd 002=
b
[35323.247288] 8139cp 0000:00:0b.0 eth1: intr, status 0001 cmd 0c cpcmd 002=
b
[35323.314456] 8139cp 0000:00:0b.0 eth1: intr, status 0001 cmd 0c cpcmd 002=
b
...
[35331.995477] 8139cp 0000:00:0b.0 eth1: intr, status 0001 cmd 0c cpcmd 002=
b
[35332.024428] 8139cp 0000:00:0b.0 eth1: Transmit timeout, status  c   2b  =
  0 80ff desc 54e0 poll 00
[35332.033424] TX ring 00 @ddea5400:   (null) 1ddd65ac 30006362 0 (b000050e=
 0)
[35332.040399] TX ring 01 @ddea5410:   (null) 1ddd5cdc 30006362 0 (b000050e=
 0)
[35332.043399] TX ring 02 @ddea5420:   (null) 1ed9165c 30006362 0 (b000050e=
 0)
[35332.043399] TX ring 03 @ddea5430:   (null) 1ddd540c 30006362 0 (b000050e=
 0)
[35332.043399] TX ring 04 @ddea5440:   (null) 1ddd4b3c 30006362 0 (b000050e=
 0)
[35332.043399] TX ring 05 @ddea5450:   (null) 1ddd426c 30006362 0 (b000050e=
 0)
[35332.043399] TX ring 06 @ddea5460:   (null) 1ddd399c 30006362 0 (b000050e=
 0)
[35332.043399] TX ring 07 @ddea5470:   (null) 1ddd27fc 30006362 0 (b000050e=
 0)
[35332.043399] TX ring 08 @ddea5480:   (null) 1ddd1f2c 30006362 0 (b000050e=
 0)
[35332.043399] TX ring 09 @ddea5490:   (null) 1ddd165c 30006362 0 (b000050e=
 0)
[35332.043399] TX ring 10 @ddea54a0:   (null) 1ddd0d8c 30006362 0 (b0000046=
 0)
[35332.043399] TX ring 11 @ddea54b0:   (null) 1ddd30cc 3000a7a6 0 (b00000ad=
 0)
[35332.043399] TX ring 12 @ddea54c0:   (null) 1de22002 30005b5a 0 (b000006a=
 0)
[35332.043399] TX ring 13 @ddea54d0:   (null) 1ed9774c 30003a6e 0 (b000050e=
 0)
[35332.043399] TX ring 14 @ddea54e0:   (null) 1ed96e7c 30008001 0 (b0000046=
 0)
[35332.043399] TX ring 15 @ddea54f0: c0014780 1ed965ac b000050e 0 (b000050e=
 0)
[35332.043399] TX ring 16 @ddea5500: dddbfa80 1ed95cdc b000050e 0 (b000050e=
 0)
[35332.043399] TX ring 17 @ddea5510: ddd59180 1ed9426c b000050e 0 (b000050e=
 0)
[35332.043399] TX ring 18 @ddea5520: ddca66c0 1ed94b3c b000050e 0 (b000050e=
 0)
[35332.043399] TX ring 19 @ddea5530:   (null) 1ddd04bc 3000d3d2 0 (b000050e=
 0)
[35332.043399] TX ring 20 @ddea5540:   (null) 1ddd165c 3000d3d2 0 (b000050e=
 0)
[35332.043399] TX ring 21 @ddea5550:   (null) 1ed9774c 3000d3d2 0 (b0000056=
 0)
[35332.043399] TX ring 22 @ddea5560:   (null) 1ed965ac 3000d3d2 0 (b000050e=
 0)
[35332.043399] TX ring 23 @ddea5570:   (null) 1ed95cdc 3000d3d2 0 (b000050e=
 0)
[35332.043399] TX ring 24 @ddea5580:   (null) 1ed96e7c 3000d3d2 0 (b000050e=
 0)
[35332.043399] TX ring 25 @ddea5590:   (null) 1ed9540c 3000d3d2 0 (b000050e=
 0)
[35332.043399] TX ring 26 @ddea55a0:   (null) 1ed9426c 3000d3d2 0 (b000050e=
 0)
[35332.043399] TX ring 27 @ddea55b0:   (null) 1ed9399c 3000d3d2 0 (b000050e=
 0)
[35332.043399] TX ring 28 @ddea55c0:   (null) 1ed930cc 3000d3d2 0 (b000050e=
 0)
[35332.043399] TX ring 29 @ddea55d0:   (null) 1ed927fc 3000d3d2 0 (b000050e=
 0)
[35332.043399] TX ring 30 @ddea55e0:   (null) 1ed94b3c 3000d3d2 0 (b000050e=
 0)
[35332.043399] TX ring 31 @ddea55f0:   (null) 1ed91f2c 3000d3d2 0 (b000050e=
 0)
[35332.043399] TX ring 32 @ddea5600:   (null) 1ed90d8c 3000d3d2 0 (b000050e=
 0)
[35332.043399] TX ring 33 @ddea5610:   (null) 1ed904bc 3000d3d2 0 (b000050e=
 0)
[35332.043399] TX ring 34 @ddea5620:   (null) 1ed9165c 3000d3d2 0 (b000050e=
 0)
[35332.043399] TX ring 35 @ddea5630:   (null) 1ddd774c 30001716 0 (b000050e=
 0)
[35332.043399] TX ring 36 @ddea5640:   (null) 1ddd65ac 30001716 0 (b000050e=
 0)
[35332.043399] TX ring 37 @ddea5650:   (null) 1ddd6e7c 30001716 0 (b000050e=
 0)
[35332.043399] TX ring 38 @ddea5660:   (null) 1ddd5cdc 30001716 0 (b000050e=
 0)
[35332.043399] TX ring 39 @ddea5670:   (null) 1ddd540c 3000a7a6 0 (b000050e=
 0)
[35332.043399] TX ring 40 @ddea5680:   (null) 1ddd4b3c 3000a7a6 0 (b000050e=
 0)
[35332.043399] TX ring 41 @ddea5690:   (null) 1ddd399c 3000a7a6 0 (b000050e=
 0)
[35332.043399] TX ring 42 @ddea56a0:   (null) 1ddd426c 3000a7a6 0 (b000050e=
 0)
[35332.043399] TX ring 43 @ddea56b0:   (null) 1ddd27fc 3000a7a6 0 (b000050e=
 0)
[35332.043399] TX ring 44 @ddea56c0:   (null) 1ddd30cc 3000a7a6 0 (b000050e=
 0)
[35332.043399] TX ring 45 @ddea56d0:   (null) 1ddd1f2c 3000a7a6 0 (b000050e=
 0)
[35332.043399] TX ring 46 @ddea56e0:   (null) 1ddd165c 3000a7a6 0 (b000050e=
 0)
[35332.043399] TX ring 47 @ddea56f0:   (null) 1ddd0d8c 3000a7a6 0 (b000050e=
 0)
[35332.043399] TX ring 48 @ddea5700:   (null) 1ddd04bc 3000a7a6 0 (b000050e=
 0)
[35332.043399] TX ring 49 @ddea5710:   (null) 1ed96e7c 3000a7a6 0 (b000050e=
 0)
[35332.043399] TX ring 50 @ddea5720:   (null) 1ed9774c 3000a7a6 0 (b000050e=
 0)
[35332.043399] TX ring 51 @ddea5730:   (null) 1ed965ac 3000a7a6 0 (b000050e=
 0)
[35332.043399] TX ring 52 @ddea5740:   (null) 1ed9540c 3000a7a6 0 (b000050e=
 0)
[35332.043399] TX ring 53 @ddea5750:   (null) 1ed95cdc 3000a7a6 0 (b000050e=
 0)
[35332.043399] TX ring 54 @ddea5760:   (null) 1ed94b3c 3000a7a6 0 (b000050e=
 0)
[35332.043399] TX ring 55 @ddea5770:   (null) 1ed9426c 3000a7a6 0 (b000050e=
 0)
[35332.043399] TX ring 56 @ddea5780:   (null) 1ed9399c 3000a7a6 0 (b000050e=
 0)
[35332.043399] TX ring 57 @ddea5790:   (null) 1ed930cc 30006362 0 (b000050e=
 0)
[35332.043399] TX ring 58 @ddea57a0:   (null) 1ed91f2c 30006362 0 (b000050e=
 0)
[35332.043399] TX ring 59 @ddea57b0:   (null) 1ed927fc 30006362 0 (b000050e=
 0)
[35332.043399] TX ring 60 @ddea57c0:   (null) 1ed90d8c 30006362 0 (b000050e=
 0)
[35332.043399] TX ring 61 @ddea57d0:   (null) 1ed904bc 30006362 0 (b000050e=
 0)
[35332.043399] TX ring 62 @ddea57e0:   (null) 1ddd774c 30006362 0 (b000050e=
 0)
[35332.043399] TX ring 63 @ddea57f0:   (null) 1ddd6e7c 70006362 0 (f000050e=
 0)

At this point I'm mostly out of ideas. My 'Invalid TxEmpty' check does
reliably trigger when the problem is happening, but it has false
positives. Perhaps we could set the TimerIntr when that happens, and
then reset the TX ring if the TxDone doesn't come within a certain
amount of time. Although on a half-duplex link or with flow control
it's not clear what the upper bound of that time would be.

At least with the patches I've sent so far, it does manage to recover
when the timeout happens.

This is what I'm testing, for reference:

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/r=
ealtek/8139cp.c
index d12fc50..4440459 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -45,7 +45,7 @@
 	  default, use ethtool to turn it on.
=20
  */
-
+#define DEBUG
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
=20
 #define DRV_NAME		"8139cp"
@@ -157,6 +157,7 @@ enum {
 	NWayAdvert	=3D 0x66, /* MII ADVERTISE */
 	NWayLPAR	=3D 0x68, /* MII LPA */
 	NWayExpansion	=3D 0x6A, /* MII Expansion */
+	TxDmaOkLowDesc  =3D 0x82, /* Low 16 bit address of a Tx descriptor. */
 	Config5		=3D 0xD8,	/* Config5 */
 	TxPoll		=3D 0xD9,	/* Tell chip to check Tx descriptors for work */
 	RxMaxSize	=3D 0xDA, /* Max size of an Rx packet (8169 only) */
@@ -341,10 +342,11 @@ struct cp_private {
 	unsigned		tx_tail;
 	struct cp_desc		*tx_ring;
 	struct sk_buff		*tx_skb[CP_TX_RING_SIZE];
-
+	struct cp_desc tx_ring_shadow[CP_TX_RING_SIZE];
 	unsigned		rx_buf_sz;
 	unsigned		wol_enabled : 1; /* Is Wake-on-LAN enabled? */
-
+	unsigned                tx_ring_running : 1;
+	int                     tx_ring_seen;
 	dma_addr_t		ring_dma;
=20
 	struct mii_if_info	mii_if;
@@ -504,8 +506,8 @@ rx_status_loop:
 			goto rx_next;
 		}
=20
-		netif_dbg(cp, rx_status, dev, "rx slot %d status 0x%x len %d\n",
-			  rx_tail, status, len);
+		netif_dbg(cp, rx_status, dev, "rx (%d) slot %d status 0x%x len %d\n",
+			  rx, rx_tail, status, len);
=20
 		new_skb =3D napi_alloc_skb(napi, buflen);
 		if (!new_skb) {
@@ -554,6 +556,7 @@ rx_next:
 	/* if we did not reach work limit, then we're done with
 	 * this round of polling
 	 */
+	netif_dbg(cp, rx_status, dev, "rx %d of %d\n", rx, budget);
 	if (rx < budget) {
 		unsigned long flags;
=20
@@ -566,6 +569,7 @@ rx_next:
 		cpw16_f(IntrMask, cp_intr_mask);
 		spin_unlock_irqrestore(&cp->lock, flags);
 	}
+	netif_dbg(cp, rx_status, dev, "rx done %d of %d\n", rx, budget);
=20
 	return rx;
 }
@@ -606,9 +610,38 @@ static irqreturn_t cp_interrupt (int irq, void *dev_in=
stance)
 			__napi_schedule(&cp->napi);
 		}
 	}
+
 	if (status & (TxOK | TxErr | TxEmpty | SWInt))
 		handled |=3D cp_tx(cp);
=20
+	if (status & TxEmpty) {
+		handled =3D 1;
+		if (cp->tx_head =3D=3D cp->tx_tail) {
+			/* Out of descriptors and we have nothing more for it.
+			   Let it stop. */
+			cp->tx_ring_running =3D 0;
+			netif_dbg(cp, tx_queued, cp->dev, "irq not kicking tx_poll, head %d tai=
l %d desc %04x poll %02x", cp->tx_head, cp->tx_tail, cpr16(TxDmaOkLowDesc),=
 cpr8(TxPoll));
+			cp->tx_head =3D cp->tx_tail =3D 0;
+		} else {
+			if (cp->tx_ring_seen >=3D 0) {
+				/* We *know* that tx_ring_seen was in the queue when
+				   we prodded it to start, and yet it's claiming that
+				   it's out of descriptors already! */
+				netdev_warn(dev, "Invalid TxEmpty, should have seen %d at %p status %2=
x %4x %4x %4x desc %4x poll %02x\n",
+					    cp->tx_ring_seen, &cp->tx_ring[cp->tx_ring_seen],
+					    cpr8(Cmd), cpr16(CpCmd),
+					    cpr16(IntrStatus), cpr16(IntrMask), cpr16(TxDmaOkLowDesc), cpr8(T=
xPoll));
+			}
+			/* The hardware raced with us adding a new descriptor, and
+			   we didn't get the IRQ in time so we didn't prod it.
+			   Prod it now to restart */
+			cp->tx_ring_running =3D 1;
+			cp->tx_ring_seen =3D cp->tx_head ? cp->tx_head - 1 : (CP_TX_RING_SIZE -=
 1);;
+			netif_dbg(cp, tx_queued, cp->dev, "irq kicking tx_poll, head %d tail %d=
 desc %04x poll %02x", cp->tx_head, cp->tx_tail, cpr16(TxDmaOkLowDesc), cpr=
8(TxPoll));
+			cpw8(TxPoll, NormalTxPoll);
+		}
+	}
+
 	if (status & LinkChg) {
 		handled =3D 1;
 		mii_check_media(&cp->mii_if, netif_msg_link(cp), false);
@@ -665,6 +698,11 @@ static int cp_tx (struct cp_private *cp)
 		if (status & DescOwn)
 			break;
=20
+		/* If it's processed the last descriptor we *knew*
+		 * was in place when we last started it, note that. */
+		if (tx_tail =3D=3D cp->tx_ring_seen)
+			cp->tx_ring_seen =3D -1;
+
 		handled =3D 1;
 		skb =3D cp->tx_skb[tx_tail];
 		BUG_ON(!skb);
@@ -692,12 +730,12 @@ static int cp_tx (struct cp_private *cp)
 				cp->dev->stats.tx_packets++;
 				cp->dev->stats.tx_bytes +=3D skb->len;
 				netif_dbg(cp, tx_done, cp->dev,
-					  "tx done, slot %d\n", tx_tail);
+					  "tx done, slot %d, status 0x%x dec %04x\n", tx_tail, status, cpr16(=
TxDmaOkLowDesc));
 			}
 			bytes_compl +=3D skb->len;
 			pkts_compl++;
 			dev_kfree_skb_irq(skb);
-		}
+		} else netif_dbg(cp, tx_done, cp->dev, "tx partial done, stlot %d, statu=
s 0x%x", tx_tail, status);
=20
 		cp->tx_skb[tx_tail] =3D NULL;
=20
@@ -773,6 +811,7 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
=20
 		txd->opts2 =3D opts2;
 		txd->addr =3D cpu_to_le64(mapping);
+	=09
 		wmb();
=20
 		flags =3D eor | len | DescOwn | FirstFrag | LastFrag;
@@ -790,13 +829,16 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb=
,
 		}
=20
 		txd->opts1 =3D cpu_to_le32(flags);
+		cp->tx_ring_shadow[entry].opts2 =3D opts2;
+		cp->tx_ring_shadow[entry].addr =3D cpu_to_le64(mapping);
+		cp->tx_ring_shadow[entry].opts1 =3D cpu_to_le32(flags);
 		wmb();
=20
 		cp->tx_skb[entry] =3D skb;
 		entry =3D NEXT_TX(entry);
 	} else {
 		struct cp_desc *txd;
-		u32 first_len, first_eor;
+		u32 first_len, first_eor, ctrl;
 		dma_addr_t first_mapping;
 		int frag, first_entry =3D entry;
 		const struct iphdr *ip =3D ip_hdr(skb);
@@ -817,7 +859,6 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 		for (frag =3D 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
 			const skb_frag_t *this_frag =3D &skb_shinfo(skb)->frags[frag];
 			u32 len;
-			u32 ctrl;
 			dma_addr_t mapping;
=20
 			len =3D skb_frag_size(this_frag);
@@ -854,6 +895,9 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 			wmb();
=20
 			txd->opts1 =3D cpu_to_le32(ctrl);
+			cp->tx_ring_shadow[entry].opts2 =3D opts2;
+			cp->tx_ring_shadow[entry].addr =3D cpu_to_le64(mapping);
+			cp->tx_ring_shadow[entry].opts1 =3D cpu_to_le32(ctrl);
 			wmb();
=20
 			cp->tx_skb[entry] =3D skb;
@@ -863,37 +907,48 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb=
,
 		txd =3D &cp->tx_ring[first_entry];
 		txd->opts2 =3D opts2;
 		txd->addr =3D cpu_to_le64(first_mapping);
+		cp->tx_ring_shadow[first_entry].opts2 =3D opts2;
+		cp->tx_ring_shadow[first_entry].addr =3D cpu_to_le64(first_mapping);
+
 		wmb();
=20
 		if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
 			if (ip->protocol =3D=3D IPPROTO_TCP)
-				txd->opts1 =3D cpu_to_le32(first_eor | first_len |
+				ctrl =3D (first_eor | first_len |
 							 FirstFrag | DescOwn |
 							 IPCS | TCPCS);
 			else if (ip->protocol =3D=3D IPPROTO_UDP)
-				txd->opts1 =3D cpu_to_le32(first_eor | first_len |
+				ctrl =3D (first_eor | first_len |
 							 FirstFrag | DescOwn |
 							 IPCS | UDPCS);
 			else
 				BUG();
 		} else
-			txd->opts1 =3D cpu_to_le32(first_eor | first_len |
+			ctrl =3D (first_eor | first_len |
 						 FirstFrag | DescOwn);
+		txd->opts1 =3D cpu_to_le32(ctrl);
+		cp->tx_ring_shadow[first_entry].opts1 =3D cpu_to_le32(ctrl);
 		wmb();
 	}
 	cp->tx_head =3D entry;
=20
 	netdev_sent_queue(dev, skb->len);
 	netif_dbg(cp, tx_queued, cp->dev, "tx queued, slot %d, skblen %d\n",
-		  entry, skb->len);
+		  entry ? entry - 1 : CP_TX_RING_SIZE-1, skb->len);
 	if (TX_BUFFS_AVAIL(cp) <=3D (MAX_SKB_FRAGS + 1))
 		netif_stop_queue(dev);
=20
 out_unlock:
+	if (!cp->tx_ring_running) {
+		cp->tx_ring_running =3D 1;
+		cp->tx_ring_seen =3D cp->tx_head ? cp->tx_head - 1 : (CP_TX_RING_SIZE - =
1);;
+		netif_dbg(cp, tx_queued, cp->dev, "tx kicking tx_poll, head %d tail %d d=
esc %04x poll %02x", cp->tx_head, cp->tx_tail, cpr16(TxDmaOkLowDesc), cpr8(=
TxPoll));
+		cpw8(TxPoll, NormalTxPoll);
+	} else {
+		netif_dbg(cp, tx_queued, cp->dev, "tx not kicking tx_poll, head %d tail =
%d desc %04x poll %02x", cp->tx_head, cp->tx_tail, cpr16(TxDmaOkLowDesc), c=
pr8(TxPoll));
+	}
 	spin_unlock_irqrestore(&cp->lock, intr_flags);
=20
-	cpw8(TxPoll, NormalTxPoll);
-
 	return NETDEV_TX_OK;
 out_dma_error:
 	dev_kfree_skb_any(skb);
@@ -1035,7 +1090,8 @@ static inline void cp_start_hw (struct cp_private *cp=
)
 	 * This variant appears to work fine.
 	 */
 	cpw8(Cmd, RxOn | TxOn);
-
+	cp->tx_ring_running =3D 0;
+	cp->tx_ring_seen =3D -1;
 	netdev_reset_queue(cp->dev);
 }
=20
@@ -1057,7 +1113,7 @@ static void cp_init_hw (struct cp_private *cp)
 	cpw32_f (MAC0 + 4, le32_to_cpu (*(__le32 *) (dev->dev_addr + 4)));
=20
 	cp_start_hw(cp);
-	cpw8(TxThresh, 0x06); /* XXX convert magic num to a constant */
+	cpw8(TxThresh, 0x2f); /* XXX convert magic num to a constant */
=20
 	__cp_set_rx_mode(dev);
 	cpw32_f (TxConfig, IFG | (TX_DMA_BURST << TxDMAShift));
@@ -1255,26 +1311,74 @@ static int cp_close (struct net_device *dev)
 static void cp_tx_timeout(struct net_device *dev)
 {
 	struct cp_private *cp =3D netdev_priv(dev);
+	dma_addr_t ring_dma;
 	unsigned long flags;
 	int rc;
+	int i;
=20
-	netdev_warn(dev, "Transmit timeout, status %2x %4x %4x %4x\n",
+	netdev_warn(dev, "Transmit timeout, status %2x %4x %4x %4x desc %02x poll=
 %02x\n",
 		    cpr8(Cmd), cpr16(CpCmd),
-		    cpr16(IntrStatus), cpr16(IntrMask));
+		    cpr16(IntrStatus), cpr16(IntrMask),
+		    cpr16(TxDmaOkLowDesc), cpr8(TxPoll));
=20
 	spin_lock_irqsave(&cp->lock, flags);
=20
+	for (i =3D 0; i < CP_TX_RING_SIZE; i++) {
+		printk("TX ring %02d @%p: %p %llx %x %x (%x %x)\n",
+		       i, &cp->tx_ring[i], cp->tx_skb[i], (unsigned long long)cp->tx_rin=
g[i].addr,
+		       cp->tx_ring[i].opts1, cp->tx_ring[i].opts2,
+		       cp->tx_ring_shadow[i].opts1, cp->tx_ring_shadow[i].opts2);
+	}
+//static void cp_stop_hw (struct cp_private *cp)
+{
+	cpw8(Cmd, RxOn);
+
+	cp->tx_head =3D cp->tx_tail =3D 0;
+
+}
+//static void cp_clean_rings (struct cp_private *cp)
+{
+	struct cp_desc *desc;
+
+	for (i =3D 0; i < CP_TX_RING_SIZE; i++) {
+		if (cp->tx_skb[i]) {
+			struct sk_buff *skb =3D cp->tx_skb[i];
+
+			desc =3D cp->tx_ring + i;
+			dma_unmap_single(&cp->pdev->dev,le64_to_cpu(desc->addr),
+					 le32_to_cpu(desc->opts1) & 0xffff,
+					 PCI_DMA_TODEVICE);
+			if (le32_to_cpu(desc->opts1) & LastFrag)
+				dev_kfree_skb_any(skb);
+			cp->dev->stats.tx_dropped++;
+			cp->tx_skb[i] =3D NULL;
+		}
+		if (i =3D=3D CP_TX_RING_SIZE - 1)
+			cp->tx_ring[i].opts1 =3D cpu_to_le32(RingEnd);
+		else
+			cp->tx_ring[i].opts1 =3D cpu_to_le32(0);
+		cp->tx_ring[i].opts2 =3D cpu_to_le32(0);
+		cp->tx_ring[i].addr =3D cpu_to_le64(0);
+	}
+	netdev_reset_queue(cp->dev);
+}
+
+	cpw8(Cmd, RxOn | TxOn);
+	cp->tx_ring_running =3D 0;
+	cp->tx_ring_seen =3D -1;
+
+
+#if 0
 	cp_stop_hw(cp);
 	cp_clean_rings(cp);
 	rc =3D cp_init_rings(cp);
 	cp_start_hw(cp);
+#endif
 	__cp_set_rx_mode(dev);
 	cpw16_f(IntrMask, cp_norx_intr_mask);
-
-	netif_wake_queue(dev);
 	napi_schedule_irqoff(&cp->napi);
-
 	spin_unlock_irqrestore(&cp->lock, flags);
+	netif_wake_queue(dev);
 }
=20
 static int cp_change_mtu(struct net_device *dev, int new_mtu)
@@ -1989,7 +2093,7 @@ static int cp_init_one (struct pci_dev *pdev, const s=
truct pci_device_id *ent)
 		    cpu_to_le16(read_eeprom (regs, i + 7, addr_len));
=20
 	dev->netdev_ops =3D &cp_netdev_ops;
-	netif_napi_add(dev, &cp->napi, cp_rx_poll, 16);
+	netif_napi_add(dev, &cp->napi, cp_rx_poll, NAPI_POLL_WEIGHT);
 	dev->ethtool_ops =3D &cp_ethtool_ops;
 	dev->watchdog_timeo =3D TX_TIMEOUT;
=20

--=20
dwmw2


--=-lthvq/g+3psanALD+W8A
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIISjjCCBicw
ggUPoAMCAQICAw3vNzANBgkqhkiG9w0BAQUFADCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0
YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcx
ODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENB
MB4XDTE1MDUwNTA5NDM0MVoXDTE2MDUwNTA5NTMzNlowQjEcMBoGA1UEAwwTZHdtdzJAaW5mcmFk
ZWFkLm9yZzEiMCAGCSqGSIb3DQEJARYTZHdtdzJAaW5mcmFkZWFkLm9yZzCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAMkbm9kPbx1j/X4RVyf/pPKSYwelcco69TvnQQbKM8m8xkWjXJI1
jpJ1jMaGUZGFToINMSZi7lZawUozudWbXSKy1SikENSTJHffsdRAIlsp+hR8vWvjsKUry6sEdqPG
doa5RY7+N4WRusWZDYW/RRWE6i9EL9qV86CVPYqw22UBOUw4/j/HVGCV6TSB8yE5iEwhk/hUuzRr
FZm1MJMR7mCS7BCR8Lr5jFY61lWpBiXNXIxLZCvDc26KR5L5tYX43iUVO3fzES1GRVoYnxxk2tmz
fcsZG5vK+Trc9L8OZJfkYrEHH3+Iw41MQ0w/djVtYr1+HYldx0QmYXAtnhIj+UMCAwEAAaOCAtkw
ggLVMAkGA1UdEwQCMAAwCwYDVR0PBAQDAgSwMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcD
BDAdBgNVHQ4EFgQUszC96C3w5/2+d+atSr0IpT26YI4wHwYDVR0jBBgwFoAUU3Ltkpzg2ssBXHx+
ljVO8tS4UYIwHgYDVR0RBBcwFYETZHdtdzJAaW5mcmFkZWFkLm9yZzCCAUwGA1UdIASCAUMwggE/
MIIBOwYLKwYBBAGBtTcBAgMwggEqMC4GCCsGAQUFBwIBFiJodHRwOi8vd3d3LnN0YXJ0c3NsLmNv
bS9wb2xpY3kucGRmMIH3BggrBgEFBQcCAjCB6jAnFiBTdGFydENvbSBDZXJ0aWZpY2F0aW9uIEF1
dGhvcml0eTADAgEBGoG+VGhpcyBjZXJ0aWZpY2F0ZSB3YXMgaXNzdWVkIGFjY29yZGluZyB0byB0
aGUgQ2xhc3MgMSBWYWxpZGF0aW9uIHJlcXVpcmVtZW50cyBvZiB0aGUgU3RhcnRDb20gQ0EgcG9s
aWN5LCByZWxpYW5jZSBvbmx5IGZvciB0aGUgaW50ZW5kZWQgcHVycG9zZSBpbiBjb21wbGlhbmNl
IG9mIHRoZSByZWx5aW5nIHBhcnR5IG9ibGlnYXRpb25zLjA2BgNVHR8ELzAtMCugKaAnhiVodHRw
Oi8vY3JsLnN0YXJ0c3NsLmNvbS9jcnR1MS1jcmwuY3JsMIGOBggrBgEFBQcBAQSBgTB/MDkGCCsG
AQUFBzABhi1odHRwOi8vb2NzcC5zdGFydHNzbC5jb20vc3ViL2NsYXNzMS9jbGllbnQvY2EwQgYI
KwYBBQUHMAKGNmh0dHA6Ly9haWEuc3RhcnRzc2wuY29tL2NlcnRzL3N1Yi5jbGFzczEuY2xpZW50
LmNhLmNydDAjBgNVHRIEHDAahhhodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS8wDQYJKoZIhvcNAQEF
BQADggEBAHMQmxHHodpS85X8HRyxhvfkys7r+taCNOaNU9cxQu/cZ/6k5nS2qGNMzZ6jb7ueY/V7
7p+4DW/9ZWODDTf4Fz00mh5SSVc20Bz7t+hhxwHd62PZgENh5i76Qq2tw48U8AsYo5damHby1epf
neZafLpUkLLO7AGBJIiRVTevdvyXQ0qnixOmKMWyvrhSNGuVIKVdeqLP+102Dwf+dpFyw+j1hz28
jEEKpHa+NR1b2kXuSPi/rMGhexwlJOh4tK8KQ6Ryr0rIN//NSbOgbyYZrzc/ZUWX9V5OA84ChFb2
vkFl0OcYrttp/rhDBLITwffPxSZeoBh9H7zYzkbCXKL3BUIwggYnMIIFD6ADAgECAgMN7zcwDQYJ
KoZIhvcNAQEFBQAwgYwxCzAJBgNVBAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSswKQYD
VQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFydENv
bSBDbGFzcyAxIFByaW1hcnkgSW50ZXJtZWRpYXRlIENsaWVudCBDQTAeFw0xNTA1MDUwOTQzNDFa
Fw0xNjA1MDUwOTUzMzZaMEIxHDAaBgNVBAMME2R3bXcyQGluZnJhZGVhZC5vcmcxIjAgBgkqhkiG
9w0BCQEWE2R3bXcyQGluZnJhZGVhZC5vcmcwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
AQDJG5vZD28dY/1+EVcn/6TykmMHpXHKOvU750EGyjPJvMZFo1ySNY6SdYzGhlGRhU6CDTEmYu5W
WsFKM7nVm10istUopBDUkyR337HUQCJbKfoUfL1r47ClK8urBHajxnaGuUWO/jeFkbrFmQ2Fv0UV
hOovRC/alfOglT2KsNtlATlMOP4/x1Rglek0gfMhOYhMIZP4VLs0axWZtTCTEe5gkuwQkfC6+YxW
OtZVqQYlzVyMS2Qrw3NuikeS+bWF+N4lFTt38xEtRkVaGJ8cZNrZs33LGRubyvk63PS/DmSX5GKx
Bx9/iMONTENMP3Y1bWK9fh2JXcdEJmFwLZ4SI/lDAgMBAAGjggLZMIIC1TAJBgNVHRMEAjAAMAsG
A1UdDwQEAwIEsDAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUHAwQwHQYDVR0OBBYEFLMwvegt
8Of9vnfmrUq9CKU9umCOMB8GA1UdIwQYMBaAFFNy7ZKc4NrLAVx8fpY1TvLUuFGCMB4GA1UdEQQX
MBWBE2R3bXcyQGluZnJhZGVhZC5vcmcwggFMBgNVHSAEggFDMIIBPzCCATsGCysGAQQBgbU3AQID
MIIBKjAuBggrBgEFBQcCARYiaHR0cDovL3d3dy5zdGFydHNzbC5jb20vcG9saWN5LnBkZjCB9wYI
KwYBBQUHAgIwgeowJxYgU3RhcnRDb20gQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwAwIBARqBvlRo
aXMgY2VydGlmaWNhdGUgd2FzIGlzc3VlZCBhY2NvcmRpbmcgdG8gdGhlIENsYXNzIDEgVmFsaWRh
dGlvbiByZXF1aXJlbWVudHMgb2YgdGhlIFN0YXJ0Q29tIENBIHBvbGljeSwgcmVsaWFuY2Ugb25s
eSBmb3IgdGhlIGludGVuZGVkIHB1cnBvc2UgaW4gY29tcGxpYW5jZSBvZiB0aGUgcmVseWluZyBw
YXJ0eSBvYmxpZ2F0aW9ucy4wNgYDVR0fBC8wLTAroCmgJ4YlaHR0cDovL2NybC5zdGFydHNzbC5j
b20vY3J0dTEtY3JsLmNybDCBjgYIKwYBBQUHAQEEgYEwfzA5BggrBgEFBQcwAYYtaHR0cDovL29j
c3Auc3RhcnRzc2wuY29tL3N1Yi9jbGFzczEvY2xpZW50L2NhMEIGCCsGAQUFBzAChjZodHRwOi8v
YWlhLnN0YXJ0c3NsLmNvbS9jZXJ0cy9zdWIuY2xhc3MxLmNsaWVudC5jYS5jcnQwIwYDVR0SBBww
GoYYaHR0cDovL3d3dy5zdGFydHNzbC5jb20vMA0GCSqGSIb3DQEBBQUAA4IBAQBzEJsRx6HaUvOV
/B0csYb35MrO6/rWgjTmjVPXMULv3Gf+pOZ0tqhjTM2eo2+7nmP1e+6fuA1v/WVjgw03+Bc9NJoe
UklXNtAc+7foYccB3etj2YBDYeYu+kKtrcOPFPALGKOXWph28tXqX53mWny6VJCyzuwBgSSIkVU3
r3b8l0NKp4sTpijFsr64UjRrlSClXXqiz/tdNg8H/naRcsPo9Yc9vIxBCqR2vjUdW9pF7kj4v6zB
oXscJSToeLSvCkOkcq9KyDf/zUmzoG8mGa83P2VFl/VeTgPOAoRW9r5BZdDnGK7baf64QwSyE8H3
z8UmXqAYfR+82M5Gwlyi9wVCMIIGNDCCBBygAwIBAgIBHjANBgkqhkiG9w0BAQUFADB9MQswCQYD
VQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwg
Q2VydGlmaWNhdGUgU2lnbmluZzEpMCcGA1UEAxMgU3RhcnRDb20gQ2VydGlmaWNhdGlvbiBBdXRo
b3JpdHkwHhcNMDcxMDI0MjEwMTU1WhcNMTcxMDI0MjEwMTU1WjCBjDELMAkGA1UEBhMCSUwxFjAU
BgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRl
IFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUg
Q2xpZW50IENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxwmDzM4t2BqxKaQuE6uW
vooyg4ymiEGWVUet1G8SD+rqvyNH4QrvnEIaFHxOhESip7vMz39ScLpNLbL1QpOlPW/tFIzNHS3q
d2XRNYG5Sv9RcGE+T4qbLtsjjJbi6sL7Ls/f/X9ftTyhxvxWkf8KW37iKrueKsxw2HqolH7GM6FX
5UfNAwAu4ZifkpmZzU1slBhyWwaQPEPPZRsWoTb7q8hmgv6Nv3Hg9rmA1/VPBIOQ6SKRkHXG0Hhm
q1dOFoAFI411+a/9nWm5rcVjGcIWZ2v/43Yksq60jExipA4l5uv9/+Hm33mbgmCszdj/Dthf13tg
Av2O83hLJ0exTqfrlwIDAQABo4IBrTCCAakwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMC
AQYwHQYDVR0OBBYEFFNy7ZKc4NrLAVx8fpY1TvLUuFGCMB8GA1UdIwQYMBaAFE4L7xqkQFulF2mH
MMo0aEPQQa7yMGYGCCsGAQUFBwEBBFowWDAnBggrBgEFBQcwAYYbaHR0cDovL29jc3Auc3RhcnRz
c2wuY29tL2NhMC0GCCsGAQUFBzAChiFodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9zZnNjYS5jcnQw
WwYDVR0fBFQwUjAnoCWgI4YhaHR0cDovL3d3dy5zdGFydHNzbC5jb20vc2ZzY2EuY3JsMCegJaAj
hiFodHRwOi8vY3JsLnN0YXJ0c3NsLmNvbS9zZnNjYS5jcmwwgYAGA1UdIAR5MHcwdQYLKwYBBAGB
tTcBAgEwZjAuBggrBgEFBQcCARYiaHR0cDovL3d3dy5zdGFydHNzbC5jb20vcG9saWN5LnBkZjA0
BggrBgEFBQcCARYoaHR0cDovL3d3dy5zdGFydHNzbC5jb20vaW50ZXJtZWRpYXRlLnBkZjANBgkq
hkiG9w0BAQUFAAOCAgEACoMIfXirLAZcuGOMXq4cuSN3TaFx2H2GvD5VSy/6rV55BYHbWNaPeQn3
oBSU8KgQZn/Kck1JxbLpAxVCNtsxeW1R87ifhsYZ0qjdrA9anrW2MAWCtosmAOT4OxK9QPoSjCMx
M3HbkZCDJgnlE8jMopH21BbyAYr7b5EfGRQJNtgWcvqSXwKHnTutR08+Kkn0KAkXCzeQNLeA5LlY
UzFyM7kPAp8pIRMQ+seHunmyG642S2+y/qHEdMuGIwpfz3eDF1PdctL04qYK/zu+Qg1Bw0RwgigV
Zs/0c5HP2/e9DBHh7eSwtzYlk4AUr6yxLlcwSjOfOmKEQ/Q8tzh0IFiNu9IPuTGAPBn4CPxD0+Ru
8T2wg8/s43R/PT3kd1OEqOJUl7q+h+r6fpvU0Fzxd2tC8Ga6fDEPme+1Nbi+03pVjuZQKbGwKJ66
gEn06WqaxVZC+J8hh/jR0k9mST1iAZPNYulcNJ8tKmVtjYsv0L1TSm2+NwON58tO+pIVzu3DWwSE
XSf+qkDavQam+QtEOZxLBXI++aMUEapSn+k3Lxm48ZCYfAWLb/Xj7F5JQMbZvCexglAbYR0kIHqW
5DnsYSdMD/IplJMojx0NBrxJ3fN9dvX2Y6BIXRsF1du4qESm4/3CKuyUV7p9DW3mPlHTGLvYxnyK
Qy7VFBkoLINszBrOUeIxggNvMIIDawIBATCBlDCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0
YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcx
ODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENB
AgMN7zcwCQYFKw4DAhoFAKCCAa8wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0B
CQUxDxcNMTUwOTE4MjI0MjA5WjAjBgkqhkiG9w0BCQQxFgQU18k41g80gwYE63kG+Ta9nAYU0jsw
gaUGCSsGAQQBgjcQBDGBlzCBlDCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0
ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNVBAMT
L1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENBAgMN7zcwgacG
CyqGSIb3DQEJEAILMYGXoIGUMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRk
LjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMv
U3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0ECAw3vNzANBgkq
hkiG9w0BAQEFAASCAQAycLAsYHfl6oe1bbzAhyk8GaJELt0sMz3EchcT3oYvBau7drnLDXbl6Wwi
qMHgeAU6LoRHgyETmzWGEJ6QddOLmo+yO/qD5ILxqTYQ8kmRFfggiBNhXtahanKARZlXrTzGzHaP
oRDiJBPTEk4Xyk529YXBn8VErT7G8bP6CXzbJ7+juMyVgtBnRL7pX4NkBLZ6DdsurewmoFynlCAs
nxEpUpuQir1fc2UXwG1JOPSXNK7bkAo6ZxOHnxlHTFQxuozeaG0dOmp3q8e3ZgJVV+N1iTpX4Amn
kmstHS9IzYneJAU36M1uuiLZJI1IdqQy3y48jvoMuFqZRYihRkkovcdBAAAAAAAA


--=-lthvq/g+3psanALD+W8A--
