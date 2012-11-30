From: Andrew Gallatin <gallatin@myri.com>
Subject: [PATCH v3 resend net-next 2/2] myri10ge: Add vlan rx for better GRO perf.
Date: Fri, 30 Nov 2012 13:31:59 -0500
Message-ID: <1354300319-30771-3-git-send-email-gallatin@myri.com>
References: <20121130.121705.1923519039781698493.davem@davemloft.net>
 <1354300319-30771-1-git-send-email-gallatin@myri.com>
Cc: netdev@vger.kernel.org, Andrew Gallatin <gallatin@myri.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f174.google.com ([209.85.213.174]:50040 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755843Ab2K3Sjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 13:39:40 -0500
Received: by mail-ye0-f174.google.com with SMTP id m6so116094yen.19
        for <netdev@vger.kernel.org>; Fri, 30 Nov 2012 10:39:39 -0800 (PST)
In-Reply-To: <1354300319-30771-1-git-send-email-gallatin@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unlike LRO, GRO requires that vlan tags be removed before
aggregation can occur.  Since the myri10ge NIC does not support
hardware vlan tag offload, we must remove the tag in the driver
to achieve performance comparable to LRO for vlan tagged frames.

Thanks to Eric Duzamet for his help simplifying the original patch.

Signed-off-by: Andrew Gallatin <gallatin@myri.com>
---
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |   41 ++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 84207c0..2fc984a 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -1264,6 +1264,42 @@ myri10ge_unmap_rx_page(struct pci_dev *pdev,
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
+	struct skb_frag_struct *frag;
+	__wsum vsum;
+
+	va = addr;
+	va += MXGEFW_PAD;
+	veh = (struct vlan_ethhdr *)va;
+	if ((dev->features & NETIF_F_HW_VLAN_RX) == NETIF_F_HW_VLAN_RX &&
+	    veh->h_vlan_proto == ntohs(ETH_P_8021Q)) {
+		/* fixup csum if needed */
+		if (skb->ip_summed == CHECKSUM_COMPLETE) {
+			vsum = csum_partial(va + ETH_HLEN, VLAN_HLEN, 0);
+			skb->csum = csum_sub(skb->csum, vsum);
+		}
+		/* pop tag */
+		__vlan_hwaccel_put_tag(skb, ntohs(veh->h_vlan_TCI));
+		memmove(va + VLAN_HLEN, va, 2 * ETH_ALEN);
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
@@ -1326,6 +1362,7 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss, int len, __wsum csum)
 		skb->ip_summed = CHECKSUM_COMPLETE;
 		skb->csum = csum;
 	}
+	myri10ge_vlan_rx(mgp->dev, va, skb);
 	skb_record_rx_queue(skb, ss - &mgp->ss[0]);
 
 	napi_gro_frags(&ss->napi);
@@ -3851,6 +3888,10 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
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
