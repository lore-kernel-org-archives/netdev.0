From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: Re: [RFC] be2net: add rxhash support
Date: Fri, 25 Feb 2011 11:44:25 -0600
Message-ID: <20110225174425.GA11203@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:16762 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752742Ab1BYRot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 12:44:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Sent: Thursday, February 24, 2011 2:25 PM
> To: Khaparde, Ajit
> Cc: netdev@vger.kernel.org
> Subject: [RFC] be2net: add rxhash support
> 
> Ajit, it seems be2net provides RSS hash value in rx compl descriptor ?
> 
> Could we feed skb->rxhash with it ?
> 
> Thanks !
Thanks Eric. Sure.
This is a long pending change which fell through the cracks.
But then because hashing is enabled in the device only when
Number of Rx Queues is > 1, I would suggest the following patch.

Unaware of exact conventions, I have added signed-off-by to the patch already.

Thanks

-----
[PATCH net-next] be2net: add rxhash support

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_main.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 26f9c56..8c4b782 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1038,6 +1038,10 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 
 	skb->truesize = skb->len + sizeof(struct sk_buff);
 	skb->protocol = eth_type_trans(skb, adapter->netdev);
+	if (adapter->netdev->features & NETIF_F_RXHASH)
+		skb->rxhash = AMAP_GET_BITS(struct amap_eth_rx_compl,
+					rsshash, rxcp);
+
 
 	vlanf = AMAP_GET_BITS(struct amap_eth_rx_compl, vtp, rxcp);
 	vtm = AMAP_GET_BITS(struct amap_eth_rx_compl, vtm, rxcp);
@@ -1099,6 +1103,10 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 		return;
 	}
 
+	if (adapter->netdev->features & NETIF_F_RXHASH)
+		skb->rxhash = AMAP_GET_BITS(struct amap_eth_rx_compl,
+						rsshash, rxcp);
+
 	remaining = pkt_size;
 	for (i = 0, j = -1; i < num_rcvd; i++) {
 		page_info = get_rx_page_info(adapter, rxo, rxq_idx);
@@ -2619,6 +2627,9 @@ static void be_netdev_init(struct net_device *netdev)
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 		NETIF_F_GRO | NETIF_F_TSO6;
 
+	if (be_multi_rxq(adapter))
+		netdev->features |= NETIF_F_RXHASH;
+
 	netdev->vlan_features |= NETIF_F_SG | NETIF_F_TSO |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
 
-- 
1.7.1
