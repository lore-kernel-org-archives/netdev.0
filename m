From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 2/4] netns xfrm: xfrm6_tunnel in netns
Date: Mon, 25 Jan 2010 22:37:54 +0200
Message-ID: <20100125203754.GA6145@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:39211 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325Ab0AYUiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 15:38:02 -0500
Received: by fxm20 with SMTP id 20so4006342fxm.21
        for <netdev@vger.kernel.org>; Mon, 25 Jan 2010 12:38:01 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm not sure about rcu stuff near kmem cache destruction:
* checks for non-empty hashes look bogus, they're done _before_
  rcu_berrier()
* unregistering netns ops is done before kmem_cache destoy
  (as it should), and unregistering involves rcu barriers by itself

So it looks nothing should be done.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/xfrm.h      |    6 +-
 net/ipv6/ipcomp6.c      |    4 -
 net/ipv6/xfrm6_tunnel.c |  140 ++++++++++++++++++++++++++++--------------------
 3 files changed, 88 insertions(+), 62 deletions(-)

--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1408,9 +1408,9 @@ extern int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 			    xfrm_address_t *saddr, u8 proto);
 extern int xfrm6_tunnel_register(struct xfrm6_tunnel *handler, unsigned short family);
 extern int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler, unsigned short family);
-extern __be32 xfrm6_tunnel_alloc_spi(xfrm_address_t *saddr);
-extern void xfrm6_tunnel_free_spi(xfrm_address_t *saddr);
-extern __be32 xfrm6_tunnel_spi_lookup(xfrm_address_t *saddr);
+extern __be32 xfrm6_tunnel_alloc_spi(struct net *net, xfrm_address_t *saddr);
+extern void xfrm6_tunnel_free_spi(struct net *net, xfrm_address_t *saddr);
+extern __be32 xfrm6_tunnel_spi_lookup(struct net *net, xfrm_address_t *saddr);
 extern int xfrm6_extract_output(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm6_prepare_output(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm6_output(struct sk_buff *skb);
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -81,7 +81,7 @@ static struct xfrm_state *ipcomp6_tunnel_create(struct xfrm_state *x)
 		goto out;
 
 	t->id.proto = IPPROTO_IPV6;
-	t->id.spi = xfrm6_tunnel_alloc_spi((xfrm_address_t *)&x->props.saddr);
+	t->id.spi = xfrm6_tunnel_alloc_spi(&init_net, (xfrm_address_t *)&x->props.saddr);
 	if (!t->id.spi)
 		goto error;
 
@@ -112,7 +112,7 @@ static int ipcomp6_tunnel_attach(struct xfrm_state *x)
 	struct xfrm_state *t = NULL;
 	__be32 spi;
 
-	spi = xfrm6_tunnel_spi_lookup((xfrm_address_t *)&x->props.saddr);
+	spi = xfrm6_tunnel_spi_lookup(&init_net, (xfrm_address_t *)&x->props.saddr);
 	if (spi)
 		t = xfrm_state_lookup(&init_net, (xfrm_address_t *)&x->id.daddr,
 					      spi, IPPROTO_IPV6, AF_INET6);
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -30,6 +30,25 @@
 #include <linux/ipv6.h>
 #include <linux/icmpv6.h>
 #include <linux/mutex.h>
+#include <net/netns/generic.h>
+
+#define XFRM6_TUNNEL_SPI_BYADDR_HSIZE 256
+#define XFRM6_TUNNEL_SPI_BYSPI_HSIZE 256
+
+#define XFRM6_TUNNEL_SPI_MIN	1
+#define XFRM6_TUNNEL_SPI_MAX	0xffffffff
+
+struct xfrm6_tunnel_net {
+	struct hlist_head spi_byaddr[XFRM6_TUNNEL_SPI_BYADDR_HSIZE];
+	struct hlist_head spi_byspi[XFRM6_TUNNEL_SPI_BYSPI_HSIZE];
+	u32 spi;
+};
+
+static int xfrm6_tunnel_net_id __read_mostly;
+static inline struct xfrm6_tunnel_net *xfrm6_tunnel_pernet(struct net *net)
+{
+	return net_generic(net, xfrm6_tunnel_net_id);
+}
 
 /*
  * xfrm_tunnel_spi things are for allocating unique id ("spi")
@@ -46,19 +65,8 @@ struct xfrm6_tunnel_spi {
 
 static DEFINE_SPINLOCK(xfrm6_tunnel_spi_lock);
 
-static u32 xfrm6_tunnel_spi;
-
-#define XFRM6_TUNNEL_SPI_MIN	1
-#define XFRM6_TUNNEL_SPI_MAX	0xffffffff
-
 static struct kmem_cache *xfrm6_tunnel_spi_kmem __read_mostly;
 
-#define XFRM6_TUNNEL_SPI_BYADDR_HSIZE 256
-#define XFRM6_TUNNEL_SPI_BYSPI_HSIZE 256
-
-static struct hlist_head xfrm6_tunnel_spi_byaddr[XFRM6_TUNNEL_SPI_BYADDR_HSIZE];
-static struct hlist_head xfrm6_tunnel_spi_byspi[XFRM6_TUNNEL_SPI_BYSPI_HSIZE];
-
 static inline unsigned xfrm6_tunnel_spi_hash_byaddr(xfrm_address_t *addr)
 {
 	unsigned h;
@@ -77,49 +85,30 @@ static inline unsigned xfrm6_tunnel_spi_hash_byspi(u32 spi)
 }
 
 
-static int xfrm6_tunnel_spi_init(void)
+static int __init xfrm6_tunnel_spi_init(void)
 {
-	int i;
-
-	xfrm6_tunnel_spi = 0;
 	xfrm6_tunnel_spi_kmem = kmem_cache_create("xfrm6_tunnel_spi",
 						  sizeof(struct xfrm6_tunnel_spi),
 						  0, SLAB_HWCACHE_ALIGN,
 						  NULL);
 	if (!xfrm6_tunnel_spi_kmem)
 		return -ENOMEM;
-
-	for (i = 0; i < XFRM6_TUNNEL_SPI_BYADDR_HSIZE; i++)
-		INIT_HLIST_HEAD(&xfrm6_tunnel_spi_byaddr[i]);
-	for (i = 0; i < XFRM6_TUNNEL_SPI_BYSPI_HSIZE; i++)
-		INIT_HLIST_HEAD(&xfrm6_tunnel_spi_byspi[i]);
 	return 0;
 }
 
 static void xfrm6_tunnel_spi_fini(void)
 {
-	int i;
-
-	for (i = 0; i < XFRM6_TUNNEL_SPI_BYADDR_HSIZE; i++) {
-		if (!hlist_empty(&xfrm6_tunnel_spi_byaddr[i]))
-			return;
-	}
-	for (i = 0; i < XFRM6_TUNNEL_SPI_BYSPI_HSIZE; i++) {
-		if (!hlist_empty(&xfrm6_tunnel_spi_byspi[i]))
-			return;
-	}
-	rcu_barrier();
 	kmem_cache_destroy(xfrm6_tunnel_spi_kmem);
-	xfrm6_tunnel_spi_kmem = NULL;
 }
 
-static struct xfrm6_tunnel_spi *__xfrm6_tunnel_spi_lookup(xfrm_address_t *saddr)
+static struct xfrm6_tunnel_spi *__xfrm6_tunnel_spi_lookup(struct net *net, xfrm_address_t *saddr)
 {
+	struct xfrm6_tunnel_net *xfrm6_tn = xfrm6_tunnel_pernet(net);
 	struct xfrm6_tunnel_spi *x6spi;
 	struct hlist_node *pos;
 
 	hlist_for_each_entry_rcu(x6spi, pos,
-			     &xfrm6_tunnel_spi_byaddr[xfrm6_tunnel_spi_hash_byaddr(saddr)],
+			     &xfrm6_tn->spi_byaddr[xfrm6_tunnel_spi_hash_byaddr(saddr)],
 			     list_byaddr) {
 		if (memcmp(&x6spi->addr, saddr, sizeof(x6spi->addr)) == 0)
 			return x6spi;
@@ -128,13 +117,13 @@ static struct xfrm6_tunnel_spi *__xfrm6_tunnel_spi_lookup(xfrm_address_t *saddr)
 	return NULL;
 }
 
-__be32 xfrm6_tunnel_spi_lookup(xfrm_address_t *saddr)
+__be32 xfrm6_tunnel_spi_lookup(struct net *net, xfrm_address_t *saddr)
 {
 	struct xfrm6_tunnel_spi *x6spi;
 	u32 spi;
 
 	rcu_read_lock_bh();
-	x6spi = __xfrm6_tunnel_spi_lookup(saddr);
+	x6spi = __xfrm6_tunnel_spi_lookup(net, saddr);
 	spi = x6spi ? x6spi->spi : 0;
 	rcu_read_unlock_bh();
 	return htonl(spi);
@@ -142,14 +131,15 @@ __be32 xfrm6_tunnel_spi_lookup(xfrm_address_t *saddr)
 
 EXPORT_SYMBOL(xfrm6_tunnel_spi_lookup);
 
-static int __xfrm6_tunnel_spi_check(u32 spi)
+static int __xfrm6_tunnel_spi_check(struct net *net, u32 spi)
 {
+	struct xfrm6_tunnel_net *xfrm6_tn = xfrm6_tunnel_pernet(net);
 	struct xfrm6_tunnel_spi *x6spi;
 	int index = xfrm6_tunnel_spi_hash_byspi(spi);
 	struct hlist_node *pos;
 
 	hlist_for_each_entry(x6spi, pos,
-			     &xfrm6_tunnel_spi_byspi[index],
+			     &xfrm6_tn->spi_byspi[index],
 			     list_byspi) {
 		if (x6spi->spi == spi)
 			return -1;
@@ -157,32 +147,33 @@ static int __xfrm6_tunnel_spi_check(u32 spi)
 	return index;
 }
 
-static u32 __xfrm6_tunnel_alloc_spi(xfrm_address_t *saddr)
+static u32 __xfrm6_tunnel_alloc_spi(struct net *net, xfrm_address_t *saddr)
 {
+	struct xfrm6_tunnel_net *xfrm6_tn = xfrm6_tunnel_pernet(net);
 	u32 spi;
 	struct xfrm6_tunnel_spi *x6spi;
 	int index;
 
-	if (xfrm6_tunnel_spi < XFRM6_TUNNEL_SPI_MIN ||
-	    xfrm6_tunnel_spi >= XFRM6_TUNNEL_SPI_MAX)
-		xfrm6_tunnel_spi = XFRM6_TUNNEL_SPI_MIN;
+	if (xfrm6_tn->spi < XFRM6_TUNNEL_SPI_MIN ||
+	    xfrm6_tn->spi >= XFRM6_TUNNEL_SPI_MAX)
+		xfrm6_tn->spi = XFRM6_TUNNEL_SPI_MIN;
 	else
-		xfrm6_tunnel_spi++;
+		xfrm6_tn->spi++;
 
-	for (spi = xfrm6_tunnel_spi; spi <= XFRM6_TUNNEL_SPI_MAX; spi++) {
-		index = __xfrm6_tunnel_spi_check(spi);
+	for (spi = xfrm6_tn->spi; spi <= XFRM6_TUNNEL_SPI_MAX; spi++) {
+		index = __xfrm6_tunnel_spi_check(net, spi);
 		if (index >= 0)
 			goto alloc_spi;
 	}
-	for (spi = XFRM6_TUNNEL_SPI_MIN; spi < xfrm6_tunnel_spi; spi++) {
-		index = __xfrm6_tunnel_spi_check(spi);
+	for (spi = XFRM6_TUNNEL_SPI_MIN; spi < xfrm6_tn->spi; spi++) {
+		index = __xfrm6_tunnel_spi_check(net, spi);
 		if (index >= 0)
 			goto alloc_spi;
 	}
 	spi = 0;
 	goto out;
 alloc_spi:
-	xfrm6_tunnel_spi = spi;
+	xfrm6_tn->spi = spi;
 	x6spi = kmem_cache_alloc(xfrm6_tunnel_spi_kmem, GFP_ATOMIC);
 	if (!x6spi)
 		goto out;
@@ -192,26 +183,26 @@ alloc_spi:
 	x6spi->spi = spi;
 	atomic_set(&x6spi->refcnt, 1);
 
-	hlist_add_head_rcu(&x6spi->list_byspi, &xfrm6_tunnel_spi_byspi[index]);
+	hlist_add_head_rcu(&x6spi->list_byspi, &xfrm6_tn->spi_byspi[index]);
 
 	index = xfrm6_tunnel_spi_hash_byaddr(saddr);
-	hlist_add_head_rcu(&x6spi->list_byaddr, &xfrm6_tunnel_spi_byaddr[index]);
+	hlist_add_head_rcu(&x6spi->list_byaddr, &xfrm6_tn->spi_byaddr[index]);
 out:
 	return spi;
 }
 
-__be32 xfrm6_tunnel_alloc_spi(xfrm_address_t *saddr)
+__be32 xfrm6_tunnel_alloc_spi(struct net *net, xfrm_address_t *saddr)
 {
 	struct xfrm6_tunnel_spi *x6spi;
 	u32 spi;
 
 	spin_lock_bh(&xfrm6_tunnel_spi_lock);
-	x6spi = __xfrm6_tunnel_spi_lookup(saddr);
+	x6spi = __xfrm6_tunnel_spi_lookup(net, saddr);
 	if (x6spi) {
 		atomic_inc(&x6spi->refcnt);
 		spi = x6spi->spi;
 	} else
-		spi = __xfrm6_tunnel_alloc_spi(saddr);
+		spi = __xfrm6_tunnel_alloc_spi(net, saddr);
 	spin_unlock_bh(&xfrm6_tunnel_spi_lock);
 
 	return htonl(spi);
@@ -225,15 +216,16 @@ static void x6spi_destroy_rcu(struct rcu_head *head)
 			container_of(head, struct xfrm6_tunnel_spi, rcu_head));
 }
 
-void xfrm6_tunnel_free_spi(xfrm_address_t *saddr)
+void xfrm6_tunnel_free_spi(struct net *net, xfrm_address_t *saddr)
 {
+	struct xfrm6_tunnel_net *xfrm6_tn = xfrm6_tunnel_pernet(net);
 	struct xfrm6_tunnel_spi *x6spi;
 	struct hlist_node *pos, *n;
 
 	spin_lock_bh(&xfrm6_tunnel_spi_lock);
 
 	hlist_for_each_entry_safe(x6spi, pos, n,
-				  &xfrm6_tunnel_spi_byaddr[xfrm6_tunnel_spi_hash_byaddr(saddr)],
+				  &xfrm6_tn->spi_byaddr[xfrm6_tunnel_spi_hash_byaddr(saddr)],
 				  list_byaddr)
 	{
 		if (memcmp(&x6spi->addr, saddr, sizeof(x6spi->addr)) == 0) {
@@ -263,10 +255,11 @@ static int xfrm6_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 
 static int xfrm6_tunnel_rcv(struct sk_buff *skb)
 {
+	struct net *net = dev_net(skb->dev);
 	struct ipv6hdr *iph = ipv6_hdr(skb);
 	__be32 spi;
 
-	spi = xfrm6_tunnel_spi_lookup((xfrm_address_t *)&iph->saddr);
+	spi = xfrm6_tunnel_spi_lookup(net, (xfrm_address_t *)&iph->saddr);
 	return xfrm6_rcv_spi(skb, IPPROTO_IPV6, spi) > 0 ? : 0;
 }
 
@@ -326,7 +319,9 @@ static int xfrm6_tunnel_init_state(struct xfrm_state *x)
 
 static void xfrm6_tunnel_destroy(struct xfrm_state *x)
 {
-	xfrm6_tunnel_free_spi((xfrm_address_t *)&x->props.saddr);
+	struct net *net = xs_net(x);
+
+	xfrm6_tunnel_free_spi(net, (xfrm_address_t *)&x->props.saddr);
 }
 
 static const struct xfrm_type xfrm6_tunnel_type = {
@@ -351,6 +346,31 @@ static struct xfrm6_tunnel xfrm46_tunnel_handler = {
 	.priority	= 2,
 };
 
+static int __net_init xfrm6_tunnel_net_init(struct net *net)
+{
+	struct xfrm6_tunnel_net *xfrm6_tn = xfrm6_tunnel_pernet(net);
+	unsigned int i;
+
+	for (i = 0; i < XFRM6_TUNNEL_SPI_BYADDR_HSIZE; i++)
+		INIT_HLIST_HEAD(&xfrm6_tn->spi_byaddr[i]);
+	for (i = 0; i < XFRM6_TUNNEL_SPI_BYSPI_HSIZE; i++)
+		INIT_HLIST_HEAD(&xfrm6_tn->spi_byspi[i]);
+	xfrm6_tn->spi = 0;
+
+	return 0;
+}
+
+static void __net_exit xfrm6_tunnel_net_exit(struct net *net)
+{
+}
+
+static struct pernet_operations xfrm6_tunnel_net_ops = {
+	.init	= xfrm6_tunnel_net_init,
+	.exit	= xfrm6_tunnel_net_exit,
+	.id	= &xfrm6_tunnel_net_id,
+	.size	= sizeof(struct xfrm6_tunnel_net),
+};
+
 static int __init xfrm6_tunnel_init(void)
 {
 	int rv;
@@ -367,8 +387,13 @@ static int __init xfrm6_tunnel_init(void)
 	rv = xfrm6_tunnel_spi_init();
 	if (rv < 0)
 		goto dereg46;
+	rv = register_pernet_subsys(&xfrm6_tunnel_net_ops);
+	if (rv < 0)
+		goto deregspi;
 	return 0;
 
+deregspi:
+	xfrm6_tunnel_spi_fini();
 dereg46:
 	xfrm6_tunnel_deregister(&xfrm46_tunnel_handler, AF_INET);
 dereg6:
@@ -381,6 +406,7 @@ err:
 
 static void __exit xfrm6_tunnel_fini(void)
 {
+	unregister_pernet_subsys(&xfrm6_tunnel_net_ops);
 	xfrm6_tunnel_spi_fini();
 	xfrm6_tunnel_deregister(&xfrm46_tunnel_handler, AF_INET);
 	xfrm6_tunnel_deregister(&xfrm6_tunnel_handler, AF_INET6);
