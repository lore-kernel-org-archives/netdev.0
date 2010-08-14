From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Sat, 14 Aug 2010 11:05:54 -0700
Message-ID: <AANLkTinGy+-ELbVx_2WJ1wOJCsz4Rez26Q2Baisws9+C@mail.gmail.com>
References: <20100812.161050.246523792.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100812.161050.246523792.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,
 I completely screwed up locking in my VM guard page patch, so when I
verified my fix for that I tried to enable all the lock debug crud I
possibly could.

And as a result, I got a locking error report, but it had nothing to
do with the VM guard page any more (so hopefully I finally fixed my
mindless code-drivel correctly. I'm a bit ashamed of myself).

Anyway, the lock warning I do get seems to be networking-related, and
is appended. Does this ring any bells? It could easily be something
old: I turn on lock debugging only when I look for bugs (or when
people point out bugs that I've created :^/ )

The only thing that seems to be related that google can find is pretty
recent too: a report from Valdis Kletnieks about this apparently
happening on e1000e too (Subject "mmotm 2010-08-11 - lockdep whinges
at e1000e driver ifconfig up"). So it does seem to be pretty recent.

Hmm? Everything obviously still works, but judging by the lockdep
report this might be a deadlock situation (lock taken in softirq _and_
outside softirq without disabling bhs)

                                    Linus

---
  r8169 0000:01:00.0: eth0: link up
  r8169 0000:01:00.0: eth0: link up

  =================================
  [ INFO: inconsistent lock state ]
  2.6.35-07956-g92fa5bd9-dirty #7
  ---------------------------------
  inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
  dbus-daemon/2432 [HC0[0]:SC1[2]:HE1:SE0] takes:
   (&(&lock->lock)->rlock){+.?...}, at: [<ffffffff814e9fd8>]
ip6t_do_table+0x7f/0x3e7
  {SOFTIRQ-ON-W} state was registered at:
    [<ffffffff8105eb80>] __lock_acquire+0x756/0x1712
    [<ffffffff8105fbbf>] lock_acquire+0x83/0x9d
    [<ffffffff81505c77>] _raw_spin_lock+0x31/0x64
    [<ffffffff814e943d>] get_counters+0xa4/0x139
    [<ffffffff814e9509>] alloc_counters+0x37/0x42
    [<ffffffff814eab47>] do_ip6t_get_ctl+0x107/0x35e
    [<ffffffff81463241>] nf_sockopt+0x55/0x81
    [<ffffffff81463280>] nf_getsockopt+0x13/0x15
    [<ffffffff814d0cce>] ipv6_getsockopt+0x7f/0xb5
    [<ffffffff814d7e29>] rawv6_getsockopt+0x3d/0x46
    [<ffffffff81434fae>] sock_common_getsockopt+0xf/0x11
    [<ffffffff814323ff>] sys_getsockopt+0x75/0x96
    [<ffffffff81001eab>] system_call_fastpath+0x16/0x1b
  irq event stamp: 21072
  hardirqs last  enabled at (21072): [<ffffffff8103b5cf>]
local_bh_enable+0xbd/0xc2
  hardirqs last disabled at (21071): [<ffffffff8103b564>]
local_bh_enable+0x52/0xc2
  softirqs last  enabled at (20000): [<ffffffff814bd355>]
unix_create1+0x164/0x17c
  softirqs last disabled at (21037): [<ffffffff81002dcc>] call_softirq+0x1c/0x28

  other info that might help us debug this:
  3 locks held by dbus-daemon/2432:
   #0:  (&idev->mc_ifc_timer){+.-...}, at: [<ffffffff810404f6>]
run_timer_softirq+0x14e/0x28c
   #1:  (rcu_read_lock){.+.+..}, at: [<ffffffff814dc9b2>] mld_sendpack+0x0/0x3bd
   #2:  (rcu_read_lock){.+.+..}, at: [<ffffffff81461ed5>] nf_hook_slow+0x0/0x10a

  stack backtrace:
  Pid: 2432, comm: dbus-daemon Not tainted 2.6.35-07956-g92fa5bd9-dirty #7
  Call Trace:
   <IRQ>  [<ffffffff8105bf16>] print_usage_bug+0x1a4/0x1b5
   [<ffffffff8100c7d3>] ? save_stack_trace+0x2a/0x47
   [<ffffffff8105cb6c>] ? check_usage_forwards+0x0/0xc6
   [<ffffffff8105c211>] mark_lock+0x2ea/0x552
   [<ffffffff8105eb07>] __lock_acquire+0x6dd/0x1712
   [<ffffffff8105246e>] ? local_clock+0x2b/0x3c
   [<ffffffff8105b2e8>] ? lock_release_holdtime+0x1c/0x123
   [<ffffffff8105fbbf>] lock_acquire+0x83/0x9d
   [<ffffffff814e9fd8>] ? ip6t_do_table+0x7f/0x3e7
   [<ffffffff81505c77>] _raw_spin_lock+0x31/0x64
   [<ffffffff814e9fd8>] ? ip6t_do_table+0x7f/0x3e7
   [<ffffffff814e9fd8>] ip6t_do_table+0x7f/0x3e7
   [<ffffffff814ebd87>] ip6table_filter_hook+0x17/0x1c
   [<ffffffff81461e92>] nf_iterate+0x41/0x84
   [<ffffffff814db3ba>] ? dst_output+0x0/0x58
   [<ffffffff81461f63>] nf_hook_slow+0x8e/0x10a
   [<ffffffff814db3ba>] ? dst_output+0x0/0x58
   [<ffffffff814dcc00>] mld_sendpack+0x24e/0x3bd
   [<ffffffff8105c4cb>] ? mark_held_locks+0x52/0x70
   [<ffffffff814dd478>] mld_ifc_timer_expire+0x24f/0x288
   [<ffffffff814dd229>] ? mld_ifc_timer_expire+0x0/0x288
   [<ffffffff81040584>] run_timer_softirq+0x1dc/0x28c
   [<ffffffff810404f6>] ? run_timer_softirq+0x14e/0x28c
   [<ffffffff8103b6dc>] ? __do_softirq+0x69/0x13d
   [<ffffffff8103b715>] __do_softirq+0xa2/0x13d
   [<ffffffff810590eb>] ? tick_program_event+0x25/0x27
   [<ffffffff81002dcc>] call_softirq+0x1c/0x28
   [<ffffffff81004834>] do_softirq+0x38/0x80
   [<ffffffff8103b2e0>] irq_exit+0x45/0x87
   [<ffffffff8101a278>] smp_apic_timer_interrupt+0x88/0x96
   [<ffffffff81002893>] apic_timer_interrupt+0x13/0x20
   <EOI>
  r8169: WARNING! Changing of MTU on this NIC may lead to frame
reception errors!
