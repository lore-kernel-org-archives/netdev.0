From: Pablo Neira <pablo@eurodev.net>
Subject: [NETLINK] introduce netlink bucket
Date: Tue, 02 Nov 2004 22:41:44 +0100
Message-ID: <4187FF18.5050608@eurodev.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090104060208020908070101"
Cc: "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090104060208020908070101
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Davem,

This patch introduces the netlink bucket struct, it joins three arrays 
into an array of netlink bucket.

Signed-off-by: Pablo Neira Ayuso <pablo@eurodev.net>

--------------090104060208020908070101
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== net/netlink/af_netlink.c 1.57 vs edited =====
--- 1.57/net/netlink/af_netlink.c	2004-10-20 07:10:40 +02:00
+++ edited/net/netlink/af_netlink.c	2004-10-30 19:37:26 +02:00
@@ -69,13 +69,15 @@
 
 #define nlk_sk(__sk) ((struct netlink_opt *)(__sk)->sk_protinfo)
 
-static struct hlist_head nl_table[MAX_LINKS];
 static DECLARE_WAIT_QUEUE_HEAD(nl_table_wait);
-static unsigned nl_nonroot[MAX_LINKS];
 
+static struct netlink_bucket {
+	struct hlist_head nl_table;
+	unsigned nl_nonroot;
 #ifdef NL_EMULATE_DEV
-static struct socket *netlink_kernel[MAX_LINKS];
+	struct socket *netlink_kernel;
 #endif
+} nl_bucket[MAX_LINKS];
 
 static int netlink_dump(struct sock *sk);
 static void netlink_destroy_callback(struct netlink_callback *cb);
@@ -164,7 +166,7 @@
 	struct hlist_node *node;
 
 	read_lock(&nl_table_lock);
-	sk_for_each(sk, node, &nl_table[protocol]) {
+	sk_for_each(sk, node, &nl_bucket[protocol].nl_table) {
 		if (nlk_sk(sk)->pid == pid) {
 			sock_hold(sk);
 			goto found;
@@ -185,7 +187,7 @@
 	struct hlist_node *node;
 
 	netlink_table_grab();
-	sk_for_each(osk, node, &nl_table[sk->sk_protocol]) {
+	sk_for_each(osk, node, &nl_bucket[sk->sk_protocol].nl_table) {
 		if (nlk_sk(osk)->pid == pid)
 			break;
 	}
@@ -193,7 +195,7 @@
 		err = -EBUSY;
 		if (nlk_sk(sk)->pid == 0) {
 			nlk_sk(sk)->pid = pid;
-			sk_add_node(sk, &nl_table[sk->sk_protocol]);
+			sk_add_node(sk, &nl_bucket[sk->sk_protocol].nl_table);
 			err = 0;
 		}
 	}
@@ -297,7 +299,7 @@
 
 retry:
 	netlink_table_grab();
-	sk_for_each(osk, node, &nl_table[sk->sk_protocol]) {
+	sk_for_each(osk, node, &nl_bucket[sk->sk_protocol].nl_table) {
 		if (nlk_sk(osk)->pid == pid) {
 			/* Bind collision, search negative pid values. */
 			if (pid > 0)
@@ -318,7 +320,7 @@
 
 static inline int netlink_capable(struct socket *sock, unsigned flag) 
 { 
-	return (nl_nonroot[sock->sk->sk_protocol] & flag) ||
+	return (nl_bucket[sock->sk->sk_protocol].nl_nonroot & flag) ||
 	       capable(CAP_NET_ADMIN);
 } 
 
@@ -615,7 +617,7 @@
 
 	netlink_lock_table();
 
-	sk_for_each(sk, node, &nl_table[protocol]) {
+	sk_for_each(sk, node, &nl_bucket[protocol].nl_table) {
 		struct netlink_opt *nlk = nlk_sk(sk);
 
 		if (ssk == sk)
@@ -675,7 +677,7 @@
 	int protocol = ssk->sk_protocol;
 
 	read_lock(&nl_table_lock);
-	sk_for_each(sk, node, &nl_table[protocol]) {
+	sk_for_each(sk, node, &nl_bucket[protocol].nl_table) {
 		struct netlink_opt *nlk = nlk_sk(sk);
 		if (ssk == sk)
 			continue;
@@ -883,7 +885,7 @@
 void netlink_set_nonroot(int protocol, unsigned flags)
 { 
 	if ((unsigned)protocol < MAX_LINKS) 
-		nl_nonroot[protocol] = flags;
+		nl_bucket[protocol].nl_nonroot = flags;
 } 
 
 static void netlink_destroy_callback(struct netlink_callback *cb)
@@ -1034,7 +1036,7 @@
 		return -ENOBUFS;
 	nlk_sk(sk)->handler = function;
 	write_lock_bh(&nl_emu_lock);
-	netlink_kernel[unit] = sk->sk_socket;
+	nl_bucket[unit].netlink_kernel = sk->sk_socket;
 	write_unlock_bh(&nl_emu_lock);
 	return 0;
 }
@@ -1044,8 +1046,8 @@
 	struct socket *sock;
 
 	write_lock_bh(&nl_emu_lock);
-	sock = netlink_kernel[unit];
-	netlink_kernel[unit] = NULL;
+	sock = nl_bucket[unit].netlink_kernel;
+	nl_bucket[unit].netlink_kernel = NULL;
 	write_unlock_bh(&nl_emu_lock);
 
 	sock_release(sock);
@@ -1056,7 +1058,7 @@
 	struct socket *sock;
 
 	read_lock(&nl_emu_lock);
-	sock = netlink_kernel[unit];
+	sock = nl_bucket[unit].netlink_kernel;
 	if (sock) {
 		struct sock *sk = sock->sk;
 		memset(skb->cb, 0, sizeof(skb->cb));
@@ -1083,7 +1085,7 @@
 	loff_t off = 0;
 
 	for (i=0; i<MAX_LINKS; i++) {
-		sk_for_each(s, node, &nl_table[i]) {
+		sk_for_each(s, node, &nl_bucket[i].nl_table) {
 			if (off == pos) {
 				seq->private = (void *) i;
 				return s;
@@ -1114,7 +1116,7 @@
 		long i = (long)seq->private;
 
 		while (++i < MAX_LINKS) {
-			s = sk_head(&nl_table[i]);
+			s = sk_head(&nl_bucket[i].nl_table);
 			if (s) {
 				seq->private = (void *) i;
 				break;

--------------090104060208020908070101--
