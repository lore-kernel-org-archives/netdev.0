From: "David S. Miller" <davem@davemloft.net>
Subject: [1/6]: Abstract neigh table walking
Date: Thu, 23 Sep 2004 22:48:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923224841.16ac32fa.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: laforge@gnumonks.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This way we can hide hash table accesses inside
of net/core/neigh.c

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/23 15:15:26-07:00 davem@nuts.davemloft.net 
#   [NET]: Abstract neigh table walking.
#   
#   This way no code actually needs to traverse the
#   neigh hash tables outside of net/core/neighbour.c
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/ipv4/arp.c
#   2004/09/23 15:14:50-07:00 davem@nuts.davemloft.net +20 -163
#   [NET]: Abstract neigh table walking.
#   
#   This way no code actually needs to traverse the
#   neigh hash tables outside of net/core/neighbour.c
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/decnet/dn_neigh.c
#   2004/09/23 15:14:50-07:00 davem@nuts.davemloft.net +52 -120
#   [NET]: Abstract neigh table walking.
#   
#   This way no code actually needs to traverse the
#   neigh hash tables outside of net/core/neighbour.c
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/core/neighbour.c
#   2004/09/23 15:14:50-07:00 davem@nuts.davemloft.net +260 -0
#   [NET]: Abstract neigh table walking.
#   
#   This way no code actually needs to traverse the
#   neigh hash tables outside of net/core/neighbour.c
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/atm/clip.c
#   2004/09/23 15:14:50-07:00 davem@nuts.davemloft.net +117 -129
#   [NET]: Abstract neigh table walking.
#   
#   This way no code actually needs to traverse the
#   neigh hash tables outside of net/core/neighbour.c
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# include/net/neighbour.h
#   2004/09/23 15:14:49-07:00 davem@nuts.davemloft.net +19 -0
#   [NET]: Abstract neigh table walking.
#   
#   This way no code actually needs to traverse the
#   neigh hash tables outside of net/core/neighbour.c
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
diff -Nru a/include/net/neighbour.h b/include/net/neighbour.h
--- a/include/net/neighbour.h	2004-09-23 22:25:53 -07:00
+++ b/include/net/neighbour.h	2004-09-23 22:25:53 -07:00
@@ -47,6 +47,7 @@
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/rcupdate.h>
+#include <linux/seq_file.h>
 
 #include <linux/err.h>
 #include <linux/sysctl.h>
@@ -223,6 +224,24 @@
 extern int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg);
 extern int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg);
 extern void neigh_app_ns(struct neighbour *n);
+
+extern void neigh_for_each(struct neigh_table *tbl, void (*cb)(struct neighbour *, void *), void *cookie);
+extern void __neigh_for_each_release(struct neigh_table *tbl, int (*cb)(struct neighbour *));
+extern void pneigh_for_each(struct neigh_table *tbl, void (*cb)(struct pneigh_entry *));
+
+struct neigh_seq_state {
+	struct neigh_table *tbl;
+	void *(*neigh_sub_iter)(struct neigh_seq_state *state,
+				struct neighbour *n, loff_t *pos);
+	unsigned int bucket;
+	unsigned int flags;
+#define NEIGH_SEQ_NEIGH_ONLY	0x00000001
+#define NEIGH_SEQ_IS_PNEIGH	0x00000002
+#define NEIGH_SEQ_SKIP_NOARP	0x00000004
+};
+extern void *neigh_seq_start(struct seq_file *, loff_t *, struct neigh_table *, unsigned int);
+extern void *neigh_seq_next(struct seq_file *, void *, loff_t *);
+extern void neigh_seq_stop(struct seq_file *, void *);
 
 extern int			neigh_sysctl_register(struct net_device *dev, 
 						      struct neigh_parms *p,
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	2004-09-23 22:25:53 -07:00
+++ b/net/atm/clip.c	2004-09-23 22:25:53 -07:00
@@ -123,64 +123,49 @@
 	spin_unlock_bh(&entry->neigh->dev->xmit_lock);
 }
 
