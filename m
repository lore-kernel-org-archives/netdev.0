From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH v2] ipx: implement shutdown()
Date: Sun,  9 Feb 2014 00:23:38 +0100
Message-ID: <1391901818-13338-1-git-send-email-sd@queasysnail.net>
Cc: davem@davemloft.net, netdev@vger.kernel.org, 00cpxxx@gmail.com,
	Sabrina Dubroca <sd@queasysnail.net>
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:57603 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751170AbaBHXYN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Feb 2014 18:24:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPX doesn't implement shutdown, which poses a problem to some users:

https://bugzilla.kernel.org/show_bug.cgi?id=67841

This patch is heavily based on the shutdown implementation for unix
sockets.

Reported-by: Bruno Jesus <00cpxxx@gmail.com>
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
v2, without debug messages

 net/ipx/af_ipx.c | 28 ++++++++++++++++++++++++++--
 1 file changed, 26 insertions(+), 2 deletions(-)

diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 994e28b..478abcf 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1383,6 +1383,7 @@ static int ipx_release(struct socket *sock)
 		goto out;
 
 	lock_sock(sk);
+	sk->sk_shutdown = SHUTDOWN_MASK;
 	if (!sock_flag(sk, SOCK_DEAD))
 		sk->sk_state_change(sk);
 
@@ -1806,8 +1807,11 @@ static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
 				flags & MSG_DONTWAIT, &rc);
-	if (!skb)
+	if (!skb) {
+		if (rc == -EAGAIN && (sk->sk_shutdown & RCV_SHUTDOWN))
+			rc = 0;
 		goto out;
+	}
 
 	ipx 	= ipx_hdr(skb);
 	copied 	= ntohs(ipx->ipx_pktsize) - sizeof(struct ipxhdr);
@@ -1937,6 +1941,26 @@ static int ipx_compat_ioctl(struct socket *sock, unsigned int cmd, unsigned long
 }
 #endif
 
+static int ipx_shutdown(struct socket *sock, int mode)
+{
+	struct sock *sk = sock->sk;
+
+	if (mode < SHUT_RD || mode > SHUT_RDWR)
+		return -EINVAL;
+	/* This maps:
+	 * SHUT_RD   (0) -> RCV_SHUTDOWN  (1)
+	 * SHUT_WR   (1) -> SEND_SHUTDOWN (2)
+	 * SHUT_RDWR (2) -> SHUTDOWN_MASK (3)
+	 */
+	++mode;
+
+	lock_sock(sk);
+	sk->sk_shutdown |= mode;
+	release_sock(sk);
+	sk->sk_state_change(sk);
+
+	return 0;
+}
 
 /*
  * Socket family declarations
@@ -1963,7 +1987,7 @@ static const struct proto_ops ipx_dgram_ops = {
 	.compat_ioctl	= ipx_compat_ioctl,
 #endif
 	.listen		= sock_no_listen,
-	.shutdown	= sock_no_shutdown, /* FIXME: support shutdown */
+	.shutdown	= ipx_shutdown,
 	.setsockopt	= ipx_setsockopt,
 	.getsockopt	= ipx_getsockopt,
 	.sendmsg	= ipx_sendmsg,
-- 
1.8.5.4
