From: David Miller <davem@davemloft.net>
Subject: Re: softirqs are invoked while bottom halves are masked
Date: Tue, 12 Jul 2011 03:01:04 -0700 (PDT)
Message-ID: <20110712.030104.585873452291819607.davem@davemloft.net>
References: <CAAXf6LXHeiCT+n=Wpdf=QfUXUHUSd7fmx9y3kB7te8N3ON1fTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, linuxppc-dev@ozlabs.org,
	ronny.meeus@gmail.com, netdev@vger.kernel.org
To: patrickdepinguin+linuxppc@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58081 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241Ab1GLKCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 06:02:23 -0400
In-Reply-To: <CAAXf6LXHeiCT+n=Wpdf=QfUXUHUSd7fmx9y3kB7te8N3ON1fTg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas De Schampheleire <patrickdepinguin+linuxppc@gmail.com>
Date: Tue, 12 Jul 2011 11:23:28 +0200

> Note that the reason we are seeing this problem, may be because the
> kernel we are using contains some patches from Freescale.
> Specifically, in dev_queue_xmit(), support is added for hardware queue
> handling, just before entering the rcu_read_lock_bh():
> 
>         if (dev->features & NETIF_F_HW_QDISC) {
>                 txq = dev_pick_tx(dev, skb);
>                 return dev_hard_start_xmit(skb, dev, txq);
>         }
> 
>         /* Disable soft irqs for various locks below. Also
>          * stops preemption for RCU.
>          */
>         rcu_read_lock_bh();
> 
> We just tried moving the escaping to dev_hard_start_xmit() after
> taking the lock, but this gives a large number of other problems, e.g.

This is definitely why you are seeing this behavior.

You cannot invoke dev_hard_start_xmit() without softirqs
being disabled.  It breaks everything.

This is what happens when you integrate networking patches
which were not reviewed and vetted on netdev.
