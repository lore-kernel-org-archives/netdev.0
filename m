From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 2/9] tipc: return POLLOUT for sockets in an unconnected state
Date: Thu, 22 Nov 2012 15:59:47 -0500
Message-ID: <1353617994-3962-3-git-send-email-paul.gortmaker@windriver.com>
References: <1353617994-3962-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Erik Hugne <erik.hugne@ericsson.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:59981 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757205Ab2KVVAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 16:00:08 -0500
In-Reply-To: <1353617994-3962-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

If an implied connect is attempted on a nonblocking STREAM/SEQPACKET
socket during link congestion, the connect message will be discarded
and sendmsg will return EAGAIN. This is normal behavior, and the
application is expected to poll the socket until POLLOUT is set,
after which the connection attempt can be retried.
However, the POLLOUT flag is never set for unconnected sockets and
poll() always returns a zero mask. The application is then left without
a trigger for when it can make another attempt at sending the message.

The solution is to check if we're polling on an unconnected socket
and set the POLLOUT flag if the TIPC port owned by this socket
is not congested. The TIPC ports waiting on a specific link will be
marked as 'not congested' when the link congestion have abated.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index b5fc8ed..59adc76 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -412,7 +412,7 @@ static int get_name(struct socket *sock, struct sockaddr *uaddr,
  * socket state		flags set
  * ------------		---------
  * unconnected		no read flags
- *			no write flags
+ *			POLLOUT if port is not congested
  *
  * connecting		POLLIN/POLLRDNORM if ACK/NACK in rx queue
  *			no write flags
@@ -442,6 +442,10 @@ static unsigned int poll(struct file *file, struct socket *sock,
 	sock_poll_wait(file, sk_sleep(sk), wait);
 
 	switch ((int)sock->state) {
+	case SS_UNCONNECTED:
+		if (!tipc_sk_port(sk)->congested)
+			mask |= POLLOUT;
+		break;
 	case SS_READY:
 	case SS_CONNECTED:
 		if (!tipc_sk_port(sk)->congested)
-- 
1.7.12.1
