From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] make ipx use a slab cache for its socks
Date: Wed, 19 Jan 2005 01:45:08 -0200
Message-ID: <41EDD7C4.90309@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070106010204030107050203"
Cc: Networking Team <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070106010204030107050203
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	This is the start of a series of patches converting the legacy
protocols to use slab caches, this is needed in preparation to introduce
struct connection_sock, most of them are trivial and small due to the
fact that we have been abstracting away access to the protocols private
area with things like {ipx,at,ax25,netrom,rose,etc}_sk(sk), there are
more involved cases, namely:

atm:

yesterday I sent a message to Chas explaining the situation (CCed netdev)

ax25 & its upper layer protos (rose, netrom):

I have the bulk of the work done, making it use the same approach used
in the inet protos: tcp_sock is a inet_sock is a sock, for ax25 it is
netrom/rose is a ax25_sock is a sock, Ralf Baechle is reviewing the
patch and seems to be happy with it so far.

bluetooth:

Still have to do further analysis, but it mostly replicates the
core infrastructure for registering a proto family, using both slab caches
and sk_protinfo, I'm thinking about generalising somewhat inet_register_protosw
API style or something along these lines.

All the others (pfkey, decnet, netlink, appletalk, llc, etc) are already converted
in my private tree and I'll be sending it as you merge the previous one,
starting with this one for IPX.

In the end of this series sk->sk_protinfo will be deleted, the generic sk_cachep
will be deleted and all proto families will have private slab caches. So struct
sock shrinks a bit again 8)

I didn't benchmarked these changed on a before/after way, but I expect some
performance gains like the ones we got when we did the same thing for TCP,
AF_UNIX, etc.

After all of this is merged I'll introduce struct connection_sock and move
on to the next target, that is to move all proto families to use sk->sk_prot,
as the inet protos do today, so as to remove sk->sk_slab and use
sk->sk_prot->slab, at this point we can change sk_alloc to have this prototype:

struct sock *sk_alloc(struct proto *prot, int priority, int zero_it);

where today we have this one:

struct sock *sk_alloc(int family, int priority, int zero_it, kmem_cache_t *slab);

because we will be able to get the relevant slab cache from sk->sk_prot->slab,
zero_it gets its original semantic, becoming again just a boolean, because we
can get the proto sock size from sk->sk_prot->slab_obj_size.

This, in turn... OK, enough "roadmap dumping" for today! 8)

Comments on this course of action will be greatly appreciated.

Ah, this changeset is available at:

bk://kernel.bkbits.net/acme/connection_sock-2.6

Best Regards,

- Arnaldo

--------------070106010204030107050203
Content-Type: text/plain;
 name="ipx_slab.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ipx_slab.patch"

===================================================================


ChangeSet@1.2336, 2005-01-18 00:45:37-02:00, acme@toy.ghostprotocols.net
  [IPX] use a private slab cache for socks
  
  Renaming ipx_opt to ipx_sock, tested with mars-nwe/ncpmount.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 include/net/ipx.h   |   13 ++++++++-
 net/ipx/af_ipx.c    |   69 ++++++++++++++++++++++++++--------------------------
 net/ipx/ipx_proc.c  |    4 +--
 net/ipx/ipx_route.c |    2 -
 4 files changed, 49 insertions(+), 39 deletions(-)


diff -Nru a/include/net/ipx.h b/include/net/ipx.h
--- a/include/net/ipx.h	2005-01-19 01:00:01 -02:00
+++ b/include/net/ipx.h	2005-01-19 01:00:01 -02:00
@@ -90,7 +90,11 @@
 	} last_hop;
 };
 
