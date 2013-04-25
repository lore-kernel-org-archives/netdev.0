From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 4/4] net: frag LRU list per CPU
Date: Thu, 25 Apr 2013 15:59:29 +0200
Message-ID: <1366898369.26911.604.camel@localhost>
References: <20130424154624.16883.40974.stgit@dragon>
	 <20130424154848.16883.65833.stgit@dragon>
	 <1366849557.8964.110.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12710 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758154Ab3DYN7f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 09:59:35 -0400
In-Reply-To: <1366849557.8964.110.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-24 at 17:25 -0700, Eric Dumazet wrote:
> On Wed, 2013-04-24 at 17:48 +0200, Jesper Dangaard Brouer wrote:
> > The global LRU list is the major bottleneck in fragmentation handling
> > (after the recent frag optimization).
> > 
> > Simply change to use a LRU list per CPU, instead of a single shared
> > LRU list.  This was the simples approach of removing the LRU list, I
> > could come up with.  The previous "direct hash cleaning" approach was
> > getting too complicated, and interacted badly with netns.
> > 
> > The /proc/sys/net/ipv4/ipfrag_*_thresh values are now per CPU limits,
> > and have been reduced to 2 Mbytes (from 4 MB).
> > 
> > Performance compared to net-next (953c96e):
> > 
> > Test-type:  20G64K    20G3F    20G64K+DoS  20G3F+DoS  20G64K+MQ 20G3F+MQ
> > ----------  -------   -------  ----------  ---------  --------  -------
> > (953c96e)
> >  net-next:  17417.4   11376.5   3853.43     6170.56     174.8    402.9
> > LRU-pr-CPU: 19047.0   13503.9  10314.10    12363.20    1528.7   2064.9
> 
> Having per cpu memory limit is going to be a nightmare for machines with
> 64+ cpus

I do see your concern, but the struct frag_cpu_limit is only 26 bytes,
well actually 32 bytes due alignment.  And the limit sort of scales with
the system size.  But yes, I'm not a complete fan of it...


> Most machines use a single cpu to receive network packets. In some
> situations, every network interrupt is balanced onto all cpus. fragments
> for the same reassembled packet can be serviced on different cpus.
> 
> So your results are good because your irq affinities were properly
> tuned.

Yes, the irq affinities needs to be aligned for this to work.  I do see
your point about the single CPU that distributes via RSS (Receive Side
Scaling).


> Why don't you remove the lru instead ?

That was my attempt in my previous patch set:
  "net: frag code fixes and RFC for LRU removal"
  http://thread.gmane.org/gmane.linux.network/266323/

I though that you "shot-me-down" on that approach.  That is why I'm
doing all this work on the LRU per CPU, stuff now... (this is actually
consuming a lot of my time, not knowing which direction you want me to
run in...)

We/you have to make a choice between:
1) "Remove LRU and do direct cleaning on hash table"
2) "Fix LRU mem acct scalability issue"


> Clearly, removing the oldest frag was an implementation choice.
> 
> We know that a slow sender has no chance to complete a packet if the
> attacker can create new fragments fast enough : frag_evictor() will keep
> the attacker fragments in memory and throw away good fragments.

Let me quote my self (which you cut out):

On Wed, 2013-04-24 at 17:48 +0200, Jesper Dangaard Brouer wrote:
> I have also tested that a 512 Kbit/s simulated link (with HTB) still
> works (with sending 3x UDP fragments) under the DoS test 20G3F+MQ,
> which is sending approx 1Mpps on a 10Gbit/s NIC

My experiments show that removing the oldest frag is actually a quite
good solution.  And the LRU list do have some advantages...

The LRU list is the hole reason, that I can make a 512 Kbit/s link work,
at the same time of a of a 10Gbit/s DoS attack (well my packet generator
was limited to 1 million packets per sec, which is not 10G)

The calculations:
  The 512 Kbit/s link will send packets spaced with 23.43 ms.
  (1500*8)/512000 = 0.0234375

Thus, I need enough buffering/ mem limit to keep minimum 24 ms worth of
data, for a new fragment to arrive, which will move the frag queue to
the tail of the LRU.

On a 1Gbit/s link this is: approx 24 MB
 (0.0234375*1000*10^6/10^6 23.4375 MB)

On a 10Gbit/s link this is: approx 240 MB
 (0.0234375*10000*10^6/10^6 234.375 MB)

Yes, the frag sizes do get account to be bigger, but I hope you get the
point, which is:
 We don't need that much memory to "protect" fragment from slow sender,
with the LRU system.

--Jesper
