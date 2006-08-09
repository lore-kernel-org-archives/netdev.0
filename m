From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [IPV4] route: Dynamic hash table sizing.
Date: Wed, 09 Aug 2006 04:14:52 -0700 (PDT)
Message-ID: <20060809.041452.102575985.davem@davemloft.net>
References: <20060809.004920.59469729.davem@davemloft.net>
	<20060809.005337.104642177.davem@davemloft.net>
	<200608091209.29231.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:15751
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030687AbWHILOs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 07:14:48 -0400
To: dada1@cosmosbay.com
In-Reply-To: <200608091209.29231.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 9 Aug 2006 12:09:28 +0200

> On Wednesday 09 August 2006 09:53, David Miller wrote:
>=20
> > +	if (atomic_read(&ipv4_dst_ops.entries) >=3D (hmask + 1) &&
> > +	    (hmask + 1) < ip_rt_hashsz_limit)
> > +		schedule_work(&rtcache_work);
> > +	return 0;
> >  }
> >
>=20
> I wonder if you should not replicate this test (against (hmask + 1) <=
=20
> ip_rt_hashsz_limit) in rtcache_resize() itself, because we might end =
calling=20
> rthash_new_size() while (hmask +1 ) =3D ip_rt_hashsz_limit

That's a good point, let me think about that.

> > -=A0=A0=A0=A0=A0=A0=A0mult =3D ((u64)ip_rt_gc_interval) << long_log=
2(hmask + 1);
> > +=A0=A0=A0=A0=A0=A0=A0mult =3D ((u64)(hmask + 1)) << (u64)ip_rt_gc_=
interval;
>=20
> Not sure I understand what you did here (in rt_check_expire()), could=
 you=20
> please explain the math ? (I may be wrong but (x * 2^y) !=3D (y * 2^x=
) for=20
> general values of x and y)

Indeed I'm a retard.

I made the same error in another location:

@@ -857,7 +984,7 @@ static int rt_garbage_collect(void)
=20
 	/* Calculate number of entries, which we want to expire now. */
 	goal =3D atomic_read(&ipv4_dst_ops.entries) -
-		(ip_rt_gc_elasticity << long_log2(hmask + 1));
+		((hmask + 1) << ip_rt_gc_elasticity);

I'll revert both of those changes, thanks.
