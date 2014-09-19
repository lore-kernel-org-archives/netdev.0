From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC net-next PATCH V3 0/2] qdisc bulk dequeuing and utilizing
 delayed tailptr updates
Date: Fri, 19 Sep 2014 23:31:08 +0200
Message-ID: <20140919233108.5bd43ccc@redhat.com>
References: <20140919204706.3231.59125.stgit@dragon>
	<1411160360.26859.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>, toke@toke.dk,
	brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1309 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757848AbaISVbp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2014 17:31:45 -0400
In-Reply-To: <1411160360.26859.31.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Sep 2014 13:59:20 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Fri, 2014-09-19 at 22:49 +0200, Jesper Dangaard Brouer wrote:
> > This patchset uses DaveM's recent API changes to dev_hard_start_xmit(),
> > from the qdisc layer, to implement dequeue bulking.
> > 
> > RFC V3: Keeping the ball rolling.
> > 
> > This patchset should now use BQL correctly.  I've done lots of testing
> > for Head-of-Line blocking issues that can occur due to requeue of a
> > SKB bulk list.  I've not been able to provoke any HoL blocking
> > situation, simply because BQL is doing such a good job, thus I'm
> > unable to "overshoot" HW/BQL limits with more than a single packet.
> > 
> > This patch chooses a very conservative approach, as by default only
> > allowing dequeue of one extra packet, besides the normal dequeue.
> > 
> > Open questions:
> > 
> > - How do we expose tuning to userspace?
> >   Patch adds /proc/sys/net/core/qdisc_bulk_dequeue_limit but I don't like it...
> >   Per device tunable?
> > 
> 
> bql is using /sys, of course ;)
> 
> # grep . /sys/class/net/eth1/queues/tx-0/byte_queue_limits/*
> /sys/class/net/eth1/queues/tx-0/byte_queue_limits/hold_time:1000
> /sys/class/net/eth1/queues/tx-0/byte_queue_limits/inflight:0
> /sys/class/net/eth1/queues/tx-0/byte_queue_limits/limit:113314
> /sys/class/net/eth1/queues/tx-0/byte_queue_limits/limit_max:1879048192
> /sys/class/net/eth1/queues/tx-0/byte_queue_limits/limit_min:0
> 
> Maybe you could simply reuse byte_queue_limits/limit, I am not sure we
> need a specific tunable.

It would make sense.  I've been running tests with qdisc_bulk_dequeue_limit=100,
and I'm being saved/limited by the BQL limit.

Perhaps we should still keep some upper bound on num of packet e.g. 32,
as this does influence the number of HW ring descriptors we use before
"flushing"/notifying HW by the tailptr write.

> 
> > - Can/should we limit dequeue bulking to devices supporting BQL?
> > 
> 
> Yes please. This will be an incentive to get BQL on drivers.

How can I test if the dev supports BQL?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
