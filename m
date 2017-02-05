From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ip6_gre: fix ip6gre_err() invalid reads
Date: Sat, 04 Feb 2017 23:18:55 -0800
Message-ID: <1486279135.7793.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36409 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751385AbdBEHS6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 02:18:58 -0500
Received: by mail-io0-f196.google.com with SMTP id q20so6264683ioi.3
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 23:18:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Andrey Konovalov reported out of bound accesses in ip6gre_err()

If GRE flags contains GRE_KEY, the following expression
*(((__be32 *)p) + (grehlen / 4) - 1)

accesses data ~40 bytes after the expected point, since
grehlen includes the size of IPv6 headers.

Let's use a "struct gre_base_hdr *greh" pointer to make this
code more readable. 

p[1] becomes greh->protocol.
grhlen is the GRE header length.

Fixes: c12b395a4664 ("gre: Support GRE over IPv6")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Andrey Konovalov <andreyknvl@google.com>
---
 net/ipv6/ip6_gre.c |   40 +++++++++++++++++++++-------------------
 1 file changed, 21 insertions(+), 19 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 558631860d91bbcb1321a4b566b6e92ddcaf7163..630b73be599977599c0021849fc6eb689cfefad7 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -367,35 +367,37 @@ static void ip6gre_tunnel_uninit(struct net_device *dev)
 
 
 static void ip6gre_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
-		u8 type, u8 code, int offset, __be32 info)
+		       u8 type, u8 code, int offset, __be32 info)
 {
-	const struct ipv6hdr *ipv6h = (const struct ipv6hdr *)skb->data;
-	__be16 *p = (__be16 *)(skb->data + offset);
-	int grehlen = offset + 4;
+	const struct gre_base_hdr *greh;
+	const struct ipv6hdr *ipv6h;
+	int grehlen = sizeof(*greh);
 	struct ip6_tnl *t;
+	int key_off = 0;
 	__be16 flags;
+	__be32 key;
 
-	flags = p[0];
-	if (flags&(GRE_CSUM|GRE_KEY|GRE_SEQ|GRE_ROUTING|GRE_VERSION)) {
-		if (flags&(GRE_VERSION|GRE_ROUTING))
-			return;
-		if (flags&GRE_KEY) {
-			grehlen += 4;
-			if (flags&GRE_CSUM)
-				grehlen += 4;
-		}
+	if (!pskb_may_pull(skb, offset + grehlen))
+		return;
+	greh = (const struct gre_base_hdr *)(skb->data + offset);
+	flags = greh->flags;
+	if (flags & (GRE_VERSION | GRE_ROUTING))
+		return;
+	if (flags & GRE_CSUM)
+		grehlen += 4;
+	if (flags & GRE_KEY) {
+		key_off = grehlen + offset;
+		grehlen += 4;
 	}
 
-	/* If only 8 bytes returned, keyed message will be dropped here */
-	if (!pskb_may_pull(skb, grehlen))
+	if (!pskb_may_pull(skb, offset + grehlen))
 		return;
 	ipv6h = (const struct ipv6hdr *)skb->data;
-	p = (__be16 *)(skb->data + offset);
+	greh = (const struct gre_base_hdr *)(skb->data + offset);
+	key = key_off ? *(__be32 *)(skb->data + key_off) : 0;
 
 	t = ip6gre_tunnel_lookup(skb->dev, &ipv6h->daddr, &ipv6h->saddr,
-				flags & GRE_KEY ?
-				*(((__be32 *)p) + (grehlen / 4) - 1) : 0,
-				p[1]);
+				 key, greh->protocol);
 	if (!t)
 		return;
 
