From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: neigh_create/inetdev_destroy race?
Date: Fri, 3 Sep 2004 23:36:23 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040903133623.GA23179@gondor.apana.org.au>
References: <20040814050848.GA11874@gondor.apana.org.au> <20040814062703.GA4806@gondor.apana.org.au> <20040815191450.77532d5d.davem@redhat.com> <20040816105131.GA11299@gondor.apana.org.au> <20040828234201.79556f6e.davem@davemloft.net> <20040829065031.GA786@gondor.apana.org.au> <20040830230820.7514985d.davem@davemloft.net> <20040831104139.GA2124@gondor.apana.org.au> <20040901222118.0ce4bcc6.davem@davemloft.net> <20040902130605.GA32570@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="huq684BweRXVnRxX"
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040902130605.GA32570@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--huq684BweRXVnRxX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Sep 02, 2004 at 11:06:05PM +1000, herbert wrote:
> 
> > Can you work on the next bit you mentioned, making
> > sure the corresponding idev is still alive when we add
> > a neighbour with its neigh_parms to the hash table?
> 
> Sure.  Actually I prefer to do it by ref counting neigh_parms directly.
> I'll send you a patch soon.

Here is the patch.

I've added a refcnt on neigh_parms as well as a dead flag.  The latter
is checked under the tbl_lock before adding a neigh entry to the hash
table.

The non-trivial bit of the patch is the first chunk of net/core/neighbour.c.
I removed that line because not doing so would mean that I have to drop
the reference to the parms right there.  That would've lead to race
conditions since many places dereference neigh->parms without holding
locks.  It's also unnecessary to reset n->parms since we're no longer
in a hurry to see it go due to the new ref counting.

You'll also notice that I've put all dereferences of dev->*_ptr under
the rcu_read_lock().  Without this we may get a neigh_parms that's
already been released.

Incidentally a lot of these places were racy even before the RCU change.
For example, in the IPv6 case neigh->parms may be set to a value that's
just been released.

