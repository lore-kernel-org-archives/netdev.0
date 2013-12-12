From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH RFC 1/2] ipv6: add the IPV6_FL_F_REPLY flag to IPV6_FL_A_GET
Date: Thu, 12 Dec 2013 11:38:16 +0100
Message-ID: <1386844697-31169-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:37887 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751155Ab3LLKiZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Dec 2013 05:38:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this option, the socket will reply with the flow label value read
on received packets.

The goal is to have a connection with the same flow label in both
direction of the communication.

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 include/linux/ipv6.h     |  1 +
 include/uapi/linux/in6.h |  1 +
 net/ipv6/ip6_flowlabel.c | 16 ++++++++++++++++
 net/ipv6/tcp_ipv6.c      | 10 ++++++++++
 4 files changed, 28 insertions(+)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 3fde066..f3dce48 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -191,6 +191,7 @@ struct ipv6_pinfo {
 	/* sockopt flags */
 	__u16			recverr:1,
 	                        sndflow:1,
+				repflow:1,
 				pmtudisc:2,
 				ipv6only:1,
 				srcprefs:3,	/* 001: prefer temporary address
diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
index 440d5c4..4686c1f 100644
--- a/include/uapi/linux/in6.h
+++ b/include/uapi/linux/in6.h
@@ -85,6 +85,7 @@ struct in6_flowlabel_req {
 
 #define IPV6_FL_F_CREATE	1
 #define IPV6_FL_F_EXCL		2
+#define IPV6_FL_F_REPLY 	4
 
 #define IPV6_FL_S_NONE		0
 #define IPV6_FL_S_EXCL		1
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index e7fb710..6bc17dc 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -527,6 +527,15 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 
 	switch (freq.flr_action) {
 	case IPV6_FL_A_PUT:
+		if (freq.flr_flags & IPV6_FL_F_REPLY) {
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
@@ -567,6 +576,13 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 		return -ESRCH;
 
 	case IPV6_FL_A_GET:
+		if (freq.flr_flags & IPV6_FL_F_REPLY) {
+			if (sk->sk_protocol != IPPROTO_TCP)
+				return -ENOPROTOOPT;
+			np->repflow = 1;
+			return 0;
+		}
+
 		if (freq.flr_label & ~IPV6_FLOWLABEL_MASK)
 			return -EINVAL;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index da046a5..798c4bc 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -480,6 +480,8 @@ static int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
 				    &ireq->ir_v6_rmt_addr);
 
 		fl6->daddr = ireq->ir_v6_rmt_addr;
+		if (np->repflow)
+			fl6->flowlabel = np->flow_label;
 		skb_set_queue_mapping(skb, queue_mapping);
 		err = ip6_xmit(sk, skb, fl6, np->opt, np->tclass);
 		err = net_xmit_eval(err);
@@ -997,6 +999,8 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	ireq = inet_rsk(req);
 	ireq->ir_v6_rmt_addr = ipv6_hdr(skb)->saddr;
 	ireq->ir_v6_loc_addr = ipv6_hdr(skb)->daddr;
+	if (np->repflow)
+		np->flow_label = ip6_flowlabel(ipv6_hdr(skb));
 	if (!want_cookie || tmp_opt.tstamp_ok)
 		TCP_ECN_create_request(req, skb, sock_net(sk));
 
@@ -1135,6 +1139,8 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		newnp->mcast_oif   = inet6_iif(skb);
 		newnp->mcast_hops  = ipv6_hdr(skb)->hop_limit;
 		newnp->rcv_flowinfo = ip6_flowinfo(ipv6_hdr(skb));
+		if (np->repflow)
+			newnp->flow_label = ip6_flowlabel(ipv6_hdr(skb));
 
 		/*
 		 * No need to charge this sock to the relevant IPv6 refcnt debug socks count
@@ -1215,6 +1221,8 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	newnp->mcast_oif  = inet6_iif(skb);
 	newnp->mcast_hops = ipv6_hdr(skb)->hop_limit;
 	newnp->rcv_flowinfo = ip6_flowinfo(ipv6_hdr(skb));
+	if (np->repflow)
+		newnp->flow_label = ip6_flowlabel(ipv6_hdr(skb));
 
 	/* Clone native IPv6 options from listening socket (if any)
 
@@ -1426,6 +1434,8 @@ ipv6_pktoptions:
 			np->mcast_hops = ipv6_hdr(opt_skb)->hop_limit;
 		if (np->rxopt.bits.rxflow || np->rxopt.bits.rxtclass)
 			np->rcv_flowinfo = ip6_flowinfo(ipv6_hdr(opt_skb));
+		if (np->repflow)
+			np->flow_label = ip6_flowlabel(ipv6_hdr(opt_skb));
 		if (ipv6_opt_accepted(sk, opt_skb)) {
 			skb_set_owner_r(opt_skb, sk);
 			opt_skb = xchg(&np->pktoptions, opt_skb);
-- 
1.8.5.1