-
-static void idle_timer_check(unsigned long dummy)
+/* The neighbour entry n->lock is held. */
+static int neigh_check_cb(struct neighbour *n)
 {
-	int i;
+	struct atmarp_entry *entry = NEIGH2ENTRY(n);
+	struct clip_vcc *cv;
 
-	/*DPRINTK("idle_timer_check\n");*/
-	write_lock(&clip_tbl.lock);
-	for (i = 0; i <= NEIGH_HASHMASK; i++) {
-		struct neighbour **np;
+	for (cv = entry->vccs; cv; cv = cv->next) {
+		unsigned long exp = cv->last_use + cv->idle_timeout;
 
-		for (np = &clip_tbl.hash_buckets[i]; *np;) {
-			struct neighbour *n = *np;
-			struct atmarp_entry *entry = NEIGH2ENTRY(n);
-			struct clip_vcc *clip_vcc;
-
-			write_lock(&n->lock);
-
-			for (clip_vcc = entry->vccs; clip_vcc;
-			    clip_vcc = clip_vcc->next)
-				if (clip_vcc->idle_timeout &&
-				    time_after(jiffies, clip_vcc->last_use+
-				    clip_vcc->idle_timeout)) {
-					DPRINTK("releasing vcc %p->%p of "
-					    "entry %p\n",clip_vcc,clip_vcc->vcc,
-					    entry);
-					vcc_release_async(clip_vcc->vcc,
-							  -ETIMEDOUT);
-				}
-			if (entry->vccs ||
-			    time_before(jiffies, entry->expires)) {
-				np = &n->next;
-				write_unlock(&n->lock);
-				continue;
-			}
-			if (atomic_read(&n->refcnt) > 1) {
-				struct sk_buff *skb;
-
-				DPRINTK("destruction postponed with ref %d\n",
-				    atomic_read(&n->refcnt));
-				while ((skb = skb_dequeue(&n->arp_queue)) !=
-				     NULL) 
-					dev_kfree_skb(skb);
-				np = &n->next;
-				write_unlock(&n->lock);
-				continue;
-			}
-			*np = n->next;
-			DPRINTK("expired neigh %p\n",n);
-			n->dead = 1;
-			write_unlock(&n->lock);
-			neigh_release(n);
+		if (cv->idle_timeout && time_after(jiffies, exp)) {
+			DPRINTK("releasing vcc %p->%p of entry %p\n",
+				cv, cv->vcc, entry);
+			vcc_release_async(cv->vcc, -ETIMEDOUT);
 		}
 	}
+
+	if (entry->vccs || time_before(jiffies, entry->expires))
+		return 0;
+
+	if (atomic_read(&n->refcnt) > 1) {
+		struct sk_buff *skb;
+
+		DPRINTK("destruction postponed with ref %d\n",
+			atomic_read(&n->refcnt));
+
+		while ((skb = skb_dequeue(&n->arp_queue)) != NULL) 
+			dev_kfree_skb(skb);
+
+		return 0;
+	}
+
+	DPRINTK("expired neigh %p\n",n);
+	return 1;
+}
+
+static void idle_timer_check(unsigned long dummy)
+{
+	write_lock(&clip_tbl.lock);
+	__neigh_for_each_release(&clip_tbl, neigh_check_cb);
 	mod_timer(&idle_timer, jiffies+CLIP_CHECK_INTERVAL*HZ);
 	write_unlock(&clip_tbl.lock);
 }
 
-
 static int clip_arp_rcv(struct sk_buff *skb)
 {
 	struct atm_vcc *vcc;
@@ -833,120 +818,126 @@
 	}
 }
 
+/* This means the neighbour entry has no attached VCC objects. */
+#define SEQ_NO_VCC_TOKEN	((void *) 2)
+
 static void atmarp_info(struct seq_file *seq, struct net_device *dev,
 			struct atmarp_entry *entry, struct clip_vcc *clip_vcc)
 {
+	unsigned long exp;
 	char buf[17];
-	int svc, off;
+	int svc, llc, off;
+
+	svc = ((clip_vcc == SEQ_NO_VCC_TOKEN) ||
+	       (clip_vcc->vcc->sk->sk_family == AF_ATMSVC));
+
+	llc = ((clip_vcc == SEQ_NO_VCC_TOKEN) ||
+	       clip_vcc->encap);
+
+	if (clip_vcc == SEQ_NO_VCC_TOKEN)
+		exp = entry->neigh->used;
+	else
+		exp = clip_vcc->last_use;
 
-	svc = !clip_vcc || clip_vcc->vcc->sk->sk_family == AF_ATMSVC;
-	seq_printf(seq, "%-6s%-4s%-4s%5ld ", dev->name, svc ? "SVC" : "PVC",
-	    !clip_vcc || clip_vcc->encap ? "LLC" : "NULL",
-	    (jiffies-(clip_vcc ? clip_vcc->last_use : entry->neigh->used))/HZ);
+	exp = (jiffies - exp) / HZ;
 
-	off = scnprintf(buf, sizeof(buf) - 1, "%d.%d.%d.%d", NIPQUAD(entry->ip));
+	seq_printf(seq, "%-6s%-4s%-4s%5ld ",
+		   dev->name,
+		   svc ? "SVC" : "PVC",
+		   llc ? "LLC" : "NULL",
+		   exp);
+
+	off = scnprintf(buf, sizeof(buf) - 1, "%d.%d.%d.%d",
+			NIPQUAD(entry->ip));
 	while (off < 16)
 		buf[off++] = ' ';
 	buf[off] = '\0';
 	seq_printf(seq, "%s", buf);
 
-	if (!clip_vcc) {
+	if (clip_vcc == SEQ_NO_VCC_TOKEN) {
 		if (time_before(jiffies, entry->expires))
 			seq_printf(seq, "(resolving)\n");
 		else
 			seq_printf(seq, "(expired, ref %d)\n",
 				   atomic_read(&entry->neigh->refcnt));
 	} else if (!svc) {
-		seq_printf(seq, "%d.%d.%d\n", clip_vcc->vcc->dev->number,
-			   clip_vcc->vcc->vpi, clip_vcc->vcc->vci);
+		seq_printf(seq, "%d.%d.%d\n",
+			   clip_vcc->vcc->dev->number,
+			   clip_vcc->vcc->vpi,
+			   clip_vcc->vcc->vci);
 	} else {
 		svc_addr(seq, &clip_vcc->vcc->remote);
 		seq_putc(seq, '\n');
 	}
 }
 
-struct arp_state {
-	int bucket;
-  	struct neighbour *n;
+struct clip_seq_state {
+	/* This member must be first. */
+	struct neigh_seq_state ns;
+
+	/* Local to clip specific iteration. */
 	struct clip_vcc *vcc;
 };
-  
-static void *arp_vcc_walk(struct arp_state *state,
-			  struct atmarp_entry *e, loff_t *l)
-{
-	struct clip_vcc *vcc = state->vcc;
 
-	if (!vcc)
-		vcc = e->vccs;
-	if (vcc == (void *)1) {
-		vcc = e->vccs;
-		--*l;
-  	}
-	for (; vcc; vcc = vcc->next) {
-		if (--*l < 0)
-			break;
-	}
-	state->vcc = vcc;
-	return (*l < 0) ? state : NULL;
-}
-  
-static void *arp_get_idx(struct arp_state *state, loff_t l)
+static struct clip_vcc *clip_seq_next_vcc(struct atmarp_entry *e,
+					  struct clip_vcc *curr)
 {
-	void *v = NULL;
-
-	for (; state->bucket <= NEIGH_HASHMASK; state->bucket++) {
-		for (; state->n; state->n = state->n->next) {
-			v = arp_vcc_walk(state, NEIGH2ENTRY(state->n), &l);
-			if (v)
-				goto done;
-  		}
-		state->n = clip_tbl.hash_buckets[state->bucket + 1];
+	if (!curr) {
+		curr = e->vccs;
+		if (!curr)
+			return SEQ_NO_VCC_TOKEN;
+		return curr;
 	}
-done:
-	return v;
+	if (curr == SEQ_NO_VCC_TOKEN)
+		return NULL;
+
+	curr = curr->next;
+
+	return curr;
 }
 
-static void *arp_seq_start(struct seq_file *seq, loff_t *pos)
+static void *clip_seq_vcc_walk(struct clip_seq_state *state,
+			       struct atmarp_entry *e, loff_t *pos)
 {
-	struct arp_state *state = seq->private;
-	void *ret = (void *)1;
+	struct clip_vcc *vcc = state->vcc;
 
-	read_lock_bh(&clip_tbl.lock);
-	state->bucket = 0;
-	state->n = clip_tbl.hash_buckets[0];
-	state->vcc = (void *)1;
-	if (*pos)
-		ret = arp_get_idx(state, *pos);
-	return ret;
-}
+	vcc = clip_seq_next_vcc(e, vcc);
+	if (vcc && pos != NULL) {
+		while (*pos) {
+			vcc = clip_seq_next_vcc(e, vcc);
+			if (!vcc)
+				break;
+			--(*pos);
+		}
+	}
+	state->vcc = vcc;
 
-static void arp_seq_stop(struct seq_file *seq, void *v)
+	return vcc;
+}
+  
+static void *clip_seq_sub_iter(struct neigh_seq_state *_state,
+			       struct neighbour *n, loff_t *pos)
 {
-	struct arp_state *state = seq->private;
+	struct clip_seq_state *state = (struct clip_seq_state *) _state;
 
-	if (state->bucket != -1)
-		read_unlock_bh(&clip_tbl.lock);
+	return clip_seq_vcc_walk(state, NEIGH2ENTRY(n), pos);
 }
 
-static void *arp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+static void *clip_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	struct arp_state *state = seq->private;
-
-	v = arp_get_idx(state, 1);
-	*pos += !!PTR_ERR(v);
-	return v;
+	return neigh_seq_start(seq, pos, &clip_tbl, NEIGH_SEQ_NEIGH_ONLY);
 }
 
-static int arp_seq_show(struct seq_file *seq, void *v)
+static int clip_seq_show(struct seq_file *seq, void *v)
 {
 	static char atm_arp_banner[] = 
 		"IPitf TypeEncp Idle IP address      ATM address\n";
 
-	if (v == (void *)1)
+	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq, atm_arp_banner);
-	else {
-		struct arp_state *state = seq->private;
-		struct neighbour *n = state->n;	
+	} else {
+		struct clip_seq_state *state = seq->private;
+		struct neighbour *n = v;
 		struct clip_vcc *vcc = state->vcc;
 
 		atmarp_info(seq, n->dev, NEIGH2ENTRY(n), vcc);
@@ -955,15 +946,15 @@
 }
 
 static struct seq_operations arp_seq_ops = {
-	.start	= arp_seq_start,
-	.next	= arp_seq_next,
-	.stop	= arp_seq_stop,
-	.show	= arp_seq_show,
+	.start	= clip_seq_start,
+	.next	= neigh_seq_next,
+	.stop	= neigh_seq_stop,
+	.show	= clip_seq_show,
 };
 
 static int arp_seq_open(struct inode *inode, struct file *file)
 {
-	struct arp_state *state;
+	struct clip_seq_state *state;
 	struct seq_file *seq;
 	int rc = -EAGAIN;
 
@@ -972,6 +963,8 @@
 		rc = -ENOMEM;
 		goto out_kfree;
 	}
+	memset(state, 0, sizeof(*state));
+	state->ns.neigh_sub_iter = clip_seq_sub_iter;
 
 	rc = seq_open(file, &arp_seq_ops);
 	if (rc)
@@ -987,16 +980,11 @@
 	goto out;
 }
 
-static int arp_seq_release(struct inode *inode, struct file *file)
-{
-	return seq_release_private(inode, file);
-}
-
 static struct file_operations arp_seq_fops = {
 	.open		= arp_seq_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
-	.release	= arp_seq_release,
+	.release	= seq_release_private,
 	.owner		= THIS_MODULE
 };
 #endif
diff -Nru a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c	2004-09-23 22:25:53 -07:00
+++ b/net/core/neighbour.c	2004-09-23 22:25:53 -07:00
@@ -1489,6 +1489,266 @@
 	return skb->len;
 }
 
