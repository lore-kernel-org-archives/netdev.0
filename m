From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison overwritten
Date: Tue, 5 Jul 2011 14:06:50 -0400
Message-ID: <20110705180650.GF2959@hmsreliant.think-freely.org>
References: <1309840708.2720.31.camel@edumazet-laptop>
 <CAB9v_DFM8PcujUB-YzcK49DS7T6Bz2FLDtkVdEYt8an1oPYVFw@mail.gmail.com>
 <1309842642.2720.36.camel@edumazet-laptop>
 <CAB9v_DEiPFzQt-TgeVC3r3Y7YFwApLK_NHkDahFOKpibtABrZg@mail.gmail.com>
 <1309844009.2720.39.camel@edumazet-laptop>
 <1309845573.2720.41.camel@edumazet-laptop>
 <20110705160531.GC2959@hmsreliant.think-freely.org>
 <1309882352.2271.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20110705164202.GD2959@hmsreliant.think-freely.org>
 <1309884441.2271.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Zaytsev <alexey.zaytsev@gmail.com>,
	Michael =?iso-8859-1?Q?B=FCsch?= <m@bues.ch>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58002 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182Ab1GESHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 14:07:05 -0400
Content-Disposition: inline
In-Reply-To: <1309884441.2271.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 05, 2011 at 06:47:21PM +0200, Eric Dumazet wrote:
> Le mardi 05 juillet 2011 =E0 12:42 -0400, Neil Horman a =E9crit :
> > On Tue, Jul 05, 2011 at 06:12:32PM +0200, Eric Dumazet wrote:
>=20
> > > So all descriptors before prod are guaranteed to be ready for hos=
t
> > > consume... Fact that a dma access is running on 'next descriptor'=
 should
> > > be irrelevant.
> > >=20
> > But we handle more than one descriptor per b44_rx call - theres a w=
hile loop in
> > there where we do advance to the next descriptor.
>=20
> Yes, but we advance up to 'prod', which is the very last safe
> descriptor.
>=20
> If hardware advertises descriptor X being ready to be handled by host=
,
> while DMA on this X descriptor is not yet finished, this would be a
> really useless hardware ;)
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


Something else just jumped out at me.  During b44_open, we call b44_ini=
t_rings.
This function allocates bp->rx_pending skb's and iteratively puts them =
in the rx
dma ring. bp->rx_pending is initalized to B44_DEF_RX_RING_PENDING, whic=
h is
defined as 200 (just about half of the 512 entries that the dma ring ac=
tually
supports in the hardware.  This is normally ok, as subsequent calls to
b44_alloc_rx_skb will fill in entries in the ring as those skbs are con=
sumed.
The problem with this however is that b44_alloc_rx_skb only sets the
DESC_CTRL_EOT bit in the descriptor of the 512th entry, indicating that=
 the
hardware should wrap around and reset the index counter.  If a large vo=
lume of
traffic is pushed through the adapter early on after initalization, or =
if the
cpu is busy during init, it would be possible that the ring buffer woul=
d fill up
prior to having additional entries added to the ring, the result being =
that the
dma engine would reach the end of the allocated descriptors, not see an=
 EOT bit
set, and continue on using unallocated descriptors.

Just a theory, but it would be interesting to see if the problem subsid=
ed if you
ensured that you allocated  a full descriptor ring on b44_open
Neil
=20
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 3d247f3..1b58a7c 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -57,7 +57,7 @@
 #define B44_MAX_MTU			1500
=20
 #define B44_RX_RING_SIZE		512
-#define B44_DEF_RX_RING_PENDING		200
+#define B44_DEF_RX_RING_PENDING		512
 #define B44_RX_RING_BYTES	(sizeof(struct dma_desc) * \
 				 B44_RX_RING_SIZE)
 #define B44_TX_RING_SIZE		512
