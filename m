From: acme@ghostprotocols.net (Arnaldo Carvalho de Melo)
Subject: [NET] make all protos partially use sk_prot
Date: Fri, 25 Mar 2005 21:39:37 -0300
Message-ID: <20050326003937.GA13951@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="dDRMvlgZJXvWKvBx"
Cc: netdev@oss.sgi.com
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


Hi Dave,

	Please take a look and apply if acceptable, full description is
on the changeset.

	Ah, I started using __ as a separator between class name and
method, I've been using this in some client projects and find it useful
for grepping and for ctags, as it eliminates some false positives and
do namespacing more strongly, please tell me if you don't like it.

	If this is accepted the next changesets probably will move
struct proto and the proto__ routines to net/core/prot.{c,h} and I'll
add proto__ prefix to all struct proto members, etc.

	Available at:

bk://kernel.bkbits.net/acme/net-2.6

Best Regards,

                        - Arnaldo

--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="proto__register.patch"

===================================================================


ChangeSet@1.2327, 2005-03-25 21:21:16-03:00, acme@toy.ghostprotocols.net
  [NET] make all protos partially use sk_prot
  
  sk_alloc_slab becomes proto__register, that receives a struct proto not necessarily
  completely filled, but at least with the proto name, owner and obj_size (aka proto
  specific sock size), with this we can remove the struct sock sk_owner and sk_slab,
  using sk->sk_prot->{owner,slab} instead.
  
  This patch also makes sk_set_owner not necessary anymore, as at sk_alloc time we
  have now access to the struct proto onwer and slab members, so we can bump the
  module refcount exactly at sock allocation time.
  
  Another nice "side effect" is that this patch removes the generic sk_cachep slab
  cache, making the only last two protocols that used it use just kmalloc, informing
  a struct proto obj_size equal to sizeof(struct sock).
  
  Ah, almost forgot that with this patch it is very easy to use a slab cache, as it is
  now created at proto__register time, and all protocols need to use proto__register,
  so its just a matter of switching the second parameter of proto__register to '1', heck,
  this can be done even at module load time with some small additional patch.
  
  Another optimization that will be possible in the future is to move the sk_protocol
  and sk_type struct sock members to struct proto, but this has to wait for all protocols
  to move completely to sk_prot.
  
  This changeset also introduces /proc/net/protocols, that lists the registered protocols
  details, some may seem excessive, but I'd like to keep them while working on further
  struct sock hierarchy work and also to realize which protocols are old ones, i.e. that
  still use struct proto_ops, etc, yeah, this is a bit of an exaggeration, as all protos
  still use struct proto_ops, but in time the idea is to move all to use sk->sk_prot and
  make the proto_ops infrastructure be shared among all protos, reducing one level of
  indirection.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 drivers/net/pppoe.c         |   36 +++++--
 include/linux/ip.h          |    2 
 include/net/llc_conn.h      |    2 
 include/net/sock.h          |   33 +-----
 net/appletalk/ddp.c         |   20 +++-
 net/atm/common.c            |   54 ++++++-----
 net/ax25/af_ax25.c          |   27 ++++-
 net/bluetooth/bnep/sock.c   |   20 +++-
 net/bluetooth/cmtp/sock.c   |   20 +++-
 net/bluetooth/hci_sock.c    |   29 ++++-
 net/bluetooth/hidp/sock.c   |   30 ++++--
 net/bluetooth/l2cap.c       |   39 +++++---
 net/bluetooth/rfcomm/sock.c |   33 ++++--
 net/bluetooth/sco.c         |   39 +++++---
 net/core/sock.c             |  214 +++++++++++++++++++++++++++++++++++---------
 net/decnet/af_decnet.c      |   28 +++--
 net/econet/af_econet.c      |   21 +++-
 net/ipv4/af_inet.c          |   24 ++--
 net/ipv4/raw.c              |    2 
 net/ipv4/syncookies.c       |    5 -
 net/ipv4/tcp_ipv4.c         |    2 
 net/ipv4/tcp_minisocks.c    |    6 -
 net/ipv4/udp.c              |    2 
 net/ipv6/af_inet6.c         |   38 +++----
 net/ipv6/raw.c              |    4 
 net/ipv6/tcp_ipv6.c         |    2 
 net/ipv6/udp.c              |    4 
 net/ipx/af_ipx.c            |   28 ++---
 net/irda/af_irda.c          |   21 ++--
 net/key/af_key.c            |   40 ++++++--
 net/llc/af_llc.c            |   29 ++++-
 net/llc/llc_conn.c          |    8 -
 net/netlink/af_netlink.c    |   29 ++++-
 net/netrom/af_netrom.c      |   33 ++++--
 net/packet/af_packet.c      |   23 +++-
 net/rose/af_rose.c          |   28 +++--
 net/sctp/ipv6.c             |   14 +-
 net/sctp/protocol.c         |   12 --
 net/sctp/socket.c           |    4 
 net/unix/af_unix.c          |   36 ++++---
 net/wanrouter/af_wanpipe.c  |   26 ++++-
 net/x25/af_x25.c            |   21 +++-
 42 files changed, 730 insertions(+), 358 deletions(-)


diff -Nru a/drivers/net/pppoe.c b/drivers/net/pppoe.c
--- a/drivers/net/pppoe.c	2005-03-25 21:30:21 -03:00
+++ b/drivers/net/pppoe.c	2005-03-25 21:30:21 -03:00
@@ -480,6 +480,13 @@
 	.func	= pppoe_disc_rcv,
 };
 
+static struct proto pppoe__proto = {
+	.name	  = "PPPOE",
+	.owner	  = THIS_MODULE,
+	.slab	  = NULL,
+	.obj_size = sizeof(struct pppox_sock),
+};
+
 /***********************************************************************
  *
  * Initialize a new struct sock.
@@ -488,14 +495,13 @@
 static int pppoe_create(struct socket *sock)
 {
 	int error = -ENOMEM;
-	struct sock *sk;
+	struct sock *sk = sk_alloc(PF_PPPOX, GFP_KERNEL, &pppoe__proto, 1);
 
-	sk = sk_alloc(PF_PPPOX, GFP_KERNEL, sizeof(struct pppox_sock), NULL);
 	if (!sk)
 		goto out;
 
 	sock_init_data(sock, sk);
-	sk_set_owner(sk, THIS_MODULE);
+
 	sock->state = SS_UNCONNECTED;
 	sock->ops   = &pppoe_ops;
 
@@ -1103,22 +1109,29 @@
 
 static int __init pppoe_init(void)
 {
- 	int err = register_pppox_proto(PX_PROTO_OE, &pppoe_proto);
+	int rc = proto__register(&pppoe__proto, 0);
 
-	if (err)
+	if (rc != 0)
 		goto out;
 
-	err = pppoe_proc_init();
-	if (err) {
-		unregister_pppox_proto(PX_PROTO_OE);
-		goto out;
-	}
+ 	rc = register_pppox_proto(PX_PROTO_OE, &pppoe_proto);
+	if (rc)
+		goto out_unregister_pppoe_proto;
+
+	rc = pppoe_proc_init();
+	if (rc)
+		goto out_unregister_pppox_proto;
 	
 	dev_add_pack(&pppoes_ptype);
 	dev_add_pack(&pppoed_ptype);
 	register_netdevice_notifier(&pppoe_notifier);
 out:
-	return err;
+	return rc;
+out_unregister_pppox_proto:
+	unregister_pppox_proto(PX_PROTO_OE);
+out_unregister_pppoe_proto:
+	proto__unregister(&pppoe__proto);
+	goto out;
 }
 
 static void __exit pppoe_exit(void)
@@ -1128,6 +1141,7 @@
 	dev_remove_pack(&pppoed_ptype);
 	unregister_netdevice_notifier(&pppoe_notifier);
 	remove_proc_entry("pppoe", proc_net);
+	proto__unregister(&pppoe__proto);
 }
 
 module_init(pppoe_init);
diff -Nru a/include/linux/ip.h b/include/linux/ip.h
--- a/include/linux/ip.h	2005-03-25 21:30:20 -03:00
+++ b/include/linux/ip.h	2005-03-25 21:30:20 -03:00
@@ -164,7 +164,7 @@
 					     const int ancestor_size)
 {
 	memcpy(inet_sk(sk_to) + 1, inet_sk(sk_from) + 1,
-	       sk_from->sk_prot->slab_obj_size - ancestor_size);
+	       sk_from->sk_prot->obj_size - ancestor_size);
 }
 #if !(defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE))
 static inline void inet_sk_copy_descendant(struct sock *sk_to,
diff -Nru a/include/net/llc_conn.h b/include/net/llc_conn.h
--- a/include/net/llc_conn.h	2005-03-25 21:30:21 -03:00
+++ b/include/net/llc_conn.h	2005-03-25 21:30:21 -03:00
@@ -92,7 +92,7 @@
 	return skb->cb[sizeof(skb->cb) - 1];
 }
 
-extern struct sock *llc_sk_alloc(int family, int priority);
+extern struct sock *llc_sk_alloc(int family, int priority, struct proto *prot);
 extern void llc_sk_free(struct sock *sk);
 
 extern void llc_sk_reset(struct sock *sk);
diff -Nru a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h	2005-03-25 21:30:21 -03:00
+++ b/include/net/sock.h	2005-03-25 21:30:21 -03:00
@@ -154,12 +154,10 @@
   *	@sk_sndtimeo - %SO_SNDTIMEO setting
   *	@sk_filter - socket filtering instructions
   *	@sk_protinfo - private area, net family specific, when not using slab
-  *	@sk_slab - the slabcache this instance was allocated from
   *	@sk_timer - sock cleanup timer
   *	@sk_stamp - time stamp of last packet received
   *	@sk_socket - Identd and reporting IO signals
   *	@sk_user_data - RPC layer private data
-  *	@sk_owner - module that owns this socket
   *	@sk_sndmsg_page - cached page for sendmsg
   *	@sk_sndmsg_off - cached offset for sendmsg
   *	@sk_send_head - front of stuff to transmit
@@ -231,12 +229,10 @@
 	long			sk_sndtimeo;
 	struct sk_filter      	*sk_filter;
 	void			*sk_protinfo;
-	kmem_cache_t		*sk_slab;
 	struct timer_list	sk_timer;
 	struct timeval		sk_stamp;
 	struct socket		*sk_socket;
 	void			*sk_user_data;
-	struct module		*sk_owner;
 	struct page		*sk_sndmsg_page;
 	struct sk_buff		*sk_send_head;
 	__u32			sk_sndmsg_off;
@@ -546,37 +542,22 @@
 	int			max_header;
 
 	kmem_cache_t		*slab;
-	int			slab_obj_size;
+	unsigned int		obj_size;
 
 	struct module		*owner;
 
 	char			name[32];
 
+	struct list_head	node;
+
 	struct {
 		int inuse;
 		u8  __pad[SMP_CACHE_BYTES - sizeof(int)];
 	} stats[NR_CPUS];
 };
 
-extern int sk_alloc_slab(struct proto *prot, char *name);
-extern void sk_free_slab(struct proto *prot);
-
-static __inline__ void sk_set_owner(struct sock *sk, struct module *owner)
-{
-	/*
-	 * One should use sk_set_owner just once, after struct sock creation,
-	 * be it shortly after sk_alloc or after a function that returns a new
-	 * struct sock (and that down the call chain called sk_alloc), e.g. the
-	 * IPv4 and IPv6 modules share tcp_create_openreq_child, so if
-	 * tcp_create_openreq_child called sk_set_owner IPv6 would have to
-	 * change the ownership of this struct sock, with one not needed
-	 * transient sk_set_owner call.
-	 */
-	BUG_ON(sk->sk_owner != NULL);
-
-	sk->sk_owner = owner;
-	__module_get(owner);
-}
+extern int proto__register(struct proto *prot, int alloc_slab);
+extern void proto__unregister(struct proto *prot);
 
 /* Called with local bh disabled */
 static __inline__ void sock_prot_inc_use(struct proto *prot)
@@ -696,8 +677,8 @@
 #define bh_lock_sock(__sk)	spin_lock(&((__sk)->sk_lock.slock))
 #define bh_unlock_sock(__sk)	spin_unlock(&((__sk)->sk_lock.slock))
 
