From: Gilberto Bertin <gilberto.bertin@gmail.com>
Subject: [net-next RFC 3/4] bindtoprefix: TCP/IPv6 implementation
Date: Wed, 23 Mar 2016 02:26:05 +0000
Message-ID: <1458699966-3752-4-git-send-email-gilberto.bertin@gmail.com>
References: <1458699966-3752-1-git-send-email-gilberto.bertin@gmail.com>
Cc: tom@herbertland.com, markzzzsmith@gmail.com,
	Gilberto Bertin <gilberto.bertin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36479 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055AbcC2Nhx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 09:37:53 -0400
Received: by mail-wm0-f65.google.com with SMTP id 20so5418512wmh.3
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 06:37:52 -0700 (PDT)
In-Reply-To: <1458699966-3752-1-git-send-email-gilberto.bertin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Gilberto Bertin <gilberto.bertin@gmail.com>
---
 net/ipv6/inet6_connection_sock.c | 17 ++++++++++++++++-
 net/ipv6/inet6_hashtables.c      |  6 ++++++
 2 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 36c3f01..c65023f 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -27,6 +27,20 @@
 #include <net/sock.h>
 #include <net/inet6_connection_sock.h>
 
+int inet6_csk_bind_prefix_conflict(const struct sock *sk,
+				   const struct sock *sk2)
+{
+	u_char plen;
+
+	plen = min(sk->sk_bind_prefix6.plen, sk2->sk_bind_prefix6.plen);
+
+	if (sk->sk_bind_to_prefix && sk2->sk_bind_to_prefix)
+		return ipv6_prefix_equal(&sk->sk_bind_prefix6.net,
+					 &sk2->sk_bind_prefix6.net, plen);
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
+		     inet6_csk_bind_prefix_conflict(sk, sk2)) {
 			if ((!reuse || !sk2->sk_reuse ||
 			     sk2->sk_state == TCP_LISTEN) &&
 			    (!reuseport || !sk2->sk_reuseport ||
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 21ace5a..bcc16ed 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -114,6 +114,12 @@ static inline int compute_score(struct sock *sk, struct net *net,
 				return -1;
 			score++;
 		}
+		if (sk->sk_bind_to_prefix) {
+			if (!ipv6_prefix_equal(&sk->sk_bind_prefix6.net, daddr,
+					       sk->sk_bind_prefix6.plen))
+				return -1;
+			score++;
+		}
 		if (sk->sk_incoming_cpu == raw_smp_processor_id())
 			score++;
 	}
-- 
2.7.3
