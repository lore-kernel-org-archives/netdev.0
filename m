From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Thu, 24 Mar 2016 10:01:37 -0700
Message-ID: <1458838897.12033.10.camel@edumazet-glaptop3.roam.corp.google.com>
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
	 <20160324165047.GA7585@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tolga Ceylan <tolga.ceylan@gmail.com>,
	Tom Herbert <tom@herbertland.com>, cgallek@google.com,
	Josh Snyder <josh@code406.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33553 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313AbcCXRBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 13:01:40 -0400
Received: by mail-pf0-f182.google.com with SMTP id 4so62998650pfd.0
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 10:01:40 -0700 (PDT)
In-Reply-To: <20160324165047.GA7585@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-03-24 at 17:50 +0100, Willy Tarreau wrote:
> On Thu, Mar 24, 2016 at 09:33:11AM -0700, Eric Dumazet wrote:
> > > --- a/net/ipv4/inet_hashtables.c
> > > +++ b/net/ipv4/inet_hashtables.c
> > > @@ -189,6 +189,8 @@ static inline int compute_score(struct sock *sk, struct net *net,
> > >                                 return -1;
> > >                         score += 4;
> > >                 }
> > > +               if (sk->sk_reuseport)
> > > +                       score++;
> > 
> > This wont work with BPF
> > 
> > >                 if (sk->sk_incoming_cpu == raw_smp_processor_id())
> > >                         score++;
> > 
> > This one does not work either with BPF
> 
> But this *is* in 4.5. Does this mean that this part doesn't work anymore or
> just that it's not usable in conjunction with BPF ? In this case I'm less
> worried, because it would mean that we have a solution for non-BPF aware
> applications and that BPF-aware applications can simply use BPF.
> 

BPF can implement the CPU choice/pref itself. It has everything needed.

> I don't try to reimplement something already available, but I'm confused
> by a few points :
>   - the code above already exists and you mention it cannot be used with BPF

_If_ you use BPF, then you can implement a CPU preference using BPF
instructions. It is a user choice.

>   - for the vast majority of applications not using BPF, would the above *still*
>     work (it worked in 4.4-rc at least)


>   - it seems to me that for BPF to be usable on process shutting down, we'd
>     need to have some form of central knowledge if the goal is to redefine
>     how to distribute the load. In my case there are multiple independant
>     processes forked on startup, so it's unclear to me how each of them could
>     reconfigure BPF when shutting down without risking to break the other ones.
>   - the doc makes me believe that BPF would require privileges to be unset, so
>     that would not be compatible with a process shutting down which has already
>     dropped its privileges after startup, but I could be wrong.
> 
> Thanks for your help on this,
> Willy
> 

The point is : BPF is the way to go, because it is expandable.

No more hard points coded forever in the kernel.

Really, when BPF can be the solution, we wont allow adding new stuff in
the kernel in the old way.
