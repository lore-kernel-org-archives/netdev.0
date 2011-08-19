From: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 20/75] cassini: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:26:52 +0100
Message-ID: <1313760467-8598-20-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>, Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	David Decotigny <decot-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

Signed-off-by: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: David Decotigny <decot-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
---
 drivers/net/cassini.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 646c86b..de5c7590 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2048,8 +2048,8 @@ static int cas_rx_process_pkt(struct cas *cp, struct cas_rx_comp *rxc,
 		skb->truesize += hlen - swivel;
 		skb->len      += hlen - swivel;
 
-		get_page(page->buffer);
-		frag->page = page->buffer;
+		__skb_frag_set_page(frag, page->buffer);
+		__skb_frag_ref(frag);
 		frag->page_offset = off;
 		frag->size = hlen - swivel;
 
@@ -2072,8 +2072,8 @@ static int cas_rx_process_pkt(struct cas *cp, struct cas_rx_comp *rxc,
 			skb->len      += hlen;
 			frag++;
 
-			get_page(page->buffer);
-			frag->page = page->buffer;
+			__skb_frag_set_page(frag, page->buffer);
+			__skb_frag_ref(frag);
 			frag->page_offset = 0;
 			frag->size = hlen;
 			RX_USED_ADD(page, hlen + cp->crc_size);
@@ -2830,9 +2830,8 @@ static inline int cas_xmit_tx_ringN(struct cas *cp, int ring,
 		skb_frag_t *fragp = &skb_shinfo(skb)->frags[frag];
 
 		len = fragp->size;
-		mapping = pci_map_page(cp->pdev, fragp->page,
-				       fragp->page_offset, len,
-				       PCI_DMA_TODEVICE);
+		mapping = skb_frag_dma_map(&cp->pdev->dev, fragp, 0, len,
+					   PCI_DMA_TODEVICE);
 
 		tabort = cas_calc_tabort(cp, fragp->page_offset, len);
 		if (unlikely(tabort)) {
@@ -2843,7 +2842,7 @@ static inline int cas_xmit_tx_ringN(struct cas *cp, int ring,
 				      ctrl, 0);
 			entry = TX_DESC_NEXT(ring, entry);
 
-			addr = cas_page_map(fragp->page);
+			addr = cas_page_map(skb_frag_page(fragp));
 			memcpy(tx_tiny_buf(cp, ring, entry),
 			       addr + fragp->page_offset + len - tabort,
 			       tabort);
-- 
1.7.2.5
