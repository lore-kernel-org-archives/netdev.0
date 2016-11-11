From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH] netfilter: x_tables: simplify IS_ERR_OR_NULL to NULL test
Date: Fri, 11 Nov 2016 13:32:38 +0100
Message-ID: <1478867558-21650-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, coreteam@netfilter.org,
        netfilter-devel@vger.kernel.org,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        James Morris <jmorris@namei.org>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Patrick McHardy <kaber@trash.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        christophe.jaillet@wanadoo.fr
To: Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit 7926dbfa4bc1 ("netfilter: don't use
mutex_lock_interruptible()"), the function xt_find_table_lock can only
return NULL on an error.  Simplify the call sites and update the
comment before the function.


The semantic patch that change the code is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression t,e;
@@

t = \(xt_find_table_lock(...)\|
      try_then_request_module(xt_find_table_lock(...),...)\)
... when != t=e
- ! IS_ERR_OR_NULL(t)
+ t

@@
expression t,e;
@@

t = \(xt_find_table_lock(...)\|
      try_then_request_module(xt_find_table_lock(...),...)\)
... when != t=e
- IS_ERR_OR_NULL(t)
+ !t

@@
expression t,e,e1;
@@

t = \(xt_find_table_lock(...)\|
      try_then_request_module(xt_find_table_lock(...),...)\)
... when != t=e
?- t ? PTR_ERR(t) : e1
+ e1
... when any

// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 net/ipv4/netfilter/arp_tables.c |   20 ++++++++++----------
 net/ipv4/netfilter/ip_tables.c  |   20 ++++++++++----------
 net/ipv6/netfilter/ip6_tables.c |   20 ++++++++++----------
 net/netfilter/x_tables.c        |    2 +-
 4 files changed, 31 insertions(+), 31 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index e76ab23..39004da 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -805,7 +805,7 @@ static int get_info(struct net *net, void __user *user,
 #endif
 	t = try_then_request_module(xt_find_table_lock(net, NFPROTO_ARP, name),
 				    "arptable_%s", name);
-	if (!IS_ERR_OR_NULL(t)) {
+	if (t) {
 		struct arpt_getinfo info;
 		const struct xt_table_info *private = t->private;
 #ifdef CONFIG_COMPAT
@@ -834,7 +834,7 @@ static int get_info(struct net *net, void __user *user,
 		xt_table_unlock(t);
 		module_put(t->me);
 	} else
-		ret = t ? PTR_ERR(t) : -ENOENT;
+		ret = -ENOENT;
 #ifdef CONFIG_COMPAT
 	if (compat)
 		xt_compat_unlock(NFPROTO_ARP);
@@ -859,7 +859,7 @@ static int get_entries(struct net *net, struct arpt_get_entries __user *uptr,
 	get.name[sizeof(get.name) - 1] = '\0';
 
 	t = xt_find_table_lock(net, NFPROTO_ARP, get.name);
-	if (!IS_ERR_OR_NULL(t)) {
+	if (t) {
 		const struct xt_table_info *private = t->private;
 
 		if (get.size == private->size)
@@ -871,7 +871,7 @@ static int get_entries(struct net *net, struct arpt_get_entries __user *uptr,
 		module_put(t->me);
 		xt_table_unlock(t);
 	} else
-		ret = t ? PTR_ERR(t) : -ENOENT;
+		ret = -ENOENT;
 
 	return ret;
 }
@@ -898,8 +898,8 @@ static int __do_replace(struct net *net, const char *name,
 
 	t = try_then_request_module(xt_find_table_lock(net, NFPROTO_ARP, name),
 				    "arptable_%s", name);
-	if (IS_ERR_OR_NULL(t)) {
-		ret = t ? PTR_ERR(t) : -ENOENT;
+	if (!t) {
+		ret = -ENOENT;
 		goto free_newinfo_counters_untrans;
 	}
 
@@ -1014,8 +1014,8 @@ static int do_add_counters(struct net *net, const void __user *user,
 		return PTR_ERR(paddc);
 
 	t = xt_find_table_lock(net, NFPROTO_ARP, tmp.name);
-	if (IS_ERR_OR_NULL(t)) {
-		ret = t ? PTR_ERR(t) : -ENOENT;
+	if (!t) {
+		ret = -ENOENT;
 		goto free;
 	}
 
@@ -1404,7 +1404,7 @@ static int compat_get_entries(struct net *net,
 
 	xt_compat_lock(NFPROTO_ARP);
 	t = xt_find_table_lock(net, NFPROTO_ARP, get.name);
-	if (!IS_ERR_OR_NULL(t)) {
+	if (t) {
 		const struct xt_table_info *private = t->private;
 		struct xt_table_info info;
 
@@ -1419,7 +1419,7 @@ static int compat_get_entries(struct net *net,
 		module_put(t->me);
 		xt_table_unlock(t);
 	} else
-		ret = t ? PTR_ERR(t) : -ENOENT;
+		ret = -ENOENT;
 
 	xt_compat_unlock(NFPROTO_ARP);
 	return ret;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index de4fa03..46815c8 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -973,7 +973,7 @@ static int get_info(struct net *net, void __user *user,
 #endif
 	t = try_then_request_module(xt_find_table_lock(net, AF_INET, name),
 				    "iptable_%s", name);
-	if (!IS_ERR_OR_NULL(t)) {
+	if (t) {
 		struct ipt_getinfo info;
 		const struct xt_table_info *private = t->private;
 #ifdef CONFIG_COMPAT
@@ -1003,7 +1003,7 @@ static int get_info(struct net *net, void __user *user,
 		xt_table_unlock(t);
 		module_put(t->me);
 	} else
-		ret = t ? PTR_ERR(t) : -ENOENT;
+		ret = -ENOENT;
 #ifdef CONFIG_COMPAT
 	if (compat)
 		xt_compat_unlock(AF_INET);
@@ -1028,7 +1028,7 @@ static int get_info(struct net *net, void __user *user,
 	get.name[sizeof(get.name) - 1] = '\0';
 
 	t = xt_find_table_lock(net, AF_INET, get.name);
-	if (!IS_ERR_OR_NULL(t)) {
+	if (t) {
 		const struct xt_table_info *private = t->private;
 		if (get.size == private->size)
 			ret = copy_entries_to_user(private->size,
@@ -1039,7 +1039,7 @@ static int get_info(struct net *net, void __user *user,
 		module_put(t->me);
 		xt_table_unlock(t);
 	} else
-		ret = t ? PTR_ERR(t) : -ENOENT;
+		ret = -ENOENT;
 
 	return ret;
 }
@@ -1064,8 +1064,8 @@ static int get_info(struct net *net, void __user *user,
 
 	t = try_then_request_module(xt_find_table_lock(net, AF_INET, name),
 				    "iptable_%s", name);
-	if (IS_ERR_OR_NULL(t)) {
-		ret = t ? PTR_ERR(t) : -ENOENT;
+	if (!t) {
+		ret = -ENOENT;
 		goto free_newinfo_counters_untrans;
 	}
 
@@ -1180,8 +1180,8 @@ static int get_info(struct net *net, void __user *user,
 		return PTR_ERR(paddc);
 
 	t = xt_find_table_lock(net, AF_INET, tmp.name);
-	if (IS_ERR_OR_NULL(t)) {
-		ret = t ? PTR_ERR(t) : -ENOENT;
+	if (!t) {
+		ret = -ENOENT;
 		goto free;
 	}
 
@@ -1626,7 +1626,7 @@ struct compat_ipt_get_entries {
 
 	xt_compat_lock(AF_INET);
 	t = xt_find_table_lock(net, AF_INET, get.name);
-	if (!IS_ERR_OR_NULL(t)) {
+	if (t) {
 		const struct xt_table_info *private = t->private;
 		struct xt_table_info info;
 		ret = compat_table_info(private, &info);
@@ -1640,7 +1640,7 @@ struct compat_ipt_get_entries {
 		module_put(t->me);
 		xt_table_unlock(t);
 	} else
-		ret = t ? PTR_ERR(t) : -ENOENT;
+		ret = -ENOENT;
 
 	xt_compat_unlock(AF_INET);
 	return ret;
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 7eac01d..6ff42b8 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1003,7 +1003,7 @@ static int get_info(struct net *net, void __user *user,
 #endif
 	t = try_then_request_module(xt_find_table_lock(net, AF_INET6, name),
 				    "ip6table_%s", name);
-	if (!IS_ERR_OR_NULL(t)) {
+	if (t) {
 		struct ip6t_getinfo info;
 		const struct xt_table_info *private = t->private;
 #ifdef CONFIG_COMPAT
@@ -1033,7 +1033,7 @@ static int get_info(struct net *net, void __user *user,
 		xt_table_unlock(t);
 		module_put(t->me);
 	} else
-		ret = t ? PTR_ERR(t) : -ENOENT;
+		ret = -ENOENT;
 #ifdef CONFIG_COMPAT
 	if (compat)
 		xt_compat_unlock(AF_INET6);
@@ -1059,7 +1059,7 @@ static int get_info(struct net *net, void __user *user,
 	get.name[sizeof(get.name) - 1] = '\0';
 
 	t = xt_find_table_lock(net, AF_INET6, get.name);
-	if (!IS_ERR_OR_NULL(t)) {
+	if (t) {
 		struct xt_table_info *private = t->private;
 		if (get.size == private->size)
 			ret = copy_entries_to_user(private->size,
@@ -1070,7 +1070,7 @@ static int get_info(struct net *net, void __user *user,
 		module_put(t->me);
 		xt_table_unlock(t);
 	} else
-		ret = t ? PTR_ERR(t) : -ENOENT;
+		ret = -ENOENT;
 
 	return ret;
 }
@@ -1095,8 +1095,8 @@ static int get_info(struct net *net, void __user *user,
 
 	t = try_then_request_module(xt_find_table_lock(net, AF_INET6, name),
 				    "ip6table_%s", name);
-	if (IS_ERR_OR_NULL(t)) {
-		ret = t ? PTR_ERR(t) : -ENOENT;
+	if (!t) {
+		ret = -ENOENT;
 		goto free_newinfo_counters_untrans;
 	}
 
@@ -1210,8 +1210,8 @@ static int get_info(struct net *net, void __user *user,
 	if (IS_ERR(paddc))
 		return PTR_ERR(paddc);
 	t = xt_find_table_lock(net, AF_INET6, tmp.name);
-	if (IS_ERR_OR_NULL(t)) {
-		ret = t ? PTR_ERR(t) : -ENOENT;
+	if (!t) {
+		ret = -ENOENT;
 		goto free;
 	}
 
@@ -1647,7 +1647,7 @@ struct compat_ip6t_get_entries {
 
 	xt_compat_lock(AF_INET6);
 	t = xt_find_table_lock(net, AF_INET6, get.name);
-	if (!IS_ERR_OR_NULL(t)) {
+	if (t) {
 		const struct xt_table_info *private = t->private;
 		struct xt_table_info info;
 		ret = compat_table_info(private, &info);
@@ -1661,7 +1661,7 @@ struct compat_ip6t_get_entries {
 		module_put(t->me);
 		xt_table_unlock(t);
 	} else
-		ret = t ? PTR_ERR(t) : -ENOENT;
+		ret = -ENOENT;
 
 	xt_compat_unlock(AF_INET6);
 	return ret;
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index fc49774..ad818e5 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -982,7 +982,7 @@ void xt_free_table_info(struct xt_table_info *info)
 }
 EXPORT_SYMBOL(xt_free_table_info);
 
-/* Find table by name, grabs mutex & ref.  Returns ERR_PTR() on error. */
+/* Find table by name, grabs mutex & ref.  Returns NULL on error. */
 struct xt_table *xt_find_table_lock(struct net *net, u_int8_t af,
 				    const char *name)
 {
