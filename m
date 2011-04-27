From: "George B." <georgeb@gmail.com>
Subject: Re: 'tcp: bind() fix when many ports are bound' problem
Date: Wed, 27 Apr 2011 10:36:45 -0700
Message-ID: <BANLkTik5-G2E+SKX2anv2t5+gJzd2WEp3Q@mail.gmail.com>
References: <AANLkTimrpZOWEc5qXPEbrJbt2Nmh2vY69aC1Dwf1cCPH@mail.gmail.com>
	<AANLkTinNcds1EAnWXOX6wAjg+wv4O=Xd65hHEGWoGos8@mail.gmail.com>
	<1294140172.3579.81.camel@edumazet-laptop>
	<AANLkTimuNM7vmeR89WKXtrUbJO1Wt1ivp9y=bQvtWg0j@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Daniel Baluta <daniel.baluta@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55921 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759707Ab1D0Rgr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 13:36:47 -0400
Received: by wwa36 with SMTP id 36so2155738wwa.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 10:36:45 -0700 (PDT)
In-Reply-To: <AANLkTimuNM7vmeR89WKXtrUbJO1Wt1ivp9y=bQvtWg0j@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 5, 2011 at 1:00 AM, Daniel Baluta <daniel.baluta@gmail.com>=
 wrote:
>
> On Tue, Jan 4, 2011 at 1:22 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > Le mardi 04 janvier 2011 =E0 13:12 +0400, Gaspar Chilingarov a =E9c=
rit :
> >> Hi there!
> >>
> >> Well, that looks strange.
> >>
> >> On my own side I've just put workaround (manually binding to all p=
orts
> >> in sequence :)
> >> and moved production code to FreeBSD as it has better scalable net=
work stack.
> >>
> >> I can see the potential problem with that bind() problem on highly
> >> loaded DNS servers/resolvers which establish tons of outgoing UDP
> >> connections.
> >>
> >> In some cases that connections could fail and as not receiving the
> >> answer it is normal condition for DNS this will go totally unnotic=
ed.
> >>
> >> I don't think anyone will hit this bug in production environment
> >> except the very high load applications.
> >
> > Dont mix TCP and UDP, they are not the same.
> >
> > Problem with TCP is you can have TIME_WAIT sockets, disallowing a p=
ort
> > to be reused. Not with UDP.
>
> Isn't SO_REUSEADDR supposed to fix this problem?
>
> Anyhow, inet_csk_get_port the function used by bind(0) performs bad.
>
> Short reminder:
> 100 IP addr =A0- 70K sockets created =3D> 700 sockets per IP.
> bind(0) for all sockets will results in a large number of
> (port, addr) duplicates although there are more than 30000 ports avai=
lable.
>
> This wouldn't be so bad if you won't try to connect duplicates to the=
 same
> remote (addr, port) which will result in a connect failure.
>
> Eric's patch introduced the restriction 'forbid two reuse enabled soc=
kets
> to bind on same (addr, port) tuple with a (non ANY addr)'.
>
> Well, I think this will break rule #2 from inet_hastable.h:
> "
> If all sockets have sk->sk_reuse set, and none of them are in
> TCP_LISTEN state, the port may be shared.
> "
> and also caused problem ([1]), don't really know if they are the same=
=2E
>
> An attempt, to fix this was to "always allow a reuse listen if
> no other listen is already active on the same IP".
>
> The problem with this fix, is that at the moment of bind() we
> don't know what will be the usage of this socket. It can be,
> bind -> connect or bind -> listen.
> >
> > The connect() [without a previous bind()], or a sendto() [without a
> > previous bind()] problem is more an API problem.
>
> Can you share your thoughts on this?
>
> Going back to my first email, are there any follow ups on your
> "tcp: bind() fix when many ports are bound" patch. I've searched
> netdev archives but no luck. I might have missed something.
>
> I really appreciate your help.
>
> thanks,
> Daniel.
> --

This is also causing a problem for me in a very high load application
where more than 64K sockets are being sourced from multiple IP
addresses.

I, too, would like to know if this has been followed up on.=A0 The old
patch that was reverted was actually working well for us, we never
actually hit the TIME_WAIT problem but we are hitting the problem of
not being able to source a connection from an IP when the global
number of connections is >64K or so.
