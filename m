From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v2] tcp: TCP Small Queues
Date: Tue, 10 Jul 2012 20:32:00 +0200
Message-ID: <1341945120.3265.6030.camel@edumazet-glaptop>
References: <CAA93jw7ywd0auqN=k2J4fLOGYMLRH+agWr4P+_CisgvRtvgJUw@mail.gmail.com>
	 <1340945457.29822.7.camel@edumazet-glaptop>
	 <1341396687.2583.1757.camel@edumazet-glaptop>
	 <20120709.000834.1182150057463599677.davem@davemloft.net>
	 <1341845722.3265.3065.camel@edumazet-glaptop>
	 <1341933215.3265.5476.camel@edumazet-glaptop>
	 <CAK6E8=eXMBzG=Zo0N8KWQSNaoekAqAh5N5eY2gE7+BYKJLaOQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dave.taht@gmail.com,
	netdev@vger.kernel.org, codel@lists.bufferbloat.net,
	therbert@google.com, mattmathis@google.com, nanditad@google.com,
	ncardwell@google.com, andrewmcgr@gmail.com
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:39400 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069Ab2GJScG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 14:32:06 -0400
Received: by eeit10 with SMTP id t10so119110eei.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 11:32:04 -0700 (PDT)
In-Reply-To: <CAK6E8=eXMBzG=Zo0N8KWQSNaoekAqAh5N5eY2gE7+BYKJLaOQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-10 at 10:37 -0700, Yuchung Cheng wrote:
> On Tue, Jul 10, 2012 at 8:13 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> > +
> > +               if (!sock_owned_by_user(sk)) {
> > +                       if ((1 << sk->sk_state) &
> > +                           (TCPF_CLOSE_WAIT | TCPF_ESTABLISHED))
> > +                               tcp_write_xmit(sk,
> > +                                              tcp_current_mss(sk),
> > +                                              0, 0,
> > +                                              GFP_ATOMIC);
> Is this case possible: app does a large send and immediately closes
> the socket. then
> the queue is throttled and tcp_write_xmit is called back when state is
> in TCP_FIN_WAIT1.
> 
> I think tcp_write_xmit should continue regardless of the current state
> because the
> send maybe throttled/delayed but state change is synchronous.
> 

I need testing some allowed states, I think.

Maybe I missed some states, but I dont think we should call
tcp_write_xmit() if socket is now in TIMEWAIT state ?

(because of tasklet delay, we might handle TX completion _after_ socket
state change)
