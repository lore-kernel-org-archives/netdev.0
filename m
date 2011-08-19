From: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 29/75] greth: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:27:01 +0100
Message-ID: <1313760467-8598-29-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1313760393.5010.356.camel-o4Be2W7LfRlXesXXhkcM7miJhflN2719@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

In order to avoid long lines also use phys_to_virt(page_to_phys(page)) =>
page_address(page) (since the are effectively the same thing for lowmem pages).

Also dump the frag's size instead of the headlen when dumping a frag.

Signed-off-by: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Cc: Kristoffer Glembo <kristoffer-FkzTOoA/JUlBDgjK7y7TUQ@public.gmane.org>
Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
---
 drivers/net/greth.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index 16ce45c..562a251 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -113,9 +113,8 @@ static void greth_print_tx_packet(struct sk_buff *skb)
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 
 		print_hex_dump(KERN_DEBUG, "TX: ", DUMP_PREFIX_OFFSET, 16, 1,
-			       phys_to_virt(page_to_phys(skb_shinfo(skb)->frags[i].page)) +
-			       skb_shinfo(skb)->frags[i].page_offset,
-			       length, true);
+			       skb_frag_address(&skb_shinfo(skb)->frags[i]),
+			       skb_shinfo(skb)->frags[i].size, true);
 	}
 }
 
@@ -528,11 +527,8 @@ greth_start_xmit_gbit(struct sk_buff *skb, struct net_device *dev)
 
 		greth_write_bd(&bdp->stat, status);
 
-		dma_addr = dma_map_page(greth->dev,
-					frag->page,
-					frag->page_offset,
-					frag->size,
-					DMA_TO_DEVICE);
+		dma_addr = skb_frag_dma_map(greth->dev, frag, 0, frag->size,
+					    DMA_TO_DEVICE);
 
 		if (unlikely(dma_mapping_error(greth->dev, dma_addr)))
 			goto frag_map_error;
-- 
1.7.2.5
