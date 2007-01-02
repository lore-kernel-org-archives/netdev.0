From: Ben Greear <greearb@candelatech.com>
Subject: Re: BUG: soft lockup detected on CPU#0!  (2.6.18.2 plus hacks)
Date: Mon, 01 Jan 2007 21:00:05 -0800
Message-ID: <4599E6D5.6050207@candelatech.com>
References: <45889C53.8000307@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jarkao2@o2.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:59262 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755262AbXABE6U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jan 2007 23:58:20 -0500
To: NetDev <netdev@vger.kernel.org>
In-Reply-To: <45889C53.8000307@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I finally had time to look through the code in this backtrace in 
detail.  I think it *could*
be a race between ip_rcv and inetdev_init, but I am not certain.  Other 
than that, I'm real
low on ideas.  I found a few more stack trace debugging options to 
enable..perhaps that
will give a better backtrace if we can reproduce it again.

I do have lock-debugging enabled, so it should have caught this if was 
an un-initialized access
problem, however.

More details below inline.

Ben Greear wrote:
> This is from 2.6.18.2 kernel with my patch set.  The MAC-VLANs are in 
> active use.
> From the backtrace, I am thinking this might be a generic problem, 
> however.
>
> Any ideas about what this could be?  It seems to be reproducible every 
> day or
> two, but no known way to make it happen quickly...
>
> Kernel is SMP, PREEMPT.
>
>
> Dec 19 04:49:33 localhost kernel: BUG: soft lockup detected on CPU#0!
> Dec 19 04:49:33 localhost kernel:  [<78104252>] show_trace+0x12/0x20
> Dec 19 04:49:33 localhost kernel:  [<78104929>] dump_stack+0x19/0x20
> Dec 19 04:49:33 localhost kernel:  [<7814c88b>] softlockup_tick+0x9b/0xd0
> Dec 19 04:49:33 localhost kernel:  [<7812a992>] 
> run_local_timers+0x12/0x20
> Dec 19 04:49:33 localhost kernel:  [<7812ac08>] 
> update_process_times+0x38/0x80
> Dec 19 04:49:33 localhost kernel:  [<78112796>] 
> smp_apic_timer_interrupt+0x66/0x70
> Dec 19 04:49:33 localhost kernel:  [<78103baa>] 
> apic_timer_interrupt+0x2a/0x30
> Dec 19 04:49:33 localhost kernel:  [<78354e8c>] _read_lock+0x3c/0x50
 > Dec 19 04:49:33 localhost kernel:  [<78331f42>] ip_check_mc+0x22/0xb0
This is blocked on:
igmp.c:    read_lock(&in_dev->mc_list_lock);

> Dec 19 04:49:33 localhost kernel:  [<783068bf>] 
> ip_route_input+0x17f/0xef0
route.c:            int our = ip_check_mc(in_dev, daddr, saddr, 
skb->nh.iph->protocol);
> Dec 19 04:49:33 localhost kernel:  [<78309c59>] ip_rcv+0x349/0x580
?? Called by a macro maybe?  Can't find an obvious call to the 
ip_route_input.
> Dec 19 04:49:33 localhost kernel:  [<782ec98d>] 
> netif_receive_skb+0x36d/0x3b0
> Dec 19 04:49:33 localhost kernel:  [<782ee50c>] 
> process_backlog+0x9c/0x130
> Dec 19 04:49:33 localhost kernel:  [<782ee795>] net_rx_action+0xc5/0x1f0
> Dec 19 04:49:33 localhost kernel:  [<78125e58>] __do_softirq+0x88/0x110
> Dec 19 04:49:33 localhost kernel:  [<78125f59>] do_softirq+0x79/0x80
> Dec 19 04:49:33 localhost kernel:  [<781260ed>] irq_exit+0x5d/0x60
> Dec 19 04:49:33 localhost kernel:  [<78105a6d>] do_IRQ+0x4d/0xa0
> Dec 19 04:49:33 localhost kernel:  [<78103ae9>] 
> common_interrupt+0x25/0x2c
> Dec 19 04:49:33 localhost kernel:  [<78354c45>] _spin_lock+0x35/0x50
> Dec 19 04:49:33 localhost kernel:  [<781aab1d>] proc_register+0x2d/0x110
> Dec 19 04:49:33 localhost kernel:  [<781ab23d>] 
> create_proc_entry+0x5d/0xd0
> Dec 19 04:49:33 localhost kernel:  [<7812873b>] 
> register_proc_table+0x6b/0x110
> Dec 19 04:49:33 localhost kernel:  [<78128771>] 
> register_proc_table+0xa1/0x110
> Dec 19 04:49:33 localhost last message repeated 3 times
> Dec 19 04:49:33 localhost kernel:  [<7812886d>] 
> register_sysctl_table+0x8d/0xc0
> Dec 19 04:49:33 localhost kernel:  [<7832f0c9>] 
> devinet_sysctl_register+0x109/0x150

This devinet_sysctl_register is called right before the ip_mc_init_dev 
call is made, and
that call is used to initialize the multicast lock that is blocked on at 
the top of this backtrace.
This *could* be the race, but only if the entities in question are the 
same thing.  I don't see
any way to determine whether they are or not based on the backtrace.

I looked through all of the uses of the mc_list_lock, and the places 
where it does a write_lock
are few and appear to be correct with no possibility of deadlocking.  If 
a lock was un-initialized, then
that could perhaps explain why it is able to deadlock (though, that 
should have triggered a different
bug report since I have spin/rw-lock debugging enabled.)

> Dec 19 04:49:33 localhost kernel:  [<7832f2ea>] inetdev_init+0xea/0x160
> Dec 19 04:49:33 localhost kernel:  [<7832fa2e>] 
> inet_rtm_newaddr+0x16e/0x190
> Dec 19 04:49:33 localhost kernel:  [<782f58a9>] 
> rtnetlink_rcv_msg+0x169/0x230
> Dec 19 04:49:33 localhost kernel:  [<78300ed0>] 
> netlink_run_queue+0x90/0x140
> Dec 19 04:49:33 localhost kernel:  [<782f56dc>] rtnetlink_rcv+0x2c/0x50
> Dec 19 04:49:33 localhost kernel:  [<783014a5>] 
> netlink_data_ready+0x15/0x60
> Dec 19 04:49:33 localhost kernel:  [<78300167>] netlink_sendskb+0x27/0x50
> Dec 19 04:49:33 localhost kernel:  [<78300bab>] 
> netlink_unicast+0x15b/0x1f0
> Dec 19 04:49:33 localhost kernel:  [<783013ab>] 
> netlink_sendmsg+0x20b/0x2f0
> Dec 19 04:49:33 localhost kernel:  [<782e12bc>] sock_sendmsg+0xfc/0x120
> Dec 19 04:49:33 localhost kernel:  [<782e1a5a>] sys_sendmsg+0x10a/0x220
> Dec 19 04:49:33 localhost kernel:  [<782e3311>] 
> sys_socketcall+0x261/0x290
> Dec 19 04:49:33 localhost kernel:  [<7810307d>] 
> sysenter_past_esp+0x56/0x8d
> Dec 19 04:52:17 localhost sshd[32311]: gethostby*.getanswer: asked for 
> "203.60.60.10.in-addr.arpa IN PTR", got type "A"
>


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


