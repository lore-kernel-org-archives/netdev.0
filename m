From: Gilberto Bertin <gilberto.bertin@gmail.com>
Subject: [net-next RFC 3/4] bindtosubnet: TCP/IPv6 implementation
Date: Wed, 16 Mar 2016 13:19:08 +0000
Message-ID: <1458134349-2454-4-git-send-email-gilberto.bertin@gmail.com>
References: <1458134349-2454-1-git-send-email-gilberto.bertin@gmail.com>
Cc: Gilberto Bertin <gilberto.bertin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:33247 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933804AbcCPNiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 09:38:16 -0400
Received: by mail-wm0-f51.google.com with SMTP id l68so190740144wml.0
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 06:38:15 -0700 (PDT)
In-Reply-To: <1458134349-2454-1-git-send-email-gilberto.bertin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Gilberto Bertin <gilberto.bertin@gmail.com>
---
 net/ipv6/inet6_connection_sock.c | 17 ++++++++++++++++-
 net/ipv6/inet6_hashtables.c      |  6 ++++++
 2 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 36c3f01..288bab6 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -27,6 +27,20 @@
 #include <net/sock.h>
 #include <net/inet6_connection_sock.h>
 
+int inet6_csk_bind_subnet_conflict(const struct sock *sk,
+				   const struct sock *sk2)
+{
+	u_char plen;
+
+	plen = min(sk->sk_bind_subnet6.plen, sk2->sk_bind_subnet6.plen);
+
+	if (sk->sk_bind_to_subnet && sk2->sk_bind_to_subnet)
+		return ipv6_prefix_equal(&sk->sk_bind_subnet6.net,
+					 &sk2->sk_bind_subnet6.net, plen);
+
+	return 0;
+}
+
 int inet6_csk_bind_conflict(const struct sock *sk,
 			    const struct inet_bind_bucket *tb, bool relax)
 {
@@ -44,7 +58,8 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 		if (sk != sk2 &&
 		    (!sk->sk_bound_dev_if ||
 		     !sk2->sk_bound_dev_if ||
-		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if)) {
+		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if) &&
+		     inet6_csk_bind_subnet_conflict(sk, sk2)) {
 			if ((!reuse || !sk2->sk_reuse ||
 			     sk2->sk_state == TCP_LISTEN) &&
 			    (!reuseport || !sk2->sk_reuseport ||
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 21ace5a..e88c82d 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -114,6 +114,12 @@ static inline int compute_score(struct sock *sk, struct net *net,
 				return -1;
 			score++;
 		}
+		if (sk->sk_bind_to_subnet) {
+			if (!ipv6_prefix_equal(&sk->sk_bind_subnet6.net, daddr,
+					       sk->sk_bind_subnet6.plen))
+				return -1;
+			score++;
+		}
 		if (sk->sk_incoming_cpu == raw_smp_processor_id())
 			score++;
 	}
-- 
2.7.2
