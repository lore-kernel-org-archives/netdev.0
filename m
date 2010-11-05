From: Urs Thuermann <urs@isnogud.escape.de>
Subject: [PATCH] Fix CAN info leak/minor heap overflow
Date: 05 Nov 2010 19:33:05 +0100
Message-ID: <ygfiq0bsjry.fsf@janus.isnogud.escape.de>
References: <1288722503.2504.14.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: socketcan@hartkopp.net, oliver.hartkopp@volkswagen.de,
	Dan Rosenberg <drosenberg@vsecurity.com>, security@kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:34584 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753316Ab0KESqz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Nov 2010 14:46:55 -0400
In-Reply-To: <1288722503.2504.14.camel@dan>; from Dan Rosenberg on Tue, 02 Nov 2010 14:28:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the leakage of kernel space addresses to userspace.
Instead, socket inode numbers are used to create unique proc file
names for CAN_BCM sockets and for referring to sockets in filter
lists.  In addition, this makes debugging easier, since inode numbers
are also shown in ls -l /proc/<pid>/fd/<fd> and lsof(8) output.

BTW, if kernel space addresses are considered security critical
information one should also take a look and possibly change

    /proc/net/{tcp,tcp6,udp,udp6,raw,raw6,unix}

and maybe some others.

The change of the procfs content leads to a new version string
20101105.

Signed-off-by: Urs Thuermann <urs@isnogud.escape.de>
Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
CC: Dan Rosenberg <drosenberg@vsecurity.com>
CC: Linus Torvalds <torvalds@linux-foundation.org>

---

diff --git a/include/linux/can/core.h b/include/linux/can/core.h
index 6c507be..e20a841 100644
--- a/include/linux/can/core.h
+++ b/include/linux/can/core.h
@@ -19,7 +19,7 @@
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 
-#define CAN_VERSION "20090105"
+#define CAN_VERSION "20101105"
 
 /* increment this number each time you change some user-space interface */
 #define CAN_ABI_VERSION "8"
diff --git a/net/can/bcm.c b/net/can/bcm.c
index 08ffe9e..0e81e04 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -86,6 +86,12 @@ MODULE_LICENSE("Dual BSD/GPL");
 MODULE_AUTHOR("Oliver Hartkopp <oliver.hartkopp@volkswagen.de>");
 MODULE_ALIAS("can-proto-2");
 
+/*
+ * Point to the sockets inode number inside the bcm ident string.
+ * We skip the string length of "bcm " (== 4) created in bcm_init().
+ */
+#define INODENUM(bo) (bo->ident + 4)
+
 /* easy access to can_frame payload */
 static inline u64 GET_U64(const struct can_frame *cp)
 {
@@ -125,7 +131,7 @@ struct bcm_sock {
 	struct list_head tx_ops;
 	unsigned long dropped_usr_msgs;
 	struct proc_dir_entry *bcm_proc_read;
-	char procname [9]; /* pointer printed in ASCII with \0 */
+	char ident[32];
 };
 
 static inline struct bcm_sock *bcm_sk(const struct sock *sk)
@@ -165,9 +171,7 @@ static int bcm_proc_show(struct seq_file *m, void *v)
 	struct bcm_sock *bo = bcm_sk(sk);
 	struct bcm_op *op;
 
-	seq_printf(m, ">>> socket %p", sk->sk_socket);
-	seq_printf(m, " / sk %p", sk);
-	seq_printf(m, " / bo %p", bo);
+	seq_printf(m, ">>> socket inode %s", INODENUM(bo));
 	seq_printf(m, " / dropped %lu", bo->dropped_usr_msgs);
 	seq_printf(m, " / bound %s", bcm_proc_getifname(ifname, bo->ifindex));
 	seq_printf(m, " <<<\n");
@@ -1168,7 +1172,7 @@ static int bcm_rx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 				err = can_rx_register(dev, op->can_id,
 						      REGMASK(op->can_id),
 						      bcm_rx_handler, op,
-						      "bcm");
+						      bo->ident);
 
 				op->rx_reg_dev = dev;
 				dev_put(dev);
