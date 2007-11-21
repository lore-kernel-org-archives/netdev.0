From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH 2/2] [TCP] MTUprobe: Cleanup send queue check (no need to loop)
Date: Wed, 21 Nov 2007 18:01:28 +0200
Message-ID: <1195660888907-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11956608882424-git-send-email-ilpo.jarvinen@helsinki.fi> <11956608882602-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58850 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755854AbXKUQBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 11:01:30 -0500
In-Reply-To: <11956608882602-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The original code has striking complexity to perform a query
which can be reduced to a very simple compare.

=46IN seqno may be included to write_seq but it should not make
any significant difference here compared to skb->len which was
used previously. One won't end up there with SYN still queued.

Use of write_seq check guarantees that there's a valid skb in
send_head so I removed the extra check.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ff22ce8..1822ce6 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1315,12 +1315,7 @@ static int tcp_mtu_probe(struct sock *sk)
 	}
=20
 	/* Have enough data in the send queue to probe? */
-	len =3D 0;
-	if ((skb =3D tcp_send_head(sk)) =3D=3D NULL)
-		return -1;
-	while ((len +=3D skb->len) < size_needed && !tcp_skb_is_last(sk, skb)=
)
-		skb =3D tcp_write_queue_next(sk, skb);
-	if (len < size_needed)
+	if (tp->write_seq - tp->snd_nxt < size_needed)
 		return -1;
=20
 	if (tp->snd_wnd < size_needed)
--=20
1.5.0.6

