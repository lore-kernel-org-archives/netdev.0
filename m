From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH V4 net-next 1/3] ipv6: add the IPV6_FL_F_REFLECT flag to IPV6_FL_A_GET
Date: Fri, 17 Jan 2014 17:15:03 +0100
Message-ID: <1389975305-12477-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:35084 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751964AbaAQQPP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 11:15:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this option, the socket will reply with the flow label value read
on received packets.

The goal is to have a connection with the same flow label in both
direction of the communication.

Changelog of V4:
 * Do not erase the flow label on the listening socket. Use pktopts to
 store the received value

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 include/linux/ipv6.h     |  1 +
 include/uapi/linux/in6.h |  1 +
 net/ipv6/ip6_flowlabel.c | 21 +++++++++++++++++++++
 net/ipv6/tcp_ipv6.c      | 12 +++++++++++-
 4 files changed, 34 insertions(+), 1 deletion(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 7e1ded0..1084304 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -191,6 +191,7 @@ struct ipv6_pinfo {
 	/* sockopt flags */
 	__u16			recverr:1,
 	                        sndflow:1,
+				repflow:1,
 				pmtudisc:3,
 				ipv6only:1,
 				srcprefs:3,	/* 001: prefer temporary address
diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
index f94f1d0..02c0cd6 100644
--- a/include/uapi/linux/in6.h
+++ b/include/uapi/linux/in6.h
@@ -85,6 +85,7 @@ struct in6_flowlabel_req {
 
 #define IPV6_FL_F_CREATE	1
 #define IPV6_FL_F_EXCL		2
+#define IPV6_FL_F_REFLECT	4
 
 #define IPV6_FL_S_NONE		0
 #define IPV6_FL_S_EXCL		1
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index cbc9351..55823f1 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -486,6 +486,11 @@ int ipv6_flowlabel_opt_get(struct sock *sk, struct in6_flowlabel_req *freq)
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6_fl_socklist *sfl;
 
+	if (np->repflow) {
+		freq->flr_label = np->flow_label;
+		return 0;
+	}
+
 	rcu_read_lock_bh();
 
 	for_each_sk_fl_rcu(np, sfl) {
@@ -527,6 +532,15 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 
 	switch (freq.flr_action) {
 	case IPV6_FL_A_PUT:
+		if (freq.flr_flags & IPV6_FL_F_REFLECT) {
+			if (sk->sk_protocol != IPPROTO_TCP)
+				return -ENOPROTOOPT;
+			if (!np->repflow)
+				return -ESRCH;
+			np->flow_label = 0;
+			np->repflow = 0;
+			return 0;
+		}
 		spin_lock_bh(&ip6_sk_fl_lock);
 		for (sflp = &np->ipv6_fl_list;
 		     (sfl = rcu_dereference(*sflp))!=NULL;
@@ -567,6 +581,13 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 		return -ESRCH;
 
 	case IPV6_FL_A_GET:
+		if (freq.flr_flags & IPV6_FL_F_REFLECT) {
+			if (sk->sk_protocol != IPPROTO_TCP)
+				return -ENOPROTOOPT;
+			np->repflow = 1;
+			return 0;
+		}
+
 		if (freq.flr_label & ~IPV6_FLOWLABEL_MASK)
 			return -EINVAL;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index ffd5fa8..47d71ff 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -483,6 +483,9 @@ static int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
 				    &ireq->ir_v6_rmt_addr);
 
 		fl6->daddr = ireq->ir_v6_rmt_addr;
+		if (np->repflow && (ireq->pktopts != NULL))
+			fl6->flowlabel = ip6_flowlabel(ipv6_hdr(ireq->pktopts));
+
 		skb_set_queue_mapping(skb, queue_mapping);
 		err = ip6_xmit(sk, skb, fl6, np->opt, np->tclass);
 		err = net_xmit_eval(err);
@@ -1013,7 +1016,8 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (!isn) {
 		if (ipv6_opt_accepted(sk, skb) ||
 		    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
-		    np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim) {
+		    np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim ||
+		    np->repflow) {
 			atomic_inc(&skb->users);
 			ireq->pktopts = skb;
 		}
@@ -1138,6 +1142,8 @@ static struct sock *tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		newnp->mcast_oif   = inet6_iif(skb);
 		newnp->mcast_hops  = ipv6_hdr(skb)->hop_limit;
 		newnp->rcv_flowinfo = ip6_flowinfo(ipv6_hdr(skb));
+		if (np->repflow)
+			newnp->flow_label = ip6_flowlabel(ipv6_hdr(skb));
 
 		/*
 		 * No need to charge this sock to the relevant IPv6 refcnt debug socks count
@@ -1218,6 +1224,8 @@ static struct sock *tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	newnp->mcast_oif  = inet6_iif(skb);
 	newnp->mcast_hops = ipv6_hdr(skb)->hop_limit;
 	newnp->rcv_flowinfo = ip6_flowinfo(ipv6_hdr(skb));
+	if (np->repflow)
+		newnp->flow_label = ip6_flowlabel(ipv6_hdr(skb));
 
 	/* Clone native IPv6 options from listening socket (if any)
 
@@ -1429,6 +1437,8 @@ ipv6_pktoptions:
 			np->mcast_hops = ipv6_hdr(opt_skb)->hop_limit;
 		if (np->rxopt.bits.rxflow || np->rxopt.bits.rxtclass)
 			np->rcv_flowinfo = ip6_flowinfo(ipv6_hdr(opt_skb));
+		if (np->repflow)
+			np->flow_label = ip6_flowlabel(ipv6_hdr(opt_skb));
 		if (ipv6_opt_accepted(sk, opt_skb)) {
 			skb_set_owner_r(opt_skb, sk);
 			opt_skb = xchg(&np->pktoptions, opt_skb);
-- 
1.8.5.2
