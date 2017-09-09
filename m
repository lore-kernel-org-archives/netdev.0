From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH v2 net] net: qualcomm: rmnet: Fix a double free
Date: Sat, 9 Sep 2017 11:58:03 +0300
Message-ID: <20170909085803.zgfqhp23yt4ol3ka@mwanda>
References: <2ddbb6da514108b4e70ccd8362292134@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2ddbb6da514108b4e70ccd8362292134@codeaurora.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a typo here so we accidentally free "skb" instead of "skbn".
It leads to a double free and a leak.  After discussing with Subash,
it's better to just move the check before the allocation and avoid the
need to free.

Fixes: ceed73a2cf4a ("drivers: net: ethernet: qualcomm: rmnet: Initial implementation")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2: Fix the leak as well.  Thanks Subash!

diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
index 557c9bf1a469..86b8c758f94e 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
@@ -84,6 +84,10 @@ struct sk_buff *rmnet_map_deaggregate(struct sk_buff *skb)
 	if (((int)skb->len - (int)packet_len) < 0)
 		return NULL;
 
+	/* Some hardware can send us empty frames. Catch them */
+	if (ntohs(maph->pkt_len) == 0)
+		return NULL;
+
 	skbn = alloc_skb(packet_len + RMNET_MAP_DEAGGR_SPACING, GFP_ATOMIC);
 	if (!skbn)
 		return NULL;
@@ -94,11 +98,5 @@ struct sk_buff *rmnet_map_deaggregate(struct sk_buff *skb)
 	memcpy(skbn->data, skb->data, packet_len);
 	skb_pull(skb, packet_len);
 
-	/* Some hardware can send us empty frames. Catch them */
-	if (ntohs(maph->pkt_len) == 0) {
-		kfree_skb(skb);
-		return NULL;
-	}
-
 	return skbn;
 }
