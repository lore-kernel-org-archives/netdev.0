From: Satoru Moriya <satoru.moriya@hds.com>
Subject: [PATCH v2 1/2] tcp: refactor tcp_retransmit_skb() for a single
 return point
Date: Fri, 20 Jan 2012 13:08:02 -0500
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD6A@USINDEVS02.corp.hds.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD67@USINDEVS02.corp.hds.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Seiji Aguchi <seiji.aguchi@hds.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usindpps03.hds.com ([207.126.252.16]:50812 "EHLO
	usindpps03.hds.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754914Ab2ATSIS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 13:08:18 -0500
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD67@USINDEVS02.corp.hds.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is just a cleanup patch for making easy to hook return value
with a tracepoint.

Signed-off-by: Satoru Moriya <satoru.moriya@hds.com>
---
 net/ipv4/tcp_output.c |   31 +++++++++++++++++++++----------
 1 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8c8de27..7bd23a8 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2092,18 +2092,24 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	 * copying overhead: fragmentation, tunneling, mangling etc.
 	 */
 	if (atomic_read(&sk->sk_wmem_alloc) >
-	    min(sk->sk_wmem_queued + (sk->sk_wmem_queued >> 2), sk->sk_sndbuf))
-		return -EAGAIN;
+	    min(sk->sk_wmem_queued + (sk->sk_wmem_queued >> 2), sk->sk_sndbuf)) {
+		err = -EAGAIN;
+		goto out;
+	}
 
 	if (before(TCP_SKB_CB(skb)->seq, tp->snd_una)) {
 		if (before(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
 			BUG();
-		if (tcp_trim_head(sk, skb, tp->snd_una - TCP_SKB_CB(skb)->seq))
-			return -ENOMEM;
+		if (tcp_trim_head(sk, skb, tp->snd_una - TCP_SKB_CB(skb)->seq)) {
+			err = -ENOMEM;
+			goto out;
+		}
 	}
 
-	if (inet_csk(sk)->icsk_af_ops->rebuild_header(sk))
-		return -EHOSTUNREACH; /* Routing failure or similar. */
+	if (inet_csk(sk)->icsk_af_ops->rebuild_header(sk)) {
+		err = -EHOSTUNREACH; /* Routing failure or similar. */
+		goto out;
+	}
 
 	cur_mss = tcp_current_mss(sk);
 
@@ -2113,12 +2119,16 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	 * our retransmit serves as a zero window probe.
 	 */
 	if (!before(TCP_SKB_CB(skb)->seq, tcp_wnd_end(tp)) &&
-	    TCP_SKB_CB(skb)->seq != tp->snd_una)
-		return -EAGAIN;
+	    TCP_SKB_CB(skb)->seq != tp->snd_una) {
+		err = -EAGAIN;
+		goto out;
+	}
 
 	if (skb->len > cur_mss) {
-		if (tcp_fragment(sk, skb, cur_mss, cur_mss))
-			return -ENOMEM; /* We'll try again later. */
+		if (tcp_fragment(sk, skb, cur_mss, cur_mss)) {
+			err = -ENOMEM; /* We'll try again later. */
+			goto out;
+		}
 	} else {
 		int oldpcount = tcp_skb_pcount(skb);
 
@@ -2188,6 +2198,7 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 		 */
 		TCP_SKB_CB(skb)->ack_seq = tp->snd_nxt;
 	}
+out:
 	return err;
 }
 
-- 
1.7.6.4
