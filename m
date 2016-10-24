From: Jiri Slaby <jslaby@suse.cz>
Subject: UDP does not autobind on recv
Date: Mon, 24 Oct 2016 14:54:52 +0200
Message-ID: <5d0f78b4-f850-4f73-dbb7-6c3d15d99c86@suse.cz>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------5DE4524B7F86C2D98F64205E"
To: ML netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:38584 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934873AbcJXMy5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 08:54:57 -0400
Received: by mail-wm0-f49.google.com with SMTP id c78so114248703wme.1
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2016 05:54:56 -0700 (PDT)
Received: from ?IPv6:2a01:4240:2e27:ad85:aaaa::19f? (f.9.1.0.0.0.0.0.0.0.0.0.a.a.a.a.5.8.d.a.7.2.e.2.0.4.2.4.1.0.a.2.v6.cust.nbox.cz. [2a01:4240:2e27:ad85:aaaa::19f])
        by smtp.gmail.com with ESMTPSA id u64sm14660618wmd.6.2016.10.24.05.54.52
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 05:54:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------5DE4524B7F86C2D98F64205E
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit

Hello,

as per man 7 udp:
  In order to receive packets, the socket can be bound to
  a local  address first  by using bind(2).  Otherwise,
  the socket layer will automatically assign a free local
  port out of the range defined by /proc/sys/net/ipv4
  /ip_local_port_range and bind the socket to INADDR_ANY.

I did not know that bind is unneeded, so I tried that. But it does not
work with this piece of code:
int main()
{
    char buf[128];
    int fd = socket(AF_INET, SOCK_DGRAM, 0);
    recv(fd, buf, sizeof(buf), 0);
}

The recv above never returns (even if I bomb all ports from the range).
ss -ulpan is silent too. As a workaround, I can stick a dummy write/send
before recv:
    write(fd, "", 0);

And it starts working. ss suddenly displays a port which the program
listens on.

I think the UDP recv path should do inet_autobind as I have done in the
attached patch. But my knowledge is very limited in that area, so I have
no idea whether that is correct at all.

thanks,
-- 
js
suse labs

--------------5DE4524B7F86C2D98F64205E
Content-Type: text/x-patch;
 name="0001-net-autobind-UDP-on-recv.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-net-autobind-UDP-on-recv.patch"

>From 57c320998feb2e1e705a4ab6d3bbcb74c6ae65f0 Mon Sep 17 00:00:00 2001
From: Jiri Slaby <jslaby@suse.cz>
Date: Sat, 22 Oct 2016 12:10:53 +0200
Subject: [PATCH] net: autobind UDP on recv

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
---
 include/net/inet_common.h | 1 +
 net/ipv4/af_inet.c        | 3 ++-
 net/ipv4/udp.c            | 5 +++++
 net/ipv6/udp.c            | 5 +++++
 4 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/include/net/inet_common.h b/include/net/inet_common.h
index 5d683428fced..ba224ed3dd36 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -27,6 +27,7 @@ ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
 int inet_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 		 int flags);
 int inet_shutdown(struct socket *sock, int how);
+int inet_autobind(struct sock *sk);
 int inet_listen(struct socket *sock, int backlog);
 void inet_sock_destruct(struct sock *sk);
 int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 9648c97e541f..d23acb11cdb0 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -171,7 +171,7 @@ EXPORT_SYMBOL(inet_sock_destruct);
  *	Automatically bind an unbound socket.
  */
 
-static int inet_autobind(struct sock *sk)
+int inet_autobind(struct sock *sk)
 {
 	struct inet_sock *inet;
 	/* We may need to bind the socket. */
@@ -187,6 +187,7 @@ static int inet_autobind(struct sock *sk)
 	release_sock(sk);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(inet_autobind);
 
 /*
  *	Move a socket into listening state.
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 82fb78265f4b..ceb07c83af17 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1360,6 +1360,11 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 	if (flags & MSG_ERRQUEUE)
 		return ip_recv_error(sk, msg, len, addr_len);
 
+	/* We may need to bind the socket. */
+	if (!inet_sk(sk)->inet_num && !sk->sk_prot->no_autobind &&
+	    inet_autobind(sk))
+		return -EAGAIN;
+
 try_again:
 	peeking = off = sk_peek_offset(sk, flags);
 	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 71963b23d5a5..1c3dafc3d91e 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -341,6 +341,11 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 	if (np->rxpmtu && np->rxopt.bits.rxpmtu)
 		return ipv6_recv_rxpmtu(sk, msg, len, addr_len);
 
+	/* We may need to bind the socket. */
+	if (!inet_sk(sk)->inet_num && !sk->sk_prot->no_autobind &&
+	    inet_autobind(sk))
+		return -EAGAIN;
+
 try_again:
 	peeking = off = sk_peek_offset(sk, flags);
 	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
-- 
2.10.1


--------------5DE4524B7F86C2D98F64205E--