+void neigh_for_each(struct neigh_table *tbl, void (*cb)(struct neighbour *, void *), void *cookie)
+{
+	int chain;
+
+	read_lock_bh(&tbl->lock);
+	for (chain = 0; chain <= NEIGH_HASHMASK; chain++) {
+		struct neighbour *n;
+
+		for (n = tbl->hash_buckets[chain]; n; n = n->next)
+			cb(n, cookie);
+	}
+	read_unlock_bh(&tbl->lock);
+}
+EXPORT_SYMBOL(neigh_for_each);
+
+/* The tbl->lock must be held as a writer and BH disabled. */
+void __neigh_for_each_release(struct neigh_table *tbl,
+			      int (*cb)(struct neighbour *))
+{
+	int chain;
+
+	for (chain = 0; chain <= NEIGH_HASHMASK; chain++) {
+		struct neighbour *n, **np;
+
+		np = &tbl->hash_buckets[chain];
+		while ((n = *np) != NULL) {
+			int release;
+
+			write_lock(&n->lock);
+			release = cb(n);
+			if (release) {
+				*np = n->next;
+				n->dead = 1;
+			} else
+				np = &n->next;
+			write_unlock(&n->lock);
+			if (release)
+				neigh_release(n);
+		}
+	}
+}
+EXPORT_SYMBOL(__neigh_for_each_release);
+
+#ifdef CONFIG_PROC_FS
+
+static struct neighbour *neigh_get_first(struct seq_file *seq)
+{
+	struct neigh_seq_state *state = seq->private;
+	struct neigh_table *tbl = state->tbl;
+	struct neighbour *n = NULL;
+	int bucket = state->bucket;
+
+	state->flags &= ~NEIGH_SEQ_IS_PNEIGH;
+	for (bucket = 0; bucket <= NEIGH_HASHMASK; bucket++) {
+		n = tbl->hash_buckets[bucket];
+
+		while (n) {
+			if (state->neigh_sub_iter) {
+				loff_t fakep = 0;
+				void *v;
+
+				v = state->neigh_sub_iter(state, n, &fakep);
+				if (!v)
+					goto next;
+			}
+			if (!(state->flags & NEIGH_SEQ_SKIP_NOARP))
+				break;
+			if (n->nud_state & ~NUD_NOARP)
+				break;
+		next:
+			n = n->next;
+		}
+
+		if (n)
+			break;
+	}
+	state->bucket = bucket;
+
+	return n;
+}
+
+static struct neighbour *neigh_get_next(struct seq_file *seq,
+					struct neighbour *n,
+					loff_t *pos)
+{
+	struct neigh_seq_state *state = seq->private;
+	struct neigh_table *tbl = state->tbl;
+
+	if (state->neigh_sub_iter) {
+		void *v = state->neigh_sub_iter(state, n, pos);
+		if (v)
+			return n;
+	}
+	n = n->next;
+
+	while (1) {
+		while (n) {
+			if (state->neigh_sub_iter) {
+				void *v = state->neigh_sub_iter(state, n, pos);
+				if (v)
+					return n;
+				goto next;
+			}
+			if (!(state->flags & NEIGH_SEQ_SKIP_NOARP))
+				break;
+
+			if (n->nud_state & ~NUD_NOARP)
+				break;
+		next:
+			n = n->next;
+		}
+
+		if (n)
+			break;
+
+		if (++state->bucket > NEIGH_HASHMASK)
+			break;
+
+		n = tbl->hash_buckets[state->bucket];
+	}
+
+	if (n && pos)
+		--(*pos);
+	return n;
+}
+
+static struct neighbour *neigh_get_idx(struct seq_file *seq, loff_t *pos)
+{
+	struct neighbour *n = neigh_get_first(seq);
+
+	if (n) {
+		while (*pos) {
+			n = neigh_get_next(seq, n, pos);
+			if (!n)
+				break;
+		}
+	}
+	return *pos ? NULL : n;
+}
+
+static struct pneigh_entry *pneigh_get_first(struct seq_file *seq)
+{
+	struct neigh_seq_state *state = seq->private;
+	struct neigh_table *tbl = state->tbl;
+	struct pneigh_entry *pn = NULL;
+	int bucket = state->bucket;
+
+	state->flags |= NEIGH_SEQ_IS_PNEIGH;
+	for (bucket = 0; bucket <= PNEIGH_HASHMASK; bucket++) {
+		pn = tbl->phash_buckets[bucket];
+		if (pn)
+			break;
+	}
+	state->bucket = bucket;
+
+	return pn;
+}
+
+static struct pneigh_entry *pneigh_get_next(struct seq_file *seq,
+					    struct pneigh_entry *pn,
+					    loff_t *pos)
+{
+	struct neigh_seq_state *state = seq->private;
+	struct neigh_table *tbl = state->tbl;
+
+	pn = pn->next;
+	while (!pn) {
+		if (++state->bucket > PNEIGH_HASHMASK)
+			break;
+		pn = tbl->phash_buckets[state->bucket];
+		if (pn)
+			break;
+	}
+
+	if (pn && pos)
+		--(*pos);
+
+	return pn;
+}
+
+static struct pneigh_entry *pneigh_get_idx(struct seq_file *seq, loff_t *pos)
+{
+	struct pneigh_entry *pn = pneigh_get_first(seq);
+
+	if (pn) {
+		while (*pos) {
+			pn = pneigh_get_next(seq, pn, pos);
+			if (!pn)
+				break;
+		}
+	}
+	return *pos ? NULL : pn;
+}
+
+static void *neigh_get_idx_any(struct seq_file *seq, loff_t *pos)
+{
+	struct neigh_seq_state *state = seq->private;
+	void *rc;
+
+	rc = neigh_get_idx(seq, pos);
+	if (!rc && !(state->flags & NEIGH_SEQ_NEIGH_ONLY))
+		rc = pneigh_get_idx(seq, pos);
+
+	return rc;
+}
+
+void *neigh_seq_start(struct seq_file *seq, loff_t *pos, struct neigh_table *tbl, unsigned int neigh_seq_flags)
+{
+	struct neigh_seq_state *state = seq->private;
+	loff_t pos_minus_one;
+
+	state->tbl = tbl;
+	state->bucket = 0;
+	state->flags = (neigh_seq_flags & ~NEIGH_SEQ_IS_PNEIGH);
+
+	read_lock_bh(&tbl->lock);
+
+	pos_minus_one = *pos - 1;
+	return *pos ? neigh_get_idx_any(seq, &pos_minus_one) : SEQ_START_TOKEN;
+}
+EXPORT_SYMBOL(neigh_seq_start);
+
+void *neigh_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct neigh_seq_state *state;
+	void *rc;
+
+	if (v == SEQ_START_TOKEN) {
+		rc = neigh_get_idx(seq, pos);
+		goto out;
+	}
+
+	state = seq->private;
+	if (!(state->flags & NEIGH_SEQ_IS_PNEIGH)) {
+		rc = neigh_get_next(seq, v, NULL);
+		if (rc)
+			goto out;
+		if (!(state->flags & NEIGH_SEQ_NEIGH_ONLY))
+			rc = pneigh_get_first(seq);
+	} else {
+		BUG_ON(state->flags & NEIGH_SEQ_NEIGH_ONLY);
+		rc = pneigh_get_next(seq, v, NULL);
+	}
+out:
+	++(*pos);
+	return rc;
+}
+EXPORT_SYMBOL(neigh_seq_next);
+
+void neigh_seq_stop(struct seq_file *seq, void *v)
+{
+	struct neigh_seq_state *state = seq->private;
+	struct neigh_table *tbl = state->tbl;
+
+	read_unlock_bh(&tbl->lock);
+}
+EXPORT_SYMBOL(neigh_seq_stop);
+
+#endif /* CONFIG_PROC_FS */
+
 #ifdef CONFIG_ARPD
 void neigh_app_ns(struct neighbour *n)
 {
diff -Nru a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
--- a/net/decnet/dn_neigh.c	2004-09-23 22:25:53 -07:00
+++ b/net/decnet/dn_neigh.c	2004-09-23 22:25:53 -07:00
@@ -514,141 +514,66 @@
 	return (*min < priority) ? (min - 6) : NULL;
 }
 
