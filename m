From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 2/3] tcp: Add tcp_collapse_one to eliminate duplicated code
Date: Fri, 22 Aug 2008 23:38:28 +0300
Message-ID: <1219437509-10048-2-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1219437509-10048-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33691 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835AbYHVUib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 16:38:31 -0400
In-Reply-To: <1219437509-10048-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index aa95c68..7cd1ad0 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4166,6 +4166,18 @@ add_sack:
 	}
 }
=20
+static struct sk_buff *tcp_collapse_one(struct sock *sk, struct sk_buf=
f *skb,
+					struct sk_buff_head *list)
+{
+	struct sk_buff *next =3D skb->next;
+
+	__skb_unlink(skb, list);
+	__kfree_skb(skb);
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRCVCOLLAPSED);
+
+	return next;
+}
+
 /* Collapse contiguous sequence of skbs head..tail with
  * sequence numbers start..end.
  * Segments with FIN/SYN are not collapsed (only because this
@@ -4183,11 +4195,7 @@ tcp_collapse(struct sock *sk, struct sk_buff_hea=
d *list,
 	for (skb =3D head; skb !=3D tail;) {
 		/* No new bits? It is possible on ofo queue. */
 		if (!before(start, TCP_SKB_CB(skb)->end_seq)) {
-			struct sk_buff *next =3D skb->next;
-			__skb_unlink(skb, list);
-			__kfree_skb(skb);
-			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRCVCOLLAPSED);
-			skb =3D next;
+			skb =3D tcp_collapse_one(sk, skb, list);
 			continue;
 		}
=20
@@ -4251,11 +4259,7 @@ tcp_collapse(struct sock *sk, struct sk_buff_hea=
d *list,
 				start +=3D size;
 			}
 			if (!before(start, TCP_SKB_CB(skb)->end_seq)) {
-				struct sk_buff *next =3D skb->next;
-				__skb_unlink(skb, list);
-				__kfree_skb(skb);
-				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRCVCOLLAPSED);
-				skb =3D next;
+				skb =3D tcp_collapse_one(sk, skb, list);
 				if (skb =3D=3D tail ||
 				    tcp_hdr(skb)->syn ||
 				    tcp_hdr(skb)->fin)
--=20
1.5.2.2

