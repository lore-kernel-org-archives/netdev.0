From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH 1/2] tipc: avoid possible deadlock while remove link_timeout()
Date: Fri, 9 Aug 2013 10:39:58 +0800
Message-ID: <5204567E.2050805@windriver.com>
References: <520376BA.5040509@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:48027 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966749Ab3HICkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 22:40:25 -0400
In-Reply-To: <520376BA.5040509@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/08/2013 06:45 PM, Ding Tianhong wrote:
> We met lockdep warning when enable and disable the bearer for commands such as:
> 
> tipc-config -netid=1234 -addr=1.1.3 -be=eth:eth0
> tipc-config -netid=1234 -addr=1.1.3 -bd=eth:eth0
> 
> [ 3001.445459] tipc: Established link <1.1.3:eth0-1.1.2:br0> on network plane A
> [ 3029.457875] tipc: Disabling bearer <eth:eth0>
> [ 3029.458066]
> [ 3029.458071] ======================================================
> [ 3029.458075] [ INFO: possible circular locking dependency detected ]
> [ 3029.458080] 3.11.0-rc3-wwd-default #4 Not tainted
> [ 3029.458084] -------------------------------------------------------
> [ 3029.458088] rmmod/7092 is trying to acquire lock:
> [ 3029.458092]  (((timer))#3){+.-...}, at: [<ffffffff8105be80>] del_timer_sync+0x0/0xd0
> [ 3029.458107]
> [ 3029.458107] but task is already holding lock:
> [ 3029.458112]  (&(&b_ptr->lock)->rlock){+.-...}, at: [<ffffffffa02b94e3>] bearer_disable+0x33/0xd0 [tipc]
> [ 3029.458126]
> [ 3029.458126] which lock already depends on the new lock.
> [ 3029.458126]
> [ 3029.458132]
> [ 3029.458132] the existing dependency chain (in reverse order) is:
> [ 3029.458137]
> [ 3029.458137] -> #2 (&(&b_ptr->lock)->rlock){+.-...}:
> [ 3029.458143]        [<ffffffff810b3b4d>] validate_chain+0x6dd/0x870
> [ 3029.458151]        [<ffffffff810b40bb>] __lock_acquire+0x3db/0x670
> [ 3029.458156]        [<ffffffff810b4453>] lock_acquire+0x103/0x130
> [ 3029.458161]        [<ffffffff814d65b1>] _raw_spin_lock_bh+0x41/0x80
> [ 3029.458169]        [<ffffffffa02b9600>] tipc_bearer_blocked+0x20/0x40 [tipc]
> [ 3029.458176]        [<ffffffffa02bf01b>] tipc_link_send_proto_msg+0x35b/0x520 tipc]
> [ 3029.458184]        [<ffffffffa02bf83a>] link_state_event+0x33a/0x590 [tipc]
> [ 3029.458191]        [<ffffffffa02bfab9>] link_start+0x29/0x40 [tipc]
> [ 3029.458198]        [<ffffffffa02bb13f>] process_signal_queue+0x7f/0xc0 [tipc]
> [ 3029.458206]        [<ffffffff8105304d>] tasklet_action+0x6d/0xf0
> [ 3029.458214]        [<ffffffff8105379a>] __do_softirq+0x16a/0x2e0
> [ 3029.458219]        [<ffffffff81053945>] run_ksoftirqd+0x35/0x50
> [ 3029.458224]        [<ffffffff8107d042>] smpboot_thread_fn+0x1e2/0x2f0
> [ 3029.458235]        [<ffffffff81073c5e>] kthread+0xde/0xf0
> [ 3029.458242]        [<ffffffff814de7ac>] ret_from_fork+0x7c/0xb0
> [ 3029.458250]
> [ 3029.458250] -> #1 (&(&n_ptr->lock)->rlock){+.-...}:
> [ 3029.458257]        [<ffffffff810b3b4d>] validate_chain+0x6dd/0x870
> [ 3029.458262]        [<ffffffff810b40bb>] __lock_acquire+0x3db/0x670
> [ 3029.458268]        [<ffffffff810b4453>] lock_acquire+0x103/0x130
> [ 3029.458273]        [<ffffffff814d65b1>] _raw_spin_lock_bh+0x41/0x80
> [ 3029.458279]        [<ffffffffa02bfaec>] link_timeout+0x1c/0x170 [tipc]
> [ 3029.458287]        [<ffffffff8105b92a>] call_timer_fn+0xda/0x1e0
> [ 3029.458292]        [<ffffffff8105bcd7>] run_timer_softirq+0x2a7/0x2d0
> [ 3029.458298]        [<ffffffff8105379a>] __do_softirq+0x16a/0x2e0
> [ 3029.458304]        [<ffffffff81053a35>] irq_exit+0xd5/0xe0
> [ 3029.458309]        [<ffffffff81033005>] smp_apic_timer_interrupt+0x45/0x60
> [ 3029.458319]        [<ffffffff814df4af>] apic_timer_interrupt+0x6f/0x80
> [ 3029.458325]        [<ffffffff8100b70e>] arch_cpu_idle+0x1e/0x30
> [ 3029.458332]        [<ffffffff810a039d>] cpu_idle_loop+0x1fd/0x280
> [ 3029.458338]        [<ffffffff810a043e>] cpu_startup_entry+0x1e/0x20
> [ 3029.458343]        [<ffffffff814c8841>] rest_init+0xc1/0xd0
> [ 3029.458349]        [<ffffffff81c990fc>] start_kernel+0x3a3/0x451
> [ 3029.458356]        [<ffffffff81c984d1>] x86_64_start_reservations+0x1b/0x32
> [ 3029.458362]        [<ffffffff81c98622>] x86_64_start_kernel+0x13a/0x141
> [ 3029.458368]
> [ 3029.458368] -> #0 (((timer))#3){+.-...}:
> [ 3029.458375]        [<ffffffff810b33fe>] check_prev_add+0x43e/0x4b0
> [ 3029.458380]        [<ffffffff810b3b4d>] validate_chain+0x6dd/0x870
> [ 3029.458386]        [<ffffffff810b40bb>] __lock_acquire+0x3db/0x670
> [ 3029.458391]        [<ffffffff810b4453>] lock_acquire+0x103/0x130
> [ 3029.458397]        [<ffffffff8105bebd>] del_timer_sync+0x3d/0xd0
> [ 3029.458402]        [<ffffffffa02bcc4e>] tipc_link_delete+0x1e/0xb0 [tipc]
> [ 3029.458410]        [<ffffffffa02b9528>] bearer_disable+0x78/0xd0 [tipc]
> [ 3029.458417]        [<ffffffffa02b95b4>] tipc_bearer_stop+0x34/0x60 [tipc]
> [ 3029.458423]        [<ffffffffa02c384b>] tipc_net_stop+0x2b/0x90 [tipc]
> [ 3029.458432]        [<ffffffffa02caf49>] tipc_exit+0x9/0xc0 [tipc]
> [ 3029.458439]        [<ffffffff810c1a58>] SyS_delete_module+0x198/0x290
> [ 3029.458445]        [<ffffffff814de852>] system_call_fastpath+0x16/0x1b
> [ 3029.458451]
> [ 3029.458451] other info that might help us debug this:
> [ 3029.458451]
> [ 3029.458458] Chain exists of:
> [ 3029.458458]   ((timer))#3 --> &(&n_ptr->lock)->rlock --> &(&b_ptr->lock)->rlock
> [ 3029.458458]
> [ 3029.458469]  Possible unsafe locking scenario:
> [ 3029.458469]
> [ 3029.458474]        CPU0                    CPU1
> [ 3029.458478]        ----                    ----
> [ 3029.458481]   lock(&(&b_ptr->lock)->rlock);
> [ 3029.458486]                                lock(&(&n_ptr->lock)->rlock);
> [ 3029.458492]                                lock(&(&b_ptr->lock)->rlock);
> [ 3029.458497]   lock(((timer))#3);
> [ 3029.458502]
> [ 3029.458502]  *** DEADLOCK ***
> [ 3029.458502]
> [ 3029.458508] 2 locks held by rmmod/7092:
> [ 3029.458511]  #0:  (tipc_net_lock){++.-..}, at: [<ffffffffa02c3846>] tipc_net_stop+0x26/0x90 [tipc]
> [ 3029.458523]  #1:  (&(&b_ptr->lock)->rlock){+.-...}, at: [<ffffffffa02b94e3>]bearer_disable+0x33/0xd0 [tipc]
> [ 3029.458535]
> [ 3029.458535] stack backtrace:
> [ 3029.458541] CPU: 3 PID: 7092 Comm: rmmod Not tainted 3.11.0-rc3-wwd-default #4
> [ 3029.458546] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
> [ 3029.458550]  00000000ffffffff ffff88010fd09c08 ffffffff814d03dd 0000000000000000
> [ 3029.458559]  ffffffff8205fca0 ffff88010fd09c48 ffffffff810b1c4f 000000000fd09c48
> [ 3029.458566]  ffff88010fd09c68 ffff88010e4d4fc0 0000000000000000 ffff88010e4d56f0
> [ 3029.458574] Call Trace:
> [ 3029.458579]  [<ffffffff814d03dd>] dump_stack+0x4d/0xa0
> [ 3029.458585]  [<ffffffff810b1c4f>] print_circular_bug+0x10f/0x120
> [ 3029.458591]  [<ffffffff810b33fe>] check_prev_add+0x43e/0x4b0
> [ 3029.458598]  [<ffffffff8100a226>] ? native_sched_clock+0x26/0x90
> [ 3029.458604]  [<ffffffff810b3b4d>] validate_chain+0x6dd/0x870
> [ 3029.458612]  [<ffffffff81087a28>] ? sched_clock_cpu+0xd8/0x110
> [ 3029.458618]  [<ffffffff810b40bb>] __lock_acquire+0x3db/0x670
> [ 3029.458624]  [<ffffffff810b4453>] lock_acquire+0x103/0x130
> [ 3029.458629]  [<ffffffff8105be80>] ? try_to_del_timer_sync+0x70/0x70
> [ 3029.458635]  [<ffffffff8105bebd>] del_timer_sync+0x3d/0xd0
> [ 3029.458641]  [<ffffffff8105be80>] ? try_to_del_timer_sync+0x70/0x70
> [ 3029.458649]  [<ffffffffa02bcc4e>] tipc_link_delete+0x1e/0xb0 [tipc]
> [ 3029.458656]  [<ffffffffa02b9528>] bearer_disable+0x78/0xd0 [tipc]
> [ 3029.458663]  [<ffffffffa02b95b4>] tipc_bearer_stop+0x34/0x60 [tipc]
> [ 3029.458671]  [<ffffffffa02c384b>] tipc_net_stop+0x2b/0x90 [tipc]
> [ 3029.458679]  [<ffffffffa02caf49>] tipc_exit+0x9/0xc0 [tipc]
> [ 3029.458685]  [<ffffffff810c1a58>] SyS_delete_module+0x198/0x290
> [ 3029.458691]  [<ffffffff814de852>] system_call_fastpath+0x16/0x1b
> 
> ----------------------------------------------------------------------
> 
> The problem is that the tipc_link_delete() will cancel the timer l_ptr->timer when
> the b_ptr->lock is hold, but the l_ptr->timer still call b_ptr->lock to finish the
> work, so the dead lock occurs.
> 

I guess the issue would disappear if you apply below patch:

http://article.gmane.org/gmane.network.tipc.general/4380

And the patch will be submitted into net-next tree soon.

Regards,
Ying

> We should unlock the b_ptr->lock when del the l_ptr->timer.
> 
> Reported-by: Wang Weidong <wangweidong1@huawei.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>  net/tipc/bearer.c | 8 +++++++-
>  net/tipc/link.c   | 2 ++
>  2 files changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
> index cb29ef7..7687211 100644
> --- a/net/tipc/bearer.c
> +++ b/net/tipc/bearer.c
> @@ -460,14 +460,20 @@ static void bearer_disable(struct tipc_bearer *b_ptr)
>  {
>  	struct tipc_link *l_ptr;
>  	struct tipc_link *temp_l_ptr;
> +	struct list_head list;
>  
>  	pr_info("Disabling bearer <%s>\n", b_ptr->name);
>  	spin_lock_bh(&b_ptr->lock);
>  	b_ptr->blocked = 1;
>  	b_ptr->media->disable_bearer(b_ptr);
> -	list_for_each_entry_safe(l_ptr, temp_l_ptr, &b_ptr->links, link_list) {
> +	list_replace_init(&b_ptr->links, &list);
> +	spin_unlock_bh(&b_ptr->lock);
> +
> +	list_for_each_entry_safe(l_ptr, temp_l_ptr, &list, link_list) {
>  		tipc_link_delete(l_ptr);
>  	}
> +
> +	spin_lock_bh(&b_ptr->lock);
>  	if (b_ptr->link_req)
>  		tipc_disc_delete(b_ptr->link_req);
>  	spin_unlock_bh(&b_ptr->lock);
> diff --git a/net/tipc/link.c b/net/tipc/link.c
> index 0cc3d90..a145718 100644
> --- a/net/tipc/link.c
> +++ b/net/tipc/link.c
> @@ -384,10 +384,12 @@ void tipc_link_delete(struct tipc_link *l_ptr)
>  	k_cancel_timer(&l_ptr->timer);
>  
>  	tipc_node_lock(l_ptr->owner);
> +	spin_lock_bh(&l_ptr->b_ptr->lock);
>  	tipc_link_reset(l_ptr);
>  	tipc_node_detach_link(l_ptr->owner, l_ptr);
>  	tipc_link_stop(l_ptr);
>  	list_del_init(&l_ptr->link_list);
> +	spin_unlock_bh(&l_ptr->b_ptr->lock);
>  	tipc_node_unlock(l_ptr->owner);
>  	k_term_timer(&l_ptr->timer);
>  	kfree(l_ptr);
> 
