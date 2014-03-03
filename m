From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] netpoll: Don't call driver methods from interrupt context.
Date: Mon, 03 Mar 2014 12:40:05 -0800
Message-ID: <874n3fow2i.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Cong Wang <xiyou.wangcong@gmail.com>,
	Matt Mackall <mpm@selenic.com>,
	Satyam Sharma <satyam.sharma@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:60562 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754177AbaCCUkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 15:40:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The attraction of the netpoll design is that with just one simple extra
method .ndo_poll_controller added to the driver a network adapter can be
polled.  This promise of simplicity and no special maintenance falls
down in the case of using network addapters from interrupt context.

There are multiple failure modes.  A typical example is:
WARNING: at net/core/skbuff.c:451 skb_release_head_state+0x7b/0xe1()
Pid: 0, comm: swapper/2 Not tainted 3.4 #1
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

To avoid this class of problem modify the netpoll so that it does not call
driver methods from interrupt context.

To achieve this all that is required is the addition of two simple tests
of in_irq(), and the ultilization of the existing logic.

Instead of attempting to transmit a packet from interrupt context,
updated the code to queue the skb in struct netpoll_info txq.

Similary when attempting to allocate a skb to hold the packet to be
transmitted when in interrupt context don't poll the device to see if
we can free some packet buffers.

In all cases where netpoll works reliably today this should result in no
change, but in nasty cases where there are messages printed from
interrupt context this should result in queued skbs that will transmited
with a small delay instead of executing code in conditions the network
deriver code has never been tested in which results in unpredictable
behavior.

One easy to trigger nasty pathology this avoids is generating a message
in interrupt context that generates a warning message the warning
message for calling the code in interrupt context which then generates
another warning message for calling the code in interrupt context
potentialy indefinitely.  That is a pathology I have observed triggered
with sysrq-t.

Cc: stable@vger.kernel.org
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/core/netpoll.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index a664f7829a6d..a1877621bf31 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -330,7 +330,7 @@ repeat:
 		skb = skb_dequeue(&skb_pool);
 
 	if (!skb) {
-		if (++count < 10) {
+		if (++count < 10 && !in_irq()) {
 			netpoll_poll_dev(np->dev);
 			goto repeat;
 		}
@@ -371,8 +371,8 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 		return;
 	}
 
-	/* don't get messages out of order, and no recursion */
-	if (skb_queue_len(&npinfo->txq) == 0 && !netpoll_owner_active(dev)) {
+	/* don't get messages out of order, and no recursion, and don't operate in irq context */
+	if (skb_queue_len(&npinfo->txq) == 0 && !netpoll_owner_active(dev) && !in_irq()) {
 		struct netdev_queue *txq;
 
 		txq = netdev_pick_tx(dev, skb, NULL);
-- 
1.7.5.4
