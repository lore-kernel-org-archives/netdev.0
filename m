From: kxie@chelsio.com
Subject: [PATCH v2 1/2 net-next-2.6] cxgb3: added private MAC address and
 provisioning packet handler for iSCSI
Date: Fri, 25 Sep 2009 15:25:36 -0700
Message-ID: <200909252225.n8PMPas1031750@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: swise@opengridcomputing.com, divy@chelsio.com, rakesh@chelsio.com,
	kxie@chelsio.com, linux-scsi@vger.kernel.org,
	open-iscsi@googlegroups.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: michaelc@cs.wisc.edu, James.Bottomley@HansenPartnership.com,
	davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752931AbZIYWSv@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH v2 1/2 net-next-2.6] cxgb3: Added private MAC address and provisioning packet handler for iSCSI

This patch added support of private MAC address per port and provisioning
packet handler for iSCSI traffic only.

This patch is generated against net-next-2.6.

Acked-by: Karen Xie <kxie@chelsio.com>
Acked-by: Divy Le Ray <divy@chelsio.com>
Signed-off-by: Rakesh Ranjan <rranjan@chelsio.com>
---
 drivers/net/cxgb3/adapter.h       |   18 +++++++++++++++++-
 drivers/net/cxgb3/cxgb3_main.c    |   22 ++++++++++++++++++----
 drivers/net/cxgb3/cxgb3_offload.c |    2 +-
 drivers/net/cxgb3/sge.c           |   30 ++++++++++++++++++++----------
 4 files changed, 56 insertions(+), 16 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 2b1aea6..3f3083a 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -48,12 +48,28 @@
 struct vlan_group;
 struct adapter;
 struct sge_qset;
+struct port_info;
 
 enum {			/* rx_offload flags */
 	T3_RX_CSUM	= 1 << 0,
 	T3_LRO		= 1 << 1,
 };
 
+enum {
+	LAN_MAC_IDX	= 0,
+	SAN_MAC_IDX,
+
+	MAX_MAC_IDX
+};
+
+struct iscsi_config {
+	__be32	ipv4_addr;
+	__u8	mac_addr[ETH_ALEN];
+	__u32	flags;
+	int (*send)(struct port_info *pi, struct sk_buff **skb);
+	int (*recv)(struct port_info *pi, struct sk_buff *skb);
+};
+
 struct port_info {
 	struct adapter *adapter;
 	struct vlan_group *vlan_grp;
@@ -67,7 +83,7 @@ struct port_info {
 	struct link_config link_config;
 	struct net_device_stats netstats;
 	int activity;
-	__be32 iscsi_ipv4addr;
+	struct iscsi_config iscsic;
 
 	int link_fault; /* link fault was detected */
 };
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 34e776c..c9113d3 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -344,8 +344,10 @@ static void link_start(struct net_device *dev)
 
 	init_rx_mode(&rm, dev, dev->mc_list);
 	t3_mac_reset(mac);
+	t3_mac_set_num_ucast(mac, MAX_MAC_IDX);
 	t3_mac_set_mtu(mac, dev->mtu);
-	t3_mac_set_address(mac, 0, dev->dev_addr);
+	t3_mac_set_address(mac, LAN_MAC_IDX, dev->dev_addr);
+	t3_mac_set_address(mac, SAN_MAC_IDX, pi->iscsic.mac_addr);
 	t3_mac_set_rx_mode(mac, &rm);
 	t3_link_start(&pi->phy, mac, &pi->link_config);
 	t3_mac_enable(mac, MAC_DIRECTION_RX | MAC_DIRECTION_TX);
@@ -903,6 +905,7 @@ static inline int offload_tx(struct t3cdev *tdev, struct sk_buff *skb)
 static int write_smt_entry(struct adapter *adapter, int idx)
 {
 	struct cpl_smt_write_req *req;
+	struct port_info *pi = netdev_priv(adapter->port[idx]);
 	struct sk_buff *skb = alloc_skb(sizeof(*req), GFP_KERNEL);
 
 	if (!skb)
@@ -913,8 +916,8 @@ static int write_smt_entry(struct adapter *adapter, int idx)
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_SMT_WRITE_REQ, idx));
 	req->mtu_idx = NMTUS - 1;	/* should be 0 but there's a T3 bug */
 	req->iff = idx;
-	memset(req->src_mac1, 0, sizeof(req->src_mac1));
 	memcpy(req->src_mac0, adapter->port[idx]->dev_addr, ETH_ALEN);
+	memcpy(req->src_mac1, pi->iscsic.mac_addr, ETH_ALEN);
 	skb->priority = 1;
 	offload_tx(&adapter->tdev, skb);
 	return 0;
@@ -2516,7 +2519,7 @@ static int cxgb_set_mac_addr(struct net_device *dev, void *p)
 		return -EINVAL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
-	t3_mac_set_address(&pi->mac, 0, dev->dev_addr);
+	t3_mac_set_address(&pi->mac, LAN_MAC_IDX, dev->dev_addr);
 	if (offload_running(adapter))
 		write_smt_entry(adapter, pi->port_id);
 	return 0;
