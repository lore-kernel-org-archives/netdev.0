From: Phil Sutter <phil.sutter@viprinet.com>
Subject: [PATCH] packet: fix leakage of tx_ring memory
Date: Fri,  1 Feb 2013 14:57:12 +0100
Message-ID: <1359727032-7999-1-git-send-email-phil.sutter@viprinet.com>
Cc: netdev@vger.kernel.org, Johann Baudy <johann.baudy@gnu-log.net>,
	stable@kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.vipri.net ([89.207.250.15]:33100 "EHLO zimbra.vipri.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755961Ab3BAOGU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 09:06:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When releasing a packet socket, the routine packet_set_ring() is reused
to free rings instead of allocating them. But when calling it for the
first time, it fills req->tp_block_nr with the value of rb->pg_vec_len
which in the second invocation makes it bail out since req->tp_block_nr
is greater zero but req->tp_block_size is zero.

This patch solves the problem by passing a zeroed auto-variable to
packet_set_ring() upon each invocation from packet_release().

As far as I can tell, this issue exists even since 69e3c75 (net: TX_RING
and packet mmap), i.e. the original inclusion of TX ring support into
af_packet, but applies only to sockets with both RX and TX ring
allocated, which is probably why this was unnoticed all the time.

Signed-off-by: Phil Sutter <phil.sutter@viprinet.com>
Cc: Johann Baudy <johann.baudy@gnu-log.net>
Cc: stable@kernel.org
---
 net/packet/af_packet.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index a91fd0b..d5f519a 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2328,6 +2328,13 @@ static int packet_sendmsg(struct kiocb *iocb, struct socket *sock,
 	return rc;
 }
 
+static int packet_free_ring(struct sock *sk, int tx_ring)
+{
+	union tpacket_req_u req_u = { 0 };
+
+	return packet_set_ring(sk, &req_u, 1, tx_ring);
+}
+
 /*
  *	Close a PACKET socket. This is fairly simple. We immediately go
  *	to 'closed' state and remove our protocol entry in the device list.
@@ -2338,7 +2345,6 @@ static int packet_release(struct socket *sock)
 	struct sock *sk = sock->sk;
 	struct packet_sock *po;
 	struct net *net;
-	union tpacket_req_u req_u;
 
 	if (!sk)
 		return 0;
@@ -2364,13 +2370,11 @@ static int packet_release(struct socket *sock)
 
 	packet_flush_mclist(sk);
 
-	memset(&req_u, 0, sizeof(req_u));
-
 	if (po->rx_ring.pg_vec)
-		packet_set_ring(sk, &req_u, 1, 0);
+		packet_free_ring(sk, 0);
 
 	if (po->tx_ring.pg_vec)
-		packet_set_ring(sk, &req_u, 1, 1);
+		packet_free_ring(sk, 1);
 
 	fanout_release(sk);
 
-- 
1.7.12.3
