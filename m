From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] be2net: fix truesize errors
Date: Thu, 13 Oct 2011 18:31:02 +0200
Message-ID: <1318523462.2393.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38172 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756316Ab1JMQaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 12:30:46 -0400
Received: by wwf22 with SMTP id 22so2056272wwf.1
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 09:30:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix skb truesize underestimations of this driver.

Each frag truesize is exactly rx_frag_size bytes. (2048 bytes per
default)

A driver should not use "sizeof(struct sk_buff)" at all.

Signed-off-by: Eric Dumazet <eric.dumazet>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 816ce56..679b804 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1071,6 +1071,7 @@ static void skb_fill_rx_data(struct be_adapter *adapter, struct be_rx_obj *rxo,
 					page_info->page_offset + hdr_len;
 		skb_shinfo(skb)->frags[0].size = curr_frag_len - hdr_len;
 		skb->data_len = curr_frag_len - hdr_len;
+		skb->truesize += rx_frag_size;
 		skb->tail += hdr_len;
 	}
 	page_info->page = NULL;
@@ -1103,7 +1104,7 @@ static void skb_fill_rx_data(struct be_adapter *adapter, struct be_rx_obj *rxo,
 		skb_shinfo(skb)->frags[j].size += curr_frag_len;
 		skb->len += curr_frag_len;
 		skb->data_len += curr_frag_len;
-
+		skb->truesize += rx_frag_size;
 		remaining -= curr_frag_len;
 		index_inc(&rxcp->rxq_idx, rxq->len);
 		page_info->page = NULL;
@@ -1133,7 +1134,6 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 	else
 		skb_checksum_none_assert(skb);
 
-	skb->truesize = skb->len + sizeof(struct sk_buff);
 	skb->protocol = eth_type_trans(skb, netdev);
 	if (adapter->netdev->features & NETIF_F_RXHASH)
 		skb->rxhash = rxcp->rss_hash;
@@ -1181,7 +1181,7 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 			put_page(page_info->page);
 		}
 		skb_shinfo(skb)->frags[j].size += curr_frag_len;
-
+		skb->truesize += rx_frag_size;
 		remaining -= curr_frag_len;
 		index_inc(&rxcp->rxq_idx, rxq->len);
 		memset(page_info, 0, sizeof(*page_info));
@@ -1191,7 +1191,6 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 	skb_shinfo(skb)->nr_frags = j + 1;
 	skb->len = rxcp->pkt_size;
 	skb->data_len = rxcp->pkt_size;
-	skb->truesize += rxcp->pkt_size;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	if (adapter->netdev->features & NETIF_F_RXHASH)
 		skb->rxhash = rxcp->rss_hash;