-extern struct sock *		sk_alloc(int family, int priority, int zero_it,
-					 kmem_cache_t *slab);
+extern struct sock		*sk_alloc(int family, int priority,
+					  struct proto *prot, int zero_it);
 extern void			sk_free(struct sock *sk);
 
 extern struct sk_buff		*sock_wmalloc(struct sock *sk,
diff -Nru a/net/appletalk/ddp.c b/net/appletalk/ddp.c
--- a/net/appletalk/ddp.c	2005-03-25 21:30:21 -03:00
+++ b/net/appletalk/ddp.c	2005-03-25 21:30:21 -03:00
@@ -1015,6 +1015,13 @@
 	return sum ? htons((unsigned short)sum) : 0xFFFF;
 }
 
+static struct proto ddp__proto = {
+	.name	  = "DDP",
+	.owner	  = THIS_MODULE,
+	.slab	  = NULL,
+	.obj_size = sizeof(struct atalk_sock),
+};
+
 /*
  * Create a socket. Initialise the socket, blank the addresses
  * set the state.
@@ -1031,14 +1038,12 @@
 	if (sock->type != SOCK_RAW && sock->type != SOCK_DGRAM)
 		goto out;
 	rc = -ENOMEM;
-	sk = sk_alloc(PF_APPLETALK, GFP_KERNEL,
-		      sizeof(struct atalk_sock), NULL);
+	sk = sk_alloc(PF_APPLETALK, GFP_KERNEL, &ddp__proto, 1);
 	if (!sk)
 		goto out;
 	rc = 0;
 	sock->ops = &atalk_dgram_ops;
 	sock_init_data(sock, sk);
-	sk_set_owner(sk, THIS_MODULE);
 
 	/* Checksums on by default */
 	sock_set_flag(sk, SOCK_ZAPPED);
@@ -1874,6 +1879,11 @@
 /* Called by proto.c on kernel start up */
 static int __init atalk_init(void)
 {
+	int rc = proto__register(&ddp__proto, 0);
+
+	if (rc != 0)
+		goto out;
+
 	(void)sock_register(&atalk_family_ops);
 	ddp_dl = register_snap_client(ddp_snap_id, atalk_rcv);
 	if (!ddp_dl)
@@ -1886,7 +1896,8 @@
 	aarp_proto_init();
 	atalk_proc_init();
 	atalk_register_sysctl();
-	return 0;
+out:
+	return rc;
 }
 module_init(atalk_init);
 
@@ -1911,6 +1922,7 @@
 	dev_remove_pack(&ppptalk_packet_type);
 	unregister_snap_client(ddp_dl);
 	sock_unregister(PF_APPLETALK);
+	proto__unregister(&ddp__proto);
 }
 module_exit(atalk_exit);
 
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	2005-03-25 21:30:21 -03:00
+++ b/net/atm/common.c	2005-03-25 21:30:21 -03:00
@@ -127,6 +127,12 @@
 	read_unlock(&sk->sk_callback_lock);
 }
 
+static struct proto vcc__proto = {
+	.name	  = "VCC",
+	.owner	  = THIS_MODULE,
+	.slab	  = NULL,
+	.obj_size = sizeof(struct atm_vcc),
+};
  
 int vcc_create(struct socket *sock, int protocol, int family)
 {
@@ -136,11 +142,10 @@
 	sock->sk = NULL;
 	if (sock->type == SOCK_STREAM)
 		return -EINVAL;
-	sk = sk_alloc(family, GFP_KERNEL, sizeof(struct atm_vcc), NULL);
+	sk = sk_alloc(family, GFP_KERNEL, &vcc__proto, 1);
 	if (!sk)
 		return -ENOMEM;
 	sock_init_data(sock, sk);
-	sk_set_owner(sk, THIS_MODULE);
 	sk->sk_state_change = vcc_def_wakeup;
 	sk->sk_write_space = vcc_write_space;
 
@@ -157,7 +162,6 @@
 	vcc->vpi = vcc->vci = 0; /* no VCI/VPI yet */
 	vcc->atm_options = vcc->aal_options = 0;
 	sk->sk_destruct = vcc_sock_destruct;
-	sock->sk = sk;
 	return 0;
 }
 
@@ -757,26 +761,35 @@
 
 static int __init atm_init(void)
 {
-	int error;
+	int rc = proto__register(&vcc__proto, 0);
 
-	if ((error = atmpvc_init()) < 0) {
-		printk(KERN_ERR "atmpvc_init() failed with %d\n", error);
-		goto failure;
-	}
-	if ((error = atmsvc_init()) < 0) {
-		printk(KERN_ERR "atmsvc_init() failed with %d\n", error);
-		goto failure;
-	}
-        if ((error = atm_proc_init()) < 0) {
-		printk(KERN_ERR "atm_proc_init() failed with %d\n",error);
-		goto failure;
-	}
-	return 0;
+	if (rc != 0)
+		goto out;
 
-failure:
+	rc = atmpvc_init();
+	if (rc != 0) {
+		printk(KERN_ERR "atmpvc_init() failed with %d\n", rc);
+		goto out_unregister_vcc_proto;
+	}
+	rc = atmsvc_init();
+	if (rc != 0) {
+		printk(KERN_ERR "atmsvc_init() failed with %d\n", rc);
+		goto out_atmpvc_exit;
+	}
+        rc = atm_proc_init();
+	if (rc != 0) {
+		printk(KERN_ERR "atm_proc_init() failed with %d\n", rc);
+		goto out_atmsvc_exit;
+	}
+out:
+	return rc;
+out_atmsvc_exit:
 	atmsvc_exit();
-	atmpvc_exit();
-	return error;
+out_atmpvc_exit:
+	atmsvc_exit();
+out_unregister_vcc_proto:
+	proto__unregister(&vcc__proto);
+	goto out;
 }
 
 static void __exit atm_exit(void)
@@ -784,6 +797,7 @@
 	atm_proc_exit();
 	atmsvc_exit();
 	atmpvc_exit();
+	proto__unregister(&vcc__proto);
 }
 
 module_init(atm_init);
diff -Nru a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
--- a/net/ax25/af_ax25.c	2005-03-25 21:30:21 -03:00
+++ b/net/ax25/af_ax25.c	2005-03-25 21:30:21 -03:00
@@ -760,6 +760,17 @@
 	return res;
 }
 
+/*
+ * XXX: when creating ax25_sock we should update the .obj_size setting
+ * below.
+ */
+static struct proto ax25__proto = {
+	.name	  = "AX25",
+	.owner	  = THIS_MODULE,
+	.slab	  = NULL,
+	.obj_size = sizeof(struct sock),
+};
+
 static int ax25_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;
@@ -810,7 +821,7 @@
 		return -ESOCKTNOSUPPORT;
 	}
 
-	if ((sk = sk_alloc(PF_AX25, GFP_ATOMIC, 1, NULL)) == NULL)
+	if ((sk = sk_alloc(PF_AX25, GFP_ATOMIC, &ax25__proto, 1)) == NULL)
 		return -ENOMEM;
 
 	ax25 = sk->sk_protinfo = ax25_create_cb();
@@ -820,7 +831,6 @@
 	}
 
 	sock_init_data(sock, sk);
-	sk_set_owner(sk, THIS_MODULE);
 
 	sk->sk_destruct = ax25_free_sock;
 	sock->ops    = &ax25_proto_ops;
@@ -836,7 +846,7 @@
 	struct sock *sk;
 	ax25_cb *ax25, *oax25;
 
-	if ((sk = sk_alloc(PF_AX25, GFP_ATOMIC, 1, NULL)) == NULL)
+	if ((sk = sk_alloc(PF_AX25, GFP_ATOMIC, osk->sk_prot, 1)) == NULL)
 		return NULL;
 
 	if ((ax25 = ax25_create_cb()) == NULL) {
@@ -856,7 +866,6 @@
 	}
 
 	sock_init_data(NULL, sk);
-	sk_set_owner(sk, THIS_MODULE);
 
 	sk->sk_destruct = ax25_free_sock;
 	sk->sk_type     = osk->sk_type;
@@ -1998,6 +2007,11 @@
 
 static int __init ax25_init(void)
 {
+	int rc = proto__register(&ax25__proto, 0);
+
+	if (rc != 0)
+		goto out;
+
 	sock_register(&ax25_family_ops);
 	dev_add_pack(&ax25_packet_type);
 	register_netdevice_notifier(&ax25_dev_notifier);
@@ -2006,8 +2020,8 @@
 	proc_net_fops_create("ax25_route", S_IRUGO, &ax25_route_fops);
 	proc_net_fops_create("ax25", S_IRUGO, &ax25_info_fops);
 	proc_net_fops_create("ax25_calls", S_IRUGO, &ax25_uid_fops);
-
-	return 0;
+out:
+	return rc;
 }
 module_init(ax25_init);
 
@@ -2032,5 +2046,6 @@
 	dev_remove_pack(&ax25_packet_type);
 
 	sock_unregister(PF_AX25);
+	proto__unregister(&ax25__proto);
 }
 module_exit(ax25_exit);
diff -Nru a/net/bluetooth/bnep/sock.c b/net/bluetooth/bnep/sock.c
--- a/net/bluetooth/bnep/sock.c	2005-03-25 21:30:21 -03:00
+++ b/net/bluetooth/bnep/sock.c	2005-03-25 21:30:21 -03:00
@@ -167,6 +167,13 @@
 	.mmap       = sock_no_mmap
 };
 
+static struct proto bnep__proto = {
+	.name	  = "BNEP",
+	.owner	  = THIS_MODULE,
+	.slab	  = NULL,
+	.obj_size = sizeof(struct bt_sock),
+};
+
 static int bnep_sock_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;
@@ -176,13 +183,11 @@
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
 
-	if (!(sk = sk_alloc(PF_BLUETOOTH, GFP_KERNEL, sizeof(struct bt_sock), NULL)))
+	if (!(sk = sk_alloc(PF_BLUETOOTH, GFP_KERNEL, &bnep__proto, 1)))
 		return -ENOMEM;
 
 	sock_init_data(sock, sk);
 
-	sk_set_owner(sk, THIS_MODULE);
-
 	sock->ops = &bnep_sock_ops;
 
 	sock->state = SS_UNCONNECTED;
@@ -203,13 +208,18 @@
 
 int __init bnep_sock_init(void)
 {
-	bt_sock_register(BTPROTO_BNEP, &bnep_sock_family_ops);
-	return 0;
+	int rc = proto__register(&bnep__proto, 0);
+
+	if (rc == 0)
+		bt_sock_register(BTPROTO_BNEP, &bnep_sock_family_ops);
+	return rc;
 }
 
 int __exit bnep_sock_cleanup(void)
 {
 	if (bt_sock_unregister(BTPROTO_BNEP))
 		BT_ERR("Can't unregister BNEP socket");
+
+	proto__unregister(&bnep__proto);
 	return 0;
 }
diff -Nru a/net/bluetooth/cmtp/sock.c b/net/bluetooth/cmtp/sock.c
--- a/net/bluetooth/cmtp/sock.c	2005-03-25 21:30:21 -03:00
+++ b/net/bluetooth/cmtp/sock.c	2005-03-25 21:30:21 -03:00
@@ -158,6 +158,13 @@
 	.mmap		= sock_no_mmap
 };
 
+static struct proto cmtp__proto = {
+	.name	  = "CMTP",
+	.owner	  = THIS_MODULE,
+	.slab	  = NULL,
+	.obj_size = sizeof(struct bt_sock),
+};
+
 static int cmtp_sock_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;
@@ -167,13 +174,11 @@
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
 
-	if (!(sk = sk_alloc(PF_BLUETOOTH, GFP_KERNEL, sizeof(struct bt_sock), NULL)))
+	if (!(sk = sk_alloc(PF_BLUETOOTH, GFP_KERNEL, &cmtp__proto, 1)))
 		return -ENOMEM;
 
 	sock_init_data(sock, sk);
 
-	sk_set_owner(sk, THIS_MODULE);
-
 	sock->ops = &cmtp_sock_ops;
 
 	sock->state = SS_UNCONNECTED;
@@ -194,13 +199,18 @@
 
 int cmtp_init_sockets(void)
 {
-	bt_sock_register(BTPROTO_CMTP, &cmtp_sock_family_ops);
+	int rc = proto__register(&cmtp__proto, 0);
 
-	return 0;
+	if (rc == 0)
+		bt_sock_register(BTPROTO_CMTP, &cmtp_sock_family_ops);
+
+	return rc;
 }
 
 void cmtp_cleanup_sockets(void)
 {
 	if (bt_sock_unregister(BTPROTO_CMTP))
 		BT_ERR("Can't unregister CMTP socket");
+
+	proto__unregister(&cmtp__proto);
 }
diff -Nru a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
--- a/net/bluetooth/hci_sock.c	2005-03-25 21:30:20 -03:00
+++ b/net/bluetooth/hci_sock.c	2005-03-25 21:30:20 -03:00
@@ -590,6 +590,13 @@
 	.mmap		= sock_no_mmap
 };
 
