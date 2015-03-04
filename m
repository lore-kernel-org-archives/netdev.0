From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv2 3/3] xen-netback: refactor xenvif_handle_frag_list()
Date: Wed, 4 Mar 2015 11:14:48 +0000
Message-ID: <1425467688-12846-4-git-send-email-david.vrabel@citrix.com>
References: <1425467688-12846-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:27909 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932943AbbCDLPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 06:15:00 -0500
In-Reply-To: <1425467688-12846-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When handling a from-guest frag list, xenvif_handle_frag_list()
replaces the frags before calling the destructor to clean up the
original (foreign) frags.  Whilst this is safe (the destructor doesn't
actually use the frags), it looks odd.

Reorder the function to be less confusing.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netback/netback.c |   21 +++++++++------------
 1 file changed, 9 insertions(+), 12 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index f5560cd..56c4a81 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1384,27 +1384,24 @@ static int xenvif_handle_frag_list(struct xenvif_queue *queue, struct sk_buff *s
 		skb_frag_size_set(&frags[i], len);
 	}
 
+	/* Copied all the bits from the frag list -- free it. */
+	skb_frag_list_init(skb);
+	xenvif_skb_zerocopy_prepare(queue, nskb);
+	kfree_skb(nskb);
+
 	/* Release all the original (foreign) frags. */
 	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++)
 		skb_frag_unref(skb, f);
-
-	/* swap out with old one */
-	memcpy(skb_shinfo(skb)->frags,
-	       frags,
-	       i * sizeof(skb_frag_t));
-	skb_shinfo(skb)->nr_frags = i;
-	skb->truesize += i * PAGE_SIZE;
-
-	/* remove traces of mapped pages and frag_list */
-	skb_frag_list_init(skb);
 	uarg = skb_shinfo(skb)->destructor_arg;
 	/* increase inflight counter to offset decrement in callback */
 	atomic_inc(&queue->inflight_packets);
 	uarg->callback(uarg, true);
 	skb_shinfo(skb)->destructor_arg = NULL;
 
-	xenvif_skb_zerocopy_prepare(queue, nskb);
-	kfree_skb(nskb);
+	/* Fill the skb with the new (local) frags. */
+	memcpy(skb_shinfo(skb)->frags, frags, i * sizeof(skb_frag_t));
+	skb_shinfo(skb)->nr_frags = i;
+	skb->truesize += i * PAGE_SIZE;
 
 	return 0;
 }
-- 
1.7.10.4
