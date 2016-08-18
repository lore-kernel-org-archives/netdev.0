From: Florian Westphal <fw@strlen.de>
Subject: [RFC 2/3] tcp: add tcp_timestamps=2 mode to force tsecr validation on ofo segments
Date: Thu, 18 Aug 2016 14:48:46 +0200
Message-ID: <1471524527-10029-3-git-send-email-fw@strlen.de>
References: <1471524527-10029-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:51584 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754025AbcHRNAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 09:00:09 -0400
In-Reply-To: <1471524527-10029-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds new tcp_timestamps=2 mode.  If enabled, out-of-order segments
(within window but sequence number does not equal to rcv.next)
that carry data (i.e. pure acks are not tested) are also subject to a
check of tsecr, the timestamp echo value.

This make blind data injection more challenging if a connection is using
tcp timestamps as injected packet needs to match expected next sequence
number or carry a timestamp echo within an given range.

This approach could later be made more strict, f.e. this currently
uses tp->lsndtime which is only updated when we send data.

Because we only care about ofo segments, normal fastpath
(successful header prediction) is not changed. We also do not
send a challenge ack, as at least one packet is known to be in-flight
(or lost).

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Documentation/networking/ip-sysctl.txt |  8 ++++++--
 net/ipv4/tcp_input.c                   | 35 ++++++++++++++++++++++++++++++++++
 2 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 9ae9293..1e360a3 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -609,8 +609,12 @@ tcp_syn_retries - INTEGER
 	with the current initial RTO of 1second. With this the final timeout
 	for an active TCP connection attempt will happen after 127seconds.
 
-tcp_timestamps - BOOLEAN
-	Enable timestamps as defined in RFC1323.
+tcp_timestamps - INTEGER
+	0: Disabled.
+	1: Enable timestamps as defined in RFC1323.
+	2: Like 1, but also drop segments that arrive out-of-order if
+	their echo timestamp (TSecr) is outside of an expected range.
+	Default: 1
 
 tcp_min_tso_segs - INTEGER
 	Minimal number of segments per TSO frame.
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 092f2dd..1234244 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -128,6 +128,8 @@ int sysctl_tcp_invalid_ratelimit __read_mostly = HZ/2;
 #define REXMIT_LOST	1 /* retransmit packets marked lost */
 #define REXMIT_NEW	2 /* FRTO-style transmit of unsent/new packets */
 
+#define TSECR_MAX_DELAY		TCP_RTO_MAX
+
 /* Adapt the MSS value used to make delayed ack decision to the
  * real world.
  */
@@ -5165,6 +5167,30 @@ static int tcp_copy_to_iovec(struct sock *sk, struct sk_buff *skb, int hlen)
 	return err;
 }
 
+static bool tcp_validate_tsecr(struct sock *sk, const struct tcphdr *th)
+{
+	const struct tcp_sock *tp = tcp_sk(sk);
+	const struct sk_buff *skb = NULL;
+	u32 ts_low;
+
+	if (sysctl_tcp_timestamps != 2 || !tp->rx_opt.tstamp_ok)
+		return true;
+
+	/* packet has no timestamp but connection is supposed to */
+	if (!tp->rx_opt.saw_tstamp)
+		return false;
+
+	ts_low = tp->retrans_stamp;
+	if (ts_low == 0) {
+		skb = tcp_write_queue_head(sk);
+		ts_low = skb ? tcp_skb_timestamp(skb) : tp->lsndtime;
+	}
+
+	ts_low -= TSECR_MAX_DELAY;
+
+	return between(tp->rx_opt.rcv_tsecr, ts_low, tcp_time_stamp);
+}
+
 /* Does PAWS and seqno based validation of an incoming segment, flags will
  * play significant role here.
  */
@@ -5255,6 +5281,15 @@ syn_challenge:
 		goto discard;
 	}
 
+	if (TCP_SKB_CB(skb)->seq == tp->rcv_nxt ||
+	    TCP_SKB_CB(skb)->seq == TCP_SKB_CB(skb)->end_seq)
+		return true;
+
+	/* last step: ofo and not pure ack: check tsecr */
+	if (!tcp_validate_tsecr(sk, th)) {
+		goto discard;
+	}
+
 	return true;
 
 discard:
-- 
2.7.3
