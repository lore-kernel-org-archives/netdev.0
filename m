From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP syn flood handling regression
Date: Sat, 10 Mar 2012 09:56:22 -0800
Message-ID: <1331402182.2453.30.camel@edumazet-laptop>
References: <20120310122725.GA31129@hostway.ca>
	 <1331401490.2453.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Simon Kirby <sim@netnation.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:55807 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447Ab2CJR43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2012 12:56:29 -0500
Received: by wibhq7 with SMTP id hq7so1825944wib.1
        for <netdev@vger.kernel.org>; Sat, 10 Mar 2012 09:56:28 -0800 (PST)
In-Reply-To: <1331401490.2453.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 10 mars 2012 =C3=A0 09:44 -0800, Eric Dumazet a =C3=A9crit :
> Le samedi 10 mars 2012 =C3=A0 04:27 -0800, Simon Kirby a =C3=A9crit :
> > Hello!
> >=20
> > A typical port 80 SYN flood started up to one of our clusters, but =
this
> > time, it didn't work so well. Legitimate connections and trying to =
fetch
> > server-status via localhost would hang for ~30 seconds before respo=
nding,
> > even though though the box had plenty of spare cycles. An strace of=
 all
> > Apache processes showed quite a bit of sleeping in accept4().
> >=20
> > This was with 3.2.9, so I went back in kernel builds and found that=
 3.1
> > and 3.0 were also broken, while 2.6.39 works as I remember -- when =
syn
> > cookies are enabled, everything just works and is fast. The DoS kep=
t up,
> > so I was able to feed a bit to a node to do some bisection.
> >=20
> > Of course, the DoS stopped literally seconds before the last bisect=
ion
> > test, but I got it down to:
> >=20
> > # good: [0e734419923bd8e599858f8fc196c7804bb85564] ipv4: Use inet_c=
sk_route_child_sock() in DCCP and TCP.
> > # bad: [ea4fc0d6193ff56fcef39b0d2210d402a7acb5f0] ipv4: Don't use r=
t->rt_{src,dst} in ip_queue_xmit().
> >=20
> > ...leaving ea4fc0d6193ff56fcef39b0d2210d402a7acb5f0 and
> > d9d8da805dcb503ef8ee49918a94d49085060f23 as culprits.
> >=20
> > I've stared at them but can't see what could be doing this.
> >=20
>=20
> Hi Simon, thanks a lot for this report.
>=20
> This sounds as a SYNCOOKIE side effect
>=20

It seems we miss a rebuild_header() indeed in the case of a syncookie
initiated socket.

So inet->cork.fl.u.ip4 is not correctly setup and
ea4fc0d6193ff56fcef39b0d2210d402a7acb5f relied on this.

I'll send a patch once tested.
