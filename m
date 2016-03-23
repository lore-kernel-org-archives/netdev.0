From: Gilberto Bertin <gilberto.bertin@gmail.com>
Subject: [net-next RFC 4/4] bindtoprefix: UPD implementation
Date: Wed, 23 Mar 2016 02:26:06 +0000
Message-ID: <1458699966-3752-5-git-send-email-gilberto.bertin@gmail.com>
References: <1458699966-3752-1-git-send-email-gilberto.bertin@gmail.com>
Cc: tom@herbertland.com, markzzzsmith@gmail.com,
	Gilberto Bertin <gilberto.bertin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35666 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755858AbcC2Nhx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 09:37:53 -0400
Received: by mail-wm0-f44.google.com with SMTP id 191so51199116wmq.0
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 06:37:53 -0700 (PDT)
In-Reply-To: <1458699966-3752-1-git-send-email-gilberto.bertin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Gilberto Bertin <gilberto.bertin@gmail.com>
---
 net/ipv4/udp.c | 36 ++++++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 95d2f19..31b9687 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -133,6 +133,23 @@ EXPORT_SYMBOL(udp_memory_allocated);
 #define MAX_UDP_PORTS 65536
 #define PORTS_PER_CHAIN (MAX_UDP_PORTS / UDP_HTABLE_SIZE_MIN)
 
+static inline int udp_csk_bind_prefix_conflict(const struct sock *sk,
+					       const struct sock *sk2)
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
+
 static int udp_lib_lport_inuse(struct net *net, __u16 num,
 			       const struct udp_hslot *hslot,
 			       unsigned long *bitmap,
@@ -153,6 +170,7 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
 		    (!sk2->sk_reuse || !sk->sk_reuse) &&
 		    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if ||
 		     sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
+		     udp_csk_bind_prefix_conflict(sk, sk2) &&
 		    (!sk2->sk_reuseport || !sk->sk_reuseport ||
 		     rcu_access_pointer(sk->sk_reuseport_cb) ||
 		     !uid_eq(uid, sock_i_uid(sk2))) &&
@@ -189,6 +207,7 @@ static int udp_lib_lport_inuse2(struct net *net, __u16 num,
 		    (!sk2->sk_reuse || !sk->sk_reuse) &&
 		    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if ||
 		     sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
+		     udp_csk_bind_prefix_conflict(sk, sk2) &&
 		    (!sk2->sk_reuseport || !sk->sk_reuseport ||
 		     rcu_access_pointer(sk->sk_reuseport_cb) ||
 		     !uid_eq(uid, sock_i_uid(sk2))) &&
@@ -426,6 +445,15 @@ static inline int compute_score(struct sock *sk, struct net *net,
 			return -1;
 		score += 4;
 	}
+
+	if (sk->sk_bind_to_prefix) {
+		__be32 mask = inet_make_mask(sk->sk_bind_prefix4.plen);
+
+		if ((sk->sk_bind_prefix4.net & mask) != (daddr & mask))
+			return -1;
+		score += 4;
+	}
+
 	if (sk->sk_incoming_cpu == raw_smp_processor_id())
 		score++;
 	return score;
@@ -471,6 +499,14 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 		score += 4;
 	}
 
+	if (sk->sk_bind_to_prefix) {
+		__be32 mask = inet_make_mask(sk->sk_bind_prefix4.plen);
+
+		if ((sk->sk_bind_prefix4.net & mask) != (daddr & mask))
+			return -1;
+		score += 4;
+	}
+
 	if (sk->sk_incoming_cpu == raw_smp_processor_id())
 		score++;
 
-- 
2.7.3
