From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: [net-next-2.6 PATCH] can: rename can_try_module_get to can_get_proto
Date: Wed, 4 May 2011 06:42:04 +0200
Message-ID: <20110504044204.GD278@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

can: rename can_try_module_get to can_get_proto

can_try_module_get does return a struct can_proto.
The name explains what is done in so much detail that a caller
may not notice that a struct can_proto is locked/unlocked.

Signed-off-by: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>

diff --git a/net/can/af_can.c b/net/can/af_can.c
index 5b52762..094fc53 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -115,7 +115,7 @@ static void can_sock_destruct(struct sock *sk)
 	skb_queue_purge(&sk->sk_receive_queue);
 }
 
-static const struct can_proto *can_try_module_get(int protocol)
+static const struct can_proto *can_get_proto(int protocol)
 {
 	const struct can_proto *cp;
 
@@ -128,6 +128,11 @@ static const struct can_proto *can_try_module_get(int protocol)
 	return cp;
 }
 
+static inline void can_put_proto(const struct can_proto *cp)
+{
+	module_put(cp->prot->owner);
+}
+
 static int can_create(struct net *net, struct socket *sock, int protocol,
 		      int kern)
 {
@@ -143,7 +148,7 @@ static int can_create(struct net *net, struct socket *sock, int protocol,
 	if (!net_eq(net, &init_net))
 		return -EAFNOSUPPORT;
 
-	cp = can_try_module_get(protocol);
+	cp = can_get_proto(protocol);
 
 #ifdef CONFIG_MODULES
 	if (!cp) {
@@ -160,7 +165,7 @@ static int can_create(struct net *net, struct socket *sock, int protocol,
 			printk(KERN_ERR "can: request_module "
 			       "(can-proto-%d) failed.\n", protocol);
 
-		cp = can_try_module_get(protocol);
+		cp = can_get_proto(protocol);
 	}
 #endif
 
@@ -195,7 +200,7 @@ static int can_create(struct net *net, struct socket *sock, int protocol,
 	}
 
  errout:
-	module_put(cp->prot->owner);
+	can_put_proto(cp);
 	return err;
 }
