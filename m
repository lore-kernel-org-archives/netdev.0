From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [RFC] struct stream_sock (aka struct sock shrink-me-harder)
Date: Wed, 15 Dec 2004 20:42:18 -0200
Message-ID: <41C0BDCA.1000305@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050301010404020702080302"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050301010404020702080302
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Dave,

	It compiles, boots, survives some testing, but is incomplete yet in
the old protos that I have to convert to per protocol slabcaches, which will
also allow us to get rid of sk_protinfo.

	Some cases are more tricky, like bluetooth, that uses both per
protocol slabcache _and_ sk->sk_protinfo, probably the best thing to do in
this case is to make bluetooth use sk->sk_prot, and that is what I plan
to do eventually to all families, to get rid of sk->sk_slab (i.e. when
all families use sk->sk_prot we can just use sk->sk_prot->slab).

	I think that besides the savings per struct sock instance on
non stream/seqpacket protos this makes things clearer by separating the
stream stuff from the bare struct sock that is needed for all familes.

	Anyway, what do you think? Any member in struct stream_sock that
should not have been moved from struct sock?

Best Regards,

- Arnaldo

--------------050301010404020702080302
Content-Type: text/plain;
 name="stream_sock.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="stream_sock.patch"

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.2175, 2004-12-15 20:31:22-02:00, acme@conectiva.com.br
  [SOCK] move stream specific stuff from struct sock to struct stream_sock
  
  [root@oldpandora ~]# diff -u before after
  --- before      2004-12-15 05:13:13.000000000 -0200
  +++ after       2004-12-15 05:13:21.000000000 -0200
  @@ -1,8 +1,8 @@
  -rawv6_sock                640
  -udpv6_sock                608
  +rawv6_sock                608
  +udpv6_sock                576
   tcpv6_sock               1120
   unix_sock                 384
  -raw_sock                  480
  -udp_sock                  480
  +raw_sock                  448
  +udp_sock                  448
   tcp_sock                 1024
  -sock                      320
  +sock                      288
  [root@oldpandora ~]#
  
  Enough said? :-)
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>


 include/linux/atmdev.h            |   18 ++
 include/linux/ip.h                |    7 -
 include/linux/ipv6.h              |   34 ++---
 include/linux/tcp.h               |   11 +
 include/linux/udp.h               |    9 -
 include/net/af_unix.h             |    2 
 include/net/ax25.h                |   15 ++
 include/net/bluetooth/bluetooth.h |   13 +
 include/net/dn.h                  |   14 +-
 include/net/sctp/sctp.h           |   23 ++-
 include/net/sock.h                |  204 ------------------------------
 include/net/stream_sock.h         |  252 ++++++++++++++++++++++++++++++++++++++
 include/net/tcp.h                 |   22 +--
 include/net/tcp_ecn.h             |    6 
 net/atm/common.c                  |   48 ++++---
 net/atm/signaling.c               |    6 
 net/atm/svc.c                     |    4 
 net/ax25/af_ax25.c                |   55 ++++----
 net/ax25/ax25_in.c                |   13 -
 net/bluetooth/af_bluetooth.c      |    7 -
 net/bluetooth/l2cap.c             |   14 +-
 net/bluetooth/rfcomm/sock.c       |   14 +-
 net/bluetooth/sco.c               |    9 -
 net/core/sock.c                   |   24 ++-
 net/core/stream.c                 |   35 ++---
 net/decnet/af_decnet.c            |    8 -
 net/decnet/dn_nsp_in.c            |    6 
 net/decnet/dn_nsp_out.c           |    2 
 net/ipv4/af_inet.c                |   14 +-
 net/ipv4/ip_output.c              |   19 +-
 net/ipv4/tcp.c                    |   47 +++----
 net/ipv4/tcp_diag.c               |    4 
 net/ipv4/tcp_input.c              |   30 ++--
 net/ipv4/tcp_ipv4.c               |   19 +-
 net/ipv4/tcp_minisocks.c          |   13 +
 net/ipv4/tcp_output.c             |   57 ++++----
 net/ipv4/tcp_timer.c              |    6 
 net/ipv6/af_inet6.c               |    3 
 net/ipv6/ip6_output.c             |   20 +--
 net/ipv6/tcp_ipv6.c               |   24 +--
 net/irda/af_irda.c                |    6 
 net/llc/af_llc.c                  |    3 
 net/netrom/af_netrom.c            |   11 -
 net/rose/af_rose.c                |   11 -
 net/sctp/associola.c              |    4 
 net/sctp/endpointola.c            |    2 
 net/sctp/sm_statefuns.c           |    2 
 net/sctp/socket.c                 |   10 -
 net/unix/af_unix.c                |   16 +-
 net/wanrouter/af_wanpipe.c        |    4 
 net/x25/af_x25.c                  |   11 -
 51 files changed, 694 insertions(+), 517 deletions(-)


diff -Nru a/include/linux/atmdev.h b/include/linux/atmdev.h
--- a/include/linux/atmdev.h	2004-12-15 20:32:26 -02:00
+++ b/include/linux/atmdev.h	2004-12-15 20:32:26 -02:00
@@ -11,6 +11,8 @@
 #include <linux/atmapi.h>
 #include <linux/atm.h>
 #include <linux/atmioc.h>
+#include <net/sock.h>
+#include <net/stream_sock.h>
 
 
 #define ESI_LEN		6
@@ -30,9 +32,6 @@
 #define ATM_DS3_PCR	(8000*12)
 			/* DS3: 12 cells in a 125 usec time slot */
 
-#define atm_sk(__sk) ((struct atm_vcc *)(__sk)->sk_protinfo)
-#define ATM_SD(s)	(atm_sk((s)->sk))
-
 
 #define __AAL_STAT_ITEMS \
     __HANDLE_ITEM(tx);			/* TX okay */ \
@@ -310,6 +309,19 @@
 					/* by CLIP and sch_atm. */
 };
 
