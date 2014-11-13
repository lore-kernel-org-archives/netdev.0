From: Luis Henriques <luis.henriques@canonical.com>
Subject: Re: [PATCH] net: skb_fclone_busy() needs to detect orphaned skb
Date: Thu, 13 Nov 2014 22:32:41 +0000
Message-ID: <20141113223241.GA4867@hercules>
References: <1414690354.9028.9.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141113191502.GC7095@hercules>
 <1415913622.17262.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Joseph Salisbury <joseph.salisbury@canonical.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:45112 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933065AbaKMWcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 17:32:50 -0500
Content-Disposition: inline
In-Reply-To: <1415913622.17262.24.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 13, 2014 at 01:20:22PM -0800, Eric Dumazet wrote:
> On Thu, 2014-11-13 at 19:15 +0000, Luis Henriques wrote:
> > Hi Eric,
> >=20
> > On Thu, Oct 30, 2014 at 10:32:34AM -0700, Eric Dumazet wrote:
> > > From: Eric Dumazet <edumazet@google.com>
> > >=20
> > > Some drivers are unable to perform TX completions in a bound time=
=2E
> > > They instead call skb_orphan()
> > >=20
> > > Problem is skb_fclone_busy() has to detect this case, otherwise
> > > we block TCP retransmits and can freeze unlucky tcp sessions on
> > > mostly idle hosts.
> > >=20
> > > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > > Fixes: 1f3279ae0c13 ("tcp: avoid retransmits of TCP packets hangi=
ng in host queues")
> > > ---
> > >  This is a stable candidate.
> > >  This problem is known to hurt users of linux-3.16 kernels used b=
y guests kernels.
> > >  David, I can provide backports if you want.
> > >  Thanks !
> > >=20
> >=20
> > We got a bug report[0] where a backport for 3.16 was provided.  Sin=
ce
> > I couldn't find the original backport post, I'm not sure who's the
> > actual author.  Could you please confirm if this backport is correc=
t?
> > (I'm copying the patch below).
> >=20
> > [0] https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1390604
> >=20
> > Cheers,
> > --
> > Lu=EDs
> >=20
> >=20
>=20
> Sure ! I provided this patch indeed, I am 'The Google engineer'
> mentioned in this bug report ;)
>=20

Awesome, Thanks!  I'll queue it for the 3.16 kernel.  Since I couldn't
find the original patch, I could only guess who 'The Google engineer'
was :-)

Cheers,
--
Lu=EDs

> Signed-off-by: Eric Dumazet <edumazet@google.com>
>=20
>=20
> Thanks !
>=20
> > diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> > index 4e4932b5079b..a8794367cd20 100644
> > --- a/net/ipv4/tcp_output.c
> > +++ b/net/ipv4/tcp_output.c
> > @@ -2082,7 +2082,8 @@ static bool skb_still_in_host_queue(const str=
uct sock *sk,
> >  	const struct sk_buff *fclone =3D skb + 1;
> > =20
> >  	if (unlikely(skb->fclone =3D=3D SKB_FCLONE_ORIG &&
> > -		     fclone->fclone =3D=3D SKB_FCLONE_CLONE)) {
> > +		     fclone->fclone =3D=3D SKB_FCLONE_CLONE &&
> > +		     fclone->sk =3D=3D sk)) {
> >  		NET_INC_STATS_BH(sock_net(sk),
> >  				 LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES);
> >  		return true;
>=20
>=20
>=20
>=20
