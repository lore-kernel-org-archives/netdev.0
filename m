From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: do not read sk_drops if application does not
 care
Date: Wed, 07 Dec 2016 10:05:36 -0800
Message-ID: <1481133936.4930.51.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Paolo Abeni <pabeni@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36851 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752441AbcLGSGj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 13:06:39 -0500
Received: by mail-pf0-f196.google.com with SMTP id c4so20947902pfb.3
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 10:06:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

sk_drops can be an often written field, do not read it unless
application showed interest.

Note that sk_drops can be read via inet_diag, so applications
can avoid getting this info from every received packet.

In the future, 'reading' sk_drops might require folding per node or per
cpu fields, and thus become even more expensive than today.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Paolo Abeni <pabeni@redhat.com>
---
 include/net/sock.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 1749e38d03014558ac882b5d1fb37b11ac5e6705..be167c1483f4a5a74b466f135bbfdf4281e5bef4 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2160,7 +2160,8 @@ struct sock_skb_cb {
 static inline void
 sock_skb_set_dropcount(const struct sock *sk, struct sk_buff *skb)
 {
-	SOCK_SKB_CB(skb)->dropcount = atomic_read(&sk->sk_drops);
+	SOCK_SKB_CB(skb)->dropcount = sock_flag(sk, SOCK_RXQ_OVFL) ?
+						atomic_read(&sk->sk_drops) : 0;
 }
 
 static inline void sk_drops_add(struct sock *sk, const struct sk_buff *skb)
