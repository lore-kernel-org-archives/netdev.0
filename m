From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_state locking regression...
Date: Tue, 09 Sep 2008 21:06:54 -0700 (PDT)
Message-ID: <20080909.210654.159776216.davem@davemloft.net>
References: <20080910032304.GA28580@gondor.apana.org.au>
	<20080909.203808.112347106.davem@davemloft.net>
	<20080910040107.GA29695@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47748
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752694AbYIJEHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 00:07:01 -0400
In-Reply-To: <20080910040107.GA29695@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 10 Sep 2008 14:01:07 +1000

> On Tue, Sep 09, 2008 at 08:38:08PM -0700, David Miller wrote:
> >
> > No problem.  It might be a little bit of a chore because this new
> > walker design is intimately tied to the af_key non-atomic dump
> > changes.
> 
> Actually I was mistaken as to how the original dump worked.  I'd
> thought that it actually kept track of which bucket it was in and
> resumed from that bucket.  However in reality it only had a global
> counter and would always start walking from the beginning up until
> the counted value.  So it isn't as easy as just copying the old
> code across :)

Only AF_KEY gave an error, and this ended the dump.  This was
one of Timo's goals, to make AF_KEY continue where it left
off in subsequent dump calls done by the user, when we hit the
socket limit.

> While it is possible to restore the old order and save a little
> bit of memory, I certainly don't think this is very urgent.

Too late, I already implemented it :-)

I'm about to give the following patch a test:

ipsec: Restore hash based xfrm_state dumping.

Get rid of ->all member of struct xfrm_state, and just use a hash
iteration like we used before.

This shrinks the size of struct xfrm_state, and also restores the
dump ordering of 2.6.25 and previous.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 4bb9499..ba0e47c 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -120,7 +120,6 @@ extern struct mutex xfrm_cfg_mutex;
 /* Full description of state of transformer. */
 struct xfrm_state
 {
-	struct list_head	all;
 	union {
 		struct list_head	gclist;
 		struct hlist_node	bydst;
@@ -1247,6 +1246,7 @@ struct xfrm6_tunnel {
 
 struct xfrm_state_walk {
 	struct xfrm_state *state;
+	unsigned int chain;
 	int count;
 	u8 proto;
 };
@@ -1283,9 +1283,10 @@ extern int xfrm_proc_init(void);
 
 static inline void xfrm_state_walk_init(struct xfrm_state_walk *walk, u8 proto)
 {
-	walk->proto = proto;
 	walk->state = NULL;
+	walk->chain = 0;
 	walk->count = 0;
+	walk->proto = proto;
 }
 
 extern int xfrm_state_walk(struct xfrm_state_walk *walk,
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index aaafcee..ccf8492 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -50,7 +50,6 @@ static DEFINE_SPINLOCK(xfrm_state_lock);
  * Main use is finding SA after policy selected tunnel or transport mode.
  * Also, it can be used by ah/esp icmp error handler to find offending SA.
  */
-static LIST_HEAD(xfrm_state_all);
 static struct hlist_head *xfrm_state_bydst __read_mostly;
 static struct hlist_head *xfrm_state_bysrc __read_mostly;
 static struct hlist_head *xfrm_state_byspi __read_mostly;
@@ -525,7 +524,6 @@ struct xfrm_state *xfrm_state_alloc(void)
 	if (x) {
 		atomic_set(&x->refcnt, 1);
 		atomic_set(&x->tunnel_users, 0);
-		INIT_LIST_HEAD(&x->all);
 		INIT_HLIST_NODE(&x->bydst);
 		INIT_HLIST_NODE(&x->bysrc);
 		INIT_HLIST_NODE(&x->byspi);
@@ -566,7 +564,6 @@ int __xfrm_state_delete(struct xfrm_state *x)
 		x->km.state = XFRM_STATE_DEAD;
 		spin_lock(&xfrm_state_lock);
 		x->lastused = xfrm_state_walk_ongoing;
-		list_del_rcu(&x->all);
 		hlist_del(&x->bydst);
 		hlist_del(&x->bysrc);
 		if (x->id.spi)
@@ -867,7 +864,6 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 
 		if (km_query(x, tmpl, pol) == 0) {
 			x->km.state = XFRM_STATE_ACQ;
-			list_add_tail(&x->all, &xfrm_state_all);
 			hlist_add_head(&x->bydst, xfrm_state_bydst+h);
 			h = xfrm_src_hash(daddr, saddr, family);
 			hlist_add_head(&x->bysrc, xfrm_state_bysrc+h);
@@ -936,8 +932,6 @@ static void __xfrm_state_insert(struct xfrm_state *x)
 
 	x->genid = ++xfrm_state_genid;
 
-	list_add_tail(&x->all, &xfrm_state_all);
-
 	h = xfrm_dst_hash(&x->id.daddr, &x->props.saddr,
 			  x->props.reqid, x->props.family);
 	hlist_add_head(&x->bydst, xfrm_state_bydst+h);
@@ -1065,7 +1059,6 @@ static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 re
 		xfrm_state_hold(x);
 		x->timer.expires = jiffies + sysctl_xfrm_acq_expires*HZ;
 		add_timer(&x->timer);
-		list_add_tail(&x->all, &xfrm_state_all);
 		hlist_add_head(&x->bydst, xfrm_state_bydst+h);
 		h = xfrm_src_hash(daddr, saddr, family);
 		hlist_add_head(&x->bysrc, xfrm_state_bysrc+h);
@@ -1563,7 +1556,7 @@ int xfrm_state_walk(struct xfrm_state_walk *walk,
 		    void *data)
 {
 	struct xfrm_state *old, *x, *last = NULL;
-	int err = 0;
+	int i, err = 0;
 
 	if (walk->state == NULL && walk->count != 0)
 		return 0;
@@ -1571,24 +1564,29 @@ int xfrm_state_walk(struct xfrm_state_walk *walk,
 	old = x = walk->state;
 	walk->state = NULL;
 	spin_lock_bh(&xfrm_state_lock);
-	if (x == NULL)
-		x = list_first_entry(&xfrm_state_all, struct xfrm_state, all);
-	list_for_each_entry_from(x, &xfrm_state_all, all) {
-		if (x->km.state == XFRM_STATE_DEAD)
-			continue;
-		if (!xfrm_id_proto_match(x->id.proto, walk->proto))
-			continue;
-		if (last) {
-			err = func(last, walk->count, data);
-			if (err) {
-				xfrm_state_hold(last);
-				walk->state = last;
-				xfrm_state_walk_ongoing++;
-				goto out;
+	for (i = walk->chain; i <= xfrm_state_hmask; i++) {
+		struct hlist_head *h = xfrm_state_bydst + i;
+		struct hlist_node *entry;
+
+		if (!x)
+			x = hlist_entry(h->first, struct xfrm_state, bydst);
+		hlist_for_each_entry_from(x, entry, bydst) {
+			if (!xfrm_id_proto_match(x->id.proto, walk->proto))
+				continue;
+			if (last) {
+				err = func(last, walk->count, data);
+				if (err) {
+					xfrm_state_hold(last);
+					walk->state = last;
+					walk->chain = i;
+					xfrm_state_walk_ongoing++;
+					goto out;
+				}
 			}
+			last = x;
+			walk->count++;
 		}
-		last = x;
-		walk->count++;
+		x = NULL;
 	}
 	if (walk->count == 0) {
 		err = -ENOENT;
