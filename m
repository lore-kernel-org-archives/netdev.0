From: David Miller <davem@davemloft.net>
Subject: Re: xfrm6: move define/ifdef check order and add a Kconfig option
Date: Mon, 24 Jul 2006 13:49:21 -0700 (PDT)
Message-ID: <20060724.134921.68314968.davem@davemloft.net>
References: <20060702143611.dffe7b15.rdunlap@xenotime.net>
	<20060703.194655.38711929.davem@davemloft.net>
	<20060703214233.fa202523.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:38301
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932169AbWGXUtM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 16:49:12 -0400
To: rdunlap@xenotime.net
In-Reply-To: <20060703214233.fa202523.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Randy.Dunlap" <rdunlap@xenotime.net>
Date: Mon, 3 Jul 2006 21:42:33 -0700

> On Mon, 03 Jul 2006 19:46:55 -0700 (PDT) David Miller wrote:
> 
> > Yes, indeed.  Nothing named CONFIG_* should be defined explicitly
> > by the source files, only through Kconfig.
> > 
> > I would rather address that than apply this patch.
> 
> by adding a Kconfig option or not?  This patch adds one.

After some more consideration, I'm just going to blow away this
debugging code altogether.  It's nothing more than primitive function
call tracing.  It does things like print object pointers which have
no meaning without context.  The improper placement of the definition
of XFRM6_TUNNEL_SPI_MAGIC makes this debugging code even more dubious.

Thanks for bringing this to my attention Randy.

diff-tree a922ba5510530ae8e3c60edc85c56f72347a3c86 (from e9e9290f5c85887baf1123a36ec9fdf56a10cf4b)
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Mon Jul 24 13:49:06 2006 -0700

    [IPV6] xfrm6_tunnel: Delete debugging code.
    
    It doesn't compile, and it's dubious in several regards:
    
    1) is enabled by non-Kconfig controlled CONFIG_* value
       (noted by Randy Dunlap)
    2) XFRM6_TUNNEL_SPI_MAGIC is defined after it's first use
    3) the debugging messages print object pointer addresses
       which have no meaning without context
    
    So let's just get rid of it.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index 6b44fe8..c8f9369 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -31,27 +31,6 @@
 #include <linux/icmpv6.h>
 #include <linux/mutex.h>
 
