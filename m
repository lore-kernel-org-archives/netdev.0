From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] af_pppox: create module infrastructure for protocol modules
Date: Tue, 29 Apr 2003 03:12:27 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429061227.GJ25361@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@oss.sgi.com>,
   Max Krasnyansky <maxk@qualcomm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
   Michal Ostrowski <mostrows@speakeasy.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

	Please consider pulling from:

bk://kernel.bkbits.net/acme/net-2.5

	There is just this outstanding changeset in this tree.

	Max, take a look and see if this same approach can be used in
bluetooth, I bet it can, its just a matter of not using struct net_proto_family
for bt_proto, just like pppox already was doing before my changes :-)

- Arnaldo

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.1147, 2003-04-29 02:55:39-03:00, acme@conectiva.com.br
  o af_pppox: create module infrastructure for protocol modules
  
  With this the pppox module is protected by the networking core and
  the pppox "core" protects modules for specific pppox protocols (pppoe,
  for instance), while doing it removed some not needed struct sock
  member initializations in pppoe_create that are done by sock_init_data.


 drivers/net/pppoe.c      |   30 ++++++++++--------------------
 drivers/net/pppox.c      |   47 ++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/if_pppox.h |   14 +++++++++++---
 3 files changed, 67 insertions(+), 24 deletions(-)


diff -Nru a/drivers/net/pppoe.c b/drivers/net/pppoe.c
--- a/drivers/net/pppoe.c	Tue Apr 29 02:58:32 2003
+++ b/drivers/net/pppoe.c	Tue Apr 29 02:58:32 2003
@@ -471,16 +471,15 @@
 
 /***********************************************************************
  *
- * Really kill the socket. (Called from sock_put if refcnt == 0.)
+ * Really kill the socket. (Called from pppox_sk_free if refcnt == 0.)
  *
  **********************************************************************/
-void pppoe_sock_destruct(struct sock *sk)
+static void pppoe_sk_free(struct sock *sk)
 {
 	struct pppox_opt *po = pppox_sk(sk);
 
 	if (po)
 		kfree(po);
-	MOD_DEC_USE_COUNT;
 }
 
 
@@ -495,26 +494,16 @@
 	struct sock *sk;
 	struct pppox_opt *po;
 
-	MOD_INC_USE_COUNT;
-
-	sk = sk_alloc(PF_PPPOX, GFP_KERNEL, 1, NULL);
+	sk = pppox_sk_alloc(sock, PX_PROTO_OE, GFP_KERNEL, 1, NULL);
 	if (!sk)
-		goto decmod;
-
-	sock_init_data(sock, sk);
+		goto out;
 
 	sock->state = SS_UNCONNECTED;
 	sock->ops   = &pppoe_ops;
 
-	sk->protocol = PX_PROTO_OE;
-	sk->family = PF_PPPOX;
-
 	sk->backlog_rcv = pppoe_rcv_core;
-	sk->next = NULL;
-	sk->pprev = NULL;
 	sk->state = PPPOX_NONE;
 	sk->type = SOCK_STREAM;
-	sk->destruct = pppoe_sock_destruct;
 
 	po = pppox_sk(sk) = kmalloc(sizeof(*po), GFP_KERNEL);
 	if (!po)
@@ -522,10 +511,8 @@
 	memset(po, 0, sizeof(*po));
 	po->sk = sk;
 	error = 0;
-	sock->sk = sk;
 out:	return error;
 frees:	sk_free(sk);
-decmod:	MOD_DEC_USE_COUNT;
 	goto out;
 }
 
@@ -1075,16 +1062,16 @@
 };
 #endif /* CONFIG_PROC_FS */
 
+/* ->release and ->ioctl are set at pppox_create */
+
 struct proto_ops pppoe_ops = {
     .family		= AF_PPPOX,
-    .release		= pppoe_release,
     .bind		= sock_no_bind,
     .connect		= pppoe_connect,
     .socketpair		= sock_no_socketpair,
     .accept		= sock_no_accept,
     .getname		= pppoe_getname,
     .poll		= datagram_poll,
-    .ioctl		= pppoe_ioctl,
     .listen		= sock_no_listen,
     .shutdown		= sock_no_shutdown,
     .setsockopt		= sock_no_setsockopt,
@@ -1096,7 +1083,10 @@
 
 struct pppox_proto pppoe_proto = {
     .create	= pppoe_create,
-    .ioctl	= pppoe_ioctl
+    .ioctl	= pppoe_ioctl,
+    .release	= pppoe_release,
+    .sk_free	= pppoe_sk_free,
+    .owner	= THIS_MODULE,
 };
 
 
diff -Nru a/drivers/net/pppox.c b/drivers/net/pppox.c
--- a/drivers/net/pppox.c	Tue Apr 29 02:58:32 2003
+++ b/drivers/net/pppox.c	Tue Apr 29 02:58:32 2003
@@ -64,9 +64,45 @@
 	}
 }
 
