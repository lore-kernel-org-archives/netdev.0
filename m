From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inetpeer: ensure to set the maximum tokens the first
 time
Date: Thu, 27 Sep 2012 15:30:00 +0200
Message-ID: <1348752600.5093.1275.camel@edumazet-glaptop>
References: <1348749237-3919-1-git-send-email-nicolas.dichtel@6wind.com>
	 <1348750405.5093.1234.camel@edumazet-glaptop>  <506452F3.4090409@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44786 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591Ab2I0NaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 09:30:05 -0400
Received: by bkcjk13 with SMTP id jk13so1782348bkc.19
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 06:30:04 -0700 (PDT)
In-Reply-To: <506452F3.4090409@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-27 at 15:21 +0200, Nicolas Dichtel wrote:
> Le 27/09/2012 14:53, Eric Dumazet a =C3=A9crit :
> > On Thu, 2012-09-27 at 14:33 +0200, Nicolas Dichtel wrote:
> >> When jiffies wraps around (for example, 5 minutes after the boot, =
see
> >> INITIAL_JIFFIES) and peer has just been created, now - peer->rate_=
last can be
> >> < XRLIM_BURST_FACTOR * timeout, so token is not set to the maximum=
 value, thus
> >> some icmp packets can be unexpectedly dropped.
> >>
> >> With this patch, it's still possible that last_rate and rate_token=
s are 0 at the
> >> same time after jiffies wraps round, but the probability is very l=
ow and the
> >> only consequence is to let some ICMP packets bypass the filter.
> >>
> >> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> >> ---
> >>   net/ipv4/inetpeer.c | 10 +++++++---
> >>   1 file changed, 7 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
> >> index e1e0a4e..92fec02 100644
> >> --- a/net/ipv4/inetpeer.c
> >> +++ b/net/ipv4/inetpeer.c
> >> @@ -559,10 +559,14 @@ bool inet_peer_xrlim_allow(struct inet_peer =
*peer, int timeout)
> >>
> >>   	token =3D peer->rate_tokens;
> >>   	now =3D jiffies;
> >> -	token +=3D now - peer->rate_last;
> >> -	peer->rate_last =3D now;
> >> -	if (token > XRLIM_BURST_FACTOR * timeout)
> >> +	if (!peer->rate_last && !token)
> >>   		token =3D XRLIM_BURST_FACTOR * timeout;
> >> +	else {
> >> +		token +=3D now - peer->rate_last;
> >> +		if (token > XRLIM_BURST_FACTOR * timeout)
> >> +			token =3D XRLIM_BURST_FACTOR * timeout;
> >> +	}
> >> +	peer->rate_last =3D now;
> >>   	if (token >=3D timeout) {
> >>   		token -=3D timeout;
> >>   		rc =3D true;
> >
> >
> > I am sorry I dont understand your patch at all.
> >
> > Why not init rate_last to a more sensible value ?
> >
> > diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
> > index e1e0a4e..25ed555 100644
> > --- a/net/ipv4/inetpeer.c
> > +++ b/net/ipv4/inetpeer.c
> > @@ -510,7 +510,7 @@ relookup:
> >   					secure_ipv6_id(daddr->addr.a6));
> >   		p->metrics[RTAX_LOCK-1] =3D INETPEER_METRICS_NEW;
> >   		p->rate_tokens =3D 0;
> > -		p->rate_last =3D 0;
> > +		p->rate_last =3D jiffies;
> inet_getpeer(...,1) is called just before inet_peer_xrlim_allow().
> So the result in inet_peer_xrlim_allow():
>     	token =3D peer->rate_tokens; =3D> 0
>     	now =3D jiffies;
> 	token +=3D now - peer->rate_last; =3D> token +=3D jiffies - jiffies =
=3D> 0
> So we have no token and packet is dropped.
>=20
> Am I wrong?

So find the right initializer ?

p->rate_last =3D jiffies;
p->rate_tokens =3D TOKENS_INIT;
