From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: gre: fix ip6gre_err()
Date: Sun, 19 Aug 2012 15:47:30 +0200
Message-ID: <1345384050.5158.208.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Dmitry Kozlov <xeb@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:40561 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751687Ab2HSNrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Aug 2012 09:47:37 -0400
Received: by wgbdr13 with SMTP id dr13so4646863wgb.1
        for <netdev@vger.kernel.org>; Sun, 19 Aug 2012 06:47:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

ip6gre_err() miscomputes grehlen (sizeof(ipv6h) is 4 or 8,
not 40 as expected), and should take into account 'offset' parameter.

Also uses pskb_may_pull() to cope with some fragged skbs

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Dmitry Kozlov <xeb@mail.ru>
---
 net/ipv6/ip6_gre.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index a84ad5d..424d11a 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -415,8 +415,8 @@ static void ip6gre_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		u8 type, u8 code, int offset, __be32 info)
 {
 	const struct ipv6hdr *ipv6h = (const struct ipv6hdr *)skb->data;
-	__be16 *p = (__be16 *)(ipv6h + 1);
-	int grehlen = sizeof(ipv6h) + 4;
+	__be16 *p = (__be16 *)(skb->data + offset);
+	int grehlen = offset + 4;
 	struct ip6_tnl *t;
 	__be16 flags;
 
@@ -432,8 +432,10 @@ static void ip6gre_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	}
 
 	/* If only 8 bytes returned, keyed message will be dropped here */
-	if (skb_headlen(skb) < grehlen)
+	if (!pskb_may_pull(skb, grehlen))
 		return;
+	ipv6h = (const struct ipv6hdr *)skb->data;
+	p = (__be16 *)(skb->data + offset);
 
 	rcu_read_lock();
 
