From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] pktgen: Clone skb to avoid corruption of skbs in ndo_start_xmit methods
Date: Tue, 19 Jul 2011 15:52:59 -0400
Message-ID: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52746 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952Ab1GSTx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 15:53:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This oops was reported recently when running a pktgen script that called for a
transmitted skb to be cloned and sent 100 times using the clone_skb command to a
bridge device with several attached interface:

BUG: unable to handle kernel paging request at ffff880136994528
RIP: 0010:[<ffff880136994528>]  [<ffff880136994528>] 0xffff880136994528
RSP: 0018:ffff8801384e5b78  EFLAGS: 00010286
RAX: ffff880136994528 RBX: ffff880137e52800 RCX: 0000000000000000
RDX: ffffffffa0529ba0 RSI: ffff880137e52800 RDI: ffff8801369944b0
RBP: ffff8801384e5ba0 R08: ffff8801379cb49c R09: ffff8801384e5c78
R10: 0000000000000000 R11: 0000000000000400 R12: ffff880137e52ec0
R13: ffff8801369944b0 R14: ffff880136ed9480 R15: ffff880137e52800
FS:  0000000000000000(0000) GS:ffff880028200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: ffff880136994528 CR3: 00000001395f2000 CR4: 00000000000026e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kpktgend_0 (pid: 2601, threadinfo ffff8801384e4000, task
ffff880137fe5560)
Stack:
 ffffffffa0527425 0000000000000000 ffff8801369944b0 ffff880137e52800
<0> ffff880136ed9480 ffff8801384e5bf0 ffffffff8141047a ffffffffa0529ba0
<0> ffff880134813e40 0000000080000000 ffff8801379cb400 ffff880137e52800
Call Trace:
 [<ffffffffa0527425>] ? tun_net_xmit+0x135/0x200 [tun]
 [<ffffffff8141047a>] dev_hard_start_xmit+0x20a/0x370
 [<ffffffff814288aa>] sch_direct_xmit+0x15a/0x1c0
 [<ffffffff81413ab8>] dev_queue_xmit+0x378/0x4a0
 [<ffffffffa0488400>] ? br_dev_queue_push_xmit+0x0/0xa0 [bridge]
 [<ffffffffa048846c>] br_dev_queue_push_xmit+0x6c/0xa0 [bridge]
 [<ffffffffa04884f8>] br_forward_finish+0x58/0x60 [bridge]
 [<ffffffffa0488690>] __br_deliver+0x60/0x70 [bridge]
 [<ffffffffa04883aa>] br_flood+0xca/0xe0 [bridge]
 [<ffffffffa0488630>] ? __br_deliver+0x0/0x70 [bridge]
 [<ffffffffa04883f7>] br_flood_deliver+0x17/0x20 [bridge]
 [<ffffffffa048748b>] br_dev_xmit+0xfb/0x100 [bridge]
 [<ffffffffa053790e>] pktgen_thread_worker+0x83e/0x1bc8 [pktgen]
 [<ffffffff81059d12>] ? finish_task_switch+0x42/0xd0
 [<ffffffffa0487390>] ? br_dev_xmit+0x0/0x100 [bridge]
 [<ffffffff81091ca0>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff81091ca0>] ? autoremove_wake_function+0x0/0x40
 [<ffffffffa05370d0>] ? pktgen_thread_worker+0x0/0x1bc8 [pktgen]
 [<ffffffff81091936>] kthread+0x96/0xa0
 [<ffffffff810141ca>] child_rip+0xa/0x20
 [<ffffffff810918a0>] ? kthread+0x0/0xa0
 [<ffffffff810141c0>] ? child_rip+0x0/0x20

Turns out the pktgen driver doesn't actually clone skbs, but rather shares them,
increasing the reference count of the skb for each send operation.  This works
for most drivers because most drivers don't store or care about any state in the
skb itself, but several do.  For instance, the above tun/tap driver and other
soft drivers (vlans, bonding/bridging), all requeue frames to a physical device,
meaning the skb next and prev pointers will be set.  Other drivers also care
about skb state.  The virtio_net driver for instance uses the skb->cb space to
store a vnet header and several converged adapters adjust the data pointer of an
skb to prepend a device control header to the skb.  Drivers expect skbs
submitted for i/o to be in their control and unshared with other users, an
assumption which pktgen is violating, the result being multiple skb users
corrupting one antohers state and producing oopses like the one above.  The
solution is to make pktgen clone the skb for each transmit so as to ensure the
drivers assumptions about private exclusive access to the skb is maintained.

Tested successfully by myself
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Reported-by: Jiri Pirko <jpirko@redhat.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: Alexey Dobriyan <adobriyan@gmail.com>
CC: David S. Miller <davem@davemloft.net>
---
 net/core/pktgen.c |   21 +++++++++++++--------
 1 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index f76079c..c8e0e08 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3297,6 +3297,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 	netdev_tx_t (*xmit)(struct sk_buff *, struct net_device *)
 		= odev->netdev_ops->ndo_start_xmit;
 	struct netdev_queue *txq;
+	struct sk_buff *tx_skb = NULL;
 	u16 queue_map;
 	int ret;
 
@@ -3316,9 +3317,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 
 	/* If no skb or clone count exhausted then get new one */
 	if (!pkt_dev->skb || (pkt_dev->last_ok &&
-			      ++pkt_dev->clone_count >= pkt_dev->clone_skb)) {
-		/* build a new pkt */
-		kfree_skb(pkt_dev->skb);
+			      ++pkt_dev->clone_count > pkt_dev->clone_skb)) {
 
 		pkt_dev->skb = fill_packet(odev, pkt_dev);
 		if (pkt_dev->skb == NULL) {
@@ -3332,10 +3331,13 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		pkt_dev->clone_count = 0;	/* reset counter */
 	}
 
+	tx_skb = (pkt_dev->clone_count == pkt_dev->clone_skb) ?
+		 pkt_dev->skb : skb_clone(pkt_dev->skb, GFP_KERNEL);
+
 	if (pkt_dev->delay && pkt_dev->last_ok)
 		spin(pkt_dev, pkt_dev->next_tx);
 
-	queue_map = skb_get_queue_mapping(pkt_dev->skb);
+	queue_map = skb_get_queue_mapping(tx_skb);
 	txq = netdev_get_tx_queue(odev, queue_map);
 
 	__netif_tx_lock_bh(txq);
@@ -3345,8 +3347,8 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		pkt_dev->last_ok = 0;
 		goto unlock;
 	}
-	atomic_inc(&(pkt_dev->skb->users));
-	ret = (*xmit)(pkt_dev->skb, odev);
+
+	ret = (*xmit)(tx_skb, odev);
 
 	switch (ret) {
 	case NETDEV_TX_OK:
@@ -3369,8 +3371,11 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		/* fallthru */
 	case NETDEV_TX_LOCKED:
 	case NETDEV_TX_BUSY:
-		/* Retry it next time */
-		atomic_dec(&(pkt_dev->skb->users));
+		/*
+		 * Only free it if its not the last in the clone series
+		 */
+		if (tx_skb != pkt_dev->skb)
+			kfree_skb(tx_skb);
 		pkt_dev->last_ok = 0;
 	}
 unlock:
-- 
1.7.6

