From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Assertions in latest kernels
Date: Wed, 23 Jan 2008 13:42:29 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801231335220.31652@kivilampi-30.cs.helsinki.fi>
References: <OFADDD4CF1.583863C7-ON652573D9.003CD405-652573D9.003CA37C@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47149 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbYAWLmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 06:42:32 -0500
In-Reply-To: <OFADDD4CF1.583863C7-ON652573D9.003CD405-652573D9.003CA37C@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Jan 2008, Krishna Kumar2 wrote:

> While running with this patch, I got these errors (pasted at the end
> of this mail).

I don't have a clue why it didn't go to the checking func (or it didn't 
print anything) but just had those WARN_ONs... Hopefully this is giving 
somewhat better input (applies on top of the other debug patch).

--
 i.

[PATCH] [TCP]: more debug

---
 include/net/tcp.h    |    3 ++-
 net/ipv4/tcp_input.c |    9 ++++++++-
 net/ipv4/tcp_ipv4.c  |   19 ++++++++++++++-----
 3 files changed, 24 insertions(+), 7 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0685035..129c3b1 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -272,6 +272,7 @@ DECLARE_SNMP_STAT(struct tcp_mib, tcp_statistics);
 #define TCP_ADD_STATS_BH(field, val)	SNMP_ADD_STATS_BH(tcp_statistics, field, val)
 #define TCP_ADD_STATS_USER(field, val)	SNMP_ADD_STATS_USER(tcp_statistics, field, val)
 
+extern void tcp_print_queue(struct sock *sk);
 extern void			tcp_verify_wq(struct sock *sk);
 
 extern void			tcp_v4_err(struct sk_buff *skb, u32);
@@ -772,8 +773,8 @@ static inline __u32 tcp_current_ssthresh(const struct sock *sk)
 /* Use define here intentionally to get WARN_ON location shown at the caller */
 #define tcp_verify_left_out(tp)	\
 	do { \
-		WARN_ON(tcp_left_out(tp) > tp->packets_out); \
 		tcp_verify_wq((struct sock *)tp); \
+		WARN_ON(tcp_left_out(tp) > tp->packets_out); \
 	} while(0)
 
 extern void tcp_enter_cwr(struct sock *sk, const int set_ssthresh);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index cdacf70..295490e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2133,12 +2133,15 @@ static void tcp_verify_retransmit_hint(struct tcp_sock *tp, struct sk_buff *skb)
 static void tcp_mark_head_lost(struct sock *sk, int packets, int fast_rexmit)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct sk_buff *skb;
+	struct sk_buff *skb, *prev = NULL;
 	int cnt;
 
+	tcp_verify_left_out(tp);
+
 	BUG_TRAP(packets <= tp->packets_out);
 	if (tp->lost_skb_hint) {
 		skb = tp->lost_skb_hint;
+		prev = skb;
 		cnt = tp->lost_cnt_hint;
 	} else {
 		skb = tcp_write_queue_head(sk);
@@ -2166,6 +2169,10 @@ static void tcp_mark_head_lost(struct sock *sk, int packets, int fast_rexmit)
 			tcp_verify_retransmit_hint(tp, skb);
 		}
 	}
+	if (tcp_left_out(tp) > tp->packets_out) {
+		printk(KERN_ERR "Prev hint: %p, exit %p\n", prev, skb);
+		tcp_print_queue(sk);
+	}
 	tcp_verify_left_out(tp);
 }
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index c95682e..c2a88c5 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -117,6 +117,15 @@ void tcp_print_queue(struct sock *sk)
 	int idx = 0;
 	int i;
 
+	i = 0;
+	tcp_for_write_queue(skb, sk) {
+		if (skb == tcp_send_head(sk))
+			printk(KERN_ERR "head %u %p\n", i, skb);		
+		else
+			printk(KERN_ERR "skb %u %p\n", i, skb);
+		i++;
+	}
+
 	tcp_for_write_queue(skb, sk) {
 		if (skb == tcp_send_head(sk))
 			break;
@@ -195,11 +204,6 @@ void tcp_verify_wq(struct sock *sk)
 		packets += tcp_skb_pcount(skb);
 	}
 
-	WARN_ON(lost != tp->lost_out);
-	WARN_ON(tcp_is_sack(tp) && (sacked != tp->sacked_out));
-	WARN_ON(packets != tp->packets_out);
-	WARN_ON(fackets != tp->fackets_out);
-
 	if ((lost != tp->lost_out) ||
 	    (tcp_is_sack(tp) && (sacked != tp->sacked_out)) ||
 	    (packets != tp->packets_out) ||
@@ -213,6 +217,11 @@ void tcp_verify_wq(struct sock *sk)
 			tp->rx_opt.sack_ok);
 		tcp_print_queue(sk);
 	}
+
+	WARN_ON(lost != tp->lost_out);
+	WARN_ON(tcp_is_sack(tp) && (sacked != tp->sacked_out));
+	WARN_ON(packets != tp->packets_out);
+	WARN_ON(fackets != tp->fackets_out);
 }
 
 static int tcp_v4_get_port(struct sock *sk, unsigned short snum)
-- 
1.5.2.2

