From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 13/20] net: qlcnic: slight optimization of addr
 compare
Date: Sat, 28 Dec 2013 14:17:57 +0800
Message-ID: <52BE6D15.5000101@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Himanshu Madhani <himanshu.madhani@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:25078 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755264Ab3L1GSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 01:18:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the possibly more efficient ether_addr_equal or
ether_addr_equal_unaligned to instead of memcmp.

Cc: Himanshu Madhani <himanshu.madhani@qlogic.com>
Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c   | 4 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c   | 4 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 3fe971c..a9a149b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -462,7 +462,7 @@ int qlcnic_nic_del_mac(struct qlcnic_adapter *adapter, const u8 *addr)
 	/* Delete MAC from the existing list */
 	list_for_each(head, &adapter->mac_list) {
 		cur = list_entry(head, struct qlcnic_mac_vlan_list, list);
-		if (memcmp(addr, cur->mac_addr, ETH_ALEN) == 0) {
+		if (ether_addr_equal(addr, cur->mac_addr)) {
 			err = qlcnic_sre_macaddr_change(adapter, cur->mac_addr,
 							0, QLCNIC_MAC_DEL);
 			if (err)
@@ -483,7 +483,7 @@ int qlcnic_nic_add_mac(struct qlcnic_adapter *adapter, const u8 *addr, u16 vlan)
 	/* look up if already exists */
 	list_for_each(head, &adapter->mac_list) {
 		cur = list_entry(head, struct qlcnic_mac_vlan_list, list);
-		if (memcmp(addr, cur->mac_addr, ETH_ALEN) == 0 &&
+		if (ether_addr_equal(addr, cur->mac_addr) &&
 		    cur->vlan_id == vlan)
 			return 0;
 	}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 0538022..a215e0f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -202,7 +202,7 @@ static struct qlcnic_filter *qlcnic_find_mac_filter(struct hlist_head *head,
 	struct hlist_node *n;
 
 	hlist_for_each_entry_safe(tmp_fil, n, head, fnode) {
-		if (!memcmp(tmp_fil->faddr, addr, ETH_ALEN) &&
+		if (ether_addr_equal(tmp_fil->faddr, addr) &&
 		    tmp_fil->vlan_id == vlan_id)
 			return tmp_fil;
 	}
@@ -346,7 +346,7 @@ static void qlcnic_send_filter(struct qlcnic_adapter *adapter,
 	head = &(adapter->fhash.fhead[hindex]);
 
 	hlist_for_each_entry_safe(tmp_fil, n, head, fnode) {
-		if (!memcmp(tmp_fil->faddr, &src_addr, ETH_ALEN) &&
+		if (ether_addr_equal(tmp_fil->faddr, &src_addr) &&
 		    tmp_fil->vlan_id == vlan_id) {
 			if (jiffies > (QLCNIC_READD_AGE * HZ + tmp_fil->ftime))
 				qlcnic_change_filter(adapter, &src_addr,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index bf132c9..d131ec1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -313,7 +313,7 @@ static void qlcnic_delete_adapter_mac(struct qlcnic_adapter *adapter)
 
 	list_for_each(head, &adapter->mac_list) {
 		cur = list_entry(head, struct qlcnic_mac_vlan_list, list);
-		if (!memcmp(adapter->mac_addr, cur->mac_addr, ETH_ALEN)) {
+		if (ether_addr_equal_unaligned(adapter->mac_addr, cur->mac_addr)) {
 			qlcnic_sre_macaddr_change(adapter, cur->mac_addr,
 						  0, QLCNIC_MAC_DEL);
 			list_del(&cur->list);
@@ -337,7 +337,7 @@ static int qlcnic_set_mac(struct net_device *netdev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EINVAL;
 
-	if (!memcmp(adapter->mac_addr, addr->sa_data, ETH_ALEN))
+	if (ether_addr_equal_unaligned(adapter->mac_addr, addr->sa_data))
 		return 0;
 
 	if (test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
-- 
1.8.0
