From: Gilberto Bertin <gilberto.bertin@gmail.com>
Subject: [net-next RFC 2/4] bindtoprefix: TCP/IPv4 implementation
Date: Wed, 23 Mar 2016 02:26:04 +0000
Message-ID: <1458699966-3752-3-git-send-email-gilberto.bertin@gmail.com>
References: <1458699966-3752-1-git-send-email-gilberto.bertin@gmail.com>
Cc: tom@herbertland.com, markzzzsmith@gmail.com,
	Gilberto Bertin <gilberto.bertin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35808 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752539AbcC2Nhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 09:37:52 -0400
Received: by mail-wm0-f67.google.com with SMTP id 139so5427235wmn.2
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 06:37:51 -0700 (PDT)
In-Reply-To: <1458699966-3752-1-git-send-email-gilberto.bertin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Gilberto Bertin <gilberto.bertin@gmail.com>
---
 net/ipv4/inet_connection_sock.c | 20 +++++++++++++++++++-
 net/ipv4/inet_hashtables.c      |  9 +++++++++
 2 files changed, 28 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 6414891..162c252 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -15,6 +15,7 @@
 
 #include <linux/module.h>
 #include <linux/jhash.h>
+#include <linux/inetdevice.h>
 
 #include <net/inet_connection_sock.h>
 #include <net/inet_hashtables.h>
@@ -43,6 +44,22 @@ void inet_get_local_port_range(struct net *net, int *low, int *high)
 }
 EXPORT_SYMBOL(inet_get_local_port_range);
 
+static inline int inet_csk_bind_prefix_conflict(const struct sock *sk,
+						const struct sock *sk2)
+{
+	__be32 mask;
+
+	if (sk->sk_bind_to_prefix && sk2->sk_bind_to_prefix) {
+		mask = inet_make_mask(min(sk->sk_bind_prefix4.plen,
+					  sk2->sk_bind_prefix4.plen));
+
+		return (sk->sk_bind_prefix4.net & mask) ==
+		       (sk2->sk_bind_prefix4.net & mask);
+	}
+
+	return 0;
+}
+
 int inet_csk_bind_conflict(const struct sock *sk,
 			   const struct inet_bind_bucket *tb, bool relax)
 {
@@ -63,7 +80,8 @@ int inet_csk_bind_conflict(const struct sock *sk,
 		    !inet_v6_ipv6only(sk2) &&
 		    (!sk->sk_bound_dev_if ||
 		     !sk2->sk_bound_dev_if ||
-		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if)) {
+		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if) &&
+		     inet_csk_bind_prefix_conflict(sk, sk2)) {
 			if ((!reuse || !sk2->sk_reuse ||
 			    sk2->sk_state == TCP_LISTEN) &&
 			    (!reuseport || !sk2->sk_reuseport ||
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index ccc5980..44693c4 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -13,6 +13,7 @@
  *      2 of the License, or (at your option) any later version.
  */
 
+#include <linux/inetdevice.h>
 #include <linux/module.h>
 #include <linux/random.h>
 #include <linux/sched.h>
@@ -189,6 +190,14 @@ static inline int compute_score(struct sock *sk, struct net *net,
 				return -1;
 			score += 4;
 		}
+		if (sk->sk_bind_to_prefix) {
+			__be32 mask = inet_make_mask(sk->sk_bind_prefix4.plen);
+
+			if ((sk->sk_bind_prefix4.net & mask) != (daddr & mask))
+				return -1;
+			score += 4;
+		}
+
 		if (sk->sk_incoming_cpu == raw_smp_processor_id())
 			score++;
 	}
-- 
2.7.3