+static struct proto hci__proto = {
+	.name	  = "HCI",
+	.owner	  = THIS_MODULE,
+	.slab	  = NULL,
+	.obj_size = sizeof(struct hci_pinfo),
+};
+
 static int hci_sock_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;
@@ -601,7 +608,7 @@
 
 	sock->ops = &hci_sock_ops;
 
-	sk = sk_alloc(PF_BLUETOOTH, GFP_KERNEL, sizeof(struct hci_pinfo), NULL);
+	sk = sk_alloc(PF_BLUETOOTH, GFP_KERNEL, &hci__proto, 1);
 	if (!sk)
 		return -ENOMEM;
 
@@ -611,8 +618,6 @@
 
 	sk->sk_protocol = protocol;
 
-	sk_set_owner(sk, THIS_MODULE);
-
 	sock->state = SS_UNCONNECTED;
 	sk->sk_state = BT_OPEN;
 
@@ -668,16 +673,25 @@
 
 int __init hci_sock_init(void)
 {
-	if (bt_sock_register(BTPROTO_HCI, &hci_sock_family_ops)) {
+	int rc = proto__register(&hci__proto, 0);
+
+	if (rc != 0)
+		goto out;
+
+	rc = bt_sock_register(BTPROTO_HCI, &hci_sock_family_ops);
+	if (rc != 0) {
 		BT_ERR("HCI socket registration failed");
-		return -EPROTO;
+		goto out_unregister_hci_proto;
 	}
 
 	hci_register_notifier(&hci_sock_nblock);
 
 	BT_INFO("HCI socket layer initialized");
-
-	return 0;
+out:
+	return rc;
+out_unregister_hci_proto:
+	proto__unregister(&hci__proto);
+	goto out;
 }
 
 int __exit hci_sock_cleanup(void)
@@ -686,5 +700,6 @@
 		BT_ERR("HCI socket unregistration failed");
 
 	hci_unregister_notifier(&hci_sock_nblock);
+	proto__unregister(&hci__proto);
 	return 0;
 }
diff -Nru a/net/bluetooth/hidp/sock.c b/net/bluetooth/hidp/sock.c
--- a/net/bluetooth/hidp/sock.c	2005-03-25 21:30:21 -03:00
+++ b/net/bluetooth/hidp/sock.c	2005-03-25 21:30:21 -03:00
@@ -164,6 +164,13 @@
 	.mmap		= sock_no_mmap
 };
 
+static struct proto hidp__proto = {
+	.name	  = "HIDP",
+	.owner	  = THIS_MODULE,
+	.slab	  = NULL,
+	.obj_size = sizeof(struct bt_sock),
+};
+
 static int hidp_sock_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;
@@ -173,13 +180,11 @@
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
 
-	if (!(sk = sk_alloc(PF_BLUETOOTH, GFP_KERNEL, sizeof(struct bt_sock), NULL)))
+	if (!(sk = sk_alloc(PF_BLUETOOTH, GFP_KERNEL, &hidp__proto, 1)))
 		return -ENOMEM;
 
 	sock_init_data(sock, sk);
 
-	sk_set_owner(sk, THIS_MODULE);
-
 	sock->ops = &hidp_sock_ops;
 
 	sock->state = SS_UNCONNECTED;
@@ -200,17 +205,26 @@
 
 int __init hidp_init_sockets(void)
 {
-	int err;
+	int rc = proto__register(&hidp__proto, 0);
 
-	err = bt_sock_register(BTPROTO_HIDP, &hidp_sock_family_ops);
-	if (err < 0)
-		BT_ERR("Can't register HIDP socket");
+	if (rc != 0)
+		goto out;
 
-	return err;
+	rc = bt_sock_register(BTPROTO_HIDP, &hidp_sock_family_ops);
+	if (rc < 0) {
+		BT_ERR("Can't register HIDP socket");
+		goto out_unregister_hidp_proto;
+	}
+out:
+	return rc;
+out_unregister_hidp_proto:
+	proto__unregister(&hidp__proto);
+	goto out;
 }
 
 void __exit hidp_cleanup_sockets(void)
 {
 	if (bt_sock_unregister(BTPROTO_HIDP) < 0)
 		BT_ERR("Can't unregister HIDP socket");
+	proto__unregister(&hidp__proto);
 }
diff -Nru a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
--- a/net/bluetooth/l2cap.c	2005-03-25 21:30:21 -03:00
+++ b/net/bluetooth/l2cap.c	2005-03-25 21:30:21 -03:00
@@ -367,18 +367,23 @@
 	pi->flush_to = L2CAP_DEFAULT_FLUSH_TO;
 }
 
