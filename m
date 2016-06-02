From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH v3 3/7] sk_buff: allow segmenting based on frag sizes
Date: Thu,  2 Jun 2016 15:05:40 -0300
Message-ID: <6a625144a5410e00dc4f27a0037622e5fc2a5e0f.1464888549.git.marcelo.leitner@gmail.com>
References: <cover.1464888549.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Xin Long <lucien.xin@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53352 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161485AbcFBSGH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2016 14:06:07 -0400
In-Reply-To: <cover.1464888549.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows segmenting a skb based on its frags sizes instead of
based on a fixed value.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Tested-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/skbuff.h |  5 +++++
 net/core/skbuff.c      | 10 +++++++---
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ee38a41274759f279be1c0752a7fab63fac517c8..329a0a9ef67115cae03b7c1304de031116384148 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -301,6 +301,11 @@ struct sk_buff;
 #endif
 extern int sysctl_max_skb_frags;
 
+/* Set skb_shinfo(skb)->gso_size to this in case you want skb_segment to
+ * segment using its current segmentation instead.
+ */
+#define GSO_BY_FRAGS	0xFFFF
+
 typedef struct skb_frag_struct skb_frag_t;
 
 struct skb_frag_struct {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 4724bcf9b0cae1cecbe5bc2c04e308bb70b3232a..97c32c75e704af1f31b064e8f1e0475ff1505d67 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3116,9 +3116,13 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 		int hsize;
 		int size;
 
-		len = head_skb->len - offset;
-		if (len > mss)
-			len = mss;
+		if (unlikely(mss == GSO_BY_FRAGS)) {
+			len = list_skb->len;
+		} else {
+			len = head_skb->len - offset;
+			if (len > mss)
+				len = mss;
+		}
 
 		hsize = skb_headlen(head_skb) - offset;
 		if (hsize < 0)
-- 
2.5.5
