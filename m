From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH 11/12][PPPOX] stop using sk_protinfo
Date: Fri, 21 Jan 2005 01:19:41 -0200
Message-ID: <41F074CD.9090401@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050401090707020900020306"
Cc: Networking Team <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, mostrows@styx.uwaterloo.ca
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050401090707020900020306
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David, Michael,

	Subject says it all, Michal, this is part of a series of patches that
intends to remove sk->sk_protinfo, that in turn will allow me to introduce
struct connection_sock, if you have any questions, please contact me or look
at netdev archives.

Regards,

- Arnaldo


--------------050401090707020900020306
Content-Type: text/plain;
 name="11-pppox.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="11-pppox.patch"

===================================================================


ChangeSet@1.2009, 2005-01-21 00:16:19-02:00, acme@toy.ghostprotocols.net
  [PPPOX] stop using sk_protinfo
  
  Required to introduce struct connection_sock.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 drivers/net/pppoe.c      |  101 ++++++++++++++++++-----------------------------
 drivers/net/pppox.c      |    2 
 include/linux/if_pppox.h |   19 ++++++--
 3 files changed, 55 insertions(+), 67 deletions(-)


diff -Nru a/drivers/net/pppoe.c b/drivers/net/pppoe.c
--- a/drivers/net/pppoe.c	2005-01-21 00:22:07 -02:00
+++ b/drivers/net/pppoe.c	2005-01-21 00:22:07 -02:00
@@ -120,17 +120,17 @@
 }
 
 /* zeroed because its in .bss */
-static struct pppox_opt *item_hash_table[PPPOE_HASH_SIZE];
+static struct pppox_sock *item_hash_table[PPPOE_HASH_SIZE];
 
 /**********************************************************************
  *
  *  Set/get/delete/rehash items  (internal versions)
  *
  **********************************************************************/
-static struct pppox_opt *__get_item(unsigned long sid, unsigned char *addr)
+static struct pppox_sock *__get_item(unsigned long sid, unsigned char *addr)
 {
 	int hash = hash_item(sid, addr);
-	struct pppox_opt *ret;
+	struct pppox_sock *ret;
 
 	ret = item_hash_table[hash];
 
@@ -140,10 +140,10 @@
 	return ret;
 }
 
