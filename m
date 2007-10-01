From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH 5/9] fs_enet: Align receive buffers.
Date: Mon, 1 Oct 2007 14:20:52 -0500
Message-ID: <20071001192052.GD28429@loki.buserror.net>
References: <20071001192017.GA28410@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:47583 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719AbXJATVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 15:21:02 -0400
Content-Disposition: inline
In-Reply-To: <20071001192017.GA28410@loki.buserror.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At least some hardware driven by this driver needs receive buffers
to be aligned on a 16-byte boundary.  This usually happens by chance,
but it breaks if slab debugging is enabled.

Signed-off-by: Scott Wood <scottwood@freescale.com>
---
 drivers/net/fs_enet/fs_enet-main.c |   21 +++++++++++++++++++--
 drivers/net/fs_enet/fs_enet.h      |    3 ++-
 2 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index a15345b..7a02986 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -70,6 +70,14 @@ static void fs_set_multicast_list(struct net_device *dev)
 	(*fep->ops->set_multicast_list)(dev);
 }
 
+static void skb_align(struct sk_buff *skb, int align)
+{
+	int off = ((unsigned long)skb->data) & (align - 1);
+
+	if (off)
+		skb_reserve(skb, align - off);
+}
+
 /* NAPI receive function */
 static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 {
@@ -159,9 +167,13 @@ static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 					skb = skbn;
 					skbn = skbt;
 				}
-			} else
+			} else {
 				skbn = dev_alloc_skb(ENET_RX_FRSIZE);
 
+				if (skbn)
+					skb_align(skbn, ENET_RX_ALIGN);
+			}
+
 			if (skbn != NULL) {
 				skb_put(skb, pkt_len);	/* Make room */
 				skb->protocol = eth_type_trans(skb, dev);
@@ -290,9 +302,13 @@ static int fs_enet_rx_non_napi(struct net_device *dev)
 					skb = skbn;
 					skbn = skbt;
 				}
-			} else
+			} else {
 				skbn = dev_alloc_skb(ENET_RX_FRSIZE);
 
+				if (skbn)
+					skb_align(skbn, ENET_RX_ALIGN);
+			}
+
 			if (skbn != NULL) {
 				skb_put(skb, pkt_len);	/* Make room */
 				skb->protocol = eth_type_trans(skb, dev);
@@ -502,6 +518,7 @@ void fs_init_bds(struct net_device *dev)
 			       dev->name);
 			break;
 		}
+		skb_align(skb, ENET_RX_ALIGN);
 		fep->rx_skbuff[i] = skb;
 		CBDW_BUFADDR(bdp,
 			dma_map_single(fep->dev, skb->data,
diff --git a/drivers/net/fs_enet/fs_enet.h b/drivers/net/fs_enet/fs_enet.h
index fbe2087..85571e4 100644
--- a/drivers/net/fs_enet/fs_enet.h
+++ b/drivers/net/fs_enet/fs_enet.h
@@ -82,7 +82,8 @@ struct phy_info {
 /* Must be a multiple of 32 (to cover both FEC & FCC) */
 #define PKT_MAXBLR_SIZE		((PKT_MAXBUF_SIZE + 31) & ~31)
 /* This is needed so that invalidate_xxx wont invalidate too much */
-#define ENET_RX_FRSIZE		L1_CACHE_ALIGN(PKT_MAXBUF_SIZE)
+#define ENET_RX_ALIGN  16
+#define ENET_RX_FRSIZE L1_CACHE_ALIGN(PKT_MAXBUF_SIZE + ENET_RX_ALIGN - 1)
 
 struct fs_enet_mii_bus {
 	struct list_head list;
-- 
1.5.3.2

