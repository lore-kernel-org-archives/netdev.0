From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Thu, 24 Mar 2016 19:00:11 +0100
Message-ID: <20160324180011.GB7585@1wt.eu>
References: <20151221204127.GC8018@1wt.eu>
 <CALmu+SwjG0GVocGufTbgX-WJfcsP85SvHB=xtW7qQX3kZwJCxg@mail.gmail.com>
 <20160324061222.GA6807@1wt.eu>
 <1458828813.10868.65.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160324142222.GB7237@1wt.eu>
 <1458830744.10868.72.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160324153053.GA7569@1wt.eu>
 <1458837191.12033.4.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160324165047.GA7585@1wt.eu>
 <1458838897.12033.10.camel@edumazet-glaptop3.roam.corp.google.com>
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
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:32130 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751106AbcCXSAX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2016 14:00:23 -0400
Content-Disposition: inline
In-Reply-To: <1458838897.12033.10.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2016 at 10:01:37AM -0700, Eric Dumazet wrote:
> On Thu, 2016-03-24 at 17:50 +0100, Willy Tarreau wrote:
> > On Thu, Mar 24, 2016 at 09:33:11AM -0700, Eric Dumazet wrote:
> > > > --- a/net/ipv4/inet_hashtables.c
> > > > +++ b/net/ipv4/inet_hashtables.c
> > > > @@ -189,6 +189,8 @@ static inline int compute_score(struct sock *sk, struct net *net,
> > > >                                 return -1;
> > > >                         score += 4;
> > > >                 }
> > > > +               if (sk->sk_reuseport)
> > > > +                       score++;
> > > 
> > > This wont work with BPF
> > > 
> > > >                 if (sk->sk_incoming_cpu == raw_smp_processor_id())
> > > >                         score++;
> > > 
> > > This one does not work either with BPF
> > 
> > But this *is* in 4.5. Does this mean that this part doesn't work anymore or
> > just that it's not usable in conjunction with BPF ? In this case I'm less
> > worried, because it would mean that we have a solution for non-BPF aware
> > applications and that BPF-aware applications can simply use BPF.
> > 
> 
> BPF can implement the CPU choice/pref itself. It has everything needed.

Well I don't need the CPU choice, it was already there, it's not my code,
I only need the ability for an independant process to stop receiving new
connections without altering the other processes nor dropping some of these
connections.

In fact initially I didn't even need anything related to incoming connection
load-balancing, just the ability to start a new process without stopping the
old one, as it used to work in 2.2 and for which I used to keep a patch in
2.4 and 2.6. When SO_REUSEPORT was reintroduced in 3.9, that solved the issue
and some users started to complain that between the old and the new processes,
some connections were lost. Hence the proposal above. Since it's not about
load distribution and that processes are totally independant, I don't see
well how to (ab)use BPF to achieve this.

The pattern is :

  t0 : unprivileged processes 1 and 2 are listening to the same port
       (sock1@pid1) (sock2@pid2)
       <------ listening ------>

  t1 : new processes are started to replace the old ones
       (sock1@pid1) (sock2@pid2) (sock3@pid3) (sock4@pid4)
       <------ listening ------> <------ listening ------>

  t2 : new processes signal the old ones they must stop
       (sock1@pid1) (sock2@pid2) (sock3@pid3) (sock4@pid4)
       <------- draining ------> <------ listening ------>

  t3 : pids 1 and 2 have finished, they go away
                                 (sock3@pid3) (sock4@pid4)
        <------ gone ----->      <------ listening ------>

> >   - it seems to me that for BPF to be usable on process shutting down, we'd
> >     need to have some form of central knowledge if the goal is to redefine
> >     how to distribute the load. In my case there are multiple independant
> >     processes forked on startup, so it's unclear to me how each of them could
> >     reconfigure BPF when shutting down without risking to break the other ones.
> >   - the doc makes me believe that BPF would require privileges to be unset, so
> >     that would not be compatible with a process shutting down which has already
> >     dropped its privileges after startup, but I could be wrong.
> > 
> > Thanks for your help on this,
> > Willy
> > 
> 
> The point is : BPF is the way to go, because it is expandable.

OK so this means we have to find a way to expand it to allow an individual
non-privileged process to change the distribution algorithm without impacting
other processes.

I need to discover it better to find what can be done, but unfortunately at
this point the sole principle makes me think of a level of complexity that
doesn't seem obvious to solve at all :-/

Regards,
Willy
