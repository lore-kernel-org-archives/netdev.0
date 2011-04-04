From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH net-next-2.6] can: convert protocol handling to RCU
Date: Mon, 04 Apr 2011 22:21:24 +0200
Message-ID: <4D9A2844.2080304@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Kurt Van Dijck <kurt.van.dijck@eia.be>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Urs Thuermann <urs@isnogud.escape.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:59191 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755539Ab1DDUVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 16:21:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes spin_locks at CAN socket creation time by using RCU.

Inspired by the discussion with Kurt van Dijck and Eric Dumazet the RCU code
was partly derived from af_phonet.c

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---

diff --git a/net/can/af_can.c b/net/can/af_can.c
index 733d66f..551ebc1 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -85,7 +85,7 @@ static struct kmem_cache *rcv_cache __read_mostly;
 
 /* table of registered CAN protocols */
 static struct can_proto *proto_tab[CAN_NPROTO] __read_mostly;
-static DEFINE_SPINLOCK(proto_tab_lock);
+static DEFINE_MUTEX(proto_tab_lock);
 
 struct timer_list can_stattimer;   /* timer for statistics update */
 struct s_stats    can_stats;       /* packet statistics */
@@ -115,6 +115,19 @@ static void can_sock_destruct(struct sock *sk)
 	skb_queue_purge(&sk->sk_receive_queue);
 }
 
+static struct can_proto *can_try_module_get(int protocol)
+{
+	struct can_proto *cp;
+
+	rcu_read_lock();
+	cp = rcu_dereference(proto_tab[protocol]);
+	if (cp && !try_module_get(cp->prot->owner))
+		cp = NULL;
+	rcu_read_unlock();
+
+	return cp;
+}
+
 static int can_create(struct net *net, struct socket *sock, int protocol,
 		      int kern)
 {
@@ -130,9 +143,12 @@ static int can_create(struct net *net, struct socket *sock, int protocol,
 	if (!net_eq(net, &init_net))
 		return -EAFNOSUPPORT;
 
+	cp = can_try_module_get(protocol);
+
 #ifdef CONFIG_MODULES
-	/* try to load protocol module kernel is modular */
-	if (!proto_tab[protocol]) {
+	if (!cp) {
+		/* try to load protocol module if kernel is modular */
+
 		err = request_module("can-proto-%d", protocol);
 
 		/*
@@ -143,22 +159,18 @@ static int can_create(struct net *net, struct socket *sock, int protocol,
 		if (err && printk_ratelimit())
 			printk(KERN_ERR "can: request_module "
 			       "(can-proto-%d) failed.\n", protocol);
+		else
+			cp = can_try_module_get(protocol);
 	}
 #endif
 
-	spin_lock(&proto_tab_lock);
-	cp = proto_tab[protocol];
-	if (cp && !try_module_get(cp->prot->owner))
-		cp = NULL;
-	spin_unlock(&proto_tab_lock);
-
 	/* check for available protocol and correct usage */
 
 	if (!cp)
 		return -EPROTONOSUPPORT;
 
 	if (cp->type != sock->type) {
-		err = -EPROTONOSUPPORT;
+		err = -EPROTOTYPE;
 		goto errout;
 	}
 
@@ -694,15 +706,16 @@ int can_proto_register(struct can_proto *cp)
 	if (err < 0)
 		return err;
 
-	spin_lock(&proto_tab_lock);
+	mutex_lock(&proto_tab_lock);
+
 	if (proto_tab[proto]) {
 		printk(KERN_ERR "can: protocol %d already registered\n",
 		       proto);
 		err = -EBUSY;
 	} else
-		proto_tab[proto] = cp;
+		rcu_assign_pointer(proto_tab[proto], cp);
 
-	spin_unlock(&proto_tab_lock);
+	mutex_unlock(&proto_tab_lock);
 
 	if (err < 0)
 		proto_unregister(cp->prot);
@@ -719,13 +732,12 @@ void can_proto_unregister(struct can_proto *cp)
 {
 	int proto = cp->protocol;
 
-	spin_lock(&proto_tab_lock);
-	if (!proto_tab[proto]) {
-		printk(KERN_ERR "BUG: can: protocol %d is not registered\n",
-		       proto);
-	}
-	proto_tab[proto] = NULL;
-	spin_unlock(&proto_tab_lock);
+	mutex_lock(&proto_tab_lock);
+	BUG_ON(proto_tab[proto] != cp);
+	rcu_assign_pointer(proto_tab[proto], NULL);
+	mutex_unlock(&proto_tab_lock);
+
+	synchronize_rcu();
 
 	proto_unregister(cp->prot);
 }

