From: idosch@idosch.org
Subject: [PATCH net] net: core: Correctly iterate over lower adjacency list
Date: Wed, 19 Oct 2016 16:57:08 +0300
Message-ID: <1476885428-5189-1-git-send-email-idosch@idosch.org>
Cc: netdev@vger.kernel.org, jiri@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        dsa@cumulusnetworks.com, Ido Schimmel <idosch@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:44846 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S941058AbcJSOQU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 10:16:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Tamir reported the following trace when processing ARP requests received
via a vlan device on top of a VLAN-aware bridge:

 NMI watchdog: BUG: soft lockup - CPU#1 stuck for 22s! [swapper/1:0]
[...]
 CPU: 1 PID: 0 Comm: swapper/1 Tainted: G        W       4.8.0-rc7 #1
 Hardware name: Mellanox Technologies Ltd. "MSN2100-CB2F"/"SA001017", BIOS 5.6.5 06/07/2016
 task: ffff88017edfea40 task.stack: ffff88017ee10000
 RIP: 0010:[<ffffffff815dcc73>]  [<ffffffff815dcc73>] netdev_all_lower_get_next_rcu+0x33/0x60
[...]
 Call Trace:
  <IRQ>
  [<ffffffffa015de0a>] mlxsw_sp_port_lower_dev_hold+0x5a/0xa0 [mlxsw_spectrum]
  [<ffffffffa016f1b0>] mlxsw_sp_router_netevent_event+0x80/0x150 [mlxsw_spectrum]
  [<ffffffff810ad07a>] notifier_call_chain+0x4a/0x70
  [<ffffffff810ad13a>] atomic_notifier_call_chain+0x1a/0x20
  [<ffffffff815ee77b>] call_netevent_notifiers+0x1b/0x20
  [<ffffffff815f2eb6>] neigh_update+0x306/0x740
  [<ffffffff815f38ce>] neigh_event_ns+0x4e/0xb0
  [<ffffffff8165ea3f>] arp_process+0x66f/0x700
  [<ffffffff8170214c>] ? common_interrupt+0x8c/0x8c
  [<ffffffff8165ec29>] arp_rcv+0x139/0x1d0
  [<ffffffff816e505a>] ? vlan_do_receive+0xda/0x320
  [<ffffffff815e3794>] __netif_receive_skb_core+0x524/0xab0
  [<ffffffff815e6830>] ? dev_queue_xmit+0x10/0x20
  [<ffffffffa06d612d>] ? br_forward_finish+0x3d/0xc0 [bridge]
  [<ffffffffa06e5796>] ? br_handle_vlan+0xf6/0x1b0 [bridge]
  [<ffffffff815e3d38>] __netif_receive_skb+0x18/0x60
  [<ffffffff815e3dc0>] netif_receive_skb_internal+0x40/0xb0
  [<ffffffff815e3e4c>] netif_receive_skb+0x1c/0x70
  [<ffffffffa06d7856>] br_pass_frame_up+0xc6/0x160 [bridge]
  [<ffffffffa06d63d7>] ? deliver_clone+0x37/0x50 [bridge]
  [<ffffffffa06d656c>] ? br_flood+0xcc/0x160 [bridge]
  [<ffffffffa06d7b14>] br_handle_frame_finish+0x224/0x4f0 [bridge]
  [<ffffffffa06d7f94>] br_handle_frame+0x174/0x300 [bridge]
  [<ffffffff815e3599>] __netif_receive_skb_core+0x329/0xab0
  [<ffffffff81374815>] ? find_next_bit+0x15/0x20
  [<ffffffff8135e802>] ? cpumask_next_and+0x32/0x50
  [<ffffffff810c9968>] ? load_balance+0x178/0x9b0
  [<ffffffff815e3d38>] __netif_receive_skb+0x18/0x60
  [<ffffffff815e3dc0>] netif_receive_skb_internal+0x40/0xb0
  [<ffffffff815e3e4c>] netif_receive_skb+0x1c/0x70
  [<ffffffffa01544a1>] mlxsw_sp_rx_listener_func+0x61/0xb0 [mlxsw_spectrum]
  [<ffffffffa005c9f7>] mlxsw_core_skb_receive+0x187/0x200 [mlxsw_core]
  [<ffffffffa007332a>] mlxsw_pci_cq_tasklet+0x63a/0x9b0 [mlxsw_pci]
  [<ffffffff81091986>] tasklet_action+0xf6/0x110
  [<ffffffff81704556>] __do_softirq+0xf6/0x280
  [<ffffffff8109213f>] irq_exit+0xdf/0xf0
  [<ffffffff817042b4>] do_IRQ+0x54/0xd0
  [<ffffffff8170214c>] common_interrupt+0x8c/0x8c

The problem is that netdev_all_lower_get_next_rcu() never advances the
iterator, thereby causing the loop over the lower adjacency list to run
forever.

Fix this by advancing the iterator and avoid the infinite loop.

Fixes: 7ce856aaaf13 ("mlxsw: spectrum: Add couple of lower device helper functions")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Reported-by: Tamir Winetroub <tamirw@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
---
Note that DavidA's series removes this code in net-next, but it wasn't
picked up for net, so I'm sending this patch.
Please consider queueing this for 4.8.y
---
 include/linux/netdevice.h |  2 +-
 net/core/dev.c            | 10 +++++++---
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 136ae6bb..465e128 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3877,7 +3877,7 @@ struct net_device *netdev_all_lower_get_next_rcu(struct net_device *dev,
 	     ldev = netdev_all_lower_get_next(dev, &(iter)))
 
 #define netdev_for_each_all_lower_dev_rcu(dev, ldev, iter) \
-	for (iter = (dev)->all_adj_list.lower.next, \
+	for (iter = &(dev)->all_adj_list.lower, \
 	     ldev = netdev_all_lower_get_next_rcu(dev, &(iter)); \
 	     ldev; \
 	     ldev = netdev_all_lower_get_next_rcu(dev, &(iter)))
diff --git a/net/core/dev.c b/net/core/dev.c
index f1fe26f..b09ac57 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5511,10 +5511,14 @@ struct net_device *netdev_all_lower_get_next_rcu(struct net_device *dev,
 {
 	struct netdev_adjacent *lower;
 
-	lower = list_first_or_null_rcu(&dev->all_adj_list.lower,
-				       struct netdev_adjacent, list);
+	lower = list_entry_rcu((*iter)->next, struct netdev_adjacent, list);
+
+	if (&lower->list == &dev->all_adj_list.lower)
+		return NULL;
+
+	*iter = &lower->list;
 
-	return lower ? lower->dev : NULL;
+	return lower->dev;
 }
 EXPORT_SYMBOL(netdev_all_lower_get_next_rcu);
 
-- 
2.7.4