-int dn_neigh_elist(struct net_device *dev, unsigned char *ptr, int n)
-{
-	int t = 0;
-	int i;
-	struct neighbour *neigh;
-	struct dn_neigh *dn;
-	struct neigh_table *tbl = &dn_neigh_table;
-	unsigned char *rs = ptr;
-	struct dn_dev *dn_db = (struct dn_dev *)dev->dn_ptr;
-
-	read_lock_bh(&tbl->lock);
-
-	for(i = 0; i < NEIGH_HASHMASK; i++) {
-		for(neigh = tbl->hash_buckets[i]; neigh != NULL; neigh = neigh->next) {
-			if (neigh->dev != dev)
-				continue;
-			dn = (struct dn_neigh *)neigh;
-			if (!(dn->flags & (DN_NDFLAG_R1|DN_NDFLAG_R2)))
-				continue;
-			if (dn_db->parms.forwarding == 1 && (dn->flags & DN_NDFLAG_R2))
-				continue;
-			if (t == n)
-				rs = dn_find_slot(ptr, n, dn->priority);
-			else
-				t++;
-			if (rs == NULL)
-				continue;
-			dn_dn2eth(rs, dn->addr);
-			rs += 6;
-			*rs = neigh->nud_state & NUD_CONNECTED ? 0x80 : 0x0;
-			*rs |= dn->priority;
-			rs++;
-		}
-	}
-
-	read_unlock_bh(&tbl->lock);
-
-	return t;
-}
-
-
-#ifdef CONFIG_PROC_FS
-
-struct dn_neigh_iter_state {
-	int bucket;
+struct elist_cb_state {
+	struct net_device *dev;
+	unsigned char *ptr;
+	unsigned char *rs;
+	int t, n;
 };
 
-static struct neighbour *neigh_get_first(struct seq_file *seq)
+static void neigh_elist_cb(struct neighbour *neigh, void *_info)
 {
-	struct dn_neigh_iter_state *state = seq->private;
-	struct neighbour *n = NULL;
-
-	for(state->bucket = 0;
-	    state->bucket <= NEIGH_HASHMASK;
-	    ++state->bucket) {
-		n = dn_neigh_table.hash_buckets[state->bucket];
-		if (n)
-			break;
-	}
-
-	return n;
-}
+	struct elist_cb_state *s = _info;
+	struct dn_dev *dn_db;
+	struct dn_neigh *dn;
 
-static struct neighbour *neigh_get_next(struct seq_file *seq,
-					struct neighbour *n)
-{
-	struct dn_neigh_iter_state *state = seq->private;
+	if (neigh->dev != s->dev)
+		return;
 
-	n = n->next;
-try_again:
-	if (n)
-		goto out;
-	if (++state->bucket > NEIGH_HASHMASK)
-		goto out;
-	n = dn_neigh_table.hash_buckets[state->bucket];
-	goto try_again;
-out:
-	return n;
+	dn = (struct dn_neigh *) neigh;
+	if (!(dn->flags & (DN_NDFLAG_R1|DN_NDFLAG_R2)))
+		return;
+
+	dn_db = (struct dn_dev *) s->dev->dn_ptr;
+	if (dn_db->parms.forwarding == 1 && (dn->flags & DN_NDFLAG_R2))
+		return;
+
+	if (s->t == s->n)
+		s->rs = dn_find_slot(s->ptr, s->n, dn->priority);
+	else
+		s->t++;
+	if (s->rs == NULL)
+		return;
+
+	dn_dn2eth(s->rs, dn->addr);
+	s->rs += 6;
+	*(s->rs) = neigh->nud_state & NUD_CONNECTED ? 0x80 : 0x0;
+	*(s->rs) |= dn->priority;
+	s->rs++;
 }
 
-static struct neighbour *neigh_get_idx(struct seq_file *seq, loff_t *pos)
+int dn_neigh_elist(struct net_device *dev, unsigned char *ptr, int n)
 {
-	struct neighbour *n = neigh_get_first(seq);
+	struct elist_cb_state state;
 
-	if (n)
-		while(*pos && (n = neigh_get_next(seq, n)))
-			--*pos;
-	return *pos ? NULL : n;
-}
+	state.dev = dev;
+	state.t = 0;
+	state.n = n;
+	state.ptr = ptr;
+	state.rs = ptr;
 
-static void *dn_neigh_get_idx(struct seq_file *seq, loff_t pos)
-{
-	void *rc;
-	read_lock_bh(&dn_neigh_table.lock);
-	rc = neigh_get_idx(seq, &pos);
-	if (!rc) {
-		read_unlock_bh(&dn_neigh_table.lock);
-	}
-	return rc;
-}
+	neigh_for_each(&dn_neigh_table, neigh_elist_cb, &state);
 
-static void *dn_neigh_seq_start(struct seq_file *seq, loff_t *pos)
-{
-	return *pos ? dn_neigh_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
+	return state.t;
 }
 
-static void *dn_neigh_seq_next(struct seq_file *seq, void *v, loff_t *pos)
-{
-	void *rc;
-
-
-	if (v == SEQ_START_TOKEN) {
-		rc = dn_neigh_get_idx(seq, 0);
-		goto out;
-	}
 
-	rc = neigh_get_next(seq, v);
-	if (rc)
-		goto out;
-	read_unlock_bh(&dn_neigh_table.lock);
-out:
-	++*pos;
-	return rc;
-}
-
-static void dn_neigh_seq_stop(struct seq_file *seq, void *v)
-{
-	if (v && v != SEQ_START_TOKEN)
-		read_unlock_bh(&dn_neigh_table.lock);
-}
+#ifdef CONFIG_PROC_FS
 
 static inline void dn_neigh_format_entry(struct seq_file *seq,
 					 struct neighbour *n)
 {
-	struct dn_neigh *dn = (struct dn_neigh *)n;
+	struct dn_neigh *dn = (struct dn_neigh *) n;
 	char buf[DN_ASCBUF_LEN];
 
 	read_lock(&n->lock);
@@ -675,10 +600,16 @@
 	return 0;
 }
 
+static void *dn_neigh_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	return neigh_seq_start(seq, pos, &dn_neigh_table,
+			       NEIGH_SEQ_NEIGH_ONLY);
+}
+
 static struct seq_operations dn_neigh_seq_ops = {
 	.start = dn_neigh_seq_start,
-	.next  = dn_neigh_seq_next,
-	.stop  = dn_neigh_seq_stop,
+	.next  = neigh_seq_next,
+	.stop  = neigh_seq_stop,
 	.show  = dn_neigh_seq_show,
 };
 