+struct atm_sock {
+	struct sock		sk;
+	struct stream_sock	*pssk;
+	struct stream_sock	ssk;
+	struct atm_vcc		vcc;
+};
+
+static inline struct atm_vcc *atm_sk(const struct sock *sk)
+{
+	return &((struct atm_sock *)sk)->vcc;
+}
+
+#define ATM_SD(s)	(atm_sk((s)->sk))
 
 struct atm_dev_addr {
 	struct sockaddr_atmsvc addr;	/* ATM address */
diff -Nru a/include/linux/ip.h b/include/linux/ip.h
--- a/include/linux/ip.h	2004-12-15 20:32:26 -02:00
+++ b/include/linux/ip.h	2004-12-15 20:32:26 -02:00
@@ -150,11 +150,12 @@
 
 /* WARNING: don't change the layout of the members in inet_sock! */
 struct inet_sock {
-	struct sock	  sk;
+	struct sock	   sk;
+	struct stream_sock *pssk;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct ipv6_pinfo *pinet6;
+	struct ipv6_pinfo  *pinet6;
 #endif
-	struct inet_opt   inet;
+	struct inet_opt    inet;
 };
 
 static inline struct inet_opt * inet_sk(const struct sock *__sk)
diff -Nru a/include/linux/ipv6.h b/include/linux/ipv6.h
--- a/include/linux/ipv6.h	2004-12-15 20:32:26 -02:00
+++ b/include/linux/ipv6.h	2004-12-15 20:32:26 -02:00
@@ -256,27 +256,31 @@
 
 /* WARNING: don't change the layout of the members in {raw,udp,tcp}6_sock! */
 struct raw6_sock {
-	struct sock	  sk;
-	struct ipv6_pinfo *pinet6;
-	struct inet_opt   inet;
-	struct raw6_opt   raw6;
-	struct ipv6_pinfo inet6;
+	struct sock	   sk;
+	struct stream_sock *pssk;
+	struct ipv6_pinfo  *pinet6;
+	struct inet_opt    inet;
+	struct raw6_opt    raw6;
+	struct ipv6_pinfo  inet6;
 };
 
 struct udp6_sock {
-	struct sock	  sk;
-	struct ipv6_pinfo *pinet6;
-	struct inet_opt   inet;
-	struct udp_opt	  udp;
-	struct ipv6_pinfo inet6;
+	struct sock	   sk;
+	struct stream_sock *pssk;
+	struct ipv6_pinfo  *pinet6;
+	struct inet_opt    inet;
+	struct udp_opt	   udp;
+	struct ipv6_pinfo  inet6;
 };
 
 struct tcp6_sock {
-	struct sock	  sk;
-	struct ipv6_pinfo *pinet6;
-	struct inet_opt   inet;
-	struct tcp_opt	  tcp;
-	struct ipv6_pinfo inet6;
+	struct sock	   sk;
+	struct stream_sock *pssk;
+	struct ipv6_pinfo  *pinet6;
+	struct inet_opt    inet;
+	struct tcp_opt	   tcp;
+	struct stream_sock ssk;
+	struct ipv6_pinfo  inet6;
 };
 
 static inline struct ipv6_pinfo * inet6_sk(const struct sock *__sk)
diff -Nru a/include/linux/tcp.h b/include/linux/tcp.h
--- a/include/linux/tcp.h	2004-12-15 20:32:26 -02:00
+++ b/include/linux/tcp.h	2004-12-15 20:32:26 -02:00
@@ -196,6 +196,7 @@
 #include <linux/skbuff.h>
 #include <linux/ip.h>
 #include <net/sock.h>
+#include <net/stream_sock.h>
 
 /* This defines a selective acknowledgement block. */
 struct tcp_sack_block {
@@ -440,12 +441,14 @@
 
 /* WARNING: don't change the layout of the members in tcp_sock! */
 struct tcp_sock {
-	struct sock	  sk;
+	struct sock		sk;
+	struct stream_sock	*pssk;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct ipv6_pinfo *pinet6;
+	struct ipv6_pinfo	*pinet6;
 #endif
-	struct inet_opt	  inet;
-	struct tcp_opt	  tcp;
+	struct inet_opt		inet;
+	struct tcp_opt		tcp;
+	struct stream_sock	ssk;
 };
 
 static inline struct tcp_opt * tcp_sk(const struct sock *__sk)
diff -Nru a/include/linux/udp.h b/include/linux/udp.h
--- a/include/linux/udp.h	2004-12-15 20:32:26 -02:00
+++ b/include/linux/udp.h	2004-12-15 20:32:26 -02:00
@@ -53,12 +53,13 @@
 
 /* WARNING: don't change the layout of the members in udp_sock! */
 struct udp_sock {
-	struct sock	  sk;
+	struct sock	   sk;
+	struct stream_sock *pssk;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct ipv6_pinfo *pinet6;
+	struct ipv6_pinfo  *pinet6;
 #endif
-	struct inet_opt	  inet;
-	struct udp_opt	  udp;
+	struct inet_opt	   inet;
+	struct udp_opt	   udp;
 };
 
 static inline struct udp_opt * udp_sk(const struct sock *__sk)
diff -Nru a/include/net/af_unix.h b/include/net/af_unix.h
--- a/include/net/af_unix.h	2004-12-15 20:32:26 -02:00
+++ b/include/net/af_unix.h	2004-12-15 20:32:26 -02:00
@@ -62,6 +62,8 @@
 struct unix_sock {
 	/* WARNING: sk has to be the first member */
 	struct sock		sk;
+	struct stream_sock	*pssk;
+	struct stream_sock	ssk;
         struct unix_address     *addr;
         struct dentry		*dentry;
         struct vfsmount		*mnt;
diff -Nru a/include/net/ax25.h b/include/net/ax25.h
--- a/include/net/ax25.h	2004-12-15 20:32:26 -02:00
+++ b/include/net/ax25.h	2004-12-15 20:32:26 -02:00
@@ -12,6 +12,8 @@
 #include <linux/timer.h>
 #include <linux/list.h>
 #include <asm/atomic.h>
+#include <net/sock.h>
+#include <net/stream_sock.h>
 
 #define	AX25_T1CLAMPLO  		1
 #define	AX25_T1CLAMPHI 			(30 * HZ)
@@ -203,7 +205,17 @@
 	atomic_t		refcount;
 } ax25_cb;
 
-#define ax25_sk(__sk) ((ax25_cb *)(__sk)->sk_protinfo)
+struct ax25_sock {
+	struct sock		sk;
+	struct stream_sock	*pssk;
+	struct stream_sock	ssk;
+	struct ax25_cb		cb;
+};
+
+static inline struct ax25_cb *ax25_sk(const struct sock *sk)
+{
+	return &((struct ax25_sock *)sk)->cb;
+}
 
 #define ax25_for_each(__ax25, node, list) \
 	hlist_for_each_entry(__ax25, node, list, ax25_node)
@@ -230,6 +242,7 @@
 extern void ax25_send_to_raw(ax25_address *, struct sk_buff *, int);
 extern void ax25_destroy_socket(ax25_cb *);
 extern ax25_cb *ax25_create_cb(void);
+extern void ax25_init_cb(ax25_cb *ax25);
 extern void ax25_fillin_cb(ax25_cb *, ax25_dev *);
 extern int  ax25_create(struct socket *, int);
 extern struct sock *ax25_make_new(struct sock *, struct ax25_dev *);
diff -Nru a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
--- a/include/net/bluetooth/bluetooth.h	2004-12-15 20:32:26 -02:00
+++ b/include/net/bluetooth/bluetooth.h	2004-12-15 20:32:26 -02:00
@@ -30,6 +30,7 @@
 #include <linux/list.h>
 #include <linux/poll.h>
 #include <net/sock.h>
+#include <net/stream_sock.h>
 
 #ifndef AF_BLUETOOTH
 #define AF_BLUETOOTH	31
@@ -111,11 +112,13 @@
 #define bt_sk(__sk) ((struct bt_sock *) __sk)
 
 struct bt_sock {
-	struct sock sk;
-	bdaddr_t    src;
-	bdaddr_t    dst;
-	struct list_head accept_q;
-	struct sock *parent;
+	struct sock	   sk;
+	struct stream_sock *pssk;
+	struct stream_sock ssk;
+	bdaddr_t	   src;
+	bdaddr_t	   dst;
+	struct list_head   accept_q;
+	struct sock	   *parent;
 };
 
 struct bt_sock_list {
diff -Nru a/include/net/dn.h b/include/net/dn.h
--- a/include/net/dn.h	2004-12-15 20:32:26 -02:00
+++ b/include/net/dn.h	2004-12-15 20:32:26 -02:00
@@ -2,6 +2,7 @@
 #define _NET_DN_H
 
 #include <linux/dn.h>
+#include <net/stream_sock.h>
 #include <asm/byteorder.h>
 
 typedef unsigned short dn_address;
@@ -133,7 +134,18 @@
 
 };
 
-#define DN_SK(__sk) ((struct dn_scp *)(__sk)->sk_protinfo)
+/* WARNING: don't change the layout of the members in tcp_sock! */
+struct decnet_sock {
+	struct sock		sk;
+	struct stream_sock	*pssk;
+	struct dn_scp		scp;
+	struct stream_sock	ssk;
+};
+
+static inline struct dn_scp *DN_SK(const struct sock *sk)
+{
+	return &((struct decnet_sock *)sk)->scp;
+}
 
 /*
  * src,dst : Source and Destination DECnet addresses
diff -Nru a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
--- a/include/net/sctp/sctp.h	2004-12-15 20:32:26 -02:00
+++ b/include/net/sctp/sctp.h	2004-12-15 20:32:26 -02:00
@@ -88,6 +88,7 @@
 #include <asm/uaccess.h>
 #include <asm/page.h>
 #include <net/sock.h>
+#include <net/stream_sock.h>
 #include <net/snmp.h>
 #include <net/sctp/structs.h>
 #include <net/sctp/constants.h>
@@ -584,21 +585,25 @@
 
 /* WARNING: Do not change the layout of the members in sctp_sock! */
 struct sctp_sock {
-	struct sock	  sk;
+	struct sock	   sk;
+	struct stream_sock *pssk;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct ipv6_pinfo *pinet6;
+	struct ipv6_pinfo  *pinet6;
 #endif /* CONFIG_IPV6 */
-	struct inet_opt	  inet;
-	struct sctp_opt	  sctp;
+	struct inet_opt	   inet;
+	struct sctp_opt	   sctp;
+	struct stream_sock ssk;
 };
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 struct sctp6_sock {
-	struct sock	  sk;
-	struct ipv6_pinfo *pinet6;
-	struct inet_opt	  inet;
-	struct sctp_opt	  sctp;
-	struct ipv6_pinfo inet6;
+	struct sock	   sk;
+	struct stream_sock *pssk;
+	struct ipv6_pinfo  *pinet6;
+	struct inet_opt	   inet;
+	struct sctp_opt	   sctp;
+	struct stream_sock ssk;
+	struct ipv6_pinfo  inet6;
 };
 #endif /* CONFIG_IPV6 */
 
diff -Nru a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h	2004-12-15 20:32:26 -02:00
+++ b/include/net/sock.h	2004-12-15 20:32:26 -02:00
@@ -130,26 +130,18 @@
   *	@sk_wmem_alloc - transmit queue bytes committed
   *	@sk_write_queue - Packet sending queue
   *	@sk_omem_alloc - "o" is "option" or "other"
-  *	@sk_wmem_queued - persistent queue size
-  *	@sk_forward_alloc - space allocated forward
   *	@sk_allocation - allocation mode
   *	@sk_sndbuf - size of send buffer in bytes
   *	@sk_flags - %SO_LINGER (l_onoff), %SO_BROADCAST, %SO_KEEPALIVE, %SO_OOBINLINE settings
   *	@sk_no_check - %SO_NO_CHECK setting, wether or not checkup packets
   *	@sk_debug - %SO_DEBUG setting
   *	@sk_rcvtstamp - %SO_TIMESTAMP setting
-  *	@sk_no_largesend - whether to sent large segments or not
-  *	@sk_route_caps - route capabilities (e.g. %NETIF_F_TSO)
-  *	@sk_lingertime - %SO_LINGER l_linger setting
-  *	@sk_hashent - hash entry in several tables (e.g. tcp_ehash)
   *	@sk_backlog - always used with the per-socket spinlock held
   *	@sk_callback_lock - used with the callbacks in the end of this struct
   *	@sk_error_queue - rarely used
   *	@sk_prot - protocol handlers inside a network family
   *	@sk_err - last error
   *	@sk_err_soft - errors that don't cause failure but are the cause of a persistent failure not just 'timed out'
-  *	@sk_ack_backlog - current listen backlog
-  *	@sk_max_ack_backlog - listen backlog set in listen()
   *	@sk_priority - %SO_PRIORITY setting
   *	@sk_type - socket type (%SOCK_STREAM, etc)
   *	@sk_localroute - route locally only, %SO_DONTROUTE setting
@@ -166,11 +158,6 @@
   *	@sk_socket - Identd and reporting IO signals
   *	@sk_user_data - RPC layer private data
   *	@sk_owner - module that owns this socket
-  *	@sk_sndmsg_page - cached page for sendmsg
-  *	@sk_sndmsg_off - cached offset for sendmsg
-  *	@sk_send_head - front of stuff to transmit
-  *	@sk_write_pending - a write to stream socket waits to start
-  *	@sk_queue_shrunk - write queue has been shrunk recently
   *	@sk_state_change - callback to indicate change in the state of the sock
   *	@sk_data_ready - callback to indicate there is data to be processed
   *	@sk_write_space - callback to indicate there is bf sending space available
@@ -206,18 +193,13 @@
 	atomic_t		sk_wmem_alloc;
 	struct sk_buff_head	sk_write_queue;
 	atomic_t		sk_omem_alloc;
-	int			sk_wmem_queued;
-	int			sk_forward_alloc;
 	unsigned int		sk_allocation;
 	int			sk_sndbuf;
 	unsigned long 		sk_flags;
 	char		 	sk_no_check;
 	unsigned char		sk_debug;
 	unsigned char		sk_rcvtstamp;
-	unsigned char		sk_no_largesend;
-	int			sk_route_caps;
-	unsigned long	        sk_lingertime;
-	int			sk_hashent;
+	/* one byte hole, try to pack */
 	/*
 	 * The backlog queue is special, it is always used with
 	 * the per-socket spinlock held and requires low latency
@@ -232,8 +214,6 @@
 	struct proto		*sk_prot;
 	int			sk_err,
 				sk_err_soft;
-	unsigned short		sk_ack_backlog;
-	unsigned short		sk_max_ack_backlog;
 	__u32			sk_priority;
 	unsigned short		sk_type;
 	unsigned char		sk_localroute;
@@ -250,13 +230,7 @@
 	struct socket		*sk_socket;
 	void			*sk_user_data;
 	struct module		*sk_owner;
-	struct page		*sk_sndmsg_page;
-	__u32			sk_sndmsg_off;
-	struct sk_buff		*sk_send_head;
-	int			sk_write_pending;
 	void			*sk_security;
-	__u8			sk_queue_shrunk;
-	/* three bytes hole, try to pack */
 	void			(*sk_state_change)(struct sock *sk);
 	void			(*sk_data_ready)(struct sock *sk, int bytes);
 	void			(*sk_write_space)(struct sock *sk);
@@ -408,59 +382,6 @@
 	return test_bit(flag, &sk->sk_flags);
 }
 
-static inline void sk_acceptq_removed(struct sock *sk)
-{
-	sk->sk_ack_backlog--;
-}
-
-static inline void sk_acceptq_added(struct sock *sk)
-{
-	sk->sk_ack_backlog++;
-}
-
-static inline int sk_acceptq_is_full(struct sock *sk)
-{
-	return sk->sk_ack_backlog > sk->sk_max_ack_backlog;
-}
-
-/*
- * Compute minimal free write space needed to queue new packets.
- */
-static inline int sk_stream_min_wspace(struct sock *sk)
-{
-	return sk->sk_wmem_queued / 2;
-}
-
-static inline int sk_stream_wspace(struct sock *sk)
-{
-	return sk->sk_sndbuf - sk->sk_wmem_queued;
-}
-
-extern void sk_stream_write_space(struct sock *sk);
-
-static inline int sk_stream_memory_free(struct sock *sk)
-{
-	return sk->sk_wmem_queued < sk->sk_sndbuf;
-}
-
-extern void sk_stream_rfree(struct sk_buff *skb);
-
-static inline void sk_stream_set_owner_r(struct sk_buff *skb, struct sock *sk)
-{
-	skb->sk = sk;
-	skb->destructor = sk_stream_rfree;
-	atomic_add(skb->truesize, &sk->sk_rmem_alloc);
-	sk->sk_forward_alloc -= skb->truesize;
-}
-
-static inline void sk_stream_free_skb(struct sock *sk, struct sk_buff *skb)
-{
-	sk->sk_queue_shrunk   = 1;
-	sk->sk_wmem_queued   -= skb->truesize;
-	sk->sk_forward_alloc += skb->truesize;
-	__kfree_skb(skb);
-}
-
 /* The per-socket spinlock must be held here. */
 #define sk_add_backlog(__sk, __skb)				\
 do {	if (!(__sk)->sk_backlog.tail) {				\
@@ -485,12 +406,6 @@
 	rc;							\
 })
 
-extern int sk_stream_wait_connect(struct sock *sk, long *timeo_p);
-extern int sk_stream_wait_memory(struct sock *sk, long *timeo_p);
-extern void sk_stream_wait_close(struct sock *sk, long timeo_p);
-extern int sk_stream_error(struct sock *sk, int flags, int err);
-extern void sk_stream_kill_queues(struct sock *sk);
-
 extern int sk_wait_data(struct sock *sk, long *timeo);
 
 /* Networking protocol blocks we attach to sockets.
@@ -656,37 +571,6 @@
 	return &container_of(socket, struct socket_alloc, socket)->vfs_inode;
 }
 
-extern void __sk_stream_mem_reclaim(struct sock *sk);
-extern int sk_stream_mem_schedule(struct sock *sk, int size, int kind);
-
-#define SK_STREAM_MEM_QUANTUM ((int)PAGE_SIZE)
-
-static inline int sk_stream_pages(int amt)
-{
-	return (amt + SK_STREAM_MEM_QUANTUM - 1) / SK_STREAM_MEM_QUANTUM;
-}
-
-static inline void sk_stream_mem_reclaim(struct sock *sk)
-{
-	if (sk->sk_forward_alloc >= SK_STREAM_MEM_QUANTUM)
-		__sk_stream_mem_reclaim(sk);
-}
-
-static inline void sk_stream_writequeue_purge(struct sock *sk)
-{
-	struct sk_buff *skb;
-
-	while ((skb = __skb_dequeue(&sk->sk_write_queue)) != NULL)
-		sk_stream_free_skb(sk, skb);
-	sk_stream_mem_reclaim(sk);
-}
-
-static inline int sk_stream_rmem_schedule(struct sock *sk, struct sk_buff *skb)
-{
-	return (int)skb->truesize <= sk->sk_forward_alloc ||
-		sk_stream_mem_schedule(sk, skb->truesize, 1);
-}
-
 /* Used by processes to "lock" a socket state, so that
  * interrupts and bottom half handlers won't change it
  * from under us. It essentially blocks any incoming
@@ -1009,35 +893,6 @@
 	return dst;
 }
 
-static inline void sk_charge_skb(struct sock *sk, struct sk_buff *skb)
-{
-	sk->sk_wmem_queued   += skb->truesize;
-	sk->sk_forward_alloc -= skb->truesize;
-}
-
-static inline int skb_copy_to_page(struct sock *sk, char __user *from,
-				   struct sk_buff *skb, struct page *page,
-				   int off, int copy)
-{
-	if (skb->ip_summed == CHECKSUM_NONE) {
-		int err = 0;
-		unsigned int csum = csum_and_copy_from_user(from,
-						     page_address(page) + off,
-							    copy, 0, &err);
-		if (err)
-			return err;
-		skb->csum = csum_block_add(skb->csum, csum, skb->len);
-	} else if (copy_from_user(page_address(page) + off, from, copy))
-		return -EFAULT;
-
-	skb->len	     += copy;
-	skb->data_len	     += copy;
-	skb->truesize	     += copy;
-	sk->sk_wmem_queued   += copy;
-	sk->sk_forward_alloc -= copy;
-	return 0;
-}
-
 /*
  * 	Queue a received datagram if it will fit. Stream and sequenced
  *	protocols can't normally use this as they need to fit buffers in
@@ -1149,63 +1004,6 @@
 	if (sk->sk_socket && sk->sk_socket->fasync_list)
 		sock_wake_async(sk->sk_socket, how, band);
 }
-
-#define SOCK_MIN_SNDBUF 2048
-#define SOCK_MIN_RCVBUF 256
-
-static inline void sk_stream_moderate_sndbuf(struct sock *sk)
-{
-	if (!(sk->sk_userlocks & SOCK_SNDBUF_LOCK)) {
-		sk->sk_sndbuf = min(sk->sk_sndbuf, sk->sk_wmem_queued / 2);
-		sk->sk_sndbuf = max(sk->sk_sndbuf, SOCK_MIN_SNDBUF);
-	}
-}
-
-static inline struct sk_buff *sk_stream_alloc_pskb(struct sock *sk,
-						   int size, int mem, int gfp)
-{
-	struct sk_buff *skb = alloc_skb(size + sk->sk_prot->max_header, gfp);
-
-	if (skb) {
-		skb->truesize += mem;
-		if (sk->sk_forward_alloc >= (int)skb->truesize ||
-		    sk_stream_mem_schedule(sk, skb->truesize, 0)) {
-			skb_reserve(skb, sk->sk_prot->max_header);
-			return skb;
-		}
-		__kfree_skb(skb);
-	} else {
-		sk->sk_prot->enter_memory_pressure();
-		sk_stream_moderate_sndbuf(sk);
-	}
-	return NULL;
-}
-
-static inline struct sk_buff *sk_stream_alloc_skb(struct sock *sk,
-						  int size, int gfp)
-{
-	return sk_stream_alloc_pskb(sk, size, 0, gfp);
-}
-
-static inline struct page *sk_stream_alloc_page(struct sock *sk)
-{
-	struct page *page = NULL;
-
-	if (sk->sk_forward_alloc >= (int)PAGE_SIZE ||
-	    sk_stream_mem_schedule(sk, PAGE_SIZE, 0))
-		page = alloc_pages(sk->sk_allocation, 0);
-	else {
-		sk->sk_prot->enter_memory_pressure();
-		sk_stream_moderate_sndbuf(sk);
-	}
-	return page;
-}
-
-#define sk_stream_for_retrans_queue(skb, sk)				\
-		for (skb = (sk)->sk_write_queue.next;			\
-		     (skb != (sk)->sk_send_head) &&			\
-		     (skb != (struct sk_buff *)&(sk)->sk_write_queue);	\
-		     skb = skb->next)
 
 /*
  *	Default write policy as shown to user space via poll/select/SIGIO
diff -Nru a/include/net/stream_sock.h b/include/net/stream_sock.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/include/net/stream_sock.h	2004-12-15 20:32:26 -02:00
@@ -0,0 +1,252 @@
+/*
+ * INET		An implementation of the TCP/IP protocol suite for the LINUX
+ *		operating system.  INET is implemented using the  BSD Socket
+ *		interface as the means of communication with the user level.
+ *
+ * Authors:	Arnaldo Carvalho de Melo <acme@conectiva.com.br>
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ */
+#ifndef _STREAM_SOCK_H
+#define _STREAM_SOCK_H
+
+#include <net/sock.h>
+
+/**
+  *	struct stream_sock - stream sock area (used in tcp_sock, etc)
+  *	@ssk_lingertime - %SO_LINGER l_linger setting
+  *	@ssk_ack_backlog - current listen backlog
+  *	@ssk_max_ack_backlog - listen backlog set in listen()
+  *	@ssk_forward_alloc - space allocated forward
+  *	@ssk_wmem_queued - persistent queue size
+  *	@ssk_write_pending - a write to stream socket waits to start
+  *	@ssk_send_head - front of stuff to transmit
+  *	@ssk_route_caps - route capabilities (e.g. %NETIF_F_TSO)
+  *	@ssk_queue_shrunk - write queue has been shrunk recently
+  *	@ssk_no_largesend - whether to sent large segments or not
+  *	@ssk_sndmsg_page - cached page for sendmsg
+  *	@ssk_sndmsg_off - cached offset for sendmsg
+  *	@ssk_hashent - hash entry in several tables (e.g. tcp_ehash)
+ */
+struct stream_sock {
+	unsigned long	        ssk_lingertime;
+	unsigned short		ssk_ack_backlog;
+	unsigned short		ssk_max_ack_backlog;
+	int			ssk_forward_alloc;
+	int			ssk_wmem_queued;
+	int			ssk_write_pending;
+	struct sk_buff		*ssk_send_head;
+	int			ssk_route_caps;
+	__u8			ssk_queue_shrunk;
+	unsigned char		ssk_no_largesend;
+	/* two bytes hole, try to pack */
+	struct page		*ssk_sndmsg_page;
+	__u32			ssk_sndmsg_off;
+	int			ssk_hashent;
+};
+
+struct pstream_sock {
+	struct sock	   sk;
+	struct stream_sock *pssk;
+};
+
+static inline struct stream_sock *sk_ssk(const struct sock *sk)
+{
+	return ((struct pstream_sock *)sk)->pssk;
+}
+
+#define ssk_set_pointer(sk, type, member) { \
+	((struct pstream_sock *)sk)->pssk = \
+		(struct stream_sock *)(((unsigned char *)sk) + \
+				       offsetof(type, member)); \
+}
+
+static inline void sk_acceptq_removed(struct sock *sk)
+{
+	sk_ssk(sk)->ssk_ack_backlog--;
+}
+
+static inline void sk_acceptq_added(struct sock *sk)
+{
+	sk_ssk(sk)->ssk_ack_backlog++;
+}
+
+static inline int sk_acceptq_is_full(struct sock *sk)
+{
+	return sk_ssk(sk)->ssk_ack_backlog > sk_ssk(sk)->ssk_max_ack_backlog;
+}
+
+static inline void sk_stream_free_skb(struct sock *sk, struct sk_buff *skb)
+{
+	struct stream_sock *ssk = sk_ssk(sk);
+
+	ssk->ssk_queue_shrunk   = 1;
+	ssk->ssk_wmem_queued   -= skb->truesize;
+	ssk->ssk_forward_alloc += skb->truesize;
+	__kfree_skb(skb);
+}
+
+extern void sk_stream_rfree(struct sk_buff *skb);
+
+static inline void sk_stream_set_owner_r(struct sk_buff *skb,
+					 struct sock *sk)
+{
+	skb->sk = sk;
+	skb->destructor = sk_stream_rfree;
+	atomic_add(skb->truesize, &sk->sk_rmem_alloc);
+	sk_ssk(sk)->ssk_forward_alloc -= skb->truesize;
+}
+
+extern void __sk_stream_mem_reclaim(struct sock *sk);
+extern int sk_stream_mem_schedule(struct sock *sk, int size, int kind);
+
+#define SK_STREAM_MEM_QUANTUM ((int)PAGE_SIZE)
+
+static inline int sk_stream_pages(int amt)
+{
+	return (amt + SK_STREAM_MEM_QUANTUM - 1) / SK_STREAM_MEM_QUANTUM;
+}
+
+static inline void sk_stream_mem_reclaim(struct sock *sk)
+{
+	if (sk_ssk(sk)->ssk_forward_alloc >= SK_STREAM_MEM_QUANTUM)
+		__sk_stream_mem_reclaim(sk);
+}
+
+static inline void sk_stream_writequeue_purge(struct sock *sk)
+{
+	struct sk_buff *skb;
+
+	while ((skb = __skb_dequeue(&sk->sk_write_queue)) != NULL)
+		sk_stream_free_skb(sk, skb);
+	sk_stream_mem_reclaim(sk);
+}
+
+static inline int sk_stream_rmem_schedule(struct sock *sk,
+					  struct sk_buff *skb)
+{
+	return (int)skb->truesize <= sk_ssk(sk)->ssk_forward_alloc ||
+		sk_stream_mem_schedule(sk, skb->truesize, 1);
+}
+
+static inline void sk_charge_skb(struct sock *sk, struct sk_buff *skb)
+{
+	struct stream_sock *ssk = sk_ssk(sk);
+
+	ssk->ssk_wmem_queued   += skb->truesize;
+	ssk->ssk_forward_alloc -= skb->truesize;
+}
+
+static inline int skb_copy_to_page(struct sock *sk, char __user *from,
+				   struct sk_buff *skb, struct page *page,
+				   int off, int copy)
+{
+	struct stream_sock *ssk;
+
+	if (skb->ip_summed == CHECKSUM_NONE) {
+		int err = 0;
+		unsigned int csum = csum_and_copy_from_user(from,
+						     page_address(page) + off,
+							    copy, 0, &err);
+		if (err)
+			return err;
+		skb->csum = csum_block_add(skb->csum, csum, skb->len);
+	} else if (copy_from_user(page_address(page) + off, from, copy))
+		return -EFAULT;
+
+	skb->len		+= copy;
+	skb->data_len		+= copy;
+	skb->truesize		+= copy;
+
+	ssk = sk_ssk(sk);
+	ssk->ssk_wmem_queued	+= copy;
+	ssk->ssk_forward_alloc	-= copy;
+	return 0;
+}
+
+#define SOCK_MIN_RCVBUF 256
+#define SOCK_MIN_SNDBUF 2048
+
+static inline void sk_stream_moderate_sndbuf(struct sock *sk)
+{
+	if (!(sk->sk_userlocks & SOCK_SNDBUF_LOCK)) {
+		sk->sk_sndbuf = min(sk->sk_sndbuf, sk_ssk(sk)->ssk_wmem_queued / 2);
+		sk->sk_sndbuf = max(sk->sk_sndbuf, SOCK_MIN_SNDBUF);
+	}
+}
+
+static inline struct sk_buff *sk_stream_alloc_pskb(struct sock *sk,
+						   int size, int mem, int gfp)
+{
+	struct sk_buff *skb = alloc_skb(size + sk->sk_prot->max_header, gfp);
+
+	if (skb) {
+		skb->truesize += mem;
+		if (sk_ssk(sk)->ssk_forward_alloc >= (int)skb->truesize ||
+		    sk_stream_mem_schedule(sk, skb->truesize, 0)) {
+			skb_reserve(skb, sk->sk_prot->max_header);
+			return skb;
+		}
+		__kfree_skb(skb);
+	} else {
+		sk->sk_prot->enter_memory_pressure();
+		sk_stream_moderate_sndbuf(sk);
+	}
+	return NULL;
+}
+
+static inline struct sk_buff *sk_stream_alloc_skb(struct sock *sk,
+						  int size, int gfp)
+{
+	return sk_stream_alloc_pskb(sk, size, 0, gfp);
+}
+
+static inline struct page *sk_stream_alloc_page(struct sock *sk)
+{
+	struct page *page = NULL;
+
+	if (sk_ssk(sk)->ssk_forward_alloc >= (int)PAGE_SIZE ||
+	    sk_stream_mem_schedule(sk, PAGE_SIZE, 0))
+		page = alloc_pages(sk->sk_allocation, 0);
+	else {
+		sk->sk_prot->enter_memory_pressure();
+		sk_stream_moderate_sndbuf(sk);
+	}
+	return page;
+}
+
+#define sk_stream_for_retrans_queue(skb, sk)				\
+		for (skb = (sk)->sk_write_queue.next;			\
+		     (skb != sk_ssk(sk)->ssk_send_head) &&		\
+		     (skb != (struct sk_buff *)&(sk)->sk_write_queue);	\
+		     skb = skb->next)
+
+/*
+ * Compute minimal free write space needed to queue new packets.
+ */
+static inline int sk_stream_min_wspace(struct sock *sk)
+{
+	return sk_ssk(sk)->ssk_wmem_queued / 2;
+}
+
+static inline int sk_stream_wspace(struct sock *sk)
+{
+	return sk->sk_sndbuf - sk_ssk(sk)->ssk_wmem_queued;
+}
+
+extern void sk_stream_write_space(struct sock *sk);
+
+static inline int sk_stream_memory_free(struct sock *sk)
+{
+	return sk_ssk(sk)->ssk_wmem_queued < sk->sk_sndbuf;
+}
+
+extern int sk_stream_wait_connect(struct sock *sk, long *timeo_p);
+extern int sk_stream_wait_memory(struct sock *sk, long *timeo_p);
+extern void sk_stream_wait_close(struct sock *sk, long timeo_p);
+extern int sk_stream_error(struct sock *sk, int flags, int err);
+extern void sk_stream_kill_queues(struct sock *sk);
+#endif	/* _STREAM_SOCK_H */
diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	2004-12-15 20:32:26 -02:00
+++ b/include/net/tcp.h	2004-12-15 20:32:26 -02:00
@@ -32,6 +32,7 @@
 #include <linux/percpu.h>
 #include <net/checksum.h>
 #include <net/sock.h>