+static struct proto l2cap__proto = {
+	.name	  = "L2CAP",
+	.owner	  = THIS_MODULE,
+	.slab	  = NULL,
+	.obj_size = sizeof(struct l2cap_pinfo),
+};
+
 static struct sock *l2cap_sock_alloc(struct socket *sock, int proto, int prio)
 {
-	struct sock *sk;
+	struct sock *sk = sk_alloc(PF_BLUETOOTH, prio, &l2cap__proto, 1);
 
-	sk = sk_alloc(PF_BLUETOOTH, prio, sizeof(struct l2cap_pinfo), NULL);
 	if (!sk)
 		return NULL;
 
 	sock_init_data(sock, sk);
-	INIT_LIST_HEAD(&bt_sk(sk)->accept_q);
 
-	sk_set_owner(sk, THIS_MODULE);
+	INIT_LIST_HEAD(&bt_sk(sk)->accept_q);
 
 	sk->sk_destruct = l2cap_sock_destruct;
 	sk->sk_sndtimeo = L2CAP_CONN_TIMEOUT;
@@ -2262,24 +2267,34 @@
 
 static int __init l2cap_init(void)
 {
-	int err;
+	int rc = proto__register(&l2cap__proto, 0);
 
-	if ((err = bt_sock_register(BTPROTO_L2CAP, &l2cap_sock_family_ops))) {
+	if (rc != 0)
+		goto out;
+
+	rc = bt_sock_register(BTPROTO_L2CAP, &l2cap_sock_family_ops);
+	if (rc != 0) {
 		BT_ERR("L2CAP socket registration failed");
-		return err;
+		goto out_unregister_l2cap_proto;
 	}
 
-	if ((err = hci_register_proto(&l2cap_hci_proto))) {
+	rc = hci_register_proto(&l2cap_hci_proto);
+	if (rc != 0) {
 		BT_ERR("L2CAP protocol registration failed");
-		return err;
+		goto out_bt_sock_unregister;
 	}
 
 	l2cap_proc_init();
 
 	BT_INFO("L2CAP ver %s", VERSION);
 	BT_INFO("L2CAP socket layer initialized");
-
-	return 0;
+out:
+	return rc;
+out_bt_sock_unregister:
+	bt_sock_unregister(BTPROTO_L2CAP);
+out_unregister_l2cap_proto:
+	proto__unregister(&l2cap__proto);
+	goto out;
 }
 
 static void __exit l2cap_exit(void)
@@ -2292,6 +2307,8 @@
 
 	if (hci_unregister_proto(&l2cap_hci_proto))
 		BT_ERR("L2CAP protocol unregistration failed");
+
+	proto__unregister(&l2cap__proto);
 }
 
 void l2cap_load(void)
diff -Nru a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
--- a/net/bluetooth/rfcomm/sock.c	2005-03-25 21:30:21 -03:00
+++ b/net/bluetooth/rfcomm/sock.c	2005-03-25 21:30:21 -03:00
@@ -279,19 +279,24 @@
 	pi->dlc->link_mode = pi->link_mode;
 }
 
+static struct proto rfcomm__proto = {
+	.name	  = "RFCOMM",
+	.owner	  = THIS_MODULE,
+	.slab	  = NULL,
+	.obj_size = sizeof(struct rfcomm_pinfo),
+};
+
 static struct sock *rfcomm_sock_alloc(struct socket *sock, int proto, int prio)
 {
 	struct rfcomm_dlc *d;
-	struct sock *sk;
+	struct sock *sk = sk_alloc(PF_BLUETOOTH, prio, &rfcomm__proto, 1);
 
-	sk = sk_alloc(PF_BLUETOOTH, prio, sizeof(struct rfcomm_pinfo), NULL);
 	if (!sk)
 		return NULL;
 
 	sock_init_data(sock, sk);
-	INIT_LIST_HEAD(&bt_sk(sk)->accept_q);
 
-	sk_set_owner(sk, THIS_MODULE);
+	INIT_LIST_HEAD(&bt_sk(sk)->accept_q);
 
 	d = rfcomm_dlc_alloc(prio);
 	if (!d) {
@@ -973,17 +978,25 @@
 
 int  __init rfcomm_init_sockets(void)
 {
-	int err;
+	int rc = proto__register(&rfcomm__proto, 0);
+
+	if (rc != 0)
+		goto out;
 
-	if ((err = bt_sock_register(BTPROTO_RFCOMM, &rfcomm_sock_family_ops))) {
-		BT_ERR("RFCOMM socket layer registration failed. %d", err);
-		return err;
+	rc = bt_sock_register(BTPROTO_RFCOMM, &rfcomm_sock_family_ops);
+	if (rc != 0) {
+		BT_ERR("RFCOMM socket layer registration failed. %d", rc);
+		goto out_unregister_rfcomm_proto;
 	}
 
 	rfcomm_sock_proc_init();
 
 	BT_INFO("RFCOMM socket layer initialized");
-	return 0;
+out:
+	return rc;
+out_unregister_rfcomm_proto:
+	proto__unregister(&rfcomm__proto);
+	goto out;
 }
 
 void __exit rfcomm_cleanup_sockets(void)
@@ -995,4 +1008,6 @@
 	/* Unregister socket, protocol and notifier */
 	if ((err = bt_sock_unregister(BTPROTO_RFCOMM)))
 		BT_ERR("RFCOMM socket layer unregistration failed. %d", err);
+
+	proto__unregister(&rfcomm__proto);
 }
diff -Nru a/net/bluetooth/sco.c b/net/bluetooth/sco.c
--- a/net/bluetooth/sco.c	2005-03-25 21:30:20 -03:00
+++ b/net/bluetooth/sco.c	2005-03-25 21:30:20 -03:00
@@ -413,18 +413,23 @@
 		sk->sk_type = parent->sk_type;
 }
 
+static struct proto sco__proto = {
+	.name	  = "SCO",
+	.owner	  = THIS_MODULE,
+	.slab	  = NULL,
+	.obj_size = sizeof(struct sco_pinfo),
+};
+
 static struct sock *sco_sock_alloc(struct socket *sock, int proto, int prio)
 {
-	struct sock *sk;
+	struct sock *sk = sk_alloc(PF_BLUETOOTH, prio, &sco__proto, 1);
 
-	sk = sk_alloc(PF_BLUETOOTH, prio, sizeof(struct sco_pinfo), NULL);
 	if (!sk)
 		return NULL;
 
 	sock_init_data(sock, sk);
-	INIT_LIST_HEAD(&bt_sk(sk)->accept_q);
 
-	sk_set_owner(sk, THIS_MODULE);
+	INIT_LIST_HEAD(&bt_sk(sk)->accept_q);
 
 	sk->sk_destruct = sco_sock_destruct;
 	sk->sk_sndtimeo = SCO_CONN_TIMEOUT;
@@ -1013,24 +1018,34 @@
 
 static int __init sco_init(void)
 {
-	int err;
+	int rc = proto__register(&sco__proto, 0);
+
+	if (rc != 0)
+		goto out;
 
-	if ((err = bt_sock_register(BTPROTO_SCO, &sco_sock_family_ops))) {
+	rc = bt_sock_register(BTPROTO_SCO, &sco_sock_family_ops);
+	if (rc != 0) {
 		BT_ERR("SCO socket registration failed");
-		return err;
+		goto out_unregister_sco_proto;
 	}
 
-	if ((err = hci_register_proto(&sco_hci_proto))) {
+	rc = hci_register_proto(&sco_hci_proto);
+	if (rc != 0) {
 		BT_ERR("SCO protocol registration failed");
-		return err;
+		goto out_bt_sock_unregister;
 	}
 
 	sco_proc_init();
 
 	BT_INFO("SCO (Voice Link) ver %s", VERSION);
 	BT_INFO("SCO socket layer initialized");
-
-	return 0;
+out:
+	return rc;
+out_bt_sock_unregister:
+	bt_sock_unregister(BTPROTO_SCO);
+out_unregister_sco_proto:
+	proto__unregister(&sco__proto);
+	goto out;
 }
 
 static void __exit sco_exit(void)
@@ -1045,6 +1060,8 @@
 
 	if ((err = hci_unregister_proto(&sco_hci_proto)))
 		BT_ERR("SCO protocol unregistration failed. %d", err);
+
+	proto__unregister(&sco__proto);
 }
 
 module_init(sco_init);
diff -Nru a/net/core/sock.c b/net/core/sock.c
--- a/net/core/sock.c	2005-03-25 21:30:21 -03:00
+++ b/net/core/sock.c	2005-03-25 21:30:21 -03:00
@@ -99,6 +99,8 @@
 #include <linux/kernel.h>
 #include <linux/major.h>
 #include <linux/module.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/sched.h>
 #include <linux/timer.h>
 #include <linux/string.h>
@@ -613,48 +615,36 @@
   	return 0;
 }
 
-static kmem_cache_t *sk_cachep;
-
 /**
  *	sk_alloc - All socket objects are allocated here
  *	@family - protocol family
  *	@priority - for allocation (%GFP_KERNEL, %GFP_ATOMIC, etc)
- *	@zero_it - zeroes the allocated sock
- *	@slab - alternate slab
- *
- *	All socket objects are allocated here. If @zero_it is non-zero
- *	it should have the size of the are to be zeroed, because the
- *	private slabcaches have different sizes of the generic struct sock.
- *	1 has been kept as a way to say sizeof(struct sock).
+ *	@prot - struct proto associated with this new sock instance
+ *	@zero_it - if we should zero the newly allocated sock
  */
-struct sock *sk_alloc(int family, int priority, int zero_it, kmem_cache_t *slab)
+struct sock *sk_alloc(int family, int priority, struct proto *prot, int zero_it)
 {
 	struct sock *sk = NULL;
-
-	/*
-	 * Transitional, this test will be removed when sk_cachep is killed
-	 */
-	if (slab == NULL && zero_it == 1)
-		slab = sk_cachep;
+	kmem_cache_t *slab = prot->slab;
 
 	if (slab != NULL)
 		sk = kmem_cache_alloc(slab, priority);
 	else
-		sk = kmalloc(zero_it, priority);
+		sk = kmalloc(prot->obj_size, priority);
 
 	if (sk) {
 		if (zero_it) {
-			memset(sk, 0,
-			       zero_it == 1 ? sizeof(struct sock) : zero_it);
+			memset(sk, 0, prot->obj_size);
 			sk->sk_family = family;
+			sk->sk_prot = prot;
 			sock_lock_init(sk);
 		}
-		sk->sk_slab = slab;
 		
 		if (security_sk_alloc(sk, family, priority)) {
 			kmem_cache_free(slab, sk);
 			sk = NULL;
-		}
+		} else
+			__module_get(prot->owner);
 	}
 	return sk;
 }
@@ -662,7 +652,7 @@
 void sk_free(struct sock *sk)
 {
 	struct sk_filter *filter;
-	struct module *owner = sk->sk_owner;
+	struct module *owner = sk->sk_prot->owner;
 
 	if (sk->sk_destruct)
 		sk->sk_destruct(sk);
@@ -680,8 +670,8 @@
 		       __FUNCTION__, atomic_read(&sk->sk_omem_alloc));
 
 	security_sk_free(sk);
-	if (sk->sk_slab != NULL)
-		kmem_cache_free(sk->sk_slab, sk);
+	if (sk->sk_prot->slab != NULL)
+		kmem_cache_free(sk->sk_prot->slab, sk);
 	else
 		kfree(sk);
 	module_put(owner);
@@ -689,11 +679,6 @@
 
 void __init sk_init(void)
 {
-	sk_cachep = kmem_cache_create("sock", sizeof(struct sock), 0,
-				      SLAB_HWCACHE_ALIGN, NULL, NULL);
-	if (!sk_cachep)
-		printk(KERN_CRIT "sk_init: Cannot create sock SLAB cache!");
-
 	if (num_physpages <= 4096) {
 		sysctl_wmem_max = 32767;
 		sysctl_rmem_max = 32767;
@@ -1227,7 +1212,6 @@
 	sk->sk_rcvlowat		=	1;
 	sk->sk_rcvtimeo		=	MAX_SCHEDULE_TIMEOUT;
 	sk->sk_sndtimeo		=	MAX_SCHEDULE_TIMEOUT;
-	sk->sk_owner		=	NULL;
 
 	sk->sk_stamp.tv_sec     = -1L;
 	sk->sk_stamp.tv_usec    = -1L;
@@ -1368,32 +1352,178 @@
 
 EXPORT_SYMBOL(sk_common_release);
 
-int sk_alloc_slab(struct proto *prot, char *name)
+static rwlock_t proto__list_lock;
+static LIST_HEAD(proto__list);
+
+int proto__register(struct proto *prot, int alloc_slab)
 {
-	prot->slab = kmem_cache_create(name,
-				       prot->slab_obj_size, 0,
-				       SLAB_HWCACHE_ALIGN, NULL, NULL);
-
-	if (prot->slab == NULL) {
-		printk(KERN_CRIT "%s: Can't create sock SLAB cache!\n",
-		       prot->name);
-		return -ENOBUFS;
+	write_lock(&proto__list_lock);
+
+	if (alloc_slab) {
+		prot->slab = kmem_cache_create(prot->name, prot->obj_size, 0,
+					       SLAB_HWCACHE_ALIGN, NULL, NULL);
+
+		if (prot->slab == NULL) {
+			printk(KERN_CRIT "%s: Can't create sock SLAB cache!\n",
+			       prot->name);
+			return -ENOBUFS;
+		}
 	}
 
+	list_add(&prot->node, &proto__list);
+	write_unlock(&proto__list_lock);
 	return 0;
 }
 
-EXPORT_SYMBOL(sk_alloc_slab);
+EXPORT_SYMBOL(proto__register);
 
-void sk_free_slab(struct proto *prot)
+void proto__unregister(struct proto *prot)
 {
+	write_lock(&proto__list_lock);
 	if (prot->slab != NULL) {
 		kmem_cache_destroy(prot->slab);
 		prot->slab = NULL;
 	}
+
+	list_del(&prot->node);
+	write_unlock(&proto__list_lock);
+}
+
+EXPORT_SYMBOL(proto__unregister);
+
+#ifdef CONFIG_PROC_FS
+static inline struct proto *__proto__head(void)
+{
+	return list_entry(proto__list.next, struct proto, node);
+}
+
+static inline struct proto *proto__head(void)
+{
+	return list_empty(&proto__list) ? NULL : __proto__head();
+}
+
+static inline struct proto *proto__next(struct proto *proto)
+{
+	return proto->node.next == &proto__list ? NULL :
+		list_entry(proto->node.next, struct proto, node);
+}
+
+static inline struct proto *proto__get_idx(loff_t pos)
+{
+	struct proto *proto;
+	loff_t i = 0;
+
+	list_for_each_entry(proto, &proto__list, node)
+		if (i++ == pos)
+			goto out;
+
+	proto =  NULL;
+out:
+	return proto;
+}
+
+void *proto__seq_start(struct seq_file *seq, loff_t *pos)
+{
+	read_lock(&proto__list_lock);
+	return *pos ? proto__get_idx(*pos - 1) : SEQ_START_TOKEN;
+}
+
+void *proto__seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	++*pos;
+	return v == SEQ_START_TOKEN ? proto__head() : proto__next(v);
+}
+
+void proto__seq_stop(struct seq_file *seq, void *v)
+{
+	read_unlock(&proto__list_lock);
+}
+
+static char proto__method_implemented(const void *method)
+{
+	return method == NULL ? 'n' : 'y';
+}
+
+static void proto__seq_printf(struct seq_file *seq, struct proto *proto)
+{
+	seq_printf(seq, "%-9s %4u %6d  %6d   %-3s %6u   %-3s  %-10s "
+			"%2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c\n",
+		   proto->name,
+		   proto->obj_size,
+		   proto->sockets_allocated != NULL ? atomic_read(proto->sockets_allocated) : -1,
+		   proto->memory_allocated != NULL ? atomic_read(proto->memory_allocated) : -1,
+		   proto->memory_pressure != NULL ? *proto->memory_pressure ? "yes" : "no" : "NI",
+		   proto->max_header,
+		   proto->slab == NULL ? "no" : "yes",
+		   module_name(proto->owner),
+		   proto__method_implemented(proto->close),
+		   proto__method_implemented(proto->connect),
+		   proto__method_implemented(proto->disconnect),
+		   proto__method_implemented(proto->accept),
+		   proto__method_implemented(proto->ioctl),
+		   proto__method_implemented(proto->init),
+		   proto__method_implemented(proto->destroy),
+		   proto__method_implemented(proto->shutdown),
+		   proto__method_implemented(proto->setsockopt),
+		   proto__method_implemented(proto->getsockopt),
+		   proto__method_implemented(proto->sendmsg),
+		   proto__method_implemented(proto->recvmsg),
+		   proto__method_implemented(proto->sendpage),
+		   proto__method_implemented(proto->bind),
+		   proto__method_implemented(proto->backlog_rcv),
+		   proto__method_implemented(proto->hash),
+		   proto__method_implemented(proto->unhash),
+		   proto__method_implemented(proto->get_port),
+		   proto__method_implemented(proto->enter_memory_pressure));
 }
 
-EXPORT_SYMBOL(sk_free_slab);
+static int proto__seq_show(struct seq_file *seq, void *v)
+{
+	if (v == SEQ_START_TOKEN)
+		seq_printf(seq, "%-9s %-4s %-8s %-6s %-5s %-7s %-4s %-10s %s",
+			   "protocol",
+			   "size",
+			   "sockets",
+			   "memory",
+			   "press",
+			   "maxhdr",
+			   "slab",
+			   "module",
+			   "cl co di ac io in de sh ss gs se re sp bi br ha uh gp em\n");
+	else
+		proto__seq_printf(seq, v);
+	return 0;
+}
+
+static struct seq_operations proto__seq_ops = {
+	.start  = proto__seq_start,
+	.next   = proto__seq_next,
+	.stop   = proto__seq_stop,
+	.show   = proto__seq_show,
+};
+
+static int proto__seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &proto__seq_ops);
+}
+
+static struct file_operations proto__seq_fops = {
+	.owner		= THIS_MODULE,
+	.open		= proto__seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
+static int __init proto__init(void)
+{
+	/* register /proc/net/protocols */
+	return proc_net_fops_create("protocols", S_IRUGO, &proto__seq_fops) == NULL ? -ENOBUFS : 0;
+}
+
+subsys_initcall(proto__init);
+
+#endif /* PROC_FS */
 
 EXPORT_SYMBOL(sk_alloc);
 EXPORT_SYMBOL(sk_free);
diff -Nru a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
--- a/net/decnet/af_decnet.c	2005-03-25 21:30:20 -03:00
+++ b/net/decnet/af_decnet.c	2005-03-25 21:30:20 -03:00
@@ -149,7 +149,6 @@
 #define DN_SK_HASH_MASK (DN_SK_HASH_SIZE - 1)
 
 
-static kmem_cache_t *dn_sk_cachep;
 static struct proto_ops dn_proto_ops;
 static DEFINE_RWLOCK(dn_hash_lock);
 static struct hlist_head dn_sk_hash[DN_SK_HASH_SIZE];
@@ -447,11 +446,16 @@
 	dst_release(xchg(&sk->sk_dst_cache, NULL));
 }
 
+static struct proto dn__proto = {
+	.name	  = "DECNET",
+	.owner	  = THIS_MODULE,
+	.obj_size = sizeof(struct dn_sock),
+};
+
 static struct sock *dn_alloc_sock(struct socket *sock, int gfp)
 {
 	struct dn_scp *scp;
-	struct sock *sk = sk_alloc(PF_DECnet, gfp, sizeof(struct dn_sock),
-				   dn_sk_cachep);
+	struct sock *sk = sk_alloc(PF_DECnet, gfp, &dn__proto, 1);
 
 	if  (!sk)
 		goto out;
@@ -459,7 +463,6 @@
 	if (sock)
 		sock->ops = &dn_proto_ops;
 	sock_init_data(sock, sk);
-	sk_set_owner(sk, THIS_MODULE);
 
 	sk->sk_backlog_rcv = dn_nsp_backlog_rcv;
 	sk->sk_destruct    = dn_destruct;
@@ -2349,14 +2352,13 @@
 
 static int __init decnet_init(void)
 {
+	int rc;
+
         printk(banner);
 
-	dn_sk_cachep = kmem_cache_create("decnet_socket_cache",
-					 sizeof(struct dn_sock),
-					 0, SLAB_HWCACHE_ALIGN,
-					 NULL, NULL);
-	if (!dn_sk_cachep)
-		return -ENOMEM;
+	rc = proto__register(&dn__proto, 1);
+	if (rc != 0)
+		goto out;
 
 	dn_neigh_init();
 	dn_dev_init();
@@ -2369,8 +2371,8 @@
 
 	proc_net_fops_create("decnet", S_IRUGO, &dn_socket_seq_fops);
 	dn_register_sysctl();
-
-	return 0;
+out:
+	return rc;
 
 }
 module_init(decnet_init);
@@ -2397,7 +2399,7 @@
 
 	proc_net_remove("decnet");
 
-	kmem_cache_destroy(dn_sk_cachep);
+	proto__unregister(&dn__proto);
 }
 module_exit(decnet_exit);
 #endif
diff -Nru a/net/econet/af_econet.c b/net/econet/af_econet.c
--- a/net/econet/af_econet.c	2005-03-25 21:30:21 -03:00
+++ b/net/econet/af_econet.c	2005-03-25 21:30:21 -03:00
@@ -555,6 +555,13 @@
 	return 0;
 }
 
+static struct proto econet__proto = {
+	.name	  = "ECONET",
+	.owner	  = THIS_MODULE,
+	.slab	  = NULL,
+	.obj_size = sizeof(struct econet_sock),
+};
+
 /*
  *	Create an Econet socket
  */
@@ -572,15 +579,13 @@
 	sock->state = SS_UNCONNECTED;
 
 	err = -ENOBUFS;
-	sk = sk_alloc(PF_ECONET, GFP_KERNEL,
-		      sizeof(struct econet_sock), NULL);
+	sk = sk_alloc(PF_ECONET, GFP_KERNEL, &econet__proto, 1);
 	if (sk == NULL)
 		goto out;
 
 	sk->sk_reuse = 1;
 	sock->ops = &econet_ops;
-	sock_init_data(sock,sk);
-	sk_set_owner(sk, THIS_MODULE);
+	sock_init_data(sock, sk);
 
 	eo = ec_sk(sk);
 	sock_reset_flag(sk, SOCK_ZAPPED);
@@ -1096,10 +1101,15 @@
 #endif
 	unregister_netdevice_notifier(&econet_netdev_notifier);
 	sock_unregister(econet_family_ops.family);
+	proto__unregister(&econet__proto);
 }
 
 static int __init econet_proto_init(void)
 {
+	int rc = proto__register(&econet__proto, 0);
+
+	if (rc != 0)
+		goto out;
 	sock_register(&econet_family_ops);
 #ifdef CONFIG_ECONET_AUNUDP
 	spin_lock_init(&aun_queue_lock);
@@ -1109,7 +1119,8 @@
 	econet_hw_initialise();
 #endif
 	register_netdevice_notifier(&econet_netdev_notifier);
-	return 0;
+out:
+	return rc;
 }
 
 module_init(econet_proto_init);
