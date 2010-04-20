From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: IPv6: race condition in __ipv6_ifa_notify() and dst_free() ?
Date: Tue, 20 Apr 2010 22:49:39 +0200
Message-ID: <20100420204939.GA15354@smudla-wifi.bakulak.kosire.czf>
References: <20100420174401.GB1334@midget.suse.cz>
 <1271786247.7895.130.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Bohac <jbohac@suse.cz>, netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:33082 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754666Ab0DTUtK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Apr 2010 16:49:10 -0400
Content-Disposition: inline
In-Reply-To: <1271786247.7895.130.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 20, 2010 at 07:57:27PM +0200, Eric Dumazet wrote:
> Le mardi 20 avril 2010 =E0 19:44 +0200, Jiri Bohac a =E9crit :
> > --- a/net/ipv6/addrconf.c	2010-04-17 00:12:32.000000000 +0200
> > +++ b/net/ipv6/addrconf.c	2010-04-20 19:07:35.000000000 +0200
> > @@ -3974,8 +3974,7 @@ static void __ipv6_ifa_notify(int event,
> >  			addrconf_leave_anycast(ifp);
> >  		addrconf_leave_solict(ifp->idev, &ifp->addr);
> >  		dst_hold(&ifp->rt->u.dst);
> > -		if (ip6_del_rt(ifp->rt))
> > -			dst_free(&ifp->rt->u.dst);
> > +		ip6_del_rt(ifp->rt);
> >  		break;
> >  	}
> >  }
> >=20
>=20
>=20
> I dont understand the problem Jiri.
>=20
> We just did dst_hold(&ifp->rt->u.dst), so if ip6_del_rt() fails we mu=
st
> dst_free(), or we leak a refcount.

Well, no ... dst_free() does not decrement the refcount.
The "opposite" of dst_hold() is dst_release(). And it does not
automatically call dst_free() when the refcount drops to 0.
dst_free() needs to be called explicitly and it apparently
expects the caller to ensure that two dst_free()s won't be called
simultaneously. But my bonding example shows this is not the
case.


--=20
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

