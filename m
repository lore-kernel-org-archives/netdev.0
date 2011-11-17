From: Flavio Leitner <fbl@redhat.com>
Subject: Re: Unable to flush ICMP redirect routes in kernel 3.0+
Date: Thu, 17 Nov 2011 11:11:45 -0200
Message-ID: <20111117111145.252924f5@asterix.rh>
References: <4EC2CA52.6020104@icdsoft.com>
	<1321391355.2602.0.camel@edumazet-laptop>
	<4EC439F2.3080809@icdsoft.com>
	<20111116223330.08de9e52@asterix.rh>
	<4EC4C160.6010804@icdsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ivan Zahariev <famzah@icdsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20955 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756345Ab1KQNLu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 08:11:50 -0500
In-Reply-To: <4EC4C160.6010804@icdsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Nov 2011 10:10:08 +0200
Ivan Zahariev <famzah@icdsoft.com> wrote:

> On 17.11.2011 =D0=B3. 02:33 =D1=87., Flavio Leitner wrote:
> > On Thu, 17 Nov 2011 00:32:18 +0200
> > Ivan Zahariev<famzah@icdsoft.com>  wrote:
> >
> >> On 11/15/2011 11:09 PM, Eric Dumazet wrote:
> >>> Le mardi 15 novembre 2011 =C3=A0 22:23 +0200, Ivan Zahariev a =C3=
=A9crit :
> >>>> Hello,
> >>>>
> >>>> We have changed nothing in our network infrastructure but only
> >>>> upgraded from Linux kernel 2.6.36.2 to 3.0.3. Here is the proble=
m
> >>>> we are experiencing:
> >>>>
> >>>> ICMP redirected routes are cached forever, and they can be
> >>>> cleared only by a reboot.
> >>>>
> >> ### (bug #1) even though we flushed the route cache,
> >> the<redirected> route resurrects from somewhere; even without
> >> making any TCP requests ### this time what "ip" returns is
> >> consistent with the real (incorrect) routing behavior of machine5
> >> root@machine5:~# ip route flush cache
> >> root@machine5:~# ip route list cache match 8.8.4.4
> >> root@machine5:~# ip route get 8.8.4.4
> >> 8.8.4.4 via 192.168.0.120 dev eth0  src 192.168.0.244
> >>       cache<redirected>   ipid 0x303a
> >>
> >> ### only a reboot clears the cached<redirected>  routes
> > IIRC, the cache flush doesn't affect the inetpeer where the
> > redirected gateway is now stored, so even after flushing the
> > route cache, the inetpeer will restore the old info later.
> >
> > fbl
> OK, I guess my questions now are:
> * How to flush the inetpeer (redirected cache info) without having to=
=20
> reboot the machine?

It will expire after 10min if you don't use that specific host.

> * Why "ip route" returns an incorrect route; example:

I am sorry for not being clear before. It is a bug, indeed.
=20
> ### (bug #2) what "ip route" returns is inconsistent, because we are=20
> using the <redirected> route 192.168.0.120 in reality
> ### note that the count of the route lines increased with one
> root@machine5:~# ip route list cache match 8.8.4.4
> 8.8.4.4 from 192.168.0.244 tos lowdelay via 192.168.0.8 dev eth0
>      cache  ipid 0x303a
> 8.8.4.4 tos lowdelay via 192.168.0.8 dev eth0  src 192.168.0.244
>      cache  ipid 0x303a
> 8.8.4.4 via 192.168.0.8 dev eth0  src 192.168.0.244
>      cache
> 8.8.4.4 from 192.168.0.244 tos lowdelay via 192.168.0.8 dev eth0
>      cache  ipid 0x303a
>=20
> ### After "ip route flush cache", the output of "ip route" gets=20
> consistent with the real routing behavior of machine5
> root@machine5:~# ip route flush cache
> root@machine5:~# ip route list cache match 8.8.4.4
> root@machine5:~# ip route get 8.8.4.4
> 8.8.4.4 via 192.168.0.120 dev eth0  src 192.168.0.244
>      cache <redirected>  ipid 0x303a
>=20

Now the redirected gateway is stored in inetpeer which represents
an specific peer.  In your case, you have one for 8.8.4.4.

When you flush the routing cache everything is flushed, except for
the inetpeer as far as I can tell.  Later, when you try to access
the host 8.8.4.4 again, the lookup will create a fresh route but
also find the previous 8.8.4.4 inetpeer, so it will re-use the
previous redirected gateway.

Therefore, the routing is fine, but it is missing a way to
invalidade or expire all related inetpeer entries when the flush
happens.

The inetpeer will expire eventually, so waiting before trying again
would help to work around:

1) flush
2) wait to expire (10min)
3) try again

If you know how to compile a kernel, try to change these thresholds
below to expire faster, then you have to wait less for it to expire
instead of rebooting.

net/ipv4/inetpeer.c:
int inet_peer_minttl __read_mostly =3D 120 * HZ;  /* TTL under high loa=
d:
120 sec */ int inet_peer_maxttl __read_mostly =3D 10 * 60 * HZ;      /*
usual time to live: 10 min */                          =20

That above is just a workaround, indeed.

I am going to be on vacations in the next couple weeks, so I won't be
able to help fixing this any time soon. However, I am pretty sure
someone else will help though :)

fbl