@@ -686,11 +617,12 @@
 {
 	struct seq_file *seq;
 	int rc = -ENOMEM;
-	struct dn_neigh_iter_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
+	struct neigh_seq_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
 
 	if (!s)
 		goto out;
 
+	memset(s, 0, sizeof(*s));
 	rc = seq_open(file, &dn_neigh_seq_ops);
 	if (rc)
 		goto out_kfree;
diff -Nru a/net/ipv4/arp.c b/net/ipv4/arp.c
--- a/net/ipv4/arp.c	2004-09-23 22:25:53 -07:00
+++ b/net/ipv4/arp.c	2004-09-23 22:25:53 -07:00
@@ -1269,162 +1269,10 @@
 }
 #endif /* CONFIG_AX25 */
 
-struct arp_iter_state {
-	int is_pneigh, bucket;
-};
-
-static struct neighbour *neigh_get_first(struct seq_file *seq)
-{
-	struct arp_iter_state* state = seq->private;
-	struct neighbour *n = NULL;
-
-	state->is_pneigh = 0;
-
-	for (state->bucket = 0;
-	     state->bucket <= NEIGH_HASHMASK;
-	     ++state->bucket) {
-		n = arp_tbl.hash_buckets[state->bucket];
-		while (n && !(n->nud_state & ~NUD_NOARP))
-			n = n->next;
-		if (n)
-			break;
-	}
-
-	return n;
-}
-
-static struct neighbour *neigh_get_next(struct seq_file *seq,
-					struct neighbour *n)
-{
-	struct arp_iter_state* state = seq->private;
-
-	do {
-		n = n->next;
-		/* Don't confuse "arp -a" w/ magic entries */
-try_again:
-		;
-	} while (n && !(n->nud_state & ~NUD_NOARP));
-
-	if (n)
-		goto out;
-	if (++state->bucket > NEIGH_HASHMASK)
-		goto out;
-	n = arp_tbl.hash_buckets[state->bucket];
-	goto try_again;
-out:
-	return n;
-}
-
-static struct neighbour *neigh_get_idx(struct seq_file *seq, loff_t *pos)
-{
-	struct neighbour *n = neigh_get_first(seq);
-
-	if (n)
-		while (*pos && (n = neigh_get_next(seq, n)))
-			--*pos;
-	return *pos ? NULL : n;
-}
-
-static struct pneigh_entry *pneigh_get_first(struct seq_file *seq)
-{
-	struct arp_iter_state* state = seq->private;
-	struct pneigh_entry *pn;
-
-	state->is_pneigh = 1;
-
-	for (state->bucket = 0;
-	     state->bucket <= PNEIGH_HASHMASK;
-	     ++state->bucket) {
-		pn = arp_tbl.phash_buckets[state->bucket];
-		if (pn)
-			break;
-	}
-	return pn;
-}
-
-static struct pneigh_entry *pneigh_get_next(struct seq_file *seq,
-					    struct pneigh_entry *pn)
-{
-	struct arp_iter_state* state = seq->private;
-
-	pn = pn->next;
-	while (!pn) {
-		if (++state->bucket > PNEIGH_HASHMASK)
-			break;
-		pn = arp_tbl.phash_buckets[state->bucket];
-	}
-	return pn;
-}
-
-static struct pneigh_entry *pneigh_get_idx(struct seq_file *seq, loff_t pos)
-{
-	struct pneigh_entry *pn = pneigh_get_first(seq);
-
-	if (pn)
-		while (pos && (pn = pneigh_get_next(seq, pn)))
-			--pos;
-	return pos ? NULL : pn;
-}
-
-static void *arp_get_idx(struct seq_file *seq, loff_t pos)
-{
-	void *rc;
-
-	read_lock_bh(&arp_tbl.lock);
-	rc = neigh_get_idx(seq, &pos);
-
-	if (!rc) {
-		read_unlock_bh(&arp_tbl.lock);
-		rc = pneigh_get_idx(seq, pos);
-	}
-	return rc;
-}
-
-static void *arp_seq_start(struct seq_file *seq, loff_t *pos)
-{
-	struct arp_iter_state* state = seq->private;
-
-	state->is_pneigh = 0;
-	state->bucket = 0;
-	return *pos ? arp_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
-}
-
-static void *arp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
-{
-	void *rc;
-	struct arp_iter_state* state;
-
-	if (v == SEQ_START_TOKEN) {
-		rc = arp_get_idx(seq, 0);
-		goto out;
-	}
-
-	state = seq->private;
-	if (!state->is_pneigh) {
-		rc = neigh_get_next(seq, v);
-		if (rc)
-			goto out;
-		read_unlock_bh(&arp_tbl.lock);
-		rc = pneigh_get_first(seq);
-	} else
-		rc = pneigh_get_next(seq, v);
-out:
-	++*pos;
-	return rc;
-}
-
-static void arp_seq_stop(struct seq_file *seq, void *v)
-{
-	struct arp_iter_state* state = seq->private;
-
-	if (!state->is_pneigh && v != SEQ_START_TOKEN)
-		read_unlock_bh(&arp_tbl.lock);
-}
-
 #define HBUFFERLEN 30
 
