From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 2/4] netxen: fix mac list management
Date: Tue,  5 May 2009 22:05:07 -0700
Message-ID: <1241586309-12112-3-git-send-email-dhananjay@netxen.com>
References: <1241586309-12112-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:59285 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751478AbZEFFFN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2009 01:05:13 -0400
In-Reply-To: <1241586309-12112-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o use standard linked list api for mac addr list management
  in NX3031.
o release mac addresses in firmware in dev close().

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    6 +-
 drivers/net/netxen/netxen_nic_hw.c   |  124 ++++++++++++++--------------------
 drivers/net/netxen/netxen_nic_main.c |    7 +-
 3 files changed, 58 insertions(+), 79 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 8dacfbb..d368e24 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1019,8 +1019,8 @@ typedef struct {
 #define NETXEN_MAC_DEL	2
 
 typedef struct nx_mac_list_s {
-	struct nx_mac_list_s *next;
-	uint8_t mac_addr[MAX_ADDR_LEN];
+	struct list_head list;
+	uint8_t mac_addr[ETH_ALEN+2];
 } nx_mac_list_t;
 
 /*
@@ -1213,7 +1213,7 @@ struct netxen_adapter {
 
 	struct net_device *netdev;
 	struct pci_dev *pdev;
-	nx_mac_list_t	*mac_list;
+	struct list_head mac_list;
 
 	u32 curr_window;
 	u32 crb_win;
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 23c974a..be643ea 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -470,45 +470,6 @@ void netxen_p2_nic_set_multi(struct net_device *netdev)
 		netxen_nic_set_mcast_addr(adapter, index, null_addr);
 }
 
-static int nx_p3_nic_add_mac(struct netxen_adapter *adapter,
-		u8 *addr, nx_mac_list_t **add_list, nx_mac_list_t **del_list)
-{
-	nx_mac_list_t *cur, *prev;
-
-	/* if in del_list, move it to adapter->mac_list */
-	for (cur = *del_list, prev = NULL; cur;) {
-		if (memcmp(addr, cur->mac_addr, ETH_ALEN) == 0) {
-			if (prev == NULL)
-				*del_list = cur->next;
-			else
-				prev->next = cur->next;
-			cur->next = adapter->mac_list;
-			adapter->mac_list = cur;
-			return 0;
-		}
-		prev = cur;
-		cur = cur->next;
-	}
-
-	/* make sure to add each mac address only once */
-	for (cur = adapter->mac_list; cur; cur = cur->next) {
-		if (memcmp(addr, cur->mac_addr, ETH_ALEN) == 0)
-			return 0;
-	}
-	/* not in del_list, create new entry and add to add_list */
-	cur = kmalloc(sizeof(*cur), in_atomic()? GFP_ATOMIC : GFP_KERNEL);
-	if (cur == NULL) {
-		printk(KERN_ERR "%s: cannot allocate memory. MAC filtering may"
-				"not work properly from now.\n", __func__);
-		return -1;
-	}
-
-	memcpy(cur->mac_addr, addr, ETH_ALEN);
-	cur->next = *add_list;
-	*add_list = cur;
-	return 0;
-}
-
 static int
 netxen_send_cmd_descs(struct netxen_adapter *adapter,
 		struct cmd_desc_type0 *cmd_desc_arr, int nr_desc)
@@ -555,14 +516,12 @@ netxen_send_cmd_descs(struct netxen_adapter *adapter,
 	return 0;
 }
 
