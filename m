From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: [PATCH] can: test size of struct sockaddr
Date: Fri, 14 Jan 2011 18:23:21 +0100
Message-ID: <20110114172321.GB331@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

I think this patch makes the CAN socket code comform to the
manpages of sendmsg & recvmsg.

Signed-off-by: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
---
 net/can/bcm.c |    6 +++++-
 net/can/raw.c |    6 +++++-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/can/bcm.c b/net/can/bcm.c
index 6faa825..dc0d5d6 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1256,6 +1256,9 @@ static int bcm_sendmsg(struct kiocb *iocb, struct socket *sock,
 		struct sockaddr_can *addr =
 			(struct sockaddr_can *)msg->msg_name;
 
+		if (msg->msg_namelen < sizeof(*addr))
+			return -EINVAL;
+
 		if (addr->can_family != AF_CAN)
 			return -EINVAL;
 
@@ -1557,8 +1560,9 @@ static int bcm_recvmsg(struct kiocb *iocb, struct socket *sock,
 	sock_recv_ts_and_drops(msg, sk, skb);
 
 	if (msg->msg_name) {
+		memcpy(msg->msg_name, skb->cb, MIN(msg->msg_namelen,
+					sizeof(struct sockaddr_can)));
 		msg->msg_namelen = sizeof(struct sockaddr_can);
-		memcpy(msg->msg_name, skb->cb, msg->msg_namelen);
 	}
 
 	skb_free_datagram(sk, skb);
diff --git a/net/can/raw.c b/net/can/raw.c
index e88f610..e68a6d3 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -649,6 +649,9 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 		struct sockaddr_can *addr =
 			(struct sockaddr_can *)msg->msg_name;
 
+		if (msg->msg_namelen < sizeof(*addr))
+			return -EINVAL;
+
 		if (addr->can_family != AF_CAN)
 			return -EINVAL;
 
@@ -727,8 +730,9 @@ static int raw_recvmsg(struct kiocb *iocb, struct socket *sock,
 	sock_recv_ts_and_drops(msg, sk, skb);
 
 	if (msg->msg_name) {
+		memcpy(msg->msg_name, skb->cb, MIN(msg->msg_namelen,
+					sizeof(struct sockaddr_can)));
 		msg->msg_namelen = sizeof(struct sockaddr_can);
-		memcpy(msg->msg_name, skb->cb, msg->msg_namelen);
 	}
 
 	/* assign the flags that have been recorded in raw_rcv() */
