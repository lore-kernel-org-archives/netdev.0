From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [net-next 1/1] tipc: fix broken tipc_poll() function
Date: Thu, 19 Oct 2017 16:42:04 +0200
Message-ID: <1508424124-1748-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parthasarathy.bhuvaragan@ericsson.com>, <ying.xue@windriver.com>,
        <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:61720 "EHLO
        sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751014AbdJSOmL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 10:42:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit ae236fb208a6 ("tipc: receive group membership events via
member socket") we broke the tipc_poll() function by checking the
state of the receive queue before the call to poll_sock_wait(), while
relying that state afterwards, when it might have changed.

We restore this in this commit.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 2bbab4f..357954c 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -714,7 +714,6 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
 			      poll_table *wait)
 {
 	struct sock *sk = sock->sk;
-	struct sk_buff *skb = skb_peek(&sk->sk_receive_queue);
 	struct tipc_sock *tsk = tipc_sk(sk);
 	struct tipc_group *grp = tsk->group;
 	u32 revents = 0;
@@ -733,7 +732,7 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
 		/* fall thru' */
 	case TIPC_LISTEN:
 	case TIPC_CONNECTING:
-		if (skb)
+		if (!skb_queue_empty(&sk->sk_receive_queue))
 			revents |= POLLIN | POLLRDNORM;
 		break;
 	case TIPC_OPEN:
@@ -742,7 +741,7 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
 				revents |= POLLOUT;
 		if (!tipc_sk_type_connectionless(sk))
 			break;
-		if (!skb)
+		if (skb_queue_empty(&sk->sk_receive_queue))
 			break;
 		revents |= POLLIN | POLLRDNORM;
 		break;
-- 
2.1.4
