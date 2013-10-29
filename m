From: David Mackey <tdmackey@booleanhaiku.com>
Subject: [PATCH] bnx2: Use dev_kfree_skb_any() in bnx2_tx_int()
Date: Tue, 29 Oct 2013 15:16:38 -0700
Message-ID: <1383084998-22673-1-git-send-email-tdmackey@booleanhaiku.com>
Cc: linux-kernel@vger.kernel.org,
	David Mackey <tdmackey@booleanhaiku.com>
To: mchan@broadcom.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using dev_kfree_skb_any() will resolve the below issue when a
netconsole message is transmitted in an irq.

 ------------[ cut here ]------------
 WARNING: at net/core/skbuff.c:451 skb_release_head_state+0x7b/0xe1()
 ...
 Pid: 0, comm: swapper/2 Not tainted 3.4.55 #1
 Call Trace:
  <IRQ>  [<ffffffff8104934c>] warn_slowpath_common+0x85/0x9d
  [<ffffffff8104937e>] warn_slowpath_null+0x1a/0x1c
  [<ffffffff81429aa7>] skb_release_head_state+0x7b/0xe1
  [<ffffffff814297e1>] __kfree_skb+0x16/0x81
  [<ffffffff814298a0>] consume_skb+0x54/0x69
  [<ffffffffa015925b>] bnx2_tx_int.clone.6+0x1b0/0x33e [bnx2]
  [<ffffffff8129c54d>] ? unmask_msi_irq+0x10/0x12
  [<ffffffffa015aa06>] bnx2_poll_work+0x3a/0x73 [bnx2]
  [<ffffffffa015aa73>] bnx2_poll_msix+0x34/0xb4 [bnx2]
  [<ffffffff814466a2>] netpoll_poll_dev+0xb9/0x1b7
  [<ffffffff814467d7>] ? find_skb+0x37/0x82
  [<ffffffff814461ed>] netpoll_send_skb_on_dev+0x117/0x200
  [<ffffffff81446a52>] netpoll_send_udp+0x230/0x242
  [<ffffffffa0174296>] write_msg+0xa7/0xfb [netconsole]
  [<ffffffff814258a4>] ? sk_free+0x1c/0x1e
  [<ffffffff810495ad>] __call_console_drivers+0x7d/0x8f
  [<ffffffff81049674>] _call_console_drivers+0xb5/0xd0
  [<ffffffff8104a134>] console_unlock+0x131/0x219
  [<ffffffff8104a7f9>] vprintk+0x3bc/0x405
  [<ffffffff81460073>] ? NF_HOOK.clone.1+0x4c/0x53
  [<ffffffff81460308>] ? ip_rcv+0x23c/0x268
  [<ffffffff814ddd4f>] printk+0x68/0x71
  [<ffffffff813315b3>] __dev_printk+0x78/0x7a
  [<ffffffff813316b2>] dev_warn+0x53/0x55
  [<ffffffff8127f181>] ? swiotlb_unmap_sg_attrs+0x47/0x5c
  [<ffffffffa004f876>] complete_scsi_command+0x28a/0x4a0 [hpsa]
  [<ffffffffa004fadb>] finish_cmd+0x4f/0x66 [hpsa]
  [<ffffffffa004fd97>] process_indexed_cmd+0x48/0x54 [hpsa]
  [<ffffffffa004ff25>] do_hpsa_intr_msi+0x4e/0x77 [hpsa]
  [<ffffffff810baebb>] handle_irq_event_percpu+0x5e/0x1b6
  [<ffffffff81088a0b>] ? timekeeping_update+0x43/0x45
  [<ffffffff810bb04b>] handle_irq_event+0x38/0x54
  [<ffffffff8102bd1e>] ? ack_apic_edge+0x36/0x3a
  [<ffffffff810bd762>] handle_edge_irq+0xa5/0xc8
  [<ffffffff81010d56>] handle_irq+0x127/0x135
  [<ffffffff814e3426>] ? __atomic_notifier_call_chain+0x12/0x14
  [<ffffffff814e343c>] ? atomic_notifier_call_chain+0x14/0x16
  [<ffffffff814e897d>] do_IRQ+0x4d/0xb4
  [<ffffffff814dffea>] common_interrupt+0x6a/0x6a
  <EOI>  [<ffffffff812b7603>] ? intel_idle+0xd8/0x112
  [<ffffffff812b7603>] ? intel_idle+0xd8/0x112
  [<ffffffff812b75e9>] ? intel_idle+0xbe/0x112
  [<ffffffff814012fc>] cpuidle_enter+0x12/0x14
  [<ffffffff814019c2>] cpuidle_idle_call+0xd1/0x19b
  [<ffffffff81016551>] cpu_idle+0xb6/0xff
  [<ffffffff814d726b>] start_secondary+0xc8/0xca
 ---[ end trace 3f15cd66441c770d ]---

Signed-off-by: David Mackey <tdmackey@booleanhaiku.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index e838a3f..372cbb5 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -2868,7 +2868,7 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		sw_cons = BNX2_NEXT_TX_BD(sw_cons);
 
 		tx_bytes += skb->len;
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		tx_pkt++;
 		if (tx_pkt == budget)
 			break;
-- 
1.7.9.5
