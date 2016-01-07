From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: suspicious rcu_dereference in tcp_v6_send_synack
Date: Thu, 7 Jan 2016 08:20:30 -0800
Message-ID: <20160107162030.GO3818@linux.vnet.ibm.com>
References: <20160107153248.GA30472@codemonkey.org.uk>
 <1452181973.8255.213.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Jones <davej@codemonkey.org.uk>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:51317 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752739AbcAGQgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 11:36:14 -0500
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 7 Jan 2016 09:36:14 -0700
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 008A21FF0046
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2016 09:24:23 -0700 (MST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u07GaC5922282298
	for <netdev@vger.kernel.org>; Thu, 7 Jan 2016 09:36:12 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u07GaAoQ024519
	for <netdev@vger.kernel.org>; Thu, 7 Jan 2016 09:36:11 -0700
Content-Disposition: inline
In-Reply-To: <1452181973.8255.213.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 07, 2016 at 07:52:53AM -0800, Eric Dumazet wrote:
> On Thu, 2016-01-07 at 10:32 -0500, Dave Jones wrote:
> > ===============================
> > [ INFO: suspicious RCU usage. ]
> > 4.4.0-rc8-firewall+ #1 Not tainted
> > -------------------------------
> > net/ipv6/tcp_ipv6.c:465 suspicious rcu_dereference_check() usage!
> > 
> > other info that might help us debug this:
> > 
> > 
> > rcu_scheduler_active = 1, debug_locks = 1
> > 1 lock held by swapper/1/0:
> >  #0:  (((&req->rsk_timer))){+.-...}, at: [<ffffffff99113285>] call_timer_fn+0x5/0x3f0
> > 
> > stack backtrace:
> > CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.4.0-rc8-firewall+ #1
> >  0000000000000000 ffff8801d7a07b28 ffffffff9948b3b5 ffff8801d6046500
> >  ffff8801d7a07b58 ffffffff990e9b7a ffff8801cd356240 0000000000000000
> >  ffff8801d23b1698 ffff8801d23b0c40 ffff8801d7a07ba8 ffffffff99b635d2
> > Call Trace:
> >  <IRQ>  [<ffffffff9948b3b5>] dump_stack+0x4e/0x79
> >  [<ffffffff990e9b7a>] lockdep_rcu_suspicious+0xea/0x110
> >  [<ffffffff99b635d2>] tcp_v6_send_synack+0x2c2/0x350
> >  [<ffffffff99a8550d>] tcp_rtx_synack+0xdd/0x180
> >  [<ffffffff99a85430>] ? tcp_send_probe0+0x1a0/0x1a0
> >  [<ffffffff99a5f0a4>] reqsk_timer_handler+0x4c4/0x530
> >  [<ffffffff99a5ebe0>] ? inet_csk_reqsk_queue_drop+0x3a0/0x3a0
> >  [<ffffffff990e0f2b>] ? __lock_is_held+0x9b/0xd0
> >  [<ffffffff991133b2>] call_timer_fn+0x132/0x3f0
> >  [<ffffffff99113285>] ? call_timer_fn+0x5/0x3f0
> >  [<ffffffff99a5ebe0>] ? inet_csk_reqsk_queue_drop+0x3a0/0x3a0
> >  [<ffffffff99113280>] ? process_timeout+0x10/0x10
> >  [<ffffffff990e44d2>] ? trace_hardirqs_on_caller+0x192/0x2a0
> >  [<ffffffff990b52ea>] ? preempt_count_sub+0x1a/0x130
> >  [<ffffffff99113cab>] run_timer_softirq+0x47b/0x590
> >  [<ffffffff99a5ebe0>] ? inet_csk_reqsk_queue_drop+0x3a0/0x3a0
> >  [<ffffffff99113830>] ? internal_add_timer+0x110/0x110
> >  [<ffffffff990e0eb8>] ? __lock_is_held+0x28/0xd0
> >  [<ffffffff99076fd2>] __do_softirq+0x1b2/0x5c0
> >  [<ffffffff9907762c>] irq_exit+0xfc/0x110
> >  [<ffffffff99c12abf>] smp_apic_timer_interrupt+0x5f/0x70
> >  [<ffffffff99c112bb>] apic_timer_interrupt+0x8b/0x90
> >  <EOI>  [<ffffffff998dd547>] ? cpuidle_enter_state+0x1c7/0x460
> >  [<ffffffff998dd542>] ? cpuidle_enter_state+0x1c2/0x460
> >  [<ffffffff99107289>] ? rcu_eqs_enter_common+0x139/0x280
> >  [<ffffffff998dd847>] cpuidle_enter+0x17/0x20
> >  [<ffffffff990dbd92>] cpu_startup_entry+0x4d2/0x5b0
> >  [<ffffffff990db8c0>] ? default_idle_call+0x60/0x60
> >  [<ffffffff9912d714>] ? clockevents_config_and_register+0x64/0x70
> >  [<ffffffff9904d785>] ? setup_APIC_timer+0x115/0x120
> >  [<ffffffff9904be1a>] start_secondary+0x23a/0x2a0
> >  [<ffffffff9904bbe0>] ? set_cpu_sibling_map+0x9c0/0x9c0
> > 
> 
> Apparently RCU lockdep thinks a softirq handler (timer soft irq) needs
> rcu_read_lock() before rcu_dereference()
> 
> This is not clear if this is a lockdep false positive.
> 
> Paul, can you remind me why it is needed, as a softirq handler is not
> allowed to schedule or be preempted ?

Hello, Eric!

If this were rcu_dereference_bh(), then you would be OK as is, given that
you are in a softirq handler.  But for rcu_dereference(), lockdep does
indeed insist on an rcu_read_lock().  Yes, you would in fact be OK with
the current implementation (I think, anyway), even with preemptible RCU,
but that is an accident of implementation.

Is the required rcu_read_lock() and rcu_read_unlock() resulting in a
performance problem?

							Thanx, Paul

> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 6b8a8a9091fa..bd100b47c717 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -462,8 +462,10 @@ static int tcp_v6_send_synack(const struct sock *sk, struct dst_entry *dst,
>  		if (np->repflow && ireq->pktopts)
>  			fl6->flowlabel = ip6_flowlabel(ipv6_hdr(ireq->pktopts));
> 
> +		rcu_read_lock();
>  		err = ip6_xmit(sk, skb, fl6, rcu_dereference(np->opt),
>  			       np->tclass);
> +		rcu_read_unlock();
>  		err = net_xmit_eval(err);
>  	}
> 
> 
> 
