From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 6/7] tcp: cache result of earlier divides when mss-aligning things
Date: Sun, 15 Mar 2009 02:23:06 +0200
Message-ID: <12370765871746-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12370765872509-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12370765871159-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12370765873185-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1237076587615-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1237076587514-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57532 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551AbZCOAXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 20:23:11 -0400
In-Reply-To: <1237076587514-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The results is very unlikely change every so often so we
hardly need to divide again after doing that once for a
connection. Yet, if divide still becomes necessary we
detect that and do the right thing and again settle for
non-divide state. Takes the u16 space which was previously
taken by the plain xmit_size_goal.

This should take care part of the tso vs non-tso difference
we found earlier.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Cc: Evgeniy Polyakov <zbr@ioremap.net>
Cc: Ingo Molnar <mingo@elte.hu>
---
 include/linux/tcp.h |    1 +
 net/ipv4/tcp.c      |   14 ++++++++++++--
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index ad2021c..9d5078b 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -248,6 +248,7 @@ struct tcp_sock {
 	/* inet_connection_sock has to be the first member of tcp_sock */
 	struct inet_connection_sock	inet_conn;
 	u16	tcp_header_len;	/* Bytes of tcp header to send		*/
+	u16	xmit_size_goal_segs; /* Goal for segmenting output packets */
=20
 /*
  *	Header prediction flags
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 886596f..2dc6741 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -665,7 +665,7 @@ static unsigned int tcp_xmit_size_goal(struct sock =
*sk, u32 mss_now,
 				       int large_allowed)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
-	u32 xmit_size_goal;
+	u32 xmit_size_goal, old_size_goal;
=20
 	xmit_size_goal =3D mss_now;
=20
@@ -676,7 +676,17 @@ static unsigned int tcp_xmit_size_goal(struct sock=
 *sk, u32 mss_now,
 				  tp->tcp_header_len);
=20
 		xmit_size_goal =3D tcp_bound_to_half_wnd(tp, xmit_size_goal);
-		xmit_size_goal -=3D (xmit_size_goal % mss_now);
+
+		/* We try hard to avoid divides here */
+		old_size_goal =3D tp->xmit_size_goal_segs * mss_now;
+
+		if (old_size_goal <=3D xmit_size_goal &&
+		    old_size_goal + mss_now > xmit_size_goal) {
+			xmit_size_goal =3D old_size_goal;
+		} else {
+			tp->xmit_size_goal_segs =3D xmit_size_goal / mss_now;
+			xmit_size_goal =3D tp->xmit_size_goal_segs * mss_now;
+		}
 	}
=20
 	return xmit_size_goal;
--=20
1.5.6.5