-static int __set_item(struct pppox_opt *po)
+static int __set_item(struct pppox_sock *po)
 {
 	int hash = hash_item(po->pppoe_pa.sid, po->pppoe_pa.remote);
-	struct pppox_opt *ret;
+	struct pppox_sock *ret;
 
 	ret = item_hash_table[hash];
 	while (ret) {
@@ -161,10 +161,10 @@
 	return 0;
 }
 
-static struct pppox_opt *__delete_item(unsigned long sid, char *addr)
+static struct pppox_sock *__delete_item(unsigned long sid, char *addr)
 {
 	int hash = hash_item(sid, addr);
-	struct pppox_opt *ret, **src;
+	struct pppox_sock *ret, **src;
 
 	ret = item_hash_table[hash];
 	src = &item_hash_table[hash];
@@ -187,26 +187,26 @@
  *  Set/get/delete/rehash items
  *
  **********************************************************************/
-static inline struct pppox_opt *get_item(unsigned long sid,
+static inline struct pppox_sock *get_item(unsigned long sid,
 					 unsigned char *addr)
 {
-	struct pppox_opt *po;
+	struct pppox_sock *po;
 
 	read_lock_bh(&pppoe_hash_lock);
 	po = __get_item(sid, addr);
 	if (po)
-		sock_hold(po->sk);
+		sock_hold(sk_pppox(po));
 	read_unlock_bh(&pppoe_hash_lock);
 
 	return po;
 }
 
-static inline struct pppox_opt *get_item_by_addr(struct sockaddr_pppox *sp)
+static inline struct pppox_sock *get_item_by_addr(struct sockaddr_pppox *sp)
 {
 	return get_item(sp->sa_addr.pppoe.sid, sp->sa_addr.pppoe.remote);
 }
 
-static inline int set_item(struct pppox_opt *po)
+static inline int set_item(struct pppox_sock *po)
 {
 	int i;
 
@@ -220,9 +220,9 @@
 	return i;
 }
 
-static inline struct pppox_opt *delete_item(unsigned long sid, char *addr)
+static inline struct pppox_sock *delete_item(unsigned long sid, char *addr)
 {
-	struct pppox_opt *ret;
+	struct pppox_sock *ret;
 
 	write_lock_bh(&pppoe_hash_lock);
 	ret = __delete_item(sid, addr);
@@ -248,11 +248,11 @@
 
 	read_lock_bh(&pppoe_hash_lock);
 	for (hash = 0; hash < PPPOE_HASH_SIZE; hash++) {
-		struct pppox_opt *po = item_hash_table[hash];
+		struct pppox_sock *po = item_hash_table[hash];
 
 		while (po != NULL) {
 			if (po->pppoe_dev == dev) {
-				struct sock *sk = po->sk;
+				struct sock *sk = sk_pppox(po);
 
 				sock_hold(sk);
 				po->pppoe_dev = NULL;
@@ -331,8 +331,8 @@
  ***********************************************************************/
 static int pppoe_rcv_core(struct sock *sk, struct sk_buff *skb)
 {
-	struct pppox_opt *po = pppox_sk(sk);
-	struct pppox_opt *relay_po = NULL;
+	struct pppox_sock *po = pppox_sk(sk);
+	struct pppox_sock *relay_po = NULL;
 
 	if (sk->sk_state & PPPOX_BOUND) {
 		struct pppoe_hdr *ph = (struct pppoe_hdr *) skb->nh.raw;
@@ -347,11 +347,11 @@
 		if (relay_po == NULL)
 			goto abort_kfree;
 
-		if ((relay_po->sk->sk_state & PPPOX_CONNECTED) == 0)
+		if ((sk_pppox(relay_po)->sk_state & PPPOX_CONNECTED) == 0)
 			goto abort_put;
 
 		skb_pull(skb, sizeof(struct pppoe_hdr));
-		if (!__pppoe_xmit( relay_po->sk, skb))
+		if (!__pppoe_xmit(sk_pppox(relay_po), skb))
 			goto abort_put;
 	} else {
 		if (sock_queue_rcv_skb(sk, skb))
@@ -361,7 +361,7 @@
 	return NET_RX_SUCCESS;
 
 abort_put:
-	sock_put(relay_po->sk);
+	sock_put(sk_pppox(relay_po));
 
 abort_kfree:
 	kfree_skb(skb);
@@ -379,7 +379,7 @@
 
 {
 	struct pppoe_hdr *ph;
-	struct pppox_opt *po;
+	struct pppox_sock *po;
 	struct sock *sk;
 	int ret;
 
@@ -395,7 +395,7 @@
 	if (!po) 
 		goto drop;
 
-	sk = po->sk;
+	sk = sk_pppox(po);
 	bh_lock_sock(sk);
 
 	/* Socket state is unknown, must put skb into backlog. */
@@ -428,7 +428,7 @@
 
 {
 	struct pppoe_hdr *ph;
-	struct pppox_opt *po;
+	struct pppox_sock *po;
 
 	if (!pskb_may_pull(skb, sizeof(struct pppoe_hdr)))
 		goto abort;
@@ -442,7 +442,7 @@
 
 	po = get_item((unsigned long) ph->sid, eth_hdr(skb)->h_source);
 	if (po) {
-		struct sock *sk = po->sk;
+		struct sock *sk = sk_pppox(po);
 
 		bh_lock_sock(sk);
 
@@ -480,20 +480,6 @@
 
 /***********************************************************************
  *
- * Really kill the socket. (Called from pppox_sk_free if refcnt == 0.)
- *
- **********************************************************************/
-static void pppoe_sk_free(struct sock *sk)
-{
-	struct pppox_opt *po = pppox_sk(sk);
-
-	if (po)
-		kfree(po);
-}
-
-
-/***********************************************************************
- *
  * Initialize a new struct sock.
  *
  **********************************************************************/
@@ -501,9 +487,8 @@
 {
 	int error = -ENOMEM;
 	struct sock *sk;
-	struct pppox_opt *po;
 
-	sk = sk_alloc(PF_PPPOX, GFP_KERNEL, 1, NULL);
+	sk = sk_alloc(PF_PPPOX, GFP_KERNEL, sizeof(struct pppox_sock), NULL);
 	if (!sk)
 		goto out;
 
@@ -517,23 +502,15 @@
 	sk->sk_type	   = SOCK_STREAM;
 	sk->sk_family	   = PF_PPPOX;
 	sk->sk_protocol	   = PX_PROTO_OE;
-	sk->sk_destruct	   = pppoe_sk_free;
 
-	po = sk->sk_protinfo = kmalloc(sizeof(*po), GFP_KERNEL);
-	if (!po)
-		goto frees;
-	memset(po, 0, sizeof(*po));
-	po->sk = sk;
 	error = 0;
 out:	return error;
-frees:	sk_free(sk);
-	goto out;
 }
 
 static int pppoe_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
-	struct pppox_opt *po;
+	struct pppox_sock *po;
 	int error = 0;
 
 	if (!sk)
@@ -573,7 +550,7 @@
 	struct sock *sk = sock->sk;
 	struct net_device *dev = NULL;
 	struct sockaddr_pppox *sp = (struct sockaddr_pppox *) uservaddr;
-	struct pppox_opt *po = pppox_sk(sk);
+	struct pppox_sock *po = pppox_sk(sk);
 	int error;
 
 	lock_sock(sk);
@@ -602,8 +579,8 @@
 		if(po->pppoe_dev)
 			dev_put(po->pppoe_dev);
 
-		memset(po, 0, sizeof(struct pppox_opt));
-		po->sk = sk;
+		memset(sk_pppox(po) + 1, 0,
+		       sizeof(struct pppox_sock) - sizeof(struct sock));
 
 		sk->sk_state = PPPOX_NONE;
 	}
@@ -679,7 +656,7 @@
 		unsigned long arg)
 {
 	struct sock *sk = sock->sk;
-	struct pppox_opt *po = pppox_sk(sk);
+	struct pppox_sock *po = pppox_sk(sk);
 	int val = 0;
 	int err = 0;
 
@@ -725,7 +702,7 @@
 
 	case PPPOEIOCSFWD:
 	{
-		struct pppox_opt *relay_po;
+		struct pppox_sock *relay_po;
 
 		err = -EBUSY;
 		if (sk->sk_state & (PPPOX_BOUND | PPPOX_ZOMBIE | PPPOX_DEAD))
@@ -755,7 +732,7 @@
 		if (!relay_po)
 			break;
 
-		sock_put(relay_po->sk);
+		sock_put(sk_pppox(relay_po));
 		sk->sk_state |= PPPOX_RELAY;
 		err = 0;
 		break;
@@ -782,7 +759,7 @@
 {
 	struct sk_buff *skb = NULL;
 	struct sock *sk = sock->sk;
-	struct pppox_opt *po = pppox_sk(sk);
+	struct pppox_sock *po = pppox_sk(sk);
 	int error = 0;
 	struct pppoe_hdr hdr;
 	struct pppoe_hdr *ph;
@@ -857,7 +834,7 @@
  ***********************************************************************/
 static int __pppoe_xmit(struct sock *sk, struct sk_buff *skb)
 {
-	struct pppox_opt *po = pppox_sk(sk);
+	struct pppox_sock *po = pppox_sk(sk);
 	struct net_device *dev = po->pppoe_dev;
 	struct pppoe_hdr hdr;
 	struct pppoe_hdr *ph;
@@ -984,7 +961,7 @@
 #ifdef CONFIG_PROC_FS
 static int pppoe_seq_show(struct seq_file *seq, void *v)
 {
-	struct pppox_opt *po;
+	struct pppox_sock *po;
 	char *dev_name;
 
 	if (v == SEQ_START_TOKEN) {
@@ -1004,9 +981,9 @@
 	return 0;
 }
 
-static __inline__ struct pppox_opt *pppoe_get_idx(loff_t pos)
+static __inline__ struct pppox_sock *pppoe_get_idx(loff_t pos)
 {
-	struct pppox_opt *po = NULL;
+	struct pppox_sock *po = NULL;
 	int i = 0;
 
 	for (; i < PPPOE_HASH_SIZE; i++) {
@@ -1031,7 +1008,7 @@
 
 static void *pppoe_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct pppox_opt *po;
+	struct pppox_sock *po;
 
 	++*pos;
 	if (v == SEQ_START_TOKEN) {
diff -Nru a/drivers/net/pppox.c b/drivers/net/pppox.c
--- a/drivers/net/pppox.c	2005-01-21 00:22:07 -02:00
+++ b/drivers/net/pppox.c	2005-01-21 00:22:07 -02:00
@@ -72,7 +72,7 @@
 		       unsigned long arg)
 {
 	struct sock *sk = sock->sk;
-	struct pppox_opt *po = pppox_sk(sk);
+	struct pppox_sock *po = pppox_sk(sk);
 	int rc = 0;
 
 	lock_sock(sk);
diff -Nru a/include/linux/if_pppox.h b/include/linux/if_pppox.h
--- a/include/linux/if_pppox.h	2005-01-21 00:22:07 -02:00
+++ b/include/linux/if_pppox.h	2005-01-21 00:22:07 -02:00
@@ -119,10 +119,13 @@
 					     relayed to (PPPoE relaying) */
 };
 
-struct pppox_opt {
+#include <net/sock.h>
+
+struct pppox_sock {
+	/* struct sock must be the first member of pppox_sock */
+	struct sock		sk;
 	struct ppp_channel	chan;
-	struct sock		*sk;
-	struct pppox_opt	*next;	  /* for hash table */
+	struct pppox_sock	*next;	  /* for hash table */
 	union {
 		struct pppoe_opt pppoe;
 	} proto;
@@ -132,7 +135,15 @@
 #define pppoe_pa	proto.pppoe.pa
 #define pppoe_relay	proto.pppoe.relay
 
-#define pppox_sk(__sk) ((struct pppox_opt *)(__sk)->sk_protinfo)
+static inline struct pppox_sock *pppox_sk(struct sock *sk)
+{
+	return (struct pppox_sock *)sk;
+}
+
+static inline struct sock *sk_pppox(struct pppox_sock *po)
+{
+	return (struct sock *)po;
+}
 
 struct module;
 



--------------050401090707020900020306--
