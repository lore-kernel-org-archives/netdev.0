From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] ipv4: don't call upper-layer disconnect function if not connected
Date: Tue, 01 Aug 2006 15:48:54 -0400
Message-ID: <44CFB026.7050907@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070704090401030102080907"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:11708 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1751857AbWHATs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 15:48:56 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070704090401030102080907
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Calling connect() with AF_UNSPEC will disconnect a socket, but we don't 
need to do any work if the socket isn't currently connected.

Signed-off-by: Brian Haley <brian.haley@hp.com>

--------------070704090401030102080907
Content-Type: text/x-patch;
 name="disconn.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="disconn.patch"

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index c84a320..b294b92 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -480,12 +480,16 @@ int inet_dgram_connect(struct socket *so
 {
 	struct sock *sk = sock->sk;
 
-	if (uaddr->sa_family == AF_UNSPEC)
-		return sk->sk_prot->disconnect(sk, flags);
+	if (uaddr->sa_family == AF_UNSPEC) {
+		if (sock->state != SS_UNCONNECTED)
+			return sk->sk_prot->disconnect(sk, flags);
+		else
+			return 0;
+	}
 
 	if (!inet_sk(sk)->num && inet_autobind(sk))
 		return -EAGAIN;
-	return sk->sk_prot->connect(sk, (struct sockaddr *)uaddr, addr_len);
+	return sk->sk_prot->connect(sk, uaddr, addr_len);
 }
 
 static long inet_wait_for_connect(struct sock *sk, long timeo)
@@ -525,8 +529,11 @@ int inet_stream_connect(struct socket *s
 	lock_sock(sk);
 
 	if (uaddr->sa_family == AF_UNSPEC) {
-		err = sk->sk_prot->disconnect(sk, flags);
-		sock->state = err ? SS_DISCONNECTING : SS_UNCONNECTED;
+		if (sock->state != SS_UNCONNECTED) {
+			err = sk->sk_prot->disconnect(sk, flags);
+			sock->state = err ? SS_DISCONNECTING : SS_UNCONNECTED;
+		} else
+			err = 0;
 		goto out;
 	}
 

--------------070704090401030102080907--
