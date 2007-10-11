From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 4/7] [TCP]: Extract tcp_match_queue_to_sack from sacktag code
Date: Thu, 11 Oct 2007 14:41:04 +0300
Message-ID: <11921028673030-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1192102867479-git-send-email-ilpo.jarvinen@helsinki.fi> <11921028673599-git-send-email-ilpo.jarvinen@helsinki.fi> <1192102867725-git-send-email-ilpo.jarvinen@helsinki.fi> <11921028673528-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, TAKANO Ryousei <takano@axe-inc.co.jp>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55295 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754737AbXJKLlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 07:41:15 -0400
In-Reply-To: <11921028673528-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is necessary for upcoming DSACK bugfix. Reduces sacktag
length which is not very sad thing at all... :-)

Notice that there's a need to handle out-of-mem at caller's
place.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   54 ++++++++++++++++++++++++++++++++----------=
-------
 1 files changed, 35 insertions(+), 19 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 5004704..bd18c25 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1181,6 +1181,38 @@ static int tcp_check_dsack(struct tcp_sock *tp, =
struct sk_buff *ack_skb,
 	return dup_sack;
 }
=20
+/* Check if skb is fully within the SACK block. In presence of GSO skb=
s,
+ * the incoming SACK may not exactly match but we can find smaller MSS
+ * aligned portion of it that matches. Therefore we might need to frag=
ment
+ * which may fail and creates some hassle (caller must handle error ca=
se
+ * returns).
+ */
+int tcp_match_skb_to_sack(struct sock *sk, struct sk_buff *skb,
+			  u32 start_seq, u32 end_seq)
+{
+	int in_sack, err;
+	unsigned int pkt_len;
+
+	in_sack =3D !after(start_seq, TCP_SKB_CB(skb)->seq) &&
+		  !before(end_seq, TCP_SKB_CB(skb)->end_seq);
+
+	if (tcp_skb_pcount(skb) > 1 && !in_sack &&
+	    after(TCP_SKB_CB(skb)->end_seq, start_seq)) {
+
+		in_sack =3D !after(start_seq, TCP_SKB_CB(skb)->seq);
+
+		if (!in_sack)
+			pkt_len =3D start_seq - TCP_SKB_CB(skb)->seq;
+		else
+			pkt_len =3D end_seq - TCP_SKB_CB(skb)->seq;
+		err =3D tcp_fragment(sk, skb, pkt_len, skb_shinfo(skb)->gso_size);
+		if (err < 0)
+			return err;
+	}
+
+	return in_sack;
+}
+
 static int
 tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 =
prior_snd_una)
 {
@@ -1333,25 +1365,9 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb, u32 prior_snd_
 			if (!before(TCP_SKB_CB(skb)->seq, end_seq))
 				break;
=20
-			in_sack =3D !after(start_seq, TCP_SKB_CB(skb)->seq) &&
-				!before(end_seq, TCP_SKB_CB(skb)->end_seq);
-
-			if (tcp_skb_pcount(skb) > 1 && !in_sack &&
-			    after(TCP_SKB_CB(skb)->end_seq, start_seq)) {
-				unsigned int pkt_len;
-
-				in_sack =3D !after(start_seq,
-						 TCP_SKB_CB(skb)->seq);
-
-				if (!in_sack)
-					pkt_len =3D (start_seq -
-						   TCP_SKB_CB(skb)->seq);
-				else
-					pkt_len =3D (end_seq -
-						   TCP_SKB_CB(skb)->seq);
-				if (tcp_fragment(sk, skb, pkt_len, skb_shinfo(skb)->gso_size))
-					break;
-			}
+			in_sack =3D tcp_match_skb_to_sack(sk, skb, start_seq, end_seq);
+			if (in_sack < 0)
+				break;
=20
 			fack_count +=3D tcp_skb_pcount(skb);
=20
--=20
1.5.0.6

