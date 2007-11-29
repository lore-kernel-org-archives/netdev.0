From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [8/12] pasemi_mac: Software-based LRO support
Date: Wed, 28 Nov 2007 20:57:27 -0600
Message-ID: <20071129025727.GI17215@lixom.net>
References: <20071129025410.GA17215@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:36907 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757295AbXK2CyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 21:54:16 -0500
Content-Disposition: inline
In-Reply-To: <20071129025410.GA17215@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: Software-based LRO support

Implement LRO for pasemi_mac. Pretty straightforward.


Signed-off-by: Olof Johansson <olof@lixom.net>

---
 drivers/net/Kconfig      |    1 
 drivers/net/pasemi_mac.c |   53 +++++++++++++++++++++++++++++++++++++++++++----
 drivers/net/pasemi_mac.h |    5 ++++
 3 files changed, 55 insertions(+), 4 deletions(-)

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -32,6 +32,7 @@
 #include <linux/ip.h>
 #include <linux/tcp.h>
 #include <net/checksum.h>
+#include <linux/inet_lro.h>
 
 #include <asm/irq.h>
 #include <asm/firmware.h>
@@ -56,9 +57,11 @@
 
 
 /* Must be a power of two */
-#define RX_RING_SIZE 1024
+#define RX_RING_SIZE 2048
 #define TX_RING_SIZE 4096
 
+#define LRO_MAX_AGGR 64
+
 #define DEFAULT_MSG_ENABLE	  \
 	(NETIF_MSG_DRV		| \
 	 NETIF_MSG_PROBE	| \
@@ -206,7 +209,6 @@ static int pasemi_get_mac_addr(struct pa
 		return -ENOENT;
 	}
 
-
 	if (sscanf(maddr, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx", &addr[0],
 		   &addr[1], &addr[2], &addr[3], &addr[4], &addr[5]) != 6) {
 		dev_warn(&pdev->dev,
@@ -219,6 +221,37 @@ static int pasemi_get_mac_addr(struct pa
 	return 0;
 }
 
+static int get_skb_hdr(struct sk_buff *skb, void **iphdr,
+		       void **tcph, u64 *hdr_flags, void *data)
+{
+	u64 macrx = (u64) data;
+	unsigned int ip_len;
+	struct iphdr *iph;
+
+	/* IPv4 header checksum failed */
+	if ((macrx & XCT_MACRX_HTY_M) != XCT_MACRX_HTY_IPV4_OK)
+		return -1;
+
+	/* non tcp packet */
+	skb_reset_network_header(skb);
+	iph = ip_hdr(skb);
+	if (iph->protocol != IPPROTO_TCP)
+		return -1;
+
+	ip_len = ip_hdrlen(skb);
+	skb_set_transport_header(skb, ip_len);
+	*tcph = tcp_hdr(skb);
+
+	/* check if ip header and tcp header are complete */
+	if (iph->tot_len < ip_len + tcp_hdrlen(skb))
+		return -1;
+
+	*hdr_flags = LRO_IPV4 | LRO_TCP;
+	*iphdr = iph;
+
+	return 0;
+}
+
 static int pasemi_mac_unmap_tx_skb(struct pasemi_mac *mac,
 				    struct sk_buff *skb,
 				    const dma_addr_t *dmas)
@@ -662,7 +695,7 @@ static int pasemi_mac_clean_rx(struct pa
 		skb_put(skb, len-4);
 
 		skb->protocol = eth_type_trans(skb, mac->netdev);
-		netif_receive_skb(skb);
+		lro_receive_skb(&mac->lro_mgr, skb, (void *)macrx);
 
 next:
 		RX_DESC(rx, n) = 0;
@@ -684,6 +717,8 @@ next:
 
 	rx_ring(mac)->next_to_clean = n;
 
+	lro_flush_all(&mac->lro_mgr);
+
 	/* Increase is in number of 16-byte entries, and since each descriptor
 	 * with an 8BRES takes up 3x8 bytes (padded to 4x8), increase with
 	 * count*2.
@@ -988,7 +1023,7 @@ static int pasemi_mac_open(struct net_de
 		      PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(0x3ff));
 
 	write_iob_reg(PAS_IOB_DMA_RXCH_CFG(mac->rx->chan.chno),
-		      PAS_IOB_DMA_RXCH_CFG_CNTTH(128));
+		      PAS_IOB_DMA_RXCH_CFG_CNTTH(256));
 
 	write_iob_reg(PAS_IOB_DMA_TXCH_CFG(mac->tx->chan.chno),
 		      PAS_IOB_DMA_TXCH_CFG_CNTTH(32));
@@ -1368,6 +1403,16 @@ pasemi_mac_probe(struct pci_dev *pdev, c
 	dev->features = NETIF_F_HW_CSUM | NETIF_F_LLTX | NETIF_F_SG |
 			NETIF_F_HIGHDMA;
 
+	mac->lro_mgr.max_aggr = LRO_MAX_AGGR;
+	mac->lro_mgr.max_desc = MAX_LRO_DESCRIPTORS;
+	mac->lro_mgr.lro_arr = mac->lro_desc;
+	mac->lro_mgr.get_skb_header = get_skb_hdr;
+	mac->lro_mgr.features = LRO_F_NAPI | LRO_F_EXTRACT_VLAN_ID;
+	mac->lro_mgr.dev = mac->netdev;
+	mac->lro_mgr.ip_summed = CHECKSUM_UNNECESSARY;
+	mac->lro_mgr.ip_summed_aggr = CHECKSUM_UNNECESSARY;
+
+
 	mac->dma_pdev = pci_get_device(PCI_VENDOR_ID_PASEMI, 0xa007, NULL);
 	if (!mac->dma_pdev) {
 		dev_err(&mac->pdev->dev, "Can't find DMA Controller\n");
Index: k.org/drivers/net/pasemi_mac.h
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.h
+++ k.org/drivers/net/pasemi_mac.h
@@ -26,6 +26,8 @@
 #include <linux/spinlock.h>
 #include <linux/phy.h>
 
+#define MAX_LRO_DESCRIPTORS 8
+
 struct pasemi_mac_txring {
 	struct pasemi_dmachan chan; /* Must be first */
 	spinlock_t	 lock;
@@ -64,7 +66,10 @@ struct pasemi_mac {
 
 	u8		mac_addr[6];
 
+	struct net_lro_mgr	lro_mgr;
+	struct net_lro_desc	lro_desc[MAX_LRO_DESCRIPTORS];
 	struct timer_list	rxtimer;
+	unsigned int		lro_max_aggr;
 
 	struct pasemi_mac_txring *tx;
 	struct pasemi_mac_rxring *rx;
Index: k.org/drivers/net/Kconfig
===================================================================
--- k.org.orig/drivers/net/Kconfig
+++ k.org/drivers/net/Kconfig
@@ -2566,6 +2566,7 @@ config PASEMI_MAC
 	tristate "PA Semi 1/10Gbit MAC"
 	depends on PPC64 && PCI
 	select PHYLIB
+	select INET_LRO
 	help
 	  This driver supports the on-chip 1/10Gbit Ethernet controller on
 	  PA Semi's PWRficient line of chips.
