From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v4] IPv6: use anycast addresses as source addresses in echo reply
Date: Mon, 6 Jan 2014 16:52:53 +0100
Message-ID: <20140106155253.GA10204@order.stressinduktion.org>
References: <20140106105614.GB4611@order.stressinduktion.org> <1389016096.57230.YahooMailBasic@web125502.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: =?utf-8?Q?Fran=C3=A7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42455 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754973AbaAFPwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 10:52:54 -0500
Content-Disposition: inline
In-Reply-To: <1389016096.57230.YahooMailBasic@web125502.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 06, 2014 at 05:48:16AM -0800, Fran=C3=A7ois-Xavier Le Bail =
wrote:
> On Mon, 1/6/14, Hannes Frederic Sowa <hannes@stressinduktion.org> wro=
te:
>=20
> > On Mon, Jan 06, 2014 at 02:41:41AM -0800, Fran=C3=A7ois-Xavier Le B=
ail wrote:
> > > On Sun, 1/5/14, Hannes Frederic Sowa <hannes@stressinduktion.org>=
 wrote:
> > >=20
> > > > On Fri, Jan 03, 2014 at 05:43:31PM +0100, Francois-Xavier Le Ba=
il wrote:
> > > > > diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
> > > > > index 5d42009..65c8619 100644
> > > > > --- a/net/ipv6/icmp.c
> > > > > +++ b/net/ipv6/icmp.c
> > > > > @@ -556,7 +556,9 @@ static void icmpv6_echo_reply(struct sk_b=
uff *skb)
> > > > > =20
> > > > >  	saddr =3D &ipv6_hdr(skb)->daddr;
> > > > > =20
> > > > > -	if (!ipv6_unicast_destination(skb))
> > > > > +	if (!ipv6_unicast_destination(skb) &&
> > > > > +	    !(net->ipv6.anycast_src_echo_reply &&
> > > > > +	      ipv6_chk_acast_addr(net, NULL, saddr)))
> > > > >  		saddr =3D NULL;
> > >=20
> > > > I am not sure why you left out the device at ipv6_chk_acast_add=
r?
> > >=20
> > > > IMHO this logic is a bit more complex, we can pass NULL for ipv=
6 addresses of
> > > > scope global but need to check the interface for scope link.
> > >=20
> > > > It is already possible via setsockopt JOIN_ANYCAST that an ll a=
ddress is
> > > > anycast on another interface which may not be checked here.
> > >=20
> > > In this case, there are neighbor solicitations "who has LL anycas=
t" with no reply, so no echo request is sent.
> >=20
> > A counter-example would be NOARP interfaces where we also don't spe=
ak ndisc.
>=20
> Right. But if an echo request arrive on an interface which do not lis=
ten at this LL anycast, is a reply can occur ?

I thought quite the opposite with anycast + forwarding enabled, that
we would process the packet. But a quick test with this snippet showed =
no
problems on a tunnel router. Local input is ok, too.

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <net/if.h>

int main(int argc, char **argv)
{
  struct ipv6_mreq mreq =3D {0};
  int sockfd=3Dsocket(AF_INET6, SOCK_DGRAM,0);
  inet_pton(AF_INET6, "fe80::AAAA", &mreq.ipv6mr_multiaddr);
  mreq.ipv6mr_interface =3D if_nametoindex("dummy0");
  setsockopt(sockfd, IPPROTO_IPV6, IPV6_JOIN_ANYCAST, &mreq, sizeof(mre=
q));
  pause();
}

I guess, I would have added skb->dev for the sake of defensive style
(and maybe performance, if tables get large). I have not tested that
and it's your choice (or Davids, of course). But I currently don't see
a reason why it should break. ;)

Greetings,

  Hannes
