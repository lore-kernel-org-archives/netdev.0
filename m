From: Luis Henriques <luis.henriques@canonical.com>
Subject: Re: [Xen-devel] [PATCH] xen-netfront: Fix handling packets on
 compound pages with skb_linearize
Date: Tue, 9 Dec 2014 09:54:53 +0000
Message-ID: <20141209095453.GA7783@hercules>
References: <1407778343-13622-1-git-send-email-zoltan.kiss@citrix.com>
 <547C2CFC.7060908@canonical.com>
 <20141208101936.GA7491@hercules>
 <54858753.1070801@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stefan Bader <stefan.bader@canonical.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>, netdev@vger.kernel.org,
	Kamal Mostafa <kamal@canonical.com>,
	linux-kernel@vger.kernel.org,
	Paul Durrant <paul.durrant@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	xen-devel@lists.xenproject.org,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:57979 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754785AbaLIJy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 04:54:58 -0500
Content-Disposition: inline
In-Reply-To: <54858753.1070801@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 08, 2014 at 11:11:15AM +0000, David Vrabel wrote:
> On 08/12/14 10:19, Luis Henriques wrote:
> > On Mon, Dec 01, 2014 at 09:55:24AM +0100, Stefan Bader wrote:
> >> On 11.08.2014 19:32, Zoltan Kiss wrote:
> >>> There is a long known problem with the netfront/netback interface=
: if the guest
> >>> tries to send a packet which constitues more than MAX_SKB_FRAGS +=
 1 ring slots,
> >>> it gets dropped. The reason is that netback maps these slots to a=
 frag in the
> >>> frags array, which is limited by size. Having so many slots can o=
ccur since
> >>> compound pages were introduced, as the ring protocol slice them u=
p into
> >>> individual (non-compound) page aligned slots. The theoretical wor=
st case
> >>> scenario looks like this (note, skbs are limited to 64 Kb here):
> >>> linear buffer: at most PAGE_SIZE - 17 * 2 bytes, overlapping page=
 boundary,
> >>> using 2 slots
> >>> first 15 frags: 1 + PAGE_SIZE + 1 bytes long, first and last byte=
s are at the
> >>> end and the beginning of a page, therefore they use 3 * 15 =3D 45=
 slots
> >>> last 2 frags: 1 + 1 bytes, overlapping page boundary, 2 * 2 =3D 4=
 slots
> >>> Although I don't think this 51 slots skb can really happen, we ne=
ed a solution
> >>> which can deal with every scenario. In real life there is only a =
few slots
> >>> overdue, but usually it causes the TCP stream to be blocked, as t=
he retry will
> >>> most likely have the same buffer layout.
> >>> This patch solves this problem by linearizing the packet. This is=
 not the
> >>> fastest way, and it can fail much easier as it tries to allocate =
a big linear
> >>> area for the whole packet, but probably easier by an order of mag=
nitude than
> >>> anything else. Probably this code path is not touched very freque=
ntly anyway.
> >>>
> >>> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> >>> Cc: Wei Liu <wei.liu2@citrix.com>
> >>> Cc: Ian Campbell <Ian.Campbell@citrix.com>
> >>> Cc: Paul Durrant <paul.durrant@citrix.com>
> >>> Cc: netdev@vger.kernel.org
> >>> Cc: linux-kernel@vger.kernel.org
> >>> Cc: xen-devel@lists.xenproject.org
> >>
> >> This does not seem to be marked explicitly as stable. Has someone =
already asked
> >> David Miller to put it on his stable queue? IMO it qualifies quite=
 well and the
> >> actual change should be simple to pick/backport.
> >>
> >=20
> > Thank you Stefan, I'm queuing this for the next 3.16 kernel release=
=2E
>=20
> Don't backport this yes.  It's broken.  It produces malformed request=
s
> and netback will report a fatal error and stop all traffic on the VIF=
=2E
>=20
> David

Ok, thank you.  I've dropped it already.

Cheers,
--
Lu=EDs
