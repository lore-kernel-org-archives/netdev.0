From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] xfrm6_tunnel: RCU conversion
Date: Sat, 24 Oct 2009 06:19:19 +0200
Message-ID: <4AE28047.1020904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Yoshifuji Hideaki <yoshfuji@linux-ipv6.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49024 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbZJXETV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 00:19:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm6_tunnels use one rwlock to protect their hash tables.

Plain and straightforward conversion to RCU locking to permit better SMP
performance.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
--- 
 net/ipv6/xfrm6_tunnel.c |   47 ++++++++++++++++++++++----------------
 1 files changed, 28 insertions(+), 19 deletions(-)

diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index 81a95c0..438831d 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -23,7 +23,7 @@
  */
 #include <linux/module.h>
 #include <linux/xfrm.h>
-#include <linux/list.h>
+#include <linux/rculist.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
 #include <net/ipv6.h>
@@ -36,14 +36,15 @@
  * per xfrm_address_t.
  */
 struct xfrm6_tunnel_spi {
-	struct hlist_node list_byaddr;
-	struct hlist_node list_byspi;
-	xfrm_address_t addr;
-	u32 spi;
-	atomic_t refcnt;
+	struct hlist_node	list_byaddr;
+	struct hlist_node	list_byspi;
+	xfrm_address_t		addr;
+	u32			spi;
+	atomic_t		refcnt;
+	struct rcu_head		rcu_head;
 };
 
-static DEFINE_RWLOCK(xfrm6_tunnel_spi_lock);
+static DEFINE_SPINLOCK(xfrm6_tunnel_spi_lock);
 
 static u32 xfrm6_tunnel_spi;
 
@@ -107,6 +108,7 @@ static void xfrm6_tunnel_spi_fini(void)
 		if (!hlist_empty(&xfrm6_tunnel_spi_byspi[i]))
 			return;
 	}
+	rcu_barrier();
 	kmem_cache_destroy(xfrm6_tunnel_spi_kmem);
 	xfrm6_tunnel_spi_kmem = NULL;
 }
@@ -116,7 +118,7 @@ static struct xfrm6_tunnel_spi *__xfrm6_tunnel_spi_lookup(xfrm_address_t *saddr)
 	struct xfrm6_tunnel_spi *x6spi;
 	struct hlist_node *pos;
 
-	hlist_for_each_entry(x6spi, pos,
+	hlist_for_each_entry_rcu(x6spi, pos,
 			     &xfrm6_tunnel_spi_byaddr[xfrm6_tunnel_spi_hash_byaddr(saddr)],
 			     list_byaddr) {
 		if (memcmp(&x6spi->addr, saddr, sizeof(x6spi->addr)) == 0)
@@ -131,10 +133,10 @@ __be32 xfrm6_tunnel_spi_lookup(xfrm_address_t *saddr)
 	struct xfrm6_tunnel_spi *x6spi;
 	u32 spi;
 
-	read_lock_bh(&xfrm6_tunnel_spi_lock);
+	rcu_read_lock_bh();
 	x6spi = __xfrm6_tunnel_spi_lookup(saddr);
 	spi = x6spi ? x6spi->spi : 0;
-	read_unlock_bh(&xfrm6_tunnel_spi_lock);
+	rcu_read_unlock_bh();
 	return htonl(spi);
 }
 
@@ -185,14 +187,15 @@ alloc_spi:
 	if (!x6spi)
 		goto out;
 
+	INIT_RCU_HEAD(&x6spi->rcu_head);
 	memcpy(&x6spi->addr, saddr, sizeof(x6spi->addr));
 	x6spi->spi = spi;
 	atomic_set(&x6spi->refcnt, 1);
 
-	hlist_add_head(&x6spi->list_byspi, &xfrm6_tunnel_spi_byspi[index]);
+	hlist_add_head_rcu(&x6spi->list_byspi, &xfrm6_tunnel_spi_byspi[index]);
 
 	index = xfrm6_tunnel_spi_hash_byaddr(saddr);
-	hlist_add_head(&x6spi->list_byaddr, &xfrm6_tunnel_spi_byaddr[index]);
+	hlist_add_head_rcu(&x6spi->list_byaddr, &xfrm6_tunnel_spi_byaddr[index]);
 out:
 	return spi;
 }
@@ -202,26 +205,32 @@ __be32 xfrm6_tunnel_alloc_spi(xfrm_address_t *saddr)
 	struct xfrm6_tunnel_spi *x6spi;
 	u32 spi;
 
-	write_lock_bh(&xfrm6_tunnel_spi_lock);
+	spin_lock_bh(&xfrm6_tunnel_spi_lock);
 	x6spi = __xfrm6_tunnel_spi_lookup(saddr);
 	if (x6spi) {
 		atomic_inc(&x6spi->refcnt);
 		spi = x6spi->spi;
 	} else
 		spi = __xfrm6_tunnel_alloc_spi(saddr);
-	write_unlock_bh(&xfrm6_tunnel_spi_lock);
+	spin_unlock_bh(&xfrm6_tunnel_spi_lock);
 
 	return htonl(spi);
 }
 
 EXPORT_SYMBOL(xfrm6_tunnel_alloc_spi);
 
+static void x6spi_destroy_rcu(struct rcu_head *head)
+{
+	kmem_cache_free(xfrm6_tunnel_spi_kmem,
+			container_of(head, struct xfrm6_tunnel_spi, rcu_head));
+}
+
 void xfrm6_tunnel_free_spi(xfrm_address_t *saddr)
 {
 	struct xfrm6_tunnel_spi *x6spi;
 	struct hlist_node *pos, *n;
 
-	write_lock_bh(&xfrm6_tunnel_spi_lock);
+	spin_lock_bh(&xfrm6_tunnel_spi_lock);
 
 	hlist_for_each_entry_safe(x6spi, pos, n,
 				  &xfrm6_tunnel_spi_byaddr[xfrm6_tunnel_spi_hash_byaddr(saddr)],
@@ -229,14 +238,14 @@ void xfrm6_tunnel_free_spi(xfrm_address_t *saddr)
 	{
 		if (memcmp(&x6spi->addr, saddr, sizeof(x6spi->addr)) == 0) {
 			if (atomic_dec_and_test(&x6spi->refcnt)) {
-				hlist_del(&x6spi->list_byaddr);
-				hlist_del(&x6spi->list_byspi);
-				kmem_cache_free(xfrm6_tunnel_spi_kmem, x6spi);
+				hlist_del_rcu(&x6spi->list_byaddr);
+				hlist_del_rcu(&x6spi->list_byspi);
+				call_rcu(&x6spi->rcu_head, x6spi_destroy_rcu);
 				break;
 			}
 		}
 	}
-	write_unlock_bh(&xfrm6_tunnel_spi_lock);
+	spin_unlock_bh(&xfrm6_tunnel_spi_lock);
 }
 
 EXPORT_SYMBOL(xfrm6_tunnel_free_spi);