@@ -1177,7 +1181,7 @@ static int bcm_rx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 		} else
 			err = can_rx_register(NULL, op->can_id,
 					      REGMASK(op->can_id),
-					      bcm_rx_handler, op, "bcm");
+					      bcm_rx_handler, op, bo->ident);
 		if (err) {
 			/* this bcm rx op is broken -> remove it */
 			list_del(&op->list);
@@ -1402,6 +1406,8 @@ static int bcm_init(struct sock *sk)
 {
 	struct bcm_sock *bo = bcm_sk(sk);
 
+	snprintf(bo->ident, sizeof(bo->ident), "bcm %lu", sock_i_ino(sk));
+
 	bo->bound            = 0;
 	bo->ifindex          = 0;
 	bo->dropped_usr_msgs = 0;
@@ -1466,7 +1472,7 @@ static int bcm_release(struct socket *sock)
 
 	/* remove procfs entry */
 	if (proc_dir && bo->bcm_proc_read)
-		remove_proc_entry(bo->procname, proc_dir);
+		remove_proc_entry(INODENUM(bo), proc_dir);
 
 	/* remove device reference */
 	if (bo->bound) {
@@ -1519,13 +1525,11 @@ static int bcm_connect(struct socket *sock, struct sockaddr *uaddr, int len,
 
 	bo->bound = 1;
 
-	if (proc_dir) {
-		/* unique socket address as filename */
-		sprintf(bo->procname, "%p", sock);
-		bo->bcm_proc_read = proc_create_data(bo->procname, 0644,
+	/* use unique socket inode number as filename */
+	if (proc_dir)
+		bo->bcm_proc_read = proc_create_data(INODENUM(bo), 0644,
 						     proc_dir,
 						     &bcm_proc_fops, sk);
-	}
 
 	return 0;
 }
diff --git a/net/can/proc.c b/net/can/proc.c
index f4265cc..15bed1c 100644
--- a/net/can/proc.c
+++ b/net/can/proc.c
@@ -204,23 +204,17 @@ static void can_print_rcvlist(struct seq_file *m, struct hlist_head *rx_list,
 
 	hlist_for_each_entry_rcu(r, n, rx_list, list) {
 		char *fmt = (r->can_id & CAN_EFF_FLAG)?
-			"   %-5s  %08X  %08x  %08x  %08x  %8ld  %s\n" :
-			"   %-5s     %03X    %08x  %08lx  %08lx  %8ld  %s\n";
+			"   %-5s  %08X  %08x  %8ld   %s\n" :
+			"   %-5s     %03X    %08x  %8ld   %s\n";
 
 		seq_printf(m, fmt, DNAME(dev), r->can_id, r->mask,
-				(unsigned long)r->func, (unsigned long)r->data,
 				r->matches, r->ident);
 	}
 }
 
 static void can_print_recv_banner(struct seq_file *m)
 {
-	/*
-	 *                  can1.  00000000  00000000  00000000
-	 *                 .......          0  tp20
-	 */
-	seq_puts(m, "  device   can_id   can_mask  function"
-			"  userdata   matches  ident\n");
+	seq_puts(m, "  device   can_id   can_mask   matches   ident\n");
 }
 
 static int can_stats_proc_show(struct seq_file *m, void *v)
diff --git a/net/can/raw.c b/net/can/raw.c
index e88f610..e057f0d 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -88,6 +88,7 @@ struct raw_sock {
 	struct can_filter dfilter; /* default/single filter */
 	struct can_filter *filter; /* pointer to filter(s) */
 	can_err_mask_t err_mask;
+	char ident[32];
 };
 
 /*
@@ -154,13 +155,14 @@ static void raw_rcv(struct sk_buff *oskb, void *data)
 static int raw_enable_filters(struct net_device *dev, struct sock *sk,
 			      struct can_filter *filter, int count)
 {
+	struct raw_sock *ro = raw_sk(sk);
 	int err = 0;
 	int i;
 
 	for (i = 0; i < count; i++) {
 		err = can_rx_register(dev, filter[i].can_id,
 				      filter[i].can_mask,
-				      raw_rcv, sk, "raw");
+				      raw_rcv, sk, ro->ident);
 		if (err) {
 			/* clean up successfully registered filters */
 			while (--i >= 0)
@@ -177,11 +179,12 @@ static int raw_enable_filters(struct net_device *dev, struct sock *sk,
 static int raw_enable_errfilter(struct net_device *dev, struct sock *sk,
 				can_err_mask_t err_mask)
 {
+	struct raw_sock *ro = raw_sk(sk);
 	int err = 0;
 
 	if (err_mask)
 		err = can_rx_register(dev, 0, err_mask | CAN_ERR_FLAG,
-				      raw_rcv, sk, "raw");
+				      raw_rcv, sk, ro->ident);
 
 	return err;
 }
@@ -281,6 +284,8 @@ static int raw_init(struct sock *sk)
 {
 	struct raw_sock *ro = raw_sk(sk);
 
+	snprintf(ro->ident, sizeof(ro->ident), "raw %lu", sock_i_ino(sk));
+
 	ro->bound            = 0;
 	ro->ifindex          = 0;
 
