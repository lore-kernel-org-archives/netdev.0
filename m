From: Jamal Hadi Salim <hadi@znyx.com>
Subject: small netfilter cleanup
Date: 05 Jun 2004 07:22:19 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1086434538.1590.16.camel@jzny.localdomain>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-q0+k3WAQkq6HY9b92iVN"
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-q0+k3WAQkq6HY9b92iVN
Content-Transfer-Encoding: 7bit
Content-Type: text/plain


I have been sitting on these patches for sometime now.
Harald, we did discuss this back when.
Attached patches for 2.4.26 and 2.6.6; both should patch
cleanly against pre 2.4.27 and 2.6.7

cheers,
jamal

--=-q0+k3WAQkq6HY9b92iVN
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=nf24p
Content-Type: text/plain; name=nf24p; charset=ISO-8859-1

--- /usr/src/2426/include/linux/netfilter.h	2003-08-25 07:44:44.000000000 -0400
+++ /usr/src/2426-mod/include/linux/netfilter.h	2004-06-03 22:51:00.000000000 -0400
@@ -146,6 +146,12 @@
 			struct nf_info *info,
 			unsigned int verdict);
 
+extern inline struct ipt_target *
+ipt_find_target_lock(const char *name, int *error, struct semaphore *mutex);
+extern inline struct ip6t_target *
+ip6t_find_target_lock(const char *name, int *error, struct semaphore *mutex);
+extern inline struct arpt_target *
+arpt_find_target_lock(const char *name, int *error, struct semaphore *mutex);
 extern void (*ip_ct_attach)(struct sk_buff *, struct nf_ct_info *);
 
 #ifdef CONFIG_NETFILTER_DEBUG
--- /usr/src/2426/include/linux/netfilter_ipv4/ip_tables.h	2002-02-25 14:38:13.000000000 -0500
+++ /usr/src/2426-mod/include/linux/netfilter_ipv4/ip_tables.h	2004-06-03 22:52:39.000000000 -0400
@@ -283,6 +283,8 @@
 	struct ipt_entry entrytable[0];
 };
 
+extern struct semaphore ipt_mutex;
+
 /* Standard return verdict, or do jump. */
 #define IPT_STANDARD_TARGET ""
 /* Error verdict. */
@@ -334,6 +336,7 @@
 /*
  *	Main firewall chains definitions and global var's definitions.
  */
+static DECLARE_MUTEX(ipt_mutex);
 #ifdef __KERNEL__
 
 #include <linux/init.h>
@@ -403,6 +406,11 @@
 	struct module *me;
 };
 
+extern struct ipt_target *
+ipt_find_target_lock(const char *name, int *error, struct semaphore *mutex);
+extern struct arpt_target *
+arpt_find_target_lock(const char *name, int *error, struct semaphore *mutex);
+
 extern int ipt_register_target(struct ipt_target *target);
 extern void ipt_unregister_target(struct ipt_target *target);
 
--- /usr/src/2426/net/ipv4/netfilter/ip_tables.c	2004-02-18 08:36:32.000000000 -0500
+++ /usr/src/2426-mod/net/ipv4/netfilter/ip_tables.c	2004-06-03 21:56:59.000000000 -0400
@@ -53,9 +53,6 @@
 #endif
 #define SMP_ALIGN(x) (((x) + SMP_CACHE_BYTES-1) & ~(SMP_CACHE_BYTES-1))
 
-/* Mutex protects lists (only traversed in user context). */
-static DECLARE_MUTEX(ipt_mutex);
-
 /* Must have mutex */
 #define ASSERT_READ_LOCK(x) IP_NF_ASSERT(down_trylock(&ipt_mutex) != 0)
 #define ASSERT_WRITE_LOCK(x) IP_NF_ASSERT(down_trylock(&ipt_mutex) != 0)
