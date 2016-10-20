From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] udp: must lock the socket in udp_disconnect()
Date: Thu, 20 Oct 2016 09:39:40 -0700
Message-ID: <1476981580.7065.15.camel@edumazet-glaptop3.roam.corp.google.com>
References: <31cb3583-5620-de3f-784d-300df3fda0a4@gmail.com>
         <CAM_iQpVExpqdOXZp0Lw+4Nr2_9W24P2dQFdM=EoYwBkHtwDoPw@mail.gmail.com>
         <05f766db-4a8c-933e-9d73-6daada21f491@gmail.com>
         <1476944754.7065.3.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>
To: Baozeng Ding <sploving1@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34146 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753142AbcJTQjm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 12:39:42 -0400
Received: by mail-pf0-f193.google.com with SMTP id 128so6042395pfz.1
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 09:39:42 -0700 (PDT)
In-Reply-To: <1476944754.7065.3.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Baozeng Ding reported KASAN traces showing uses after free in
udp_lib_get_port() and other related UDP functions.

A CONFIG_DEBUG_PAGEALLOC=y kernel would eventually crash.

I could write a reproducer with two threads doing :

static int sock_fd;
static void *thr1(void *arg)
{
	for (;;) {
		connect(sock_fd, (const struct sockaddr *)arg,
			sizeof(struct sockaddr_in));
	}
}

static void *thr2(void *arg)
{
	struct sockaddr_in unspec;

	for (;;) {
		memset(&unspec, 0, sizeof(unspec));
	        connect(sock_fd, (const struct sockaddr *)&unspec,
			sizeof(unspec));
        }
}

Problem is that udp_disconnect() could run without holding socket lock,
and this was causing list corruptions.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Baozeng Ding <sploving1@gmail.com>
---
 include/net/udp.h   |    1 +
 net/ipv4/ping.c     |    2 +-
 net/ipv4/raw.c      |    2 +-
 net/ipv4/udp.c      |   13 +++++++++++--
 net/ipv6/ping.c     |    2 +-
 net/ipv6/raw.c      |    2 +-
 net/l2tp/l2tp_ip.c  |    2 +-
 net/l2tp/l2tp_ip6.c |    2 +-
 8 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index ea53a87d880f..4948790d393d 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -258,6 +258,7 @@ void udp_flush_pending_frames(struct sock *sk);
 void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst);
 int udp_rcv(struct sk_buff *skb);
 int udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
+int __udp_disconnect(struct sock *sk, int flags);
 int udp_disconnect(struct sock *sk, int flags);
 unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait);
 struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 7cf7d6e380c2..205e2000d395 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -994,7 +994,7 @@ struct proto ping_prot = {
 	.init =		ping_init_sock,
 	.close =	ping_close,
 	.connect =	ip4_datagram_connect,
-	.disconnect =	udp_disconnect,
+	.disconnect =	__udp_disconnect,
 	.setsockopt =	ip_setsockopt,
 	.getsockopt =	ip_getsockopt,
 	.sendmsg =	ping_v4_sendmsg,
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 90a85c955872..ecbe5a7c2d6d 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -918,7 +918,7 @@ struct proto raw_prot = {
 	.close		   = raw_close,
 	.destroy	   = raw_destroy,
 	.connect	   = ip4_datagram_connect,
-	.disconnect	   = udp_disconnect,
+	.disconnect	   = __udp_disconnect,
 	.ioctl		   = raw_ioctl,
 	.init		   = raw_init,
 	.setsockopt	   = raw_setsockopt,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 7d96dc2d3d08..311613e413cb 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1345,7 +1345,7 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 	goto try_again;
 }
 
-int udp_disconnect(struct sock *sk, int flags)
+int __udp_disconnect(struct sock *sk, int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	/*
@@ -1367,6 +1367,15 @@ int udp_disconnect(struct sock *sk, int flags)
 	sk_dst_reset(sk);
 	return 0;
 }
+EXPORT_SYMBOL(__udp_disconnect);
+
+int udp_disconnect(struct sock *sk, int flags)
+{
+	lock_sock(sk);
+	__udp_disconnect(sk, flags);
+	release_sock(sk);
+	return 0;
+}
 EXPORT_SYMBOL(udp_disconnect);
 
 void udp_lib_unhash(struct sock *sk)
@@ -2193,7 +2202,7 @@ int udp_abort(struct sock *sk, int err)
 
 	sk->sk_err = err;
 	sk->sk_error_report(sk);
-	udp_disconnect(sk, 0);
+	__udp_disconnect(sk, 0);
 
 	release_sock(sk);
 
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index 0e983b694ee8..66e2d9dfc43a 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -180,7 +180,7 @@ struct proto pingv6_prot = {
 	.init =		ping_init_sock,
 	.close =	ping_close,
 	.connect =	ip6_datagram_connect_v6_only,
-	.disconnect =	udp_disconnect,
+	.disconnect =	__udp_disconnect,
 	.setsockopt =	ipv6_setsockopt,
 	.getsockopt =	ipv6_getsockopt,
 	.sendmsg =	ping_v6_sendmsg,
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 54404f08efcc..054a1d84fc5e 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1241,7 +1241,7 @@ struct proto rawv6_prot = {
 	.close		   = rawv6_close,
 	.destroy	   = raw6_destroy,
 	.connect	   = ip6_datagram_connect_v6_only,
-	.disconnect	   = udp_disconnect,
+	.disconnect	   = __udp_disconnect,
 	.ioctl		   = rawv6_ioctl,
 	.init		   = rawv6_init_sk,
 	.setsockopt	   = rawv6_setsockopt,
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 42de4ccd159f..fce25afb652a 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -338,7 +338,7 @@ static int l2tp_ip_disconnect(struct sock *sk, int flags)
 	if (sock_flag(sk, SOCK_ZAPPED))
 		return 0;
 
-	return udp_disconnect(sk, flags);
+	return __udp_disconnect(sk, flags);
 }
 
 static int l2tp_ip_getname(struct socket *sock, struct sockaddr *uaddr,
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index ea2ae6664cc8..ad3468c32b53 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -410,7 +410,7 @@ static int l2tp_ip6_disconnect(struct sock *sk, int flags)
 	if (sock_flag(sk, SOCK_ZAPPED))
 		return 0;
 
-	return udp_disconnect(sk, flags);
+	return __udp_disconnect(sk, flags);
 }
 
 static int l2tp_ip6_getname(struct socket *sock, struct sockaddr *uaddr,
