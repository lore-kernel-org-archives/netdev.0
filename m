From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: skb_segment() provides list head and tail
Date: Fri, 03 Oct 2014 20:59:19 -0700
Message-ID: <1412395159.17245.33.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141001203345.3321.99675.stgit@dragon>
	 <20141003.123806.183331913071081861.davem@davemloft.net>
	 <1412369869.17245.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141003.145647.1980640682969765484.davem@davemloft.net>
	 <1412373477.17245.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1412375467.17245.16.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, therbert@google.com,
	hannes@stressinduktion.org, fw@strlen.de, dborkman@redhat.com,
	jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:46164 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944AbaJDD6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 23:58:42 -0400
Received: by mail-pa0-f47.google.com with SMTP id rd3so2484457pab.20
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 20:58:40 -0700 (PDT)
In-Reply-To: <1412375467.17245.16.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Its unfortunate we have to walk again skb list to find the tail
after segmentation, even if data is probably hot in cpu caches.

skb_segment() can store the tail of the list into segs->prev,
and validate_xmit_skb_list() can immediately get the tail.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dev.c    |   27 +++++++++++++++------------
 net/core/skbuff.c |    5 +++++
 2 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 1a90530f83ff..7d5691cc1f47 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2724,22 +2724,25 @@ struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *d
 {
 	struct sk_buff *next, *head = NULL, *tail;
 
-	while (skb) {
+	for (; skb != NULL; skb = next) {
 		next = skb->next;
 		skb->next = NULL;
+
+		/* in case skb wont be segmented, point to itself */
+		skb->prev = skb;
+
 		skb = validate_xmit_skb(skb, dev);
-		if (skb) {
-			struct sk_buff *end = skb;
+		if (!skb)
+			continue;
 
-			while (end->next)
-				end = end->next;
-			if (!head)
-				head = skb;
-			else
-				tail->next = skb;
-			tail = end;
-		}
-		skb = next;
+		if (!head)
+			head = skb;
+		else
+			tail->next = skb;
+		/* If skb was segmented, skb->prev points to
+		 * the last segment. If not, it still contains skb.
+		 */
+		tail = skb->prev;
 	}
 	return head;
 }
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index a0b312fa3047..06b57ec91f32 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3083,6 +3083,11 @@ perform_csum_check:
 		}
 	} while ((offset += len) < head_skb->len);
 
+	/* Some callers want to get the end of the list.
+	 * Put it in segs->prev to avoid walking the list.
+	 * (see validate_xmit_skb_list() for example)
+	 */
+	segs->prev = tail;
 	return segs;
 
 err:
