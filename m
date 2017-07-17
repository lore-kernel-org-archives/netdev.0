From: Lin Zhang <xiaolou4617@gmail.com>
Subject: [PATCH net-next v2 resubmit] skbuff: optimize the pull_pages code in __pskb_pull_tail()
Date: Mon, 17 Jul 2017 17:25:02 +0800
Message-ID: <1500283502-36546-1-git-send-email-xiaolou4617@gmail.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        Lin Zhang <xiaolou4617@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36609 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751178AbdGQJZP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 05:25:15 -0400
Received: by mail-pg0-f65.google.com with SMTP id y129so18853831pgy.3
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 02:25:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the pull_pages code block, if the first frag size > eat,
we can end the loop in advance to avoid extra copy.

Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>
---
v1 -> v2:
	* no need to rewrite skb_shinfo(skb)->nr_frags, per Eric Dumazet.
---
 net/core/skbuff.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f990eb8..af61065 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1719,6 +1719,8 @@ void *__pskb_pull_tail(struct sk_buff *skb, int delta)
 			if (eat) {
 				skb_shinfo(skb)->frags[k].page_offset += eat;
 				skb_frag_size_sub(&skb_shinfo(skb)->frags[k], eat);
+				if (!i)
+					goto end;
 				eat = 0;
 			}
 			k++;
@@ -1726,6 +1728,7 @@ void *__pskb_pull_tail(struct sk_buff *skb, int delta)
 	}
 	skb_shinfo(skb)->nr_frags = k;
 
+end:
 	skb->tail     += delta;
 	skb->data_len -= delta;
 
-- 
1.8.3.1