@@ -2654,7 +2657,7 @@ static void check_t3b2_mac(struct adapter *adapter)
 			struct cmac *mac = &p->mac;
 
 			t3_mac_set_mtu(mac, dev->mtu);
-			t3_mac_set_address(mac, 0, dev->dev_addr);
+			t3_mac_set_address(mac, LAN_MAC_IDX, dev->dev_addr);
 			cxgb_set_rxmode(dev);
 			t3_link_start(&p->phy, mac, &p->link_config);
 			t3_mac_enable(mac, MAC_DIRECTION_RX | MAC_DIRECTION_TX);
@@ -3112,6 +3115,14 @@ static const struct net_device_ops cxgb_netdev_ops = {
 #endif
 };
 
+static void __devinit cxgb3_init_iscsi_mac(struct net_device *dev)
+{
+	struct port_info *pi = netdev_priv(dev);
+
+	memcpy(pi->iscsic.mac_addr, dev->dev_addr, ETH_ALEN);
+	pi->iscsic.mac_addr[3] |= 0x80;
+}
+
 static int __devinit init_one(struct pci_dev *pdev,
 			      const struct pci_device_id *ent)
 {
@@ -3270,6 +3281,9 @@ static int __devinit init_one(struct pci_dev *pdev,
 		goto out_free_dev;
 	}
 
+	for_each_port(adapter, i)
+		cxgb3_init_iscsi_mac(adapter->port[i]);
+
 	/* Driver's ready. Reflect it on LEDs */
 	t3_led_ready(adapter);
 
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index 75064ee..7f314c3 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -447,7 +447,7 @@ static int cxgb_offload_ctl(struct t3cdev *tdev, unsigned int req, void *data)
 	case GET_ISCSI_IPV4ADDR: {
 		struct iscsi_ipv4addr *p = data;
 		struct port_info *pi = netdev_priv(p->dev);
-		p->ipv4addr = pi->iscsi_ipv4addr;
+		p->ipv4addr = pi->iscsic.ipv4_addr;
 		break;
 	}
 	case GET_EMBEDDED_INFO: {
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index f866128..a911363 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1946,10 +1946,9 @@ static void restart_tx(struct sge_qset *qs)
  *	Check if the ARP request is probing the private IP address
  *	dedicated to iSCSI, generate an ARP reply if so.
  */
-static void cxgb3_arp_process(struct adapter *adapter, struct sk_buff *skb)
+static void cxgb3_arp_process(struct port_info *pi, struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
-	struct port_info *pi;
 	struct arphdr *arp;
 	unsigned char *arp_ptr;
 	unsigned char *sha;
@@ -1972,12 +1971,11 @@ static void cxgb3_arp_process(struct adapter *adapter, struct sk_buff *skb)
 	arp_ptr += dev->addr_len;
 	memcpy(&tip, arp_ptr, sizeof(tip));
 
-	pi = netdev_priv(dev);
-	if (tip != pi->iscsi_ipv4addr)
+	if (tip != pi->iscsic.ipv4_addr)
 		return;
 
 	arp_send(ARPOP_REPLY, ETH_P_ARP, sip, dev, tip, sha,
-		 dev->dev_addr, sha);
+		 pi->iscsic.mac_addr, sha);
 
 }
 
@@ -1986,6 +1984,19 @@ static inline int is_arp(struct sk_buff *skb)
 	return skb->protocol == htons(ETH_P_ARP);
 }
 
+static void cxgb3_process_iscsi_prov_pack(struct port_info *pi,
+					struct sk_buff *skb)
+{
+	if (is_arp(skb)) {
+		cxgb3_arp_process(pi, skb);
+		return;
+	}
+
+	if (pi->iscsic.recv)
+		pi->iscsic.recv(pi, skb);
+
+}
+
 /**
  *	rx_eth - process an ingress ethernet packet
  *	@adap: the adapter
@@ -2024,13 +2035,12 @@ static void rx_eth(struct adapter *adap, struct sge_rspq *rq,
 				vlan_gro_receive(&qs->napi, grp,
 						 ntohs(p->vlan), skb);
 			else {
-				if (unlikely(pi->iscsi_ipv4addr &&
-				    is_arp(skb))) {
+				if (unlikely(pi->iscsic.flags)) {
 					unsigned short vtag = ntohs(p->vlan) &
 								VLAN_VID_MASK;
 					skb->dev = vlan_group_get_device(grp,
 									 vtag);
-					cxgb3_arp_process(adap, skb);
+					cxgb3_process_iscsi_prov_pack(pi, skb);
 				}
 				__vlan_hwaccel_rx(skb, grp, ntohs(p->vlan),
 					  	  rq->polling);
@@ -2041,8 +2051,8 @@ static void rx_eth(struct adapter *adap, struct sge_rspq *rq,
 		if (lro)
 			napi_gro_receive(&qs->napi, skb);
 		else {
-			if (unlikely(pi->iscsi_ipv4addr && is_arp(skb)))
-				cxgb3_arp_process(adap, skb);
+			if (unlikely(pi->iscsic.flags))
+				cxgb3_process_iscsi_prov_pack(pi, skb);
 			netif_receive_skb(skb);
 		}
 	} else
-- 
1.6.0.6
