From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V2 1/9] net: frag evictor, avoid killing warm
 frag queues
Date: Thu, 29 Nov 2012 23:17:50 +0100
Message-ID: <1354227470.11754.348.camel@localhost>
References: <20121129161019.17754.29670.stgit@dragon>
	 <20121129161052.17754.85017.stgit@dragon>
	 <20121129.124427.1093031685966728935.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, fw@strlen.de, netdev@vger.kernel.org,
	pablo@netfilter.org, tgraf@suug.ch, amwang@redhat.com,
	kaber@trash.net, paulmck@linux.vnet.ibm.com,
	herbert@gondor.hengli.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48292 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754006Ab2K2WTm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2012 17:19:42 -0500
In-Reply-To: <20121129.124427.1093031685966728935.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-29 at 12:44 -0500, David Miller wrote:
> From: Jesper Dangaard Brouer <brouer@redhat.com>
> Date: Thu, 29 Nov 2012 17:11:09 +0100
> 
> > The fragmentation evictor system have a very unfortunate eviction
> > system for killing fragment, when the system is put under pressure.
> > If packets are coming in too fast, the evictor code kills "warm"
> > fragments too quickly.  Resulting in a massive performance drop,
> > because we drop frag lists where we have already queue up a lot of
> > fragments/work, which gets killed before they have a chance to
> > complete.
> 
> I think this is a trade-off where the decision is somewhat
> arbitrary.
> 
> If you kill warm entries, the sending of all of the fragments is
> wasted.  If you retain warm entries and drop incoming new fragments,
> well then the sending of all of those newer fragments is wasted too.
> 
> The only way I could see this making sense is if some "probability
> of fulfillment" was taken into account.  For example, if you have
> more than half of the fragments already, then yes it may be
> advisable to retain the warm entry.

I disagree, once we have spend energy on allocation a frag queue and
adding just a single packet, while the entry is warn we must not drop
it.

I believe, we need the concept of "warn" entries.  Without it you scheme
is dangerous, as we would retain entries with missed/dropped fragments
too long.

> Otherwise, as I said, the decision seems arbitrary.

This patch/system actually includes a "promise/probability of
fulfillment". Let me explain.

We allow "warn" entries to complete, by allowing (new) fragments/packets
for these entries (present in the frag queue).  While we don't allow the
system to create new entries.  This creates the selection we interested
in (as we must drop some packets given the arrival rate bigger than the
processing rate).

(This might be hard to follow)
While blocking new frag queue entries, we are dropping packets.  When
fragments complete, the "window" opens up again.  Creating a frag queue
entry, in this situation, might be for a fragment which already have
lost some packets, thus wasting resources.  BUT its not such a big
problem, because our evictor system will quickly kill this fragment
queue, due to the LRU list (and the fq getting "cold").

I have through of keeping track of fragment id's of dropped fragments,
but is a scalability problem of its own to maintain this list.  And I'm
not sure how effective its going to be (as we already get some of the
effect "automatically", as descrived above).


> Let's take a step back and think about why this is happening at all.
> 
> I wonder how reasonable the high and low thresholds really are.  Even
> once you move them to per-cpu, I think the limits are far too small.

It is VERY important that you understand/realize that throwing more
memory at the problem is NOT the solution.  It a classical queue theory
situation where the arrival rate is bigger than the processing
capabilities. Thus, we must drop packets, or else the NIC will do it for
us... for fragments we need do this "dropping" more intelligent.

For example lets give a threshold of 2000 MBytes:

[root@dragon ~]# sysctl -w net/ipv4/ipfrag_high_thresh=$(((1024**2*2000)))
net.ipv4.ipfrag_high_thresh = 2097152000

[root@dragon ~]# sysctl -w net/ipv4/ipfrag_low_thresh=$(((1024**2*2000)-655350))
net.ipv4.ipfrag_low_thresh = 2096496650

4x10 Netperf adjusted output:
 Socket  Message  Elapsed      Messages
 Size    Size     Time         Okay Errors   Throughput
 bytes   bytes    secs            #      #   10^6bits/sec

 229376   65507   20.00      298685      0    7826.35
 212992           20.00          27              0.71

 229376   65507   20.00      366668      0    9607.71
 212992           20.00          13              0.34

 229376   65507   20.00      254790      0    6676.20
 212992           20.00          14              0.37

 229376   65507   20.00      309293      0    8104.33
 212992           20.00          15              0.39

Can we agree that the current evictor strategy is broken?


> I'm under the impression that it's common for skb->truesize for 1500
> MTU frames to be something rounded up to the next power of 2, so
> 2048 bytes, or something like that.  Then add in the sk_buff control
> overhead, as well as the inet_frag head.

(Plus, the size of the frag queue struct, which is also being accounted
for).

> So a 64K fragmented frame probably consumes close to 100K.
> 
> So once we have three 64K frames in flight, we're already over the
> high threshold and will start dropping things.
> 
> That's beyond stupid.

Yes, I would say the interval between ipfrag_high_thresh and
ipfrag_low_thresh seems quite a stupid default.


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
