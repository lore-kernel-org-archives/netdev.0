From: Jason Lunz <lunz@falooley.org>
Subject: Re: e100-3.0.0_dev8 "Minneapolis Moline" release
Date: Wed, 18 Jun 2003 15:33:25 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <slrnbf11i5.kck.lunz@stoli.localnet>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010107D977@orsmsx402.jf.intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

scott.feldman@intel.com said:
> Also, any feedback on the code correctness, maintainability, credits,
> etc. would help.

Is the anonymous union in struct cb some kind of gcc3-only thing? It
doesn't compile for my debian woody gcc 2.95 unless I name the union
member.

-- 
Jason Lunz			Reflex Security
lunz@reflexsecurity.com		http://www.reflexsecurity.com/


--- e100.c	Tue Jun 17 08:51:45 2003
+++ e100.c.union	Wed Jun 18 11:27:45 2003
@@ -434,7 +434,7 @@
 				u16 eol;
 			} tbd;
 		} tcb;
-	};
+	} data;
 	struct cb *next, *prev;
 	dma_addr_t dma_addr;
 	struct sk_buff *skb;
@@ -867,7 +867,7 @@
 
 static void e100_configure(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 {
-	struct config *config = &cb->config;
+	struct config *config = &cb->data.config;
 	u8 *c = (u8 *)config;
 
 	cb->command = cpu_to_le16(cb_config);
@@ -942,7 +942,7 @@
 		dev_addr[3], dev_addr[4], dev_addr[5]);
 	
 	cb->command = cpu_to_le16(cb_iaaddr);
-	memcpy(cb->iaaddr, dev_addr, ETH_ALEN);
+	memcpy(cb->data.iaaddr, dev_addr, ETH_ALEN);
 }
 
 #define NCONFIG_AUTO_SWITCH	0x0080
@@ -1051,9 +1051,9 @@
 	u16 i, count = min(netdev->mc_count, E100_MAX_MULTICAST_ADDRS);
 
 	cb->command = cpu_to_le16(cb_multi);
-	cb->multi.count = cpu_to_le16(count * ETH_ALEN);
+	cb->data.multi.count = cpu_to_le16(count * ETH_ALEN);
 	for(i = 0; list && i < count; i++, list = list->next)
-		memcpy(&cb->multi.addr[i*ETH_ALEN], &list->dmi_addr, ETH_ALEN);
+		memcpy(&cb->data.multi.addr[i*ETH_ALEN], &list->dmi_addr, ETH_ALEN);
 }
 
 static void e100_set_multicast_list(struct net_device *netdev)
@@ -1175,13 +1175,13 @@
 	struct sk_buff *skb)
 {
 	cb->command = nic->tx_command;
-	cb->tcb.tbd_array = cb->dma_addr + offsetof(struct cb, tcb.tbd);
-	cb->tcb.tcb_byte_count = 0;
-	cb->tcb.threshold = nic->tx_threshold;
-	cb->tcb.tbd_count = 1;
-	cb->tcb.tbd.buf_addr = cpu_to_le32(pci_map_single(nic->pdev,
+	cb->data.tcb.tbd_array = cb->dma_addr + offsetof(struct cb, data.tcb.tbd);
+	cb->data.tcb.tcb_byte_count = 0;
+	cb->data.tcb.threshold = nic->tx_threshold;
+	cb->data.tcb.tbd_count = 1;
+	cb->data.tcb.tbd.buf_addr = cpu_to_le32(pci_map_single(nic->pdev,
 		skb->data, skb->len, PCI_DMA_TODEVICE));
-	cb->tcb.tbd.size = cpu_to_le16(skb->len);
+	cb->data.tcb.tbd.size = cpu_to_le16(skb->len);
 }
 
 static int e100_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
@@ -1217,8 +1217,8 @@
 			nic->net_stats.tx_bytes += cb->skb->len;
 
 			pci_unmap_single(nic->pdev,
-				le32_to_cpu(cb->tcb.tbd.buf_addr),
-				le16_to_cpu(cb->tcb.tbd.size),
+				le32_to_cpu(cb->data.tcb.tbd.buf_addr),
+				le16_to_cpu(cb->data.tcb.tbd.size),
 				PCI_DMA_TODEVICE);
 			dev_kfree_skb_irq(cb->skb);
 			tx_cleaned = 1;
@@ -1241,8 +1241,8 @@
 			struct cb *cb = nic->cb_to_clean;
 			if(cb->skb) {
 				pci_unmap_single(nic->pdev,
-					le32_to_cpu(cb->tcb.tbd.buf_addr),
-					le16_to_cpu(cb->tcb.tbd.size),
+					le32_to_cpu(cb->data.tcb.tbd.buf_addr),
+					le16_to_cpu(cb->data.tcb.tbd.size),
 					PCI_DMA_TODEVICE);
 				dev_kfree_skb_irq(cb->skb);
 			}
