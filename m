From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next 2/2] bnx2x: allocate mac filtering pending list
 in PAGE_SIZE increments
Date: Sun, 18 Sep 2016 10:25:05 +0000
Message-ID: <BL2PR07MB2306CEA6AD75D9D4EB77FB1F8DF50@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <cover.1474060371.git.jbaron@akamai.com>
 <d46b4fa36c32affff20fcc92148e33ee6176f899.1474060371.git.jbaron@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Ariel.Elior@qlogic.com" <Ariel.Elior@qlogic.com>
To: Jason Baron <jbaron@akamai.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0055.outbound.protection.outlook.com ([104.47.38.55]:3536
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754739AbcIRKZH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Sep 2016 06:25:07 -0400
In-Reply-To: <d46b4fa36c32affff20fcc92148e33ee6176f899.1474060371.git.jbaron@akamai.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Currently, we can have high order page allocations that specify
> GFP_ATOMIC when configuring multicast MAC address filters.
>=20
> For example, we have seen order 2 page allocation failures with
> ~500 multicast addresses configured.
>=20
> Convert the allocation for the pending list to be done in PAGE_SIZE
> increments.
>=20
> Signed-off-by: Jason Baron <jbaron@akamai.com>

While I appreciate the effort, I wonder whether it's worth it:

- The hardware [even in its newer generation] provides an approximate
based classification [I.e., hashed] with 256 bins.
When configuring 500 multicast addresses, one can argue the
difference between multicast-promisc mode and actual configuration
is insignificant.
Perhaps the easier-to-maintain alternative would simply be to
determine the maximal number of multicast addresses that can be
configured using a single PAGE, and if in need of more than that
simply move into multicast-promisc.

 - While GFP_ATOMIC is required in this flow due to the fact it's being
called from sleepless context, I do believe this is mostly a remnant -
it's possible that by slightly changing the locking scheme we can have
the configuration done from sleepless context and simply switch to
GFP_KERNEL instead.

Regarding the patch itself, only comment I have:
> +			elem_group =3D (struct bnx2x_mcast_elem_group *)
> +				     elem_group->mcast_group_link.next;
Let's use list_next_entry() instead.
