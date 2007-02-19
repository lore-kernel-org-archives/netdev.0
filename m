From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 17/18] [TCP]: SACK enhanced FRTO
Date: Mon, 19 Feb 2007 13:38:11 +0200
Message-ID: <11718850923836-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11718850923446-git-send-email-ilpo.jarvinen@helsinki.fi> <1171885092563-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921459-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923208-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921817-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922528-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921864-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922604-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921021-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923324-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922734-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921158-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921574-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921409-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921389-git-send-email-ilpo.jarvinen@helsinki.fi> <1171885092244-git-
 send-email-ilpo.jarvinen@helsinki.fi> <1171885092532-git-send-email-ilpo.jarvinen@helsinki
 .fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Pasi Sarolahti <pasi.sarolahti@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49901 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113AbXBSLiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 06:38:20 -0500
In-Reply-To: <1171885092532-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implements the SACK-enhanced FRTO given in RFC4138 using the
variant given in Appendix B.

RFC4138, Appendix B:
  "This means that in order to declare timeout spurious, the TCP
   sender must receive an acknowledgment for non-retransmitted
   segment between SND.UNA and RecoveryPoint in algorithm step 3.
   RecoveryPoint is defined in conservative SACK-recovery
   algorithm [RFC3517]"

The basic version of the FRTO algorithm can still be used also
when SACK is enabled. To enabled SACK-enhanced version, tcp_frto
sysctl is set to 2.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   76 ++++++++++++++++++++++++++++++++++++++++++=
+-------
 1 files changed, 65 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 356de02..3ce4019 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -100,6 +100,7 @@ #define FLAG_DATA_SACKED	0x20 /* New SAC
 #define FLAG_ECE		0x40 /* ECE in this ACK				*/
 #define FLAG_DATA_LOST		0x80 /* SACK detected data lossage.		*/
 #define FLAG_SLOWPATH		0x100 /* Do not skip RFC checks for window upda=
te.*/
+#define FLAG_ONLY_ORIG_SACKED	0x200 /* SACKs only non-rexmit sent befo=
re RTO */
=20
 #define FLAG_ACKED		(FLAG_DATA_ACKED|FLAG_SYN_ACKED)
 #define FLAG_NOT_DUP		(FLAG_DATA|FLAG_WIN_UPDATE|FLAG_ACKED)
@@ -110,6 +111,8 @@ #define IsReno(tp) ((tp)->rx_opt.sack_ok
 #define IsFack(tp) ((tp)->rx_opt.sack_ok & 2)
 #define IsDSack(tp) ((tp)->rx_opt.sack_ok & 4)
=20
+#define IsSackFrto() (sysctl_tcp_frto =3D=3D 0x2)
+
 #define TCP_REMNANT (TCP_FLAG_FIN|TCP_FLAG_URG|TCP_FLAG_SYN|TCP_FLAG_P=
SH)
=20
 /* Adapt the MSS value used to make delayed ack decision to the
@@ -1159,6 +1162,18 @@ tcp_sacktag_write_queue(struct sock *sk,
 						/* clear lost hint */
 						tp->retransmit_skb_hint =3D NULL;
 					}
+					/* SACK enhanced F-RTO detection.
+					 * Set flag if and only if non-rexmitted
+					 * segments below frto_highmark are
+					 * SACKed (RFC4138; Appendix B).
+					 * Clearing correct due to in-order walk
+					 */
+					if (after(end_seq, tp->frto_highmark)) {
+						flag &=3D ~FLAG_ONLY_ORIG_SACKED;
+					} else {
+						if (!(sacked & TCPCB_RETRANS))
+							flag |=3D FLAG_ONLY_ORIG_SACKED;
+					}
 				}
=20
 				TCP_SKB_CB(skb)->sacked |=3D TCPCB_SACKED_ACKED;
@@ -1240,7 +1255,8 @@ #endif
 /* F-RTO can only be used if these conditions are satisfied:
  *  - there must be some unsent new data
  *  - the advertised window should allow sending it
- *  - TCP has never retransmitted anything other than head
+ *  - TCP has never retransmitted anything other than head (SACK enhan=
ced
+ *    variant from Appendix B of RFC4138 is more robust here)
  */
 int tcp_use_frto(struct sock *sk)
 {
@@ -1252,6 +1268,9 @@ int tcp_use_frto(struct sock *sk)
 		      tp->snd_una + tp->snd_wnd))
 		return 0;
