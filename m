From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/09: ebtables: split update_counters into two functions
Date: Thu, 18 Feb 2010 19:21:07 +0100 (MET)
Message-ID: <20100218182107.21826.91844.sendpatchset@x2.localnet>
References: <20100218182103.21826.17908.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100218182103.21826.17908.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 49facff9f92508413f3da598f86aaf6c1121ff27
Author: Florian Westphal <fw@strlen.de>
Date:   Sun Feb 7 02:48:47 2010 +0100

    netfilter: ebtables: split update_counters into two functions
    
    allows to call do_update_counters() from upcoming CONFIG_COMPAT
    code instead of copy&pasting the same code.
    
    Signed-off-by: Florian Westphal <fw@strlen.de>

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 46030dc..76b99d3 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1242,38 +1242,33 @@ void ebt_unregister_table(struct net *net, struct ebt_table *table)
 }
 
 /* userspace just supplied us with counters */
-static int update_counters(struct net *net, const void __user *user,
-			   unsigned int len)
+static int do_update_counters(struct net *net, const char *name,
+				struct ebt_counter __user *counters,
+				unsigned int num_counters,
+				const void __user *user, unsigned int len)
 {
 	int i, ret;
 	struct ebt_counter *tmp;
-	struct ebt_replace hlp;
 	struct ebt_table *t;
 
-	if (copy_from_user(&hlp, user, sizeof(hlp)))
-		return -EFAULT;
-
-	if (len != sizeof(hlp) + hlp.num_counters * sizeof(struct ebt_counter))
-		return -EINVAL;
-	if (hlp.num_counters == 0)
+	if (num_counters == 0)
 		return -EINVAL;
 
-	if (!(tmp = vmalloc(hlp.num_counters * sizeof(*tmp))))
+	tmp = vmalloc(num_counters * sizeof(*tmp));
+	if (!tmp)
 		return -ENOMEM;
 
-	t = find_table_lock(net, hlp.name, &ret, &ebt_mutex);
+	t = find_table_lock(net, name, &ret, &ebt_mutex);
 	if (!t)
 		goto free_tmp;
 
-	if (hlp.num_counters != t->private->nentries) {
+	if (num_counters != t->private->nentries) {
 		BUGPRINT("Wrong nr of counters\n");
 		ret = -EINVAL;
 		goto unlock_mutex;
 	}
 
-	if ( copy_from_user(tmp, hlp.counters,
-	   hlp.num_counters * sizeof(struct ebt_counter)) ) {
-		BUGPRINT("Updata_counters && !cfu\n");
+	if (copy_from_user(tmp, counters, num_counters * sizeof(*counters))) {
 		ret = -EFAULT;
 		goto unlock_mutex;
 	}
@@ -1282,7 +1277,7 @@ static int update_counters(struct net *net, const void __user *user,
 	write_lock_bh(&t->lock);
 
 	/* we add to the counters of the first cpu */
-	for (i = 0; i < hlp.num_counters; i++) {
+	for (i = 0; i < num_counters; i++) {
 		t->private->counters[i].pcnt += tmp[i].pcnt;
 		t->private->counters[i].bcnt += tmp[i].bcnt;
 	}
@@ -1296,6 +1291,21 @@ free_tmp:
 	return ret;
 }
 
+static int update_counters(struct net *net, const void __user *user,
+			    unsigned int len)
+{
+	struct ebt_replace hlp;
+
+	if (copy_from_user(&hlp, user, sizeof(hlp)))
+		return -EFAULT;
+
+	if (len != sizeof(hlp) + hlp.num_counters * sizeof(struct ebt_counter))
+		return -EINVAL;
+
+	return do_update_counters(net, hlp.name, hlp.counters,
+				hlp.num_counters, user, len);
+}
+
 static inline int ebt_make_matchname(const struct ebt_entry_match *m,
     const char *base, char __user *ubase)
 {
