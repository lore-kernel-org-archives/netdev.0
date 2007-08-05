From: Luca Tettamanti <kronos.it-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [BUG] rt2x00: inconsistent lock state
Date: Sun, 5 Aug 2007 21:45:54 +0200
Message-ID: <20070805194554.GA17141@dreamland.darkstar.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: rt2400-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,
while testing wireless-dev (git current) and rt2x00 driver lockdep emitted the
following warning (shortly after wpa_supplicant upped the interface):

ACPI: PCI Interrupt 0000:02:00.0[A] -> Link [LNKB] -> GSI 5 (level, low) -> IRQ 5
wmaster0: Selected rate control algorithm 'simple'

=================================
[ INFO: inconsistent lock state ]
2.6.23-rc1-gd34764df #33
---------------------------------
inconsistent {hardirq-on-W} -> {in-hardirq-R} usage.
wpa_supplicant/4918 [HC1[1]:SC0[0]:HE0:SE1] takes:
 (dev_base_lock){-.?-}, at: [<c030d3c0>] dev_get_by_index+0x10/0x40
{hardirq-on-W} state was registered at:
  [<c013cdbf>] __lock_acquire+0x65f/0x1050
  [<c013d826>] lock_acquire+0x76/0xa0
  [<c036299a>] _write_lock_bh+0x3a/0x50
  [<c030bf7a>] register_netdevice+0x27a/0x400
  [<c030c13a>] register_netdev+0x3a/0x50
  [<c047e26d>] loopback_init+0xd/0x10
  [<c0462742>] kernel_init+0xa2/0x290
  [<c0104d43>] kernel_thread_helper+0x7/0x14
  [<ffffffff>] 0xffffffff
irq event stamp: 3178
hardirqs last  enabled at (3177): [<c0362f25>] _spin_unlock_irqrestore+0x55/0x70
hardirqs last disabled at (3178): [<c0104b94>] common_interrupt+0x24/0x34
softirqs last  enabled at (3174): [<c01232c8>] __do_softirq+0xa8/0xc0
softirqs last disabled at (3167): [<c0106bab>] do_softirq+0x9b/0xf0

other info that might help us debug this:
1 lock held by wpa_supplicant/4918:
 #0:  (rtnl_mutex){--..}, at: [<c03613dc>] mutex_lock+0x1c/0x20

stack backtrace:
 [<c010510a>] show_trace_log_lvl+0x1a/0x30
 [<c0105da2>] show_trace+0x12/0x20
 [<c0105dc5>] dump_stack+0x15/0x20
 [<c013b1d0>] print_usage_bug+0x150/0x160
 [<c013beb8>] mark_lock+0x4d8/0x620
 [<c013cf35>] __lock_acquire+0x7d5/0x1050
 [<c013d826>] lock_acquire+0x76/0xa0
 [<c0362a85>] _read_lock+0x35/0x50
 [<c030d3c0>] dev_get_by_index+0x10/0x40
 [<e0bf16ec>] ieee80211_beacon_get+0x1c/0x530 [mac80211]
 [<e0af5404>] rt2x00lib_beacondone+0x44/0x70 [rt2x00lib]
 [<e0b43894>] rt2500pci_interrupt+0xa4/0xd0 [rt2500pci]
 [<c014a398>] handle_IRQ_event+0x28/0x60
 [<c014bc7d>] handle_level_irq+0x6d/0xf0
 [<c0106c9a>] do_IRQ+0x9a/0x100
 [<c0104b9e>] common_interrupt+0x2e/0x34
 [<e0bf42a2>] ieee80211_open+0x322/0x3d0 [mac80211]
 [<c030ca77>] dev_open+0x37/0x80
 [<c030a95d>] dev_change_flags+0x7d/0x180
 [<c0347124>] devinet_ioctl+0x4b4/0x650
 [<c034766b>] inet_ioctl+0x6b/0x90
 [<c02ff965>] sock_ioctl+0xb5/0x1f0
 [<c0178c38>] do_ioctl+0x28/0x80
 [<c0178ce7>] vfs_ioctl+0x57/0x2b0
 [<c0178f79>] sys_ioctl+0x39/0x60
 [<c01041a6>] syscall_call+0x7/0xb
 =======================

If I'm reading the state bits and the message correcly dev_base_lock was
aquired for write with IRQ enabled (via register_netdevice), but lockep also
saw it aquired for read *in* IRQ (hardirq) context (rt2x00 code path, via
rt2x00lib_beacondone -> ieee80211_beacon_get); this means that a deadlock can
occur if we take an interrupt while the lock is already held.
So either the lock must be IRQ-safe (_irq() / _irq_save()) or rt2x00 must not
take it in interrupt context.

Luca
-- 
Software is like sex; it's better when it's free.
Linus Torvalds
