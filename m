From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH] can: make struct proto const
Date: Tue, 22 Mar 2011 19:27:25 +0100
Message-ID: <4D88EA0D.3090601@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Kurt Van Dijck <kurt.van.dijck@eia.be>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:55662 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910Ab1CVS10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 14:27:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

can_ioctl is the only reason for struct proto to be non-const.
script/check-patch.pl suggests struct proto be const.

Setting the reference to the common can_ioctl() in all CAN protocols directly
removes the need to make the struct proto writable in af_can.c

Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---

diff --git a/include/linux/can/core.h b/include/linux/can/core.h
index 6c507be..6f70a6d 100644
--- a/include/linux/can/core.h
+++ b/include/linux/can/core.h
@@ -36,10 +36,10 @@
  * @prot:       pointer to struct proto structure.
  */
 struct can_proto {
-	int              type;
-	int              protocol;
-	struct proto_ops *ops;
-	struct proto     *prot;
+	int type;
+	int protocol;
+	const struct proto_ops *ops;
+	struct proto *prot;
 };
 
 /* function prototypes for the CAN networklayer core (af_can.c) */
@@ -58,5 +58,6 @@ extern void can_rx_unregister(struct net_device *dev, canid_t can_id,
 			      void *data);
 
 extern int can_send(struct sk_buff *skb, int loop);
+extern int can_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
 
 #endif /* CAN_CORE_H */
diff --git a/net/can/af_can.c b/net/can/af_can.c
index 702be5a..733d66f 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -95,7 +95,7 @@ struct s_pstats   can_pstats;      /* receive list statistics */
  * af_can socket functions
  */
 
-static int can_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+int can_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	struct sock *sk = sock->sk;
 
@@ -108,6 +108,7 @@ static int can_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		return -ENOIOCTLCMD;
 	}
 }
+EXPORT_SYMBOL(can_ioctl);
 
 static void can_sock_destruct(struct sock *sk)
 {
@@ -698,13 +699,9 @@ int can_proto_register(struct can_proto *cp)
 		printk(KERN_ERR "can: protocol %d already registered\n",
 		       proto);
 		err = -EBUSY;
-	} else {
+	} else
 		proto_tab[proto] = cp;
 
-		/* use generic ioctl function if not defined by module */
-		if (!cp->ops->ioctl)
-			cp->ops->ioctl = can_ioctl;
-	}
 	spin_unlock(&proto_tab_lock);
 
 	if (err < 0)
diff --git a/net/can/bcm.c b/net/can/bcm.c
index 092dc88..871a0ad 100644
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
+	.ioctl         = can_ioctl,	/* use can_ioctl() from af_can.c */
 	.listen        = sock_no_listen,
 	.shutdown      = sock_no_shutdown,
 	.setsockopt    = sock_no_setsockopt,
diff --git a/net/can/raw.c b/net/can/raw.c
index 883e9d7..649acfa 100644
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
+	.ioctl         = can_ioctl,	/* use can_ioctl() from af_can.c */
 	.listen        = sock_no_listen,
 	.shutdown      = sock_no_shutdown,
 	.setsockopt    = raw_setsockopt,