diff -Nru a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
--- a/net/ipv4/af_inet.c	2005-03-25 21:30:20 -03:00
+++ b/net/ipv4/af_inet.c	2005-03-25 21:30:20 -03:00
@@ -281,14 +281,11 @@
 	BUG_TRAP(answer_prot->slab != NULL);
 
 	err = -ENOBUFS;
-	sk = sk_alloc(PF_INET, GFP_KERNEL,
-		      answer_prot->slab_obj_size,
-		      answer_prot->slab);
+	sk = sk_alloc(PF_INET, GFP_KERNEL, answer_prot, 1);
 	if (sk == NULL)
 		goto out;
 
 	err = 0;
-	sk->sk_prot = answer_prot;
 	sk->sk_no_check = answer_no_check;
 	if (INET_PROTOSW_REUSE & answer_flags)
 		sk->sk_reuse = 1;
@@ -309,7 +306,6 @@
 	inet->id = 0;
 
 	sock_init_data(sock, sk);
-	sk_set_owner(sk, sk->sk_prot->owner);
 
 	sk->sk_destruct	   = inet_sock_destruct;
 	sk->sk_family	   = PF_INET;
@@ -1026,17 +1022,17 @@
 		goto out;
 	}
 
-	rc = sk_alloc_slab(&tcp_prot, "tcp_sock");
+	rc = proto__register(&tcp_prot, 1);
 	if (rc)
 		goto out;
 
-	rc = sk_alloc_slab(&udp_prot, "udp_sock");
+	rc = proto__register(&udp_prot, 1);
 	if (rc)
-		goto out_tcp_free_slab;
+		goto out_unregister_tcp_proto;
 
-	rc = sk_alloc_slab(&raw_prot, "raw_sock");
+	rc = proto__register(&raw_prot, 1);
 	if (rc)
-		goto out_udp_free_slab;
+		goto out_unregister_udp_proto;
 
 	/*
 	 *	Tell SOCKET that we are alive... 
@@ -1110,10 +1106,10 @@
 	rc = 0;
 out:
 	return rc;
-out_tcp_free_slab:
-	sk_free_slab(&tcp_prot);
-out_udp_free_slab:
-	sk_free_slab(&udp_prot);
+out_unregister_tcp_proto:
+	proto__unregister(&tcp_prot);
+out_unregister_udp_proto:
+	proto__unregister(&udp_prot);
 	goto out;
 }
 
diff -Nru a/net/ipv4/raw.c b/net/ipv4/raw.c
--- a/net/ipv4/raw.c	2005-03-25 21:30:20 -03:00
+++ b/net/ipv4/raw.c	2005-03-25 21:30:20 -03:00
@@ -724,7 +724,7 @@
 	.backlog_rcv =	raw_rcv_skb,
 	.hash =		raw_v4_hash,
 	.unhash =	raw_v4_unhash,
-	.slab_obj_size = sizeof(struct raw_sock),
+	.obj_size =	sizeof(struct raw_sock),
 };
 
 #ifdef CONFIG_PROC_FS
diff -Nru a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
--- a/net/ipv4/syncookies.c	2005-03-25 21:30:21 -03:00
+++ b/net/ipv4/syncookies.c	2005-03-25 21:30:21 -03:00
@@ -179,10 +179,9 @@
 	struct sock *child;
 
 	child = tp->af_specific->syn_recv_sock(sk, skb, req, dst);
-	if (child) {
-		sk_set_owner(child, sk->sk_owner);
+	if (child)
 		tcp_acceptq_queue(sk, req, child);
-	} else
+	else
 		tcp_openreq_free(req);
 
 	return child;
diff -Nru a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	2005-03-25 21:30:20 -03:00
+++ b/net/ipv4/tcp_ipv4.c	2005-03-25 21:30:20 -03:00
@@ -2614,7 +2614,7 @@
 	.sysctl_wmem		= sysctl_tcp_wmem,
 	.sysctl_rmem		= sysctl_tcp_rmem,
 	.max_header		= MAX_TCP_HEADER,
-	.slab_obj_size		= sizeof(struct tcp_sock),
+	.obj_size		= sizeof(struct tcp_sock),
 };
 
 
diff -Nru a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
--- a/net/ipv4/tcp_minisocks.c	2005-03-25 21:30:21 -03:00
+++ b/net/ipv4/tcp_minisocks.c	2005-03-25 21:30:21 -03:00
@@ -688,8 +688,8 @@
 {
 	/* allocate the newsk from the same slab of the master sock,
 	 * if not, at sk_free time we'll try to free it from the wrong
-	 * slabcache (i.e. is it TCPv4 or v6?) -acme */
-	struct sock *newsk = sk_alloc(PF_INET, GFP_ATOMIC, 0, sk->sk_prot->slab);
+	 * slabcache (i.e. is it TCPv4 or v6?), this is handled thru sk->sk_prot -acme */
+	struct sock *newsk = sk_alloc(PF_INET, GFP_ATOMIC, sk->sk_prot, 0);
 
 	if(newsk != NULL) {
 		struct tcp_sock *newtp;
@@ -807,7 +807,6 @@
 						  keepalive_time_when(newtp));
 		newsk->sk_socket = NULL;
 		newsk->sk_sleep = NULL;
-		newsk->sk_owner = NULL;
 
 		newtp->rx_opt.tstamp_ok = req->tstamp_ok;
 		if((newtp->rx_opt.sack_ok = req->sack_ok) != 0) {
@@ -1019,7 +1018,6 @@
 		if (child == NULL)
 			goto listen_overflow;
 
-		sk_set_owner(child, sk->sk_owner);
 		tcp_synq_unlink(tp, req, prev);
 		tcp_synq_removed(sk, req);
 
diff -Nru a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c	2005-03-25 21:30:20 -03:00
+++ b/net/ipv4/udp.c	2005-03-25 21:30:20 -03:00
@@ -1371,7 +1371,7 @@
 	.hash =		udp_v4_hash,
 	.unhash =	udp_v4_unhash,
 	.get_port =	udp_v4_get_port,
-	.slab_obj_size = sizeof(struct udp_sock),
+	.obj_size =	sizeof(struct udp_sock),
 };
 
 /* ------------------------------------------------------------------------ */
diff -Nru a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
--- a/net/ipv6/af_inet6.c	2005-03-25 21:30:20 -03:00
+++ b/net/ipv6/af_inet6.c	2005-03-25 21:30:20 -03:00
@@ -107,7 +107,7 @@
 
 static __inline__ struct ipv6_pinfo *inet6_sk_generic(struct sock *sk)
 {
-	const int offset = sk->sk_prot->slab_obj_size - sizeof(struct ipv6_pinfo);
+	const int offset = sk->sk_prot->obj_size - sizeof(struct ipv6_pinfo);
 
 	return (struct ipv6_pinfo *)(((u8 *)sk) + offset);
 }
@@ -166,15 +166,11 @@
 	BUG_TRAP(answer_prot->slab != NULL);
 
 	rc = -ENOBUFS;
-	sk = sk_alloc(PF_INET6, GFP_KERNEL,
-		      answer_prot->slab_obj_size,
-		      answer_prot->slab);
+	sk = sk_alloc(PF_INET6, GFP_KERNEL, answer_prot, 1);
 	if (sk == NULL)
 		goto out;
 
 	sock_init_data(sock, sk);
-	sk->sk_prot = answer_prot;
-	sk_set_owner(sk, sk->sk_prot->owner);
 
 	rc = 0;
 	sk->sk_no_check = answer_no_check;
@@ -710,17 +706,17 @@
 		return -EINVAL;
 	}
 
-	err = sk_alloc_slab(&tcpv6_prot, "tcpv6_sock");
+	err = proto__register(&tcpv6_prot, 1);
 	if (err)
 		goto out;
 
-	err = sk_alloc_slab(&udpv6_prot, "udpv6_sock");
+	err = proto__register(&udpv6_prot, 1);
 	if (err)
-		goto out_tcp_free_slab;
+		goto out_unregister_tcp_proto;
 
-	err = sk_alloc_slab(&rawv6_prot, "rawv6_sock");
+	err = proto__register(&rawv6_prot, 1);
 	if (err)
-		goto out_udp_free_slab;
+		goto out_unregister_udp_proto;
 
 
 	/* Register the socket-side information for inet6_create.  */
@@ -740,7 +736,7 @@
 	/* Initialise ipv6 mibs */
 	err = init_ipv6_mibs();
 	if (err)
