From: Tom Herbert <therbert@google.com>
Subject: [PATCH] forcedeth: GRO support
Date: Mon, 3 May 2010 22:08:45 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1005032203520.11991@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, aabdulla@nvidia.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:55156 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206Ab0EDFIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 01:08:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add GRO support to forcedeth.

Signed-off-by: Tom Herbert <therbert@google.com>
---
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 5cf0e66..4a24cc7 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -2817,7 +2817,7 @@ static int nv_rx_process(struct net_device *dev, int limit)
 		dprintk(KERN_DEBUG "%s: nv_rx_process: %d bytes, proto %d accepted.\n",
 					dev->name, len, skb->protocol);
 #ifdef CONFIG_FORCEDETH_NAPI
-		netif_receive_skb(skb);
+		napi_gro_receive(&np->napi, skb);
 #else
 		netif_rx(skb);
 #endif
@@ -2910,7 +2910,7 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 
 			if (likely(!np->vlangrp)) {
 #ifdef CONFIG_FORCEDETH_NAPI
-				netif_receive_skb(skb);
+				napi_gro_receive(&np->napi, skb);
 #else
 				netif_rx(skb);
 #endif
@@ -2918,15 +2918,15 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 				vlanflags = le32_to_cpu(np->get_rx.ex->buflow);
 				if (vlanflags & NV_RX3_VLAN_TAG_PRESENT) {
 #ifdef CONFIG_FORCEDETH_NAPI
-					vlan_hwaccel_receive_skb(skb, np->vlangrp,
-								 vlanflags & NV_RX3_VLAN_TAG_MASK);
+					vlan_gro_receive(&np->napi, np->vlangrp,
+							 vlanflags & NV_RX3_VLAN_TAG_MASK, skb);
 #else
 					vlan_hwaccel_rx(skb, np->vlangrp,
 							vlanflags & NV_RX3_VLAN_TAG_MASK);
 #endif
 				} else {
 #ifdef CONFIG_FORCEDETH_NAPI
-					netif_receive_skb(skb);
+					napi_gro_receive(&np->napi, skb);
 #else
 					netif_rx(skb);
 #endif
@@ -5711,6 +5711,9 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		np->txrxctl_bits |= NVREG_TXRXCTL_RXCHECK;
 		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 		dev->features |= NETIF_F_TSO;
+#ifdef CONFIG_FORCEDETH_NAPI
+		dev->features |= NETIF_F_GRO;
+#endif
 	}
 
 	np->vlanctl_bits = 0;
