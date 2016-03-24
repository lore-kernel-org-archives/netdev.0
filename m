From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Thu, 24 Mar 2016 17:50:47 +0100
Message-ID: <20160324165047.GA7585@1wt.eu>
References: <20151219070009.GA4634@1wt.eu>
 <CALx6S35248apbWqtG+g2U99O=4UJqyAG0bJeuxhZWtShrpDF+w@mail.gmail.com>
 <20151221204127.GC8018@1wt.eu>
 <CALmu+SwjG0GVocGufTbgX-WJfcsP85SvHB=xtW7qQX3kZwJCxg@mail.gmail.com>
 <20160324061222.GA6807@1wt.eu>
 <1458828813.10868.65.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160324142222.GB7237@1wt.eu>
 <1458830744.10868.72.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160324153053.GA7569@1wt.eu>
 <1458837191.12033.4.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tolga Ceylan <tolga.ceylan@gmail.com>,
	Tom Herbert <tom@herbertland.com>, cgallek@google.com,
	Josh Snyder <josh@code406.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:32118 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756152AbcCXQvC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2016 12:51:02 -0400
Content-Disposition: inline
In-Reply-To: <1458837191.12033.4.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2016 at 09:33:11AM -0700, Eric Dumazet wrote:
> > --- a/net/ipv4/inet_hashtables.c
> > +++ b/net/ipv4/inet_hashtables.c
> > @@ -189,6 +189,8 @@ static inline int compute_score(struct sock *sk, struct net *net,
> >                                 return -1;
> >                         score += 4;
> >                 }
> > +               if (sk->sk_reuseport)
> > +                       score++;
> 
> This wont work with BPF
> 
> >                 if (sk->sk_incoming_cpu == raw_smp_processor_id())
> >                         score++;
> 
> This one does not work either with BPF

But this *is* in 4.5. Does this mean that this part doesn't work anymore or
just that it's not usable in conjunction with BPF ? In this case I'm less
worried, because it would mean that we have a solution for non-BPF aware
applications and that BPF-aware applications can simply use BPF.

> Whole point of BPF was to avoid iterate through all sockets [1],
> and let user space use whatever selection logic it needs.
> 
> [1] This was okay with up to 16 sockets. But with 128 it does not scale.

Indeed.

> If you really look at how BPF works, implementing another 'per listener' flag
> would break the BPF selection.

OK.

> You can certainly implement the SO_REUSEPORT_LISTEN_OFF by loading an
> updated BPF, why should we add another way in the kernel to do the same,
> in a way that would not work in some cases ?

I don't try to reimplement something already available, but I'm confused
by a few points :
  - the code above already exists and you mention it cannot be used with BPF
  - for the vast majority of applications not using BPF, would the above *still*
    work (it worked in 4.4-rc at least)
  - it seems to me that for BPF to be usable on process shutting down, we'd
    need to have some form of central knowledge if the goal is to redefine
    how to distribute the load. In my case there are multiple independant
    processes forked on startup, so it's unclear to me how each of them could
    reconfigure BPF when shutting down without risking to break the other ones.
  - the doc makes me believe that BPF would require privileges to be unset, so
    that would not be compatible with a process shutting down which has already
    dropped its privileges after startup, but I could be wrong.

Thanks for your help on this,
Willy
