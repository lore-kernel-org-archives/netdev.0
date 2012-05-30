From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 2/2] tcp: Early SYN limit and SYN cookie handling to
 mitigate SYN floods
Date: Wed, 30 May 2012 11:24:23 +0200
Message-ID: <1338369863.7747.96.camel@localhost>
References: <20120528115102.12068.79994.stgit@localhost.localdomain>
	 <20120528115226.12068.31850.stgit@localhost.localdomain>
	 <m2bol6lqxo.fsf@firstfloor.org> <1338360073.2760.81.camel@edumazet-glaptop>
	 <1338363926.7747.55.camel@localhost>
	 <1338365702.2760.112.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, Florian Westphal <fw@strlen.de>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Martin Topholm <mph@hoth.dk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38582 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932360Ab2E3JYq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2012 05:24:46 -0400
In-Reply-To: <1338365702.2760.112.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-30 at 10:15 +0200, Eric Dumazet wrote:
> On Wed, 2012-05-30 at 09:45 +0200, Jesper Dangaard Brouer wrote:
> 
> > Sounds interesting, but TCP Fast Open is primarily concerned with
> > enabling data exchange during SYN establishment.  I don't see any
> > indication that they have implemented parallel SYN handling.
> > 
> 
> Not at all, TCP fast open main goal is to allow connection establishment
> with a single packet (thus removing one RTT). This also removes the
> whole idea of having half-sockets (in SYN_RCV state)
> 
> Then, allowing DATA in the SYN packet is an extra bonus, only if the
> whole request can fit in the packet (it is unlikely for typical http
> requests)
> 
> 
> > Implementing parallel SYN handling, should also benefit their work.
> 
> Why do you think I am working on this ? Hint : I am a Google coworker.

Did know you work for Google, but didn't know you worked actively on
parallel SYN handling.  Your previous quote "eventually in a short
time", indicated to me, that I should solve the issue my self first, and
then we would replace my code with your full solution later.


> > After studying this code path, I also see great performance benefit in
> > also optimizing the normal 3WHS on sock's in sk_state == LISTEN.
> > Perhaps we should split up the code path for LISTEN vs. ESTABLISHED, as
> > they are very entangled at the moment AFAIKS.
> > 
> > > Yuchung Cheng and Jerry Chu should upstream this code in a very near
> > > future.
> > 
> > Looking forward to see the code, and the fallout discussions, on
> > transferring data on SYN packets.
> > 
> 
> Problem is this code will be delayed if we change net-next code in this
> area, because we'll have to rebase and retest everything.

Okay, don't want to delay your work.  We can wait merging my cleanup
patches, and I can take the pain of rebasing them after your work is
merged.  And then we will see if my performance patches have gotten
obsolete.

I'm going to post some updated v2 patches, just because I know some
people that are desperate for a quick solution to their DDoS issues, and
are willing patch their kernels for production.

 
> > > Another way to mitigate SYN scalability issues before the full RCU
> > > solution I was cooking is to either :
> > > 
> > > 1) Use a hardware filter (like on Intel NICS) to force all SYN packets
> > > going to one queue (so that they are all serviced on one CPU)
> > > 
> > > 2) Tweak RPS (__skb_get_rxhash()) so that SYN packets rxhash is not
> > > dependent on src port/address, to get same effect (All SYN packets
> > > processed by one cpu). Note this only address the SYN flood problem, not
> > > the general 3WHS scalability one, since if real connection is
> > > established, the third packet (ACK from client) will have the 'real'
> > > rxhash and will be processed by another cpu.
> > 
> > I don't like the idea of overloading one CPU with SYN packets. As the
> > attacker can still cause a DoS on new connections.
> > 
> 
> One CPU can handle more than one million SYN per second, while 32 cpus
> fighting on socket lock can not handle 1 % of this load.

Not sure, one CPU can handle 1Mpps on this particular path.  And Hans
have some other measurements, although I'm assuming he has small CPUs.
But if you are working on the real solution, we don't need to discuss
this :-)


> If Intel chose to implement this hardware filter in their NIC, its for a
> good reason.
> 
> 
> > My "unlocked" parallel SYN cookie approach, should favor established
> > connections, as they are allowed to run under a BH lock, and thus don't
> > let new SYN packets in (on this CPU), until the establish conn packet is
> > finished.  Unless I have misunderstood something... I think I have,
> > established connections have their own/seperate struck sock, and thus
> > this is another slock spinlock, right?. (Well let Eric bash me for
> > this ;-))
> 
> It seems you forgot I have patches to have full parallelism, not only
> the SYNCOOKIE hack.

I'm so much, looking forward to this :-)

> I am still polishing them, its a _long_ process, especially if network
> tree changes a lot.
> 
> If you believe you can beat me on this, please let me know so that I can
> switch to other tasks.

I don't dare to go into that battle with the network ninja, I surrender.
DaveM, Eric's patches take precedence over mine...

/me Crawing back into my cave, and switching to boring bugzilla cases of
backporting kernel patches instead...

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
