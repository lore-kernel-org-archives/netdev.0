From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.72] (1/3) PPPoE cleanup [TRIVIAL]
Date: Fri, 20 Jun 2003 17:31:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030620173139.01f935c7.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mostrows@speakeasy.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
   Michal Ostrowski
 <mostrows@styx.uwaterloo.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a cleanup patch, no change in functionality.
  - Get rid of debug macro's that aren't used anywhere in the code.
  - Make functions and data structures static where possible
  - C99 initializer for ppoe_chan_ops
  - fix whitespace typo

diff -Nru a/drivers/net/pppoe.c b/drivers/net/pppoe.c
--- a/drivers/net/pppoe.c	Fri Jun 20 16:38:03 2003
+++ b/drivers/net/pppoe.c	Fri Jun 20 16:38:03 2003
@@ -77,27 +77,14 @@
 
 #include <asm/uaccess.h>
 
-static int __attribute__((unused)) pppoe_debug = 7;
 #define PPPOE_HASH_BITS 4
 #define PPPOE_HASH_SIZE (1<<PPPOE_HASH_BITS)
 
-int pppoe_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
-int pppoe_xmit(struct ppp_channel *chan, struct sk_buff *skb);
-int __pppoe_xmit(struct sock *sk, struct sk_buff *skb);
-
-struct proto_ops pppoe_ops;
-
-
-#if 0
-#define CHECKPTR(x,y) do { if (!(x) && pppoe_debug &7 ){ printk(KERN_CRIT "PPPoE Invalid pointer : %s , %p\n",#x,(x)); error=-EINVAL; goto y; }} while (0)
-#define DEBUG(s,args...) do { if( pppoe_debug & (s) ) printk(KERN_CRIT args ); } while (0)
-#else
-#define CHECKPTR(x,y) do { } while (0)
-#define DEBUG(s,args...) do { } while (0)
-#endif
-
-
+static int pppoe_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
+static int pppoe_xmit(struct ppp_channel *chan, struct sk_buff *skb);
+static int __pppoe_xmit(struct sock *sk, struct sk_buff *skb);
 
+static struct proto_ops pppoe_ops;
 static rwlock_t pppoe_hash_lock = RW_LOCK_UNLOCKED;
 
 
@@ -255,8 +242,7 @@
 {
 	int hash;
 
-	if (dev == NULL)
-		BUG();
+	BUG_ON(dev == NULL);
 
 	read_lock_bh(&pppoe_hash_lock);
 	for (hash = 0; hash < PPPOE_HASH_SIZE; hash++) {
@@ -336,14 +322,12 @@
 };
 
 
-
-
 /************************************************************************
  *
  * Do the real work of receiving a PPPoE Session frame.
  *
  ***********************************************************************/
-int pppoe_rcv_core(struct sock *sk, struct sk_buff *skb)
+static int pppoe_rcv_core(struct sock *sk, struct sk_buff *skb)
 {
 	struct pppox_opt *po = pppox_sk(sk);
 	struct pppox_opt *relay_po = NULL;
@@ -361,7 +345,7 @@
 			goto abort_put;
 
 		skb_pull(skb, sizeof(struct pppoe_hdr));
-		if (!__pppoe_xmit( relay_po->sk , skb))
+		if (!__pppoe_xmit( relay_po->sk, skb))
 			goto abort_put;
 	} else {
 		sock_queue_rcv_skb(sk, skb);
@@ -460,12 +444,12 @@
 	return NET_RX_SUCCESS; /* Lies... :-) */
 }
 
-struct packet_type pppoes_ptype = {
+static struct packet_type pppoes_ptype = {
 	.type	= __constant_htons(ETH_P_PPP_SES),
 	.func	= pppoe_rcv,
 };
 
-struct packet_type pppoed_ptype = {
+static struct packet_type pppoed_ptype = {
 	.type	= __constant_htons(ETH_P_PPP_DISC),
 	.func	= pppoe_disc_rcv,
 };
@@ -522,7 +506,7 @@
 	goto out;
 }
 
-int pppoe_release(struct socket *sock)
+static int pppoe_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 	struct pppox_opt *po;
@@ -559,7 +543,7 @@
 }
 
 
-int pppoe_connect(struct socket *sock, struct sockaddr *uservaddr,
+static int pppoe_connect(struct socket *sock, struct sockaddr *uservaddr,
 		  int sockaddr_len, int flags)
 {
 	struct sock *sk = sock->sk;
@@ -648,7 +632,7 @@
 }
 
 
-int pppoe_getname(struct socket *sock, struct sockaddr *uaddr,
+static int pppoe_getname(struct socket *sock, struct sockaddr *uaddr,
 		  int *usockaddr_len, int peer)
 {
 	int len = sizeof(struct sockaddr_pppox);
@@ -667,7 +651,7 @@
 }
 
 
-int pppoe_ioctl(struct socket *sock, unsigned int cmd,
+static int pppoe_ioctl(struct socket *sock, unsigned int cmd,
 		unsigned long arg)
 {
 	struct sock *sk = sock->sk;
@@ -769,7 +753,7 @@
 }
 
 
-int pppoe_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
+static int pppoe_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 		  int total_len)
 {
 	struct sk_buff *skb = NULL;
@@ -847,7 +831,7 @@
  * xmit function for internal use.
  *
  ***********************************************************************/
-int __pppoe_xmit(struct sock *sk, struct sk_buff *skb)
+static int __pppoe_xmit(struct sock *sk, struct sk_buff *skb)
 {
 	struct pppox_opt *po = pppox_sk(sk);
 	struct net_device *dev = po->pppoe_dev;
@@ -921,16 +905,18 @@
  * sends PPP frame over PPPoE socket
  *
  ***********************************************************************/
-int pppoe_xmit(struct ppp_channel *chan, struct sk_buff *skb)
+static int pppoe_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 {
 	struct sock *sk = (struct sock *) chan->private;
 	return __pppoe_xmit(sk, skb);
 }
 
 
-struct ppp_channel_ops pppoe_chan_ops = { pppoe_xmit , NULL };
+static struct ppp_channel_ops pppoe_chan_ops = { 
+	.start_xmit = pppoe_xmit, 
+};
 
-int pppoe_recvmsg(struct kiocb *iocb, struct socket *sock,
+static int pppoe_recvmsg(struct kiocb *iocb, struct socket *sock,
 		  struct msghdr *m, int total_len, int flags)
 {
 	struct sock *sk = sock->sk;
@@ -1071,7 +1057,7 @@
 
 /* ->ioctl are set at pppox_create */
 
-struct proto_ops pppoe_ops = {
+static struct proto_ops pppoe_ops = {
     .family		= AF_PPPOX,
     .owner		= THIS_MODULE,
     .release		= pppoe_release,
@@ -1090,14 +1076,14 @@
     .mmap		= sock_no_mmap
 };
 
-struct pppox_proto pppoe_proto = {
+static struct pppox_proto pppoe_proto = {
     .create	= pppoe_create,
     .ioctl	= pppoe_ioctl,
     .owner	= THIS_MODULE,
 };
 
 
-int __init pppoe_init(void)
+static int __init pppoe_init(void)
 {
  	int err = register_pppox_proto(PX_PROTO_OE, &pppoe_proto);
 
@@ -1125,7 +1111,7 @@
 	goto out;
 }
 
-void __exit pppoe_exit(void)
+static void __exit pppoe_exit(void)
 {
 	unregister_pppox_proto(PX_PROTO_OE);
 	dev_remove_pack(&pppoes_ptype);
