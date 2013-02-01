From: Phil Sutter <phil.sutter@viprinet.com>
Subject: [PATCH v2] packet: fix leakage of tx_ring memory
Date: Fri,  1 Feb 2013 18:21:41 +0100
Message-ID: <1359739301-14044-1-git-send-email-phil.sutter@viprinet.com>
References: <510BF1C4.4050108@redhat.com>
Cc: netdev@vger.kernel.org, Johann Baudy <johann.baudy@gnu-log.net>,
	Daniel Borkmann <dborkman@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.vipri.net ([89.207.250.15]:36582 "EHLO zimbra.vipri.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757099Ab3BARWL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 12:22:11 -0500
In-Reply-To: <510BF1C4.4050108@redhat.com>
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
Cc: Daniel Borkmann <dborkman@redhat.com>

---
Changes since v1:
- less functions
- more code duplication
---
 net/packet/af_packet.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index a91fd0b..07c9483 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2364,13 +2364,15 @@ static int packet_release(struct socket *sock)
 
 	packet_flush_mclist(sk);
 
-	memset(&req_u, 0, sizeof(req_u));
-
-	if (po->rx_ring.pg_vec)
+	if (po->rx_ring.pg_vec) {
+		memset(&req_u, 0, sizeof(req_u));
 		packet_set_ring(sk, &req_u, 1, 0);
+	}
 
-	if (po->tx_ring.pg_vec)
+	if (po->tx_ring.pg_vec) {
+		memset(&req_u, 0, sizeof(req_u));
 		packet_set_ring(sk, &req_u, 1, 1);
+	}
 
 	fanout_release(sk);
 
-- 
1.7.12.3
