From: Patrick Schaaf <bof@bof.de>
Subject: [PATCH] my recent meddling with ip_conntrack
Date: Sat, 3 Aug 2002 21:55:46 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020803215546.A284@oknodo.bof.de>
References: <20020802102451.A685@oknodo.bof.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="OXfL5xGRrasGEqWY"
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: netfilter-devel@lists.netfilter.org
Content-Disposition: inline
In-Reply-To: <20020802102451.A685@oknodo.bof.de>; from bof@bof.de on Fri, Aug 02, 2002 at 10:24:51AM +0200
List-Id: netdev.vger.kernel.org


--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi netfilter-devel & netdev,

I have pulled my recent ip_conntrack patches up to 2.4.19, and have
that merge running now on my shiny new dual P-MMX 200. No surprises.
It's already up 40 minutes with hundreds of connections tracked!

Patch appended for curious people and would-be testers. All comments welcome.
This is not meant for inclusion anywhere, right now, just looking for some
eyeballs.

have a nice weekend
  Patrick

Short Changelog, in order of probable importance:

- netfilter hook statistics, /proc/net/nf_hook_stat*, as a compile option
  found under "Networking Options". Per-hook-function rdtscll() based
  timing and occurrence counting. See netfilter in action for yourself!
- remove unneccessary add_timer() calls from per-packet processing.
  Introduces new ip_conntrack->timeout_target, 4 byte in size.
  The running timer is never disturbed when increasing monotonically.
  That covers the normal ESTABLISHED case. When the timer runs out,
  it possibly restarts itself to the then-current timeout_target.
- prefer to allocate the ip_conntrack hash using get_free_pages()
- use a single linked list to hash them. BTW, with bucket count
  autoselection, this change doubles the number of available buckets.
  Saves four byte per ip_conntrack_hash_tuple, 8 byte per ip_conntrack.
- in include/linux/skbuff.h, introduce nf_skb_forget(), and use that to
  cleanup several of places in ipv4/ core stack code.
- make init_conntrack() a bit more sane, removes unneccessary hash
  computations.


--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="bof-ct-merged-20020803.Changelog"

---------------------- Would send the following csets ---------------------
ChangeSet@1.597, 2002-08-03 18:20:26+02:00, bof@cdr.(none)
  Merge bkbits-linux-2.4 after 2.4.19

ChangeSet@1.582.9.7, 2002-08-02 09:02:19+02:00, bof@cdr.(none)
  ip_conntrack_standalone.c:
    cleanup /proc/net/ip_conntrack output - same as always, now.

ChangeSet@1.582.9.6, 2002-08-02 09:00:13+02:00, bof@cdr.(none)
  ip_conntrack.h:
    prototype for new ip_ct_sudden_death()
  ip_conntrack_proto_icmp.c, ip_conntrack_proto_tcp.c:
    use ip_ct_sudden_death(), instead of fiddling with ct->timeout directly.
  ip_conntrack_core.c:
    introduce ct->timeout_target, makes add_timer() a rare event.
  ip_conntrack_standalone.c:
    show ct->timeout_target in /proc/net/ip_conntrack.

ChangeSet@1.582.9.5, 2002-08-01 22:52:01+02:00, bof@cdr.(none)
  ip_conntrack_core.c:
    more add_timer avoidance

ChangeSet@1.582.9.4, 2002-08-01 22:27:28+02:00, bof@cdr.(none)
  ip_conntrack.h, ip_conntrack_core.c:
    begin add_timer avoidance

ChangeSet@1.582.9.3, 2002-08-01 21:21:14+02:00, bof@cdr.(none)
  ip_conntrack_core.c:
    get_free_pages allocation for ip_conntrack_hash

ChangeSet@1.582.7.5, 2002-08-01 19:04:41+02:00, bof@cdr.(none)
  netfilter.c:
    remove KERN_NOTICE output

ChangeSet@1.582.9.2, 2002-08-01 09:45:24+02:00, bof@cdr.(none)
  srlist.h:
    fix single ring list code
  ip_conntrack_core.c:
    type agnostic ip_conntrack_hash allocation

ChangeSet@1.582.9.1, 2002-07-31 20:57:39+02:00, bof@cdr.(none)
  include/linux/netfilter_ipv4/srlist.h:
    introduced. a single ring list implementation with almost the same
    interface as the netfilter_ipv4/listhelp.h
  include/linux/netfilter_ipv4/ip_conntrack*.h:
    use srlist_head in place of list_head for conntrack tuple hashing.
  net/ipv4/netfilter/ip_conntrack_{core,standalone}.c:
    use srlist_head instead of list_head for conntrack tuple hashing.

ChangeSet@1.582.7.4, 2002-07-29 09:25:21+02:00, bof@cdr.(none)
  netfilter.c:
    some more comments, minimal cleanup, KERN_NOTICE upon (un)registration.
  Configure.help:
    friendly help and advise regarding CONFIG_NETFILTER_HOOK_STAT

ChangeSet@1.582.7.3, 2002-07-28 11:58:38+02:00, bof@cdr.(none)
  net/core/netfilter.c:
    remove debug printks related to slabifying hook statistic counters.

ChangeSet@1.582.7.2, 2002-07-28 11:54:23+02:00, bof@cdr.(none)
  net/core/netfilter.c:
    slabify, make per-cpu counters.

ChangeSet@1.582.7.1, 2002-07-27 19:16:23+02:00, bof@cdr.(none)
  Config.in, netfilter.h, netfilter.c:
    netfilter hook statistics

ChangeSet@1.582.4.2, 2002-07-22 21:07:02+02:00, bof@cdr.(none)
  overall:
    compiles now, skb_nf_forget() introduction probably OK.
  skbuff.h:
    sk_buff speling fix

ChangeSet@1.582.4.1, 2002-07-22 20:45:22+02:00, bof@cdr.(none)
  skbuff.h:
    define skb_nf_forget()
  skbuff.c, ip_conntrack_core.c, ipt_REJECT.c, ipip.c, ip_gre.c, sit.c:
    use skb_nf_forget()
  ip_input.c, ipmr.c:
    use skb_nf_forget()
    NOTE: original code did not clear nf_debug. Now it will.

ChangeSet@1.582.2.70, 2002-07-22 09:32:20+02:00, bof@cdr.(none)
  ip_conntrack_core.c:
    in init_conntrack(), rename drop_next to drop_rotor: document recent change.

ChangeSet@1.582.2.69, 2002-07-22 09:31:29+02:00, bof@cdr.(none)
  ip_conntrack_core.c:
    in init_conntrack(), narrow scope of static drop_next.

ChangeSet@1.582.2.68, 2002-07-22 09:30:29+02:00, bof@cdr.(none)
  ip_conntrack_core.c:
    sanitize typing for hash_conntrack() return value: always use u_int32_t.

ChangeSet@1.582.2.67, 2002-07-22 09:24:39+02:00, bof@cdr.(none)
  ip_conntrack_core.c:
    remove hash calculation from unconditional part of init_conntrack(),
    to the rare place where it is needed.

ChangeSet@1.582.2.66, 2002-07-22 09:23:20+02:00, bof@cdr.(none)
  ip_conntrack_core.c:
    remove repl_hash calculation in init_conntrack(): it was not used.