@@ -418,7 +415,7 @@
 {
 	void *ret;
 
-#if 0
+#if 0 
 	duprintf("find_inlist: searching for `%s' in %s.\n",
 		 name, head == &ipt_target ? "ipt_target"
 		 : head == &ipt_match ? "ipt_match"
@@ -464,7 +461,7 @@
 #endif
 
 static inline struct ipt_table *
-find_table_lock(const char *name, int *error, struct semaphore *mutex)
+ipt_find_table_lock(const char *name, int *error, struct semaphore *mutex)
 {
 	return find_inlist_lock(&ipt_tables, name, "iptable_", error, mutex);
 }
@@ -475,8 +472,8 @@
 	return find_inlist_lock(&ipt_match, name, "ipt_", error, mutex);
 }
 
-static inline struct ipt_target *
-find_target_lock(const char *name, int *error, struct semaphore *mutex)
+struct ipt_target *
+ipt_find_target_lock(const char *name, int *error, struct semaphore *mutex)
 {
 	return find_inlist_lock(&ipt_target, name, "ipt_", error, mutex);
 }
@@ -693,7 +690,7 @@
 		goto cleanup_matches;
 
 	t = ipt_get_target(e);
-	target = find_target_lock(t->u.user.name, &ret, &ipt_mutex);
+	target = ipt_find_target_lock(t->u.user.name, &ret, &ipt_mutex);
 	if (!target) {
 		duprintf("check_entry: `%s' not found\n", t->u.user.name);
 		goto cleanup_matches;
@@ -1030,7 +1027,7 @@
 	int ret;
 	struct ipt_table *t;
 
-	t = find_table_lock(entries->name, &ret, &ipt_mutex);
+	t = ipt_find_table_lock(entries->name, &ret, &ipt_mutex);
 	if (t) {
 		duprintf("t->private->number = %u\n",
 			 t->private->number);
@@ -1097,7 +1094,7 @@
 
 	duprintf("ip_tables: Translated table\n");
 
-	t = find_table_lock(tmp.name, &ret, &ipt_mutex);
+	t = ipt_find_table_lock(tmp.name, &ret, &ipt_mutex);
 	if (!t)
 		goto free_newinfo_counters_untrans;
 
@@ -1191,7 +1188,7 @@
 		goto free;
 	}
 
-	t = find_table_lock(tmp.name, &ret, &ipt_mutex);
+	t = ipt_find_table_lock(tmp.name, &ret, &ipt_mutex);
 	if (!t)
 		goto free;
 
@@ -1266,7 +1263,7 @@
 			break;
 		}
 		name[IPT_TABLE_MAXNAMELEN-1] = '\0';
-		t = find_table_lock(name, &ret, &ipt_mutex);
+		t = ipt_find_table_lock(name, &ret, &ipt_mutex);
 		if (t) {
 			struct ipt_getinfo info;
 
@@ -1838,6 +1835,7 @@
 EXPORT_SYMBOL(ipt_do_table);
 EXPORT_SYMBOL(ipt_register_target);
 EXPORT_SYMBOL(ipt_unregister_target);
+EXPORT_SYMBOL(ipt_find_target_lock);
 
 module_init(init);
 module_exit(fini);
--- /usr/src/2426/include/linux/netfilter_arp.h	2002-08-02 20:39:45.000000000 -0400
+++ /usr/src/2426-mod/include/linux/netfilter_arp.h	2004-06-03 22:52:11.000000000 -0400
@@ -16,4 +16,5 @@
 #define NF_ARP_OUT	1
 #define NF_ARP_NUMHOOKS	2
 
+static DECLARE_MUTEX(arpt_mutex);
 #endif /* __LINUX_ARP_NETFILTER_H */
--- /usr/src/2426/net/ipv4/netfilter/arp_tables.c	2003-08-25 07:44:44.000000000 -0400
+++ /usr/src/2426-mod/net/ipv4/netfilter/arp_tables.c	2004-06-03 21:56:59.000000000 -0400
@@ -52,7 +52,6 @@
 #endif
 #define SMP_ALIGN(x) (((x) + SMP_CACHE_BYTES-1) & ~(SMP_CACHE_BYTES-1))
 
-static DECLARE_MUTEX(arpt_mutex);
 
 #define ASSERT_READ_LOCK(x) ARP_NF_ASSERT(down_trylock(&arpt_mutex) != 0)
 #define ASSERT_WRITE_LOCK(x) ARP_NF_ASSERT(down_trylock(&arpt_mutex) != 0)
@@ -380,12 +379,12 @@
 }
 #endif
 
-static inline struct arpt_table *find_table_lock(const char *name, int *error, struct semaphore *mutex)
+static inline struct arpt_table *arpt_find_table_lock(const char *name, int *error, struct semaphore *mutex)
 {
 	return find_inlist_lock(&arpt_tables, name, "arptable_", error, mutex);
 }
 
-static inline struct arpt_target *find_target_lock(const char *name, int *error, struct semaphore *mutex)
+struct arpt_target *arpt_find_target_lock(const char *name, int *error, struct semaphore *mutex)
 {
 	return find_inlist_lock(&arpt_target, name, "arpt_", error, mutex);
 }
@@ -535,7 +534,7 @@
 	}
 
 	t = arpt_get_target(e);
