From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH 6/9] irda: use sock slab cache
Date: Thu, 20 Jan 2005 00:04:31 -0200
Message-ID: <41EF11AF.70203@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000202030007010503090107"
Cc: irda-users@lists.sourceforge.net, Networking Team <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, Jean Tourrilhes <jt@hpl.hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000202030007010503090107
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David, Jean,

	Please read the log in the patch.

Regards,

- Arnaldo


--------------000202030007010503090107
Content-Type: text/plain;
 name="irda_sock.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="irda_sock.patch"

===================================================================


ChangeSet@1.2342, 2005-01-19 23:04:52-02:00, acme@toy.ghostprotocols.net
  [IRDA] use a private slab cache for socks
  
  Required to get rid of sk_protinfo and to introduce struct connection_sock,
  also for consistency with other protocol families implementations.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 include/net/irda/af_irda.h |    9 ++++++-
 net/irda/af_irda.c         |   52 +++++++++++++++++++++++----------------------
 2 files changed, 34 insertions(+), 27 deletions(-)


diff -Nru a/include/net/irda/af_irda.h b/include/net/irda/af_irda.h
--- a/include/net/irda/af_irda.h	2005-01-19 23:43:00 -02:00
+++ b/include/net/irda/af_irda.h	2005-01-19 23:43:00 -02:00
@@ -33,9 +33,12 @@
 #include <net/irda/irlmp.h>		/* struct lsap_cb */
 #include <net/irda/irttp.h>		/* struct tsap_cb */
 #include <net/irda/discovery.h>		/* struct discovery_t */
+#include <net/sock.h>
 
 /* IrDA Socket */
 struct irda_sock {
+	/* struct sock has to be the first member of irda_sock */
+	struct sock sk;
 	__u32 saddr;          /* my local address */
 	__u32 daddr;          /* peer address */
 
@@ -69,7 +72,6 @@
 
 	int errno;            /* status of the IAS query */
 
-	struct sock *sk;
 	wait_queue_head_t query_wait;	/* Wait for the answer to a query */
 	struct timer_list watchdog;	/* Timeout for discovery */
 
@@ -77,6 +79,9 @@
 	LOCAL_FLOW rx_flow;
 };
 
-#define irda_sk(__sk) ((struct irda_sock *)(__sk)->sk_protinfo)
+static inline struct irda_sock *irda_sk(struct sock *sk)
+{
+	return (struct irda_sock *)sk;
+}
 
 #endif /* AF_IRDA_H */
diff -Nru a/net/irda/af_irda.c b/net/irda/af_irda.c
--- a/net/irda/af_irda.c	2005-01-19 23:43:00 -02:00
+++ b/net/irda/af_irda.c	2005-01-19 23:43:00 -02:00
@@ -60,6 +60,8 @@
 
 #include <net/irda/af_irda.h>
 
+static kmem_cache_t *irda_sk_slab;
+
 static int irda_create(struct socket *sock, int protocol);
 
 static struct proto_ops irda_stream_ops;
@@ -87,10 +89,10 @@
 
 	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
 
-	self = (struct irda_sock *) instance;
+	self = instance;
 	ASSERT(self != NULL, return -1;);
 
-	sk = self->sk;
+	sk = instance;
 	ASSERT(sk != NULL, return -1;);
 
 	err = sock_queue_rcv_skb(sk, skb);
@@ -117,7 +119,7 @@
 	struct irda_sock *self;
 	struct sock *sk;
 
-	self = (struct irda_sock *) instance;
+	self = instance;
 
 	IRDA_DEBUG(2, "%s(%p)\n", __FUNCTION__, self);
 
@@ -125,7 +127,7 @@
 	if(skb)
 		dev_kfree_skb(skb);
 
-	sk = self->sk;
+	sk = instance;
 	if (sk == NULL) {
 		IRDA_DEBUG(0, "%s(%p) : BUG : sk is NULL\n",
 			   __FUNCTION__, self);
@@ -183,11 +185,11 @@
 	struct irda_sock *self;
 	struct sock *sk;
 
-	self = (struct irda_sock *) instance;
+	self = instance;
 
 	IRDA_DEBUG(2, "%s(%p)\n", __FUNCTION__, self);
 
-	sk = self->sk;
+	sk = instance;
 	if (sk == NULL) {
 		dev_kfree_skb(skb);
 		return;
@@ -245,11 +247,11 @@
 	struct irda_sock *self;
 	struct sock *sk;
 
-	self = (struct irda_sock *) instance;
+	self = instance;
 
 	IRDA_DEBUG(2, "%s(%p)\n", __FUNCTION__, self);
 
-	sk = self->sk;
+	sk = instance;
 	if (sk == NULL) {
 		dev_kfree_skb(skb);
 		return;
@@ -332,10 +334,10 @@
 
 	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
 
-	self = (struct irda_sock *) instance;
+	self = instance;
 	ASSERT(self != NULL, return;);
 
-	sk = self->sk;
+	sk = instance;
 	ASSERT(sk != NULL, return;);
 
 	switch (flow) {
@@ -1082,17 +1084,12 @@
 	}
 
 	/* Allocate networking socket */
-	if ((sk = sk_alloc(PF_IRDA, GFP_ATOMIC, 1, NULL)) == NULL)
+	sk = sk_alloc(PF_IRDA, GFP_ATOMIC,
+		      sizeof(struct irda_sock), irda_sk_slab);
+	if (sk == NULL)
 		return -ENOMEM;
 
-	/* Allocate IrDA socket */
-	self = sk->sk_protinfo = kmalloc(sizeof(struct irda_sock), GFP_ATOMIC);
-	if (self == NULL) {
-		sk_free(sk);
-		return -ENOMEM;
-	}
-	memset(self, 0, sizeof(struct irda_sock));
-
+	self = irda_sk(sk);
 	IRDA_DEBUG(2, "%s() : self is %p\n", __FUNCTION__, self);
 
 	init_waitqueue_head(&self->query_wait);
@@ -1102,8 +1099,6 @@
 	sk_set_owner(sk, THIS_MODULE);
 	sk->sk_family = PF_IRDA;
 	sk->sk_protocol = protocol;
-	/* Link networking socket and IrDA socket structs together */
-	self->sk = sk;
 
 	switch (sock->type) {
 	case SOCK_STREAM:
@@ -1187,7 +1182,6 @@
 		self->lsap = NULL;
 	}
 #endif /* CONFIG_IRDA_ULTRA */
-	kfree(self);
 }
 
 /*
@@ -1208,8 +1202,6 @@
 
 	/* Destroy IrDA socket */
 	irda_destroy_socket(irda_sk(sk));
-	/* Prevent sock_def_destruct() to create havoc */
-	sk->sk_protinfo = NULL;
 
 	sock_orphan(sk);
 	sock->sk   = NULL;
@@ -2557,6 +2549,13 @@
  */
 int __init irsock_init(void)
 {
+	irda_sk_slab = kmem_cache_create("irda_sock",
+					 sizeof(struct irda_sock), 0,
+					 SLAB_HWCACHE_ALIGN, NULL, NULL);
+
+	if (irda_sk_slab == NULL)
+		return -ENOMEM;
+
 	sock_register(&irda_family_ops);
 
 	return 0;
@@ -2572,5 +2571,8 @@
 {
 	sock_unregister(PF_IRDA);
 
-        return;
+	if (irda_sk_slab != NULL) {
+		kmem_cache_destroy(irda_sk_slab);
+		irda_sk_slab = NULL;
+	}
 }



--------------000202030007010503090107--