---------------------------------------------------------------------------

--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="bof-ct-merged-20020803.patch"

diff -urN ex1/Documentation/Configure.help ex2/Documentation/Configure.help
--- ex1/Documentation/Configure.help	Sat Aug  3 21:21:17 2002
+++ ex2/Documentation/Configure.help	Sat Aug  3 21:24:54 2002
@@ -2429,6 +2429,23 @@
   You can say Y here if you want to get additional messages useful in
   debugging the netfilter code.
 
+Netfilter hook statistics
+CONFIG_NETFILTER_HOOK_STAT
+  If you say Y here, the time spent in the various netfilter hook
+  functions is measured, using the TSC of your processor. Your
+  kernel won't boot when you don't have a working TSC.
+  Say N when you don't have a modern Intel/AMD processor.
+
+  When enabled, look at /proc/net/nf_stat_hook_* for the actual
+  measurement results, presented in a format easy to guess by
+  any well-calibrated crystal ball.
+
+  The timing imposes a processing overhead that may be relevant
+  on machines with high packet rates. The overhead is estimated
+  at about 5% of the time used by the hook functions, themselves.
+
+  The safe thing is to say N.
+
 Connection tracking (required for masq/NAT)
 CONFIG_IP_NF_CONNTRACK
   Connection tracking keeps a record of what packets have passed
diff -urN ex1/include/linux/netfilter.h ex2/include/linux/netfilter.h
--- ex1/include/linux/netfilter.h	Sat Aug  3 21:21:14 2002
+++ ex2/include/linux/netfilter.h	Sat Aug  3 21:24:50 2002
@@ -51,6 +51,9 @@
 	int hooknum;
 	/* Hooks are ordered in ascending priority. */
 	int priority;
+#ifdef CONFIG_NETFILTER_HOOK_STAT
+	void *hook_stat;
+#endif
 };
 
 struct nf_sockopt_ops
diff -urN ex1/include/linux/netfilter_ipv4/ip_conntrack.h ex2/include/linux/netfilter_ipv4/ip_conntrack.h
--- ex1/include/linux/netfilter_ipv4/ip_conntrack.h	Sat Aug  3 21:21:09 2002
+++ ex2/include/linux/netfilter_ipv4/ip_conntrack.h	Sat Aug  3 21:24:47 2002
@@ -97,6 +97,7 @@
 	volatile unsigned long status;
 
 	/* Timer function; drops refcnt when it goes off. */