-	target = find_target_lock(t->u.user.name, &ret, &arpt_mutex);
+	target = arpt_find_target_lock(t->u.user.name, &ret, &arpt_mutex);
 	if (!target) {
 		duprintf("check_entry: `%s' not found\n", t->u.user.name);
 		goto out;
@@ -834,7 +833,7 @@
 	int ret;
 	struct arpt_table *t;
 
-	t = find_table_lock(entries->name, &ret, &arpt_mutex);
+	t = arpt_find_table_lock(entries->name, &ret, &arpt_mutex);
 	if (t) {
 		duprintf("t->private->number = %u\n",
 			 t->private->number);
@@ -900,7 +899,7 @@
 
 	duprintf("arp_tables: Translated table\n");
 
-	t = find_table_lock(tmp.name, &ret, &arpt_mutex);
+	t = arpt_find_table_lock(tmp.name, &ret, &arpt_mutex);
 	if (!t)
 		goto free_newinfo_counters_untrans;
 
@@ -985,7 +984,7 @@
 		goto free;
 	}
 
-	t = find_table_lock(tmp.name, &ret, &arpt_mutex);
+	t = arpt_find_table_lock(tmp.name, &ret, &arpt_mutex);
 	if (!t)
 		goto free;
 
@@ -1058,7 +1057,7 @@
 			break;
 		}
 		name[ARPT_TABLE_MAXNAMELEN-1] = '\0';
-		t = find_table_lock(name, &ret, &arpt_mutex);
+		t = arpt_find_table_lock(name, &ret, &arpt_mutex);
 		if (t) {
 			struct arpt_getinfo info;
 
@@ -1306,6 +1305,7 @@
 EXPORT_SYMBOL(arpt_register_table);
 EXPORT_SYMBOL(arpt_unregister_table);
 EXPORT_SYMBOL(arpt_do_table);
+EXPORT_SYMBOL(arpt_find_target_lock);
 EXPORT_SYMBOL(arpt_register_target);
 EXPORT_SYMBOL(arpt_unregister_target);
 
--- /usr/src/2426/include/linux/netfilter_ipv6/ip6_tables.h	2003-06-13 10:51:38.000000000 -0400
+++ /usr/src/2426-mod/include/linux/netfilter_ipv6/ip6_tables.h	2004-06-03 22:54:59.000000000 -0400
@@ -106,6 +106,8 @@
 	u_int64_t pcnt, bcnt;			/* Packet and byte counters */
 };
 
+static DECLARE_MUTEX(ip6t_mutex);
+
 /* Values for "flag" field in struct ip6t_ip6 (general ip6 structure). */
 #define IP6T_F_PROTO		0x01	/* Set if rule cares about upper 
 					   protocols */
--- /usr/src/2426/net/ipv6/netfilter/ip6_tables.c	2004-04-14 09:05:41.000000000 -0400
+++ /usr/src/2426-mod/net/ipv6/netfilter/ip6_tables.c	2004-06-03 21:56:59.000000000 -0400
@@ -57,8 +57,6 @@
 #endif
 #define SMP_ALIGN(x) (((x) + SMP_CACHE_BYTES-1) & ~(SMP_CACHE_BYTES-1))
 
-/* Mutex protects lists (only traversed in user context). */
-static DECLARE_MUTEX(ip6t_mutex);
 
 /* Must have mutex */
 #define ASSERT_READ_LOCK(x) IP_NF_ASSERT(down_trylock(&ip6t_mutex) != 0)
@@ -535,7 +533,7 @@
 #endif
 
 static inline struct ip6t_table *
-find_table_lock(const char *name, int *error, struct semaphore *mutex)
+ip6t_find_table_lock(const char *name, int *error, struct semaphore *mutex)
 {
 	return find_inlist_lock(&ip6t_tables, name, "ip6table_", error, mutex);
 }
@@ -546,8 +544,8 @@
 	return find_inlist_lock(&ip6t_match, name, "ip6t_", error, mutex);
 }
 
