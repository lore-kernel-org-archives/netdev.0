From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: [PATCH net-next] can-raw: add msg_flags to distinguish local traffic
Date: Fri, 15 Oct 2010 09:37:09 +0200
Message-ID: <20101015073709.GA387@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
To: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
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

CAN has no addressing scheme. It is currently impossible
for userspace to tell is a received CAN frame comes from
another process on the local host, or from a remote CAN
device.
This patch add support for userspace applications to distinguish
between 'own', 'local' and 'remote' CAN traffic.
Distinction is made by returning some flags in msg->msg_flags
in the call to recvmsg.
MSG_CONFIRM flag means 'own', as in 'transmission confirmation'
MSG_DONTROUTE flag means 'local', not routed.
Obviously, msgs with MSG_CONFIRM will have MSG_DONTROUTE set too.

Please note that on SocketCAN mailing list, different opinions
exist on the exact meaning of MSG_DONTROUTE. Better (=more
intuitive) alternatives are appreciated.

Signed-off-by: Kurt Van Dijck <kurt.van.dijck-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>
---
 net/can/raw.c |   33 ++++++++++++++++++++++++++++++---
 1 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/net/can/raw.c b/net/can/raw.c
index 7d77e67..f98709e 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -90,23 +90,39 @@ struct raw_sock {
 	can_err_mask_t err_mask;
 };
 
+/*
+ * return some space to store extra msg flags in.
+ * We use 1 int beyond the 'struct sockaddr_can' in skb->cb
+ * to store those.
+ * These flags will be use in raw_recvmsg()
+ */
+static inline int *raw_flags(struct sk_buff *skb)
+{
+	BUILD_BUG_ON(sizeof(skb->cb)
+			<= (sizeof(struct sockaddr_can) + sizeof(int)));
+	/* return pointer after struct sockaddr_can */
+	return (int *)(&((struct sockaddr_can *)skb->cb)[1]);
+}
+
 static inline struct raw_sock *raw_sk(const struct sock *sk)
 {
 	return (struct raw_sock *)sk;
 }
 
-static void raw_rcv(struct sk_buff *skb, void *data)
+static void raw_rcv(struct sk_buff *oskb, void *data)
 {
 	struct sock *sk = (struct sock *)data;
 	struct raw_sock *ro = raw_sk(sk);
 	struct sockaddr_can *addr;
+	struct sk_buff *skb;
+	int *pflags;
 
 	/* check the received tx sock reference */
-	if (!ro->recv_own_msgs && skb->sk == sk)
+	if (!ro->recv_own_msgs && oskb->sk == sk)
 		return;
 
 	/* clone the given skb to be able to enqueue it into the rcv queue */
-	skb = skb_clone(skb, GFP_ATOMIC);
+	skb = skb_clone(oskb, GFP_ATOMIC);
 	if (!skb)
 		return;
 
@@ -123,6 +139,14 @@ static void raw_rcv(struct sk_buff *skb, void *data)
 	addr->can_family  = AF_CAN;
 	addr->can_ifindex = skb->dev->ifindex;
 
+	/* prepare the flags for raw_recvmsg() */
+	pflags = raw_flags(skb);
+	*pflags = 0;
+	if (oskb->sk)
+		*pflags |= MSG_DONTROUTE;
+	if (oskb->sk == sk)
+		*pflags |= MSG_CONFIRM;
+
 	if (sock_queue_rcv_skb(sk, skb) < 0)
 		kfree_skb(skb);
 }
@@ -707,6 +731,9 @@ static int raw_recvmsg(struct kiocb *iocb, struct socket *sock,
 		memcpy(msg->msg_name, skb->cb, msg->msg_namelen);
 	}
 
+	/* assign the flags that have been recorded in in raw_rcv() */
+	msg->msg_flags |= *(raw_flags(skb));
+
 	skb_free_datagram(sk, skb);
 
 	return size;
