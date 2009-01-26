From: John Reumann <reumann.linux@gmail.com>
Subject: [PATCH 1/1] Return EINVAL if the user provides a return data structure for getsockname that is too small
 to hold the PF_ address.  This introduces a new error code but this should be OK as the error
 is real and would otherwise corrupt the user-application's stack, i.e., it results in trouble
 no matter what.  I do not do a partial copy of the sockaddr structure because it does not
 make very much sense to retrieve only part of the socket address (e.g., ip + af_family).
Date: Mon, 26 Jan 2009 11:21:40 -0500
Message-ID: <20090126163452.85EAF54A11@localhost>
To: undisclosed-recipients:;
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:55318 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751656AbZAZQe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 11:34:59 -0500
Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id n0QGYvaq002275
	for <netdev@vger.kernel.org>; Mon, 26 Jan 2009 16:34:57 GMT
Received: from localhost (reumann-warp.nyc.corp.google.com [172.26.76.182])
	by spaceape7.eur.corp.google.com with ESMTP id n0QGYqtc017492
	for <netdev@vger.kernel.org>; Mon, 26 Jan 2009 08:34:53 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 net/ipv4/af_inet.c  |    7 +++++--
 net/ipv6/af_inet6.c |    3 +++
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 743f554..52283ff 100644
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
 
+	if (*uaddr_len < sizeof(struct sockaddr_in))
+		return -EINVAL;
+
 	sin->sin_family = AF_INET;
 	if (peer) {
 		if (!inet->dport ||
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index c802bc1..74b8407 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -401,6 +401,9 @@ int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 
+	if (*uaddr_len < sizeof(struct sockaddr_in6))
+		return -EINVAL;
+
 	sin->sin6_family = AF_INET6;
 	sin->sin6_flowinfo = 0;
 	sin->sin6_scope_id = 0;
-- 
1.5.4.5

