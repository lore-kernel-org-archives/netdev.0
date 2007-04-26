From: akpm@linux-foundation.org
Subject: [patch 10/15] ppp_generic: fix lockdep warning
Date: Thu, 26 Apr 2007 00:27:29 -0700
Message-ID: <200704260727.l3Q7RTxG023970@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, jarkao2@o2.pl,
	jura@netams.com, paulus@samba.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:59336 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933629AbXDZIAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 04:00:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@o2.pl>

> =======================================================
> [ INFO: possible circular locking dependency detected ]
> 2.6.21-rc4 #1
> -------------------------------------------------------
> pppd/8926 is trying to acquire lock:
> (&vlan_netdev_xmit_lock_key){-...}, at: [<c0265486>]
> dev_queue_xmit+0x247/0x2f1
>
> but task is already holding lock:
> (&pch->downl){-+..}, at: [<c0230c72>] ppp_channel_push+0x19/0x9a
>
> which lock already depends on the new lock.
>
>
> the existing dependency chain (in reverse order) is:
>
> -> #3 (&pch->downl){-+..}:
>       [<c013642b>] __lock_acquire+0xe62/0x1010
>       [<c0136642>] lock_acquire+0x69/0x83
>       [<c02afc13>] _spin_lock_bh+0x30/0x3d
>       [<c022f715>] ppp_push+0x5a/0x9a
>       [<c022fb40>] ppp_xmit_process+0x2e/0x511
>       [<c0231a05>] ppp_write+0xb8/0xf2
>       [<c015ec26>] vfs_write+0x7f/0xba
>       [<c015f158>] sys_write+0x3d/0x64
>       [<c01027de>] sysenter_past_esp+0x5f/0x99
>       [<ffffffff>] 0xffffffff
>
> -> #2 (&ppp->wlock){-+..}:
>       [<c013642b>] __lock_acquire+0xe62/0x1010
>       [<c0136642>] lock_acquire+0x69/0x83
>       [<c02afc13>] _spin_lock_bh+0x30/0x3d
>       [<c022fb2b>] ppp_xmit_process+0x19/0x511
>       [<c02318d3>] ppp_start_xmit+0x18a/0x204
>       [<c0263a6f>] dev_hard_start_xmit+0x1f6/0x2c4
>       [<c026ded3>] __qdisc_run+0x81/0x1bc
>       [<c026549e>] dev_queue_xmit+0x25f/0x2f1
>       [<c027c75f>] ip_output+0x1be/0x25f
>       [<c02788ce>] ip_forward+0x159/0x22b
>       [<c027745c>] ip_rcv+0x297/0x4dd
>       [<c0263698>] netif_receive_skb+0x164/0x1f2
>       [<c022199d>] e1000_clean_rx_irq+0x12a/0x4b7
>       [<c02209bc>] e1000_clean+0x3ff/0x5dd
>       [<c0265084>] net_rx_action+0x7d/0x12b
>       [<c011e442>] __do_softirq+0x82/0xf2
>       [<c011e509>] do_softirq+0x57/0x59
>       [<c011e877>] irq_exit+0x7f/0x81
>       [<c0105011>] do_IRQ+0x45/0x84
>       [<c0103252>] common_interrupt+0x2e/0x34
>       [<c0100b66>] mwait_idle+0x12/0x14
>       [<c0100c60>] cpu_idle+0x6c/0x86
>       [<c01001cd>] rest_init+0x23/0x36
>       [<c0377d89>] start_kernel+0x3ca/0x461
>       [<00000000>] 0x0
>       [<ffffffff>] 0xffffffff
>
> -> #1 (&dev->_xmit_lock){-+..}:
>       [<c013642b>] __lock_acquire+0xe62/0x1010
>       [<c0136642>] lock_acquire+0x69/0x83
>       [<c02afc13>] _spin_lock_bh+0x30/0x3d
>       [<c0266861>] dev_mc_add+0x34/0x16a
>       [<c02ab5c7>] vlan_dev_set_multicast_list+0x88/0x25c
>       [<c0266592>] __dev_mc_upload+0x22/0x24
>       [<c0266914>] dev_mc_add+0xe7/0x16a
>       [<c029f323>] igmp_group_added+0xe6/0xeb
>       [<c029f50b>] ip_mc_inc_group+0x13f/0x210
>       [<c029f5fa>] ip_mc_up+0x1e/0x61
>       [<c029ab81>] inetdev_event+0x154/0x2c7
>       [<c0125a46>] notifier_call_chain+0x2c/0x39
>       [<c0125a7c>] raw_notifier_call_chain+0x8/0xa
>       [<c026477a>] dev_open+0x6d/0x71
>       [<c0263028>] dev_change_flags+0x51/0x101
>       [<c029b7ca>] devinet_ioctl+0x4df/0x644
>       [<c029bc03>] inet_ioctl+0x5c/0x6f
>       [<c02596e0>] sock_ioctl+0x4f/0x1e8
>       [<c0168c32>] do_ioctl+0x22/0x71
>       [<c0168cd6>] vfs_ioctl+0x55/0x27e
>       [<c0168f32>] sys_ioctl+0x33/0x51
>       [<c01027de>] sysenter_past_esp+0x5f/0x99
>       [<ffffffff>] 0xffffffff
>
> -> #0 (&vlan_netdev_xmit_lock_key){-...}:
>       [<c0136289>] __lock_acquire+0xcc0/0x1010
>       [<c0136642>] lock_acquire+0x69/0x83
>       [<c02afbd6>] _spin_lock+0x2b/0x38
>       [<c0265486>] dev_queue_xmit+0x247/0x2f1
>       [<c02334f6>] __pppoe_xmit+0x1a9/0x215
>       [<c023356c>] pppoe_xmit+0xa/0xc
>       [<c0230c9a>] ppp_channel_push+0x41/0x9a
>       [<c0231a13>] ppp_write+0xc6/0xf2
>       [<c015ec26>] vfs_write+0x7f/0xba
>       [<c015f158>] sys_write+0x3d/0x64
>       [<c01027de>] sysenter_past_esp+0x5f/0x99
>       [<ffffffff>] 0xffffffff
>
> other info that might help us debug this:
>
> 1 lock held by pppd/8926:
> #0:  (&pch->downl){-+..}, at: [<c0230c72>] ppp_channel_push+0x19/0x9a
>
> stack backtrace:
> [<c0103834>] show_trace_log_lvl+0x1a/0x30
> [<c0103f16>] show_trace+0x12/0x14
> [<c0103f9d>] dump_stack+0x16/0x18
> [<c01343cd>] print_circular_bug_tail+0x68/0x71
> [<c0136289>] __lock_acquire+0xcc0/0x1010
> [<c0136642>] lock_acquire+0x69/0x83
> [<c02afbd6>] _spin_lock+0x2b/0x38
> [<c0265486>] dev_queue_xmit+0x247/0x2f1
> [<c02334f6>] __pppoe_xmit+0x1a9/0x215
> [<c023356c>] pppoe_xmit+0xa/0xc
> [<c0230c9a>] ppp_channel_push+0x41/0x9a
> [<c0231a13>] ppp_write+0xc6/0xf2
> [<c015ec26>] vfs_write+0x7f/0xba
> [<c015f158>] sys_write+0x3d/0x64
> [<c01027de>] sysenter_past_esp+0x5f/0x99
> =======================
> Clocksource tsc unstable (delta = 4686844667 ns)
> Time: acpi_pm clocksource has been installed.
...

