From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [net-next v2 11/13] tcp: add mss_clamp to tcp_request_sock_ops
Date: Wed, 25 Jun 2014 17:10:00 +0300
Message-ID: <1403705402-14388-12-git-send-email-octavian.purdila@intel.com>
References: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Cc: Octavian Purdila <octavian.purdila@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:45758 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757130AbaFYOKg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2014 10:10:36 -0400
In-Reply-To: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add mss_clamp member to tcp_request_sock_ops so that we can later
unify tcp_v4_conn_request and tcp_v6_conn_request.

Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
---
 include/net/tcp.h   | 1 +
 net/ipv4/tcp_ipv4.c | 3 ++-
 net/ipv6/tcp_ipv6.c | 4 +++-
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8e9c28d..30fe98b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1592,6 +1592,7 @@ struct tcp_sock_af_ops {
 };
 
 struct tcp_request_sock_ops {
+	u16 mss_clamp;
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key	*(*md5_lookup) (struct sock *sk,
 						struct request_sock *req);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 597dd9d75..499d440 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1265,6 +1265,7 @@ struct request_sock_ops tcp_request_sock_ops __read_mostly = {
 };
 
 static const struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
+	.mss_clamp	=	TCP_MSS_DEFAULT,
 #ifdef CONFIG_TCP_MD5SIG
 	.md5_lookup	=	tcp_v4_reqsk_md5_lookup,
 	.calc_md5_hash	=	tcp_v4_md5_hash_skb,
@@ -1324,7 +1325,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	af_ops = tcp_rsk(req)->af_specific = &tcp_request_sock_ipv4_ops;
 
 	tcp_clear_options(&tmp_opt);
-	tmp_opt.mss_clamp = TCP_MSS_DEFAULT;
+	tmp_opt.mss_clamp = af_ops->mss_clamp;
 	tmp_opt.user_mss  = tp->rx_opt.user_mss;
 	tcp_parse_options(skb, &tmp_opt, 0, want_cookie ? NULL : &foc);
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 41389bb..ad65833 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -754,6 +754,8 @@ struct request_sock_ops tcp6_request_sock_ops __read_mostly = {
 };
 
 static const struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
+	.mss_clamp	=	IPV6_MIN_MTU - sizeof(struct tcphdr) -
+				sizeof(struct ipv6hdr),
 #ifdef CONFIG_TCP_MD5SIG
 	.md5_lookup	=	tcp_v6_reqsk_md5_lookup,
 	.calc_md5_hash	=	tcp_v6_md5_hash_skb,
@@ -1047,7 +1049,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	af_ops = tcp_rsk(req)->af_specific = &tcp_request_sock_ipv6_ops;
 
 	tcp_clear_options(&tmp_opt);
-	tmp_opt.mss_clamp = IPV6_MIN_MTU - sizeof(struct tcphdr) - sizeof(struct ipv6hdr);
+	tmp_opt.mss_clamp = af_ops->mss_clamp;
 	tmp_opt.user_mss = tp->rx_opt.user_mss;
 	tcp_parse_options(skb, &tmp_opt, 0, want_cookie ? NULL : &foc);
 
-- 
1.8.3.2
