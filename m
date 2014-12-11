From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [net] gre: fix the inner mac header in nbma gre tunnels xmit path
Date: Thu, 11 Dec 2014 09:14:39 +0200
Message-ID: <1418282079-30245-1-git-send-email-timo.teras@iki.fi>
References: <CA+mtBx-WsgMRAYDUaPiVaBt43cRx7tb-0hRJ+6Eao8vjd3j8aQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>,
	Tom Herbert <therbert@google.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:38826 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753905AbaLKHPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 02:15:08 -0500
Received: by mail-lb0-f180.google.com with SMTP id l4so3573444lbv.25
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 23:15:06 -0800 (PST)
In-Reply-To: <CA+mtBx-WsgMRAYDUaPiVaBt43cRx7tb-0hRJ+6Eao8vjd3j8aQ@mail.gmail.com>
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
 length"
Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
Cc: Tom Herbert <therbert@google.com>
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>
---
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
index 94213c8..6d2f84d 100644
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
+		skb_reset_mac_header(mac);
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
