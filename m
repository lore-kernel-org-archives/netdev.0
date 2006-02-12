From: Harald Welte <laforge@gnumonks.org>
Subject: [PATCH] [NETFILTER] nf_conntrack: clean up to reduce size of
	'struct nf_conn'
Date: Sun, 12 Feb 2006 18:56:22 +0100
Message-ID: <20060212175622.GG4601@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="TdkiTnkLhLQllcMS"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--TdkiTnkLhLQllcMS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave!

This is net-2.6.17 stuff, please apply.

Thanks!



[NETFILTER] nf_conntrack: clean up to reduce size of 'struct nf_conn'

This patch moves all helper related data fields of 'struct nf_conn' into a
separate structure 'struct nf_conn_help'.  This new structure is only
present in conntrack entries for which we actually have a helper loaded.

Also, this patch cleans up the nf_conntrack 'features' mechanism to
resemble what the original idea was:  Just glue the feature-specific
data structures at the end of 'struct nf_conn', and explicitly re-calculate
the pointer to it when needed rather than keeping pointers around.

Saves 20 bytes per conntrack on my x86_64 box. A non-helped conntrack is
276 bytes. We still need to save another 20 bytes in order to fit into to
target of 256bytes.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit aba8cf3ac5b60e10eb1ce9f30b6bb4c007ab9868
tree 758aedbe80b8306c1991a05c47eab8905d33a13b
parent 94d3d40c84672b74e59ea5252f61602610e1513e
author Harald Welte <laforge@netfilter.org> Sun, 29 Jan 2006 19:19:06 +0100
committer Harald Welte <laforge@netfilter.org> Sun, 29 Jan 2006 19:19:06 +0=
100

 include/net/netfilter/nf_conntrack.h           |   56 +++++++----
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   22 ++---
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   39 +++++---
 net/netfilter/nf_conntrack_core.c              |  117 ++++++++++----------=
----
 net/netfilter/nf_conntrack_ftp.c               |    2=20
 net/netfilter/nf_conntrack_netlink.c           |   39 +++++---
 net/netfilter/nf_conntrack_standalone.c        |    1=20
 net/netfilter/xt_helper.c                      |    8 +-
 8 files changed, 147 insertions(+), 137 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/n=
