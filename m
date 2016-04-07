From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [Lsf] [LSF/MM TOPIC] Generic page-pool recycle facility?
Date: Thu, 7 Apr 2016 22:38:53 +0200
Message-ID: <20160407223853.6f4c7dbd@redhat.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	<20160407161715.52635cac@redhat.com>
	<1460058531.13579.12.camel@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "lsf@lists.linux-foundation.org" <lsf@lists.linux-foundation.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>,
        "bblanco@plumgrid.com" <bblanco@plumgrid.com>,
        "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
        "James.Bottomley@HansenPartnership.com"
 <James.Bottomley@HansenPartnership.com>,
        "tom@herbertland.com"
 <tom@herbertland.com>,
        "lsf-pc@lists.linux-foundation.org"
 <lsf-pc@lists.linux-foundation.org>,
        brouer@redhat.com
To: "Waskiewicz, PJ" <PJ.Waskiewicz@netapp.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1460058531.13579.12.camel@netapp.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, 7 Apr 2016 19:48:50 +0000
"Waskiewicz, PJ" <PJ.Waskiewicz@netapp.com> wrote:

> On Thu, 2016-04-07 at 16:17 +0200, Jesper Dangaard Brouer wrote:
> > (Topic proposal for MM-summit)
> >=20
> > Network Interface Cards (NIC) drivers, and increasing speeds stress
> > the page-allocator (and DMA APIs).=C2=A0=C2=A0A number of driver specif=
ic
> > open-coded approaches exists that work-around these bottlenecks in
> > the
> > page allocator and DMA APIs. E.g. open-coded recycle mechanisms, and
> > allocating larger pages and handing-out page "fragments".
> >=20
> > I'm proposing a generic page-pool recycle facility, that can cover
> > the
> > driver use-cases, increase performance and open up for zero-copy RX. =20
>=20
> Is this based on the page recycle stuff from ixgbe that used to be in
> the driver? =C2=A0If so I'd really like to be part of the discussion.

Okay, so it is not part of the driver any-longer?  I've studied the
current ixgbe driver (and other NIC drivers) closely.  Do you have some
code pointers, to this older code?

The likely-fastest recycle code I've see is in the bnx2x driver.  If
you are interested see: bnx2x_reuse_rx_data().  Again is it a bit
open-coded produce/consumer ring queue (which would be nice to also
cleanup).


To amortize the cost of allocating a single page, most other drivers
use the trick of allocating a larger (compound) page, and partition
this page into smaller "fragments".  Which also amortize the cost of
dma_map/unmap (important on non-x86).

This is actually problematic performance wise, because packet-data
(in these page fragments) only get DMA_sync'ed, and is thus considered
"read-only".  As netstack need to write packet headers, yet-another
(writable) memory area is allocated per packet (plus the SKB meta-data
struct).

--=20
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
