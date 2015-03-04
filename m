From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv2 2/3] xen-netback: unref frags when handling a from-guest skb with a frag list
Date: Wed, 4 Mar 2015 11:14:47 +0000
Message-ID: <1425467688-12846-3-git-send-email-david.vrabel@citrix.com>
References: <1425467688-12846-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:8652 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932926AbbCDLPA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2015 06:15:00 -0500
In-Reply-To: <1425467688-12846-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Every time a VIF is destroyed up to 256 pages may be leaked if packets
with more than MAX_SKB_FRAGS frags were transmitted from the guest.
Even worse, if another user of ballooned pages allocated one of these
ballooned pages it would not handle the unexpectedly >1 page count
(e.g., gntdev would deadlock when unmapping a grant because the page
count would never reach 1).

When handling a from-guest skb with a frag list, unref the frags
before releasing them so they are freed correctly when the VIF is
destroyed.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netback/netback.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index f7a31d2..f5560cd 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1343,7 +1343,7 @@ static int xenvif_handle_frag_list(struct xenvif_queue *queue, struct sk_buff *s
 {
 	unsigned int offset = skb_headlen(skb);
 	skb_frag_t frags[MAX_SKB_FRAGS];
-	int i;
+	int i, f;
 	struct ubuf_info *uarg;
 	struct sk_buff *nskb = skb_shinfo(skb)->frag_list;
 
@@ -1383,6 +1383,11 @@ static int xenvif_handle_frag_list(struct xenvif_queue *queue, struct sk_buff *s
 		frags[i].page_offset = 0;
 		skb_frag_size_set(&frags[i], len);
 	}
+
+	/* Release all the original (foreign) frags. */
+	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++)
+		skb_frag_unref(skb, f);
+
 	/* swap out with old one */
 	memcpy(skb_shinfo(skb)->frags,
 	       frags,
-- 
1.7.10.4