-		goto out_raw_free_slab;
+		goto out_unregister_raw_proto;
 	
 	/*
 	 *	ipngwg API draft makes clear that the correct semantics
@@ -827,12 +823,12 @@
 	ipv6_sysctl_unregister();
 #endif
 	cleanup_ipv6_mibs();
-out_raw_free_slab:
-	sk_free_slab(&rawv6_prot);
-out_udp_free_slab:
-	sk_free_slab(&udpv6_prot);
-out_tcp_free_slab:
-	sk_free_slab(&tcpv6_prot);
+out_unregister_raw_proto:
+	proto__unregister(&rawv6_prot);
+out_unregister_udp_proto:
+	proto__unregister(&udpv6_prot);
+out_unregister_tcp_proto:
+	proto__unregister(&tcpv6_prot);
 	goto out;
 }
 module_init(inet6_init);
@@ -862,9 +858,9 @@
 	ipv6_sysctl_unregister();	
 #endif
 	cleanup_ipv6_mibs();
-	sk_free_slab(&rawv6_prot);
-	sk_free_slab(&udpv6_prot);
-	sk_free_slab(&tcpv6_prot);
+	proto__unregister(&rawv6_prot);
+	proto__unregister(&udpv6_prot);
+	proto__unregister(&tcpv6_prot);
 }
 module_exit(inet6_exit);
 
diff -Nru a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c	2005-03-25 21:30:20 -03:00
+++ b/net/ipv6/raw.c	2005-03-25 21:30:20 -03:00
@@ -977,7 +977,7 @@
 }
 
 struct proto rawv6_prot = {
-	.name =		"RAW",
+	.name =		"RAWv6",
 	.owner =	THIS_MODULE,
 	.close =	rawv6_close,
 	.connect =	ip6_datagram_connect,
@@ -993,7 +993,7 @@
 	.backlog_rcv =	rawv6_rcv_skb,
 	.hash =		raw_v6_hash,
 	.unhash =	raw_v6_unhash,
-	.slab_obj_size = sizeof(struct raw6_sock),
+	.obj_size =	sizeof(struct raw6_sock),
 };
 
 #ifdef CONFIG_PROC_FS
diff -Nru a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	2005-03-25 21:30:20 -03:00
+++ b/net/ipv6/tcp_ipv6.c	2005-03-25 21:30:20 -03:00
@@ -2235,7 +2235,7 @@
 	.sysctl_wmem		= sysctl_tcp_wmem,
 	.sysctl_rmem		= sysctl_tcp_rmem,
 	.max_header		= MAX_TCP_HEADER,
-	.slab_obj_size		= sizeof(struct tcp6_sock),
+	.obj_size		= sizeof(struct tcp6_sock),
 };
 
 static struct inet6_protocol tcpv6_protocol = {
diff -Nru a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c	2005-03-25 21:30:21 -03:00
+++ b/net/ipv6/udp.c	2005-03-25 21:30:21 -03:00
@@ -1036,7 +1036,7 @@
 /* ------------------------------------------------------------------------ */
 
 struct proto udpv6_prot = {
-	.name =		"UDP",
+	.name =		"UDPv6",
 	.owner =	THIS_MODULE,
 	.close =	udpv6_close,
 	.connect =	ip6_datagram_connect,
@@ -1051,7 +1051,7 @@
 	.hash =		udp_v6_hash,
 	.unhash =	udp_v6_unhash,
 	.get_port =	udp_v6_get_port,
-	.slab_obj_size = sizeof(struct udp6_sock),
+	.obj_size =	sizeof(struct udp6_sock),
 };
 
 extern struct proto_ops inet6_dgram_ops;
diff -Nru a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
--- a/net/ipx/af_ipx.c	2005-03-25 21:30:20 -03:00
+++ b/net/ipx/af_ipx.c	2005-03-25 21:30:20 -03:00
@@ -80,8 +80,6 @@
 LIST_HEAD(ipx_interfaces);
 DEFINE_SPINLOCK(ipx_interfaces_lock);
 
-static kmem_cache_t *ipx_sk_slab;
-
 struct ipx_interface *ipx_primary_net;
 struct ipx_interface *ipx_internal_net;
 
@@ -1347,6 +1345,12 @@
 	return rc;
 }
 
+static struct proto ipx__proto = {
+	.name	  = "IPX",
+	.owner	  = THIS_MODULE,
+	.obj_size = sizeof(struct ipx_sock),
+};
+
 static int ipx_create(struct socket *sock, int protocol)
 {
 	int rc = -ESOCKTNOSUPPORT;
@@ -1361,8 +1365,8 @@
 	if (sock->type != SOCK_DGRAM)
 		goto out;
 
-	sk = sk_alloc(PF_IPX, GFP_KERNEL, sizeof(struct ipx_sock), ipx_sk_slab);
        	rc = -ENOMEM;
+	sk = sk_alloc(PF_IPX, GFP_KERNEL, &ipx__proto, 1);
 	if (!sk)
 		goto out;
 #ifdef IPX_REFCNT_DEBUG
@@ -1371,7 +1375,6 @@
 			atomic_read(&ipx_sock_nr));
 #endif
 	sock_init_data(sock, sk);
-	sk_set_owner(sk, THIS_MODULE);
 	sk->sk_no_check = 1;		/* Checksum off by default */
 	sock->ops = &ipx_dgram_ops;
 	rc = 0;
@@ -1954,12 +1957,10 @@
 
 static int __init ipx_init(void)
 {
-	ipx_sk_slab = kmem_cache_create("ipx_sock",
-					sizeof(struct ipx_sock), 0,
-					SLAB_HWCACHE_ALIGN, NULL, NULL);
+	int rc = proto__register(&ipx__proto, 1);
 
-	if (ipx_sk_slab == NULL)
-		return -ENOMEM;
+	if (rc != 0)
+		goto out;
 
 	sock_register(&ipx_family_ops);
 
@@ -1986,7 +1987,8 @@
 	register_netdevice_notifier(&ipx_dev_notifier);
 	ipx_register_sysctl();
 	ipx_proc_init();
-	return 0;
+out:
+	return rc;
 }
 
 static void __exit ipx_proto_finito(void)
@@ -2012,11 +2014,7 @@
 	destroy_EII_client(pEII_datalink);
 	pEII_datalink = NULL;
 
-	if (ipx_sk_slab != NULL) {
-		kmem_cache_destroy(ipx_sk_slab);
-		ipx_sk_slab = NULL;
-	}
-
+	proto__unregister(&ipx__proto);
 	sock_unregister(ipx_family_ops.family);
 }
 
diff -Nru a/net/irda/af_irda.c b/net/irda/af_irda.c
--- a/net/irda/af_irda.c	2005-03-25 21:30:21 -03:00
+++ b/net/irda/af_irda.c	2005-03-25 21:30:21 -03:00
@@ -1071,6 +1071,13 @@
 	return 0;
 }
 
+static struct proto irda__proto = {
+	.name	  = "IRDA",
+	.owner	  = THIS_MODULE,
+	.slab	  = NULL,
+	.obj_size = sizeof(struct irda_sock),
+};
+
 /*
  * Function irda_create (sock, protocol)
  *
@@ -1095,8 +1102,7 @@
 	}
 
 	/* Allocate networking socket */
-	sk = sk_alloc(PF_IRDA, GFP_ATOMIC,
-		      sizeof(struct irda_sock), NULL);
+	sk = sk_alloc(PF_IRDA, GFP_ATOMIC, &irda__proto, 1);
 	if (sk == NULL)
 		return -ENOMEM;
 
@@ -1107,7 +1113,6 @@
 
 	/* Initialise networking socket struct */
 	sock_init_data(sock, sk);	/* Note : set sk->sk_refcnt to 1 */
-	sk_set_owner(sk, THIS_MODULE);
 	sk->sk_family = PF_IRDA;
 	sk->sk_protocol = protocol;
 
@@ -2561,9 +2566,12 @@
  */
 int __init irsock_init(void)
 {
-	sock_register(&irda_family_ops);
+	int rc = proto__register(&irda__proto, 0);
 
-	return 0;
+	if (rc == 0)
+		sock_register(&irda_family_ops);
+
+	return rc;
 }
 
 /*
@@ -2575,6 +2583,5 @@
 void __exit irsock_cleanup(void)
 {
 	sock_unregister(PF_IRDA);
-
-        return;
+	proto__unregister(&irda__proto);
 }
diff -Nru a/net/key/af_key.c b/net/key/af_key.c
--- a/net/key/af_key.c	2005-03-25 21:30:21 -03:00
+++ b/net/key/af_key.c	2005-03-25 21:30:21 -03:00
@@ -129,6 +129,13 @@
 	pfkey_table_ungrab();
 }
 
+static struct proto key__proto = {
+	.name	  = "KEY",
+	.owner	  = THIS_MODULE,
+	.slab	  = NULL,
+	.obj_size = sizeof(struct pfkey_sock),
+};
+
 static int pfkey_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;
@@ -142,13 +149,12 @@
 		return -EPROTONOSUPPORT;
 
 	err = -ENOMEM;
-	sk = sk_alloc(PF_KEY, GFP_KERNEL, sizeof(struct pfkey_sock), NULL);
+	sk = sk_alloc(PF_KEY, GFP_KERNEL, &key__proto, 1);
 	if (sk == NULL)
 		goto out;
 	
 	sock->ops = &pfkey_ops;
 	sock_init_data(sock, sk);
-	sk_set_owner(sk, THIS_MODULE);
 
 	sk->sk_family = PF_KEY;
 	sk->sk_destruct = pfkey_sock_destruct;
@@ -2858,16 +2864,38 @@
 	xfrm_unregister_km(&pfkeyv2_mgr);
 	remove_proc_entry("net/pfkey", NULL);
 	sock_unregister(PF_KEY);
+	proto__unregister(&key__proto);
 }
 
 static int __init ipsec_pfkey_init(void)
 {
-	sock_register(&pfkey_family_ops);
+	int rc = proto__register(&key__proto, 0);
+
+	if (rc != 0)
+		goto out;
+
+	rc = sock_register(&pfkey_family_ops);
+	if (rc != 0)
+		goto out_unregister_key_proto;
 #ifdef CONFIG_PROC_FS
-	create_proc_read_entry("net/pfkey", 0, NULL, pfkey_read_proc, NULL);
+	rc = -ENOMEM;
+	if (create_proc_read_entry("net/pfkey", 0, NULL, pfkey_read_proc, NULL) == NULL)
+		goto out_sock_unregister;
+#endif
+	rc = xfrm_register_km(&pfkeyv2_mgr);
+	if (rc != 0)
+		goto out_remove_proc_entry;
+out:
+	return rc;
+out_remove_proc_entry:
+#ifdef CONFIG_PROC_FS
+	remove_proc_entry("net/pfkey", NULL);
+out_sock_unregister:
 #endif
-	xfrm_register_km(&pfkeyv2_mgr);
-	return 0;
+	sock_unregister(PF_KEY);
+out_unregister_key_proto:
+	proto__unregister(&key__proto);
+	goto out;
 }
 
 module_init(ipsec_pfkey_init);
diff -Nru a/net/llc/af_llc.c b/net/llc/af_llc.c
--- a/net/llc/af_llc.c	2005-03-25 21:30:20 -03:00
+++ b/net/llc/af_llc.c	2005-03-25 21:30:20 -03:00
@@ -135,6 +135,13 @@
 	sock->ops	= &llc_ui_ops;
 }
 
+static struct proto llc__proto = {
+	.name	  = "DDP",
+	.owner	  = THIS_MODULE,
+	.slab	  = NULL,
+	.obj_size = sizeof(struct llc_sock),
+};
+
 /**
  *	llc_ui_create - alloc and init a new llc_ui socket
  *	@sock: Socket to initialize and attach allocated sk to.
@@ -151,7 +158,7 @@
 
 	if (sock->type == SOCK_DGRAM || sock->type == SOCK_STREAM) {
 		rc = -ENOMEM;
-		sk = llc_sk_alloc(PF_LLC, GFP_KERNEL);
+		sk = llc_sk_alloc(PF_LLC, GFP_KERNEL, &llc__proto);
 		if (sk) {
 			rc = 0;
 			llc_ui_sk_init(sock, sk);
@@ -1033,18 +1040,25 @@
 
 static int __init llc2_init(void)
 {
-	int rc;
+	int rc = proto__register(&llc__proto, 0);
+
+	if (rc != 0)
+		goto out;
 
 	llc_build_offset_table();
 	llc_station_init();
 	llc_ui_sap_last_autoport = LLC_SAP_DYN_START;
 	rc = llc_proc_init();
-	if (!rc) {
-		sock_register(&llc_ui_family_ops);
-		llc_add_pack(LLC_DEST_SAP, llc_sap_handler);
-		llc_add_pack(LLC_DEST_CONN, llc_conn_handler);
-	}
+	if (rc != 0)
+		goto out_unregister_llc_proto;
+	sock_register(&llc_ui_family_ops);
+	llc_add_pack(LLC_DEST_SAP, llc_sap_handler);
+	llc_add_pack(LLC_DEST_CONN, llc_conn_handler);
+out:
 	return rc;
+out_unregister_llc_proto:
+	proto__unregister(&llc__proto);
+	goto out;
 }
 
 static void __exit llc2_exit(void)
@@ -1054,6 +1068,7 @@
 	llc_remove_pack(LLC_DEST_CONN);
 	sock_unregister(PF_LLC);
 	llc_proc_exit();
+	proto__unregister(&llc__proto);
 }
 
 module_init(llc2_init);
diff -Nru a/net/llc/llc_conn.c b/net/llc/llc_conn.c
--- a/net/llc/llc_conn.c	2005-03-25 21:30:20 -03:00
+++ b/net/llc/llc_conn.c	2005-03-25 21:30:20 -03:00
@@ -683,7 +683,7 @@
 			goto drop;
 		}
 
-		sk = llc_sk_alloc(parent->sk_family, GFP_ATOMIC);
+		sk = llc_sk_alloc(parent->sk_family, GFP_ATOMIC, parent->sk_prot);
 		if (!sk) {
 			sock_put(parent);
 			goto drop;
@@ -830,16 +830,14 @@
  *	Allocates a LLC sock and initializes it. Returns the new LLC sock
  *	or %NULL if there's no memory available for one
  */
