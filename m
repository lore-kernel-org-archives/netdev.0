From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH V5] qdisc: bulk dequeue support for qdiscs with
 TCQ_F_ONETXQUEUE
Date: Tue, 30 Sep 2014 07:07:37 -0400
Message-ID: <542A8EF9.10403@mojatatu.com>
References: <20140930085114.24043.81310.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>, toke@toke.dk
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:52159 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445AbaI3LHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 07:07:41 -0400
Received: by mail-ie0-f178.google.com with SMTP id rl12so6309100iec.37
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 04:07:40 -0700 (PDT)
In-Reply-To: <20140930085114.24043.81310.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/30/14 04:53, Jesper Dangaard Brouer wrote:

[..]
> To avoid overshooting the HW limits, which results in requeuing, the
> patch limits the amount of bytes dequeued, based on the drivers BQL
> limits.  In-effect bulking will only happen for BQL enabled drivers.
> Besides the bytelimit from BQL, also limit bulking to maximum 7
> packets to avoid any issues with available descriptor in HW and
> any HoL issues measured at 100Mbit/s.
>


[..]

>
> The measured perf diff benefit (at 10Gbit/s) for TCP_STREAM were 4.66%
> less CPU used on calls to _raw_spin_lock() (mostly from sch_direct_xmit).
>
> Tool mpstat, while stressing the system with netperf 24x TCP_STREAM, shows:
>   * Disabled bulking: 8.30% soft 88.75% idle
>   * Enabled  bulking: 7.80% soft 89.36% idle
>

I know you have put a lot of hard work here and i hate to do
this to you, but:
The base test case is to surely *not to allow* the bulk code to be
executed at all. i.e when you say "disabled bulking" it
should mean not calling qdisc_may_bulk or qdisc_avail_bulklimit()
because that code was not there initially.  My gut feeling is you
will find that your numbers for "Disabled bulking" to be a lot lower
than you show.
This is because no congestion likely happens at 24x TCP_STREAM
running at 10G with a modern day cpu and therefore you will end up
consuming more cpu.

Note, there are benefits as you have shown - but i would not
consider those to be standard use cases (actully one which would
have shown clear win is the VM thing Rusty was after). For this reason
my view is that i should be able to disable via ifdef bulking (yes, I
know DaveM hates ifdefs ;->).

cheers,
jamal
