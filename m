From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/23] netfilter: x_tables: introduce and use xt_copy_counters_from_user
Date: Fri, 22 Apr 2016 15:39:48 +0200
Message-ID: <1461332394-3994-18-git-send-email-pablo@netfilter.org>
References: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45279 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753923AbcDVNkY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 09:40:24 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 300C26DFCA
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:23 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 0EDBB9D0FF
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:23 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id C0E6B9D11C
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:16 +0200 (CEST)
In-Reply-To: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

The three variants use same copy&pasted code, condense this into a
helper and use that.

Make sure info.name is 0-terminated.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/x_tables.h |  3 ++
 net/ipv4/netfilter/arp_tables.c    | 48 +++----------------------
 net/ipv4/netfilter/ip_tables.c     | 48 +++----------------------
 net/ipv6/netfilter/ip6_tables.c    | 49 +++----------------------
 net/netfilter/x_tables.c           | 74 ++++++++++++++++++++++++++++++++++++++
 5 files changed, 92 insertions(+), 130 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index e2da9b9..4dd9306 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -251,6 +251,9 @@ int xt_check_match(struct xt_mtchk_param *, unsigned int size, u_int8_t proto,
 int xt_check_target(struct xt_tgchk_param *, unsigned int size, u_int8_t proto,
 		    bool inv_proto);
 
+void *xt_copy_counters_from_user(const void __user *user, unsigned int len,
+				 struct xt_counters_info *info, bool compat);
+
 struct xt_table *xt_register_table(struct net *net,
 				   const struct xt_table *table,
 				   struct xt_table_info *bootstrap,
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 8cefb7a..60f5161 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -1123,55 +1123,17 @@ static int do_add_counters(struct net *net, const void __user *user,
 	unsigned int i;
 	struct xt_counters_info tmp;
 	struct xt_counters *paddc;
-	unsigned int num_counters;
-	const char *name;
-	int size;
-	void *ptmp;
 	struct xt_table *t;
 	const struct xt_table_info *private;
 	int ret = 0;
 	struct arpt_entry *iter;
 	unsigned int addend;
-#ifdef CONFIG_COMPAT
-	struct compat_xt_counters_info compat_tmp;
-
-	if (compat) {
-		ptmp = &compat_tmp;
-		size = sizeof(struct compat_xt_counters_info);
-	} else
-#endif
-	{
-		ptmp = &tmp;
-		size = sizeof(struct xt_counters_info);
-	}
 
-	if (copy_from_user(ptmp, user, size) != 0)
-		return -EFAULT;
-
-#ifdef CONFIG_COMPAT
-	if (compat) {
-		num_counters = compat_tmp.num_counters;
-		name = compat_tmp.name;
-	} else
-#endif
-	{
-		num_counters = tmp.num_counters;
-		name = tmp.name;
-	}
-
-	if (len != size + num_counters * sizeof(struct xt_counters))
-		return -EINVAL;
-
-	paddc = vmalloc(len - size);
-	if (!paddc)
-		return -ENOMEM;
-
-	if (copy_from_user(paddc, user + size, len - size) != 0) {
-		ret = -EFAULT;
-		goto free;
-	}
+	paddc = xt_copy_counters_from_user(user, len, &tmp, compat);
+	if (IS_ERR(paddc))
+		return PTR_ERR(paddc);
 
-	t = xt_find_table_lock(net, NFPROTO_ARP, name);
+	t = xt_find_table_lock(net, NFPROTO_ARP, tmp.name);
 	if (IS_ERR_OR_NULL(t)) {
 		ret = t ? PTR_ERR(t) : -ENOENT;
 		goto free;
@@ -1179,7 +1141,7 @@ static int do_add_counters(struct net *net, const void __user *user,
 
 	local_bh_disable();
 	private = t->private;
-	if (private->number != num_counters) {
+	if (private->number != tmp.num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
 	}
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 9340ce0..735d1ee 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1307,55 +1307,17 @@ do_add_counters(struct net *net, const void __user *user,
 	unsigned int i;
 	struct xt_counters_info tmp;
 	struct xt_counters *paddc;
-	unsigned int num_counters;
-	const char *name;
-	int size;
-	void *ptmp;
 	struct xt_table *t;
 	const struct xt_table_info *private;
 	int ret = 0;
 	struct ipt_entry *iter;
 	unsigned int addend;
-#ifdef CONFIG_COMPAT
-	struct compat_xt_counters_info compat_tmp;
-
-	if (compat) {
-		ptmp = &compat_tmp;
-		size = sizeof(struct compat_xt_counters_info);
-	} else
-#endif
-	{
-		ptmp = &tmp;
-		size = sizeof(struct xt_counters_info);
-	}
 
-	if (copy_from_user(ptmp, user, size) != 0)
-		return -EFAULT;
-
-#ifdef CONFIG_COMPAT
-	if (compat) {
-		num_counters = compat_tmp.num_counters;
-		name = compat_tmp.name;
-	} else
-#endif
-	{
-		num_counters = tmp.num_counters;
-		name = tmp.name;
-	}
-
-	if (len != size + num_counters * sizeof(struct xt_counters))
-		return -EINVAL;
-
-	paddc = vmalloc(len - size);
-	if (!paddc)
-		return -ENOMEM;
-
-	if (copy_from_user(paddc, user + size, len - size) != 0) {
-		ret = -EFAULT;
-		goto free;
-	}
+	paddc = xt_copy_counters_from_user(user, len, &tmp, compat);
+	if (IS_ERR(paddc))
+		return PTR_ERR(paddc);
 
-	t = xt_find_table_lock(net, AF_INET, name);
+	t = xt_find_table_lock(net, AF_INET, tmp.name);
 	if (IS_ERR_OR_NULL(t)) {
 		ret = t ? PTR_ERR(t) : -ENOENT;
 		goto free;
@@ -1363,7 +1325,7 @@ do_add_counters(struct net *net, const void __user *user,
 
 	local_bh_disable();
 	private = t->private;
-	if (private->number != num_counters) {
+	if (private->number != tmp.num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
 	}
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index aa01085..73e606c 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1319,55 +1319,16 @@ do_add_counters(struct net *net, const void __user *user, unsigned int len,
 	unsigned int i;
 	struct xt_counters_info tmp;
 	struct xt_counters *paddc;
-	unsigned int num_counters;
-	char *name;
-	int size;
-	void *ptmp;
 	struct xt_table *t;
 	const struct xt_table_info *private;
 	int ret = 0;
 	struct ip6t_entry *iter;
 	unsigned int addend;
-#ifdef CONFIG_COMPAT
-	struct compat_xt_counters_info compat_tmp;
-
-	if (compat) {
-		ptmp = &compat_tmp;
-		size = sizeof(struct compat_xt_counters_info);
-	} else
-#endif
-	{
-		ptmp = &tmp;
-		size = sizeof(struct xt_counters_info);
-	}
-
-	if (copy_from_user(ptmp, user, size) != 0)
-		return -EFAULT;
-
-#ifdef CONFIG_COMPAT
-	if (compat) {
-		num_counters = compat_tmp.num_counters;
-		name = compat_tmp.name;
-	} else
-#endif
-	{
-		num_counters = tmp.num_counters;
-		name = tmp.name;
-	}
-
-	if (len != size + num_counters * sizeof(struct xt_counters))
-		return -EINVAL;
-
-	paddc = vmalloc(len - size);
-	if (!paddc)
-		return -ENOMEM;
-
-	if (copy_from_user(paddc, user + size, len - size) != 0) {
-		ret = -EFAULT;
-		goto free;
-	}
 
-	t = xt_find_table_lock(net, AF_INET6, name);
+	paddc = xt_copy_counters_from_user(user, len, &tmp, compat);
+	if (IS_ERR(paddc))
+		return PTR_ERR(paddc);
+	t = xt_find_table_lock(net, AF_INET6, tmp.name);
 	if (IS_ERR_OR_NULL(t)) {
 		ret = t ? PTR_ERR(t) : -ENOENT;
 		goto free;
@@ -1375,7 +1336,7 @@ do_add_counters(struct net *net, const void __user *user, unsigned int len,
 
 	local_bh_disable();
 	private = t->private;
-	if (private->number != num_counters) {
+	if (private->number != tmp.num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
 	}
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 9ec23ffa..c69c892 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -752,6 +752,80 @@ int xt_check_target(struct xt_tgchk_param *par,
 }
 EXPORT_SYMBOL_GPL(xt_check_target);
 
+/**
+ * xt_copy_counters_from_user - copy counters and metadata from userspace
+ *
+ * @user: src pointer to userspace memory
+ * @len: alleged size of userspace memory
+ * @info: where to store the xt_counters_info metadata
+ * @compat: true if we setsockopt call is done by 32bit task on 64bit kernel
+ *
+ * Copies counter meta data from @user and stores it in @info.
+ *
+ * vmallocs memory to hold the counters, then copies the counter data
+ * from @user to the new memory and returns a pointer to it.
+ *
+ * If @compat is true, @info gets converted automatically to the 64bit
+ * representation.
+ *
+ * The metadata associated with the counters is stored in @info.
+ *
+ * Return: returns pointer that caller has to test via IS_ERR().
+ * If IS_ERR is false, caller has to vfree the pointer.
+ */
+void *xt_copy_counters_from_user(const void __user *user, unsigned int len,
+				 struct xt_counters_info *info, bool compat)
+{
+	void *mem;
+	u64 size;
+
+#ifdef CONFIG_COMPAT
+	if (compat) {
+		/* structures only differ in size due to alignment */
+		struct compat_xt_counters_info compat_tmp;
+
+		if (len <= sizeof(compat_tmp))
+			return ERR_PTR(-EINVAL);
+
+		len -= sizeof(compat_tmp);
+		if (copy_from_user(&compat_tmp, user, sizeof(compat_tmp)) != 0)
+			return ERR_PTR(-EFAULT);
+
+		strlcpy(info->name, compat_tmp.name, sizeof(info->name));
+		info->num_counters = compat_tmp.num_counters;
+		user += sizeof(compat_tmp);
+	} else
+#endif
+	{
+		if (len <= sizeof(*info))
+			return ERR_PTR(-EINVAL);
+
+		len -= sizeof(*info);
+		if (copy_from_user(info, user, sizeof(*info)) != 0)
+			return ERR_PTR(-EFAULT);
+
+		info->name[sizeof(info->name) - 1] = '\0';
+		user += sizeof(*info);
+	}
+
+	size = sizeof(struct xt_counters);
+	size *= info->num_counters;
+
+	if (size != (u64)len)
+		return ERR_PTR(-EINVAL);
+
+	mem = vmalloc(len);
+	if (!mem)
+		return ERR_PTR(-ENOMEM);
+
+	if (copy_from_user(mem, user, len) == 0)
+		return mem;
+
+	vfree(mem);
+	return ERR_PTR(-EFAULT);
+}
+EXPORT_SYMBOL_GPL(xt_copy_counters_from_user);
+
 #ifdef CONFIG_COMPAT
 int xt_compat_target_offset(const struct xt_target *target)
 {
-- 
2.1.4