-static inline struct ip6t_target *
-find_target_lock(const char *name, int *error, struct semaphore *mutex)
+struct ip6t_target *
+ip6t_find_target_lock(const char *name, int *error, struct semaphore *mutex)
 {
 	return find_inlist_lock(&ip6t_target, name, "ip6t_", error, mutex);
 }
@@ -764,7 +762,7 @@
 		goto cleanup_matches;
 
 	t = ip6t_get_target(e);
-	target = find_target_lock(t->u.user.name, &ret, &ip6t_mutex);
+	target = ip6t_find_target_lock(t->u.user.name, &ret, &ip6t_mutex);
 	if (!target) {
 		duprintf("check_entry: `%s' not found\n", t->u.user.name);
 		goto cleanup_matches;
@@ -1101,7 +1099,7 @@
 	int ret;
 	struct ip6t_table *t;
 
-	t = find_table_lock(entries->name, &ret, &ip6t_mutex);
+	t = ip6t_find_table_lock(entries->name, &ret, &ip6t_mutex);
 	if (t) {
 		duprintf("t->private->number = %u\n",
 			 t->private->number);
@@ -1164,7 +1162,7 @@
 
 	duprintf("ip_tables: Translated table\n");
 
-	t = find_table_lock(tmp.name, &ret, &ip6t_mutex);
+	t = ip6t_find_table_lock(tmp.name, &ret, &ip6t_mutex);
 	if (!t)
 		goto free_newinfo_counters_untrans;
 
@@ -1258,7 +1256,7 @@
 		goto free;
 	}
 
-	t = find_table_lock(tmp.name, &ret, &ip6t_mutex);
+	t = ip6t_find_table_lock(tmp.name, &ret, &ip6t_mutex);
 	if (!t)
 		goto free;
 
@@ -1333,7 +1331,7 @@
 			break;
 		}
 		name[IP6T_TABLE_MAXNAMELEN-1] = '\0';
-		t = find_table_lock(name, &ret, &ip6t_mutex);
+		t = ip6t_find_table_lock(name, &ret, &ip6t_mutex);
 		if (t) {
 			struct ip6t_getinfo info;
 
@@ -1940,6 +1938,7 @@
 EXPORT_SYMBOL(ip6t_register_table);
 EXPORT_SYMBOL(ip6t_unregister_table);
 EXPORT_SYMBOL(ip6t_do_table);
+EXPORT_SYMBOL(ip6t_find_target_lock);
 EXPORT_SYMBOL(ip6t_register_match);
 EXPORT_SYMBOL(ip6t_unregister_match);
 EXPORT_SYMBOL(ip6t_register_target);

--=-q0+k3WAQkq6HY9b92iVN
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=nf26p
Content-Type: text/plain; name=nf26p; charset=ISO-8859-1

--- /usr/src/266/include/linux/netfilter.h	2004-05-09 22:32:37.000000000 -0400
+++ /usr/src/266-mod/include/linux/netfilter.h	2004-06-04 10:21:20.000000000 -0400
@@ -171,6 +171,12 @@
 			struct nf_info *info,
 			unsigned int verdict);
 
+extern inline struct ipt_target *
+ipt_find_target_lock(const char *name, int *error, struct semaphore *mutex);
+extern inline struct ip6t_target *
+ip6t_find_target_lock(const char *name, int *error, struct semaphore *mutex);
+extern inline struct arpt_target *
+arpt_find_target_lock(const char *name, int *error, struct semaphore *mutex);
 extern void (*ip_ct_attach)(struct sk_buff *, struct nf_ct_info *);
 
 #ifdef CONFIG_NETFILTER_DEBUG
--- /usr/src/266/include/linux/netfilter_ipv4/ip_tables.h	2004-05-09 22:32:37.000000000 -0400
+++ /usr/src/266-mod/include/linux/netfilter_ipv4/ip_tables.h	2004-06-04 10:21:20.000000000 -0400
@@ -283,6 +283,8 @@
 	struct ipt_entry entrytable[0];
 };
 
+extern struct semaphore ipt_mutex;
+
 /* Standard return verdict, or do jump. */
 #define IPT_STANDARD_TARGET ""
 /* Error verdict. */
@@ -334,6 +336,7 @@
 /*
  *	Main firewall chains definitions and global var's definitions.
  */
+static DECLARE_MUTEX(ipt_mutex);
 #ifdef __KERNEL__
 
 #include <linux/init.h>
@@ -406,6 +409,11 @@
 	struct module *me;
 };
 
