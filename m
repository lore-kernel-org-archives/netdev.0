From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6.26] [IPV6]: Share common code-paths for sticky
 socket options.
Date: Sun, 13 Apr 2008 16:58:35 +0900 (JST)
Message-ID: <20080413.165835.51630475.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33445 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129AbYDMH4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2008 03:56:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ipv6_sockglue.c |   64 ++++++++++++++++++----------------------------
 1 files changed, 25 insertions(+), 39 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 2f1244d..06de9d0 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -103,6 +103,29 @@ int ip6_ra_control(struct sock *sk, int sel, void (*destructor)(struct sock *))
 	return 0;
 }
 
+static
+struct ipv6_txoptions *ipv6_update_options(struct sock *sk,
+					   struct ipv6_txoptions *opt)
+{
+	if (inet_sk(sk)->is_icsk) {
+		if (opt &&
+		    !((1 << sk->sk_state) & (TCPF_LISTEN | TCPF_CLOSE)) &&
+		    inet_sk(sk)->daddr != LOOPBACK4_IPV6) {
+			struct inet_connection_sock *icsk = inet_csk(sk);
+			icsk->icsk_ext_hdr_len = opt->opt_flen + opt->opt_nflen;
+			icsk->icsk_sync_mss(sk, icsk->icsk_pmtu_cookie);
+		}
+		opt = xchg(&inet6_sk(sk)->opt, opt);
+	} else {
+		write_lock(&sk->sk_dst_lock);
+		opt = xchg(&inet6_sk(sk)->opt, opt);
+		write_unlock(&sk->sk_dst_lock);
+	}
+	sk_dst_reset(sk);
+
+	return opt;
+}
+
 static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		    char __user *optval, int optlen)
 {
@@ -351,25 +374,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		}
 
 		retv = 0;
-		if (inet_sk(sk)->is_icsk) {
-			if (opt) {
-				struct inet_connection_sock *icsk = inet_csk(sk);
-				if (!((1 << sk->sk_state) &
-				      (TCPF_LISTEN | TCPF_CLOSE))
-				    && inet_sk(sk)->daddr != LOOPBACK4_IPV6) {
-					icsk->icsk_ext_hdr_len =
-						opt->opt_flen + opt->opt_nflen;
-					icsk->icsk_sync_mss(sk, icsk->icsk_pmtu_cookie);
-				}
-			}
-			opt = xchg(&np->opt, opt);
-			sk_dst_reset(sk);
-		} else {
-			write_lock(&sk->sk_dst_lock);
-			opt = xchg(&np->opt, opt);
-			write_unlock(&sk->sk_dst_lock);
-			sk_dst_reset(sk);
-		}
+		opt = ipv6_update_options(sk, opt);
 sticky_done:
 		if (opt)
 			sock_kfree_s(sk, opt, opt->tot_len);
@@ -415,26 +420,7 @@ sticky_done:
 			goto done;
 update:
 		retv = 0;
-		if (inet_sk(sk)->is_icsk) {
-			if (opt) {
-				struct inet_connection_sock *icsk = inet_csk(sk);
-				if (!((1 << sk->sk_state) &
-				      (TCPF_LISTEN | TCPF_CLOSE))
-				    && inet_sk(sk)->daddr != LOOPBACK4_IPV6) {
-					icsk->icsk_ext_hdr_len =
-						opt->opt_flen + opt->opt_nflen;
-					icsk->icsk_sync_mss(sk, icsk->icsk_pmtu_cookie);
-				}
-			}
-			opt = xchg(&np->opt, opt);
-			sk_dst_reset(sk);
-		} else {
-			write_lock(&sk->sk_dst_lock);
-			opt = xchg(&np->opt, opt);
-			write_unlock(&sk->sk_dst_lock);
-			sk_dst_reset(sk);
-		}
-
+		opt = ipv6_update_options(sk, opt);
 done:
 		if (opt)
 			sock_kfree_s(sk, opt, opt->tot_len);
-- 
1.4.4.4












