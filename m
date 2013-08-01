From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: add a temporary sanity check in skb_orphan()
Date: Thu, 01 Aug 2013 11:43:08 -0700
Message-ID: <1375382588.10515.181.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:57662 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050Ab3HASnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 14:43:11 -0400
Received: by mail-pd0-f178.google.com with SMTP id w10so2351978pde.9
        for <netdev@vger.kernel.org>; Thu, 01 Aug 2013 11:43:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

David suggested to add a BUG_ON() to catch if some layer
sets skb->sk pointer without a corresponding destructor.

As skb can sit in a queue, it's mandatory to make sure the
socket cannot disappear, and it's usually done by taking a
reference on the socket, then releasing it from the skb
destructor.

This patch is a follow-up to commit c34a761231b5
("net: skb_orphan() changes") and will be reverted after
catching all possible offenders if any.

Suggested-by: David Miller <davem@davemloft.net>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/skbuff.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a95547a..d48de68 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1809,6 +1809,8 @@ static inline void skb_orphan(struct sk_buff *skb)
 		skb->destructor(skb);
 		skb->destructor = NULL;
 		skb->sk		= NULL;
+	} else {
+		BUG_ON(skb->sk);
 	}
 }
 
