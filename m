From: Jon Maloy <jon.maloy@ericsson.com>
Subject: Re: [PATCH net] net: tipc: fix possible CPU stall while removing
 module
Date: Tue, 10 Dec 2013 12:20:20 -0800
Message-ID: <52A77784.1040309@ericsson.com>
References: <1386698071-9214-1-git-send-email-pablo@gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <allan.stephens@windriver.com>
To: Pablo Neira Ayuso <pablo@gnumonks.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usevmg21.ericsson.net ([198.24.6.65]:62011 "EHLO
	usevmg21.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691Ab3LJUUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 15:20:30 -0500
In-Reply-To: <1386698071-9214-1-git-send-email-pablo@gnumonks.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is already a patch in the queue fixing this issue.

http://marc.info/?l=linux-netdev&m=138665890819879&w=2

Regards
///jon


On 12/10/2013 09:54 AM, Pablo Neira Ayuso wrote:
> The following stall is possible while removing the tipc module:
> 
> [ 4244.091196] INFO: rcu_sched self-detected stall on CPU { 41}  (t=30001 jiffies)
> [ 4244.091414] Pid: 5311, comm: rmmod Tainted: G           O 3.4.51 #1
> [ 4244.091524] Call Trace:
> [ 4244.091618]  <IRQ>  [<ffffffff810b3741>] ? __rcu_pending+0x1a1/0x4d0
> [ 4244.091741]  [<ffffffff81085030>] ? tick_nohz_handler+0xe0/0xe0
> [ 4244.091848]  [<ffffffff810b3b18>] ? rcu_check_callbacks+0xa8/0x150
> [ 4244.091957]  [<ffffffff81046f3f>] ? update_process_times+0x3f/0x80
> [ 4244.092065]  [<ffffffff8108508b>] ? tick_sched_timer+0x5b/0xb0
> [ 4244.092172]  [<ffffffff8105d967>] ? __run_hrtimer+0x77/0x1c0
> [ 4244.092278]  [<ffffffff8105dd1f>] ? hrtimer_interrupt+0xef/0x270
> [ 4244.092386]  [<ffffffff8106714d>] ? ttwu_do_wakeup+0x3d/0x100
> [ 4244.092494]  [<ffffffff81020d43>] ? smp_apic_timer_interrupt+0x63/0xa0
> [ 4244.092605]  [<ffffffff8167fc4a>] ? apic_timer_interrupt+0x6a/0x70
> [ 4244.092714]  [<ffffffff81677985>] ? _raw_spin_lock_bh+0x25/0x30
> [ 4244.092820]  [<ffffffff81677969>] ? _raw_spin_lock_bh+0x9/0x30
> [ 4244.092936]  [<ffffffffa0333c45>] ? tipc_nodesub_unsubscribe+0x15/0x50 [tipc]
> [ 4244.093049]  [<ffffffffa03303ea>] ? named_purge_publ+0x3a/0x90 [tipc]
> [ 4244.093158]  [<ffffffff8103ee15>] ? __do_softirq+0xd5/0x1e0
> [ 4244.093266]  [<ffffffffa032a25b>] ? process_signal_queue+0x7b/0xc0 [tipc]
> [ 4244.093376]  [<ffffffff8103f41b>] ? tasklet_action+0xbb/0xd0
> [ 4244.093482]  [<ffffffff8103edf1>] ? __do_softirq+0xb1/0x1e0
> [ 4244.093589]  [<ffffffff8168059c>] ? call_softirq+0x1c/0x30
> [ 4244.093691]  <EOI>  [<ffffffff810041e5>] ? do_softirq+0x65/0xa0
> [ 4244.095460]  [<ffffffff8103f834>] ? local_bh_enable_ip+0x94/0xa0
> [ 4244.095570]  [<ffffffffa0332c93>] ? tipc_net_stop+0x73/0x90 [tipc]
> [ 4244.095679]  [<ffffffffa0339d61>] ? tipc_exit+0x9/0x29 [tipc]
> [ 4244.095786]  [<ffffffff8108e8bf>] ? sys_delete_module+0x1af/0x2b0
> [ 4244.095894]  [<ffffffff81677d75>] ? page_fault+0x25/0x30
> [ 4244.095999]  [<ffffffff8167f1b9>] ? system_call_fastpath+0x16/0x1b
> 
> The two things that trigger this oops are related to tipc_net_stop(), they
> are:
> 
> * tipc_net_stop() schedules the removal of the bearers via workqueue, which
>   includes the removal of the packet handler for the TIPC protocol family. So,
>   we have no time guarantees when the packet handler is removed.
> 
> * tipc_net_stop() cleans up the the tipc_node_list, so it releases all
>   tipc_node structures. However, the tipc_node_subscr structure still holds
>   a reference to the tipc_node structures, which is now invalid.
> 
> After leaving tipc_net_stop, BH are enabled again. If we have a TIPC
> message that is pending to be handled (in the softirq path), the packet
> handler will likely be still there, so it passes the packet to tipc_recv_msg().
> In that path, if the TIPC message announces a new service publication,
> named_purge_publ() is invoked, then tipc_nodesub_unsubscribe() to remove
> the node subscription happens. This function tries to get the node lock, but
> that structure was already released by tipc_net_stop(), so it stalls.
> 
> The proposed fix removes the bearers first so we make sure we get no more
> TIPC packets running through the input path, accessing the name-service
> base in inconsistent state (as tipc_node structures are not there anymore).
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@gnumonks.org>
> ---
>  net/tipc/core.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/tipc/core.c b/net/tipc/core.c
> index fd4eeea..7373fd9 100644
> --- a/net/tipc/core.c
> +++ b/net/tipc/core.c
> @@ -81,9 +81,9 @@ struct sk_buff *tipc_buf_acquire(u32 size)
>   */
>  static void tipc_core_stop_net(void)
>  {
> -	tipc_net_stop();
>  	tipc_eth_media_stop();
>  	tipc_ib_media_stop();
> +	tipc_net_stop();
>  }
>  
>  /**
> 
