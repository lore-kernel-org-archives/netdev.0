From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] be2net: add rxhash support
Date: Thu, 24 Feb 2011 21:24:44 +0100
Message-ID: <1298579084.2659.13.camel@edumazet-laptop>
References: <20110131232755.GA4691@akhaparde-VBox>
	 <20110201.154209.179944086.davem@davemloft.net>
	 <1298560543.2814.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ajit Khaparde <ajit.khaparde@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:41511 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756515Ab1BXUYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 15:24:49 -0500
Received: by bwz15 with SMTP id 15so1398660bwz.19
        for <netdev@vger.kernel.org>; Thu, 24 Feb 2011 12:24:48 -0800 (PST)
In-Reply-To: <1298560543.2814.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ajit, it seems be2net provides RSS hash value in rx compl descriptor ?

Could we feed skb->rxhash with it ?

Thanks !

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 0bdccb1..f2db5b2 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1038,6 +1038,9 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 
 	skb->truesize = skb->len + sizeof(struct sk_buff);
 	skb->protocol = eth_type_trans(skb, adapter->netdev);
+	if (adapter->netdev->features & NETIF_F_RXHASH)
+		skb->rxhash = AMAP_GET_BITS(struct amap_eth_rx_compl, rsshash, rxcp);
+
 
 	vlanf = AMAP_GET_BITS(struct amap_eth_rx_compl, vtp, rxcp);
 	vtm = AMAP_GET_BITS(struct amap_eth_rx_compl, vtm, rxcp);
@@ -1099,6 +1102,9 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 		return;
 	}
 
+	if (adapter->netdev->features & NETIF_F_RXHASH)
+		skb->rxhash = AMAP_GET_BITS(struct amap_eth_rx_compl, rsshash, rxcp);
+
 	remaining = pkt_size;
 	for (i = 0, j = -1; i < num_rcvd; i++) {
 		page_info = get_rx_page_info(adapter, rxo, rxq_idx);
@@ -2618,6 +2624,7 @@ static void be_netdev_init(struct net_device *netdev)
 		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 		NETIF_F_GRO | NETIF_F_TSO6;
+	netdev->features |= NETIF_F_RXHASH;
 
 	netdev->vlan_features |= NETIF_F_SG | NETIF_F_TSO |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;