-#ifdef CONFIG_IPV6_XFRM6_TUNNEL_DEBUG
-# define X6TDEBUG	3
-#else
-# define X6TDEBUG	1
-#endif
-
-#define X6TPRINTK(fmt, args...)		printk(fmt, ## args)
-#define X6TNOPRINTK(fmt, args...)	do { ; } while(0)
-
-#if X6TDEBUG >= 1
-# define X6TPRINTK1	X6TPRINTK
-#else
-# define X6TPRINTK1	X6TNOPRINTK
-#endif
-
-#if X6TDEBUG >= 3
-# define X6TPRINTK3	X6TPRINTK
-#else
-# define X6TPRINTK3	X6TNOPRINTK
-#endif
-
 /*
  * xfrm_tunnel_spi things are for allocating unique id ("spi") 
  * per xfrm_address_t.
@@ -62,15 +41,8 @@ struct xfrm6_tunnel_spi {
 	xfrm_address_t addr;
 	u32 spi;
 	atomic_t refcnt;
-#ifdef XFRM6_TUNNEL_SPI_MAGIC
-	u32 magic;
-#endif
 };
 
-#ifdef CONFIG_IPV6_XFRM6_TUNNEL_DEBUG
-# define XFRM6_TUNNEL_SPI_MAGIC 0xdeadbeef
-#endif
-
 static DEFINE_RWLOCK(xfrm6_tunnel_spi_lock);
 
 static u32 xfrm6_tunnel_spi;
@@ -86,43 +58,15 @@ static kmem_cache_t *xfrm6_tunnel_spi_km
 static struct hlist_head xfrm6_tunnel_spi_byaddr[XFRM6_TUNNEL_SPI_BYADDR_HSIZE];
 static struct hlist_head xfrm6_tunnel_spi_byspi[XFRM6_TUNNEL_SPI_BYSPI_HSIZE];
 
-#ifdef XFRM6_TUNNEL_SPI_MAGIC
-static int x6spi_check_magic(const struct xfrm6_tunnel_spi *x6spi,
-			     const char *name)
-{
-	if (unlikely(x6spi->magic != XFRM6_TUNNEL_SPI_MAGIC)) {
-		X6TPRINTK3(KERN_DEBUG "%s(): x6spi object "
-				      "at %p has corrupted magic %08x "
-				      "(should be %08x)\n",
-			   name, x6spi, x6spi->magic, XFRM6_TUNNEL_SPI_MAGIC);
-		return -1;
-	}
-	return 0;
-}
-#else
-static int inline x6spi_check_magic(const struct xfrm6_tunnel_spi *x6spi,
-				    const char *name)
-{
-	return 0;
-}
-#endif
-
-#define X6SPI_CHECK_MAGIC(x6spi) x6spi_check_magic((x6spi), __FUNCTION__)
-
-
 static unsigned inline xfrm6_tunnel_spi_hash_byaddr(xfrm_address_t *addr)
 {
 	unsigned h;
 
-	X6TPRINTK3(KERN_DEBUG "%s(addr=%p)\n", __FUNCTION__, addr);
-
 	h = addr->a6[0] ^ addr->a6[1] ^ addr->a6[2] ^ addr->a6[3];
 	h ^= h >> 16;
 	h ^= h >> 8;
 	h &= XFRM6_TUNNEL_SPI_BYADDR_HSIZE - 1;
 
-	X6TPRINTK3(KERN_DEBUG "%s() = %u\n", __FUNCTION__, h);
-
 	return h;
 }
 
@@ -136,19 +80,13 @@ static int xfrm6_tunnel_spi_init(void)
 {
 	int i;
 
-	X6TPRINTK3(KERN_DEBUG "%s()\n", __FUNCTION__);
-
 	xfrm6_tunnel_spi = 0;
 	xfrm6_tunnel_spi_kmem = kmem_cache_create("xfrm6_tunnel_spi",
 						  sizeof(struct xfrm6_tunnel_spi),
 						  0, SLAB_HWCACHE_ALIGN,
 						  NULL, NULL);
-	if (!xfrm6_tunnel_spi_kmem) {
-		X6TPRINTK1(KERN_ERR
-			   "%s(): failed to allocate xfrm6_tunnel_spi_kmem\n",
-		           __FUNCTION__);
+	if (!xfrm6_tunnel_spi_kmem)
 		return -ENOMEM;
-	}
 
 	for (i = 0; i < XFRM6_TUNNEL_SPI_BYADDR_HSIZE; i++)
 		INIT_HLIST_HEAD(&xfrm6_tunnel_spi_byaddr[i]);
@@ -161,22 +99,16 @@ static void xfrm6_tunnel_spi_fini(void)
 {
 	int i;
 
-	X6TPRINTK3(KERN_DEBUG "%s()\n", __FUNCTION__);
-
 	for (i = 0; i < XFRM6_TUNNEL_SPI_BYADDR_HSIZE; i++) {
 		if (!hlist_empty(&xfrm6_tunnel_spi_byaddr[i]))
-			goto err;
+			return;
 	}
 	for (i = 0; i < XFRM6_TUNNEL_SPI_BYSPI_HSIZE; i++) {
 		if (!hlist_empty(&xfrm6_tunnel_spi_byspi[i]))
-			goto err;
+			return;
 	}
 	kmem_cache_destroy(xfrm6_tunnel_spi_kmem);
 	xfrm6_tunnel_spi_kmem = NULL;
-	return;
-err:
-	X6TPRINTK1(KERN_ERR "%s(): table is not empty\n", __FUNCTION__);
-	return;
 }
 
 static struct xfrm6_tunnel_spi *__xfrm6_tunnel_spi_lookup(xfrm_address_t *saddr)
@@ -184,19 +116,13 @@ static struct xfrm6_tunnel_spi *__xfrm6_
 	struct xfrm6_tunnel_spi *x6spi;
 	struct hlist_node *pos;
 
-	X6TPRINTK3(KERN_DEBUG "%s(saddr=%p)\n", __FUNCTION__, saddr);
-
 	hlist_for_each_entry(x6spi, pos,
 			     &xfrm6_tunnel_spi_byaddr[xfrm6_tunnel_spi_hash_byaddr(saddr)],
 			     list_byaddr) {
-		if (memcmp(&x6spi->addr, saddr, sizeof(x6spi->addr)) == 0) {
-			X6SPI_CHECK_MAGIC(x6spi);
-			X6TPRINTK3(KERN_DEBUG "%s() = %p(%u)\n", __FUNCTION__, x6spi, x6spi->spi);
+		if (memcmp(&x6spi->addr, saddr, sizeof(x6spi->addr)) == 0)
 			return x6spi;
-		}
 	}
 
-	X6TPRINTK3(KERN_DEBUG "%s() = NULL(0)\n", __FUNCTION__);
 	return NULL;
 }
 
@@ -205,8 +131,6 @@ u32 xfrm6_tunnel_spi_lookup(xfrm_address
 	struct xfrm6_tunnel_spi *x6spi;
 	u32 spi;
 
-	X6TPRINTK3(KERN_DEBUG "%s(saddr=%p)\n", __FUNCTION__, saddr);
-
 	read_lock_bh(&xfrm6_tunnel_spi_lock);
 	x6spi = __xfrm6_tunnel_spi_lookup(saddr);
 	spi = x6spi ? x6spi->spi : 0;
@@ -223,8 +147,6 @@ static u32 __xfrm6_tunnel_alloc_spi(xfrm
 	struct hlist_node *pos;
 	unsigned index;
 
-	X6TPRINTK3(KERN_DEBUG "%s(saddr=%p)\n", __FUNCTION__, saddr);
-
 	if (xfrm6_tunnel_spi < XFRM6_TUNNEL_SPI_MIN ||
 	    xfrm6_tunnel_spi >= XFRM6_TUNNEL_SPI_MAX)
 		xfrm6_tunnel_spi = XFRM6_TUNNEL_SPI_MIN;
@@ -258,18 +180,10 @@ try_next_2:;
 	spi = 0;
 	goto out;
 alloc_spi:
-	X6TPRINTK3(KERN_DEBUG "%s(): allocate new spi for " NIP6_FMT "\n",
-			      __FUNCTION__, 
-			      NIP6(*(struct in6_addr *)saddr));
 	x6spi = kmem_cache_alloc(xfrm6_tunnel_spi_kmem, SLAB_ATOMIC);
-	if (!x6spi) {
-		X6TPRINTK1(KERN_ERR "%s(): kmem_cache_alloc() failed\n", 
-			   __FUNCTION__);
+	if (!x6spi)
 		goto out;
-	}
-#ifdef XFRM6_TUNNEL_SPI_MAGIC
-	x6spi->magic = XFRM6_TUNNEL_SPI_MAGIC;
-#endif
+
 	memcpy(&x6spi->addr, saddr, sizeof(x6spi->addr));
 	x6spi->spi = spi;
 	atomic_set(&x6spi->refcnt, 1);
@@ -278,9 +192,7 @@ alloc_spi:
 
 	index = xfrm6_tunnel_spi_hash_byaddr(saddr);
 	hlist_add_head(&x6spi->list_byaddr, &xfrm6_tunnel_spi_byaddr[index]);
-	X6SPI_CHECK_MAGIC(x6spi);
 out:
-	X6TPRINTK3(KERN_DEBUG "%s() = %u\n", __FUNCTION__, spi);
 	return spi;
 }
 
@@ -289,8 +201,6 @@ u32 xfrm6_tunnel_alloc_spi(xfrm_address_
 	struct xfrm6_tunnel_spi *x6spi;
 	u32 spi;
 
-	X6TPRINTK3(KERN_DEBUG "%s(saddr=%p)\n", __FUNCTION__, saddr);
-
 	write_lock_bh(&xfrm6_tunnel_spi_lock);
 	x6spi = __xfrm6_tunnel_spi_lookup(saddr);
 	if (x6spi) {
@@ -300,8 +210,6 @@ u32 xfrm6_tunnel_alloc_spi(xfrm_address_
 		spi = __xfrm6_tunnel_alloc_spi(saddr);
 	write_unlock_bh(&xfrm6_tunnel_spi_lock);
 
-	X6TPRINTK3(KERN_DEBUG "%s() = %u\n", __FUNCTION__, spi);
-
 	return spi;
 }
 
@@ -312,8 +220,6 @@ void xfrm6_tunnel_free_spi(xfrm_address_
 	struct xfrm6_tunnel_spi *x6spi;
 	struct hlist_node *pos, *n;
 
-	X6TPRINTK3(KERN_DEBUG "%s(saddr=%p)\n", __FUNCTION__, saddr);
-
 	write_lock_bh(&xfrm6_tunnel_spi_lock);
 
 	hlist_for_each_entry_safe(x6spi, pos, n, 
@@ -321,12 +227,6 @@ void xfrm6_tunnel_free_spi(xfrm_address_
 				  list_byaddr)
 	{
 		if (memcmp(&x6spi->addr, saddr, sizeof(x6spi->addr)) == 0) {
-			X6TPRINTK3(KERN_DEBUG "%s(): x6spi object for " NIP6_FMT 
-					      " found at %p\n",
-				   __FUNCTION__, 
-				   NIP6(*(struct in6_addr *)saddr),
-				   x6spi);
-			X6SPI_CHECK_MAGIC(x6spi);
 			if (atomic_dec_and_test(&x6spi->refcnt)) {
 				hlist_del(&x6spi->list_byaddr);
 				hlist_del(&x6spi->list_byspi);
@@ -377,20 +277,14 @@ static int xfrm6_tunnel_err(struct sk_bu
 		case ICMPV6_ADDR_UNREACH:
 		case ICMPV6_PORT_UNREACH:
 		default:
-			X6TPRINTK3(KERN_DEBUG
-				   "xfrm6_tunnel: Destination Unreach.\n");
 			break;
 		}
 		break;
 	case ICMPV6_PKT_TOOBIG:
-			X6TPRINTK3(KERN_DEBUG 
-				   "xfrm6_tunnel: Packet Too Big.\n");
 		break;
 	case ICMPV6_TIME_EXCEED:
 		switch (code) {
 		case ICMPV6_EXC_HOPLIMIT:
-			X6TPRINTK3(KERN_DEBUG
-				   "xfrm6_tunnel: Too small Hoplimit.\n");
 			break;
 		case ICMPV6_EXC_FRAGTIME:
 		default: 
@@ -447,22 +341,14 @@ static struct xfrm6_tunnel xfrm6_tunnel_
 
 static int __init xfrm6_tunnel_init(void)
 {
-	X6TPRINTK3(KERN_DEBUG "%s()\n", __FUNCTION__);
-
-	if (xfrm_register_type(&xfrm6_tunnel_type, AF_INET6) < 0) {
-		X6TPRINTK1(KERN_ERR
-			   "xfrm6_tunnel init: can't add xfrm type\n");
+	if (xfrm_register_type(&xfrm6_tunnel_type, AF_INET6) < 0)
 		return -EAGAIN;
-	}
+
 	if (xfrm6_tunnel_register(&xfrm6_tunnel_handler)) {
-		X6TPRINTK1(KERN_ERR
-			   "xfrm6_tunnel init(): can't add handler\n");
 		xfrm_unregister_type(&xfrm6_tunnel_type, AF_INET6);
 		return -EAGAIN;
 	}
 	if (xfrm6_tunnel_spi_init() < 0) {
-		X6TPRINTK1(KERN_ERR
-			   "xfrm6_tunnel init: failed to initialize spi\n");
 		xfrm6_tunnel_deregister(&xfrm6_tunnel_handler);
 		xfrm_unregister_type(&xfrm6_tunnel_type, AF_INET6);
 		return -EAGAIN;
@@ -472,15 +358,9 @@ static int __init xfrm6_tunnel_init(void
 
 static void __exit xfrm6_tunnel_fini(void)
 {
-	X6TPRINTK3(KERN_DEBUG "%s()\n", __FUNCTION__);
-
 	xfrm6_tunnel_spi_fini();
-	if (xfrm6_tunnel_deregister(&xfrm6_tunnel_handler))
-		X6TPRINTK1(KERN_ERR 
-			   "xfrm6_tunnel close: can't remove handler\n");
-	if (xfrm_unregister_type(&xfrm6_tunnel_type, AF_INET6) < 0)
-		X6TPRINTK1(KERN_ERR
-			   "xfrm6_tunnel close: can't remove xfrm type\n");
+	xfrm6_tunnel_deregister(&xfrm6_tunnel_handler);
+	xfrm_unregister_type(&xfrm6_tunnel_type, AF_INET6);
 }
 
 module_init(xfrm6_tunnel_init);
