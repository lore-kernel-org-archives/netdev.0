From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC net-next 2/4] ipv6 flowlabel: Convert hash list to RCU.
Date: Thu, 31 Jan 2013 04:27:47 +0900
Message-ID: <51097433.2000109@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56140 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751401Ab3A3T1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 14:27:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ipv6.h       |    1 +
 net/ipv6/ip6_flowlabel.c |   94 ++++++++++++++++++++++++++--------------------
 2 files changed, 55 insertions(+), 40 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index dc30b60..1d45716 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -222,6 +222,7 @@ struct ip6_flowlabel {
 	struct in6_addr		dst;
 	struct ipv6_txoptions	*opt;
 	unsigned long		linger;
+	struct rcu_head		rcu;
 	u8			share;
 	union {
 		struct pid *pid;
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 5d767f1..da15601 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -51,25 +51,33 @@
 #define FL_HASH(l)	(ntohl(l)&FL_HASH_MASK)
 
 static atomic_t fl_size = ATOMIC_INIT(0);
-static struct ip6_flowlabel *fl_ht[FL_HASH_MASK+1];
+static struct ip6_flowlabel __rcu *fl_ht[FL_HASH_MASK+1];
 
 static void ip6_fl_gc(unsigned long dummy);
 static DEFINE_TIMER(ip6_fl_gc_timer, ip6_fl_gc, 0, 0);
 
 /* FL hash table lock: it protects only of GC */
 
-static DEFINE_RWLOCK(ip6_fl_lock);
+static DEFINE_SPINLOCK(ip6_fl_lock);
 
 /* Big socket sock */
 
 static DEFINE_RWLOCK(ip6_sk_fl_lock);
 
+#define for_each_fl_rcu(hash, fl)				\
+	for (fl = rcu_dereference(fl_ht[(hash)]);		\
+	     fl != NULL;					\
+	     fl = rcu_dereference(fl->next))
+#define for_each_fl_continue_rcu(fl)				\
+	for (fl = rcu_dereference(fl->next);			\
+	     fl != NULL;					\
+	     fl = rcu_dereference(fl->next))
 
 static inline struct ip6_flowlabel *__fl_lookup(struct net *net, __be32 label)
 {
 	struct ip6_flowlabel *fl;
 
-	for (fl=fl_ht[FL_HASH(label)]; fl; fl = fl->next) {
+	for_each_fl_rcu(FL_HASH(label), fl) {
 		if (fl->label == label && net_eq(fl->fl_net, net))
 			return fl;
 	}
@@ -80,11 +88,11 @@ static struct ip6_flowlabel *fl_lookup(struct net *net, __be32 label)
 {
 	struct ip6_flowlabel *fl;
 
-	read_lock_bh(&ip6_fl_lock);
+	rcu_read_lock_bh();
 	fl = __fl_lookup(net, label);
-	if (fl)
-		atomic_inc(&fl->users);
-	read_unlock_bh(&ip6_fl_lock);
+	if (fl && !atomic_inc_not_zero(&fl->users))
+		fl = NULL;
+	rcu_read_unlock_bh();
 	return fl;
 }
 
@@ -96,13 +104,13 @@ static void fl_free(struct ip6_flowlabel *fl)
 			put_pid(fl->owner.pid);
 		release_net(fl->fl_net);
 		kfree(fl->opt);
+		kfree_rcu(fl, rcu);
 	}
-	kfree(fl);
 }
 
 static void fl_release(struct ip6_flowlabel *fl)
 {
-	write_lock_bh(&ip6_fl_lock);
+	spin_lock_bh(&ip6_fl_lock);
 
 	fl->lastuse = jiffies;
 	if (atomic_dec_and_test(&fl->users)) {
@@ -119,7 +127,7 @@ static void fl_release(struct ip6_flowlabel *fl)
 		    time_after(ip6_fl_gc_timer.expires, ttd))
 			mod_timer(&ip6_fl_gc_timer, ttd);
 	}
-	write_unlock_bh(&ip6_fl_lock);
+	spin_unlock_bh(&ip6_fl_lock);
 }
 
 static void ip6_fl_gc(unsigned long dummy)
@@ -128,12 +136,13 @@ static void ip6_fl_gc(unsigned long dummy)
 	unsigned long now = jiffies;
 	unsigned long sched = 0;
 
-	write_lock(&ip6_fl_lock);
+	spin_lock(&ip6_fl_lock);
 
 	for (i=0; i<=FL_HASH_MASK; i++) {
 		struct ip6_flowlabel *fl, **flp;
 		flp = &fl_ht[i];
-		while ((fl=*flp) != NULL) {
+		while ((fl = rcu_dereference_protected(*flp,
+						       lockdep_is_held(&ip6_fl_lock))) != NULL) {
 			if (atomic_read(&fl->users) == 0) {
 				unsigned long ttd = fl->lastuse + fl->linger;
 				if (time_after(ttd, fl->expires))
@@ -156,18 +165,19 @@ static void ip6_fl_gc(unsigned long dummy)
 	if (sched) {
 		mod_timer(&ip6_fl_gc_timer, sched);
 	}
-	write_unlock(&ip6_fl_lock);
+	spin_unlock(&ip6_fl_lock);
 }
 
 static void __net_exit ip6_fl_purge(struct net *net)
 {
 	int i;
 
-	write_lock(&ip6_fl_lock);
+	spin_lock(&ip6_fl_lock);
 	for (i = 0; i <= FL_HASH_MASK; i++) {
 		struct ip6_flowlabel *fl, **flp;
 		flp = &fl_ht[i];
-		while ((fl = *flp) != NULL) {
+		while ((fl = rcu_dereference_protected(*flp,
+						       lockdep_is_held(&ip6_fl_lock))) != NULL) {
 			if (net_eq(fl->fl_net, net) &&
 			    atomic_read(&fl->users) == 0) {
 				*flp = fl->next;
@@ -178,7 +188,7 @@ static void __net_exit ip6_fl_purge(struct net *net)
 			flp = &fl->next;
 		}
 	}
-	write_unlock(&ip6_fl_lock);
+	spin_unlock(&ip6_fl_lock);
 }
 
 static struct ip6_flowlabel *fl_intern(struct net *net,
@@ -188,7 +198,7 @@ static struct ip6_flowlabel *fl_intern(struct net *net,
 
 	fl->label = label & IPV6_FLOWLABEL_MASK;
 
-	write_lock_bh(&ip6_fl_lock);
+	spin_lock_bh(&ip6_fl_lock);
 	if (label == 0) {
 		for (;;) {
 			fl->label = htonl(net_random())&IPV6_FLOWLABEL_MASK;
@@ -210,16 +220,16 @@ static struct ip6_flowlabel *fl_intern(struct net *net,
 		lfl = __fl_lookup(net, fl->label);
 		if (lfl != NULL) {
 			atomic_inc(&lfl->users);
-			write_unlock_bh(&ip6_fl_lock);
+			spin_unlock_bh(&ip6_fl_lock);
 			return lfl;
 		}
 	}
 
 	fl->lastuse = jiffies;
 	fl->next = fl_ht[FL_HASH(fl->label)];
-	fl_ht[FL_HASH(fl->label)] = fl;
+	rcu_assign_pointer(fl_ht[FL_HASH(fl->label)], fl);
 	atomic_inc(&fl_size);
-	write_unlock_bh(&ip6_fl_lock);
+	spin_unlock_bh(&ip6_fl_lock);
 	return NULL;
 }
 
@@ -650,13 +660,13 @@ static struct ip6_flowlabel *ip6fl_get_first(struct seq_file *seq)
 	struct net *net = seq_file_net(seq);
 
 	for (state->bucket = 0; state->bucket <= FL_HASH_MASK; ++state->bucket) {
-		fl = fl_ht[state->bucket];
-
-		while (fl && !net_eq(fl->fl_net, net))
-			fl = fl->next;
-		if (fl)
-			break;
+		for_each_fl_rcu(state->bucket, fl) {
+			if (net_eq(fl->fl_net, net))
+				goto out;
+		}
 	}
+	fl = NULL;
+out:
 	return fl;
 }
 
@@ -665,18 +675,22 @@ static struct ip6_flowlabel *ip6fl_get_next(struct seq_file *seq, struct ip6_flo
 	struct ip6fl_iter_state *state = ip6fl_seq_private(seq);
 	struct net *net = seq_file_net(seq);
 
-	fl = fl->next;
+	for_each_fl_continue_rcu(fl) {
+		if (net_eq(fl->fl_net, net))
+			goto out;
+	}
+
 try_again:
-	while (fl && !net_eq(fl->fl_net, net))
-		fl = fl->next;
-
-	while (!fl) {
-		if (++state->bucket <= FL_HASH_MASK) {
-			fl = fl_ht[state->bucket];
-			goto try_again;
-		} else
-			break;
+	if (++state->bucket <= FL_HASH_MASK) {
+		for_each_fl_rcu(state->bucket, fl) {
+			if (net_eq(fl->fl_net, net))
+				goto out;
+		}
+		goto try_again;
 	}
+	fl = NULL;
+
+out:
 	return fl;
 }
 
@@ -690,9 +704,9 @@ static struct ip6_flowlabel *ip6fl_get_idx(struct seq_file *seq, loff_t pos)
 }
 
 static void *ip6fl_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(ip6_fl_lock)
+	__acquires(RCU)
 {
-	read_lock_bh(&ip6_fl_lock);
+	rcu_read_lock_bh();
 	return *pos ? ip6fl_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 }
 
@@ -709,9 +723,9 @@ static void *ip6fl_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void ip6fl_seq_stop(struct seq_file *seq, void *v)
-	__releases(ip6_fl_lock)
+	__releases(RCU)
 {
-	read_unlock_bh(&ip6_fl_lock);
+	rcu_read_unlock_bh();
 }
 
 static int ip6fl_seq_show(struct seq_file *seq, void *v)
-- 
1.7.9.5
