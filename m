From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 13/18] [TCP] FRTO: Entry is allowed only during (New)Reno like recovery
Date: Mon, 19 Feb 2007 13:38:07 +0200
Message-ID: <11718850921409-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11718850923446-git-send-email-ilpo.jarvinen@helsinki.fi> <1171885092563-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921459-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923208-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921817-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922528-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921864-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922604-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921021-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923324-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922734-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921158-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921574-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Pasi Sarolahti <pasi.sarolahti@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49901 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932140AbXBSLiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 06:38:18 -0500
In-Reply-To: <11718850921574-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This interpretation comes from RFC4138:
    "If the sender implements some loss recovery algorithm other
     than Reno or NewReno [FHG04], the F-RTO algorithm SHOULD
     NOT be entered when earlier fast recovery is underway."

I think the RFC means to say (especially in the light of
Appendix B) that ...recovery is underway (not just fast recovery)
or was underway when it was interrupted by an earlier (F-)RTO
that hasn't yet been resolved (snd_una has not advanced enough).
Thus, my interpretation is that whenever TCP has ever
retransmitted other than head, basic version cannot be used
because then the order assumptions which are used as FRTO basis
do not hold.

NewReno has only the head segment retransmitted at a time.
Therefore, walk up to the segment that has not been SACKed, if
that segment is not retransmitted nor anything before it, we know
for sure, that nothing after the non-SACKed segment should be
either. This assumption is valid because TCPCB_EVER_RETRANS does
not leave holes but each non-SACKed segment is rexmitted
in-order.

Check for retrans_out > 1 avoids more expensive walk through the
skb list, as we can know the result beforehand: F-RTO will not be
allowed.

SACKed skb can turn into non-SACked only in the extremely rare
case of SACK reneging, in this case we might fail to detect
retransmissions if there were them for any other than head. To
get rid of that feature, whole rexmit queue would have to be
walked (always) or FRTO should be prevented when SACK reneging
happens. Of course RTO should still trigger after reneging which
makes this issue even less likely to show up. And as long as the
response is as conservative as it's now, nothing bad happens even
then.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h    |    2 +-
 net/ipv4/tcp_input.c |   25 +++++++++++++++++++++----
 2 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 572a77b..7fd6b77 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -341,7 +341,7 @@ extern struct sock *		tcp_check_req(stru
 extern int			tcp_child_process(struct sock *parent,
 						  struct sock *child,
 						  struct sk_buff *skb);
-extern int			tcp_use_frto(const struct sock *sk);
+extern int			tcp_use_frto(struct sock *sk);
 extern void			tcp_enter_frto(struct sock *sk);
 extern void			tcp_enter_loss(struct sock *sk, int how);
 extern void			tcp_clear_retrans(struct tcp_sock *tp);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 5e952f0..8f0aa9d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1239,14 +1239,31 @@ #endif
 /* F-RTO can only be used if these conditions are satisfied:
  *  - there must be some unsent new data
  *  - the advertised window should allow sending it
+ *  - TCP has never retransmitted anything other than head
  */
-int tcp_use_frto(const struct sock *sk)
+int tcp_use_frto(struct sock *sk)
 {
 	const struct tcp_sock *tp =3D tcp_sk(sk);
+	struct sk_buff *skb;
 =09
-	return (sysctl_tcp_frto && sk->sk_send_head &&
-		!after(TCP_SKB_CB(sk->sk_send_head)->end_seq,
-		       tp->snd_una + tp->snd_wnd));
+	if (!sysctl_tcp_frto || !sk->sk_send_head ||
+		after(TCP_SKB_CB(sk->sk_send_head)->end_seq,
+		      tp->snd_una + tp->snd_wnd))
+		return 0;
+
+	/* Avoid expensive walking of rexmit queue if possible */
+	if (tp->retrans_out > 1)
+		return 0;
+
+	skb =3D skb_peek(&sk->sk_write_queue)->next;	/* Skips head */
+	sk_stream_for_retrans_queue_from(skb, sk) {
+		if (TCP_SKB_CB(skb)->sacked&TCPCB_RETRANS)
+			return 0;
+		/* Short-circuit when first non-SACKed skb has been checked */
+		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED))
+			break;
+	}
+	return 1;
 }
=20
 /* RTO occurred, but do not yet enter Loss state. Instead, defer RTO
--=20
1.4.2

