From: "Jonathan T. Leighton" <jtleight@udel.edu>
Subject: [PATCH 2/2] ipv6: Handle IPv4-mapped src to in6addr_any dst.
Date: Sun, 12 Feb 2017 17:26:07 -0500
Message-ID: <7de3e9af8a12e60819ebc58dd682ea2eb3ede05e.1486937974.git.jtleight@udel.edu>
References: <cover.1486937974.git.jtleight@udel.edu>
Cc: "Jonathan T. Leighton" <jtleight@udel.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35254 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751405AbdBLW0M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 17:26:12 -0500
Received: by mail-qt0-f193.google.com with SMTP id s58so11010591qtc.2
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 14:26:12 -0800 (PST)
In-Reply-To: <cover.1486937974.git.jtleight@udel.edu>
In-Reply-To: <cover.1486937974.git.jtleight@udel.edu>
References: <cover.1486937974.git.jtleight@udel.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a check on the type of the source address for the case
where the destination address is in6addr_any. If the source is an
IPv4-mapped IPv6 source address, the destination is changed to
::ffff:127.0.0.1, and otherwise the destination is changed to ::1. This
is done in three locations to handle UDP calls to either connect() or
sendmsg() and TCP calls to connect(). Note that udpv6_sendmsg() delays
handling an in6addr_any destination until very late, so the patch only
needs to handle the case where the source is an IPv4-mapped IPv6
address.

Signed-off-by: Jonathan T. Leighton <jtleight@udel.edu>
---
 net/ipv6/datagram.c | 14 +++++++++-----
 net/ipv6/tcp_ipv6.c | 11 ++++++++---
 net/ipv6/udp.c      |  4 ++++
 3 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index a3eaafd..eec27f8 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -167,18 +167,22 @@ int __ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (np->sndflow)
 		fl6_flowlabel = usin->sin6_flowinfo & IPV6_FLOWINFO_MASK;
 
-	addr_type = ipv6_addr_type(&usin->sin6_addr);
-
-	if (addr_type == IPV6_ADDR_ANY) {
+	if (ipv6_addr_any(&usin->sin6_addr)) {
 		/*
 		 *	connect to self
 		 */
-		usin->sin6_addr.s6_addr[15] = 0x01;
+		if (ipv6_addr_v4mapped(&sk->sk_v6_rcv_saddr))
+			ipv6_addr_set_v4mapped(htonl(INADDR_LOOPBACK),
+					       &usin->sin6_addr);
+		else
+			usin->sin6_addr = in6addr_loopback;
 	}
 
+	addr_type = ipv6_addr_type(&usin->sin6_addr);
+
 	daddr = &usin->sin6_addr;
 
-	if (addr_type == IPV6_ADDR_MAPPED) {
+	if (addr_type & IPV6_ADDR_MAPPED) {
 		struct sockaddr_in sin;
 
 		if (__ipv6_only_sock(sk)) {
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index b5d2721..21c7199 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -149,8 +149,13 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	 *	connect() to INADDR_ANY means loopback (BSD'ism).
 	 */
 
-	if (ipv6_addr_any(&usin->sin6_addr))
-		usin->sin6_addr.s6_addr[15] = 0x1;
+	if (ipv6_addr_any(&usin->sin6_addr)) {
+		if (ipv6_addr_v4mapped(&sk->sk_v6_rcv_saddr))
+			ipv6_addr_set_v4mapped(htonl(INADDR_LOOPBACK),
+					       &usin->sin6_addr);
+		else
+			usin->sin6_addr = in6addr_loopback;
+	}
 
 	addr_type = ipv6_addr_type(&usin->sin6_addr);
 
@@ -189,7 +194,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	 *	TCP over IPv4
 	 */
 
-	if (addr_type == IPV6_ADDR_MAPPED) {
+	if (addr_type & IPV6_ADDR_MAPPED) {
 		u32 exthdrlen = icsk->icsk_ext_hdr_len;
 		struct sockaddr_in sin;
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index df71ba0..4e4c401 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1046,6 +1046,10 @@ int udpv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 			if (addr_len < SIN6_LEN_RFC2133)
 				return -EINVAL;
 			daddr = &sin6->sin6_addr;
+			if (ipv6_addr_any(daddr) &&
+			    ipv6_addr_v4mapped(&np->saddr))
+				ipv6_addr_set_v4mapped(htonl(INADDR_LOOPBACK),
+						       daddr);
 			break;
 		case AF_INET:
 			goto do_udp_sendmsg;
-- 
2.7.4
