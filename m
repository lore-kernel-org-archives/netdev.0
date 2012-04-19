From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: allow better page reuse in splice(sock ->
 pipe)
Date: Thu, 19 Apr 2012 21:38:17 +0200
Message-ID: <1334864297.2395.220.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57232 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932254Ab2DSTiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 15:38:23 -0400
Received: by bkcik5 with SMTP id ik5so6666694bkc.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 12:38:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

splice() from socket to pipe needs linear_to_page() helper to transfert
skb header to part of page.

We can reset the offset in the current sk->sk_sndmsg_page if we are the
last user of the page.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/skbuff.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 43c490d..bf257de 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1565,6 +1565,9 @@ new_page:
 	} else {
 		unsigned int mlen;
 
+		/* If we are the only user of the page, we can reset offset */
+		if (page_count(p) == 1)
+			sk->sk_sndmsg_off = 0;
 		off = sk->sk_sndmsg_off;
 		mlen = PAGE_SIZE - off;
 		if (mlen < 64 && mlen < *len) {
