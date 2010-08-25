From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 2/4] qlcnic: support port vlan id
Date: Wed, 25 Aug 2010 07:03:03 -0700
Message-ID: <1282744985-31540-3-git-send-email-amit.salecha@qlogic.com>
References: <1282744985-31540-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:63201 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753967Ab0HYODH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Aug 2010 10:03:07 -0400
In-Reply-To: <1282744985-31540-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On NIC Partition capable adapter, Administrator can configure to
tag packet with particular vlan id. Packet will be tagged and strip with
that vlan id. Also if 'Tagging' flag is disable, other packet will be drop.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    4 +-
 drivers/net/qlcnic/qlcnic_init.c |   39 ++++++++++++++++
 drivers/net/qlcnic/qlcnic_main.c |   89 +++++++++++++++++++++++++++++--------
 3 files changed, 111 insertions(+), 21 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 508d531..d15de63 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -175,7 +175,7 @@
 	((_desc)->port_ctxid = ((_port) & 0xf) | (((_port) << 4) & 0xf0))
 
 #define qlcnic_set_tx_flags_opcode(_desc, _flags, _opcode) \
-	((_desc)->flags_opcode = \
+	((_desc)->flags_opcode |= \
 	cpu_to_le16(((_flags) & 0x7f) | (((_opcode) & 0x3f) << 7)))
 
 #define qlcnic_set_tx_frags_len(_desc, _frags, _len) \
@@ -902,6 +902,7 @@ struct qlcnic_mac_req {
 #define QLCNIC_BRIDGE_ENABLED       	0X10
 #define QLCNIC_DIAG_ENABLED		0x20
 #define QLCNIC_ESWITCH_ENABLED		0x40
+#define QLCNIC_TAGGING_ENABLED		0x100
 #define QLCNIC_MACSPOOF			0x200
 #define QLCNIC_IS_MSI_FAMILY(adapter) \
 	((adapter)->flags & (QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED))
@@ -967,6 +968,7 @@ struct qlcnic_adapter {
 	u16 max_tx_ques;
 	u16 max_rx_ques;
 	u16 max_mtu;
+	u16 pvid;
 
 	u32 fw_hal_version;
 	u32 capabilities;
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index a174521..df91b75 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -25,6 +25,7 @@
 #include <linux/netdevice.h>
 #include <linux/delay.h>
 #include <linux/slab.h>
+#include <linux/if_vlan.h>
 #include "qlcnic.h"
 
 struct crb_addr_pair {
@@ -1302,6 +1303,27 @@ static struct sk_buff *qlcnic_process_rxbuf(struct qlcnic_adapter *adapter,
 	return skb;
 }
 
+static int
+qlcnic_check_rx_tagging(struct qlcnic_adapter *adapter, struct sk_buff *skb)
+{
+	u16 vlan_tag;
+	struct ethhdr *eth_hdr;
+
+	if (!__vlan_get_tag(skb, &vlan_tag)) {
+		if (vlan_tag == adapter->pvid) {
+			/* strip the tag from the packet and send it up */
+			eth_hdr = (struct ethhdr *) skb->data;
+			memmove(skb->data + VLAN_HLEN, eth_hdr, ETH_ALEN * 2);
+			skb_pull(skb, VLAN_HLEN);
+			return 0;
+		}
+	}
+	if (adapter->flags & QLCNIC_TAGGING_ENABLED)
+		return 0;
+
+	return -EIO;
+}
+
 static struct qlcnic_rx_buffer *
 qlcnic_process_rcv(struct qlcnic_adapter *adapter,
 		struct qlcnic_host_sds_ring *sds_ring,
@@ -1342,6 +1364,15 @@ qlcnic_process_rcv(struct qlcnic_adapter *adapter,
 		skb_pull(skb, pkt_offset);
 
 	skb->truesize = skb->len + sizeof(struct sk_buff);
+
+	if (unlikely(adapter->pvid)) {
+		if (qlcnic_check_rx_tagging(adapter, skb)) {
+			adapter->stats.rxdropped++;
+			dev_kfree_skb_any(skb);
+			return buffer;
+		}
+	}
+
 	skb->protocol = eth_type_trans(skb, netdev);
 
 	napi_gro_receive(&sds_ring->napi, skb);
@@ -1406,6 +1437,14 @@ qlcnic_process_lro(struct qlcnic_adapter *adapter,
 	skb->truesize = skb->len + sizeof(struct sk_buff) + skb_headroom(skb);
 
 	skb_pull(skb, l2_hdr_offset);
+
+	if (unlikely(adapter->pvid)) {
+		if (qlcnic_check_rx_tagging(adapter, skb)) {
+			adapter->stats.rxdropped++;
+			dev_kfree_skb_any(skb);
+			return buffer;
+		}
+	}
 	skb->protocol = eth_type_trans(skb, netdev);
 
 	iph = (struct iphdr *)skb->data;
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 5d93b46..0892122 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -759,6 +759,21 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 }
 
 static void
+qlcnic_set_vlan_config(struct qlcnic_adapter *adapter,
+		struct qlcnic_esw_func_cfg *esw_cfg)
+{
+	if (esw_cfg->discard_tagged)
+		adapter->flags &= ~QLCNIC_TAGGING_ENABLED;
+	else
+		adapter->flags |= QLCNIC_TAGGING_ENABLED;
+
+	if (esw_cfg->vlan_id)
+		adapter->pvid = esw_cfg->vlan_id;
+	else
+		adapter->pvid = 0;
+}
+
+static void
 qlcnic_set_eswitch_port_features(struct qlcnic_adapter *adapter,
 		struct qlcnic_esw_func_cfg *esw_cfg)
 {
@@ -781,6 +796,7 @@ qlcnic_set_eswitch_port_config(struct qlcnic_adapter *adapter)
 	esw_cfg.pci_func = adapter->ahw.pci_func;
 	if (qlcnic_get_eswitch_port_config(adapter, &esw_cfg))
 			return -EIO;
+	qlcnic_set_vlan_config(adapter, &esw_cfg);
 	qlcnic_set_eswitch_port_features(adapter, &esw_cfg);
 
 	return 0;
@@ -1728,26 +1744,13 @@ qlcnic_tso_check(struct net_device *netdev,
 {
 	u8 opcode = TX_ETHER_PKT;
 	__be16 protocol = skb->protocol;
-	u16 flags = 0, vid = 0;
-	int copied, offset, copy_len, hdr_len = 0, tso = 0, vlan_oob = 0;
+	u16 flags = 0;
+	int copied, offset, copy_len, hdr_len = 0, tso = 0;
 	struct cmd_desc_type0 *hwdesc;
 	struct vlan_ethhdr *vh;
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	u32 producer = tx_ring->producer;
-
-	if (protocol == cpu_to_be16(ETH_P_8021Q)) {
-
-		vh = (struct vlan_ethhdr *)skb->data;
-		protocol = vh->h_vlan_encapsulated_proto;
-		flags = FLAGS_VLAN_TAGGED;
-
-	} else if (vlan_tx_tag_present(skb)) {
-
-		flags = FLAGS_VLAN_OOB;
-		vid = vlan_tx_tag_get(skb);
-		qlcnic_set_tx_vlan_tci(first_desc, vid);
-		vlan_oob = 1;
-	}
+	int vlan_oob = first_desc->flags_opcode & cpu_to_le16(FLAGS_VLAN_OOB);
 
 	if (*(skb->data) & BIT_0) {
 		flags |= BIT_0;
@@ -1818,7 +1821,7 @@ qlcnic_tso_check(struct net_device *netdev,
 		vh = (struct vlan_ethhdr *)((char *)hwdesc + 2);
 		skb_copy_from_linear_data(skb, vh, 12);
 		vh->h_vlan_proto = htons(ETH_P_8021Q);
-		vh->h_vlan_TCI = htons(vid);
+		vh->h_vlan_TCI = htons(first_desc->vlan_TCI);
 		skb_copy_from_linear_data_offset(skb, 12,
 				(char *)vh + 16, copy_len - 16);
 
@@ -1898,11 +1901,47 @@ out_err:
 	return -ENOMEM;
 }
 
+static int
+qlcnic_check_tx_tagging(struct qlcnic_adapter *adapter,
+			struct sk_buff *skb,
+			struct cmd_desc_type0 *first_desc)
+{
+	u8 opcode = 0;
+	u16 flags = 0;
+	__be16 protocol = skb->protocol;
+	struct vlan_ethhdr *vh;
+
+	if (protocol == cpu_to_be16(ETH_P_8021Q)) {
+		vh = (struct vlan_ethhdr *)skb->data;
+		protocol = vh->h_vlan_encapsulated_proto;
+		flags = FLAGS_VLAN_TAGGED;
+		qlcnic_set_tx_vlan_tci(first_desc, ntohs(vh->h_vlan_TCI));
+	} else if (vlan_tx_tag_present(skb)) {
+		flags = FLAGS_VLAN_OOB;
+		qlcnic_set_tx_vlan_tci(first_desc, vlan_tx_tag_get(skb));
+	}
+	if (unlikely(adapter->pvid)) {
+		if (first_desc->vlan_TCI &&
+				!(adapter->flags & QLCNIC_TAGGING_ENABLED))
+			return -EIO;
+		if (first_desc->vlan_TCI &&
+				(adapter->flags & QLCNIC_TAGGING_ENABLED))
+			goto set_flags;
+
+		flags = FLAGS_VLAN_OOB;
+		qlcnic_set_tx_vlan_tci(first_desc, adapter->pvid);
+	}
+set_flags:
+	qlcnic_set_tx_flags_opcode(first_desc, flags, opcode);
+	return 0;
+}
+
 static inline void
 qlcnic_clear_cmddesc(u64 *desc)
 {
 	desc[0] = 0ULL;
 	desc[2] = 0ULL;
+	desc[7] = 0ULL;
 }
 
 netdev_tx_t
@@ -1952,6 +1991,12 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	pdev = adapter->pdev;
 
+	first_desc = hwdesc = &tx_ring->desc_head[producer];
+	qlcnic_clear_cmddesc((u64 *)hwdesc);
+
+	if (qlcnic_check_tx_tagging(adapter, skb, first_desc))
+		goto drop_packet;
+
 	if (qlcnic_map_tx_skb(pdev, skb, pbuf)) {
 		adapter->stats.tx_dma_map_error++;
 		goto drop_packet;
@@ -1960,9 +2005,6 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	pbuf->skb = skb;
 	pbuf->frag_count = frag_count;
 
-	first_desc = hwdesc = &tx_ring->desc_head[producer];
-	qlcnic_clear_cmddesc((u64 *)hwdesc);
-
 	qlcnic_set_tx_frags_len(first_desc, frag_count, skb->len);
 	qlcnic_set_tx_port(first_desc, adapter->portnum);
 
@@ -3349,6 +3391,13 @@ qlcnic_sysfs_write_esw_config(struct file *file, struct kobject *kobj,
 		case QLCNIC_PORT_DEFAULTS:
 			qlcnic_set_eswitch_port_features(adapter, &esw_cfg[i]);
 			break;
+		case QLCNIC_ADD_VLAN:
+			qlcnic_set_vlan_config(adapter, &esw_cfg[i]);
+			break;
+		case QLCNIC_DEL_VLAN:
+			esw_cfg[i].vlan_id = 0;
+			qlcnic_set_vlan_config(adapter, &esw_cfg[i]);
+			break;
 		}
 	}
 
-- 
1.6.0.2

