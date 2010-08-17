From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 09/14] tipc: Remove per-connection sequence number logic
Date: Tue, 17 Aug 2010 17:00:11 -0400
Message-ID: <1282078816-11844-10-git-send-email-paul.gortmaker@windriver.com>
References: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57135 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089Ab0HQVA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 17:00:26 -0400
In-Reply-To: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Remove validation of the per-connection sequence numbers on routable
connections, since routable connections are not supported by TIPC.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |   15 +++------------
 1 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 0737680..ebcbc21 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -588,19 +588,10 @@ void tipc_port_recv_proto_msg(struct sk_buff *buf)
 	if (!p_ptr) {
 		err = TIPC_ERR_NO_PORT;
 	} else if (p_ptr->publ.connected) {
-		if (port_peernode(p_ptr) != msg_orignode(msg))
+		if ((port_peernode(p_ptr) != msg_orignode(msg)) ||
+		    (port_peerport(p_ptr) != msg_origport(msg))) {
 			err = TIPC_ERR_NO_PORT;
-		if (port_peerport(p_ptr) != msg_origport(msg))
-			err = TIPC_ERR_NO_PORT;
-		if (!err && msg_routed(msg)) {
-			u32 seqno = msg_transp_seqno(msg);
-			u32 myno =  ++p_ptr->last_in_seqno;
-			if (seqno != myno) {
-				err = TIPC_ERR_NO_PORT;
-				abort_buf = port_build_self_abort_msg(p_ptr, err);
-			}
-		}
-		if (msg_type(msg) == CONN_ACK) {
+		} else if (msg_type(msg) == CONN_ACK) {
 			int wakeup = tipc_port_congested(p_ptr) &&
 				     p_ptr->publ.congested &&
 				     p_ptr->wakeup;
-- 
1.7.2.1

