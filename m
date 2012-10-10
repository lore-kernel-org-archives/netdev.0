From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] compound skb frag pages appearing in start_xmit
Date: Wed, 10 Oct 2012 11:13:04 +0100
Message-ID: <1349863984.10070.26.camel@zakaz.uk.xensource.com>
References: <1349790467.21847.185.camel@zakaz.uk.xensource.com>
	 <1349790863.21172.4406.camel@edumazet-glaptop>
	 <1349792241.21847.199.camel@zakaz.uk.xensource.com>
	 <1349792847.21172.4479.camel@edumazet-glaptop>
	 <1349793630.21847.208.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	"Konrad Rzeszutek Wilk" <konrad@kernel.org>,
	xen-devel <xen-devel@lists.xen.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:60422 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754942Ab2JJKNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 06:13:07 -0400
In-Reply-To: <1349793630.21847.208.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-09 at 15:40 +0100, Ian Campbell wrote:
> On Tue, 2012-10-09 at 15:27 +0100, Eric Dumazet wrote:
> > On Tue, 2012-10-09 at 15:17 +0100, Ian Campbell wrote:
> > 
> > > Does the higher order pages effectively reduce the number of frags which
> > > are in use? e.g if MAX_SKB_FRAGS is 16, then for order-0 pages you could
> > > have 64K worth of frag data.
> > > 
> > > If we switch to order-3 pages everywhere then can the skb contain 512K
> > > of data, or does the effective maximum number of frags in an skb reduce
> > > to 2?
> > 
> > effective number of frags reduce to 2 or 3
> > 
> > (We still limit GSO packets to ~63536 bytes)
> 
> Great! Then I think the fix is more/less trivial...

The following seems to work for me.

I haven't tackled netfront yet.

8<--------------------------------------------------------------

>From 551e42e3dd203f2eb97cb082985013bb33b8f020 Mon Sep 17 00:00:00 2001
From: Ian Campbell <ian.campbell@citrix.com>
Date: Tue, 9 Oct 2012 15:51:20 +0100
Subject: [PATCH] xen: netback: handle compound page fragments on transmit.

An SKB paged fragment can consist of a compound page with order > 0.
However the netchannel protocol deals only in PAGE_SIZE frames.

Handle this in netbk_gop_frag_copy and xen_netbk_count_skb_slots by
iterating over the frames which make up the page.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Konrad Rzeszutek Wilk <konrad@kernel.org>
Cc: Sander Eikelenboom <linux@eikelenboom.it>
---
 drivers/net/xen-netback/netback.c |   40 ++++++++++++++++++++++++++++++++----
 1 files changed, 35 insertions(+), 5 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 4ebfcf3..d747e30 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -335,21 +335,35 @@ unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		unsigned long size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
+		unsigned long offset = skb_shinfo(skb)->frags[i].page_offset;
 		unsigned long bytes;
+
+		offset &= ~PAGE_MASK;
+
 		while (size > 0) {
+			BUG_ON(offset >= PAGE_SIZE);
 			BUG_ON(copy_off > MAX_BUFFER_OFFSET);
 
-			if (start_new_rx_buffer(copy_off, size, 0)) {
+			bytes = PAGE_SIZE - offset;
+
+			if (bytes > size)
+				bytes = size;
+
+			if (start_new_rx_buffer(copy_off, bytes, 0)) {
 				count++;
 				copy_off = 0;
 			}
 
-			bytes = size;
 			if (copy_off + bytes > MAX_BUFFER_OFFSET)
 				bytes = MAX_BUFFER_OFFSET - copy_off;
 
 			copy_off += bytes;
+
+			offset += bytes;
 			size -= bytes;
+
+			if (offset == PAGE_SIZE)
+				offset = 0;
 		}
 	}
 	return count;
@@ -403,14 +417,24 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 	unsigned long bytes;
 
 	/* Data must not cross a page boundary. */
-	BUG_ON(size + offset > PAGE_SIZE);
+	BUG_ON(size + offset > PAGE_SIZE<<compound_order(page));
 
 	meta = npo->meta + npo->meta_prod - 1;
 
+	/* Skip unused frames from start of page */
+	page += offset >> PAGE_SHIFT;
+	offset &= ~PAGE_MASK;
+
 	while (size > 0) {
+		BUG_ON(offset >= PAGE_SIZE);
 		BUG_ON(npo->copy_off > MAX_BUFFER_OFFSET);
 
-		if (start_new_rx_buffer(npo->copy_off, size, *head)) {
+		bytes = PAGE_SIZE - offset;
+
+		if (bytes > size)
+			bytes = size;
+
+		if (start_new_rx_buffer(npo->copy_off, bytes, *head)) {
 			/*
 			 * Netfront requires there to be some data in the head
 			 * buffer.
@@ -420,7 +444,6 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 			meta = get_next_rx_buffer(vif, npo);
 		}
 
-		bytes = size;
 		if (npo->copy_off + bytes > MAX_BUFFER_OFFSET)
 			bytes = MAX_BUFFER_OFFSET - npo->copy_off;
 
@@ -453,6 +476,13 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 		offset += bytes;
 		size -= bytes;
 
+		/* Next frame */
+		if (offset == PAGE_SIZE) {
+			BUG_ON(!PageCompound(page));
+			page++;
+			offset = 0;
+		}
+
 		/* Leave a gap for the GSO descriptor. */
 		if (*head && skb_shinfo(skb)->gso_size && !vif->gso_prefix)
 			vif->rx.req_cons++;
-- 
1.7.2.5