+#include <net/stream_sock.h>
 #include <net/snmp.h>
 #include <net/ip.h>
 #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
@@ -1457,7 +1458,7 @@
 
 extern void tcp_set_skb_tso_segs(struct sk_buff *, unsigned int);
 
-/* This checks if the data bearing packet SKB (usually sk->sk_send_head)
+/* This checks if the data bearing packet SKB (usually sk_ssk(sk)->ssk_send_head)
  * should be put on the wire right now.
  */
 static __inline__ int tcp_snd_test(const struct tcp_opt *tp, 
@@ -1523,7 +1524,7 @@
 						 unsigned cur_mss,
 						 int nonagle)
 {
-	struct sk_buff *skb = sk->sk_send_head;
+	struct sk_buff *skb = sk_ssk(sk)->ssk_send_head;
 
 	if (skb) {
 		if (!tcp_skb_is_last(sk, skb))
@@ -1543,7 +1544,7 @@
 
 static __inline__ int tcp_may_send_now(struct sock *sk, struct tcp_opt *tp)
 {
-	struct sk_buff *skb = sk->sk_send_head;
+	struct sk_buff *skb = sk_ssk(sk)->ssk_send_head;
 
 	return (skb &&
 		tcp_snd_test(tp, skb, tcp_current_mss(sk, 1),
@@ -1951,10 +1952,12 @@
 
 static inline void tcp_v4_setup_caps(struct sock *sk, struct dst_entry *dst)
 {
-	sk->sk_route_caps = dst->dev->features;
-	if (sk->sk_route_caps & NETIF_F_TSO) {
-		if (sk->sk_no_largesend || dst->header_len)
-			sk->sk_route_caps &= ~NETIF_F_TSO;
+	struct stream_sock *ssk = sk_ssk(sk);
+
+	ssk->ssk_route_caps = dst->dev->features;
+	if (ssk->ssk_route_caps & NETIF_F_TSO) {
+		if (ssk->ssk_no_largesend || dst->header_len)
+			ssk->ssk_route_caps &= ~NETIF_F_TSO;
 	}
 }
 
@@ -1963,13 +1966,14 @@
 static inline int tcp_use_frto(const struct sock *sk)
 {
 	const struct tcp_opt *tp = tcp_sk(sk);
+	const struct stream_sock *ssk = sk_ssk(sk);
 	
 	/* F-RTO must be activated in sysctl and there must be some
 	 * unsent new data, and the advertised window should allow
 	 * sending it.
 	 */
-	return (sysctl_tcp_frto && sk->sk_send_head &&
-		!after(TCP_SKB_CB(sk->sk_send_head)->end_seq,
+	return (sysctl_tcp_frto && ssk->ssk_send_head &&
+		!after(TCP_SKB_CB(ssk->ssk_send_head)->end_seq,
 		       tp->snd_una + tp->snd_wnd));
 }
 
diff -Nru a/include/net/tcp_ecn.h b/include/net/tcp_ecn.h
--- a/include/net/tcp_ecn.h	2004-12-15 20:32:26 -02:00
+++ b/include/net/tcp_ecn.h	2004-12-15 20:32:26 -02:00
@@ -30,11 +30,13 @@
 static __inline__ void
 TCP_ECN_send_syn(struct sock *sk, struct tcp_opt *tp, struct sk_buff *skb)
 {
+	struct stream_sock *ssk = sk_ssk(sk);
+
 	tp->ecn_flags = 0;
-	if (sysctl_tcp_ecn && !(sk->sk_route_caps & NETIF_F_TSO)) {
+	if (sysctl_tcp_ecn && !(ssk->ssk_route_caps & NETIF_F_TSO)) {
 		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_ECE|TCPCB_FLAG_CWR;
 		tp->ecn_flags = TCP_ECN_OK;
-		sk->sk_no_largesend = 1;
+		ssk->ssk_no_largesend = 1;
 	}
 }
 
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	2004-12-15 20:32:26 -02:00
+++ b/net/atm/common.c	2004-12-15 20:32:26 -02:00
@@ -31,6 +31,7 @@
 #include "addr.h"		/* address registry */
 #include "signaling.h"		/* for WAITING and sigd_attach */
 
+static kmem_cache_t *atm_sk_cachep;
 
 #if 0
 #define DPRINTK(format,args...) printk(KERN_DEBUG format,##args)
@@ -46,7 +47,7 @@
 	struct atm_vcc *vcc = atm_sk(sk);
 	struct hlist_head *head = &vcc_hash[vcc->vci &
 					(VCC_HTABLE_SIZE - 1)];
-	sk->sk_hashent = vcc->vci & (VCC_HTABLE_SIZE - 1);
+	sk_ssk(sk)->ssk_hashent = vcc->vci & (VCC_HTABLE_SIZE - 1);
 	sk_add_node(sk, head);
 }
 
@@ -96,8 +97,6 @@
 
 	if (atomic_read(&vcc->sk->sk_wmem_alloc))
 		printk(KERN_DEBUG "vcc_sock_destruct: wmem leakage (%d bytes) detected.\n", atomic_read(&sk->sk_wmem_alloc));
-
-	kfree(sk->sk_protinfo);
 }
 
 static void vcc_def_wakeup(struct sock *sk)
@@ -139,7 +138,7 @@
 	sock->sk = NULL;
 	if (sock->type == SOCK_STREAM)
 		return -EINVAL;
-	sk = sk_alloc(family, GFP_KERNEL, 1, NULL);
+	sk = sk_alloc(family, GFP_KERNEL, sizeof(struct atm_sock), atm_sk_cachep);
 	if (!sk)
 		return -ENOMEM;
 	sock_init_data(sock, sk);
@@ -147,13 +146,7 @@
 	sk->sk_state_change = vcc_def_wakeup;
 	sk->sk_write_space = vcc_write_space;
 
-	vcc = sk->sk_protinfo = kmalloc(sizeof(*vcc), GFP_KERNEL);
-	if (!vcc) {
-		sk_free(sk);
-		return -ENOMEM;
-	}
-
-	memset(vcc, 0, sizeof(*vcc));
+	vcc = atm_sk(sk);
 	vcc->sk = sk;
 	vcc->dev = NULL;
 	memset(&vcc->local,0,sizeof(struct sockaddr_atmsvc));
@@ -779,26 +772,38 @@
 
 static int __init atm_init(void)
 {
-	int error;
+	int error = -ENOMEM;
+
+	atm_sk_cachep = kmem_cache_create("atm_sock", sizeof(struct atm_sock), 0,
+					  SLAB_HWCACHE_ALIGN, NULL, NULL);
+
+	if (atm_sk_cachep == NULL) {
+		printk(KERN_ERR "failed to alloc atm sock slab cache\n");
+		goto out;
+	}
 
 	if ((error = atmpvc_init()) < 0) {
 		printk(KERN_ERR "atmpvc_init() failed with %d\n", error);
-		goto failure;
+		goto out_free_slab;
 	}
 	if ((error = atmsvc_init()) < 0) {
 		printk(KERN_ERR "atmsvc_init() failed with %d\n", error);
-		goto failure;
+		goto out_pvc_exit;
 	}
         if ((error = atm_proc_init()) < 0) {
 		printk(KERN_ERR "atm_proc_init() failed with %d\n",error);
-		goto failure;
+		goto out_svc_exit;
 	}
-	return 0;
-
-failure:
+out:
+	return error;
+out_free_slab:
+	kmem_cache_destroy(atm_sk_cachep);
+	atm_sk_cachep = NULL;
+out_pvc_exit:
 	atmsvc_exit();
+out_svc_exit:
 	atmpvc_exit();
-	return error;
+	goto out;
 }
 
 static void __exit atm_exit(void)
@@ -806,6 +811,11 @@
 	atm_proc_exit();
 	atmsvc_exit();
 	atmpvc_exit();
+
+	if (atm_sk_cachep) {
+		kmem_cache_destroy(atm_sk_cachep);
+		atm_sk_cachep = NULL;
+	}
 }
 
 module_init(atm_init);
diff -Nru a/net/atm/signaling.c b/net/atm/signaling.c
--- a/net/atm/signaling.c	2004-12-15 20:32:26 -02:00
+++ b/net/atm/signaling.c	2004-12-15 20:32:26 -02:00
@@ -133,13 +133,13 @@
 			vcc = *(struct atm_vcc **) &msg->listen_vcc;
 			DPRINTK("as_indicate!!!\n");
 			lock_sock(vcc->sk);
-			if (vcc->sk->sk_ack_backlog ==
-			    vcc->sk->sk_max_ack_backlog) {
+			if (sk_ssk(vcc->sk)->ssk_ack_backlog ==
+			    sk_ssk(vcc->sk)->ssk_max_ack_backlog) {
 				sigd_enq(NULL,as_reject,vcc,NULL,NULL);
 				dev_kfree_skb(skb);
 				goto as_indicate_complete;
 			}
-			vcc->sk->sk_ack_backlog++;
+			sk_ssk(vcc->sk)->ssk_ack_backlog++;
 			skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
 			DPRINTK("waking vcc->sk->sk_sleep 0x%p\n", vcc->sk->sk_sleep);
 			vcc->sk->sk_state_change(vcc->sk);
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	2004-12-15 20:32:26 -02:00
+++ b/net/atm/svc.c	2004-12-15 20:32:26 -02:00
@@ -320,7 +320,7 @@
 		goto out;
 	}
 	set_bit(ATM_VF_LISTEN,&vcc->flags);
-	vcc->sk->sk_max_ack_backlog = backlog > 0 ? backlog :
+	sk_ssk(vcc->sk)->ssk_max_ack_backlog = backlog > 0 ? backlog :
 						    ATM_BACKLOG_DEFAULT;
 	error = -sk->sk_err;
 out:
@@ -387,7 +387,7 @@
 		error = vcc_connect(newsock, msg->pvc.sap_addr.itf,
 				    msg->pvc.sap_addr.vpi, msg->pvc.sap_addr.vci);
 		dev_kfree_skb(skb);
-		old_vcc->sk->sk_ack_backlog--;
+		sk_ssk(old_vcc->sk)->ssk_ack_backlog--;
 		if (error) {
 			sigd_enq2(NULL,as_reject,old_vcc,NULL,NULL,
 			    &old_vcc->qos,error);
diff -Nru a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
--- a/net/ax25/af_ax25.c	2004-12-15 20:32:26 -02:00
+++ b/net/ax25/af_ax25.c	2004-12-15 20:32:26 -02:00
@@ -49,7 +49,7 @@
 #include <net/ip.h>
 #include <net/arp.h>
 
-
+static kmem_cache_t *ax25_sk_cachep;
 
 HLIST_HEAD(ax25_list);
 spinlock_t ax25_list_lock = SPIN_LOCK_UNLOCKED;
@@ -466,14 +466,8 @@
 /*
  * Create an empty AX.25 control block.
  */
-ax25_cb *ax25_create_cb(void)
+void ax25_init_cb(ax25_cb *ax25)
 {
-	ax25_cb *ax25;
-
-	if ((ax25 = kmalloc(sizeof(*ax25), GFP_ATOMIC)) == NULL)
-		return NULL;
-
-	memset(ax25, 0x00, sizeof(*ax25));
 	atomic_set(&ax25->refcount, 1);
 
 	skb_queue_head_init(&ax25->write_queue);
@@ -490,6 +484,14 @@
 	ax25_fillin_cb(ax25, NULL);
 
 	ax25->state = AX25_STATE_0;
+}
+
+ax25_cb *ax25_create_cb(void)
+{
+	ax25_cb *ax25 = kmalloc(sizeof(*ax25), GFP_ATOMIC);
+
+	if (ax25)
+		ax25_init_cb(ax25);
 
 	return ax25;
 }
@@ -743,7 +745,7 @@
 
 	lock_sock(sk);
 	if (sk->sk_type == SOCK_SEQPACKET && sk->sk_state != TCP_LISTEN) {
-		sk->sk_max_ack_backlog = backlog;
+		sk_ssk(sk)->ssk_max_ack_backlog = backlog;
 		sk->sk_state           = TCP_LISTEN;
 		goto out;
 	}
@@ -805,14 +807,12 @@
 		return -ESOCKTNOSUPPORT;
 	}
 
-	if ((sk = sk_alloc(PF_AX25, GFP_ATOMIC, 1, NULL)) == NULL)
+	if ((sk = sk_alloc(PF_AX25, GFP_ATOMIC, sizeof(struct ax25_sock),
+			   ax25_sk_cachep)) == NULL)
 		return -ENOMEM;
 
-	ax25 = sk->sk_protinfo = ax25_create_cb();
-	if (!ax25) {
-		sk_free(sk);
-		return -ENOMEM;
-	}
+	ax25 = ax25_sk(sk);
+	ax25_init_cb(ax25);
 
 	sock_init_data(sock, sk);
 	sk_set_owner(sk, THIS_MODULE);
@@ -831,13 +831,12 @@
 	struct sock *sk;
 	ax25_cb *ax25, *oax25;
 
-	if ((sk = sk_alloc(PF_AX25, GFP_ATOMIC, 1, NULL)) == NULL)
+	if ((sk = sk_alloc(PF_AX25, GFP_ATOMIC, sizeof(struct ax25_sock),
+			   ax25_sk_cachep)) == NULL)
 		return NULL;
 
-	if ((ax25 = ax25_create_cb()) == NULL) {
-		sk_free(sk);
-		return NULL;
-	}
+	ax25 = ax25_sk(sk);
+	ax25_init_cb(ax25);
 
 	switch (osk->sk_type) {
 	case SOCK_DGRAM:
@@ -893,7 +892,6 @@
 		memcpy(ax25->digipeat, oax25->digipeat, sizeof(ax25_digi));
 	}
 
-	sk->sk_protinfo = ax25;
 	ax25->sk    = sk;
 
 	return sk;
@@ -1335,7 +1333,7 @@
 
 	/* Now attach up the new socket */
 	kfree_skb(skb);
-	sk->sk_ack_backlog--;
+	sk_ssk(sk)->ssk_ack_backlog--;
 	newsock->sk    = newsk;
 	newsock->state = SS_CONNECTED;
 
@@ -1989,6 +1987,14 @@
 
 static int __init ax25_init(void)
 {
+	
+	ax25_sk_cachep = kmem_cache_create("ax25_sock", sizeof(struct ax25_sock), 0,
+					   SLAB_HWCACHE_ALIGN, NULL, NULL);
+
+	if (ax25_sk_cachep == NULL) {
+		printk(KERN_ERR "failed to alloc ax25 sock slab cache\n");
+		return -ENOMEM;
+	}
 	sock_register(&ax25_family_ops);
 	dev_add_pack(&ax25_packet_type);
 	register_netdevice_notifier(&ax25_dev_notifier);
@@ -2023,5 +2029,10 @@
 	dev_remove_pack(&ax25_packet_type);
 
 	sock_unregister(PF_AX25);
+
+	if (ax25_sk_cachep) {
+		kmem_cache_destroy(ax25_sk_cachep);
+		ax25_sk_cachep = NULL;
+	}
 }
 module_exit(ax25_exit);
diff -Nru a/net/ax25/ax25_in.c b/net/ax25/ax25_in.c
--- a/net/ax25/ax25_in.c	2004-12-15 20:32:26 -02:00
+++ b/net/ax25/ax25_in.c	2004-12-15 20:32:26 -02:00
@@ -356,7 +356,7 @@
 
 	if (sk != NULL) {
 		bh_lock_sock(sk);
-		if (sk->sk_ack_backlog == sk->sk_max_ack_backlog ||
+		if (sk_ssk(sk)->ssk_ack_backlog == sk_ssk(sk)->ssk_max_ack_backlog ||
 		    (make = ax25_make_new(sk, ax25_dev)) == NULL) {
 			if (mine)
 				ax25_return_dm(dev, &src, &dest, &dp);
@@ -373,7 +373,7 @@
 
 		make->sk_state = TCP_ESTABLISHED;
 
-		sk->sk_ack_backlog++;
+		sk_ssk(sk)->ssk_ack_backlog++;
 		bh_unlock_sock(sk);
 	} else {
 		if (!mine) {
@@ -381,13 +381,8 @@
 			return 0;
 		}
 
-		if ((ax25 = ax25_create_cb()) == NULL) {
-			ax25_return_dm(dev, &src, &dest, &dp);
-			kfree_skb(skb);
-			return 0;
-		}
-
-		ax25_fillin_cb(ax25, ax25_dev);
+		ax25_init_cb(ax25_sk(sk));
+		ax25_fillin_cb(ax25_sk(sk), ax25_dev);
 	}
 
 	ax25->source_addr = dest;
diff -Nru a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
--- a/net/bluetooth/af_bluetooth.c	2004-12-15 20:32:26 -02:00
+++ b/net/bluetooth/af_bluetooth.c	2004-12-15 20:32:26 -02:00
@@ -127,6 +127,9 @@
 		sk->sk_protinfo = pi;
 	}
 
+	if (sock->type == SOCK_STREAM)
+		ssk_set_pointer(sk, struct bt_sock, ssk);
+
 	sock_init_data(sock, sk);
 	INIT_LIST_HEAD(&bt_sk(sk)->accept_q);
 
@@ -161,7 +164,7 @@
 	sock_hold(sk);
 	list_add_tail(&bt_sk(sk)->accept_q, &bt_sk(parent)->accept_q);
 	bt_sk(sk)->parent = parent;
-	parent->sk_ack_backlog++;
+	sk_ssk(parent)->ssk_ack_backlog++;
 }
 EXPORT_SYMBOL(bt_accept_enqueue);
 
@@ -170,7 +173,7 @@
 	BT_DBG("sk %p state %d", sk, sk->sk_state);
 
 	list_del_init(&bt_sk(sk)->accept_q);
-	bt_sk(sk)->parent->sk_ack_backlog--;
+	sk_ssk(bt_sk(sk)->parent)->ssk_ack_backlog--;
 	bt_sk(sk)->parent = NULL;
 	sock_put(sk);
 }
diff -Nru a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
--- a/net/bluetooth/l2cap.c	2004-12-15 20:32:26 -02:00
+++ b/net/bluetooth/l2cap.c	2004-12-15 20:32:26 -02:00
@@ -604,8 +604,8 @@
 			goto done;
 	}
 
-	sk->sk_max_ack_backlog = backlog;
-	sk->sk_ack_backlog = 0;
+	sk_ssk(sk)->ssk_max_ack_backlog = backlog;
+	sk_ssk(sk)->ssk_ack_backlog = 0;
 	sk->sk_state = BT_LISTEN;
 
 done:
@@ -892,8 +892,9 @@
 		l2cap_sock_clear_timer(sk);
 		__l2cap_sock_close(sk, 0);
 
-		if (sock_flag(sk, SOCK_LINGER) && sk->sk_lingertime)
-			err = bt_sock_wait_state(sk, BT_CLOSED, sk->sk_lingertime);
+		if (sock_flag(sk, SOCK_LINGER) && sk_ssk(sk)->ssk_lingertime)
+			err = bt_sock_wait_state(sk, BT_CLOSED,
+						 sk_ssk(sk)->ssk_lingertime);
 	}
 	release_sock(sk);
 	return err;
@@ -1406,8 +1407,9 @@
 	result = L2CAP_CR_NO_MEM;
 
 	/* Check for backlog size */
-	if (parent->sk_ack_backlog > parent->sk_max_ack_backlog) {
-		BT_DBG("backlog full %d", parent->sk_ack_backlog); 
+	if (sk_ssk(parent)->ssk_ack_backlog >
+	    sk_ssk(parent)->ssk_max_ack_backlog) {
+		BT_DBG("backlog full %d", sk_ssk(parent)->ssk_ack_backlog); 
 		goto response;
 	}
 
diff -Nru a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
--- a/net/bluetooth/rfcomm/sock.c	2004-12-15 20:32:26 -02:00
+++ b/net/bluetooth/rfcomm/sock.c	2004-12-15 20:32:26 -02:00
@@ -428,8 +428,8 @@
 			goto done;
 	}
 
-	sk->sk_max_ack_backlog = backlog;
-	sk->sk_ack_backlog = 0;
+	sk_ssk(sk)->ssk_max_ack_backlog = backlog;
+	sk_ssk(sk)->ssk_ack_backlog = 0;
 	sk->sk_state = BT_LISTEN;
 
 done:
@@ -739,8 +739,9 @@
 		sk->sk_shutdown = SHUTDOWN_MASK;
 		__rfcomm_sock_close(sk);
 
-		if (sock_flag(sk, SOCK_LINGER) && sk->sk_lingertime)
-			err = bt_sock_wait_state(sk, BT_CLOSED, sk->sk_lingertime);
+		if (sock_flag(sk, SOCK_LINGER) && sk_ssk(sk)->ssk_lingertime)
+			err = bt_sock_wait_state(sk, BT_CLOSED,
+						 sk_ssk(sk)->ssk_lingertime);
 	}
 	release_sock(sk);
 	return err;
@@ -783,8 +784,9 @@
 		return 0;
 
 	/* Check for backlog size */
-	if (parent->sk_ack_backlog > parent->sk_max_ack_backlog) {
-		BT_DBG("backlog full %d", parent->sk_ack_backlog); 
+	if (sk_ssk(parent)->ssk_ack_backlog >
+	    sk_ssk(parent)->ssk_max_ack_backlog) {
+		BT_DBG("backlog full %d", sk_ssk(parent)->ssk_ack_backlog); 
 		goto done;
 	}
 
diff -Nru a/net/bluetooth/sco.c b/net/bluetooth/sco.c
--- a/net/bluetooth/sco.c	2004-12-15 20:32:26 -02:00
+++ b/net/bluetooth/sco.c	2004-12-15 20:32:26 -02:00
@@ -540,8 +540,8 @@
 		goto done;
 	}
 
-	sk->sk_max_ack_backlog = backlog;
-	sk->sk_ack_backlog = 0;
+	sk_ssk(sk)->ssk_max_ack_backlog = backlog;
+	sk_ssk(sk)->ssk_ack_backlog = 0;
 	sk->sk_state = BT_LISTEN;
 
 done:
@@ -733,9 +733,10 @@
 
 	sco_sock_close(sk);
 
-	if (sock_flag(sk, SOCK_LINGER) && sk->sk_lingertime) {
+	if (sock_flag(sk, SOCK_LINGER) && sk_ssk(sk)->ssk_lingertime) {
 		lock_sock(sk);
-		err = bt_sock_wait_state(sk, BT_CLOSED, sk->sk_lingertime);
+		err = bt_sock_wait_state(sk, BT_CLOSED,
+					 sk_ssk(sk)->ssk_lingertime);
 		release_sock(sk);
 	}
 
diff -Nru a/net/core/sock.c b/net/core/sock.c
--- a/net/core/sock.c	2004-12-15 20:32:26 -02:00
+++ b/net/core/sock.c	2004-12-15 20:32:26 -02:00
@@ -307,7 +307,8 @@
 			break;
 
 		case SO_LINGER:
-			if(optlen<sizeof(ling)) {
+			if (sk->sk_type == SOCK_STREAM ||
+			    optlen < sizeof(ling)) {
 				ret = -EINVAL;	/* 1003.1g */
 				break;
 			}
@@ -320,10 +321,10 @@
 			else {
 #if (BITS_PER_LONG == 32)
 				if (ling.l_linger >= MAX_SCHEDULE_TIMEOUT/HZ)
-					sk->sk_lingertime = MAX_SCHEDULE_TIMEOUT;
+					sk_ssk(sk)->ssk_lingertime = MAX_SCHEDULE_TIMEOUT;
 				else
 #endif
-					sk->sk_lingertime = ling.l_linger * HZ;
+					sk_ssk(sk)->ssk_lingertime = ling.l_linger * HZ;
 				sock_set_flag(sk, SOCK_LINGER);
 			}
 			break;
@@ -513,9 +514,11 @@
 			break;
 		
 		case SO_LINGER:	
+			if (sk->sk_type != SOCK_STREAM)
+				return -EINVAL;
 			lv		= sizeof(v.ling);
 			v.ling.l_onoff	= !!sock_flag(sk, SOCK_LINGER);
- 			v.ling.l_linger	= sk->sk_lingertime / HZ;
+ 			v.ling.l_linger	= sk_ssk(sk)->ssk_lingertime / HZ;
 			break;
 					
 		case SO_BSDCOMPAT:
@@ -1156,8 +1159,6 @@
 	skb_queue_head_init(&sk->sk_write_queue);
 	skb_queue_head_init(&sk->sk_error_queue);
 
-	sk->sk_send_head	=	NULL;
-
 	init_timer(&sk->sk_timer);
 	
 	sk->sk_allocation	=	GFP_KERNEL;
@@ -1184,13 +1185,18 @@
 	sk->sk_error_report	=	sock_def_error_report;
 	sk->sk_destruct		=	sock_def_destruct;
 
-	sk->sk_sndmsg_page	=	NULL;
-	sk->sk_sndmsg_off	=	0;
+	if (sk->sk_type == SOCK_STREAM) {
+		struct stream_sock *ssk = sk_ssk(sk);
+
+		ssk->ssk_send_head	=	NULL;
+		ssk->ssk_sndmsg_page	=	NULL;
+		ssk->ssk_sndmsg_off	=	0;
+		ssk->ssk_write_pending	=	0;
+	}
 
 	sk->sk_peercred.pid 	=	0;
 	sk->sk_peercred.uid	=	-1;
 	sk->sk_peercred.gid	=	-1;
-	sk->sk_write_pending	=	0;
 	sk->sk_rcvlowat		=	1;
 	sk->sk_rcvtimeo		=	MAX_SCHEDULE_TIMEOUT;
 	sk->sk_sndtimeo		=	MAX_SCHEDULE_TIMEOUT;
diff -Nru a/net/core/stream.c b/net/core/stream.c
--- a/net/core/stream.c	2004-12-15 20:32:26 -02:00
+++ b/net/core/stream.c	2004-12-15 20:32:26 -02:00
@@ -64,13 +64,13 @@
 			return sock_intr_errno(*timeo_p);
 
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
-		sk->sk_write_pending++;
+		sk_ssk(sk)->ssk_write_pending++;
 		if (sk_wait_event(sk, timeo_p,
 				  !((1 << sk->sk_state) & 
 				    ~(TCPF_ESTABLISHED | TCPF_CLOSE_WAIT))))
 			break;
 		finish_wait(sk->sk_sleep, &wait);
-		sk->sk_write_pending--;
+		sk_ssk(sk)->ssk_write_pending--;
 	}
 	return 0;
 }
@@ -136,10 +136,10 @@
 			break;
 
 		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
-		sk->sk_write_pending++;
+		sk_ssk(sk)->ssk_write_pending++;
 		sk_wait_event(sk, &current_timeo, sk_stream_memory_free(sk) &&
 						  vm_wait);
-		sk->sk_write_pending--;
+		sk_ssk(sk)->ssk_write_pending--;
 
 		if (vm_wait) {
 			vm_wait -= current_timeo;
@@ -173,7 +173,7 @@
 	struct sock *sk = skb->sk;
 
 	atomic_sub(skb->truesize, &sk->sk_rmem_alloc);
-	sk->sk_forward_alloc += skb->truesize;
+	sk_ssk(sk)->ssk_forward_alloc += skb->truesize;
 }
 
 EXPORT_SYMBOL(sk_stream_rfree);
@@ -191,10 +191,12 @@
 
 void __sk_stream_mem_reclaim(struct sock *sk)
 {
-	if (sk->sk_forward_alloc >= SK_STREAM_MEM_QUANTUM) {
-		atomic_sub(sk->sk_forward_alloc / SK_STREAM_MEM_QUANTUM,
+	struct stream_sock *ssk = sk_ssk(sk);
+
+	if (ssk->ssk_forward_alloc >= SK_STREAM_MEM_QUANTUM) {
+		atomic_sub(ssk->ssk_forward_alloc / SK_STREAM_MEM_QUANTUM,
 			   sk->sk_prot->memory_allocated);
-		sk->sk_forward_alloc &= SK_STREAM_MEM_QUANTUM - 1;
+		ssk->ssk_forward_alloc &= SK_STREAM_MEM_QUANTUM - 1;
 		if (*sk->sk_prot->memory_pressure &&
 		    (atomic_read(sk->sk_prot->memory_allocated) <
 		     sk->sk_prot->sysctl_mem[0]))
@@ -207,8 +209,9 @@
 int sk_stream_mem_schedule(struct sock *sk, int size, int kind)
 {
 	int amt = sk_stream_pages(size);
+	struct stream_sock *ssk = sk_ssk(sk);
 
-	sk->sk_forward_alloc += amt * SK_STREAM_MEM_QUANTUM;
+	ssk->ssk_forward_alloc += amt * SK_STREAM_MEM_QUANTUM;
 	atomic_add(amt, sk->sk_prot->memory_allocated);
 
 	/* Under limit. */
@@ -231,14 +234,14 @@
 	if (kind) {
 		if (atomic_read(&sk->sk_rmem_alloc) < sk->sk_prot->sysctl_rmem[0])
 			return 1;
-	} else if (sk->sk_wmem_queued < sk->sk_prot->sysctl_wmem[0])
+	} else if (ssk->ssk_wmem_queued < sk->sk_prot->sysctl_wmem[0])
 		return 1;
 
 	if (!*sk->sk_prot->memory_pressure ||
 	    sk->sk_prot->sysctl_mem[2] > atomic_read(sk->sk_prot->sockets_allocated) *
-				sk_stream_pages(sk->sk_wmem_queued +
+				sk_stream_pages(ssk->ssk_wmem_queued +
 						atomic_read(&sk->sk_rmem_alloc) +
-						sk->sk_forward_alloc))
+						ssk->ssk_forward_alloc))
 		return 1;
 
 suppress_allocation:
@@ -249,12 +252,12 @@
 		/* Fail only if socket is _under_ its sndbuf.
 		 * In this case we cannot block, so that we have to fail.
 		 */
-		if (sk->sk_wmem_queued + size >= sk->sk_sndbuf)
+		if (ssk->ssk_wmem_queued + size >= sk->sk_sndbuf)
 			return 1;
 	}
 
 	/* Alas. Undo changes. */
-	sk->sk_forward_alloc -= amt * SK_STREAM_MEM_QUANTUM;
+	ssk->ssk_forward_alloc -= amt * SK_STREAM_MEM_QUANTUM;
 	atomic_sub(amt, sk->sk_prot->memory_allocated);
 	return 0;
 }
@@ -275,8 +278,8 @@
 	/* Account for returned memory. */
 	sk_stream_mem_reclaim(sk);
 
-	BUG_TRAP(!sk->sk_wmem_queued);
-	BUG_TRAP(!sk->sk_forward_alloc);
+	BUG_TRAP(!sk_ssk(sk)->ssk_wmem_queued);
+	BUG_TRAP(!sk_ssk(sk)->ssk_forward_alloc);
 
 	/* It is _impossible_ for the backlog to contain anything
 	 * when we get here.  All user references to this socket
diff -Nru a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
--- a/net/decnet/af_decnet.c	2004-12-15 20:32:26 -02:00
+++ b/net/decnet/af_decnet.c	2004-12-15 20:32:26 -02:00
@@ -942,7 +942,7 @@
 	fl.proto = DNPROTO_NSP;
 	if (dn_route_output_sock(&sk->sk_dst_cache, &fl, sk, flags) < 0)
 		goto out;
-	sk->sk_route_caps = sk->sk_dst_cache->dev->features;
+	sk_ssk(sk)->ssk_route_caps = sk->sk_dst_cache->dev->features;
 	sock->state = SS_CONNECTING;
 	scp->state = DN_CI;
 	scp->segsize_loc = dst_path_metric(sk->sk_dst_cache, RTAX_ADVMSS);
@@ -1080,7 +1080,7 @@
 	}
 
 	cb = DN_SKB_CB(skb);
-	sk->sk_ack_backlog--;
+	sk_ssk(sk)->ssk_ack_backlog--;
 	newsk = dn_alloc_sock(newsock, sk->sk_allocation);
 	if (newsk == NULL) {
 		release_sock(sk);
@@ -1268,8 +1268,8 @@
 	if ((DN_SK(sk)->state != DN_O) || (sk->sk_state == TCP_LISTEN))
 		goto out;
 
-	sk->sk_max_ack_backlog = backlog;
-	sk->sk_ack_backlog     = 0;
+	sk_ssk(sk)->ssk_max_ack_backlog = backlog;
+	sk_ssk(sk)->ssk_ack_backlog     = 0;
 	sk->sk_state           = TCP_LISTEN;
 	err                 = 0;
 	dn_rehash_sock(sk);
diff -Nru a/net/decnet/dn_nsp_in.c b/net/decnet/dn_nsp_in.c
--- a/net/decnet/dn_nsp_in.c	2004-12-15 20:32:26 -02:00
+++ b/net/decnet/dn_nsp_in.c	2004-12-15 20:32:26 -02:00
@@ -324,12 +324,14 @@
 
 static void dn_nsp_conn_init(struct sock *sk, struct sk_buff *skb)
 {
-	if (sk->sk_ack_backlog >= sk->sk_max_ack_backlog) {
+	struct stream_sock *ssk = sk_ssk(sk);
+
+	if (ssk->ssk_ack_backlog >= ssk->ssk_max_ack_backlog) {
 		kfree_skb(skb);
 		return;
 	}
 
-	sk->sk_ack_backlog++;
+	ssk->ssk_ack_backlog++;
 	skb_queue_tail(&sk->sk_receive_queue, skb);
 	sk->sk_state_change(sk);
 }
diff -Nru a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
--- a/net/decnet/dn_nsp_out.c	2004-12-15 20:32:26 -02:00
+++ b/net/decnet/dn_nsp_out.c	2004-12-15 20:32:26 -02:00
@@ -99,7 +99,7 @@
 	fl.proto = DNPROTO_NSP;
 	if (dn_route_output_sock(&sk->sk_dst_cache, &fl, sk, 0) == 0) {
 		dst = sk_dst_get(sk);
-		sk->sk_route_caps = dst->dev->features;
+		sk_ssk(sk)->ssk_route_caps = dst->dev->features;
 		goto try_again;
 	}
 
diff -Nru a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
--- a/net/ipv4/af_inet.c	2004-12-15 20:32:26 -02:00
+++ b/net/ipv4/af_inet.c	2004-12-15 20:32:26 -02:00
@@ -148,8 +148,8 @@
 
 	BUG_TRAP(!atomic_read(&sk->sk_rmem_alloc));
 	BUG_TRAP(!atomic_read(&sk->sk_wmem_alloc));
-	BUG_TRAP(!sk->sk_wmem_queued);
-	BUG_TRAP(!sk->sk_forward_alloc);
+	BUG_TRAP(!(sk->sk_type == SOCK_STREAM && sk_ssk(sk)->ssk_wmem_queued));
+	BUG_TRAP(!(sk->sk_type == SOCK_STREAM && sk_ssk(sk)->ssk_forward_alloc));
 
 	if (inet->opt)
 		kfree(inet->opt);
@@ -215,7 +215,7 @@
 		if (err)
 			goto out;
 	}
-	sk->sk_max_ack_backlog = backlog;
+	sk_ssk(sk)->ssk_max_ack_backlog = backlog;
 	err = 0;
 
 out:
@@ -308,9 +308,13 @@
 
 	inet->id = 0;
 
-	sock_init_data(sock, sk);
 	sk_set_owner(sk, sk->sk_prot->owner);
 
+	if (sock->type == SOCK_STREAM)
+		ssk_set_pointer(sk, struct tcp_sock, ssk);
+
+	sock_init_data(sock, sk);
+
 	sk->sk_destruct	   = inet_sock_destruct;
 	sk->sk_family	   = PF_INET;
 	sk->sk_protocol	   = protocol;
@@ -375,7 +379,7 @@
 		timeout = 0;
 		if (sock_flag(sk, SOCK_LINGER) &&
 		    !(current->flags & PF_EXITING))
-			timeout = sk->sk_lingertime;
+			timeout = sk_ssk(sk)->ssk_lingertime;
 		sock->sk = NULL;
 		sk->sk_prot->close(sk, timeout);
 	}
diff -Nru a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c	2004-12-15 20:32:26 -02:00
+++ b/net/ipv4/ip_output.c	2004-12-15 20:32:26 -02:00
@@ -747,8 +747,10 @@
 		inet->cork.fragsize = mtu = dst_pmtu(&rt->u.dst);
 		inet->cork.rt = rt;
 		inet->cork.length = 0;
-		sk->sk_sndmsg_page = NULL;
-		sk->sk_sndmsg_off = 0;
+		if (sk->sk_type == SOCK_STREAM) {
+			sk_ssk(sk)->ssk_sndmsg_page = NULL;
+			sk_ssk(sk)->ssk_sndmsg_off = 0;
+		}
 		if ((exthdrlen = rt->u.dst.header_len) != 0) {
 			length += exthdrlen;
 			transhdrlen += exthdrlen;
@@ -914,8 +916,9 @@
 		} else {
 			int i = skb_shinfo(skb)->nr_frags;
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i-1];
-			struct page *page = sk->sk_sndmsg_page;
-			int off = sk->sk_sndmsg_off;
+			struct stream_sock *ssk = sk_ssk(sk);
+			struct page *page = ssk->ssk_sndmsg_page;
+			int off = ssk->ssk_sndmsg_off;
 			unsigned int left;
 
 			if (page && (left = PAGE_SIZE - off) > 0) {
@@ -927,7 +930,7 @@
 						goto error;
 					}
 					get_page(page);
-	 				skb_fill_page_desc(skb, i, page, sk->sk_sndmsg_off, 0);
+	 				skb_fill_page_desc(skb, i, page, ssk->ssk_sndmsg_off, 0);
 					frag = &skb_shinfo(skb)->frags[i];
 				}
 			} else if (i < MAX_SKB_FRAGS) {
@@ -938,8 +941,8 @@
 					err = -ENOMEM;
 					goto error;
 				}
-				sk->sk_sndmsg_page = page;
-				sk->sk_sndmsg_off = 0;
+				ssk->ssk_sndmsg_page = page;
+				ssk->ssk_sndmsg_off = 0;
 
 				skb_fill_page_desc(skb, i, page, 0, 0);
 				frag = &skb_shinfo(skb)->frags[i];
@@ -953,7 +956,7 @@
 				err = -EFAULT;
 				goto error;
 			}
-			sk->sk_sndmsg_off += copy;
+			ssk->ssk_sndmsg_off += copy;
 			frag->size += copy;
 			skb->len += copy;
 			skb->data_len += copy;
diff -Nru a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c	2004-12-15 20:32:26 -02:00
+++ b/net/ipv4/tcp.c	2004-12-15 20:32:26 -02:00
@@ -462,10 +462,10 @@
 {
 	struct inet_opt *inet = inet_sk(sk);
 	struct tcp_opt *tp = tcp_sk(sk);
+	struct stream_sock *ssk = sk_ssk(sk);
 	struct tcp_listen_opt *lopt;
 
-	sk->sk_max_ack_backlog = 0;
-	sk->sk_ack_backlog = 0;
+	ssk->ssk_max_ack_backlog = ssk->ssk_ack_backlog = 0;
 	tp->accept_queue = tp->accept_queue_tail = NULL;
 	rwlock_init(&tp->syn_wait_lock);
 	tcp_delack_init(tp);
@@ -575,7 +575,7 @@
 		sk_acceptq_removed(sk);
 		tcp_openreq_fastfree(req);
 	}
-	BUG_TRAP(!sk->sk_ack_backlog);
+	BUG_TRAP(!sk_ssk(sk)->ssk_ack_backlog);
 }
 
 static inline void tcp_mark_push(struct tcp_opt *tp, struct sk_buff *skb)
@@ -599,8 +599,8 @@
 	TCP_SKB_CB(skb)->sacked = 0;
 	__skb_queue_tail(&sk->sk_write_queue, skb);
 	sk_charge_skb(sk, skb);
-	if (!sk->sk_send_head)
-		sk->sk_send_head = skb;
+	if (!sk_ssk(sk)->ssk_send_head)
+		sk_ssk(sk)->ssk_send_head = skb;
 	else if (tp->nonagle&TCP_NAGLE_PUSH)
 		tp->nonagle &= ~TCP_NAGLE_PUSH; 
 }
@@ -618,7 +618,7 @@
 static inline void tcp_push(struct sock *sk, struct tcp_opt *tp, int flags,
 			    int mss_now, int nonagle)
 {
-	if (sk->sk_send_head) {
+	if (sk_ssk(sk)->ssk_send_head) {
 		struct sk_buff *skb = sk->sk_write_queue.prev;
 		if (!(flags & MSG_MORE) || forced_push(tp))
 			tcp_mark_push(tp, skb);
@@ -658,7 +658,8 @@
 		int offset = poffset % PAGE_SIZE;
 		int size = min_t(size_t, psize, PAGE_SIZE - offset);
 
-		if (!sk->sk_send_head || (copy = mss_now - skb->len) <= 0) {
+		if (!sk_ssk(sk)->ssk_send_head ||
+		    (copy = mss_now - skb->len) <= 0) {
 new_segment:
 			if (!sk_stream_memory_free(sk))
 				goto wait_for_sndbuf;
@@ -707,7 +708,7 @@
 		if (forced_push(tp)) {
 			tcp_mark_push(tp, skb);
 			__tcp_push_pending_frames(sk, tp, mss_now, TCP_NAGLE_PUSH);
-		} else if (skb == sk->sk_send_head)
+		} else if (skb == sk_ssk(sk)->ssk_send_head)
 			tcp_push_one(sk, mss_now);
 		continue;
 
@@ -740,11 +741,12 @@
 {
 	ssize_t res;
 	struct sock *sk = sock->sk;
+	struct stream_sock *ssk = sk_ssk(sk);
 
 #define TCP_ZC_CSUM_FLAGS (NETIF_F_IP_CSUM | NETIF_F_NO_CSUM | NETIF_F_HW_CSUM)
 
-	if (!(sk->sk_route_caps & NETIF_F_SG) ||
-	    !(sk->sk_route_caps & TCP_ZC_CSUM_FLAGS))
+	if (!(ssk->ssk_route_caps & NETIF_F_SG) ||
+	    !(ssk->ssk_route_caps & TCP_ZC_CSUM_FLAGS))
 		return sock_no_sendpage(sock, page, offset, size, flags);
 
 #undef TCP_ZC_CSUM_FLAGS
@@ -757,14 +759,14 @@
 	return res;
 }
 
-#define TCP_PAGE(sk)	(sk->sk_sndmsg_page)
-#define TCP_OFF(sk)	(sk->sk_sndmsg_off)
+#define TCP_PAGE(sk)	(sk_ssk(sk)->ssk_sndmsg_page)
+#define TCP_OFF(sk)	(sk_ssk(sk)->ssk_sndmsg_off)
 
 static inline int select_size(struct sock *sk, struct tcp_opt *tp)
 {
 	int tmp = tp->mss_cache_std;
 
-	if (sk->sk_route_caps & NETIF_F_SG) {
+	if (sk_ssk(sk)->ssk_route_caps & NETIF_F_SG) {
 		int pgbreak = SKB_MAX_HEAD(MAX_TCP_HEADER);
 
 		if (tmp >= pgbreak &&
@@ -821,7 +823,7 @@
 
 			skb = sk->sk_write_queue.prev;
 
-			if (!sk->sk_send_head ||
+			if (!sk_ssk(sk)->ssk_send_head ||
 			    (copy = mss_now - skb->len) <= 0) {
 
 new_segment:
@@ -839,7 +841,7 @@
 				/*
 				 * Check whether we can use HW checksum.
 				 */
-				if (sk->sk_route_caps &
+				if (sk_ssk(sk)->ssk_route_caps &
 				    (NETIF_F_IP_CSUM | NETIF_F_NO_CSUM |
 				     NETIF_F_HW_CSUM))
 					skb->ip_summed = CHECKSUM_HW;
@@ -872,7 +874,7 @@
 					merge = 1;
 				} else if (i == MAX_SKB_FRAGS ||
 					   (!i &&
-					   !(sk->sk_route_caps & NETIF_F_SG))) {
+					   !(sk_ssk(sk)->ssk_route_caps & NETIF_F_SG))) {
 					/* Need to add new fragment and cannot
 					 * do this because interface is non-SG,
 					 * or because all the page slots are
@@ -951,7 +953,7 @@
 			if (forced_push(tp)) {
 				tcp_mark_push(tp, skb);
 				__tcp_push_pending_frames(sk, tp, mss_now, TCP_NAGLE_PUSH);
-			} else if (skb == sk->sk_send_head)
+			} else if (skb == sk_ssk(sk)->ssk_send_head)
 				tcp_push_one(sk, mss_now);
 			continue;
 
@@ -977,8 +979,8 @@
 
 do_fault:
 	if (!skb->len) {
-		if (sk->sk_send_head == skb)
-			sk->sk_send_head = NULL;
+		if (sk_ssk(sk)->ssk_send_head == skb)
+			sk_ssk(sk)->ssk_send_head = NULL;
 		__skb_unlink(skb, skb->list);
 		sk_stream_free_skb(sk, skb);
 	}
@@ -1654,7 +1656,8 @@
 		NET_INC_STATS_USER(LINUX_MIB_TCPABORTONCLOSE);
 		tcp_set_state(sk, TCP_CLOSE);
 		tcp_send_active_reset(sk, GFP_KERNEL);
-	} else if (sock_flag(sk, SOCK_LINGER) && !sk->sk_lingertime) {
+	} else if (sock_flag(sk, SOCK_LINGER) &&
+		   !sk_ssk(sk)->ssk_lingertime) {
 		/* Check zero linger _after_ checking for unread data. */
 		sk->sk_prot->disconnect(sk, 0);
 		NET_INC_STATS_USER(LINUX_MIB_TCPABORTONDATA);
@@ -1739,7 +1742,7 @@
 	if (sk->sk_state != TCP_CLOSE) {
 		sk_stream_mem_reclaim(sk);
 		if (atomic_read(&tcp_orphan_count) > sysctl_tcp_max_orphans ||
-		    (sk->sk_wmem_queued > SOCK_MIN_SNDBUF &&
+		    (sk_ssk(sk)->ssk_wmem_queued > SOCK_MIN_SNDBUF &&
 		     atomic_read(&tcp_memory_allocated) > sysctl_tcp_mem[2])) {
 			if (net_ratelimit())
 				printk(KERN_INFO "TCP: too many of orphaned "
@@ -1818,7 +1821,7 @@
 	tcp_set_ca_state(tp, TCP_CA_Open);
 	tcp_clear_retrans(tp);
 	tcp_delack_init(tp);
-	sk->sk_send_head = NULL;
+	sk_ssk(sk)->ssk_send_head = NULL;
 	tp->saw_tstamp = 0;
 	tcp_sack_reset(tp);
 	__sk_dst_reset(sk);
diff -Nru a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
--- a/net/ipv4/tcp_diag.c	2004-12-15 20:32:26 -02:00
+++ b/net/ipv4/tcp_diag.c	2004-12-15 20:32:26 -02:00
@@ -158,8 +158,8 @@
 
 	if (minfo) {
 		minfo->tcpdiag_rmem = atomic_read(&sk->sk_rmem_alloc);
-		minfo->tcpdiag_wmem = sk->sk_wmem_queued;
-		minfo->tcpdiag_fmem = sk->sk_forward_alloc;
+		minfo->tcpdiag_wmem = sk_ssk(sk)->ssk_wmem_queued;
+		minfo->tcpdiag_fmem = sk_ssk(sk)->ssk_forward_alloc;
 		minfo->tcpdiag_tmem = atomic_read(&sk->sk_wmem_alloc);
 	}
 
diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	2004-12-15 20:32:26 -02:00
+++ b/net/ipv4/tcp_input.c	2004-12-15 20:32:26 -02:00
@@ -962,6 +962,7 @@
 tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_una)
 {
 	struct tcp_opt *tp = tcp_sk(sk);
+	struct stream_sock *ssk = sk_ssk(sk);
 	unsigned char *ptr = ack_skb->h.raw + TCP_SKB_CB(ack_skb)->sacked;
 	struct tcp_sack_block *sp = (struct tcp_sack_block *)(ptr+2);
 	int num_sacks = (ptr[1] - TCPOLEN_SACK_BASE)>>3;
@@ -973,9 +974,9 @@
 
 	/* So, SACKs for already sent large segments will be lost.
 	 * Not good, but alternative is to resegment the queue. */
-	if (sk->sk_route_caps & NETIF_F_TSO) {
-		sk->sk_route_caps &= ~NETIF_F_TSO;
-		sk->sk_no_largesend = 1;
+	if (ssk->ssk_route_caps & NETIF_F_TSO) {
+		ssk->ssk_route_caps &= ~NETIF_F_TSO;
+		ssk->ssk_no_largesend = 1;
 		tp->mss_cache = tp->mss_cache_std;
 	}
 
@@ -2435,7 +2436,7 @@
 	__s32 seq_rtt = -1;
 
 	while ((skb = skb_peek(&sk->sk_write_queue)) &&
-	       skb != sk->sk_send_head) {
+	       skb != sk_ssk(sk)->ssk_send_head) {
 		struct tcp_skb_cb *scb = TCP_SKB_CB(skb); 
 		__u8 sacked = scb->sacked;
 
@@ -2529,7 +2530,7 @@
 
 	/* Was it a usable window open? */
 
-	if (!after(TCP_SKB_CB(sk->sk_send_head)->end_seq,
+	if (!after(TCP_SKB_CB(sk_ssk(sk)->ssk_send_head)->end_seq,
 		   tp->snd_una + tp->snd_wnd)) {
 		tp->backoff = 0;
 		tcp_clear_xmit_timer(sk, TCP_TIME_PROBE0);
@@ -2967,7 +2968,7 @@
 	 * being used to time the probes, and is probably far higher than
 	 * it needs to be for normal retransmission.
 	 */
-	if (sk->sk_send_head)
+	if (sk_ssk(sk)->ssk_send_head)
 		tcp_ack_probe(sk);
 	return 1;
 
@@ -3943,7 +3944,7 @@
 
 
 /* When incoming ACK allowed to free some skb from write_queue,
- * we remember this event in flag sk->sk_queue_shrunk and wake up socket
+ * we remember this event in flag sk_ssk(sk)->ssk_queue_shrunk and wake up socket
  * on the exit from tcp input handler.
  *
  * PROBLEM: sndbuf expansion does not work well with largesend.
@@ -3971,8 +3972,8 @@
 
 static inline void tcp_check_space(struct sock *sk)
 {
-	if (sk->sk_queue_shrunk) {
-		sk->sk_queue_shrunk = 0;
+	if (sk_ssk(sk)->ssk_queue_shrunk) {
+		sk_ssk(sk)->ssk_queue_shrunk = 0;
 		if (sk->sk_socket &&
 		    test_bit(SOCK_NOSPACE, &sk->sk_socket->flags))
 			tcp_new_space(sk);
@@ -3991,7 +3992,7 @@
 
 static __inline__ void tcp_data_snd_check(struct sock *sk)
 {
-	struct sk_buff *skb = sk->sk_send_head;
+	struct sk_buff *skb = sk_ssk(sk)->ssk_send_head;
 
 	if (skb != NULL)
 		__tcp_data_snd_check(sk, skb);
@@ -4337,7 +4338,7 @@
 
 				tcp_rcv_rtt_measure_ts(tp, skb);
 
-				if ((int)skb->truesize > sk->sk_forward_alloc)
+				if ((int)skb->truesize > sk_ssk(sk)->ssk_forward_alloc)
 					goto step5;
 
 				NET_INC_STATS_BH(LINUX_MIB_TCPHPHITS);
@@ -4515,7 +4516,7 @@
 
 		TCP_ECN_rcv_synack(tp, th);
 		if (tp->ecn_flags&TCP_ECN_OK)
-			sk->sk_no_largesend = 1;
+			sk_ssk(sk)->ssk_no_largesend = 1;
 
 		tp->snd_wl1 = TCP_SKB_CB(skb)->seq;
 		tcp_ack(sk, skb, FLAG_SLOWPATH);
@@ -4585,7 +4586,8 @@
 			sk_wake_async(sk, 0, POLL_OUT);
 		}
 
-		if (sk->sk_write_pending || tp->defer_accept || tp->ack.pingpong) {
+		if (sk_ssk(sk)->ssk_write_pending ||
+		    tp->defer_accept || tp->ack.pingpong) {
 			/* Save one ACK. Data will be ready after
 			 * several ticks, if write_pending is set.
 			 *
@@ -4653,7 +4655,7 @@
 
 		TCP_ECN_rcv_syn(tp, th);
 		if (tp->ecn_flags&TCP_ECN_OK)
-			sk->sk_no_largesend = 1;
+			sk_ssk(sk)->ssk_no_largesend = 1;
 
 		tcp_sync_mss(sk, tp->pmtu_cookie);
 		tcp_initialize_rcv_mss(sk);
diff -Nru a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	2004-12-15 20:32:26 -02:00
+++ b/net/ipv4/tcp_ipv4.c	2004-12-15 20:32:26 -02:00
@@ -359,8 +359,8 @@
 		lock = &tcp_lhash_lock;
 		tcp_listen_wlock();
 	} else {
-		list = &tcp_ehash[(sk->sk_hashent = tcp_sk_hashfn(sk))].chain;
-		lock = &tcp_ehash[sk->sk_hashent].lock;
+		list = &tcp_ehash[(sk_ssk(sk)->ssk_hashent = tcp_sk_hashfn(sk))].chain;
+		lock = &tcp_ehash[sk_ssk(sk)->ssk_hashent].lock;
 		write_lock(lock);
 	}
 	__sk_add_node(sk, list);
@@ -391,7 +391,7 @@
 		tcp_listen_wlock();
 		lock = &tcp_lhash_lock;
 	} else {
-		struct tcp_ehash_bucket *head = &tcp_ehash[sk->sk_hashent];
+		struct tcp_ehash_bucket *head = &tcp_ehash[sk_ssk(sk)->ssk_hashent];
 		lock = &head->lock;
 		write_lock_bh(&head->lock);
 	}
@@ -612,7 +612,7 @@
 	 * in hash table socket with a funny identity. */
 	inet->num = lport;
 	inet->sport = htons(lport);
-	sk->sk_hashent = hash;
+	sk_ssk(sk)->ssk_hashent = hash;
 	BUG_TRAP(sk_unhashed(sk));
 	__sk_add_node(sk, &head->chain);
 	sock_prot_inc_use(sk->sk_prot);
@@ -864,7 +864,7 @@
 	/* This unhashes the socket and releases the local port, if necessary. */
 	tcp_set_state(sk, TCP_CLOSE);
 	ip_rt_put(rt);
-	sk->sk_route_caps = 0;
+	sk_ssk(sk)->ssk_route_caps = 0;
 	inet->dport = 0;
 	return err;
 }
@@ -1954,7 +1954,7 @@
 	}
 
 	/* Routing failed... */
-	sk->sk_route_caps = 0;
+	sk_ssk(sk)->ssk_route_caps = 0;
 
 	if (!sysctl_ip_dynaddr ||
 	    sk->sk_state != TCP_SYN_SENT ||
@@ -2095,6 +2095,7 @@
 int tcp_v4_destroy_sock(struct sock *sk)
 {
 	struct tcp_opt *tp = tcp_sk(sk);
+	struct stream_sock *ssk = sk_ssk(sk);
 
 	tcp_clear_xmit_timers(sk);
 
@@ -2114,9 +2115,9 @@
 	/*
 	 * If sendmsg cached page exists, toss it.
 	 */
-	if (sk->sk_sndmsg_page) {
-		__free_page(sk->sk_sndmsg_page);
-		sk->sk_sndmsg_page = NULL;
+	if (ssk->ssk_sndmsg_page) {
+		__free_page(ssk->ssk_sndmsg_page);
+		ssk->ssk_sndmsg_page = NULL;
 	}
 
 	atomic_dec(&tcp_sockets_allocated);
diff -Nru a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
--- a/net/ipv4/tcp_minisocks.c	2004-12-15 20:32:26 -02:00
+++ b/net/ipv4/tcp_minisocks.c	2004-12-15 20:32:26 -02:00
@@ -294,7 +294,7 @@
  */
 static void __tcp_tw_hashdance(struct sock *sk, struct tcp_tw_bucket *tw)
 {
-	struct tcp_ehash_bucket *ehead = &tcp_ehash[sk->sk_hashent];
+	struct tcp_ehash_bucket *ehead = &tcp_ehash[sk_ssk(sk)->ssk_hashent];
 	struct tcp_bind_hashbucket *bhead;
 
 	/* Step 1: Put TW into bind hash. Original socket stays there too.
@@ -354,7 +354,7 @@
 		tw->tw_rcv_wscale	= tp->rcv_wscale;
 		atomic_set(&tw->tw_refcnt, 1);
 
-		tw->tw_hashent		= sk->sk_hashent;
+		tw->tw_hashent		= sk_ssk(sk)->ssk_hashent;
 		tw->tw_rcv_nxt		= tp->rcv_nxt;
 		tw->tw_snd_nxt		= tp->snd_nxt;
 		tw->tw_rcv_wnd		= tcp_receive_window(tp);
@@ -695,6 +695,7 @@
 
 		memcpy(newsk, sk, sizeof(struct tcp_sock));
 		newsk->sk_state = TCP_SYN_RECV;
+		ssk_set_pointer(newsk, struct tcp_sock, ssk);
 
 		/* SANITY */
 		sk_node_init(&newsk->sk_node);
@@ -712,13 +713,13 @@
 		atomic_set(&newsk->sk_wmem_alloc, 0);
 		skb_queue_head_init(&newsk->sk_write_queue);
 		atomic_set(&newsk->sk_omem_alloc, 0);
-		newsk->sk_wmem_queued = 0;
-		newsk->sk_forward_alloc = 0;
+		sk_ssk(newsk)->ssk_wmem_queued = 0;
+		sk_ssk(newsk)->ssk_forward_alloc = 0;
 
 		sock_reset_flag(newsk, SOCK_DONE);
 		newsk->sk_userlocks = sk->sk_userlocks & ~SOCK_BINDPORT_LOCK;
 		newsk->sk_backlog.head = newsk->sk_backlog.tail = NULL;
-		newsk->sk_send_head = NULL;
+		sk_ssk(newsk)->ssk_send_head = NULL;
 		rwlock_init(&newsk->sk_callback_lock);
 		skb_queue_head_init(&newsk->sk_error_queue);
 		newsk->sk_write_space = sk_stream_write_space;
@@ -839,7 +840,7 @@
 		newtp->mss_clamp = req->mss;
 		TCP_ECN_openreq_child(newtp, req);
 		if (newtp->ecn_flags&TCP_ECN_OK)
-			newsk->sk_no_largesend = 1;
+			sk_ssk(newsk)->ssk_no_largesend = 1;
 
 		tcp_ca_init(newtp);
 
diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	2004-12-15 20:32:26 -02:00
+++ b/net/ipv4/tcp_output.c	2004-12-15 20:32:26 -02:00
@@ -54,9 +54,11 @@
 static __inline__
 void update_send_head(struct sock *sk, struct tcp_opt *tp, struct sk_buff *skb)
 {
-	sk->sk_send_head = skb->next;
-	if (sk->sk_send_head == (struct sk_buff *)&sk->sk_write_queue)
-		sk->sk_send_head = NULL;
+	struct stream_sock *ssk = sk_ssk(sk);
+
+	ssk->ssk_send_head = skb->next;
+	if (ssk->ssk_send_head == (struct sk_buff *)&sk->sk_write_queue)
+		ssk->ssk_send_head = NULL;
 	tp->snd_nxt = TCP_SKB_CB(skb)->end_seq;
 	tcp_packets_out_inc(sk, tp, skb);
 }
@@ -404,8 +406,8 @@
 	sk_charge_skb(sk, skb);
 
 	/* Queue it, remembering where we must start sending. */
-	if (sk->sk_send_head == NULL)
-		sk->sk_send_head = skb;
+	if (sk_ssk(sk)->ssk_send_head == NULL)
+		sk_ssk(sk)->ssk_send_head = skb;
 }
 
 /* Send _single_ skb sitting at the send head. This function requires
@@ -414,13 +416,13 @@
 void tcp_push_one(struct sock *sk, unsigned cur_mss)
 {
 	struct tcp_opt *tp = tcp_sk(sk);
-	struct sk_buff *skb = sk->sk_send_head;
+	struct sk_buff *skb = sk_ssk(sk)->ssk_send_head;
 
 	if (tcp_snd_test(tp, skb, cur_mss, TCP_NAGLE_PUSH)) {
 		/* Send it out now. */
 		TCP_SKB_CB(skb)->when = tcp_time_stamp;
 		if (!tcp_transmit_skb(sk, skb_clone(skb, sk->sk_allocation))) {
-			sk->sk_send_head = NULL;
+			sk_ssk(sk)->ssk_send_head = NULL;
 			tp->snd_nxt = TCP_SKB_CB(skb)->end_seq;
 			tcp_packets_out_inc(sk, tp, skb);
 			return;
@@ -566,6 +568,8 @@
 
 int tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len)
 {
+	struct stream_sock *ssk;
+
 	if (skb_cloned(skb) &&
 	    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
 		return -ENOMEM;
@@ -581,9 +585,11 @@
 	skb->ip_summed = CHECKSUM_HW;
 
 	skb->truesize	     -= len;
-	sk->sk_queue_shrunk   = 1;
-	sk->sk_wmem_queued   -= len;
-	sk->sk_forward_alloc += len;
+
+	ssk = sk_ssk(sk);
+	ssk->ssk_queue_shrunk   = 1;
+	ssk->ssk_wmem_queued   -= len;
+	ssk->ssk_forward_alloc += len;
 
 	/* Any change of skb->len requires recalculation of tso
 	 * factor and mss.
@@ -679,7 +685,7 @@
 	}
 
 	do_large = (large &&
-		    (sk->sk_route_caps & NETIF_F_TSO) &&
+		    (sk_ssk(sk)->ssk_route_caps & NETIF_F_TSO) &&
 		    !tp->urg_mode);
 
 	if (do_large) {
@@ -745,7 +751,7 @@
 		 */
 		mss_now = tcp_current_mss(sk, 1);
 
-		while ((skb = sk->sk_send_head) &&
+		while ((skb = sk_ssk(sk)->ssk_send_head) &&
 		       tcp_snd_test(tp, skb, mss_now,
 			       	    tcp_skb_is_last(sk, skb) ? nonagle :
 				    			       TCP_NAGLE_PUSH)) {
@@ -772,7 +778,8 @@
 			return 0;
 		}
 
-		return !tcp_get_pcount(&tp->packets_out) && sk->sk_send_head;
+		return !tcp_get_pcount(&tp->packets_out) &&
+		       sk_ssk(sk)->ssk_send_head;
 	}
 	return 0;
 }
@@ -1017,6 +1024,7 @@
 int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_opt *tp = tcp_sk(sk);
+	struct stream_sock *ssk = sk_ssk(sk);
  	unsigned int cur_mss = tcp_current_mss(sk, 0);
 	int err;
 
@@ -1024,16 +1032,16 @@
 	 * copying overhead: frgagmentation, tunneling, mangling etc.
 	 */
 	if (atomic_read(&sk->sk_wmem_alloc) >
-	    min(sk->sk_wmem_queued + (sk->sk_wmem_queued >> 2), sk->sk_sndbuf))
+	    min(ssk->ssk_wmem_queued + (ssk->ssk_wmem_queued >> 2), sk->sk_sndbuf))
 		return -EAGAIN;
 
 	if (before(TCP_SKB_CB(skb)->seq, tp->snd_una)) {
 		if (before(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
 			BUG();
 
-		if (sk->sk_route_caps & NETIF_F_TSO) {
-			sk->sk_route_caps &= ~NETIF_F_TSO;
-			sk->sk_no_largesend = 1;
+		if (ssk->ssk_route_caps & NETIF_F_TSO) {
+			ssk->ssk_route_caps &= ~NETIF_F_TSO;
+			ssk->ssk_no_largesend = 1;
 			tp->mss_cache = tp->mss_cache_std;
 		}
 
@@ -1067,7 +1075,7 @@
 	/* Collapse two adjacent packets if worthwhile and we can. */
 	if(!(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_SYN) &&
 	   (skb->len < (cur_mss >> 1)) &&
-	   (skb->next != sk->sk_send_head) &&
+	   (skb->next != ssk->ssk_send_head) &&
 	   (skb->next != (struct sk_buff *)&sk->sk_write_queue) &&
 	   (skb_shinfo(skb)->nr_frags == 0 && skb_shinfo(skb->next)->nr_frags == 0) &&
 	   (sysctl_tcp_retrans_collapse != 0))
@@ -1245,7 +1253,7 @@
 	 */
 	mss_now = tcp_current_mss(sk, 1);
 
-	if (sk->sk_send_head != NULL) {
+	if (sk_ssk(sk)->ssk_send_head != NULL) {
 		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_FIN;
 		TCP_SKB_CB(skb)->end_seq++;
 		tp->write_seq++;
@@ -1635,9 +1643,10 @@
 {
 	if (sk->sk_state != TCP_CLOSE) {
 		struct tcp_opt *tp = tcp_sk(sk);
+		struct stream_sock *ssk = sk_ssk(sk);
 		struct sk_buff *skb;
 
-		if ((skb = sk->sk_send_head) != NULL &&
+		if ((skb = ssk->ssk_send_head) != NULL &&
 		    before(TCP_SKB_CB(skb)->seq, tp->snd_una+tp->snd_wnd)) {
 			int err;
 			unsigned int mss = tcp_current_mss(sk, 0);
@@ -1658,9 +1667,9 @@
 					return -1;
 				/* SWS override triggered forced fragmentation.
 				 * Disable TSO, the connection is too sick. */
-				if (sk->sk_route_caps & NETIF_F_TSO) {
-					sk->sk_no_largesend = 1;
-					sk->sk_route_caps &= ~NETIF_F_TSO;
+				if (ssk->ssk_route_caps & NETIF_F_TSO) {
+					ssk->ssk_no_largesend = 1;
+					ssk->ssk_route_caps &= ~NETIF_F_TSO;
 					tp->mss_cache = tp->mss_cache_std;
 				}
 			} else if (!tcp_skb_pcount(skb))
@@ -1693,7 +1702,7 @@
 
 	err = tcp_write_wakeup(sk);
 
-	if (tcp_get_pcount(&tp->packets_out) || !sk->sk_send_head) {
+	if (tcp_get_pcount(&tp->packets_out) || !sk_ssk(sk)->ssk_send_head) {
 		/* Cancel probe timer, if it is not required. */
 		tp->probes_out = 0;
 		tp->backoff = 0;
diff -Nru a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
--- a/net/ipv4/tcp_timer.c	2004-12-15 20:32:26 -02:00
+++ b/net/ipv4/tcp_timer.c	2004-12-15 20:32:26 -02:00
@@ -114,7 +114,7 @@
 		orphans <<= 1;
 
 	if (orphans >= sysctl_tcp_max_orphans ||
-	    (sk->sk_wmem_queued > SOCK_MIN_SNDBUF &&
+	    (sk_ssk(sk)->ssk_wmem_queued > SOCK_MIN_SNDBUF &&
 	     atomic_read(&tcp_memory_allocated) > sysctl_tcp_mem[2])) {
 		if (net_ratelimit())
 			printk(KERN_INFO "Out of socket memory\n");
@@ -271,7 +271,7 @@
 	struct tcp_opt *tp = tcp_sk(sk);
 	int max_probes;
 
-	if (tcp_get_pcount(&tp->packets_out) || !sk->sk_send_head) {
+	if (tcp_get_pcount(&tp->packets_out) || !sk_ssk(sk)->ssk_send_head) {
 		tp->probes_out = 0;
 		return;
 	}
@@ -608,7 +608,7 @@
 	elapsed = keepalive_time_when(tp);
 
 	/* It is alive without keepalive 8) */
-	if (tcp_get_pcount(&tp->packets_out) || sk->sk_send_head)
+	if (tcp_get_pcount(&tp->packets_out) || sk_ssk(sk)->ssk_send_head)
 		goto resched;
 
 	elapsed = tcp_time_stamp - tp->rcv_tstamp;
diff -Nru a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
--- a/net/ipv6/af_inet6.c	2004-12-15 20:32:26 -02:00
+++ b/net/ipv6/af_inet6.c	2004-12-15 20:32:26 -02:00
@@ -173,6 +173,9 @@
 	if (sk == NULL)
 		goto out;
 
+	if (sock->type == SOCK_STREAM)
+		ssk_set_pointer(sk, struct tcp6_sock, ssk);
+
 	sock_init_data(sock, sk);
 	sk->sk_prot = answer_prot;
 	sk_set_owner(sk, sk->sk_prot->owner);
diff -Nru a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c	2004-12-15 20:32:26 -02:00
+++ b/net/ipv6/ip6_output.c	2004-12-15 20:32:26 -02:00
@@ -847,8 +847,10 @@
 		np->cork.hop_limit = hlimit;
 		inet->cork.fragsize = mtu = dst_pmtu(&rt->u.dst);
 		inet->cork.length = 0;
-		sk->sk_sndmsg_page = NULL;
-		sk->sk_sndmsg_off = 0;
+		if (sk->sk_type == SOCK_STREAM) {
+			sk_ssk(sk)->ssk_sndmsg_page = NULL;
+			sk_ssk(sk)->ssk_sndmsg_off = 0;
+		}
 		exthdrlen = rt->u.dst.header_len + (opt ? opt->opt_flen : 0);
 		length += exthdrlen;
 		transhdrlen += exthdrlen;
@@ -1028,8 +1030,9 @@
 		} else {
 			int i = skb_shinfo(skb)->nr_frags;
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i-1];
-			struct page *page = sk->sk_sndmsg_page;
-			int off = sk->sk_sndmsg_off;
+			struct stream_sock *ssk = sk_ssk(sk);
+			struct page *page = ssk->ssk_sndmsg_page;
+			int off = ssk->ssk_sndmsg_off;
 			unsigned int left;
 
 			if (page && (left = PAGE_SIZE - off) > 0) {
@@ -1041,7 +1044,8 @@
 						goto error;
 					}
 					get_page(page);
-					skb_fill_page_desc(skb, i, page, sk->sk_sndmsg_off, 0);
+					skb_fill_page_desc(skb, i, page,
+							   ssk->ssk_sndmsg_off, 0);
 					frag = &skb_shinfo(skb)->frags[i];
 				}
 			} else if(i < MAX_SKB_FRAGS) {
@@ -1052,8 +1056,8 @@
 					err = -ENOMEM;
 					goto error;
 				}
-				sk->sk_sndmsg_page = page;
-				sk->sk_sndmsg_off = 0;
+				ssk->ssk_sndmsg_page = page;
+				ssk->ssk_sndmsg_off = 0;
 
 				skb_fill_page_desc(skb, i, page, 0, 0);
 				frag = &skb_shinfo(skb)->frags[i];
@@ -1067,7 +1071,7 @@
 				err = -EFAULT;
 				goto error;
 			}
-			sk->sk_sndmsg_off += copy;
+			ssk->ssk_sndmsg_off += copy;
 			frag->size += copy;
 			skb->len += copy;
 			skb->data_len += copy;
diff -Nru a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	2004-12-15 20:32:26 -02:00
+++ b/net/ipv6/tcp_ipv6.c	2004-12-15 20:32:26 -02:00
@@ -220,9 +220,11 @@
 		lock = &tcp_lhash_lock;
 		tcp_listen_wlock();
 	} else {
-		sk->sk_hashent = tcp_v6_sk_hashfn(sk);
-		list = &tcp_ehash[sk->sk_hashent].chain;
-		lock = &tcp_ehash[sk->sk_hashent].lock;
+		struct stream_sock *ssk = sk_ssk(sk);
+
+		ssk->ssk_hashent = tcp_v6_sk_hashfn(sk);
+		list = &tcp_ehash[ssk->ssk_hashent].chain;
+		lock = &tcp_ehash[ssk->ssk_hashent].lock;
 		write_lock(lock);
 	}
 
@@ -492,7 +494,7 @@
 unique:
 	BUG_TRAP(sk_unhashed(sk));
 	__sk_add_node(sk, &head->chain);
-	sk->sk_hashent = hash;
+	sk_ssk(sk)->ssk_hashent = hash;
 	sock_prot_inc_use(sk->sk_prot);
 	write_unlock_bh(&head->lock);
 
@@ -695,7 +697,7 @@
 	inet->rcv_saddr = LOOPBACK4_IPV6;
 
 	ip6_dst_store(sk, dst, NULL);
-	sk->sk_route_caps = dst->dev->features &
+	sk_ssk(sk)->ssk_route_caps = dst->dev->features &
 		~(NETIF_F_IP_CSUM | NETIF_F_TSO);
 
 	tp->ext_header_len = 0;
@@ -729,7 +731,7 @@
 	__sk_dst_reset(sk);
 failure:
 	inet->dport = 0;
-	sk->sk_route_caps = 0;
+	sk_ssk(sk)->ssk_route_caps = 0;
 	return err;
 }
 
@@ -1386,7 +1388,7 @@
 #endif
 
 	ip6_dst_store(newsk, dst, NULL);
-	newsk->sk_route_caps = dst->dev->features &
+	sk_ssk(newsk)->ssk_route_caps = dst->dev->features &
 		~(NETIF_F_IP_CSUM | NETIF_F_TSO);
 
 	newtcp6sk = (struct tcp6_sock *)newsk;
@@ -1776,7 +1778,7 @@
 
 		err = ip6_dst_lookup(sk, &dst, &fl);
 		if (err) {
-			sk->sk_route_caps = 0;
+			sk_ssk(sk)->ssk_route_caps = 0;
 			return err;
 		}
 		if (final_p)
@@ -1789,7 +1791,7 @@
 		}
 
 		ip6_dst_store(sk, dst, NULL);
-		sk->sk_route_caps = dst->dev->features &
+		sk_ssk(sk)->ssk_route_caps = dst->dev->features &
 			~(NETIF_F_IP_CSUM | NETIF_F_TSO);
 		tcp_sk(sk)->ext2_header_len = dst->header_len;
 	}
@@ -1837,13 +1839,13 @@
 			ipv6_addr_copy(&fl.fl6_dst, final_p);
 
 		if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
-			sk->sk_route_caps = 0;
+			sk_ssk(sk)->ssk_route_caps = 0;
 			dst_release(dst);
 			return err;
 		}
 
 		ip6_dst_store(sk, dst, NULL);
-		sk->sk_route_caps = dst->dev->features &
+		sk_ssk(sk)->ssk_route_caps = dst->dev->features &
 			~(NETIF_F_IP_CSUM | NETIF_F_TSO);
 		tcp_sk(sk)->ext2_header_len = dst->header_len;
 	}
diff -Nru a/net/irda/af_irda.c b/net/irda/af_irda.c
--- a/net/irda/af_irda.c	2004-12-15 20:32:26 -02:00
+++ b/net/irda/af_irda.c	2004-12-15 20:32:26 -02:00
@@ -760,8 +760,8 @@
 		return -EOPNOTSUPP;
 
 	if (sk->sk_state != TCP_LISTEN) {
-		sk->sk_max_ack_backlog = backlog;
-		sk->sk_state           = TCP_LISTEN;
+		sk_ssk(sk)->ssk_max_ack_backlog = backlog;
+		sk->sk_state			= TCP_LISTEN;
 
 		return 0;
 	}
@@ -937,7 +937,7 @@
 	skb->sk = NULL;
 	skb->destructor = NULL;
 	kfree_skb(skb);
-	sk->sk_ack_backlog--;
+	sk_ssk(sk)->ssk_ack_backlog--;
 
 	newsock->state = SS_CONNECTED;
 
diff -Nru a/net/llc/af_llc.c b/net/llc/af_llc.c
--- a/net/llc/af_llc.c	2004-12-15 20:32:26 -02:00
+++ b/net/llc/af_llc.c	2004-12-15 20:32:26 -02:00
@@ -464,9 +464,7 @@
 	rc = 0;
 	if (!(unsigned)backlog)	/* BSDism */
 		backlog = 1;
-	sk->sk_max_ack_backlog = backlog;
 	if (sk->sk_state != TCP_LISTEN) {
-		sk->sk_ack_backlog = 0;
 		sk->sk_state	   = TCP_LISTEN;
 	}
 	sk->sk_socket->flags |= __SO_ACCEPTCON;
@@ -648,7 +646,6 @@
 
 	/* put original socket back into a clean listen state. */
 	sk->sk_state = TCP_LISTEN;
-	sk->sk_ack_backlog--;
 	skb->sk = NULL;
 	dprintk("%s: ok success on %02X, client on %02X\n", __FUNCTION__,
 		llc_sk(sk)->addr.sllc_sap, newllc->daddr.lsap);
diff -Nru a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
--- a/net/netrom/af_netrom.c	2004-12-15 20:32:26 -02:00
+++ b/net/netrom/af_netrom.c	2004-12-15 20:32:26 -02:00
@@ -406,8 +406,8 @@
 	lock_sock(sk);
 	if (sk->sk_state != TCP_LISTEN) {
 		memset(&nr_sk(sk)->user_addr, 0, AX25_ADDR_LEN);
-		sk->sk_max_ack_backlog = backlog;
-		sk->sk_state           = TCP_LISTEN;
+		sk_ssk(sk)->ssk_max_ack_backlog	= backlog;
+		sk->sk_state			= TCP_LISTEN;
 		release_sock(sk);
 		return 0;
 	}
@@ -806,7 +806,7 @@
 
 	/* Now attach up the new socket */
 	kfree_skb(skb);
-	sk->sk_ack_backlog--;
+	sk_ssk(sk)->ssk_ack_backlog--;
 	newsock->sk = newsk;
 
 out:
@@ -939,7 +939,8 @@
 
 	user = (ax25_address *)(skb->data + 21);
 
-	if (!sk || sk->sk_ack_backlog == sk->sk_max_ack_backlog ||
+	if (!sk || sk_ssk(sk)->ssk_ack_backlog ==
+		   sk_ssk(sk)->ssk_max_ack_backlog ||
 	    (make = nr_make_new(sk)) == NULL) {
 		nr_transmit_refusal(skb, 0);
 		if (sk)
@@ -992,7 +993,7 @@
 	nr_make->vr        = 0;
 	nr_make->vl        = 0;
 	nr_make->state     = NR_STATE_3;
-	sk->sk_ack_backlog++;
+	sk_ssk(sk)->ssk_ack_backlog++;
 
 	nr_insert_socket(make);
 
diff -Nru a/net/rose/af_rose.c b/net/rose/af_rose.c
--- a/net/rose/af_rose.c	2004-12-15 20:32:26 -02:00
+++ b/net/rose/af_rose.c	2004-12-15 20:32:26 -02:00
@@ -497,8 +497,8 @@
 		memset(&rose->dest_addr, 0, ROSE_ADDR_LEN);
 		memset(&rose->dest_call, 0, AX25_ADDR_LEN);
 		memset(rose->dest_digis, 0, AX25_ADDR_LEN * ROSE_MAX_DIGIS);
-		sk->sk_max_ack_backlog = backlog;
-		sk->sk_state           = TCP_LISTEN;
+		sk_ssk(sk)->ssk_max_ack_backlog	= backlog;
+		sk->sk_state			= TCP_LISTEN;
 		return 0;
 	}
 
@@ -888,7 +888,7 @@
 	/* Now attach up the new socket */
 	skb->sk = NULL;
 	kfree_skb(skb);
-	sk->sk_ack_backlog--;
+	sk_ssk(sk)->ssk_ack_backlog--;
 	newsock->sk = newsk;
 
 out:
@@ -954,7 +954,8 @@
 	/*
 	 * We can't accept the Call Request.
 	 */
-	if (!sk || sk->sk_ack_backlog == sk->sk_max_ack_backlog ||
+	if (!sk || sk_ssk(sk)->ssk_ack_backlog ==
+		   sk_ssk(sk)->ssk_max_ack_backlog ||
 	    (make = rose_make_new(sk)) == NULL) {
 		rose_transmit_clear_request(neigh, lci, ROSE_NETWORK_CONGESTION, 120);
 		return 0;
@@ -994,7 +995,7 @@
 	make_rose->va        = 0;
 	make_rose->vr        = 0;
 	make_rose->vl        = 0;
-	sk->sk_ack_backlog++;
+	sk_ssk(sk)->ssk_ack_backlog++;
 
 	rose_insert_socket(make);
 
diff -Nru a/net/sctp/associola.c b/net/sctp/associola.c
--- a/net/sctp/associola.c	2004-12-15 20:32:26 -02:00
+++ b/net/sctp/associola.c	2004-12-15 20:32:26 -02:00
@@ -310,7 +310,7 @@
 
 	/* Decrement the backlog value for a TCP-style listening socket. */
 	if (sctp_style(sk, TCP) && sctp_sstate(sk, LISTENING))
-		sk->sk_ack_backlog--;
+		sk_ssk(sk)->ssk_ack_backlog--;
 
 	/* Mark as dead, so other users can know this structure is
 	 * going away.
@@ -915,7 +915,7 @@
 
 	/* Decrement the backlog value for a TCP-style socket. */
 	if (sctp_style(oldsk, TCP))
-		oldsk->sk_ack_backlog--;
+		sk_ssk(oldsk)->ssk_ack_backlog--;
 
 	/* Release references to the old endpoint and the sock.  */
 	sctp_endpoint_put(assoc->ep);
diff -Nru a/net/sctp/endpointola.c b/net/sctp/endpointola.c
--- a/net/sctp/endpointola.c	2004-12-15 20:32:26 -02:00
+++ b/net/sctp/endpointola.c	2004-12-15 20:32:26 -02:00
@@ -171,7 +171,7 @@
 
 	/* Increment the backlog value for a TCP-style listening socket. */
 	if (sctp_style(sk, TCP) && sctp_sstate(sk, LISTENING))
-		sk->sk_ack_backlog++;
+		sk_ssk(sk)->ssk_ack_backlog++;
 }
 
 /* Free the endpoint structure.  Delay cleanup until
diff -Nru a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
--- a/net/sctp/sm_statefuns.c	2004-12-15 20:32:26 -02:00
+++ b/net/sctp/sm_statefuns.c	2004-12-15 20:32:26 -02:00
@@ -216,7 +216,7 @@
 	 */
 	if (!sctp_sstate(sk, LISTENING) ||
 	    (sctp_style(sk, TCP) &&
-	     (sk->sk_ack_backlog >= sk->sk_max_ack_backlog)))
+	     (sk_ssk(sk)->ssk_ack_backlog >= sk_ssk(sk)->ssk_max_ack_backlog)))
 		return sctp_sf_tabort_8_4_8(ep, asoc, type, arg, commands);
 
 	/* 3.1 A packet containing an INIT chunk MUST have a zero Verification
diff -Nru a/net/sctp/socket.c b/net/sctp/socket.c
--- a/net/sctp/socket.c	2004-12-15 20:32:26 -02:00
+++ b/net/sctp/socket.c	2004-12-15 20:32:26 -02:00
@@ -143,7 +143,7 @@
 	*((struct sctp_chunk **)(chunk->skb->cb)) = chunk;
 
 	asoc->sndbuf_used += SCTP_DATA_SNDSIZE(chunk);
-	sk->sk_wmem_queued += SCTP_DATA_SNDSIZE(chunk);
+	sk_ssk(sk)->ssk_wmem_queued += SCTP_DATA_SNDSIZE(chunk);
 }
 
 /* Verify that this is a valid address. */
@@ -976,7 +976,7 @@
 				sctp_association_free(asoc);
 
 			} else if (sock_flag(sk, SOCK_LINGER) &&
-				   !sk->sk_lingertime)
+				   !sk_ssk(sk)->ssk_lingertime)
 				sctp_primitive_ABORT(asoc, NULL);
 			else
 				sctp_primitive_SHUTDOWN(asoc, NULL);
@@ -3853,7 +3853,7 @@
 			return -EAGAIN;
 	}
 	sk->sk_state = SCTP_SS_LISTENING;
-	sk->sk_max_ack_backlog = backlog;
+	sk_ssk(sk)->ssk_max_ack_backlog = backlog;
 	sctp_hash_endpoint(ep);
 	return 0;
 }
@@ -4321,7 +4321,7 @@
 	asoc = chunk->asoc;
 	sk = asoc->base.sk;
 	asoc->sndbuf_used -= SCTP_DATA_SNDSIZE(chunk);
-	sk->sk_wmem_queued -= SCTP_DATA_SNDSIZE(chunk);
+	sk_ssk(sk)->ssk_wmem_queued -= SCTP_DATA_SNDSIZE(chunk);
 	__sctp_write_space(asoc);
 
 	sctp_association_put(asoc);
@@ -4415,7 +4415,7 @@
 {
 	int amt = 0;
 
-	amt = sk->sk_sndbuf - sk->sk_wmem_queued;
+	amt = sk->sk_sndbuf - sk_ssk(sk)->ssk_wmem_queued;
 	if (amt < 0)
 		amt = 0;
 	return amt;
diff -Nru a/net/unix/af_unix.c b/net/unix/af_unix.c
--- a/net/unix/af_unix.c	2004-12-15 20:32:26 -02:00
+++ b/net/unix/af_unix.c	2004-12-15 20:32:26 -02:00
@@ -430,10 +430,10 @@
 	unix_state_wlock(sk);
 	if (sk->sk_state != TCP_CLOSE && sk->sk_state != TCP_LISTEN)
 		goto out_unlock;
-	if (backlog > sk->sk_max_ack_backlog)
+	if (backlog > sk_ssk(sk)->ssk_max_ack_backlog)
 		wake_up_interruptible_all(&u->peer_wait);
-	sk->sk_max_ack_backlog	= backlog;
-	sk->sk_state		= TCP_LISTEN;
+	sk_ssk(sk)->ssk_max_ack_backlog	= backlog;
+	sk->sk_state			= TCP_LISTEN;
 	/* set credentials so connect can copy them */
 	sk->sk_peercred.pid	= current->tgid;
 	sk->sk_peercred.uid	= current->euid;
@@ -547,11 +547,13 @@
 
 	atomic_inc(&unix_nr_socks);
 
+	ssk_set_pointer(sk, struct unix_sock, ssk);
+	sk_ssk(sk)->ssk_max_ack_backlog	= sysctl_unix_max_dgram_qlen;
+
 	sock_init_data(sock,sk);
 	sk_set_owner(sk, THIS_MODULE);
 
 	sk->sk_write_space	= unix_write_space;
-	sk->sk_max_ack_backlog	= sysctl_unix_max_dgram_qlen;
 	sk->sk_destruct		= unix_sock_destructor;
 	u	  = unix_sk(sk);
 	u->dentry = NULL;
@@ -922,7 +924,7 @@
 	sched = !sock_flag(other, SOCK_DEAD) &&
 		!(other->sk_shutdown & RCV_SHUTDOWN) &&
 		(skb_queue_len(&other->sk_receive_queue) >
-		 other->sk_max_ack_backlog);
+		 sk_ssk(other)->ssk_max_ack_backlog);
 
 	unix_state_runlock(other);
 
@@ -995,7 +997,7 @@
 		goto out_unlock;
 
 	if (skb_queue_len(&other->sk_receive_queue) >
-	    other->sk_max_ack_backlog) {
+	    sk_ssk(other)->ssk_max_ack_backlog) {
 		err = -EAGAIN;
 		if (!timeo)
 			goto out_unlock;
@@ -1364,7 +1366,7 @@
 
 	if (unix_peer(other) != sk &&
 	    (skb_queue_len(&other->sk_receive_queue) >
-	     other->sk_max_ack_backlog)) {
+	     sk_ssk(other)->ssk_max_ack_backlog)) {
 		if (!timeo) {
 			err = -EAGAIN;
 			goto out_unlock;
diff -Nru a/net/wanrouter/af_wanpipe.c b/net/wanrouter/af_wanpipe.c
--- a/net/wanrouter/af_wanpipe.c	2004-12-15 20:32:26 -02:00
+++ b/net/wanrouter/af_wanpipe.c	2004-12-15 20:32:26 -02:00
@@ -415,7 +415,6 @@
 	sll->sll_halen = 0;
 
 	skb->dev = dev;
-	sk->sk_ack_backlog++;
 
 	/* We must do this manually, since the sock_queue_rcv_skb()
 	 * function sets the skb->dev to NULL.  However, we use
@@ -425,7 +424,6 @@
 
          	wanpipe_unlink_driver(newsk);
 		wanpipe_kill_sock_irq (newsk);
-		--sk->sk_ack_backlog;
 		return -ENOMEM;
 	}	
 
@@ -1519,7 +1517,6 @@
 	sk->sk_family	    = PF_WANPIPE;
 	wp_sk(sk)->num	    = protocol;
 	sk->sk_state	    = WANSOCK_DISCONNECTED;
-	sk->sk_ack_backlog  = 0;
 	sk->sk_bound_dev_if = 0;
 
 	atomic_inc(&wanpipe_socks_nr);
@@ -2427,7 +2424,6 @@
 	newsk->sk_sleep = &newsock->wait;
 
 	/* Now attach up the new socket */
-	sk->sk_ack_backlog--;
 	newsock->sk = newsk;
 	
 	kfree_skb(skb);
diff -Nru a/net/x25/af_x25.c b/net/x25/af_x25.c
--- a/net/x25/af_x25.c	2004-12-15 20:32:26 -02:00
+++ b/net/x25/af_x25.c	2004-12-15 20:32:26 -02:00
@@ -423,8 +423,8 @@
 
 	if (sk->sk_state != TCP_LISTEN) {
 		memset(&x25_sk(sk)->dest_addr, 0, X25_ADDR_LEN);
-		sk->sk_max_ack_backlog = backlog;
-		sk->sk_state           = TCP_LISTEN;
+		sk_ssk(sk)->ssk_max_ack_backlog = backlog;
+		sk->sk_state			= TCP_LISTEN;
 		rc = 0;
 	}
 
@@ -776,7 +776,7 @@
 	/* Now attach up the new socket */
 	skb->sk = NULL;
 	kfree_skb(skb);
-	sk->sk_ack_backlog--;
+	sk_ssk(sk)->ssk_ack_backlog--;
 	newsock->sk    = newsk;
 	newsock->state = SS_CONNECTED;
 	rc = 0;
@@ -835,7 +835,8 @@
 	/*
 	 *	We can't accept the Call Request.
 	 */
-	if (!sk || sk->sk_ack_backlog == sk->sk_max_ack_backlog)
+	if (!sk || sk_ssk(sk)->ssk_ack_backlog ==
+		   sk_ssk(sk)->ssk_max_ack_backlog)
 		goto out_clear_request;
 
 	/*
@@ -886,7 +887,7 @@
 
 	makex25->state = X25_STATE_3;
 
-	sk->sk_ack_backlog++;
+	sk_ssk(sk)->ssk_ack_backlog++;
 
 	x25_insert_socket(make);
 


--------------050301010404020702080302--
