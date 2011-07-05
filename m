From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [RFC] non-preemptible kernel socket for RAMster
Date: Tue, 05 Jul 2011 20:23:59 +0200
Message-ID: <1309890239.2545.10.camel@edumazet-laptop>
References: <4232c4b6-15be-42d8-be42-6e27f9188ce2@default 1309883430.2271.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <918f7b76-4904-41cc-9f55-c07adafb34b4@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Konrad Wilk <konrad.wilk@oracle.com>,
	linux-mm <linux-mm@kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39255 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354Ab1GESYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 14:24:04 -0400
Received: by wyg8 with SMTP id 8so4183011wyg.19
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 11:24:02 -0700 (PDT)
In-Reply-To: <918f7b76-4904-41cc-9f55-c07adafb34b4@default>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 juillet 2011 =C3=A0 10:25 -0700, Dan Magenheimer a =C3=A9cr=
it :
> > From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> > Sent: Tuesday, July 05, 2011 10:31 AM
> > To: Dan Magenheimer
> > Cc: netdev@vger.kernel.org; Konrad Wilk; linux-mm
> > Subject: Re: [RFC] non-preemptible kernel socket for RAMster
> >=20
> > Le mardi 05 juillet 2011 =C3=A0 08:54 -0700, Dan Magenheimer a =C3=A9=
crit :
> > > In working on a kernel project called RAMster* (where RAM on a
> > > remote system may be used for clean page cache pages and for swap
> > > pages), I found I have need for a kernel socket to be used when
> > > in non-preemptible state.  I admit to being a networking idiot,
> > > but I have been successfully using the following small patch.
> > > I'm not sure whether I am lucky so far... perhaps more
> > > sockets or larger/different loads will require a lot more
> > > changes (or maybe even make my objective impossible).
> > > So I thought I'd post it for comment.  I'd appreciate
> > > any thoughts or suggestions.
> > >
> > > Thanks,
> > > Dan
> > >
> > > * http://events.linuxfoundation.org/events/linuxcon/magenheimer
> > >
> > > diff -Napur linux-2.6.37/net/core/sock.c linux-2.6.37-ramster/net=
/core/sock.c
> > > --- linux-2.6.37/net/core/sock.c	2011-07-03 19:14:52.267853088 -0=
600
> > > +++ linux-2.6.37-ramster/net/core/sock.c	2011-07-03 19:10:04.3409=
80799 -0600
> > > @@ -1587,6 +1587,14 @@ static void __lock_sock(struct sock *sk)
> > >  	__acquires(&sk->sk_lock.slock)
> > >  {
> > >  	DEFINE_WAIT(wait);
> > > +	if (!preemptible()) {
> > > +		while (sock_owned_by_user(sk)) {
> > > +			spin_unlock_bh(&sk->sk_lock.slock);
> > > +			cpu_relax();
> > > +			spin_lock_bh(&sk->sk_lock.slock);
> > > +		}
> > > +		return;
> > > +	}
> >=20
> > Hmm, was this tested on UP machine ?
>=20
> Hi Eric --
>=20
> Thanks for the reply!
>=20
> I hadn't tested UP in awhile so am testing now, and it seems to
> work OK so far.  However, I am just testing my socket, *not* testing
> sockets in general.  Are you implying that this patch will
> break (kernel) sockets in general on a UP machine?  If so,
> could you be more specific as to why?  (Again, I said
> I am a networking idiot. ;-)  I played a bit with adding
> a new SOCK_ flag and triggering off of that, but this
> version of the patch seemed much simpler.

Say you have two processes and socket S

One process locks socket S, and is preempted by another process.

This second process is non preemptible and try to lock same socket.

-> deadlock, since P1 never releases socket S



