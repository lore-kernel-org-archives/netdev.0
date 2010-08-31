From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 09/10] qlcnic: mac vlan learning support
Date: Tue, 31 Aug 2010 07:29:39 -0700
Message-ID: <1283264980-25881-10-git-send-email-amit.salecha@qlogic.com>
References: <1283264980-25881-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:23243 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1757475Ab0HaO3m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 10:29:42 -0400
In-Reply-To: <1283264980-25881-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hypervisor allows, two VM's interfaces to have same mac address.
These VM's interfaces get differentiate with Vlan tag.
This patch add support to learn and configure mac+vlan filter on device.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    3 +++
 drivers/net/qlcnic/qlcnic_hw.c   |   17 +++++++++++------
 drivers/net/qlcnic/qlcnic_main.c |   16 ++++++++++++----
 3 files changed, 26 insertions(+), 10 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 9f306fb..6667c30 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -722,6 +722,8 @@ struct qlcnic_cardrsp_tx_ctx {
 #define QLCNIC_MAC_NOOP	0
 #define QLCNIC_MAC_ADD	1
 #define QLCNIC_MAC_DEL	2
+#define QLCNIC_MAC_VLAN_ADD	3
+#define QLCNIC_MAC_VLAN_DEL	4
 
 struct qlcnic_mac_list_s {
 	struct list_head list;
@@ -932,6 +934,7 @@ struct qlcnic_mac_req {
 struct qlcnic_filter {
 	struct hlist_node fnode;
 	u8 faddr[ETH_ALEN];
+	u16 vlan_id;
 	unsigned long ftime;
 };
 
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 5b2bce5..c198df9 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -375,7 +375,7 @@ qlcnic_send_cmd_descs(struct qlcnic_adapter *adapter,
 
 static int
 qlcnic_sre_macaddr_change(struct qlcnic_adapter *adapter, u8 *addr,
-				unsigned op)
+				u16 vlan_id, unsigned op)
 {
 	struct qlcnic_nic_req req;
 	struct qlcnic_mac_req *mac_req;
@@ -391,6 +391,8 @@ qlcnic_sre_macaddr_change(struct qlcnic_adapter *adapter, u8 *addr,
 	mac_req->op = op;
 	memcpy(mac_req->mac_addr, addr, 6);
 
+	req.words[1] = cpu_to_le64(vlan_id);
+
 	return qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
 }
 
@@ -415,7 +417,7 @@ static int qlcnic_nic_add_mac(struct qlcnic_adapter *adapter, u8 *addr)
 	memcpy(cur->mac_addr, addr, ETH_ALEN);
 
 	if (qlcnic_sre_macaddr_change(adapter,
-				cur->mac_addr, QLCNIC_MAC_ADD)) {
+				cur->mac_addr, 0, QLCNIC_MAC_ADD)) {
 		kfree(cur);
 		return -EIO;
 	}
@@ -485,7 +487,7 @@ void qlcnic_free_mac_list(struct qlcnic_adapter *adapter)
 	while (!list_empty(head)) {
 		cur = list_entry(head->next, struct qlcnic_mac_list_s, list);
 		qlcnic_sre_macaddr_change(adapter,
-				cur->mac_addr, QLCNIC_MAC_DEL);
+				cur->mac_addr, 0, QLCNIC_MAC_DEL);
 		list_del(&cur->list);
 		kfree(cur);
 	}
@@ -506,7 +508,9 @@ void qlcnic_prune_lb_filters(struct qlcnic_adapter *adapter)
 			if (jiffies >
 				(QLCNIC_FILTER_AGE * HZ + tmp_fil->ftime)) {
 				qlcnic_sre_macaddr_change(adapter,
-					tmp_fil->faddr, QLCNIC_MAC_DEL);
+					tmp_fil->faddr, tmp_fil->vlan_id,
+					tmp_fil->vlan_id ? QLCNIC_MAC_VLAN_DEL :
+					QLCNIC_MAC_DEL);
 				spin_lock_bh(&adapter->mac_learn_lock);
 				adapter->fhash.fnum--;
 				hlist_del(&tmp_fil->fnode);
@@ -528,8 +532,9 @@ void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter)
 		head = &(adapter->fhash.fhead[i]);
 
 		hlist_for_each_entry_safe(tmp_fil, tmp_hnode, n, head, fnode) {
-			qlcnic_sre_macaddr_change(adapter,
-					tmp_fil->faddr, QLCNIC_MAC_DEL);
+			qlcnic_sre_macaddr_change(adapter, tmp_fil->faddr,
+				tmp_fil->vlan_id, tmp_fil->vlan_id ?
+				QLCNIC_MAC_VLAN_DEL :  QLCNIC_MAC_DEL);
 			spin_lock_bh(&adapter->mac_learn_lock);
 			adapter->fhash.fnum--;
 			hlist_del(&tmp_fil->fnode);
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 0fbfb53..5a6445a 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1826,7 +1826,7 @@ static void qlcnic_free_lb_filters_mem(struct qlcnic_adapter *adapter)
 }
 
 static void qlcnic_change_filter(struct qlcnic_adapter *adapter,
-		u64 uaddr, struct qlcnic_host_tx_ring *tx_ring)
+		u64 uaddr, u16 vlan_id, struct qlcnic_host_tx_ring *tx_ring)
 {
 	struct cmd_desc_type0 *hwdesc;
 	struct qlcnic_nic_req *req;
@@ -1845,9 +1845,11 @@ static void qlcnic_change_filter(struct qlcnic_adapter *adapter,
 	req->req_hdr = cpu_to_le64(word);
 
 	mac_req = (struct qlcnic_mac_req *)&(req->words[0]);
-	mac_req->op = QLCNIC_MAC_ADD;
+	mac_req->op = vlan_id ? QLCNIC_MAC_VLAN_ADD : QLCNIC_MAC_ADD;
 	memcpy(mac_req->mac_addr, &uaddr, ETH_ALEN);
 
+	req->words[1] = cpu_to_le64(vlan_id);
+
 	tx_ring->producer = get_next_index(producer, tx_ring->num_desc);
 }
 
@@ -1865,6 +1867,7 @@ qlcnic_send_filter(struct qlcnic_adapter *adapter,
 	struct hlist_node *tmp_hnode, *n;
 	struct hlist_head *head;
 	u64 src_addr = 0;
+	u16 vlan_id = 0;
 	u8 hindex;
 
 	if (!compare_ether_addr(phdr->h_source, adapter->mac_addr))
@@ -1873,12 +1876,16 @@ qlcnic_send_filter(struct qlcnic_adapter *adapter,
 	if (adapter->fhash.fnum >= adapter->fhash.fmax)
 		return;
 
+	/* Only NPAR capable devices support vlan based learning*/
+	if (adapter->flags & QLCNIC_ESWITCH_ENABLED)
+		vlan_id = first_desc->vlan_TCI;
 	memcpy(&src_addr, phdr->h_source, ETH_ALEN);
 	hindex = QLCNIC_MAC_HASH(src_addr) & (QLCNIC_LB_MAX_FILTERS - 1);
 	head = &(adapter->fhash.fhead[hindex]);
 
 	hlist_for_each_entry_safe(tmp_fil, tmp_hnode, n, head, fnode) {
-		if (!memcmp(tmp_fil->faddr, &src_addr, ETH_ALEN)) {
+		if (!memcmp(tmp_fil->faddr, &src_addr, ETH_ALEN) &&
+			    tmp_fil->vlan_id == vlan_id) {
 			tmp_fil->ftime = jiffies;
 			return;
 		}
@@ -1888,9 +1895,10 @@ qlcnic_send_filter(struct qlcnic_adapter *adapter,
 	if (!fil)
 		return;
 
-	qlcnic_change_filter(adapter, src_addr, tx_ring);
+	qlcnic_change_filter(adapter, src_addr, vlan_id, tx_ring);
 
 	fil->ftime = jiffies;
+	fil->vlan_id = vlan_id;
 	memcpy(fil->faddr, &src_addr, ETH_ALEN);
 	spin_lock(&adapter->mac_learn_lock);
 	hlist_add_head(&(fil->fnode), head);
-- 
1.6.0.2

