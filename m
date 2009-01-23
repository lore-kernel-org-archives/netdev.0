From: John Reumann <reumann.linux@gmail.com>
Subject: [PATCH 1/1] Fix getsockname (ipv4/ipv6)
Date: Fri, 23 Jan 2009 16:45:52 -0500
Message-ID: <20090126220931.A8F0154A11@localhost>
To: undisclosed-recipients:;
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:25273 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752289AbZAZWJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 17:09:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change will return ENOSPC if the return address provided by the caller of getsockname
 is not sufficiently large to hold the return value.  This is consistent with the rest of the
 API. However, there are some implemenations that copy only as many bytes of sockaddr from the
 kernel to user-space as specified in the *addrlen attribute.  (1) This wasn't the behavior now
 (2) we should not adopt this behavior because it is quite messy, e.g., copy only part of a port,
 IP-address? Most partial retrivals do not make sense.  This is why I suggest returning EINVAL,
 when the return struct is too small.
---
 net/ipv4/af_inet.c  |    7 +++++--
 net/ipv6/af_inet6.c |    3 +++
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 743f554..9a8c5b0 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -677,10 +677,13 @@ do_err:
 int inet_getname(struct socket *sock, struct sockaddr *uaddr,
 			int *uaddr_len, int peer)
 {
-	struct sock *sk		= sock->sk;
-	struct inet_sock *inet	= inet_sk(sk);
+	struct sock *sk = sock->sk;
+	struct inet_sock *inet = inet_sk(sk);
 	struct sockaddr_in *sin	= (struct sockaddr_in *)uaddr;
 
+        if (*uaddr_len < sizeof(struct sockaddr_in))
+	  return -ENOSPC;
+
 	sin->sin_family = AF_INET;
 	if (peer) {
 		if (!inet->dport ||
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index c802bc1..f2772ee 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -401,6 +401,9 @@ int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 
+	if (*uaddr_len < sizeof(struct sockaddr_in6))
+		return -ENOSPC;
+
 	sin->sin6_family = AF_INET6;
 	sin->sin6_flowinfo = 0;
 	sin->sin6_scope_id = 0;
-- 
1.5.4.5

