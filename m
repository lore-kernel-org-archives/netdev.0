From: Tushar Dave <tushar.n.dave@oracle.com>
Subject: [PATCH] ixgbe: Check for skb->queue_mapping
Date: Wed, 29 Mar 2017 16:55:14 -0700
Message-ID: <1490831714-6184-1-git-send-email-tushar.n.dave@oracle.com>
To: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24711 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932829AbdC2X5Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 19:57:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are events seen where skb->queue_mapping value is greater than
adapter->num_tx_queue. In such cases, adapter->tx_ring becomes invalid
(null) and xmit results in kernel panic.

One such event is running netconsole and enabling VF on the same device.
Or running netconsole and changing number of tx queues via ethtool on
same device.

This patch adds check for skb->queue_mapping and uses simple arithmetic
to select available tx queue from driver.

e.g.
Unable to handle kernel NULL pointer dereference
tsk->{mm,active_mm}->context = 0000000000001525
tsk->{mm,active_mm}->pgd = fff800130ff9a000
              \|/ ____ \|/
              "@'/ .. \`@"
              /_| \__/ |_\
                 \__U_/
kworker/48:1(475): Oops [#1]
CPU: 48 PID: 475 Comm: kworker/48:1 Tainted: G           OE
4.11.0-rc3-davem-net+ #7
Workqueue: events queue_process
task: fff80013113299c0 task.stack: fff800131132c000
TSTATE: 0000004480e01600 TPC: 00000000103f9e3c TNPC: 00000000103f9e40 Y:
00000000    Tainted: G           OE
TPC: <ixgbe_xmit_frame_ring+0x7c/0x6c0 [ixgbe]>
g0: 0000000000000000 g1: 0000000000003fff g2: 0000000000000000 g3:
0000000000000001
g4: fff80013113299c0 g5: fff8001fa6808000 g6: fff800131132c000 g7:
00000000000000c0
o0: fff8001fa760c460 o1: fff8001311329a50 o2: fff8001fa7607504 o3:
0000000000000003
o4: fff8001f96e63a40 o5: fff8001311d77ec0 sp: fff800131132f0e1 ret_pc:
000000000049ed94
RPC: <set_next_entity+0x34/0xb80>
l0: 0000000000000000 l1: 0000000000000800 l2: 0000000000000000 l3:
0000000000000000
l4: 000b2aa30e34b10d l5: 0000000000000000 l6: 0000000000000000 l7:
fff8001fa7605028
i0: fff80013111a8a00 i1: fff80013155a0780 i2: 0000000000000000 i3:
0000000000000000
i4: 0000000000000000 i5: 0000000000100000 i6: fff800131132f1a1 i7:
00000000103fa4b0
I7: <ixgbe_xmit_frame+0x30/0xa0 [ixgbe]>
Call Trace:
 [00000000103fa4b0] ixgbe_xmit_frame+0x30/0xa0 [ixgbe]
 [0000000000998c74] netpoll_start_xmit+0xf4/0x200
 [0000000000998e10] queue_process+0x90/0x160
 [0000000000485fa8] process_one_work+0x188/0x480
 [0000000000486410] worker_thread+0x170/0x4c0
 [000000000048c6b8] kthread+0xd8/0x120
 [0000000000406064] ret_from_fork+0x1c/0x2c
 [0000000000000000]           (null)
Disabling lock debugging due to kernel taint
Caller[00000000103fa4b0]: ixgbe_xmit_frame+0x30/0xa0 [ixgbe]
Caller[0000000000998c74]: netpoll_start_xmit+0xf4/0x200
Caller[0000000000998e10]: queue_process+0x90/0x160
Caller[0000000000485fa8]: process_one_work+0x188/0x480
Caller[0000000000486410]: worker_thread+0x170/0x4c0
Caller[000000000048c6b8]: kthread+0xd8/0x120
Caller[0000000000406064]: ret_from_fork+0x1c/0x2c
Caller[0000000000000000]:           (null)

Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 32 ++++++++++++++-------------
 1 file changed, 17 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a7a430a..6f76c3b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8149,29 +8149,31 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
-static netdev_tx_t __ixgbe_xmit_frame(struct sk_buff *skb,
-				      struct net_device *netdev,
-				      struct ixgbe_ring *ring)
+static inline struct ixgbe_ring *ixgbe_get_txq(struct ixgbe_adapter *adapter,
+					       struct sk_buff *skb)
 {
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	struct ixgbe_ring *tx_ring;
-
-	/*
-	 * The minimum packet size for olinfo paylen is 17 so pad the skb
-	 * in order to meet this minimum size requirement.
-	 */
-	if (skb_put_padto(skb, 17))
-		return NETDEV_TX_OK;
+	unsigned int txq = skb->queue_mapping;
 
-	tx_ring = ring ? ring : adapter->tx_ring[skb->queue_mapping];
+	if (txq >= adapter->num_tx_queues)
+		txq = txq % adapter->num_tx_queues;
 
-	return ixgbe_xmit_frame_ring(skb, adapter, tx_ring);
+	return adapter->tx_ring[txq];
 }
 
 static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 				    struct net_device *netdev)
 {
-	return __ixgbe_xmit_frame(skb, netdev, NULL);
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	/* The minimum packet size for olinfo paylen is 17 so pad the skb
+	 * in order to meet this minimum size requirement.
+	 */
+	if (skb_put_padto(skb, 17))
+		return NETDEV_TX_OK;
+
+	return ixgbe_xmit_frame_ring(skb,
+				     adapter,
+				     ixgbe_get_txq(adapter, skb));
 }
 
 /**
-- 
1.9.1
