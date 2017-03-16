From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 6/9] net, ipv6: convert xfrm6_tunnel_spi.refcnt from atomic_t to refcount_t
Date: Thu, 16 Mar 2017 20:23:28 +0200
Message-ID: <1489688611-4542-7-git-send-email-elena.reshetova@intel.com>
References: <1489688611-4542-1-git-send-email-elena.reshetova@intel.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
        jmorris@namei.org, kaber@trash.net, yoshfuji@linux-ipv6.org,
        steffen.klassert@secunet.com, kuznet@ms2.inr.ac.ru,
        peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489688611-4542-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 net/ipv6/xfrm6_tunnel.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index d7b731a..4e438bc 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -59,7 +59,7 @@ struct xfrm6_tunnel_spi {
 	struct hlist_node	list_byspi;
 	xfrm_address_t		addr;
 	u32			spi;
-	atomic_t		refcnt;
+	refcount_t		refcnt;
 	struct rcu_head		rcu_head;
 };
 
@@ -160,7 +160,7 @@ static u32 __xfrm6_tunnel_alloc_spi(struct net *net, xfrm_address_t *saddr)
 
 	memcpy(&x6spi->addr, saddr, sizeof(x6spi->addr));
 	x6spi->spi = spi;
-	atomic_set(&x6spi->refcnt, 1);
+	refcount_set(&x6spi->refcnt, 1);
 
 	hlist_add_head_rcu(&x6spi->list_byspi, &xfrm6_tn->spi_byspi[index]);
 
@@ -178,7 +178,7 @@ __be32 xfrm6_tunnel_alloc_spi(struct net *net, xfrm_address_t *saddr)
 	spin_lock_bh(&xfrm6_tunnel_spi_lock);
 	x6spi = __xfrm6_tunnel_spi_lookup(net, saddr);
 	if (x6spi) {
-		atomic_inc(&x6spi->refcnt);
+		refcount_inc(&x6spi->refcnt);
 		spi = x6spi->spi;
 	} else
 		spi = __xfrm6_tunnel_alloc_spi(net, saddr);
@@ -207,7 +207,7 @@ static void xfrm6_tunnel_free_spi(struct net *net, xfrm_address_t *saddr)
 				  list_byaddr)
 	{
 		if (xfrm6_addr_equal(&x6spi->addr, saddr)) {
-			if (atomic_dec_and_test(&x6spi->refcnt)) {
+			if (refcount_dec_and_test(&x6spi->refcnt)) {
 				hlist_del_rcu(&x6spi->list_byaddr);
 				hlist_del_rcu(&x6spi->list_byspi);
 				call_rcu(&x6spi->rcu_head, x6spi_destroy_rcu);
-- 
2.7.4
