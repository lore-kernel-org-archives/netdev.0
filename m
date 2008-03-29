From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 20/21] forcedeth: fix locking bug with netconsole
Date: Fri, 28 Mar 2008 22:09:47 -0400
Message-ID: <47EDA4EB.5060608@garzik.org>
References: <200803282141.m2SLfUwU011858@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mingo@elte.hu, aabdulla@nvidia.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38107 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752696AbYC2CJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 22:09:50 -0400
In-Reply-To: <200803282141.m2SLfUwU011858@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Ingo Molnar <mingo@elte.hu>
> 
> While using netconsole on forcedeth, lockdep noticed the following locking
> bug:
> 
> =================================
> [ INFO: inconsistent lock state ]
> 2.6.24-rc6 #6
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
> ---------------------------------
> inconsistent {softirq-on-W} -> {in-softirq-W} usage.
> udevd/719 [HC0[0]:SC1[1]:HE1:SE0] takes:
>  (_xmit_ETHER){-+..}, at: [<c043062e>] dev_watchdog+0x1c/0xb9
> {softirq-on-W} state was registered at:
>   [<c0147f67>] mark_held_locks+0x4e/0x66
>   [<c014810e>] trace_hardirqs_on+0xfe/0x136
>   [<c048ae63>] _spin_unlock_irq+0x22/0x42
>   [<c02ec617>] nv_start_xmit_optimized+0x347/0x37a
>   [<c042c80d>] netpoll_send_skb+0xa4/0x147
>   [<c042d4a6>] netpoll_send_udp+0x238/0x242
>   [<c02f44f6>] write_msg+0x6d/0x9b
>   [<c012c129>] __call_console_drivers+0x4e/0x5a
>   [<c012c18c>] _call_console_drivers+0x57/0x5b
>   [<c012c2dd>] release_console_sem+0x11c/0x1b9
>   [<c012caeb>] register_console+0x1eb/0x1f3
>   [<c06ae673>] init_netconsole+0x119/0x15f
>   [<c069149b>] kernel_init+0x147/0x294
>   [<c01058cb>] kernel_thread_helper+0x7/0x10
>   [<ffffffff>] 0xffffffff
> irq event stamp: 950
> hardirqs last  enabled at (950): [<c048ae63>] _spin_unlock_irq+0x22/0x42
> hardirqs last disabled at (949): [<c048aaf7>] _spin_lock_irq+0xc/0x38
> softirqs last  enabled at (0): [<c012a29c>] copy_process+0x375/0x126d
> softirqs last disabled at (947): [<c0106d43>] do_softirq+0x61/0xc6
> 
> other info that might help us debug this:
> no locks held by udevd/719.
> 
> stack backtrace:
> Pid: 719, comm: udevd Not tainted 2.6.24-rc6 #6
>  [<c0105c46>] show_trace_log_lvl+0x12/0x25
>  [<c01063ec>] show_trace+0xd/0x10
>  [<c010670c>] dump_stack+0x57/0x5f
>  [<c0147505>] print_usage_bug+0x10a/0x117
>  [<c0147c38>] mark_lock+0x121/0x402
>  [<c01488b6>] __lock_acquire+0x3d1/0xb64
>  [<c0149405>] lock_acquire+0x4e/0x6a
>  [<c048a99b>] _spin_lock+0x23/0x32
>  [<c043062e>] dev_watchdog+0x1c/0xb9
>  [<c0133e4a>] run_timer_softirq+0x133/0x193
>  [<c0130907>] __do_softirq+0x78/0xed
>  [<c0106d43>] do_softirq+0x61/0xc6
>  =======================
> eth1: link down
> 
> The fix is to disable/restore irqs instead of disable/enable.
> 
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
> Cc: Ayaz Abdulla <aabdulla@nvidia.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/forcedeth.c |   18 ++++++++++--------
>  net/core/netpoll.c      |    3 +++
>  2 files changed, 13 insertions(+), 8 deletions(-)
> 
> diff -puN drivers/net/forcedeth.c~forcedeth-fix-locking-bug-with-netconsole drivers/net/forcedeth.c
> --- a/drivers/net/forcedeth.c~forcedeth-fix-locking-bug-with-netconsole
> +++ a/drivers/net/forcedeth.c
> @@ -1854,6 +1854,7 @@ static int nv_start_xmit(struct sk_buff 
>  	struct ring_desc* start_tx;
>  	struct ring_desc* prev_tx;
>  	struct nv_skb_map* prev_tx_ctx;
> +	unsigned long flags;
>  
>  	/* add fragments to entries count */
>  	for (i = 0; i < fragments; i++) {
> @@ -1863,10 +1864,10 @@ static int nv_start_xmit(struct sk_buff 
>  
>  	empty_slots = nv_get_empty_tx_slots(np);
>  	if (unlikely(empty_slots <= entries)) {
> -		spin_lock_irq(&np->lock);
> +		spin_lock_irqsave(&np->lock, flags);
>  		netif_stop_queue(dev);
>  		np->tx_stop = 1;
> -		spin_unlock_irq(&np->lock);
> +		spin_unlock_irqrestore(&np->lock, flags);
>  		return NETDEV_TX_BUSY;
>  	}
>  
> @@ -1929,13 +1930,13 @@ static int nv_start_xmit(struct sk_buff 
>  		tx_flags_extra = skb->ip_summed == CHECKSUM_PARTIAL ?
>  			 NV_TX2_CHECKSUM_L3 | NV_TX2_CHECKSUM_L4 : 0;
>  
> -	spin_lock_irq(&np->lock);
> +	spin_lock_irqsave(&np->lock, flags);
>  
>  	/* set tx flags */
>  	start_tx->flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
>  	np->put_tx.orig = put_tx;
>  
> -	spin_unlock_irq(&np->lock);
> +	spin_unlock_irqrestore(&np->lock, flags);
>  
>  	dprintk(KERN_DEBUG "%s: nv_start_xmit: entries %d queued for transmission. tx_flags_extra: %x\n",
>  		dev->name, entries, tx_flags_extra);
> @@ -1971,6 +1972,7 @@ static int nv_start_xmit_optimized(struc
>  	struct ring_desc_ex* prev_tx;
>  	struct nv_skb_map* prev_tx_ctx;
>  	struct nv_skb_map* start_tx_ctx;
> +	unsigned long flags;
>  
>  	/* add fragments to entries count */
>  	for (i = 0; i < fragments; i++) {
> @@ -1980,10 +1982,10 @@ static int nv_start_xmit_optimized(struc
>  
>  	empty_slots = nv_get_empty_tx_slots(np);
>  	if (unlikely(empty_slots <= entries)) {
> -		spin_lock_irq(&np->lock);
> +		spin_lock_irqsave(&np->lock, flags);
>  		netif_stop_queue(dev);
>  		np->tx_stop = 1;
> -		spin_unlock_irq(&np->lock);
> +		spin_unlock_irqrestore(&np->lock, flags);
>  		return NETDEV_TX_BUSY;
>  	}
>  
> @@ -2059,7 +2061,7 @@ static int nv_start_xmit_optimized(struc
>  			start_tx->txvlan = 0;
>  	}
>  
> -	spin_lock_irq(&np->lock);
> +	spin_lock_irqsave(&np->lock, flags);
>  
>  	if (np->tx_limit) {
>  		/* Limit the number of outstanding tx. Setup all fragments, but
> @@ -2085,7 +2087,7 @@ static int nv_start_xmit_optimized(struc
>  	start_tx->flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
>  	np->put_tx.ex = put_tx;
>  
> -	spin_unlock_irq(&np->lock);
> +	spin_unlock_irqrestore(&np->lock, flags);
>  
>  	dprintk(KERN_DEBUG "%s: nv_start_xmit_optimized: entries %d queued for transmission. tx_flags_extra: %x\n",
>  		dev->name, entries, tx_flags_extra);

applied (this forcedeth.c portion only)


