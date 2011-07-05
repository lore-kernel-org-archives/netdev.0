From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison overwritten
Date: Tue, 5 Jul 2011 15:53:53 -0400
Message-ID: <20110705195353.GG2959@hmsreliant.think-freely.org>
References: <1309844009.2720.39.camel@edumazet-laptop>
 <1309845573.2720.41.camel@edumazet-laptop>
 <20110705160531.GC2959@hmsreliant.think-freely.org>
 <1309882352.2271.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20110705164202.GD2959@hmsreliant.think-freely.org>
 <1309884441.2271.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20110705180650.GF2959@hmsreliant.think-freely.org>
 <1309889634.2545.2.camel@edumazet-laptop>
 <1309890775.2545.17.camel@edumazet-laptop>
 <1309891516.2545.23.camel@edumazet-laptop>
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
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58328 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752494Ab1GETyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 15:54:19 -0400
Content-Disposition: inline
In-Reply-To: <1309891516.2545.23.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 05, 2011 at 08:45:16PM +0200, Eric Dumazet wrote:
> Le mardi 05 juillet 2011 =E0 20:32 +0200, Eric Dumazet a =E9crit :
>=20
> > Then, maybe the driver model is completely wrong, and should really
> > setup 512 buffers, or use less descs but set EOT on last one.
> >=20
> > Currently it uses a 200 sliding window out of the 512 descs.
> >=20
> >=20
>=20
> One thing we could do would be to allocate a special guard buffer and
> set all 'out of window' descriptors to point to this guard buffer, an=
d
> periodically check if buffer is dirtied by the card.
>=20
> (first word would be enough)
>=20
> (instead of setting desc->addr to NULL, set to
> dma_map_single(guard_buffer))
>=20
I think this is a goo idea, at least for testing.  It seems odd to me t=
hat we
have the B44_DMARX_PTR value which indicates (ostensibly) the pointer t=
o the
descriptor to be processed next (the documentation isnt' very verbose o=
n the
subject), along with the EOT bit on a descriptor.  It seems like both t=
he
register and the bit are capable of conveying the same (or at least ove=
rlapping)
information.

I think what I'm having the most trouble with is understanding when the=
 hw looks
at the EOT bit in the descriptor.  If it completes a DMA and sees the E=
OT bit
set, does the next DMA occur to the descriptor pointed to by the DMARX_=
ADDR
register?  Of does it stall until such time as the DMARX_PTR register i=
s rotated
around?  What if it doesn't see the EOT bit set?  Does it just keep goi=
ng with
the next descriptor? =20

Also, there seems to be some inconsistency in the settnig of the B44_DM=
ARX_PTR
register.  In bnx2_init_hw its set to the value of bp->rx_pending, whic=
h is
defined as being 200.  But in b44_rx its advanced by sizeof(struct dma_=
desc) for
every iteration.  So in b44_init_hw we write the value 200 to it, osten=
sibly
indicating a limit of 200 descriptors, but in b44_rx we iteratively wri=
te the
values 0, 8, 16, 24...4*n to the register to indicate which descriptor =
we're
indexing?  Something really doesn't sit right with me there.  In the fo=
rmer case
we treat the register as holding  number of entries, and in the latter =
we treat
it as holding a byte offset into an array.  Or am I missing something?

Regards
Neil

>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
