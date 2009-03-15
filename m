From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 3/7] tcp: consolidate paws check
Date: Sun, 15 Mar 2009 02:23:03 +0200
Message-ID: <12370765873185-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12370765872509-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12370765871159-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55491 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252AbZCOAXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 20:23:09 -0400
In-Reply-To: <12370765871159-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wow, it was quite tricky to merge that stream of negations
but I think I finally got it right:

check & replace_ts_recent:
(s32)(rcv_tsval - ts_recent) >=3D 0                  =3D> 0
(s32)(ts_recent - rcv_tsval) <=3D 0                  =3D> 0

discard:
(s32)(ts_recent - rcv_tsval)  > TCP_PAWS_WINDOW    =3D> 1
(s32)(ts_recent - rcv_tsval) <=3D TCP_PAWS_WINDOW    =3D> 0

I toggled the return values of tcp_paws_check around since
the old encoding added yet-another negation making tracking
of truth-values really complicated.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h        |   18 ++++++++++++++----
 net/ipv4/tcp_input.c     |   11 +++++------
 net/ipv4/tcp_minisocks.c |    4 ++--
 3 files changed, 21 insertions(+), 12 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index d74ac30..255ca35 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -997,11 +997,21 @@ static inline int tcp_fin_time(const struct sock =
*sk)
 	return fin_timeout;
 }
=20
-static inline int tcp_paws_check(const struct tcp_options_received *rx=
_opt, int rst)
+static inline int tcp_paws_check(const struct tcp_options_received *rx=
_opt,
+				 int paws_win)
 {
-	if ((s32)(rx_opt->rcv_tsval - rx_opt->ts_recent) >=3D 0)
-		return 0;
-	if (get_seconds() >=3D rx_opt->ts_recent_stamp + TCP_PAWS_24DAYS)
+	if ((s32)(rx_opt->ts_recent - rx_opt->rcv_tsval) <=3D paws_win)
+		return 1;
+	if (unlikely(get_seconds() >=3D rx_opt->ts_recent_stamp + TCP_PAWS_24=
DAYS))
+		return 1;
+
+	return 0;
+}
+
+static inline int tcp_paws_reject(const struct tcp_options_received *r=
x_opt,
+				  int rst)
+{
+	if (tcp_paws_check(rx_opt, 0))
 		return 0;
=20
 	/* RST segments are not recommended to carry timestamp,
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f527a16..b7d02c5 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3883,8 +3883,7 @@ static inline void tcp_replace_ts_recent(struct t=
cp_sock *tp, u32 seq)
 		 * Not only, also it occurs for expired timestamps.
 		 */
=20
-		if ((s32)(tp->rx_opt.rcv_tsval - tp->rx_opt.ts_recent) >=3D 0 ||
-		   get_seconds() >=3D tp->rx_opt.ts_recent_stamp + TCP_PAWS_24DAYS)
+		if (tcp_paws_check(&tp->rx_opt, 0))
 			tcp_store_ts_recent(tp);
 	}
 }
@@ -3936,9 +3935,9 @@ static inline int tcp_paws_discard(const struct s=
ock *sk,
 				   const struct sk_buff *skb)
 {
 	const struct tcp_sock *tp =3D tcp_sk(sk);
-	return ((s32)(tp->rx_opt.ts_recent - tp->rx_opt.rcv_tsval) > TCP_PAWS=
_WINDOW &&
-		get_seconds() < tp->rx_opt.ts_recent_stamp + TCP_PAWS_24DAYS &&
-		!tcp_disordered_ack(sk, skb));
+
+	return !tcp_paws_check(&tp->rx_opt, TCP_PAWS_WINDOW) &&
+	       !tcp_disordered_ack(sk, skb);
 }
=20
 /* Check segment sequence number for validity.
@@ -5513,7 +5512,7 @@ discard:
=20
 	/* PAWS check. */
 	if (tp->rx_opt.ts_recent_stamp && tp->rx_opt.saw_tstamp &&
-	    tcp_paws_check(&tp->rx_opt, 0))
+	    tcp_paws_reject(&tp->rx_opt, 0))
 		goto discard_and_undo;
=20
 	if (th->syn) {
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 4b0df3e..43bbba7 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -107,7 +107,7 @@ tcp_timewait_state_process(struct inet_timewait_soc=
k *tw, struct sk_buff *skb,
 		if (tmp_opt.saw_tstamp) {
 			tmp_opt.ts_recent	=3D tcptw->tw_ts_recent;
 			tmp_opt.ts_recent_stamp	=3D tcptw->tw_ts_recent_stamp;
-			paws_reject =3D tcp_paws_check(&tmp_opt, th->rst);
+			paws_reject =3D tcp_paws_reject(&tmp_opt, th->rst);
 		}
 	}
=20
@@ -511,7 +511,7 @@ struct sock *tcp_check_req(struct sock *sk, struct =
sk_buff *skb,
 			 * from another data.
 			 */
 			tmp_opt.ts_recent_stamp =3D get_seconds() - ((TCP_TIMEOUT_INIT/HZ)<=
<req->retrans);
-			paws_reject =3D tcp_paws_check(&tmp_opt, th->rst);
+			paws_reject =3D tcp_paws_reject(&tmp_opt, th->rst);
 		}
 	}
=20
--=20
1.5.6.5

