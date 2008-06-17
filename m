From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Consolidate ax25 socket grafting.
Date: Tue, 17 Jun 2008 02:32:01 -0700 (PDT)
Message-ID: <20080617.023201.14122891.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-hams@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47483
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754624AbYFQJcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 05:32:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[ For the AX.25 folks: I'm basically walking the tree auditing
  how parent sockets get grafted to child socks and making protocols
  use sock_graft() and sock_orphan() when they are open-coding that
  construct. ]

Applied and pushed to net-next-2.6

ax25: Use sock_graft() and remove bogus sk_socket and sk_sleep init.

The way that listening sockets work in ax25 is that the packet input
code path creates new socks via ax25_make_new() and attaches them
to the incoming SKB.  This SKB gets queued up into the listening
socket's receive queue.

When accept()'d the sock gets hooked up to the real parent socket.
Alternatively, if the listening socket is closed and released, any
unborn socks stuff up in the receive queue get released.

So during this time period these sockets are unreachable in any
other way, so no wakeup events nor references to their ->sk_socket
and ->sk_sleep members can occur.  And even if they do, all such
paths have to make NULL checks.

So do not deceptively initialize them in ax25_make_new() to the
values in the listening socket.  Leave them at NULL.

Finally, use sock_graft() in ax25_accept().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ax25/af_ax25.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 2712544..97eaa23 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -893,13 +893,11 @@ struct sock *ax25_make_new(struct sock *osk, struct ax25_dev *ax25_dev)
 
 	sk->sk_destruct = ax25_free_sock;
 	sk->sk_type     = osk->sk_type;
-	sk->sk_socket   = osk->sk_socket;
 	sk->sk_priority = osk->sk_priority;
 	sk->sk_protocol = osk->sk_protocol;
 	sk->sk_rcvbuf   = osk->sk_rcvbuf;
 	sk->sk_sndbuf   = osk->sk_sndbuf;
 	sk->sk_state    = TCP_ESTABLISHED;
-	sk->sk_sleep    = osk->sk_sleep;
 	sock_copy_flags(sk, osk);
 
 	oax25 = ax25_sk(osk);
@@ -1361,13 +1359,11 @@ static int ax25_accept(struct socket *sock, struct socket *newsock, int flags)
 		goto out;
 
 	newsk		 = skb->sk;
-	newsk->sk_socket = newsock;
-	newsk->sk_sleep	 = &newsock->wait;
+	sock_graft(newsk, newsock);
 
 	/* Now attach up the new socket */
 	kfree_skb(skb);
 	sk->sk_ack_backlog--;
-	newsock->sk    = newsk;
 	newsock->state = SS_CONNECTED;
 
 out:
-- 
1.5.5.1.308.g1fbb5

