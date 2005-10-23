From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [3/3] [NEIGH] Fix timer leak in neigh_changeaddr
Date: Sun, 23 Oct 2005 17:33:31 +1000
Message-ID: <20051023073331.GC17626@gondor.apana.org.au>
References: <43534273.2050106@reub.net> <E1ETaJB-0004a0-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="2/5bycvrmDh4d1IB"
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, acme@conectiva.com.br, davem@davemloft.net,
	greearb@candelatech.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751433AbVJWHdl@vger.kernel.org>
To: Reuben Farrelly <reuben-lkml@reub.net>
Content-Disposition: inline
In-Reply-To: <E1ETaJB-0004a0-00@gondolin.me.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--2/5bycvrmDh4d1IB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

[NEIGH] Fix timer leak in neigh_changeaddr

neigh_changeaddr attempts to delete neighbour timers without setting
nud_state.  This doesn't work because the timer may have already fired
when we acquire the write lock in neigh_changeaddr.  The result is that
the timer may keep firing for quite a while until the entry reaches
NEIGH_FAILED.

It should be setting the nud_state straight away so that if the timer
has already fired it can simply exit once we relinquish the lock.

In fact, this whole function is simply duplicating the logic in
neigh_ifdown which in turn is already doing the right thing when
it comes to deleting timers and setting nud_state.

So all we have to do is take that code out and put it into a common
function and make both neigh_changeaddr and neigh_ifdown call it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--2/5bycvrmDh4d1IB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p3.patch"

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -175,39 +175,10 @@ static void pneigh_queue_purge(struct sk
 	}
 }
 
-void neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev)
+static void neigh_flush_dev(struct neigh_table *tbl, struct net_device *dev)
 {
 	int i;
 
-	write_lock_bh(&tbl->lock);
-
-	for (i=0; i <= tbl->hash_mask; i++) {
-		struct neighbour *n, **np;
-
-		np = &tbl->hash_buckets[i];
-		while ((n = *np) != NULL) {
-			if (dev && n->dev != dev) {
-				np = &n->next;
-				continue;
-			}
-			*np = n->next;
-			write_lock_bh(&n->lock);
-			n->dead = 1;
-			neigh_del_timer(n);
-			write_unlock_bh(&n->lock);
-			neigh_release(n);
-		}
-	}
-
-        write_unlock_bh(&tbl->lock);
-}
-
-int neigh_ifdown(struct neigh_table *tbl, struct net_device *dev)
-{
-	int i;
-
-	write_lock_bh(&tbl->lock);
-
 	for (i = 0; i <= tbl->hash_mask; i++) {
 		struct neighbour *n, **np = &tbl->hash_buckets[i];
 
@@ -243,7 +214,19 @@ int neigh_ifdown(struct neigh_table *tbl
 			neigh_release(n);
 		}
 	}
+}
 
+void neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev)
+{
+	write_lock_bh(&tbl->lock);
+	neigh_flush_dev(tbl, dev);
+	write_unlock_bh(&tbl->lock);
+}
+
+int neigh_ifdown(struct neigh_table *tbl, struct net_device *dev)
+{
+	write_lock_bh(&tbl->lock);
+	neigh_flush_dev(tbl, dev);
 	pneigh_ifdown(tbl, dev);
 	write_unlock_bh(&tbl->lock);
 

--2/5bycvrmDh4d1IB--
