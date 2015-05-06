From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 2/2] tcp: add TCPWinProbe and TCPKeepAlive SNMP counters
Date: Wed,  6 May 2015 14:26:25 -0700
Message-ID: <1430947585-2375-3-git-send-email-edumazet@google.com>
References: <1430947585-2375-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f74.google.com ([209.85.192.74]:34414 "EHLO
	mail-qg0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868AbbEFVdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 17:33:54 -0400
Received: by qgdq107 with SMTP id q107so708179qgd.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 14:33:54 -0700 (PDT)
In-Reply-To: <1430947585-2375-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Diagnosing problems related to Window Probes has been hard because
we lack a counter.

TCPWinProbe counts the number of ACK packets a sender has to send
at regular intervals to make sure a reverse ACK packet opening back
a window had not been lost.

TCPKeepAlive counts the number of ACK packets sent to keep TCP
flows alive (SO_KEEPALIVE)

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 include/net/tcp.h         |  2 +-
 include/uapi/linux/snmp.h |  2 ++
 net/ipv4/proc.c           |  2 ++
 net/ipv4/tcp_output.c     | 13 +++++++------
 net/ipv4/tcp_timer.c      |  2 +-
 5 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7a2248a35b13..b8ea12880fd9 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -527,7 +527,7 @@ int tcp_fragment(struct sock *, struct sk_buff *, u32, unsigned int, gfp_t);
 
 void tcp_send_probe0(struct sock *);
 void tcp_send_partial(struct sock *);
-int tcp_write_wakeup(struct sock *);
+int tcp_write_wakeup(struct sock *, int mib);
 void tcp_send_fin(struct sock *sk);
 void tcp_send_active_reset(struct sock *sk, gfp_t priority);
 int tcp_send_synack(struct sock *);
diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index 6a6fb747c78d..eee8968407f0 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -276,6 +276,8 @@ enum
 	LINUX_MIB_TCPACKSKIPPEDFINWAIT2,	/* TCPACKSkippedFinWait2 */
 	LINUX_MIB_TCPACKSKIPPEDTIMEWAIT,	/* TCPACKSkippedTimeWait */
 	LINUX_MIB_TCPACKSKIPPEDCHALLENGE,	/* TCPACKSkippedChallenge */
+	LINUX_MIB_TCPWINPROBE,			/* TCPWinProbe */
+	LINUX_MIB_TCPKEEPALIVE,			/* TCPKeepAlive */
 	__LINUX_MIB_MAX
 };
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index e1f3b911dd1e..da5d483e236a 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -298,6 +298,8 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPACKSkippedFinWait2", LINUX_MIB_TCPACKSKIPPEDFINWAIT2),
 	SNMP_MIB_ITEM("TCPACKSkippedTimeWait", LINUX_MIB_TCPACKSKIPPEDTIMEWAIT),
 	SNMP_MIB_ITEM("TCPACKSkippedChallenge", LINUX_MIB_TCPACKSKIPPEDCHALLENGE),
+	SNMP_MIB_ITEM("TCPWinProbe", LINUX_MIB_TCPWINPROBE),
+	SNMP_MIB_ITEM("TCPKeepAlive", LINUX_MIB_TCPKEEPALIVE),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index b76c719e1979..7386d32cd670 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3382,7 +3382,7 @@ EXPORT_SYMBOL_GPL(tcp_send_ack);
  * one is with SEG.SEQ=SND.UNA to deliver urgent pointer, another is
  * out-of-date with SND.UNA-1 to probe window.
  */
-static int tcp_xmit_probe_skb(struct sock *sk, int urgent)
+static int tcp_xmit_probe_skb(struct sock *sk, int urgent, int mib)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
@@ -3400,6 +3400,7 @@ static int tcp_xmit_probe_skb(struct sock *sk, int urgent)
 	 */
 	tcp_init_nondata_skb(skb, tp->snd_una - !urgent, TCPHDR_ACK);
 	skb_mstamp_get(&skb->skb_mstamp);
+	NET_INC_STATS_BH(sock_net(sk), mib);
 	return tcp_transmit_skb(sk, skb, 0, GFP_ATOMIC);
 }
 
@@ -3407,12 +3408,12 @@ void tcp_send_window_probe(struct sock *sk)
 {
 	if (sk->sk_state == TCP_ESTABLISHED) {
 		tcp_sk(sk)->snd_wl1 = tcp_sk(sk)->rcv_nxt - 1;
-		tcp_xmit_probe_skb(sk, 0);
+		tcp_xmit_probe_skb(sk, 0, LINUX_MIB_TCPWINPROBE);
 	}
 }
 
 /* Initiate keepalive or window probe from timer. */
-int tcp_write_wakeup(struct sock *sk)
+int tcp_write_wakeup(struct sock *sk, int mib)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
@@ -3449,8 +3450,8 @@ int tcp_write_wakeup(struct sock *sk)
 		return err;
 	} else {
 		if (between(tp->snd_up, tp->snd_una + 1, tp->snd_una + 0xFFFF))
-			tcp_xmit_probe_skb(sk, 1);
-		return tcp_xmit_probe_skb(sk, 0);
+			tcp_xmit_probe_skb(sk, 1, mib);
+		return tcp_xmit_probe_skb(sk, 0, mib);
 	}
 }
 
@@ -3464,7 +3465,7 @@ void tcp_send_probe0(struct sock *sk)
 	unsigned long probe_max;
 	int err;
 
-	err = tcp_write_wakeup(sk);
+	err = tcp_write_wakeup(sk, LINUX_MIB_TCPWINPROBE);
 
 	if (tp->packets_out || !tcp_send_head(sk)) {
 		/* Cancel probe timer, if it is not required. */
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 8c65dc147d8b..65bf670e8714 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -616,7 +616,7 @@ static void tcp_keepalive_timer (unsigned long data)
 			tcp_write_err(sk);
 			goto out;
 		}
-		if (tcp_write_wakeup(sk) <= 0) {
+		if (tcp_write_wakeup(sk, LINUX_MIB_TCPKEEPALIVE) <= 0) {
 			icsk->icsk_probes_out++;
 			elapsed = keepalive_intvl_when(tp);
 		} else {
-- 
2.2.0.rc0.207.ga3a616c
