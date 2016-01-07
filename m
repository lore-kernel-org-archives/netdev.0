From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: suspicious rcu_dereference in tcp_v6_send_synack
Date: Thu, 07 Jan 2016 07:52:53 -0800
Message-ID: <1452181973.8255.213.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160107153248.GA30472@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@codemonkey.org.uk>,
	Paul McKenney <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33008 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753064AbcAGPw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 10:52:56 -0500
Received: by mail-pa0-f51.google.com with SMTP id cy9so261659315pac.0
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 07:52:55 -0800 (PST)
In-Reply-To: <20160107153248.GA30472@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-01-07 at 10:32 -0500, Dave Jones wrote:
> ===============================
> [ INFO: suspicious RCU usage. ]
> 4.4.0-rc8-firewall+ #1 Not tainted
> -------------------------------
> net/ipv6/tcp_ipv6.c:465 suspicious rcu_dereference_check() usage!
> 
> other info that might help us debug this:
> 
> 
> rcu_scheduler_active = 1, debug_locks = 1
> 1 lock held by swapper/1/0:
>  #0:  (((&req->rsk_timer))){+.-...}, at: [<ffffffff99113285>] call_timer_fn+0x5/0x3f0
> 
> stack backtrace:
> CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.4.0-rc8-firewall+ #1
>  0000000000000000 ffff8801d7a07b28 ffffffff9948b3b5 ffff8801d6046500
>  ffff8801d7a07b58 ffffffff990e9b7a ffff8801cd356240 0000000000000000
>  ffff8801d23b1698 ffff8801d23b0c40 ffff8801d7a07ba8 ffffffff99b635d2
> Call Trace:
>  <IRQ>  [<ffffffff9948b3b5>] dump_stack+0x4e/0x79
>  [<ffffffff990e9b7a>] lockdep_rcu_suspicious+0xea/0x110
>  [<ffffffff99b635d2>] tcp_v6_send_synack+0x2c2/0x350
>  [<ffffffff99a8550d>] tcp_rtx_synack+0xdd/0x180
>  [<ffffffff99a85430>] ? tcp_send_probe0+0x1a0/0x1a0
>  [<ffffffff99a5f0a4>] reqsk_timer_handler+0x4c4/0x530
>  [<ffffffff99a5ebe0>] ? inet_csk_reqsk_queue_drop+0x3a0/0x3a0
>  [<ffffffff990e0f2b>] ? __lock_is_held+0x9b/0xd0
>  [<ffffffff991133b2>] call_timer_fn+0x132/0x3f0
>  [<ffffffff99113285>] ? call_timer_fn+0x5/0x3f0
>  [<ffffffff99a5ebe0>] ? inet_csk_reqsk_queue_drop+0x3a0/0x3a0
>  [<ffffffff99113280>] ? process_timeout+0x10/0x10
>  [<ffffffff990e44d2>] ? trace_hardirqs_on_caller+0x192/0x2a0
>  [<ffffffff990b52ea>] ? preempt_count_sub+0x1a/0x130
>  [<ffffffff99113cab>] run_timer_softirq+0x47b/0x590
>  [<ffffffff99a5ebe0>] ? inet_csk_reqsk_queue_drop+0x3a0/0x3a0
>  [<ffffffff99113830>] ? internal_add_timer+0x110/0x110
>  [<ffffffff990e0eb8>] ? __lock_is_held+0x28/0xd0
>  [<ffffffff99076fd2>] __do_softirq+0x1b2/0x5c0
>  [<ffffffff9907762c>] irq_exit+0xfc/0x110
>  [<ffffffff99c12abf>] smp_apic_timer_interrupt+0x5f/0x70
>  [<ffffffff99c112bb>] apic_timer_interrupt+0x8b/0x90
>  <EOI>  [<ffffffff998dd547>] ? cpuidle_enter_state+0x1c7/0x460
>  [<ffffffff998dd542>] ? cpuidle_enter_state+0x1c2/0x460
>  [<ffffffff99107289>] ? rcu_eqs_enter_common+0x139/0x280
>  [<ffffffff998dd847>] cpuidle_enter+0x17/0x20
>  [<ffffffff990dbd92>] cpu_startup_entry+0x4d2/0x5b0
>  [<ffffffff990db8c0>] ? default_idle_call+0x60/0x60
>  [<ffffffff9912d714>] ? clockevents_config_and_register+0x64/0x70
>  [<ffffffff9904d785>] ? setup_APIC_timer+0x115/0x120
>  [<ffffffff9904be1a>] start_secondary+0x23a/0x2a0
>  [<ffffffff9904bbe0>] ? set_cpu_sibling_map+0x9c0/0x9c0
> 

Apparently RCU lockdep thinks a softirq handler (timer soft irq) needs
rcu_read_lock() before rcu_dereference()

This is not clear if this is a lockdep false positive.

Paul, can you remind me why it is needed, as a softirq handler is not
allowed to schedule or be preempted ?


diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 6b8a8a9091fa..bd100b47c717 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -462,8 +462,10 @@ static int tcp_v6_send_synack(const struct sock *sk, struct dst_entry *dst,
 		if (np->repflow && ireq->pktopts)
 			fl6->flowlabel = ip6_flowlabel(ipv6_hdr(ireq->pktopts));
 
+		rcu_read_lock();
 		err = ip6_xmit(sk, skb, fl6, rcu_dereference(np->opt),
 			       np->tclass);
+		rcu_read_unlock();
 		err = net_xmit_eval(err);
 	}
 
