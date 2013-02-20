From: Cong Wang <amwang@redhat.com>
Subject: [Patch] net: fix a wrong assignment in skb_split()
Date: Wed, 20 Feb 2013 16:51:30 +0800
Message-ID: <1361350290-28581-1-git-send-email-amwang@redhat.com>
Cc: Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44074 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756933Ab3BTIvx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2013 03:51:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit c9af6db4c11ccc6c3e7f1 (net: Fix possible wrong checksum generation)
has a suspicous piece:

	-       skb_shinfo(skb1)->gso_type = skb_shinfo(skb)->gso_type;
	-
	+       skb_shinfo(skb)->tx_flags = skb_shinfo(skb1)->tx_flags & SKBTX_SHARED_FRAG;

skb1 is the new skb, therefore should be on the left side of the assignment.
This patch fixes it.

Cc: Pravin B Shelar <pshelar@nicira.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2a3ca33..33245ef 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2326,7 +2326,7 @@ void skb_split(struct sk_buff *skb, struct sk_buff *skb1, const u32 len)
 {
 	int pos = skb_headlen(skb);
 
-	skb_shinfo(skb)->tx_flags = skb_shinfo(skb1)->tx_flags & SKBTX_SHARED_FRAG;
+	skb_shinfo(skb1)->tx_flags = skb_shinfo(skb)->tx_flags & SKBTX_SHARED_FRAG;
 	if (len < pos)	/* Split line is inside header. */
 		skb_split_inside_header(skb, skb1, len, pos);
 	else		/* Second chunk has no header, nothing to copy. */
