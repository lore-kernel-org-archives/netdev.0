From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: QFQ Plus: fair-queueing service at DRR cost
Date: Tue, 20 Nov 2012 13:54:09 -0500 (EST)
Message-ID: <20121120.135409.1810847883436963918.davem@davemloft.net>
References: <20121120174513.GA21618@paolo-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, shemminger@vyatta.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rizzo@iet.unipi.it, fchecconi@gmail.com
To: paolo.valente@unimore.it
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121120174513.GA21618@paolo-ThinkPad-W520>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paolo Valente <paolo.valente@unimore.it>
Date: Tue, 20 Nov 2012 18:45:13 +0100

> -	struct sk_buff *skb;
> +	struct sk_buff *skb = NULL;

This is not really an improvement, now the compiler can think
that NULL is passed eventually into qdisc_bstats_update().

Please make the logic easier for the compiler to digest.

For example, restructure the top-level logic into something like:

	skb = NULL;
	if (!list_empty(&in_serv_agg->active))
		skb = qfq_peek_skb(in_serv_agg, &cl, &len);
	else
		len = 0; /* no more active classes in the in-service agg */

	if (len == 0 || in_serv_agg->budget < len) {
 ...
		/*
		 * If we get here, there are other aggregates queued:
		 * choose the new aggregate to serve.
		 */
		in_serv_agg = q->in_serv_agg = qfq_choose_next_agg(q);
		skb = qfq_peek_skb(in_serv_agg, &cl, &len);
	}
	if (!skb)
		return NULL;

That way it is clearer, to both humans and the compiler, what is
going on here.

Thanks.