+static int pppox_release(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+	int rc = pppox_protos[sk->protocol]->release(sock);
+
+	module_put(pppox_protos[sk->protocol]->owner);
+	return rc;
+}
+
+static void pppox_sk_free(struct sock *sk)
+{
+	pppox_protos[sk->protocol]->sk_free(sk);
+	module_put(pppox_protos[sk->protocol]->owner);
+}
+
+struct sock *pppox_sk_alloc(struct socket *sock, int protocol, int priority,
+			    int zero_it, kmem_cache_t *slab)
+{
+	struct sock *sk = NULL;
+
+	if (!try_module_get(pppox_protos[protocol]->owner))
+		goto out;
+
+	sk = sk_alloc(PF_PPPOX, priority, zero_it, slab);
+	if (sk) {
+		sock_init_data(sock, sk);
+		sk->family   = PF_PPPOX;
+		sk->protocol = protocol;
+		sk->destruct = pppox_sk_free;
+	} else
+		module_put(pppox_protos[protocol]->owner);
+out:
+	return sk;
+}
+
 EXPORT_SYMBOL(register_pppox_proto);
 EXPORT_SYMBOL(unregister_pppox_proto);
 EXPORT_SYMBOL(pppox_unbind_sock);
+EXPORT_SYMBOL(pppox_sk_alloc);
 
 static int pppox_ioctl(struct socket* sock, unsigned int cmd, 
 		       unsigned long arg)
@@ -116,11 +152,19 @@
 	if (!pppox_protos[protocol])
 		goto out;
 
+	rc = -EBUSY;
+	if (!try_module_get(pppox_protos[protocol]->owner))
+		goto out;
+
 	rc = pppox_protos[protocol]->create(sock);
-	if (!rc)
+	if (!rc) {
 		/* We get to set the ioctl handler. */
+		/* And the release handler, for module refcounting */
 		/* For everything else, pppox is just a shell. */
 		sock->ops->ioctl = pppox_ioctl;
+		sock->ops->release = pppox_release;
+	} else
+		module_put(pppox_protos[protocol]->owner);
 out:
 	return rc;
 }
@@ -128,6 +172,7 @@
 static struct net_proto_family pppox_proto_family = {
 	.family	= PF_PPPOX,
 	.create	= pppox_create,
+	.owner	= THIS_MODULE,
 };
 
 static int __init pppox_init(void)
diff -Nru a/include/linux/if_pppox.h b/include/linux/if_pppox.h
--- a/include/linux/if_pppox.h	Tue Apr 29 02:58:32 2003
+++ b/include/linux/if_pppox.h	Tue Apr 29 02:58:32 2003
@@ -134,10 +134,15 @@
 
 #define pppox_sk(__sk) ((struct pppox_opt *)(__sk)->protinfo)
 
+struct module;
+
 struct pppox_proto {
-	int (*create)(struct socket *sock);
-	int (*ioctl)(struct socket *sock, unsigned int cmd,
-		     unsigned long arg);
+	int		(*create)(struct socket *sock);
+	int		(*ioctl)(struct socket *sock, unsigned int cmd,
+				 unsigned long arg);
+	int		(*release)(struct socket *sock);
+	void            (*sk_free)(struct sock *sk);
+	struct module	*owner;
 };
 
 extern int register_pppox_proto(int proto_num, struct pppox_proto *pp);
@@ -145,6 +150,9 @@
 extern void pppox_unbind_sock(struct sock *sk);/* delete ppp-channel binding */
 extern int pppox_channel_ioctl(struct ppp_channel *pc, unsigned int cmd,
 			       unsigned long arg);
+extern struct sock *pppox_sk_alloc(struct socket *sock, int protocol,
+				   int priority, int zero_it,
+				   kmem_cache_t *slab);
 
 /* PPPoX socket states */
 enum {

===================================================================


This BitKeeper patch contains the following changesets:
1.1147
## Wrapped with gzip_uu ##


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
9_^'"-)OD\VEGQ)B)+8_H_P,X$HUJ'A8     
 