-struct sock *llc_sk_alloc(int family, int priority)
+struct sock *llc_sk_alloc(int family, int priority, struct proto *prot)
 {
-	struct sock *sk = sk_alloc(family, priority,
-				   sizeof(struct llc_sock), NULL);
+	struct sock *sk = sk_alloc(family, priority, prot, 1);
 
 	if (!sk)
 		goto out;
 	llc_sk_init(sk);
 	sock_init_data(NULL, sk);
-	sk_set_owner(sk, THIS_MODULE);
 #ifdef LLC_REFCNT_DEBUG
 	atomic_inc(&llc_sock_nr);
 	printk(KERN_DEBUG "LLC socket %p created in %s, now we have %d alive\n", sk,
diff -Nru a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
--- a/net/netlink/af_netlink.c	2005-03-25 21:30:20 -03:00
+++ b/net/netlink/af_netlink.c	2005-03-25 21:30:20 -03:00
@@ -321,6 +321,13 @@
 	netlink_table_ungrab();
 }
 
+static struct proto netlink__proto = {
+	.name	  = "NETLINK",
+	.owner	  = THIS_MODULE,
+	.slab	  = NULL,
+	.obj_size = sizeof(struct netlink_sock),
+};
+
 static int netlink_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;
@@ -336,13 +343,11 @@
 
 	sock->ops = &netlink_ops;
 
-	sk = sk_alloc(PF_NETLINK, GFP_KERNEL,
-		      sizeof(struct netlink_sock), NULL);
+	sk = sk_alloc(PF_NETLINK, GFP_KERNEL, &netlink__proto, 1);
 	if (!sk)
 		return -ENOMEM;
 
-	sock_init_data(sock,sk);
-	sk_set_owner(sk, THIS_MODULE);
+	sock_init_data(sock, sk);
 
 	nlk = nlk_sk(sk);
 
@@ -1367,6 +1372,10 @@
 	int i;
 	unsigned long max;
 	unsigned int order;
+	int rc = proto__register(&netlink__proto, 0);
+
+	if (rc != 0)
+		goto out;
 
 	if (sizeof(struct netlink_skb_parms) > sizeof(dummy_skb->cb))
 		netlink_skb_parms_too_large();
@@ -1413,15 +1422,17 @@
 #endif
 	/* The netlink device handler may be needed early. */ 
 	rtnetlink_init();
-	return 0;
+out:
+	return rc;
 }
 
 static void __exit netlink_proto_exit(void)
 {
-       sock_unregister(PF_NETLINK);
-       proc_net_remove("netlink");
-       kfree(nl_table);
-       nl_table = NULL;
+	sock_unregister(PF_NETLINK);
+	proc_net_remove("netlink");
+	kfree(nl_table);
+	nl_table = NULL;
+	proto__unregister(&netlink__proto);
 }
 
 core_initcall(netlink_proto_init);
diff -Nru a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
--- a/net/netrom/af_netrom.c	2005-03-25 21:30:20 -03:00
+++ b/net/netrom/af_netrom.c	2005-03-25 21:30:20 -03:00
@@ -64,11 +64,6 @@
 
 static struct proto_ops nr_proto_ops;
 
-static struct sock *nr_alloc_sock(void)
-{
-	return  sk_alloc(PF_NETROM, GFP_ATOMIC, sizeof(struct nr_sock), NULL);
-}
-
 /*
  *	Socket removal during an interrupt is now safe.
  */
@@ -398,6 +393,13 @@
 	return -EOPNOTSUPP;
 }
 
+static struct proto nr__proto = {
+	.name	  = "NETROM",
+	.owner	  = THIS_MODULE,
+	.slab	  = NULL,
+	.obj_size = sizeof(struct nr_sock),
+};
+
 static int nr_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;
@@ -406,13 +408,12 @@
 	if (sock->type != SOCK_SEQPACKET || protocol != 0)
 		return -ESOCKTNOSUPPORT;
 
-	if ((sk = nr_alloc_sock()) == NULL)
+	if ((sk = sk_alloc(PF_NETROM, GFP_ATOMIC, &nr__proto, 1)) == NULL)
 		return -ENOMEM;
 
 	nr = nr_sk(sk);
 
 	sock_init_data(sock, sk);
-	sk_set_owner(sk, THIS_MODULE);
 
 	sock->ops    = &nr_proto_ops;
 	sk->sk_protocol = protocol;
@@ -444,13 +445,12 @@
 	if (osk->sk_type != SOCK_SEQPACKET)
 		return NULL;
 
-	if ((sk = nr_alloc_sock()) == NULL)
+	if ((sk = sk_alloc(PF_NETROM, GFP_ATOMIC, osk->sk_prot, 1)) == NULL)
 		return NULL;
 
 	nr = nr_sk(sk);
 
 	sock_init_data(NULL, sk);
-	sk_set_owner(sk, THIS_MODULE);
 
 	sk->sk_type     = osk->sk_type;
 	sk->sk_socket   = osk->sk_socket;
@@ -1368,6 +1368,10 @@
 static int __init nr_proto_init(void)
 {
 	int i;
+	int rc = proto__register(&nr__proto, 0);
+
+	if (rc != 0)
+		goto out;
 
 	if (nr_ndevs > 0x7fffffff/sizeof(struct net_device *)) {
 		printk(KERN_ERR "NET/ROM: nr_proto_init - nr_ndevs parameter to large\n");
@@ -1423,15 +1427,17 @@
 	proc_net_fops_create("nr", S_IRUGO, &nr_info_fops);
 	proc_net_fops_create("nr_neigh", S_IRUGO, &nr_neigh_fops);
 	proc_net_fops_create("nr_nodes", S_IRUGO, &nr_nodes_fops);
-	return 0;
-
- fail:
+out:
+	return rc;
+fail:
 	while (--i >= 0) {
 		unregister_netdev(dev_nr[i]);
 		free_netdev(dev_nr[i]);
 	}
 	kfree(dev_nr);
-	return -1;
+	proto__unregister(&nr__proto);
+	rc = -1;
+	goto out;
 }
 
 module_init(nr_proto_init);
@@ -1475,5 +1481,6 @@
 	}
 
 	kfree(dev_nr);
+	proto__unregister(&nr__proto);
 }
 module_exit(nr_exit);
diff -Nru a/net/packet/af_packet.c b/net/packet/af_packet.c
--- a/net/packet/af_packet.c	2005-03-25 21:30:21 -03:00
+++ b/net/packet/af_packet.c	2005-03-25 21:30:21 -03:00
@@ -955,6 +955,12 @@
 	return err;
 }
 
+static struct proto packet__proto = {
+	.name	  = "PACKET",
+	.owner	  = THIS_MODULE,
+	.slab	  = NULL,
+	.obj_size = sizeof(struct packet_sock),
+};
 
 /*
  *	Create a packet of type SOCK_PACKET. 
@@ -978,8 +984,7 @@
 	sock->state = SS_UNCONNECTED;
 
 	err = -ENOBUFS;
-	sk = sk_alloc(PF_PACKET, GFP_KERNEL,
-		      sizeof(struct packet_sock), NULL);
+	sk = sk_alloc(PF_PACKET, GFP_KERNEL, &packet__proto, 1);
 	if (sk == NULL)
 		goto out;
 
@@ -988,8 +993,7 @@
 	if (sock->type == SOCK_PACKET)
 		sock->ops = &packet_ops_spkt;
 #endif
-	sock_init_data(sock,sk);
-	sk_set_owner(sk, THIS_MODULE);
+	sock_init_data(sock, sk);
 
 	po = pkt_sk(sk);
 	sk->sk_family = PF_PACKET;
@@ -1881,16 +1885,21 @@
 	proc_net_remove("packet");
 	unregister_netdevice_notifier(&packet_netdev_notifier);
 	sock_unregister(PF_PACKET);
-	return;
+	proto__unregister(&packet__proto);
 }
 
 static int __init packet_init(void)
 {
+	int rc = proto__register(&packet__proto, 0);
+
+	if (rc != 0)
+		goto out;
+
 	sock_register(&packet_family_ops);
 	register_netdevice_notifier(&packet_netdev_notifier);
 	proc_net_fops_create("packet", 0, &packet_seq_fops);
-
-	return 0;
+out:
+	return rc;
 }
 
 module_init(packet_init);
diff -Nru a/net/rose/af_rose.c b/net/rose/af_rose.c
--- a/net/rose/af_rose.c	2005-03-25 21:30:20 -03:00
+++ b/net/rose/af_rose.c	2005-03-25 21:30:20 -03:00
@@ -126,11 +126,6 @@
 	return 0;
 }
 
-static struct sock *rose_alloc_sock(void)
-{
-	return sk_alloc(PF_ROSE, GFP_ATOMIC, sizeof(struct rose_sock), NULL);
-}
-
 /*
  *	Socket removal during an interrupt is now safe.
  */
@@ -488,6 +483,13 @@
 	return -EOPNOTSUPP;
 }
 
+static struct proto rose__proto = {
+	.name	  = "ROSE",
+	.owner	  = THIS_MODULE,
+	.slab	  = NULL,
+	.obj_size = sizeof(struct rose_sock),
+};
+
 static int rose_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;
@@ -496,13 +498,12 @@
 	if (sock->type != SOCK_SEQPACKET || protocol != 0)
 		return -ESOCKTNOSUPPORT;
 
-	if ((sk = rose_alloc_sock()) == NULL)
+	if ((sk = sk_alloc(PF_ROSE, GFP_ATOMIC, &rose__proto, 1)) == NULL)
 		return -ENOMEM;
 
 	rose = rose_sk(sk);
 
 	sock_init_data(sock, sk);
-	sk_set_owner(sk, THIS_MODULE);
 
 	skb_queue_head_init(&rose->ack_queue);
 #ifdef M_BIT
@@ -535,13 +536,12 @@
 	if (osk->sk_type != SOCK_SEQPACKET)
 		return NULL;
 
-	if ((sk = rose_alloc_sock()) == NULL)
+	if ((sk = sk_alloc(PF_ROSE, GFP_ATOMIC, &rose__proto, 1)) == NULL)
 		return NULL;
 
 	rose = rose_sk(sk);
 
 	sock_init_data(NULL, sk);
-	sk_set_owner(sk, THIS_MODULE);
 
 	skb_queue_head_init(&rose->ack_queue);
 #ifdef M_BIT
@@ -1472,6 +1472,10 @@
 static int __init rose_proto_init(void)
 {
 	int i;
+	int rc = proto__register(&rose__proto, 0);
+
+	if (rc != 0)
+		goto out;
 
 	rose_callsign = null_ax25_address;
 
@@ -1524,14 +1528,15 @@
 	proc_net_fops_create("rose_neigh", S_IRUGO, &rose_neigh_fops);
 	proc_net_fops_create("rose_nodes", S_IRUGO, &rose_nodes_fops);
 	proc_net_fops_create("rose_routes", S_IRUGO, &rose_routes_fops);
-
-	return 0;
+out:
+	return rc;
 fail:
 	while (--i >= 0) {
 		unregister_netdev(dev_rose[i]);
 		free_netdev(dev_rose[i]);
 	}
 	kfree(dev_rose);
+	proto__unregister(&rose__proto);
 	return -ENOMEM;
 }
 module_init(rose_proto_init);
@@ -1579,6 +1584,7 @@
 	}
 
 	kfree(dev_rose);
+	proto__unregister(&rose__proto);
 }
 
 module_exit(rose_exit);
diff -Nru a/net/sctp/ipv6.c b/net/sctp/ipv6.c
--- a/net/sctp/ipv6.c	2005-03-25 21:30:20 -03:00
+++ b/net/sctp/ipv6.c	2005-03-25 21:30:20 -03:00
@@ -594,13 +594,11 @@
 	struct ipv6_pinfo *newnp, *np = inet6_sk(sk);
 	struct sctp6_sock *newsctp6sk;
 
