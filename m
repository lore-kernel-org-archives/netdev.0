From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 7/7] [TCP]: Limit processing lost_retrans loop to work-to-do cases
Date: Thu, 11 Oct 2007 14:41:07 +0300
Message-ID: <1192102867248-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1192102867479-git-send-email-ilpo.jarvinen@helsinki.fi> <11921028673599-git-send-email-ilpo.jarvinen@helsinki.fi> <1192102867725-git-send-email-ilpo.jarvinen@helsinki.fi> <11921028673528-git-send-email-ilpo.jarvinen@helsinki.fi> <11921028673030-git-send-email-ilpo.jarvinen@helsinki.fi> <11921028672853-git-send-email-ilpo.jarvinen@helsinki.fi> <11921028671668-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, TAKANO Ryousei <takano@axe-inc.co.jp>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49824 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755117AbXJKLlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 07:41:17 -0400
In-Reply-To: <11921028671668-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This addition of lost_retrans_low to tcp_sock might be
unnecessary, it's not clear how often lost_retrans worker is
executed when there wasn't work to do.

Cc: TAKANO Ryousei <takano@axe-inc.co.jp>
Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h   |    2 ++
 net/ipv4/tcp_input.c  |   14 +++++++++++---
 net/ipv4/tcp_output.c |    2 ++
 3 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 9ff456e..c5b94c1 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -348,6 +348,8 @@ struct tcp_sock {
 	int     lost_cnt_hint;
 	int     retransmit_cnt_hint;
=20
+	u32	lost_retrans_low;	/* Sent seq after any rxmit (lowest) */
+
 	u16	advmss;		/* Advertised MSS			*/
 	u16	prior_ssthresh; /* ssthresh saved at recovery start	*/
 	u32	lost_out;	/* Lost packets			*/
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d5e0fcc..0a42e93 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1112,7 +1112,8 @@ static int tcp_is_sackblock_valid(struct tcp_sock=
 *tp, int is_dsack,
  *
  * Search retransmitted skbs from write_queue that were sent when snd_=
nxt was
  * less than what is now known to be received by the other end (derive=
d from
- * SACK blocks by the caller).
+ * SACK blocks by the caller). Also calculate the lowest snd_nxt among=
 the
+ * remaining retransmitted skbs to avoid some costly processing per AC=
Ks.
  */
 static int tcp_mark_lost_retrans(struct sock *sk, u32 received_upto)
 {
@@ -1120,6 +1121,7 @@ static int tcp_mark_lost_retrans(struct sock *sk,=
 u32 received_upto)
 	struct sk_buff *skb;
 	int flag =3D 0;
 	int cnt =3D 0;
+	u32 new_low_seq =3D 0;
=20
 	tcp_for_write_queue(skb, sk) {
 		u32 ack_seq =3D TCP_SKB_CB(skb)->ack_seq;
@@ -1151,9 +1153,15 @@ static int tcp_mark_lost_retrans(struct sock *sk=
, u32 received_upto)
 				NET_INC_STATS_BH(LINUX_MIB_TCPLOSTRETRANSMIT);
 			}
 		} else {
+			if (!new_low_seq || before(ack_seq, new_low_seq))
+				new_low_seq =3D ack_seq;
 			cnt +=3D tcp_skb_pcount(skb);
 		}
 	}
+
+	if (tp->retrans_out)
+		tp->lost_retrans_low =3D new_low_seq;
+
 	return flag;
 }
=20
@@ -1481,8 +1489,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 		}
 	}
=20
-	if (tp->retrans_out && highest_sack_end_seq &&
-	    after(highest_sack_end_seq, tp->high_seq) &&
+	if (tp->retrans_out &&
+	    after(highest_sack_end_seq, tp->lost_retrans_low) &&
 	    icsk->icsk_ca_state =3D=3D TCP_CA_Recovery)
 		flag |=3D tcp_mark_lost_retrans(sk, highest_sack_end_seq);
=20
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5329675..324b420 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1914,6 +1914,8 @@ int tcp_retransmit_skb(struct sock *sk, struct sk=
_buff *skb)
 				printk(KERN_DEBUG "retrans_out leaked.\n");
 		}
 #endif
+		if (!tp->retrans_out)
+			tp->lost_retrans_low =3D tp->snd_nxt;
 		TCP_SKB_CB(skb)->sacked |=3D TCPCB_RETRANS;
 		tp->retrans_out +=3D tcp_skb_pcount(skb);
=20
--=20
1.5.0.6

