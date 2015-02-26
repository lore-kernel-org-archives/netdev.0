From: Eyal Birger <eyal.birger@gmail.com>
Subject: [PATCH net-next v2 3/7] net: rxrpc: change call to sock_recv_ts_and_drops() on rxrpc recvmsg to sock_recv_timestamp()
Date: Thu, 26 Feb 2015 21:07:00 +0200
Message-ID: <1424977624-649-4-git-send-email-eyal.birger@gmail.com>
References: <1424977624-649-1-git-send-email-eyal.birger@gmail.com>
Cc: willemb@google.com, edumazet@google.com, shmulik.ladkani@gmail.com,
	linux-bluetooth@vger.kernel.org, marcel@holtmann.org,
	netdev@vger.kernel.org, Eyal Birger <eyal.birger@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:46532 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754523AbbBZTHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 14:07:31 -0500
In-Reply-To: <1424977624-649-1-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 3b885787ea4112 ("net: Generalize socket rx gap / receive queue overflow cmsg")
allowed receiving packet dropcount information as a socket level option.
RXRPC sockets recvmsg function was changed to support this by calling
sock_recv_ts_and_drops() instead of sock_recv_timestamp().

However, protocol families wishing to receive dropcount should call
sock_queue_rcv_skb() or set the dropcount specifically (as done
in packet_rcv()). This was not done for rxrpc and thus this feature
never worked on these sockets.

Formalizing this by not calling sock_recv_ts_and_drops() in rxrpc as
part of an effort to move skb->dropcount into skb->cb[]

Signed-off-by: Eyal Birger <eyal.birger@gmail.com>
---
 net/rxrpc/ar-recvmsg.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
index 4575485..d58ba70 100644
--- a/net/rxrpc/ar-recvmsg.c
+++ b/net/rxrpc/ar-recvmsg.c
@@ -150,7 +150,7 @@ int rxrpc_recvmsg(struct kiocb *iocb, struct socket *sock,
 				       &call->conn->trans->peer->srx, len);
 				msg->msg_namelen = len;
 			}
-			sock_recv_ts_and_drops(msg, &rx->sk, skb);
+			sock_recv_timestamp(msg, &rx->sk, skb);
 		}
 
 		/* receive the message */
-- 
2.1.4
