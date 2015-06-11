From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/5] tcp: reserve tcp_skb_mss() to tcp stack
Date: Thu, 11 Jun 2015 09:15:15 -0700
Message-ID: <1434039319-31309-2-git-send-email-edumazet@google.com>
References: <1434039319-31309-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:33428 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932079AbbFKQPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 12:15:32 -0400
Received: by iebgx4 with SMTP id gx4so8571559ieb.0
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 09:15:31 -0700 (PDT)
In-Reply-To: <1434039319-31309-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_gso_segment() and tcp_gro_receive() are not strictly
part of TCP stack. They should not assume tcp_skb_mss(skb)
is in fact skb_shinfo(skb)->gso_size.

This will allow us to change tcp_skb_mss() in following patches.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_offload.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 3f7c2fca5431..9864a2dbadce 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -77,7 +77,7 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 	oldlen = (u16)~skb->len;
 	__skb_pull(skb, thlen);
 
-	mss = tcp_skb_mss(skb);
+	mss = skb_shinfo(skb)->gso_size;
 	if (unlikely(skb->len <= mss))
 		goto out;
 
@@ -242,7 +242,7 @@ found:
 		flush |= *(u32 *)((u8 *)th + i) ^
 			 *(u32 *)((u8 *)th2 + i);
 
-	mss = tcp_skb_mss(p);
+	mss = skb_shinfo(p)->gso_size;
 
 	flush |= (len - 1) >= mss;
 	flush |= (ntohl(th2->seq) + skb_gro_len(p)) ^ ntohl(th->seq);
-- 
2.2.0.rc0.207.ga3a616c
