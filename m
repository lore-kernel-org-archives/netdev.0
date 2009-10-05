From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] Use sk_mark for IPv6 routing lookups
Date: Mon, 05 Oct 2009 14:24:16 -0400
Message-ID: <4ACA39D0.3080306@hp.com>
References: <200910011814.47689.atis@mikrotik.com> <55a4f86e0910021025u7523029av1e4ee917d1fb1ee5@mail.gmail.com> <4AC64419.6020202@hp.com> <200910051555.41543.atis@mikrotik.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?TWFjaWVqIMW7ZW5jenlrb3dza2k=?= <zenczykowski@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Atis Elsts <atis@mikrotik.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:48733 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754160AbZJESY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 14:24:57 -0400
In-Reply-To: <200910051555.41543.atis@mikrotik.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Atis Elsts wrote:
> Not sure if there is need to fill the mark from skb in tunnel xmit functions. In any case, it's not done for GRE or IPIP tunnels at the moment.

Ok, I'll just drop that part, I'm not sure what should be done in this case.

> Also, in this patch you are doing that for SIT (v6-in-v4) tunnels only, and not doing it for v4-in-v6 or v6-in-v6 tunnels. Any reason for that?

I just sent that patch out too quickly, here's a better one with the updates.


Add support for IPv6 route lookups using sk_mark.

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index e127a32..da36497 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -654,6 +654,7 @@ int inet6_sk_rebuild_header(struct sock *sk)
 		ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 		fl.fl6_flowlabel = np->flow_label;
 		fl.oif = sk->sk_bound_dev_if;
+		fl.mark = sk->sk_mark;
 		fl.fl_ip_dport = inet->dport;
 		fl.fl_ip_sport = inet->sport;
 		security_sk_classify_flow(sk, &fl);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index e2bdc6d..a615b4d 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -147,6 +147,7 @@ ipv4_connected:
 	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
 	ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 	fl.oif = sk->sk_bound_dev_if;
+	fl.mark = sk->sk_mark;
 	fl.fl_ip_dport = inet->dport;
 	fl.fl_ip_sport = inet->sport;
 
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index cc4797d..a9f4a21 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -194,6 +194,7 @@ int inet6_csk_xmit(struct sk_buff *skb, int ipfragok)
 	fl.fl6_flowlabel = np->flow_label;
 	IP6_ECN_flow_xmit(sk, fl.fl6_flowlabel);
 	fl.oif = sk->sk_bound_dev_if;
+	fl.mark = sk->sk_mark;
 	fl.fl_ip_sport = inet->sport;
 	fl.fl_ip_dport = inet->dport;
 	security_sk_classify_flow(sk, &fl);
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 14f54eb..dc0f736 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -424,6 +424,7 @@ sticky_done:
 
 		fl.fl6_flowlabel = 0;
 		fl.oif = sk->sk_bound_dev_if;
+		fl.mark = sk->sk_mark;
 
 		if (optlen == 0)
 			goto update;
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 6b6ae91..cbe55e5 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -252,6 +252,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		}
 		ipv6_addr_copy(&fl.fl6_src, &ireq6->loc_addr);
 		fl.oif = sk->sk_bound_dev_if;
+		fl.mark = sk->sk_mark;
 		fl.fl_ip_dport = inet_rsk(req)->rmt_port;
 		fl.fl_ip_sport = inet_sk(sk)->sport;
 		security_req_classify_flow(req, &fl);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 21d100b..321aafd 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -243,6 +243,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	ipv6_addr_copy(&fl.fl6_src,
 		       (saddr ? saddr : &np->saddr));
 	fl.oif = sk->sk_bound_dev_if;
+	fl.mark = sk->sk_mark;
 	fl.fl_ip_dport = usin->sin6_port;
 	fl.fl_ip_sport = inet->sport;
 
@@ -383,6 +384,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
 			ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 			fl.oif = sk->sk_bound_dev_if;
+			fl.mark = sk->sk_mark;
 			fl.fl_ip_dport = inet->dport;
 			fl.fl_ip_sport = inet->sport;
 			security_skb_classify_flow(skb, &fl);
@@ -477,6 +479,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req)
 	ipv6_addr_copy(&fl.fl6_src, &treq->loc_addr);
 	fl.fl6_flowlabel = 0;
 	fl.oif = treq->iif;
+	fl.mark = sk->sk_mark;
 	fl.fl_ip_dport = inet_rsk(req)->rmt_port;
 	fl.fl_ip_sport = inet_rsk(req)->loc_port;
 	security_req_classify_flow(req, &fl);
@@ -1345,6 +1348,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		}
 		ipv6_addr_copy(&fl.fl6_src, &treq->loc_addr);
 		fl.oif = sk->sk_bound_dev_if;
+		fl.mark = sk->sk_mark;
 		fl.fl_ip_dport = inet_rsk(req)->rmt_port;
 		fl.fl_ip_sport = inet_rsk(req)->loc_port;
 		security_req_classify_flow(req, &fl);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 3a60f12..3842c55 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -879,6 +879,8 @@ do_udp_sendmsg:
 	if (!fl.oif)
 		fl.oif = np->sticky_pktinfo.ipi6_ifindex;
 
+	fl.mark = sk->sk_mark;
+
 	if (msg->msg_controllen) {
 		opt = &opt_space;
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
