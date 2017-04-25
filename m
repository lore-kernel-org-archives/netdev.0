From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH 5/8] can: network namespace support for CAN_BCM protocol
Date: Tue, 25 Apr 2017 08:19:42 +0200
Message-ID: <20170425061945.28722-6-socketcan@hartkopp.net>
References: <20170425061945.28722-1-socketcan@hartkopp.net>
Cc: Oliver Hartkopp <socketcan@hartkopp.net>, mkl@pengutronix.de,
        dev@kicherer.org, netdev@vger.kernel.org
To: linux-can@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.220]:35028 "EHLO
        mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S980628AbdDYGUa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 02:20:30 -0400
In-Reply-To: <20170425061945.28722-1-socketcan@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The CAN_BCM protocol and its procfs entries were not implemented as per-net
in the initial network namespace support by Mario Kicherer (8e8cda6d737d).
This patch adds the missing per-net functionality for the CAN BCM.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
---
 include/net/netns/can.h |  1 +
 net/can/bcm.c           | 90 +++++++++++++++++++++++++++++++------------------
 2 files changed, 58 insertions(+), 33 deletions(-)

diff --git a/include/net/netns/can.h b/include/net/netns/can.h
index 574157dbc43a..0f3c31aab8a8 100644
--- a/include/net/netns/can.h
+++ b/include/net/netns/can.h
@@ -23,6 +23,7 @@ struct netns_can {
 	struct proc_dir_entry *pde_rcvlist_sff;
 	struct proc_dir_entry *pde_rcvlist_eff;
 	struct proc_dir_entry *pde_rcvlist_err;
+	struct proc_dir_entry *bcmproc_dir;
 #endif
 
 	/* receive filters subscribed for 'all' CAN devices */
diff --git a/net/can/bcm.c b/net/can/bcm.c
index 1976629a8463..0e855917b7e1 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1,7 +1,7 @@
 /*
  * bcm.c - Broadcast Manager to filter/send (cyclic) CAN content
  *
- * Copyright (c) 2002-2016 Volkswagen Group Electronic Research
+ * Copyright (c) 2002-2017 Volkswagen Group Electronic Research
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -77,7 +77,7 @@
 		     (CAN_EFF_MASK | CAN_EFF_FLAG | CAN_RTR_FLAG) : \
 		     (CAN_SFF_MASK | CAN_EFF_FLAG | CAN_RTR_FLAG))
 
-#define CAN_BCM_VERSION "20161123"
+#define CAN_BCM_VERSION "20170425"
 
 MODULE_DESCRIPTION("PF_CAN broadcast manager protocol");
 MODULE_LICENSE("Dual BSD/GPL");
@@ -118,8 +118,6 @@ struct bcm_op {
 	struct net_device *rx_reg_dev;
 };
 
-static struct proc_dir_entry *proc_dir;
-
 struct bcm_sock {
 	struct sock sk;
 	int bound;
@@ -149,7 +147,7 @@ static inline ktime_t bcm_timeval_to_ktime(struct bcm_timeval tv)
 /*
  * procfs functions
  */
-static char *bcm_proc_getifname(char *result, int ifindex)
+static char *bcm_proc_getifname(struct net *net, char *result, int ifindex)
 {
 	struct net_device *dev;
 
@@ -157,7 +155,7 @@ static char *bcm_proc_getifname(char *result, int ifindex)
 		return "any";
 
 	rcu_read_lock();
-	dev = dev_get_by_index_rcu(&init_net, ifindex);
+	dev = dev_get_by_index_rcu(net, ifindex);
 	if (dev)
 		strcpy(result, dev->name);
 	else
@@ -170,7 +168,8 @@ static char *bcm_proc_getifname(char *result, int ifindex)
 static int bcm_proc_show(struct seq_file *m, void *v)
 {
 	char ifname[IFNAMSIZ];
-	struct sock *sk = (struct sock *)m->private;
+	struct net *net = m->private;
+	struct sock *sk = (struct sock *)PDE_DATA(m->file->f_inode);
 	struct bcm_sock *bo = bcm_sk(sk);
 	struct bcm_op *op;
 
@@ -178,7 +177,7 @@ static int bcm_proc_show(struct seq_file *m, void *v)
 	seq_printf(m, " / sk %pK", sk);
 	seq_printf(m, " / bo %pK", bo);
 	seq_printf(m, " / dropped %lu", bo->dropped_usr_msgs);
-	seq_printf(m, " / bound %s", bcm_proc_getifname(ifname, bo->ifindex));
+	seq_printf(m, " / bound %s", bcm_proc_getifname(net, ifname, bo->ifindex));
 	seq_printf(m, " <<<\n");
 
 	list_for_each_entry(op, &bo->rx_ops, list) {
@@ -190,7 +189,7 @@ static int bcm_proc_show(struct seq_file *m, void *v)
 			continue;
 
 		seq_printf(m, "rx_op: %03X %-5s ", op->can_id,
-			   bcm_proc_getifname(ifname, op->ifindex));
+			   bcm_proc_getifname(net, ifname, op->ifindex));
 
 		if (op->flags & CAN_FD_FRAME)
 			seq_printf(m, "(%u)", op->nframes);
@@ -219,7 +218,7 @@ static int bcm_proc_show(struct seq_file *m, void *v)
 	list_for_each_entry(op, &bo->tx_ops, list) {
 
 		seq_printf(m, "tx_op: %03X %s ", op->can_id,
-			   bcm_proc_getifname(ifname, op->ifindex));
+			   bcm_proc_getifname(net, ifname, op->ifindex));
 
 		if (op->flags & CAN_FD_FRAME)
 			seq_printf(m, "(%u) ", op->nframes);
@@ -242,7 +241,7 @@ static int bcm_proc_show(struct seq_file *m, void *v)
 
 static int bcm_proc_open(struct inode *inode, struct file *file)
 {
-	return single_open(file, bcm_proc_show, PDE_DATA(inode));
+	return single_open_net(inode, file, bcm_proc_show);
 }
 
 static const struct file_operations bcm_proc_fops = {
@@ -267,7 +266,7 @@ static void bcm_can_tx(struct bcm_op *op)
 	if (!op->ifindex)
 		return;
 
-	dev = dev_get_by_index(&init_net, op->ifindex);
+	dev = dev_get_by_index(sock_net(op->sk), op->ifindex);
 	if (!dev) {
 		/* RFC: should this bcm_op remove itself here? */
 		return;
@@ -764,7 +763,7 @@ static void bcm_remove_op(struct bcm_op *op)
 static void bcm_rx_unreg(struct net_device *dev, struct bcm_op *op)
 {
 	if (op->rx_reg_dev == dev) {
-		can_rx_unregister(&init_net, dev, op->can_id,
+		can_rx_unregister(dev_net(dev), dev, op->can_id,
 				  REGMASK(op->can_id), bcm_rx_handler, op);
 
 		/* mark as removed subscription */
@@ -800,7 +799,7 @@ static int bcm_delete_rx_op(struct list_head *ops, struct bcm_msg_head *mh,
 				if (op->rx_reg_dev) {
 					struct net_device *dev;
 
-					dev = dev_get_by_index(&init_net,
+					dev = dev_get_by_index(sock_net(op->sk),
 							       op->ifindex);
 					if (dev) {
 						bcm_rx_unreg(dev, op);
@@ -808,7 +807,8 @@ static int bcm_delete_rx_op(struct list_head *ops, struct bcm_msg_head *mh,
 					}
 				}
 			} else
-				can_rx_unregister(&init_net, NULL, op->can_id,
+				can_rx_unregister(sock_net(op->sk), NULL,
+						  op->can_id,
 						  REGMASK(op->can_id),
 						  bcm_rx_handler, op);
 
@@ -1220,9 +1220,9 @@ static int bcm_rx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 		if (ifindex) {
 			struct net_device *dev;
 
-			dev = dev_get_by_index(&init_net, ifindex);
+			dev = dev_get_by_index(sock_net(sk), ifindex);
 			if (dev) {
-				err = can_rx_register(&init_net, dev,
+				err = can_rx_register(sock_net(sk), dev,
 						      op->can_id,
 						      REGMASK(op->can_id),
 						      bcm_rx_handler, op,
@@ -1233,7 +1233,7 @@ static int bcm_rx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 			}
 
 		} else
-			err = can_rx_register(&init_net, NULL, op->can_id,
+			err = can_rx_register(sock_net(sk), NULL, op->can_id,
 					      REGMASK(op->can_id),
 					      bcm_rx_handler, op, "bcm", sk);
 		if (err) {
@@ -1273,7 +1273,7 @@ static int bcm_tx_send(struct msghdr *msg, int ifindex, struct sock *sk,
 		return err;
 	}
 
-	dev = dev_get_by_index(&init_net, ifindex);
+	dev = dev_get_by_index(sock_net(sk), ifindex);
 	if (!dev) {
 		kfree_skb(skb);
 		return -ENODEV;
@@ -1338,7 +1338,7 @@ static int bcm_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
 		if (ifindex) {
 			struct net_device *dev;
 
-			dev = dev_get_by_index(&init_net, ifindex);
+			dev = dev_get_by_index(sock_net(sk), ifindex);
 			if (!dev)
 				return -ENODEV;
 
@@ -1419,7 +1419,7 @@ static int bcm_notifier(struct notifier_block *nb, unsigned long msg,
 	struct bcm_op *op;
 	int notify_enodev = 0;
 
-	if (!net_eq(dev_net(dev), &init_net))
+	if (!net_eq(dev_net(dev), sock_net(sk)))
 		return NOTIFY_DONE;
 
 	if (dev->type != ARPHRD_CAN)
@@ -1491,6 +1491,7 @@ static int bcm_init(struct sock *sk)
 static int bcm_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
+	struct net *net = sock_net(sk);
 	struct bcm_sock *bo;
 	struct bcm_op *op, *next;
 
@@ -1522,14 +1523,14 @@ static int bcm_release(struct socket *sock)
 			if (op->rx_reg_dev) {
 				struct net_device *dev;
 
-				dev = dev_get_by_index(&init_net, op->ifindex);
+				dev = dev_get_by_index(net, op->ifindex);
 				if (dev) {
 					bcm_rx_unreg(dev, op);
 					dev_put(dev);
 				}
 			}
 		} else
-			can_rx_unregister(&init_net, NULL, op->can_id,
+			can_rx_unregister(net, NULL, op->can_id,
 					  REGMASK(op->can_id),
 					  bcm_rx_handler, op);
 
@@ -1537,8 +1538,8 @@ static int bcm_release(struct socket *sock)
 	}
 
 	/* remove procfs entry */
-	if (proc_dir && bo->bcm_proc_read)
-		remove_proc_entry(bo->procname, proc_dir);
+	if (net->can.bcmproc_dir && bo->bcm_proc_read)
+		remove_proc_entry(bo->procname, net->can.bcmproc_dir);
 
 	/* remove device reference */
 	if (bo->bound) {
@@ -1561,6 +1562,7 @@ static int bcm_connect(struct socket *sock, struct sockaddr *uaddr, int len,
 	struct sockaddr_can *addr = (struct sockaddr_can *)uaddr;
 	struct sock *sk = sock->sk;
 	struct bcm_sock *bo = bcm_sk(sk);
+	struct net *net = sock_net(sk);
 	int ret = 0;
 
 	if (len < sizeof(*addr))
@@ -1577,7 +1579,7 @@ static int bcm_connect(struct socket *sock, struct sockaddr *uaddr, int len,
 	if (addr->can_ifindex) {
 		struct net_device *dev;
 
-		dev = dev_get_by_index(&init_net, addr->can_ifindex);
+		dev = dev_get_by_index(net, addr->can_ifindex);
 		if (!dev) {
 			ret = -ENODEV;
 			goto fail;
@@ -1596,11 +1598,11 @@ static int bcm_connect(struct socket *sock, struct sockaddr *uaddr, int len,
 		bo->ifindex = 0;
 	}
 
-	if (proc_dir) {
+	if (net->can.bcmproc_dir) {
 		/* unique socket address as filename */
 		sprintf(bo->procname, "%lu", sock_i_ino(sk));
 		bo->bcm_proc_read = proc_create_data(bo->procname, 0644,
-						     proc_dir,
+						     net->can.bcmproc_dir,
 						     &bcm_proc_fops, sk);
 		if (!bo->bcm_proc_read) {
 			ret = -ENOMEM;
@@ -1687,6 +1689,31 @@ static const struct can_proto bcm_can_proto = {
 	.prot       = &bcm_proto,
 };
 
+static int canbcm_pernet_init(struct net *net)
+{
+	/* create /proc/net/can-bcm directory */
+	if (IS_ENABLED(CONFIG_PROC_FS)) {
+		net->can.bcmproc_dir =
+			proc_net_mkdir(net, "can-bcm", net->proc_net);
+	}
+
+	return 0;
+}
+
+static void canbcm_pernet_exit(struct net *net)
+{
+	/* remove /proc/net/can-bcm directory */
+	if (IS_ENABLED(CONFIG_PROC_FS)) {
+		if (net->can.bcmproc_dir)
+			remove_proc_entry("can-bcm", net->proc_net);
+	}
+}
+
+static struct pernet_operations canbcm_pernet_ops __read_mostly = {
+	.init = canbcm_pernet_init,
+	.exit = canbcm_pernet_exit,
+};
+
 static int __init bcm_module_init(void)
 {
 	int err;
@@ -1699,17 +1726,14 @@ static int __init bcm_module_init(void)
 		return err;
 	}
 
-	/* create /proc/net/can-bcm directory */
-	proc_dir = proc_mkdir("can-bcm", init_net.proc_net);
+	register_pernet_subsys(&canbcm_pernet_ops);
 	return 0;
 }
 
 static void __exit bcm_module_exit(void)
 {
 	can_proto_unregister(&bcm_can_proto);
-
-	if (proc_dir)
-		remove_proc_entry("can-bcm", init_net.proc_net);
+	unregister_pernet_subsys(&canbcm_pernet_ops);
 }
 
 module_init(bcm_module_init);
-- 
2.11.0
