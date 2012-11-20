From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH V2] xen/netfront: handle compound page fragments on transmit
Date: Tue, 20 Nov 2012 16:00:57 +0000
Message-ID: <1353427257-16789-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>, xen-devel@lists.xen.org,
	Eric Dumazet <edumazet@google.com>,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	ANNIE LI <annie.li@oracle.com>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	Stefan Bader <stefan.bader@canonical.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:41281 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752343Ab2KTQFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 11:05:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An SKB paged fragment can consist of a compound page with order > 0.
However the netchannel protocol deals only in PAGE_SIZE frames.

Handle this in xennet_make_frags by iterating over the frames which
make up the page.

This is the netfront equivalent to 6a8ed462f16b for netback.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org
Cc: xen-devel@lists.xen.org
Cc: Eric Dumazet <edumazet@google.com>
Cc: Konrad Rzeszutek Wilk <konrad@kernel.org>
Cc: ANNIE LI <annie.li@oracle.com>
Cc: Sander Eikelenboom <linux@eikelenboom.it>
Cc: Stefan Bader <stefan.bader@canonical.com>
---
v2: check we have enough room in the ring and that the other end can
    cope with the number of slots in a single frame
---
 drivers/net/xen-netfront.c |   95 ++++++++++++++++++++++++++++++++++----------
 1 files changed, 74 insertions(+), 21 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index caa0110..d9b16f4 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -452,29 +452,82 @@ static void xennet_make_frags(struct sk_buff *skb, struct net_device *dev,
 	/* Grant backend access to each skb fragment page. */
 	for (i = 0; i < frags; i++) {
 		skb_frag_t *frag = skb_shinfo(skb)->frags + i;
+		struct page *page = skb_frag_page(frag);
+		unsigned long size = skb_frag_size(frag);
+		unsigned long offset = frag->page_offset;
 
-		tx->flags |= XEN_NETTXF_more_data;
+		/* Data must not cross a page boundary. */
+		BUG_ON(size + offset > PAGE_SIZE<<compound_order(page));
 
-		id = get_id_from_freelist(&np->tx_skb_freelist, np->tx_skbs);
-		np->tx_skbs[id].skb = skb_get(skb);
-		tx = RING_GET_REQUEST(&np->tx, prod++);
-		tx->id = id;
-		ref = gnttab_claim_grant_reference(&np->gref_tx_head);
-		BUG_ON((signed short)ref < 0);
+		/* Skip unused frames from start of page */
+		page += offset >> PAGE_SHIFT;
+		offset &= ~PAGE_MASK;
 
-		mfn = pfn_to_mfn(page_to_pfn(skb_frag_page(frag)));
-		gnttab_grant_foreign_access_ref(ref, np->xbdev->otherend_id,
-						mfn, GNTMAP_readonly);
+		while (size > 0) {
+			unsigned long bytes;
 
-		tx->gref = np->grant_tx_ref[id] = ref;
-		tx->offset = frag->page_offset;
-		tx->size = skb_frag_size(frag);
-		tx->flags = 0;
+			BUG_ON(offset >= PAGE_SIZE);
+
+			bytes = PAGE_SIZE - offset;
+			if (bytes > size)
+				bytes = size;
+
+			tx->flags |= XEN_NETTXF_more_data;
+
+			id = get_id_from_freelist(&np->tx_skb_freelist, np->tx_skbs);
+			np->tx_skbs[id].skb = skb_get(skb);
+			tx = RING_GET_REQUEST(&np->tx, prod++);
+			tx->id = id;
+			ref = gnttab_claim_grant_reference(&np->gref_tx_head);
+			BUG_ON((signed short)ref < 0);
+
+			mfn = pfn_to_mfn(page_to_pfn(page));
+			gnttab_grant_foreign_access_ref(ref, np->xbdev->otherend_id,
+							mfn, GNTMAP_readonly);
+
+			tx->gref = np->grant_tx_ref[id] = ref;
+			tx->offset = offset;
+			tx->size = bytes;
+			tx->flags = 0;
+
+			offset += bytes;
+			size -= bytes;
+
+			/* Next frame */
+			if (offset == PAGE_SIZE && size) {
+				BUG_ON(!PageCompound(page));
+				page++;
+				offset = 0;
+			}
+		}
 	}
 
 	np->tx.req_prod_pvt = prod;
 }
 
+/*
+ * Count how many ring slots are required to send the frags of this
+ * skb. Each frag might be a compound page.
+ */
+static int xennet_count_skb_frag_slots(struct sk_buff *skb)
+{
+	int i, frags = skb_shinfo(skb)->nr_frags;
+	int pages = 0;
+
+	for (i = 0; i < frags; i++) {
+		skb_frag_t *frag = skb_shinfo(skb)->frags + i;
+		unsigned long size = skb_frag_size(frag);
+		unsigned long offset = frag->page_offset;
+
+		/* Skip unused frames from start of page */
+		offset &= ~PAGE_MASK;
+
+		pages += PFN_UP(offset + size);
+	}
+
+	return pages;
+}
+
 static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned short id;
@@ -487,23 +540,23 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	grant_ref_t ref;
 	unsigned long mfn;
 	int notify;
-	int frags = skb_shinfo(skb)->nr_frags;
+	int slots;
 	unsigned int offset = offset_in_page(data);
 	unsigned int len = skb_headlen(skb);
 	unsigned long flags;
 
-	frags += DIV_ROUND_UP(offset + len, PAGE_SIZE);
-	if (unlikely(frags > MAX_SKB_FRAGS + 1)) {
-		printk(KERN_ALERT "xennet: skb rides the rocket: %d frags\n",
-		       frags);
-		dump_stack();
+	slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
+		xennet_count_skb_frag_slots(skb);
+	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
+		printk(KERN_ALERT "xennet: skb rides the rocket: %d slots\n",
+		       slots);
 		goto drop;
 	}
 
 	spin_lock_irqsave(&np->tx_lock, flags);
 
 	if (unlikely(!netif_carrier_ok(dev) ||
-		     (frags > 1 && !xennet_can_sg(dev)) ||
+		     (slots > 1 && !xennet_can_sg(dev)) ||
 		     netif_needs_gso(skb, netif_skb_features(skb)))) {
 		spin_unlock_irqrestore(&np->tx_lock, flags);
 		goto drop;
-- 
1.7.2.5
