From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V2 1/9] net: frag evictor, avoid killing warm
 frag queues
Date: Fri, 30 Nov 2012 11:04:06 +0100
Message-ID: <1354269846.11754.381.camel@localhost>
References: <20121129161019.17754.29670.stgit@dragon>
	 <20121129161052.17754.85017.stgit@dragon>
	 <20121129.124427.1093031685966728935.davem@davemloft.net>
	 <1354227470.11754.348.camel@localhost>
	 <1354230100.3299.40.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org, pablo@netfilter.org, tgraf@suug.ch,
	amwang@redhat.com, kaber@trash.net, paulmck@linux.vnet.ibm.com,
	herbert@gondor.hengli.com.au
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29694 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752258Ab2K3KHh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2012 05:07:37 -0500
In-Reply-To: <1354230100.3299.40.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-29 at 15:01 -0800, Eric Dumazet wrote:
> On Thu, 2012-11-29 at 23:17 +0100, Jesper Dangaard Brouer wrote:
> 
> > For example lets give a threshold of 2000 MBytes:
> > 
> > [root@dragon ~]# sysctl -w net/ipv4/ipfrag_high_thresh=$(((1024**2*2000)))
> > net.ipv4.ipfrag_high_thresh = 2097152000
> > 
> > [root@dragon ~]# sysctl -w net/ipv4/ipfrag_low_thresh=$(((1024**2*2000)-655350))
> > net.ipv4.ipfrag_low_thresh = 2096496650
> > 
> > 4x10 Netperf adjusted output:
> >  Socket  Message  Elapsed      Messages
> >  Size    Size     Time         Okay Errors   Throughput
> >  bytes   bytes    secs            #      #   10^6bits/sec
> > 
> >  229376   65507   20.00      298685      0    7826.35
> >  212992           20.00          27              0.71
> > 
> >  229376   65507   20.00      366668      0    9607.71
> >  212992           20.00          13              0.34
> > 
> >  229376   65507   20.00      254790      0    6676.20
> >  212992           20.00          14              0.37
> > 
> >  229376   65507   20.00      309293      0    8104.33
> >  212992           20.00          15              0.39
> > 
> > Can we agree that the current evictor strategy is broken?
> 
> Not really, you drop packets because of another limit.

Then tell me which limit?
And notice the result is the same for 200 MBytes threshold.

As I wrote *just* above the section you quoted:

On Thu, 2012-11-29 at 23:17 +0100, Jesper Dangaard Brouer wrote:
[...] Thus, we must drop packets, or else the NIC will do it for
> us... for fragments we need do this "dropping" more intelligent. 

So, I think it is the NIC dropping packets, in this case... what do you
claim?



I still claim the the current evictor strategy is broken!

We need to drop fragments more intelligently in software. As DaveM
correctly states, the code/algorithm needs some "probability
of fulfillment" taken into account.   Which is actually what my evictor
code implements (I don't claim its perfect, as it currently does have
fairness/fair-queue issues, I have a plan for fixing it, but lets not
clutter up this answer).


So, let me instead show, with tests, that the evictor strategy is
broken, while keeping the original default thresh settings:

# grep . /proc/sys/net/ipv4/ipfrag_*_thresh
/proc/sys/net/ipv4/ipfrag_high_thresh:262144
/proc/sys/net/ipv4/ipfrag_low_thresh:196608

Test purpose, I will on a single 10G link demonstrate, that starting
several "N" netperf UDP fragmentation flows, will hurt performance, and
then claim this is caused by the bad evictor strategy.

Test setup:
 - Disable Ethernet flow control
 - netperf packet size 65507
 - Run netserver on one NUMA node
 - Start netperf clients against a NIC on the other NUMA node
 - (The NUMA imbalance helps the effect occur at lower N) 

Result: N=1  8040 Mbit/s
Result: N=2  9584 Mbit/s (4739+4845)
Result: N=3  4055 Mbit/s (1436+1371+1248)
Result: N=4  2247 Mbit/s (1538+29+54+626)
Result: N=5   879 Mbit/s (78+152+226+125+298)
Result: N=6   293 Mbit/s (85+55+32+57+46+18)
Result: N=7   354 Mbit/s (70+47+33+80+20+72+32)

Can we, now, agree that the current evictor strategy is broken?!?


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
