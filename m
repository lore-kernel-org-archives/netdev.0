From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: skb_can_coalesce returns a boolean
Date: Tue, 24 Apr 2012 05:48:27 +0200
Message-ID: <1335239307.5205.125.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:42744 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064Ab2DXDsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 23:48:32 -0400
Received: by wejx9 with SMTP id x9so126317wej.19
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2012 20:48:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/skbuff.h |    6 +++---
 net/ipv4/tcp.c         |    3 ++-
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f25795c..4a656b5 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1963,8 +1963,8 @@ static inline int skb_add_data(struct sk_buff *skb,
 	return -EFAULT;
 }
 
-static inline int skb_can_coalesce(struct sk_buff *skb, int i,
-				   const struct page *page, int off)
+static inline bool skb_can_coalesce(struct sk_buff *skb, int i,
+				    const struct page *page, int off)
 {
 	if (i) {
 		const struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i - 1];
@@ -1972,7 +1972,7 @@ static inline int skb_can_coalesce(struct sk_buff *skb, int i,
 		return page == skb_frag_page(frag) &&
 		       off == frag->page_offset + skb_frag_size(frag);
 	}
-	return 0;
+	return false;
 }
 
 static inline int __skb_linearize(struct sk_buff *skb)
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index bcc4eab..de6a238 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -848,9 +848,10 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffse
 	while (psize > 0) {
 		struct sk_buff *skb = tcp_write_queue_tail(sk);
 		struct page *page = pages[poffset / PAGE_SIZE];
-		int copy, i, can_coalesce;
+		int copy, i;
 		int offset = poffset % PAGE_SIZE;
 		int size = min_t(size_t, psize, PAGE_SIZE - offset);
+		bool can_coalesce;
 
 		if (!tcp_send_head(sk) || (copy = size_goal - skb->len) <= 0) {
 new_segment:
