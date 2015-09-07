From: Julien Grall <julien.grall@citrix.com>
Subject: [PATCH v4 01/20] net/xen-netback: xenvif_gop_frag_copy: move GSO
 check out of the loop
Date: Mon, 7 Sep 2015 16:33:39 +0100
Message-ID: <1441640038-23615-2-git-send-email-julien.grall@citrix.com>
References: <1441640038-23615-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, ian.campbell@citrix.com,
 stefano.stabellini@eu.citrix.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Julien
 Grall <julien.grall@citrix.com>, linux-arm-kernel@lists.infradead.org
To: <xen-devel@lists.xenproject.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1441640038-23615-1-git-send-email-julien.grall@citrix.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
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
index 7c64c74..d4c1bc7 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -277,6 +277,13 @@ static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb
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
 
@@ -336,13 +343,6 @@ static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb
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
