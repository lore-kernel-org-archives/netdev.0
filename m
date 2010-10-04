From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 5/8] qlcnic: fix vlan TSO on big endian machine
Date: Mon,  4 Oct 2010 07:20:13 -0700
Message-ID: <1286202016-18026-6-git-send-email-amit.salecha@qlogic.com>
References: <1286202016-18026-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:48319 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754258Ab0JDOUS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Oct 2010 10:20:18 -0400
In-Reply-To: <1286202016-18026-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

o desc->vlan_tci is in __le16 format. Doing htons and
  cpu_to_le64 again on vlan_tci, result in invalid value on ppc.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    7 ++++++-
 drivers/net/qlcnic/qlcnic_hw.c   |    6 ++++--
 drivers/net/qlcnic/qlcnic_main.c |   15 ++++++++++-----
 3 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 7af3c6c..9d80171 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -898,6 +898,11 @@ struct qlcnic_mac_req {
 	u8 mac_addr[6];
 };
 
+struct qlcnic_vlan_req {
+	__le16 vlan_id;
+	__le16 rsvd[3];
+};
+
 struct qlcnic_ipaddr {
 	__be32 ipv4;
 	__be32 ipv6[4];
@@ -940,7 +945,7 @@ struct qlcnic_ipaddr {
 struct qlcnic_filter {
 	struct hlist_node fnode;
 	u8 faddr[ETH_ALEN];
-	u16 vlan_id;
+	__le16 vlan_id;
 	unsigned long ftime;
 };
 
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 68d5693..712cfab 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -375,10 +375,11 @@ qlcnic_send_cmd_descs(struct qlcnic_adapter *adapter,
 
 static int
 qlcnic_sre_macaddr_change(struct qlcnic_adapter *adapter, u8 *addr,
-				u16 vlan_id, unsigned op)
+				__le16 vlan_id, unsigned op)
 {
 	struct qlcnic_nic_req req;
 	struct qlcnic_mac_req *mac_req;
+	struct qlcnic_vlan_req *vlan_req;
 	u64 word;
 
 	memset(&req, 0, sizeof(struct qlcnic_nic_req));
@@ -391,7 +392,8 @@ qlcnic_sre_macaddr_change(struct qlcnic_adapter *adapter, u8 *addr,
 	mac_req->op = op;
 	memcpy(mac_req->mac_addr, addr, 6);
 
-	req.words[1] = cpu_to_le64(vlan_id);
+	vlan_req = (struct qlcnic_vlan_req *)&req.words[1];
+	vlan_req->vlan_id = vlan_id;
 
 	return qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
 }
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index a3d7705..6001f41 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -28,6 +28,7 @@
 
 #include "qlcnic.h"
 
+#include <linux/swab.h>
 #include <linux/dma-mapping.h>
 #include <linux/if_vlan.h>
 #include <net/ip.h>
@@ -1834,11 +1835,12 @@ static void qlcnic_free_lb_filters_mem(struct qlcnic_adapter *adapter)
 }
 
 static void qlcnic_change_filter(struct qlcnic_adapter *adapter,
-		u64 uaddr, u16 vlan_id, struct qlcnic_host_tx_ring *tx_ring)
+		u64 uaddr, __le16 vlan_id, struct qlcnic_host_tx_ring *tx_ring)
 {
 	struct cmd_desc_type0 *hwdesc;
 	struct qlcnic_nic_req *req;
 	struct qlcnic_mac_req *mac_req;
+	struct qlcnic_vlan_req *vlan_req;
 	u32 producer;
 	u64 word;
 
@@ -1856,7 +1858,8 @@ static void qlcnic_change_filter(struct qlcnic_adapter *adapter,
 	mac_req->op = vlan_id ? QLCNIC_MAC_VLAN_ADD : QLCNIC_MAC_ADD;
 	memcpy(mac_req->mac_addr, &uaddr, ETH_ALEN);
 
-	req->words[1] = cpu_to_le64(vlan_id);
+	vlan_req = (struct qlcnic_vlan_req *)&req->words[1];
+	vlan_req->vlan_id = vlan_id;
 
 	tx_ring->producer = get_next_index(producer, tx_ring->num_desc);
 }
@@ -1875,7 +1878,7 @@ qlcnic_send_filter(struct qlcnic_adapter *adapter,
 	struct hlist_node *tmp_hnode, *n;
 	struct hlist_head *head;
 	u64 src_addr = 0;
-	u16 vlan_id = 0;
+	__le16 vlan_id = 0;
 	u8 hindex;
 
 	if (!compare_ether_addr(phdr->h_source, adapter->mac_addr))
@@ -1928,7 +1931,8 @@ qlcnic_tso_check(struct net_device *netdev,
 	struct vlan_ethhdr *vh;
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	u32 producer = tx_ring->producer;
-	int vlan_oob = first_desc->flags_opcode & cpu_to_le16(FLAGS_VLAN_OOB);
+	__le16 vlan_oob = first_desc->flags_opcode &
+				cpu_to_le16(FLAGS_VLAN_OOB);
 
 	if (*(skb->data) & BIT_0) {
 		flags |= BIT_0;
@@ -1999,7 +2003,8 @@ qlcnic_tso_check(struct net_device *netdev,
 		vh = (struct vlan_ethhdr *)((char *)hwdesc + 2);
 		skb_copy_from_linear_data(skb, vh, 12);
 		vh->h_vlan_proto = htons(ETH_P_8021Q);
-		vh->h_vlan_TCI = htons(first_desc->vlan_TCI);
+		vh->h_vlan_TCI = (__be16)swab16((u16)first_desc->vlan_TCI);
+
 		skb_copy_from_linear_data_offset(skb, 12,
 				(char *)vh + 16, copy_len - 16);
 
-- 
1.6.3.3

