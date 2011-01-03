From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [net-next-2.6 PATCH v2 3/3] net_sched: implement a root
 container qdisc sch_mclass
Date: Mon, 3 Jan 2011 18:02:44 +0100
Message-ID: <20110103170244.GA1843@del.dom.local>
References: <20101221192831.9703.56356.stgit@jf-dev1-dcblab>
 <20101221192930.9703.63791.stgit@jf-dev1-dcblab>
 <4D1D17C9.3040500@gmail.com>
 <4D2161FF.4070804@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hadi@cyberus.ca" <hadi@cyberus.ca>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:63325 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895Ab1ACRCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 12:02:54 -0500
Received: by bwz15 with SMTP id 15so13873168bwz.19
        for <netdev@vger.kernel.org>; Mon, 03 Jan 2011 09:02:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4D2161FF.4070804@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 02, 2011 at 09:43:27PM -0800, John Fastabend wrote:
> On 12/30/2010 3:37 PM, Jarek Poplawski wrote:
> > John Fastabend wrote:
> >> This implements a mclass 'multi-class' queueing discipline that by
> >> default creates multiple mq qdisc's one for each traffic class. Each
> >> mq qdisc then owns a range of queues per the netdev_tc_txq mappings.
> > 
> > Is it really necessary to add one more abstraction layer for this,
> > probably not most often used (or even asked by users), functionality?
> > Why mclass can't simply do these few things more instead of attaching
> > (and changing) mq?
> > 
> 
> The statistics work nicely when the mq qdisc is used. 

Well, I sometimes add leaf qdiscs only to get class stats with less
typing, too ;-)

> 
> qdisc mclass 8002: root  tc 4 map 0 1 2 3 0 1 2 3 1 1 1 1 1 1 1 1
>              queues:(0:1) (2:3) (4:5) (6:15)
>  Sent 140 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> qdisc mq 8003: parent 8002:1
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> qdisc mq 8004: parent 8002:2
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> qdisc mq 8005: parent 8002:3
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> qdisc mq 8006: parent 8002:4
>  Sent 140 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> qdisc sfq 8007: parent 8005:1 limit 127p quantum 1514b
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> qdisc sfq 8008: parent 8005:2 limit 127p quantum 1514b
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> 
> The mclass gives the statistics for the interface and then statistics on the mq qdisc gives statistics for each traffic class. Also, when using the 'mq qdisc' with this abstraction other qdisc can be grafted onto the queue. For example the sch_sfq is used in the above example.

IMHO, these tc offsets and counts make simply two level hierarchy
(classes with leaf subclasses) similarly (or simpler) to other
classful qdisc which manage it all inside one module. Of course,
we could think of another way of code organization, but it should
be rather done at the beginning of schedulers design. The mq qdisc
broke the design a bit adding a fake root, but I doubt we should go
deeper unless it's necessary. Doing mclass (or something) as a more
complex alternative to mq should be enough. Why couldn't mclass graft
sch_sfq the same way as mq?

> 
> Although I am not too hung up on this use case it does seem to be a good abstraction to me. Is it strictly necessary though no and looking at the class statistics of mclass could be used to get stats per traffic class.

I am not too hung up on this either, especially if it's OK to others,
especially to DaveM ;-)

> 
> > ...
> >> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> >> index 0af57eb..723ee52 100644
> >> --- a/include/net/sch_generic.h
> >> +++ b/include/net/sch_generic.h
> >> @@ -50,6 +50,7 @@ struct Qdisc {
> >>  #define TCQ_F_INGRESS		4
> >>  #define TCQ_F_CAN_BYPASS	8
> >>  #define TCQ_F_MQROOT		16
> >> +#define TCQ_F_MQSAFE		32
> > 
> > If every other qdisc added a flag for qdiscs it likes...
> > 
> 
> then we run out of bits and get unneeded complexity. I think I will drop the MQSAFE bit completely and let user space catch this. The worst that should happen is the noop qdisc is used.

Maybe you're right. On the other hand, usually flags are added for
more general purpose and the optimal/wrong configs are the matter of
documentation.

> 
> >> @@ -709,7 +709,13 @@ static void attach_default_qdiscs(struct net_device *dev)
> >>  		dev->qdisc = txq->qdisc_sleeping;
> >>  		atomic_inc(&dev->qdisc->refcnt);
> >>  	} else {
> >> -		qdisc = qdisc_create_dflt(txq, &mq_qdisc_ops, TC_H_ROOT);
> >> +		if (dev->num_tc)
> > 
> > Actually, where this num_tc is expected to be set? I can see it inside
> > mclass only, with unsetting on destruction, but probably I miss something.
> 
> Either through mclass as you noted or a driver could set the num_tc. One of the RFC's I sent out has ixgbe setting the num_tc when DCB was enabled.

OK, I probably missed this second possibility in the last version.

...
> >> +	/* Unwind attributes on failure */
> >> +	u8 unwnd_tc = dev->num_tc;
> >> +	u8 unwnd_map[16];
> > 
> > [TC_MAX_QUEUE] ?
> 
> Actually TC_BITMASK+1 is probably more accurate. This array maps the skb priority to a traffic class after the priority is masked with TC_BITMASK.
> 
> > 
> >> +	struct netdev_tc_txq unwnd_txq[16];
> >> +
> 
> Although unwnd_txq should be TC_MAX_QUEUE.
...
> >> +	/* Always use supplied priority mappings */
> >> +	for (i = 0; i < 16; i++) {
> > 
> > i < qopt->num_tc ?
> 
> Nope, TC_BITMASK+1 here. If we only have 4 tcs for example we still need to map all 16 priority values to a tc.

OK, anyway, all these '16' should be 'upgraded'.
 
Thanks,
Jarek P.
