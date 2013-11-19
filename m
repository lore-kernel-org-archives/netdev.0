From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net v3 1/2] net: sched: tbf: fix calculation of max_size
Date: Tue, 19 Nov 2013 10:38:28 +0100
Message-ID: <20131119103828.5697d5c9@redhat.com>
References: <1384845939-8424-1-git-send-email-yangyingliang@huawei.com>
	<1384845939-8424-2-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<eric.dumazet@gmail.com>, <brouer@redhat.com>, <jpirko@redhat.com>
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20233 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751380Ab3KSJik (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Nov 2013 04:38:40 -0500
In-Reply-To: <1384845939-8424-2-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 Nov 2013 15:25:38 +0800
Yang Yingliang <yangyingliang@huawei.com> wrote:

> commit b757c9336d63f94c6b57532(tbf: improved accuracy at high rates)
> introduce a regression.
> 
> With the follow command:
> tc qdisc add dev eth1 root handle 1: tbf latency 50ms burst 10KB rate 30gbit mtu 64k
> 
> Without this patch, the max_size value is 10751(bytes).
> But, in fact, the real max_size value should be smaller than 7440(bytes).
> Or a packet whose length is bigger than 7440 will cause network congestion.
> Because the packet is so big that can't get enough tokens. Even all the tokens
> in the buffer is given to the packet.

Sorry, but I don't like the commit message.  The real problem is the
value in q->buffer, and that the userspace rate table cannot handle
these high rates, which you don't mention.

I would write something like:

The kernel no longer uses the userspace provided rate table.  Thus, it
is wrong to calculate max_size based on this rate table.  At high rates
this rate table gets very inaccurate, which can lead wrong calculation
of max_size.

Consequence of max_size being too large is severe, and cause packets
being stalled in tbf_dequeue() because it cannot get enough tokens.
The max_size guards against enqueuing packet sizes above q->buffer
"time" in tbf_enqueue().

This patch fixes the calculation of max_size. By ... add desc ...
perhaps also mention how it is connected to p->mtu (with is also a
"time" value).


The rest of the patch looks okay now, one point below though.


> diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
> index 68f9859..c194129 100644
> --- a/net/sched/sch_tbf.c
> +++ b/net/sched/sch_tbf.c
[...]
> @@ -339,30 +326,46 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
[...]
> +	for (n = 0; n < 65536; n++)
> +		if (psched_l2t_ns(&q->rate, n) > q->buffer)
> +			break;
> +	max_size = min_t(u32, n, (256ULL << qopt->rate.cell_log) - 1);

I'm a little uncertain about, if using the 65536 constant is okay, or
considered "bad style".

I'm still a little confused/uncertain why we need the "qopt->rate.cell_log".

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
