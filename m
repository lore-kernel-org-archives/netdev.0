From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH] xen/netfront: handle compound page
 fragments on transmit
Date: Tue, 20 Nov 2012 13:35:16 +0000
Message-ID: <1353418516.13542.38.camel@zakaz.uk.xensource.com>
References: <1353403286.18229.159.camel@zakaz.uk.xensource.com>
	 <1353411606-15940-1-git-send-email-ian.campbell@citrix.com>
	 <50AB856D02000078000A9EFD@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stefan Bader <stefan.bader@canonical.com>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	Eric Dumazet <edumazet@google.com>,
	"Konrad Rzeszutek Wilk" <konrad@kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	ANNIE LI <annie.li@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:1550 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752421Ab2KTNfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 08:35:19 -0500
In-Reply-To: <50AB856D02000078000A9EFD@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-20 at 12:28 +0000, Jan Beulich wrote:
> >>> On 20.11.12 at 12:40, Ian Campbell <ian.campbell@citrix.com> wrote:
> > An SKB paged fragment can consist of a compound page with order > 0.
> > However the netchannel protocol deals only in PAGE_SIZE frames.
> > 
> > Handle this in xennet_make_frags by iterating over the frames which
> > make up the page.
> > 
> > This is the netfront equivalent to 6a8ed462f16b for netback.
> 
> Wouldn't you need to be at least a little more conservative here
> with respect to resource use: I realize that get_id_from_freelist()
> return values were never checked, and failure of
> gnttab_claim_grant_reference() was always dealt with via
> BUG_ON(), but considering that netfront_tx_slot_available()
> doesn't account for compound page fragments, I think this (lack
> of) error handling needs improvement in the course of the
> change here (regardless of - I think - someone having said that
> usually the sum of all pages referenced from an skb's fragments
> would not exceed MAX_SKB_FRAGS - "usually" just isn't enough
> imo).

I think it is more than "usually", it is derived from the number of
pages needed to contain 64K of data which is the maximum size of the
data associated with an skb (AIUI).

Unwinding from failure in xennet_make_frags looks pretty tricky, but how
about this incremental patch:

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index a12b99a..06d0a84 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -505,6 +505,46 @@ static void xennet_make_frags(struct sk_buff *skb, struct net_device *dev,
 	np->tx.req_prod_pvt = prod;
 }
 
+/*
+ * Count how many ring slots are required to send the frags of this
+ * skb. Each frag might be a compound page.
+ */
+static int xennet_count_skb_frag_pages(struct sk_buff *skb)
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
+		while (size > 0) {
+			unsigned long bytes;
+
+			BUG_ON(offset >= PAGE_SIZE);
+
+			bytes = PAGE_SIZE - offset;
+			if (bytes > size)
+				bytes = size;
+
+			offset += bytes;
+			size -= bytes;
+
+			/* Next frame */
+			if (offset == PAGE_SIZE && size) {
+				pages++;
+				offset = 0;
+			}
+		}
+	}
+
+	return pages;
+}
+
 static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned short id;
@@ -517,12 +557,13 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	grant_ref_t ref;
 	unsigned long mfn;
 	int notify;
-	int frags = skb_shinfo(skb)->nr_frags;
+	int frags;
 	unsigned int offset = offset_in_page(data);
 	unsigned int len = skb_headlen(skb);
 	unsigned long flags;
 
-	frags += DIV_ROUND_UP(offset + len, PAGE_SIZE);
+	frags = xennet_count_skb_frag_pages(skb) +
+		DIV_ROUND_UP(offset + len, PAGE_SIZE);
 	if (unlikely(frags > MAX_SKB_FRAGS + 1)) {
 		printk(KERN_ALERT "xennet: skb rides the rocket: %d frags\n",
 		       frags);
