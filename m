From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 2/8] qlcnic: Fix ingress MAC learning
Date: Fri, 2 Aug 2013 23:15:55 -0400
Message-ID: <1375499761-21141-3-git-send-email-shahed.shaikh@qlogic.com>
References: <1375499761-21141-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:59068 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754712Ab3HCDy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 23:54:29 -0400
In-Reply-To: <1375499761-21141-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

o Delete MAC address from the adapter's filter table
  if the source MAC address of ingress packet matches.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c |   99 ++++++++++++++++--------
 1 files changed, 66 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 82a03d3..6946d35 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -161,36 +161,68 @@ static inline int qlcnic_82xx_is_lb_pkt(u64 sts_data)
 	return (qlcnic_get_sts_status(sts_data) == STATUS_CKSUM_LOOP) ? 1 : 0;
 }
 
+static void qlcnic_delete_rx_list_mac(struct qlcnic_adapter *adapter,
+				      struct qlcnic_filter *fil,
+				      void *addr, u16 vlan_id)
+{
+	int ret;
+	u8 op;
+
+	op = vlan_id ? QLCNIC_MAC_VLAN_ADD : QLCNIC_MAC_ADD;
+	ret = qlcnic_sre_macaddr_change(adapter, addr, vlan_id, op);
+	if (ret)
+		return;
+
+	op = vlan_id ? QLCNIC_MAC_VLAN_DEL : QLCNIC_MAC_DEL;
+	ret = qlcnic_sre_macaddr_change(adapter, addr, vlan_id, op);
+	if (!ret) {
+		hlist_del(&fil->fnode);
+		adapter->rx_fhash.fnum--;
+	}
+}
+
+static struct qlcnic_filter *qlcnic_find_mac_filter(struct hlist_head *head,
+						    void *addr, u16 vlan_id)
+{
+	struct qlcnic_filter *tmp_fil = NULL;
+	struct hlist_node *n;
+
+	hlist_for_each_entry_safe(tmp_fil, n, head, fnode) {
+		if (!memcmp(tmp_fil->faddr, addr, ETH_ALEN) &&
+		    tmp_fil->vlan_id == vlan_id)
+			return tmp_fil;
+	}
+
+	return NULL;
+}
+
 void qlcnic_add_lb_filter(struct qlcnic_adapter *adapter, struct sk_buff *skb,
 			  int loopback_pkt, u16 vlan_id)
 {
 	struct ethhdr *phdr = (struct ethhdr *)(skb->data);
 	struct qlcnic_filter *fil, *tmp_fil;
-	struct hlist_node *n;
 	struct hlist_head *head;
 	unsigned long time;
 	u64 src_addr = 0;
-	u8 hindex, found = 0, op;
+	u8 hindex, op;
 	int ret;
 
 	memcpy(&src_addr, phdr->h_source, ETH_ALEN);
+	hindex = qlcnic_mac_hash(src_addr) &
+		 (adapter->fhash.fbucket_size - 1);
 
 	if (loopback_pkt) {
 		if (adapter->rx_fhash.fnum >= adapter->rx_fhash.fmax)
 			return;
 
-		hindex = qlcnic_mac_hash(src_addr) &
-			 (adapter->fhash.fbucket_size - 1);
 		head = &(adapter->rx_fhash.fhead[hindex]);
 
-		hlist_for_each_entry_safe(tmp_fil, n, head, fnode) {
-			if (!memcmp(tmp_fil->faddr, &src_addr, ETH_ALEN) &&
-			    tmp_fil->vlan_id == vlan_id) {
-				time = tmp_fil->ftime;
-				if (jiffies > (QLCNIC_READD_AGE * HZ + time))
-					tmp_fil->ftime = jiffies;
-				return;
-			}
+		tmp_fil = qlcnic_find_mac_filter(head, &src_addr, vlan_id);
+		if (tmp_fil) {
+			time = tmp_fil->ftime;
+			if (time_after(jiffies, QLCNIC_READD_AGE * HZ + time))
+				tmp_fil->ftime = jiffies;
+			return;
 		}
 
 		fil = kzalloc(sizeof(struct qlcnic_filter), GFP_ATOMIC);
@@ -205,36 +237,37 @@ void qlcnic_add_lb_filter(struct qlcnic_adapter *adapter, struct sk_buff *skb,
 		adapter->rx_fhash.fnum++;
 		spin_unlock(&adapter->rx_mac_learn_lock);
 	} else {
-		hindex = qlcnic_mac_hash(src_addr) &
-			 (adapter->fhash.fbucket_size - 1);
-		head = &(adapter->rx_fhash.fhead[hindex]);
-		spin_lock(&adapter->rx_mac_learn_lock);
-		hlist_for_each_entry_safe(tmp_fil, n, head, fnode) {
-			if (!memcmp(tmp_fil->faddr, &src_addr, ETH_ALEN) &&
-			    tmp_fil->vlan_id == vlan_id) {
-				found = 1;
-				break;
-			}
-		}
+		head = &adapter->fhash.fhead[hindex];
 
-		if (!found) {
-			spin_unlock(&adapter->rx_mac_learn_lock);
-			return;
-		}
+		spin_lock(&adapter->mac_learn_lock);
 
-		op = vlan_id ? QLCNIC_MAC_VLAN_ADD : QLCNIC_MAC_ADD;
-		ret = qlcnic_sre_macaddr_change(adapter, (u8 *)&src_addr,
-						vlan_id, op);
-		if (!ret) {
+		tmp_fil = qlcnic_find_mac_filter(head, &src_addr, vlan_id);
+		if (tmp_fil) {
 			op = vlan_id ? QLCNIC_MAC_VLAN_DEL : QLCNIC_MAC_DEL;
 			ret = qlcnic_sre_macaddr_change(adapter,
 							(u8 *)&src_addr,
 							vlan_id, op);
 			if (!ret) {
-				hlist_del(&(tmp_fil->fnode));
-				adapter->rx_fhash.fnum--;
+				hlist_del(&tmp_fil->fnode);
+				adapter->fhash.fnum--;
 			}
+
+			spin_unlock(&adapter->mac_learn_lock);
+
+			return;
 		}
+
+		spin_unlock(&adapter->mac_learn_lock);
+
+		head = &adapter->rx_fhash.fhead[hindex];
+
+		spin_lock(&adapter->rx_mac_learn_lock);
+
+		tmp_fil = qlcnic_find_mac_filter(head, &src_addr, vlan_id);
+		if (tmp_fil)
+			qlcnic_delete_rx_list_mac(adapter, tmp_fil, &src_addr,
+						  vlan_id);
+
 		spin_unlock(&adapter->rx_mac_learn_lock);
 	}
 }
-- 
1.5.6
