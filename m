From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: fix skb_availroom()
Date: Thu, 14 Mar 2013 16:40:32 +0100
Message-ID: <1363275632.29475.32.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Mukesh Agrawal <quiche@chromium.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:39129 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758004Ab3CNPkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 11:40:37 -0400
Received: by mail-ee0-f44.google.com with SMTP id l10so1104837eei.17
        for <netdev@vger.kernel.org>; Thu, 14 Mar 2013 08:40:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Chrome OS team reported a crash on a Pixel ChromeBook in TCP stack :

https://code.google.com/p/chromium/issues/detail?id=182056

commit a21d45726acac (tcp: avoid order-1 allocations on wifi and tx
path) did a poor choice adding an 'avail_size' field to skb, while
what we really needed was a 'reserved_tailroom' one.

It would have avoided commit 22b4a4f22da (tcp: fix retransmit of
partially acked frames) and this commit.

Crash occurs because skb_split() is not aware of the 'avail_size'
management (and should not be aware)

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Mukesh Agrawal <quiche@chromium.org>
---
 include/linux/skbuff.h |    7 +++++--
 net/ipv4/tcp.c         |    2 +-
 net/ipv4/tcp_output.c  |    1 -
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 821c7f4..6f2bb86 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -500,7 +500,7 @@ struct sk_buff {
 	union {
 		__u32		mark;
 		__u32		dropcount;
-		__u32		avail_size;
+		__u32		reserved_tailroom;
 	};
 
 	sk_buff_data_t		inner_transport_header;
@@ -1447,7 +1447,10 @@ static inline int skb_tailroom(const struct sk_buff *skb)
  */
 static inline int skb_availroom(const struct sk_buff *skb)
 {
-	return skb_is_nonlinear(skb) ? 0 : skb->avail_size - skb->len;
+	if (skb_is_nonlinear(skb))
+		return 0;
+
+	return skb->end - skb->tail - skb->reserved_tailroom;
 }
 
 /**
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 47e854f..e220207 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -775,7 +775,7 @@ struct sk_buff *sk_stream_alloc_skb(struct sock *sk, int size, gfp_t gfp)
 			 * Make sure that we have exactly size bytes
 			 * available to the caller, no more, no less.
 			 */
-			skb->avail_size = size;
+			skb->reserved_tailroom = skb->end - skb->tail - size;
 			return skb;
 		}
 		__kfree_skb(skb);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e2b4461..817fbb3 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1298,7 +1298,6 @@ static void __pskb_trim_head(struct sk_buff *skb, int len)
 	eat = min_t(int, len, skb_headlen(skb));
 	if (eat) {
 		__skb_pull(skb, eat);
-		skb->avail_size -= eat;
 		len -= eat;
 		if (!len)
 			return;
