From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: [PATCH] net/ipv4/netfilter/ip_tables.c: remove some inlines
Date: Sun, 16 Dec 2007 12:47:53 -0800
Message-ID: <200712161247.53986.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_57YZH+QYgtSjRtH"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	Harald Welte <laforge@gnumonks.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759250AbXLPUsV@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_57YZH+QYgtSjRtH
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi Patrick, Harald,

I was working on unrelated problem and noticed that ip_tables.c
seem to abuse inline. I prepared a patch which removes inlines
except those which are used by packet matching code
(and thus are really performance-critical).
I added comments explaining that remaining inlines are
performance critical.

Result as reported by size:

   text    data     bss     dec     hex filename
-  6451     380      88    6919    1b07 ip_tables.o
+  6339     348      72    6759    1a67 ip_tables.o

Please take this patch into netfilter queue.

Signed-off-by: Denys Vlasenko <vda.linux@googlemail.com>
--
vda

--Boundary-00=_57YZH+QYgtSjRtH
Content-Type: text/x-diff;
  charset="us-ascii";
  name="linux-2.6.ipt.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="linux-2.6.ipt.diff"

diff -urpN linux-2.6.org/net/ipv4/netfilter/ip_tables.c linux-2.6.ipt/net/ipv4/netfilter/ip_tables.c
--- linux-2.6.org/net/ipv4/netfilter/ip_tables.c	2007-12-14 10:46:37.000000000 -0800
+++ linux-2.6.ipt/net/ipv4/netfilter/ip_tables.c	2007-12-16 12:37:46.000000000 -0800
@@ -74,6 +74,7 @@ do {								\
    Hence the start of any table is given by get_table() below.  */
 
 /* Returns whether matches rule or not. */
+/* Performance critical - called for every packet */
 static inline int
 ip_packet_match(const struct iphdr *ip,
 		const char *indev,
@@ -152,7 +153,7 @@ ip_packet_match(const struct iphdr *ip,
 	return 1;
 }
 
-static inline bool
+static bool
 ip_checkentry(const struct ipt_ip *ip)
 {
 	if (ip->flags & ~IPT_F_MASK) {
@@ -182,6 +183,7 @@ ipt_error(struct sk_buff *skb,
 	return NF_DROP;
 }
 
+/* Performance critical - called for every packet */
 static inline
 bool do_match(struct ipt_entry_match *m,
 	      const struct sk_buff *skb,
@@ -198,6 +200,7 @@ bool do_match(struct ipt_entry_match *m,
 		return false;
 }
 
+/* Performance critical */
 static inline struct ipt_entry *
 get_entry(void *base, unsigned int offset)
 {
@@ -205,6 +208,7 @@ get_entry(void *base, unsigned int offse
 }
 
 /* All zeroes == unconditional rule. */
+/* Mildly perf critical (only if packet tracing is on) */
 static inline int
 unconditional(const struct ipt_ip *ip)
 {
@@ -219,7 +223,7 @@ unconditional(const struct ipt_ip *ip)
 
 #if defined(CONFIG_NETFILTER_XT_TARGET_TRACE) || \
     defined(CONFIG_NETFILTER_XT_TARGET_TRACE_MODULE)
-static const char *hooknames[] = {
+static const char *const hooknames[] = {
 	[NF_IP_PRE_ROUTING]		= "PREROUTING",
 	[NF_IP_LOCAL_IN]		= "INPUT",
 	[NF_IP_FORWARD]			= "FORWARD",
@@ -233,7 +237,7 @@ enum nf_ip_trace_comments {
 	NF_IP_TRACE_COMMENT_POLICY,
 };
 
-static const char *comments[] = {
+static const char *const comments[] = {
 	[NF_IP_TRACE_COMMENT_RULE]	= "rule",
 	[NF_IP_TRACE_COMMENT_RETURN]	= "return",
 	[NF_IP_TRACE_COMMENT_POLICY]	= "policy",
@@ -249,6 +253,7 @@ static struct nf_loginfo trace_loginfo =
 	},
 };
 
+/* Mildly perf critical (only if packet tracing is on) */
 static inline int
 get_chainname_rulenum(struct ipt_entry *s, struct ipt_entry *e,
 		      char *hookname, char **chainname,
@@ -567,7 +572,7 @@ mark_source_chains(struct xt_table_info 
 	return 1;
 }
 
-static inline int
+static int
 cleanup_match(struct ipt_entry_match *m, unsigned int *i)
 {
 	if (i && (*i)-- == 0)
@@ -579,7 +584,7 @@ cleanup_match(struct ipt_entry_match *m,
 	return 0;
 }
 
-static inline int
+static int
 check_entry(struct ipt_entry *e, const char *name)
 {
 	struct ipt_entry_target *t;
@@ -599,7 +604,7 @@ check_entry(struct ipt_entry *e, const c
 	return 0;
 }
 
-static inline int check_match(struct ipt_entry_match *m, const char *name,
+static int check_match(struct ipt_entry_match *m, const char *name,
 				const struct ipt_ip *ip, unsigned int hookmask,
 				unsigned int *i)
 {
@@ -622,7 +627,7 @@ static inline int check_match(struct ipt
 	return ret;
 }
 
-static inline int
+static int
 find_check_match(struct ipt_entry_match *m,
 	    const char *name,
 	    const struct ipt_ip *ip,
@@ -651,7 +656,7 @@ err:
 	return ret;
 }
 
-static inline int check_target(struct ipt_entry *e, const char *name)
+static int check_target(struct ipt_entry *e, const char *name)
 {
 	struct ipt_entry_target *t;
 	struct xt_target *target;
@@ -672,7 +677,7 @@ static inline int check_target(struct ip
 	return ret;
 }
 
-static inline int
+static int
 find_check_entry(struct ipt_entry *e, const char *name, unsigned int size,
 	    unsigned int *i)
 {
@@ -716,7 +721,7 @@ find_check_entry(struct ipt_entry *e, co
 	return ret;
 }
 
-static inline int
+static int
 check_entry_size_and_hooks(struct ipt_entry *e,
 			   struct xt_table_info *newinfo,
 			   unsigned char *base,
@@ -759,7 +764,7 @@ check_entry_size_and_hooks(struct ipt_en
 	return 0;
 }
 
-static inline int
+static int
 cleanup_entry(struct ipt_entry *e, unsigned int *i)
 {
 	struct ipt_entry_target *t;
@@ -1293,7 +1298,7 @@ __do_replace(const char *name, unsigned 
 	get_counters(oldinfo, counters);
 	/* Decrease module usage counts and free resource */
 	loc_cpu_old_entry = oldinfo->entries[raw_smp_processor_id()];
-	IPT_ENTRY_ITERATE(loc_cpu_old_entry, oldinfo->size, cleanup_entry,NULL);
+	IPT_ENTRY_ITERATE(loc_cpu_old_entry, oldinfo->size, cleanup_entry, NULL);
 	xt_free_table_info(oldinfo);
 	if (copy_to_user(counters_ptr, counters,
 			 sizeof(struct xt_counters) * num_counters) != 0)
@@ -1361,7 +1366,7 @@ do_replace(void __user *user, unsigned i
 	return 0;
 
  free_newinfo_untrans:
-	IPT_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry,NULL);
+	IPT_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry, NULL);
  free_newinfo:
 	xt_free_table_info(newinfo);
 	return ret;
@@ -1369,7 +1374,7 @@ do_replace(void __user *user, unsigned i
 
 /* We're lazy, and add to the first CPU; overflow works its fey magic
  * and everything is OK. */
-static inline int
+static int
 add_counter_to_entry(struct ipt_entry *e,
 		     const struct xt_counters addme[],
 		     unsigned int *i)
@@ -1527,7 +1532,7 @@ out:
 	return ret;
 }
 
-static inline int
+static int
 compat_find_calc_match(struct ipt_entry_match *m,
 	    const char *name,
 	    const struct ipt_ip *ip,
@@ -1551,7 +1556,7 @@ compat_find_calc_match(struct ipt_entry_
 	return 0;
 }
 
-static inline int
+static int
 compat_release_match(struct ipt_entry_match *m, unsigned int *i)
 {
 	if (i && (*i)-- == 0)
@@ -1561,7 +1566,7 @@ compat_release_match(struct ipt_entry_ma
 	return 0;
 }
 
-static inline int
+static int
 compat_release_entry(struct ipt_entry *e, unsigned int *i)
 {
 	struct ipt_entry_target *t;
@@ -1576,7 +1581,7 @@ compat_release_entry(struct ipt_entry *e
 	return 0;
 }
 
-static inline int
+static int
 check_compat_entry_size_and_hooks(struct ipt_entry *e,
 			   struct xt_table_info *newinfo,
 			   unsigned int *size,
@@ -1702,7 +1707,7 @@ static int compat_copy_entry_from_user(s
 	return ret;
 }
 
-static inline int compat_check_entry(struct ipt_entry *e, const char *name,
+static int compat_check_entry(struct ipt_entry *e, const char *name,
 						unsigned int *i)
 {
 	int j, ret;
@@ -1895,7 +1900,7 @@ compat_do_replace(void __user *user, uns
 	return 0;
 
  free_newinfo_untrans:
-	IPT_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry,NULL);
+	IPT_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry, NULL);
  free_newinfo:
 	xt_free_table_info(newinfo);
 	return ret;

--Boundary-00=_57YZH+QYgtSjRtH--
