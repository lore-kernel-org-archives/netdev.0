From: Terry Loftin <terry.loftin@hp.com>
Subject: [PATCH 0/1][RFC] e1000e:  stop cleaning when we reach tx_ring->next_to_use
Date: Wed, 31 Mar 2010 14:01:28 -0600
Message-ID: <4BB3AA18.3050301@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:19012 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757566Ab0CaUBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 16:01:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During long test runs with heavy network traffic, we have had
a number of crashes in e1000e with backtraces like this:

 BUG: unable to handle kernel NULL pointer dereference at 00000000000000cc
 IP: [<ffffffffa006951f>] e1000_clean_tx_irq+0x81/0x2db [e1000e]

 Pid: 0, comm: swapper Not tainted 2.6.32-4-amd64 #1 ProLiant DL380 G6
 RIP: 0010:[<ffffffffa006951f>]  [<ffffffffa006951f>] e1000_clean_tx_irq+0x81/0x2db [e1000e]
 RSP: 0018:ffff8800282039a0  EFLAGS: 00010246
 RAX: ffff8803259e0000 RBX: 0000000000000046 RCX: 0000000000000000
 RDX: ffff8803259e0000 RSI: 0000000000000000 RDI: ffffc90006b20af0
 RBP: ffff880028203a10 R08: 0000000000000000 R09: 0000000000003d5c
 R10: 0000000000000000 R11: 0000000000000010 R12: 0000000000000046
 R13: ffff8801a4bc45c0 R14: ffff8801a4b5cd40 R15: 0000000000000046
 FS:  0000000000000000(0000) GS:ffff880028200000(0000) knlGS:0000000000000000
 CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
 CR2: 00000000000000cc CR3: 0000000001001000 CR4: 00000000000006f0
 DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
 DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
 Process swapper (pid: 0, threadinfo ffffffff81420000, task ffffffff8145e4b0)
 Stack:
  0000000000000008 0000000000000001 ffff8802fa2d8200 ffff8801a6966880
 <0> ffff8800282039d0 ffff8801a4bc4000 0000000000000003 01ffffff00000000
 <0> ffff8803259e0000 ffff8801a4bc45c0 ffff8801a4b5cd40 ffff880326cbccc0
 Call Trace:
  <IRQ>
  [<ffffffffa00697aa>] e1000_intr_msix_tx+0x31/0x53 [e1000e] (eth9 tx)
  [<ffffffff810924f1>] handle_IRQ_event+0x61/0x13b
  [<ffffffff81093dc9>] handle_edge_irq+0xeb/0x130
  [<ffffffff8100e910>] handle_irq+0x1f/0x27
  [<ffffffff8100df5c>] do_IRQ+0x5a/0xba
  [<ffffffff8100c513>] ret_from_intr+0x0/0x11
  [<ffffffffa006950f>] ? e1000_clean_tx_irq+0x71/0x2db [e1000e]
  [<ffffffff8100c513>] ? ret_from_intr+0x0/0x11
  [<ffffffffa00697aa>] ? e1000_intr_msix_tx+0x31/0x53 [e1000e] (eth6 tx)
  [<ffffffff810924f1>] ? handle_IRQ_event+0x61/0x13b
  [<ffffffff81093dc9>] ? handle_edge_irq+0xeb/0x130
  [<ffffffff8100e910>] ? handle_irq+0x1f/0x27
  [<ffffffff8100df5c>] ? do_IRQ+0x5a/0xba
  [<ffffffff8100c513>] ? ret_from_intr+0x0/0x11
  [<ffffffffa006b54a>] ? e1000_clean_rx_irq+0x1fb/0x2fb [e1000e] (eth6 rx)
  [<ffffffff8119a78c>] ? is_swiotlb_buffer+0x2b/0x39
  [<ffffffffa006cc87>] ? e1000_clean+0x75/0x22b [e1000e]
  [<ffffffff81255d96>] ? net_rx_action+0xb8/0x1e3
  [<ffffffff8104f9e3>] ? __do_softirq+0xde/0x19f
  [<ffffffff8100ccec>] ? call_softirq+0x1c/0x28
  [<ffffffff8100e8b1>] ? do_softirq+0x41/0x81
  [<ffffffff8104f7bd>] ? irq_exit+0x36/0x75
  [<ffffffff8100dfa5>] ? do_IRQ+0xa3/0xba
  [<ffffffff8100c513>] ? ret_from_intr+0x0/0x11
  <EOI>
  [<ffffffffa019161f>] ? acpi_idle_enter_bm+0x2bb/0x2f2 [processor]
  [<ffffffffa0191618>] ? acpi_idle_enter_bm+0x2b4/0x2f2 [processor]
  [<ffffffff8123f426>] ? cpuidle_idle_call+0x9b/0xf9
  [<ffffffff8100aeec>] ? cpu_idle+0x5b/0x93
  [<ffffffff812f7e82>] ? rest_init+0x66/0x68
  [<ffffffff814d9ca8>] ? start_kernel+0x381/0x38c
  [<ffffffff814d9140>] ? early_idt_handler+0x0/0x71
  [<ffffffff814d92a3>] ? x86_64_start_reservations+0xaa/0xae
  [<ffffffff814d939e>] ? x86_64_start_kernel+0xf7/0x106

Typically, we find several nested interrupts.  Each interrupt is for
a different interface and tx or rx combination as noted above in
parenthesis.  This problem happens on about 30% of our 4-day CHO runs.

The crash occurs in e1000_clean_tx_irq(), on this line:
              segs = skb_shinfo(skb)->gso_segs ?: 1;

because the skb is null (0xcc is the offset of gso_segs).

The problem is that we clean the tx_ring until we hit an entry that
does not have (eop_desc->upper.data & E1000_TXD_STAT_DD).
In other words, we keep cleaning the ring until we find an entry
that the hardware hasn't marked as done.

The crash always occurs when i >= tx_ring->next_to_use.  In the crash
above, we set eop to the ring entries next_to_watch index at the
bottom of the while loop:

index   next_to_watch   skb        descriptor->upper.data
0x46    0x46            null       0
0x47    0x47            null       0

That is, eop = 0x46.  By the time we get to the test at the top of the
while loop, the ring now looks like this:

index   next_to_watch   skb        descriptor->upper.data
0x46    0x47            null       E1000_TXD_STAT_DD
0x47    0x47            not-null   E1000_TXD_STAT_DD

Because descriptor->upper.data now has E1000_TXD_STAT_DD, we assume
this entry can be cleaned, and since we're using the old next_to_watch
value, we assume it has an skb.

Apparently, we've been interrupted long enough handling interrupts from
other interfaces that another cpu has had time to call e1000_start_xmit(),
queue up more tx's and the hardware has had time to xmit some of them
and mark them as E1000_TXD_STAT_DD.

I've been able to make this occur much more frequently (within 10 minutes)
by inserting a delay loop after we set eop, similar to:
    if (i == tx_ring->next_to_use) for (j = 0; j < 5000000; j++ ) ;

The fix is to just bail out when (i == tx_ring->next_to_use).  With
the fix and the delay loop, the problem no longer occurred for me.
A patch follows.  If you find it acceptable, please considerate it.
Thanks,

-T

