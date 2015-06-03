From: sfeldma@gmail.com
Subject: [PATCH net-next v2] rocker: move netevent neigh update to processes context
Date: Tue,  2 Jun 2015 20:43:28 -0700
Message-ID: <1433303008-32656-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, simon.horman@netronome.com,
	makita.toshiaki@lab.ntt.co.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:35468 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752745AbbFCDlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 23:41:52 -0400
Received: by pdbnf5 with SMTP id nf5so86052453pdb.2
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 20:41:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

v2:

Changes based on review:

- David Miller <davem@davemloft.net> raise problem with system_wq not
  preserving queue order to execution order.  To fix, use driver-private
  ordered workqueue to preserve ordering of queued work.

- Jiri Pirko <jiri@resnulli.us> small change on kfree of work queue item.

v1:

In review of Simon's patchset "rocker: transaction fixes". it was noted
that rocker->neigh_tbl_next_index was unprotected in the call path below
and could race with other contexts calling rocker_port_ipv4_neigh():

	arp_process()
	neigh_update()
	rocker_neigh_update()
	rocker_port_ipv4_neigh()

To fix, move the neigh_update() event processing to process contexts and
hold rtnl_lock to call rocker_port_ipv4_neigh().  This will protect
rocker->neigh_tbl_next_index accesses and is more consistent with the rest
of the driver code where non-I/O processing is done under process context
with rtnl_lock held.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/rocker/rocker.c |   71 +++++++++++++++++++++++++++++-----
 1 file changed, 62 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 819289e..aaf5e38 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -240,6 +240,9 @@ struct rocker {
 	spinlock_t cmd_ring_lock;		/* for cmd ring accesses */
 	struct rocker_dma_ring_info cmd_ring;
 	struct rocker_dma_ring_info event_ring;
+	struct workqueue_struct *wq;		/* ordered workqueue for
+						 * async processing
+						 */
 	DECLARE_HASHTABLE(flow_tbl, 16);
 	spinlock_t flow_tbl_lock;		/* for flow tbl accesses */
 	u64 flow_tbl_next_cookie;
@@ -1464,7 +1467,7 @@ static void rocker_event_mac_vlan_seen_work(struct work_struct *work)
 			sw->addr, sw->vlan_id, sw->flags);
 	rtnl_unlock();
 
-	kfree(work);
+	kfree(sw);
 }
 
 static int rocker_event_mac_vlan_seen(const struct rocker *rocker,
@@ -1508,7 +1511,7 @@ static int rocker_event_mac_vlan_seen(const struct rocker *rocker,
 	ether_addr_copy(sw->addr, addr);
 	sw->vlan_id = vlan_id;
 
-	schedule_work(&sw->work);
+	queue_work(rocker_port->rocker->wq, &sw->work);
 
 	return 0;
 }
@@ -3523,6 +3526,7 @@ static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
 				 enum switchdev_trans trans, int flags,
 				 const u8 *addr, __be16 vlan_id)
 {
+	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_fdb_learn_work *lw;
 	enum rocker_of_dpa_table_id goto_tbl =
 		ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
@@ -3565,7 +3569,7 @@ static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
 	if (trans == SWITCHDEV_TRANS_PREPARE)
 		rocker_port_kfree(trans, lw);
 	else
-		schedule_work(&lw->work);
+		queue_work(rocker->wq, &lw->work);
 
 	return 0;
 }
@@ -4962,6 +4966,12 @@ static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	if (!rocker)
 		return -ENOMEM;
 
+	rocker->wq = alloc_ordered_workqueue("rocker", 0);
+	if (!rocker->wq) {
+		dev_err(&pdev->dev, "allocate workqueue failed\n");
+		goto err_wq;
+	}
+
 	err = pci_enable_device(pdev);
 	if (err) {
 		dev_err(&pdev->dev, "pci_enable_device failed\n");
@@ -5081,6 +5091,8 @@ err_pci_set_dma_mask:
 err_pci_request_regions:
 	pci_disable_device(pdev);
 err_pci_enable_device:
+	destroy_workqueue(rocker->wq);
+err_wq:
 	kfree(rocker);
 	return err;
 }
@@ -5099,6 +5111,7 @@ static void rocker_remove(struct pci_dev *pdev)
 	iounmap(rocker->hw_addr);
 	pci_release_regions(rocker->pdev);
 	pci_disable_device(rocker->pdev);
+	destroy_workqueue(rocker->wq);
 	kfree(rocker);
 }
 
@@ -5224,14 +5237,54 @@ static struct notifier_block rocker_netdevice_nb __read_mostly = {
  * Net event notifier event handler
  ************************************/
 
-static int rocker_neigh_update(struct net_device *dev, struct neighbour *n)
+struct rocker_neigh_update_work {
+	struct work_struct work;
+	struct rocker_port *rocker_port;
+	int flags;
+	__be32 ip_addr;
+	unsigned char ha[ALIGN(MAX_ADDR_LEN, sizeof(unsigned long))];
+};
+
+static void rocker_event_neigh_update_work(struct work_struct *work)
+{
+	struct rocker_neigh_update_work *nw =
+		container_of(work, struct rocker_neigh_update_work, work);
+	int err;
+
+	rtnl_lock();
+	err = rocker_port_ipv4_neigh(nw->rocker_port, SWITCHDEV_TRANS_NONE,
+				     nw->flags, nw->ip_addr, nw->ha);
+	rtnl_unlock();
+
+	if (err)
+		netdev_warn(nw->rocker_port->dev,
+			    "failed to handle neigh %pI4 update (err %d)\n",
+			    &nw->ip_addr, err);
+
+	kfree(nw);
+}
+
+static int rocker_event_neigh_update(struct net_device *dev,
+				     struct neighbour *n)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
-	int flags = (n->nud_state & NUD_VALID) ? 0 : ROCKER_OP_FLAG_REMOVE;
-	__be32 ip_addr = *(__be32 *)n->primary_key;
+	struct rocker *rocker = rocker_port->rocker;
+	struct rocker_neigh_update_work *nw;
 
-	return rocker_port_ipv4_neigh(rocker_port, SWITCHDEV_TRANS_NONE,
-				      flags, ip_addr, n->ha);
+	nw = kmalloc(sizeof(*nw), GFP_ATOMIC);
+	if (!nw)
+		return -ENOMEM;
+
+	INIT_WORK(&nw->work, rocker_event_neigh_update_work);
+
+	nw->rocker_port = rocker_port;
+	nw->flags = (n->nud_state & NUD_VALID) ? 0 : ROCKER_OP_FLAG_REMOVE;
+	nw->ip_addr = *(__be32 *)n->primary_key;
+	memcpy(nw->ha, n->ha, sizeof(nw->ha));
+
+	queue_work(rocker->wq, &nw->work);
+
+	return 0;
 }
 
 static int rocker_netevent_event(struct notifier_block *unused,
@@ -5248,7 +5301,7 @@ static int rocker_netevent_event(struct notifier_block *unused,
 		dev = n->dev;
 		if (!rocker_port_dev_check(dev))
 			return NOTIFY_DONE;
-		err = rocker_neigh_update(dev, n);
+		err = rocker_event_neigh_update(dev, n);
 		if (err)
 			netdev_warn(dev,
 				    "failed to handle neigh update (err %d)\n",
-- 
1.7.10.4
