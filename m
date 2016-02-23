From: Gilberto Bertin <gilberto.bertin@gmail.com>
Subject: [net-next RFC 2/4] bindtosubnet: TCP/IPv4 implementation
Date: Tue, 23 Feb 2016 15:27:43 +0000
Message-ID: <1456241265-5766-3-git-send-email-gilberto.bertin@gmail.com>
References: <1456241265-5766-1-git-send-email-gilberto.bertin@gmail.com>
Cc: Gilberto Bertin <gilberto.bertin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:35109 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753347AbcBWP1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 10:27:48 -0500
Received: by mail-wm0-f53.google.com with SMTP id c200so226160660wme.0
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 07:27:47 -0800 (PST)
In-Reply-To: <1456241265-5766-1-git-send-email-gilberto.bertin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Gilberto Bertin <gilberto.bertin@gmail.com>
---
 net/ipv4/inet_connection_sock.c | 20 +++++++++++++++++++-
 net/ipv4/inet_hashtables.c      |  9 +++++++++
 2 files changed, 28 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 46b9c88..b182ec6 100644
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
 
+static inline int inet_csk_bind_subnet_conflict(const struct sock *sk,
+						const struct sock *sk2)
+{
+	__be32 mask;
+
+	if (sk->sk_bind_to_subnet && sk2->sk_bind_to_subnet) {
+		mask = inet_make_mask(min(sk->sk_bind_subnet4.plen,
+					  sk2->sk_bind_subnet4.plen));
+
+		return (sk->sk_bind_subnet4.net & mask) ==
+		       (sk2->sk_bind_subnet4.net & mask);
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
+		     inet_csk_bind_subnet_conflict(sk, sk2)) {
 			if ((!reuse || !sk2->sk_reuse ||
 			    sk2->sk_state == TCP_LISTEN) &&
 			    (!reuseport || !sk2->sk_reuseport ||
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index ccc5980..1a0229c 100644
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
+		if (sk->sk_bind_to_subnet) {
+			__be32 mask = inet_make_mask(sk->sk_bind_subnet4.plen);
+
+			if ((sk->sk_bind_subnet4.net & mask) != (daddr & mask))
+				return -1;
+			score += 4;
+		}
+
 		if (sk->sk_incoming_cpu == raw_smp_processor_id())
 			score++;
 	}
-- 
2.7.1
