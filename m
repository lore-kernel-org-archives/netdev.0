From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fq_codel: Fair Queue Codel AQM
Date: Fri, 11 May 2012 17:23:30 +0200
Message-ID: <1336749810.31653.176.camel@edumazet-glaptop>
References: <1336744796.31653.164.camel@edumazet-glaptop>
	 <CABa6K_Fk07CUR1+hOx06cwJ5MuNYi7vpeLYFOc_1Qwmu5ubYhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dave Taht <dave.taht@bufferbloat.net>,
	Kathleen Nichols <nichols@pollere.com>,
	Van Jacobson <van@pollere.net>,
	Tom Herbert <therbert@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:32915 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756483Ab2EKPXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 11:23:35 -0400
Received: by bkcji2 with SMTP id ji2so2338495bkc.19
        for <netdev@vger.kernel.org>; Fri, 11 May 2012 08:23:34 -0700 (PDT)
In-Reply-To: <CABa6K_Fk07CUR1+hOx06cwJ5MuNYi7vpeLYFOc_1Qwmu5ubYhQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-11 at 23:03 +0800, Changli Gao wrote:
> On Fri, May 11, 2012 at 9:59 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > Fair Queue Codel implementation.
> >
> > Principles :
> >
> > - Packets are classified (internal classifier or external) on flows.
> > - This is a Stochastic model (as we use a hash, several flows might
> >                              be hashed on same slot)
> > - Each flow has a CoDel managed queue.
> > - Flows are linked onto two (Round Robin) lists,
> >  so that new flows have priority on old ones.
> 
> I don't think it is a good idea, as the old ones may be starved. It isn't
> fair. Why not use the conventional DRR?
> 

Hey, its DRR, but with 64 bytes per flow instead of more than 256.
One cache line per flow, that was my goal, sharing the codel_params and
stats for all flows.

A 'struct fq_codel_flow' can be in three states :

- Detached state
- In new flow list
- In old flow list

And its the dequeue() that can put a flow in detached state, only if
coming from old flow list.

Its possible I missed something, because in my first coding I had 3
lists.

Anyway I'll send a V2 because I left .change method to NULL, while the
intent was to permit a change on fq_codel.

> > +
> > +       /* Queue is full! Find the fat flow and drop packet from it.
> > +        * This might sound expensive, but with 1024 flows, we scan
> > +        * 4KB of memory, and we dont need to handle a complex tree
> > +        * in fast path (packet queue/enqueue) with many cache misses.
> > +        */
> 
> How about the tricks used by SFQ?

They are too expensive in term of cache misses and limits.
Code is complex and difficult to maintain.
That was a nice compromise 20 years ago when memory was expensive.
Now, memory is cheap but still slow.

Also adding the 'priority to new flows' is too difficult with SFQ.