-static int nx_p3_sre_macaddr_change(struct net_device *dev,
-		u8 *addr, unsigned op)
+static int
+nx_p3_sre_macaddr_change(struct netxen_adapter *adapter, u8 *addr, unsigned op)
 {
-	struct netxen_adapter *adapter = netdev_priv(dev);
 	nx_nic_req_t req;
 	nx_mac_req_t *mac_req;
 	u64 word;
-	int rv;
 
 	memset(&req, 0, sizeof(nx_nic_req_t));
 	req.qhdr = cpu_to_le64(NX_NIC_REQUEST << 23);
@@ -574,28 +533,51 @@ static int nx_p3_sre_macaddr_change(struct net_device *dev,
 	mac_req->op = op;
 	memcpy(mac_req->mac_addr, addr, 6);
 
-	rv = netxen_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
-	if (rv != 0) {
-		printk(KERN_ERR "ERROR. Could not send mac update\n");
-		return rv;
+	return netxen_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
+}
+
+static int nx_p3_nic_add_mac(struct netxen_adapter *adapter,
+		u8 *addr, struct list_head *del_list)
+{
+	struct list_head *head;
+	nx_mac_list_t *cur;
+
+	/* look up if already exists */
+	list_for_each(head, del_list) {
+		cur = list_entry(head, nx_mac_list_t, list);
+
+		if (memcmp(addr, cur->mac_addr, ETH_ALEN) == 0) {
+			list_move_tail(head, &adapter->mac_list);
+			return 0;
+		}
 	}
 
-	return 0;
+	cur = kzalloc(sizeof(nx_mac_list_t), GFP_ATOMIC);
+	if (cur == NULL) {
+		printk(KERN_ERR "%s: failed to add mac address filter\n",
+				adapter->netdev->name);
+		return -ENOMEM;
+	}
+	memcpy(cur->mac_addr, addr, ETH_ALEN);
+	list_add_tail(&cur->list, &adapter->mac_list);
+	return nx_p3_sre_macaddr_change(adapter,
+				cur->mac_addr, NETXEN_MAC_ADD);
 }
 
 void netxen_p3_nic_set_multi(struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
-	nx_mac_list_t *cur, *next, *del_list, *add_list = NULL;
 	struct dev_mc_list *mc_ptr;
 	u8 bcast_addr[ETH_ALEN] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
 	u32 mode = VPORT_MISS_MODE_DROP;
+	LIST_HEAD(del_list);
+	struct list_head *head;
+	nx_mac_list_t *cur;
 
-	del_list = adapter->mac_list;
-	adapter->mac_list = NULL;
+	list_splice_tail_init(&adapter->mac_list, &del_list);
 
-	nx_p3_nic_add_mac(adapter, netdev->dev_addr, &add_list, &del_list);
-	nx_p3_nic_add_mac(adapter, bcast_addr, &add_list, &del_list);
+	nx_p3_nic_add_mac(adapter, netdev->dev_addr, &del_list);
+	nx_p3_nic_add_mac(adapter, bcast_addr, &del_list);
 
 	if (netdev->flags & IFF_PROMISC) {
 		mode = VPORT_MISS_MODE_ACCEPT_ALL;
@@ -611,25 +593,20 @@ void netxen_p3_nic_set_multi(struct net_device *netdev)
 	if (netdev->mc_count > 0) {
 		for (mc_ptr = netdev->mc_list; mc_ptr;
 		     mc_ptr = mc_ptr->next) {
-			nx_p3_nic_add_mac(adapter, mc_ptr->dmi_addr,
-					  &add_list, &del_list);
+			nx_p3_nic_add_mac(adapter, mc_ptr->dmi_addr, &del_list);
 		}
 	}
 
 send_fw_cmd:
 	adapter->set_promisc(adapter, mode);
-	for (cur = del_list; cur;) {
-		nx_p3_sre_macaddr_change(netdev, cur->mac_addr, NETXEN_MAC_DEL);
-		next = cur->next;
+	head = &del_list;
+	while (!list_empty(head)) {
+		cur = list_entry(head->next, nx_mac_list_t, list);
+
+		nx_p3_sre_macaddr_change(adapter,
+				cur->mac_addr, NETXEN_MAC_DEL);
+		list_del(&cur->list);
 		kfree(cur);
-		cur = next;
-	}
-	for (cur = add_list; cur;) {
-		nx_p3_sre_macaddr_change(netdev, cur->mac_addr, NETXEN_MAC_ADD);
-		next = cur->next;
-		cur->next = adapter->mac_list;
-		adapter->mac_list = cur;
-		cur = next;
 	}
 }
 
@@ -654,14 +631,15 @@ int netxen_p3_nic_set_promisc(struct netxen_adapter *adapter, u32 mode)
 
 void netxen_p3_free_mac_list(struct netxen_adapter *adapter)
 {
-	nx_mac_list_t *cur, *next;
-
-	cur = adapter->mac_list;
-
-	while (cur) {
-		next = cur->next;
+	nx_mac_list_t *cur;
+	struct list_head *head = &adapter->mac_list;
+
+	while (!list_empty(head)) {
+		cur = list_entry(head->next, nx_mac_list_t, list);
+		nx_p3_sre_macaddr_change(adapter,
+				cur->mac_addr, NETXEN_MAC_DEL);
+		list_del(&cur->list);
 		kfree(cur);
-		cur = next;
 	}
 }
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 6a496b1..a5577f8 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -815,6 +815,9 @@ netxen_nic_down(struct netxen_adapter *adapter, struct net_device *netdev)
 	if (adapter->stop_port)
 		adapter->stop_port(adapter);
 
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		netxen_p3_free_mac_list(adapter);
+
 	netxen_release_tx_buffers(adapter);
 
 	FLUSH_SCHEDULED_WORK();
@@ -961,6 +964,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	rwlock_init(&adapter->adapter_lock);
 	spin_lock_init(&adapter->tx_clean_lock);
+	INIT_LIST_HEAD(&adapter->mac_list);
 
 	err = netxen_setup_pci_map(adapter);
 	if (err)
@@ -1114,9 +1118,6 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 
 	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC) {
 		netxen_nic_detach(adapter);
-
-		if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
-			netxen_p3_free_mac_list(adapter);
 	}
 
 	if (adapter->portnum == 0)
-- 
1.6.0.2