=20
+	if (IsSackFrto())
+		return 1;
+
 	/* Avoid expensive walking of rexmit queue if possible */
 	if (tp->retrans_out > 1)
 		return 0;
@@ -1328,9 +1347,18 @@ void tcp_enter_frto(struct sock *sk)
 	}
 	tcp_sync_left_out(tp);
=20
+	/* Earlier loss recovery underway (see RFC4138; Appendix B).
+	 * The last condition is necessary at least in tp->frto_counter case.
+	 */
+	if (IsSackFrto() && (tp->frto_counter ||
+	    ((1 << icsk->icsk_ca_state) & (TCPF_CA_Recovery|TCPF_CA_Loss))) &=
&
+	    after(tp->high_seq, tp->snd_una)) {
+		tp->frto_highmark =3D tp->high_seq;
+	} else {
+		tp->frto_highmark =3D tp->snd_nxt;
+	}
 	tcp_set_ca_state(sk, TCP_CA_Disorder);
 	tp->high_seq =3D tp->snd_nxt;
-	tp->frto_highmark =3D tp->snd_nxt;
 	tp->frto_counter =3D 1;
 }
=20
@@ -2566,6 +2594,10 @@ static void tcp_conservative_spur_to_res
  * Rationale: if the RTO was spurious, new ACKs should arrive from the
  * original window even after we transmit two new data segments.
  *
+ * SACK version:
+ *   on first step, wait until first cumulative ACK arrives, then move=
 to
+ *   the second step. In second step, the next ACK decides.
+ *
  * F-RTO is implemented (mainly) in four functions:
  *   - tcp_use_frto() is used to determine if TCP is can use F-RTO
  *   - tcp_enter_frto() prepares TCP state on RTO if F-RTO is used, it=
 is
@@ -2590,16 +2622,38 @@ static int tcp_process_frto(struct sock=20
 		return 1;
 	}
=20
-	/* RFC4138 shortcoming in step 2; should also have case c): ACK isn't
-	 * duplicate nor advances window, e.g., opposite dir data, winupdate
-	 */
-	if ((tp->snd_una =3D=3D prior_snd_una) && (flag&FLAG_NOT_DUP) &&
-	    !(flag&FLAG_FORWARD_PROGRESS))
-		return 1;
+	if (!IsSackFrto() || IsReno(tp)) {
+		/* RFC4138 shortcoming in step 2; should also have case c):
+		 * ACK isn't duplicate nor advances window, e.g., opposite dir
+		 * data, winupdate
+		 */
+		if ((tp->snd_una =3D=3D prior_snd_una) && (flag&FLAG_NOT_DUP) &&
+		    !(flag&FLAG_FORWARD_PROGRESS))
+			return 1;
=20
-	if (!(flag&FLAG_DATA_ACKED)) {
-		tcp_enter_frto_loss(sk, (tp->frto_counter =3D=3D 1 ? 0 : 3), flag);
-		return 1;
+		if (!(flag&FLAG_DATA_ACKED)) {
+			tcp_enter_frto_loss(sk, (tp->frto_counter =3D=3D 1 ? 0 : 3),
+					    flag);
+			return 1;
+		}
+	} else {
+		if (!(flag&FLAG_DATA_ACKED) && (tp->frto_counter =3D=3D 1)) {
+			/* Prevent sending of new data. */
+			tp->snd_cwnd =3D min(tp->snd_cwnd,
+					   tcp_packets_in_flight(tp));
+			return 1;
+		}
+
+		if ((tp->frto_counter =3D=3D 2) &&
+		    (!(flag&FLAG_FORWARD_PROGRESS) ||
+		     ((flag&FLAG_DATA_SACKED) && !(flag&FLAG_ONLY_ORIG_SACKED)))) {
+			/* RFC4138 shortcoming (see comment above) */
+			if (!(flag&FLAG_FORWARD_PROGRESS) && (flag&FLAG_NOT_DUP))
+				return 1;
+
+			tcp_enter_frto_loss(sk, 3, flag);
+			return 1;
+		}
 	}
=20
 	if (tp->frto_counter =3D=3D 1) {
--=20
1.4.2

