From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: net/sched/ipt.c
Date: Thu, 06 Jan 2005 15:46:45 +1100
Message-ID: <1104986805.20582.116.camel@localhost.localdomain>
References: <20050105203352.2bc3b71a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050105203352.2bc3b71a.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-01-05 at 20:33 -0800, Andrew Morton wrote:
> Am I missing something?
> 
> *** Warning: "__ipt_mutex_up" [net/sched/ipt.ko] undefined!
> *** Warning: "__ipt_find_target_lock" [net/sched/ipt.ko] undefined!

Patch already sent...
Rusty.

Name: Restore net/sched/ipt.c After iptables Kmod Cleanup
Status: Tested under nfsim
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Thomas Graf points out that I broke net/sched/ipt.c when I removed
__ipt_find_target_lock.  In fact, those routines don't need to keep
the lock held, so we can simplify them, and expose an interface
(ipt_find_target) which does module loading correctly for
net/sched/ipt.c.

As Thomas points out, this also gets the module refcounts right.

Index: linux-2.6.10-bk8-Netfilter/net/ipv4/netfilter/ip_tables.c
===================================================================
--- linux-2.6.10-bk8-Netfilter.orig/net/ipv4/netfilter/ip_tables.c	2005-01-06 09:12:01.000000000 +1100
+++ linux-2.6.10-bk8-Netfilter/net/ipv4/netfilter/ip_tables.c	2005-01-06 09:49:10.000000000 +1100
@@ -430,62 +430,63 @@
 	return NULL;
 }
 
-/* Find match, grabs mutex & ref.  Returns ERR_PTR() on error. */
-static inline struct ipt_match *find_match_lock(const char *name, u8 revision)
+/* Find match, grabs ref.  Returns ERR_PTR() on error. */
+static inline struct ipt_match *find_match(const char *name, u8 revision)
 {
 	struct ipt_match *m;
-	int found = 0;
+	int err = 0;
 
 	if (down_interruptible(&ipt_mutex) != 0)
 		return ERR_PTR(-EINTR);
 
 	list_for_each_entry(m, &ipt_match, list) {
 		if (strcmp(m->name, name) == 0) {
-			found = 1;
 			if (m->revision == revision) {
-				if (!try_module_get(m->me))
-					found = 0;
-				else
+				if (try_module_get(m->me)) {
+					up(&ipt_mutex);
 					return m;
-			}
+				}
+			} else
+				err = -EPROTOTYPE; /* Found something. */
 		}
 	}
 	up(&ipt_mutex);
-
-	/* Not found at all?  NULL so try_then_request_module loads module. */
-	if (!found)
-		return NULL;
-
-	return ERR_PTR(-EPROTOTYPE);
+	return ERR_PTR(err);
 }
 
-/* Find target, grabs mutex & ref.  Returns ERR_PTR() on error. */
-static inline struct ipt_target *find_target_lock(const char *name, u8 revision)
+/* Find target, grabs ref.  Returns ERR_PTR() on error. */
+static inline struct ipt_target *find_target(const char *name, u8 revision)
 {
 	struct ipt_target *t;
-	int found = 0;
+	int err = 0;
 
 	if (down_interruptible(&ipt_mutex) != 0)
 		return ERR_PTR(-EINTR);
 
 	list_for_each_entry(t, &ipt_target, list) {
 		if (strcmp(t->name, name) == 0) {
-			found = 1;
 			if (t->revision == revision) {
-				if (!try_module_get(t->me))
-					found = 0;
-				else
+				if (try_module_get(t->me)) {
+					up(&ipt_mutex);
 					return t;
-			}
+				}
+			} else
+				err = -EPROTOTYPE; /* Found something. */
 		}
 	}
 	up(&ipt_mutex);
+	return ERR_PTR(err);
+}
 
-	/* Not found at all?  NULL so try_then_request_module loads module. */
-	if (!found)
-		return NULL;
+struct ipt_target *ipt_find_target(const char *name, u8 revision)
+{
+	struct ipt_target *target;
 
-	return ERR_PTR(-EPROTOTYPE);
+	target = try_then_request_module(find_target(name, revision),
+					 "ipt_%s", name);
+	if (IS_ERR(target) || !target)
+		return NULL;
+	return target;
 }
 
 static int match_revfn(const char *name, u8 revision, int *bestp)