+extern struct ipt_target *
+ipt_find_target_lock(const char *name, int *error, struct semaphore *mutex);
+extern struct arpt_target *
+arpt_find_target_lock(const char *name, int *error, struct semaphore *mutex);
+
 extern int ipt_register_target(struct ipt_target *target);
 extern void ipt_unregister_target(struct ipt_target *target);
 
--- /usr/src/266/net/ipv4/netfilter/ip_tables.c	2004-05-09 22:32:26.000000000 -0400
+++ /usr/src/266-mod/net/ipv4/netfilter/ip_tables.c	2004-06-04 10:21:20.000000000 -0400
@@ -61,9 +61,6 @@
 #endif
 #define SMP_ALIGN(x) (((x) + SMP_CACHE_BYTES-1) & ~(SMP_CACHE_BYTES-1))
 
-/* Mutex protects lists (only traversed in user context). */
-static DECLARE_MUTEX(ipt_mutex);
-
 /* Must have mutex */
 #define ASSERT_READ_LOCK(x) IP_NF_ASSERT(down_trylock(&ipt_mutex) != 0)
 #define ASSERT_WRITE_LOCK(x) IP_NF_ASSERT(down_trylock(&ipt_mutex) != 0)
@@ -418,7 +415,7 @@
 {
 	void *ret;
 
-#if 0
+#if 0 
 	duprintf("find_inlist: searching for `%s' in %s.\n",
 		 name, head == &ipt_target ? "ipt_target"
 		 : head == &ipt_match ? "ipt_match"
@@ -461,7 +458,7 @@
 #endif
 
 static inline struct ipt_table *
-find_table_lock(const char *name, int *error, struct semaphore *mutex)
+ipt_find_table_lock(const char *name, int *error, struct semaphore *mutex)
 {
 	return find_inlist_lock(&ipt_tables, name, "iptable_", error, mutex);
 }
@@ -472,8 +469,8 @@
 	return find_inlist_lock(&ipt_match, name, "ipt_", error, mutex);
 }
 
-static inline struct ipt_target *
-find_target_lock(const char *name, int *error, struct semaphore *mutex)
+struct ipt_target *
+ipt_find_target_lock(const char *name, int *error, struct semaphore *mutex)
 {
 	return find_inlist_lock(&ipt_target, name, "ipt_", error, mutex);
 }
@@ -688,7 +685,7 @@
 		goto cleanup_matches;
 
 	t = ipt_get_target(e);
-	target = find_target_lock(t->u.user.name, &ret, &ipt_mutex);
+	target = ipt_find_target_lock(t->u.user.name, &ret, &ipt_mutex);
 	if (!target) {
 		duprintf("check_entry: `%s' not found\n", t->u.user.name);
 		goto cleanup_matches;
@@ -1025,7 +1022,7 @@
 	int ret;
 	struct ipt_table *t;
 
-	t = find_table_lock(entries->name, &ret, &ipt_mutex);
+	t = ipt_find_table_lock(entries->name, &ret, &ipt_mutex);
 	if (t) {
 		duprintf("t->private->number = %u\n",
 			 t->private->number);
@@ -1092,7 +1089,7 @@
 
 	duprintf("ip_tables: Translated table\n");
 
-	t = find_table_lock(tmp.name, &ret, &ipt_mutex);
+	t = ipt_find_table_lock(tmp.name, &ret, &ipt_mutex);
 	if (!t)
 		goto free_newinfo_counters_untrans;
 
@@ -1195,7 +1192,7 @@
 		goto free;
 	}
 
-	t = find_table_lock(tmp.name, &ret, &ipt_mutex);
+	t = ipt_find_table_lock(tmp.name, &ret, &ipt_mutex);
 	if (!t)
 		goto free;
 
@@ -1270,7 +1267,7 @@
 			break;
 		}
 		name[IPT_TABLE_MAXNAMELEN-1] = '\0';
-		t = find_table_lock(name, &ret, &ipt_mutex);
+		t = ipt_find_table_lock(name, &ret, &ipt_mutex);
 		if (t) {
 			struct ipt_getinfo info;
 
@@ -1855,6 +1852,7 @@
 EXPORT_SYMBOL(ipt_do_table);
 EXPORT_SYMBOL(ipt_register_target);
 EXPORT_SYMBOL(ipt_unregister_target);
+EXPORT_SYMBOL(ipt_find_target_lock);
 
 module_init(init);
 module_exit(fini);
--- /usr/src/266/include/linux/netfilter_arp.h	2004-05-09 22:32:00.000000000 -0400
+++ /usr/src/266-mod/include/linux/netfilter_arp.h	2004-06-04 10:21:20.000000000 -0400
@@ -17,4 +17,5 @@
 #define NF_ARP_FORWARD	2
 #define NF_ARP_NUMHOOKS	3
 
+static DECLARE_MUTEX(arpt_mutex);
 #endif /* __LINUX_ARP_NETFILTER_H */
--- /usr/src/266/net/ipv4/netfilter/arp_tables.c	2004-05-09 22:33:12.000000000 -0400
+++ /usr/src/266-mod/net/ipv4/netfilter/arp_tables.c	2004-06-04 10:21:20.000000000 -0400
@@ -56,7 +56,6 @@
 #endif
 #define SMP_ALIGN(x) (((x) + SMP_CACHE_BYTES-1) & ~(SMP_CACHE_BYTES-1))
 
-static DECLARE_MUTEX(arpt_mutex);
 
 #define ASSERT_READ_LOCK(x) ARP_NF_ASSERT(down_trylock(&arpt_mutex) != 0)
 #define ASSERT_WRITE_LOCK(x) ARP_NF_ASSERT(down_trylock(&arpt_mutex) != 0)
@@ -388,12 +387,12 @@
 }
 #endif
 
-static inline struct arpt_table *find_table_lock(const char *name, int *error, struct semaphore *mutex)
+static inline struct arpt_table *arpt_find_table_lock(const char *name, int *error, struct semaphore *mutex)
 {
 	return find_inlist_lock(&arpt_tables, name, "arptable_", error, mutex);
 }
 
-static inline struct arpt_target *find_target_lock(const char *name, int *error, struct semaphore *mutex)
+struct arpt_target *arpt_find_target_lock(const char *name, int *error, struct semaphore *mutex)
 {
 	return find_inlist_lock(&arpt_target, name, "arpt_", error, mutex);
 }
@@ -543,7 +542,7 @@
 	}
 
 	t = arpt_get_target(e);