f_conntrack.h
index 6d075ca..9d1f0e6 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -67,6 +67,18 @@ do {									\
=20
 struct nf_conntrack_helper;
=20
+/* nf_conn feature for connections that have a helper */
+struct nf_conn_help {
+	/* Helper. if any */
+	struct nf_conntrack_helper *helper;
+=09
+	union nf_conntrack_help help;
+=09
+	/* Current number of expected connections */
+	unsigned int expecting;
+};
+
+
 #include <net/netfilter/ipv4/nf_conntrack_ipv4.h>
 struct nf_conn
 {
@@ -81,6 +93,9 @@ struct nf_conn
 	/* Have we seen traffic both ways yet? (bitset) */
 	unsigned long status;
=20
+	/* If we were expected by an expectation, this will be it */
+	struct nf_conn *master;
+
 	/* Timer function; drops refcnt when it goes off. */
 	struct timer_list timeout;
=20
@@ -88,38 +103,22 @@ struct nf_conn
 	/* Accounting Information (same cache line as other written members) */
 	struct ip_conntrack_counter counters[IP_CT_DIR_MAX];
 #endif
-	/* If we were expected by an expectation, this will be it */
-	struct nf_conn *master;
-=09
-	/* Current number of expected connections */
-	unsigned int expecting;
=20
 	/* Unique ID that identifies this conntrack*/
 	unsigned int id;
=20
-	/* Helper. if any */
-	struct nf_conntrack_helper *helper;
-
 	/* features - nat, helper, ... used by allocating system */
 	u_int32_t features;
=20
-	/* Storage reserved for other modules: */
-
-	union nf_conntrack_proto proto;
-
 #if defined(CONFIG_NF_CONNTRACK_MARK)
 	u_int32_t mark;
 #endif
=20
-	/* These members are dynamically allocated. */
-
-	union nf_conntrack_help *help;
+	/* Storage reserved for other modules: */
+	union nf_conntrack_proto proto;
=20
-	/* Layer 3 dependent members. (ex: NAT) */
-	union {
-		struct nf_conntrack_ipv4 *ipv4;
-	} l3proto;
-	void *data[0];
+	/* features dynamically at the end: helper, nat (both optional) */
+	char data[0];
 };
=20
 struct nf_conntrack_expect
@@ -373,10 +372,23 @@ nf_conntrack_expect_event(enum ip_conntr
 #define NF_CT_F_NUM	4
=20
 extern int
-nf_conntrack_register_cache(u_int32_t features, const char *name, size_t s=
ize,
-			    int (*init_conntrack)(struct nf_conn *, u_int32_t));
+nf_conntrack_register_cache(u_int32_t features, const char *name, size_t s=
ize);
 extern void
 nf_conntrack_unregister_cache(u_int32_t features);
=20
+/* valid combinations:
+ * basic: nf_conn, nf_conn .. nf_conn_help
+ * nat: nf_conn .. nf_conn_nat, nf_conn .. nf_conn_nat, nf_conn help
+ */
+static inline struct nf_conn_help *nfct_help(const struct nf_conn *ct)
+{
+	unsigned int offset =3D sizeof(struct nf_conn);
+
+	if (!(ct->features & NF_CT_F_HELP))
+		return NULL;
+
+	return (struct nf_conn_help *) ((void *)ct + offset);
+}
+
 #endif /* __KERNEL__ */
 #endif /* _NF_CONNTRACK_H */
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netf=
ilter/nf_conntrack_l3proto_ipv4.c
index 167619f..e52b50b 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -141,19 +141,21 @@ static unsigned int ipv4_conntrack_help(
 {
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
+	struct nf_conn_help *help;
=20
 	/* This is where we call the helper: as the packet goes out. */
 	ct =3D nf_ct_get(*pskb, &ctinfo);
-	if (ct && ct->helper) {
-		unsigned int ret;
-		ret =3D ct->helper->help(pskb,
-				       (*pskb)->nh.raw - (*pskb)->data
-						       + (*pskb)->nh.iph->ihl*4,
-				       ct, ctinfo);
-		if (ret !=3D NF_ACCEPT)
-			return ret;
-	}
-	return NF_ACCEPT;
+	if (!ct)
+		return NF_ACCEPT;
+
+	help =3D nfct_help(ct);
+	if (!help || !help->helper)
+		return NF_ACCEPT;
+
+	return help->helper->help(pskb,
+			       (*pskb)->nh.raw - (*pskb)->data
+					       + (*pskb)->nh.iph->ihl*4,
+			       ct, ctinfo);
 }
=20
 static unsigned int ipv4_conntrack_defrag(unsigned int hooknum,
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netf=
ilter/nf_conntrack_l3proto_ipv6.c
index ac702a2..ac35f95 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -179,31 +179,36 @@ static unsigned int ipv6_confirm(unsigne
 				 int (*okfn)(struct sk_buff *))
 {
 	struct nf_conn *ct;
+	struct nf_conn_help *help;
 	enum ip_conntrack_info ctinfo;
+	unsigned int ret, protoff;
+	unsigned int extoff =3D (u8*)((*pskb)->nh.ipv6h + 1)
+			      - (*pskb)->data;
+	unsigned char pnum =3D (*pskb)->nh.ipv6h->nexthdr;
+
=20
 	/* This is where we call the helper: as the packet goes out. */
 	ct =3D nf_ct_get(*pskb, &ctinfo);
-	if (ct && ct->helper) {
-		unsigned int ret, protoff;
-		unsigned int extoff =3D (u8*)((*pskb)->nh.ipv6h + 1)
-				      - (*pskb)->data;
-		unsigned char pnum =3D (*pskb)->nh.ipv6h->nexthdr;
-
-		protoff =3D nf_ct_ipv6_skip_exthdr(*pskb, extoff, &pnum,
-						 (*pskb)->len - extoff);
-		if (protoff < 0 || protoff > (*pskb)->len ||
-		    pnum =3D=3D NEXTHDR_FRAGMENT) {
-			DEBUGP("proto header not found\n");
-			return NF_ACCEPT;
-		}
+	if (!ct)
+		goto out;
=20
-		ret =3D ct->helper->help(pskb, protoff, ct, ctinfo);
-		if (ret !=3D NF_ACCEPT)
-			return ret;
+	help =3D nfct_help(ct);
+	if (!help || !help->helper)
+		goto out;
+
+	protoff =3D nf_ct_ipv6_skip_exthdr(*pskb, extoff, &pnum,
+					 (*pskb)->len - extoff);
+	if (protoff < 0 || protoff > (*pskb)->len ||
+	    pnum =3D=3D NEXTHDR_FRAGMENT) {
+		DEBUGP("proto header not found\n");
+		return NF_ACCEPT;
 	}
=20
+	ret =3D help->helper->help(pskb, protoff, ct, ctinfo);
+	if (ret !=3D NF_ACCEPT)
+		return ret;
+out:
 	/* We've seen it coming out the other side: confirm it */
-
 	return nf_conntrack_confirm(pskb);
 }
=20
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack=
_core.c
index 62bb509..873afa6 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -3,7 +3,7 @@
    extension. */
=20
 /* (C) 1999-2001 Paul `Rusty' Russell
- * (C) 2002-2005 Netfilter Core Team <coreteam@netfilter.org>
+ * (C) 2002-2006 Netfilter Core Team <coreteam@netfilter.org>
  * (C) 2003,2004 USAGI/WIDE Project <http://www.linux-ipv6.org>
  *
  * This program is free software; you can redistribute it and/or modify
@@ -20,6 +20,9 @@
  *	- generalize L3 protocol denendent part.
  * 23 Mar 2004: Yasuyuki Kozakai @USAGI <yasuyuki.kozakai@toshiba.co.jp>
  *	- add support various size of conntrack structures.
+ * 26 Jan 2006: Harald Welte <laforge@netfilter.org>
+ * 	- restructure nf_conn (introduce nf_conn_help)
+ * 	- redesign 'features' how they were originally intended
  *
  * Derived from net/ipv4/netfilter/ip_conntrack_core.c
  */
@@ -55,7 +58,7 @@
 #include <net/netfilter/nf_conntrack_core.h>
 #include <linux/netfilter_ipv4/listhelp.h>
=20
-#define NF_CONNTRACK_VERSION	"0.4.1"
+#define NF_CONNTRACK_VERSION	"0.5.0"
=20
 #if 0
 #define DEBUGP printk
@@ -259,21 +262,8 @@ static inline u_int32_t hash_conntrack(c
 				nf_conntrack_hash_rnd);
 }
=20
-/* Initialize "struct nf_conn" which has spaces for helper */
-static int
-init_conntrack_for_helper(struct nf_conn *conntrack, u_int32_t features)
-{
-
-	conntrack->help =3D (union nf_conntrack_help *)
-		(((unsigned long)conntrack->data
-		  + (__alignof__(union nf_conntrack_help) - 1))
-		 & (~((unsigned long)(__alignof__(union nf_conntrack_help) -1))));
-	return 0;
-}
-
 int nf_conntrack_register_cache(u_int32_t features, const char *name,
-				size_t size,
-				int (*init)(struct nf_conn *, u_int32_t))
+				size_t size)
 {
 	int ret =3D 0;
 	char *cache_name;
@@ -296,8 +286,7 @@ int nf_conntrack_register_cache(u_int32_
 		DEBUGP("nf_conntrack_register_cache: already resisterd.\n");
 		if ((!strncmp(nf_ct_cache[features].name, name,
 			      NF_CT_FEATURES_NAMELEN))
-		    && nf_ct_cache[features].size =3D=3D size
-		    && nf_ct_cache[features].init_conntrack =3D=3D init) {
+		    && nf_ct_cache[features].size =3D=3D size) {
 			DEBUGP("nf_conntrack_register_cache: reusing.\n");
 			nf_ct_cache[features].use++;
 			ret =3D 0;
@@ -340,7 +329,6 @@ int nf_conntrack_register_cache(u_int32_
 	write_lock_bh(&nf_ct_cache_lock);
 	nf_ct_cache[features].use =3D 1;
 	nf_ct_cache[features].size =3D size;
-	nf_ct_cache[features].init_conntrack =3D init;
 	nf_ct_cache[features].cachep =3D cachep;
 	nf_ct_cache[features].name =3D cache_name;
 	write_unlock_bh(&nf_ct_cache_lock);
@@ -377,7 +365,6 @@ void nf_conntrack_unregister_cache(u_int
 	name =3D nf_ct_cache[features].name;
 	nf_ct_cache[features].cachep =3D NULL;
 	nf_ct_cache[features].name =3D NULL;
-	nf_ct_cache[features].init_conntrack =3D NULL;
 	nf_ct_cache[features].size =3D 0;
 	write_unlock_bh(&nf_ct_cache_lock);
=20
@@ -432,11 +419,15 @@ nf_ct_invert_tuple(struct nf_conntrack_t
 /* nf_conntrack_expect helper functions */
 void nf_ct_unlink_expect(struct nf_conntrack_expect *exp)
 {
+	struct nf_conn_help *master_help =3D nfct_help(exp->master);
+
+	NF_CT_ASSERT(master_help);
 	ASSERT_WRITE_LOCK(&nf_conntrack_lock);
 	NF_CT_ASSERT(!timer_pending(&exp->timeout));
+
 	list_del(&exp->list);
 	NF_CT_STAT_INC(expect_delete);
-	exp->master->expecting--;
+	master_help->expecting--;
 	nf_conntrack_expect_put(exp);
 }
=20
@@ -508,9 +499,10 @@ find_expectation(const struct nf_conntra
 void nf_ct_remove_expectations(struct nf_conn *ct)
 {
 	struct nf_conntrack_expect *i, *tmp;
+	struct nf_conn_help *help =3D nfct_help(ct);
=20
 	/* Optimization: most connection never expect any others. */
-	if (ct->expecting =3D=3D 0)
+	if (!help || help->expecting =3D=3D 0)
 		return;
=20
 	list_for_each_entry_safe(i, tmp, &nf_conntrack_expect_list, list) {
@@ -713,6 +705,7 @@ __nf_conntrack_confirm(struct sk_buff **
 			  conntrack_tuple_cmp,
 			  struct nf_conntrack_tuple_hash *,
 			  &ct->tuplehash[IP_CT_DIR_REPLY].tuple, NULL)) {
+		struct nf_conn_help *help;
 		/* Remove from unconfirmed list */
 		list_del(&ct->tuplehash[IP_CT_DIR_ORIGINAL].list);
=20
@@ -726,7 +719,8 @@ __nf_conntrack_confirm(struct sk_buff **
 		set_bit(IPS_CONFIRMED_BIT, &ct->status);
 		NF_CT_STAT_INC(insert);
 		write_unlock_bh(&nf_conntrack_lock);
-		if (ct->helper)
+		help =3D nfct_help(ct);
+		if (help && help->helper)
 			nf_conntrack_event_cache(IPCT_HELPER, *pskb);
 #ifdef CONFIG_NF_NAT_NEEDED
 		if (test_bit(IPS_SRC_NAT_DONE_BIT, &ct->status) ||
@@ -842,8 +836,9 @@ __nf_conntrack_alloc(const struct nf_con
 {
 	struct nf_conn *conntrack =3D NULL;
 	u_int32_t features =3D 0;
+	void *helper;
=20
-	if (!nf_conntrack_hash_rnd_initted) {
+	if (unlikely(!nf_conntrack_hash_rnd_initted)) {
 		get_random_bytes(&nf_conntrack_hash_rnd, 4);
 		nf_conntrack_hash_rnd_initted =3D 1;
 	}
@@ -863,8 +858,11 @@ __nf_conntrack_alloc(const struct nf_con
=20
 	/*  find features needed by this conntrack. */
 	features =3D l3proto->get_features(orig);
+
+	/* FIXME: protect helper list per RCU */
 	read_lock_bh(&nf_conntrack_lock);
-	if (__nf_ct_helper_find(repl) !=3D NULL)
+	helper =3D __nf_ct_helper_find(repl);
+	if (helper)
 		features |=3D NF_CT_F_HELP;
 	read_unlock_bh(&nf_conntrack_lock);
=20
@@ -872,7 +870,7 @@ __nf_conntrack_alloc(const struct nf_con
=20
 	read_lock_bh(&nf_ct_cache_lock);
=20
-	if (!nf_ct_cache[features].use) {
+	if (unlikely(!nf_ct_cache[features].use)) {
 		DEBUGP("nf_conntrack_alloc: not supported features =3D 0x%x\n",
 			features);
 		goto out;
@@ -886,12 +884,10 @@ __nf_conntrack_alloc(const struct nf_con
=20
 	memset(conntrack, 0, nf_ct_cache[features].size);
 	conntrack->features =3D features;
-	if (nf_ct_cache[features].init_conntrack &&
-	    nf_ct_cache[features].init_conntrack(conntrack, features) < 0) {
-		DEBUGP("nf_conntrack_alloc: failed to init\n");
-		kmem_cache_free(nf_ct_cache[features].cachep, conntrack);
-		conntrack =3D NULL;
-		goto out;
+	if (helper) {
+		struct nf_conn_help *help =3D nfct_help(conntrack);
+		NF_CT_ASSERT(help);
+		help->helper =3D helper;
 	}
=20
 	atomic_set(&conntrack->ct_general.use, 1);
@@ -972,11 +968,8 @@ init_conntrack(const struct nf_conntrack
 #endif
 		nf_conntrack_get(&conntrack->master->ct_general);
 		NF_CT_STAT_INC(expect_new);
-	} else {
-		conntrack->helper =3D __nf_ct_helper_find(&repl_tuple);
-
+	} else
 		NF_CT_STAT_INC(new);
-        }
=20
 	/* Overload tuple linked list to put us in unconfirmed list. */
 	list_add(&conntrack->tuplehash[IP_CT_DIR_ORIGINAL].list, &unconfirmed);
@@ -1206,14 +1199,16 @@ void nf_conntrack_expect_put(struct nf_c
=20
 static void nf_conntrack_expect_insert(struct nf_conntrack_expect *exp)
 {
+	struct nf_conn_help *master_help =3D nfct_help(exp->master);
+
 	atomic_inc(&exp->use);
-	exp->master->expecting++;
+	master_help->expecting++;
 	list_add(&exp->list, &nf_conntrack_expect_list);
=20
 	init_timer(&exp->timeout);
 	exp->timeout.data =3D (unsigned long)exp;
 	exp->timeout.function =3D expectation_timed_out;
-	exp->timeout.expires =3D jiffies + exp->master->helper->timeout * HZ;
+	exp->timeout.expires =3D jiffies + master_help->helper->timeout * HZ;
 	add_timer(&exp->timeout);
=20
 	exp->id =3D ++nf_conntrack_expect_next_id;
@@ -1239,10 +1234,12 @@ static void evict_oldest_expect(struct n
=20
 static inline int refresh_timer(struct nf_conntrack_expect *i)
 {
+	struct nf_conn_help *master_help =3D nfct_help(i->master);
+
 	if (!del_timer(&i->timeout))
 		return 0;
=20
-	i->timeout.expires =3D jiffies + i->master->helper->timeout*HZ;
+	i->timeout.expires =3D jiffies + master_help->helper->timeout*HZ;
 	add_timer(&i->timeout);
 	return 1;
 }
@@ -1251,8 +1248,11 @@ int nf_conntrack_expect_related(struct n
 {
 	struct nf_conntrack_expect *i;
 	struct nf_conn *master =3D expect->master;
+	struct nf_conn_help *master_help =3D nfct_help(master);
 	int ret;
=20
+	NF_CT_ASSERT(master_help);
+
 	DEBUGP("nf_conntrack_expect_related %p\n", related_to);
 	DEBUGP("tuple: "); NF_CT_DUMP_TUPLE(&expect->tuple);
 	DEBUGP("mask:  "); NF_CT_DUMP_TUPLE(&expect->mask);
@@ -1271,8 +1271,8 @@ int nf_conntrack_expect_related(struct n
 		}
 	}
 	/* Will be over limit? */
-	if (master->helper->max_expected &&=20
-	    master->expecting >=3D master->helper->max_expected)
+	if (master_help->helper->max_expected &&=20
+	    master_help->expecting >=3D master_help->helper->max_expected)
 		evict_oldest_expect(master);
=20
 	nf_conntrack_expect_insert(expect);
@@ -1283,24 +1283,6 @@ out:
 	return ret;
 }
=20
-/* Alter reply tuple (maybe alter helper).  This is for NAT, and is
-   implicitly racy: see __nf_conntrack_confirm */
-void nf_conntrack_alter_reply(struct nf_conn *conntrack,
-			      const struct nf_conntrack_tuple *newreply)
-{
-	write_lock_bh(&nf_conntrack_lock);
-	/* Should be unconfirmed, so not in hash table yet */
-	NF_CT_ASSERT(!nf_ct_is_confirmed(conntrack));
-
-	DEBUGP("Altering reply tuple of %p to ", conntrack);
-	NF_CT_DUMP_TUPLE(newreply);
-
-	conntrack->tuplehash[IP_CT_DIR_REPLY].tuple =3D *newreply;
-	if (!conntrack->master && conntrack->expecting =3D=3D 0)
-		conntrack->helper =3D __nf_ct_helper_find(newreply);
-	write_unlock_bh(&nf_conntrack_lock);
-}
-
 int nf_conntrack_helper_register(struct nf_conntrack_helper *me)
 {
 	int ret;
@@ -1309,8 +1291,7 @@ int nf_conntrack_helper_register(struct=20
 	ret =3D nf_conntrack_register_cache(NF_CT_F_HELP, "nf_conntrack:help",
 					  sizeof(struct nf_conn)
 					  + sizeof(union nf_conntrack_help)
-					  + __alignof__(union nf_conntrack_help),
-					  init_conntrack_for_helper);
+					  + __alignof__(union nf_conntrack_help));
 	if (ret < 0) {
 		printk(KERN_ERR "nf_conntrack_helper_reigster: Unable to create slab cac=
he for conntracks\n");
 		return ret;
@@ -1338,9 +1319,12 @@ __nf_conntrack_helper_find_byname(const=20
 static inline int unhelp(struct nf_conntrack_tuple_hash *i,
 			 const struct nf_conntrack_helper *me)
 {
-	if (nf_ct_tuplehash_to_ctrack(i)->helper =3D=3D me) {
-		nf_conntrack_event(IPCT_HELPER, nf_ct_tuplehash_to_ctrack(i));
-		nf_ct_tuplehash_to_ctrack(i)->helper =3D NULL;
+	struct nf_conn *ct =3D nf_ct_tuplehash_to_ctrack(i);
+	struct nf_conn_help *help =3D nfct_help(ct);
+
+	if (help && help->helper =3D=3D me) {
+		nf_conntrack_event(IPCT_HELPER, ct);
+		help->helper =3D NULL;
 	}
 	return 0;
 }
@@ -1356,7 +1340,8 @@ void nf_conntrack_helper_unregister(stru
=20
 	/* Get rid of expectations */
 	list_for_each_entry_safe(exp, tmp, &nf_conntrack_expect_list, list) {
-		if (exp->master->helper =3D=3D me && del_timer(&exp->timeout)) {
+		struct nf_conn_help *help =3D nfct_help(exp->master);
+		if (help->helper =3D=3D me && del_timer(&exp->timeout)) {
 			nf_ct_unlink_expect(exp);
 			nf_conntrack_expect_put(exp);
 		}
@@ -1695,7 +1680,7 @@ int __init nf_conntrack_init(void)
 	}
=20
 	ret =3D nf_conntrack_register_cache(NF_CT_F_BASIC, "nf_conntrack:basic",
-					  sizeof(struct nf_conn), NULL);
+					  sizeof(struct nf_conn));
 	if (ret < 0) {
 		printk(KERN_ERR "Unable to create nf_conn slab cache\n");
 		goto err_free_hash;
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_=
ftp.c
index ab0c920..280c5c2 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -440,7 +440,7 @@ static int help(struct sk_buff **pskb,
 	u32 seq;
 	int dir =3D CTINFO2DIR(ctinfo);
 	unsigned int matchlen, matchoff;
-	struct ip_ct_ftp_master *ct_ftp_info =3D &ct->help->ct_ftp_info;
+	struct ip_ct_ftp_master *ct_ftp_info =3D &nfct_help(ct)->help.ct_ftp_info;
 	struct nf_conntrack_expect *exp;
 	struct nf_conntrack_man cmd =3D {};
=20
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntr=
ack_netlink.c
index 73ab16b..bd42186 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2,7 +2,7 @@
  * protocol helpers and general trouble making from userspace.
  *
  * (C) 2001 by Jay Schulist <jschlst@samba.org>
- * (C) 2002-2005 by Harald Welte <laforge@gnumonks.org>
+ * (C) 2002-2006 by Harald Welte <laforge@gnumonks.org>
  * (C) 2003 by Patrick Mchardy <kaber@trash.net>
  * (C) 2005 by Pablo Neira Ayuso <pablo@eurodev.net>
  *
@@ -44,7 +44,7 @@
=20
 MODULE_LICENSE("GPL");
=20
-static char __initdata version[] =3D "0.92";
+static char __initdata version[] =3D "0.93";
=20
 #if 0
 #define DEBUGP printk
@@ -165,15 +165,16 @@ static inline int
 ctnetlink_dump_helpinfo(struct sk_buff *skb, const struct nf_conn *ct)
 {
 	struct nfattr *nest_helper;
+	const struct nf_conn_help *help =3D nfct_help(ct);
=20
-	if (!ct->helper)
+	if (!help)
 		return 0;
 	=09
 	nest_helper =3D NFA_NEST(skb, CTA_HELP);
-	NFA_PUT(skb, CTA_HELP_NAME, strlen(ct->helper->name), ct->helper->name);
+	NFA_PUT(skb, CTA_HELP_NAME, strlen(help->helper->name), help->helper->nam=
e);
=20
-	if (ct->helper->to_nfattr)
-		ct->helper->to_nfattr(skb, ct);
+	if (help->helper->to_nfattr)
+		help->helper->to_nfattr(skb, ct);
=20
 	NFA_NEST_END(skb, nest_helper);
=20
@@ -903,11 +904,17 @@ static inline int
 ctnetlink_change_helper(struct nf_conn *ct, struct nfattr *cda[])
 {
 	struct nf_conntrack_helper *helper;
+	struct nf_conn_help *help =3D nfct_help(ct);
 	char *helpname;
 	int err;
=20
 	DEBUGP("entered %s\n", __FUNCTION__);
=20
+	if (!help) {
+		/* FIXME: we need to reallocate and rehash */
+		return -EBUSY;
+	}
+
 	/* don't change helper of sibling connections */
 	if (ct->master)
 		return -EINVAL;
@@ -924,18 +931,18 @@ ctnetlink_change_helper(struct nf_conn *
 			return -EINVAL;
 	}
=20
-	if (ct->helper) {
+	if (help->helper) {
 		if (!helper) {
 			/* we had a helper before ... */
 			nf_ct_remove_expectations(ct);
-			ct->helper =3D NULL;
+			help->helper =3D NULL;
 		} else {
 			/* need to zero data of old helper */
-			memset(&ct->help, 0, sizeof(ct->help));
+			memset(&help->help, 0, sizeof(help->help));
 		}
 	}
 =09
-	ct->helper =3D helper;
+	help->helper =3D helper;
=20
 	return 0;
 }
@@ -1050,14 +1057,9 @@ ctnetlink_create_conntrack(struct nfattr
 		ct->mark =3D ntohl(*(u_int32_t *)NFA_DATA(cda[CTA_MARK-1]));
 #endif
=20
-	ct->helper =3D nf_ct_helper_find_get(rtuple);
-
 	add_timer(&ct->timeout);
 	nf_conntrack_hash_insert(ct);
=20
-	if (ct->helper)
-		nf_ct_helper_put(ct->helper);
-
 	DEBUGP("conntrack with id %u inserted\n", ct->id);
 	return 0;
=20
@@ -1417,7 +1419,8 @@ ctnetlink_del_expect(struct sock *ctnl,=20
 		}
 		list_for_each_entry_safe(exp, tmp, &nf_conntrack_expect_list,
 					 list) {
-			if (exp->master->helper =3D=3D h=20
+			struct nf_conn_help *m_help =3D nfct_help(exp->master);
+			if (m_help->helper =3D=3D h=20
 			    && del_timer(&exp->timeout)) {
 				nf_ct_unlink_expect(exp);
 				nf_conntrack_expect_put(exp);
@@ -1452,6 +1455,7 @@ ctnetlink_create_expect(struct nfattr *c
 	struct nf_conntrack_tuple_hash *h =3D NULL;
 	struct nf_conntrack_expect *exp;
 	struct nf_conn *ct;
+	struct nf_conn_help *help;
 	int err =3D 0;
=20
 	DEBUGP("entered %s\n", __FUNCTION__);
@@ -1472,8 +1476,9 @@ ctnetlink_create_expect(struct nfattr *c
 	if (!h)
 		return -ENOENT;
 	ct =3D nf_ct_tuplehash_to_ctrack(h);
+	help =3D nfct_help(ct);
=20
-	if (!ct->helper) {
+	if (!help || !help->helper) {
 		/* such conntrack hasn't got any helper, abort */
 		err =3D -EINVAL;
 		goto out;
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_con=
ntrack_standalone.c
index 617599a..290d5a0 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -839,7 +839,6 @@ EXPORT_SYMBOL(nf_conntrack_l3proto_unreg
 EXPORT_SYMBOL(nf_conntrack_protocol_register);
 EXPORT_SYMBOL(nf_conntrack_protocol_unregister);
 EXPORT_SYMBOL(nf_ct_invert_tuplepr);
-EXPORT_SYMBOL(nf_conntrack_alter_reply);
 EXPORT_SYMBOL(nf_conntrack_destroyed);
 EXPORT_SYMBOL(need_conntrack);
 EXPORT_SYMBOL(nf_conntrack_helper_register);
diff --git a/net/netfilter/xt_helper.c b/net/netfilter/xt_helper.c
index 38b6715..c451169 100644
--- a/net/netfilter/xt_helper.c
+++ b/net/netfilter/xt_helper.c
@@ -96,6 +96,7 @@ match(const struct sk_buff *skb,
 {
 	const struct xt_helper_info *info =3D matchinfo;
 	struct nf_conn *ct;
+	struct nf_conn_help *master_help;
 	enum ip_conntrack_info ctinfo;
 	int ret =3D info->invert;
 =09
@@ -111,7 +112,8 @@ match(const struct sk_buff *skb,
 	}
=20
 	read_lock_bh(&nf_conntrack_lock);
-	if (!ct->master->helper) {
+	master_help =3D nfct_help(ct->master);
+	if (!master_help || !master_help->helper) {
 		DEBUGP("xt_helper: master ct %p has no helper\n",=20
 			exp->expectant);
 		goto out_unlock;
@@ -123,8 +125,8 @@ match(const struct sk_buff *skb,
 	if (info->name[0] =3D=3D '\0')
 		ret ^=3D 1;
 	else
-		ret ^=3D !strncmp(ct->master->helper->name, info->name,=20
-		                strlen(ct->master->helper->name));
+		ret ^=3D !strncmp(master_help->helper->name, info->name,=20
+		                strlen(master_help->helper->name));
 out_unlock:
 	read_unlock_bh(&nf_conntrack_lock);
 	return ret;
--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--TdkiTnkLhLQllcMS
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFD73bGXaXGVTD0i/8RApVgAJ94oQx8hayMkbhfckF6QK3XURIWqACfasPV
QctrkwW6AaH2E7p/Nmbo0gA=
=+po0
-----END PGP SIGNATURE-----

--TdkiTnkLhLQllcMS--
