From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] non-preemptible kernel socket for RAMster
Date: Tue, 5 Jul 2011 12:07:10 -0700 (PDT)
Message-ID: <d3199429-87d1-4917-bf1d-be1fbbc1e64f@default>
References: <4232c4b6-15be-42d8-be42-6e27f9188ce2@default>
 <1309883430.2271.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <918f7b76-4904-41cc-9f55-c07adafb34b4@default
 1309890239.2545.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, Konrad Wilk <konrad.wilk@oracle.com>,
	linux-mm <linux-mm@kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:39558 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124Ab1GETHg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 15:07:36 -0400
In-Reply-To: <1309890239.2545.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > > +++ linux-2.6.37-ramster/net/core/sock.c	2011-07-03 19:10:04.340980799 -0600
> > > > @@ -1587,6 +1587,14 @@ static void __lock_sock(struct sock *sk)
> > > >  	__acquires(&sk->sk_lock.slock)
> > > >  {
> > > >  	DEFINE_WAIT(wait);
> > > > +	if (!preemptible()) {
> > > > +		while (sock_owned_by_user(sk)) {
> > > > +			spin_unlock_bh(&sk->sk_lock.slock);
> > > > +			cpu_relax();
> > > > +			spin_lock_bh(&sk->sk_lock.slock);
> > > > +		}
> > > > +		return;
> > > > +	}
> > >
> > > Hmm, was this tested on UP machine ?
> >
> > Hi Eric --
> >
> > Thanks for the reply!
> >
> > I hadn't tested UP in awhile so am testing now, and it seems to
> > work OK so far.  However, I am just testing my socket, *not* testing
> > sockets in general.  Are you implying that this patch will
> > break (kernel) sockets in general on a UP machine?  If so,
> > could you be more specific as to why?  (Again, I said
> > I am a networking idiot. ;-)  I played a bit with adding
> > a new SOCK_ flag and triggering off of that, but this
> > version of the patch seemed much simpler.
> 
> Say you have two processes and socket S
> 
> One process locks socket S, and is preempted by another process.
> 
> This second process is non preemptible and try to lock same socket.
> 
> -> deadlock, since P1 never releases socket S

Oh, OK.  My use model is that a socket that is used non-preemptible
must always be used non-preemptible.  In other words, this kind
of socket is an extreme form of non-blocking.  Doesn't that seem
like a reasonable constraint? 

Thanks,
Dan