-	newsk = sk_alloc(PF_INET6, GFP_KERNEL, sk->sk_prot->slab_obj_size,
-			 sk->sk_prot->slab);
+	newsk = sk_alloc(PF_INET6, GFP_KERNEL, sk->sk_prot, 1);
 	if (!newsk)
 		goto out;
 
 	sock_init_data(NULL, newsk);
-	sk_set_owner(newsk, THIS_MODULE);
 
 	newsk->sk_type = SOCK_STREAM;
 
@@ -974,14 +972,14 @@
 /* Initialize IPv6 support and register with inet6 stack.  */
 int sctp_v6_init(void)
 {
-	int rc = sk_alloc_slab(&sctpv6_prot, "sctpv6_sock");
+	int rc = proto__register(&sctpv6_prot, 1);
 
 	if (rc)
 		goto out;
 	/* Register inet6 protocol. */
 	rc = -EAGAIN;
 	if (inet6_add_protocol(&sctpv6_protocol, IPPROTO_SCTP) < 0)
-		goto out_sctp_free_slab;
+		goto out_unregister_sctp_proto;
 
 	/* Add SCTPv6(UDP and TCP style) to inetsw6 linked list. */
 	inet6_register_protosw(&sctpv6_seqpacket_protosw);
@@ -998,8 +996,8 @@
 	rc = 0;
 out:
 	return rc;
-out_sctp_free_slab:
-	sk_free_slab(&sctpv6_prot);
+out_unregister_sctp_proto:
+	proto__unregister(&sctpv6_prot);
 	goto out;
 }
 
@@ -1011,5 +1009,5 @@
 	inet6_unregister_protosw(&sctpv6_seqpacket_protosw);
 	inet6_unregister_protosw(&sctpv6_stream_protosw);
 	unregister_inet6addr_notifier(&sctp_inet6addr_notifier);
-	sk_free_slab(&sctpv6_prot);
+	proto__unregister(&sctpv6_prot);
 }
diff -Nru a/net/sctp/protocol.c b/net/sctp/protocol.c
--- a/net/sctp/protocol.c	2005-03-25 21:30:20 -03:00
+++ b/net/sctp/protocol.c	2005-03-25 21:30:20 -03:00
@@ -550,21 +550,17 @@
 static struct sock *sctp_v4_create_accept_sk(struct sock *sk,
 					     struct sctp_association *asoc)
 {
-	struct sock *newsk;
 	struct inet_sock *inet = inet_sk(sk);
 	struct inet_sock *newinet;
+	struct sock *newsk = sk_alloc(PF_INET, GFP_KERNEL, sk->sk_prot, 1);
 
-	newsk = sk_alloc(PF_INET, GFP_KERNEL, sk->sk_prot->slab_obj_size,
-			 sk->sk_prot->slab);
 	if (!newsk)
 		goto out;
 
 	sock_init_data(NULL, newsk);
-	sk_set_owner(newsk, THIS_MODULE);
 
 	newsk->sk_type = SOCK_STREAM;
 
-	newsk->sk_prot = sk->sk_prot;
 	newsk->sk_no_check = sk->sk_no_check;
 	newsk->sk_reuse = sk->sk_reuse;
 	newsk->sk_shutdown = sk->sk_shutdown;
@@ -970,7 +966,7 @@
 	if (!sctp_sanity_check())
 		goto out;
 
-	status = sk_alloc_slab(&sctp_prot, "sctp_sock");
+	status = proto__register(&sctp_prot, 1);
 	if (status)
 		goto out;
 
@@ -1164,7 +1160,7 @@
 out:
 	return status;
 err_add_protocol:
-	sk_free_slab(&sctp_prot);
+	proto__unregister(&sctp_prot);
 err_ctl_sock_init:
 	sctp_v6_exit();
 err_v6_init:
@@ -1233,7 +1229,7 @@
 	inet_del_protocol(&sctp_protocol, IPPROTO_SCTP);
 	inet_unregister_protosw(&sctp_seqpacket_protosw);
 	inet_unregister_protosw(&sctp_stream_protosw);
-	sk_free_slab(&sctp_prot);
+	proto__unregister(&sctp_prot);
 }
 
 module_init(sctp_init);
diff -Nru a/net/sctp/socket.c b/net/sctp/socket.c
--- a/net/sctp/socket.c	2005-03-25 21:30:21 -03:00
+++ b/net/sctp/socket.c	2005-03-25 21:30:21 -03:00
@@ -4768,7 +4768,7 @@
 	.hash        =	sctp_hash,
 	.unhash      =	sctp_unhash,
 	.get_port    =	sctp_get_port,
-	.slab_obj_size = sizeof(struct sctp_sock),
+	.obj_size    =  sizeof(struct sctp_sock),
 };
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
@@ -4792,6 +4792,6 @@
 	.hash		= sctp_hash,
 	.unhash		= sctp_unhash,
 	.get_port	= sctp_get_port,
-	.slab_obj_size	= sizeof(struct sctp6_sock),
+	.obj_size	= sizeof(struct sctp6_sock),
 };
 #endif /* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
diff -Nru a/net/unix/af_unix.c b/net/unix/af_unix.c
--- a/net/unix/af_unix.c	2005-03-25 21:30:20 -03:00
+++ b/net/unix/af_unix.c	2005-03-25 21:30:21 -03:00
@@ -121,8 +121,6 @@
 
 int sysctl_unix_max_dgram_qlen = 10;
 
-static kmem_cache_t *unix_sk_cachep;
-
 struct hlist_head unix_socket_table[UNIX_HASH_SIZE + 1];
 DEFINE_RWLOCK(unix_table_lock);
 static atomic_t unix_nr_socks = ATOMIC_INIT(0);
@@ -532,6 +530,12 @@
 	.sendpage =	sock_no_sendpage,
 };
 
+static struct proto unix__proto = {
+	.name	  = "UNIX",
+	.owner	  = THIS_MODULE,
+	.obj_size = sizeof(struct unix_sock),
+};
+
 static struct sock * unix_create1(struct socket *sock)
 {
 	struct sock *sk = NULL;
@@ -540,15 +544,13 @@
 	if (atomic_read(&unix_nr_socks) >= 2*files_stat.max_files)
 		goto out;
 
-	sk = sk_alloc(PF_UNIX, GFP_KERNEL, sizeof(struct unix_sock),
-		      unix_sk_cachep);
+	sk = sk_alloc(PF_UNIX, GFP_KERNEL, &unix__proto, 1);
 	if (!sk)
 		goto out;
 
 	atomic_inc(&unix_nr_socks);
 
-	sock_init_data(sock,sk);
-	sk_set_owner(sk, THIS_MODULE);
+	sock_init_data(sock, sk);
 
 	sk->sk_write_space	= unix_write_space;
 	sk->sk_max_ack_backlog	= sysctl_unix_max_dgram_qlen;
@@ -2050,26 +2052,28 @@
 
 static int __init af_unix_init(void)
 {
+	int rc = -1;
 	struct sk_buff *dummy_skb;
 
 	if (sizeof(struct unix_skb_parms) > sizeof(dummy_skb->cb)) {
 		printk(KERN_CRIT "%s: panic\n", __FUNCTION__);
-		return -1;
+		goto out;
+	}
+
+	rc = proto__register(&unix__proto, 1);
+        if (rc != 0) {
+                printk(KERN_CRIT "%s: Cannot create unix_sock SLAB cache!\n",
+		       __FUNCTION__);
+		goto out;
 	}
-        /* allocate our sock slab cache */
-        unix_sk_cachep = kmem_cache_create("unix_sock",
-					   sizeof(struct unix_sock), 0,
-					   SLAB_HWCACHE_ALIGN, NULL, NULL);
-        if (!unix_sk_cachep)
-                printk(KERN_CRIT
-                        "af_unix_init: Cannot create unix_sock SLAB cache!\n");
 
 	sock_register(&unix_family_ops);
 #ifdef CONFIG_PROC_FS
 	proc_net_fops_create("unix", 0, &unix_seq_fops);
 #endif
 	unix_sysctl_register();
-	return 0;
+out:
+	return rc;
 }
 
 static void __exit af_unix_exit(void)
@@ -2077,7 +2081,7 @@
 	sock_unregister(PF_UNIX);
 	unix_sysctl_unregister();
 	proc_net_remove("unix");
-	kmem_cache_destroy(unix_sk_cachep);
+	proto__unregister(&unix__proto);
 }
 
 module_init(af_unix_init);
diff -Nru a/net/wanrouter/af_wanpipe.c b/net/wanrouter/af_wanpipe.c
--- a/net/wanrouter/af_wanpipe.c	2005-03-25 21:30:21 -03:00
+++ b/net/wanrouter/af_wanpipe.c	2005-03-25 21:30:21 -03:00
@@ -477,6 +477,18 @@
 	return sk;
 }
 
+/* 
+ * FIXME: wanpipe_opt has to include a sock in its definition and stop using
+ * sk_protinfo, but this code is not even compilable now, so lets leave it for
+ * later.
+ */
+static struct proto wanpipe__proto = {
+	.name	  = "WANPIPE",
+	.owner	  = THIS_MODULE,
+	.slab	  = sk_cachep,
+	.obj_size = sizeof(struct sock),
+};
+
 /*============================================================
  * wanpipe_make_new
  *
@@ -495,7 +507,7 @@
 	struct sock *sk;
 	struct wanpipe_opt *wan_opt;
 
-	if ((sk = sk_alloc(PF_WANPIPE, GFP_ATOMIC, 1, NULL)) == NULL)
+	if ((sk = sk_alloc(PF_WANPIPE, GFP_ATOMIC, &wanpipe__proto, 1)) == NULL)
 		return NULL;
 
 	if ((wan_opt = kmalloc(sizeof(struct wanpipe_opt), GFP_ATOMIC)) == NULL) {
@@ -2577,17 +2589,23 @@
 	printk(KERN_INFO "wansock: Cleaning up \n");
 	unregister_netdevice_notifier(&wanpipe_netdev_notifier);
 	sock_unregister(PF_WANPIPE);
-	return;
+	proto__unregister(&wanpipe__proto);
 }
 
-
 int init_module(void)
 {
+	int rc;
 
 	printk(KERN_INFO "wansock: Registering Socket \n");
+
+	rc = proto__register(&wanpipe__proto, 0);
+	if (rc != 0)
+		goto out;
+
 	sock_register(&wanpipe_family_ops);
 	register_netdevice_notifier(&wanpipe_netdev_notifier);
-	return 0;
+out:
+	return rc;
 }
 #endif
 MODULE_LICENSE("GPL");
diff -Nru a/net/x25/af_x25.c b/net/x25/af_x25.c
--- a/net/x25/af_x25.c	2005-03-25 21:30:21 -03:00
+++ b/net/x25/af_x25.c	2005-03-25 21:30:21 -03:00
@@ -442,17 +442,22 @@
 	return rc;
 }
 
+static struct proto x25__proto = {
+	.name	  = "X25",
+	.owner	  = THIS_MODULE,
+	.slab	  = NULL,
+	.obj_size = sizeof(struct x25_sock),
+};
+
 static struct sock *x25_alloc_socket(void)
 {
 	struct x25_sock *x25;
-	struct sock *sk = sk_alloc(AF_X25, GFP_ATOMIC,
-				   sizeof(struct x25_sock), NULL);
+	struct sock *sk = sk_alloc(AF_X25, GFP_ATOMIC, &x25__proto, 1);
 
 	if (!sk)
 		goto out;
 
 	sock_init_data(NULL, sk);
-	sk_set_owner(sk, THIS_MODULE);
 
 	x25 = x25_sk(sk);
 	skb_queue_head_init(&x25->ack_queue);
@@ -481,7 +486,6 @@
 	x25 = x25_sk(sk);
 
 	sock_init_data(sock, sk);
-	sk_set_owner(sk, THIS_MODULE);
 
 	x25_init_timers(sk);
 
@@ -1385,6 +1389,11 @@
 
 static int __init x25_init(void)
 {
+	int rc = proto__register(&x25__proto, 0);
+
+	if (rc != 0)
+		goto out;
+
 	sock_register(&x25_family_ops);
 
 	dev_add_pack(&x25_packet_type);
@@ -1397,7 +1406,8 @@
 	x25_register_sysctl();
 #endif
 	x25_proc_init();
-	return 0;
+out:
+	return rc;
 }
 module_init(x25_init);
 
@@ -1416,6 +1426,7 @@
 	dev_remove_pack(&x25_packet_type);
 
 	sock_unregister(AF_X25);
+	proto__unregister(&x25__proto);
 }
 module_exit(x25_exit);
 


--dDRMvlgZJXvWKvBx--