-	target = find_target_lock(t->u.user.name, &ret, &arpt_mutex);
+	target = arpt_find_target_lock(t->u.user.name, &ret, &arpt_mutex);
 	if (!target) {
 		duprintf("check_entry: `%s' not found\n", t->u.user.name);
 		goto out;
@@ -843,7 +842,7 @@
 	int ret;
 	struct arpt_table *t;
 
-	t = find_table_lock(entries->name, &ret, &arpt_mutex);
+	t = arpt_find_table_lock(entries->name, &ret, &arpt_mutex);
 	if (t) {
 		duprintf("t->private->number = %u\n",
 			 t->private->number);
@@ -909,7 +908,7 @@
 
 	duprintf("arp_tables: Translated table\n");
 
-	t = find_table_lock(tmp.name, &ret, &arpt_mutex);
+	t = arpt_find_table_lock(tmp.name, &ret, &arpt_mutex);
 	if (!t)
 		goto free_newinfo_counters_untrans;
 
@@ -1002,7 +1001,7 @@
 		goto free;
 	}
 
-	t = find_table_lock(tmp.name, &ret, &arpt_mutex);
+	t = arpt_find_table_lock(tmp.name, &ret, &arpt_mutex);
 	if (!t)
 		goto free;
 
@@ -1075,7 +1074,7 @@
 			break;
 		}
 		name[ARPT_TABLE_MAXNAMELEN-1] = '\0';
-		t = find_table_lock(name, &ret, &arpt_mutex);
+		t = arpt_find_table_lock(name, &ret, &arpt_mutex);
 		if (t) {
 			struct arpt_getinfo info;
 
@@ -1323,6 +1322,7 @@
 EXPORT_SYMBOL(arpt_register_table);
 EXPORT_SYMBOL(arpt_unregister_table);
 EXPORT_SYMBOL(arpt_do_table);
+EXPORT_SYMBOL(arpt_find_target_lock);
 EXPORT_SYMBOL(arpt_register_target);
 EXPORT_SYMBOL(arpt_unregister_target);
 
--- /usr/src/266/include/linux/netfilter_ipv6/ip6_tables.h	2004-05-09 22:33:20.000000000 -0400
+++ /usr/src/266-mod/include/linux/netfilter_ipv6/ip6_tables.h	2004-06-04 10:21:20.000000000 -0400
@@ -106,6 +106,8 @@
 	u_int64_t pcnt, bcnt;			/* Packet and byte counters */
 };
 
