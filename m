From: Andrew Gallatin <gallatin@myri.com>
Subject: [PATCH net-next 2/3] myri10ge: Add vlan rx for better GRO perf.
Date: Wed, 14 Nov 2012 08:06:35 -0500
Message-ID: <50A3975B.7020608@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:47427 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422804Ab2KNNGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 08:06:38 -0500
Received: by mail-yh0-f46.google.com with SMTP id m54so46690yhm.19
        for <netdev@vger.kernel.org>; Wed, 14 Nov 2012 05:06:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Unlike LRO, GRO requires that vlan tags be removed before
aggregation can occur.  Since the myri10ge NIC does not support
hardware vlan tag offload, we must remove the tag in the driver
to achieve performance comparable to LRO for vlan tagged frames.

Signed-off-by: Andrew Gallatin <gallatin@myri.com>
---
  drivers/net/ethernet/myricom/myri10ge/myri10ge.c |   47 
++++++++++++++++++++++
  1 file changed, 47 insertions(+)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c 
b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index a5ab2f2..b9b6dfd 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -1264,6 +1264,48 @@ myri10ge_unmap_rx_page(struct pci_dev *pdev,
  	}
  }

+/*
+ * GRO does not support acceleration of tagged vlan frames, and
+ * this NIC does not support vlan tag offload, so we must pop
+ * the tag ourselves to be able to achieve GRO performance that
+ * is comparable to LRO.
+ */
+
+static inline void
+myri10ge_vlan_rx(struct net_device *dev, void *addr, struct sk_buff *skb)
+{
+	u8 *va;
+	struct vlan_ethhdr *veh;
+	struct ethhdr *eh;
+	struct skb_frag_struct *frag;
+	u16 proto;
+
+	va = addr;
+	va += MXGEFW_PAD;
+	veh = (struct vlan_ethhdr *) va;
+	if ((dev->features & (NETIF_F_HW_VLAN_RX | NETIF_F_GRO)) ==
+	    (NETIF_F_HW_VLAN_RX | NETIF_F_GRO) &&
+	    (veh->h_vlan_proto == ntohs(ETH_P_8021Q))) {
+		/* fixup csum if needed */
+		if (skb->ip_summed == CHECKSUM_COMPLETE)
+			skb->csum = csum_sub(skb->csum,
+					     csum_partial(va + ETH_HLEN,
+							  VLAN_HLEN, 0));
+		/* pop tag */
+		__vlan_hwaccel_put_tag(skb, ntohs(veh->h_vlan_TCI));
+		proto = veh->h_vlan_encapsulated_proto;
+		memmove(va + VLAN_HLEN, va, ETH_HLEN);
+		va += VLAN_HLEN;
+		eh = (struct ethhdr *)va;
+		eh->h_proto = proto;
+		skb->len -= VLAN_HLEN;
+		skb->data_len -= VLAN_HLEN;
+		frag = skb_shinfo(skb)->frags;
+		frag->page_offset += VLAN_HLEN;
+		skb_frag_size_set(frag, skb_frag_size(frag) - VLAN_HLEN);
+	}
+}
+
  static inline int
  myri10ge_rx_done(struct myri10ge_slice_state *ss, int len, __wsum csum)
  {
@@ -1329,6 +1371,7 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss, 
int len, __wsum csum)
  		skb->ip_summed = CHECKSUM_COMPLETE;
  		skb->csum = csum;
  	}
+	myri10ge_vlan_rx(mgp->dev, va, skb);
  	skb_record_rx_queue(skb, ss - &mgp->ss[0]);

  	napi_gro_frags(&ss->napi);
@@ -3854,6 +3897,10 @@ static int myri10ge_probe(struct pci_dev *pdev, 
const struct pci_device_id *ent)
  	netdev->netdev_ops = &myri10ge_netdev_ops;
  	netdev->mtu = myri10ge_initial_mtu;
  	netdev->hw_features = mgp->features | NETIF_F_RXCSUM;
+
+	/* fake NETIF_F_HW_VLAN_RX for good GRO performance */
+	netdev->hw_features |= NETIF_F_HW_VLAN_RX;
+
  	netdev->features = netdev->hw_features;

  	if (dac_enabled)
-- 
1.7.9.5
