From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 04/62: xtables: obtain random bytes earlier, in checkentry
Date: Tue, 16 Feb 2010 15:55:24 +0100 (MET)
Message-ID: <20100216145522.2796.77588.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51947 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755606Ab0BPOz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:55:26 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 294188ae32f984a072c64c959354b2f6f52f80a7
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Mon Jan 4 16:28:38 2010 +0100

    netfilter: xtables: obtain random bytes earlier, in checkentry
    
    We can initialize the random hash bytes on checkentry. This is
    preferable since it is outside the hot path.
    
    Reference: http://bugzilla.netfilter.org/show_bug.cgi?id=621
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 38f03f7..8103bef 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -40,15 +40,11 @@ struct xt_connlimit_data {
 	spinlock_t lock;
 };
 
-static u_int32_t connlimit_rnd;
-static bool connlimit_rnd_inited;
+static u_int32_t connlimit_rnd __read_mostly;
+static bool connlimit_rnd_inited __read_mostly;
 
 static inline unsigned int connlimit_iphash(__be32 addr)
 {
-	if (unlikely(!connlimit_rnd_inited)) {
-		get_random_bytes(&connlimit_rnd, sizeof(connlimit_rnd));
-		connlimit_rnd_inited = true;
-	}
 	return jhash_1word((__force __u32)addr, connlimit_rnd) & 0xFF;
 }
 
@@ -59,11 +55,6 @@ connlimit_iphash6(const union nf_inet_addr *addr,
 	union nf_inet_addr res;
 	unsigned int i;
 
-	if (unlikely(!connlimit_rnd_inited)) {
-		get_random_bytes(&connlimit_rnd, sizeof(connlimit_rnd));
-		connlimit_rnd_inited = true;
-	}
-
 	for (i = 0; i < ARRAY_SIZE(addr->ip6); ++i)
 		res.ip6[i] = addr->ip6[i] & mask->ip6[i];
 
@@ -226,6 +217,10 @@ static bool connlimit_mt_check(const struct xt_mtchk_param *par)
 	struct xt_connlimit_info *info = par->matchinfo;
 	unsigned int i;
 
+	if (unlikely(!connlimit_rnd_inited)) {
+		get_random_bytes(&connlimit_rnd, sizeof(connlimit_rnd));
+		connlimit_rnd_inited = true;
+	}
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
 		printk(KERN_WARNING "cannot load conntrack support for "
 		       "address family %u\n", par->family);
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index fc70a49..768d01f 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -90,25 +90,17 @@ static struct proc_dir_entry *recent_proc_dir;
 static const struct file_operations recent_old_fops, recent_mt_fops;
 #endif
 
-static u_int32_t hash_rnd;
-static bool hash_rnd_initted;
+static u_int32_t hash_rnd __read_mostly;
+static bool hash_rnd_inited __read_mostly;
 
-static unsigned int recent_entry_hash4(const union nf_inet_addr *addr)
+static inline unsigned int recent_entry_hash4(const union nf_inet_addr *addr)
 {
-	if (!hash_rnd_initted) {
-		get_random_bytes(&hash_rnd, sizeof(hash_rnd));
-		hash_rnd_initted = true;
-	}
 	return jhash_1word((__force u32)addr->ip, hash_rnd) &
 	       (ip_list_hash_size - 1);
 }
 
-static unsigned int recent_entry_hash6(const union nf_inet_addr *addr)
+static inline unsigned int recent_entry_hash6(const union nf_inet_addr *addr)
 {
-	if (!hash_rnd_initted) {
-		get_random_bytes(&hash_rnd, sizeof(hash_rnd));
-		hash_rnd_initted = true;
-	}
 	return jhash2((u32 *)addr->ip6, ARRAY_SIZE(addr->ip6), hash_rnd) &
 	       (ip_list_hash_size - 1);
 }
@@ -287,6 +279,10 @@ static bool recent_mt_check(const struct xt_mtchk_param *par)
 	unsigned i;
 	bool ret = false;
 
+	if (unlikely(!hash_rnd_inited)) {
+		get_random_bytes(&hash_rnd, sizeof(hash_rnd));
+		hash_rnd_inited = true;
+	}
 	if (hweight8(info->check_set &
 		     (XT_RECENT_SET | XT_RECENT_REMOVE |
 		      XT_RECENT_CHECK | XT_RECENT_UPDATE)) != 1)
