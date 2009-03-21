From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCHv2] net/*: use linux/kernel.h swap()
Date: Sat, 21 Mar 2009 15:16:09 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0903211514370.31762@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0903192305360.30791@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="-696208474-319582149-1237497133=:30791"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54672 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752963AbZCUNQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 09:16:13 -0400
In-Reply-To: <Pine.LNX.4.64.0903192305360.30791@wrl-59.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0903211514371.31762@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-319582149-1237497133=:30791
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0903211514372.31762@wrl-59.cs.helsinki.fi>


tcp_sack_swap seems unnecessary so I pushed swap to the caller.
Also removed comment that seemed then pointless, and added include
when not already there. Compile tested.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---

v2 removes the tcp_sack_swap completely().

 net/decnet/dn_route.c |    6 +-----
 net/ipv4/tcp_input.c  |   23 +++--------------------
 net/ipv6/addrconf.c   |    7 ++-----
 net/sched/sch_tbf.c   |    9 ++-------
 4 files changed, 8 insertions(+), 37 deletions(-)

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 5130dee..0cc4394 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -380,7 +380,6 @@ static int dn_return_short(struct sk_buff *skb)
 	unsigned char *ptr;
 	__le16 *src;
 	__le16 *dst;
-	__le16 tmp;
 
 	/* Add back headers */
 	skb_push(skb, skb->data - skb_network_header(skb));
@@ -399,10 +398,7 @@ static int dn_return_short(struct sk_buff *skb)
 	ptr += 2;
 	*ptr = 0; /* Zero hop count */
 
-	/* Swap source and destination */
-	tmp  = *src;
-	*src = *dst;
-	*dst = tmp;
+	swap(*src, *dst);
 
 	skb->pkt_type = PACKET_OUTGOING;
 	dn_rt_finish_output(skb, NULL, NULL);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fae78e3..8ac82b3 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -64,6 +64,7 @@
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/sysctl.h>
+#include <linux/kernel.h>
 #include <net/dst.h>
 #include <net/tcp.h>
 #include <net/inet_common.h>
@@ -1802,11 +1803,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 	for (i = used_sacks - 1; i > 0; i--) {
 		for (j = 0; j < i; j++) {
 			if (after(sp[j].start_seq, sp[j + 1].start_seq)) {
-				struct tcp_sack_block tmp;
-
-				tmp = sp[j];
-				sp[j] = sp[j + 1];
-				sp[j + 1] = tmp;
+				swap(sp[j], sp[j + 1]);
 
 				/* Track where the first SACK block goes to */
 				if (j == first_sack_index)
@@ -4156,20 +4153,6 @@ static void tcp_sack_maybe_coalesce(struct tcp_sock *tp)
 	}
 }
 
-static inline void tcp_sack_swap(struct tcp_sack_block *sack1,
-				 struct tcp_sack_block *sack2)
-{
-	__u32 tmp;
-
-	tmp = sack1->start_seq;
-	sack1->start_seq = sack2->start_seq;
-	sack2->start_seq = tmp;
-
-	tmp = sack1->end_seq;
-	sack1->end_seq = sack2->end_seq;
-	sack2->end_seq = tmp;
-}
-
 static void tcp_sack_new_ofo_skb(struct sock *sk, u32 seq, u32 end_seq)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -4184,7 +4167,7 @@ static void tcp_sack_new_ofo_skb(struct sock *sk, u32 seq, u32 end_seq)
 		if (tcp_sack_extend(sp, seq, end_seq)) {
 			/* Rotate this_sack to the first one. */
 			for (; this_sack > 0; this_sack--, sp--)
-				tcp_sack_swap(sp, sp - 1);
+				swap(*sp, *(sp - 1));
 			if (cur_sacks > 1)
 				tcp_sack_maybe_coalesce(tp);
 			return;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 717584b..8499da9 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -40,6 +40,7 @@
 
 #include <linux/errno.h>
 #include <linux/types.h>
+#include <linux/kernel.h>
 #include <linux/socket.h>
 #include <linux/sockios.h>
 #include <linux/net.h>
@@ -1215,16 +1216,12 @@ int ipv6_dev_get_saddr(struct net *net, struct net_device *dst_dev,
 					}
 					break;
 				} else if (minihiscore < miniscore) {
-					struct ipv6_saddr_score *tmp;
-
 					if (hiscore->ifa)
 						in6_ifa_put(hiscore->ifa);
 
 					in6_ifa_hold(score->ifa);
 
-					tmp = hiscore;
-					hiscore = score;
-					score = tmp;
+					swap(hiscore, score);
 
 					/* restore our iterator */
 					score->ifa = hiscore->ifa;
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index a2f93c0..e22dfe8 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -236,7 +236,6 @@ static int tbf_change(struct Qdisc* sch, struct nlattr *opt)
 	struct tc_tbf_qopt *qopt;
 	struct qdisc_rate_table *rtab = NULL;
 	struct qdisc_rate_table *ptab = NULL;
-	struct qdisc_rate_table *tmp;
 	struct Qdisc *child = NULL;
 	int max_size,n;
 
@@ -295,13 +294,9 @@ static int tbf_change(struct Qdisc* sch, struct nlattr *opt)
 	q->tokens = q->buffer;
 	q->ptokens = q->mtu;
 
-	tmp = q->R_tab;
-	q->R_tab = rtab;
-	rtab = tmp;
+	swap(q->R_tab, rtab);
+	swap(q->P_tab, ptab);
 
-	tmp = q->P_tab;
-	q->P_tab = ptab;
-	ptab = tmp;
 	sch_tree_unlock(sch);
 	err = 0;
 done:
-- 
1.5.6.5

---696208474-319582149-1237497133=:30791--
