From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] AX.25 UID fixes
Date: Mon, 22 Aug 2005 12:10:38 +0100
Message-ID: <20050822111038.GA7545@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hams@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@linux-mips.org
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 o Brown paperbag bug - ax25_findbyuid() was always returning a NULL pointer
   as the result.  Breaks ROSE completly and AX.25 if UID policy set to deny.

 o While the list structure of AX.25's UID to callsign mapping table was
   properly protected by a spinlock, it's elements were not refcounted
   resulting in a race between removal and usage of an element.

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

 include/net/ax25.h     |   18 +++++++++-
 net/ax25/af_ax25.c     |   20 +++++++----
 net/ax25/ax25_route.c  |   12 ++++---
 net/ax25/ax25_uid.c    |   83 +++++++++++++++++++++----------------------------
 net/netrom/af_netrom.c |   24 +++++++++-----
 net/rose/af_rose.c     |   20 +++++++----
 6 files changed, 100 insertions(+), 77 deletions(-)

Index: linux-cvs/include/net/ax25.h
===================================================================
--- linux-cvs.orig/include/net/ax25.h
+++ linux-cvs/include/net/ax25.h
@@ -148,11 +148,25 @@ enum {
 #define AX25_DEF_DS_TIMEOUT	180000			/* DAMA timeout 3 minutes */
 
 typedef struct ax25_uid_assoc {
-	struct ax25_uid_assoc	*next;
+	struct hlist_node	uid_node;
+	atomic_t		refcount;
 	uid_t			uid;
 	ax25_address		call;
 } ax25_uid_assoc;
 
+#define ax25_uid_for_each(__ax25, node, list) \
+	hlist_for_each_entry(__ax25, node, list, uid_node)
+
+#define ax25_uid_hold(ax25) \
+	atomic_inc(&((ax25)->refcount))
+
+static inline void ax25_uid_put(ax25_uid_assoc *assoc)
+{
+	if (atomic_dec_and_test(&assoc->refcount)) {
+		kfree(assoc);
+	}
+}
+
 typedef struct {
 	ax25_address		calls[AX25_MAX_DIGIS];
 	unsigned char		repeated[AX25_MAX_DIGIS];
@@ -386,7 +400,7 @@ extern unsigned long ax25_display_timer(
 
 /* ax25_uid.c */
 extern int  ax25_uid_policy;
-extern ax25_address *ax25_findbyuid(uid_t);
+extern ax25_uid_assoc *ax25_findbyuid(uid_t);
 extern int  ax25_uid_ioctl(int, struct sockaddr_ax25 *);
 extern struct file_operations ax25_uid_fops;
 extern void ax25_uid_free(void);
Index: linux-cvs/net/ax25/ax25_route.c
===================================================================
--- linux-cvs.orig/net/ax25/ax25_route.c
+++ linux-cvs/net/ax25/ax25_route.c
@@ -422,8 +422,8 @@ static inline void ax25_adjust_path(ax25
  */
 int ax25_rt_autobind(ax25_cb *ax25, ax25_address *addr)
 {
+	ax25_uid_assoc *user;
 	ax25_route *ax25_rt;
-	ax25_address *call;
 	int err;
 
 	if ((ax25_rt = ax25_get_route(addr, NULL)) == NULL)
@@ -434,16 +434,18 @@ int ax25_rt_autobind(ax25_cb *ax25, ax25
 		goto put;
 	}
 
-	if ((call = ax25_findbyuid(current->euid)) == NULL) {
+	user = ax25_findbyuid(current->euid);
+	if (user) {
+		ax25->source_addr = user->call;
+		ax25_uid_put(user);
+	} else {
 		if (ax25_uid_policy && !capable(CAP_NET_BIND_SERVICE)) {
 			err = -EPERM;
 			goto put;
 		}
-		call = (ax25_address *)ax25->ax25_dev->dev->dev_addr;
+		ax25->source_addr = *(ax25_address *)ax25->ax25_dev->dev->dev_addr;
 	}
 
-	ax25->source_addr = *call;
-
 	if (ax25_rt->digipeat != NULL) {
 		if ((ax25->digipeat = kmalloc(sizeof(ax25_digi), GFP_ATOMIC)) == NULL) {
 			err = -ENOMEM;
Index: linux-cvs/net/ax25/ax25_uid.c
===================================================================
--- linux-cvs.orig/net/ax25/ax25_uid.c
+++ linux-cvs/net/ax25/ax25_uid.c
@@ -28,6 +28,7 @@
 #include <linux/fcntl.h>
 #include <linux/mm.h>
 #include <linux/interrupt.h>
+#include <linux/list.h>
 #include <linux/notifier.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
@@ -41,38 +42,41 @@
  *	Callsign/UID mapper. This is in kernel space for security on multi-amateur machines.
  */
 
-static ax25_uid_assoc *ax25_uid_list;
+HLIST_HEAD(ax25_uid_list);
 static DEFINE_RWLOCK(ax25_uid_lock);
 
 int ax25_uid_policy = 0;
 
-ax25_address *ax25_findbyuid(uid_t uid)
+ax25_uid_assoc *ax25_findbyuid(uid_t uid)
 {
-	ax25_uid_assoc *ax25_uid;
-	ax25_address *res = NULL;
+	ax25_uid_assoc *ax25_uid, *res = NULL;
+	struct hlist_node *node;
 
 	read_lock(&ax25_uid_lock);
-	for (ax25_uid = ax25_uid_list; ax25_uid != NULL; ax25_uid = ax25_uid->next) {
+	ax25_uid_for_each(ax25_uid, node, &ax25_uid_list) {
 		if (ax25_uid->uid == uid) {
-			res = &ax25_uid->call;
+			ax25_uid_hold(ax25_uid);
+			res = ax25_uid;
 			break;
 		}
 	}
 	read_unlock(&ax25_uid_lock);
 
-	return NULL;
+	return res;
 }
 
 int ax25_uid_ioctl(int cmd, struct sockaddr_ax25 *sax)
 {
-	ax25_uid_assoc *s, *ax25_uid;
+	ax25_uid_assoc *ax25_uid;
+	struct hlist_node *node;
+	ax25_uid_assoc *user;
 	unsigned long res;
 
 	switch (cmd) {
 	case SIOCAX25GETUID:
 		res = -ENOENT;
 		read_lock(&ax25_uid_lock);
-		for (ax25_uid = ax25_uid_list; ax25_uid != NULL; ax25_uid = ax25_uid->next) {
+		ax25_uid_for_each(ax25_uid, node, &ax25_uid_list) {
 			if (ax25cmp(&sax->sax25_call, &ax25_uid->call) == 0) {
 				res = ax25_uid->uid;
 				break;
@@ -85,19 +89,22 @@ int ax25_uid_ioctl(int cmd, struct socka
 	case SIOCAX25ADDUID:
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
-		if (ax25_findbyuid(sax->sax25_uid))
+		user = ax25_findbyuid(sax->sax25_uid);
+		if (user) {
+			ax25_uid_put(user);
 			return -EEXIST;
+		}
 		if (sax->sax25_uid == 0)
 			return -EINVAL;
 		if ((ax25_uid = kmalloc(sizeof(*ax25_uid), GFP_KERNEL)) == NULL)
 			return -ENOMEM;
 
+		atomic_set(&ax25_uid->refcount, 1);
 		ax25_uid->uid  = sax->sax25_uid;
 		ax25_uid->call = sax->sax25_call;
 
 		write_lock(&ax25_uid_lock);
-		ax25_uid->next = ax25_uid_list;
-		ax25_uid_list  = ax25_uid;
+		hlist_add_head(&ax25_uid->uid_node, &ax25_uid_list);
 		write_unlock(&ax25_uid_lock);
 
 		return 0;
@@ -106,34 +113,21 @@ int ax25_uid_ioctl(int cmd, struct socka
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
+		ax25_uid = NULL;
 		write_lock(&ax25_uid_lock);
-		for (ax25_uid = ax25_uid_list; ax25_uid != NULL; ax25_uid = ax25_uid->next) {
-			if (ax25cmp(&sax->sax25_call, &ax25_uid->call) == 0) {
+		ax25_uid_for_each(ax25_uid, node, &ax25_uid_list) {
+			if (ax25cmp(&sax->sax25_call, &ax25_uid->call) == 0)
 				break;
-			}
 		}
 		if (ax25_uid == NULL) {
 			write_unlock(&ax25_uid_lock);
 			return -ENOENT;
 		}
-		if ((s = ax25_uid_list) == ax25_uid) {
-			ax25_uid_list = s->next;
-			write_unlock(&ax25_uid_lock);
-			kfree(ax25_uid);
-			return 0;
-		}
-		while (s != NULL && s->next != NULL) {
-			if (s->next == ax25_uid) {
-				s->next = ax25_uid->next;
-				write_unlock(&ax25_uid_lock);
-				kfree(ax25_uid);
-				return 0;
-			}
-			s = s->next;
-		}
+		hlist_del_init(&ax25_uid->uid_node);
+		ax25_uid_put(ax25_uid);
 		write_unlock(&ax25_uid_lock);
 
-		return -ENOENT;
+		return 0;
 
 	default:
 		return -EINVAL;
@@ -147,13 +141,11 @@ int ax25_uid_ioctl(int cmd, struct socka
 static void *ax25_uid_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	struct ax25_uid_assoc *pt;
-	int i = 1;
+	struct hlist_node *node;
+	int i = 0;
 
 	read_lock(&ax25_uid_lock);
-	if (*pos == 0)
-		return SEQ_START_TOKEN;
-
-	for (pt = ax25_uid_list; pt != NULL; pt = pt->next) {
+	ax25_uid_for_each(pt, node, &ax25_uid_list) {
 		if (i == *pos)
 			return pt;
 		++i;
@@ -164,8 +156,9 @@ static void *ax25_uid_seq_start(struct s
 static void *ax25_uid_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	++*pos;
-	return (v == SEQ_START_TOKEN) ? ax25_uid_list : 
-		((struct ax25_uid_assoc *) v)->next;
+
+	return hlist_entry(((ax25_uid_assoc *)v)->uid_node.next,
+	                   ax25_uid_assoc, uid_node);
 }
 
 static void ax25_uid_seq_stop(struct seq_file *seq, void *v)
@@ -179,7 +172,6 @@ static int ax25_uid_seq_show(struct seq_
 		seq_printf(seq, "Policy: %d\n", ax25_uid_policy);
 	else {
 		struct ax25_uid_assoc *pt = v;
-		
 
 		seq_printf(seq, "%6d %s\n", pt->uid, ax2asc(&pt->call));
 	}
@@ -213,16 +205,13 @@ struct file_operations ax25_uid_fops = {
  */
 void __exit ax25_uid_free(void)
 {
-	ax25_uid_assoc *s, *ax25_uid;
+	ax25_uid_assoc *ax25_uid;
+	struct hlist_node *node;
 
 	write_lock(&ax25_uid_lock);
-	ax25_uid = ax25_uid_list;
-	while (ax25_uid != NULL) {
-		s        = ax25_uid;
-		ax25_uid = ax25_uid->next;
-
-		kfree(s);
+	ax25_uid_for_each(ax25_uid, node, &ax25_uid_list) {
+		hlist_del_init(&ax25_uid->uid_node);
+		ax25_uid_put(ax25_uid);
 	}
-	ax25_uid_list = NULL;
 	write_unlock(&ax25_uid_lock);
 }
Index: linux-cvs/net/netrom/af_netrom.c
===================================================================
--- linux-cvs.orig/net/netrom/af_netrom.c
+++ linux-cvs/net/netrom/af_netrom.c
@@ -542,7 +542,8 @@ static int nr_bind(struct socket *sock, 
 	struct nr_sock *nr = nr_sk(sk);
 	struct full_sockaddr_ax25 *addr = (struct full_sockaddr_ax25 *)uaddr;
 	struct net_device *dev;
-	ax25_address *user, *source;
+	ax25_uid_assoc *user;
+	ax25_address *source;
 
 	lock_sock(sk);
 	if (!sock_flag(sk, SOCK_ZAPPED)) {
@@ -581,16 +582,19 @@ static int nr_bind(struct socket *sock, 
 	} else {
 		source = &addr->fsa_ax25.sax25_call;
 
-		if ((user = ax25_findbyuid(current->euid)) == NULL) {
+		user = ax25_findbyuid(current->euid);
+		if (user) {
+			nr->user_addr   = user->call;
+			ax25_uid_put(user);
+		} else {
 			if (ax25_uid_policy && !capable(CAP_NET_BIND_SERVICE)) {
 				release_sock(sk);
 				dev_put(dev);
 				return -EPERM;
 			}
-			user = source;
+			nr->user_addr   = *source;
 		}
 
-		nr->user_addr   = *user;
 		nr->source_addr = *source;
 	}
 
@@ -610,7 +614,8 @@ static int nr_connect(struct socket *soc
 	struct sock *sk = sock->sk;
 	struct nr_sock *nr = nr_sk(sk);
 	struct sockaddr_ax25 *addr = (struct sockaddr_ax25 *)uaddr;
-	ax25_address *user, *source = NULL;
+	ax25_address *source = NULL;
+	ax25_uid_assoc *user;
 	struct net_device *dev;
 
 	lock_sock(sk);
@@ -651,16 +656,19 @@ static int nr_connect(struct socket *soc
 		}
 		source = (ax25_address *)dev->dev_addr;
 
-		if ((user = ax25_findbyuid(current->euid)) == NULL) {
+		user = ax25_findbyuid(current->euid);
+		if (user) {
+			nr->user_addr   = user->call;
+			ax25_uid_put(user);
+		} else {
 			if (ax25_uid_policy && !capable(CAP_NET_ADMIN)) {
 				dev_put(dev);
 				release_sock(sk);
 				return -EPERM;
 			}
-			user = source;
+			nr->user_addr   = *source;
 		}
 
-		nr->user_addr   = *user;
 		nr->source_addr = *source;
 		nr->device      = dev;
 
Index: linux-cvs/net/rose/af_rose.c
===================================================================
--- linux-cvs.orig/net/rose/af_rose.c
+++ linux-cvs/net/rose/af_rose.c
@@ -626,7 +626,8 @@ static int rose_bind(struct socket *sock
 	struct rose_sock *rose = rose_sk(sk);
 	struct sockaddr_rose *addr = (struct sockaddr_rose *)uaddr;
 	struct net_device *dev;
-	ax25_address *user, *source;
+	ax25_address *source;
+	ax25_uid_assoc *user;
 	int n;
 
 	if (!sock_flag(sk, SOCK_ZAPPED))
@@ -651,14 +652,17 @@ static int rose_bind(struct socket *sock
 
 	source = &addr->srose_call;
 
-	if ((user = ax25_findbyuid(current->euid)) == NULL) {
+	user = ax25_findbyuid(current->euid);
+	if (user) {
+		rose->source_call = user->call;
+		ax25_uid_put(user);
+	} else {
 		if (ax25_uid_policy && !capable(CAP_NET_BIND_SERVICE))
 			return -EACCES;
-		user = source;
+		rose->source_call   = *source;
 	}
 
 	rose->source_addr   = addr->srose_addr;
-	rose->source_call   = *user;
 	rose->device        = dev;
 	rose->source_ndigis = addr->srose_ndigis;
 
@@ -685,8 +689,8 @@ static int rose_connect(struct socket *s
 	struct rose_sock *rose = rose_sk(sk);
 	struct sockaddr_rose *addr = (struct sockaddr_rose *)uaddr;
 	unsigned char cause, diagnostic;
-	ax25_address *user;
 	struct net_device *dev;
+	ax25_uid_assoc *user;
 	int n;
 
 	if (sk->sk_state == TCP_ESTABLISHED && sock->state == SS_CONNECTING) {
@@ -736,12 +740,14 @@ static int rose_connect(struct socket *s
 		if ((dev = rose_dev_first()) == NULL)
 			return -ENETUNREACH;
 
-		if ((user = ax25_findbyuid(current->euid)) == NULL)
+		user = ax25_findbyuid(current->euid);
+		if (!user)
 			return -EINVAL;
 
 		memcpy(&rose->source_addr, dev->dev_addr, ROSE_ADDR_LEN);
-		rose->source_call = *user;
+		rose->source_call = user->call;
 		rose->device      = dev;
+		ax25_uid_put(user);
 
 		rose_insert_socket(sk);		/* Finish the bind */
 	}
Index: linux-cvs/net/ax25/af_ax25.c
===================================================================
--- linux-cvs.orig/net/ax25/af_ax25.c
+++ linux-cvs/net/ax25/af_ax25.c
@@ -1011,7 +1011,8 @@ static int ax25_bind(struct socket *sock
 	struct sock *sk = sock->sk;
 	struct full_sockaddr_ax25 *addr = (struct full_sockaddr_ax25 *)uaddr;
 	ax25_dev *ax25_dev = NULL;
-	ax25_address *call;
+	ax25_uid_assoc *user;
+	ax25_address call;
 	ax25_cb *ax25;
 	int err = 0;
 
@@ -1030,9 +1031,15 @@ static int ax25_bind(struct socket *sock
 	if (addr->fsa_ax25.sax25_family != AF_AX25)
 		return -EINVAL;
 
-	call = ax25_findbyuid(current->euid);
-	if (call == NULL && ax25_uid_policy && !capable(CAP_NET_ADMIN)) {
-		return -EACCES;
+	user = ax25_findbyuid(current->euid);
+	if (user) {
+		call = user->call;
+		ax25_uid_put(user);
+	} else {
+		if (ax25_uid_policy && !capable(CAP_NET_ADMIN))
+			return -EACCES;
+
+		call = addr->fsa_ax25.sax25_call;
 	}
 
 	lock_sock(sk);
@@ -1043,10 +1050,7 @@ static int ax25_bind(struct socket *sock
 		goto out;
 	}
 
-	if (call == NULL)
-		ax25->source_addr = addr->fsa_ax25.sax25_call;
-	else
-		ax25->source_addr = *call;
+	ax25->source_addr = call;
 
 	/*
 	 * User already set interface with SO_BINDTODEVICE