+	unsigned long timeout_target;
 	struct timer_list timeout;
 
 	/* If we're expecting another related connection, this will be
@@ -160,6 +161,9 @@
 
 extern int invert_tuplepr(struct ip_conntrack_tuple *inverse,
 			  const struct ip_conntrack_tuple *orig);
+
+/* Kill this conntrack immediately, without regard to timeouts. */
+extern int ip_ct_sudden_death(struct ip_conntrack *ct);
 
 /* Refresh conntrack for this many jiffies */
 extern void ip_ct_refresh(struct ip_conntrack *ct,
diff -urN ex1/include/linux/netfilter_ipv4/ip_conntrack_core.h ex2/include/linux/netfilter_ipv4/ip_conntrack_core.h
--- ex1/include/linux/netfilter_ipv4/ip_conntrack_core.h	Sat Aug  3 21:21:21 2002
+++ ex2/include/linux/netfilter_ipv4/ip_conntrack_core.h	Sat Aug  3 21:24:55 2002
@@ -1,6 +1,7 @@
 #ifndef _IP_CONNTRACK_CORE_H
 #define _IP_CONNTRACK_CORE_H
 #include <linux/netfilter_ipv4/lockhelp.h>
+#include <linux/netfilter_ipv4/srlist.h>
 
 /* This header is used to share core functionality between the
    standalone connection tracking module, and the compatibility layer's use
@@ -44,7 +45,7 @@
 	return NF_ACCEPT;
 }
 
-extern struct list_head *ip_conntrack_hash;
+extern struct srlist_head *ip_conntrack_hash;
 extern struct list_head expect_list;
 DECLARE_RWLOCK_EXTERN(ip_conntrack_lock);
 #endif /* _IP_CONNTRACK_CORE_H */
diff -urN ex1/include/linux/netfilter_ipv4/ip_conntrack_tuple.h ex2/include/linux/netfilter_ipv4/ip_conntrack_tuple.h
--- ex1/include/linux/netfilter_ipv4/ip_conntrack_tuple.h	Sat Aug  3 21:21:16 2002
+++ ex2/include/linux/netfilter_ipv4/ip_conntrack_tuple.h	Sat Aug  3 21:24:54 2002
@@ -1,6 +1,8 @@
 #ifndef _IP_CONNTRACK_TUPLE_H
 #define _IP_CONNTRACK_TUPLE_H
 
+#include <linux/netfilter_ipv4/srlist.h>
+
 /* A `tuple' is a structure containing the information to uniquely
   identify a connection.  ie. if two packets have the same tuple, they
   are in the same connection; if not, they are not.
@@ -85,7 +87,7 @@
 /* Connections have two entries in the hash table: one for each way */
 struct ip_conntrack_tuple_hash
 {
-	struct list_head list;
+	struct srlist_head list;
 
 	struct ip_conntrack_tuple tuple;
 
diff -urN ex1/include/linux/netfilter_ipv4/srlist.h ex2/include/linux/netfilter_ipv4/srlist.h
--- ex1/include/linux/netfilter_ipv4/srlist.h	Thu Jan  1 01:00:00 1970
+++ ex2/include/linux/netfilter_ipv4/srlist.h	Sat Aug  3 21:24:35 2002
@@ -0,0 +1,78 @@
+#ifndef __NETFILTER_IPV4_SRLIST_H
+#define __NETFILTER_IPV4_SRLIST_H
+
+struct srlist_head {
+	struct srlist_head *next;
+};
+
+#define INIT_SRLIST_HEAD(ptr) do { (ptr)->next = (ptr); } while (0)
+
+#define SRLIST_FIND(srl, cmpfn, type, args...)				\
+({									\
+ 	struct srlist_head *__head = (struct srlist_head *) (srl);	\
+	struct srlist_head *__i;					\
+									\
+	ASSERT_READ_LOCK(__head);					\
+	__i = __head;							\
+	do {								\
+		if (__i->next == __head) { __i = 0; break; }		\
+		__i = __i->next;					\
+	} while (!cmpfn((const type)__i , ## args));			\
+	(type)__i;							\
+})
+
+#define SRLIST_FIND_W(srl, cmpfn, type, args...)			\
+({									\
+ 	struct srlist_head *__head = (struct srlist_head *) (srl);	\
+	struct srlist_head *__i;					\
+									\
+	ASSERT_WRITE_LOCK(__head);					\
+	__i = __head;							\
+	do {								\
+		if (__i->next == __head) { __i = 0; break; }		\
+		__i = __i->next;					\
+	} while (!cmpfn((const type)__i , ## args));			\
+	(type)__i;							\
+})
+
+#ifndef CONFIG_NETFILTER_DEBUG
+#define SRLIST_DELETE_WARN(estr, e, hstr) do{}while (0)
+#else
+#define SRLIST_DELETE_WARN(estr, e, hstr)			\
+	printk("TUPLE_DELETE: %s:%u `%s'(%p) not in %s.\n",	\
+	       __FILE__, __LINE__, estr, e, hstr)
+#endif
+
+#define SRLIST_DELETE(srl, elem)					\
+do {									\
+ 	struct srlist_head *__head = (struct srlist_head *) (srl);	\
+ 	struct srlist_head *__elem = (struct srlist_head *) (elem);	\
+	struct srlist_head *__i;					\
+									\
+	ASSERT_WRITE_LOCK(__head);					\
+	__i = __head;							\
+	while (1) {							\
+		struct srlist_head *__next = __i->next;			\
+									\
+		if (__next == __head) {					\
+			SRLIST_DELETE_WARN(#elem, __elem, #srl);	\
+			break;						\
+		}							\
+		if (__next == __elem) {					\
+			__i->next = __elem->next;			\
+			break;						\
+		}							\
+		__i = __next;						\
+	}								\
+} while (0)
+
+#define SRLIST_PREPEND(srl, elem)					\
+do {									\
+ 	struct srlist_head *__head = (struct srlist_head *) (srl);	\
+ 	struct srlist_head *__elem = (struct srlist_head *) (elem);	\
+									\
+	__elem->next = __head->next;					\
+	__head->next = __elem;						\
+} while (0)
+
+#endif
diff -urN ex1/include/linux/skbuff.h ex2/include/linux/skbuff.h
--- ex1/include/linux/skbuff.h	Sat Aug  3 21:20:56 2002
+++ ex2/include/linux/skbuff.h	Sat Aug  3 21:24:37 2002
@@ -1144,6 +1144,17 @@
 	if (nfct)
 		atomic_inc(&nfct->master->use);
 }
+static inline void
+skb_nf_forget(struct sk_buff *skb)
+{
+	nf_conntrack_put(skb->nfct);
+	skb->nfct = NULL;
+#ifdef CONFIG_NETFILTER_DEBUG
+	skb->nf_debug = 0;
+#endif
+}
+#else
+static inline void skb_nf_forget(struct sk_buff *skb) {}
 #endif
 
 #endif	/* __KERNEL__ */
diff -urN ex1/net/Config.in ex2/net/Config.in
--- ex1/net/Config.in	Sat Aug  3 21:21:01 2002
+++ ex2/net/Config.in	Sat Aug  3 21:24:41 2002
@@ -13,6 +13,7 @@
 bool 'Network packet filtering (replaces ipchains)' CONFIG_NETFILTER
 if [ "$CONFIG_NETFILTER" = "y" ]; then
    bool '  Network packet filtering debugging' CONFIG_NETFILTER_DEBUG
+   bool '  Netfilter hook statistics' CONFIG_NETFILTER_HOOK_STAT
 fi
 bool 'Socket Filtering'  CONFIG_FILTER
 tristate 'Unix domain sockets' CONFIG_UNIX
diff -urN ex1/net/core/netfilter.c ex2/net/core/netfilter.c
--- ex1/net/core/netfilter.c	Sat Aug  3 21:21:12 2002
+++ ex2/net/core/netfilter.c	Sat Aug  3 21:24:49 2002
@@ -47,6 +47,293 @@
 struct list_head nf_hooks[NPROTO][NF_MAX_HOOKS];
 static LIST_HEAD(nf_sockopts);
 
+#ifdef CONFIG_NETFILTER_HOOK_STAT
+
+/*
+ * menuconfig this under "Network options" >> "Netfilter hook statistics"
+ *
+ * The following code, up to the next #endif, implements per hook
+ * statistics counting. If enabled, look at /proc/net/nf_stat_hook*
+ * for the results.
+ *
+ */
+
+#include <linux/slab.h>
+#include <linux/proc_fs.h>
+#include <asm/msr.h>
+
+/*
+ * nf_stat_hook_proc[pf][hooknum] is a flag per protocol/hook, telling
+ * whether we have already created the /proc/net/nf_stat_hook_X.Y file.
+ * The array is only consulted during module registration. This code
+ * never removes the proc files; when all hook functions unregister,
+ * an empty file remains.
+ *
+ * Not used under normal per-packet processing.
+ */
+static unsigned char nf_stat_hook_proc[NPROTO][NF_MAX_HOOKS];
+
+/*
+ * struct nf_stat_hook_sample is used in nf_inject(), to record the
+ * beginning of the operation.	 After calling the hook function,
+ * it is reused to compute the duration of the hook function call,
+ * which is then recorded in nf_hook_ops->stat[percpu].
+ *
+ * CPU-local data on the stack, unshared.
+ */
+struct nf_stat_hook_sample {
+	unsigned long long stamp;
+};
+
+/*
+ * struct nf_stat_hook is our main statistics state structure.
+ * It is kept cache-aligned and per-cpu, summing the per-cpu
+ * values only when read through the /proc interface.
+ *
+ * CPU-local data, read across all CPUs only on user request.
+ * Updated locally on each CPU, one update per packet and hook function.
+ */
+struct nf_stat_hook {
+	unsigned long long count;
+	unsigned long long sum;
+} __attribute__ ((__aligned__(SMP_CACHE_BYTES)));
+
+/*
+ * The nf_stat_hook structures come from our private slab cache.
+ */
+static kmem_cache_t *nf_stat_hook_slab;
+
+/*
+ * nf_stat_hook_zero() is the slab ctor/dtor
+ */
+static void nf_stat_hook_zero(void *data, kmem_cache_t *slab, unsigned long x)
+{
+	struct nf_stat_hook *stat = data;
+	int i;
+
+	for (i=0; i<NR_CPUS; i++,stat++)
+		stat->count = stat->sum = 0;
+}
+
+/*
+ * nf_stat_hook_setup() is the one-time initialization routine.
+ * It allocates the slab cache for our statistics counters,
+ * and initializes the "proc registration" flag array.
+ */
+static void __init nf_stat_hook_setup(void)
+{
+	/* early rdtsc to catch booboo at boot time */
+	{ struct nf_stat_hook_sample sample; rdtscll(sample.stamp); }
+
+	nf_stat_hook_slab = kmem_cache_create("nf_stat_hook",
+				NR_CPUS * sizeof(struct nf_stat_hook),
+				0, SLAB_HWCACHE_ALIGN,
+				nf_stat_hook_zero, nf_stat_hook_zero);
+	if (!nf_stat_hook_slab)
+		printk(KERN_ERR "nf_stat_hook will NOT WORK - no slab.\n");
+
+	memset(nf_stat_hook_proc, 0, sizeof(nf_stat_hook_proc));
+}
+
+/*
+ * nf_stat_hook_read_proc() is a proc_fs read_proc() callback.
+ * Called per protocol/hook, the statistics of all netfilter
+ * hook elements sitting on that hook, are shown, in priority
+ * order. On SMP, the per-cpu counters are summed here.
+ * For accuracy, maybe we need to take some write lock. Later.
+ *
+ * Readings might look strange, until such locking is done.
+ * If you need to compensate, read several times, and throw
+ * out the strange results. Look for silly non-monotony.
+ *
+ * Output fields are seperated by a single blank, and represent:
+ * [0] address of 'struct nf_hook_ops'. (pointer, in unadorned 8-byte hex)
+ * [1] address of nf_hook_ops->hook() function pointer. When the
+ *     hook module is built into the kernel, you can find this
+ *     in System.map. (pointer, in unadorned 8-byte hex)
+ * [2] hook priority. (signed integer, in ascii)
+ * [3] number of times hook was called. (unsigned 64 bit integer, in ascii)
+ * [4] total number of cycles spent in the hook function, measured by
+ *     summing the rdtscll() differences across the calls. (unsigned
+ *     64 bit integer, in ascii)
+ *
+ * Additional fields may be added in the future; if any field is eventually
+ * retired, it will be set to neutral values: '00000000' for the pointer
+ * fields, and '0' for the integer fields. That's theory, not guarantee. :)
+ */
+static int nf_stat_hook_read_proc(
+	char *page,
+	char **start,
+	off_t off,
+	int count,
+	int *eof,
+	void *data
+) {
+	struct list_head *l;
+	int res;
+
+	for (	res = 0, l = ((struct list_head *)data)->next;
+		l != data;
+		l = l->next
+	) {
+		int i;
+		struct nf_hook_ops *elem = (struct nf_hook_ops *) l;
+		struct nf_stat_hook *stat = elem->hook_stat;
+
+		if (stat) {
+			unsigned long long count;
+			unsigned long long sum;
+			/* maybe write_lock something here */
+			for (i=0, count=0, sum=0; i<NR_CPUS; i++, stat++) {
+				count += stat->count;
+				sum += stat->sum;
+			}
+			/* and then write_unlock it here */
+			i = sprintf(page+res, "%p %p %d %Lu %Lu\n",
+					elem, elem->hook, elem->priority,
+					count, sum);
+		} else {
+			i = sprintf(page+res, "%p %p %d 0 0\n",
+					elem, elem->hook, elem->priority);
+		}
+		if (i <= 0)
+			break;
+		res += i;
+	}
+	return res;
+}
+
+/*
+ * nf_stat_hook_register() is called whenever a hook element registers.
+ * When neccessary, we create a /proc/net/nf_stat_hook* file here,
+ * and we always allocate one struct nf_stat_hook.
+ */
+static void nf_stat_hook_register(struct nf_hook_ops *elem)
+{
+	elem->hook_stat = (NULL == nf_stat_hook_slab)
+		? 0 : kmem_cache_alloc(nf_stat_hook_slab, SLAB_ATOMIC);
+	if (!elem->hook_stat) return;
+	if (!nf_stat_hook_proc[elem->pf][elem->hooknum]) {
+		char buf[64];
+		char hookname_buf[16];
+		char pfname_buf[16];
+		char *hookname;
+		char *pfname;
+		struct proc_dir_entry *proc;
+
+		switch(elem->pf) {
+			case 2:
+				pfname = "ipv4";
+				switch(elem->hooknum) {
+					case 0:
+						hookname = "PRE-ROUTING";
+						break;
+					case 1:
+						hookname = "LOCAL-IN";
+						break;
+					case 2:
+						hookname = "FORWARD";
+						break;
+					case 3:
+						hookname = "LOCAL-OUT";
+						break;
+					case 4:
+						hookname = "POST-ROUTING";
+						break;
+					default:
+						sprintf(hookname_buf, "hook%d",
+							elem->hooknum);
+						hookname = hookname_buf;
+						break;
+				}
+				break;
+			default:
+				sprintf(hookname_buf, "hook%d",
+					elem->hooknum);
+				hookname = hookname_buf;
+				sprintf(pfname_buf, "pf%d",
+					elem->pf);
+				pfname = pfname_buf;
+				break;
+		}
+		sprintf(buf, "net/nf_stat_hook_%s.%s", pfname, hookname);
+		proc = create_proc_read_entry(buf, 0644, NULL,
+			nf_stat_hook_read_proc,
+			&nf_hooks[elem->pf][elem->hooknum]
+		);
+		if (!proc) {
+			printk(KERN_ERR "cannot create %s\n", buf);
+			kmem_cache_free(nf_stat_hook_slab, elem->hook_stat);
+			elem->hook_stat = 0;
+			return;
+		}
+		proc->owner = THIS_MODULE;
+	}
+	nf_stat_hook_proc[elem->pf][elem->hooknum]++;
+}
+
+/*
+ * nf_stat_hook_unregister() is called when a hook element unregisters.
+ * The statistics structure is freed, but we NEVER remove the /proc/net
+ * file entry. Maybe we should. nf_stat_hook_proc[][] contains the correct
+ * counter, I think (modulo races).
+ */
+static void nf_stat_hook_unregister(struct nf_hook_ops *elem)
+{
+	if (elem->hook_stat)
+		kmem_cache_free(nf_stat_hook_slab, elem->hook_stat);
+	nf_stat_hook_proc[elem->pf][elem->hooknum]--;
+}
+
+/*
+ * Finally, the next two functions implement the real timekeeping.
+ * If rdtscll() proves problematic, these have to be changed.
+ * The _begin() function is called before a specific hook entry
+ * function gets called - it starts the timer.
+ * The _end() function is called after the hook entry function,
+ * and it stops the timer, and remembers the interval in the
+ * statistics structure (per-cpu).
+ */
+
+static inline void nf_stat_hook_begin(struct nf_stat_hook_sample *sample)
+{
+	rdtscll(sample->stamp);
+}
+
+static inline void nf_stat_hook_end(
+	struct nf_stat_hook_sample *sample,
+	struct nf_hook_ops *elem,
+	int verdict
+) {
+	struct nf_stat_hook *stat = elem->hook_stat;
+	struct nf_stat_hook_sample now;
+	if (!stat) return;
+	rdtscll(now.stamp); now.stamp -= sample->stamp;
+	stat += smp_processor_id();
+	stat->count++;
+	stat->sum += now.stamp;
+}
+
+#else
+
+/*
+ * Here, a set of empty macros provides for nice ifdef free callers into
+ * this statistics code. If CONFIG_NETFILTER_HOOK_STAT is NOT defined,
+ * these should make the compiled code identical to what we had before.
+ */
+struct nf_stat_hook_sample {};
+#define nf_stat_hook_begin(a) do{}while(0)
+#define nf_stat_hook_end(a,b,c) do{}while(0)
+#define nf_stat_hook_register(a) do{}while(0)
+#define nf_stat_hook_unregister(a) do{}while(0)
+#define nf_stat_hook_setup() do{}while(0)
+
+/*
+ * End of new statistics stuff. On with the traditional net/core/netfilter.c
+ * Search below for "nf_stat_hook" to see where we call into the statistics.
+ */
+#endif
+
 /* 
  * A queue handler may be registered for each protocol.  Each is protected by
  * long term mutex.  The handler must provide an an outfn() to accept packets
@@ -68,6 +355,7 @@
 		if (reg->priority < ((struct nf_hook_ops *)i)->priority)
 			break;
 	}
+	nf_stat_hook_register(reg);
 	list_add(&reg->list, i->prev);
 	br_write_unlock_bh(BR_NETPROTO_LOCK);
 	return 0;
@@ -77,6 +365,7 @@
 {
 	br_write_lock_bh(BR_NETPROTO_LOCK);
 	list_del(&reg->list);
+	nf_stat_hook_unregister(reg);
 	br_write_unlock_bh(BR_NETPROTO_LOCK);
 }
 
@@ -346,14 +635,19 @@
 {
 	for (*i = (*i)->next; *i != head; *i = (*i)->next) {
 		struct nf_hook_ops *elem = (struct nf_hook_ops *)*i;
+		struct nf_stat_hook_sample sample;
+		nf_stat_hook_begin(&sample);
 		switch (elem->hook(hook, skb, indev, outdev, okfn)) {
 		case NF_QUEUE:
+			nf_stat_hook_end(&sample, elem, NF_QUEUE);
 			return NF_QUEUE;
 
 		case NF_STOLEN:
+			nf_stat_hook_end(&sample, elem, NF_STOLEN);
 			return NF_STOLEN;
 
 		case NF_DROP:
+			nf_stat_hook_end(&sample, elem, NF_DROP);
 			return NF_DROP;
 
 		case NF_REPEAT:
@@ -369,6 +663,7 @@
 				elem->hook, hook);
 #endif
 		}
+		nf_stat_hook_end(&sample, elem, NF_ACCEPT);
 	}
 	return NF_ACCEPT;
 }
@@ -638,4 +933,5 @@
 		for (h = 0; h < NF_MAX_HOOKS; h++)
 			INIT_LIST_HEAD(&nf_hooks[i][h]);
 	}
+	nf_stat_hook_setup();
 }
diff -urN ex1/net/core/skbuff.c ex2/net/core/skbuff.c
--- ex1/net/core/skbuff.c	Sat Aug  3 21:21:00 2002
+++ ex2/net/core/skbuff.c	Sat Aug  3 21:24:40 2002
@@ -323,9 +323,7 @@
 		}
 		skb->destructor(skb);
 	}
-#ifdef CONFIG_NETFILTER
-	nf_conntrack_put(skb->nfct);
-#endif
+	skb_nf_forget(skb);
 	skb_headerinit(skb, NULL, 0);  /* clean state */
 	kfree_skbmem(skb);
 }
diff -urN ex1/net/ipv4/ip_gre.c ex2/net/ipv4/ip_gre.c
--- ex1/net/ipv4/ip_gre.c	Sat Aug  3 21:21:16 2002
+++ ex2/net/ipv4/ip_gre.c	Sat Aug  3 21:24:54 2002
@@ -644,13 +644,7 @@
 		skb->dev = tunnel->dev;
 		dst_release(skb->dst);
 		skb->dst = NULL;
-#ifdef CONFIG_NETFILTER
-		nf_conntrack_put(skb->nfct);
-		skb->nfct = NULL;
-#ifdef CONFIG_NETFILTER_DEBUG
-		skb->nf_debug = 0;
-#endif
-#endif
+		skb_nf_forget(skb);
 		ipgre_ecn_decapsulate(iph, skb);
 		netif_rx(skb);
 		read_unlock(&ipgre_lock);
@@ -876,13 +870,7 @@
 		}
 	}
 
-#ifdef CONFIG_NETFILTER
-	nf_conntrack_put(skb->nfct);
-	skb->nfct = NULL;
-#ifdef CONFIG_NETFILTER_DEBUG
-	skb->nf_debug = 0;
-#endif
-#endif
+	skb_nf_forget(skb);
 
 	IPTUNNEL_XMIT();
 	tunnel->recursion--;
diff -urN ex1/net/ipv4/ip_input.c ex2/net/ipv4/ip_input.c
--- ex1/net/ipv4/ip_input.c	Sat Aug  3 21:20:57 2002
+++ ex2/net/ipv4/ip_input.c	Sat Aug  3 21:24:37 2002
@@ -226,12 +226,9 @@
 
 	__skb_pull(skb, ihl);
 
-#ifdef CONFIG_NETFILTER
 	/* Free reference early: we don't need it any more, and it may
            hold ip_conntrack module loaded indefinitely. */
-	nf_conntrack_put(skb->nfct);
-	skb->nfct = NULL;
-#endif /*CONFIG_NETFILTER*/
+	skb_nf_forget(skb);
 
         /* Point into the IP datagram, just past the header. */
         skb->h.raw = skb->data;
diff -urN ex1/net/ipv4/ipip.c ex2/net/ipv4/ipip.c
--- ex1/net/ipv4/ipip.c	Sat Aug  3 21:21:14 2002
+++ ex2/net/ipv4/ipip.c	Sat Aug  3 21:24:50 2002
@@ -493,13 +493,7 @@
 		skb->dev = tunnel->dev;
 		dst_release(skb->dst);
 		skb->dst = NULL;
-#ifdef CONFIG_NETFILTER
-		nf_conntrack_put(skb->nfct);
-		skb->nfct = NULL;
-#ifdef CONFIG_NETFILTER_DEBUG
-		skb->nf_debug = 0;
-#endif
-#endif
+		skb_nf_forget(skb);
 		ipip_ecn_decapsulate(iph, skb);
 		netif_rx(skb);
 		read_unlock(&ipip_lock);
@@ -644,13 +638,7 @@
 	if ((iph->ttl = tiph->ttl) == 0)
 		iph->ttl	=	old_iph->ttl;
 
-#ifdef CONFIG_NETFILTER
-	nf_conntrack_put(skb->nfct);
-	skb->nfct = NULL;
-#ifdef CONFIG_NETFILTER_DEBUG
-	skb->nf_debug = 0;
-#endif
-#endif
+	skb_nf_forget(skb);
 
 	IPTUNNEL_XMIT();
 	tunnel->recursion--;
diff -urN ex1/net/ipv4/ipmr.c ex2/net/ipv4/ipmr.c
--- ex1/net/ipv4/ipmr.c	Sat Aug  3 21:21:13 2002
+++ ex2/net/ipv4/ipmr.c	Sat Aug  3 21:24:49 2002
@@ -1096,10 +1096,7 @@
 
 	skb->h.ipiph = skb->nh.iph;
 	skb->nh.iph = iph;
-#ifdef CONFIG_NETFILTER
-	nf_conntrack_put(skb->nfct);
-	skb->nfct = NULL;
-#endif
+	skb_nf_forget(skb);
 }
 
 static inline int ipmr_forward_finish(struct sk_buff *skb)
@@ -1441,10 +1438,7 @@
 	skb->dst = NULL;
 	((struct net_device_stats*)reg_dev->priv)->rx_bytes += skb->len;
 	((struct net_device_stats*)reg_dev->priv)->rx_packets++;
-#ifdef CONFIG_NETFILTER
-	nf_conntrack_put(skb->nfct);
-	skb->nfct = NULL;
-#endif
+	skb_nf_forget(skb);
 	netif_rx(skb);
 	dev_put(reg_dev);
 	return 0;
@@ -1508,10 +1502,7 @@
 	((struct net_device_stats*)reg_dev->priv)->rx_bytes += skb->len;
 	((struct net_device_stats*)reg_dev->priv)->rx_packets++;
 	skb->dst = NULL;
-#ifdef CONFIG_NETFILTER
-	nf_conntrack_put(skb->nfct);
-	skb->nfct = NULL;
-#endif
+	skb_nf_forget(skb);
 	netif_rx(skb);
 	dev_put(reg_dev);
 	return 0;
diff -urN ex1/net/ipv4/netfilter/ip_conntrack_core.c ex2/net/ipv4/netfilter/ip_conntrack_core.c
--- ex1/net/ipv4/netfilter/ip_conntrack_core.c	Sat Aug  3 21:20:55 2002
+++ ex2/net/ipv4/netfilter/ip_conntrack_core.c	Sat Aug  3 21:24:34 2002
@@ -52,9 +52,31 @@
 unsigned int ip_conntrack_htable_size = 0;
 static int ip_conntrack_max = 0;
 static atomic_t ip_conntrack_count = ATOMIC_INIT(0);
-struct list_head *ip_conntrack_hash;
+struct srlist_head *ip_conntrack_hash;
+static int ip_conntrack_hash_vmalloced;
 static kmem_cache_t *ip_conntrack_cachep;
 
+static __init void alloc_ip_conntrack_hash(void)
+{
+	const size_t s = sizeof(*ip_conntrack_hash) * ip_conntrack_htable_size;
+	IP_NF_ASSERT(ip_conntrack_hash == 0);
+	ip_conntrack_hash = (void *) __get_free_pages(GFP_KERNEL, get_order(s));
+	if (!ip_conntrack_hash) {
+		ip_conntrack_hash = vmalloc(s);
+		if (!ip_conntrack_hash) BUG();
+		ip_conntrack_hash_vmalloced = 1;
+	}
+}
+
+static void free_ip_conntrack_hash(void)
+{
+	const size_t s = sizeof(*ip_conntrack_hash) * ip_conntrack_htable_size;
+	if (ip_conntrack_hash_vmalloced)
+		vfree(ip_conntrack_hash);
+	else
+		free_pages((unsigned long)ip_conntrack_hash, get_order(s));
+}
+
 extern struct ip_conntrack_protocol ip_conntrack_generic_protocol;
 
 static inline int proto_cmpfn(const struct ip_conntrack_protocol *curr,
@@ -155,12 +177,12 @@
 {
 	MUST_BE_WRITE_LOCKED(&ip_conntrack_lock);
 	/* Remove from both hash lists: must not NULL out next ptrs,
-           otherwise we'll look unconfirmed.  Fortunately, LIST_DELETE
+           otherwise we'll look unconfirmed.  Fortunately, SRLIST_DELETE
            doesn't do this. --RR */
-	LIST_DELETE(&ip_conntrack_hash
+	SRLIST_DELETE(&ip_conntrack_hash
 		    [hash_conntrack(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple)],
 		    &ct->tuplehash[IP_CT_DIR_ORIGINAL]);
-	LIST_DELETE(&ip_conntrack_hash
+	SRLIST_DELETE(&ip_conntrack_hash
 		    [hash_conntrack(&ct->tuplehash[IP_CT_DIR_REPLY].tuple)],
 		    &ct->tuplehash[IP_CT_DIR_REPLY]);
 	/* If our expected is in the list, take it out. */
@@ -196,14 +218,46 @@
 	atomic_dec(&ip_conntrack_count);
 }
 
+static inline int later_than(unsigned long this, unsigned long ref)
+{
+	return	this > ref
+	     || (ref > ((unsigned long)-1) - 864000 && this < ref + 864000);
+}
+
+static inline int earlier_than(unsigned long this, unsigned long ref)
+{
+	return this != ref && !later_than(this, ref);
+}
+
+static inline void activate_timeout_target(struct ip_conntrack *ct)
+{
+	ct->timeout.expires = ct->timeout_target;
+	add_timer(&ct->timeout);
+}
+
 static void death_by_timeout(unsigned long ul_conntrack)
 {
 	struct ip_conntrack *ct = (void *)ul_conntrack;
 
 	WRITE_LOCK(&ip_conntrack_lock);
+	if (later_than(ct->timeout_target, ct->timeout.expires)) {
+		activate_timeout_target(ct);
+		WRITE_UNLOCK(&ip_conntrack_lock);
+		return;
+	}
+	clean_from_lists(ct);
+	WRITE_UNLOCK(&ip_conntrack_lock);
+	ip_conntrack_put(ct);
+}
+
+int ip_ct_sudden_death(struct ip_conntrack *ct)
+{
+	if (!del_timer(&ct->timeout)) return 0;
+	WRITE_LOCK(&ip_conntrack_lock);
 	clean_from_lists(ct);
 	WRITE_UNLOCK(&ip_conntrack_lock);
 	ip_conntrack_put(ct);
+	return 1;
 }
 
 static inline int
@@ -223,7 +277,7 @@
 	struct ip_conntrack_tuple_hash *h;
 
 	MUST_BE_READ_LOCKED(&ip_conntrack_lock);
-	h = LIST_FIND(&ip_conntrack_hash[hash_conntrack(tuple)],
+	h = SRLIST_FIND(&ip_conntrack_hash[hash_conntrack(tuple)],
 		      conntrack_tuple_cmp,
 		      struct ip_conntrack_tuple_hash *,
 		      tuple, ignored_conntrack);
@@ -271,7 +325,7 @@
 int
 __ip_conntrack_confirm(struct nf_ct_info *nfct)
 {
-	unsigned int hash, repl_hash;
+	u_int32_t hash, repl_hash;
 	struct ip_conntrack *ct;
 	enum ip_conntrack_info ctinfo;
 
@@ -301,23 +355,19 @@
 	/* See if there's one in the list already, including reverse:
            NAT could have grabbed it without realizing, since we're
            not in the hash.  If there is, we lost race. */
-	if (!LIST_FIND(&ip_conntrack_hash[hash],
+	if (!SRLIST_FIND(&ip_conntrack_hash[hash],
 		       conntrack_tuple_cmp,
 		       struct ip_conntrack_tuple_hash *,
 		       &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple, NULL)
-	    && !LIST_FIND(&ip_conntrack_hash[repl_hash],
+	    && !SRLIST_FIND(&ip_conntrack_hash[repl_hash],
 			  conntrack_tuple_cmp,
 			  struct ip_conntrack_tuple_hash *,
 			  &ct->tuplehash[IP_CT_DIR_REPLY].tuple, NULL)) {
-		list_prepend(&ip_conntrack_hash[hash],
+		SRLIST_PREPEND(&ip_conntrack_hash[hash],
 			     &ct->tuplehash[IP_CT_DIR_ORIGINAL]);
-		list_prepend(&ip_conntrack_hash[repl_hash],
+		SRLIST_PREPEND(&ip_conntrack_hash[repl_hash],
 			     &ct->tuplehash[IP_CT_DIR_REPLY]);
-		/* Timer relative to confirmation time, not original
-		   setting time, otherwise we'd get timer wrap in
-		   wierd delay cases. */
-		ct->timeout.expires += jiffies;
-		add_timer(&ct->timeout);
+		activate_timeout_target(ct);
 		atomic_inc(&ct->ct_general.use);
 		WRITE_UNLOCK(&ip_conntrack_lock);
 		return NF_ACCEPT;
@@ -435,19 +485,22 @@
 
 /* There's a small race here where we may free a just-assured
    connection.  Too bad: we're in trouble anyway. */
-static inline int unreplied(const struct ip_conntrack_tuple_hash *i)
+static inline int unreplied(const struct ip_conntrack_tuple_hash *i,
+		struct ip_conntrack_tuple_hash **lru)
 {
-	return !(i->ctrack->status & IPS_ASSURED);
+	if (!(i->ctrack->status & IPS_ASSURED))
+		*lru = (struct ip_conntrack_tuple_hash *) i;
+	return 0;
 }
 
-static int early_drop(struct list_head *chain)
+static int early_drop(struct srlist_head *chain)
 {
 	/* Traverse backwards: gives us oldest, which is roughly LRU */
-	struct ip_conntrack_tuple_hash *h;
+	struct ip_conntrack_tuple_hash *h = 0;
 	int dropped = 0;
 
 	READ_LOCK(&ip_conntrack_lock);
-	h = LIST_FIND(chain, unreplied, struct ip_conntrack_tuple_hash *);
+	SRLIST_FIND(chain, unreplied, struct ip_conntrack_tuple_hash *, &h);
 	if (h)
 		atomic_inc(&h->ctrack->ct_general.use);
 	READ_UNLOCK(&ip_conntrack_lock);
@@ -455,10 +508,7 @@
 	if (!h)
 		return dropped;
 
-	if (del_timer(&h->ctrack->timeout)) {
-		death_by_timeout((unsigned long)h->ctrack);
-		dropped = 1;
-	}
+	dropped = ip_ct_sudden_death(h->ctrack);
 	ip_conntrack_put(h->ctrack);
 	return dropped;
 }
@@ -485,22 +535,19 @@
 {
 	struct ip_conntrack *conntrack;
 	struct ip_conntrack_tuple repl_tuple;
-	size_t hash, repl_hash;
 	struct ip_conntrack_expect *expected;
 	int i;
-	static unsigned int drop_next = 0;
-
-	hash = hash_conntrack(tuple);
 
 	if (ip_conntrack_max &&
 	    atomic_read(&ip_conntrack_count) >= ip_conntrack_max) {
 		/* Try dropping from random chain, or else from the
                    chain about to put into (in case they're trying to
                    bomb one hash chain). */
-		unsigned int next = (drop_next++)%ip_conntrack_htable_size;
+		static u_int32_t drop_rotor = 0;
+		u_int32_t next = (drop_rotor++)%ip_conntrack_htable_size;
 
 		if (!early_drop(&ip_conntrack_hash[next])
-		    && !early_drop(&ip_conntrack_hash[hash])) {
+		    && !early_drop(&ip_conntrack_hash[hash_conntrack(tuple)])) {
 			if (net_ratelimit())
 				printk(KERN_WARNING
 				       "ip_conntrack: table full, dropping"
@@ -513,7 +560,6 @@
 		DEBUGP("Can't invert tuple.\n");
 		return NULL;
 	}
-	repl_hash = hash_conntrack(&repl_tuple);
 
 	conntrack = kmem_cache_alloc(ip_conntrack_cachep, GFP_ATOMIC);
 	if (!conntrack) {
@@ -689,8 +735,7 @@
 	ret = proto->packet(ct, (*pskb)->nh.iph, (*pskb)->len, ctinfo);
 	if (ret == -1) {
 		/* Invalid */
-		nf_conntrack_put((*pskb)->nfct);
-		(*pskb)->nfct = NULL;
+		skb_nf_forget(*pskb);
 		return NF_ACCEPT;
 	}
 
@@ -699,8 +744,7 @@
 				       ct, ctinfo);
 		if (ret == -1) {
 			/* Invalid */
-			nf_conntrack_put((*pskb)->nfct);
-			(*pskb)->nfct = NULL;
+			skb_nf_forget(*pskb);
 			return NF_ACCEPT;
 		}
 	}
@@ -808,7 +852,7 @@
 	return 0;
 }
 
-static inline int unhelp(struct ip_conntrack_tuple_hash *i,
+static inline int unhelp(const struct ip_conntrack_tuple_hash *i,
 			 const struct ip_conntrack_helper *me)
 {
 	if (i->ctrack->helper == me) {
@@ -834,7 +878,7 @@
 
 	/* Get rid of expecteds, set helpers to NULL. */
 	for (i = 0; i < ip_conntrack_htable_size; i++)
-		LIST_FIND_W(&ip_conntrack_hash[i], unhelp,
+		SRLIST_FIND_W(&ip_conntrack_hash[i], unhelp,
 			    struct ip_conntrack_tuple_hash *, me);
 	WRITE_UNLOCK(&ip_conntrack_lock);
 
@@ -851,15 +895,11 @@
 	IP_NF_ASSERT(ct->timeout.data == (unsigned long)ct);
 
 	WRITE_LOCK(&ip_conntrack_lock);
-	/* If not in hash table, timer will not be active yet */
-	if (!is_confirmed(ct))
-		ct->timeout.expires = extra_jiffies;
-	else {
-		/* Need del_timer for race avoidance (may already be dying). */
-		if (del_timer(&ct->timeout)) {
-			ct->timeout.expires = jiffies + extra_jiffies;
-			add_timer(&ct->timeout);
-		}
+	ct->timeout_target = jiffies + extra_jiffies;
+	if (	is_confirmed(ct)
+	     && earlier_than(ct->timeout_target, ct->timeout.expires)
+	     &&	del_timer(&ct->timeout)) {
+		activate_timeout_target(ct);
 	}
 	WRITE_UNLOCK(&ip_conntrack_lock);
 }
@@ -942,7 +982,7 @@
 
 	READ_LOCK(&ip_conntrack_lock);
 	for (i = 0; !h && i < ip_conntrack_htable_size; i++) {
-		h = LIST_FIND(&ip_conntrack_hash[i], do_kill,
+		h = SRLIST_FIND(&ip_conntrack_hash[i], do_kill,
 			      struct ip_conntrack_tuple_hash *, kill, data);
 	}
 	if (h)
@@ -961,10 +1001,7 @@
 	/* This is order n^2, by the way. */
 	while ((h = get_next_corpse(kill, data)) != NULL) {
 		/* Time to push up daises... */
-		if (del_timer(&h->ctrack->timeout))
-			death_by_timeout((unsigned long)h->ctrack);
-		/* ... else the timer will get him soon. */
-
+		ip_ct_sudden_death(h->ctrack);
 		ip_conntrack_put(h->ctrack);
 	}
 }
@@ -1073,7 +1110,7 @@
 	}
 
 	kmem_cache_destroy(ip_conntrack_cachep);
-	vfree(ip_conntrack_hash);
+	free_ip_conntrack_hash();
 	nf_unregister_sockopt(&so_getorigdst);
 }
 
@@ -1092,7 +1129,7 @@
  	} else {
 		ip_conntrack_htable_size
 			= (((num_physpages << PAGE_SHIFT) / 16384)
-			   / sizeof(struct list_head));
+			   / sizeof(*ip_conntrack_hash));
 		if (num_physpages > (1024 * 1024 * 1024 / PAGE_SIZE))
 			ip_conntrack_htable_size = 8192;
 		if (ip_conntrack_htable_size < 16)
@@ -1107,8 +1144,7 @@
 	if (ret != 0)
 		return ret;
 
-	ip_conntrack_hash = vmalloc(sizeof(struct list_head)
-				    * ip_conntrack_htable_size);
+	alloc_ip_conntrack_hash();
 	if (!ip_conntrack_hash) {
 		nf_unregister_sockopt(&so_getorigdst);
 		return -ENOMEM;
@@ -1119,7 +1155,7 @@
 	                                        SLAB_HWCACHE_ALIGN, NULL, NULL);
 	if (!ip_conntrack_cachep) {
 		printk(KERN_ERR "Unable to create ip_conntrack slab cache\n");
-		vfree(ip_conntrack_hash);
+		free_ip_conntrack_hash();
 		nf_unregister_sockopt(&so_getorigdst);
 		return -ENOMEM;
 	}
@@ -1133,7 +1169,7 @@
 	WRITE_UNLOCK(&ip_conntrack_lock);
 
 	for (i = 0; i < ip_conntrack_htable_size; i++)
-		INIT_LIST_HEAD(&ip_conntrack_hash[i]);
+		INIT_SRLIST_HEAD(&ip_conntrack_hash[i]);
 
 /* This is fucking braindead.  There is NO WAY of doing this without
    the CONFIG_SYSCTL unless you don't want to detect errors.
@@ -1143,7 +1179,7 @@
 		= register_sysctl_table(ip_conntrack_root_table, 0);
 	if (ip_conntrack_sysctl_header == NULL) {
 		kmem_cache_destroy(ip_conntrack_cachep);
-		vfree(ip_conntrack_hash);
+		free_ip_conntrack_hash();
 		nf_unregister_sockopt(&so_getorigdst);
 		return -ENOMEM;
 	}
diff -urN ex1/net/ipv4/netfilter/ip_conntrack_proto_icmp.c ex2/net/ipv4/netfilter/ip_conntrack_proto_icmp.c
--- ex1/net/ipv4/netfilter/ip_conntrack_proto_icmp.c	Sat Aug  3 21:20:56 2002
+++ ex2/net/ipv4/netfilter/ip_conntrack_proto_icmp.c	Sat Aug  3 21:24:36 2002
@@ -77,9 +77,8 @@
            means this will only run once even if count hits zero twice
            (theoretically possible with SMP) */
 	if (CTINFO2DIR(ctinfo) == IP_CT_DIR_REPLY) {
-		if (atomic_dec_and_test(&ct->proto.icmp.count)
-		    && del_timer(&ct->timeout))
-			ct->timeout.function((unsigned long)ct);
+		if (atomic_dec_and_test(&ct->proto.icmp.count))
+			ip_ct_sudden_death(ct);
 	} else {
 		atomic_inc(&ct->proto.icmp.count);
 		ip_ct_refresh(ct, ICMP_TIMEOUT);
diff -urN ex1/net/ipv4/netfilter/ip_conntrack_proto_tcp.c ex2/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
--- ex1/net/ipv4/netfilter/ip_conntrack_proto_tcp.c	Sat Aug  3 21:21:12 2002
+++ ex2/net/ipv4/netfilter/ip_conntrack_proto_tcp.c	Sat Aug  3 21:24:49 2002
@@ -189,8 +189,7 @@
 	   problem case, so we can delete the conntrack
 	   immediately.  --RR */
 	if (!(conntrack->status & IPS_SEEN_REPLY) && tcph->rst) {
-		if (del_timer(&conntrack->timeout))
-			conntrack->timeout.function((unsigned long)conntrack);
+		ip_ct_sudden_death(conntrack);
 	} else {
 		/* Set ASSURED if we see see valid ack in ESTABLISHED after SYN_RECV */
 		if (oldtcpstate == TCP_CONNTRACK_SYN_RECV
diff -urN ex1/net/ipv4/netfilter/ip_conntrack_standalone.c ex2/net/ipv4/netfilter/ip_conntrack_standalone.c
--- ex1/net/ipv4/netfilter/ip_conntrack_standalone.c	Sat Aug  3 21:21:12 2002
+++ ex2/net/ipv4/netfilter/ip_conntrack_standalone.c	Sat Aug  3 21:24:48 2002
@@ -83,7 +83,7 @@
 		      conntrack->tuplehash[IP_CT_DIR_ORIGINAL]
 		      .tuple.dst.protonum,
 		      timer_pending(&conntrack->timeout)
-		      ? (conntrack->timeout.expires - jiffies)/HZ : 0);
+		      ? (conntrack->timeout_target - jiffies)/HZ : 0);
 
 	len += proto->print_conntrack(buffer + len, conntrack);
 	len += print_tuple(buffer + len,
@@ -140,7 +140,7 @@
 	READ_LOCK(&ip_conntrack_lock);
 	/* Traverse hash; print originals then reply. */
 	for (i = 0; i < ip_conntrack_htable_size; i++) {
-		if (LIST_FIND(&ip_conntrack_hash[i], conntrack_iterate,
+		if (SRLIST_FIND(&ip_conntrack_hash[i], conntrack_iterate,
 			      struct ip_conntrack_tuple_hash *,
 			      buffer, offset, &upto, &len, length))
 			goto finished;
diff -urN ex1/net/ipv4/netfilter/ipt_REJECT.c ex2/net/ipv4/netfilter/ipt_REJECT.c
--- ex1/net/ipv4/netfilter/ipt_REJECT.c	Sat Aug  3 21:21:04 2002
+++ ex2/net/ipv4/netfilter/ipt_REJECT.c	Sat Aug  3 21:24:43 2002
@@ -69,12 +69,8 @@
 		return;
 
 	/* This packet will not be the same as the other: clear nf fields */
-	nf_conntrack_put(nskb->nfct);
-	nskb->nfct = NULL;
 	nskb->nfcache = 0;
-#ifdef CONFIG_NETFILTER_DEBUG
-	nskb->nf_debug = 0;
-#endif
+	skb_nf_forget(nskb);
 
 	tcph = (struct tcphdr *)((u_int32_t*)nskb->nh.iph + nskb->nh.iph->ihl);
 
diff -urN ex1/net/ipv6/sit.c ex2/net/ipv6/sit.c
--- ex1/net/ipv6/sit.c	Sat Aug  3 21:21:17 2002
+++ ex2/net/ipv6/sit.c	Sat Aug  3 21:24:54 2002
@@ -403,13 +403,7 @@
 		skb->dev = tunnel->dev;
 		dst_release(skb->dst);
 		skb->dst = NULL;
-#ifdef CONFIG_NETFILTER
-		nf_conntrack_put(skb->nfct);
-		skb->nfct = NULL;
-#ifdef CONFIG_NETFILTER_DEBUG
-		skb->nf_debug = 0;
-#endif
-#endif
+		skb_nf_forget(skb);
 		ipip6_ecn_decapsulate(iph, skb);
 		netif_rx(skb);
 		read_unlock(&ipip6_lock);
@@ -600,13 +594,7 @@
 	if ((iph->ttl = tiph->ttl) == 0)
 		iph->ttl	=	iph6->hop_limit;
 
-#ifdef CONFIG_NETFILTER
-	nf_conntrack_put(skb->nfct);
-	skb->nfct = NULL;
-#ifdef CONFIG_NETFILTER_DEBUG
-	skb->nf_debug = 0;
-#endif
-#endif
+	skb_nf_forget(skb);
 
 	IPTUNNEL_XMIT();
 	tunnel->recursion--;

--OXfL5xGRrasGEqWY--