-struct ipx_opt {
+#include <net/sock.h>
+
+struct ipx_sock {
+	/* struct sock has to be the first member of ipx_sock */
+	struct sock		sk;
 	struct ipx_address	dest_addr;
 	struct ipx_interface	*intrfc;
 	unsigned short		port;
@@ -105,9 +109,14 @@
 	unsigned short		ipx_ncp_conn;
 };
 
-#define ipx_sk(__sk) ((struct ipx_opt *)(__sk)->sk_protinfo)
+static inline struct ipx_sock *ipx_sk(struct sock *sk)
+{
+	return (struct ipx_sock *)sk;
+}
+
 #define IPX_SKB_CB(__skb) ((struct ipx_cb *)&((__skb)->cb[0]))
 #endif
+
 #define IPX_MIN_EPHEMERAL_SOCKET	0x4000
 #define IPX_MAX_EPHEMERAL_SOCKET	0x7fff
 
diff -Nru a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
--- a/net/ipx/af_ipx.c	2005-01-19 01:00:01 -02:00
+++ b/net/ipx/af_ipx.c	2005-01-19 01:00:01 -02:00
@@ -80,6 +80,8 @@
 LIST_HEAD(ipx_interfaces);
 DEFINE_SPINLOCK(ipx_interfaces_lock);
 
+static kmem_cache_t *ipx_sk_slab;
+
 struct ipx_interface *ipx_primary_net;
 struct ipx_interface *ipx_internal_net;
 
@@ -277,7 +279,7 @@
 	spin_lock_bh(&intrfc->if_sklist_lock);
 
 	sk_for_each(s, node, &intrfc->if_sklist) {
-		struct ipx_opt *ipxs = ipx_sk(s);
+		struct ipx_sock *ipxs = ipx_sk(s);
 
 		if (ipxs->port == port &&
 		    !memcmp(ipx_node, ipxs->node, IPX_NODE_LEN))
@@ -302,7 +304,7 @@
 	spin_lock_bh(&intrfc->if_sklist_lock);
 	/* error sockets */
 	sk_for_each_safe(s, node, t, &intrfc->if_sklist) {
-		struct ipx_opt *ipxs = ipx_sk(s);
+		struct ipx_sock *ipxs = ipx_sk(s);
 
 		s->sk_err = ENOLINK;
 		s->sk_error_report(s);
@@ -400,7 +402,7 @@
 	spin_lock_bh(&intrfc->if_sklist_lock);
 
 	sk_for_each(s, node, &intrfc->if_sklist) {
-		struct ipx_opt *ipxs = ipx_sk(s);
+		struct ipx_sock *ipxs = ipx_sk(s);
 
 		if (ipxs->port == ipx->ipx_dest.sock &&
 		    (is_broadcast || !memcmp(ipx->ipx_dest.node,
@@ -1348,32 +1350,21 @@
 static int ipx_create(struct socket *sock, int protocol)
 {
 	int rc = -ESOCKTNOSUPPORT;
-	struct ipx_opt *ipx = NULL;
 	struct sock *sk;
 
-	switch (sock->type) {
-	case SOCK_DGRAM:
-		sk = sk_alloc(PF_IPX, GFP_KERNEL, 1, NULL);
-        	rc = -ENOMEM;
-		if (!sk)
-			goto out;
-		ipx = sk->sk_protinfo = kmalloc(sizeof(*ipx), GFP_KERNEL);
-		if (!ipx)
-			goto outsk;
-		memset(ipx, 0, sizeof(*ipx));
-                sock->ops = &ipx_dgram_ops;
-                break;
-	case SOCK_SEQPACKET:
-		/*
-		 * SPX support is not anymore in the kernel sources. If
-		 * you want to ressurrect it, completing it and making
-		 * it understand shared skbs, be fully multithreaded,
-		 * etc, grab the sources in an early 2.5 kernel tree.
-		 */
-	case SOCK_STREAM:       /* Allow higher levels to piggyback */
-	default:
+	/*
+	 * SPX support is not anymore in the kernel sources. If you want to
+	 * ressurrect it, completing it and making it understand shared skbs,
+	 * be fully multithreaded, etc, grab the sources in an early 2.5 kernel
+	 * tree.
+	 */
+	if (sock->type != SOCK_DGRAM)
+		goto out;
+
+	sk = sk_alloc(PF_IPX, GFP_KERNEL, sizeof(struct ipx_sock), ipx_sk_slab);
+       	rc = -ENOMEM;
+	if (!sk)
 		goto out;
-	}
 #ifdef IPX_REFCNT_DEBUG
         atomic_inc(&ipx_sock_nr);
         printk(KERN_DEBUG "IPX socket %p created, now we have %d alive\n", sk,
@@ -1382,12 +1373,10 @@
 	sock_init_data(sock, sk);
 	sk_set_owner(sk, THIS_MODULE);
 	sk->sk_no_check = 1;		/* Checksum off by default */
+	sock->ops = &ipx_dgram_ops;
 	rc = 0;
 out:
 	return rc;
-outsk:
-	sk_free(sk);
-	goto out;
 }
 
 static int ipx_release(struct socket *sock)
@@ -1433,7 +1422,7 @@
 static int ipx_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 {
 	struct sock *sk = sock->sk;
-	struct ipx_opt *ipxs = ipx_sk(sk);
+	struct ipx_sock *ipxs = ipx_sk(sk);
 	struct ipx_interface *intrfc;
 	struct sockaddr_ipx *addr = (struct sockaddr_ipx *)uaddr;
 	int rc = -EINVAL;
@@ -1529,7 +1518,7 @@
 	int addr_len, int flags)
 {
 	struct sock *sk = sock->sk;
-	struct ipx_opt *ipxs = ipx_sk(sk);
+	struct ipx_sock *ipxs = ipx_sk(sk);
 	struct sockaddr_ipx *addr;
 	int rc = -EINVAL;
 	struct ipx_route *rt;
@@ -1593,7 +1582,7 @@
 	struct ipx_address *addr;
 	struct sockaddr_ipx sipx;
 	struct sock *sk = sock->sk;
-	struct ipx_opt *ipxs = ipx_sk(sk);
+	struct ipx_sock *ipxs = ipx_sk(sk);
 	int rc;
 
 	*uaddr_len = sizeof(struct sockaddr_ipx);
@@ -1693,7 +1682,7 @@
 	struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
-	struct ipx_opt *ipxs = ipx_sk(sk);
+	struct ipx_sock *ipxs = ipx_sk(sk);
 	struct sockaddr_ipx *usipx = (struct sockaddr_ipx *)msg->msg_name;
 	struct sockaddr_ipx local_sipx;
 	int rc = -EINVAL;
@@ -1758,7 +1747,7 @@
 		struct msghdr *msg, size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
-	struct ipx_opt *ipxs = ipx_sk(sk);
+	struct ipx_sock *ipxs = ipx_sk(sk);
 	struct sockaddr_ipx *sipx = (struct sockaddr_ipx *)msg->msg_name;
 	struct ipxhdr *ipx = NULL;
 	struct sk_buff *skb;
@@ -1965,6 +1954,13 @@
 
 static int __init ipx_init(void)
 {
+	ipx_sk_slab = kmem_cache_create("ipx_sock",
+					sizeof(struct ipx_sock), 0,
+					SLAB_HWCACHE_ALIGN, NULL, NULL);
+
+	if (ipx_sk_slab == NULL)
+		return -ENOMEM;
+
 	sock_register(&ipx_family_ops);
 
 	pEII_datalink = make_EII_client();
@@ -2015,6 +2011,11 @@
 	dev_remove_pack(&ipx_dix_packet_type);
 	destroy_EII_client(pEII_datalink);
 	pEII_datalink = NULL;
+
+	if (ipx_sk_slab != NULL) {
+		kmem_cache_destroy(ipx_sk_slab);
+		ipx_sk_slab = NULL;
+	}
 
 	sock_unregister(ipx_family_ops.family);
 }
diff -Nru a/net/ipx/ipx_proc.c b/net/ipx/ipx_proc.c
--- a/net/ipx/ipx_proc.c	2005-01-19 01:00:01 -02:00
+++ b/net/ipx/ipx_proc.c	2005-01-19 01:00:01 -02:00
@@ -202,7 +202,7 @@
 {
 	struct sock* sk, *next;
 	struct ipx_interface *i;
-	struct ipx_opt *ipxs;
+	struct ipx_sock *ipxs;
 
 	++*pos;
 	if (v == SEQ_START_TOKEN) {
@@ -243,7 +243,7 @@
 static int ipx_seq_socket_show(struct seq_file *seq, void *v)
 {
 	struct sock *s;
-	struct ipx_opt *ipxs;
+	struct ipx_sock *ipxs;
 
 	if (v == SEQ_START_TOKEN) {
 #ifdef CONFIG_IPX_INTERN
diff -Nru a/net/ipx/ipx_route.c b/net/ipx/ipx_route.c
--- a/net/ipx/ipx_route.c	2005-01-19 01:00:01 -02:00
+++ b/net/ipx/ipx_route.c	2005-01-19 01:00:01 -02:00
@@ -172,7 +172,7 @@
 			struct iovec *iov, size_t len, int noblock)
 {
 	struct sk_buff *skb;
-	struct ipx_opt *ipxs = ipx_sk(sk);
+	struct ipx_sock *ipxs = ipx_sk(sk);
 	struct ipx_interface *intrfc;
 	struct ipxhdr *ipx;
 	size_t size;


--------------070106010204030107050203--