-static __inline__ void arp_format_neigh_entry(struct seq_file *seq,
-					      struct neighbour *n)
+static void arp_format_neigh_entry(struct seq_file *seq,
+				   struct neighbour *n)
 {
 	char hbuffer[HBUFFERLEN];
 	const char hexbuf[] = "0123456789ABCDEF";
@@ -1455,8 +1303,8 @@
 	read_unlock(&n->lock);
 }
 
-static __inline__ void arp_format_pneigh_entry(struct seq_file *seq,
-					       struct pneigh_entry *n)
+static void arp_format_pneigh_entry(struct seq_file *seq,
+				    struct pneigh_entry *n)
 {
 	struct net_device *dev = n->dev;
 	int hatype = dev ? dev->type : 0;
@@ -1470,13 +1318,13 @@
 
 static int arp_seq_show(struct seq_file *seq, void *v)
 {
-	if (v == SEQ_START_TOKEN)
+	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq, "IP address       HW type     Flags       "
 			      "HW address            Mask     Device\n");
-	else {
-		struct arp_iter_state* state = seq->private;
+	} else {
+		struct neigh_seq_state *state = seq->private;
 
-		if (state->is_pneigh)
+		if (state->flags & NEIGH_SEQ_IS_PNEIGH)
 			arp_format_pneigh_entry(seq, v);
 		else
 			arp_format_neigh_entry(seq, v);
@@ -1485,12 +1333,20 @@
 	return 0;
 }
 
+static void *arp_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	/* Don't want to confuse "arp -a" w/ magic entries,
+	 * so we tell the generic iterator to skip NUD_NOARP.
+	 */
+	return neigh_seq_start(seq, pos, &arp_tbl, NEIGH_SEQ_SKIP_NOARP);
+}
+
 /* ------------------------------------------------------------------------ */
 
 static struct seq_operations arp_seq_ops = {
 	.start  = arp_seq_start,
-	.next   = arp_seq_next,
-	.stop   = arp_seq_stop,
+	.next   = neigh_seq_next,
+	.stop   = neigh_seq_stop,
 	.show   = arp_seq_show,
 };
 
@@ -1498,11 +1354,12 @@
 {
 	struct seq_file *seq;
 	int rc = -ENOMEM;
-	struct arp_iter_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
+	struct neigh_seq_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
        
 	if (!s)
 		goto out;
 
+	memset(s, 0, sizeof(*s));
 	rc = seq_open(file, &arp_seq_ops);
 	if (rc)
 		goto out_kfree;
