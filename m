From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC net-next PATCH V2 2/3] qdisc: bulk dequeue support for
 qdiscs with TCQ_F_ONETXQUEUE
Date: Thu, 4 Sep 2014 15:17:02 +0200
Message-ID: <20140904131702.GA934@breakpoint.cc>
References: <20140904125247.4108.8132.stgit@dragon>
 <20140904125438.4108.38160.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:55582 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751172AbaIDNRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 09:17:08 -0400
Content-Disposition: inline
In-Reply-To: <20140904125438.4108.38160.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> Some detail about the flow; dev_hard_start_xmit() will process the skb
> list, and transmit packets individually towards the driver (see
> xmit_one()).  In case the driver stops midway in the list, the
> remaining skb list is returned by dev_hard_start_xmit().  In
> sch_direct_xmit() this returned list is requeued by dev_requeue_skb().
> 
> The patch also tries to limit the amount of bytes dequeued, based on
> the drivers BQL limits.  It also tries to avoid and stop dequeuing
> when seeing a GSO packet (both real GSO and segmented GSO skb lists).
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> +static inline struct sk_buff *qdisc_bulk_dequeue_skb(struct Qdisc *q,
> +						     struct sk_buff *head)
> +{
> +	struct sk_buff *new, *skb = head;
> +	struct netdev_queue *txq = q->dev_queue;
> +	int bytelimit = netdev_tx_avail_queue(txq);
> +	int limit = 5;
> +
> +	if (bytelimit <= 0)
> +		return head;

bytelimit < psched_mtu(qdisc_dev(q)) ?
It would avoid overshooting bql on next dequeue operation.

> +			 * Requeue is difficult because if requeuing
> +			 * on q->gso_skb, then a second requeue can
> +			 * happen from sch_direct_xmit e.g. if driver
> +			 * returns NETDEV_TX_BUSY, which would
> +			 * overwrite this requeue.
> +			 */

Perhaps we should just free the entire list in such a case;
it would also permit extending this to qdisc with
multiple tx queues later (since you could requeue skb
if the txq mapping changes)?

It would also allow use of qdisc_peek helpers to only dequeue
skb when it is suitable for bulking.

Unrelated to your patch: q->gso_skb should be renamed.
It has nothing to do with gso anymore...
