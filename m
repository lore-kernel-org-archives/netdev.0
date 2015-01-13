From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCH 2/3] xen-netfront: refactor skb slot counting
Date: Tue, 13 Jan 2015 17:16:43 +0000
Message-ID: <1421169404-27461-3-git-send-email-david.vrabel@citrix.com>
References: <1421169404-27461-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:10640 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752228AbbAMRUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 12:20:23 -0500
In-Reply-To: <1421169404-27461-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A function to count the number of slots an skb needs is more useful
than one that counts the slots needed for only the frags.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netfront.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 22bcb4e..6b29b3a 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -521,13 +521,15 @@ static void xennet_make_frags(struct sk_buff *skb, struct netfront_queue *queue,
 }
 
 /*
- * Count how many ring slots are required to send the frags of this
- * skb. Each frag might be a compound page.
+ * Count how many ring slots are required to send this skb. Each frag
+ * might be a compound page.
  */
-static int xennet_count_skb_frag_slots(struct sk_buff *skb)
+static int xennet_count_skb_slots(struct sk_buff *skb)
 {
 	int i, frags = skb_shinfo(skb)->nr_frags;
-	int pages = 0;
+	int pages;
+
+	pages = PFN_UP(offset_in_page(skb->data) + skb_headlen(skb));
 
 	for (i = 0; i < frags; i++) {
 		skb_frag_t *frag = skb_shinfo(skb)->frags + i;
@@ -597,8 +599,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto drop;
 	}
 
-	slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
-		xennet_count_skb_frag_slots(skb);
+	slots = xennet_count_skb_slots(skb);
 	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
 		net_dbg_ratelimited("xennet: skb rides the rocket: %d slots, %d bytes\n",
 				    slots, skb->len);
-- 
1.7.10.4
