From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH 5/9] netlink: use sock slab cache
Date: Thu, 20 Jan 2005 00:04:25 -0200
Message-ID: <41EF11A9.3030104@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040604040408030709030001"
Cc: Networking Team <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040604040408030709030001
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David,

	The netlink one.

- Arnaldo


--------------040604040408030709030001
Content-Type: text/plain;
 name="netlink_sock.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netlink_sock.patch"

===================================================================


ChangeSet@1.2341, 2005-01-19 23:04:10-02:00, acme@toy.ghostprotocols.net
  [NETLINK] use a private slab cache for socks
  
  Required to get rid of sk_protinfo and to introduce struct connection_sock,
  also for consistency with other protocol families implementations.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 af_netlink.c |   82 ++++++++++++++++++++++++++++++++++-------------------------
 1 files changed, 48 insertions(+), 34 deletions(-)


diff -Nru a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
--- a/net/netlink/af_netlink.c	2005-01-19 23:40:04 -02:00
+++ b/net/netlink/af_netlink.c	2005-01-19 23:40:04 -02:00
@@ -59,8 +59,9 @@
 #define NL_EMULATE_DEV
 #endif
 
-struct netlink_opt
-{
+struct netlink_sock {
+	/* struct sock has to be the first member of netlink_sock */
+	struct sock		sk;
 	u32			pid;
 	unsigned int		groups;
 	u32			dst_pid;
@@ -73,7 +74,12 @@
 	void			(*data_ready)(struct sock *sk, int bytes);
 };
 
-#define nlk_sk(__sk) ((struct netlink_opt *)(__sk)->sk_protinfo)
+static inline struct netlink_sock *nlk_sk(struct sock *sk)
+{
+	return (struct netlink_sock *)sk;
+}
+
+static kmem_cache_t *netlink_sk_slab;
 
 struct nl_pid_hash {
 	struct hlist_head *table;
@@ -122,8 +128,6 @@
 	BUG_TRAP(!atomic_read(&sk->sk_rmem_alloc));
 	BUG_TRAP(!atomic_read(&sk->sk_wmem_alloc));
 	BUG_TRAP(!nlk_sk(sk)->cb);
-
-	kfree(nlk_sk(sk));
 }
 
 /* This lock without WQ_FLAG_EXCLUSIVE is good on UP and it is _very_ bad on SMP.
@@ -327,7 +331,7 @@
 static int netlink_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;
-	struct netlink_opt *nlk;
+	struct netlink_sock *nlk;
 
 	sock->state = SS_UNCONNECTED;
 
@@ -339,19 +343,15 @@
 
 	sock->ops = &netlink_ops;
 
-	sk = sk_alloc(PF_NETLINK, GFP_KERNEL, 1, NULL);
+	sk = sk_alloc(PF_NETLINK, GFP_KERNEL,
+		      sizeof(struct netlink_sock), netlink_sk_slab);
 	if (!sk)
 		return -ENOMEM;
 
 	sock_init_data(sock,sk);
 	sk_set_owner(sk, THIS_MODULE);
 
-	nlk = sk->sk_protinfo = kmalloc(sizeof(*nlk), GFP_KERNEL);
-	if (!nlk) {
-		sk_free(sk);
-		return -ENOMEM;
-	}
-	memset(nlk, 0, sizeof(*nlk));
+	nlk = nlk_sk(sk);
 
 	spin_lock_init(&nlk->cb_lock);
 	init_waitqueue_head(&nlk->wait);
@@ -364,7 +364,7 @@
 static int netlink_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
-	struct netlink_opt *nlk;
+	struct netlink_sock *nlk;
 
 	if (!sk)
 		return 0;
@@ -445,7 +445,7 @@
 static int netlink_bind(struct socket *sock, struct sockaddr *addr, int addr_len)
 {
 	struct sock *sk = sock->sk;
-	struct netlink_opt *nlk = nlk_sk(sk);
+	struct netlink_sock *nlk = nlk_sk(sk);
 	struct sockaddr_nl *nladdr = (struct sockaddr_nl *)addr;
 	int err;
 	
@@ -486,7 +486,7 @@
 {
 	int err = 0;
 	struct sock *sk = sock->sk;
-	struct netlink_opt *nlk = nlk_sk(sk);
+	struct netlink_sock *nlk = nlk_sk(sk);
 	struct sockaddr_nl *nladdr=(struct sockaddr_nl*)addr;
 
 	if (addr->sa_family == AF_UNSPEC) {
@@ -517,7 +517,7 @@
 static int netlink_getname(struct socket *sock, struct sockaddr *addr, int *addr_len, int peer)
 {
 	struct sock *sk = sock->sk;
-	struct netlink_opt *nlk = nlk_sk(sk);
+	struct netlink_sock *nlk = nlk_sk(sk);
 	struct sockaddr_nl *nladdr=(struct sockaddr_nl *)addr;
 	
 	nladdr->nl_family = AF_NETLINK;
@@ -546,7 +546,7 @@
 {
 	int protocol = ssk->sk_protocol;
 	struct sock *sock;
-	struct netlink_opt *nlk;
+	struct netlink_sock *nlk;
 
 	sock = netlink_lookup(protocol, pid);
 	if (!sock)
@@ -592,7 +592,7 @@
  */
 int netlink_attachskb(struct sock *sk, struct sk_buff *skb, int nonblock, long timeo)
 {
-	struct netlink_opt *nlk;
+	struct netlink_sock *nlk;
 
 	nlk = nlk_sk(sk);
 
@@ -636,7 +636,7 @@
 
 int netlink_sendskb(struct sock *sk, struct sk_buff *skb, int protocol)
 {
-	struct netlink_opt *nlk;
+	struct netlink_sock *nlk;
 	int len = skb->len;
 
 	nlk = nlk_sk(sk);
@@ -704,7 +704,7 @@
 
 static __inline__ int netlink_broadcast_deliver(struct sock *sk, struct sk_buff *skb)
 {
-	struct netlink_opt *nlk = nlk_sk(sk);
+	struct netlink_sock *nlk = nlk_sk(sk);
 #ifdef NL_EMULATE_DEV
 	if (nlk->handler) {
 		skb_orphan(skb);
@@ -737,7 +737,7 @@
 static inline int do_one_broadcast(struct sock *sk,
 				   struct netlink_broadcast_data *p)
 {
-	struct netlink_opt *nlk = nlk_sk(sk);
+	struct netlink_sock *nlk = nlk_sk(sk);
 	int val;
 
 	if (p->exclude_sk == sk)
@@ -829,7 +829,7 @@
 static inline int do_one_set_err(struct sock *sk,
 				 struct netlink_set_err_data *p)
 {
-	struct netlink_opt *nlk = nlk_sk(sk);
+	struct netlink_sock *nlk = nlk_sk(sk);
 
 	if (sk == p->exclude_sk)
 		goto out;
@@ -864,7 +864,7 @@
 
 static inline void netlink_rcv_wake(struct sock *sk)
 {
-	struct netlink_opt *nlk = nlk_sk(sk);
+	struct netlink_sock *nlk = nlk_sk(sk);
 
 	if (!skb_queue_len(&sk->sk_receive_queue))
 		clear_bit(0, &nlk->state);
@@ -877,7 +877,7 @@
 {
 	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct sock *sk = sock->sk;
-	struct netlink_opt *nlk = nlk_sk(sk);
+	struct netlink_sock *nlk = nlk_sk(sk);
 	struct sockaddr_nl *addr=msg->msg_name;
 	u32 dst_pid;
 	u32 dst_groups;
@@ -961,7 +961,7 @@
 	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct scm_cookie scm;
 	struct sock *sk = sock->sk;
-	struct netlink_opt *nlk = nlk_sk(sk);
+	struct netlink_sock *nlk = nlk_sk(sk);
 	int noblock = flags&MSG_DONTWAIT;
 	size_t copied;
 	struct sk_buff *skb;
@@ -1015,7 +1015,7 @@
 
 static void netlink_data_ready(struct sock *sk, int len)
 {
-	struct netlink_opt *nlk = nlk_sk(sk);
+	struct netlink_sock *nlk = nlk_sk(sk);
 
 	if (nlk->data_ready)
 		nlk->data_ready(sk, len);
@@ -1079,7 +1079,7 @@
 
 static int netlink_dump(struct sock *sk)
 {
-	struct netlink_opt *nlk = nlk_sk(sk);
+	struct netlink_sock *nlk = nlk_sk(sk);
 	struct netlink_callback *cb;
 	struct sk_buff *skb;
 	struct nlmsghdr *nlh;
@@ -1129,7 +1129,7 @@
 {
 	struct netlink_callback *cb;
 	struct sock *sk;
-	struct netlink_opt *nlk;
+	struct netlink_sock *nlk;
 
 	cb = kmalloc(sizeof(*cb), GFP_KERNEL);
 	if (cb == NULL)
@@ -1286,7 +1286,7 @@
 			 "Rmem     Wmem     Dump     Locks\n");
 	else {
 		struct sock *s = v;
-		struct netlink_opt *nlk = nlk_sk(s);
+		struct netlink_sock *nlk = nlk_sk(s);
 
 		seq_printf(seq, "%p %-3d %-6d %08x %-8d %-8d %p %d\n",
 			   s,
@@ -1392,9 +1392,18 @@
 	if (sizeof(struct netlink_skb_parms) > sizeof(dummy_skb->cb))
 		netlink_skb_parms_too_large();
 
+	netlink_sk_slab = kmem_cache_create("netlink_sock",
+					    sizeof(struct netlink_sock), 0,
+					    SLAB_HWCACHE_ALIGN, NULL, NULL);
+
+	if (netlink_sk_slab == NULL)
+		return -ENOMEM;
+
 	nl_table = kmalloc(sizeof(*nl_table) * MAX_LINKS, GFP_KERNEL);
 	if (!nl_table) {
 enomem:
+		kmem_cache_destroy(netlink_sk_slab);
+		netlink_sk_slab = NULL;
 		printk(KERN_CRIT "netlink_init: Cannot allocate nl_table\n");
 		return -ENOMEM;
 	}
@@ -1439,10 +1448,15 @@
 
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
+
+	if (netlink_sk_slab != NULL) {
+		kmem_cache_destroy(netlink_sk_slab);
+		netlink_sk_slab = NULL;
+	}
 }
 
 core_initcall(netlink_proto_init);



--------------040604040408030709030001--
