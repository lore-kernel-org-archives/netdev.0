From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/09: ebtables: split copy_everything_to_user into two functions
Date: Thu, 18 Feb 2010 19:21:05 +0100 (MET)
Message-ID: <20100218182105.21826.13597.sendpatchset@x2.localnet>
References: <20100218182103.21826.17908.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38161 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193Ab0BRSVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 13:21:08 -0500
In-Reply-To: <20100218182103.21826.17908.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 837395aa863142be7c38be0ca780aef21b12b49f
Author: Florian Westphal <fw@strlen.de>
Date:   Sun Feb 7 02:11:34 2010 +0100

    netfilter: ebtables: split copy_everything_to_user into two functions
    
    once CONFIG_COMPAT support is added to ebtables, the new
    copy_counters_to_user function can be called instead of duplicating
    code.
    
    Also remove last use of MEMPRINT, as requested by Bart De Schuymer.
    
    Signed-off-by: Florian Westphal <fw@strlen.de>

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index a707dbd..46030dc 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -33,11 +33,6 @@
 #define BUGPRINT(format, args...) printk("kernel msg: ebtables bug: please "\
 					 "report to author: "format, ## args)
 /* #define BUGPRINT(format, args...) */
-#define MEMPRINT(format, args...) printk("kernel msg: ebtables "\
-					 ": out of memory: "format, ## args)
-/* #define MEMPRINT(format, args...) */
-
-
 
 /*
  * Each cpu has its own set of counters, so there is no need for write_lock in
@@ -1263,10 +1258,8 @@ static int update_counters(struct net *net, const void __user *user,
 	if (hlp.num_counters == 0)
 		return -EINVAL;
 
-	if (!(tmp = vmalloc(hlp.num_counters * sizeof(*tmp)))) {
-		MEMPRINT("Update_counters && nomemory\n");
+	if (!(tmp = vmalloc(hlp.num_counters * sizeof(*tmp))))
 		return -ENOMEM;
-	}
 
 	t = find_table_lock(net, hlp.name, &ret, &ebt_mutex);
 	if (!t)
@@ -1345,14 +1338,46 @@ ebt_make_names(struct ebt_entry *e, const char *base, char __user *ubase)
 	return 0;
 }
 
+static int copy_counters_to_user(struct ebt_table *t,
+				  const struct ebt_counter *oldcounters,
+				  void __user *user, unsigned int num_counters,
+				  unsigned int nentries)
+{
+	struct ebt_counter *counterstmp;
+	int ret = 0;
+
+	/* userspace might not need the counters */
+	if (num_counters == 0)
+		return 0;
+
+	if (num_counters != nentries) {
+		BUGPRINT("Num_counters wrong\n");
+		return -EINVAL;
+	}
+
+	counterstmp = vmalloc(nentries * sizeof(*counterstmp));
+	if (!counterstmp)
+		return -ENOMEM;
+
+	write_lock_bh(&t->lock);
+	get_counters(oldcounters, counterstmp, nentries);
+	write_unlock_bh(&t->lock);
+
+	if (copy_to_user(user, counterstmp,
+	   nentries * sizeof(struct ebt_counter)))
+		ret = -EFAULT;
+	vfree(counterstmp);
+	return ret;
+}
+
 /* called with ebt_mutex locked */
 static int copy_everything_to_user(struct ebt_table *t, void __user *user,
     const int *len, int cmd)
 {
 	struct ebt_replace tmp;
-	struct ebt_counter *counterstmp;
 	const struct ebt_counter *oldcounters;
 	unsigned int entries_size, nentries;
+	int ret;
 	char *entries;
 
 	if (cmd == EBT_SO_GET_ENTRIES) {
@@ -1388,29 +1413,10 @@ static int copy_everything_to_user(struct ebt_table *t, void __user *user,
 		return -EINVAL;
 	}
 
-	/* userspace might not need the counters */
-	if (tmp.num_counters) {
-		if (tmp.num_counters != nentries) {
-			BUGPRINT("Num_counters wrong\n");
-			return -EINVAL;
-		}
-		counterstmp = vmalloc(nentries * sizeof(*counterstmp));
-		if (!counterstmp) {
-			MEMPRINT("Couldn't copy counters, out of memory\n");
-			return -ENOMEM;
-		}
-		write_lock_bh(&t->lock);
-		get_counters(oldcounters, counterstmp, nentries);
-		write_unlock_bh(&t->lock);
-
-		if (copy_to_user(tmp.counters, counterstmp,
-		   nentries * sizeof(struct ebt_counter))) {
-			BUGPRINT("Couldn't copy counters to userspace\n");
-			vfree(counterstmp);
-			return -EFAULT;
-		}
-		vfree(counterstmp);
-	}
+	ret = copy_counters_to_user(t, oldcounters, tmp.counters,
+					tmp.num_counters, nentries);
+	if (ret)
+		return ret;
 
 	if (copy_to_user(tmp.entries, entries, entries_size)) {
 		BUGPRINT("Couldn't copy entries to userspace\n");
