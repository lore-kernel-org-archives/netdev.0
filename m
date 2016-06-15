From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] gre: fix error handler
Date: Tue, 14 Jun 2016 22:15:01 -0700
Message-ID: <1465967701.7945.200.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <tom@herbertland.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35042 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbcFOFPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 01:15:06 -0400
Received: by mail-pa0-f65.google.com with SMTP id hf6so714682pac.2
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 22:15:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

1) gre_parse_header() can be called from gre_err()

   At this point transport header points to ICMP header, not the inner
header.

2) We can not really change transport header as ipgre_err() will later
assume transport header still points to ICMP header.

3) pskb_may_pull() logic in gre_parse_header() really works
  if we are interested at zone pointed by skb->data

So this fix :

A) changes gre_parse_header() to use skb->data instead of
skb_transport_header()

B) changes gre_err() to pull the IPv4 header immediately following
the ICMP header that was already pulled earlier.

C) remove obsolete IPV6 includes

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tom Herbert <tom@herbertland.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
---
 net/ipv4/gre_demux.c |    4 ++--
 net/ipv4/ip_gre.c    |    9 +++------
 2 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index 4c39f4fd332a..0ba26ad9809d 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -71,7 +71,7 @@ int gre_parse_header(struct sk_buff *skb, struct tnl_=
ptk_info *tpi,
 	if (unlikely(!pskb_may_pull(skb, sizeof(struct gre_base_hdr))))
 		return -EINVAL;
=20
-	greh =3D (struct gre_base_hdr *)skb_transport_header(skb);
+	greh =3D (struct gre_base_hdr *)skb->data;
 	if (unlikely(greh->flags & (GRE_VERSION | GRE_ROUTING)))
 		return -EINVAL;
=20
@@ -81,7 +81,7 @@ int gre_parse_header(struct sk_buff *skb, struct tnl_=
ptk_info *tpi,
 	if (!pskb_may_pull(skb, hdr_len))
 		return -EINVAL;
=20
-	greh =3D (struct gre_base_hdr *)skb_transport_header(skb);
+	greh =3D (struct gre_base_hdr *)skb->data;
 	tpi->proto =3D greh->protocol;
=20
 	options =3D (__be32 *)(greh + 1);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 4d2025f7ec57..454832bc2897 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -49,12 +49,6 @@
 #include <net/gre.h>
 #include <net/dst_metadata.h>
=20
-#if IS_ENABLED(CONFIG_IPV6)
-#include <net/ipv6.h>
-#include <net/ip6_fib.h>
-#include <net/ip6_route.h>
-#endif
-
 /*
    Problems & solutions
    --------------------
@@ -217,11 +211,14 @@ static void gre_err(struct sk_buff *skb, u32 info=
)
 	 * by themselves???
 	 */
=20
+	const struct iphdr *iph =3D (struct iphdr *)skb->data;
 	const int type =3D icmp_hdr(skb)->type;
 	const int code =3D icmp_hdr(skb)->code;
 	struct tnl_ptk_info tpi;
 	bool csum_err =3D false;
=20
+	pskb_pull(skb, iph->ihl * 4);
+
 	if (gre_parse_header(skb, &tpi, &csum_err, htons(ETH_P_IP)) < 0) {
 		if (!csum_err)		/* ignore csum errors. */
 			return;
