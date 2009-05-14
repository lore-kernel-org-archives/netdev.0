From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v2 3/7] [PATCH 3/8] can: CAN Network device driver and
 Netlink interface
Date: Thu, 14 May 2009 11:51:01 +0200
Message-ID: <4A0BE985.7090202@grandegger.com>
References: <20090512092757.048938233@denx.de>	<20090512092757.574693100@denx.de>	<20090512233052.ecd600f1.akpm@linux-foundation.org>	<20090512235323.e3de5e5d.akpm@linux-foundation.org>	<4A0AB0EC.5010902@grandegger.com> <20090513085734.387dddbe.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:35568 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759304AbZENJvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2009 05:51:03 -0400
In-Reply-To: <20090513085734.387dddbe.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Wed, 13 May 2009 13:37:16 +0200 Wolfgang Grandegger <wg@grandegger.com> wrote:
> 
>>> Also, I wonder if it's safe to take netif_tx_lock() from a timer
>>> handler when other parts of the code might be taking it from process
>>> context (I didn't check).
>>>
>>> lockdep should be able to detect this, and I trust this code has been
>>> fully runtime tested with lockdep enabled?
>> Well, CONFIG_PROVE_LOCKING would be cool, but I'm unable to enabled it
>> for my MPC5200 test system. Only 64bit PowerPC's seem to support
>> TRACE_IRQFLAGS_SUPPORT. I'm going to test the code on a PC as well.
> 
> I discussed this off-list with Peter Zijlstra and Johannes Berg. 
> Apparently lockdep _will_ detect this deadlockable situation - Johannes
> recently added the capability because he had the same situation in
> wireless code somewhere.

Below is the kernel message I get with CONFIG_PROVE_LOCKING enabled when
I call can_restart_now() from the user context via netlink interface. I
have some difficulties interpreting the message, but it seems to confirm
your fears.

> But of course it does require that the timer handler has executed at
> least once.  Many handlers in the kernel never fire in normal operation.

I do not see problems if can_restart_now() is called via timer callback
(after replacing del_timer_sync with del_timer).

Wolfgang.



peak_pci 0000:01:08.0: setting BTR0=0x00 BTR1=0x14
can: controller area network core (rev 20090105 abi 8)
NET: Registered protocol family 29
can: request_module (can-proto-1) failed.
can: raw protocol (rev 20090105)
peak_pci 0000:01:08.0: error warning interrupt
peak_pci 0000:01:08.0: error passive interrupt
peak_pci 0000:01:08.0: error warning interrupt
peak_pci 0000:01:08.0: bus-off

=================================
[ INFO: inconsistent lock state ]
2.6.29.3 #1
---------------------------------
inconsistent {in-softirq-W} -> {softirq-on-W} usage.
ip/2847 [HC0[0]:SC0[0]:HE1:SE1] takes:
 (&dev->tx_global_lock){-+..}, at: [<f7e29806>] can_restart_now+0x26/0x1c1 [can_dev]
{in-softirq-W} state was registered at:
  [<c044957d>] __lock_acquire+0x244/0xb01
  [<c0449e95>] lock_acquire+0x5b/0x81
  [<c067c29b>] _spin_lock+0x1b/0x2a
  [<c06031fd>] netif_tx_lock+0x18/0x6a
  [<c06032a2>] dev_watchdog+0xf/0x10d
  [<c04331bc>] run_timer_softirq+0x13b/0x19b
  [<c043000e>] __do_softirq+0x98/0x136
  [<ffffffff>] 0xffffffff
irq event stamp: 1973
hardirqs last  enabled at (1973): [<c067b100>] __mutex_lock_common+0x2be/0x313
hardirqs last disabled at (1972): [<c067aeb4>] __mutex_lock_common+0x72/0x313
softirqs last  enabled at (1790): [<c05fe73b>] sk_filter+0x9a/0xa7
softirqs last disabled at (1788): [<c05fe6bf>] sk_filter+0x1e/0xa7

other info that might help us debug this:
1 lock held by ip/2847:
 #0:  (rtnl_mutex){--..}, at: [<c05fcef7>] rtnetlink_rcv+0x12/0x26

stack backtrace:
Pid: 2847, comm: ip Not tainted 2.6.29.3 #1
Call Trace:
 [<c0679d30>] ? printk+0xf/0x17
 [<c044860c>] valid_state+0x12a/0x13d
 [<c04489dc>] mark_lock+0x248/0x349
 [<c04495fe>] __lock_acquire+0x2c5/0xb01
 [<c04858e4>] ? handle_mm_fault+0x6a4/0x6b7
 [<c0449e95>] lock_acquire+0x5b/0x81
 [<f7e29806>] ? can_restart_now+0x26/0x1c1 [can_dev]
 [<c067c29b>] _spin_lock+0x1b/0x2a
 [<f7e29806>] ? can_restart_now+0x26/0x1c1 [can_dev]
 [<f7e29806>] can_restart_now+0x26/0x1c1 [can_dev]
 [<f7e29ab8>] can_changelink+0x117/0x12f [can_dev]
 [<c060a7aa>] ? nla_parse+0x57/0xb2
 [<f7e299a1>] ? can_changelink+0x0/0x12f [can_dev]
 [<c05fd306>] rtnl_newlink+0x249/0x3df
 [<c05fd1fe>] ? rtnl_newlink+0x141/0x3df
 [<c05fd0bd>] ? rtnl_newlink+0x0/0x3df
 [<c05fd0a3>] rtnetlink_rcv_msg+0x198/0x1b2
 [<c05fcf0b>] ? rtnetlink_rcv_msg+0x0/0x1b2
 [<c060a2a0>] netlink_rcv_skb+0x30/0x78
 [<c05fcf03>] rtnetlink_rcv+0x1e/0x26
 [<c0609e8a>] netlink_unicast+0xf6/0x156
 [<c060a130>] netlink_sendmsg+0x246/0x253
 [<c05e8b28>] __sock_sendmsg+0x45/0x4e
 [<c05e9303>] sock_sendmsg+0xb8/0xce
 [<c043c15f>] ? autoremove_wake_function+0x0/0x33
 [<c048348d>] ? might_fault+0x43/0x80
 [<c048348d>] ? might_fault+0x43/0x80
 [<c051aa39>] ? copy_from_user+0x2a/0x111
 [<c05eff69>] ? verify_iovec+0x40/0x6f
 [<c05e9458>] sys_sendmsg+0x13f/0x192
 [<c067e281>] ? do_page_fault+0x380/0x690
 [<c0447a3f>] ? register_lock_class+0x17/0x290
 [<c04487b2>] ? mark_lock+0x1e/0x349
 [<c04487b2>] ? mark_lock+0x1e/0x349
 [<c048348d>] ? might_fault+0x43/0x80
 [<c05ea3f4>] sys_socketcall+0x153/0x183
 [<c04038eb>] sysenter_do_call+0x12/0x3f
