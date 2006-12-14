From: Ralf Baechle <ralf@linux-mips.org>
Subject: [AX.25 1/7] Mark all kmalloc users __must_check
Date: Thu, 14 Dec 2006 23:42:07 +0100
Message-ID: <11661361331883-git-send-email-ralf@linux-mips.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-hams-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The recent fix 0506d4068bad834aab1141b5dc5e748eb175c6b3 made obvious that
error values were not being propagated through the AX.25 stack.  To help
with that this patch marks all kmalloc users in the AX.25, NETROM and
ROSE stacks as __must_check.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 include/net/ax25.h    |   11 ++++++-----
 include/net/rose.h    |    4 ++--
 net/ax25/af_ax25.c    |    4 ++--
 net/ax25/ax25_route.c |    2 +-
 net/netrom/nr_route.c |    8 +++++---
 net/rose/rose_route.c |    2 +-
 6 files changed, 17 insertions(+), 14 deletions(-)

Index: linux-net/include/net/ax25.h
===================================================================
--- linux-net.orig/include/net/ax25.h
+++ linux-net/include/net/ax25.h
@@ -277,7 +277,7 @@ struct sock *ax25_get_socket(ax25_addres
 extern ax25_cb *ax25_find_cb(ax25_address *, ax25_address *, ax25_digi *, struct net_device *);
 extern void ax25_send_to_raw(ax25_address *, struct sk_buff *, int);
 extern void ax25_destroy_socket(ax25_cb *);
-extern ax25_cb *ax25_create_cb(void);
+extern ax25_cb * __must_check ax25_create_cb(void);
 extern void ax25_fillin_cb(ax25_cb *, ax25_dev *);
 extern struct sock *ax25_make_new(struct sock *, struct ax25_dev *);
 
@@ -333,11 +333,12 @@ extern void ax25_ds_t3timer_expiry(ax25_
 extern void ax25_ds_idletimer_expiry(ax25_cb *);
 
 /* ax25_iface.c */
-extern int  ax25_protocol_register(unsigned int, int (*)(struct sk_buff *, ax25_cb *));
+extern int __must_check ax25_protocol_register(unsigned int, int (*)(struct sk_buff *, ax25_cb *));
 extern void ax25_protocol_release(unsigned int);
-extern int  ax25_linkfail_register(void (*)(ax25_cb *, int));
+extern int __must_check ax25_linkfail_register(void (*)(ax25_cb *, int));
 extern void ax25_linkfail_release(void (*)(ax25_cb *, int));
-extern int  ax25_listen_register(ax25_address *, struct net_device *);
+extern int __must_check ax25_listen_register(ax25_address *,
+	struct net_device *);
 extern void ax25_listen_release(ax25_address *, struct net_device *);
 extern int  (*ax25_protocol_function(unsigned int))(struct sk_buff *, ax25_cb *);
 extern int  ax25_listen_mine(ax25_address *, struct net_device *);
@@ -415,7 +416,7 @@ extern unsigned long ax25_display_timer(
 /* ax25_uid.c */
 extern int  ax25_uid_policy;
 extern ax25_uid_assoc *ax25_findbyuid(uid_t);
-extern int  ax25_uid_ioctl(int, struct sockaddr_ax25 *);
+extern int __must_check ax25_uid_ioctl(int, struct sockaddr_ax25 *);
 extern struct file_operations ax25_uid_fops;
 extern void ax25_uid_free(void);
 
Index: linux-net/include/net/rose.h
===================================================================
--- linux-net.orig/include/net/rose.h
+++ linux-net/include/net/rose.h
@@ -193,8 +193,8 @@ extern struct file_operations rose_neigh
 extern struct file_operations rose_nodes_fops;
 extern struct file_operations rose_routes_fops;
 
-extern int  rose_add_loopback_neigh(void);
-extern int  rose_add_loopback_node(rose_address *);
+extern int __must_check rose_add_loopback_neigh(void);
+extern int __must_check rose_add_loopback_node(rose_address *);
 extern void rose_del_loopback_node(rose_address *);
 extern void rose_rt_device_down(struct net_device *);
 extern void rose_link_device_down(struct net_device *);
Index: linux-net/net/ax25/af_ax25.c
===================================================================
--- linux-net.orig/net/ax25/af_ax25.c
+++ linux-net/net/ax25/af_ax25.c
@@ -1088,8 +1088,8 @@ out:
 /*
  *	FIXME: nonblock behaviour looks like it may have a bug.
  */
-static int ax25_connect(struct socket *sock, struct sockaddr *uaddr,
-	int addr_len, int flags)
+static int __must_check ax25_connect(struct socket *sock,
+	struct sockaddr *uaddr, int addr_len, int flags)
 {
 	struct sock *sk = sock->sk;
 	ax25_cb *ax25 = ax25_sk(sk), *ax25t;
Index: linux-net/net/ax25/ax25_route.c
===================================================================
--- linux-net.orig/net/ax25/ax25_route.c
+++ linux-net/net/ax25/ax25_route.c
@@ -71,7 +71,7 @@ void ax25_rt_device_down(struct net_devi
 	write_unlock(&ax25_route_lock);
 }
 
-static int ax25_rt_add(struct ax25_routes_struct *route)
+static int __must_check ax25_rt_add(struct ax25_routes_struct *route)
 {
 	ax25_route *ax25_rt;
 	ax25_dev *ax25_dev;
Index: linux-net/net/rose/rose_route.c
===================================================================
--- linux-net.orig/net/rose/rose_route.c
+++ linux-net/net/rose/rose_route.c
@@ -52,7 +52,7 @@ struct rose_neigh *rose_loopback_neigh;
  *	Add a new route to a node, and in the process add the node and the
  *	neighbour if it is new.
  */
-static int rose_add_node(struct rose_route_struct *rose_route,
+static int __must_check rose_add_node(struct rose_route_struct *rose_route,
 	struct net_device *dev)
 {
 	struct rose_node  *rose_node, *rose_tmpn, *rose_tmpp;
Index: linux-net/net/netrom/nr_route.c
===================================================================
--- linux-net.orig/net/netrom/nr_route.c
+++ linux-net/net/netrom/nr_route.c
@@ -87,8 +87,9 @@ static void nr_remove_neigh(struct nr_ne
  *	Add a new route to a node, and in the process add the node and the
  *	neighbour if it is new.
  */
-static int nr_add_node(ax25_address *nr, const char *mnemonic, ax25_address *ax25,
-	ax25_digi *ax25_digi, struct net_device *dev, int quality, int obs_count)
+static int __must_check nr_add_node(ax25_address *nr, const char *mnemonic,
+	ax25_address *ax25, ax25_digi *ax25_digi, struct net_device *dev,
+	int quality, int obs_count)
 {
 	struct nr_node  *nr_node;
 	struct nr_neigh *nr_neigh;
@@ -406,7 +407,8 @@ static int nr_del_node(ax25_address *cal
 /*
  *	Lock a neighbour with a quality.
  */
-static int nr_add_neigh(ax25_address *callsign, ax25_digi *ax25_digi, struct net_device *dev, unsigned int quality)
+static int __must_check nr_add_neigh(ax25_address *callsign,
+	ax25_digi *ax25_digi, struct net_device *dev, unsigned int quality)
 {
 	struct nr_neigh *nr_neigh;
 