@@ -708,15 +709,14 @@
 {
 	struct ipt_match *match;
 
-	match = try_then_request_module(find_match_lock(m->u.user.name,
-							m->u.user.revision),
+	match = try_then_request_module(find_match(m->u.user.name,
+						   m->u.user.revision),
 					"ipt_%s", m->u.user.name);
 	if (IS_ERR(match) || !match) {
 		duprintf("check_match: `%s' not found\n", m->u.user.name);
 		return match ? PTR_ERR(match) : -ENOENT;
 	}
 	m->u.kernel.match = match;
-	up(&ipt_mutex);
 
 	if (m->u.kernel.match->checkentry
 	    && !m->u.kernel.match->checkentry(name, ip, m->data,
@@ -754,8 +754,8 @@
 		goto cleanup_matches;
 
 	t = ipt_get_target(e);
-	target = try_then_request_module(find_target_lock(t->u.user.name,
-							  t->u.user.revision),
+	target = try_then_request_module(find_target(t->u.user.name,
+						     t->u.user.revision),
 					 "ipt_%s", t->u.user.name);
 	if (IS_ERR(target) || !target) {
 		duprintf("check_entry: `%s' not found\n", t->u.user.name);
@@ -763,7 +763,6 @@
 		goto cleanup_matches;
 	}
 	t->u.kernel.target = target;
-	up(&ipt_mutex);
 
 	if (t->u.kernel.target == &ipt_standard_target) {
 		if (!standard_check(t, size)) {
Index: linux-2.6.10-bk8-Netfilter/net/sched/ipt.c
===================================================================
--- linux-2.6.10-bk8-Netfilter.orig/net/sched/ipt.c	2004-12-28 12:31:11.000000000 +1100
+++ linux-2.6.10-bk8-Netfilter/net/sched/ipt.c	2005-01-06 09:37:01.000000000 +1100
@@ -31,6 +31,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/proc_fs.h>
+#include <linux/kmod.h>
 #include <net/sock.h>
 #include <net/pkt_sched.h>
 #include <linux/tc_act/tc_ipt.h>
@@ -60,32 +61,23 @@
 	struct ipt_target *target;
 	int ret = 0;
 	struct ipt_entry_target *t = p->t;
-	target = __ipt_find_target_lock(t->u.user.name, &ret);
 
+	target = ipt_find_target(t->u.user.name, t->u.user.revision);
 	if (!target) {
 		printk("init_targ: Failed to find %s\n", t->u.user.name);
 		return -1;
 	}
 
 	DPRINTK("init_targ: found %s\n", target->name);
-	/* we really need proper ref counting
-	 seems to be only needed for modules?? Talk to laforge */
-/*      if (target->me)
-              __MOD_INC_USE_COUNT(target->me);
-*/
 	t->u.kernel.target = target;
 
-	__ipt_mutex_up();
-
 	if (t->u.kernel.target->checkentry
 	    && !t->u.kernel.target->checkentry(p->tname, NULL, t->data,
 					       t->u.target_size
 					       - sizeof (*t), p->hook)) {
-/*              if (t->u.kernel.target->me)
-	      __MOD_DEC_USE_COUNT(t->u.kernel.target->me);
-*/
 		DPRINTK("ip_tables: check failed for `%s'.\n",
 			t->u.kernel.target->name);
+		module_put(t->u.kernel.target->me);
 		ret = -EINVAL;
 	}
 
@@ -235,8 +227,12 @@
 {
 	struct tcf_ipt *p;
 	p = PRIV(a,ipt);
-	if (NULL != p)
+	if (NULL != p) {
+		struct ipt_entry_target *t = p->t;
+		if (t && t->u.kernel.target)
+			module_put(t->u.kernel.target->me);
 		return tcf_hash_release(p, bind);
+	}
 	return 0;
 }
 
Index: linux-2.6.10-bk8-Netfilter/include/linux/netfilter_ipv4/ip_tables.h
===================================================================
--- linux-2.6.10-bk8-Netfilter.orig/include/linux/netfilter_ipv4/ip_tables.h	2005-01-06 09:11:56.000000000 +1100
+++ linux-2.6.10-bk8-Netfilter/include/linux/netfilter_ipv4/ip_tables.h	2005-01-06 09:40:03.000000000 +1100
@@ -456,6 +456,9 @@
 	struct module *me;
 };
 
+/* net/sched/ipt.c: Gimme access to your targets!  Gets target->me. */
+extern struct ipt_target *ipt_find_target(const char *name, u8 revision);
+
 extern int ipt_register_table(struct ipt_table *table);
 extern void ipt_unregister_table(struct ipt_table *table);
 extern unsigned int ipt_do_table(struct sk_buff **pskb,

-- 
A bad analogy is like a leaky screwdriver -- Richard Braakman
