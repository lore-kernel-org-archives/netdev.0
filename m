From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net] tcp: randomize timestamps on syncookies
Date: Fri, 5 May 2017 02:32:08 +0200
Message-ID: <20170505003208.GI13320@breakpoint.cc>
References: <1493935361.7796.29.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170505002456.GH13320@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:59250 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752330AbdEEAca (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 20:32:30 -0400
Content-Disposition: inline
In-Reply-To: <20170505002456.GH13320@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Westphal <fw@strlen.de> wrote:
[..]
> This breaks syncookies w. timestamps; cookie_timestamp_decode() lacks a tsoff
> for readjustment.
> 
> We also need to pass the (recomputed) tsoff to tcp_get_cookie_sock().

This small delta makes things work for me:

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 1be353fc5cb1..8c0e5a901d64 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -470,7 +470,7 @@ void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb);
 /* From syncookies.c */
 struct sock *tcp_get_cookie_sock(struct sock *sk, struct sk_buff *skb,
 				 struct request_sock *req,
-				 struct dst_entry *dst);
+				 struct dst_entry *dst, u32 tsoff);
 int __cookie_v4_check(const struct iphdr *iph, const struct tcphdr *th,
 		      u32 cookie);
 struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb);
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 496b97e17aaf..39bfdc94bf44 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -16,6 +16,7 @@
 #include <linux/siphash.h>
 #include <linux/kernel.h>
 #include <linux/export.h>
+#include <net/secure_seq.h>
 #include <net/tcp.h>
 #include <net/route.h>
 
@@ -203,7 +204,7 @@ EXPORT_SYMBOL_GPL(__cookie_v4_check);
 
 struct sock *tcp_get_cookie_sock(struct sock *sk, struct sk_buff *skb,
 				 struct request_sock *req,
-				 struct dst_entry *dst)
+				 struct dst_entry *dst, u32 tsoff)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct sock *child;
@@ -213,6 +214,7 @@ struct sock *tcp_get_cookie_sock(struct sock *sk, struct sk_buff *skb,
 						 NULL, &own_req);
 	if (child) {
 		atomic_set(&req->rsk_refcnt, 1);
+		tcp_sk(child)->tsoffset = tsoff;
 		sock_rps_save_rxhash(child, skb);
 		inet_csk_reqsk_queue_add(sk, req, child);
 	} else {
@@ -292,6 +294,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	struct rtable *rt;
 	__u8 rcv_wscale;
 	struct flowi4 fl4;
+	u32 tsoff;
 
 	if (!sock_net(sk)->ipv4.sysctl_tcp_syncookies || !th->ack || th->rst)
 		goto out;
@@ -311,6 +314,12 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
 	tcp_parse_options(skb, &tcp_opt, 0, NULL);
 
+	tsoff = 0;
+	if (tcp_opt.saw_tstamp && tcp_opt.rcv_tsecr) {
+		tsoff = secure_tcp_ts_off(ip_hdr(skb)->daddr, ip_hdr(skb)->saddr);
+		tcp_opt.rcv_tsecr -= tsoff;
+	}
+
 	if (!cookie_timestamp_decode(&tcp_opt))
 		goto out;
 
@@ -381,7 +390,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	ireq->rcv_wscale  = rcv_wscale;
 	ireq->ecn_ok = cookie_ecn_ok(&tcp_opt, sock_net(sk), &rt->dst);
 
-	ret = tcp_get_cookie_sock(sk, skb, req, &rt->dst);
+	ret = tcp_get_cookie_sock(sk, skb, req, &rt->dst, tsoff);
 	/* ip_queue_xmit() depends on our flow being setup
 	 * Normal sockets get it right from inet_csk_route_child_sock()
 	 */
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 895ff650db43..eb96825d6340 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -18,6 +18,7 @@
 #include <linux/random.h>
 #include <linux/siphash.h>
 #include <linux/kernel.h>
+#include <net/secure_seq.h>
 #include <net/ipv6.h>
 #include <net/tcp.h>
 
@@ -143,6 +144,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	int mss;
 	struct dst_entry *dst;
 	__u8 rcv_wscale;
+	u32 tsoff;
 
 	if (!sock_net(sk)->ipv4.sysctl_tcp_syncookies || !th->ack || th->rst)
 		goto out;
@@ -162,6 +164,12 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
 	tcp_parse_options(skb, &tcp_opt, 0, NULL);
 
+	tsoff = 0;
+	if (tcp_opt.saw_tstamp && tcp_opt.rcv_tsecr) {
+		tsoff = secure_tcpv6_ts_off(&ip_hdr(skb)->daddr, &ip_hdr(skb)->saddr);
+		tcp_opt.rcv_tsecr -= tsoff;
+	}
+
 	if (!cookie_timestamp_decode(&tcp_opt))
 		goto out;
 
@@ -242,7 +250,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	ireq->rcv_wscale = rcv_wscale;
 	ireq->ecn_ok = cookie_ecn_ok(&tcp_opt, sock_net(sk), dst);
 
-	ret = tcp_get_cookie_sock(sk, skb, req, dst);
+	ret = tcp_get_cookie_sock(sk, skb, req, dst, tsoff);
 out:
 	return ret;
 out_free:
