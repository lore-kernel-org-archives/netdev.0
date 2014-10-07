From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Quota in __qdisc_run()
Date: Tue, 7 Oct 2014 21:34:23 +0200
Message-ID: <20141007213423.37bfac8b@redhat.com>
References: <20141007153050.792c9743@redhat.com>
	<1412693013.4140057.176149461.0FBF6CBD@webmail.messagingengine.com>
	<1412694080.11091.131.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141007.131938.1410434352331637585.davem@davemloft.net>
	<20141007200329.5d20a27e@redhat.com>
	<1412709015.11091.158.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hannes@stressinduktion.org,
	netdev@vger.kernel.org, therbert@google.com, fw@strlen.de,
	dborkman@redhat.com, jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk,
	brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43375 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755253AbaJGTer (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2014 15:34:47 -0400
In-Reply-To: <1412709015.11091.158.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 07 Oct 2014 12:10:15 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Tue, 2014-10-07 at 20:03 +0200, Jesper Dangaard Brouer wrote:
> 
> > According to my measurements, at 10Gbit/s TCP_STREAM test the BQL limit
> > is 381528 bytes / 1514 = 252 packets, that will (potentially) be bulk
> > dequeued at once (with your version of the patch).
> > 
> 
> That's because you use a single queue maybe ?

No, I just double checked.

I was using a single netperf TCP_STREAM with GRO=off TSO=off.

> Here we have limits around 2 TSO packets.

Which should be approx 128k

Just tested with GRO=on TSO=on single TCP_STREAM, which is weird as I
should hit your 2xTSO limit right, and inflight shows 408780.

And I do have (which I guess is the 2xTSO):
 /proc/sys/net/ipv4/tcp_limit_output_bytes:131072

$ grep -H . /sys/class/net/eth4/queues/tx-*/byte_queue_limits/{inflight,limit}
/sys/class/net/eth4/queues/tx-0/byte_queue_limits/inflight:0
/sys/class/net/eth4/queues/tx-10/byte_queue_limits/inflight:0
/sys/class/net/eth4/queues/tx-11/byte_queue_limits/inflight:0
/sys/class/net/eth4/queues/tx-1/byte_queue_limits/inflight:0
/sys/class/net/eth4/queues/tx-2/byte_queue_limits/inflight:0
/sys/class/net/eth4/queues/tx-3/byte_queue_limits/inflight:0
/sys/class/net/eth4/queues/tx-4/byte_queue_limits/inflight:0
/sys/class/net/eth4/queues/tx-5/byte_queue_limits/inflight:0
/sys/class/net/eth4/queues/tx-6/byte_queue_limits/inflight:0
/sys/class/net/eth4/queues/tx-7/byte_queue_limits/inflight:0
/sys/class/net/eth4/queues/tx-8/byte_queue_limits/inflight:408780
/sys/class/net/eth4/queues/tx-9/byte_queue_limits/inflight:0
/sys/class/net/eth4/queues/tx-0/byte_queue_limits/limit:340848
/sys/class/net/eth4/queues/tx-10/byte_queue_limits/limit:340650
/sys/class/net/eth4/queues/tx-11/byte_queue_limits/limit:367902
/sys/class/net/eth4/queues/tx-1/byte_queue_limits/limit:272520
/sys/class/net/eth4/queues/tx-2/byte_queue_limits/limit:204390
/sys/class/net/eth4/queues/tx-3/byte_queue_limits/limit:162856
/sys/class/net/eth4/queues/tx-4/byte_queue_limits/limit:158314
/sys/class/net/eth4/queues/tx-5/byte_queue_limits/limit:136260
/sys/class/net/eth4/queues/tx-6/byte_queue_limits/limit:140802
/sys/class/net/eth4/queues/tx-7/byte_queue_limits/limit:152258
/sys/class/net/eth4/queues/tx-8/byte_queue_limits/limit:340650
/sys/class/net/eth4/queues/tx-9/byte_queue_limits/limit:340650

Strange...

> Even with only 4 tx queues I have :
> 
> # sar -n DEV 3 3 |grep eth1
> 12:05:19 PM      eth1 147217.67 809066.67   9488.71 1196207.78      0.00      0.00      0.00
> 12:05:22 PM      eth1 145958.00 807822.33   9407.48 1194366.73      0.00      0.00      0.00
> 12:05:25 PM      eth1 147502.33 804739.33   9507.26 1189804.23      0.00      0.00      0.33
> Average:         eth1 146892.67 807209.44   9467.82 1193459.58      0.00      0.00      0.11
> 
> 
> grep . /sys/class/net/eth1/queues/tx*/byte_queue_limits/{inflight,limit}
> /sys/class/net/eth1/queues/tx-0/byte_queue_limits/inflight:115064
> /sys/class/net/eth1/queues/tx-1/byte_queue_limits/inflight:0
> /sys/class/net/eth1/queues/tx-2/byte_queue_limits/inflight:0
> /sys/class/net/eth1/queues/tx-3/byte_queue_limits/inflight:0
> /sys/class/net/eth1/queues/tx-0/byte_queue_limits/limit:102952
> /sys/class/net/eth1/queues/tx-1/byte_queue_limits/limit:124148
> /sys/class/net/eth1/queues/tx-2/byte_queue_limits/limit:102952
> /sys/class/net/eth1/queues/tx-3/byte_queue_limits/limit:136260

Guess this is okay, 115064 / 1514 = 76 pkts which is closer to the 64 weight_p.


> > It seems to have the potential to exceed the weight_p(64) quite a lot.
> > And with e.g. TX ring size 512, we also also challenge the drivers at
> > this early adoption phase of tailptr writes.  Just saying...
> > 
> 
> Yep, but remind we want to squeeze bugs out of the drivers, then add
> additional knobs later.

Okay, for squeezing out bugs, then I understand this more aggressive
bulking strategy.  I'm all in then!


> Whatever limit we choose in core networking stack (being 64 packets for
> example), hardware might have different constraints that need to be
> taken care of in the driver.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
