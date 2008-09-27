From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 2/4] atl1: remove LLTX
Date: Sat, 27 Sep 2008 09:17:21 -0500
Message-ID: <1222525043-4648-3-git-send-email-jacliburn@bellsouth.net>
References: <1222525043-4648-1-git-send-email-jacliburn@bellsouth.net>
Cc: csnook@redhat.com, jie.yang@atheros.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jay Cliburn <jacliburn@bellsouth.net>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost04.isp.att.net ([204.127.217.104]:50939 "EHLO
	fmailhost04.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757AbYI0OW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Sep 2008 10:22:27 -0400
In-Reply-To: <1222525043-4648-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NETIF_F_LLTX is deprecated. Remove private TX locking from the driver
and remove the NETIF_F_LLTX feature flag.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atlx/atl1.c |   18 +-----------------
 1 files changed, 1 insertions(+), 17 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index e00a986..5f157e0 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2109,7 +2109,6 @@ static u16 atl1_tpd_avail(struct atl1_tpd_ring *tpd_ring)
 static int atl1_tso(struct atl1_adapter *adapter, struct sk_buff *skb,
 	struct tx_packet_desc *ptpd)
 {
-	/* spinlock held */
 	u8 hdr_len, ip_off;
 	u32 real_len;
 	int err;
@@ -2196,7 +2195,6 @@ static int atl1_tx_csum(struct atl1_adapter *adapter, struct sk_buff *skb,
 static void atl1_tx_map(struct atl1_adapter *adapter, struct sk_buff *skb,
 	struct tx_packet_desc *ptpd)
 {
-	/* spinlock held */
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
 	struct atl1_buffer *buffer_info;
 	u16 buf_len = skb->len;
@@ -2303,7 +2301,6 @@ static void atl1_tx_map(struct atl1_adapter *adapter, struct sk_buff *skb,
 static void atl1_tx_queue(struct atl1_adapter *adapter, u16 count,
        struct tx_packet_desc *ptpd)
 {
-	/* spinlock held */
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
 	struct atl1_buffer *buffer_info;
 	struct tx_packet_desc *tpd;
@@ -2361,7 +2358,6 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	struct tx_packet_desc *ptpd;
 	u16 frag_size;
 	u16 vlan_tag;
-	unsigned long flags;
 	unsigned int nr_frags = 0;
 	unsigned int mss = 0;
 	unsigned int f;
@@ -2399,18 +2395,9 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		}
 	}
 
-	if (!spin_trylock_irqsave(&adapter->lock, flags)) {
-		/* Can't get lock - tell upper layer to requeue */
-		if (netif_msg_tx_queued(adapter))
-			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
-				"tx locked\n");
-		return NETDEV_TX_LOCKED;
-	}
-
 	if (atl1_tpd_avail(&adapter->tpd_ring) < count) {
 		/* not enough descriptors */
 		netif_stop_queue(netdev);
-		spin_unlock_irqrestore(&adapter->lock, flags);
 		if (netif_msg_tx_queued(adapter))
 			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
 				"tx busy\n");
@@ -2432,7 +2419,6 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	tso = atl1_tso(adapter, skb, ptpd);
 	if (tso < 0) {
-		spin_unlock_irqrestore(&adapter->lock, flags);
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
@@ -2440,7 +2426,6 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	if (!tso) {
 		ret_val = atl1_tx_csum(adapter, skb, ptpd);
 		if (ret_val < 0) {
-			spin_unlock_irqrestore(&adapter->lock, flags);
 			dev_kfree_skb_any(skb);
 			return NETDEV_TX_OK;
 		}
@@ -2449,7 +2434,7 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	atl1_tx_map(adapter, skb, ptpd);
 	atl1_tx_queue(adapter, count, ptpd);
 	atl1_update_mailbox(adapter);
-	spin_unlock_irqrestore(&adapter->lock, flags);
+	mmiowb();
 	netdev->trans_start = jiffies;
 	return NETDEV_TX_OK;
 }
@@ -3024,7 +3009,6 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	netdev->features = NETIF_F_HW_CSUM;
 	netdev->features |= NETIF_F_SG;
 	netdev->features |= (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
-	netdev->features |= NETIF_F_LLTX;
 
 	/*
 	 * patch for some L1 of old version,
-- 
1.5.5.1

