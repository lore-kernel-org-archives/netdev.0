From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next PATCH V3 0/2] qdisc bulk dequeuing and utilizing
 delayed tailptr updates
Date: Fri, 19 Sep 2014 13:59:20 -0700
Message-ID: <1411160360.26859.31.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140919204706.3231.59125.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>, toke@toke.dk
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:65110 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757740AbaISU7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 16:59:23 -0400
Received: by mail-pa0-f43.google.com with SMTP id kx10so823709pab.30
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 13:59:22 -0700 (PDT)
In-Reply-To: <20140919204706.3231.59125.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-19 at 22:49 +0200, Jesper Dangaard Brouer wrote:
> This patchset uses DaveM's recent API changes to dev_hard_start_xmit(),
> from the qdisc layer, to implement dequeue bulking.
> 
> RFC V3: Keeping the ball rolling.
> 
> This patchset should now use BQL correctly.  I've done lots of testing
> for Head-of-Line blocking issues that can occur due to requeue of a
> SKB bulk list.  I've not been able to provoke any HoL blocking
> situation, simply because BQL is doing such a good job, thus I'm
> unable to "overshoot" HW/BQL limits with more than a single packet.
> 
> This patch chooses a very conservative approach, as by default only
> allowing dequeue of one extra packet, besides the normal dequeue.
> 
> Open questions:
> 
> - How do we expose tuning to userspace?
>   Patch adds /proc/sys/net/core/qdisc_bulk_dequeue_limit but I don't like it...
>   Per device tunable?
> 

bql is using /sys, of course ;)

# grep . /sys/class/net/eth1/queues/tx-0/byte_queue_limits/*
/sys/class/net/eth1/queues/tx-0/byte_queue_limits/hold_time:1000
/sys/class/net/eth1/queues/tx-0/byte_queue_limits/inflight:0
/sys/class/net/eth1/queues/tx-0/byte_queue_limits/limit:113314
/sys/class/net/eth1/queues/tx-0/byte_queue_limits/limit_max:1879048192
/sys/class/net/eth1/queues/tx-0/byte_queue_limits/limit_min:0

Maybe you could simply reuse byte_queue_limits/limit, I am not sure we
need a specific tunable.


> - Can/should we limit dequeue bulking to devices supporting BQL?
> 

Yes please. This will be an incentive to get BQL on drivers.
