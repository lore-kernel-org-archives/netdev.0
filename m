From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next 2/2] bnx2x: allocate mac filtering pending list
 in PAGE_SIZE increments
Date: Tue, 20 Sep 2016 07:41:43 +0000
Message-ID: <BL2PR07MB23061EAE5CF41EE56A1ED99B8DF70@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <cover.1474060371.git.jbaron@akamai.com>
 <d46b4fa36c32affff20fcc92148e33ee6176f899.1474060371.git.jbaron@akamai.com>
 <BL2PR07MB2306CEA6AD75D9D4EB77FB1F8DF50@BL2PR07MB2306.namprd07.prod.outlook.com>
 <57E02F82.9060903@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Ariel.Elior@qlogic.com" <Ariel.Elior@qlogic.com>
To: Jason Baron <jbaron@akamai.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0071.outbound.protection.outlook.com ([104.47.34.71]:14226
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751282AbcITHlt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 03:41:49 -0400
In-Reply-To: <57E02F82.9060903@akamai.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> Currently, we can have high order page allocations that specify
> >> GFP_ATOMIC when configuring multicast MAC address filters.
> >>
> >> For example, we have seen order 2 page allocation failures with
> >> ~500 multicast addresses configured.
> >>
> >> Convert the allocation for the pending list to be done in PAGE_SIZE
> >> increments.
> >>
> >> Signed-off-by: Jason Baron <jbaron@akamai.com>
> >
> > While I appreciate the effort, I wonder whether it's worth it:
> >
> > - The hardware [even in its newer generation] provides an approximate
> > based classification [I.e., hashed] with 256 bins.
> > When configuring 500 multicast addresses, one can argue the difference
> > between multicast-promisc mode and actual configuration is
> > insignificant.
>=20
> With 256 bins, I think it takes close to: 256*lg(256) or 2,048 multicast =
addresses
> to expect to have all bins have at least one hash, assuming a uniform dis=
tribution
> of the hashes.
>=20
> > Perhaps the easier-to-maintain alternative would simply be to
> > determine the maximal number of multicast addresses that can be
> > configured using a single PAGE, and if in need of more than that
> > simply move into multicast-promisc.
> >
>=20
> sizeof(struct bnx2x_mcast_list_elem) =3D 24. So there are 170 per page on=
 x86. So
> if we want to fit 2,048 elements, we need 12 pages.

That's not exactly what I mean - let's assume you'd have problems
allocating more than a PAGE. According to your calculation, that
means you're already using more than 170 multicast addresses.
I didn't bother trying to solve the combinatorics question of how
many bins you'd use on average for 170 filters given there are only
256 bins, but that would be a significant portion.
The question I rose was whether it actually makes a difference
under such circumstances whether the device would actually filter
those multicast addresses or be completely multicast promiscuous.
e.g., whether it's significant to be filtering out multicast ingress
traffic when you're already allowing 1/2 of all random multicast
packets to be classified for the interface.

But again, given that you've actually taken the trouble of solving
this, I guess this question is mostly theoretical. We HAVE a better
solution now [a.k.a., yours ;-) ]

> I think it would be easy to add a check to bnx2x_set_rx_mode_inner() to e=
nforce
> some maximum number of elements (perhaps 2,048 based on the above math)
> for the !CHIP_IS_E1() case on top of what I already posted.

The benefit should have been that we could have dropped your
Solution by limiting the driver to use at most the number of filters
that would fit in a single page.
I don't think it would serve any purpose to take your change and
in addition choose some combinatorics based upper limit.
