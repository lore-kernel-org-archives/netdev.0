From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next PATCH 1/1 V4] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Wed, 24 Sep 2014 19:38:40 -0700
Message-ID: <CA+mtBx-3HTHvodGXJ_zHArbeLtbeTc3XUc_CZr4CgfvU9BiDAA@mail.gmail.com>
References: <20140924160932.9721.56450.stgit@localhost>
	<20140924161047.9721.43080.stgit@localhost>
	<1411579395.15395.41.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140924195831.6fb91051@redhat.com>
	<CA+mtBx8s63TDe1XS7TzfscwhiRCgyeLkKLz2p-4et1erX0-dUQ@mail.gmail.com>
	<1411586550.15395.46.camel@edumazet-glaptop2.roam.corp.google.com>
	<1411611140.16953.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>,
	Florian Westphal <fw@strlen.de>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Dave Taht <dave.taht@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:36348 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751603AbaIYCil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 22:38:41 -0400
Received: by mail-ie0-f172.google.com with SMTP id rp18so10818662iec.17
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 19:38:41 -0700 (PDT)
In-Reply-To: <1411611140.16953.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 24, 2014 at 7:12 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2014-09-24 at 12:22 -0700, Eric Dumazet wrote:
>> On Wed, 2014-09-24 at 11:34 -0700, Tom Herbert wrote:
>> > >
>> > I believe drivers typically use skb->len for BQL tracking. Since
>> > bytelimit is based on BQL here, it might be more correct to use
>> > skb->len.
>
> Speaking of BQL, I wonder if we now should try to not wakeup queues as
> soon some room was made, and instead have a 50% threshold ?
>
> This would probably increase probability to have bulk dequeues ;)
>
It would be good to have data on that. In the absence of TSO, I've
seen BQL limits at around 30K for "standard" interrupt rates on 10G.
This should mean that ~15K becomes available every interrupt period
(the math is actually straightforward), so that should already have 10
packet batches which isn't bad!

It's also probably true that we can tradeoff batching for latency in
many ways-- more batching increase latency, less batching helps
latency. For instance, the interrupt rate can be modulated to balance
between latency and batching (CPU utilization).

Tom

>
> diff --git a/include/linux/dynamic_queue_limits.h b/include/linux/dynamic_queue_limits.h
> index 5621547d631b..c0be7ff5ae97 100644
> --- a/include/linux/dynamic_queue_limits.h
> +++ b/include/linux/dynamic_queue_limits.h
> @@ -83,6 +83,13 @@ static inline int dql_avail(const struct dql *dql)
>         return dql->adj_limit - dql->num_queued;
>  }
>
> +/* Returns true if a queue occupancy is less than half capacity */
> +static inline bool dql_half_avail(const struct dql *dql)
> +{
> +       return dql->adj_limit >= (dql->num_queued << 1);
> +}
> +
> +
>  /* Record number of completed objects and recalculate the limit. */
>  void dql_completed(struct dql *dql, unsigned int count);
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index c8e388e5fccc..1f7541284b32 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2413,7 +2413,7 @@ static inline void netdev_tx_sent_queue(struct netdev_queue *dev_queue,
>         smp_mb();
>
>         /* check again in case another CPU has just made room avail */
> -       if (unlikely(dql_avail(&dev_queue->dql) >= 0))
> +       if (unlikely(dql_half_avail(&dev_queue->dql)))
>                 clear_bit(__QUEUE_STATE_STACK_XOFF, &dev_queue->state);
>  #endif
>  }
> @@ -2448,7 +2448,7 @@ static inline void netdev_tx_completed_queue(struct netdev_queue *dev_queue,
>          */
>         smp_mb();
>
> -       if (dql_avail(&dev_queue->dql) < 0)
> +       if (!dql_half_avail(&dev_queue->dql))
>                 return;
>
>         if (test_and_clear_bit(__QUEUE_STATE_STACK_XOFF, &dev_queue->state))
>
>
