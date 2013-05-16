From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: gso: do not generate out of order packets
Date: Wed, 15 May 2013 18:38:01 -0700
Message-ID: <1368668281.4519.75.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f52.google.com ([209.85.210.52]:58294 "EHLO
	mail-da0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752467Ab3EPBiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 21:38:05 -0400
Received: by mail-da0-f52.google.com with SMTP id o9so1311196dan.25
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 18:38:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

GSO TCP handler has following issues :

1) ooo_okay from original GSO packet is duplicated to all segments
2) segments (but the last one) are orphaned, so transmit path can not
get transmit queue number from the socket. This happens if GSO
segmentation is done before stacked device for example.

Result is we can send packets from a given TCP flow to different TX
queues (if using multiqueue NICS). This generates OOO problems and
spurious SACK & retransmits.

=46ix this by keeping socket pointer set for all segments.

This means that every segment must also have a destructor, and the
original gso skb truesize must be split on all segments, to keep
precise sk->sk_wmem_alloc accounting.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp.c |   22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index dcb116d..0b6276f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2887,6 +2887,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *s=
kb,
 	unsigned int mss;
 	struct sk_buff *gso_skb =3D skb;
 	__sum16 newcheck;
+	bool ooo_okay, copy_destructor;
=20
 	if (!pskb_may_pull(skb, sizeof(*th)))
 		goto out;
@@ -2927,10 +2928,18 @@ struct sk_buff *tcp_tso_segment(struct sk_buff =
*skb,
 		goto out;
 	}
=20
+	copy_destructor =3D gso_skb->destructor =3D=3D tcp_wfree;
+	ooo_okay =3D gso_skb->ooo_okay;
+	/* All segments but the first should have ooo_okay cleared */
+	skb->ooo_okay =3D 0;
+
 	segs =3D skb_segment(skb, features);
 	if (IS_ERR(segs))
 		goto out;
=20
+	/* Only first segment might have ooo_okay set */
+	segs->ooo_okay =3D ooo_okay;
+
 	delta =3D htonl(oldlen + (thlen + mss));
=20
 	skb =3D segs;
@@ -2950,6 +2959,17 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *=
skb,
 						    thlen, skb->csum));
=20
 		seq +=3D mss;
+		if (copy_destructor) {
+			skb->destructor =3D gso_skb->destructor;
+			skb->sk =3D gso_skb->sk;
+			/* {tcp|sock}_wfree() use exact truesize accounting :
+			 * sum(skb->truesize) MUST be exactly be gso_skb->truesize
+			 * So we account mss bytes of 'true size' for each segment.
+			 * The last segment will contain the remaining.
+			 */
+			skb->truesize =3D mss;
+			gso_skb->truesize -=3D mss;
+		}
 		skb =3D skb->next;
 		th =3D tcp_hdr(skb);
=20
@@ -2962,7 +2982,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *s=
kb,
 	 * is freed at TX completion, and not right now when gso_skb
 	 * is freed by GSO engine
 	 */
-	if (gso_skb->destructor =3D=3D tcp_wfree) {
+	if (copy_destructor) {
 		swap(gso_skb->sk, skb->sk);
 		swap(gso_skb->destructor, skb->destructor);
 		swap(gso_skb->truesize, skb->truesize);
