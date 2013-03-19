From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH 01/12] udp: add encap_destroy callback
Date: Tue, 19 Mar 2013 16:11:12 +0000
Message-ID: <1363709483-24021-2-git-send-email-tparkin@katalix.com>
References: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Cc: Tom Parkin <tparkin@katalix.com>,
	James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:36141 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932699Ab3CSQLa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 12:11:30 -0400
In-Reply-To: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Users of udp encapsulation currently have an encap_rcv callback which they can
use to hook into the udp receive path.

In situations where a encapsulation user allocates resources associated with a
udp encap socket, it may be convenient to be able to also hook the proto
.destroy operation.  For example, if an encap user holds a reference to the
udp socket, the destroy hook might be used to relinquish this reference.

This patch adds a socket destroy hook into udp, which is set and enabled
in the same way as the existing encap_rcv hook.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 include/linux/udp.h |    1 +
 net/ipv4/udp.c      |    7 +++++++
 net/ipv6/udp.c      |    8 ++++++++
 3 files changed, 16 insertions(+)

diff --git a/include/linux/udp.h b/include/linux/udp.h
index 9d81de1..42278bb 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -68,6 +68,7 @@ struct udp_sock {
 	 * For encapsulation sockets.
 	 */
 	int (*encap_rcv)(struct sock *sk, struct sk_buff *skb);
+	void (*encap_destroy)(struct sock *sk);
 };
 
 static inline struct udp_sock *udp_sk(const struct sock *sk)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 41760e0..7117d14 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1762,9 +1762,16 @@ int udp_rcv(struct sk_buff *skb)
 
 void udp_destroy_sock(struct sock *sk)
 {
+	struct udp_sock *up = udp_sk(sk);
 	bool slow = lock_sock_fast(sk);
 	udp_flush_pending_frames(sk);
 	unlock_sock_fast(sk, slow);
+	if (static_key_false(&udp_encap_needed) && up->encap_type) {
+		void (*encap_destroy)(struct sock *sk);
+		encap_destroy = ACCESS_ONCE(up->encap_destroy);
+		if (encap_destroy)
+			encap_destroy(sk);
+	}
 }
 
 /*
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 3ed57ec..da6019b 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1286,10 +1286,18 @@ do_confirm:
 
 void udpv6_destroy_sock(struct sock *sk)
 {
+	struct udp_sock *up = udp_sk(sk);
 	lock_sock(sk);
 	udp_v6_flush_pending_frames(sk);
 	release_sock(sk);
 
+	if (static_key_false(&udpv6_encap_needed) && up->encap_type) {
+		void (*encap_destroy)(struct sock *sk);
+		encap_destroy = ACCESS_ONCE(up->encap_destroy);
+		if (encap_destroy)
+			encap_destroy(sk);
+	}
+
 	inet6_destroy_sock(sk);
 }
 
-- 
1.7.9.5