+static DECLARE_MUTEX(ip6t_mutex);
+
 /* Values for "flag" field in struct ip6t_ip6 (general ip6 structure). */
 #define IP6T_F_PROTO		0x01	/* Set if rule cares about upper 
 					   protocols */
--- /usr/src/266/net/ipv6/netfilter/ip6_tables.c	2004-05-09 22:33:19.000000000 -0400
+++ /usr/src/266-mod/net/ipv6/netfilter/ip6_tables.c	2004-06-04 10:21:20.000000000 -0400
@@ -66,8 +66,6 @@
 #endif
 #define SMP_ALIGN(x) (((x) + SMP_CACHE_BYTES-1) & ~(SMP_CACHE_BYTES-1))
 
-/* Mutex protects lists (only traversed in user context). */
-static DECLARE_MUTEX(ip6t_mutex);
 
 /* Must have mutex */
 #define ASSERT_READ_LOCK(x) IP_NF_ASSERT(down_trylock(&ip6t_mutex) != 0)
@@ -544,7 +542,7 @@
 #endif
 
 static inline struct ip6t_table *
-find_table_lock(const char *name, int *error, struct semaphore *mutex)
+ip6t_find_table_lock(const char *name, int *error, struct semaphore *mutex)
 {
 	return find_inlist_lock(&ip6t_tables, name, "ip6table_", error, mutex);
 }
@@ -555,8 +553,8 @@
 	return find_inlist_lock(&ip6t_match, name, "ip6t_", error, mutex);
 }
 
-static inline struct ip6t_target *
-find_target_lock(const char *name, int *error, struct semaphore *mutex)
+struct ip6t_target *
+ip6t_find_target_lock(const char *name, int *error, struct semaphore *mutex)
 {
 	return find_inlist_lock(&ip6t_target, name, "ip6t_", error, mutex);
 }
@@ -771,7 +769,7 @@
 		goto cleanup_matches;
 
 	t = ip6t_get_target(e);
-	target = find_target_lock(t->u.user.name, &ret, &ip6t_mutex);
+	target = ip6t_find_target_lock(t->u.user.name, &ret, &ip6t_mutex);
 	if (!target) {
 		duprintf("check_entry: `%s' not found\n", t->u.user.name);
 		goto cleanup_matches;
@@ -1111,7 +1109,7 @@
 	int ret;
 	struct ip6t_table *t;
 
-	t = find_table_lock(entries->name, &ret, &ip6t_mutex);
+	t = ip6t_find_table_lock(entries->name, &ret, &ip6t_mutex);
 	if (t) {
 		duprintf("t->private->number = %u\n",
 			 t->private->number);
@@ -1174,7 +1172,7 @@
 
 	duprintf("ip_tables: Translated table\n");
 
-	t = find_table_lock(tmp.name, &ret, &ip6t_mutex);
+	t = ip6t_find_table_lock(tmp.name, &ret, &ip6t_mutex);
 	if (!t)
 		goto free_newinfo_counters_untrans;
 
@@ -1276,7 +1274,7 @@
 		goto free;
 	}
 
-	t = find_table_lock(tmp.name, &ret, &ip6t_mutex);
+	t = ip6t_find_table_lock(tmp.name, &ret, &ip6t_mutex);
 	if (!t)
 		goto free;
 
@@ -1351,7 +1349,7 @@
 			break;
 		}
 		name[IP6T_TABLE_MAXNAMELEN-1] = '\0';
-		t = find_table_lock(name, &ret, &ip6t_mutex);
+		t = ip6t_find_table_lock(name, &ret, &ip6t_mutex);
 		if (t) {
 			struct ip6t_getinfo info;
 
@@ -1964,6 +1962,7 @@
 EXPORT_SYMBOL(ip6t_register_table);
 EXPORT_SYMBOL(ip6t_unregister_table);
 EXPORT_SYMBOL(ip6t_do_table);
+EXPORT_SYMBOL(ip6t_find_target_lock);
 EXPORT_SYMBOL(ip6t_register_match);
 EXPORT_SYMBOL(ip6t_unregister_match);
 EXPORT_SYMBOL(ip6t_register_target);

--=-q0+k3WAQkq6HY9b92iVN--
