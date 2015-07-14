From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv6: lock socket in ip6_datagram_connect()
Date: Tue, 14 Jul 2015 08:10:22 +0200
Message-ID: <1436854222.1374.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:36203 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913AbbGNGK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 02:10:26 -0400
Received: by wgxm20 with SMTP id m20so129267297wgx.3
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 23:10:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

ip6_datagram_connect() is doing a lot of socket changes without
socket being locked.

This looks wrong, at least for udp_lib_rehash() which could corrupt
lists because of concurrent udp_sk(sk)->udp_portaddr_hash accesses.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip.h    |    1 +
 net/ipv4/datagram.c |   16 ++++++++++++----
 net/ipv6/datagram.c |   20 +++++++++++++++-----
 3 files changed, 28 insertions(+), 9 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 0750a186ea63..d5fe9f2ab699 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -161,6 +161,7 @@ static inline __u8 get_rtconn_flags(struct ipcm_cookie* ipc, struct sock* sk)
 }
 
 /* datagram.c */
+int __ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len);
 int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len);
 
 void ip4_datagram_release_cb(struct sock *sk);
diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index 90c0e8386116..574fad9cca05 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -20,7 +20,7 @@
 #include <net/route.h>
 #include <net/tcp_states.h>
 
-int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
+int __ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct sockaddr_in *usin = (struct sockaddr_in *) uaddr;
@@ -39,8 +39,6 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	sk_dst_reset(sk);
 
-	lock_sock(sk);
-
 	oif = sk->sk_bound_dev_if;
 	saddr = inet->inet_saddr;
 	if (ipv4_is_multicast(usin->sin_addr.s_addr)) {
@@ -82,9 +80,19 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	sk_dst_set(sk, &rt->dst);
 	err = 0;
 out:
-	release_sock(sk);
 	return err;
 }
+EXPORT_SYMBOL(__ip4_datagram_connect);
+
+int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
+{
+	int res;
+
+	lock_sock(sk);
+	res = __ip4_datagram_connect(sk, uaddr, addr_len);
+	release_sock(sk);
+	return res;
+}
 EXPORT_SYMBOL(ip4_datagram_connect);
 
 /* Because UDP xmit path can manipulate sk_dst_cache without holding
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 62d908e64eeb..b10a88986a98 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -40,7 +40,7 @@ static bool ipv6_mapped_addr_any(const struct in6_addr *a)
 	return ipv6_addr_v4mapped(a) && (a->s6_addr32[3] == 0);
 }
 
-int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
+static int __ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
 	struct sockaddr_in6	*usin = (struct sockaddr_in6 *) uaddr;
 	struct inet_sock	*inet = inet_sk(sk);
@@ -56,7 +56,7 @@ int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (usin->sin6_family == AF_INET) {
 		if (__ipv6_only_sock(sk))
 			return -EAFNOSUPPORT;
-		err = ip4_datagram_connect(sk, uaddr, addr_len);
+		err = __ip4_datagram_connect(sk, uaddr, addr_len);
 		goto ipv4_connected;
 	}
 
@@ -98,9 +98,9 @@ int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		sin.sin_addr.s_addr = daddr->s6_addr32[3];
 		sin.sin_port = usin->sin6_port;
 
-		err = ip4_datagram_connect(sk,
-					   (struct sockaddr *) &sin,
-					   sizeof(sin));
+		err = __ip4_datagram_connect(sk,
+					     (struct sockaddr *) &sin,
+					     sizeof(sin));
 
 ipv4_connected:
 		if (err)
@@ -204,6 +204,16 @@ out:
 	fl6_sock_release(flowlabel);
 	return err;
 }
+
+int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
+{
+	int res;
+
+	lock_sock(sk);
+	res = __ip6_datagram_connect(sk, uaddr, addr_len);
+	release_sock(sk);
+	return res;
+}
 EXPORT_SYMBOL_GPL(ip6_datagram_connect);
 
 int ip6_datagram_connect_v6_only(struct sock *sk, struct sockaddr *uaddr,
