From: akepner <akepner@riverbed.com>
Subject: e1000e: avoid NULL pointer deref in e1000_print_hw_hang()
Date: Wed, 20 Mar 2013 18:40:05 -0700
Message-ID: <20130321014005.GD6755@riverbed.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eng.riverbed.com ([208.70.196.45]:17426 "EHLO
	smtp1.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752690Ab3CUBkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 21:40:07 -0400
Received: from riverbed.com (unknown [216.200.161.146])
	(using TLSv1 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	by tlssmtp (Postfix) with ESMTP id C309D6B97D
	for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 18:40:06 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If an e1000e interface is brought down, and subsequently 
'print_hang_task' is run we'll dereference a NULL 'buffer_info' 
pointer and crash with something like this: 

Mar 19 13:20:27  RXDATA: BUG: unable to handle kernel NULL pointer dereference at 000000000000001a
Mar 19 13:20:27  RXDATA: IP: [<ffffffff8145040c>] e1000_print_hw_hang+0x4c/0x390
Mar 19 13:20:27  RXDATA: PGD 82668067 PUD 763f6067 PMD 0
Mar 19 13:20:27  RXDATA: Oops: 0000 [#1] SMP
Mar 19 13:20:27  RXDATA: last sysfs file: /sys/devices/virtual/bypass/2-3/ping_watchdog
Mar 19 13:20:27  RXDATA: CPU 3
Mar 19 13:20:27  RXDATA: Pid: 18, comm: events/3 Tainted: P           ----------------   2.6.32 #1 empty
Mar 19 13:20:28  RXDATA: RIP: 0010:[<ffffffff8145040c>]  [<ffffffff8145040c>] e1000_print_hw_hang+0x4c/0x390
Mar 19 13:20:28  RXDATA: RSP: 0000:ffff88019ee71d40  EFLAGS: 00010202
Mar 19 13:20:28  RXDATA: RAX: 0000000000000000 RBX: ffff88019b64b3a0 RCX: ffff88019b648700
Mar 19 13:20:28  RXDATA: RDX: 0000000000000000 RSI: ffff88019b648000 RDI: ffff88019b64b3a0
Mar 19 13:20:28  RXDATA: RBP: ffff88019ee71e30 R08: 0000000000000000 R09: 0000000000000000
Mar 19 13:20:28  RXDATA: R10: ffff880028401340 R11: 0000000000000006 R12: ffff88019b5865c0
Mar 19 13:20:28  RXDATA: R13: ffffffff814503c0 R14: 0000000000000000 R15: ffff8800282d8a08
Mar 19 13:20:28  RXDATA: FS:  0000000000000000(0000) GS:ffff8800282c0000(0000) knlGS:0000000000000000
Mar 19 13:20:28  RXDATA: CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
Mar 19 13:20:28  RXDATA: CR2: 000000000000001a CR3: 0000000076364000 CR4: 00000000000406e0
Mar 19 13:20:28  RXDATA: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Mar 19 13:20:28  RXDATA: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Mar 19 13:20:28  RXDATA: Process events/3 (pid: 18, threadinfo ffff88019ee70000, task ffff88019ee6f560)
Mar 19 13:20:28  RXDATA: Stack:
Mar 19 13:20:28  RXDATA:  0000000000000000 0000000000000001 ffff88019ee71fd8 ffffea000173d740
Mar 19 13:20:28  RXDATA: <0> ffff88019ee71dd0 0000000000000282 ffff88019ee71fd8 ffff8800282d8a08
Mar 19 13:20:29  RXDATA: <0> ffff88019ee71da0 ffffffff811045ed ffffea000173d740 0000000000000000
Mar 19 13:20:29  RXDATA: Call Trace:
Mar 19 13:20:29  RXDATA:  [<ffffffff811045ed>] ? free_hot_page+0x2d/0x60
Mar 19 13:20:29  RXDATA:  [<ffffffff81127a6c>] ? __vunmap+0x9c/0x120
Mar 19 13:20:29  RXDATA:  [<ffffffff8116cfb0>] ? free_fdtable_work+0x0/0x90
Mar 19 13:20:29  RXDATA:  [<ffffffff814503c0>] ? e1000_print_hw_hang+0x0/0x390
Mar 19 13:20:29  RXDATA:  [<ffffffff81081120>] worker_thread+0x170/0x2a0
Mar 19 13:20:29  RXDATA:  [<ffffffff81086a60>] ? autoremove_wake_function+0x0/0x40
Mar 19 13:20:29  RXDATA:  [<ffffffff81080fb0>] ? worker_thread+0x0/0x2a0
Mar 19 13:20:29  RXDATA:  [<ffffffff810866f6>] kthread+0x96/0xa0
Mar 19 13:20:29  RXDATA:  [<ffffffff8100c0ea>] child_rip+0xa/


(This was seen on a pretty old kernel/driver, but looks like
the same bug is still possible.)

Signed-off-by: <akepner@riverbed.com>

--- 

Index: drivers/net/e1000e/netdev.c
===================================================================
--- drivers/net/e1000e/netdev.c	(revision 15849)
+++ drivers/net/e1000e/netdev.c	(working copy)
@@ -1441,18 +1441,25 @@ static void e1000_print_hw_hang(struct work_struct
 	struct e1000_adapter *adapter = container_of(work,
 						     struct e1000_adapter,
 						     print_hang_task);
-	struct net_device *netdev = adapter->netdev;
-	struct e1000_ring *tx_ring = adapter->tx_ring;
-	unsigned int i = tx_ring->next_to_clean;
-	unsigned int eop = tx_ring->buffer_info[i].next_to_watch;
-	struct e1000_tx_desc *eop_desc = E1000_TX_DESC(*tx_ring, eop);
-	struct e1000_hw *hw = &adapter->hw;
+	struct net_device *netdev;
+	struct e1000_ring *tx_ring;
+	unsigned int i;
+	unsigned int eop;
+	struct e1000_tx_desc *eop_desc;
+	struct e1000_hw *hw;
 	u16 phy_status, phy_1000t_status, phy_ext_status;
 	u16 pci_status;
 
 	if (test_bit(__E1000_DOWN, &adapter->state))
 		return;
 
+	netdev = adapter->netdev;
+	tx_ring = adapter->tx_ring;
+	i = tx_ring->next_to_clean;
+	eop = tx_ring->buffer_info[i].next_to_watch;
+	eop_desc = E1000_TX_DESC(*tx_ring, eop);
+	hw = &adapter->hw;
+
 	if (!adapter->tx_hang_recheck && (adapter->flags2 & FLAG2_DMA_BURST)) {
 		/* May be block on write-back, flush and detect again
 		 * flush pending descriptor writebacks to memory
