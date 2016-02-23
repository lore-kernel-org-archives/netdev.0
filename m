From: Gilberto Bertin <gilberto.bertin@gmail.com>
Subject: [net-next RFC 4/4] bindtosubnet: UPD implementation
Date: Tue, 23 Feb 2016 15:27:45 +0000
Message-ID: <1456241265-5766-5-git-send-email-gilberto.bertin@gmail.com>
References: <1456241265-5766-1-git-send-email-gilberto.bertin@gmail.com>
Cc: Gilberto Bertin <gilberto.bertin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37769 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752668AbcBWP1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 10:27:50 -0500
Received: by mail-wm0-f51.google.com with SMTP id g62so215325346wme.0
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 07:27:49 -0800 (PST)
In-Reply-To: <1456241265-5766-1-git-send-email-gilberto.bertin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Gilberto Bertin <gilberto.bertin@gmail.com>
---
 net/ipv4/udp.c | 35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index c438908..0e78fc4 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -132,6 +132,22 @@ EXPORT_SYMBOL(udp_memory_allocated);
 #define MAX_UDP_PORTS 65536
 #define PORTS_PER_CHAIN (MAX_UDP_PORTS / UDP_HTABLE_SIZE_MIN)
 
+static inline int udp_csk_bind_subnet_conflict(const struct sock *sk,
+					       const struct sock *sk2)
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
 static int udp_lib_lport_inuse(struct net *net, __u16 num,
 			       const struct udp_hslot *hslot,
 			       unsigned long *bitmap,
@@ -151,6 +167,7 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
 		    (!sk2->sk_reuse || !sk->sk_reuse) &&
 		    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if ||
 		     sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
+		     udp_csk_bind_subnet_conflict(sk, sk2) &&
 		    (!sk2->sk_reuseport || !sk->sk_reuseport ||
 		     !uid_eq(uid, sock_i_uid(sk2))) &&
 		    saddr_comp(sk, sk2)) {
@@ -185,6 +202,7 @@ static int udp_lib_lport_inuse2(struct net *net, __u16 num,
 		    (!sk2->sk_reuse || !sk->sk_reuse) &&
 		    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if ||
 		     sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
+		     udp_csk_bind_subnet_conflict(sk, sk2) &&
 		    (!sk2->sk_reuseport || !sk->sk_reuseport ||
 		     !uid_eq(uid, sock_i_uid(sk2))) &&
 		    saddr_comp(sk, sk2)) {
@@ -374,6 +392,15 @@ static inline int compute_score(struct sock *sk, struct net *net,
 			return -1;
 		score += 4;
 	}
+
+	if (sk->sk_bind_to_subnet) {
+		__be32 mask = inet_make_mask(sk->sk_bind_subnet4.plen);
+
+		if ((sk->sk_bind_subnet4.net & mask) != (daddr & mask))
+			return -1;
+		score += 4;
+	}
+
 	if (sk->sk_incoming_cpu == raw_smp_processor_id())
 		score++;
 	return score;
@@ -419,6 +446,14 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 		score += 4;
 	}
 
+	if (sk->sk_bind_to_subnet) {
+		__be32 mask = inet_make_mask(sk->sk_bind_subnet4.plen);
+
+		if ((sk->sk_bind_subnet4.net & mask) != (daddr & mask))
+			return -1;
+		score += 4;
+	}
+
 	if (sk->sk_incoming_cpu == raw_smp_processor_id())
 		score++;
 
-- 
2.7.1
