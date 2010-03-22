From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] Improved network performance by balancing Rx against
 other work
Date: Tue, 23 Mar 2010 00:27:55 +1100
Message-ID: <20100322132754.GO17637@laptop>
References: <87tysfu05d.wl%peterc@chubb.wattle.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Peter Chubb <peter.chubb@nicta.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:53099 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752014Ab0CVN17 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Mar 2010 09:27:59 -0400
Content-Disposition: inline
In-Reply-To: <87tysfu05d.wl%peterc@chubb.wattle.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 17, 2010 at 01:55:58PM +1100, Peter Chubb wrote:
> +static int e1000_intr_thread(void *data)
> +{
> +	struct net_device *netdev = data;
> +	struct e1000_adapter *adapter = netdev_priv(netdev);
> +	const int budget = 32; // FIXME should be auto-tuneable
> +	int tx_clean_complete = 0, work_done = 0;
> +
> +	while(!e1000_wait_for_intr(adapter)) {
> +		do {
> +			work_done = 0;
> +
> +			tx_clean_complete = e1000_clean_tx_irq(adapter, &adapter->tx_ring[0]);
> +			adapter->clean_rx(adapter, &adapter->rx_ring[0], &work_done, budget);
> +			if (!tx_clean_complete)
> +				work_done = budget;
> +
> +			if (work_done == budget) {
> +				/*
> +				 * Give up the rest of the timeslice to allow
> +				 * userspace to make forward progress
> +				 */
> +				sys_sched_yield();

sched_yield literally has undefined semantics if you are in SCHED_OTHER
priority (which your thread is). sched_yield use in userspace and even
kernel has caused headaches whenever the scheduler changes
significantly.

Please use anything but sched_yield. cond_resched() looks appropriate
here, it gives a simple resched point on !PREEMPT kernels. Then the
scheduler nice levels and newer resource controls should give sufficient
flexibility to fine tune CPU allocation after that.


> +			}
> +		} while (work_done == budget);
> +
> +		/* If budget not fully consumed, wait for an interrupt */
> +		adapter->last_icr = 0;
> +		if (likely(adapter->itr_setting & 3))
> +			e1000_set_itr(adapter);
> +		if (!test_bit(__E1000_DOWN, &adapter->flags))
> +			e1000_irq_enable(adapter);
> +	}
> +	return 0;
> +}

