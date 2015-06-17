From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/17] fm10k: use correct ethernet driver Tx timestamp function
Date: Wed, 17 Jun 2015 05:54:50 -0700
Message-ID: <1434545704-112470-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1434545704-112470-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:22624 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756300AbbFQMzJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 08:55:09 -0400
In-Reply-To: <1434545704-112470-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

skb_complete_tx_timestamp is intended for use by PHY drivers which
implement a different method of returning timestamps. This method is
intended to be used after a PHY driver accepts a cloned packet via its
phy_driver.txtstamp function. It is not correct to use in the standard
ethernet driver such as fm10k. This patch fixes the following possible
kernel panic.

[ 2744.552896] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G        W  OE  3.19.3-200.fc21.x86_64 #1
[ 2744.552899] Hardware name: Intel Corporation S2600CO/S2600CO, BIOS SE5C600.86B.02.03.8x23.060520140825 06/05/2014
[ 2744.552901]  0000000000000000 2f4c8b10ea3f9848 ffff88081ee03a38 ffffffff8176e215
[ 2744.552906]  0000000000000000 0000000000000000 ffff88081ee03a78 ffffffff8109bc1a
[ 2744.552910]  ffff88081ee03c50 ffff88080e55fc00 ffff88080e55fc00 ffffffff81647c50
[ 2744.552914] Call Trace:
[ 2744.552917]  <IRQ>  [<ffffffff8176e215>] dump_stack+0x45/0x57
[ 2744.552931]  [<ffffffff8109bc1a>] warn_slowpath_common+0x8a/0xc0
[ 2744.552936]  [<ffffffff81647c50>] ? skb_queue_purge+0x20/0x40
[ 2744.552941]  [<ffffffff8109bd4a>] warn_slowpath_null+0x1a/0x20
[ 2744.552946]  [<ffffffff81646911>] skb_release_head_state+0xe1/0xf0
[ 2744.552950]  [<ffffffff81647b26>] skb_release_all+0x16/0x30
[ 2744.552954]  [<ffffffff81647ba6>] kfree_skb+0x36/0x90
[ 2744.552958]  [<ffffffff81647c50>] skb_queue_purge+0x20/0x40
[ 2744.552964]  [<ffffffff81751f8d>] packet_sock_destruct+0x1d/0x90
[ 2744.552968]  [<ffffffff81642053>] __sk_free+0x23/0x140
[ 2744.552973]  [<ffffffff81642189>] sk_free+0x19/0x20
[ 2744.552977]  [<ffffffff81647d60>] skb_complete_tx_timestamp+0x50/0x60
[ 2744.552988]  [<ffffffffa02eee40>] fm10k_ts_tx_hwtstamp+0xd0/0x100 [fm10k]
[ 2744.552994]  [<ffffffffa02e054e>] fm10k_1588_msg_pf+0x12e/0x140 [fm10k]
[ 2744.553002]  [<ffffffffa02edf1d>] fm10k_tlv_msg_parse+0x8d/0xc0 [fm10k]
[ 2744.553010]  [<ffffffffa02eb2d0>] fm10k_mbx_dequeue_rx+0x60/0xb0 [fm10k]
[ 2744.553016]  [<ffffffffa02ebf98>] fm10k_sm_mbx_process+0x178/0x3c0 [fm10k]
[ 2744.553022]  [<ffffffffa02e09ca>] fm10k_msix_mbx_pf+0xfa/0x360 [fm10k]
[ 2744.553030]  [<ffffffff811030a7>] ? get_next_timer_interrupt+0x1f7/0x270
[ 2744.553036]  [<ffffffff810f2a47>] handle_irq_event_percpu+0x77/0x1a0
[ 2744.553041]  [<ffffffff810f2bab>] handle_irq_event+0x3b/0x60
[ 2744.553045]  [<ffffffff810f5d6e>] handle_edge_irq+0x6e/0x120
[ 2744.553054]  [<ffffffff81017414>] handle_irq+0x74/0x140
[ 2744.553061]  [<ffffffff810bb54a>] ? atomic_notifier_call_chain+0x1a/0x20
[ 2744.553066]  [<ffffffff8177777f>] do_IRQ+0x4f/0xf0
[ 2744.553072]  [<ffffffff8177556d>] common_interrupt+0x6d/0x6d
[ 2744.553074]  <EOI>  [<ffffffff81609b16>] ? cpuidle_enter_state+0x66/0x160
[ 2744.553084]  [<ffffffff81609b01>] ? cpuidle_enter_state+0x51/0x160
[ 2744.553087]  [<ffffffff81609cf7>] cpuidle_enter+0x17/0x20
[ 2744.553092]  [<ffffffff810de101>] cpu_startup_entry+0x321/0x3c0
[ 2744.553098]  [<ffffffff81764497>] rest_init+0x77/0x80
[ 2744.553103]  [<ffffffff81d4f02c>] start_kernel+0x4a4/0x4c5
[ 2744.553107]  [<ffffffff81d4e120>] ? early_idt_handlers+0x120/0x120
[ 2744.553110]  [<ffffffff81d4e4d7>] x86_64_start_reservations+0x2a/0x2c
[ 2744.553114]  [<ffffffff81d4e62b>] x86_64_start_kernel+0x152/0x175

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c b/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
index 9043633..95f1d62 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
@@ -103,9 +103,10 @@ void fm10k_ts_tx_hwtstamp(struct fm10k_intfc *interface, __le16 dglort,
 	if (!skb)
 		return;
 
-	/* timestamp the sk_buff and return it to the socket */
+	/* timestamp the sk_buff and free out copy */
 	fm10k_systime_to_hwtstamp(interface, &shhwtstamps, systime);
-	skb_complete_tx_timestamp(skb, &shhwtstamps);
+	skb_tstamp_tx(skb, &shhwtstamps);
+	dev_kfree_skb_any(skb);
 }
 
 void fm10k_ts_tx_subtask(struct fm10k_intfc *interface)
-- 
2.4.3
