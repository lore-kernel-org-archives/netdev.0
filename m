From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/2] [TCP]: DSACK signals data receival, be conservative
Date: Wed, 1 Aug 2007 21:06:55 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0708012106170.27657@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0708012054180.27657@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1171963027-1185991615=:27657"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58742 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764596AbXHASG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2007 14:06:57 -0400
In-Reply-To: <Pine.LNX.4.64.0708012054180.27657@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1171963027-1185991615=:27657
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


In case a DSACK is received, it's better to lower cwnd as it's
a sign of data receival.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c3124e6..f030435 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -103,6 +103,7 @@ int sysctl_tcp_abc __read_mostly;
 #define FLAG_SLOWPATH		0x100 /* Do not skip RFC checks for window update.*/
 #define FLAG_ONLY_ORIG_SACKED	0x200 /* SACKs only non-rexmit sent before RTO */
 #define FLAG_SND_UNA_ADVANCED	0x400 /* Snd_una was changed (!= FLAG_DATA_ACKED) */
+#define FLAG_DSACKING_ACK	0x800 /* SACK blocks contained DSACK info */
 
 #define FLAG_ACKED		(FLAG_DATA_ACKED|FLAG_SYN_ACKED)
 #define FLAG_NOT_DUP		(FLAG_DATA|FLAG_WIN_UPDATE|FLAG_ACKED)
@@ -966,12 +967,14 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 
 	/* Check for D-SACK. */
 	if (before(ntohl(sp[0].start_seq), TCP_SKB_CB(ack_skb)->ack_seq)) {
+		flag |= FLAG_DSACKING_ACK;
 		found_dup_sack = 1;
 		tp->rx_opt.sack_ok |= 4;
 		NET_INC_STATS_BH(LINUX_MIB_TCPDSACKRECV);
 	} else if (num_sacks > 1 &&
 			!after(ntohl(sp[0].end_seq), ntohl(sp[1].end_seq)) &&
 			!before(ntohl(sp[0].start_seq), ntohl(sp[1].start_seq))) {
+		flag |= FLAG_DSACKING_ACK;
 		found_dup_sack = 1;
 		tp->rx_opt.sack_ok |= 4;
 		NET_INC_STATS_BH(LINUX_MIB_TCPDSACKOFORECV);
@@ -1858,7 +1861,7 @@ static void tcp_cwnd_down(struct sock *sk, int flag)
 	struct tcp_sock *tp = tcp_sk(sk);
 	int decr = tp->snd_cwnd_cnt + 1;
 
-	if ((flag&FLAG_ANY_PROGRESS) ||
+	if ((flag&(FLAG_ANY_PROGRESS|FLAG_DSACKING_ACK)) ||
 	    (IsReno(tp) && !(flag&FLAG_NOT_DUP))) {
 		tp->snd_cwnd_cnt = decr&1;
 		decr >>= 1;
-- 
1.5.0.6

---696243703-1171963027-1185991615=:27657--
