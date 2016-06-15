From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net] gre: fix error handler
Date: Wed, 15 Jun 2016 06:24:00 -0700
Message-ID: <1465997040.7945.207.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465967701.7945.200.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1465969537.7945.201.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Benc <jbenc@redhat.com>, netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36085 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753154AbcFONYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 09:24:04 -0400
Received: by mail-pa0-f65.google.com with SMTP id fg1so1574654pad.3
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 06:24:03 -0700 (PDT)
In-Reply-To: <1465969537.7945.201.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

1) gre_parse_header() can be called from gre_err()

   At this point transport header points to ICMP header, not the inner
header.

2) We can not really change transport header as ipgre_err() will later
assume transport header still points to ICMP header (using icmp_hdr())

3) pskb_may_pull() logic in gre_parse_header() really works
  if we are interested at zone pointed by skb->data

4) As Jiri explained in commit b7f8fe251e46 ("gre: do not pull header i=
n
ICMP error processing") we should not pull headers in error handler.

So this fix :

A) changes gre_parse_header() to use skb->data instead of
skb_transport_header()

B) Adds a nhs parameter to gre_parse_header() so that we can skip the
not pulled IP header from error path.
  This offset is 0 for normal receive path.

C) remove obsolete IPV6 includes

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tom Herbert <tom@herbertland.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Jiri Benc <jbenc@redhat.com>
---
 include/net/gre.h    |    2 +-
 net/ipv4/gre_demux.c |   10 +++++-----
 net/ipv4/ip_gre.c    |   12 ++++--------
 net/ipv6/ip6_gre.c   |    2 +-
 4 files changed, 11 insertions(+), 15 deletions(-)

diff --git a/include/net/gre.h b/include/net/gre.h
index 5dce30a6abe3..7a54a31d1d4c 100644
--- a/include/net/gre.h
+++ b/include/net/gre.h
@@ -26,7 +26,7 @@ int gre_del_protocol(const struct gre_protocol *proto=
, u8 version);
 struct net_device *gretap_fb_dev_create(struct net *net, const char *n=
ame,
 				       u8 name_assign_type);
 int gre_parse_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
-		     bool *csum_err, __be16 proto);
+		     bool *csum_err, __be16 proto, int nhs);
=20
 static inline int gre_calc_hlen(__be16 o_flags)
 {
diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index 4c39f4fd332a..de1d119a4497 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -62,26 +62,26 @@ EXPORT_SYMBOL_GPL(gre_del_protocol);
=20
 /* Fills in tpi and returns header length to be pulled. */
 int gre_parse_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
-		     bool *csum_err, __be16 proto)
+		     bool *csum_err, __be16 proto, int nhs)
 {
 	const struct gre_base_hdr *greh;
 	__be32 *options;
 	int hdr_len;
=20
-	if (unlikely(!pskb_may_pull(skb, sizeof(struct gre_base_hdr))))
+	if (unlikely(!pskb_may_pull(skb, nhs + sizeof(struct gre_base_hdr))))
 		return -EINVAL;
=20
-	greh =3D (struct gre_base_hdr *)skb_transport_header(skb);
+	greh =3D (struct gre_base_hdr *)(skb->data + nhs);
 	if (unlikely(greh->flags & (GRE_VERSION | GRE_ROUTING)))
 		return -EINVAL;
=20
 	tpi->flags =3D gre_flags_to_tnl_flags(greh->flags);
 	hdr_len =3D gre_calc_hlen(tpi->flags);
=20
-	if (!pskb_may_pull(skb, hdr_len))
+	if (!pskb_may_pull(skb, nhs + hdr_len))
 		return -EINVAL;
=20
-	greh =3D (struct gre_base_hdr *)skb_transport_header(skb);
+	greh =3D (struct gre_base_hdr *)(skb->data + nhs);
 	tpi->proto =3D greh->protocol;
=20
 	options =3D (__be32 *)(greh + 1);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 07c5cf1838d8..1d000af7f561 100644
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
@@ -217,12 +211,14 @@ static void gre_err(struct sk_buff *skb, u32 info=
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
-	if (gre_parse_header(skb, &tpi, &csum_err, htons(ETH_P_IP)) < 0) {
+	if (gre_parse_header(skb, &tpi, &csum_err, htons(ETH_P_IP),
+			     iph->ihl * 4) < 0) {
 		if (!csum_err)		/* ignore csum errors. */
 			return;
 	}
@@ -338,7 +334,7 @@ static int gre_rcv(struct sk_buff *skb)
 	}
 #endif
=20
-	hdr_len =3D gre_parse_header(skb, &tpi, &csum_err, htons(ETH_P_IP));
+	hdr_len =3D gre_parse_header(skb, &tpi, &csum_err, htons(ETH_P_IP), 0=
);
 	if (hdr_len < 0)
 		goto drop;
=20
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index fdc9de276ab1..776d145113e1 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -468,7 +468,7 @@ static int gre_rcv(struct sk_buff *skb)
 	bool csum_err =3D false;
 	int hdr_len;
=20
-	hdr_len =3D gre_parse_header(skb, &tpi, &csum_err, htons(ETH_P_IPV6))=
;
+	hdr_len =3D gre_parse_header(skb, &tpi, &csum_err, htons(ETH_P_IPV6),=
 0);
 	if (hdr_len < 0)
 		goto drop;
=20
