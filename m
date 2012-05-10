From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [RFC] net: remove NETIF_F_FRAGLIST from xgmac, ehea, axienet and ll_temac
Date: Thu, 10 May 2012 20:20:42 +0200
Message-ID: <1336674042-6378-1-git-send-email-bigeasy@linutronix.de>
Cc: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	Rob Herring <rob.herring@calxeda.com>,
	Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:60628 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761075Ab2EJSTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 14:19:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There seem to be two ways how the data payload can be attached to a
sk_buff. That is simple kmalloc() and via "paged" fragments. The former
is simple. The latter attaches each fragment to sh_info->frags and
accounts total number of fragments in sh_info->nr_frags. Once
skb->data_len is non-zero then there should be page fragments available
and sh_info->nr_frags should not be zero anymore.

There is also a third way how data can be added to a skb, that is via
the sh_info->frag_list. This is a complete sk_buff (including data)
which is attached to the former skb. This one can also have linear
memory (kmalloc()) or not (->frags).
If the network driver which should transmit the skb does not support
one of this cool things, then the network core makes a linear skb which
contains only linear kmalloc() memory. If the driver supports the frags
(nr_frags is non zero) then it denotes this by setting the NETIF_F_SG
flag. If the driver is also able to walk via the ->frag_list then it
sets NETIF_F_FRAGLIST flag.

I remove the NETIF_F_FRAGLIST flag here from these drivers here because
I did not find any evidence that they look the ->frag_list at all. It
seems that they look only at sh_info->frags and handle only those pages.
Other drivers which set this flag like ifb don't look at the
->frag_list either but they pass the skb back to the network stack.

The virtio_net driver is using skb_to_sgvec() which gives it a sglist
including everything and tun is using skb_copy_datagram_const_iovec()
which is considering the ->frag_list as well.

So I found evidence that some drivers are doing it right, but for those
five I haven't found any.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/ethernet/calxeda/xgmac.c              |    2 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c         |    2 +-
 drivers/net/ethernet/tehuti/tehuti.c              |    4 +---
 drivers/net/ethernet/xilinx/ll_temac_main.c       |    2 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c |    2 +-
 drivers/scsi/cxgbi/libcxgbi.c                     |    2 +-
 6 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 11f667f..11fa3a5 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -1772,7 +1772,7 @@ static int xgmac_probe(struct platform_device *pdev)
 	if (device_can_wakeup(priv->device))
 		priv->wolopts = WAKE_MAGIC;	/* Magic Frame as default */
 
-	ndev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA;
+	ndev->hw_features = NETIF_F_SG | NETIF_F_HIGHDMA;
 	if (readl(priv->base + XGMAC_DMA_HW_FEATURE) & DMA_HW_FEAT_TXCOESEL)
 		ndev->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 				     NETIF_F_RXCSUM;
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index c9069a2..2231ad6 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -3029,7 +3029,7 @@ static struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 
 	dev->hw_features = NETIF_F_SG | NETIF_F_TSO
 		      | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX | NETIF_F_LRO;
-	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO
+	dev->features = NETIF_F_SG | NETIF_F_TSO
 		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX
 		      | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER
 		      | NETIF_F_RXCSUM;
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index ad973ff..6c7e519 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -1994,9 +1994,7 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		ndev->irq = pdev->irq;
 		ndev->features = NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO
 		    | NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
-		    NETIF_F_HW_VLAN_FILTER | NETIF_F_RXCSUM
-		    /*| NETIF_F_FRAGLIST */
-		    ;
+		    NETIF_F_HW_VLAN_FILTER | NETIF_F_RXCSUM;
 		ndev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG |
 			NETIF_F_TSO | NETIF_F_HW_VLAN_TX;
 
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index d21591a..e804f1f 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -1020,7 +1020,7 @@ static int __devinit temac_of_probe(struct platform_device *op)
 	dev_set_drvdata(&op->dev, ndev);
 	SET_NETDEV_DEV(ndev, &op->dev);
 	ndev->flags &= ~IFF_MULTICAST;  /* clear multicast */
-	ndev->features = NETIF_F_SG | NETIF_F_FRAGLIST;
+	ndev->features = NETIF_F_SG;
 	ndev->netdev_ops = &temac_netdev_ops;
 	ndev->ethtool_ops = &temac_ethtool_ops;
 #if 0
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 9c365e1..fde716d 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1494,7 +1494,7 @@ static int __devinit axienet_of_probe(struct platform_device *op)
 
 	SET_NETDEV_DEV(ndev, &op->dev);
 	ndev->flags &= ~IFF_MULTICAST;  /* clear multicast */
-	ndev->features = NETIF_F_SG | NETIF_F_FRAGLIST;
+	ndev->features = NETIF_F_SG;
 	ndev->netdev_ops = &axienet_netdev_ops;
 	ndev->ethtool_ops = &axienet_ethtool_ops;
 
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index d9253db..7968d4f 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -1968,7 +1968,7 @@ int cxgbi_conn_init_pdu(struct iscsi_task *task, unsigned int offset,
 			}
 			skb_put(skb, count + padlen);
 		} else {
-			/* data fit into frag_list */
+			/* data fit into frags */
 			for (i = 0; i < tdata->nr_frags; i++) {
 				__skb_fill_page_desc(skb, i,
 						tdata->frags[i].page,
-- 
1.7.10
