From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 2/2]: niu: Manage TX backlog in-driver.
Date: Mon, 23 Jun 2008 10:04:45 +0800
Message-ID: <485F04BD.6090601@cn.fujitsu.com>
References: <20080622.161658.115278698.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vinay@linux.vnet.ibm.com,
	krkumar2@in.ibm.com, matheos.worku@sun.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56335 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752612AbYFWCIu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jun 2008 22:08:50 -0400
In-Reply-To: <20080622.161658.115278698.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-6-23 7:16:
> +
> +		while ((skb = __skb_dequeue(&rp->tx_backlog)) != NULL)
> +			dev_kfree_skb(skb);

How about __skb_queue_purge(&rp->tx_backlog);

> +static void __niu_tx_queue_backlog(struct niu *np, struct tx_ring_info *rp,
> +				   struct sk_buff *skb)
> +{
> +	if (skb_queue_len(&rp->tx_backlog) < np->dev->tx_queue_len)
> +		__skb_queue_tail(&rp->tx_backlog, skb);

Do we need lock to proteck tx_backlog?
How about use skb_queue_tail()?

> +	else
> +		dev_kfree_skb(skb);
> +
> +	smp_mb();
> +
> +	/* This is a deadlock breaker.  niu_tx_work() updates the consumer
> +	 * index, then checks the tx_backlog for emptiness.  It also
> +	 * tries to mitigate work by only flushing the backlog when at
> +	 * least a certain percentage of space is available.  Those
> +	 * tests in niu_tx_work() run lockless.
> +	 *
> +	 * Here, we make the two primary memory operations in the
> +	 * reverse order.  The idea is to make sure that one of these
> +	 * two code paths will process the backlog no matter what the
> +	 * order of their relative execution might be.
> +	 *
> +	 * In short:
> +	 *
> +	 * niu_tx_work() --> rp->cons = foo; test skb_queue_empty()
> +	 * niu_start_xmit() --> __skb_queue_tail(); test rp->cons
> +	 */
> +	if (niu_tx_avail(rp) > NIU_TX_WAKEUP_THRESH(rp))
> +		__niu_xmit_backlog(np, rp);
> +}
> +

