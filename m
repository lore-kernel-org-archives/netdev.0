From: Ralf Baechle <ralf@linux-mips.org>
Subject: [AX.25 1/2] Introduce struct ax25_sock.
Date: Fri, 21 Jul 2006 11:29:46 -0400
Message-ID: <20060721152946.GA16317@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:23185 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S1750875AbWGUPaE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jul 2006 11:30:04 -0400
Received: from localhost.localdomain ([127.0.0.1]:42371 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S8133899AbWGUPaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2006 16:30:01 +0100
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Upto now AX.25 was using two separate structures for it's sockets.  One=
,
ax25_cb described the entire actual AX.25 connection.  The other was
the standard struct sock.

This patch combines both into struct ax25_sock which is more in line wi=
th
current practice.  An AX.25 speciality was that a ax25_cb could exist
without a struct sock referencing it.  Keep that alive for now by keepi=
ng
the old struct sock *sk member of ax25_cb in struct ax25_sock.  This no=
w
just has become a struct-internal pointer.

Aside of wanrouter AX.25 has also been the last member of struct
sock.sk_protinfo.  With net/wanrouter being considered hopeless code an=
d
an application-level solution being prefered these days this means we n=
ow
can delete sk_protinfo.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 include/net/ax25.h        |  144 +++++++++++++++++--------------------=
-
 include/net/netrom.h      |    6 -
 include/net/rose.h        |    6 -
 net/ax25/af_ax25.c        |  173 ++++++++++++++++++++-----------------=
---------
 net/ax25/ax25_ds_in.c     |    8 +-
 net/ax25/ax25_ds_subr.c   |   14 +--
 net/ax25/ax25_ds_timer.c  |   10 +-
 net/ax25/ax25_iface.c     |   16 ++--
 net/ax25/ax25_in.c        |   15 ++-
 net/ax25/ax25_ip.c        |    4 -
 net/ax25/ax25_out.c       |   19 ++---
 net/ax25/ax25_route.c     |    2=20
 net/ax25/ax25_std_in.c    |   10 +-
 net/ax25/ax25_std_subr.c  |   10 +-
 net/ax25/ax25_std_timer.c |   10 +-
 net/ax25/ax25_subr.c      |   18 ++--
 net/ax25/ax25_timer.c     |   32 ++++----
 net/netrom/nr_route.c     |   14 +--
 net/rose/rose_route.c     |    4 -
 19 files changed, 243 insertions(+), 272 deletions(-)

Index: linux-net/include/net/ax25.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-net.orig/include/net/ax25.h	2006-07-14 01:22:39.000000000 +01=
00
+++ linux-net/include/net/ax25.h	2006-07-14 01:25:20.000000000 +0100
@@ -10,6 +10,7 @@
 #include <linux/spinlock.h>
 #include <linux/timer.h>
 #include <linux/list.h>
+#include <net/sock.h>
 #include <asm/atomic.h>
=20
 #define	AX25_T1CLAMPLO  		1
@@ -221,8 +222,9 @@ typedef struct ax25_dev {
 #endif
 } ax25_dev;
=20
-typedef struct ax25_cb {
-	struct hlist_node	ax25_node;
+struct ax25_sock {
+	/* Struct sock has to be the first member of ax25_sock */
+	struct sock		sock;
 	ax25_address		source_addr, dest_addr;
 	ax25_digi		*digipeat;
 	ax25_dev		*ax25_dev;
@@ -241,24 +243,12 @@ typedef struct ax25_cb {
 	unsigned char		window;
 	struct timer_list	timer, dtimer;
 	struct sock		*sk;		/* Backlink to socket */
-	atomic_t		refcount;
-} ax25_cb;
-
-#define ax25_sk(__sk) ((ax25_cb *)(__sk)->sk_protinfo)
-
-#define ax25_for_each(__ax25, node, list) \
-	hlist_for_each_entry(__ax25, node, list, ax25_node)
+};
=20
-#define ax25_cb_hold(__ax25) \
-	atomic_inc(&((__ax25)->refcount))
+#define ax25_sk(sk) ((struct ax25_sock *)(sk))
=20
-static __inline__ void ax25_cb_put(ax25_cb *ax25)
-{
-	if (atomic_dec_and_test(&ax25->refcount)) {
-		kfree(ax25->digipeat);
-		kfree(ax25);
-	}
-}
+#define ax25_for_each(ax25, node, list) \
+	hlist_for_each_entry(ax25, node, list, sock.sk_node)
=20
 static inline __be16 ax25_type_trans(struct sk_buff *skb, struct net_d=
evice *dev)
 {
@@ -271,14 +261,14 @@ static inline __be16 ax25_type_trans(str
 /* af_ax25.c */
 extern struct hlist_head ax25_list;
 extern spinlock_t ax25_list_lock;
-extern void ax25_cb_add(ax25_cb *);
+extern void ax25_cb_add(struct ax25_sock *);
 struct sock *ax25_find_listener(ax25_address *, int, struct net_device=
 *, int);
 struct sock *ax25_get_socket(ax25_address *, ax25_address *, int);
-extern ax25_cb *ax25_find_cb(ax25_address *, ax25_address *, ax25_digi=
 *, struct net_device *);
+extern struct ax25_sock *ax25_find_cb(ax25_address *, ax25_address *, =
ax25_digi *, struct net_device *);
 extern void ax25_send_to_raw(ax25_address *, struct sk_buff *, int);
-extern void ax25_destroy_socket(ax25_cb *);
-extern ax25_cb *ax25_create_cb(void);
-extern void ax25_fillin_cb(ax25_cb *, ax25_dev *);
+extern void ax25_destroy_socket(struct ax25_sock *);
+extern struct ax25_sock *ax25_alloc_sock(struct socket *sock);
+extern void ax25_fillin_cb(struct ax25_sock *, ax25_dev *);
 extern struct sock *ax25_make_new(struct sock *, struct ax25_dev *);
=20
 /* ax25_addr.c */
@@ -309,39 +299,39 @@ extern struct net_device *ax25_fwd_dev(s
 extern void ax25_dev_free(void);
=20
 /* ax25_ds_in.c */
-extern int  ax25_ds_frame_in(ax25_cb *, struct sk_buff *, int);
+extern int  ax25_ds_frame_in(struct ax25_sock *, struct sk_buff *, int=
);
=20
 /* ax25_ds_subr.c */
-extern void ax25_ds_nr_error_recovery(ax25_cb *);
-extern void ax25_ds_enquiry_response(ax25_cb *);
-extern void ax25_ds_establish_data_link(ax25_cb *);
+extern void ax25_ds_nr_error_recovery(struct ax25_sock *);
+extern void ax25_ds_enquiry_response(struct ax25_sock *);
+extern void ax25_ds_establish_data_link(struct ax25_sock *);
 extern void ax25_dev_dama_off(ax25_dev *);
-extern void ax25_dama_on(ax25_cb *);
-extern void ax25_dama_off(ax25_cb *);
+extern void ax25_dama_on(struct ax25_sock *);
+extern void ax25_dama_off(struct ax25_sock *);
=20
 /* ax25_ds_timer.c */
 extern void ax25_ds_set_timer(ax25_dev *);
 extern void ax25_ds_del_timer(ax25_dev *);
-extern void ax25_ds_timer(ax25_cb *);
-extern void ax25_ds_t1_timeout(ax25_cb *);
-extern void ax25_ds_heartbeat_expiry(ax25_cb *);
-extern void ax25_ds_t3timer_expiry(ax25_cb *);
-extern void ax25_ds_idletimer_expiry(ax25_cb *);
+extern void ax25_ds_timer(struct ax25_sock *);
+extern void ax25_ds_t1_timeout(struct ax25_sock *);
+extern void ax25_ds_heartbeat_expiry(struct ax25_sock *);
+extern void ax25_ds_t3timer_expiry(struct ax25_sock *);
+extern void ax25_ds_idletimer_expiry(struct ax25_sock *);
=20
 /* ax25_iface.c */
-extern int  ax25_protocol_register(unsigned int, int (*)(struct sk_buf=
f *, ax25_cb *));
+extern int  ax25_protocol_register(unsigned int, int (*)(struct sk_buf=
f *, struct ax25_sock *));
 extern void ax25_protocol_release(unsigned int);
-extern int  ax25_linkfail_register(void (*)(ax25_cb *, int));
-extern void ax25_linkfail_release(void (*)(ax25_cb *, int));
+extern int  ax25_linkfail_register(void (*)(struct ax25_sock *, int));
+extern void ax25_linkfail_release(void (*)(struct ax25_sock *, int));
 extern int  ax25_listen_register(ax25_address *, struct net_device *);
 extern void ax25_listen_release(ax25_address *, struct net_device *);
-extern int  (*ax25_protocol_function(unsigned int))(struct sk_buff *, =
ax25_cb *);
+extern int  (*ax25_protocol_function(unsigned int))(struct sk_buff *, =
struct ax25_sock *);
 extern int  ax25_listen_mine(ax25_address *, struct net_device *);
-extern void ax25_link_failed(ax25_cb *, int);
+extern void ax25_link_failed(struct ax25_sock *, int);
 extern int  ax25_protocol_is_registered(unsigned int);
=20
 /* ax25_in.c */
-extern int  ax25_rx_iframe(ax25_cb *, struct sk_buff *);
+extern int  ax25_rx_iframe(struct ax25_sock *, struct sk_buff *);
 extern int  ax25_kiss_rcv(struct sk_buff *, struct net_device *, struc=
t packet_type *, struct net_device *);
=20
 /* ax25_ip.c */
@@ -349,63 +339,63 @@ extern int  ax25_hard_header(struct sk_b
 extern int  ax25_rebuild_header(struct sk_buff *);
=20
 /* ax25_out.c */
-extern ax25_cb *ax25_send_frame(struct sk_buff *, int, ax25_address *,=
 ax25_address *, ax25_digi *, struct net_device *);
-extern void ax25_output(ax25_cb *, int, struct sk_buff *);
-extern void ax25_kick(ax25_cb *);
-extern void ax25_transmit_buffer(ax25_cb *, struct sk_buff *, int);
+extern struct ax25_sock *ax25_send_frame(struct sk_buff *, int, ax25_a=
ddress *, ax25_address *, ax25_digi *, struct net_device *);
+extern void ax25_output(struct ax25_sock *, int, struct sk_buff *);
+extern void ax25_kick(struct ax25_sock *);
+extern void ax25_transmit_buffer(struct ax25_sock *, struct sk_buff *,=
 int);
 extern void ax25_queue_xmit(struct sk_buff *skb, struct net_device *de=
v);
-extern int  ax25_check_iframes_acked(ax25_cb *, unsigned short);
+extern int  ax25_check_iframes_acked(struct ax25_sock *, unsigned shor=
t);
=20
 /* ax25_route.c */
 extern void ax25_rt_device_down(struct net_device *);
 extern int  ax25_rt_ioctl(unsigned int, void __user *);
 extern struct file_operations ax25_route_fops;
 extern ax25_route *ax25_get_route(ax25_address *addr, struct net_devic=
e *dev);
-extern int  ax25_rt_autobind(ax25_cb *, ax25_address *);
+extern int  ax25_rt_autobind(struct ax25_sock *, ax25_address *);
 extern struct sk_buff *ax25_rt_build_path(struct sk_buff *, ax25_addre=
ss *, ax25_address *, ax25_digi *);
 extern void ax25_rt_free(void);
=20
 /* ax25_std_in.c */
-extern int  ax25_std_frame_in(ax25_cb *, struct sk_buff *, int);
+extern int  ax25_std_frame_in(struct ax25_sock *, struct sk_buff *, in=
t);
=20
 /* ax25_std_subr.c */
-extern void ax25_std_nr_error_recovery(ax25_cb *);
-extern void ax25_std_establish_data_link(ax25_cb *);
-extern void ax25_std_transmit_enquiry(ax25_cb *);
-extern void ax25_std_enquiry_response(ax25_cb *);
-extern void ax25_std_timeout_response(ax25_cb *);
+extern void ax25_std_nr_error_recovery(struct ax25_sock *);
+extern void ax25_std_establish_data_link(struct ax25_sock *);
+extern void ax25_std_transmit_enquiry(struct ax25_sock *);
+extern void ax25_std_enquiry_response(struct ax25_sock *);
+extern void ax25_std_timeout_response(struct ax25_sock *);
=20
 /* ax25_std_timer.c */
-extern void ax25_std_heartbeat_expiry(ax25_cb *);
-extern void ax25_std_t1timer_expiry(ax25_cb *);
-extern void ax25_std_t2timer_expiry(ax25_cb *);
-extern void ax25_std_t3timer_expiry(ax25_cb *);
-extern void ax25_std_idletimer_expiry(ax25_cb *);
+extern void ax25_std_heartbeat_expiry(struct ax25_sock *);
+extern void ax25_std_t1timer_expiry(struct ax25_sock *);
+extern void ax25_std_t2timer_expiry(struct ax25_sock *);
+extern void ax25_std_t3timer_expiry(struct ax25_sock *);
+extern void ax25_std_idletimer_expiry(struct ax25_sock *);
=20
 /* ax25_subr.c */
-extern void ax25_clear_queues(ax25_cb *);
-extern void ax25_frames_acked(ax25_cb *, unsigned short);
-extern void ax25_requeue_frames(ax25_cb *);
-extern int  ax25_validate_nr(ax25_cb *, unsigned short);
-extern int  ax25_decode(ax25_cb *, struct sk_buff *, int *, int *, int=
 *);
-extern void ax25_send_control(ax25_cb *, int, int, int);
+extern void ax25_clear_queues(struct ax25_sock *);
+extern void ax25_frames_acked(struct ax25_sock *, unsigned short);
+extern void ax25_requeue_frames(struct ax25_sock *);
+extern int  ax25_validate_nr(struct ax25_sock *, unsigned short);
+extern int  ax25_decode(struct ax25_sock *, struct sk_buff *, int *, i=
nt *, int *);
+extern void ax25_send_control(struct ax25_sock *, int, int, int);
 extern void ax25_return_dm(struct net_device *, ax25_address *, ax25_a=
ddress *, ax25_digi *);
-extern void ax25_calculate_t1(ax25_cb *);
-extern void ax25_calculate_rtt(ax25_cb *);
-extern void ax25_disconnect(ax25_cb *, int);
+extern void ax25_calculate_t1(struct ax25_sock *);
+extern void ax25_calculate_rtt(struct ax25_sock *);
+extern void ax25_disconnect(struct ax25_sock *, int);
=20
 /* ax25_timer.c */
-extern void ax25_start_heartbeat(ax25_cb *);
-extern void ax25_start_t1timer(ax25_cb *);
-extern void ax25_start_t2timer(ax25_cb *);
-extern void ax25_start_t3timer(ax25_cb *);
-extern void ax25_start_idletimer(ax25_cb *);
-extern void ax25_stop_heartbeat(ax25_cb *);
-extern void ax25_stop_t1timer(ax25_cb *);
-extern void ax25_stop_t2timer(ax25_cb *);
-extern void ax25_stop_t3timer(ax25_cb *);
-extern void ax25_stop_idletimer(ax25_cb *);
-extern int  ax25_t1timer_running(ax25_cb *);
+extern void ax25_start_heartbeat(struct ax25_sock *);
+extern void ax25_start_t1timer(struct ax25_sock *);
+extern void ax25_start_t2timer(struct ax25_sock *);
+extern void ax25_start_t3timer(struct ax25_sock *);
+extern void ax25_start_idletimer(struct ax25_sock *);
+extern void ax25_stop_heartbeat(struct ax25_sock *);
+extern void ax25_stop_t1timer(struct ax25_sock *);
+extern void ax25_stop_t2timer(struct ax25_sock *);
+extern void ax25_stop_t3timer(struct ax25_sock *);
+extern void ax25_stop_idletimer(struct ax25_sock *);
+extern int  ax25_t1timer_running(struct ax25_sock *);
 extern unsigned long ax25_display_timer(struct timer_list *);
=20
 /* ax25_uid.c */
Index: linux-net/include/net/netrom.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-net.orig/include/net/netrom.h	2006-07-14 01:22:39.000000000 +=
0100
+++ linux-net/include/net/netrom.h	2006-07-14 01:25:20.000000000 +0100
@@ -89,7 +89,7 @@ struct nr_neigh {
 	struct hlist_node	neigh_node;
 	ax25_address		callsign;
 	ax25_digi		*digipeat;
-	ax25_cb			*ax25;
+	struct ax25_sock			*ax25;
 	struct net_device	*dev;
 	unsigned char		quality;
 	unsigned char		locked;
@@ -213,8 +213,8 @@ extern void nr_rt_device_down(struct net
 extern struct net_device *nr_dev_first(void);
 extern struct net_device *nr_dev_get(ax25_address *);
 extern int  nr_rt_ioctl(unsigned int, void __user *);
-extern void nr_link_failed(ax25_cb *, int);
-extern int  nr_route_frame(struct sk_buff *, ax25_cb *);
+extern void nr_link_failed(struct ax25_sock *, int);
+extern int  nr_route_frame(struct sk_buff *, struct ax25_sock *);
 extern struct file_operations nr_nodes_fops;
 extern struct file_operations nr_neigh_fops;
 extern void nr_rt_free(void);
Index: linux-net/include/net/rose.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-net.orig/include/net/rose.h	2006-07-14 01:22:39.000000000 +01=
00
+++ linux-net/include/net/rose.h	2006-07-14 01:25:20.000000000 +0100
@@ -85,7 +85,7 @@ struct rose_neigh {
 	struct rose_neigh	*next;
 	ax25_address		callsign;
 	ax25_digi		*digipeat;
-	ax25_cb			*ax25;
+	struct ax25_sock			*ax25;
 	struct net_device		*dev;
 	unsigned short		count;
 	unsigned short		use;
@@ -203,8 +203,8 @@ extern struct net_device *rose_dev_get(r
 extern struct rose_route *rose_route_free_lci(unsigned int, struct ros=
e_neigh *);
 extern struct rose_neigh *rose_get_neigh(rose_address *, unsigned char=
 *, unsigned char *);
 extern int  rose_rt_ioctl(unsigned int, void __user *);
-extern void rose_link_failed(ax25_cb *, int);
-extern int  rose_route_frame(struct sk_buff *, ax25_cb *);
+extern void rose_link_failed(struct ax25_sock *, int);
+extern int  rose_route_frame(struct sk_buff *, struct ax25_sock *);
 extern void rose_rt_free(void);
=20
 /* rose_subr.c */
Index: linux-net/net/ax25/af_ax25.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-net.orig/net/ax25/af_ax25.c	2006-07-14 01:22:39.000000000 +01=
00
+++ linux-net/net/ax25/af_ax25.c	2006-07-14 01:27:33.000000000 +0100
@@ -54,24 +54,21 @@
 HLIST_HEAD(ax25_list);
 DEFINE_SPINLOCK(ax25_list_lock);
=20
+static struct proto ax25_proto;
 static const struct proto_ops ax25_proto_ops;
=20
-static void ax25_free_sock(struct sock *sk)
+static void ax25_sk_destruct(struct sock *sk)
 {
-	ax25_cb_put(ax25_sk(sk));
+	struct ax25_sock *ax25 =3D (struct ax25_sock *) sk;
+
+	kfree(ax25->digipeat);
 }
=20
-/*
- *	Socket removal during an interrupt is now safe.
- */
-static void ax25_cb_del(ax25_cb *ax25)
+static void ax25_cb_del(struct ax25_sock *ax25)
 {
-	if (!hlist_unhashed(&ax25->ax25_node)) {
-		spin_lock_bh(&ax25_list_lock);
-		hlist_del_init(&ax25->ax25_node);
-		spin_unlock_bh(&ax25_list_lock);
-		ax25_cb_put(ax25);
-	}
+	spin_lock_bh(&ax25_list_lock);
+	sk_del_node_init(&ax25->sock);
+	spin_unlock_bh(&ax25_list_lock);
 }
=20
 /*
@@ -80,18 +77,22 @@ static void ax25_cb_del(ax25_cb *ax25)
 static void ax25_kill_by_device(struct net_device *dev)
 {
 	ax25_dev *ax25_dev;
-	ax25_cb *s;
+	struct ax25_sock *ax25;
 	struct hlist_node *node;
=20
 	if ((ax25_dev =3D ax25_dev_ax25dev(dev)) =3D=3D NULL)
 		return;
=20
 	spin_lock_bh(&ax25_list_lock);
-	ax25_for_each(s, node, &ax25_list) {
-		if (s->ax25_dev =3D=3D ax25_dev) {
-			s->ax25_dev =3D NULL;
-			ax25_disconnect(s, ENETUNREACH);
+	ax25_for_each(ax25, node, &ax25_list) {
+		if (ax25->sk)
+			bh_lock_sock(ax25->sk);
+		if (ax25->ax25_dev =3D=3D ax25_dev) {
+			ax25->ax25_dev =3D NULL;
+			ax25_disconnect(ax25, ENETUNREACH);
 		}
+		if (ax25->sk)
+			bh_unlock_sock(ax25->sk);
 	}
 	spin_unlock_bh(&ax25_list_lock);
 }
@@ -127,11 +128,10 @@ static int ax25_device_event(struct noti
 /*
  *	Add a socket to the bound sockets list.
  */
-void ax25_cb_add(ax25_cb *ax25)
+void ax25_cb_add(struct ax25_sock *ax25)
 {
 	spin_lock_bh(&ax25_list_lock);
-	ax25_cb_hold(ax25);
-	hlist_add_head(&ax25->ax25_node, &ax25_list);
+	sk_add_node(&ax25->sock, &ax25_list);
 	spin_unlock_bh(&ax25_list_lock);
 }
=20
@@ -142,7 +142,7 @@ void ax25_cb_add(ax25_cb *ax25)
 struct sock *ax25_find_listener(ax25_address *addr, int digi,
 	struct net_device *dev, int type)
 {
-	ax25_cb *s;
+	struct ax25_sock *s;
 	struct hlist_node *node;
=20
 	spin_lock(&ax25_list_lock);
@@ -171,7 +171,7 @@ struct sock *ax25_get_socket(ax25_addres
 	int type)
 {
 	struct sock *sk =3D NULL;
-	ax25_cb *s;
+	struct ax25_sock *s;
 	struct hlist_node *node;
=20
 	spin_lock(&ax25_list_lock);
@@ -194,10 +194,10 @@ struct sock *ax25_get_socket(ax25_addres
  *	Find an AX.25 control block given both ends. It will only pick up
  *	floating AX.25 control blocks or non Raw socket bound control block=
s.
  */
-ax25_cb *ax25_find_cb(ax25_address *src_addr, ax25_address *dest_addr,
+struct ax25_sock *ax25_find_cb(ax25_address *src_addr, ax25_address *d=
est_addr,
 	ax25_digi *digi, struct net_device *dev)
 {
-	ax25_cb *s;
+	struct ax25_sock *s;
 	struct hlist_node *node;
=20
 	spin_lock_bh(&ax25_list_lock);
@@ -216,7 +216,7 @@ ax25_cb *ax25_find_cb(ax25_address *src_
 				if (s->digipeat !=3D NULL && s->digipeat->ndigi !=3D 0)
 					continue;
 			}
-			ax25_cb_hold(s);
+			sock_hold(&s->sock);
 			spin_unlock_bh(&ax25_list_lock);
=20
 			return s;
@@ -231,7 +231,7 @@ EXPORT_SYMBOL(ax25_find_cb);
=20
 void ax25_send_to_raw(ax25_address *addr, struct sk_buff *skb, int pro=
to)
 {
-	ax25_cb *s;
+	struct ax25_sock *s;
 	struct sk_buff *copy;
 	struct hlist_node *node;
=20
@@ -254,14 +254,14 @@ void ax25_send_to_raw(ax25_address *addr
 /*
  *	Deferred destroy.
  */
-void ax25_destroy_socket(ax25_cb *);
+void ax25_destroy_socket(struct ax25_sock *);
=20
 /*
  *	Handler for deferred kills.
  */
 static void ax25_destroy_timer(unsigned long data)
 {
-	ax25_cb *ax25=3D(ax25_cb *)data;
+	struct ax25_sock *ax25 =3D (struct ax25_sock *)data;
 	struct sock *sk;
 =09
 	sk=3Dax25->sk;
@@ -279,7 +279,7 @@ static void ax25_destroy_timer(unsigned=20
  *	work. Once it is removed from the queue no interrupt or bottom half
  *	will touch it and we are (fairly 8-) ) safe.
  */
-void ax25_destroy_socket(ax25_cb *ax25)
+void ax25_destroy_socket(struct ax25_sock *ax25)
 {
 	struct sk_buff *skb;
=20
@@ -297,7 +297,7 @@ void ax25_destroy_socket(ax25_cb *ax25)
 		while ((skb =3D skb_dequeue(&ax25->sk->sk_receive_queue)) !=3D NULL)=
 {
 			if (skb->sk !=3D ax25->sk) {
 				/* A pending connection */
-				ax25_cb *sax25 =3D ax25_sk(skb->sk);
+				struct ax25_sock *sax25 =3D ax25_sk(skb->sk);
=20
 				/* Queue the unaccepted socket for death */
 				sock_orphan(skb->sk);
@@ -326,7 +326,7 @@ void ax25_destroy_socket(ax25_cb *ax25)
 			sock_put(sk);
 		}
 	} else {
-		ax25_cb_put(ax25);
+		sock_put(&ax25->sock);
 	}
 }
=20
@@ -340,7 +340,7 @@ static int ax25_ctl_ioctl(const unsigned
 	struct ax25_ctl_struct ax25_ctl;
 	ax25_digi digi;
 	ax25_dev *ax25_dev;
-	ax25_cb *ax25;
+	struct ax25_sock *ax25;
 	unsigned int k;
=20
 	if (copy_from_user(&ax25_ctl, arg, sizeof(ax25_ctl)))
@@ -425,7 +425,7 @@ static int ax25_ctl_ioctl(const unsigned
 	return 0;
 }
=20
-static void ax25_fillin_cb_from_dev(ax25_cb *ax25, ax25_dev *ax25_dev)
+static void ax25_fillin_cb_from_dev(struct ax25_sock *ax25, ax25_dev *=
ax25_dev)
 {
 	ax25->rtt     =3D msecs_to_jiffies(ax25_dev->values[AX25_VALUES_T1]) =
/ 2;
 	ax25->t1      =3D msecs_to_jiffies(ax25_dev->values[AX25_VALUES_T1]);
@@ -449,7 +449,7 @@ static void ax25_fillin_cb_from_dev(ax25
  *	Fill in a created AX.25 created control block with the default
  *	values for a particular device.
  */
-void ax25_fillin_cb(ax25_cb *ax25, ax25_dev *ax25_dev)
+void ax25_fillin_cb(struct ax25_sock *ax25, ax25_dev *ax25_dev)
 {
 	ax25->ax25_dev =3D ax25_dev;
=20
@@ -482,14 +482,15 @@ void ax25_fillin_cb(ax25_cb *ax25, ax25_
 /*
  * Create an empty AX.25 control block.
  */
-ax25_cb *ax25_create_cb(void)
+struct ax25_sock *ax25_alloc_sock(struct socket *sock)
 {
-	ax25_cb *ax25;
+	struct ax25_sock *ax25;
=20
-	if ((ax25 =3D kzalloc(sizeof(*ax25), GFP_ATOMIC)) =3D=3D NULL)
+	ax25 =3D (struct ax25_sock *) sk_alloc(PF_AX25, GFP_ATOMIC, &ax25_pro=
to, 1);
+	 if (!ax25)
 		return NULL;
=20
-	atomic_set(&ax25->refcount, 1);
+	sock_init_data(sock, &ax25->sock);
=20
 	skb_queue_head_init(&ax25->write_queue);
 	skb_queue_head_init(&ax25->frag_queue);
@@ -518,7 +519,7 @@ static int ax25_setsockopt(struct socket
 	char __user *optval, int optlen)
 {
 	struct sock *sk =3D sock->sk;
-	ax25_cb *ax25;
+	struct ax25_sock *ax25;
 	struct net_device *dev;
 	char devname[IFNAMSIZ];
 	int opt, res =3D 0;
@@ -658,7 +659,7 @@ static int ax25_getsockopt(struct socket
 	char __user *optval, int __user *optlen)
 {
 	struct sock *sk =3D sock->sk;
-	ax25_cb *ax25;
+	struct ax25_sock *ax25;
 	struct ax25_dev *ax25_dev;
 	char devname[IFNAMSIZ];
 	void *valptr;
@@ -770,20 +771,15 @@ out:
 	return res;
 }
=20
-/*
- * XXX: when creating ax25_sock we should update the .obj_size setting
- * below.
- */
 static struct proto ax25_proto =3D {
 	.name	  =3D "AX25",
 	.owner	  =3D THIS_MODULE,
-	.obj_size =3D sizeof(struct sock),
+	.obj_size =3D sizeof(struct ax25_sock),
 };
=20
 static int ax25_create(struct socket *sock, int protocol)
 {
-	struct sock *sk;
-	ax25_cb *ax25;
+	struct ax25_sock *ax25;
=20
 	switch (sock->type) {
 	case SOCK_DGRAM:
@@ -830,62 +826,47 @@ static int ax25_create(struct socket *so
 		return -ESOCKTNOSUPPORT;
 	}
=20
-	if ((sk =3D sk_alloc(PF_AX25, GFP_ATOMIC, &ax25_proto, 1)) =3D=3D NUL=
L)
-		return -ENOMEM;
-
-	ax25 =3D sk->sk_protinfo =3D ax25_create_cb();
-	if (!ax25) {
-		sk_free(sk);
+	ax25 =3D ax25_alloc_sock(sock);
+	if (!ax25)
 		return -ENOMEM;
-	}
-
-	sock_init_data(sock, sk);
=20
-	sk->sk_destruct =3D ax25_free_sock;
+	ax25->sock.sk_destruct =3D ax25_sk_destruct;
 	sock->ops    =3D &ax25_proto_ops;
-	sk->sk_protocol =3D protocol;
+	ax25->sock.sk_protocol =3D protocol;
=20
-	ax25->sk    =3D sk;
+	ax25->sk    =3D &ax25->sock;
=20
 	return 0;
 }
=20
 struct sock *ax25_make_new(struct sock *osk, struct ax25_dev *ax25_dev=
)
 {
-	struct sock *sk;
-	ax25_cb *ax25, *oax25;
+	struct ax25_sock *ax25, *oax25;
=20
-	if ((sk =3D sk_alloc(PF_AX25, GFP_ATOMIC, osk->sk_prot, 1)) =3D=3D NU=
LL)
+	ax25 =3D ax25_alloc_sock(NULL);
+	if (!ax25)
 		return NULL;
=20
-	if ((ax25 =3D ax25_create_cb()) =3D=3D NULL) {
-		sk_free(sk);
-		return NULL;
-	}
-
 	switch (osk->sk_type) {
 	case SOCK_DGRAM:
 		break;
 	case SOCK_SEQPACKET:
 		break;
 	default:
-		sk_free(sk);
-		ax25_cb_put(ax25);
+		sk_free(&ax25->sock);
 		return NULL;
 	}
=20
-	sock_init_data(NULL, sk);
-
-	sk->sk_destruct =3D ax25_free_sock;
-	sk->sk_type     =3D osk->sk_type;
-	sk->sk_socket   =3D osk->sk_socket;
-	sk->sk_priority =3D osk->sk_priority;
-	sk->sk_protocol =3D osk->sk_protocol;
-	sk->sk_rcvbuf   =3D osk->sk_rcvbuf;
-	sk->sk_sndbuf   =3D osk->sk_sndbuf;
-	sk->sk_state    =3D TCP_ESTABLISHED;
-	sk->sk_sleep    =3D osk->sk_sleep;
-	sock_copy_flags(sk, osk);
+	ax25->sock.sk_destruct =3D ax25_sk_destruct;
+	ax25->sock.sk_type     =3D osk->sk_type;
+	ax25->sock.sk_socket   =3D osk->sk_socket;
+	ax25->sock.sk_priority =3D osk->sk_priority;
+	ax25->sock.sk_protocol =3D osk->sk_protocol;
+	ax25->sock.sk_rcvbuf   =3D osk->sk_rcvbuf;
+	ax25->sock.sk_sndbuf   =3D osk->sk_sndbuf;
+	ax25->sock.sk_state    =3D TCP_ESTABLISHED;
+	ax25->sock.sk_sleep    =3D osk->sk_sleep;
+	sock_copy_flags(&ax25->sock, osk);
=20
 	oax25 =3D ax25_sk(osk);
=20
@@ -907,24 +888,22 @@ struct sock *ax25_make_new(struct sock *
=20
 	if (oax25->digipeat !=3D NULL) {
 		if ((ax25->digipeat =3D kmalloc(sizeof(ax25_digi), GFP_ATOMIC)) =3D=3D=
 NULL) {
-			sk_free(sk);
-			ax25_cb_put(ax25);
+			sk_free(&ax25->sock);
 			return NULL;
 		}
=20
 		memcpy(ax25->digipeat, oax25->digipeat, sizeof(ax25_digi));
 	}
=20
-	sk->sk_protinfo =3D ax25;
-	ax25->sk    =3D sk;
+	ax25->sk    =3D &ax25->sock;
=20
-	return sk;
+	return &ax25->sock;
 }
=20
 static int ax25_release(struct socket *sock)
 {
 	struct sock *sk =3D sock->sk;
-	ax25_cb *ax25;
+	struct ax25_sock *ax25;
=20
 	if (sk =3D=3D NULL)
 		return 0;
@@ -1014,7 +993,7 @@ static int ax25_bind(struct socket *sock
 	ax25_dev *ax25_dev =3D NULL;
 	ax25_uid_assoc *user;
 	ax25_address call;
-	ax25_cb *ax25;
+	struct ax25_sock *ax25;
 	int err =3D 0;
=20
 	if (addr_len !=3D sizeof(struct sockaddr_ax25) &&
@@ -1092,7 +1071,7 @@ static int ax25_connect(struct socket *s
 	int addr_len, int flags)
 {
 	struct sock *sk =3D sock->sk;
-	ax25_cb *ax25 =3D ax25_sk(sk), *ax25t;
+	struct ax25_sock *ax25 =3D ax25_sk(sk), *ax25t;
 	struct full_sockaddr_ax25 *fsa =3D (struct full_sockaddr_ax25 *)uaddr=
;
 	ax25_digi *digi =3D NULL;
 	int ct =3D 0, err =3D 0;
@@ -1212,7 +1191,7 @@ static int ax25_connect(struct socket *s
 		    	 ax25->ax25_dev->dev))) {
 		kfree(digi);
 		err =3D -EADDRINUSE;		/* Already such a connection */
-		ax25_cb_put(ax25t);
+		sock_put(&ax25t->sock);
 		goto out;
 	}
=20
@@ -1375,7 +1354,7 @@ static int ax25_getname(struct socket *s
 	struct full_sockaddr_ax25 *fsa =3D (struct full_sockaddr_ax25 *)uaddr=
;
 	struct sock *sk =3D sock->sk;
 	unsigned char ndigi, i;
-	ax25_cb *ax25;
+	struct ax25_sock *ax25;
 	int err =3D 0;
=20
 	lock_sock(sk);
@@ -1426,7 +1405,7 @@ static int ax25_sendmsg(struct kiocb *io
 	struct sk_buff *skb;
 	ax25_digi dtmp, *dp;
 	unsigned char *asmptr;
-	ax25_cb *ax25;
+	struct ax25_sock *ax25;
 	size_t size;
 	int lv, err, addr_len =3D msg->msg_namelen;
=20
@@ -1762,7 +1741,7 @@ static int ax25_ioctl(struct socket *soc
=20
 	case SIOCAX25GETINFO:
 	case SIOCAX25GETINFOOLD: {
-		ax25_cb *ax25 =3D ax25_sk(sk);
+		struct ax25_sock *ax25 =3D ax25_sk(sk);
 		struct ax25_info_struct ax25_info;
=20
 		ax25_info.t1        =3D ax25->t1   / HZ;
@@ -1849,7 +1828,7 @@ static int ax25_ioctl(struct socket *soc
=20
 static void *ax25_info_start(struct seq_file *seq, loff_t *pos)
 {
-	struct ax25_cb *ax25;
+	struct ax25_sock *ax25;
 	struct hlist_node *node;
 	int i =3D 0;
=20
@@ -1866,8 +1845,8 @@ static void *ax25_info_next(struct seq_f
 {
 	++*pos;
=20
-	return hlist_entry( ((struct ax25_cb *)v)->ax25_node.next,
-			    struct ax25_cb, ax25_node);
+	return hlist_entry(((struct ax25_sock *)v)->sock.sk_node.next,
+			    struct ax25_sock, sock.sk_node);
 }
 =09
 static void ax25_info_stop(struct seq_file *seq, void *v)
@@ -1877,7 +1856,7 @@ static void ax25_info_stop(struct seq_fi
=20
 static int ax25_info_show(struct seq_file *seq, void *v)
 {
-	ax25_cb *ax25 =3D v;
+	struct ax25_sock *ax25 =3D v;
 	char buf[11];
 	int k;
=20
Index: linux-net/net/ax25/ax25_ds_in.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-net.orig/net/ax25/ax25_ds_in.c	2006-07-14 01:22:39.000000000 =
+0100
+++ linux-net/net/ax25/ax25_ds_in.c	2006-07-14 01:25:20.000000000 +0100
@@ -34,7 +34,7 @@
  *	The handling of the timer(s) is in file ax25_ds_timer.c.
  *	Handling of state 0 and connection release is in ax25.c.
  */
-static int ax25_ds_state1_machine(ax25_cb *ax25, struct sk_buff *skb, =
int frametype, int pf, int type)
+static int ax25_ds_state1_machine(struct ax25_sock *ax25, struct sk_bu=
ff *skb, int frametype, int pf, int type)
 {
 	switch (frametype) {
 	case AX25_SABM:
@@ -102,7 +102,7 @@ static int ax25_ds_state1_machine(ax25_c
  *	The handling of the timer(s) is in file ax25_ds_timer.c
  *	Handling of state 0 and connection release is in ax25.c.
  */
-static int ax25_ds_state2_machine(ax25_cb *ax25, struct sk_buff *skb, =
int frametype, int pf, int type)
+static int ax25_ds_state2_machine(struct ax25_sock *ax25, struct sk_bu=
ff *skb, int frametype, int pf, int type)
 {
 	switch (frametype) {
 	case AX25_SABM:
@@ -147,7 +147,7 @@ static int ax25_ds_state2_machine(ax25_c
  *	The handling of the timer(s) is in file ax25_timer.c
  *	Handling of state 0 and connection release is in ax25.c.
  */
-static int ax25_ds_state3_machine(ax25_cb *ax25, struct sk_buff *skb, =
int frametype, int ns, int nr, int pf, int type)
+static int ax25_ds_state3_machine(struct ax25_sock *ax25, struct sk_bu=
ff *skb, int frametype, int ns, int nr, int pf, int type)
 {
 	int queued =3D 0;
=20
@@ -281,7 +281,7 @@ static int ax25_ds_state3_machine(ax25_c
 /*
  *	Higher level upcall for a LAPB frame
  */
-int ax25_ds_frame_in(ax25_cb *ax25, struct sk_buff *skb, int type)
+int ax25_ds_frame_in(struct ax25_sock *ax25, struct sk_buff *skb, int =
type)
 {
 	int queued =3D 0, frametype, ns, nr, pf;
=20
Index: linux-net/net/ax25/ax25_ds_subr.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-net.orig/net/ax25/ax25_ds_subr.c	2006-07-14 01:22:39.00000000=
0 +0100
+++ linux-net/net/ax25/ax25_ds_subr.c	2006-07-14 01:25:20.000000000 +01=
00
@@ -29,7 +29,7 @@
 #include <linux/mm.h>
 #include <linux/interrupt.h>
=20
-void ax25_ds_nr_error_recovery(ax25_cb *ax25)
+void ax25_ds_nr_error_recovery(struct ax25_sock *ax25)
 {
 	ax25_ds_establish_data_link(ax25);
 }
@@ -37,9 +37,9 @@ void ax25_ds_nr_error_recovery(ax25_cb *
 /*
  *	dl1bke 960114: transmit I frames on DAMA poll
  */
-void ax25_ds_enquiry_response(ax25_cb *ax25)
+void ax25_ds_enquiry_response(struct ax25_sock *ax25)
 {
-	ax25_cb *ax25o;
+	struct ax25_sock *ax25o;
 	struct hlist_node *node;
=20
 	/* Please note that neither DK4EG=B4s nor DG2FEF=B4s
@@ -109,7 +109,7 @@ void ax25_ds_enquiry_response(ax25_cb *a
 	spin_unlock(&ax25_list_lock);
 }
=20
-void ax25_ds_establish_data_link(ax25_cb *ax25)
+void ax25_ds_establish_data_link(struct ax25_sock *ax25)
 {
 	ax25->condition &=3D AX25_COND_DAMA_MODE;
 	ax25->n2count    =3D 0;
@@ -158,7 +158,7 @@ static void ax25_kiss_cmd(ax25_dev *ax25
  */
 static int ax25_check_dama_slave(ax25_dev *ax25_dev)
 {
-	ax25_cb *ax25;
+	struct ax25_sock *ax25;
 	int res =3D 0;
 	struct hlist_node *node;
=20
@@ -197,13 +197,13 @@ void ax25_dev_dama_off(ax25_dev *ax25_de
 	}
 }
=20
-void ax25_dama_on(ax25_cb *ax25)
+void ax25_dama_on(struct ax25_sock *ax25)
 {
 	ax25_dev_dama_on(ax25->ax25_dev);
 	ax25->condition |=3D AX25_COND_DAMA_MODE;
 }
=20
-void ax25_dama_off(ax25_cb *ax25)
+void ax25_dama_off(struct ax25_sock *ax25)
 {
 	ax25->condition &=3D ~AX25_COND_DAMA_MODE;
 	ax25_dev_dama_off(ax25->ax25_dev);
Index: linux-net/net/ax25/ax25_ds_timer.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-net.orig/net/ax25/ax25_ds_timer.c	2006-07-14 01:22:39.0000000=
00 +0100
+++ linux-net/net/ax25/ax25_ds_timer.c	2006-07-14 01:25:20.000000000 +0=
100
@@ -74,7 +74,7 @@ void ax25_ds_set_timer(ax25_dev *ax25_de
 static void ax25_ds_timeout(unsigned long arg)
 {
 	ax25_dev *ax25_dev =3D (struct ax25_dev *) arg;
-	ax25_cb *ax25;
+	struct ax25_sock *ax25;
 	struct hlist_node *node;
=20
 	if (ax25_dev =3D=3D NULL || !ax25_dev->dama.slave)
@@ -98,7 +98,7 @@ static void ax25_ds_timeout(unsigned lon
 	ax25_dev_dama_off(ax25_dev);
 }
=20
-void ax25_ds_heartbeat_expiry(ax25_cb *ax25)
+void ax25_ds_heartbeat_expiry(struct ax25_sock *ax25)
 {
 	struct sock *sk=3Dax25->sk;
=20
@@ -150,7 +150,7 @@ void ax25_ds_heartbeat_expiry(ax25_cb *a
  *                gets reloaded with every frame for this
  *		  connection.
  */
-void ax25_ds_t3timer_expiry(ax25_cb *ax25)
+void ax25_ds_t3timer_expiry(struct ax25_sock *ax25)
 {
 	ax25_send_control(ax25, AX25_DISC, AX25_POLLON, AX25_COMMAND);
 	ax25_dama_off(ax25);
@@ -161,7 +161,7 @@ void ax25_ds_t3timer_expiry(ax25_cb *ax2
  *		  unlike T3 this timer gets reloaded only on
  *		  I frames.
  */
-void ax25_ds_idletimer_expiry(ax25_cb *ax25)
+void ax25_ds_idletimer_expiry(struct ax25_sock *ax25)
 {
 	ax25_clear_queues(ax25);
=20
@@ -193,7 +193,7 @@ void ax25_ds_idletimer_expiry(ax25_cb *a
  *                Thus we'll have to do parts of our T1 handling in
  *                ax25_enquiry_response().
  */
-void ax25_ds_t1_timeout(ax25_cb *ax25)
+void ax25_ds_t1_timeout(struct ax25_sock *ax25)
 {
 	switch (ax25->state) {
 	case AX25_STATE_1:
Index: linux-net/net/ax25/ax25_iface.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-net.orig/net/ax25/ax25_iface.c	2006-07-14 01:22:39.000000000 =
+0100
+++ linux-net/net/ax25/ax25_iface.c	2006-07-14 01:25:20.000000000 +0100
@@ -32,13 +32,13 @@
 static struct protocol_struct {
 	struct protocol_struct *next;
 	unsigned int pid;
-	int (*func)(struct sk_buff *, ax25_cb *);
+	int (*func)(struct sk_buff *, struct ax25_sock *);
 } *protocol_list =3D NULL;
 static DEFINE_RWLOCK(protocol_list_lock);
=20
 static struct linkfail_struct {
 	struct linkfail_struct *next;
-	void (*func)(ax25_cb *, int);
+	void (*func)(struct ax25_sock *, int);
 } *linkfail_list =3D NULL;
 static DEFINE_SPINLOCK(linkfail_lock);
=20
@@ -50,7 +50,7 @@ static struct listen_struct {
 static DEFINE_SPINLOCK(listen_lock);
=20
 int ax25_protocol_register(unsigned int pid,
-	int (*func)(struct sk_buff *, ax25_cb *))
+	int (*func)(struct sk_buff *, struct ax25_sock *))
 {
 	struct protocol_struct *protocol;
=20
@@ -110,7 +110,7 @@ void ax25_protocol_release(unsigned int=20
=20
 EXPORT_SYMBOL(ax25_protocol_release);
=20
-int ax25_linkfail_register(void (*func)(ax25_cb *, int))
+int ax25_linkfail_register(void (*func)(struct ax25_sock *, int))
 {
 	struct linkfail_struct *linkfail;
=20
@@ -129,7 +129,7 @@ int ax25_linkfail_register(void (*func)(
=20
 EXPORT_SYMBOL(ax25_linkfail_register);
=20
-void ax25_linkfail_release(void (*func)(ax25_cb *, int))
+void ax25_linkfail_release(void (*func)(struct ax25_sock *, int))
 {
 	struct linkfail_struct *s, *linkfail;
=20
@@ -220,9 +220,9 @@ void ax25_listen_release(ax25_address *c
=20
 EXPORT_SYMBOL(ax25_listen_release);
=20
-int (*ax25_protocol_function(unsigned int pid))(struct sk_buff *, ax25=
_cb *)
+int (*ax25_protocol_function(unsigned int pid))(struct sk_buff *, stru=
ct ax25_sock *)
 {
-	int (*res)(struct sk_buff *, ax25_cb *) =3D NULL;
+	int (*res)(struct sk_buff *, struct ax25_sock *) =3D NULL;
 	struct protocol_struct *protocol;
=20
 	read_lock(&protocol_list_lock);
@@ -251,7 +251,7 @@ int ax25_listen_mine(ax25_address *calls
 	return 0;
 }
=20
-void ax25_link_failed(ax25_cb *ax25, int reason)
+void ax25_link_failed(struct ax25_sock *ax25, int reason)
 {
 	struct linkfail_struct *linkfail;
=20
Index: linux-net/net/ax25/ax25_in.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-net.orig/net/ax25/ax25_in.c	2006-07-14 01:22:39.000000000 +01=
00
+++ linux-net/net/ax25/ax25_in.c	2006-07-14 01:25:20.000000000 +0100
@@ -36,7 +36,7 @@
  *	Given a fragment, queue it on the fragment queue and if the fragmen=
t
  *	is complete, send it back to ax25_rx_iframe.
  */
-static int ax25_rx_fragment(ax25_cb *ax25, struct sk_buff *skb)
+static int ax25_rx_fragment(struct ax25_sock *ax25, struct sk_buff *sk=
b)
 {
 	struct sk_buff *skbn, *skbo;
=20
@@ -99,9 +99,9 @@ static int ax25_rx_fragment(ax25_cb *ax2
  *	This is where all valid I frames are sent to, to be dispatched to
  *	whichever protocol requires them.
  */
-int ax25_rx_iframe(ax25_cb *ax25, struct sk_buff *skb)
+int ax25_rx_iframe(struct ax25_sock *ax25, struct sk_buff *skb)
 {
-	int (*func)(struct sk_buff *, ax25_cb *);
+	int (*func)(struct sk_buff *, struct ax25_sock *);
 	unsigned char pid;
 	int queued =3D 0;
=20
@@ -157,7 +157,7 @@ int ax25_rx_iframe(ax25_cb *ax25, struct
 /*
  *	Higher level upcall for a LAPB frame
  */
-static int ax25_process_rx_frame(ax25_cb *ax25, struct sk_buff *skb, i=
nt type, int dama)
+static int ax25_process_rx_frame(struct ax25_sock *ax25, struct sk_buf=
f *skb, int type, int dama)
 {
 	int queued =3D 0;
=20
@@ -190,7 +190,7 @@ static int ax25_rcv(struct sk_buff *skb,
 	int type =3D 0, mine =3D 0, dama;
 	struct sock *make, *sk;
 	ax25_digi dp, reverse_dp;
-	ax25_cb *ax25;
+	struct ax25_sock *ax25;
 	ax25_dev *ax25_dev;
=20
 	/*
@@ -321,7 +321,7 @@ static int ax25_rcv(struct sk_buff *skb,
 		if (ax25_process_rx_frame(ax25, skb, type, dama) =3D=3D 0)
 			kfree_skb(skb);
=20
-		ax25_cb_put(ax25);
+		sock_put(&ax25->sock);
 		return 0;
 	}
=20
@@ -376,7 +376,8 @@ static int ax25_rcv(struct sk_buff *skb,
 			return 0;
 		}
=20
-		if ((ax25 =3D ax25_create_cb()) =3D=3D NULL) {
+		ax25 =3D ax25_alloc_sock(NULL);
+		if (!ax25) {
 			ax25_return_dm(dev, &src, &dest, &dp);
 			kfree_skb(skb);
 			return 0;
Index: linux-net/net/ax25/ax25_ip.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-net.orig/net/ax25/ax25_ip.c	2006-07-14 01:22:39.000000000 +01=
00
+++ linux-net/net/ax25/ax25_ip.c	2006-07-14 01:25:20.000000000 +0100
@@ -108,7 +108,7 @@ int ax25_rebuild_header(struct sk_buff *
 	ax25_address *src, *dst;
 	ax25_digi *digipeat =3D NULL;
 	ax25_dev *ax25_dev;
-	ax25_cb *ax25;
+	struct ax25_sock *ax25;
 	char ip_mode =3D ' ';
=20
 	dst =3D (ax25_address *)(bp + 1);
@@ -180,7 +180,7 @@ int ax25_rebuild_header(struct sk_buff *
 			    &src_c,
 			    &dst_c, digipeat, dev);
 			if (ax25) {
-				ax25_cb_put(ax25);
+				sock_put(&ax25->sock);
 			}
 			goto put;
 		}
Index: linux-net/net/ax25/ax25_out.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-net.orig/net/ax25/ax25_out.c	2006-07-14 01:22:39.000000000 +0=
100
+++ linux-net/net/ax25/ax25_out.c	2006-07-14 01:25:20.000000000 +0100
@@ -34,10 +34,10 @@
=20
 static DEFINE_SPINLOCK(ax25_frag_lock);
=20
-ax25_cb *ax25_send_frame(struct sk_buff *skb, int paclen, ax25_address=
 *src, ax25_address *dest, ax25_digi *digi, struct net_device *dev)
+struct ax25_sock *ax25_send_frame(struct sk_buff *skb, int paclen, ax2=
5_address *src, ax25_address *dest, ax25_digi *digi, struct net_device =
*dev)
 {
 	ax25_dev *ax25_dev;
-	ax25_cb *ax25;
+	struct ax25_sock *ax25;
=20
 	/*
 	 * Take the default packet length for the device if zero is
@@ -61,7 +61,8 @@ ax25_cb *ax25_send_frame(struct sk_buff=20
 	if ((ax25_dev =3D ax25_dev_ax25dev(dev)) =3D=3D NULL)
 		return NULL;
=20
-	if ((ax25 =3D ax25_create_cb()) =3D=3D NULL)
+	ax25 =3D ax25_alloc_sock(NULL);
+	if (!ax25)
 		return NULL;
=20
 	ax25_fillin_cb(ax25, ax25_dev);
@@ -71,7 +72,7 @@ ax25_cb *ax25_send_frame(struct sk_buff=20
=20
 	if (digi !=3D NULL) {
 		if ((ax25->digipeat =3D kmalloc(sizeof(ax25_digi), GFP_ATOMIC)) =3D=3D=
 NULL) {
-			ax25_cb_put(ax25);
+			sock_put(&ax25->sock);
 			return NULL;
 		}
 		memcpy(ax25->digipeat, digi, sizeof(ax25_digi));
@@ -112,7 +113,7 @@ EXPORT_SYMBOL(ax25_send_frame);
  *	zero then we are not allowed to do fragmentation, even if the frame
  *	is too large.
  */
-void ax25_output(ax25_cb *ax25, int paclen, struct sk_buff *skb)
+void ax25_output(struct ax25_sock *ax25, int paclen, struct sk_buff *s=
kb)
 {
 	struct sk_buff *skbn;
 	unsigned char *p;
@@ -199,7 +200,7 @@ void ax25_output(ax25_cb *ax25, int pacl
  *  This procedure is passed a buffer descriptor for an iframe. It bui=
lds
  *  the rest of the control part of the frame and then writes it out.
  */
-static void ax25_send_iframe(ax25_cb *ax25, struct sk_buff *skb, int p=
oll_bit)
+static void ax25_send_iframe(struct ax25_sock *ax25, struct sk_buff *s=
kb, int poll_bit)
 {
 	unsigned char *frame;
=20
@@ -229,7 +230,7 @@ static void ax25_send_iframe(ax25_cb *ax
 	ax25_transmit_buffer(ax25, skb, AX25_COMMAND);
 }
=20
-void ax25_kick(ax25_cb *ax25)
+void ax25_kick(struct ax25_sock *ax25)
 {
 	struct sk_buff *skb, *skbn;
 	int last =3D 1;
@@ -311,7 +312,7 @@ void ax25_kick(ax25_cb *ax25)
 	}
 }
=20
-void ax25_transmit_buffer(ax25_cb *ax25, struct sk_buff *skb, int type=
)
+void ax25_transmit_buffer(struct ax25_sock *ax25, struct sk_buff *skb,=
 int type)
 {
 	struct sk_buff *skbn;
 	unsigned char *ptr;
@@ -361,7 +362,7 @@ void ax25_queue_xmit(struct sk_buff *skb
 	dev_queue_xmit(skb);
 }
=20
-int ax25_check_iframes_acked(ax25_cb *ax25, unsigned short nr)
+int ax25_check_iframes_acked(struct ax25_sock *ax25, unsigned short nr=
)
 {
 	if (ax25->vs =3D=3D nr) {
 		ax25_frames_acked(ax25, nr);
Index: linux-net/net/ax25/ax25_route.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-net.orig/net/ax25/ax25_route.c	2006-07-14 01:22:39.000000000 =
+0100
+++ linux-net/net/ax25/ax25_route.c	2006-07-14 01:25:20.000000000 +0100
@@ -405,7 +405,7 @@ static inline void ax25_adjust_path(ax25
 /*
  *	Find which interface to use.
  */
-int ax25_rt_autobind(ax25_cb *ax25, ax25_address *addr)
+int ax25_rt_autobind(struct ax25_sock *ax25, ax25_address *addr)
 {
 	ax25_uid_assoc *user;
 	ax25_route *ax25_rt;
Index: linux-net/net/ax25/ax25_std_in.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-net.orig/net/ax25/ax25_std_in.c	2006-07-14 01:22:39.000000000=
 +0100
+++ linux-net/net/ax25/ax25_std_in.c	2006-07-14 01:25:20.000000000 +010=
0
@@ -41,7 +41,7 @@
  *	The handling of the timer(s) is in file ax25_std_timer.c.
  *	Handling of state 0 and connection release is in ax25.c.
  */
-static int ax25_std_state1_machine(ax25_cb *ax25, struct sk_buff *skb,=
 int frametype, int pf, int type)
+static int ax25_std_state1_machine(struct ax25_sock *ax25, struct sk_b=
uff *skb, int frametype, int pf, int type)
 {
 	switch (frametype) {
 	case AX25_SABM:
@@ -105,7 +105,7 @@ static int ax25_std_state1_machine(ax25_
  *	The handling of the timer(s) is in file ax25_std_timer.c
  *	Handling of state 0 and connection release is in ax25.c.
  */
-static int ax25_std_state2_machine(ax25_cb *ax25, struct sk_buff *skb,=
 int frametype, int pf, int type)
+static int ax25_std_state2_machine(struct ax25_sock *ax25, struct sk_b=
uff *skb, int frametype, int pf, int type)
 {
 	switch (frametype) {
 	case AX25_SABM:
@@ -143,7 +143,7 @@ static int ax25_std_state2_machine(ax25_
  *	The handling of the timer(s) is in file ax25_std_timer.c
  *	Handling of state 0 and connection release is in ax25.c.
  */
-static int ax25_std_state3_machine(ax25_cb *ax25, struct sk_buff *skb,=
 int frametype, int ns, int nr, int pf, int type)
+static int ax25_std_state3_machine(struct ax25_sock *ax25, struct sk_b=
uff *skb, int frametype, int ns, int nr, int pf, int type)
 {
 	int queued =3D 0;
=20
@@ -268,7 +268,7 @@ static int ax25_std_state3_machine(ax25_
  *	The handling of the timer(s) is in file ax25_std_timer.c
  *	Handling of state 0 and connection release is in ax25.c.
  */
-static int ax25_std_state4_machine(ax25_cb *ax25, struct sk_buff *skb,=
 int frametype, int ns, int nr, int pf, int type)
+static int ax25_std_state4_machine(struct ax25_sock *ax25, struct sk_b=
uff *skb, int frametype, int ns, int nr, int pf, int type)
 {
 	int queued =3D 0;
=20
@@ -421,7 +421,7 @@ static int ax25_std_state4_machine(ax25_
 /*
  *	Higher level upcall for a LAPB frame
  */
-int ax25_std_frame_in(ax25_cb *ax25, struct sk_buff *skb, int type)
+int ax25_std_frame_in(struct ax25_sock *ax25, struct sk_buff *skb, int=
 type)
 {
 	int queued =3D 0, frametype, ns, nr, pf;
=20
Index: linux-net/net/ax25/ax25_std_subr.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-net.orig/net/ax25/ax25_std_subr.c	2006-07-14 01:22:39.0000000=
00 +0100
+++ linux-net/net/ax25/ax25_std_subr.c	2006-07-14 01:25:20.000000000 +0=
100
@@ -32,12 +32,12 @@
  * Networking Conference paper, as is the whole state machine.
  */
=20
-void ax25_std_nr_error_recovery(ax25_cb *ax25)
+void ax25_std_nr_error_recovery(struct ax25_sock *ax25)
 {
 	ax25_std_establish_data_link(ax25);
 }
=20
-void ax25_std_establish_data_link(ax25_cb *ax25)
+void ax25_std_establish_data_link(struct ax25_sock *ax25)
 {
 	ax25->condition =3D 0x00;
 	ax25->n2count   =3D 0;
@@ -54,7 +54,7 @@ void ax25_std_establish_data_link(ax25_c
 	ax25_start_t1timer(ax25);
 }
=20
-void ax25_std_transmit_enquiry(ax25_cb *ax25)
+void ax25_std_transmit_enquiry(struct ax25_sock *ax25)
 {
 	if (ax25->condition & AX25_COND_OWN_RX_BUSY)
 		ax25_send_control(ax25, AX25_RNR, AX25_POLLON, AX25_COMMAND);
@@ -67,7 +67,7 @@ void ax25_std_transmit_enquiry(ax25_cb *
 	ax25_start_t1timer(ax25);
 }
=20
-void ax25_std_enquiry_response(ax25_cb *ax25)
+void ax25_std_enquiry_response(struct ax25_sock *ax25)
 {
 	if (ax25->condition & AX25_COND_OWN_RX_BUSY)
 		ax25_send_control(ax25, AX25_RNR, AX25_POLLON, AX25_RESPONSE);
@@ -77,7 +77,7 @@ void ax25_std_enquiry_response(ax25_cb *
 	ax25->condition &=3D ~AX25_COND_ACK_PENDING;
 }
=20
-void ax25_std_timeout_response(ax25_cb *ax25)
+void ax25_std_timeout_response(struct ax25_sock *ax25)
 {
 	if (ax25->condition & AX25_COND_OWN_RX_BUSY)
 		ax25_send_control(ax25, AX25_RNR, AX25_POLLOFF, AX25_RESPONSE);
Index: linux-net/net/ax25/ax25_std_timer.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-net.orig/net/ax25/ax25_std_timer.c	2006-07-14 01:22:39.000000=
000 +0100
+++ linux-net/net/ax25/ax25_std_timer.c	2006-07-14 01:25:20.000000000 +=
0100
@@ -31,7 +31,7 @@
 #include <linux/mm.h>
 #include <linux/interrupt.h>
=20
-void ax25_std_heartbeat_expiry(ax25_cb *ax25)
+void ax25_std_heartbeat_expiry(struct ax25_sock *ax25)
 {
 	struct sock *sk=3Dax25->sk;
 =09
@@ -79,7 +79,7 @@ void ax25_std_heartbeat_expiry(ax25_cb *
 	ax25_start_heartbeat(ax25);
 }
=20
-void ax25_std_t2timer_expiry(ax25_cb *ax25)
+void ax25_std_t2timer_expiry(struct ax25_sock *ax25)
 {
 	if (ax25->condition & AX25_COND_ACK_PENDING) {
 		ax25->condition &=3D ~AX25_COND_ACK_PENDING;
@@ -87,14 +87,14 @@ void ax25_std_t2timer_expiry(ax25_cb *ax
 	}
 }
=20
-void ax25_std_t3timer_expiry(ax25_cb *ax25)
+void ax25_std_t3timer_expiry(struct ax25_sock *ax25)
 {
 	ax25->n2count =3D 0;
 	ax25_std_transmit_enquiry(ax25);
 	ax25->state   =3D AX25_STATE_4;
 }
=20
-void ax25_std_idletimer_expiry(ax25_cb *ax25)
+void ax25_std_idletimer_expiry(struct ax25_sock *ax25)
 {
 	ax25_clear_queues(ax25);
=20
@@ -120,7 +120,7 @@ void ax25_std_idletimer_expiry(ax25_cb *
 	}
 }
=20
-void ax25_std_t1timer_expiry(ax25_cb *ax25)
+void ax25_std_t1timer_expiry(struct ax25_sock *ax25)
 {
 	switch (ax25->state) {
 	case AX25_STATE_1:
Index: linux-net/net/ax25/ax25_subr.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-net.orig/net/ax25/ax25_subr.c	2006-07-14 01:22:39.000000000 +=
0100
+++ linux-net/net/ax25/ax25_subr.c	2006-07-14 01:25:20.000000000 +0100
@@ -34,7 +34,7 @@
 /*
  *	This routine purges all the queues of frames.
  */
-void ax25_clear_queues(ax25_cb *ax25)
+void ax25_clear_queues(struct ax25_sock *ax25)
 {
 	skb_queue_purge(&ax25->write_queue);
 	skb_queue_purge(&ax25->ack_queue);
@@ -47,7 +47,7 @@ void ax25_clear_queues(ax25_cb *ax25)
  * acknowledged. This replaces the boxes labelled "V(a) <- N(r)" on th=
e
  * SDL diagram.
  */
-void ax25_frames_acked(ax25_cb *ax25, unsigned short nr)
+void ax25_frames_acked(struct ax25_sock *ax25, unsigned short nr)
 {
 	struct sk_buff *skb;
=20
@@ -63,7 +63,7 @@ void ax25_frames_acked(ax25_cb *ax25, un
 	}
 }
=20
-void ax25_requeue_frames(ax25_cb *ax25)
+void ax25_requeue_frames(struct ax25_sock *ax25)
 {
         struct sk_buff *skb, *skb_prev =3D NULL;
=20
@@ -85,7 +85,7 @@ void ax25_requeue_frames(ax25_cb *ax25)
  *	Validate that the value of nr is between va and vs. Return true or
  *	false for testing.
  */
-int ax25_validate_nr(ax25_cb *ax25, unsigned short nr)
+int ax25_validate_nr(struct ax25_sock *ax25, unsigned short nr)
 {
 	unsigned short vc =3D ax25->va;
=20
@@ -103,7 +103,7 @@ int ax25_validate_nr(ax25_cb *ax25, unsi
  *	This routine is the centralised routine for parsing the control
  *	information for the different frame formats.
  */
-int ax25_decode(ax25_cb *ax25, struct sk_buff *skb, int *ns, int *nr, =
int *pf)
+int ax25_decode(struct ax25_sock *ax25, struct sk_buff *skb, int *ns, =
int *nr, int *pf)
 {
 	unsigned char *frame;
 	int frametype =3D AX25_ILLEGAL;
@@ -153,7 +153,7 @@ int ax25_decode(ax25_cb *ax25, struct sk
  *	command or  response  for  the remote machine ( eg. RR, UA etc. ).
  *	Only supervisory or unnumbered frames are processed.
  */
-void ax25_send_control(ax25_cb *ax25, int frametype, int poll_bit, int=
 type)
+void ax25_send_control(struct ax25_sock *ax25, int frametype, int poll=
_bit, int type)
 {
 	struct sk_buff *skb;
 	unsigned char  *dptr;
@@ -226,7 +226,7 @@ void ax25_return_dm(struct net_device *d
 /*
  *	Exponential backoff for AX.25
  */
-void ax25_calculate_t1(ax25_cb *ax25)
+void ax25_calculate_t1(struct ax25_sock *ax25)
 {
 	int n, t =3D 2;
=20
@@ -251,7 +251,7 @@ void ax25_calculate_t1(ax25_cb *ax25)
 /*
  *	Calculate the Round Trip Time
  */
-void ax25_calculate_rtt(ax25_cb *ax25)
+void ax25_calculate_rtt(struct ax25_sock *ax25)
 {
 	if (ax25->backoff =3D=3D 0)
 		return;
@@ -266,7 +266,7 @@ void ax25_calculate_rtt(ax25_cb *ax25)
 		ax25->rtt =3D AX25_T1CLAMPHI;
 }
=20
-void ax25_disconnect(ax25_cb *ax25, int reason)
+void ax25_disconnect(struct ax25_sock *ax25, int reason)
 {
 	ax25_clear_queues(ax25);
=20
Index: linux-net/net/ax25/ax25_timer.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-net.orig/net/ax25/ax25_timer.c	2006-07-14 01:22:39.000000000 =
+0100
+++ linux-net/net/ax25/ax25_timer.c	2006-07-14 01:25:20.000000000 +0100
@@ -40,7 +40,7 @@ static void ax25_t2timer_expiry(unsigned
 static void ax25_t3timer_expiry(unsigned long);
 static void ax25_idletimer_expiry(unsigned long);
=20
-void ax25_start_heartbeat(ax25_cb *ax25)
+void ax25_start_heartbeat(struct ax25_sock *ax25)
 {
 	del_timer(&ax25->timer);
=20
@@ -51,7 +51,7 @@ void ax25_start_heartbeat(ax25_cb *ax25)
 	add_timer(&ax25->timer);
 }
=20
-void ax25_start_t1timer(ax25_cb *ax25)
+void ax25_start_t1timer(struct ax25_sock *ax25)
 {
 	del_timer(&ax25->t1timer);
=20
@@ -62,7 +62,7 @@ void ax25_start_t1timer(ax25_cb *ax25)
 	add_timer(&ax25->t1timer);
 }
=20
-void ax25_start_t2timer(ax25_cb *ax25)
+void ax25_start_t2timer(struct ax25_sock *ax25)
 {
 	del_timer(&ax25->t2timer);
=20
@@ -73,7 +73,7 @@ void ax25_start_t2timer(ax25_cb *ax25)
 	add_timer(&ax25->t2timer);
 }
=20
-void ax25_start_t3timer(ax25_cb *ax25)
+void ax25_start_t3timer(struct ax25_sock *ax25)
 {
 	del_timer(&ax25->t3timer);
=20
@@ -86,7 +86,7 @@ void ax25_start_t3timer(ax25_cb *ax25)
 	}
 }
=20
-void ax25_start_idletimer(ax25_cb *ax25)
+void ax25_start_idletimer(struct ax25_sock *ax25)
 {
 	del_timer(&ax25->idletimer);
=20
@@ -99,32 +99,32 @@ void ax25_start_idletimer(ax25_cb *ax25)
 	}
 }
=20
-void ax25_stop_heartbeat(ax25_cb *ax25)
+void ax25_stop_heartbeat(struct ax25_sock *ax25)
 {
 	del_timer(&ax25->timer);
 }
=20
-void ax25_stop_t1timer(ax25_cb *ax25)
+void ax25_stop_t1timer(struct ax25_sock *ax25)
 {
 	del_timer(&ax25->t1timer);
 }
=20
-void ax25_stop_t2timer(ax25_cb *ax25)
+void ax25_stop_t2timer(struct ax25_sock *ax25)
 {
 	del_timer(&ax25->t2timer);
 }
=20
-void ax25_stop_t3timer(ax25_cb *ax25)
+void ax25_stop_t3timer(struct ax25_sock *ax25)
 {
 	del_timer(&ax25->t3timer);
 }
=20
-void ax25_stop_idletimer(ax25_cb *ax25)
+void ax25_stop_idletimer(struct ax25_sock *ax25)
 {
 	del_timer(&ax25->idletimer);
 }
=20
-int ax25_t1timer_running(ax25_cb *ax25)
+int ax25_t1timer_running(struct ax25_sock *ax25)
 {
 	return timer_pending(&ax25->t1timer);
 }
@@ -142,7 +142,7 @@ EXPORT_SYMBOL(ax25_display_timer);
 static void ax25_heartbeat_expiry(unsigned long param)
 {
 	int proto =3D AX25_PROTO_STD_SIMPLEX;
-	ax25_cb *ax25 =3D (ax25_cb *)param;
+	struct ax25_sock *ax25 =3D (struct ax25_sock *)param;
=20
 	if (ax25->ax25_dev)
 		proto =3D ax25->ax25_dev->values[AX25_VALUES_PROTOCOL];
@@ -166,7 +166,7 @@ static void ax25_heartbeat_expiry(unsign
=20
 static void ax25_t1timer_expiry(unsigned long param)
 {
-	ax25_cb *ax25 =3D (ax25_cb *)param;
+	struct ax25_sock *ax25 =3D (struct ax25_sock *)param;
=20
 	switch (ax25->ax25_dev->values[AX25_VALUES_PROTOCOL]) {
 	case AX25_PROTO_STD_SIMPLEX:
@@ -185,7 +185,7 @@ static void ax25_t1timer_expiry(unsigned
=20
 static void ax25_t2timer_expiry(unsigned long param)
 {
-	ax25_cb *ax25 =3D (ax25_cb *)param;
+	struct ax25_sock *ax25 =3D (struct ax25_sock *)param;
=20
 	switch (ax25->ax25_dev->values[AX25_VALUES_PROTOCOL]) {
 	case AX25_PROTO_STD_SIMPLEX:
@@ -204,7 +204,7 @@ static void ax25_t2timer_expiry(unsigned
=20
 static void ax25_t3timer_expiry(unsigned long param)
 {
-	ax25_cb *ax25 =3D (ax25_cb *)param;
+	struct ax25_sock *ax25 =3D (struct ax25_sock *)param;
=20
 	switch (ax25->ax25_dev->values[AX25_VALUES_PROTOCOL]) {
 	case AX25_PROTO_STD_SIMPLEX:
@@ -225,7 +225,7 @@ static void ax25_t3timer_expiry(unsigned
=20
 static void ax25_idletimer_expiry(unsigned long param)
 {
-	ax25_cb *ax25 =3D (ax25_cb *)param;
+	struct ax25_sock *ax25 =3D (struct ax25_sock *)param;
=20
 	switch (ax25->ax25_dev->values[AX25_VALUES_PROTOCOL]) {
 	case AX25_PROTO_STD_SIMPLEX:
Index: linux-net/net/netrom/nr_route.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-net.orig/net/netrom/nr_route.c	2006-07-14 01:22:39.000000000 =
+0100
+++ linux-net/net/netrom/nr_route.c	2006-07-14 01:25:20.000000000 +0100
@@ -718,7 +718,7 @@ int nr_rt_ioctl(unsigned int cmd, void _
  * 	A level 2 link has timed out, therefore it appears to be a poor li=
nk,
  *	then don't use that neighbour until it is reset.
  */
-void nr_link_failed(ax25_cb *ax25, int reason)
+void nr_link_failed(struct ax25_sock *ax25, int reason)
 {
 	struct nr_neigh *s, *nr_neigh =3D NULL;
 	struct hlist_node *node;
@@ -738,7 +738,7 @@ void nr_link_failed(ax25_cb *ax25, int r
 		return;
=20
 	nr_neigh->ax25 =3D NULL;
-	ax25_cb_put(ax25);
+	sock_put(&ax25->sock);
=20
 	if (++nr_neigh->failed < sysctl_netrom_link_fails_count) {
 		nr_neigh_put(nr_neigh);
@@ -757,17 +757,17 @@ void nr_link_failed(ax25_cb *ax25, int r
 }
=20
 /*
- *	Route a frame to an appropriate AX.25 connection. A NULL ax25_cb
+ *	Route a frame to an appropriate AX.25 connection. A NULL struct ax2=
5_sock
  *	indicates an internally generated frame.
  */
-int nr_route_frame(struct sk_buff *skb, ax25_cb *ax25)
+int nr_route_frame(struct sk_buff *skb, struct ax25_sock *ax25)
 {
 	ax25_address *nr_src, *nr_dest;
 	struct nr_neigh *nr_neigh;
 	struct nr_node  *nr_node;
 	struct net_device *dev;
 	unsigned char *dptr;
-	ax25_cb *ax25s;
+	struct ax25_sock *ax25s;
 	int ret;
 	struct sk_buff *skbn;
=20
@@ -833,8 +833,8 @@ int nr_route_frame(struct sk_buff *skb,=20
=20
 	ax25s =3D ax25_send_frame(skb, 256, (ax25_address *)dev->dev_addr, &n=
r_neigh->callsign, nr_neigh->digipeat, nr_neigh->dev);
 	if (nr_neigh->ax25 && ax25s) {
-		/* We were already holding this ax25_cb */
-		ax25_cb_put(ax25s);
+		/* We were already holding this struct ax25_sock */
+		sock_put(&ax25s->sock);
 	}
 	nr_neigh->ax25 =3D ax25s;
=20
Index: linux-net/net/rose/rose_route.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-net.orig/net/rose/rose_route.c	2006-07-14 01:22:39.000000000 =
+0100
+++ linux-net/net/rose/rose_route.c	2006-07-14 01:25:20.000000000 +0100
@@ -790,7 +790,7 @@ static void rose_del_route_by_neigh(stru
  *	then don't use that neighbour until it is reset. Blow away all thro=
ugh
  *	routes and connections using this route.
  */
-void rose_link_failed(ax25_cb *ax25, int reason)
+void rose_link_failed(struct ax25_sock *ax25, int reason)
 {
 	struct rose_neigh *rose_neigh;
=20
@@ -830,7 +830,7 @@ void rose_link_device_down(struct net_de
 /*
  *	Route a frame to an appropriate AX.25 connection.
  */
-int rose_route_frame(struct sk_buff *skb, ax25_cb *ax25)
+int rose_route_frame(struct sk_buff *skb, struct ax25_sock *ax25)
 {
 	struct rose_neigh *rose_neigh, *new_neigh;
 	struct rose_route *rose_route;
