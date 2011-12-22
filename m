From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 ipv6_select_ident
Date: Thu, 22 Dec 2011 08:51:17 +0100
Message-ID: <1324540277.2621.41.camel@edumazet-laptop>
References: <1324484956.2301.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF2117F.6000803@bootc.net>
	 <1324488984.2301.45.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324490401.2301.46.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF23BF2.4000601@bootc.net> <1324499332.2621.7.camel@edumazet-laptop>
	 <1324500775.2621.9.camel@edumazet-laptop> <4EF2568C.6040006@bootc.net>
	 <AEC29013-98F3-4A16-A88B-AD31C9E88EB8@bootc.net>
	 <1324528656.2621.19.camel@edumazet-laptop>
	 <20111222063806.GP6348@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chris Boot <bootc@bootc.net>, lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:36040 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914Ab1LVHvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 02:51:23 -0500
In-Reply-To: <20111222063806.GP6348@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 d=C3=A9cembre 2011 =C3=A0 07:38 +0100, Steffen Klassert a =C3=
=A9crit :
> On Thu, Dec 22, 2011 at 05:37:36AM +0100, Eric Dumazet wrote:
> > Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 23:12 +0000, Chris Boot a =
=C3=A9crit :
> > >=20
> > > (gdb) list *ip_fragment+0x9d
> > > 0xffffffff812a62e1 is in ip_fragment (include/net/dst.h:209).
> > > 204		return dst_metric(dst, RTAX_FEATURES) & feature;
> > > 205	}
> > > 206=09
> > > 207	static inline u32 dst_mtu(const struct dst_entry *dst)
> > > 208	{
> > > 209		return dst->ops->mtu(dst);
> > > 210	}
> > > 211=09
> > > 212	/* RTT metrics are stored in milliseconds for user ABI, but u=
sed as jiffies */
> >=20
> > This one is different, its not IPv6 related but IPv4 :
> >=20
> > fake_dst_ops lacks a .mtu() field
> >=20
> > Bug added in commit 618f9bc74a039da76 (net: Move mtu handling down =
to
> > the protocol depended handlers)
> >=20
>=20
> Before I did this patch, I changed the .default_mtu field of "struct =
dst_ops"
> to .mtu and converted all users of default_mtu to mtu. fake_dst_ops n=
ever
> had a default_mtu field, so I did not touch it. I guess this bug is a=
rround
> since fake_dst_ops exists. It's now just much easier to trigger as co=
mmit
> 618f9bc74a039da76 changed dst_mtu() to call dst->ops->mtu() unconditi=
onally.

I dont think so.

Prior to 618f9bc74a0, we were calling=20

static inline u32 dst_mtu(const struct dst_entry *dst)
 {
       u32 mtu =3D dst_metric_raw(dst, RTAX_MTU);

       if (!mtu)
               mtu =3D dst->ops->mtu(dst);

       return mtu;
}

with dst =3D fake_rtable

and we did :

dst_init_metrics(&rt->dst, br_dst_default_metrics, true);

so dst_metric_raw(dst, RTAX_MTU) was returning 1500

So bug is new, we dont need to backport this fix.
