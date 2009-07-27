From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 10/12] netxen: add vlan tx acceleration support
Date: Sun, 26 Jul 2009 23:07:45 -0700
Message-ID: <1248674867-18821-11-git-send-email-dhananjay@netxen.com>
References: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org, Amit Kumar Salecha <amit@netxen.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:33579 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751429AbZG0GHs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2009 02:07:48 -0400
In-Reply-To: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable vlan tx acceleration for NX3031 if firmware advertises
capability.

Signed-off-by: Amit Kumar Salecha <amit@netxen.com>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |   11 ++++++-
 drivers/net/netxen/netxen_nic_main.c |   52 ++++++++++++++++++++++++++++++---
 2 files changed, 57 insertions(+), 6 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index e7702f6..d01cc09 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -304,6 +304,10 @@ struct netxen_ring_ctx {
 #define FLAGS_IPSEC_SA_ADD	0x04
 #define FLAGS_IPSEC_SA_DELETE	0x08
 #define FLAGS_VLAN_TAGGED	0x10
+#define FLAGS_VLAN_OOB		0x40
+
+#define netxen_set_tx_vlan_tci(cmd_desc, v)	\
+	(cmd_desc)->vlan_TCI = cpu_to_le16(v);
 
 #define netxen_set_cmd_desc_port(cmd_desc, var)	\
 	((cmd_desc)->port_ctxid |= ((var) & 0x0F))
@@ -342,7 +346,9 @@ struct cmd_desc_type0 {
 
 	__le64 addr_buffer4;
 
-	__le64 unused;
+	__le16 vlan_TCI;
+	__le16 reserved;
+	__le32 reserved2;
 
 } __attribute__ ((aligned(64)));
 
@@ -1111,6 +1117,9 @@ typedef struct {
 
 #define NX_FW_CAPABILITY_LINK_NOTIFICATION	(1 << 5)
 #define NX_FW_CAPABILITY_SWITCHING		(1 << 6)
+#define NX_FW_CAPABILITY_PEXQ			(1 << 7)
+#define NX_FW_CAPABILITY_BDG			(1 << 8)
+#define NX_FW_CAPABILITY_FVLANTX		(1 << 9)
 
 /* module types */
 #define LINKEVENT_MODULE_NOT_PRESENT			1
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 8a4e6ce..41ab99d 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1036,6 +1036,9 @@ netxen_setup_netdev(struct netxen_adapter *adapter,
 		netdev->vlan_features |= NETIF_F_HIGHDMA;
 	}
 
+	if (adapter->capabilities & NX_FW_CAPABILITY_FVLANTX)
+		netdev->features |= (NETIF_F_HW_VLAN_TX);
+
 	netdev->irq = adapter->msix_entries[0].vector;
 
 	err = netxen_napi_add(adapter, netdev);
@@ -1353,15 +1356,24 @@ netxen_tso_check(struct net_device *netdev,
 {
 	u8 opcode = TX_ETHER_PKT;
 	__be16 protocol = skb->protocol;
-	u16 flags = 0;
+	u16 flags = 0, vid = 0;
 	u32 producer;
-	int copied, offset, copy_len, hdr_len = 0, tso = 0;
+	int copied, offset, copy_len, hdr_len = 0, tso = 0, vlan_oob = 0;
 	struct cmd_desc_type0 *hwdesc;
+	struct vlan_ethhdr *vh;
 
 	if (protocol == cpu_to_be16(ETH_P_8021Q)) {
-		struct vlan_ethhdr *vh = (struct vlan_ethhdr *)skb->data;
+
+		vh = (struct vlan_ethhdr *)skb->data;
 		protocol = vh->h_vlan_encapsulated_proto;
 		flags = FLAGS_VLAN_TAGGED;
+
+	} else if (vlan_tx_tag_present(skb)) {
+
+		flags = FLAGS_VLAN_OOB;
+		vid = vlan_tx_tag_get(skb);
+		netxen_set_tx_vlan_tci(first_desc, vid);
+		vlan_oob = 1;
 	}
 
 	if ((netdev->features & (NETIF_F_TSO | NETIF_F_TSO6)) &&
@@ -1371,6 +1383,13 @@ netxen_tso_check(struct net_device *netdev,
 
 		first_desc->mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
 		first_desc->total_hdr_length = hdr_len;
+		if (vlan_oob) {
+			first_desc->total_hdr_length += VLAN_HLEN;
+			first_desc->tcp_hdr_offset = VLAN_HLEN;
+			first_desc->ip_hdr_offset = VLAN_HLEN;
+			/* Only in case of TSO on vlan device */
+			flags |= FLAGS_VLAN_TAGGED;
+		}
 
 		opcode = (protocol == cpu_to_be16(ETH_P_IPV6)) ?
 				TX_TCP_LSO6 : TX_TCP_LSO;
@@ -1395,8 +1414,9 @@ netxen_tso_check(struct net_device *netdev,
 				opcode = TX_UDPV6_PKT;
 		}
 	}
-	first_desc->tcp_hdr_offset = skb_transport_offset(skb);
-	first_desc->ip_hdr_offset = skb_network_offset(skb);
+
+	first_desc->tcp_hdr_offset += skb_transport_offset(skb);
+	first_desc->ip_hdr_offset += skb_network_offset(skb);
 	netxen_set_tx_flags_opcode(first_desc, flags, opcode);
 
 	if (!tso)
@@ -1409,6 +1429,28 @@ netxen_tso_check(struct net_device *netdev,
 	copied = 0;
 	offset = 2;
 
+	if (vlan_oob) {
+		/* Create a TSO vlan header template for firmware */
+
+		hwdesc = &tx_ring->desc_head[producer];
+		tx_ring->cmd_buf_arr[producer].skb = NULL;
+
+		copy_len = min((int)sizeof(struct cmd_desc_type0) - offset,
+				hdr_len + VLAN_HLEN);
+
+		vh = (struct vlan_ethhdr *)((char *)hwdesc + 2);
+		skb_copy_from_linear_data(skb, vh, 12);
+		vh->h_vlan_proto = htons(ETH_P_8021Q);
+		vh->h_vlan_TCI = htons(vid);
+		skb_copy_from_linear_data_offset(skb, 12,
+				(char *)vh + 16, copy_len - 16);
+
+		copied = copy_len;
+		offset = 0;
+
+		producer = get_next_index(producer, tx_ring->num_desc);
+	}
+
 	while (copied < hdr_len) {
 
 		copy_len = min((int)sizeof(struct cmd_desc_type0) - offset,
-- 
1.6.0.2

