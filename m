From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: [RFC v3 3/6] can: make struct proto const
Date: Mon, 14 Mar 2011 14:47:21 +0100
Message-ID: <20110314134721.GD333@e-circ.dyndns.org>
References: <20110314132004.GA333@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110314132004.GA333-MxZ6Iy/zr/UdbCeoMzGj59i2O/JbrIOy@public.gmane.org>
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

can_ioctl is the only reason for struct proto to be non-const.
script/check-patch.pl suggests struct proto be const.
This patch performs the necessary change.

Signed-off-by: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
---
diff --git a/include/linux/can/core.h b/include/linux/can/core.h
index 430c446..0767cc6 100644
--- a/include/linux/can/core.h
+++ b/include/linux/can/core.h
@@ -39,7 +39,7 @@
 struct can_proto {
 	int              type;
 	int              protocol;
-	struct proto_ops *ops;
+	const struct proto_ops *ops;
 	struct proto     *prot;
 
 	const struct rtnl_af_ops *rtnl_link_ops;
@@ -78,6 +78,8 @@ struct rtgencanmsg {
 
 extern int  can_proto_register(const struct can_proto *cp);
 extern void can_proto_unregister(const struct can_proto *cp);
+extern int can_sock_ioctl(struct socket *sock, unsigned int cmd,
+		unsigned long arg);
 
 extern int  can_rx_register(struct net_device *dev, canid_t can_id,
 			    canid_t mask,
diff --git a/net/can/af_can.c b/net/can/af_can.c
index db59c6e..c1f8c05 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -139,7 +139,7 @@ static inline void can_put_proto(const struct can_proto *cp)
  * af_can socket functions
  */
 
-static int can_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+int can_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	struct sock *sk = sock->sk;
 
@@ -152,6 +152,7 @@ static int can_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		return -ENOIOCTLCMD;
 	}
 }
+EXPORT_SYMBOL(can_sock_ioctl);
 
 static void can_sock_destruct(struct sock *sk)
 {
@@ -720,10 +721,6 @@ int can_proto_register(const struct can_proto *cp)
 		err = -EBUSY;
 	} else {
 		proto_tab[proto] = cp;
-
-		/* use generic ioctl function if not defined by module */
-		if (!cp->ops->ioctl)
-			cp->ops->ioctl = can_ioctl;
 	}
 	spin_unlock(&proto_tab_lock);
 
diff --git a/net/can/bcm.c b/net/can/bcm.c
index ac1961d..fd89542 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1569,7 +1569,7 @@ static int bcm_recvmsg(struct kiocb *iocb, struct socket *sock,
 	return size;
 }
 
-static struct proto_ops bcm_ops __read_mostly = {
+static const struct proto_ops bcm_ops = {
 	.family        = PF_CAN,
 	.release       = bcm_release,
 	.bind          = sock_no_bind,
@@ -1578,7 +1578,7 @@ static struct proto_ops bcm_ops __read_mostly = {
 	.accept        = sock_no_accept,
 	.getname       = sock_no_getname,
 	.poll          = datagram_poll,
-	.ioctl         = NULL,		/* use can_ioctl() from af_can.c */
+	.ioctl         = can_sock_ioctl,
 	.listen        = sock_no_listen,
 	.shutdown      = sock_no_shutdown,
 	.setsockopt    = sock_no_setsockopt,
diff --git a/net/can/raw.c b/net/can/raw.c
index 9ad3dfc..8581596 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -742,7 +742,7 @@ static int raw_recvmsg(struct kiocb *iocb, struct socket *sock,
 	return size;
 }
 
-static struct proto_ops raw_ops __read_mostly = {
+static const struct proto_ops raw_ops = {
 	.family        = PF_CAN,
 	.release       = raw_release,
 	.bind          = raw_bind,
@@ -751,7 +751,7 @@ static struct proto_ops raw_ops __read_mostly = {
 	.accept        = sock_no_accept,
 	.getname       = raw_getname,
 	.poll          = datagram_poll,
-	.ioctl         = NULL,		/* use can_ioctl() from af_can.c */
+	.ioctl         = can_sock_ioctl,
 	.listen        = sock_no_listen,
 	.shutdown      = sock_no_shutdown,
 	.setsockopt    = raw_setsockopt,