lockdep has seen locks "-> #0" - "-> #3" taken in circular order, but IMHO,
lock "-> #3" (&pch->downl) taken after "-> #2" (&ppp->wlock) differs from
&pch->downl lock taken in "-> #0" (before &vlan_netdev_xmit_lock_key) and
lockdep should be notified about this.

Reported & tested by: "Yuriy N. Shkandybin" <jura@netams.com>
Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
Cc: Paul Mackerras <paulus@samba.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ppp_generic.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff -puN drivers/net/ppp_generic.c~ppp_generic-fix-lockdep-warning drivers/net/ppp_generic.c
--- a/drivers/net/ppp_generic.c~ppp_generic-fix-lockdep-warning
+++ a/drivers/net/ppp_generic.c
@@ -1433,7 +1433,8 @@ ppp_channel_push(struct channel *pch)
 	struct sk_buff *skb;
 	struct ppp *ppp;
 
-	spin_lock_bh(&pch->downl);
+	local_bh_disable();
+	spin_lock_nested(&pch->downl, SINGLE_DEPTH_NESTING);
 	if (pch->chan != 0) {
 		while (!skb_queue_empty(&pch->file.xq)) {
 			skb = skb_dequeue(&pch->file.xq);
@@ -1447,7 +1448,8 @@ ppp_channel_push(struct channel *pch)
 		/* channel got deregistered */
 		skb_queue_purge(&pch->file.xq);
 	}
-	spin_unlock_bh(&pch->downl);
+	spin_unlock(&pch->downl);
+	local_bh_enable();
 	/* see if there is anything from the attached unit to be sent */
 	if (skb_queue_empty(&pch->file.xq)) {
 		read_lock_bh(&pch->upl);
_
