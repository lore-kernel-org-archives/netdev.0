From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 4/4 net-next] tcp: makes tcp_try_coalesce aware of
 skb->head_frag
Date: Fri, 27 Apr 2012 12:38:33 +0200
Message-ID: <1335523113.2775.239.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Tom Herbert <therbert@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:62335 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759804Ab2D0Kik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 06:38:40 -0400
Received: by bkuw12 with SMTP id w12so389388bku.19
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2012 03:38:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

TCP coalesce can check if skb to be merged has its skb->head mapped to =
a
page fragment, instead of a kmalloc() area.

We had to disable coalescing in this case, for performance reasons.

We 'upgrade' skb->head as a fragment in itself.

This reduces number of cache misses when user makes its copies, since a
less sk_buff are fetched.

This makes receive and ofo queues shorter and thus reduce cache line
misses in TCP stack.

This is a followup of patch "net: allow skb->head to be a page fragment=
"

Tested with tg3 nic, with GRO on or off. We can see "TCPRcvCoalesce"
counter being incremented.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: Matt Carlson <mcarlson@broadcom.com>
Cc: Michael Chan <mchan@broadcom.com>
---
 net/ipv4/tcp_input.c |   55 ++++++++++++++++++++++++++++++++---------
 1 file changed, 43 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c93b0cb..96a631d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4464,10 +4464,12 @@ static inline int tcp_try_rmem_schedule(struct =
sock *sk, unsigned int size)
  */
 static bool tcp_try_coalesce(struct sock *sk,
 			     struct sk_buff *to,
-			     struct sk_buff *from)
+			     struct sk_buff *from,
+			     bool *fragstolen)
 {
-	int len =3D from->len;
+	int delta, len =3D from->len;
=20
+	*fragstolen =3D false;
 	if (tcp_hdr(from)->fin)
 		return false;
 	if (len <=3D skb_tailroom(to)) {
@@ -4478,15 +4480,19 @@ merge:
 		TCP_SKB_CB(to)->ack_seq =3D TCP_SKB_CB(from)->ack_seq;
 		return true;
 	}
+
+	if (skb_has_frag_list(to) || skb_has_frag_list(from))
+		return false;
+
 	if (skb_headlen(from) =3D=3D 0 &&
-	    !skb_has_frag_list(to) &&
-	    !skb_has_frag_list(from) &&
 	    (skb_shinfo(to)->nr_frags +
 	     skb_shinfo(from)->nr_frags <=3D MAX_SKB_FRAGS)) {
-		int delta =3D from->truesize - ksize(from->head) -
-			    SKB_DATA_ALIGN(sizeof(struct sk_buff));
+		WARN_ON_ONCE(from->head_frag);
+		delta =3D from->truesize - ksize(from->head) -
+			SKB_DATA_ALIGN(sizeof(struct sk_buff));
=20
 		WARN_ON_ONCE(delta < len);
+copyfrags:
 		memcpy(skb_shinfo(to)->frags + skb_shinfo(to)->nr_frags,
 		       skb_shinfo(from)->frags,
 		       skb_shinfo(from)->nr_frags * sizeof(skb_frag_t));
@@ -4499,6 +4505,20 @@ merge:
 		to->data_len +=3D len;
 		goto merge;
 	}
+	if (from->head_frag) {
+		struct page *page;
+		unsigned int offset;
+
+		if (skb_shinfo(to)->nr_frags + skb_shinfo(from)->nr_frags >=3D MAX_S=
KB_FRAGS)
+			return false;
+		page =3D virt_to_head_page(from->head);
+		offset =3D from->data - (unsigned char *)page_address(page);
+		skb_fill_page_desc(to, skb_shinfo(to)->nr_frags,
+				   page, offset, skb_headlen(from));
+		*fragstolen =3D true;
+		delta =3D len; /* we dont know real truesize... */
+		goto copyfrags;
+	}
 	return false;
 }
=20
@@ -4540,10 +4560,15 @@ static void tcp_data_queue_ofo(struct sock *sk,=
 struct sk_buff *skb)
 	end_seq =3D TCP_SKB_CB(skb)->end_seq;
=20
 	if (seq =3D=3D TCP_SKB_CB(skb1)->end_seq) {
-		if (!tcp_try_coalesce(sk, skb1, skb)) {
+		bool fragstolen;
+
+		if (!tcp_try_coalesce(sk, skb1, skb, &fragstolen)) {
 			__skb_queue_after(&tp->out_of_order_queue, skb1, skb);
 		} else {
-			__kfree_skb(skb);
+			if (fragstolen)
+				kmem_cache_free(skbuff_head_cache, skb);
+			else
+				__kfree_skb(skb);
 			skb =3D NULL;
 		}
=20
@@ -4626,6 +4651,7 @@ static void tcp_data_queue(struct sock *sk, struc=
t sk_buff *skb)
 	const struct tcphdr *th =3D tcp_hdr(skb);
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	int eaten =3D -1;
+	bool fragstolen =3D false;
=20
 	if (TCP_SKB_CB(skb)->seq =3D=3D TCP_SKB_CB(skb)->end_seq)
 		goto drop;
@@ -4672,7 +4698,9 @@ queue_and_out:
 				goto drop;
=20
 			tail =3D skb_peek_tail(&sk->sk_receive_queue);
-			eaten =3D (tail && tcp_try_coalesce(sk, tail, skb)) ? 1 : 0;
+			eaten =3D (tail &&
+				 tcp_try_coalesce(sk, tail, skb,
+						  &fragstolen)) ? 1 : 0;
 			if (eaten <=3D 0) {
 				skb_set_owner_r(skb, sk);
 				__skb_queue_tail(&sk->sk_receive_queue, skb);
@@ -4699,9 +4727,12 @@ queue_and_out:
=20
 		tcp_fast_path_check(sk);
=20
-		if (eaten > 0)
-			__kfree_skb(skb);
-		else if (!sock_flag(sk, SOCK_DEAD))
+		if (eaten > 0) {
+			if (fragstolen)
+				kmem_cache_free(skbuff_head_cache, skb);
+			else
+				__kfree_skb(skb);
+		} else if (!sock_flag(sk, SOCK_DEAD))
 			sk->sk_data_ready(sk, 0);
 		return;
 	}
