From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH net, v2] gre: fix the inner mac header in nbma tunnel xmit path
Date: Mon, 15 Dec 2014 09:24:13 +0200
Message-ID: <1418628253-4950-1-git-send-email-timo.teras@iki.fi>
References: <20141211.150706.1736198745550279282.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>,
	Tom Herbert <therbert@google.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:34546 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbaLOHYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 02:24:46 -0500
Received: by mail-la0-f51.google.com with SMTP id ms9so8879289lab.38
        for <netdev@vger.kernel.org>; Sun, 14 Dec 2014 23:24:45 -0800 (PST)
In-Reply-To: <20141211.150706.1736198745550279282.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NBMA GRE tunnels temporarily push GRE header that contain the
per-packet NBMA destination on the skb via header ops early in xmit
path. It is the later pulled before the real GRE header is constructed.

The inner mac was thus set differently in nbma case: the GRE header
has been pushed by neighbor layer, and mac header points to beginning
of the temporary gre header (set by dev_queue_xmit).

Now that the offloads expect mac header to point to the gre payload,
fix the xmit patch to:
 - pull first the temporary gre header away
 - and reset mac header to point to gre payload

This fixes tso to work again with nbma tunnels.

=46ixes: 14051f0452a2 ("gre: Use inner mac length when computing tunnel=
 length")
Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
Cc: Tom Herbert <therbert@google.com>
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>
---
=46ixed the stupid typo of skb_reset_mac_header()'s argument. And yes,
I did recompile, retest and verify that this works.

Comments from v1 apply:

Though, normally mac header does point to the begging of the hardware h=
eader.
E.g. in ethernet case it's pointing to the ethernet header. But now in =
gre
case it's instead pointing to the payload which seems counter-intuitive=
 to me.
But I guess tunnels are a bit of special case, and there's valid reason=
s to
have it point to tunnel payload too.

Applying this patch on top of the Tom's previous fix of 14051f0452a2 se=
ems to
now make my dmvpn scenario work again. So this should go to -stable too
(atleast 3.14).

 net/ipv4/ip_gre.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 94213c8..b40b90d 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -250,10 +250,6 @@ static netdev_tx_t ipgre_xmit(struct sk_buff *skb,
 	struct ip_tunnel *tunnel =3D netdev_priv(dev);
 	const struct iphdr *tnl_params;
=20
-	skb =3D gre_handle_offloads(skb, !!(tunnel->parms.o_flags&TUNNEL_CSUM=
));
-	if (IS_ERR(skb))
-		goto out;
-
 	if (dev->header_ops) {
 		/* Need space for new headers */
 		if (skb_cow_head(skb, dev->needed_headroom -
@@ -266,6 +262,7 @@ static netdev_tx_t ipgre_xmit(struct sk_buff *skb,
 		 * to gre header.
 		 */
 		skb_pull(skb, tunnel->hlen + sizeof(struct iphdr));
+		skb_reset_mac_header(skb);
 	} else {
 		if (skb_cow_head(skb, dev->needed_headroom))
 			goto free_skb;
@@ -273,6 +270,10 @@ static netdev_tx_t ipgre_xmit(struct sk_buff *skb,
 		tnl_params =3D &tunnel->parms.iph;
 	}
=20
+	skb =3D gre_handle_offloads(skb, !!(tunnel->parms.o_flags&TUNNEL_CSUM=
));
+	if (IS_ERR(skb))
+		goto out;
+
 	__gre_xmit(skb, dev, tnl_params, skb->protocol);
=20
 	return NETDEV_TX_OK;
--=20
2.2.0
