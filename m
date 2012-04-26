From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] drop_monitor: fix sleeping in invalid context
 warning
Date: Thu, 26 Apr 2012 21:01:29 +0200
Message-ID: <1335466889.2775.60.camel@edumazet-glaptop>
References: <1335466022-32661-1-git-send-email-nhorman@tuxdriver.com>
	 <1335466022-32661-2-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:37573 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716Ab2DZTBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 15:01:37 -0400
Received: by eaaq12 with SMTP id q12so434689eaa.19
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2012 12:01:36 -0700 (PDT)
In-Reply-To: <1335466022-32661-2-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-26 at 14:47 -0400, Neil Horman wrote:
> Eric Dumazet pointed out this warning in the drop_monitor protocol to me:
> 
> [   38.352571] BUG: sleeping function called from invalid context at kernel/mutex.c:85
> [   38.352576] in_atomic(): 1, irqs_disabled(): 0, pid: 4415, name: dropwatch
> [   38.352580] Pid: 4415, comm: dropwatch Not tainted 3.4.0-rc2+ #71
> [   38.352582] Call Trace:
> [   38.352592]  [<ffffffff8153aaf0>] ? trace_napi_poll_hit+0xd0/0xd0
> [   38.352599]  [<ffffffff81063f2a>] __might_sleep+0xca/0xf0
> [   38.352606]  [<ffffffff81655b16>] mutex_lock+0x26/0x50
> [   38.352610]  [<ffffffff8153aaf0>] ? trace_napi_poll_hit+0xd0/0xd0
> [   38.352616]  [<ffffffff810b72d9>] tracepoint_probe_register+0x29/0x90
> [   38.352621]  [<ffffffff8153a585>] set_all_monitor_traces+0x105/0x170
> [   38.352625]  [<ffffffff8153a8ca>] net_dm_cmd_trace+0x2a/0x40
> [   38.352630]  [<ffffffff8154a81a>] genl_rcv_msg+0x21a/0x2b0
> [   38.352636]  [<ffffffff810f8029>] ? zone_statistics+0x99/0xc0
> [   38.352640]  [<ffffffff8154a600>] ? genl_rcv+0x30/0x30
> [   38.352645]  [<ffffffff8154a059>] netlink_rcv_skb+0xa9/0xd0
> [   38.352649]  [<ffffffff8154a5f0>] genl_rcv+0x20/0x30
> [   38.352653]  [<ffffffff81549a7e>] netlink_unicast+0x1ae/0x1f0
> [   38.352658]  [<ffffffff81549d76>] netlink_sendmsg+0x2b6/0x310
> [   38.352663]  [<ffffffff8150824f>] sock_sendmsg+0x10f/0x130
> [   38.352668]  [<ffffffff8150abe0>] ? move_addr_to_kernel+0x60/0xb0
> [   38.352673]  [<ffffffff81515f04>] ? verify_iovec+0x64/0xe0
> [   38.352677]  [<ffffffff81509c46>] __sys_sendmsg+0x386/0x390
> [   38.352682]  [<ffffffff810ffaf9>] ? handle_mm_fault+0x139/0x210
> [   38.352687]  [<ffffffff8165b5bc>] ? do_page_fault+0x1ec/0x4f0
> [   38.352693]  [<ffffffff8106ba4d>] ? set_next_entity+0x9d/0xb0
> [   38.352699]  [<ffffffff81310b49>] ? tty_ldisc_deref+0x9/0x10
> [   38.352703]  [<ffffffff8106d363>] ? pick_next_task_fair+0x63/0x140
> [   38.352708]  [<ffffffff8150b8d4>] sys_sendmsg+0x44/0x80
> [   38.352713]  [<ffffffff8165f8e2>] system_call_fastpath+0x16/0x1b
> 
> It stems from holding a spinlock (trace_state_lock) while attempting to register
> or unregister tracepoint hooks, making in_atomic() true in this context, leading
> to the warning when the tracepoint calls might_sleep() while its taking a mutex.
> Since we only use the trace_state_lock to prevent trace protocol state races, as
> well as hardware stat list updates on an rcu write side, we can just convert the
> spinlock to a mutex to avoid this problem.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: David Miller <davem@davemloft.net>
> ---
>  net/core/drop_monitor.c |   14 +++++++-------
>  1 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
> index 5c3c81a..04ce1dd 100644
> --- a/net/core/drop_monitor.c
> +++ b/net/core/drop_monitor.c
> @@ -42,7 +42,7 @@ static void send_dm_alert(struct work_struct *unused);
>   * netlink alerts
>   */
>  static int trace_state = TRACE_OFF;
> -static DEFINE_SPINLOCK(trace_state_lock);
> +static DEFINE_MUTEX(trace_state_lock);

Maybe rename it to trace_state_mutex ?