Finally in order to make sure that all stale entries are purged as
quickly as possible I've added neigh_ifdown/arp_ifdown calls after
every neigh_parms_release call.  In many cases we now have multiple
calls to neigh_ifdown in the shutdown path.  I didn't remove the
earlier calls because there may be hidden dependencies for them to
be there.  Once the respective maintainers have looked at them we
can probably remove most of them.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au> 

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--huq684BweRXVnRxX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== drivers/s390/net/qeth_main.c 1.13 vs edited =====
--- 1.13/drivers/s390/net/qeth_main.c	2004-08-27 17:02:36 +10:00
+++ edited/drivers/s390/net/qeth_main.c	2004-09-03 23:16:30 +10:00
@@ -6710,19 +6710,28 @@
 qeth_arp_constructor(struct neighbour *neigh)
 {
 	struct net_device *dev = neigh->dev;
-	struct in_device *in_dev = in_dev_get(dev);
+	struct in_device *in_dev;
+	struct neigh_parms *parms;
 
-	if (in_dev == NULL)
-		return -EINVAL;
 	if (!qeth_verify_dev(dev)) {
-		in_dev_put(in_dev);
 		return qeth_old_arp_constructor(neigh);
 	}
 
+	rcu_read_lock();
+	in_dev = __in_dev_get(dev);
+	if (in_dev == NULL) {
+		rcu_read_unlock();
+		return -EINVAL;
+	}
+
+	parms = in_dev->arp_parms;
+	if (parms) {
+		__neigh_parms_put(neigh->parms);
+		neigh->parms = neigh_parms_clone(parms);
+	}
+	rcu_read_unlock();
+
 	neigh->type = inet_addr_type(*(u32 *) neigh->primary_key);
-	if (in_dev->arp_parms)
-		neigh->parms = in_dev->arp_parms;
-	in_dev_put(in_dev);
 	neigh->nud_state = NUD_NOARP;
 	neigh->ops = arp_direct_ops;
 	neigh->output = neigh->ops->queue_xmit;
===== include/net/neighbour.h 1.9 vs edited =====
--- 1.9/include/net/neighbour.h	2004-09-02 15:03:13 +10:00
+++ edited/include/net/neighbour.h	2004-09-03 23:15:51 +10:00
@@ -67,6 +67,8 @@
 
 	void	*sysctl_table;
 
+	int dead;
+	atomic_t refcnt;
 	struct rcu_head rcu_head;
 
 	int	base_reachable_time;
@@ -199,6 +201,7 @@
 
 extern struct neigh_parms	*neigh_parms_alloc(struct net_device *dev, struct neigh_table *tbl);
 extern void			neigh_parms_release(struct neigh_table *tbl, struct neigh_parms *parms);
+extern void			neigh_parms_destroy(struct neigh_parms *parms);
 extern unsigned long		neigh_rand_reach_time(unsigned long base);
 
 extern void			pneigh_enqueue(struct neigh_table *tbl, struct neigh_parms *p,
@@ -219,6 +222,23 @@
 						      char *p_name,
 						      proc_handler *proc_handler);
 extern void			neigh_sysctl_unregister(struct neigh_parms *p);
+
+static inline void __neigh_parms_put(struct neigh_parms *parms)
+{
+	atomic_dec(&parms->refcnt);
+}
+
+static inline void neigh_parms_put(struct neigh_parms *parms)
+{
+	if (atomic_dec_and_test(&parms->refcnt))
+		neigh_parms_destroy(parms);
+}
+
+static inline struct neigh_parms *neigh_parms_clone(struct neigh_parms *parms)
+{
+	atomic_inc(&parms->refcnt);
+	return parms;
+}
 
 /*
  *	Neighbour references
===== net/atm/clip.c 1.36 vs edited =====
--- 1.36/net/atm/clip.c	2004-08-16 12:05:46 +10:00
+++ edited/net/atm/clip.c	2004-09-03 23:16:55 +10:00
@@ -26,6 +26,7 @@
 #include <linux/bitops.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
+#include <linux/rcupdate.h>
 #include <net/route.h> /* for struct rtable and routing */
 #include <net/icmp.h> /* icmp_send */
 #include <asm/param.h> /* for HZ */
@@ -311,13 +312,27 @@
 {
 	struct atmarp_entry *entry = NEIGH2ENTRY(neigh);
 	struct net_device *dev = neigh->dev;
-	struct in_device *in_dev = dev->ip_ptr;
+	struct in_device *in_dev;
+	struct neigh_parms *parms;
 
 	DPRINTK("clip_constructor (neigh %p, entry %p)\n",neigh,entry);
-	if (!in_dev) return -EINVAL;
 	neigh->type = inet_addr_type(entry->ip);
 	if (neigh->type != RTN_UNICAST) return -EINVAL;
-	if (in_dev->arp_parms) neigh->parms = in_dev->arp_parms;
+
+	rcu_read_lock();
+	in_dev = __in_dev_get(dev);
+	if (!in_dev) {
+		rcu_read_unlock();
+		return -EINVAL;
+	}
+
+	parms = in_dev->arp_parms;
+	if (parms) {
+		__neigh_parms_put(neigh->parms);
+		neigh->parms = neigh_parms_clone(parms);
+	}
+	rcu_read_unlock();
+
 	neigh->ops = &clip_neigh_ops;
 	neigh->output = neigh->nud_state & NUD_VALID ?
 	    neigh->ops->connected_output : neigh->ops->output;
===== net/core/neighbour.c 1.29 vs edited =====
--- 1.29/net/core/neighbour.c	2004-09-02 15:03:13 +10:00
+++ edited/net/core/neighbour.c	2004-09-03 23:17:17 +10:00
@@ -227,7 +227,6 @@
 				   we must kill timers etc. and move
 				   it to safe state.
 				 */
-				n->parms = &tbl->parms;
 				skb_queue_purge(&n->arp_queue);
 				n->output = neigh_blackhole;
 				if (n->nud_state & NUD_VALID)
@@ -273,7 +272,7 @@
 	n->updated	  = n->used = now;
 	n->nud_state	  = NUD_NONE;
 	n->output	  = neigh_blackhole;
-	n->parms	  = &tbl->parms;
+	n->parms	  = neigh_parms_clone(&tbl->parms);
 	init_timer(&n->timer);
 	n->timer.function = neigh_timer_handler;
 	n->timer.data	  = (unsigned long)n;
@@ -340,12 +339,16 @@
 	hash_val = tbl->hash(pkey, dev);
 
 	write_lock_bh(&tbl->lock);
+	if (n->parms->dead) {
+		rc = ERR_PTR(-EINVAL);
+		goto out_tbl_unlock;
+	}
+
 	for (n1 = tbl->hash_buckets[hash_val]; n1; n1 = n1->next) {
 		if (dev == n1->dev && !memcmp(n1->primary_key, pkey, key_len)) {
 			neigh_hold(n1);
-			write_unlock_bh(&tbl->lock);
 			rc = n1;
-			goto out_neigh_release;
+			goto out_tbl_unlock;
 		}
 	}
 
@@ -358,6 +361,8 @@
 	rc = n;
 out:
 	return rc;
+out_tbl_unlock:
+	write_unlock_bh(&tbl->lock);
 out_neigh_release:
 	neigh_release(n);
 	goto out;
@@ -494,6 +499,7 @@
 	skb_queue_purge(&neigh->arp_queue);
 
 	dev_put(neigh->dev);
+	neigh_parms_put(neigh->parms);
 
 	NEIGH_PRINTK2("neigh %p is destroyed.\n", neigh);
 
@@ -1120,6 +1126,7 @@
 	if (p) {
 		memcpy(p, &tbl->parms, sizeof(*p));
 		p->tbl		  = tbl;
+		atomic_set(&p->refcnt, 1);
 		INIT_RCU_HEAD(&p->rcu_head);
 		p->reachable_time =
 				neigh_rand_reach_time(p->base_reachable_time);
@@ -1141,7 +1148,7 @@
 	struct neigh_parms *parms =
 		container_of(head, struct neigh_parms, rcu_head);
 
-	kfree(parms);
+	neigh_parms_put(parms);
 }
 
 void neigh_parms_release(struct neigh_table *tbl, struct neigh_parms *parms)
@@ -1154,6 +1161,7 @@
 	for (p = &tbl->parms.next; *p; p = &(*p)->next) {
 		if (*p == parms) {
 			*p = parms->next;
+			parms->dead = 1;
 			write_unlock_bh(&tbl->lock);
 			call_rcu(&parms->rcu_head, neigh_rcu_free_parms);
 			return;
@@ -1163,11 +1171,17 @@
 	NEIGH_PRINTK1("neigh_parms_release: not found\n");
 }
 
+void neigh_parms_destroy(struct neigh_parms *parms)
+{
+	kfree(parms);
+}
+
 
 void neigh_table_init(struct neigh_table *tbl)
 {
 	unsigned long now = jiffies;
 
+	atomic_set(&tbl->parms.refcnt, 1);
 	INIT_RCU_HEAD(&tbl->parms.rcu_head);
 	tbl->parms.reachable_time =
 			  neigh_rand_reach_time(tbl->parms.base_reachable_time);
===== net/decnet/dn_dev.c 1.24 vs edited =====
--- 1.24/net/decnet/dn_dev.c	2004-08-19 07:36:05 +10:00
+++ edited/net/decnet/dn_dev.c	2004-09-03 22:19:04 +10:00
@@ -1215,6 +1215,7 @@
 	dev->dn_ptr = NULL;
 
 	neigh_parms_release(&dn_neigh_table, dn_db->neigh_parms);
+	neigh_ifdown(&dn_neigh_table, dev);
 
 	if (dn_db->router)
 		neigh_release(dn_db->router);
===== net/decnet/dn_neigh.c 1.10 vs edited =====
--- 1.10/net/decnet/dn_neigh.c	2004-01-26 16:13:52 +11:00
+++ edited/net/decnet/dn_neigh.c	2004-09-03 23:17:26 +10:00
@@ -35,6 +35,7 @@
 #include <linux/netfilter_decnet.h>
 #include <linux/spinlock.h>
 #include <linux/seq_file.h>
+#include <linux/rcupdate.h>
 #include <asm/atomic.h>
 #include <net/neighbour.h>
 #include <net/dst.h>
@@ -134,13 +135,22 @@
 {
 	struct net_device *dev = neigh->dev;
 	struct dn_neigh *dn = (struct dn_neigh *)neigh;
-	struct dn_dev *dn_db = (struct dn_dev *)dev->dn_ptr;
+	struct dn_dev *dn_db;
+	struct neigh_parms *parms;
 
-	if (dn_db == NULL)
+	rcu_read_lock();
+	dn_db = dev->dn_ptr;
+	if (dn_db == NULL) {
+		rcu_read_unlock();
 		return -EINVAL;
+	}
 
-	if (dn_db->neigh_parms)
-		neigh->parms = dn_db->neigh_parms;
+	parms = dn_db->neigh_parms;
+	if (parms) {
+		__neigh_parms_put(neigh->parms);
+		neigh->parms = neigh_parms_clone(parms);
+	}
+	rcu_read_unlock();
 
 	if (dn_db->use_long)
 		neigh->ops = &dn_long_ops;
===== net/ipv4/arp.c 1.43 vs edited =====
--- 1.43/net/ipv4/arp.c	2004-09-02 11:12:37 +10:00
+++ edited/net/ipv4/arp.c	2004-09-03 23:17:42 +10:00
@@ -96,6 +96,7 @@
 #include <linux/stat.h>
 #include <linux/init.h>
 #include <linux/net.h>
+#include <linux/rcupdate.h>
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
@@ -237,16 +238,24 @@
 {
 	u32 addr = *(u32*)neigh->primary_key;
 	struct net_device *dev = neigh->dev;
-	struct in_device *in_dev = in_dev_get(dev);
-
-	if (in_dev == NULL)
-		return -EINVAL;
+	struct in_device *in_dev;
+	struct neigh_parms *parms;
 
 	neigh->type = inet_addr_type(addr);
-	if (in_dev->arp_parms)
-		neigh->parms = in_dev->arp_parms;
 
-	in_dev_put(in_dev);
+	rcu_read_lock();
+	in_dev = __in_dev_get(dev);
+	if (in_dev == NULL) {
+		rcu_read_unlock();
+		return -EINVAL;
+	}
+
+	parms = in_dev->arp_parms;
+	if (parms) {
+		__neigh_parms_put(neigh->parms);
+		neigh->parms = neigh_parms_clone(parms);
+	}
+	rcu_read_unlock();
 
 	if (dev->hard_header == NULL) {
 		neigh->nud_state = NUD_NOARP;
===== net/ipv4/devinet.c 1.36 vs edited =====
--- 1.36/net/ipv4/devinet.c	2004-08-16 16:11:59 +10:00
+++ edited/net/ipv4/devinet.c	2004-09-03 22:19:04 +10:00
@@ -184,6 +184,7 @@
 static void inetdev_destroy(struct in_device *in_dev)
 {
 	struct in_ifaddr *ifa;
+	struct net_device *dev;
 
 	ASSERT_RTNL();
 
@@ -200,12 +201,15 @@
 	devinet_sysctl_unregister(&in_dev->cnf);
 #endif
 
-	in_dev->dev->ip_ptr = NULL;
+	dev = in_dev->dev;
+	dev->ip_ptr = NULL;
 
 #ifdef CONFIG_SYSCTL
 	neigh_sysctl_unregister(in_dev->arp_parms);
 #endif
 	neigh_parms_release(&arp_tbl, in_dev->arp_parms);
+	arp_ifdown(dev);
+
 	call_rcu(&in_dev->rcu_head, in_dev_rcu_put);
 }
 
===== net/ipv6/addrconf.c 1.106 vs edited =====
--- 1.106/net/ipv6/addrconf.c	2004-08-17 12:25:06 +10:00
+++ edited/net/ipv6/addrconf.c	2004-09-03 23:04:03 +10:00
@@ -2072,6 +2072,7 @@
 		neigh_sysctl_unregister(idev->nd_parms);
 #endif
 		neigh_parms_release(&nd_tbl, idev->nd_parms);
+		neigh_ifdown(&nd_tbl, dev);
 		in6_dev_put(idev);
 	}
 	return 0;
===== net/ipv6/ndisc.c 1.87 vs edited =====
--- 1.87/net/ipv6/ndisc.c	2004-08-08 16:43:41 +10:00
+++ edited/net/ipv6/ndisc.c	2004-09-03 23:17:56 +10:00
@@ -58,6 +58,7 @@
 #include <linux/in6.h>
 #include <linux/route.h>
 #include <linux/init.h>
+#include <linux/rcupdate.h>
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
@@ -284,14 +285,23 @@
 {
 	struct in6_addr *addr = (struct in6_addr*)&neigh->primary_key;
 	struct net_device *dev = neigh->dev;
-	struct inet6_dev *in6_dev = in6_dev_get(dev);
+	struct inet6_dev *in6_dev;
+	struct neigh_parms *parms;
 	int is_multicast = ipv6_addr_is_multicast(addr);
 
-	if (in6_dev == NULL)
+	rcu_read_lock();
+	in6_dev = in6_dev_get(dev);
+	if (in6_dev == NULL) {
+		rcu_read_unlock();
 		return -EINVAL;
+	}
 
-	if (in6_dev->nd_parms)
-		neigh->parms = in6_dev->nd_parms;
+	parms = in6_dev->nd_parms;
+	if (parms) {
+		__neigh_parms_put(neigh->parms);
+		neigh->parms = neigh_parms_clone(parms);
+	}
+	rcu_read_unlock();
 
 	neigh->type = is_multicast ? RTN_MULTICAST : RTN_UNICAST;
 	if (dev->hard_header == NULL) {

--huq684BweRXVnRxX--
