From: <erik.hugne@ericsson.com>
Subject: [PATCH v2] tipc: prevent dropped connections due to rcvbuf overflow
Date: Thu, 4 Oct 2012 17:00:43 +0200
Message-ID: <1349362843-25826-1-git-send-email-erik.hugne@ericsson.com>
References: <1349358913.16011.59.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ying.xue@windriver.com>, <paul.gortmaker@windriver.com>,
	<tipc-discussion@lists.sourceforge.net>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.ericsson.se ([193.180.251.45]:48070 "EHLO
	mailgw1.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965200Ab2JDPAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 11:00:50 -0400
In-Reply-To: <1349358913.16011.59.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

When large buffers are sent over connected TIPC sockets, it
is likely that the sk_backlog will be filled up on the
receiver side, but the TIPC flow control mechanism is happily
unaware of this since that is based on message count.

The sender will receive a TIPC_ERR_OVERLOAD message when this occurs
and drop it's side of the connection, leaving it stale on
the receiver end.

By increasing the sk_rcvbuf to a 'worst case' value, we avoid the
overload caused by a full backlog queue and the flow control
will work properly.

This worst case value is the max TIPC message size times
the flow control window, multiplied by two because a sender
will transmit up to double the window size before a port is marked
congested.
We multiply this by 2 to account for the sk_buff and other overheads.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/socket.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 09dc5b9..fd5f042 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -220,6 +220,7 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol,
 
 	sock_init_data(sock, sk);
 	sk->sk_backlog_rcv = backlog_rcv;
+	sk->sk_rcvbuf = TIPC_FLOW_CONTROL_WIN * 2 * TIPC_MAX_USER_MSG_SIZE * 2;
 	tipc_sk(sk)->p = tp_ptr;
 	tipc_sk(sk)->conn_timeout = CONN_TIMEOUT_DEFAULT;
 
-- 
1.7.5.4
