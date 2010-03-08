From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 3/6] qlcnic: fix multicast handling
Date: Mon,  8 Mar 2010 02:14:47 -0800
Message-ID: <1268043290-19929-4-git-send-email-amit.salecha@qlogic.com>
References: <1268043290-19929-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com,
	ameen.rahman@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:53092 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753123Ab0CHKOw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Mar 2010 05:14:52 -0500
In-Reply-To: <1268043290-19929-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

For promiscuous mode, driver send request to device for deleting
multicast addresses and again it send request for adding them back
while exiting from this mode, this is bad for performance.
Just setting device in promiscuous mode is enough, no need to del/add
multicast addresses.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_hw.c |   31 ++++++-------------------------
 1 files changed, 6 insertions(+), 25 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index e95646b..da00e16 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -398,20 +398,16 @@ qlcnic_sre_macaddr_change(struct qlcnic_adapter *adapter, u8 *addr,
 	return qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
 }
 
-static int qlcnic_nic_add_mac(struct qlcnic_adapter *adapter,
-		u8 *addr, struct list_head *del_list)
+static int qlcnic_nic_add_mac(struct qlcnic_adapter *adapter, u8 *addr)
 {
 	struct list_head *head;
 	struct qlcnic_mac_list_s *cur;
 
 	/* look up if already exists */
-	list_for_each(head, del_list) {
+	list_for_each(head, &adapter->mac_list) {
 		cur = list_entry(head, struct qlcnic_mac_list_s, list);
-
-		if (memcmp(addr, cur->mac_addr, ETH_ALEN) == 0) {
-			list_move_tail(head, &adapter->mac_list);
+		if (memcmp(addr, cur->mac_addr, ETH_ALEN) == 0)
 			return 0;
-		}
 	}
 
 	cur = kzalloc(sizeof(struct qlcnic_mac_list_s), GFP_ATOMIC);
@@ -433,14 +429,9 @@ void qlcnic_set_multi(struct net_device *netdev)
 	struct dev_mc_list *mc_ptr;
 	u8 bcast_addr[ETH_ALEN] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
 	u32 mode = VPORT_MISS_MODE_DROP;
-	LIST_HEAD(del_list);
-	struct list_head *head;
-	struct qlcnic_mac_list_s *cur;
 
-	list_splice_tail_init(&adapter->mac_list, &del_list);
-
-	qlcnic_nic_add_mac(adapter, adapter->mac_addr, &del_list);
-	qlcnic_nic_add_mac(adapter, bcast_addr, &del_list);
+	qlcnic_nic_add_mac(adapter, adapter->mac_addr);
+	qlcnic_nic_add_mac(adapter, bcast_addr);
 
 	if (netdev->flags & IFF_PROMISC) {
 		mode = VPORT_MISS_MODE_ACCEPT_ALL;
@@ -455,22 +446,12 @@ void qlcnic_set_multi(struct net_device *netdev)
 
 	if (!netdev_mc_empty(netdev)) {
 		netdev_for_each_mc_addr(mc_ptr, netdev) {
-			qlcnic_nic_add_mac(adapter, mc_ptr->dmi_addr,
-							&del_list);
+			qlcnic_nic_add_mac(adapter, mc_ptr->dmi_addr);
 		}
 	}
 
 send_fw_cmd:
 	qlcnic_nic_set_promisc(adapter, mode);
-	head = &del_list;
-	while (!list_empty(head)) {
-		cur = list_entry(head->next, struct qlcnic_mac_list_s, list);
-
-		qlcnic_sre_macaddr_change(adapter,
-				cur->mac_addr, QLCNIC_MAC_DEL);
-		list_del(&cur->list);
-		kfree(cur);
-	}
 }
 
 int qlcnic_nic_set_promisc(struct qlcnic_adapter *adapter, u32 mode)
-- 
1.6.0.2

