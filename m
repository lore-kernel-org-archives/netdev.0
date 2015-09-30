From: Julien Grall <julien.grall@citrix.com>
Subject: [PATCH v5 01/22] net/xen-netback: xenvif_gop_frag_copy: move GSO check out of the loop
Date: Wed, 30 Sep 2015 11:45:16 +0100
Message-ID: <1443609937-25278-2-git-send-email-julien.grall@citrix.com>
References: <1443609937-25278-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <ian.campbell@citrix.com>,
	<stefano.stabellini@eu.citrix.com>, <linux-kernel@vger.kernel.org>,
	"Julien Grall" <julien.grall@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>
To: <xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443609937-25278-1-git-send-email-julien.grall@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The skb doesn't change within the function. Therefore it's only
necessary to check if we need GSO once at the beginning.

Signed-off-by: Julien Grall <julien.grall@citrix.com>
Acked-by: Wei Liu <wei.liu2@citrix.com>

---
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org

    Changes in v4:
        - Add Wei's acked

    Changes in v2:
        - Patch added
---
 drivers/net/xen-netback/netback.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index ec98d43..c4e6c02 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -288,6 +288,13 @@ static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb
 	unsigned long bytes;
 	int gso_type = XEN_NETIF_GSO_TYPE_NONE;
 
+	if (skb_is_gso(skb)) {
+		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
+			gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
+		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
+			gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
+	}
+
 	/* Data must not cross a page boundary. */
 	BUG_ON(size + offset > PAGE_SIZE<<compound_order(page));
 
@@ -347,13 +354,6 @@ static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb
 		}
 
 		/* Leave a gap for the GSO descriptor. */
-		if (skb_is_gso(skb)) {
-			if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
-				gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
-			else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
-				gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
-		}
-
 		if (*head && ((1 << gso_type) & queue->vif->gso_mask))
 			queue->rx.req_cons++;
 
-- 
2.1.4
