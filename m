From: "David S. Miller" <davem@davemloft.net>
Subject: Re: neigh_create/inetdev_destroy race?
Date: Wed, 1 Sep 2004 22:21:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040901222118.0ce4bcc6.davem@davemloft.net>
References: <20040814005411.GA18350@gondor.apana.org.au>
	<20040814012513.GA721@gondor.apana.org.au>
	<20040814013030.GA2042@gondor.apana.org.au>
	<20040814050848.GA11874@gondor.apana.org.au>
	<20040814062703.GA4806@gondor.apana.org.au>
	<20040815191450.77532d5d.davem@redhat.com>
	<20040816105131.GA11299@gondor.apana.org.au>
	<20040828234201.79556f6e.davem@davemloft.net>
	<20040829065031.GA786@gondor.apana.org.au>
	<20040830230820.7514985d.davem@davemloft.net>
	<20040831104139.GA2124@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040831104139.GA2124@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 31 Aug 2004 20:41:39 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> > I think we can clear this by putting neigh_parms_release() into an
> > RCU handler.  It can't be in in_dev_rcu_put.
> 
> Yes that should go a long way in resolving this problem.

So here's the first step.  No rcu_read_lock()'s are needed
since the tbl->lock needs to be held as a write when
traversing these things anyways for other reasons.

Can you work on the next bit you mentioned, making
sure the corresponding idev is still alive when we add
a neighbour with its neigh_parms to the hash table?

Thanks.

===== include/net/neighbour.h 1.8 vs edited =====
--- 1.8/include/net/neighbour.h	2004-08-16 14:10:51 -07:00
+++ edited/include/net/neighbour.h	2004-09-01 21:57:37 -07:00
@@ -46,6 +46,7 @@
 #include <asm/atomic.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
+#include <linux/rcupdate.h>
 
 #include <linux/err.h>
 #include <linux/sysctl.h>
@@ -65,6 +66,8 @@
 	void	*priv;
 
 	void	*sysctl_table;
+
+	struct rcu_head rcu_head;
 
 	int	base_reachable_time;
 	int	retrans_time;
===== net/core/neighbour.c 1.28 vs edited =====
--- 1.28/net/core/neighbour.c	2004-04-29 16:26:35 -07:00
+++ edited/net/core/neighbour.c	2004-09-01 22:00:59 -07:00
@@ -1120,6 +1120,7 @@
 	if (p) {
 		memcpy(p, &tbl->parms, sizeof(*p));
 		p->tbl		  = tbl;
+		INIT_RCU_HEAD(&p->rcu_head);
 		p->reachable_time =
 				neigh_rand_reach_time(p->base_reachable_time);
 		if (dev && dev->neigh_setup && dev->neigh_setup(dev, p)) {
@@ -1135,6 +1136,14 @@
 	return p;
 }
 
+static void neigh_rcu_free_parms(struct rcu_head *head)
+{
+	struct neigh_parms *parms =
+		container_of(head, struct neigh_parms, rcu_head);
+
+	kfree(parms);
+}
+
 void neigh_parms_release(struct neigh_table *tbl, struct neigh_parms *parms)
 {
 	struct neigh_parms **p;
@@ -1146,7 +1155,7 @@
 		if (*p == parms) {
 			*p = parms->next;
 			write_unlock_bh(&tbl->lock);
-			kfree(parms);
+			call_rcu(&parms->rcu_head, neigh_rcu_free_parms);
 			return;
 		}
 	}
@@ -1159,6 +1168,7 @@
 {
 	unsigned long now = jiffies;
 
+	INIT_RCU_HEAD(&tbl->parms.rcu_head);
 	tbl->parms.reachable_time =
 			  neigh_rand_reach_time(tbl->parms.base_reachable_time);
 
