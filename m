From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] [NETFILTER] x_tables
Date: Thu, 12 Jan 2006 21:47:34 +0100
Message-ID: <20060112204734.GQ4430@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="67L3nkltNbzPAvlZ"
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


--67L3nkltNbzPAvlZ
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave!

Finally, I included all the suggestions/comments for x_tables "take 5",
ran the nfsim testsuite and feel confident that this is ready for prime
time.

Please apply this huge one for 2.6.16,

	Thanks!


[NETFILTER] x_tables: Abstraction layer for {ip,ip6,arp}_tables

This monster-patch tries to do the best job for unifying the data structures
and backend interfaces for the three evil clones ip_tables, ip6_tables and
arp_tables.  In an ideal world we would never have allowed this kind of=20
copy+paste programming... but well, our world isn't (yet?) ideal.

o introduce a new x_tables module
o {ip,arp,ip6}_tables depend on this x_tables module
o registration functions for tables, matches and targets are only
  wrappers around x_tables provided functions
o all matches/targets that are used from ip_tables and ip6_tables
  are now implemented as xt_FOOBAR.c files and provide module aliases
  to ipt_FOOBAR and ip6t_FOOBAR
o header files for xt_matches are in include/linux/netfilter/,=20
  include/linux/netfilter_{ipv4,ipv6} contains compatibility wrappers
  around the xt_FOOBAR.h headers

Based on this patchset we're going to further unify the code, gradually get=
ting
rid of all the layer 3 specific assumptions.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---

diff --git a/include/linux/netfilter/nf_conntrack_common.h b/include/linux/=
netfilter/nf_conntrack_common.h
index 6d39b51..3ff88c8 100644
--- a/include/linux/netfilter/nf_conntrack_common.h
+++ b/include/linux/netfilter/nf_conntrack_common.h
@@ -154,6 +154,9 @@ struct ip_conntrack_stat
 	unsigned int expect_delete;
 };
=20
+/* call to create an explicit dependency on nf_conntrack. */
+extern void need_conntrack(void);
+
 #endif /* __KERNEL__ */
=20
 #endif /* _NF_CONNTRACK_COMMON_H */
diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x=
_tables.h
new file mode 100644
index 0000000..472f048
--- /dev/null
+++ b/include/linux/netfilter/x_tables.h
@@ -0,0 +1,224 @@
+#ifndef _X_TABLES_H
+#define _X_TABLES_H
+
+#define XT_FUNCTION_MAXNAMELEN 30
+#define XT_TABLE_MAXNAMELEN 32
+
+/* The argument to IPT_SO_GET_REVISION_*.  Returns highest revision
+ * kernel supports, if >=3D revision. */
+struct xt_get_revision
+{
+	char name[XT_FUNCTION_MAXNAMELEN-1];
+
+	u_int8_t revision;
+};
+
+/* CONTINUE verdict for targets */
+#define XT_CONTINUE 0xFFFFFFFF
+
+/* For standard target */
+#define XT_RETURN (-NF_REPEAT - 1)
+
+#define XT_ALIGN(s) (((s) + (__alignof__(void *)-1)) & ~(__alignof__(void =
*)-1))
+
+/* Standard return verdict, or do jump. */
+#define XT_STANDARD_TARGET ""
+/* Error verdict. */
+#define XT_ERROR_TARGET "ERROR"
+
+/*
+ * New IP firewall options for [gs]etsockopt at the RAW IP level.
+ * Unlike BSD Linux inherits IP options so you don't have to use a raw
+ * socket for this. Instead we check rights in the calls. */
+#define XT_BASE_CTL		64	/* base for firewall socket options */
+
+#define XT_SO_SET_REPLACE	(XT_BASE_CTL)
+#define XT_SO_SET_ADD_COUNTERS	(XT_BASE_CTL + 1)
+#define XT_SO_SET_MAX		XT_SO_SET_ADD_COUNTERS
+
+#define XT_SO_GET_INFO			(XT_BASE_CTL)
+#define XT_SO_GET_ENTRIES		(XT_BASE_CTL + 1)
+#define XT_SO_GET_REVISION_MATCH	(XT_BASE_CTL + 2)
+#define XT_SO_GET_REVISION_TARGET	(XT_BASE_CTL + 3)
+#define XT_SO_GET_MAX			XT_SO_GET_REVISION_TARGET
+
+#define SET_COUNTER(c,b,p) do { (c).bcnt =3D (b); (c).pcnt =3D (p); } whil=
e(0)
+#define ADD_COUNTER(c,b,p) do { (c).bcnt +=3D (b); (c).pcnt +=3D (p); } wh=
ile(0)
+
+struct xt_counters
+{
+	u_int64_t pcnt, bcnt;			/* Packet and byte counters */
+};
+
+/* The argument to IPT_SO_ADD_COUNTERS. */
+struct xt_counters_info
+{
+	/* Which table. */
+	char name[XT_TABLE_MAXNAMELEN];
+
+	unsigned int num_counters;
+
+	/* The counters (actually `number' of these). */
+	struct xt_counters counters[0];
+};
+
+#define XT_INV_PROTO		0x40	/* Invert the sense of PROTO. */
+
+#ifdef __KERNEL__
+
+#include <linux/netdevice.h>
+
+#define ASSERT_READ_LOCK(x)
+#define ASSERT_WRITE_LOCK(x)
+#include <linux/netfilter_ipv4/listhelp.h>
+
+struct xt_match
+{
+	struct list_head list;
+
+	const char name[XT_FUNCTION_MAXNAMELEN-1];
+
+	u_int8_t revision;
+
+	/* Return true or false: return FALSE and set *hotdrop =3D 1 to
+           force immediate packet drop. */
+	/* Arguments changed since 2.6.9, as this must now handle
+	   non-linear skb, using skb_header_pointer and
+	   skb_ip_make_writable. */
+	int (*match)(const struct sk_buff *skb,
+		     const struct net_device *in,
+		     const struct net_device *out,
+		     const void *matchinfo,
+		     int offset,
+		     unsigned int protoff,
+		     int *hotdrop);
+
+	/* Called when user tries to insert an entry of this type. */
+	/* Should return true or false. */
+	int (*checkentry)(const char *tablename,
+			  const void *ip,
+			  void *matchinfo,
+			  unsigned int matchinfosize,
+			  unsigned int hook_mask);
+
+	/* Called when entry of this type deleted. */
+	void (*destroy)(void *matchinfo, unsigned int matchinfosize);
+
+	/* Set this to THIS_MODULE if you are a module, otherwise NULL */
+	struct module *me;
+};
+
+/* Registration hooks for targets. */
+struct xt_target
+{
+	struct list_head list;
+
+	const char name[XT_FUNCTION_MAXNAMELEN-1];
+
+	u_int8_t revision;
+
+	/* Returns verdict. Argument order changed since 2.6.9, as this
+	   must now handle non-linear skbs, using skb_copy_bits and
+	   skb_ip_make_writable. */
+	unsigned int (*target)(struct sk_buff **pskb,
+			       const struct net_device *in,
+			       const struct net_device *out,
+			       unsigned int hooknum,
+			       const void *targinfo,
+			       void *userdata);
+
+	/* Called when user tries to insert an entry of this type:
+           hook_mask is a bitmask of hooks from which it can be
+           called. */
+	/* Should return true or false. */
+	int (*checkentry)(const char *tablename,
+			  const void *entry,
+			  void *targinfo,
+			  unsigned int targinfosize,
+			  unsigned int hook_mask);
+
+	/* Called when entry of this type deleted. */
+	void (*destroy)(void *targinfo, unsigned int targinfosize);
+
+	/* Set this to THIS_MODULE if you are a module, otherwise NULL */
+	struct module *me;
+};
+
+/* Furniture shopping... */
+struct xt_table
+{
+	struct list_head list;
+
+	/* A unique name... */
+	char name[XT_TABLE_MAXNAMELEN];
+
+	/* What hooks you will enter on */
+	unsigned int valid_hooks;
+
+	/* Lock for the curtain */
+	rwlock_t lock;
+
+	/* Man behind the curtain... */
+	//struct ip6t_table_info *private;
+	void *private;
+
+	/* Set this to THIS_MODULE if you are a module, otherwise NULL */
+	struct module *me;
+
+	int af;		/* address/protocol family */
+};
+
+#include <linux/netfilter_ipv4.h>
+
+/* The table itself */
+struct xt_table_info
+{
+	/* Size per table */
+	unsigned int size;
+	/* Number of entries: FIXME. --RR */
+	unsigned int number;
+	/* Initial number of entries. Needed for module usage count */
+	unsigned int initial_entries;
+
+	/* Entry points and underflows */
+	unsigned int hook_entry[NF_IP_NUMHOOKS];
+	unsigned int underflow[NF_IP_NUMHOOKS];
+
+	/* ipt_entry tables: one per CPU */
+	char *entries[NR_CPUS];
+};
+
+extern int xt_register_target(int af, struct xt_target *target);
+extern void xt_unregister_target(int af, struct xt_target *target);
+extern int xt_register_match(int af, struct xt_match *target);
+extern void xt_unregister_match(int af, struct xt_match *target);
+
+extern int xt_register_table(struct xt_table *table,
+			     struct xt_table_info *bootstrap,
+			     struct xt_table_info *newinfo);
+extern void *xt_unregister_table(struct xt_table *table);
+
+extern struct xt_table_info *xt_replace_table(struct xt_table *table,
+					      unsigned int num_counters,
+					      struct xt_table_info *newinfo,
+					      int *error);
+
+extern struct xt_match *xt_find_match(int af, const char *name, u8 revisio=
n);
+extern struct xt_target *xt_find_target(int af, const char *name, u8 revis=
ion);
+extern struct xt_target *xt_request_find_target(int af, const char *name,=
=20
+						u8 revision);
+extern int xt_find_revision(int af, const char *name, u8 revision, int tar=
get,
+			    int *err);
+
+extern struct xt_table *xt_find_table_lock(int af, const char *name);
+extern void xt_table_unlock(struct xt_table *t);
+
+extern int xt_proto_init(int af);
+extern void xt_proto_fini(int af);
+
+extern struct xt_table_info *xt_alloc_table_info(unsigned int size);
+extern void xt_free_table_info(struct xt_table_info *info);
+
+#endif /* __KERNEL__ */
+
+#endif /* _X_TABLES_H */
diff --git a/include/linux/netfilter/xt_CLASSIFY.h b/include/linux/netfilte=
r/xt_CLASSIFY.h
new file mode 100644
index 0000000..5811135
--- /dev/null
+++ b/include/linux/netfilter/xt_CLASSIFY.h
@@ -0,0 +1,8 @@
+#ifndef _XT_CLASSIFY_H
+#define _XT_CLASSIFY_H
+
+struct xt_classify_target_info {
+	u_int32_t priority;
+};
+
+#endif /*_XT_CLASSIFY_H */
diff --git a/include/linux/netfilter/xt_CONNMARK.h b/include/linux/netfilte=
r/xt_CONNMARK.h
new file mode 100644
index 0000000..9f74468
--- /dev/null
+++ b/include/linux/netfilter/xt_CONNMARK.h
@@ -0,0 +1,25 @@
+#ifndef _XT_CONNMARK_H_target
+#define _XT_CONNMARK_H_target
+
+/* Copyright (C) 2002,2004 MARA Systems AB <http://www.marasystems.com>
+ * by Henrik Nordstrom <hno@marasystems.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+enum {
+	XT_CONNMARK_SET =3D 0,
+	XT_CONNMARK_SAVE,
+	XT_CONNMARK_RESTORE
+};
+
+struct xt_connmark_target_info {
+	unsigned long mark;
+	unsigned long mask;
+	u_int8_t mode;
+};
+
+#endif /*_XT_CONNMARK_H_target*/
diff --git a/include/linux/netfilter/xt_MARK.h b/include/linux/netfilter/xt=
_MARK.h
new file mode 100644
index 0000000..b021e93
--- /dev/null
+++ b/include/linux/netfilter/xt_MARK.h
@@ -0,0 +1,21 @@
+#ifndef _XT_MARK_H_target
+#define _XT_MARK_H_target
+
+/* Version 0 */
+struct xt_mark_target_info {
+	unsigned long mark;
+};
+
+/* Version 1 */
+enum {
+	XT_MARK_SET=3D0,
+	XT_MARK_AND,
+	XT_MARK_OR,
+};
+
+struct xt_mark_target_info_v1 {
+	unsigned long mark;
+	u_int8_t mode;
+};
+
+#endif /*_XT_MARK_H_target */
diff --git a/include/linux/netfilter/xt_NFQUEUE.h b/include/linux/netfilter=
/xt_NFQUEUE.h
new file mode 100644
index 0000000..9a9af79
--- /dev/null
+++ b/include/linux/netfilter/xt_NFQUEUE.h
@@ -0,0 +1,16 @@
+/* iptables module for using NFQUEUE mechanism
+ *
+ * (C) 2005 Harald Welte <laforge@netfilter.org>
+ *
+ * This software is distributed under GNU GPL v2, 1991
+ *=20
+*/
+#ifndef _XT_NFQ_TARGET_H
+#define _XT_NFQ_TARGET_H
+
+/* target info */
+struct xt_NFQ_info {
+	u_int16_t queuenum;
+};
+
+#endif /* _XT_NFQ_TARGET_H */
diff --git a/include/linux/netfilter/xt_comment.h b/include/linux/netfilter=
/xt_comment.h
new file mode 100644
index 0000000..eacfedc
--- /dev/null
+++ b/include/linux/netfilter/xt_comment.h
@@ -0,0 +1,10 @@
+#ifndef _XT_COMMENT_H
+#define _XT_COMMENT_H
+
+#define XT_MAX_COMMENT_LEN 256
+
+struct xt_comment_info {
+	unsigned char comment[XT_MAX_COMMENT_LEN];
+};
+
+#endif /* XT_COMMENT_H */
diff --git a/include/linux/netfilter/xt_connbytes.h b/include/linux/netfilt=
er/xt_connbytes.h
new file mode 100644
index 0000000..c022c98
--- /dev/null
+++ b/include/linux/netfilter/xt_connbytes.h
@@ -0,0 +1,25 @@
+#ifndef _XT_CONNBYTES_H
+#define _XT_CONNBYTES_H
+
+enum xt_connbytes_what {
+	XT_CONNBYTES_PKTS,
+	XT_CONNBYTES_BYTES,
+	XT_CONNBYTES_AVGPKT,
+};
+
+enum xt_connbytes_direction {
+	XT_CONNBYTES_DIR_ORIGINAL,
+	XT_CONNBYTES_DIR_REPLY,
+	XT_CONNBYTES_DIR_BOTH,
+};
+
+struct xt_connbytes_info
+{
+	struct {
+		aligned_u64 from;	/* count to be matched */
+		aligned_u64 to;		/* count to be matched */
+	} count;
+	u_int8_t what;		/* ipt_connbytes_what */
+	u_int8_t direction;	/* ipt_connbytes_direction */
+};
+#endif
diff --git a/include/linux/netfilter/xt_connmark.h b/include/linux/netfilte=
r/xt_connmark.h
new file mode 100644
index 0000000..c592f6a
--- /dev/null
+++ b/include/linux/netfilter/xt_connmark.h
@@ -0,0 +1,18 @@
+#ifndef _XT_CONNMARK_H
+#define _XT_CONNMARK_H
+
+/* Copyright (C) 2002,2004 MARA Systems AB <http://www.marasystems.com>
+ * by Henrik Nordstrom <hno@marasystems.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+struct xt_connmark_info {
+	unsigned long mark, mask;
+	u_int8_t invert;
+};
+
+#endif /*_XT_CONNMARK_H*/
diff --git a/include/linux/netfilter/xt_conntrack.h b/include/linux/netfilt=
er/xt_conntrack.h
new file mode 100644
index 0000000..34f63cf
--- /dev/null
+++ b/include/linux/netfilter/xt_conntrack.h
@@ -0,0 +1,63 @@
+/* Header file for kernel module to match connection tracking information.
+ * GPL (C) 2001  Marc Boucher (marc@mbsi.ca).
+ */
+
+#ifndef _XT_CONNTRACK_H
+#define _XT_CONNTRACK_H
+
+#include <linux/netfilter/nf_conntrack_tuple_common.h>
+#include <linux/in.h>
+
+#define XT_CONNTRACK_STATE_BIT(ctinfo) (1 << ((ctinfo)%IP_CT_IS_REPLY+1))
+#define XT_CONNTRACK_STATE_INVALID (1 << 0)
+
+#define XT_CONNTRACK_STATE_SNAT (1 << (IP_CT_NUMBER + 1))
+#define XT_CONNTRACK_STATE_DNAT (1 << (IP_CT_NUMBER + 2))
+#define XT_CONNTRACK_STATE_UNTRACKED (1 << (IP_CT_NUMBER + 3))
+
+/* flags, invflags: */
+#define XT_CONNTRACK_STATE	0x01
+#define XT_CONNTRACK_PROTO	0x02
+#define XT_CONNTRACK_ORIGSRC	0x04
+#define XT_CONNTRACK_ORIGDST	0x08
+#define XT_CONNTRACK_REPLSRC	0x10
+#define XT_CONNTRACK_REPLDST	0x20
+#define XT_CONNTRACK_STATUS	0x40
+#define XT_CONNTRACK_EXPIRES	0x80
+
+/* This is exposed to userspace, so remains frozen in time. */
+struct ip_conntrack_old_tuple
+{
+	struct {
+		__u32 ip;
+		union {
+			__u16 all;
+		} u;
+	} src;
+
+	struct {
+		__u32 ip;
+		union {
+			__u16 all;
+		} u;
+
+		/* The protocol. */
+		u16 protonum;
+	} dst;
+};
+
+struct xt_conntrack_info
+{
+	unsigned int statemask, statusmask;
+
+	struct ip_conntrack_old_tuple tuple[IP_CT_DIR_MAX];
+	struct in_addr sipmsk[IP_CT_DIR_MAX], dipmsk[IP_CT_DIR_MAX];
+
+	unsigned long expires_min, expires_max;
+
+	/* Flags word */
+	u_int8_t flags;
+	/* Inverse flags */
+	u_int8_t invflags;
+};
+#endif /*_XT_CONNTRACK_H*/
diff --git a/include/linux/netfilter/xt_dccp.h b/include/linux/netfilter/xt=
_dccp.h
new file mode 100644
index 0000000..e0221b9
--- /dev/null
+++ b/include/linux/netfilter/xt_dccp.h
@@ -0,0 +1,23 @@
+#ifndef _XT_DCCP_H_
+#define _XT_DCCP_H_
+
+#define XT_DCCP_SRC_PORTS	        0x01
+#define XT_DCCP_DEST_PORTS	        0x02
+#define XT_DCCP_TYPE			0x04
+#define XT_DCCP_OPTION			0x08
+
+#define XT_DCCP_VALID_FLAGS		0x0f
+
+struct xt_dccp_info {
+	u_int16_t dpts[2];  /* Min, Max */
+	u_int16_t spts[2];  /* Min, Max */
+
+	u_int16_t flags;
+	u_int16_t invflags;
+
+	u_int16_t typemask;
+	u_int8_t option;
+};
+
+#endif /* _XT_DCCP_H_ */
+
diff --git a/include/linux/netfilter/xt_helper.h b/include/linux/netfilter/=
xt_helper.h
new file mode 100644
index 0000000..6b42763
--- /dev/null
+++ b/include/linux/netfilter/xt_helper.h
@@ -0,0 +1,8 @@
+#ifndef _XT_HELPER_H
+#define _XT_HELPER_H
+
+struct xt_helper_info {
+	int invert;
+	char name[30];
+};
+#endif /* _XT_HELPER_H */
diff --git a/include/linux/netfilter/xt_length.h b/include/linux/netfilter/=
xt_length.h
new file mode 100644
index 0000000..7c2b439
--- /dev/null
+++ b/include/linux/netfilter/xt_length.h
@@ -0,0 +1,9 @@
+#ifndef _XT_LENGTH_H
+#define _XT_LENGTH_H
+
+struct xt_length_info {
+    u_int16_t	min, max;
+    u_int8_t	invert;
+};
+
+#endif /*_XT_LENGTH_H*/
diff --git a/include/linux/netfilter/xt_limit.h b/include/linux/netfilter/x=
t_limit.h
new file mode 100644
index 0000000..b3ce653
--- /dev/null
+++ b/include/linux/netfilter/xt_limit.h
@@ -0,0 +1,21 @@
+#ifndef _XT_RATE_H
+#define _XT_RATE_H
+
+/* timings are in milliseconds. */
+#define XT_LIMIT_SCALE 10000
+
+/* 1/10,000 sec period =3D> max of 10,000/sec.  Min rate is then 429490
+   seconds, or one every 59 hours. */
+struct xt_rateinfo {
+	u_int32_t avg;    /* Average secs between packets * scale */
+	u_int32_t burst;  /* Period multiplier for upper limit. */
+
+	/* Used internally by the kernel */
+	unsigned long prev;
+	u_int32_t credit;
+	u_int32_t credit_cap, cost;
+
+	/* Ugly, ugly fucker. */
+	struct xt_rateinfo *master;
+};
+#endif /*_XT_RATE_H*/
diff --git a/include/linux/netfilter/xt_mac.h b/include/linux/netfilter/xt_=
mac.h
new file mode 100644
index 0000000..b892cdc
--- /dev/null
+++ b/include/linux/netfilter/xt_mac.h
@@ -0,0 +1,8 @@
+#ifndef _XT_MAC_H
+#define _XT_MAC_H
+
+struct xt_mac_info {
+    unsigned char srcaddr[ETH_ALEN];
+    int invert;
+};
+#endif /*_XT_MAC_H*/
diff --git a/include/linux/netfilter/xt_mark.h b/include/linux/netfilter/xt=
_mark.h
new file mode 100644
index 0000000..802dd48
--- /dev/null
+++ b/include/linux/netfilter/xt_mark.h
@@ -0,0 +1,9 @@
+#ifndef _XT_MARK_H
+#define _XT_MARK_H
+
+struct xt_mark_info {
+    unsigned long mark, mask;
+    u_int8_t invert;
+};
+
+#endif /*_XT_MARK_H*/
diff --git a/include/linux/netfilter/xt_physdev.h b/include/linux/netfilter=
/xt_physdev.h
new file mode 100644
index 0000000..25a7a18
--- /dev/null
+++ b/include/linux/netfilter/xt_physdev.h
@@ -0,0 +1,24 @@
+#ifndef _XT_PHYSDEV_H
+#define _XT_PHYSDEV_H
+
+#ifdef __KERNEL__
+#include <linux/if.h>
+#endif
+
+#define XT_PHYSDEV_OP_IN		0x01
+#define XT_PHYSDEV_OP_OUT		0x02
+#define XT_PHYSDEV_OP_BRIDGED		0x04
+#define XT_PHYSDEV_OP_ISIN		0x08
+#define XT_PHYSDEV_OP_ISOUT		0x10
+#define XT_PHYSDEV_OP_MASK		(0x20 - 1)
+
+struct xt_physdev_info {
+	char physindev[IFNAMSIZ];
+	char in_mask[IFNAMSIZ];
+	char physoutdev[IFNAMSIZ];
+	char out_mask[IFNAMSIZ];
+	u_int8_t invert;
+	u_int8_t bitmask;
+};
+
+#endif /*_XT_PHYSDEV_H*/
diff --git a/include/linux/netfilter/xt_pkttype.h b/include/linux/netfilter=
/xt_pkttype.h
new file mode 100644
index 0000000..f265cf5
--- /dev/null
+++ b/include/linux/netfilter/xt_pkttype.h
@@ -0,0 +1,8 @@
+#ifndef _XT_PKTTYPE_H
+#define _XT_PKTTYPE_H
+
+struct xt_pkttype_info {
+	int	pkttype;
+	int	invert;
+};
+#endif /*_XT_PKTTYPE_H*/
diff --git a/include/linux/netfilter/xt_realm.h b/include/linux/netfilter/x=
t_realm.h
new file mode 100644
index 0000000..220e872
--- /dev/null
+++ b/include/linux/netfilter/xt_realm.h
@@ -0,0 +1,10 @@
+#ifndef _XT_REALM_H
+#define _XT_REALM_H
+
+struct xt_realm_info {
+	u_int32_t id;
+	u_int32_t mask;
+	u_int8_t invert;
+};
+
+#endif /* _XT_REALM_H */
diff --git a/include/linux/netfilter/xt_sctp.h b/include/linux/netfilter/xt=
_sctp.h
new file mode 100644
index 0000000..b157897
--- /dev/null
+++ b/include/linux/netfilter/xt_sctp.h
@@ -0,0 +1,107 @@
+#ifndef _XT_SCTP_H_
+#define _XT_SCTP_H_
+
+#define XT_SCTP_SRC_PORTS	        0x01
+#define XT_SCTP_DEST_PORTS	        0x02
+#define XT_SCTP_CHUNK_TYPES		0x04
+
+#define XT_SCTP_VALID_FLAGS		0x07
+
+#define ELEMCOUNT(x) (sizeof(x)/sizeof(x[0]))
+
+
+struct xt_sctp_flag_info {
+	u_int8_t chunktype;
+	u_int8_t flag;
+	u_int8_t flag_mask;
+};
+
+#define XT_NUM_SCTP_FLAGS	4
+
+struct xt_sctp_info {
+	u_int16_t dpts[2];  /* Min, Max */
+	u_int16_t spts[2];  /* Min, Max */
+
+	u_int32_t chunkmap[256 / sizeof (u_int32_t)];  /* Bit mask of chunks to b=
e matched according to RFC 2960 */
+
+#define SCTP_CHUNK_MATCH_ANY   0x01  /* Match if any of the chunk types ar=
e present */
+#define SCTP_CHUNK_MATCH_ALL   0x02  /* Match if all of the chunk types ar=
e present */
+#define SCTP_CHUNK_MATCH_ONLY  0x04  /* Match if these are the only chunk =
types present */
+
+	u_int32_t chunk_match_type;
+	struct xt_sctp_flag_info flag_info[XT_NUM_SCTP_FLAGS];
+	int flag_count;
+
+	u_int32_t flags;
+	u_int32_t invflags;
+};
+
+#define bytes(type) (sizeof(type) * 8)
+
+#define SCTP_CHUNKMAP_SET(chunkmap, type) 		\
+	do { 						\
+		chunkmap[type / bytes(u_int32_t)] |=3D 	\
+			1 << (type % bytes(u_int32_t));	\
+	} while (0)
+
+#define SCTP_CHUNKMAP_CLEAR(chunkmap, type)		 	\
+	do {							\
+		chunkmap[type / bytes(u_int32_t)] &=3D 		\
+			~(1 << (type % bytes(u_int32_t)));	\
+	} while (0)
+
+#define SCTP_CHUNKMAP_IS_SET(chunkmap, type) 			\
+({								\
+	(chunkmap[type / bytes (u_int32_t)] & 			\
+		(1 << (type % bytes (u_int32_t)))) ? 1: 0;	\
+})
+
+#define SCTP_CHUNKMAP_RESET(chunkmap) 				\
+	do {							\
+		int i; 						\
+		for (i =3D 0; i < ELEMCOUNT(chunkmap); i++)	\
+			chunkmap[i] =3D 0;			\
+	} while (0)
+
+#define SCTP_CHUNKMAP_SET_ALL(chunkmap) 			\
+	do {							\
+		int i; 						\
+		for (i =3D 0; i < ELEMCOUNT(chunkmap); i++) 	\
+			chunkmap[i] =3D ~0;			\
+	} while (0)
+
+#define SCTP_CHUNKMAP_COPY(destmap, srcmap) 			\
+	do {							\
+		int i; 						\
+		for (i =3D 0; i < ELEMCOUNT(chunkmap); i++) 	\
+			destmap[i] =3D srcmap[i];			\
+	} while (0)
+
+#define SCTP_CHUNKMAP_IS_CLEAR(chunkmap) 		\
+({							\
+	int i; 						\
+	int flag =3D 1;					\
+	for (i =3D 0; i < ELEMCOUNT(chunkmap); i++) {	\
+		if (chunkmap[i]) {			\
+			flag =3D 0;			\
+			break;				\
+		}					\
+	}						\
+        flag;						\
+})
+
+#define SCTP_CHUNKMAP_IS_ALL_SET(chunkmap) 		\
+({							\
+	int i; 						\
+	int flag =3D 1;					\
+	for (i =3D 0; i < ELEMCOUNT(chunkmap); i++) {	\
+		if (chunkmap[i] !=3D ~0) {		\
+			flag =3D 0;			\
+				break;			\
+		}					\
+	}						\
+        flag;						\
+})
+
+#endif /* _XT_SCTP_H_ */
+
diff --git a/include/linux/netfilter/xt_state.h b/include/linux/netfilter/x=
t_state.h
new file mode 100644
index 0000000..c06f32e
--- /dev/null
+++ b/include/linux/netfilter/xt_state.h
@@ -0,0 +1,13 @@
+#ifndef _XT_STATE_H
+#define _XT_STATE_H
+
+#define XT_STATE_BIT(ctinfo) (1 << ((ctinfo)%IP_CT_IS_REPLY+1))
+#define XT_STATE_INVALID (1 << 0)
+
+#define XT_STATE_UNTRACKED (1 << (IP_CT_NUMBER + 1))
+
+struct xt_state_info
+{
+	unsigned int statemask;
+};
+#endif /*_XT_STATE_H*/
diff --git a/include/linux/netfilter/xt_string.h b/include/linux/netfilter/=
xt_string.h
new file mode 100644
index 0000000..3b3419f
--- /dev/null
+++ b/include/linux/netfilter/xt_string.h
@@ -0,0 +1,18 @@
+#ifndef _XT_STRING_H
+#define _XT_STRING_H
+
+#define XT_STRING_MAX_PATTERN_SIZE 128
+#define XT_STRING_MAX_ALGO_NAME_SIZE 16
+
+struct xt_string_info
+{
+	u_int16_t from_offset;
+	u_int16_t to_offset;
+	char	  algo[XT_STRING_MAX_ALGO_NAME_SIZE];
+	char 	  pattern[XT_STRING_MAX_PATTERN_SIZE];
+	u_int8_t  patlen;
+	u_int8_t  invert;
+	struct ts_config __attribute__((aligned(8))) *config;
+};
+
+#endif /*_XT_STRING_H*/
diff --git a/include/linux/netfilter/xt_tcpmss.h b/include/linux/netfilter/=
xt_tcpmss.h
new file mode 100644
index 0000000..e03274c
--- /dev/null
+++ b/include/linux/netfilter/xt_tcpmss.h
@@ -0,0 +1,9 @@
+#ifndef _XT_TCPMSS_MATCH_H
+#define _XT_TCPMSS_MATCH_H
+
+struct xt_tcpmss_match_info {
+    u_int16_t mss_min, mss_max;
+    u_int8_t invert;
+};
+
+#endif /*_XT_TCPMSS_MATCH_H*/
diff --git a/include/linux/netfilter/xt_tcpudp.h b/include/linux/netfilter/=
xt_tcpudp.h
new file mode 100644
index 0000000..78bc65f
--- /dev/null
+++ b/include/linux/netfilter/xt_tcpudp.h
@@ -0,0 +1,36 @@
+#ifndef _XT_TCPUDP_H
+#define _XT_TCPUDP_H
+
+/* TCP matching stuff */
+struct xt_tcp
+{
+	u_int16_t spts[2];			/* Source port range. */
+	u_int16_t dpts[2];			/* Destination port range. */
+	u_int8_t option;			/* TCP Option iff non-zero*/
+	u_int8_t flg_mask;			/* TCP flags mask byte */
+	u_int8_t flg_cmp;			/* TCP flags compare byte */
+	u_int8_t invflags;			/* Inverse flags */
+};
+
+/* Values for "inv" field in struct ipt_tcp. */
+#define XT_TCP_INV_SRCPT	0x01	/* Invert the sense of source ports. */
+#define XT_TCP_INV_DSTPT	0x02	/* Invert the sense of dest ports. */
+#define XT_TCP_INV_FLAGS	0x04	/* Invert the sense of TCP flags. */
+#define XT_TCP_INV_OPTION	0x08	/* Invert the sense of option test. */
+#define XT_TCP_INV_MASK		0x0F	/* All possible flags. */
+
+/* UDP matching stuff */
+struct xt_udp
+{
+	u_int16_t spts[2];			/* Source port range. */
+	u_int16_t dpts[2];			/* Destination port range. */
+	u_int8_t invflags;			/* Inverse flags */
+};
+
+/* Values for "invflags" field in struct ipt_udp. */
+#define XT_UDP_INV_SRCPT	0x01	/* Invert the sense of source ports. */
+#define XT_UDP_INV_DSTPT	0x02	/* Invert the sense of dest ports. */
+#define XT_UDP_INV_MASK	0x03	/* All possible flags. */
+
+
+#endif
diff --git a/include/linux/netfilter_arp/arp_tables.h b/include/linux/netfi=
lter_arp/arp_tables.h
index e98a870..fd21796 100644
--- a/include/linux/netfilter_arp/arp_tables.h
+++ b/include/linux/netfilter_arp/arp_tables.h
@@ -19,8 +19,12 @@
 #include <linux/compiler.h>
 #include <linux/netfilter_arp.h>
=20
-#define ARPT_FUNCTION_MAXNAMELEN 30
-#define ARPT_TABLE_MAXNAMELEN 32
+#include <linux/netfilter/x_tables.h>
+
+#define ARPT_FUNCTION_MAXNAMELEN XT_FUNCTION_MAXNAMELEN
+#define ARPT_TABLE_MAXNAMELEN XT_TABLE_MAXNAMELEN
+#define arpt_target xt_target
+#define arpt_table xt_table
=20
 #define ARPT_DEV_ADDR_LEN_MAX 16
=20
@@ -91,11 +95,6 @@ struct arpt_standard_target
 	int verdict;
 };
=20
-struct arpt_counters
-{
-	u_int64_t pcnt, bcnt;			/* Packet and byte counters */
-};
-
 /* Values for "flag" field in struct arpt_ip (general arp structure).
  * No flags defined yet.
  */
@@ -130,7 +129,7 @@ struct arpt_entry
 	unsigned int comefrom;
=20
 	/* Packet and byte counters. */
-	struct arpt_counters counters;
+	struct xt_counters counters;
=20
 	/* The matches (if any), then the target. */
 	unsigned char elems[0];
@@ -141,23 +140,24 @@ struct arpt_entry
  * Unlike BSD Linux inherits IP options so you don't have to use a raw
  * socket for this. Instead we check rights in the calls.
  */
-#define ARPT_BASE_CTL		96	/* base for firewall socket options */
+#define ARPT_CTL_OFFSET		32
+#define ARPT_BASE_CTL		(XT_BASE_CTL+ARPT_CTL_OFFSET)
=20
-#define ARPT_SO_SET_REPLACE		(ARPT_BASE_CTL)
-#define ARPT_SO_SET_ADD_COUNTERS	(ARPT_BASE_CTL + 1)
-#define ARPT_SO_SET_MAX			ARPT_SO_SET_ADD_COUNTERS
-
-#define ARPT_SO_GET_INFO		(ARPT_BASE_CTL)
-#define ARPT_SO_GET_ENTRIES		(ARPT_BASE_CTL + 1)
-/* #define ARPT_SO_GET_REVISION_MATCH	(ARPT_BASE_CTL + 2)*/
-#define ARPT_SO_GET_REVISION_TARGET	(ARPT_BASE_CTL + 3)
-#define ARPT_SO_GET_MAX			ARPT_SO_GET_REVISION_TARGET
+#define ARPT_SO_SET_REPLACE		(XT_SO_SET_REPLACE+ARPT_CTL_OFFSET)
+#define ARPT_SO_SET_ADD_COUNTERS	(XT_SO_SET_ADD_COUNTERS+ARPT_CTL_OFFSET)
+#define ARPT_SO_SET_MAX			(XT_SO_SET_MAX+ARPT_CTL_OFFSET)
+
+#define ARPT_SO_GET_INFO		(XT_SO_GET_INFO+ARPT_CTL_OFFSET)
+#define ARPT_SO_GET_ENTRIES		(XT_SO_GET_ENTRIES+ARPT_CTL_OFFSET)
+/* #define ARPT_SO_GET_REVISION_MATCH	XT_SO_GET_REVISION_MATCH  */
+#define ARPT_SO_GET_REVISION_TARGET	(XT_SO_GET_REVISION_TARGET+ARPT_CTL_OF=
FSET)
+#define ARPT_SO_GET_MAX			(XT_SO_GET_REVISION_TARGET+ARPT_CTL_OFFSET)
=20
 /* CONTINUE verdict for targets */
-#define ARPT_CONTINUE 0xFFFFFFFF
+#define ARPT_CONTINUE XT_CONTINUE
=20
 /* For standard target */
-#define ARPT_RETURN (-NF_REPEAT - 1)
+#define ARPT_RETURN XT_RETURN
=20
 /* The argument to ARPT_SO_GET_INFO */
 struct arpt_getinfo
@@ -208,23 +208,14 @@ struct arpt_replace
 	/* Number of counters (must be equal to current number of entries). */
 	unsigned int num_counters;
 	/* The old entries' counters. */
-	struct arpt_counters __user *counters;
+	struct xt_counters __user *counters;
=20
 	/* The entries (hang off end: not really an array). */
 	struct arpt_entry entries[0];
 };
=20
 /* The argument to ARPT_SO_ADD_COUNTERS. */
-struct arpt_counters_info
-{
-	/* Which table. */
-	char name[ARPT_TABLE_MAXNAMELEN];
-
-	unsigned int num_counters;
-
-	/* The counters (actually `number' of these). */
-	struct arpt_counters counters[0];
-};
+#define arpt_counters_info xt_counters_info
=20
 /* The argument to ARPT_SO_GET_ENTRIES. */
 struct arpt_get_entries
@@ -239,19 +230,10 @@ struct arpt_get_entries
 	struct arpt_entry entrytable[0];
 };
=20
-/* The argument to ARPT_SO_GET_REVISION_*.  Returns highest revision
- * kernel supports, if >=3D revision. */
-struct arpt_get_revision
-{
-	char name[ARPT_FUNCTION_MAXNAMELEN-1];
-
-	u_int8_t revision;
-};
-
 /* Standard return verdict, or do jump. */
-#define ARPT_STANDARD_TARGET ""
+#define ARPT_STANDARD_TARGET XT_STANDARD_TARGET
 /* Error verdict. */
-#define ARPT_ERROR_TARGET "ERROR"
+#define ARPT_ERROR_TARGET XT_ERROR_TARGET
=20
 /* Helper functions */
 static __inline__ struct arpt_entry_target *arpt_get_target(struct arpt_en=
try *e)
@@ -281,63 +263,8 @@ static __inline__ struct arpt_entry_targ
  */
 #ifdef __KERNEL__
=20
-/* Registration hooks for targets. */
-struct arpt_target
-{
-	struct list_head list;
-
-	const char name[ARPT_FUNCTION_MAXNAMELEN-1];
-
-	u_int8_t revision;
-
-	/* Returns verdict. */
-	unsigned int (*target)(struct sk_buff **pskb,
-			       unsigned int hooknum,
-			       const struct net_device *in,
-			       const struct net_device *out,
-			       const void *targinfo,
-			       void *userdata);
-
-	/* Called when user tries to insert an entry of this type:
-           hook_mask is a bitmask of hooks from which it can be
-           called. */
-	/* Should return true or false. */
-	int (*checkentry)(const char *tablename,
-			  const struct arpt_entry *e,
-			  void *targinfo,
-			  unsigned int targinfosize,
-			  unsigned int hook_mask);
-
-	/* Called when entry of this type deleted. */
-	void (*destroy)(void *targinfo, unsigned int targinfosize);
-
-	/* Set this to THIS_MODULE if you are a module, otherwise NULL */
-	struct module *me;
-};
-
-extern int arpt_register_target(struct arpt_target *target);
-extern void arpt_unregister_target(struct arpt_target *target);
-
-/* Furniture shopping... */
-struct arpt_table
-{
-	struct list_head list;
-
-	/* A unique name... */
-	char name[ARPT_TABLE_MAXNAMELEN];
-
-	/* What hooks you will enter on */
-	unsigned int valid_hooks;
-
-	/* Lock for the curtain */
-	rwlock_t lock;
-
-	/* Man behind the curtain... */
-	struct arpt_table_info *private;
-
-	/* Set this to THIS_MODULE if you are a module, otherwise NULL */
-	struct module *me;
-};
+#define arpt_register_target(tgt) xt_register_target(NF_ARP, tgt)
+#define arpt_unregister_target(tgt) xt_unregister_target(NF_ARP, tgt)
=20
 extern int arpt_register_table(struct arpt_table *table,
 			       const struct arpt_replace *repl);
diff --git a/include/linux/netfilter_ipv4/ip_conntrack.h b/include/linux/ne=
tfilter_ipv4/ip_conntrack.h
index b3432ab..215765f 100644
--- a/include/linux/netfilter_ipv4/ip_conntrack.h
+++ b/include/linux/netfilter_ipv4/ip_conntrack.h
@@ -199,9 +199,6 @@ ip_conntrack_put(struct ip_conntrack *ct
 	nf_conntrack_put(&ct->ct_general);
 }
=20
-/* call to create an explicit dependency on ip_conntrack. */
-extern void need_ip_conntrack(void);
-
 extern int invert_tuplepr(struct ip_conntrack_tuple *inverse,
 			  const struct ip_conntrack_tuple *orig);
=20
diff --git a/include/linux/netfilter_ipv4/ip_tables.h b/include/linux/netfi=
lter_ipv4/ip_tables.h
index d19d65c..76ba24b 100644
--- a/include/linux/netfilter_ipv4/ip_tables.h
+++ b/include/linux/netfilter_ipv4/ip_tables.h
@@ -25,8 +25,14 @@
 #include <linux/compiler.h>
 #include <linux/netfilter_ipv4.h>
=20
-#define IPT_FUNCTION_MAXNAMELEN 30
-#define IPT_TABLE_MAXNAMELEN 32
+#include <linux/netfilter/x_tables.h>
+
+#define IPT_FUNCTION_MAXNAMELEN XT_FUNCTION_MAXNAMELEN
+#define IPT_TABLE_MAXNAMELEN XT_FUNCTION_MAXNAMELEN
+#define ipt_match xt_match
+#define ipt_target xt_target
+#define ipt_table xt_table
+#define ipt_get_revision xt_get_revision
=20
 /* Yes, Virginia, you have to zero the padding. */
 struct ipt_ip {
@@ -102,10 +108,7 @@ struct ipt_standard_target
 	int verdict;
 };
=20
-struct ipt_counters
-{
-	u_int64_t pcnt, bcnt;			/* Packet and byte counters */
-};
+#define ipt_counters xt_counters
=20
 /* Values for "flag" field in struct ipt_ip (general ip structure). */
 #define IPT_F_FRAG		0x01	/* Set if rule is a fragment rule */
@@ -119,7 +122,7 @@ struct ipt_counters
 #define IPT_INV_SRCIP		0x08	/* Invert the sense of SRC IP. */
 #define IPT_INV_DSTIP		0x10	/* Invert the sense of DST OP. */
 #define IPT_INV_FRAG		0x20	/* Invert the sense of FRAG. */
-#define IPT_INV_PROTO		0x40	/* Invert the sense of PROTO. */
+#define IPT_INV_PROTO		XT_INV_PROTO
 #define IPT_INV_MASK		0x7F	/* All possible flag bits mask. */
=20
 /* This structure defines each of the firewall rules.  Consists of 3
@@ -141,7 +144,7 @@ struct ipt_entry
 	unsigned int comefrom;
=20
 	/* Packet and byte counters. */
-	struct ipt_counters counters;
+	struct xt_counters counters;
=20
 	/* The matches (if any), then the target. */
 	unsigned char elems[0];
@@ -151,54 +154,34 @@ struct ipt_entry
  * New IP firewall options for [gs]etsockopt at the RAW IP level.
  * Unlike BSD Linux inherits IP options so you don't have to use a raw
  * socket for this. Instead we check rights in the calls. */
-#define IPT_BASE_CTL		64	/* base for firewall socket options */
-
-#define IPT_SO_SET_REPLACE	(IPT_BASE_CTL)
-#define IPT_SO_SET_ADD_COUNTERS	(IPT_BASE_CTL + 1)
-#define IPT_SO_SET_MAX		IPT_SO_SET_ADD_COUNTERS
-
-#define IPT_SO_GET_INFO			(IPT_BASE_CTL)
-#define IPT_SO_GET_ENTRIES		(IPT_BASE_CTL + 1)
-#define IPT_SO_GET_REVISION_MATCH	(IPT_BASE_CTL + 2)
-#define IPT_SO_GET_REVISION_TARGET	(IPT_BASE_CTL + 3)
-#define IPT_SO_GET_MAX			IPT_SO_GET_REVISION_TARGET
-
-/* CONTINUE verdict for targets */
-#define IPT_CONTINUE 0xFFFFFFFF
-
-/* For standard target */
-#define IPT_RETURN (-NF_REPEAT - 1)
-
-/* TCP matching stuff */
-struct ipt_tcp
-{
-	u_int16_t spts[2];			/* Source port range. */
-	u_int16_t dpts[2];			/* Destination port range. */
-	u_int8_t option;			/* TCP Option iff non-zero*/
-	u_int8_t flg_mask;			/* TCP flags mask byte */
-	u_int8_t flg_cmp;			/* TCP flags compare byte */
-	u_int8_t invflags;			/* Inverse flags */
-};
-
-/* Values for "inv" field in struct ipt_tcp. */
-#define IPT_TCP_INV_SRCPT	0x01	/* Invert the sense of source ports. */
-#define IPT_TCP_INV_DSTPT	0x02	/* Invert the sense of dest ports. */
-#define IPT_TCP_INV_FLAGS	0x04	/* Invert the sense of TCP flags. */
-#define IPT_TCP_INV_OPTION	0x08	/* Invert the sense of option test. */
-#define IPT_TCP_INV_MASK	0x0F	/* All possible flags. */
+#define IPT_BASE_CTL		XT_BASE_CTL
=20
-/* UDP matching stuff */
-struct ipt_udp
-{
-	u_int16_t spts[2];			/* Source port range. */
-	u_int16_t dpts[2];			/* Destination port range. */
-	u_int8_t invflags;			/* Inverse flags */
-};
-
-/* Values for "invflags" field in struct ipt_udp. */
-#define IPT_UDP_INV_SRCPT	0x01	/* Invert the sense of source ports. */
-#define IPT_UDP_INV_DSTPT	0x02	/* Invert the sense of dest ports. */
-#define IPT_UDP_INV_MASK	0x03	/* All possible flags. */
+#define IPT_SO_SET_REPLACE	XT_SO_SET_REPLACE
+#define IPT_SO_SET_ADD_COUNTERS	XT_SO_SET_ADD_COUNTERS
+#define IPT_SO_SET_MAX		XT_SO_SET_MAX
+
+#define IPT_SO_GET_INFO			XT_SO_GET_INFO
+#define IPT_SO_GET_ENTRIES		XT_SO_GET_ENTRIES
+#define IPT_SO_GET_REVISION_MATCH	XT_SO_GET_REVISION_MATCH
+#define IPT_SO_GET_REVISION_TARGET	XT_SO_GET_REVISION_TARGET
+#define IPT_SO_GET_MAX			XT_SO_GET_REVISION_TARGET
+
+#define IPT_CONTINUE XT_CONTINUE
+#define IPT_RETURN XT_RETURN
+
+#include <linux/netfilter/xt_tcpudp.h>
+#define ipt_udp xt_udp
+#define ipt_tcp xt_tcp
+
+#define IPT_TCP_INV_SRCPT	XT_TCP_INV_SRCPT
+#define IPT_TCP_INV_DSTPT	XT_TCP_INV_DSTPT
+#define IPT_TCP_INV_FLAGS	XT_TCP_INV_FLAGS
+#define IPT_TCP_INV_OPTION	XT_TCP_INV_OPTION
+#define IPT_TCP_INV_MASK	XT_TCP_INV_MASK
+
+#define IPT_UDP_INV_SRCPT	XT_UDP_INV_SRCPT
+#define IPT_UDP_INV_DSTPT	XT_UDP_INV_DSTPT
+#define IPT_UDP_INV_MASK	XT_UDP_INV_MASK
=20
 /* ICMP matching stuff */
 struct ipt_icmp
@@ -260,23 +243,14 @@ struct ipt_replace
 	/* Number of counters (must be equal to current number of entries). */
 	unsigned int num_counters;
 	/* The old entries' counters. */
-	struct ipt_counters __user *counters;
+	struct xt_counters __user *counters;
=20
 	/* The entries (hang off end: not really an array). */
 	struct ipt_entry entries[0];
 };
=20
 /* The argument to IPT_SO_ADD_COUNTERS. */
-struct ipt_counters_info
-{
-	/* Which table. */
-	char name[IPT_TABLE_MAXNAMELEN];
-
-	unsigned int num_counters;
-
-	/* The counters (actually `number' of these). */
-	struct ipt_counters counters[0];
-};
+#define ipt_counters_info xt_counters_info
=20
 /* The argument to IPT_SO_GET_ENTRIES. */
 struct ipt_get_entries
@@ -291,19 +265,10 @@ struct ipt_get_entries
 	struct ipt_entry entrytable[0];
 };
=20
-/* The argument to IPT_SO_GET_REVISION_*.  Returns highest revision
- * kernel supports, if >=3D revision. */
-struct ipt_get_revision
-{
-	char name[IPT_FUNCTION_MAXNAMELEN-1];
-
-	u_int8_t revision;
-};
-
 /* Standard return verdict, or do jump. */
-#define IPT_STANDARD_TARGET ""
+#define IPT_STANDARD_TARGET XT_STANDARD_TARGET
 /* Error verdict. */
-#define IPT_ERROR_TARGET "ERROR"
+#define IPT_ERROR_TARGET XT_ERROR_TARGET
=20
 /* Helper functions */
 static __inline__ struct ipt_entry_target *
@@ -356,103 +321,18 @@ ipt_get_target(struct ipt_entry *e)
 #include <linux/init.h>
 extern void ipt_init(void) __init;
=20
-struct ipt_match
-{
-	struct list_head list;
-
-	const char name[IPT_FUNCTION_MAXNAMELEN-1];
-
-	u_int8_t revision;
-
-	/* Return true or false: return FALSE and set *hotdrop =3D 1 to
-           force immediate packet drop. */
-	/* Arguments changed since 2.4, as this must now handle
-           non-linear skbs, using skb_copy_bits and
-           skb_ip_make_writable. */
-	int (*match)(const struct sk_buff *skb,
-		     const struct net_device *in,
-		     const struct net_device *out,
-		     const void *matchinfo,
-		     int offset,
-		     int *hotdrop);
-
-	/* Called when user tries to insert an entry of this type. */
-	/* Should return true or false. */
-	int (*checkentry)(const char *tablename,
-			  const struct ipt_ip *ip,
-			  void *matchinfo,
-			  unsigned int matchinfosize,
-			  unsigned int hook_mask);
+#define ipt_register_target(tgt) xt_register_target(AF_INET, tgt)
+#define ipt_unregister_target(tgt) xt_unregister_target(AF_INET, tgt)
=20
-	/* Called when entry of this type deleted. */
-	void (*destroy)(void *matchinfo, unsigned int matchinfosize);
+#define ipt_register_match(mtch) xt_register_match(AF_INET, mtch)
+#define ipt_unregister_match(mtch) xt_unregister_match(AF_INET, mtch)
=20
-	/* Set this to THIS_MODULE. */
-	struct module *me;
-};
-
-/* Registration hooks for targets. */
-struct ipt_target
-{
-	struct list_head list;
-
-	const char name[IPT_FUNCTION_MAXNAMELEN-1];
-
-	u_int8_t revision;
-
-	/* Called when user tries to insert an entry of this type:
-           hook_mask is a bitmask of hooks from which it can be
-           called. */
-	/* Should return true or false. */
-	int (*checkentry)(const char *tablename,
-			  const struct ipt_entry *e,
-			  void *targinfo,
-			  unsigned int targinfosize,
-			  unsigned int hook_mask);
-
-	/* Called when entry of this type deleted. */
-	void (*destroy)(void *targinfo, unsigned int targinfosize);
-
-	/* Returns verdict.  Argument order changed since 2.4, as this
-           must now handle non-linear skbs, using skb_copy_bits and
-           skb_ip_make_writable. */
-	unsigned int (*target)(struct sk_buff **pskb,
-			       const struct net_device *in,
-			       const struct net_device *out,
-			       unsigned int hooknum,
-			       const void *targinfo,
-			       void *userdata);
-
-	/* Set this to THIS_MODULE. */
-	struct module *me;
-};
-
-extern int ipt_register_target(struct ipt_target *target);
-extern void ipt_unregister_target(struct ipt_target *target);
-
-extern int ipt_register_match(struct ipt_match *match);
-extern void ipt_unregister_match(struct ipt_match *match);
-
-/* Furniture shopping... */
-struct ipt_table
-{
-	struct list_head list;
+//#define ipt_register_table(tbl, repl) xt_register_table(AF_INET, tbl, re=
pl)
+//#define ipt_unregister_table(tbl) xt_unregister_table(AF_INET, tbl)
=20
-	/* A unique name... */
-	char name[IPT_TABLE_MAXNAMELEN];
-
-	/* What hooks you will enter on */
-	unsigned int valid_hooks;
-
-	/* Lock for the curtain */
-	rwlock_t lock;
-
-	/* Man behind the curtain... */
-	struct ipt_table_info *private;
-
-	/* Set to THIS_MODULE. */
-	struct module *me;
-};
+extern int ipt_register_table(struct ipt_table *table,
+			      const struct ipt_replace *repl);
+extern void ipt_unregister_table(struct ipt_table *table);
=20
 /* net/sched/ipt.c: Gimme access to your targets!  Gets target->me. */
 extern struct ipt_target *ipt_find_target(const char *name, u8 revision);
@@ -476,9 +356,6 @@ struct ipt_error
 	struct ipt_error_target target;
 };
=20
-extern int ipt_register_table(struct ipt_table *table,
-			      const struct ipt_replace *repl);
-extern void ipt_unregister_table(struct ipt_table *table);
 extern unsigned int ipt_do_table(struct sk_buff **pskb,
 				 unsigned int hook,
 				 const struct net_device *in,
@@ -486,6 +363,6 @@ extern unsigned int ipt_do_table(struct=20
 				 struct ipt_table *table,
 				 void *userdata);
=20
-#define IPT_ALIGN(s) (((s) + (__alignof__(struct ipt_entry)-1)) & ~(__alig=
nof__(struct ipt_entry)-1))
+#define IPT_ALIGN(s) XT_ALIGN(s)
 #endif /*__KERNEL__*/
 #endif /* _IPTABLES_H */
diff --git a/include/linux/netfilter_ipv4/ipt_CLASSIFY.h b/include/linux/ne=
tfilter_ipv4/ipt_CLASSIFY.h
index 7596e3d..a46d511 100644
--- a/include/linux/netfilter_ipv4/ipt_CLASSIFY.h
+++ b/include/linux/netfilter_ipv4/ipt_CLASSIFY.h
@@ -1,8 +1,7 @@
 #ifndef _IPT_CLASSIFY_H
 #define _IPT_CLASSIFY_H
=20
-struct ipt_classify_target_info {
-	u_int32_t priority;
-};
+#include <linux/netfilter/xt_CLASSIFY.h>
+#define ipt_classify_target_info xt_classify_target_info
=20
 #endif /*_IPT_CLASSIFY_H */
diff --git a/include/linux/netfilter_ipv4/ipt_CONNMARK.h b/include/linux/ne=
tfilter_ipv4/ipt_CONNMARK.h
index d3c0253..9ecfee0 100644
--- a/include/linux/netfilter_ipv4/ipt_CONNMARK.h
+++ b/include/linux/netfilter_ipv4/ipt_CONNMARK.h
@@ -9,17 +9,11 @@
  * the Free Software Foundation; either version 2 of the License, or
  * (at your option) any later version.
  */
+#include <linux/netfilter/xt_CONNMARK.h>
+#define IPT_CONNMARK_SET	XT_CONNMARK_SET
+#define IPT_CONNMARK_SAVE	XT_CONNMARK_SAVE
+#define	IPT_CONNMARK_RESTORE	XT_CONNMARK_RESTORE
=20
-enum {
-	IPT_CONNMARK_SET =3D 0,
-	IPT_CONNMARK_SAVE,
-	IPT_CONNMARK_RESTORE
-};
-
-struct ipt_connmark_target_info {
-	unsigned long mark;
-	unsigned long mask;
-	u_int8_t mode;
-};
+#define ipt_connmark_target_info xt_connmark_target_info
=20
 #endif /*_IPT_CONNMARK_H_target*/
diff --git a/include/linux/netfilter_ipv4/ipt_MARK.h b/include/linux/netfil=
ter_ipv4/ipt_MARK.h
index f474857..697a486 100644
--- a/include/linux/netfilter_ipv4/ipt_MARK.h
+++ b/include/linux/netfilter_ipv4/ipt_MARK.h
@@ -1,20 +1,18 @@
 #ifndef _IPT_MARK_H_target
 #define _IPT_MARK_H_target
=20
+/* Backwards compatibility for old userspace */
+
+#include <linux/netfilter/xt_MARK.h>
+
 /* Version 0 */
-struct ipt_mark_target_info {
-	unsigned long mark;
-};
+#define ipt_mark_target_info xt_mark_target_info
=20
 /* Version 1 */
-enum {
-	IPT_MARK_SET=3D0,
-	IPT_MARK_AND,
-	IPT_MARK_OR
-};
-
-struct ipt_mark_target_info_v1 {
-	unsigned long mark;
-	u_int8_t mode;
-};
+#define IPT_MARK_SET	XT_MARK_SET
+#define IPT_MARK_AND	XT_MARK_AND
+#define	IPT_MARK_OR	XT_MARK_OR
+
+#define ipt_mark_target_info_v1 xt_mark_target_info_v1
+
 #endif /*_IPT_MARK_H_target*/
diff --git a/include/linux/netfilter_ipv4/ipt_NFQUEUE.h b/include/linux/net=
filter_ipv4/ipt_NFQUEUE.h
index b5b2943..97a2a75 100644
--- a/include/linux/netfilter_ipv4/ipt_NFQUEUE.h
+++ b/include/linux/netfilter_ipv4/ipt_NFQUEUE.h
@@ -8,9 +8,9 @@
 #ifndef _IPT_NFQ_TARGET_H
 #define _IPT_NFQ_TARGET_H
=20
-/* target info */
-struct ipt_NFQ_info {
-	u_int16_t queuenum;
-};
+/* Backwards compatibility for old userspace */
+#include <linux/netfilter/xt_NFQUEUE.h>
+
+#define ipt_NFQ_info xt_NFQ_info
=20
 #endif /* _IPT_DSCP_TARGET_H */
diff --git a/include/linux/netfilter_ipv4/ipt_comment.h b/include/linux/net=
filter_ipv4/ipt_comment.h
index 85c1123..ae2afc2 100644
--- a/include/linux/netfilter_ipv4/ipt_comment.h
+++ b/include/linux/netfilter_ipv4/ipt_comment.h
@@ -1,10 +1,10 @@
 #ifndef _IPT_COMMENT_H
 #define _IPT_COMMENT_H
=20
-#define IPT_MAX_COMMENT_LEN 256
+#include <linux/netfilter/xt_comment.h>
=20
-struct ipt_comment_info {
-	unsigned char comment[IPT_MAX_COMMENT_LEN];
-};
+#define IPT_MAX_COMMENT_LEN XT_MAX_COMMENT_LEN
+
+#define ipt_comment_info xt_comment_info
=20
 #endif /* _IPT_COMMENT_H */
diff --git a/include/linux/netfilter_ipv4/ipt_connbytes.h b/include/linux/n=
etfilter_ipv4/ipt_connbytes.h
index 9e5532f..b04dfa3 100644
--- a/include/linux/netfilter_ipv4/ipt_connbytes.h
+++ b/include/linux/netfilter_ipv4/ipt_connbytes.h
@@ -1,25 +1,18 @@
 #ifndef _IPT_CONNBYTES_H
 #define _IPT_CONNBYTES_H
=20
-enum ipt_connbytes_what {
-	IPT_CONNBYTES_PKTS,
-	IPT_CONNBYTES_BYTES,
-	IPT_CONNBYTES_AVGPKT,
-};
+#include <net/netfilter/xt_connbytes.h>
+#define ipt_connbytes_what xt_connbytes_what
=20
-enum ipt_connbytes_direction {
-	IPT_CONNBYTES_DIR_ORIGINAL,
-	IPT_CONNBYTES_DIR_REPLY,
-	IPT_CONNBYTES_DIR_BOTH,
-};
+#define IPT_CONNBYTES_PKTS	XT_CONNBYTES_PACKETS
+#define IPT_CONNBYTES_BYTES	XT_CONNBYTES_BYTES
+#define IPT_CONNBYTES_AVGPKT	XT_CONNBYTES_AVGPKT
+
+#define ipt_connbytes_direction 	xt_connbytes_direction
+#define IPT_CONNBYTES_DIR_ORIGINAL 	XT_CONNBYTES_DIR_ORIGINAL
+#define IPT_CONNBYTES_DIR_REPLY 	XT_CONNBYTES_DIR_REPLY
+#define IPT_CONNBYTES_DIR_BOTH		XT_CONNBYTES_DIR_BOTH
+
+#define ipt_connbytes_info xt_connbytes_info
=20
-struct ipt_connbytes_info
-{
-	struct {
-		aligned_u64 from;	/* count to be matched */
-		aligned_u64 to;		/* count to be matched */
-	} count;
-	u_int8_t what;		/* ipt_connbytes_what */
-	u_int8_t direction;	/* ipt_connbytes_direction */
-};
 #endif
diff --git a/include/linux/netfilter_ipv4/ipt_connmark.h b/include/linux/ne=
tfilter_ipv4/ipt_connmark.h
index 4657327..c7ba656 100644
--- a/include/linux/netfilter_ipv4/ipt_connmark.h
+++ b/include/linux/netfilter_ipv4/ipt_connmark.h
@@ -1,18 +1,7 @@
 #ifndef _IPT_CONNMARK_H
 #define _IPT_CONNMARK_H
=20
-/* Copyright (C) 2002,2004 MARA Systems AB <http://www.marasystems.com>
- * by Henrik Nordstrom <hno@marasystems.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- */
-
-struct ipt_connmark_info {
-	unsigned long mark, mask;
-	u_int8_t invert;
-};
+#include <linux/netfilter/xt_connmark.h>
+#define ipt_connmark_info xt_connmark_info
=20
 #endif /*_IPT_CONNMARK_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_conntrack.h b/include/linux/n=
etfilter_ipv4/ipt_conntrack.h
index 413c565..cde6762 100644
--- a/include/linux/netfilter_ipv4/ipt_conntrack.h
+++ b/include/linux/netfilter_ipv4/ipt_conntrack.h
@@ -5,56 +5,24 @@
 #ifndef _IPT_CONNTRACK_H
 #define _IPT_CONNTRACK_H
=20
-#define IPT_CONNTRACK_STATE_BIT(ctinfo) (1 << ((ctinfo)%IP_CT_IS_REPLY+1))
-#define IPT_CONNTRACK_STATE_INVALID (1 << 0)
+#include <linux/netfilter/xt_conntrack.h>
=20
-#define IPT_CONNTRACK_STATE_SNAT (1 << (IP_CT_NUMBER + 1))
-#define IPT_CONNTRACK_STATE_DNAT (1 << (IP_CT_NUMBER + 2))
-#define IPT_CONNTRACK_STATE_UNTRACKED (1 << (IP_CT_NUMBER + 3))
+#define IPT_CONNTRACK_STATE_BIT(ctinfo) XT_CONNTRACK_STATE_BIT(ctinfo)
+#define IPT_CONNTRACK_STATE_INVALID 	XT_CONNTRACK_STATE_INVALID
=20
-/* flags, invflags: */
-#define IPT_CONNTRACK_STATE	0x01
-#define IPT_CONNTRACK_PROTO	0x02
-#define IPT_CONNTRACK_ORIGSRC	0x04
-#define IPT_CONNTRACK_ORIGDST	0x08
-#define IPT_CONNTRACK_REPLSRC	0x10
-#define IPT_CONNTRACK_REPLDST	0x20
-#define IPT_CONNTRACK_STATUS	0x40
-#define IPT_CONNTRACK_EXPIRES	0x80
-
-/* This is exposed to userspace, so remains frozen in time. */
-struct ip_conntrack_old_tuple
-{
-	struct {
-		__u32 ip;
-		union {
-			__u16 all;
-		} u;
-	} src;
-
-	struct {
-		__u32 ip;
-		union {
-			__u16 all;
-		} u;
-
-		/* The protocol. */
-		u16 protonum;
-	} dst;
-};
+#define IPT_CONNTRACK_STATE_SNAT 	XT_CONNTRACK_STATE_SNAT
+#define IPT_CONNTRACK_STATE_DNAT	XT_CONNTRACK_STATE_DNAT
+#define IPT_CONNTRACK_STATE_UNTRACKED	XT_CONNTRACK_STATE_UNTRACKED
=20
-struct ipt_conntrack_info
-{
-	unsigned int statemask, statusmask;
-
-	struct ip_conntrack_old_tuple tuple[IP_CT_DIR_MAX];
-	struct in_addr sipmsk[IP_CT_DIR_MAX], dipmsk[IP_CT_DIR_MAX];
-
-	unsigned long expires_min, expires_max;
+/* flags, invflags: */
+#define IPT_CONNTRACK_STATE		XT_CONNTRACK_STATE
+#define IPT_CONNTRACK_PROTO		XT_CONNTRACK_PROTO
+#define IPT_CONNTRACK_ORIGSRC		XT_CONNTRACK_ORIGSRC
+#define IPT_CONNTRACK_ORIGDST		XT_CONNTRACK_ORIGDST
+#define IPT_CONNTRACK_REPLSRC		XT_CONNTRACK_REPLSRC
+#define IPT_CONNTRACK_REPLDST		XT_CONNTRACK_REPLDST
+#define IPT_CONNTRACK_STATUS		XT_CONNTRACK_STATUS
+#define IPT_CONNTRACK_EXPIRES		XT_CONNTRACK_EXPIRES
=20
-	/* Flags word */
-	u_int8_t flags;
-	/* Inverse flags */
-	u_int8_t invflags;
-};
+#define ipt_conntrack_info		xt_conntrack_info
 #endif /*_IPT_CONNTRACK_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_dccp.h b/include/linux/netfil=
ter_ipv4/ipt_dccp.h
index 3cb3a52..e70d11e 100644
--- a/include/linux/netfilter_ipv4/ipt_dccp.h
+++ b/include/linux/netfilter_ipv4/ipt_dccp.h
@@ -1,23 +1,15 @@
 #ifndef _IPT_DCCP_H_
 #define _IPT_DCCP_H_
=20
-#define IPT_DCCP_SRC_PORTS	        0x01
-#define IPT_DCCP_DEST_PORTS	        0x02
-#define IPT_DCCP_TYPE			0x04
-#define IPT_DCCP_OPTION			0x08
+#include <linux/netfilter/xt_dccp.h>
+#define IPT_DCCP_SRC_PORTS	XT_DCCP_SRC_PORTS
+#define IPT_DCCP_DEST_PORTS	XT_DCCP_DEST_PORTS
+#define IPT_DCCP_TYPE		XT_DCCP_TYPE
+#define IPT_DCCP_OPTION		XT_DCCP_OPTION
=20
-#define IPT_DCCP_VALID_FLAGS		0x0f
+#define IPT_DCCP_VALID_FLAGS 	XT_DCCP_VALID_FLAGS
=20
-struct ipt_dccp_info {
-	u_int16_t dpts[2];  /* Min, Max */
-	u_int16_t spts[2];  /* Min, Max */
-
-	u_int16_t flags;
-	u_int16_t invflags;
-
-	u_int16_t typemask;
-	u_int8_t option;
-};
+#define ipt_dccp_info xt_dccp_info
=20
 #endif /* _IPT_DCCP_H_ */
=20
diff --git a/include/linux/netfilter_ipv4/ipt_helper.h b/include/linux/netf=
ilter_ipv4/ipt_helper.h
index 6f12ecb..80452c2 100644
--- a/include/linux/netfilter_ipv4/ipt_helper.h
+++ b/include/linux/netfilter_ipv4/ipt_helper.h
@@ -1,8 +1,7 @@
 #ifndef _IPT_HELPER_H
 #define _IPT_HELPER_H
=20
-struct ipt_helper_info {
-	int invert;
-	char name[30];
-};
+#include <linux/netfilter/xt_helper.h>
+#define ipt_helper_info xt_helper_info
+
 #endif /* _IPT_HELPER_H */
diff --git a/include/linux/netfilter_ipv4/ipt_length.h b/include/linux/netf=
ilter_ipv4/ipt_length.h
index 6e08852..9b45206 100644
--- a/include/linux/netfilter_ipv4/ipt_length.h
+++ b/include/linux/netfilter_ipv4/ipt_length.h
@@ -1,9 +1,7 @@
 #ifndef _IPT_LENGTH_H
 #define _IPT_LENGTH_H
=20
-struct ipt_length_info {
-    u_int16_t	min, max;
-    u_int8_t	invert;
-};
+#include <linux/netfilter/xt_length.h>
+#define ipt_length_info xt_length_info
=20
 #endif /*_IPT_LENGTH_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_limit.h b/include/linux/netfi=
lter_ipv4/ipt_limit.h
index 2564534..92f5cd0 100644
--- a/include/linux/netfilter_ipv4/ipt_limit.h
+++ b/include/linux/netfilter_ipv4/ipt_limit.h
@@ -1,21 +1,8 @@
 #ifndef _IPT_RATE_H
 #define _IPT_RATE_H
=20
-/* timings are in milliseconds. */
-#define IPT_LIMIT_SCALE 10000
+#include <linux/netfilter/xt_limit.h>
+#define IPT_LIMIT_SCALE XT_LIMIT_SCALE
+#define ipt_rateinfo xt_rateinfo
=20
-/* 1/10,000 sec period =3D> max of 10,000/sec.  Min rate is then 429490
-   seconds, or one every 59 hours. */
-struct ipt_rateinfo {
-	u_int32_t avg;    /* Average secs between packets * scale */
-	u_int32_t burst;  /* Period multiplier for upper limit. */
-
-	/* Used internally by the kernel */
-	unsigned long prev;
-	u_int32_t credit;
-	u_int32_t credit_cap, cost;
-
-	/* Ugly, ugly fucker. */
-	struct ipt_rateinfo *master;
-};
 #endif /*_IPT_RATE_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_mac.h b/include/linux/netfilt=
er_ipv4/ipt_mac.h
index f8d5b8e..b186008 100644
--- a/include/linux/netfilter_ipv4/ipt_mac.h
+++ b/include/linux/netfilter_ipv4/ipt_mac.h
@@ -1,8 +1,7 @@
 #ifndef _IPT_MAC_H
 #define _IPT_MAC_H
=20
-struct ipt_mac_info {
-    unsigned char srcaddr[ETH_ALEN];
-    int invert;
-};
+#include <linux/netfilter/xt_mac.h>
+#define ipt_mac_info xt_mac_info
+
 #endif /*_IPT_MAC_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_mark.h b/include/linux/netfil=
ter_ipv4/ipt_mark.h
index f3952b5..bfde67c 100644
--- a/include/linux/netfilter_ipv4/ipt_mark.h
+++ b/include/linux/netfilter_ipv4/ipt_mark.h
@@ -1,9 +1,9 @@
 #ifndef _IPT_MARK_H
 #define _IPT_MARK_H
=20
-struct ipt_mark_info {
-    unsigned long mark, mask;
-    u_int8_t invert;
-};
+/* Backwards compatibility for old userspace */
+#include <linux/netfilter/xt_mark.h>
+
+#define ipt_mark_info xt_mark_info
=20
 #endif /*_IPT_MARK_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_physdev.h b/include/linux/net=
filter_ipv4/ipt_physdev.h
index 7538c86..2400e71 100644
--- a/include/linux/netfilter_ipv4/ipt_physdev.h
+++ b/include/linux/netfilter_ipv4/ipt_physdev.h
@@ -1,24 +1,17 @@
 #ifndef _IPT_PHYSDEV_H
 #define _IPT_PHYSDEV_H
=20
-#ifdef __KERNEL__
-#include <linux/if.h>
-#endif
+/* Backwards compatibility for old userspace */
=20
-#define IPT_PHYSDEV_OP_IN		0x01
-#define IPT_PHYSDEV_OP_OUT		0x02
-#define IPT_PHYSDEV_OP_BRIDGED		0x04
-#define IPT_PHYSDEV_OP_ISIN		0x08
-#define IPT_PHYSDEV_OP_ISOUT		0x10
-#define IPT_PHYSDEV_OP_MASK		(0x20 - 1)
+#include <linux/netfilter/xt_physdev.h>
=20
-struct ipt_physdev_info {
-	char physindev[IFNAMSIZ];
-	char in_mask[IFNAMSIZ];
-	char physoutdev[IFNAMSIZ];
-	char out_mask[IFNAMSIZ];
-	u_int8_t invert;
-	u_int8_t bitmask;
-};
+#define IPT_PHYSDEV_OP_IN		XT_PHYSDEV_OP_IN
+#define IPT_PHYSDEV_OP_OUT		XT_PHYSDEV_OP_OUT
+#define IPT_PHYSDEV_OP_BRIDGED		XT_PHYSDEV_OP_BRIDGED
+#define IPT_PHYSDEV_OP_ISIN		XT_PHYSDEV_OP_ISIN
+#define IPT_PHYSDEV_OP_ISOUT		XT_PHYSDEV_OP_ISOUT
+#define IPT_PHYSDEV_OP_MASK		XT_PHYSDEV_OP_MASK
+
+#define ipt_physdev_info xt_physdev_info
=20
 #endif /*_IPT_PHYSDEV_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_pkttype.h b/include/linux/net=
filter_ipv4/ipt_pkttype.h
index d53a658..ff1fbc9 100644
--- a/include/linux/netfilter_ipv4/ipt_pkttype.h
+++ b/include/linux/netfilter_ipv4/ipt_pkttype.h
@@ -1,8 +1,7 @@
 #ifndef _IPT_PKTTYPE_H
 #define _IPT_PKTTYPE_H
=20
-struct ipt_pkttype_info {
-	int	pkttype;
-	int	invert;
-};
+#include <linux/netfilter/xt_pkttype.h>
+#define ipt_pkttype_info xt_pkttype_info
+
 #endif /*_IPT_PKTTYPE_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_realm.h b/include/linux/netfi=
lter_ipv4/ipt_realm.h
index a4d6698..b3996ea 100644
--- a/include/linux/netfilter_ipv4/ipt_realm.h
+++ b/include/linux/netfilter_ipv4/ipt_realm.h
@@ -1,10 +1,7 @@
 #ifndef _IPT_REALM_H
 #define _IPT_REALM_H
=20
-struct ipt_realm_info {
-	u_int32_t id;
-	u_int32_t mask;
-	u_int8_t invert;
-};
+#include <linux/netfilter/xt_realm.h>
+#define ipt_realm_info xt_realm_info
=20
 #endif /* _IPT_REALM_H */
diff --git a/include/linux/netfilter_ipv4/ipt_state.h b/include/linux/netfi=
lter_ipv4/ipt_state.h
index 5df3786..a44a99c 100644
--- a/include/linux/netfilter_ipv4/ipt_state.h
+++ b/include/linux/netfilter_ipv4/ipt_state.h
@@ -1,13 +1,15 @@
 #ifndef _IPT_STATE_H
 #define _IPT_STATE_H
=20
-#define IPT_STATE_BIT(ctinfo) (1 << ((ctinfo)%IP_CT_IS_REPLY+1))
-#define IPT_STATE_INVALID (1 << 0)
+/* Backwards compatibility for old userspace */
=20
-#define IPT_STATE_UNTRACKED (1 << (IP_CT_NUMBER + 1))
+#include <linux/netfilter/xt_state.h>
+
+#define IPT_STATE_BIT		XT_STATE_BIT
+#define IPT_STATE_INVALID	XT_STATE_INVALID
+
+#define IPT_STATE_UNTRACKED	XT_STATE_UNTRACKED
+
+#define ipt_state_info		xt_state_info
=20
-struct ipt_state_info
-{
-	unsigned int statemask;
-};
 #endif /*_IPT_STATE_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_string.h b/include/linux/netf=
ilter_ipv4/ipt_string.h
index a265f6e..c26de30 100644
--- a/include/linux/netfilter_ipv4/ipt_string.h
+++ b/include/linux/netfilter_ipv4/ipt_string.h
@@ -1,18 +1,10 @@
 #ifndef _IPT_STRING_H
 #define _IPT_STRING_H
=20
-#define IPT_STRING_MAX_PATTERN_SIZE 128
-#define IPT_STRING_MAX_ALGO_NAME_SIZE 16
+#include <linux/netfilter/xt_string.h>
=20
-struct ipt_string_info
-{
-	u_int16_t from_offset;
-	u_int16_t to_offset;
-	char	  algo[IPT_STRING_MAX_ALGO_NAME_SIZE];
-	char 	  pattern[IPT_STRING_MAX_PATTERN_SIZE];
-	u_int8_t  patlen;
-	u_int8_t  invert;
-	struct ts_config __attribute__((aligned(8))) *config;
-};
+#define IPT_STRING_MAX_PATTERN_SIZE XT_STRING_MAX_PATTERN_SIZE
+#define IPT_STRING_MAX_ALGO_NAME_SIZE XT_STRING_MAX_ALGO_NAME_SIZE
+#define ipt_string_info xt_string_info
=20
 #endif /*_IPT_STRING_H*/
diff --git a/include/linux/netfilter_ipv4/ipt_tcpmss.h b/include/linux/netf=
ilter_ipv4/ipt_tcpmss.h
index e2b1439..18bbc8e 100644
--- a/include/linux/netfilter_ipv4/ipt_tcpmss.h
+++ b/include/linux/netfilter_ipv4/ipt_tcpmss.h
@@ -1,9 +1,7 @@
 #ifndef _IPT_TCPMSS_MATCH_H
 #define _IPT_TCPMSS_MATCH_H
=20
-struct ipt_tcpmss_match_info {
-    u_int16_t mss_min, mss_max;
-    u_int8_t invert;
-};
+#include <linux/netfilter/xt_tcpmss.h>
+#define ipt_tcpmss_match_info xt_tcpmss_match_info
=20
 #endif /*_IPT_TCPMSS_MATCH_H*/
diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netf=
ilter_ipv6/ip6_tables.h
index c163ba3..f249b57 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -25,8 +25,15 @@
 #include <linux/compiler.h>
 #include <linux/netfilter_ipv6.h>
=20
-#define IP6T_FUNCTION_MAXNAMELEN 30
-#define IP6T_TABLE_MAXNAMELEN 32
+#include <linux/netfilter/x_tables.h>
+
+#define IP6T_FUNCTION_MAXNAMELEN XT_FUNCTION_MAXNAMELEN
+#define IP6T_TABLE_MAXNAMELEN XT_TABLE_MAXNAMELEN
+
+#define ip6t_match xt_match
+#define ip6t_target xt_target
+#define ip6t_table xt_table
+#define ip6t_get_revision xt_get_revision
=20
 /* Yes, Virginia, you have to zero the padding. */
 struct ip6t_ip6 {
@@ -104,10 +111,7 @@ struct ip6t_standard_target
 	int verdict;
 };
=20
-struct ip6t_counters
-{
-	u_int64_t pcnt, bcnt;			/* Packet and byte counters */
-};
+#define ip6t_counters	xt_counters
=20
 /* Values for "flag" field in struct ip6t_ip6 (general ip6 structure). */
 #define IP6T_F_PROTO		0x01	/* Set if rule cares about upper=20
@@ -123,7 +127,7 @@ struct ip6t_counters
 #define IP6T_INV_SRCIP		0x08	/* Invert the sense of SRC IP. */
 #define IP6T_INV_DSTIP		0x10	/* Invert the sense of DST OP. */
 #define IP6T_INV_FRAG		0x20	/* Invert the sense of FRAG. */
-#define IP6T_INV_PROTO		0x40	/* Invert the sense of PROTO. */
+#define IP6T_INV_PROTO		XT_INV_PROTO
 #define IP6T_INV_MASK		0x7F	/* All possible flag bits mask. */
=20
 /* This structure defines each of the firewall rules.  Consists of 3
@@ -145,7 +149,7 @@ struct ip6t_entry
 	unsigned int comefrom;
=20
 	/* Packet and byte counters. */
-	struct ip6t_counters counters;
+	struct xt_counters counters;
=20
 	/* The matches (if any), then the target. */
 	unsigned char elems[0];
@@ -155,54 +159,41 @@ struct ip6t_entry
  * New IP firewall options for [gs]etsockopt at the RAW IP level.
  * Unlike BSD Linux inherits IP options so you don't have to use
  * a raw socket for this. Instead we check rights in the calls. */
-#define IP6T_BASE_CTL			64	/* base for firewall socket options */
+#define IP6T_BASE_CTL			XT_BASE_CTL
=20
-#define IP6T_SO_SET_REPLACE		(IP6T_BASE_CTL)
-#define IP6T_SO_SET_ADD_COUNTERS	(IP6T_BASE_CTL + 1)
-#define IP6T_SO_SET_MAX			IP6T_SO_SET_ADD_COUNTERS
-
-#define IP6T_SO_GET_INFO		(IP6T_BASE_CTL)
-#define IP6T_SO_GET_ENTRIES		(IP6T_BASE_CTL + 1)
-#define	IP6T_SO_GET_REVISION_MATCH	(IP6T_BASE_CTL + 2)
-#define	IP6T_SO_GET_REVISION_TARGET	(IP6T_BASE_CTL + 3)
-#define IP6T_SO_GET_MAX			IP6T_SO_GET_REVISION_TARGET
+#define IP6T_SO_SET_REPLACE		XT_SO_SET_REPLACE
+#define IP6T_SO_SET_ADD_COUNTERS	XT_SO_SET_ADD_COUNTERS
+#define IP6T_SO_SET_MAX			XT_SO_SET_MAX
+
+#define IP6T_SO_GET_INFO		XT_SO_GET_INFO
+#define IP6T_SO_GET_ENTRIES		XT_SO_GET_ENTRIES
+#define	IP6T_SO_GET_REVISION_MATCH	XT_SO_GET_REVISION_MATCH
+#define	IP6T_SO_GET_REVISION_TARGET	XT_SO_GET_REVISION_TARGET
+#define IP6T_SO_GET_MAX			XT_SO_GET_REVISION_TARGET
=20
 /* CONTINUE verdict for targets */
-#define IP6T_CONTINUE 0xFFFFFFFF
+#define IP6T_CONTINUE XT_CONTINUE
=20
 /* For standard target */
-#define IP6T_RETURN (-NF_REPEAT - 1)
+#define IP6T_RETURN XT_RETURN
=20
-/* TCP matching stuff */
-struct ip6t_tcp
-{
-	u_int16_t spts[2];			/* Source port range. */
-	u_int16_t dpts[2];			/* Destination port range. */
-	u_int8_t option;			/* TCP Option iff non-zero*/
-	u_int8_t flg_mask;			/* TCP flags mask byte */
-	u_int8_t flg_cmp;			/* TCP flags compare byte */
-	u_int8_t invflags;			/* Inverse flags */
-};
+/* TCP/UDP matching stuff */
+#include <linux/netfilter/xt_tcpudp.h>
=20
-/* Values for "inv" field in struct ipt_tcp. */
-#define IP6T_TCP_INV_SRCPT	0x01	/* Invert the sense of source ports. */
-#define IP6T_TCP_INV_DSTPT	0x02	/* Invert the sense of dest ports. */
-#define IP6T_TCP_INV_FLAGS	0x04	/* Invert the sense of TCP flags. */
-#define IP6T_TCP_INV_OPTION	0x08	/* Invert the sense of option test. */
-#define IP6T_TCP_INV_MASK	0x0F	/* All possible flags. */
+#define ip6t_tcp xt_tcp
+#define ip6t_udp xt_udp
=20
-/* UDP matching stuff */
-struct ip6t_udp
-{
-	u_int16_t spts[2];			/* Source port range. */
-	u_int16_t dpts[2];			/* Destination port range. */
-	u_int8_t invflags;			/* Inverse flags */
-};
+/* Values for "inv" field in struct ipt_tcp. */
+#define IP6T_TCP_INV_SRCPT	XT_TCP_INV_SRCPT
+#define IP6T_TCP_INV_DSTPT	XT_TCP_INV_DSTPT
+#define IP6T_TCP_INV_FLAGS	XT_TCP_INV_FLAGS
+#define IP6T_TCP_INV_OPTION	XT_TCP_INV_OPTION
+#define IP6T_TCP_INV_MASK	XT_TCP_INV_MASK
=20
 /* Values for "invflags" field in struct ipt_udp. */
-#define IP6T_UDP_INV_SRCPT	0x01	/* Invert the sense of source ports. */
-#define IP6T_UDP_INV_DSTPT	0x02	/* Invert the sense of dest ports. */
-#define IP6T_UDP_INV_MASK	0x03	/* All possible flags. */
+#define IP6T_UDP_INV_SRCPT	XT_UDP_INV_SRCPT
+#define IP6T_UDP_INV_DSTPT	XT_UDP_INV_DSTPT
+#define IP6T_UDP_INV_MASK	XT_UDP_INV_MASK
=20
 /* ICMP matching stuff */
 struct ip6t_icmp
@@ -264,23 +255,14 @@ struct ip6t_replace
 	/* Number of counters (must be equal to current number of entries). */
 	unsigned int num_counters;
 	/* The old entries' counters. */
-	struct ip6t_counters __user *counters;
+	struct xt_counters __user *counters;
=20
 	/* The entries (hang off end: not really an array). */
 	struct ip6t_entry entries[0];
 };
=20
 /* The argument to IP6T_SO_ADD_COUNTERS. */
-struct ip6t_counters_info
-{
-	/* Which table. */
-	char name[IP6T_TABLE_MAXNAMELEN];
-
-	unsigned int num_counters;
-
-	/* The counters (actually `number' of these). */
-	struct ip6t_counters counters[0];
-};
+#define ip6t_counters_info xt_counters_info
=20
 /* The argument to IP6T_SO_GET_ENTRIES. */
 struct ip6t_get_entries
@@ -295,19 +277,10 @@ struct ip6t_get_entries
 	struct ip6t_entry entrytable[0];
 };
=20
-/* The argument to IP6T_SO_GET_REVISION_*.  Returns highest revision
- * kernel supports, if >=3D revision. */
-struct ip6t_get_revision
-{
-	char name[IP6T_FUNCTION_MAXNAMELEN-1];
-
-	u_int8_t revision;
-};
-
 /* Standard return verdict, or do jump. */
-#define IP6T_STANDARD_TARGET ""
+#define IP6T_STANDARD_TARGET XT_STANDARD_TARGET
 /* Error verdict. */
-#define IP6T_ERROR_TARGET "ERROR"
+#define IP6T_ERROR_TARGET XT_ERROR_TARGET
=20
 /* Helper functions */
 static __inline__ struct ip6t_entry_target *
@@ -361,104 +334,11 @@ ip6t_get_target(struct ip6t_entry *e)
 #include <linux/init.h>
 extern void ip6t_init(void) __init;
=20
-struct ip6t_match
-{
-	struct list_head list;
-
-	const char name[IP6T_FUNCTION_MAXNAMELEN-1];
+#define ip6t_register_target(tgt) xt_register_target(AF_INET6, tgt)
+#define ip6t_unregister_target(tgt) xt_unregister_target(AF_INET6, tgt)
=20
-	u_int8_t revision;
-
-	/* Return true or false: return FALSE and set *hotdrop =3D 1 to
-           force immediate packet drop. */
-	/* Arguments changed since 2.6.9, as this must now handle
-	   non-linear skb, using skb_header_pointer and
-	   skb_ip_make_writable. */
-	int (*match)(const struct sk_buff *skb,
-		     const struct net_device *in,
-		     const struct net_device *out,
-		     const void *matchinfo,
-		     int offset,
-		     unsigned int protoff,
-		     int *hotdrop);
-
-	/* Called when user tries to insert an entry of this type. */
-	/* Should return true or false. */
-	int (*checkentry)(const char *tablename,
-			  const struct ip6t_ip6 *ip,
-			  void *matchinfo,
-			  unsigned int matchinfosize,
-			  unsigned int hook_mask);
-
-	/* Called when entry of this type deleted. */
-	void (*destroy)(void *matchinfo, unsigned int matchinfosize);
-
-	/* Set this to THIS_MODULE if you are a module, otherwise NULL */
-	struct module *me;
-};
-
-/* Registration hooks for targets. */
-struct ip6t_target
-{
-	struct list_head list;
-
-	const char name[IP6T_FUNCTION_MAXNAMELEN-1];
-
-	u_int8_t revision;
-
-	/* Returns verdict. Argument order changed since 2.6.9, as this
-	   must now handle non-linear skbs, using skb_copy_bits and
-	   skb_ip_make_writable. */
-	unsigned int (*target)(struct sk_buff **pskb,
-			       const struct net_device *in,
-			       const struct net_device *out,
-			       unsigned int hooknum,
-			       const void *targinfo,
-			       void *userdata);
-
-	/* Called when user tries to insert an entry of this type:
-           hook_mask is a bitmask of hooks from which it can be
-           called. */
-	/* Should return true or false. */
-	int (*checkentry)(const char *tablename,
-			  const struct ip6t_entry *e,
-			  void *targinfo,
-			  unsigned int targinfosize,
-			  unsigned int hook_mask);
-
-	/* Called when entry of this type deleted. */
-	void (*destroy)(void *targinfo, unsigned int targinfosize);
-
-	/* Set this to THIS_MODULE if you are a module, otherwise NULL */
-	struct module *me;
-};
-
-extern int ip6t_register_target(struct ip6t_target *target);
-extern void ip6t_unregister_target(struct ip6t_target *target);
-
-extern int ip6t_register_match(struct ip6t_match *match);
-extern void ip6t_unregister_match(struct ip6t_match *match);
-
-/* Furniture shopping... */
-struct ip6t_table
-{
-	struct list_head list;
-
-	/* A unique name... */
-	char name[IP6T_TABLE_MAXNAMELEN];
-
-	/* What hooks you will enter on */
-	unsigned int valid_hooks;
-
-	/* Lock for the curtain */
-	rwlock_t lock;
-
-	/* Man behind the curtain... */
-	struct ip6t_table_info *private;
-
-	/* Set this to THIS_MODULE if you are a module, otherwise NULL */
-	struct module *me;
-};
+#define ip6t_register_match(match) xt_register_match(AF_INET6, match)
+#define ip6t_unregister_match(match) xt_unregister_match(AF_INET6, match)
=20
 extern int ip6t_register_table(struct ip6t_table *table,
 			       const struct ip6t_replace *repl);
diff --git a/include/linux/netfilter_ipv6/ip6t_MARK.h b/include/linux/netfi=
lter_ipv6/ip6t_MARK.h
index 7ade8d8..7cf629a 100644
--- a/include/linux/netfilter_ipv6/ip6t_MARK.h
+++ b/include/linux/netfilter_ipv6/ip6t_MARK.h
@@ -1,8 +1,9 @@
 #ifndef _IP6T_MARK_H_target
 #define _IP6T_MARK_H_target
=20
-struct ip6t_mark_target_info {
-	unsigned long mark;
-};
+/* Backwards compatibility for old userspace */
+#include <linux/netfilter/xt_MARK.h>
=20
-#endif /*_IPT_MARK_H_target*/
+#define ip6t_mark_target_info xt_mark_target_info
+
+#endif /*_IP6T_MARK_H_target*/
diff --git a/include/linux/netfilter_ipv6/ip6t_length.h b/include/linux/net=
filter_ipv6/ip6t_length.h
index 7fc09f9..9e9689d 100644
--- a/include/linux/netfilter_ipv6/ip6t_length.h
+++ b/include/linux/netfilter_ipv6/ip6t_length.h
@@ -1,10 +1,8 @@
 #ifndef _IP6T_LENGTH_H
 #define _IP6T_LENGTH_H
=20
-struct ip6t_length_info {
-	u_int16_t  min, max;
-	u_int8_t   invert;
-};
+#include <linux/netfilter/xt_length.h>
+#define ip6t_length_info xt_length_info
=20
 #endif /*_IP6T_LENGTH_H*/
 =09
diff --git a/include/linux/netfilter_ipv6/ip6t_limit.h b/include/linux/netf=
ilter_ipv6/ip6t_limit.h
index f2866e5..487e5ea 100644
--- a/include/linux/netfilter_ipv6/ip6t_limit.h
+++ b/include/linux/netfilter_ipv6/ip6t_limit.h
@@ -1,21 +1,8 @@
 #ifndef _IP6T_RATE_H
 #define _IP6T_RATE_H
=20
-/* timings are in milliseconds. */
-#define IP6T_LIMIT_SCALE 10000
+#include <linux/netfilter/xt_limit.h>
+#define IP6T_LIMIT_SCALE XT_LIMIT_SCALE
+#define ip6t_rateinfo xt_rateinfo
=20
-/* 1/10,000 sec period =3D> max of 10,000/sec.  Min rate is then 429490
-   seconds, or one every 59 hours. */
-struct ip6t_rateinfo {
-	u_int32_t avg;    /* Average secs between packets * scale */
-	u_int32_t burst;  /* Period multiplier for upper limit. */
-
-	/* Used internally by the kernel */
-	unsigned long prev;
-	u_int32_t credit;
-	u_int32_t credit_cap, cost;
-
-	/* Ugly, ugly fucker. */
-	struct ip6t_rateinfo *master;
-};
-#endif /*_IPT_RATE_H*/
+#endif /*_IP6T_RATE_H*/
diff --git a/include/linux/netfilter_ipv6/ip6t_mac.h b/include/linux/netfil=
ter_ipv6/ip6t_mac.h
index 87c088c..ac58e83 100644
--- a/include/linux/netfilter_ipv6/ip6t_mac.h
+++ b/include/linux/netfilter_ipv6/ip6t_mac.h
@@ -1,8 +1,7 @@
 #ifndef _IP6T_MAC_H
 #define _IP6T_MAC_H
=20
-struct ip6t_mac_info {
-    unsigned char srcaddr[ETH_ALEN];
-    int invert;
-};
-#endif /*_IPT_MAC_H*/
+#include <linux/netfilter/xt_mac.h>
+#define ip6t_mac_info xt_mac_info
+
+#endif /*_IP6T_MAC_H*/
diff --git a/include/linux/netfilter_ipv6/ip6t_mark.h b/include/linux/netfi=
lter_ipv6/ip6t_mark.h
index a734441..ff20495 100644
--- a/include/linux/netfilter_ipv6/ip6t_mark.h
+++ b/include/linux/netfilter_ipv6/ip6t_mark.h
@@ -1,9 +1,9 @@
 #ifndef _IP6T_MARK_H
 #define _IP6T_MARK_H
=20
-struct ip6t_mark_info {
-    unsigned long mark, mask;
-    u_int8_t invert;
-};
+/* Backwards compatibility for old userspace */
+#include <linux/netfilter/xt_mark.h>
+
+#define ip6t_mark_info xt_mark_info
=20
 #endif /*_IPT_MARK_H*/
diff --git a/include/linux/netfilter_ipv6/ip6t_physdev.h b/include/linux/ne=
tfilter_ipv6/ip6t_physdev.h
index c234731..c161c0a 100644
--- a/include/linux/netfilter_ipv6/ip6t_physdev.h
+++ b/include/linux/netfilter_ipv6/ip6t_physdev.h
@@ -1,24 +1,17 @@
 #ifndef _IP6T_PHYSDEV_H
 #define _IP6T_PHYSDEV_H
=20
-#ifdef __KERNEL__
-#include <linux/if.h>
-#endif
+/* Backwards compatibility for old userspace */
=20
-#define IP6T_PHYSDEV_OP_IN		0x01
-#define IP6T_PHYSDEV_OP_OUT		0x02
-#define IP6T_PHYSDEV_OP_BRIDGED		0x04
-#define IP6T_PHYSDEV_OP_ISIN		0x08
-#define IP6T_PHYSDEV_OP_ISOUT		0x10
-#define IP6T_PHYSDEV_OP_MASK		(0x20 - 1)
+#include <linux/netfilter/xt_physdev.h>
=20
-struct ip6t_physdev_info {
-	char physindev[IFNAMSIZ];
-	char in_mask[IFNAMSIZ];
-	char physoutdev[IFNAMSIZ];
-	char out_mask[IFNAMSIZ];
-	u_int8_t invert;
-	u_int8_t bitmask;
-};
+#define IP6T_PHYSDEV_OP_IN		XT_PHYSDEV_OP_IN
+#define IP6T_PHYSDEV_OP_OUT		XT_PHYSDEV_OP_OUT
+#define IP6T_PHYSDEV_OP_BRIDGED		XT_PHYSDEV_OP_BRIDGED
+#define IP6T_PHYSDEV_OP_ISIN		XT_PHYSDEV_OP_ISIN
+#define IP6T_PHYSDEV_OP_ISOUT		XT_PHYSDEV_OP_ISOUT
+#define IP6T_PHYSDEV_OP_MASK		XT_PHYSDEV_OP_MASK
+
+#define ip6t_physdev_info xt_physdev_info
=20
 #endif /*_IP6T_PHYSDEV_H*/
diff --git a/include/net/netfilter/ipv4/nf_conntrack_ipv4.h b/include/net/n=
etfilter/ipv4/nf_conntrack_ipv4.h
index 25b081a..9168443 100644
--- a/include/net/netfilter/ipv4/nf_conntrack_ipv4.h
+++ b/include/net/netfilter/ipv4/nf_conntrack_ipv4.h
@@ -37,7 +37,4 @@ struct nf_conntrack_ipv4 {
 struct sk_buff *
 nf_ct_ipv4_ct_gather_frags(struct sk_buff *skb);
=20
-/* call to create an explicit dependency on nf_conntrack_l3proto_ipv4. */
-extern void need_ip_conntrack(void);
-
 #endif /*_NF_CONNTRACK_IPV4_H*/
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/n=
f_conntrack.h
index 64b82b7..6d075ca 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -221,9 +221,6 @@ extern void nf_ct_helper_put(struct nf_c
 extern struct nf_conntrack_helper *
 __nf_conntrack_helper_find_byname(const char *name);
=20
-/* call to create an explicit dependency on nf_conntrack. */
-extern void need_nf_conntrack(void);
-
 extern int nf_ct_invert_tuplepr(struct nf_conntrack_tuple *inverse,
 				const struct nf_conntrack_tuple *orig);
=20
diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index 9f6e019..a29c123 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -15,6 +15,7 @@
 #include <linux/netfilter.h>
 #include <linux/module.h>
 #include <linux/ip.h>
+#include <linux/in.h>
 #include <linux/if_arp.h>
 #include <linux/spinlock.h>
=20
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index a9893ec..db78303 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -182,6 +182,7 @@ config IP_NF_QUEUE
=20
 config IP_NF_IPTABLES
 	tristate "IP tables support (required for filtering/masq/NAT)"
+	depends on NETFILTER_XTABLES
 	help
 	  iptables is a general, extensible packet identification framework.
 	  The packet filtering and full NAT (masquerading, port forwarding,
@@ -191,16 +192,6 @@ config IP_NF_IPTABLES
 	  To compile it as a module, choose M here.  If unsure, say N.
=20
 # The matches.
-config IP_NF_MATCH_LIMIT
-	tristate "limit match support"
-	depends on IP_NF_IPTABLES
-	help
-	  limit matching allows you to control the rate at which a rule can be
-	  matched: mainly useful in combination with the LOG target ("LOG
-	  target support", below) and to avoid some Denial of Service attacks.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 config IP_NF_MATCH_IPRANGE
 	tristate "IP range match support"
 	depends on IP_NF_IPTABLES
@@ -210,37 +201,6 @@ config IP_NF_MATCH_IPRANGE
=20
 	  To compile it as a module, choose M here.  If unsure, say N.
=20
-config IP_NF_MATCH_MAC
-	tristate "MAC address match support"
-	depends on IP_NF_IPTABLES
-	help
-	  MAC matching allows you to match packets based on the source
-	  Ethernet address of the packet.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
-config IP_NF_MATCH_PKTTYPE
-	tristate "Packet type match support"
-	depends on IP_NF_IPTABLES
-	help
-	  Packet type matching allows you to match a packet by
-	  its "class", eg. BROADCAST, MULTICAST, ...
-
-	  Typical usage:
-	  iptables -A INPUT -m pkttype --pkt-type broadcast -j LOG
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
-config IP_NF_MATCH_MARK
-	tristate "netfilter MARK match support"
-	depends on IP_NF_IPTABLES
-	help
-	  Netfilter mark matching allows you to match packets based on the
-	  `nfmark' value in the packet.  This can be set by the MARK target
-	  (see below).
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 config IP_NF_MATCH_MULTIPORT
 	tristate "Multiple port match support"
 	depends on IP_NF_IPTABLES
@@ -301,15 +261,6 @@ config IP_NF_MATCH_AH_ESP
=20
 	  To compile it as a module, choose M here.  If unsure, say N.
=20
-config IP_NF_MATCH_LENGTH
-	tristate "LENGTH match support"
-	depends on IP_NF_IPTABLES
-	help
-	  This option allows you to match the length of a packet against a
-	  specific value or range of values.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 config IP_NF_MATCH_TTL
 	tristate "TTL match support"
 	depends on IP_NF_IPTABLES
@@ -319,50 +270,6 @@ config IP_NF_MATCH_TTL
=20
 	  To compile it as a module, choose M here.  If unsure, say N.
=20
-config IP_NF_MATCH_TCPMSS
-	tristate "tcpmss match support"
-	depends on IP_NF_IPTABLES
-	help
-	  This option adds a `tcpmss' match, which allows you to examine the
-	  MSS value of TCP SYN packets, which control the maximum packet size
-	  for that connection.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
-config IP_NF_MATCH_HELPER
-	tristate "Helper match support"
-	depends on IP_NF_IPTABLES
-	depends on IP_NF_CONNTRACK || NF_CONNTRACK_IPV4
-	help
-	  Helper matching allows you to match packets in dynamic connections
-	  tracked by a conntrack-helper, ie. ip_conntrack_ftp
-
-	  To compile it as a module, choose M here.  If unsure, say Y.
-
-config IP_NF_MATCH_STATE
-	tristate "Connection state match support"
-	depends on IP_NF_IPTABLES
-	depends on IP_NF_CONNTRACK || NF_CONNTRACK_IPV4
-	help
-	  Connection state matching allows you to match packets based on their
-	  relationship to a tracked connection (ie. previous packets).  This
-	  is a powerful tool for packet classification.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
-config IP_NF_MATCH_CONNTRACK
-	tristate "Connection tracking match support"
-	depends on IP_NF_IPTABLES
-	depends on IP_NF_CONNTRACK || NF_CONNTRACK_IPV4
-	help
-	  This is a general conntrack match module, a superset of the state match.
-
-	  It allows matching on additional conntrack information, which is
-	  useful in complex configurations, such as NAT gateways with multiple
-	  internet links or tunnels.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 config IP_NF_MATCH_OWNER
 	tristate "Owner match support"
 	depends on IP_NF_IPTABLES
@@ -372,15 +279,6 @@ config IP_NF_MATCH_OWNER
=20
 	  To compile it as a module, choose M here.  If unsure, say N.
=20
-config IP_NF_MATCH_PHYSDEV
-	tristate "Physdev match support"
-	depends on IP_NF_IPTABLES && BRIDGE_NETFILTER
-	help
-	  Physdev packet matching matches against the physical bridge ports
-	  the IP packet arrived on or will leave by.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 config IP_NF_MATCH_ADDRTYPE
 	tristate  'address type match support'
 	depends on IP_NF_IPTABLES
@@ -391,75 +289,6 @@ config IP_NF_MATCH_ADDRTYPE
 	  If you want to compile it as a module, say M here and read
 	  <file:Documentation/modules.txt>.  If unsure, say `N'.
=20
-config IP_NF_MATCH_REALM
-	tristate  'realm match support'
-	depends on IP_NF_IPTABLES
-	select NET_CLS_ROUTE
-	help
-	  This option adds a `realm' match, which allows you to use the realm
-	  key from the routing subsystem inside iptables.
-=09
-	  This match pretty much resembles the CONFIG_NET_CLS_ROUTE4 option=20
-	  in tc world.
-=09
-	  If you want to compile it as a module, say M here and read
-	  <file:Documentation/modules.txt>.  If unsure, say `N'.
-
-config IP_NF_MATCH_SCTP
-	tristate  'SCTP protocol match support'
-	depends on IP_NF_IPTABLES
-	help
-	  With this option enabled, you will be able to use the iptables
-	  `sctp' match in order to match on SCTP source/destination ports
-	  and SCTP chunk types.
-
-	  If you want to compile it as a module, say M here and read
-	  <file:Documentation/modules.txt>.  If unsure, say `N'.
-
-config IP_NF_MATCH_DCCP
-	tristate  'DCCP protocol match support'
-	depends on IP_NF_IPTABLES
-	help
-	  With this option enabled, you will be able to use the iptables
-	  `dccp' match in order to match on DCCP source/destination ports
-	  and DCCP flags.
-
-	  If you want to compile it as a module, say M here and read
-	  <file:Documentation/modules.txt>.  If unsure, say `N'.
-
-config IP_NF_MATCH_COMMENT
-	tristate  'comment match support'
-	depends on IP_NF_IPTABLES
-	help
-	  This option adds a `comment' dummy-match, which allows you to put
-	  comments in your iptables ruleset.
-
-	  If you want to compile it as a module, say M here and read
-	  <file:Documentation/modules.txt>.  If unsure, say `N'.
-
-config IP_NF_MATCH_CONNMARK
-	tristate  'Connection mark match support'
-	depends on IP_NF_IPTABLES
-	depends on (IP_NF_CONNTRACK && IP_NF_CONNTRACK_MARK) || (NF_CONNTRACK_MAR=
K && NF_CONNTRACK_IPV4)
-	help
-	  This option adds a `connmark' match, which allows you to match the
-	  connection mark value previously set for the session by `CONNMARK'.=20
-=09
-	  If you want to compile it as a module, say M here and read
-	  <file:Documentation/modules.txt>.  The module will be called
-	  ipt_connmark.o.  If unsure, say `N'.
-
-config IP_NF_MATCH_CONNBYTES
-	tristate  'Connection byte/packet counter match support'
-	depends on IP_NF_IPTABLES
-	depends on (IP_NF_CONNTRACK && IP_NF_CT_ACCT) || (NF_CT_ACCT && NF_CONNTR=
ACK_IPV4)
-	help
-	  This option adds a `connbytes' match, which allows you to match the
-	  number of bytes and/or packets for each direction within a connection.
-
-	  If you want to compile it as a module, say M here and read
-	  <file:Documentation/modules.txt>.  If unsure, say `N'.
-
 config IP_NF_MATCH_HASHLIMIT
 	tristate  'hashlimit match support'
 	depends on IP_NF_IPTABLES
@@ -474,19 +303,6 @@ config IP_NF_MATCH_HASHLIMIT
 	  destination IP' or `500pps from any given source IP'  with a single
 	  IPtables rule.
=20
-config IP_NF_MATCH_STRING
-	tristate  'string match support'
-	depends on IP_NF_IPTABLES=20
-	select TEXTSEARCH
-	select TEXTSEARCH_KMP
-	select TEXTSEARCH_BM
-	select TEXTSEARCH_FSM
-	help
-	  This option adds a `string' match, which allows you to look for
-	  pattern matchings in packets.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 config IP_NF_MATCH_POLICY
        tristate "IPsec policy match support"
        depends on IP_NF_IPTABLES && XFRM
@@ -572,17 +388,6 @@ config IP_NF_TARGET_TCPMSS
=20
 	  To compile it as a module, choose M here.  If unsure, say N.
=20
-config IP_NF_TARGET_NFQUEUE
-	tristate "NFQUEUE Target Support"
-	depends on IP_NF_IPTABLES
-	help
-	  This Target replaced the old obsolete QUEUE target.
-
-	  As opposed to QUEUE, it supports 65535 different queues,
-	  not just one.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 # NAT + specific targets
 config IP_NF_NAT
 	tristate "Full NAT"
@@ -735,31 +540,6 @@ config IP_NF_TARGET_DSCP
=20
 	  To compile it as a module, choose M here.  If unsure, say N.
=20
-config IP_NF_TARGET_MARK
-	tristate "MARK target support"
-	depends on IP_NF_MANGLE
-	help
-	  This option adds a `MARK' target, which allows you to create rules
-	  in the `mangle' table which alter the netfilter mark (nfmark) field
-	  associated with the packet prior to routing. This can change
-	  the routing method (see `Use netfilter MARK value as routing
-	  key') and can also be used by other subsystems to change their
-	  behavior.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
-config IP_NF_TARGET_CLASSIFY
-	tristate "CLASSIFY target support"
-	depends on IP_NF_MANGLE
-	help
-	  This option adds a `CLASSIFY' target, which enables the user to set
-	  the priority of a packet. Some qdiscs can use this value for
-	  classification, among these are:
-
-  	  atm, cbq, dsmark, pfifo_fast, htb, prio
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 config IP_NF_TARGET_TTL
 	tristate  'TTL target support'
 	depends on IP_NF_MANGLE
@@ -774,19 +554,6 @@ config IP_NF_TARGET_TTL
=20
 	  To compile it as a module, choose M here.  If unsure, say N.
=20
-config IP_NF_TARGET_CONNMARK
-	tristate  'CONNMARK target support'
-	depends on IP_NF_MANGLE
-	depends on (IP_NF_CONNTRACK && IP_NF_CONNTRACK_MARK) || (NF_CONNTRACK_MAR=
K && NF_CONNTRACK_IPV4)
-	help
-	  This option adds a `CONNMARK' target, which allows one to manipulate
-	  the connection mark value.  Similar to the MARK target, but
-	  affects the connection mark value rather than the packet mark value.
-=09
-	  If you want to compile it as a module, say M here and read
-	  <file:Documentation/modules.txt>.  The module will be called
-	  ipt_CONNMARK.o.  If unsure, say `N'.
-
 config IP_NF_TARGET_CLUSTERIP
 	tristate "CLUSTERIP target support (EXPERIMENTAL)"
 	depends on IP_NF_MANGLE && EXPERIMENTAL
@@ -810,23 +577,10 @@ config IP_NF_RAW
 	  If you want to compile it as a module, say M here and read
 	  <file:Documentation/modules.txt>.  If unsure, say `N'.
=20
-config IP_NF_TARGET_NOTRACK
-	tristate  'NOTRACK target support'
-	depends on IP_NF_RAW
-	depends on IP_NF_CONNTRACK || NF_CONNTRACK_IPV4
-	help
-	  The NOTRACK target allows a select rule to specify
-	  which packets *not* to enter the conntrack/NAT
-	  subsystem with all the consequences (no ICMP error tracking,
-	  no protocol helpers for the selected packets).
-=09
-	  If you want to compile it as a module, say M here and read
-	  <file:Documentation/modules.txt>.  If unsure, say `N'.
-
-
 # ARP tables
 config IP_NF_ARPTABLES
 	tristate "ARP tables support"
+	depends on NETFILTER_XTABLES
 	help
 	  arptables is a general, extensible packet identification framework.
 	  The ARP packet filtering and mangling (manipulation)subsystems
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 549b01a..bcefe64 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -47,14 +47,8 @@ obj-$(CONFIG_IP_NF_RAW) +=3D iptable_raw.o
=20
 # matches
 obj-$(CONFIG_IP_NF_MATCH_HELPER) +=3D ipt_helper.o
-obj-$(CONFIG_IP_NF_MATCH_LIMIT) +=3D ipt_limit.o
 obj-$(CONFIG_IP_NF_MATCH_HASHLIMIT) +=3D ipt_hashlimit.o
-obj-$(CONFIG_IP_NF_MATCH_SCTP) +=3D ipt_sctp.o
-obj-$(CONFIG_IP_NF_MATCH_DCCP) +=3D ipt_dccp.o
-obj-$(CONFIG_IP_NF_MATCH_MARK) +=3D ipt_mark.o
-obj-$(CONFIG_IP_NF_MATCH_MAC) +=3D ipt_mac.o
 obj-$(CONFIG_IP_NF_MATCH_IPRANGE) +=3D ipt_iprange.o
-obj-$(CONFIG_IP_NF_MATCH_PKTTYPE) +=3D ipt_pkttype.o
 obj-$(CONFIG_IP_NF_MATCH_MULTIPORT) +=3D ipt_multiport.o
 obj-$(CONFIG_IP_NF_MATCH_OWNER) +=3D ipt_owner.o
 obj-$(CONFIG_IP_NF_MATCH_TOS) +=3D ipt_tos.o
@@ -62,40 +56,25 @@ obj-$(CONFIG_IP_NF_MATCH_RECENT) +=3D ipt_
 obj-$(CONFIG_IP_NF_MATCH_ECN) +=3D ipt_ecn.o
 obj-$(CONFIG_IP_NF_MATCH_DSCP) +=3D ipt_dscp.o
 obj-$(CONFIG_IP_NF_MATCH_AH_ESP) +=3D ipt_ah.o ipt_esp.o
-obj-$(CONFIG_IP_NF_MATCH_LENGTH) +=3D ipt_length.o
 obj-$(CONFIG_IP_NF_MATCH_TTL) +=3D ipt_ttl.o
-obj-$(CONFIG_IP_NF_MATCH_STATE) +=3D ipt_state.o
-obj-$(CONFIG_IP_NF_MATCH_CONNMARK) +=3D ipt_connmark.o
-obj-$(CONFIG_IP_NF_MATCH_CONNTRACK) +=3D ipt_conntrack.o
-obj-$(CONFIG_IP_NF_MATCH_CONNBYTES) +=3D ipt_connbytes.o
-obj-$(CONFIG_IP_NF_MATCH_TCPMSS) +=3D ipt_tcpmss.o
-obj-$(CONFIG_IP_NF_MATCH_REALM) +=3D ipt_realm.o
 obj-$(CONFIG_IP_NF_MATCH_ADDRTYPE) +=3D ipt_addrtype.o
-obj-$(CONFIG_IP_NF_MATCH_PHYSDEV) +=3D ipt_physdev.o
 obj-$(CONFIG_IP_NF_MATCH_POLICY) +=3D ipt_policy.o
-obj-$(CONFIG_IP_NF_MATCH_COMMENT) +=3D ipt_comment.o
-obj-$(CONFIG_IP_NF_MATCH_STRING) +=3D ipt_string.o
=20
 # targets
 obj-$(CONFIG_IP_NF_TARGET_REJECT) +=3D ipt_REJECT.o
 obj-$(CONFIG_IP_NF_TARGET_TOS) +=3D ipt_TOS.o
 obj-$(CONFIG_IP_NF_TARGET_ECN) +=3D ipt_ECN.o
 obj-$(CONFIG_IP_NF_TARGET_DSCP) +=3D ipt_DSCP.o
-obj-$(CONFIG_IP_NF_TARGET_MARK) +=3D ipt_MARK.o
 obj-$(CONFIG_IP_NF_TARGET_MASQUERADE) +=3D ipt_MASQUERADE.o
 obj-$(CONFIG_IP_NF_TARGET_REDIRECT) +=3D ipt_REDIRECT.o
 obj-$(CONFIG_IP_NF_TARGET_NETMAP) +=3D ipt_NETMAP.o
 obj-$(CONFIG_IP_NF_TARGET_SAME) +=3D ipt_SAME.o
-obj-$(CONFIG_IP_NF_TARGET_CLASSIFY) +=3D ipt_CLASSIFY.o
 obj-$(CONFIG_IP_NF_NAT_SNMP_BASIC) +=3D ip_nat_snmp_basic.o
 obj-$(CONFIG_IP_NF_TARGET_LOG) +=3D ipt_LOG.o
-obj-$(CONFIG_IP_NF_TARGET_CONNMARK) +=3D ipt_CONNMARK.o
 obj-$(CONFIG_IP_NF_TARGET_ULOG) +=3D ipt_ULOG.o
 obj-$(CONFIG_IP_NF_TARGET_TCPMSS) +=3D ipt_TCPMSS.o
-obj-$(CONFIG_IP_NF_TARGET_NOTRACK) +=3D ipt_NOTRACK.o
 obj-$(CONFIG_IP_NF_TARGET_CLUSTERIP) +=3D ipt_CLUSTERIP.o
 obj-$(CONFIG_IP_NF_TARGET_TTL) +=3D ipt_TTL.o
-obj-$(CONFIG_IP_NF_TARGET_NFQUEUE) +=3D ipt_NFQUEUE.o
=20
 # generic ARP tables
 obj-$(CONFIG_IP_NF_ARPTABLES) +=3D arp_tables.o
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_table=
s.c
index b6d5284..afe3d8f 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -24,6 +24,7 @@
 #include <asm/uaccess.h>
 #include <asm/semaphore.h>
=20
+#include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_arp/arp_tables.h>
=20
 MODULE_LICENSE("GPL");
@@ -55,28 +56,9 @@ do {								\
 #else
 #define ARP_NF_ASSERT(x)
 #endif
-#define SMP_ALIGN(x) (((x) + SMP_CACHE_BYTES-1) & ~(SMP_CACHE_BYTES-1))
=20
-static DECLARE_MUTEX(arpt_mutex);
-
-#define ASSERT_READ_LOCK(x) ARP_NF_ASSERT(down_trylock(&arpt_mutex) !=3D 0)
-#define ASSERT_WRITE_LOCK(x) ARP_NF_ASSERT(down_trylock(&arpt_mutex) !=3D =
0)
 #include <linux/netfilter_ipv4/listhelp.h>
=20
-struct arpt_table_info {
-	unsigned int size;
-	unsigned int number;
-	unsigned int initial_entries;
-	unsigned int hook_entry[NF_ARP_NUMHOOKS];
-	unsigned int underflow[NF_ARP_NUMHOOKS];
-	void *entries[NR_CPUS];
-};
-
-static LIST_HEAD(arpt_target);
-static LIST_HEAD(arpt_tables);
-#define SET_COUNTER(c,b,p) do { (c).bcnt =3D (b); (c).pcnt =3D (p); } whil=
e(0)
-#define ADD_COUNTER(c,b,p) do { (c).bcnt +=3D (b); (c).pcnt +=3D (p); } wh=
ile(0)
-
 static inline int arp_devaddr_compare(const struct arpt_devaddr_info *ap,
 				      char *hdr_addr, int len)
 {
@@ -223,9 +205,9 @@ static inline int arp_checkentry(const s
 }
=20
 static unsigned int arpt_error(struct sk_buff **pskb,
-			       unsigned int hooknum,
 			       const struct net_device *in,
 			       const struct net_device *out,
+			       unsigned int hooknum,
 			       const void *targinfo,
 			       void *userinfo)
 {
@@ -254,6 +236,7 @@ unsigned int arpt_do_table(struct sk_buf
 	struct arpt_entry *e, *back;
 	const char *indev, *outdev;
 	void *table_base;
+	struct xt_table_info *private =3D table->private;
=20
 	/* ARP header, plus 2 device addresses, plus 2 IP addresses.  */
 	if (!pskb_may_pull((*pskb), (sizeof(struct arphdr) +
@@ -265,9 +248,9 @@ unsigned int arpt_do_table(struct sk_buf
 	outdev =3D out ? out->name : nulldevname;
=20
 	read_lock_bh(&table->lock);
-	table_base =3D (void *)table->private->entries[smp_processor_id()];
-	e =3D get_entry(table_base, table->private->hook_entry[hook]);
-	back =3D get_entry(table_base, table->private->underflow[hook]);
+	table_base =3D (void *)private->entries[smp_processor_id()];
+	e =3D get_entry(table_base, private->hook_entry[hook]);
+	back =3D get_entry(table_base, private->underflow[hook]);
=20
 	arp =3D (*pskb)->nh.arph;
 	do {
@@ -315,8 +298,8 @@ unsigned int arpt_do_table(struct sk_buf
 				 * abs. verdicts
 				 */
 				verdict =3D t->u.kernel.target->target(pskb,
-								     hook,
 								     in, out,
+								     hook,
 								     t->data,
 								     userdata);
=20
@@ -341,106 +324,6 @@ unsigned int arpt_do_table(struct sk_buf
 		return verdict;
 }
=20
-/*
- * These are weird, but module loading must not be done with mutex
- * held (since they will register), and we have to have a single
- * function to use try_then_request_module().
- */
-
-/* Find table by name, grabs mutex & ref.  Returns ERR_PTR() on error. */
-static inline struct arpt_table *find_table_lock(const char *name)
-{
-	struct arpt_table *t;
-
-	if (down_interruptible(&arpt_mutex) !=3D 0)
-		return ERR_PTR(-EINTR);
-
-	list_for_each_entry(t, &arpt_tables, list)
-		if (strcmp(t->name, name) =3D=3D 0 && try_module_get(t->me))
-			return t;
-	up(&arpt_mutex);
-	return NULL;
-}
-
-
-/* Find target, grabs ref.  Returns ERR_PTR() on error. */
-static inline struct arpt_target *find_target(const char *name, u8 revisio=
n)
-{
-	struct arpt_target *t;
-	int err =3D 0;
-
-	if (down_interruptible(&arpt_mutex) !=3D 0)
-		return ERR_PTR(-EINTR);
-
-	list_for_each_entry(t, &arpt_target, list) {
-		if (strcmp(t->name, name) =3D=3D 0) {
-			if (t->revision =3D=3D revision) {
-				if (try_module_get(t->me)) {
-					up(&arpt_mutex);
-					return t;
-				}
-			} else
-				err =3D -EPROTOTYPE; /* Found something. */
-		}
-	}
-	up(&arpt_mutex);
-	return ERR_PTR(err);
-}
-
-struct arpt_target *arpt_find_target(const char *name, u8 revision)
-{
-	struct arpt_target *target;
-
-	target =3D try_then_request_module(find_target(name, revision),
-					 "arpt_%s", name);
-	if (IS_ERR(target) || !target)
-		return NULL;
-	return target;
-}
-
-static int target_revfn(const char *name, u8 revision, int *bestp)
-{
-	struct arpt_target *t;
-	int have_rev =3D 0;
-
-	list_for_each_entry(t, &arpt_target, list) {
-		if (strcmp(t->name, name) =3D=3D 0) {
-			if (t->revision > *bestp)
-				*bestp =3D t->revision;
-			if (t->revision =3D=3D revision)
-				have_rev =3D1;
-		}
-	}
-	return have_rev;
-}
-
-/* Returns true or false (if no such extension at all) */
-static inline int find_revision(const char *name, u8 revision,
-				int (*revfn)(const char *, u8, int *),
-				int *err)
-{
-	int have_rev, best =3D -1;
-
-	if (down_interruptible(&arpt_mutex) !=3D 0) {
-		*err =3D -EINTR;
-		return 1;
-	}
-	have_rev =3D revfn(name, revision, &best);
-	up(&arpt_mutex);
-
-	/* Nothing at all?  Return 0 to try loading module. */
-	if (best =3D=3D -1) {
-		*err =3D -ENOENT;
-		return 0;
-	}
-
-	*err =3D best;
-	if (!have_rev)
-		*err =3D -EPROTONOSUPPORT;
-	return 1;
-}
-
-
 /* All zeroes =3D=3D unconditional rule. */
 static inline int unconditional(const struct arpt_arp *arp)
 {
@@ -456,7 +339,7 @@ static inline int unconditional(const st
 /* Figures out from what hook each rule can be called: returns 0 if
  * there are loops.  Puts hook bitmask in comefrom.
  */
-static int mark_source_chains(struct arpt_table_info *newinfo,
+static int mark_source_chains(struct xt_table_info *newinfo,
 			      unsigned int valid_hooks, void *entry0)
 {
 	unsigned int hook;
@@ -587,8 +470,8 @@ static inline int check_entry(struct arp
 	}
=20
 	t =3D arpt_get_target(e);
-	target =3D try_then_request_module(find_target(t->u.user.name,
-						     t->u.user.revision),
+	target =3D try_then_request_module(xt_find_target(NF_ARP, t->u.user.name,
+							t->u.user.revision),
 					 "arpt_%s", t->u.user.name);
 	if (IS_ERR(target) || !target) {
 		duprintf("check_entry: `%s' not found\n", t->u.user.name);
@@ -622,7 +505,7 @@ out:
 }
=20
 static inline int check_entry_size_and_hooks(struct arpt_entry *e,
-					     struct arpt_table_info *newinfo,
+					     struct xt_table_info *newinfo,
 					     unsigned char *base,
 					     unsigned char *limit,
 					     const unsigned int *hook_entries,
@@ -656,7 +539,7 @@ static inline int check_entry_size_and_h
            < 0 (not ARPT_RETURN). --RR */
=20
 	/* Clear counters and comefrom */
-	e->counters =3D ((struct arpt_counters) { 0, 0 });
+	e->counters =3D ((struct xt_counters) { 0, 0 });
 	e->comefrom =3D 0;
=20
 	(*i)++;
@@ -683,7 +566,7 @@ static inline int cleanup_entry(struct a
  */
 static int translate_table(const char *name,
 			   unsigned int valid_hooks,
-			   struct arpt_table_info *newinfo,
+			   struct xt_table_info *newinfo,
 			   void *entry0,
 			   unsigned int size,
 			   unsigned int number,
@@ -764,34 +647,9 @@ static int translate_table(const char *n
 	return ret;
 }
=20
-static struct arpt_table_info *replace_table(struct arpt_table *table,
-					     unsigned int num_counters,
-					     struct arpt_table_info *newinfo,
-					     int *error)
-{
-	struct arpt_table_info *oldinfo;
-
-	/* Do the substitution. */
-	write_lock_bh(&table->lock);
-	/* Check inside lock: is the old number correct? */
-	if (num_counters !=3D table->private->number) {
-		duprintf("num_counters !=3D table->private->number (%u/%u)\n",
-			 num_counters, table->private->number);
-		write_unlock_bh(&table->lock);
-		*error =3D -EAGAIN;
-		return NULL;
-	}
-	oldinfo =3D table->private;
-	table->private =3D newinfo;
-	newinfo->initial_entries =3D oldinfo->initial_entries;
-	write_unlock_bh(&table->lock);
-
-	return oldinfo;
-}
-
 /* Gets counters. */
 static inline int add_entry_to_counter(const struct arpt_entry *e,
-				       struct arpt_counters total[],
+				       struct xt_counters total[],
 				       unsigned int *i)
 {
 	ADD_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
@@ -801,7 +659,7 @@ static inline int add_entry_to_counter(c
 }
=20
 static inline int set_entry_to_counter(const struct arpt_entry *e,
-				       struct arpt_counters total[],
+				       struct xt_counters total[],
 				       unsigned int *i)
 {
 	SET_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
@@ -810,8 +668,8 @@ static inline int set_entry_to_counter(c
 	return 0;
 }
=20
-static void get_counters(const struct arpt_table_info *t,
-			 struct arpt_counters counters[])
+static void get_counters(const struct xt_table_info *t,
+			 struct xt_counters counters[])
 {
 	unsigned int cpu;
 	unsigned int i;
@@ -849,7 +707,8 @@ static int copy_entries_to_user(unsigned
 {
 	unsigned int off, num, countersize;
 	struct arpt_entry *e;
-	struct arpt_counters *counters;
+	struct xt_counters *counters;
+	struct xt_table_info *private =3D table->private;
 	int ret =3D 0;
 	void *loc_cpu_entry;
=20
@@ -857,18 +716,18 @@ static int copy_entries_to_user(unsigned
 	 * (other than comefrom, which userspace doesn't care
 	 * about).
 	 */
-	countersize =3D sizeof(struct arpt_counters) * table->private->number;
-	counters =3D vmalloc(countersize);
+	countersize =3D sizeof(struct xt_counters) * private->number;
+	counters =3D vmalloc_node(countersize, numa_node_id());
=20
 	if (counters =3D=3D NULL)
 		return -ENOMEM;
=20
 	/* First, sum counters... */
 	write_lock_bh(&table->lock);
-	get_counters(table->private, counters);
+	get_counters(private, counters);
 	write_unlock_bh(&table->lock);
=20
-	loc_cpu_entry =3D table->private->entries[raw_smp_processor_id()];
+	loc_cpu_entry =3D private->entries[raw_smp_processor_id()];
 	/* ... then copy entire thing ... */
 	if (copy_to_user(userptr, loc_cpu_entry, total_size) !=3D 0) {
 		ret =3D -EFAULT;
@@ -911,75 +770,34 @@ static int get_entries(const struct arpt
 	int ret;
 	struct arpt_table *t;
=20
-	t =3D find_table_lock(entries->name);
+	t =3D xt_find_table_lock(NF_ARP, entries->name);
 	if (t || !IS_ERR(t)) {
+		struct xt_table_info *private =3D t->private;
 		duprintf("t->private->number =3D %u\n",
-			 t->private->number);
-		if (entries->size =3D=3D t->private->size)
-			ret =3D copy_entries_to_user(t->private->size,
+			 private->number);
+		if (entries->size =3D=3D private->size)
+			ret =3D copy_entries_to_user(private->size,
 						   t, uptr->entrytable);
 		else {
 			duprintf("get_entries: I've got %u not %u!\n",
-				 t->private->size,
-				 entries->size);
+				 private->size, entries->size);
 			ret =3D -EINVAL;
 		}
 		module_put(t->me);
-		up(&arpt_mutex);
+		xt_table_unlock(t);
 	} else
 		ret =3D t ? PTR_ERR(t) : -ENOENT;
=20
 	return ret;
 }
=20
-static void free_table_info(struct arpt_table_info *info)
-{
-	int cpu;
-	for_each_cpu(cpu) {
-		if (info->size <=3D PAGE_SIZE)
-			kfree(info->entries[cpu]);
-		else
-			vfree(info->entries[cpu]);
-	}
-	kfree(info);
-}
-
-static struct arpt_table_info *alloc_table_info(unsigned int size)
-{
-	struct arpt_table_info *newinfo;
-	int cpu;
-=09
-	newinfo =3D kzalloc(sizeof(struct arpt_table_info), GFP_KERNEL);
-	if (!newinfo)
-		return NULL;
-
-	newinfo->size =3D size;
-
-	for_each_cpu(cpu) {
-		if (size <=3D PAGE_SIZE)
-			newinfo->entries[cpu] =3D kmalloc_node(size,
-							GFP_KERNEL,
-							cpu_to_node(cpu));
-		else
-			newinfo->entries[cpu] =3D vmalloc_node(size,
-							     cpu_to_node(cpu));
-
-		if (newinfo->entries[cpu] =3D=3D NULL) {
-			free_table_info(newinfo);
-			return NULL;
-		}
-	}
-
-	return newinfo;
-}
-
 static int do_replace(void __user *user, unsigned int len)
 {
 	int ret;
 	struct arpt_replace tmp;
 	struct arpt_table *t;
-	struct arpt_table_info *newinfo, *oldinfo;
-	struct arpt_counters *counters;
+	struct xt_table_info *newinfo, *oldinfo;
+	struct xt_counters *counters;
 	void *loc_cpu_entry, *loc_cpu_old_entry;
=20
 	if (copy_from_user(&tmp, user, sizeof(tmp)) !=3D 0)
@@ -989,11 +807,7 @@ static int do_replace(void __user *user,
 	if (len !=3D sizeof(tmp) + tmp.size)
 		return -ENOPROTOOPT;
=20
-	/* Pedantry: prevent them from hitting BUG() in vmalloc.c --RR */
-	if ((SMP_ALIGN(tmp.size) >> PAGE_SHIFT) + 2 > num_physpages)
-		return -ENOMEM;
-
-	newinfo =3D alloc_table_info(tmp.size);
+	newinfo =3D xt_alloc_table_info(tmp.size);
 	if (!newinfo)
 		return -ENOMEM;
=20
@@ -1005,7 +819,7 @@ static int do_replace(void __user *user,
 		goto free_newinfo;
 	}
=20
-	counters =3D vmalloc(tmp.num_counters * sizeof(struct arpt_counters));
+	counters =3D vmalloc(tmp.num_counters * sizeof(struct xt_counters));
 	if (!counters) {
 		ret =3D -ENOMEM;
 		goto free_newinfo;
@@ -1019,7 +833,7 @@ static int do_replace(void __user *user,
=20
 	duprintf("arp_tables: Translated table\n");
=20
-	t =3D try_then_request_module(find_table_lock(tmp.name),
+	t =3D try_then_request_module(xt_find_table_lock(NF_ARP, tmp.name),
 				    "arptable_%s", tmp.name);
 	if (!t || IS_ERR(t)) {
 		ret =3D t ? PTR_ERR(t) : -ENOENT;
@@ -1034,7 +848,7 @@ static int do_replace(void __user *user,
 		goto put_module;
 	}
=20
-	oldinfo =3D replace_table(t, tmp.num_counters, newinfo, &ret);
+	oldinfo =3D xt_replace_table(t, tmp.num_counters, newinfo, &ret);
 	if (!oldinfo)
 		goto put_module;
=20
@@ -1054,23 +868,23 @@ static int do_replace(void __user *user,
 	loc_cpu_old_entry =3D oldinfo->entries[raw_smp_processor_id()];
 	ARPT_ENTRY_ITERATE(loc_cpu_old_entry, oldinfo->size, cleanup_entry,NULL);
=20
-	free_table_info(oldinfo);
+	xt_free_table_info(oldinfo);
 	if (copy_to_user(tmp.counters, counters,
-			 sizeof(struct arpt_counters) * tmp.num_counters) !=3D 0)
+			 sizeof(struct xt_counters) * tmp.num_counters) !=3D 0)
 		ret =3D -EFAULT;
 	vfree(counters);
-	up(&arpt_mutex);
+	xt_table_unlock(t);
 	return ret;
=20
  put_module:
 	module_put(t->me);
-	up(&arpt_mutex);
+	xt_table_unlock(t);
  free_newinfo_counters_untrans:
 	ARPT_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry, NULL);
  free_newinfo_counters:
 	vfree(counters);
  free_newinfo:
-	free_table_info(newinfo);
+	xt_free_table_info(newinfo);
 	return ret;
 }
=20
@@ -1078,7 +892,7 @@ static int do_replace(void __user *user,
  * and everything is OK.
  */
 static inline int add_counter_to_entry(struct arpt_entry *e,
-				       const struct arpt_counters addme[],
+				       const struct xt_counters addme[],
 				       unsigned int *i)
 {
=20
@@ -1091,15 +905,16 @@ static inline int add_counter_to_entry(s
 static int do_add_counters(void __user *user, unsigned int len)
 {
 	unsigned int i;
-	struct arpt_counters_info tmp, *paddc;
+	struct xt_counters_info tmp, *paddc;
 	struct arpt_table *t;
+	struct xt_table_info *private;
 	int ret =3D 0;
 	void *loc_cpu_entry;
=20
 	if (copy_from_user(&tmp, user, sizeof(tmp)) !=3D 0)
 		return -EFAULT;
=20
-	if (len !=3D sizeof(tmp) + tmp.num_counters*sizeof(struct arpt_counters))
+	if (len !=3D sizeof(tmp) + tmp.num_counters*sizeof(struct xt_counters))
 		return -EINVAL;
=20
 	paddc =3D vmalloc(len);
@@ -1111,29 +926,30 @@ static int do_add_counters(void __user *
 		goto free;
 	}
=20
-	t =3D find_table_lock(tmp.name);
+	t =3D xt_find_table_lock(NF_ARP, tmp.name);
 	if (!t || IS_ERR(t)) {
 		ret =3D t ? PTR_ERR(t) : -ENOENT;
 		goto free;
 	}
=20
 	write_lock_bh(&t->lock);
-	if (t->private->number !=3D paddc->num_counters) {
+	private =3D t->private;
+	if (private->number !=3D paddc->num_counters) {
 		ret =3D -EINVAL;
 		goto unlock_up_free;
 	}
=20
 	i =3D 0;
 	/* Choose the copy that is on our node */
-	loc_cpu_entry =3D t->private->entries[smp_processor_id()];
+	loc_cpu_entry =3D private->entries[smp_processor_id()];
 	ARPT_ENTRY_ITERATE(loc_cpu_entry,
-			   t->private->size,
+			   private->size,
 			   add_counter_to_entry,
 			   paddc->counters,
 			   &i);
  unlock_up_free:
 	write_unlock_bh(&t->lock);
-	up(&arpt_mutex);
+	xt_table_unlock(t);
 	module_put(t->me);
  free:
 	vfree(paddc);
@@ -1190,25 +1006,26 @@ static int do_arpt_get_ctl(struct sock *
 		}
 		name[ARPT_TABLE_MAXNAMELEN-1] =3D '\0';
=20
-		t =3D try_then_request_module(find_table_lock(name),
+		t =3D try_then_request_module(xt_find_table_lock(NF_ARP, name),
 					    "arptable_%s", name);
 		if (t && !IS_ERR(t)) {
 			struct arpt_getinfo info;
+			struct xt_table_info *private =3D t->private;
=20
 			info.valid_hooks =3D t->valid_hooks;
-			memcpy(info.hook_entry, t->private->hook_entry,
+			memcpy(info.hook_entry, private->hook_entry,
 			       sizeof(info.hook_entry));
-			memcpy(info.underflow, t->private->underflow,
+			memcpy(info.underflow, private->underflow,
 			       sizeof(info.underflow));
-			info.num_entries =3D t->private->number;
-			info.size =3D t->private->size;
+			info.num_entries =3D private->number;
+			info.size =3D private->size;
 			strcpy(info.name, name);
=20
 			if (copy_to_user(user, &info, *len) !=3D 0)
 				ret =3D -EFAULT;
 			else
 				ret =3D 0;
-			up(&arpt_mutex);
+			xt_table_unlock(t);
 			module_put(t->me);
 		} else
 			ret =3D t ? PTR_ERR(t) : -ENOENT;
@@ -1233,7 +1050,7 @@ static int do_arpt_get_ctl(struct sock *
 	}
=20
 	case ARPT_SO_GET_REVISION_TARGET: {
-		struct arpt_get_revision rev;
+		struct xt_get_revision rev;
=20
 		if (*len !=3D sizeof(rev)) {
 			ret =3D -EINVAL;
@@ -1244,8 +1061,8 @@ static int do_arpt_get_ctl(struct sock *
 			break;
 		}
=20
-		try_then_request_module(find_revision(rev.name, rev.revision,
-						      target_revfn, &ret),
+		try_then_request_module(xt_find_revision(NF_ARP, rev.name,
+							 rev.revision, 1, &ret),
 					"arpt_%s", rev.name);
 		break;
 	}
@@ -1258,38 +1075,16 @@ static int do_arpt_get_ctl(struct sock *
 	return ret;
 }
=20
-/* Registration hooks for targets. */
-int arpt_register_target(struct arpt_target *target)
-{
-	int ret;
-
-	ret =3D down_interruptible(&arpt_mutex);
-	if (ret !=3D 0)
-		return ret;
-
-	list_add(&target->list, &arpt_target);
-	up(&arpt_mutex);
-
-	return ret;
-}
-
-void arpt_unregister_target(struct arpt_target *target)
-{
-	down(&arpt_mutex);
-	LIST_DELETE(&arpt_target, target);
-	up(&arpt_mutex);
-}
-
 int arpt_register_table(struct arpt_table *table,
 			const struct arpt_replace *repl)
 {
 	int ret;
-	struct arpt_table_info *newinfo;
-	static struct arpt_table_info bootstrap
+	struct xt_table_info *newinfo;
+	static struct xt_table_info bootstrap
 		=3D { 0, 0, 0, { 0 }, { 0 }, { } };
 	void *loc_cpu_entry;
=20
-	newinfo =3D alloc_table_info(repl->size);
+	newinfo =3D xt_alloc_table_info(repl->size);
 	if (!newinfo) {
 		ret =3D -ENOMEM;
 		return ret;
@@ -1304,60 +1099,33 @@ int arpt_register_table(struct arpt_tabl
 			      repl->num_entries,
 			      repl->hook_entry,
 			      repl->underflow);
+
 	duprintf("arpt_register_table: translate table gives %d\n", ret);
 	if (ret !=3D 0) {
-		free_table_info(newinfo);
+		xt_free_table_info(newinfo);
 		return ret;
 	}
=20
-	ret =3D down_interruptible(&arpt_mutex);
-	if (ret !=3D 0) {
-		free_table_info(newinfo);
+	if (xt_register_table(table, &bootstrap, newinfo) !=3D 0) {
+		xt_free_table_info(newinfo);
 		return ret;
 	}
=20
-	/* Don't autoload: we'd eat our tail... */
-	if (list_named_find(&arpt_tables, table->name)) {
-		ret =3D -EEXIST;
-		goto free_unlock;
-	}
-
-	/* Simplifies replace_table code. */
-	table->private =3D &bootstrap;
-	if (!replace_table(table, 0, newinfo, &ret))
-		goto free_unlock;
-
-	duprintf("table->private->number =3D %u\n",
-		 table->private->number);
-=09
-	/* save number of initial entries */
-	table->private->initial_entries =3D table->private->number;
-
-	rwlock_init(&table->lock);
-	list_prepend(&arpt_tables, table);
-
- unlock:
-	up(&arpt_mutex);
-	return ret;
-
- free_unlock:
-	free_table_info(newinfo);
-	goto unlock;
+	return 0;
 }
=20
 void arpt_unregister_table(struct arpt_table *table)
 {
+	struct xt_table_info *private;
 	void *loc_cpu_entry;
=20
-	down(&arpt_mutex);
-	LIST_DELETE(&arpt_tables, table);
-	up(&arpt_mutex);
+	private =3D xt_unregister_table(table);
=20
 	/* Decrease module usage counts and free resources */
-	loc_cpu_entry =3D table->private->entries[raw_smp_processor_id()];
-	ARPT_ENTRY_ITERATE(loc_cpu_entry, table->private->size,
+	loc_cpu_entry =3D private->entries[raw_smp_processor_id()];
+	ARPT_ENTRY_ITERATE(loc_cpu_entry, private->size,
 			   cleanup_entry, NULL);
-	free_table_info(table->private);
+	xt_free_table_info(private);
 }
=20
 /* The built-in targets: standard (NULL) and error. */
@@ -1380,52 +1148,15 @@ static struct nf_sockopt_ops arpt_sockop
 	.get		=3D do_arpt_get_ctl,
 };
=20
-#ifdef CONFIG_PROC_FS
-static inline int print_name(const struct arpt_table *t,
-			     off_t start_offset, char *buffer, int length,
-			     off_t *pos, unsigned int *count)
-{
-	if ((*count)++ >=3D start_offset) {
-		unsigned int namelen;
-
-		namelen =3D sprintf(buffer + *pos, "%s\n", t->name);
-		if (*pos + namelen > length) {
-			/* Stop iterating */
-			return 1;
-		}
-		*pos +=3D namelen;
-	}
-	return 0;
-}
-
-static int arpt_get_tables(char *buffer, char **start, off_t offset, int l=
ength)
-{
-	off_t pos =3D 0;
-	unsigned int count =3D 0;
-
-	if (down_interruptible(&arpt_mutex) !=3D 0)
-		return 0;
-
-	LIST_FIND(&arpt_tables, print_name, struct arpt_table *,
-		  offset, buffer, length, &pos, &count);
-
-	up(&arpt_mutex);
-
-	/* `start' hack - see fs/proc/generic.c line ~105 */
-	*start=3D(char *)((unsigned long)count-offset);
-	return pos;
-}
-#endif /*CONFIG_PROC_FS*/
-
 static int __init init(void)
 {
 	int ret;
=20
+	xt_proto_init(NF_ARP);
+
 	/* Noone else will be downing sem now, so we won't sleep */
-	down(&arpt_mutex);
-	list_append(&arpt_target, &arpt_standard_target);
-	list_append(&arpt_target, &arpt_error_target);
-	up(&arpt_mutex);
+	xt_register_target(NF_ARP, &arpt_standard_target);
+	xt_register_target(NF_ARP, &arpt_error_target);
=20
 	/* Register setsockopt */
 	ret =3D nf_register_sockopt(&arpt_sockopts);
@@ -1434,19 +1165,6 @@ static int __init init(void)
 		return ret;
 	}
=20
-#ifdef CONFIG_PROC_FS
-	{
-		struct proc_dir_entry *proc;
-
-		proc =3D proc_net_create("arp_tables_names", 0, arpt_get_tables);
-		if (!proc) {
-			nf_unregister_sockopt(&arpt_sockopts);
-			return -ENOMEM;
-		}
-		proc->owner =3D THIS_MODULE;
-	}
-#endif
-
 	printk("arp_tables: (C) 2002 David S. Miller\n");
 	return 0;
 }
@@ -1454,16 +1172,12 @@ static int __init init(void)
 static void __exit fini(void)
 {
 	nf_unregister_sockopt(&arpt_sockopts);
-#ifdef CONFIG_PROC_FS
-	proc_net_remove("arp_tables_names");
-#endif
+	xt_proto_fini(NF_ARP);
 }
=20
 EXPORT_SYMBOL(arpt_register_table);
 EXPORT_SYMBOL(arpt_unregister_table);
 EXPORT_SYMBOL(arpt_do_table);
-EXPORT_SYMBOL(arpt_register_target);
-EXPORT_SYMBOL(arpt_unregister_target);
=20
 module_init(init);
 module_exit(fini);
diff --git a/net/ipv4/netfilter/arpt_mangle.c b/net/ipv4/netfilter/arpt_man=
gle.c
index 3e592ec..c97650a 100644
--- a/net/ipv4/netfilter/arpt_mangle.c
+++ b/net/ipv4/netfilter/arpt_mangle.c
@@ -8,8 +8,9 @@ MODULE_AUTHOR("Bart De Schuymer <bdschuy
 MODULE_DESCRIPTION("arptables arp payload mangle target");
=20
 static unsigned int
-target(struct sk_buff **pskb, unsigned int hooknum, const struct net_devic=
e *in,
-   const struct net_device *out, const void *targinfo, void *userinfo)
+target(struct sk_buff **pskb, const struct net_device *in,
+   const struct net_device *out, unsigned int hooknum, const void *targinf=
o,
+   void *userinfo)
 {
 	const struct arpt_mangle *mangle =3D targinfo;
 	struct arphdr *arp;
@@ -64,7 +65,7 @@ target(struct sk_buff **pskb, unsigned i
 }
=20
 static int
-checkentry(const char *tablename, const struct arpt_entry *e, void *targin=
fo,
+checkentry(const char *tablename, const void *e, void *targinfo,
    unsigned int targinfosize, unsigned int hook_mask)
 {
 	const struct arpt_mangle *mangle =3D targinfo;
diff --git a/net/ipv4/netfilter/arptable_filter.c b/net/ipv4/netfilter/arpt=
able_filter.c
index 0d759f5..f6ab45f 100644
--- a/net/ipv4/netfilter/arptable_filter.c
+++ b/net/ipv4/netfilter/arptable_filter.c
@@ -145,6 +145,7 @@ static struct arpt_table packet_filter =3D
 	.lock		=3D RW_LOCK_UNLOCKED,
 	.private	=3D NULL,
 	.me		=3D THIS_MODULE,
+	.af		=3D NF_ARP,
 };
=20
 /* The work comes in here from netfilter.c */
diff --git a/net/ipv4/netfilter/ip_conntrack_standalone.c b/net/ipv4/netfil=
ter/ip_conntrack_standalone.c
index 9dec129..833fcb4 100644
--- a/net/ipv4/netfilter/ip_conntrack_standalone.c
+++ b/net/ipv4/netfilter/ip_conntrack_standalone.c
@@ -944,7 +944,7 @@ module_exit(fini);
=20
 /* Some modules need us, but don't depend directly on any symbol.
    They should call this. */
-void need_ip_conntrack(void)
+void need_conntrack(void)
 {
 }
=20
@@ -962,7 +962,7 @@ EXPORT_SYMBOL(ip_ct_get_tuple);
 EXPORT_SYMBOL(invert_tuplepr);
 EXPORT_SYMBOL(ip_conntrack_alter_reply);
 EXPORT_SYMBOL(ip_conntrack_destroyed);
-EXPORT_SYMBOL(need_ip_conntrack);
+EXPORT_SYMBOL(need_conntrack);
 EXPORT_SYMBOL(ip_conntrack_helper_register);
 EXPORT_SYMBOL(ip_conntrack_helper_unregister);
 EXPORT_SYMBOL(ip_ct_iterate_cleanup);
diff --git a/net/ipv4/netfilter/ip_nat_rule.c b/net/ipv4/netfilter/ip_nat_r=
ule.c
index cb66b8b..1de8628 100644
--- a/net/ipv4/netfilter/ip_nat_rule.c
+++ b/net/ipv4/netfilter/ip_nat_rule.c
@@ -95,6 +95,7 @@ static struct ipt_table nat_table =3D {
 	.valid_hooks	=3D NAT_VALID_HOOKS,
 	.lock		=3D RW_LOCK_UNLOCKED,
 	.me		=3D THIS_MODULE,
+	.af		=3D AF_INET,
 };
=20
 /* Source NAT */
@@ -168,7 +169,7 @@ static unsigned int ipt_dnat_target(stru
 }
=20
 static int ipt_snat_checkentry(const char *tablename,
-			       const struct ipt_entry *e,
+			       const void *entry,
 			       void *targinfo,
 			       unsigned int targinfosize,
 			       unsigned int hook_mask)
@@ -201,7 +202,7 @@ static int ipt_snat_checkentry(const cha
 }
=20
 static int ipt_dnat_checkentry(const char *tablename,
-			       const struct ipt_entry *e,
+			       const void *entry,
 			       void *targinfo,
 			       unsigned int targinfosize,
 			       unsigned int hook_mask)
diff --git a/net/ipv4/netfilter/ip_nat_standalone.c b/net/ipv4/netfilter/ip=
_nat_standalone.c
index 8b8a1f0..ad438fb 100644
--- a/net/ipv4/netfilter/ip_nat_standalone.c
+++ b/net/ipv4/netfilter/ip_nat_standalone.c
@@ -364,7 +364,7 @@ static int init_or_cleanup(int init)
 {
 	int ret =3D 0;
=20
-	need_ip_conntrack();
+	need_conntrack();
=20
 	if (!init) goto cleanup;
=20
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 877bc96..2371b20 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -2,7 +2,7 @@
  * Packet matching code.
  *
  * Copyright (C) 1999 Paul `Rusty' Russell & Michael J. Neuling
- * Copyright (C) 2000-2004 Netfilter Core Team <coreteam@netfilter.org>
+ * Copyright (C) 2000-2005 Netfilter Core Team <coreteam@netfilter.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -11,6 +11,8 @@
  * 19 Jan 2002 Harald Welte <laforge@gnumonks.org>
  * 	- increase module usage count as soon as we have rules inside
  * 	  a table
+ * 08 Oct 2005 Harald Welte <lafore@netfilter.org>
+ * 	- Generalize into "x_tables" layer and "{ip,ip6,arp}_tables"
  */
 #include <linux/config.h>
 #include <linux/cache.h>
@@ -20,8 +22,6 @@
 #include <linux/vmalloc.h>
 #include <linux/netdevice.h>
 #include <linux/module.h>
-#include <linux/tcp.h>
-#include <linux/udp.h>
 #include <linux/icmp.h>
 #include <net/ip.h>
 #include <asm/uaccess.h>
@@ -30,6 +30,7 @@
 #include <linux/err.h>
 #include <linux/cpumask.h>
=20
+#include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
=20
 MODULE_LICENSE("GPL");
@@ -62,14 +63,6 @@ do {								\
 #else
 #define IP_NF_ASSERT(x)
 #endif
-#define SMP_ALIGN(x) (((x) + SMP_CACHE_BYTES-1) & ~(SMP_CACHE_BYTES-1))
-
-static DECLARE_MUTEX(ipt_mutex);
-
-/* Must have mutex */
-#define ASSERT_READ_LOCK(x) IP_NF_ASSERT(down_trylock(&ipt_mutex) !=3D 0)
-#define ASSERT_WRITE_LOCK(x) IP_NF_ASSERT(down_trylock(&ipt_mutex) !=3D 0)
-#include <linux/netfilter_ipv4/listhelp.h>
=20
 #if 0
 /* All the better to debug you with... */
@@ -86,36 +79,6 @@ static DECLARE_MUTEX(ipt_mutex);
=20
    Hence the start of any table is given by get_table() below.  */
=20
-/* The table itself */
-struct ipt_table_info
-{
-	/* Size per table */
-	unsigned int size;
-	/* Number of entries: FIXME. --RR */
-	unsigned int number;
-	/* Initial number of entries. Needed for module usage count */
-	unsigned int initial_entries;
-
-	/* Entry points and underflows */
-	unsigned int hook_entry[NF_IP_NUMHOOKS];
-	unsigned int underflow[NF_IP_NUMHOOKS];
-
-	/* ipt_entry tables: one per CPU */
-	void *entries[NR_CPUS];
-};
-
-static LIST_HEAD(ipt_target);
-static LIST_HEAD(ipt_match);
-static LIST_HEAD(ipt_tables);
-#define SET_COUNTER(c,b,p) do { (c).bcnt =3D (b); (c).pcnt =3D (p); } whil=
e(0)
-#define ADD_COUNTER(c,b,p) do { (c).bcnt +=3D (b); (c).pcnt +=3D (p); } wh=
ile(0)
-
-#if 0
-#define down(x) do { printk("DOWN:%u:" #x "\n", __LINE__); down(x); } whil=
e(0)
-#define down_interruptible(x) ({ int __r; printk("DOWNi:%u:" #x "\n", __LI=
NE__); __r =3D down_interruptible(x); if (__r !=3D 0) printk("ABORT-DOWNi:%=
u\n", __LINE__); __r; })
-#define up(x) do { printk("UP:%u:" #x "\n", __LINE__); up(x); } while(0)
-#endif
-
 /* Returns whether matches rule or not. */
 static inline int
 ip_packet_match(const struct iphdr *ip,
@@ -234,7 +197,8 @@ int do_match(struct ipt_entry_match *m,
 	     int *hotdrop)
 {
 	/* Stop iteration if it doesn't match */
-	if (!m->u.kernel.match->match(skb, in, out, m->data, offset, hotdrop))
+	if (!m->u.kernel.match->match(skb, in, out, m->data, offset,=20
+	    skb->nh.iph->ihl*4, hotdrop))
 		return 1;
 	else
 		return 0;
@@ -265,6 +229,7 @@ ipt_do_table(struct sk_buff **pskb,
 	const char *indev, *outdev;
 	void *table_base;
 	struct ipt_entry *e, *back;
+	struct xt_table_info *private =3D table->private;
=20
 	/* Initialization */
 	ip =3D (*pskb)->nh.iph;
@@ -281,24 +246,11 @@ ipt_do_table(struct sk_buff **pskb,
=20
 	read_lock_bh(&table->lock);
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
-	table_base =3D (void *)table->private->entries[smp_processor_id()];
-	e =3D get_entry(table_base, table->private->hook_entry[hook]);
-
-#ifdef CONFIG_NETFILTER_DEBUG
-	/* Check noone else using our table */
-	if (((struct ipt_entry *)table_base)->comefrom !=3D 0xdead57ac
-	    && ((struct ipt_entry *)table_base)->comefrom !=3D 0xeeeeeeec) {
-		printk("ASSERT: CPU #%u, %s comefrom(%p) =3D %X\n",
-		       smp_processor_id(),
-		       table->name,
-		       &((struct ipt_entry *)table_base)->comefrom,
-		       ((struct ipt_entry *)table_base)->comefrom);
-	}
-	((struct ipt_entry *)table_base)->comefrom =3D 0x57acc001;
-#endif
+	table_base =3D (void *)private->entries[smp_processor_id()];
+	e =3D get_entry(table_base, private->hook_entry[hook]);
=20
 	/* For return from builtin chain */
-	back =3D get_entry(table_base, table->private->underflow[hook]);
+	back =3D get_entry(table_base, private->underflow[hook]);
=20
 	do {
 		IP_NF_ASSERT(e);
@@ -384,9 +336,6 @@ ipt_do_table(struct sk_buff **pskb,
 		}
 	} while (!hotdrop);
=20
-#ifdef CONFIG_NETFILTER_DEBUG
-	((struct ipt_entry *)table_base)->comefrom =3D 0xdead57ac;
-#endif
 	read_unlock_bh(&table->lock);
=20
 #ifdef DEBUG_ALLOW_ALL
@@ -398,145 +347,6 @@ ipt_do_table(struct sk_buff **pskb,
 #endif
 }
=20
-/*
- * These are weird, but module loading must not be done with mutex
- * held (since they will register), and we have to have a single
- * function to use try_then_request_module().
- */
-
-/* Find table by name, grabs mutex & ref.  Returns ERR_PTR() on error. */
-static inline struct ipt_table *find_table_lock(const char *name)
-{
-	struct ipt_table *t;
-
-	if (down_interruptible(&ipt_mutex) !=3D 0)
-		return ERR_PTR(-EINTR);
-
-	list_for_each_entry(t, &ipt_tables, list)
-		if (strcmp(t->name, name) =3D=3D 0 && try_module_get(t->me))
-			return t;
-	up(&ipt_mutex);
-	return NULL;
-}
-
-/* Find match, grabs ref.  Returns ERR_PTR() on error. */
-static inline struct ipt_match *find_match(const char *name, u8 revision)
-{
-	struct ipt_match *m;
-	int err =3D 0;
-
-	if (down_interruptible(&ipt_mutex) !=3D 0)
-		return ERR_PTR(-EINTR);
-
-	list_for_each_entry(m, &ipt_match, list) {
-		if (strcmp(m->name, name) =3D=3D 0) {
-			if (m->revision =3D=3D revision) {
-				if (try_module_get(m->me)) {
-					up(&ipt_mutex);
-					return m;
-				}
-			} else
-				err =3D -EPROTOTYPE; /* Found something. */
-		}
-	}
-	up(&ipt_mutex);
-	return ERR_PTR(err);
-}
-
-/* Find target, grabs ref.  Returns ERR_PTR() on error. */
-static inline struct ipt_target *find_target(const char *name, u8 revision)
-{
-	struct ipt_target *t;
-	int err =3D 0;
-
-	if (down_interruptible(&ipt_mutex) !=3D 0)
-		return ERR_PTR(-EINTR);
-
-	list_for_each_entry(t, &ipt_target, list) {
-		if (strcmp(t->name, name) =3D=3D 0) {
-			if (t->revision =3D=3D revision) {
-				if (try_module_get(t->me)) {
-					up(&ipt_mutex);
-					return t;
-				}
-			} else
-				err =3D -EPROTOTYPE; /* Found something. */
-		}
-	}
-	up(&ipt_mutex);
-	return ERR_PTR(err);
-}
-
-struct ipt_target *ipt_find_target(const char *name, u8 revision)
-{
-	struct ipt_target *target;
-
-	target =3D try_then_request_module(find_target(name, revision),
-					 "ipt_%s", name);
-	if (IS_ERR(target) || !target)
-		return NULL;
-	return target;
-}
-
-static int match_revfn(const char *name, u8 revision, int *bestp)
-{
-	struct ipt_match *m;
-	int have_rev =3D 0;
-
-	list_for_each_entry(m, &ipt_match, list) {
-		if (strcmp(m->name, name) =3D=3D 0) {
-			if (m->revision > *bestp)
-				*bestp =3D m->revision;
-			if (m->revision =3D=3D revision)
-				have_rev =3D 1;
-		}
-	}
-	return have_rev;
-}
-
-static int target_revfn(const char *name, u8 revision, int *bestp)
-{
-	struct ipt_target *t;
-	int have_rev =3D 0;
-
-	list_for_each_entry(t, &ipt_target, list) {
-		if (strcmp(t->name, name) =3D=3D 0) {
-			if (t->revision > *bestp)
-				*bestp =3D t->revision;
-			if (t->revision =3D=3D revision)
-				have_rev =3D 1;
-		}
-	}
-	return have_rev;
-}
-
-/* Returns true or false (if no such extension at all) */
-static inline int find_revision(const char *name, u8 revision,
-				int (*revfn)(const char *, u8, int *),
-				int *err)
-{
-	int have_rev, best =3D -1;
-
-	if (down_interruptible(&ipt_mutex) !=3D 0) {
-		*err =3D -EINTR;
-		return 1;
-	}
-	have_rev =3D revfn(name, revision, &best);
-	up(&ipt_mutex);
-
-	/* Nothing at all?  Return 0 to try loading module. */
-	if (best =3D=3D -1) {
-		*err =3D -ENOENT;
-		return 0;
-	}
-
-	*err =3D best;
-	if (!have_rev)
-		*err =3D -EPROTONOSUPPORT;
-	return 1;
-}
-
-
 /* All zeroes =3D=3D unconditional rule. */
 static inline int
 unconditional(const struct ipt_ip *ip)
@@ -553,7 +363,7 @@ unconditional(const struct ipt_ip *ip)
 /* Figures out from what hook each rule can be called: returns 0 if
    there are loops.  Puts hook bitmask in comefrom. */
 static int
-mark_source_chains(struct ipt_table_info *newinfo,
+mark_source_chains(struct xt_table_info *newinfo,
 		   unsigned int valid_hooks, void *entry0)
 {
 	unsigned int hook;
@@ -699,7 +509,7 @@ check_match(struct ipt_entry_match *m,
 {
 	struct ipt_match *match;
=20
-	match =3D try_then_request_module(find_match(m->u.user.name,
+	match =3D try_then_request_module(xt_find_match(AF_INET, m->u.user.name,
 						   m->u.user.revision),
 					"ipt_%s", m->u.user.name);
 	if (IS_ERR(match) || !match) {
@@ -744,7 +554,8 @@ check_entry(struct ipt_entry *e, const c
 		goto cleanup_matches;
=20
 	t =3D ipt_get_target(e);
-	target =3D try_then_request_module(find_target(t->u.user.name,
+	target =3D try_then_request_module(xt_find_target(AF_INET,
+						     t->u.user.name,
 						     t->u.user.revision),
 					 "ipt_%s", t->u.user.name);
 	if (IS_ERR(target) || !target) {
@@ -781,7 +592,7 @@ check_entry(struct ipt_entry *e, const c
=20
 static inline int
 check_entry_size_and_hooks(struct ipt_entry *e,
-			   struct ipt_table_info *newinfo,
+			   struct xt_table_info *newinfo,
 			   unsigned char *base,
 			   unsigned char *limit,
 			   const unsigned int *hook_entries,
@@ -815,7 +626,7 @@ check_entry_size_and_hooks(struct ipt_en
            < 0 (not IPT_RETURN). --RR */
=20
 	/* Clear counters and comefrom */
-	e->counters =3D ((struct ipt_counters) { 0, 0 });
+	e->counters =3D ((struct xt_counters) { 0, 0 });
 	e->comefrom =3D 0;
=20
 	(*i)++;
@@ -845,7 +656,7 @@ cleanup_entry(struct ipt_entry *e, unsig
 static int
 translate_table(const char *name,
 		unsigned int valid_hooks,
-		struct ipt_table_info *newinfo,
+		struct xt_table_info *newinfo,
 		void *entry0,
 		unsigned int size,
 		unsigned int number,
@@ -922,48 +733,10 @@ translate_table(const char *name,
 	return ret;
 }
=20
-static struct ipt_table_info *
-replace_table(struct ipt_table *table,
-	      unsigned int num_counters,
-	      struct ipt_table_info *newinfo,
-	      int *error)
-{
-	struct ipt_table_info *oldinfo;
-
-#ifdef CONFIG_NETFILTER_DEBUG
-	{
-		int cpu;
-
-		for_each_cpu(cpu) {
-			struct ipt_entry *table_base =3D newinfo->entries[cpu];
-			if (table_base)
-				table_base->comefrom =3D 0xdead57ac;
-		}
-	}
-#endif
-
-	/* Do the substitution. */
-	write_lock_bh(&table->lock);
-	/* Check inside lock: is the old number correct? */
-	if (num_counters !=3D table->private->number) {
-		duprintf("num_counters !=3D table->private->number (%u/%u)\n",
-			 num_counters, table->private->number);
-		write_unlock_bh(&table->lock);
-		*error =3D -EAGAIN;
-		return NULL;
-	}
-	oldinfo =3D table->private;
-	table->private =3D newinfo;
-	newinfo->initial_entries =3D oldinfo->initial_entries;
-	write_unlock_bh(&table->lock);
-
-	return oldinfo;
-}
-
 /* Gets counters. */
 static inline int
 add_entry_to_counter(const struct ipt_entry *e,
-		     struct ipt_counters total[],
+		     struct xt_counters total[],
 		     unsigned int *i)
 {
 	ADD_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
@@ -984,8 +757,8 @@ set_entry_to_counter(const struct ipt_en
 }
=20
 static void
-get_counters(const struct ipt_table_info *t,
-	     struct ipt_counters counters[])
+get_counters(const struct xt_table_info *t,
+	     struct xt_counters counters[])
 {
 	unsigned int cpu;
 	unsigned int i;
@@ -1024,14 +797,15 @@ copy_entries_to_user(unsigned int total_
 {
 	unsigned int off, num, countersize;
 	struct ipt_entry *e;
-	struct ipt_counters *counters;
+	struct xt_counters *counters;
+	struct xt_table_info *private =3D table->private;
 	int ret =3D 0;
 	void *loc_cpu_entry;
=20
 	/* We need atomic snapshot of counters: rest doesn't change
 	   (other than comefrom, which userspace doesn't care
 	   about). */
-	countersize =3D sizeof(struct ipt_counters) * table->private->number;
+	countersize =3D sizeof(struct xt_counters) * private->number;
 	counters =3D vmalloc_node(countersize, numa_node_id());
=20
 	if (counters =3D=3D NULL)
@@ -1039,14 +813,14 @@ copy_entries_to_user(unsigned int total_
=20
 	/* First, sum counters... */
 	write_lock_bh(&table->lock);
-	get_counters(table->private, counters);
+	get_counters(private, counters);
 	write_unlock_bh(&table->lock);
=20
 	/* choose the copy that is on our node/cpu, ...
 	 * This choice is lazy (because current thread is
 	 * allowed to migrate to another cpu)
 	 */
-	loc_cpu_entry =3D table->private->entries[raw_smp_processor_id()];
+	loc_cpu_entry =3D private->entries[raw_smp_processor_id()];
 	/* ... then copy entire thing ... */
 	if (copy_to_user(userptr, loc_cpu_entry, total_size) !=3D 0) {
 		ret =3D -EFAULT;
@@ -1108,74 +882,36 @@ get_entries(const struct ipt_get_entries
 	int ret;
 	struct ipt_table *t;
=20
-	t =3D find_table_lock(entries->name);
+	t =3D xt_find_table_lock(AF_INET, entries->name);
 	if (t && !IS_ERR(t)) {
+		struct xt_table_info *private =3D t->private;
 		duprintf("t->private->number =3D %u\n",
-			 t->private->number);
-		if (entries->size =3D=3D t->private->size)
-			ret =3D copy_entries_to_user(t->private->size,
+			 private->number);
+		if (entries->size =3D=3D private->size)
+			ret =3D copy_entries_to_user(private->size,
 						   t, uptr->entrytable);
 		else {
 			duprintf("get_entries: I've got %u not %u!\n",
-				 t->private->size,
+				 private->size,
 				 entries->size);
 			ret =3D -EINVAL;
 		}
 		module_put(t->me);
-		up(&ipt_mutex);
+		xt_table_unlock(t);
 	} else
 		ret =3D t ? PTR_ERR(t) : -ENOENT;
=20
 	return ret;
 }
=20
-static void free_table_info(struct ipt_table_info *info)
-{
-	int cpu;
-	for_each_cpu(cpu) {
-		if (info->size <=3D PAGE_SIZE)
-			kfree(info->entries[cpu]);
-		else
-			vfree(info->entries[cpu]);
-	}
-	kfree(info);
-}
-
-static struct ipt_table_info *alloc_table_info(unsigned int size)
-{
-	struct ipt_table_info *newinfo;
-	int cpu;
-
-	newinfo =3D kzalloc(sizeof(struct ipt_table_info), GFP_KERNEL);
-	if (!newinfo)
-		return NULL;
-
-	newinfo->size =3D size;
-
-	for_each_cpu(cpu) {
-		if (size <=3D PAGE_SIZE)
-			newinfo->entries[cpu] =3D kmalloc_node(size,
-				GFP_KERNEL,
-				cpu_to_node(cpu));
-		else
-			newinfo->entries[cpu] =3D vmalloc_node(size, cpu_to_node(cpu));
-		if (newinfo->entries[cpu] =3D=3D 0) {
-			free_table_info(newinfo);
-			return NULL;
-		}
-	}
-
-	return newinfo;
-}
-
 static int
 do_replace(void __user *user, unsigned int len)
 {
 	int ret;
 	struct ipt_replace tmp;
 	struct ipt_table *t;
-	struct ipt_table_info *newinfo, *oldinfo;
-	struct ipt_counters *counters;
+	struct xt_table_info *newinfo, *oldinfo;
+	struct xt_counters *counters;
 	void *loc_cpu_entry, *loc_cpu_old_entry;
=20
 	if (copy_from_user(&tmp, user, sizeof(tmp)) !=3D 0)
@@ -1185,11 +921,7 @@ do_replace(void __user *user, unsigned i
 	if (len !=3D sizeof(tmp) + tmp.size)
 		return -ENOPROTOOPT;
=20
-	/* Pedantry: prevent them from hitting BUG() in vmalloc.c --RR */
-	if ((SMP_ALIGN(tmp.size) >> PAGE_SHIFT) + 2 > num_physpages)
-		return -ENOMEM;
-
-	newinfo =3D alloc_table_info(tmp.size);
+	newinfo =3D xt_alloc_table_info(tmp.size);
 	if (!newinfo)
 		return -ENOMEM;
=20
@@ -1201,7 +933,7 @@ do_replace(void __user *user, unsigned i
 		goto free_newinfo;
 	}
=20
-	counters =3D vmalloc(tmp.num_counters * sizeof(struct ipt_counters));
+	counters =3D vmalloc(tmp.num_counters * sizeof(struct xt_counters));
 	if (!counters) {
 		ret =3D -ENOMEM;
 		goto free_newinfo;
@@ -1215,7 +947,7 @@ do_replace(void __user *user, unsigned i
=20
 	duprintf("ip_tables: Translated table\n");
=20
-	t =3D try_then_request_module(find_table_lock(tmp.name),
+	t =3D try_then_request_module(xt_find_table_lock(AF_INET, tmp.name),
 				    "iptable_%s", tmp.name);
 	if (!t || IS_ERR(t)) {
 		ret =3D t ? PTR_ERR(t) : -ENOENT;
@@ -1230,7 +962,7 @@ do_replace(void __user *user, unsigned i
 		goto put_module;
 	}
=20
-	oldinfo =3D replace_table(t, tmp.num_counters, newinfo, &ret);
+	oldinfo =3D xt_replace_table(t, tmp.num_counters, newinfo, &ret);
 	if (!oldinfo)
 		goto put_module;
=20
@@ -1249,23 +981,23 @@ do_replace(void __user *user, unsigned i
 	/* Decrease module usage counts and free resource */
 	loc_cpu_old_entry =3D oldinfo->entries[raw_smp_processor_id()];
 	IPT_ENTRY_ITERATE(loc_cpu_old_entry, oldinfo->size, cleanup_entry,NULL);
-	free_table_info(oldinfo);
+	xt_free_table_info(oldinfo);
 	if (copy_to_user(tmp.counters, counters,
-			 sizeof(struct ipt_counters) * tmp.num_counters) !=3D 0)
+			 sizeof(struct xt_counters) * tmp.num_counters) !=3D 0)
 		ret =3D -EFAULT;
 	vfree(counters);
-	up(&ipt_mutex);
+	xt_table_unlock(t);
 	return ret;
=20
  put_module:
 	module_put(t->me);
-	up(&ipt_mutex);
+	xt_table_unlock(t);
  free_newinfo_counters_untrans:
 	IPT_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry,NULL);
  free_newinfo_counters:
 	vfree(counters);
  free_newinfo:
-	free_table_info(newinfo);
+	xt_free_table_info(newinfo);
 	return ret;
 }
=20
@@ -1273,7 +1005,7 @@ do_replace(void __user *user, unsigned i
  * and everything is OK. */
 static inline int
 add_counter_to_entry(struct ipt_entry *e,
-		     const struct ipt_counters addme[],
+		     const struct xt_counters addme[],
 		     unsigned int *i)
 {
 #if 0
@@ -1295,15 +1027,16 @@ static int
 do_add_counters(void __user *user, unsigned int len)
 {
 	unsigned int i;
-	struct ipt_counters_info tmp, *paddc;
+	struct xt_counters_info tmp, *paddc;
 	struct ipt_table *t;
+	struct xt_table_info *private;
 	int ret =3D 0;
 	void *loc_cpu_entry;
=20
 	if (copy_from_user(&tmp, user, sizeof(tmp)) !=3D 0)
 		return -EFAULT;
=20
-	if (len !=3D sizeof(tmp) + tmp.num_counters*sizeof(struct ipt_counters))
+	if (len !=3D sizeof(tmp) + tmp.num_counters*sizeof(struct xt_counters))
 		return -EINVAL;
=20
 	paddc =3D vmalloc_node(len, numa_node_id());
@@ -1315,29 +1048,30 @@ do_add_counters(void __user *user, unsig
 		goto free;
 	}
=20
-	t =3D find_table_lock(tmp.name);
+	t =3D xt_find_table_lock(AF_INET, tmp.name);
 	if (!t || IS_ERR(t)) {
 		ret =3D t ? PTR_ERR(t) : -ENOENT;
 		goto free;
 	}
=20
 	write_lock_bh(&t->lock);
-	if (t->private->number !=3D paddc->num_counters) {
+	private =3D t->private;
+	if (private->number !=3D paddc->num_counters) {
 		ret =3D -EINVAL;
 		goto unlock_up_free;
 	}
=20
 	i =3D 0;
 	/* Choose the copy that is on our node */
-	loc_cpu_entry =3D t->private->entries[raw_smp_processor_id()];
+	loc_cpu_entry =3D private->entries[raw_smp_processor_id()];
 	IPT_ENTRY_ITERATE(loc_cpu_entry,
-			  t->private->size,
+			  private->size,
 			  add_counter_to_entry,
 			  paddc->counters,
 			  &i);
  unlock_up_free:
 	write_unlock_bh(&t->lock);
-	up(&ipt_mutex);
+	xt_table_unlock(t);
 	module_put(t->me);
  free:
 	vfree(paddc);
@@ -1396,25 +1130,26 @@ do_ipt_get_ctl(struct sock *sk, int cmd,
 		}
 		name[IPT_TABLE_MAXNAMELEN-1] =3D '\0';
=20
-		t =3D try_then_request_module(find_table_lock(name),
+		t =3D try_then_request_module(xt_find_table_lock(AF_INET, name),
 					    "iptable_%s", name);
 		if (t && !IS_ERR(t)) {
 			struct ipt_getinfo info;
+			struct xt_table_info *private =3D t->private;
=20
 			info.valid_hooks =3D t->valid_hooks;
-			memcpy(info.hook_entry, t->private->hook_entry,
+			memcpy(info.hook_entry, private->hook_entry,
 			       sizeof(info.hook_entry));
-			memcpy(info.underflow, t->private->underflow,
+			memcpy(info.underflow, private->underflow,
 			       sizeof(info.underflow));
-			info.num_entries =3D t->private->number;
-			info.size =3D t->private->size;
+			info.num_entries =3D private->number;
+			info.size =3D private->size;
 			memcpy(info.name, name, sizeof(info.name));
=20
 			if (copy_to_user(user, &info, *len) !=3D 0)
 				ret =3D -EFAULT;
 			else
 				ret =3D 0;
-			up(&ipt_mutex);
+			xt_table_unlock(t);
 			module_put(t->me);
 		} else
 			ret =3D t ? PTR_ERR(t) : -ENOENT;
@@ -1441,7 +1176,7 @@ do_ipt_get_ctl(struct sock *sk, int cmd,
 	case IPT_SO_GET_REVISION_MATCH:
 	case IPT_SO_GET_REVISION_TARGET: {
 		struct ipt_get_revision rev;
-		int (*revfn)(const char *, u8, int *);
+		int target;
=20
 		if (*len !=3D sizeof(rev)) {
 			ret =3D -EINVAL;
@@ -1453,12 +1188,13 @@ do_ipt_get_ctl(struct sock *sk, int cmd,
 		}
=20
 		if (cmd =3D=3D IPT_SO_GET_REVISION_TARGET)
-			revfn =3D target_revfn;
+			target =3D 1;
 		else
-			revfn =3D match_revfn;
+			target =3D 0;
=20
-		try_then_request_module(find_revision(rev.name, rev.revision,
-						      revfn, &ret),
+		try_then_request_module(xt_find_revision(AF_INET, rev.name,
+							 rev.revision,
+							 target, &ret),
 					"ipt_%s", rev.name);
 		break;
 	}
@@ -1471,60 +1207,15 @@ do_ipt_get_ctl(struct sock *sk, int cmd,
 	return ret;
 }
=20
-/* Registration hooks for targets. */
-int
-ipt_register_target(struct ipt_target *target)
-{
-	int ret;
-
-	ret =3D down_interruptible(&ipt_mutex);
-	if (ret !=3D 0)
-		return ret;
-	list_add(&target->list, &ipt_target);
-	up(&ipt_mutex);
-	return ret;
-}
-
-void
-ipt_unregister_target(struct ipt_target *target)
-{
-	down(&ipt_mutex);
-	LIST_DELETE(&ipt_target, target);
-	up(&ipt_mutex);
-}
-
-int
-ipt_register_match(struct ipt_match *match)
+int ipt_register_table(struct xt_table *table, const struct ipt_replace *r=
epl)
 {
 	int ret;
-
-	ret =3D down_interruptible(&ipt_mutex);
-	if (ret !=3D 0)
-		return ret;
-
-	list_add(&match->list, &ipt_match);
-	up(&ipt_mutex);
-
-	return ret;
-}
-
-void
-ipt_unregister_match(struct ipt_match *match)
-{
-	down(&ipt_mutex);
-	LIST_DELETE(&ipt_match, match);
-	up(&ipt_mutex);
-}
-
-int ipt_register_table(struct ipt_table *table, const struct ipt_replace *=
repl)
-{
-	int ret;
-	struct ipt_table_info *newinfo;
-	static struct ipt_table_info bootstrap
+	struct xt_table_info *newinfo;
+	static struct xt_table_info bootstrap
 		=3D { 0, 0, 0, { 0 }, { 0 }, { } };
 	void *loc_cpu_entry;
=20
-	newinfo =3D alloc_table_info(repl->size);
+	newinfo =3D xt_alloc_table_info(repl->size);
 	if (!newinfo)
 		return -ENOMEM;
=20
@@ -1540,246 +1231,29 @@ int ipt_register_table(struct ipt_table=20
 			      repl->hook_entry,
 			      repl->underflow);
 	if (ret !=3D 0) {
-		free_table_info(newinfo);
+		xt_free_table_info(newinfo);
 		return ret;
 	}
=20
-	ret =3D down_interruptible(&ipt_mutex);
-	if (ret !=3D 0) {
-		free_table_info(newinfo);
+	if (xt_register_table(table, &bootstrap, newinfo) !=3D 0) {
+		xt_free_table_info(newinfo);
 		return ret;
 	}
=20
-	/* Don't autoload: we'd eat our tail... */
-	if (list_named_find(&ipt_tables, table->name)) {
-		ret =3D -EEXIST;
-		goto free_unlock;
-	}
-
-	/* Simplifies replace_table code. */
-	table->private =3D &bootstrap;
-	if (!replace_table(table, 0, newinfo, &ret))
-		goto free_unlock;
-
-	duprintf("table->private->number =3D %u\n",
-		 table->private->number);
-=09
-	/* save number of initial entries */
-	table->private->initial_entries =3D table->private->number;
-
-	rwlock_init(&table->lock);
-	list_prepend(&ipt_tables, table);
-
- unlock:
-	up(&ipt_mutex);
-	return ret;
-
- free_unlock:
-	free_table_info(newinfo);
-	goto unlock;
+	return 0;
 }
=20
 void ipt_unregister_table(struct ipt_table *table)
 {
+	struct xt_table_info *private;
 	void *loc_cpu_entry;
=20
-	down(&ipt_mutex);
-	LIST_DELETE(&ipt_tables, table);
-	up(&ipt_mutex);
+ 	private =3D xt_unregister_table(table);
=20
 	/* Decrease module usage counts and free resources */
-	loc_cpu_entry =3D table->private->entries[raw_smp_processor_id()];
-	IPT_ENTRY_ITERATE(loc_cpu_entry, table->private->size,
-			  cleanup_entry, NULL);
-	free_table_info(table->private);
-}
-
-/* Returns 1 if the port is matched by the range, 0 otherwise */
-static inline int
-port_match(u_int16_t min, u_int16_t max, u_int16_t port, int invert)
-{
-	int ret;
-
-	ret =3D (port >=3D min && port <=3D max) ^ invert;
-	return ret;
-}
-
-static int
-tcp_find_option(u_int8_t option,
-		const struct sk_buff *skb,
-		unsigned int optlen,
-		int invert,
-		int *hotdrop)
-{
-	/* tcp.doff is only 4 bits, ie. max 15 * 4 bytes */
-	u_int8_t _opt[60 - sizeof(struct tcphdr)], *op;
-	unsigned int i;
-
-	duprintf("tcp_match: finding option\n");
-
-	if (!optlen)
-		return invert;
-
-	/* If we don't have the whole header, drop packet. */
-	op =3D skb_header_pointer(skb,
-				skb->nh.iph->ihl*4 + sizeof(struct tcphdr),
-				optlen, _opt);
-	if (op =3D=3D NULL) {
-		*hotdrop =3D 1;
-		return 0;
-	}
-
-	for (i =3D 0; i < optlen; ) {
-		if (op[i] =3D=3D option) return !invert;
-		if (op[i] < 2) i++;
-		else i +=3D op[i+1]?:1;
-	}
-
-	return invert;
-}
-
-static int
-tcp_match(const struct sk_buff *skb,
-	  const struct net_device *in,
-	  const struct net_device *out,
-	  const void *matchinfo,
-	  int offset,
-	  int *hotdrop)
-{
-	struct tcphdr _tcph, *th;
-	const struct ipt_tcp *tcpinfo =3D matchinfo;
-
-	if (offset) {
-		/* To quote Alan:
-
-		   Don't allow a fragment of TCP 8 bytes in. Nobody normal
-		   causes this. Its a cracker trying to break in by doing a
-		   flag overwrite to pass the direction checks.
-		*/
-		if (offset =3D=3D 1) {
-			duprintf("Dropping evil TCP offset=3D1 frag.\n");
-			*hotdrop =3D 1;
-		}
-		/* Must not be a fragment. */
-		return 0;
-	}
-
-#define FWINVTCP(bool,invflg) ((bool) ^ !!(tcpinfo->invflags & invflg))
-
-	th =3D skb_header_pointer(skb, skb->nh.iph->ihl*4,
-				sizeof(_tcph), &_tcph);
-	if (th =3D=3D NULL) {
-		/* We've been asked to examine this packet, and we
-		   can't.  Hence, no choice but to drop. */
-		duprintf("Dropping evil TCP offset=3D0 tinygram.\n");
-		*hotdrop =3D 1;
-		return 0;
-	}
-
-	if (!port_match(tcpinfo->spts[0], tcpinfo->spts[1],
-			ntohs(th->source),
-			!!(tcpinfo->invflags & IPT_TCP_INV_SRCPT)))
-		return 0;
-	if (!port_match(tcpinfo->dpts[0], tcpinfo->dpts[1],
-			ntohs(th->dest),
-			!!(tcpinfo->invflags & IPT_TCP_INV_DSTPT)))
-		return 0;
-	if (!FWINVTCP((((unsigned char *)th)[13] & tcpinfo->flg_mask)
-		      =3D=3D tcpinfo->flg_cmp,
-		      IPT_TCP_INV_FLAGS))
-		return 0;
-	if (tcpinfo->option) {
-		if (th->doff * 4 < sizeof(_tcph)) {
-			*hotdrop =3D 1;
-			return 0;
-		}
-		if (!tcp_find_option(tcpinfo->option, skb,
-				     th->doff*4 - sizeof(_tcph),
-				     tcpinfo->invflags & IPT_TCP_INV_OPTION,
-				     hotdrop))
-			return 0;
-	}
-	return 1;
-}
-
-/* Called when user tries to insert an entry of this type. */
-static int
-tcp_checkentry(const char *tablename,
-	       const struct ipt_ip *ip,
-	       void *matchinfo,
-	       unsigned int matchsize,
-	       unsigned int hook_mask)
-{
-	const struct ipt_tcp *tcpinfo =3D matchinfo;
-
-	/* Must specify proto =3D=3D TCP, and no unknown invflags */
-	return ip->proto =3D=3D IPPROTO_TCP
-		&& !(ip->invflags & IPT_INV_PROTO)
-		&& matchsize =3D=3D IPT_ALIGN(sizeof(struct ipt_tcp))
-		&& !(tcpinfo->invflags & ~IPT_TCP_INV_MASK);
-}
-
-static int
-udp_match(const struct sk_buff *skb,
-	  const struct net_device *in,
-	  const struct net_device *out,
-	  const void *matchinfo,
-	  int offset,
-	  int *hotdrop)
-{
-	struct udphdr _udph, *uh;
-	const struct ipt_udp *udpinfo =3D matchinfo;
-
-	/* Must not be a fragment. */
-	if (offset)
-		return 0;
-
-	uh =3D skb_header_pointer(skb, skb->nh.iph->ihl*4,
-				sizeof(_udph), &_udph);
-	if (uh =3D=3D NULL) {
-		/* We've been asked to examine this packet, and we
-		   can't.  Hence, no choice but to drop. */
-		duprintf("Dropping evil UDP tinygram.\n");
-		*hotdrop =3D 1;
-		return 0;
-	}
-
-	return port_match(udpinfo->spts[0], udpinfo->spts[1],
-			  ntohs(uh->source),
-			  !!(udpinfo->invflags & IPT_UDP_INV_SRCPT))
-		&& port_match(udpinfo->dpts[0], udpinfo->dpts[1],
-			      ntohs(uh->dest),
-			      !!(udpinfo->invflags & IPT_UDP_INV_DSTPT));
-}
-
-/* Called when user tries to insert an entry of this type. */
-static int
-udp_checkentry(const char *tablename,
-	       const struct ipt_ip *ip,
-	       void *matchinfo,
-	       unsigned int matchinfosize,
-	       unsigned int hook_mask)
-{
-	const struct ipt_udp *udpinfo =3D matchinfo;
-
-	/* Must specify proto =3D=3D UDP, and no unknown invflags */
-	if (ip->proto !=3D IPPROTO_UDP || (ip->invflags & IPT_INV_PROTO)) {
-		duprintf("ipt_udp: Protocol %u !=3D %u\n", ip->proto,
-			 IPPROTO_UDP);
-		return 0;
-	}
-	if (matchinfosize !=3D IPT_ALIGN(sizeof(struct ipt_udp))) {
-		duprintf("ipt_udp: matchsize %u !=3D %u\n",
-			 matchinfosize, IPT_ALIGN(sizeof(struct ipt_udp)));
-		return 0;
-	}
-	if (udpinfo->invflags & ~IPT_UDP_INV_MASK) {
-		duprintf("ipt_udp: unknown flags %X\n",
-			 udpinfo->invflags);
-		return 0;
-	}
-
-	return 1;
+	loc_cpu_entry =3D private->entries[raw_smp_processor_id()];
+	IPT_ENTRY_ITERATE(loc_cpu_entry, private->size, cleanup_entry, NULL);
+	xt_free_table_info(private);
 }
=20
 /* Returns 1 if the type and code is matched by the range, 0 otherwise */
@@ -1798,6 +1272,7 @@ icmp_match(const struct sk_buff *skb,
 	   const struct net_device *out,
 	   const void *matchinfo,
 	   int offset,
+	   unsigned int protoff,
 	   int *hotdrop)
 {
 	struct icmphdr _icmph, *ic;
@@ -1807,8 +1282,7 @@ icmp_match(const struct sk_buff *skb,
 	if (offset)
 		return 0;
=20
-	ic =3D skb_header_pointer(skb, skb->nh.iph->ihl*4,
-				sizeof(_icmph), &_icmph);
+	ic =3D skb_header_pointer(skb, protoff, sizeof(_icmph), &_icmph);
 	if (ic =3D=3D NULL) {
 		/* We've been asked to examine this packet, and we
 		 * can't.  Hence, no choice but to drop.
@@ -1828,11 +1302,12 @@ icmp_match(const struct sk_buff *skb,
 /* Called when user tries to insert an entry of this type. */
 static int
 icmp_checkentry(const char *tablename,
-	   const struct ipt_ip *ip,
+	   const void *info,
 	   void *matchinfo,
 	   unsigned int matchsize,
 	   unsigned int hook_mask)
 {
+	const struct ipt_ip *ip =3D info;
 	const struct ipt_icmp *icmpinfo =3D matchinfo;
=20
 	/* Must specify proto =3D=3D ICMP, and no unknown invflags */
@@ -1862,123 +1337,22 @@ static struct nf_sockopt_ops ipt_sockopt
 	.get		=3D do_ipt_get_ctl,
 };
=20
-static struct ipt_match tcp_matchstruct =3D {
-	.name		=3D "tcp",
-	.match		=3D &tcp_match,
-	.checkentry	=3D &tcp_checkentry,
-};
-
-static struct ipt_match udp_matchstruct =3D {
-	.name		=3D "udp",
-	.match		=3D &udp_match,
-	.checkentry	=3D &udp_checkentry,
-};
-
 static struct ipt_match icmp_matchstruct =3D {
 	.name		=3D "icmp",
 	.match		=3D &icmp_match,
 	.checkentry	=3D &icmp_checkentry,
 };
=20
-#ifdef CONFIG_PROC_FS
-static inline int print_name(const char *i,
-			     off_t start_offset, char *buffer, int length,
-			     off_t *pos, unsigned int *count)
-{
-	if ((*count)++ >=3D start_offset) {
-		unsigned int namelen;
-
-		namelen =3D sprintf(buffer + *pos, "%s\n",
-				  i + sizeof(struct list_head));
-		if (*pos + namelen > length) {
-			/* Stop iterating */
-			return 1;
-		}
-		*pos +=3D namelen;
-	}
-	return 0;
-}
-
-static inline int print_target(const struct ipt_target *t,
-                               off_t start_offset, char *buffer, int lengt=
h,
-                               off_t *pos, unsigned int *count)
-{
-	if (t =3D=3D &ipt_standard_target || t =3D=3D &ipt_error_target)
-		return 0;
-	return print_name((char *)t, start_offset, buffer, length, pos, count);
-}
-
-static int ipt_get_tables(char *buffer, char **start, off_t offset, int le=
ngth)
-{
-	off_t pos =3D 0;
-	unsigned int count =3D 0;
-
-	if (down_interruptible(&ipt_mutex) !=3D 0)
-		return 0;
-
-	LIST_FIND(&ipt_tables, print_name, void *,
-		  offset, buffer, length, &pos, &count);
-
-	up(&ipt_mutex);
-
-	/* `start' hack - see fs/proc/generic.c line ~105 */
-	*start=3D(char *)((unsigned long)count-offset);
-	return pos;
-}
-
-static int ipt_get_targets(char *buffer, char **start, off_t offset, int l=
ength)
-{
-	off_t pos =3D 0;
-	unsigned int count =3D 0;
-
-	if (down_interruptible(&ipt_mutex) !=3D 0)
-		return 0;
-
-	LIST_FIND(&ipt_target, print_target, struct ipt_target *,
-		  offset, buffer, length, &pos, &count);
-=09
-	up(&ipt_mutex);
-
-	*start =3D (char *)((unsigned long)count - offset);
-	return pos;
-}
-
-static int ipt_get_matches(char *buffer, char **start, off_t offset, int l=
ength)
-{
-	off_t pos =3D 0;
-	unsigned int count =3D 0;
-
-	if (down_interruptible(&ipt_mutex) !=3D 0)
-		return 0;
-=09
-	LIST_FIND(&ipt_match, print_name, void *,
-		  offset, buffer, length, &pos, &count);
-
-	up(&ipt_mutex);
-
-	*start =3D (char *)((unsigned long)count - offset);
-	return pos;
-}
-
-static const struct { char *name; get_info_t *get_info; } ipt_proc_entry[]=
 =3D
-{ { "ip_tables_names", ipt_get_tables },
-  { "ip_tables_targets", ipt_get_targets },
-  { "ip_tables_matches", ipt_get_matches },
-  { NULL, NULL} };
-#endif /*CONFIG_PROC_FS*/
-
 static int __init init(void)
 {
 	int ret;
=20
+	xt_proto_init(AF_INET);
+
 	/* Noone else will be downing sem now, so we won't sleep */
-	down(&ipt_mutex);
-	list_append(&ipt_target, &ipt_standard_target);
-	list_append(&ipt_target, &ipt_error_target);
-	list_append(&ipt_match, &tcp_matchstruct);
-	list_append(&ipt_match, &udp_matchstruct);
-	list_append(&ipt_match, &icmp_matchstruct);
-	up(&ipt_mutex);
+	xt_register_target(AF_INET, &ipt_standard_target);
+	xt_register_target(AF_INET, &ipt_error_target);
+	xt_register_match(AF_INET, &icmp_matchstruct);
=20
 	/* Register setsockopt */
 	ret =3D nf_register_sockopt(&ipt_sockopts);
@@ -1987,49 +1361,23 @@ static int __init init(void)
 		return ret;
 	}
=20
-#ifdef CONFIG_PROC_FS
-	{
-	struct proc_dir_entry *proc;
-	int i;
-
-	for (i =3D 0; ipt_proc_entry[i].name; i++) {
-		proc =3D proc_net_create(ipt_proc_entry[i].name, 0,
-				       ipt_proc_entry[i].get_info);
-		if (!proc) {
-			while (--i >=3D 0)
-				proc_net_remove(ipt_proc_entry[i].name);
-			nf_unregister_sockopt(&ipt_sockopts);
-			return -ENOMEM;
-		}
-		proc->owner =3D THIS_MODULE;
-	}
-	}
-#endif
-
-	printk("ip_tables: (C) 2000-2002 Netfilter core team\n");
+	printk("ip_tables: (C) 2000-2006 Netfilter Core Team\n");
 	return 0;
 }
=20
 static void __exit fini(void)
 {
 	nf_unregister_sockopt(&ipt_sockopts);
-#ifdef CONFIG_PROC_FS
-	{
-	int i;
-	for (i =3D 0; ipt_proc_entry[i].name; i++)
-		proc_net_remove(ipt_proc_entry[i].name);
-	}
-#endif
+
+	xt_unregister_match(AF_INET, &icmp_matchstruct);
+	xt_unregister_target(AF_INET, &ipt_error_target);
+	xt_unregister_target(AF_INET, &ipt_standard_target);
+
+	xt_proto_fini(AF_INET);
 }
=20
 EXPORT_SYMBOL(ipt_register_table);
 EXPORT_SYMBOL(ipt_unregister_table);
-EXPORT_SYMBOL(ipt_register_match);
-EXPORT_SYMBOL(ipt_unregister_match);
 EXPORT_SYMBOL(ipt_do_table);
-EXPORT_SYMBOL(ipt_register_target);
-EXPORT_SYMBOL(ipt_unregister_target);
-EXPORT_SYMBOL(ipt_find_target);
-
 module_init(init);
 module_exit(fini);
diff --git a/net/ipv4/netfilter/ipt_CLASSIFY.c b/net/ipv4/netfilter/ipt_CLA=
SSIFY.c
deleted file mode 100644
index dab78d8..0000000
--- a/net/ipv4/netfilter/ipt_CLASSIFY.c
+++ /dev/null
@@ -1,90 +0,0 @@
-/*
- * This is a module which is used for setting the skb->priority field
- * of an skb for qdisc classification.
- */
-
-/* (C) 2001-2002 Patrick McHardy <kaber@trash.net>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/ip.h>
-#include <net/checksum.h>
-
-#include <linux/netfilter_ipv4/ip_tables.h>
-#include <linux/netfilter_ipv4/ipt_CLASSIFY.h>
-
-MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
-MODULE_LICENSE("GPL");
-MODULE_DESCRIPTION("iptables qdisc classification target module");
-
-static unsigned int
-target(struct sk_buff **pskb,
-       const struct net_device *in,
-       const struct net_device *out,
-       unsigned int hooknum,
-       const void *targinfo,
-       void *userinfo)
-{
-	const struct ipt_classify_target_info *clinfo =3D targinfo;
-
-	if((*pskb)->priority !=3D clinfo->priority)=20
-		(*pskb)->priority =3D clinfo->priority;
-
-	return IPT_CONTINUE;
-}
-
-static int
-checkentry(const char *tablename,
-           const struct ipt_entry *e,
-           void *targinfo,
-           unsigned int targinfosize,
-           unsigned int hook_mask)
-{
-	if (targinfosize !=3D IPT_ALIGN(sizeof(struct ipt_classify_target_info))){
-		printk(KERN_ERR "CLASSIFY: invalid size (%u !=3D %Zu).\n",
-		       targinfosize,
-		       IPT_ALIGN(sizeof(struct ipt_classify_target_info)));
-		return 0;
-	}
-=09
-	if (hook_mask & ~((1 << NF_IP_LOCAL_OUT) | (1 << NF_IP_FORWARD) |
-	                  (1 << NF_IP_POST_ROUTING))) {
-		printk(KERN_ERR "CLASSIFY: only valid in LOCAL_OUT, FORWARD "
-		                "and POST_ROUTING.\n");
-		return 0;
-	}
-
-	if (strcmp(tablename, "mangle") !=3D 0) {
-		printk(KERN_ERR "CLASSIFY: can only be called from "
-		                "\"mangle\" table, not \"%s\".\n",
-		                tablename);
-		return 0;
-	}
-
-	return 1;
-}
-
-static struct ipt_target ipt_classify_reg =3D {=20
-	.name 		=3D "CLASSIFY",=20
-	.target 	=3D target,
-	.checkentry	=3D checkentry,
-	.me 		=3D THIS_MODULE,
-};
-
-static int __init init(void)
-{
-	return ipt_register_target(&ipt_classify_reg);
-}
-
-static void __exit fini(void)
-{
-	ipt_unregister_target(&ipt_classify_reg);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CL=
USTERIP.c
index 45c52d8..d9bc971 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -379,12 +379,13 @@ target(struct sk_buff **pskb,
=20
 static int
 checkentry(const char *tablename,
-	   const struct ipt_entry *e,
+	   const void *e_void,
            void *targinfo,
            unsigned int targinfosize,
            unsigned int hook_mask)
 {
 	struct ipt_clusterip_tgt_info *cipinfo =3D targinfo;
+	const struct ipt_entry *e =3D e_void;
=20
 	struct clusterip_config *config;
=20
diff --git a/net/ipv4/netfilter/ipt_CONNMARK.c b/net/ipv4/netfilter/ipt_CON=
NMARK.c
deleted file mode 100644
index 8acac5a..0000000
--- a/net/ipv4/netfilter/ipt_CONNMARK.c
+++ /dev/null
@@ -1,122 +0,0 @@
-/* This kernel module is used to modify the connection mark values, or
- * to optionally restore the skb nfmark from the connection mark
- *
- * Copyright (C) 2002,2004 MARA Systems AB <http://www.marasystems.com>
- * by Henrik Nordstrom <hno@marasystems.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  U=
SA
- */
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/ip.h>
-#include <net/checksum.h>
-
-MODULE_AUTHOR("Henrik Nordstrom <hno@marasytems.com>");
-MODULE_DESCRIPTION("IP tables CONNMARK matching module");
-MODULE_LICENSE("GPL");
-
-#include <linux/netfilter_ipv4/ip_tables.h>
-#include <linux/netfilter_ipv4/ipt_CONNMARK.h>
-#include <net/netfilter/nf_conntrack_compat.h>
-
-static unsigned int
-target(struct sk_buff **pskb,
-       const struct net_device *in,
-       const struct net_device *out,
-       unsigned int hooknum,
-       const void *targinfo,
-       void *userinfo)
-{
-	const struct ipt_connmark_target_info *markinfo =3D targinfo;
-	u_int32_t diff;
-	u_int32_t nfmark;
-	u_int32_t newmark;
-	u_int32_t ctinfo;
-	u_int32_t *ctmark =3D nf_ct_get_mark(*pskb, &ctinfo);
-
-	if (ctmark) {
-	    switch(markinfo->mode) {
-	    case IPT_CONNMARK_SET:
-		newmark =3D (*ctmark & ~markinfo->mask) | markinfo->mark;
-		if (newmark !=3D *ctmark)
-		    *ctmark =3D newmark;
-		break;
-	    case IPT_CONNMARK_SAVE:
-		newmark =3D (*ctmark & ~markinfo->mask) | ((*pskb)->nfmark & markinfo->m=
ask);
-		if (*ctmark !=3D newmark)
-		    *ctmark =3D newmark;
-		break;
-	    case IPT_CONNMARK_RESTORE:
-		nfmark =3D (*pskb)->nfmark;
-		diff =3D (*ctmark ^ nfmark) & markinfo->mask;
-		if (diff !=3D 0)
-		    (*pskb)->nfmark =3D nfmark ^ diff;
-		break;
-	    }
-	}
-
-	return IPT_CONTINUE;
-}
-
-static int
-checkentry(const char *tablename,
-	   const struct ipt_entry *e,
-	   void *targinfo,
-	   unsigned int targinfosize,
-	   unsigned int hook_mask)
-{
-	struct ipt_connmark_target_info *matchinfo =3D targinfo;
-	if (targinfosize !=3D IPT_ALIGN(sizeof(struct ipt_connmark_target_info)))=
 {
-		printk(KERN_WARNING "CONNMARK: targinfosize %u !=3D %Zu\n",
-		       targinfosize,
-		       IPT_ALIGN(sizeof(struct ipt_connmark_target_info)));
-		return 0;
-	}
-
-	if (matchinfo->mode =3D=3D IPT_CONNMARK_RESTORE) {
-	    if (strcmp(tablename, "mangle") !=3D 0) {
-		    printk(KERN_WARNING "CONNMARK: restore can only be called from \"man=
gle\" table, not \"%s\"\n", tablename);
-		    return 0;
-	    }
-	}
-
-	if (matchinfo->mark > 0xffffffff || matchinfo->mask > 0xffffffff) {
-		printk(KERN_WARNING "CONNMARK: Only supports 32bit mark\n");
-		return 0;
-	}
-
-	return 1;
-}
-
-static struct ipt_target ipt_connmark_reg =3D {
-	.name =3D "CONNMARK",
-	.target =3D &target,
-	.checkentry =3D &checkentry,
-	.me =3D THIS_MODULE
-};
-
-static int __init init(void)
-{
-	need_ip_conntrack();
-	return ipt_register_target(&ipt_connmark_reg);
-}
-
-static void __exit fini(void)
-{
-	ipt_unregister_target(&ipt_connmark_reg);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv4/netfilter/ipt_DSCP.c b/net/ipv4/netfilter/ipt_DSCP.c
index 6e31957..898cdf7 100644
--- a/net/ipv4/netfilter/ipt_DSCP.c
+++ b/net/ipv4/netfilter/ipt_DSCP.c
@@ -57,7 +57,7 @@ target(struct sk_buff **pskb,
=20
 static int
 checkentry(const char *tablename,
-	   const struct ipt_entry *e,
+	   const void *e_void,
            void *targinfo,
            unsigned int targinfosize,
            unsigned int hook_mask)
diff --git a/net/ipv4/netfilter/ipt_ECN.c b/net/ipv4/netfilter/ipt_ECN.c
index a131969..7064454 100644
--- a/net/ipv4/netfilter/ipt_ECN.c
+++ b/net/ipv4/netfilter/ipt_ECN.c
@@ -113,12 +113,13 @@ target(struct sk_buff **pskb,
=20
 static int
 checkentry(const char *tablename,
-	   const struct ipt_entry *e,
+	   const void *e_void,
            void *targinfo,
            unsigned int targinfosize,
            unsigned int hook_mask)
 {
 	const struct ipt_ECN_info *einfo =3D (struct ipt_ECN_info *)targinfo;
+	const struct ipt_entry *e =3D e_void;
=20
 	if (targinfosize !=3D IPT_ALIGN(sizeof(struct ipt_ECN_info))) {
 		printk(KERN_WARNING "ECN: targinfosize %u !=3D %Zu\n",
diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
index 30be0f1..6606ddb 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -431,7 +431,7 @@ ipt_log_target(struct sk_buff **pskb,
 }
=20
 static int ipt_log_checkentry(const char *tablename,
-			      const struct ipt_entry *e,
+			      const void *e,
 			      void *targinfo,
 			      unsigned int targinfosize,
 			      unsigned int hook_mask)
diff --git a/net/ipv4/netfilter/ipt_MARK.c b/net/ipv4/netfilter/ipt_MARK.c
deleted file mode 100644
index 52b4f2c..0000000
--- a/net/ipv4/netfilter/ipt_MARK.c
+++ /dev/null
@@ -1,172 +0,0 @@
-/* This is a module which is used for setting the NFMARK field of an skb. =
*/
-
-/* (C) 1999-2001 Marc Boucher <marc@mbsi.ca>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/ip.h>
-#include <net/checksum.h>
-
-#include <linux/netfilter_ipv4/ip_tables.h>
-#include <linux/netfilter_ipv4/ipt_MARK.h>
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Marc Boucher <marc@mbsi.ca>");
-MODULE_DESCRIPTION("iptables MARK modification module");
-
-static unsigned int
-target_v0(struct sk_buff **pskb,
-	  const struct net_device *in,
-	  const struct net_device *out,
-	  unsigned int hooknum,
-	  const void *targinfo,
-	  void *userinfo)
-{
-	const struct ipt_mark_target_info *markinfo =3D targinfo;
-
-	if((*pskb)->nfmark !=3D markinfo->mark)
-		(*pskb)->nfmark =3D markinfo->mark;
-
-	return IPT_CONTINUE;
-}
-
-static unsigned int
-target_v1(struct sk_buff **pskb,
-	  const struct net_device *in,
-	  const struct net_device *out,
-	  unsigned int hooknum,
-	  const void *targinfo,
-	  void *userinfo)
-{
-	const struct ipt_mark_target_info_v1 *markinfo =3D targinfo;
-	int mark =3D 0;
-
-	switch (markinfo->mode) {
-	case IPT_MARK_SET:
-		mark =3D markinfo->mark;
-		break;
-	=09
-	case IPT_MARK_AND:
-		mark =3D (*pskb)->nfmark & markinfo->mark;
-		break;
-	=09
-	case IPT_MARK_OR:
-		mark =3D (*pskb)->nfmark | markinfo->mark;
-		break;
-	}
-
-	if((*pskb)->nfmark !=3D mark)
-		(*pskb)->nfmark =3D mark;
-
-	return IPT_CONTINUE;
-}
-
-
-static int
-checkentry_v0(const char *tablename,
-	      const struct ipt_entry *e,
-	      void *targinfo,
-	      unsigned int targinfosize,
-	      unsigned int hook_mask)
-{
-	struct ipt_mark_target_info *markinfo =3D targinfo;
-
-	if (targinfosize !=3D IPT_ALIGN(sizeof(struct ipt_mark_target_info))) {
-		printk(KERN_WARNING "MARK: targinfosize %u !=3D %Zu\n",
-		       targinfosize,
-		       IPT_ALIGN(sizeof(struct ipt_mark_target_info)));
-		return 0;
-	}
-
-	if (strcmp(tablename, "mangle") !=3D 0) {
-		printk(KERN_WARNING "MARK: can only be called from \"mangle\" table, not=
 \"%s\"\n", tablename);
-		return 0;
-	}
-
-	if (markinfo->mark > 0xffffffff) {
-		printk(KERN_WARNING "MARK: Only supports 32bit wide mark\n");
-		return 0;
-	}
-
-	return 1;
-}
-
-static int
-checkentry_v1(const char *tablename,
-	      const struct ipt_entry *e,
-	      void *targinfo,
-	      unsigned int targinfosize,
-	      unsigned int hook_mask)
-{
-	struct ipt_mark_target_info_v1 *markinfo =3D targinfo;
-
-	if (targinfosize !=3D IPT_ALIGN(sizeof(struct ipt_mark_target_info_v1))){
-		printk(KERN_WARNING "MARK: targinfosize %u !=3D %Zu\n",
-		       targinfosize,
-		       IPT_ALIGN(sizeof(struct ipt_mark_target_info_v1)));
-		return 0;
-	}
-
-	if (strcmp(tablename, "mangle") !=3D 0) {
-		printk(KERN_WARNING "MARK: can only be called from \"mangle\" table, not=
 \"%s\"\n", tablename);
-		return 0;
-	}
-
-	if (markinfo->mode !=3D IPT_MARK_SET
-	    && markinfo->mode !=3D IPT_MARK_AND
-	    && markinfo->mode !=3D IPT_MARK_OR) {
-		printk(KERN_WARNING "MARK: unknown mode %u\n",
-		       markinfo->mode);
-		return 0;
-	}
-
-	if (markinfo->mark > 0xffffffff) {
-		printk(KERN_WARNING "MARK: Only supports 32bit wide mark\n");
-		return 0;
-	}
-
-	return 1;
-}
-
-static struct ipt_target ipt_mark_reg_v0 =3D {
-	.name		=3D "MARK",
-	.target		=3D target_v0,
-	.checkentry	=3D checkentry_v0,
-	.me		=3D THIS_MODULE,
-	.revision	=3D 0,
-};
-
-static struct ipt_target ipt_mark_reg_v1 =3D {
-	.name		=3D "MARK",
-	.target		=3D target_v1,
-	.checkentry	=3D checkentry_v1,
-	.me		=3D THIS_MODULE,
-	.revision	=3D 1,
-};
-
-static int __init init(void)
-{
-	int err;
-
-	err =3D ipt_register_target(&ipt_mark_reg_v0);
-	if (!err) {
-		err =3D ipt_register_target(&ipt_mark_reg_v1);
-		if (err)
-			ipt_unregister_target(&ipt_mark_reg_v0);
-	}
-	return err;
-}
-
-static void __exit fini(void)
-{
-	ipt_unregister_target(&ipt_mark_reg_v0);
-	ipt_unregister_target(&ipt_mark_reg_v1);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_M=
ASQUERADE.c
index 2786051..12c56d3 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -40,7 +40,7 @@ static DEFINE_RWLOCK(masq_lock);
 /* FIXME: Multiple targets. --RR */
 static int
 masquerade_check(const char *tablename,
-		 const struct ipt_entry *e,
+		 const void *e,
 		 void *targinfo,
 		 unsigned int targinfosize,
 		 unsigned int hook_mask)
diff --git a/net/ipv4/netfilter/ipt_NETMAP.c b/net/ipv4/netfilter/ipt_NETMA=
P.c
index e6e7b60..b074467 100644
--- a/net/ipv4/netfilter/ipt_NETMAP.c
+++ b/net/ipv4/netfilter/ipt_NETMAP.c
@@ -31,7 +31,7 @@ MODULE_DESCRIPTION("iptables 1:1 NAT map
=20
 static int
 check(const char *tablename,
-      const struct ipt_entry *e,
+      const void *e,
       void *targinfo,
       unsigned int targinfosize,
       unsigned int hook_mask)
diff --git a/net/ipv4/netfilter/ipt_NFQUEUE.c b/net/ipv4/netfilter/ipt_NFQU=
EUE.c
deleted file mode 100644
index 3cedc9b..0000000
--- a/net/ipv4/netfilter/ipt_NFQUEUE.c
+++ /dev/null
@@ -1,70 +0,0 @@
-/* iptables module for using new netfilter netlink queue
- *
- * (C) 2005 by Harald Welte <laforge@netfilter.org>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as=20
- * published by the Free Software Foundation.
- *=20
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-
-#include <linux/netfilter.h>
-#include <linux/netfilter_ipv4/ip_tables.h>
-#include <linux/netfilter_ipv4/ipt_NFQUEUE.h>
-
-MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
-MODULE_DESCRIPTION("iptables NFQUEUE target");
-MODULE_LICENSE("GPL");
-
-static unsigned int
-target(struct sk_buff **pskb,
-       const struct net_device *in,
-       const struct net_device *out,
-       unsigned int hooknum,
-       const void *targinfo,
-       void *userinfo)
-{
-	const struct ipt_NFQ_info *tinfo =3D targinfo;
-
-	return NF_QUEUE_NR(tinfo->queuenum);
-}
-
-static int
-checkentry(const char *tablename,
-	   const struct ipt_entry *e,
-           void *targinfo,
-           unsigned int targinfosize,
-           unsigned int hook_mask)
-{
-	if (targinfosize !=3D IPT_ALIGN(sizeof(struct ipt_NFQ_info))) {
-		printk(KERN_WARNING "NFQUEUE: targinfosize %u !=3D %Zu\n",
-		       targinfosize,
-		       IPT_ALIGN(sizeof(struct ipt_NFQ_info)));
-		return 0;
-	}
-
-	return 1;
-}
-
-static struct ipt_target ipt_NFQ_reg =3D {
-	.name		=3D "NFQUEUE",
-	.target		=3D target,
-	.checkentry	=3D checkentry,
-	.me		=3D THIS_MODULE,
-};
-
-static int __init init(void)
-{
-	return ipt_register_target(&ipt_NFQ_reg);
-}
-
-static void __exit fini(void)
-{
-	ipt_unregister_target(&ipt_NFQ_reg);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv4/netfilter/ipt_NOTRACK.c b/net/ipv4/netfilter/ipt_NOTR=
ACK.c
deleted file mode 100644
index e3c69d0..0000000
--- a/net/ipv4/netfilter/ipt_NOTRACK.c
+++ /dev/null
@@ -1,76 +0,0 @@
-/* This is a module which is used for setting up fake conntracks
- * on packets so that they are not seen by the conntrack/NAT code.
- */
-#include <linux/module.h>
-#include <linux/skbuff.h>
-
-#include <linux/netfilter_ipv4/ip_tables.h>
-#include <net/netfilter/nf_conntrack_compat.h>
-
-static unsigned int
-target(struct sk_buff **pskb,
-       const struct net_device *in,
-       const struct net_device *out,
-       unsigned int hooknum,
-       const void *targinfo,
-       void *userinfo)
-{
-	/* Previously seen (loopback)? Ignore. */
-	if ((*pskb)->nfct !=3D NULL)
-		return IPT_CONTINUE;
-
-	/* Attach fake conntrack entry.=20
-	   If there is a real ct entry correspondig to this packet,=20
-	   it'll hang aroun till timing out. We don't deal with it
-	   for performance reasons. JK */
-	nf_ct_untrack(*pskb);
-	(*pskb)->nfctinfo =3D IP_CT_NEW;
-	nf_conntrack_get((*pskb)->nfct);
-
-	return IPT_CONTINUE;
-}
-
-static int
-checkentry(const char *tablename,
-	   const struct ipt_entry *e,
-           void *targinfo,
-           unsigned int targinfosize,
-           unsigned int hook_mask)
-{
-	if (targinfosize !=3D 0) {
-		printk(KERN_WARNING "NOTRACK: targinfosize %u !=3D 0\n",
-		       targinfosize);
-		return 0;
-	}
-
-	if (strcmp(tablename, "raw") !=3D 0) {
-		printk(KERN_WARNING "NOTRACK: can only be called from \"raw\" table, not=
 \"%s\"\n", tablename);
-		return 0;
-	}
-
-	return 1;
-}
-
-static struct ipt_target ipt_notrack_reg =3D {=20
-	.name =3D "NOTRACK",=20
-	.target =3D target,=20
-	.checkentry =3D checkentry,
-	.me =3D THIS_MODULE=20
-};
-
-static int __init init(void)
-{
-	if (ipt_register_target(&ipt_notrack_reg))
-		return -EINVAL;
-
-	return 0;
-}
-
-static void __exit fini(void)
-{
-	ipt_unregister_target(&ipt_notrack_reg);
-}
-
-module_init(init);
-module_exit(fini);
-MODULE_LICENSE("GPL");
diff --git a/net/ipv4/netfilter/ipt_REDIRECT.c b/net/ipv4/netfilter/ipt_RED=
IRECT.c
index 5245bfd..140be51 100644
--- a/net/ipv4/netfilter/ipt_REDIRECT.c
+++ b/net/ipv4/netfilter/ipt_REDIRECT.c
@@ -33,7 +33,7 @@ MODULE_DESCRIPTION("iptables REDIRECT ta
 /* FIXME: Take multiple ranges --RR */
 static int
 redirect_check(const char *tablename,
-	       const struct ipt_entry *e,
+	       const void *e,
 	       void *targinfo,
 	       unsigned int targinfosize,
 	       unsigned int hook_mask)
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJEC=
T.c
index 6693526..3eb47aa 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -282,12 +282,13 @@ static unsigned int reject(struct sk_buf
 }
=20
 static int check(const char *tablename,
-		 const struct ipt_entry *e,
+		 const void *e_void,
 		 void *targinfo,
 		 unsigned int targinfosize,
 		 unsigned int hook_mask)
 {
  	const struct ipt_reject_info *rejinfo =3D targinfo;
+	const struct ipt_entry *e =3D e_void;
=20
  	if (targinfosize !=3D IPT_ALIGN(sizeof(struct ipt_reject_info))) {
   		DEBUGP("REJECT: targinfosize %u !=3D 0\n", targinfosize);
diff --git a/net/ipv4/netfilter/ipt_SAME.c b/net/ipv4/netfilter/ipt_SAME.c
index 7a0536d..a22de59 100644
--- a/net/ipv4/netfilter/ipt_SAME.c
+++ b/net/ipv4/netfilter/ipt_SAME.c
@@ -49,7 +49,7 @@ MODULE_DESCRIPTION("iptables special SNA
=20
 static int
 same_check(const char *tablename,
-	      const struct ipt_entry *e,
+	      const void *e,
 	      void *targinfo,
 	      unsigned int targinfosize,
 	      unsigned int hook_mask)
diff --git a/net/ipv4/netfilter/ipt_TCPMSS.c b/net/ipv4/netfilter/ipt_TCPMS=
S.c
index 8db70d6..c122841 100644
--- a/net/ipv4/netfilter/ipt_TCPMSS.c
+++ b/net/ipv4/netfilter/ipt_TCPMSS.c
@@ -210,12 +210,13 @@ static inline int find_syn_match(const s
 /* Must specify -p tcp --syn/--tcp-flags SYN */
 static int
 ipt_tcpmss_checkentry(const char *tablename,
-		      const struct ipt_entry *e,
+		      const void *e_void,
 		      void *targinfo,
 		      unsigned int targinfosize,
 		      unsigned int hook_mask)
 {
 	const struct ipt_tcpmss_info *tcpmssinfo =3D targinfo;
+	const struct ipt_entry *e =3D e_void;
=20
 	if (targinfosize !=3D IPT_ALIGN(sizeof(struct ipt_tcpmss_info))) {
 		DEBUGP("ipt_tcpmss_checkentry: targinfosize %u !=3D %u\n",
diff --git a/net/ipv4/netfilter/ipt_TOS.c b/net/ipv4/netfilter/ipt_TOS.c
index deadb36..3a44a56 100644
--- a/net/ipv4/netfilter/ipt_TOS.c
+++ b/net/ipv4/netfilter/ipt_TOS.c
@@ -52,7 +52,7 @@ target(struct sk_buff **pskb,
=20
 static int
 checkentry(const char *tablename,
-	   const struct ipt_entry *e,
+	   const void *e_void,
            void *targinfo,
            unsigned int targinfosize,
            unsigned int hook_mask)
diff --git a/net/ipv4/netfilter/ipt_TTL.c b/net/ipv4/netfilter/ipt_TTL.c
index b9ae6a9..b769eb2 100644
--- a/net/ipv4/netfilter/ipt_TTL.c
+++ b/net/ipv4/netfilter/ipt_TTL.c
@@ -66,7 +66,7 @@ ipt_ttl_target(struct sk_buff **pskb, co
 }
=20
 static int ipt_ttl_checkentry(const char *tablename,
-		const struct ipt_entry *e,
+		const void *e,
 		void *targinfo,
 		unsigned int targinfosize,
 		unsigned int hook_mask)
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index 38641cd..641dbc4 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -330,7 +330,7 @@ static void ipt_logfn(unsigned int pf,
 }
=20
 static int ipt_ulog_checkentry(const char *tablename,
-			       const struct ipt_entry *e,
+			       const void *e,
 			       void *targinfo,
 			       unsigned int targinfosize,
 			       unsigned int hookmask)
diff --git a/net/ipv4/netfilter/ipt_addrtype.c b/net/ipv4/netfilter/ipt_add=
rtype.c
index e19c2a5..d6b83a9 100644
--- a/net/ipv4/netfilter/ipt_addrtype.c
+++ b/net/ipv4/netfilter/ipt_addrtype.c
@@ -29,7 +29,7 @@ static inline int match_type(u_int32_t a
=20
 static int match(const struct sk_buff *skb, const struct net_device *in,
 		 const struct net_device *out, const void *matchinfo,
-		 int offset, int *hotdrop)
+		 int offset, unsigned int protoff, int *hotdrop)
 {
 	const struct ipt_addrtype_info *info =3D matchinfo;
 	const struct iphdr *iph =3D skb->nh.iph;
@@ -43,7 +43,7 @@ static int match(const struct sk_buff *s
 	return ret;
 }
=20
-static int checkentry(const char *tablename, const struct ipt_ip *ip,
+static int checkentry(const char *tablename, const void *ip,
 		      void *matchinfo, unsigned int matchsize,
 		      unsigned int hook_mask)
 {
diff --git a/net/ipv4/netfilter/ipt_ah.c b/net/ipv4/netfilter/ipt_ah.c
index a0fea84..144adfe 100644
--- a/net/ipv4/netfilter/ipt_ah.c
+++ b/net/ipv4/netfilter/ipt_ah.c
@@ -41,6 +41,7 @@ match(const struct sk_buff *skb,
       const struct net_device *out,
       const void *matchinfo,
       int offset,
+      unsigned int protoff,
       int *hotdrop)
 {
 	struct ip_auth_hdr _ahdr, *ah;
@@ -50,7 +51,7 @@ match(const struct sk_buff *skb,
 	if (offset)
 		return 0;
=20
-	ah =3D skb_header_pointer(skb, skb->nh.iph->ihl * 4,
+	ah =3D skb_header_pointer(skb, protoff,
 				sizeof(_ahdr), &_ahdr);
 	if (ah =3D=3D NULL) {
 		/* We've been asked to examine this packet, and we
@@ -69,12 +70,13 @@ match(const struct sk_buff *skb,
 /* Called when user tries to insert an entry of this type. */
 static int
 checkentry(const char *tablename,
-	   const struct ipt_ip *ip,
+	   const void *ip_void,
 	   void *matchinfo,
 	   unsigned int matchinfosize,
 	   unsigned int hook_mask)
 {
 	const struct ipt_ah *ahinfo =3D matchinfo;
+	const struct ipt_ip *ip =3D ip_void;
=20
 	/* Must specify proto =3D=3D AH, and no unknown invflags */
 	if (ip->proto !=3D IPPROTO_AH || (ip->invflags & IPT_INV_PROTO)) {
diff --git a/net/ipv4/netfilter/ipt_comment.c b/net/ipv4/netfilter/ipt_comm=
ent.c
deleted file mode 100644
index 6b76a1e..0000000
--- a/net/ipv4/netfilter/ipt_comment.c
+++ /dev/null
@@ -1,59 +0,0 @@
-/*
- * Implements a dummy match to allow attaching comments to rules
- *
- * 2003-05-13 Brad Fisher (brad@info-link.net)
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/netfilter_ipv4/ip_tables.h>
-#include <linux/netfilter_ipv4/ipt_comment.h>
-
-MODULE_AUTHOR("Brad Fisher <brad@info-link.net>");
-MODULE_DESCRIPTION("iptables comment match module");
-MODULE_LICENSE("GPL");
-
-static int
-match(const struct sk_buff *skb,
-      const struct net_device *in,
-      const struct net_device *out,
-      const void *matchinfo,
-      int offset,
-      int *hotdrop)
-{
-	/* We always match */
-	return 1;
-}
-
-static int
-checkentry(const char *tablename,
-           const struct ipt_ip *ip,
-           void *matchinfo,
-           unsigned int matchsize,
-           unsigned int hook_mask)
-{
-	/* Check the size */
-	if (matchsize !=3D IPT_ALIGN(sizeof(struct ipt_comment_info)))
-		return 0;
-	return 1;
-}
-
-static struct ipt_match comment_match =3D {
-	.name		=3D "comment",
-	.match		=3D match,
-	.checkentry	=3D checkentry,
-	.me		=3D THIS_MODULE
-};
-
-static int __init init(void)
-{
-	return ipt_register_match(&comment_match);
-}
-
-static void __exit fini(void)
-{
-	ipt_unregister_match(&comment_match);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv4/netfilter/ipt_connbytes.c b/net/ipv4/netfilter/ipt_co=
nnbytes.c
deleted file mode 100644
index d68a048..0000000
--- a/net/ipv4/netfilter/ipt_connbytes.c
+++ /dev/null
@@ -1,161 +0,0 @@
-/* Kernel module to match connection tracking byte counter.
- * GPL (C) 2002 Martin Devera (devik@cdi.cz).
- *
- * 2004-07-20 Harald Welte <laforge@netfilter.org>
- * 	- reimplemented to use per-connection accounting counters
- * 	- add functionality to match number of packets
- * 	- add functionality to match average packet size
- * 	- add support to match directions seperately
- *
- */
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <net/netfilter/nf_conntrack_compat.h>
-#include <linux/netfilter_ipv4/ip_tables.h>
-#include <linux/netfilter_ipv4/ipt_connbytes.h>
-
-#include <asm/div64.h>
-#include <asm/bitops.h>
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
-MODULE_DESCRIPTION("iptables match for matching number of pkts/bytes per c=
onnection");
-
-/* 64bit divisor, dividend and result. dynamic precision */
-static u_int64_t div64_64(u_int64_t dividend, u_int64_t divisor)
-{
-	u_int32_t d =3D divisor;
-
-	if (divisor > 0xffffffffULL) {
-		unsigned int shift =3D fls(divisor >> 32);
-
-		d =3D divisor >> shift;
-		dividend >>=3D shift;
-	}
-
-	do_div(dividend, d);
-	return dividend;
-}
-
-static int
-match(const struct sk_buff *skb,
-      const struct net_device *in,
-      const struct net_device *out,
-      const void *matchinfo,
-      int offset,
-      int *hotdrop)
-{
-	const struct ipt_connbytes_info *sinfo =3D matchinfo;
-	u_int64_t what =3D 0;	/* initialize to make gcc happy */
-	const struct ip_conntrack_counter *counters;
-
-	if (!(counters =3D nf_ct_get_counters(skb)))
-		return 0; /* no match */
-
-	switch (sinfo->what) {
-	case IPT_CONNBYTES_PKTS:
-		switch (sinfo->direction) {
-		case IPT_CONNBYTES_DIR_ORIGINAL:
-			what =3D counters[IP_CT_DIR_ORIGINAL].packets;
-			break;
-		case IPT_CONNBYTES_DIR_REPLY:
-			what =3D counters[IP_CT_DIR_REPLY].packets;
-			break;
-		case IPT_CONNBYTES_DIR_BOTH:
-			what =3D counters[IP_CT_DIR_ORIGINAL].packets;
-			what +=3D counters[IP_CT_DIR_REPLY].packets;
-			break;
-		}
-		break;
-	case IPT_CONNBYTES_BYTES:
-		switch (sinfo->direction) {
-		case IPT_CONNBYTES_DIR_ORIGINAL:
-			what =3D counters[IP_CT_DIR_ORIGINAL].bytes;
-			break;
-		case IPT_CONNBYTES_DIR_REPLY:
-			what =3D counters[IP_CT_DIR_REPLY].bytes;
-			break;
-		case IPT_CONNBYTES_DIR_BOTH:
-			what =3D counters[IP_CT_DIR_ORIGINAL].bytes;
-			what +=3D counters[IP_CT_DIR_REPLY].bytes;
-			break;
-		}
-		break;
-	case IPT_CONNBYTES_AVGPKT:
-		switch (sinfo->direction) {
-		case IPT_CONNBYTES_DIR_ORIGINAL:
-			what =3D div64_64(counters[IP_CT_DIR_ORIGINAL].bytes,
-					counters[IP_CT_DIR_ORIGINAL].packets);
-			break;
-		case IPT_CONNBYTES_DIR_REPLY:
-			what =3D div64_64(counters[IP_CT_DIR_REPLY].bytes,
-					counters[IP_CT_DIR_REPLY].packets);
-			break;
-		case IPT_CONNBYTES_DIR_BOTH:
-			{
-				u_int64_t bytes;
-				u_int64_t pkts;
-				bytes =3D counters[IP_CT_DIR_ORIGINAL].bytes +
-					counters[IP_CT_DIR_REPLY].bytes;
-				pkts =3D counters[IP_CT_DIR_ORIGINAL].packets+
-					counters[IP_CT_DIR_REPLY].packets;
-
-				/* FIXME_THEORETICAL: what to do if sum
-				 * overflows ? */
-
-				what =3D div64_64(bytes, pkts);
-			}
-			break;
-		}
-		break;
-	}
-
-	if (sinfo->count.to)
-		return (what <=3D sinfo->count.to && what >=3D sinfo->count.from);
-	else
-		return (what >=3D sinfo->count.from);
-}
-
-static int check(const char *tablename,
-		 const struct ipt_ip *ip,
-		 void *matchinfo,
-		 unsigned int matchsize,
-		 unsigned int hook_mask)
-{
-	const struct ipt_connbytes_info *sinfo =3D matchinfo;
-
-	if (matchsize !=3D IPT_ALIGN(sizeof(struct ipt_connbytes_info)))
-		return 0;
-
-	if (sinfo->what !=3D IPT_CONNBYTES_PKTS &&
-	    sinfo->what !=3D IPT_CONNBYTES_BYTES &&
-	    sinfo->what !=3D IPT_CONNBYTES_AVGPKT)
-		return 0;
-
-	if (sinfo->direction !=3D IPT_CONNBYTES_DIR_ORIGINAL &&
-	    sinfo->direction !=3D IPT_CONNBYTES_DIR_REPLY &&
-	    sinfo->direction !=3D IPT_CONNBYTES_DIR_BOTH)
-		return 0;
-
-	return 1;
-}
-
-static struct ipt_match state_match =3D {
-	.name		=3D "connbytes",
-	.match		=3D &match,
-	.checkentry	=3D &check,
-	.me		=3D THIS_MODULE
-};
-
-static int __init init(void)
-{
-	return ipt_register_match(&state_match);
-}
-
-static void __exit fini(void)
-{
-	ipt_unregister_match(&state_match);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv4/netfilter/ipt_connmark.c b/net/ipv4/netfilter/ipt_con=
nmark.c
deleted file mode 100644
index 5306ef2..0000000
--- a/net/ipv4/netfilter/ipt_connmark.c
+++ /dev/null
@@ -1,88 +0,0 @@
-/* This kernel module matches connection mark values set by the
- * CONNMARK target
- *
- * Copyright (C) 2002,2004 MARA Systems AB <http://www.marasystems.com>
- * by Henrik Nordstrom <hno@marasystems.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  U=
SA
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-
-MODULE_AUTHOR("Henrik Nordstrom <hno@marasytems.com>");
-MODULE_DESCRIPTION("IP tables connmark match module");
-MODULE_LICENSE("GPL");
-
-#include <linux/netfilter_ipv4/ip_tables.h>
-#include <linux/netfilter_ipv4/ipt_connmark.h>
-#include <net/netfilter/nf_conntrack_compat.h>
-
-static int
-match(const struct sk_buff *skb,
-      const struct net_device *in,
-      const struct net_device *out,
-      const void *matchinfo,
-      int offset,
-      int *hotdrop)
-{
-	const struct ipt_connmark_info *info =3D matchinfo;
-	u_int32_t ctinfo;
-	const u_int32_t *ctmark =3D nf_ct_get_mark(skb, &ctinfo);
-	if (!ctmark)
-		return 0;
-
-	return (((*ctmark) & info->mask) =3D=3D info->mark) ^ info->invert;
-}
-
-static int
-checkentry(const char *tablename,
-	   const struct ipt_ip *ip,
-	   void *matchinfo,
-	   unsigned int matchsize,
-	   unsigned int hook_mask)
-{
-	struct ipt_connmark_info *cm =3D=20
-				(struct ipt_connmark_info *)matchinfo;
-	if (matchsize !=3D IPT_ALIGN(sizeof(struct ipt_connmark_info)))
-		return 0;
-
-	if (cm->mark > 0xffffffff || cm->mask > 0xffffffff) {
-		printk(KERN_WARNING "connmark: only support 32bit mark\n");
-		return 0;
-	}
-
-	return 1;
-}
-
-static struct ipt_match connmark_match =3D {
-	.name =3D "connmark",
-	.match =3D &match,
-	.checkentry =3D &checkentry,
-	.me =3D THIS_MODULE
-};
-
-static int __init init(void)
-{
-	return ipt_register_match(&connmark_match);
-}
-
-static void __exit fini(void)
-{
-	ipt_unregister_match(&connmark_match);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv4/netfilter/ipt_conntrack.c b/net/ipv4/netfilter/ipt_co=
nntrack.c
deleted file mode 100644
index c8d1870..0000000
--- a/net/ipv4/netfilter/ipt_conntrack.c
+++ /dev/null
@@ -1,232 +0,0 @@
-/* Kernel module to match connection tracking information.
- * Superset of Rusty's minimalistic state match.
- *
- * (C) 2001  Marc Boucher (marc@mbsi.ca).
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-
-#if defined(CONFIG_IP_NF_CONNTRACK) || defined(CONFIG_IP_NF_CONNTRACK_MODU=
LE)
-#include <linux/netfilter_ipv4/ip_conntrack.h>
-#include <linux/netfilter_ipv4/ip_conntrack_tuple.h>
-#else
-#include <net/netfilter/nf_conntrack.h>
-#endif
-
-#include <linux/netfilter_ipv4/ip_tables.h>
-#include <linux/netfilter_ipv4/ipt_conntrack.h>
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Marc Boucher <marc@mbsi.ca>");
-MODULE_DESCRIPTION("iptables connection tracking match module");
-
-#if defined(CONFIG_IP_NF_CONNTRACK) || defined(CONFIG_IP_NF_CONNTRACK_MODU=
LE)
-
-static int
-match(const struct sk_buff *skb,
-      const struct net_device *in,
-      const struct net_device *out,
-      const void *matchinfo,
-      int offset,
-      int *hotdrop)
-{
-	const struct ipt_conntrack_info *sinfo =3D matchinfo;
-	struct ip_conntrack *ct;
-	enum ip_conntrack_info ctinfo;
-	unsigned int statebit;
-
-	ct =3D ip_conntrack_get((struct sk_buff *)skb, &ctinfo);
-
-#define FWINV(bool,invflg) ((bool) ^ !!(sinfo->invflags & invflg))
-
-	if (ct =3D=3D &ip_conntrack_untracked)
-		statebit =3D IPT_CONNTRACK_STATE_UNTRACKED;
-	else if (ct)
- 		statebit =3D IPT_CONNTRACK_STATE_BIT(ctinfo);
- 	else
- 		statebit =3D IPT_CONNTRACK_STATE_INVALID;
-=20
-	if(sinfo->flags & IPT_CONNTRACK_STATE) {
-		if (ct) {
-			if(ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.ip !=3D
-			    ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.ip)
-				statebit |=3D IPT_CONNTRACK_STATE_SNAT;
-
-			if(ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.ip !=3D
-			    ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.ip)
-				statebit |=3D IPT_CONNTRACK_STATE_DNAT;
-		}
-
-		if (FWINV((statebit & sinfo->statemask) =3D=3D 0, IPT_CONNTRACK_STATE))
-			return 0;
-	}
-
-	if(sinfo->flags & IPT_CONNTRACK_PROTO) {
-		if (!ct || FWINV(ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.protonum !=
=3D sinfo->tuple[IP_CT_DIR_ORIGINAL].dst.protonum, IPT_CONNTRACK_PROTO))
-                	return 0;
-	}
-
-	if(sinfo->flags & IPT_CONNTRACK_ORIGSRC) {
-		if (!ct || FWINV((ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.ip&sinfo->=
sipmsk[IP_CT_DIR_ORIGINAL].s_addr) !=3D sinfo->tuple[IP_CT_DIR_ORIGINAL].sr=
c.ip, IPT_CONNTRACK_ORIGSRC))
-			return 0;
-	}
-
-	if(sinfo->flags & IPT_CONNTRACK_ORIGDST) {
-		if (!ct || FWINV((ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.ip&sinfo->=
dipmsk[IP_CT_DIR_ORIGINAL].s_addr) !=3D sinfo->tuple[IP_CT_DIR_ORIGINAL].ds=
t.ip, IPT_CONNTRACK_ORIGDST))
-			return 0;
-	}
-
-	if(sinfo->flags & IPT_CONNTRACK_REPLSRC) {
-		if (!ct || FWINV((ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.ip&sinfo->sip=
msk[IP_CT_DIR_REPLY].s_addr) !=3D sinfo->tuple[IP_CT_DIR_REPLY].src.ip, IPT=
_CONNTRACK_REPLSRC))
-			return 0;
-	}
-
-	if(sinfo->flags & IPT_CONNTRACK_REPLDST) {
-		if (!ct || FWINV((ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.ip&sinfo->dip=
msk[IP_CT_DIR_REPLY].s_addr) !=3D sinfo->tuple[IP_CT_DIR_REPLY].dst.ip, IPT=
_CONNTRACK_REPLDST))
-			return 0;
-	}
-
-	if(sinfo->flags & IPT_CONNTRACK_STATUS) {
-		if (!ct || FWINV((ct->status & sinfo->statusmask) =3D=3D 0, IPT_CONNTRAC=
K_STATUS))
-			return 0;
-	}
-
-	if(sinfo->flags & IPT_CONNTRACK_EXPIRES) {
-		unsigned long expires;
-
-		if(!ct)
-			return 0;
-
-		expires =3D timer_pending(&ct->timeout) ? (ct->timeout.expires - jiffies=
)/HZ : 0;
-
-		if (FWINV(!(expires >=3D sinfo->expires_min && expires <=3D sinfo->expir=
es_max), IPT_CONNTRACK_EXPIRES))
-			return 0;
-	}
-
-	return 1;
-}
-
-#else /* CONFIG_IP_NF_CONNTRACK */
-static int
-match(const struct sk_buff *skb,
-      const struct net_device *in,
-      const struct net_device *out,
-      const void *matchinfo,
-      int offset,
-      int *hotdrop)
-{
-	const struct ipt_conntrack_info *sinfo =3D matchinfo;
-	struct nf_conn *ct;
-	enum ip_conntrack_info ctinfo;
-	unsigned int statebit;
-
-	ct =3D nf_ct_get((struct sk_buff *)skb, &ctinfo);
-
-#define FWINV(bool,invflg) ((bool) ^ !!(sinfo->invflags & invflg))
-
-	if (ct =3D=3D &nf_conntrack_untracked)
-		statebit =3D IPT_CONNTRACK_STATE_UNTRACKED;
-	else if (ct)
- 		statebit =3D IPT_CONNTRACK_STATE_BIT(ctinfo);
- 	else
- 		statebit =3D IPT_CONNTRACK_STATE_INVALID;
-=20
-	if(sinfo->flags & IPT_CONNTRACK_STATE) {
-		if (ct) {
-			if(ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3.ip !=3D
-			    ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.u3.ip)
-				statebit |=3D IPT_CONNTRACK_STATE_SNAT;
-
-			if(ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.u3.ip !=3D
-			    ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u3.ip)
-				statebit |=3D IPT_CONNTRACK_STATE_DNAT;
-		}
-
-		if (FWINV((statebit & sinfo->statemask) =3D=3D 0, IPT_CONNTRACK_STATE))
-			return 0;
-	}
-
-	if(sinfo->flags & IPT_CONNTRACK_PROTO) {
-		if (!ct || FWINV(ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.protonum !=
=3D sinfo->tuple[IP_CT_DIR_ORIGINAL].dst.protonum, IPT_CONNTRACK_PROTO))
-                	return 0;
-	}
-
-	if(sinfo->flags & IPT_CONNTRACK_ORIGSRC) {
-		if (!ct || FWINV((ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3.ip&sinf=
o->sipmsk[IP_CT_DIR_ORIGINAL].s_addr) !=3D sinfo->tuple[IP_CT_DIR_ORIGINAL]=
=2Esrc.ip, IPT_CONNTRACK_ORIGSRC))
-			return 0;
-	}
-
-	if(sinfo->flags & IPT_CONNTRACK_ORIGDST) {
-		if (!ct || FWINV((ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.u3.ip&sinf=
o->dipmsk[IP_CT_DIR_ORIGINAL].s_addr) !=3D sinfo->tuple[IP_CT_DIR_ORIGINAL]=
=2Edst.ip, IPT_CONNTRACK_ORIGDST))
-			return 0;
-	}
-
-	if(sinfo->flags & IPT_CONNTRACK_REPLSRC) {
-		if (!ct || FWINV((ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u3.ip&sinfo->=
sipmsk[IP_CT_DIR_REPLY].s_addr) !=3D sinfo->tuple[IP_CT_DIR_REPLY].src.ip, =
IPT_CONNTRACK_REPLSRC))
-			return 0;
-	}
-
-	if(sinfo->flags & IPT_CONNTRACK_REPLDST) {
-		if (!ct || FWINV((ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.u3.ip&sinfo->=
dipmsk[IP_CT_DIR_REPLY].s_addr) !=3D sinfo->tuple[IP_CT_DIR_REPLY].dst.ip, =
IPT_CONNTRACK_REPLDST))
-			return 0;
-	}
-
-	if(sinfo->flags & IPT_CONNTRACK_STATUS) {
-		if (!ct || FWINV((ct->status & sinfo->statusmask) =3D=3D 0, IPT_CONNTRAC=
K_STATUS))
-			return 0;
-	}
-
-	if(sinfo->flags & IPT_CONNTRACK_EXPIRES) {
-		unsigned long expires;
-
-		if(!ct)
-			return 0;
-
-		expires =3D timer_pending(&ct->timeout) ? (ct->timeout.expires - jiffies=
)/HZ : 0;
-
-		if (FWINV(!(expires >=3D sinfo->expires_min && expires <=3D sinfo->expir=
es_max), IPT_CONNTRACK_EXPIRES))
-			return 0;
-	}
-
-	return 1;
-}
-
-#endif /* CONFIG_NF_IP_CONNTRACK */
-
-static int check(const char *tablename,
-		 const struct ipt_ip *ip,
-		 void *matchinfo,
-		 unsigned int matchsize,
-		 unsigned int hook_mask)
-{
-	if (matchsize !=3D IPT_ALIGN(sizeof(struct ipt_conntrack_info)))
-		return 0;
-
-	return 1;
-}
-
-static struct ipt_match conntrack_match =3D {
-	.name		=3D "conntrack",
-	.match		=3D &match,
-	.checkentry	=3D &check,
-	.me		=3D THIS_MODULE,
-};
-
-static int __init init(void)
-{
-	need_ip_conntrack();
-	return ipt_register_match(&conntrack_match);
-}
-
-static void __exit fini(void)
-{
-	ipt_unregister_match(&conntrack_match);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv4/netfilter/ipt_dccp.c b/net/ipv4/netfilter/ipt_dccp.c
deleted file mode 100644
index ad3278b..0000000
--- a/net/ipv4/netfilter/ipt_dccp.c
+++ /dev/null
@@ -1,176 +0,0 @@
-/*
- * iptables module for DCCP protocol header matching
- *
- * (C) 2005 by Harald Welte <laforge@netfilter.org>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/spinlock.h>
-#include <net/ip.h>
-#include <linux/dccp.h>
-
-#include <linux/netfilter_ipv4/ip_tables.h>
-#include <linux/netfilter_ipv4/ipt_dccp.h>
-
-#define DCCHECK(cond, option, flag, invflag) (!((flag) & (option)) \
-		                  || (!!((invflag) & (option)) ^ (cond)))
-
-static unsigned char *dccp_optbuf;
-static DEFINE_SPINLOCK(dccp_buflock);
-
-static inline int
-dccp_find_option(u_int8_t option,
-		 const struct sk_buff *skb,
-		 const struct dccp_hdr *dh,
-		 int *hotdrop)
-{
-	/* tcp.doff is only 4 bits, ie. max 15 * 4 bytes */
-	unsigned char *op;
-	unsigned int optoff =3D __dccp_hdr_len(dh);
-	unsigned int optlen =3D dh->dccph_doff*4 - __dccp_hdr_len(dh);
-	unsigned int i;
-
-	if (dh->dccph_doff * 4 < __dccp_hdr_len(dh)) {
-		*hotdrop =3D 1;
-		return 0;
-	}
-
-	if (!optlen)
-		return 0;
-
-	spin_lock_bh(&dccp_buflock);
-	op =3D skb_header_pointer(skb,
-				skb->nh.iph->ihl*4 + optoff,
-				optlen, dccp_optbuf);
-	if (op =3D=3D NULL) {
-		/* If we don't have the whole header, drop packet. */
-		spin_unlock_bh(&dccp_buflock);
-		*hotdrop =3D 1;
-		return 0;
-	}
-
-	for (i =3D 0; i < optlen; ) {
-		if (op[i] =3D=3D option) {
-			spin_unlock_bh(&dccp_buflock);
-			return 1;
-		}
-
-		if (op[i] < 2)=20
-			i++;
-		else=20
-			i +=3D op[i+1]?:1;
-	}
-
-	spin_unlock_bh(&dccp_buflock);
-	return 0;
-}
-
-
-static inline int
-match_types(const struct dccp_hdr *dh, u_int16_t typemask)
-{
-	return (typemask & (1 << dh->dccph_type));
-}
-
-static inline int
-match_option(u_int8_t option, const struct sk_buff *skb,
-	     const struct dccp_hdr *dh, int *hotdrop)
-{
-	return dccp_find_option(option, skb, dh, hotdrop);
-}
-
-static int
-match(const struct sk_buff *skb,
-      const struct net_device *in,
-      const struct net_device *out,
-      const void *matchinfo,
-      int offset,
-      int *hotdrop)
-{
-	const struct ipt_dccp_info *info =3D=20
-				(const struct ipt_dccp_info *)matchinfo;
-	struct dccp_hdr _dh, *dh;
-
-	if (offset)
-		return 0;
-=09
-	dh =3D skb_header_pointer(skb, skb->nh.iph->ihl*4, sizeof(_dh), &_dh);
-	if (dh =3D=3D NULL) {
-		*hotdrop =3D 1;
-		return 0;
-       	}
-
-	return  DCCHECK(((ntohs(dh->dccph_sport) >=3D info->spts[0])=20
-			&& (ntohs(dh->dccph_sport) <=3D info->spts[1])),=20
-		   	IPT_DCCP_SRC_PORTS, info->flags, info->invflags)
-		&& DCCHECK(((ntohs(dh->dccph_dport) >=3D info->dpts[0])=20
-			&& (ntohs(dh->dccph_dport) <=3D info->dpts[1])),=20
-			IPT_DCCP_DEST_PORTS, info->flags, info->invflags)
-		&& DCCHECK(match_types(dh, info->typemask),
-			   IPT_DCCP_TYPE, info->flags, info->invflags)
-		&& DCCHECK(match_option(info->option, skb, dh, hotdrop),
-			   IPT_DCCP_OPTION, info->flags, info->invflags);
-}
-
-static int
-checkentry(const char *tablename,
-	   const struct ipt_ip *ip,
-	   void *matchinfo,
-	   unsigned int matchsize,
-	   unsigned int hook_mask)
-{
-	const struct ipt_dccp_info *info;
-
-	info =3D (const struct ipt_dccp_info *)matchinfo;
-
-	return ip->proto =3D=3D IPPROTO_DCCP
-		&& !(ip->invflags & IPT_INV_PROTO)
-		&& matchsize =3D=3D IPT_ALIGN(sizeof(struct ipt_dccp_info))
-		&& !(info->flags & ~IPT_DCCP_VALID_FLAGS)
-		&& !(info->invflags & ~IPT_DCCP_VALID_FLAGS)
-		&& !(info->invflags & ~info->flags);
-}
-
-static struct ipt_match dccp_match =3D=20
-{=20
-	.name 		=3D "dccp",
-	.match		=3D &match,
-	.checkentry	=3D &checkentry,
-	.me 		=3D THIS_MODULE,
-};
-
-static int __init init(void)
-{
-	int ret;
-
-	/* doff is 8 bits, so the maximum option size is (4*256).  Don't put
-	 * this in BSS since DaveM is worried about locked TLB's for kernel
-	 * BSS. */
-	dccp_optbuf =3D kmalloc(256 * 4, GFP_KERNEL);
-	if (!dccp_optbuf)
-		return -ENOMEM;
-	ret =3D ipt_register_match(&dccp_match);
-	if (ret)
-		kfree(dccp_optbuf);
-
-	return ret;
-}
-
-static void __exit fini(void)
-{
-	ipt_unregister_match(&dccp_match);
-	kfree(dccp_optbuf);
-}
-
-module_init(init);
-module_exit(fini);
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
-MODULE_DESCRIPTION("Match for DCCP protocol packets");
-
diff --git a/net/ipv4/netfilter/ipt_dscp.c b/net/ipv4/netfilter/ipt_dscp.c
index 5df52a6..92063b4 100644
--- a/net/ipv4/netfilter/ipt_dscp.c
+++ b/net/ipv4/netfilter/ipt_dscp.c
@@ -21,7 +21,7 @@ MODULE_LICENSE("GPL");
=20
 static int match(const struct sk_buff *skb, const struct net_device *in,
 		 const struct net_device *out, const void *matchinfo,
-		 int offset, int *hotdrop)
+		 int offset, unsigned int protoff, int *hotdrop)
 {
 	const struct ipt_dscp_info *info =3D matchinfo;
 	const struct iphdr *iph =3D skb->nh.iph;
@@ -31,7 +31,7 @@ static int match(const struct sk_buff *s
 	return ((iph->tos&IPT_DSCP_MASK) =3D=3D sh_dscp) ^ info->invert;
 }
=20
-static int checkentry(const char *tablename, const struct ipt_ip *ip,
+static int checkentry(const char *tablename, const void *ip,
 		      void *matchinfo, unsigned int matchsize,
 		      unsigned int hook_mask)
 {
diff --git a/net/ipv4/netfilter/ipt_ecn.c b/net/ipv4/netfilter/ipt_ecn.c
index b6f7181..e68b0c7 100644
--- a/net/ipv4/netfilter/ipt_ecn.c
+++ b/net/ipv4/netfilter/ipt_ecn.c
@@ -67,7 +67,7 @@ static inline int match_tcp(const struct
=20
 static int match(const struct sk_buff *skb, const struct net_device *in,
 		 const struct net_device *out, const void *matchinfo,
-		 int offset, int *hotdrop)
+		 int offset, unsigned int protoff, int *hotdrop)
 {
 	const struct ipt_ecn_info *info =3D matchinfo;
=20
@@ -85,11 +85,12 @@ static int match(const struct sk_buff *s
 	return 1;
 }
=20
-static int checkentry(const char *tablename, const struct ipt_ip *ip,
+static int checkentry(const char *tablename, const void *ip_void,
 		      void *matchinfo, unsigned int matchsize,
 		      unsigned int hook_mask)
 {
 	const struct ipt_ecn_info *info =3D matchinfo;
+	const struct ipt_ip *ip =3D ip_void;
=20
 	if (matchsize !=3D IPT_ALIGN(sizeof(struct ipt_ecn_info)))
 		return 0;
diff --git a/net/ipv4/netfilter/ipt_esp.c b/net/ipv4/netfilter/ipt_esp.c
index e1d0dd3..9de191a 100644
--- a/net/ipv4/netfilter/ipt_esp.c
+++ b/net/ipv4/netfilter/ipt_esp.c
@@ -42,6 +42,7 @@ match(const struct sk_buff *skb,
       const struct net_device *out,
       const void *matchinfo,
       int offset,
+      unsigned int protoff,
       int *hotdrop)
 {
 	struct ip_esp_hdr _esp, *eh;
@@ -51,7 +52,7 @@ match(const struct sk_buff *skb,
 	if (offset)
 		return 0;
=20
-	eh =3D skb_header_pointer(skb, skb->nh.iph->ihl * 4,
+	eh =3D skb_header_pointer(skb, protoff,
 				sizeof(_esp), &_esp);
 	if (eh =3D=3D NULL) {
 		/* We've been asked to examine this packet, and we
@@ -70,12 +71,13 @@ match(const struct sk_buff *skb,
 /* Called when user tries to insert an entry of this type. */
 static int
 checkentry(const char *tablename,
-	   const struct ipt_ip *ip,
+	   const void *ip_void,
 	   void *matchinfo,
 	   unsigned int matchinfosize,
 	   unsigned int hook_mask)
 {
 	const struct ipt_esp *espinfo =3D matchinfo;
+	const struct ipt_ip *ip =3D ip_void;
=20
 	/* Must specify proto =3D=3D ESP, and no unknown invflags */
 	if (ip->proto !=3D IPPROTO_ESP || (ip->invflags & IPT_INV_PROTO)) {
diff --git a/net/ipv4/netfilter/ipt_hashlimit.c b/net/ipv4/netfilter/ipt_ha=
shlimit.c
index 2dd1ccc..4fe48c1 100644
--- a/net/ipv4/netfilter/ipt_hashlimit.c
+++ b/net/ipv4/netfilter/ipt_hashlimit.c
@@ -429,6 +429,7 @@ hashlimit_match(const struct sk_buff *sk
 		const struct net_device *out,
 		const void *matchinfo,
 		int offset,
+		unsigned int protoff,
 		int *hotdrop)
 {
 	struct ipt_hashlimit_info *r =3D=20
@@ -504,7 +505,7 @@ hashlimit_match(const struct sk_buff *sk
=20
 static int
 hashlimit_checkentry(const char *tablename,
-		     const struct ipt_ip *ip,
+		     const void *inf,
 		     void *matchinfo,
 		     unsigned int matchsize,
 		     unsigned int hook_mask)
diff --git a/net/ipv4/netfilter/ipt_helper.c b/net/ipv4/netfilter/ipt_helpe=
r.c
deleted file mode 100644
index aef649e..0000000
--- a/net/ipv4/netfilter/ipt_helper.c
+++ /dev/null
@@ -1,168 +0,0 @@
-/* iptables module to match on related connections */
-/*
- * (C) 2001 Martin Josefsson <gandalf@wlug.westbo.se>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- *
- *   19 Mar 2002 Harald Welte <laforge@gnumonks.org>:
- *   		 - Port to newnat infrastructure
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/netfilter.h>
-#include <linux/interrupt.h>
-#if defined(CONFIG_IP_NF_CONNTRACK) || defined(CONFIG_IP_NF_CONNTRACK_MODU=
LE)
-#include <linux/netfilter_ipv4/ip_conntrack.h>
-#include <linux/netfilter_ipv4/ip_conntrack_core.h>
-#include <linux/netfilter_ipv4/ip_conntrack_helper.h>
-#else
-#include <net/netfilter/nf_conntrack.h>
-#include <net/netfilter/nf_conntrack_core.h>
-#include <net/netfilter/nf_conntrack_helper.h>
-#endif
-#include <linux/netfilter_ipv4/ip_tables.h>
-#include <linux/netfilter_ipv4/ipt_helper.h>
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Martin Josefsson <gandalf@netfilter.org>");
-MODULE_DESCRIPTION("iptables helper match module");
-
-#if 0
-#define DEBUGP printk
-#else
-#define DEBUGP(format, args...)
-#endif
-
-#if defined(CONFIG_IP_NF_CONNTRACK) || defined(CONFIG_IP_NF_CONNTRACK_MODU=
LE)
-static int
-match(const struct sk_buff *skb,
-      const struct net_device *in,
-      const struct net_device *out,
-      const void *matchinfo,
-      int offset,
-      int *hotdrop)
-{
-	const struct ipt_helper_info *info =3D matchinfo;
-	struct ip_conntrack *ct;
-	enum ip_conntrack_info ctinfo;
-	int ret =3D info->invert;
-=09
-	ct =3D ip_conntrack_get((struct sk_buff *)skb, &ctinfo);
-	if (!ct) {
-		DEBUGP("ipt_helper: Eek! invalid conntrack?\n");
-		return ret;
-	}
-
-	if (!ct->master) {
-		DEBUGP("ipt_helper: conntrack %p has no master\n", ct);
-		return ret;
-	}
-
-	read_lock_bh(&ip_conntrack_lock);
-	if (!ct->master->helper) {
-		DEBUGP("ipt_helper: master ct %p has no helper\n",=20
-			exp->expectant);
-		goto out_unlock;
-	}
-
-	DEBUGP("master's name =3D %s , info->name =3D %s\n",=20
-		ct->master->helper->name, info->name);
-
-	if (info->name[0] =3D=3D '\0')
-		ret ^=3D 1;
-	else
-		ret ^=3D !strncmp(ct->master->helper->name, info->name,=20
-		                strlen(ct->master->helper->name));
-out_unlock:
-	read_unlock_bh(&ip_conntrack_lock);
-	return ret;
-}
-
-#else /* CONFIG_IP_NF_CONNTRACK */
-
-static int
-match(const struct sk_buff *skb,
-      const struct net_device *in,
-      const struct net_device *out,
-      const void *matchinfo,
-      int offset,
-      int *hotdrop)
-{
-	const struct ipt_helper_info *info =3D matchinfo;
-	struct nf_conn *ct;
-	enum ip_conntrack_info ctinfo;
-	int ret =3D info->invert;
-=09
-	ct =3D nf_ct_get((struct sk_buff *)skb, &ctinfo);
-	if (!ct) {
-		DEBUGP("ipt_helper: Eek! invalid conntrack?\n");
-		return ret;
-	}
-
-	if (!ct->master) {
-		DEBUGP("ipt_helper: conntrack %p has no master\n", ct);
-		return ret;
-	}
-
-	read_lock_bh(&nf_conntrack_lock);
-	if (!ct->master->helper) {
-		DEBUGP("ipt_helper: master ct %p has no helper\n",=20
-			exp->expectant);
-		goto out_unlock;
-	}
-
-	DEBUGP("master's name =3D %s , info->name =3D %s\n",=20
-		ct->master->helper->name, info->name);
-
-	if (info->name[0] =3D=3D '\0')
-		ret ^=3D 1;
-	else
-		ret ^=3D !strncmp(ct->master->helper->name, info->name,=20
-		                strlen(ct->master->helper->name));
-out_unlock:
-	read_unlock_bh(&nf_conntrack_lock);
-	return ret;
-}
-#endif
-
-static int check(const char *tablename,
-		 const struct ipt_ip *ip,
-		 void *matchinfo,
-		 unsigned int matchsize,
-		 unsigned int hook_mask)
-{
-	struct ipt_helper_info *info =3D matchinfo;
-
-	info->name[29] =3D '\0';
-
-	/* verify size */
-	if (matchsize !=3D IPT_ALIGN(sizeof(struct ipt_helper_info)))
-		return 0;
-
-	return 1;
-}
-
-static struct ipt_match helper_match =3D {
-	.name		=3D "helper",
-	.match		=3D &match,
-	.checkentry	=3D &check,
-	.me		=3D THIS_MODULE,
-};
-
-static int __init init(void)
-{
-	need_ip_conntrack();
-	return ipt_register_match(&helper_match);
-}
-
-static void __exit fini(void)
-{
-	ipt_unregister_match(&helper_match);
-}
-
-module_init(init);
-module_exit(fini);
-
diff --git a/net/ipv4/netfilter/ipt_iprange.c b/net/ipv4/netfilter/ipt_ipra=
nge.c
index b835b7b..13fb16f 100644
--- a/net/ipv4/netfilter/ipt_iprange.c
+++ b/net/ipv4/netfilter/ipt_iprange.c
@@ -28,7 +28,7 @@ match(const struct sk_buff *skb,
       const struct net_device *in,
       const struct net_device *out,
       const void *matchinfo,
-      int offset, int *hotdrop)
+      int offset, unsigned int protoff, int *hotdrop)
 {
 	const struct ipt_iprange_info *info =3D matchinfo;
 	const struct iphdr *iph =3D skb->nh.iph;
@@ -63,7 +63,7 @@ match(const struct sk_buff *skb,
 }
=20
 static int check(const char *tablename,
-		 const struct ipt_ip *ip,
+		 const void *inf,
 		 void *matchinfo,
 		 unsigned int matchsize,
 		 unsigned int hook_mask)
diff --git a/net/ipv4/netfilter/ipt_length.c b/net/ipv4/netfilter/ipt_lengt=
h.c
deleted file mode 100644
index 4eabcfb..0000000
--- a/net/ipv4/netfilter/ipt_length.c
+++ /dev/null
@@ -1,64 +0,0 @@
-/* Kernel module to match packet length. */
-/* (C) 1999-2001 James Morris <jmorros@intercode.com.au>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-
-#include <linux/netfilter_ipv4/ipt_length.h>
-#include <linux/netfilter_ipv4/ip_tables.h>
-
-MODULE_AUTHOR("James Morris <jmorris@intercode.com.au>");
-MODULE_DESCRIPTION("IP tables packet length matching module");
-MODULE_LICENSE("GPL");
-
-static int
-match(const struct sk_buff *skb,
-      const struct net_device *in,
-      const struct net_device *out,
-      const void *matchinfo,
-      int offset,
-      int *hotdrop)
-{
-	const struct ipt_length_info *info =3D matchinfo;
-	u_int16_t pktlen =3D ntohs(skb->nh.iph->tot_len);
-=09
-	return (pktlen >=3D info->min && pktlen <=3D info->max) ^ info->invert;
-}
-
-static int
-checkentry(const char *tablename,
-           const struct ipt_ip *ip,
-           void *matchinfo,
-           unsigned int matchsize,
-           unsigned int hook_mask)
-{
-	if (matchsize !=3D IPT_ALIGN(sizeof(struct ipt_length_info)))
-		return 0;
-
-	return 1;
-}
-
-static struct ipt_match length_match =3D {
-	.name		=3D "length",
-	.match		=3D &match,
-	.checkentry	=3D &checkentry,
-	.me		=3D THIS_MODULE,
-};
-
-static int __init init(void)
-{
-	return ipt_register_match(&length_match);
-}
-
-static void __exit fini(void)
-{
-	ipt_unregister_match(&length_match);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv4/netfilter/ipt_limit.c b/net/ipv4/netfilter/ipt_limit.c
deleted file mode 100644
index 0c24dcc..0000000
--- a/net/ipv4/netfilter/ipt_limit.c
+++ /dev/null
@@ -1,157 +0,0 @@
-/* Kernel module to control the rate
- *
- * 2 September 1999: Changed from the target RATE to the match
- *                   `limit', removed logging.  Did I mention that
- *                   Alexey is a fucking genius?
- *                   Rusty Russell (rusty@rustcorp.com.au).  */
-
-/* (C) 1999 J=E9r=F4me de Vivie <devivie@info.enserb.u-bordeaux.fr>
- * (C) 1999 Herv=E9 Eychenne <eychenne@info.enserb.u-bordeaux.fr>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/spinlock.h>
-#include <linux/interrupt.h>
-
-#include <linux/netfilter_ipv4/ip_tables.h>
-#include <linux/netfilter_ipv4/ipt_limit.h>
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Herve Eychenne <rv@wallfire.org>");
-MODULE_DESCRIPTION("iptables rate limit match");
-
-/* The algorithm used is the Simple Token Bucket Filter (TBF)
- * see net/sched/sch_tbf.c in the linux source tree
- */
-
-static DEFINE_SPINLOCK(limit_lock);
-
-/* Rusty: This is my (non-mathematically-inclined) understanding of
-   this algorithm.  The `average rate' in jiffies becomes your initial
-   amount of credit `credit' and the most credit you can ever have
-   `credit_cap'.  The `peak rate' becomes the cost of passing the
-   test, `cost'.
-
-   `prev' tracks the last packet hit: you gain one credit per jiffy.
-   If you get credit balance more than this, the extra credit is
-   discarded.  Every time the match passes, you lose `cost' credits;
-   if you don't have that many, the test fails.
-
-   See Alexey's formal explanation in net/sched/sch_tbf.c.
-
-   To get the maxmum range, we multiply by this factor (ie. you get N
-   credits per jiffy).  We want to allow a rate as low as 1 per day
-   (slowest userspace tool allows), which means
-   CREDITS_PER_JIFFY*HZ*60*60*24 < 2^32. ie. */
-#define MAX_CPJ (0xFFFFFFFF / (HZ*60*60*24))
-
-/* Repeated shift and or gives us all 1s, final shift and add 1 gives
- * us the power of 2 below the theoretical max, so GCC simply does a
- * shift. */
-#define _POW2_BELOW2(x) ((x)|((x)>>1))
-#define _POW2_BELOW4(x) (_POW2_BELOW2(x)|_POW2_BELOW2((x)>>2))
-#define _POW2_BELOW8(x) (_POW2_BELOW4(x)|_POW2_BELOW4((x)>>4))
-#define _POW2_BELOW16(x) (_POW2_BELOW8(x)|_POW2_BELOW8((x)>>8))
-#define _POW2_BELOW32(x) (_POW2_BELOW16(x)|_POW2_BELOW16((x)>>16))
-#define POW2_BELOW32(x) ((_POW2_BELOW32(x)>>1) + 1)
-
-#define CREDITS_PER_JIFFY POW2_BELOW32(MAX_CPJ)
-
-static int
-ipt_limit_match(const struct sk_buff *skb,
-		const struct net_device *in,
-		const struct net_device *out,
-		const void *matchinfo,
-		int offset,
-		int *hotdrop)
-{
-	struct ipt_rateinfo *r =3D ((struct ipt_rateinfo *)matchinfo)->master;
-	unsigned long now =3D jiffies;
-
-	spin_lock_bh(&limit_lock);
-	r->credit +=3D (now - xchg(&r->prev, now)) * CREDITS_PER_JIFFY;
-	if (r->credit > r->credit_cap)
-		r->credit =3D r->credit_cap;
-
-	if (r->credit >=3D r->cost) {
-		/* We're not limited. */
-		r->credit -=3D r->cost;
-		spin_unlock_bh(&limit_lock);
-		return 1;
-	}
-
-       	spin_unlock_bh(&limit_lock);
-	return 0;
-}
-
-/* Precision saver. */
-static u_int32_t
-user2credits(u_int32_t user)
-{
-	/* If multiplying would overflow... */
-	if (user > 0xFFFFFFFF / (HZ*CREDITS_PER_JIFFY))
-		/* Divide first. */
-		return (user / IPT_LIMIT_SCALE) * HZ * CREDITS_PER_JIFFY;
-
-	return (user * HZ * CREDITS_PER_JIFFY) / IPT_LIMIT_SCALE;
-}
-
-static int
-ipt_limit_checkentry(const char *tablename,
-		     const struct ipt_ip *ip,
-		     void *matchinfo,
-		     unsigned int matchsize,
-		     unsigned int hook_mask)
-{
-	struct ipt_rateinfo *r =3D matchinfo;
-
-	if (matchsize !=3D IPT_ALIGN(sizeof(struct ipt_rateinfo)))
-		return 0;
-
-	/* Check for overflow. */
-	if (r->burst =3D=3D 0
-	    || user2credits(r->avg * r->burst) < user2credits(r->avg)) {
-		printk("Overflow in ipt_limit, try lower: %u/%u\n",
-		       r->avg, r->burst);
-		return 0;
-	}
-
-	/* User avg in seconds * IPT_LIMIT_SCALE: convert to jiffies *
-	   128. */
-	r->prev =3D jiffies;
-	r->credit =3D user2credits(r->avg * r->burst);	 /* Credits full. */
-	r->credit_cap =3D user2credits(r->avg * r->burst); /* Credits full. */
-	r->cost =3D user2credits(r->avg);
-
-	/* For SMP, we only want to use one set of counters. */
-	r->master =3D r;
-
-	return 1;
-}
-
-static struct ipt_match ipt_limit_reg =3D {
-	.name		=3D "limit",
-	.match		=3D ipt_limit_match,
-	.checkentry	=3D ipt_limit_checkentry,
-	.me		=3D THIS_MODULE,
-};
-
-static int __init init(void)
-{
-	if (ipt_register_match(&ipt_limit_reg))
-		return -EINVAL;
-	return 0;
-}
-
-static void __exit fini(void)
-{
-	ipt_unregister_match(&ipt_limit_reg);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv4/netfilter/ipt_mac.c b/net/ipv4/netfilter/ipt_mac.c
deleted file mode 100644
index 1b9bb45..0000000
--- a/net/ipv4/netfilter/ipt_mac.c
+++ /dev/null
@@ -1,80 +0,0 @@
-/* Kernel module to match MAC address parameters. */
-
-/* (C) 1999-2001 Paul `Rusty' Russell
- * (C) 2002-2004 Netfilter Core Team <coreteam@netfilter.org>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/if_ether.h>
-#include <linux/etherdevice.h>
-
-#include <linux/netfilter_ipv4/ipt_mac.h>
-#include <linux/netfilter_ipv4/ip_tables.h>
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
-MODULE_DESCRIPTION("iptables mac matching module");
-
-static int
-match(const struct sk_buff *skb,
-      const struct net_device *in,
-      const struct net_device *out,
-      const void *matchinfo,
-      int offset,
-      int *hotdrop)
-{
-    const struct ipt_mac_info *info =3D matchinfo;
-
-    /* Is mac pointer valid? */
-    return (skb->mac.raw >=3D skb->head
-	    && (skb->mac.raw + ETH_HLEN) <=3D skb->data
-	    /* If so, compare... */
-	    && ((!compare_ether_addr(eth_hdr(skb)->h_source, info->srcaddr))
-		^ info->invert));
-}
-
-static int
-ipt_mac_checkentry(const char *tablename,
-		   const struct ipt_ip *ip,
-		   void *matchinfo,
-		   unsigned int matchsize,
-		   unsigned int hook_mask)
-{
-	/* FORWARD isn't always valid, but it's nice to be able to do --RR */
-	if (hook_mask
-	    & ~((1 << NF_IP_PRE_ROUTING) | (1 << NF_IP_LOCAL_IN)
-		| (1 << NF_IP_FORWARD))) {
-		printk("ipt_mac: only valid for PRE_ROUTING, LOCAL_IN or FORWARD.\n");
-		return 0;
-	}
-
-	if (matchsize !=3D IPT_ALIGN(sizeof(struct ipt_mac_info)))
-		return 0;
-
-	return 1;
-}
-
-static struct ipt_match mac_match =3D {
-	.name		=3D "mac",
-	.match		=3D &match,
-	.checkentry	=3D &ipt_mac_checkentry,
-	.me		=3D THIS_MODULE,
-};
-
-static int __init init(void)
-{
-	return ipt_register_match(&mac_match);
-}
-
-static void __exit fini(void)
-{
-	ipt_unregister_match(&mac_match);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv4/netfilter/ipt_mark.c b/net/ipv4/netfilter/ipt_mark.c
deleted file mode 100644
index 00bef6c..0000000
--- a/net/ipv4/netfilter/ipt_mark.c
+++ /dev/null
@@ -1,71 +0,0 @@
-/* Kernel module to match NFMARK values. */
-
-/* (C) 1999-2001 Marc Boucher <marc@mbsi.ca>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-
-#include <linux/netfilter_ipv4/ipt_mark.h>
-#include <linux/netfilter_ipv4/ip_tables.h>
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Marc Boucher <marc@mbsi.ca>");
-MODULE_DESCRIPTION("iptables mark matching module");
-
-static int
-match(const struct sk_buff *skb,
-      const struct net_device *in,
-      const struct net_device *out,
-      const void *matchinfo,
-      int offset,
-      int *hotdrop)
-{
-	const struct ipt_mark_info *info =3D matchinfo;
-
-	return ((skb->nfmark & info->mask) =3D=3D info->mark) ^ info->invert;
-}
-
-static int
-checkentry(const char *tablename,
-           const struct ipt_ip *ip,
-           void *matchinfo,
-           unsigned int matchsize,
-           unsigned int hook_mask)
-{
-	struct ipt_mark_info *minfo =3D (struct ipt_mark_info *) matchinfo;
-
-	if (matchsize !=3D IPT_ALIGN(sizeof(struct ipt_mark_info)))
-		return 0;
-
-	if (minfo->mark > 0xffffffff || minfo->mask > 0xffffffff) {
-		printk(KERN_WARNING "mark: only supports 32bit mark\n");
-		return 0;
-	}
-
-	return 1;
-}
-
-static struct ipt_match mark_match =3D {
-	.name		=3D "mark",
-	.match		=3D &match,
-	.checkentry	=3D &checkentry,
-	.me		=3D THIS_MODULE,
-};
-
-static int __init init(void)
-{
-	return ipt_register_match(&mark_match);
-}
-
-static void __exit fini(void)
-{
-	ipt_unregister_match(&mark_match);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv4/netfilter/ipt_multiport.c b/net/ipv4/netfilter/ipt_mu=
ltiport.c
index 99e8188..2d52326 100644
--- a/net/ipv4/netfilter/ipt_multiport.c
+++ b/net/ipv4/netfilter/ipt_multiport.c
@@ -97,6 +97,7 @@ match(const struct sk_buff *skb,
       const struct net_device *out,
       const void *matchinfo,
       int offset,
+      unsigned int protoff,
       int *hotdrop)
 {
 	u16 _ports[2], *pptr;
@@ -105,7 +106,7 @@ match(const struct sk_buff *skb,
 	if (offset)
 		return 0;
=20
-	pptr =3D skb_header_pointer(skb, skb->nh.iph->ihl * 4,
+	pptr =3D skb_header_pointer(skb, protoff,
 				  sizeof(_ports), _ports);
 	if (pptr =3D=3D NULL) {
 		/* We've been asked to examine this packet, and we
@@ -128,6 +129,7 @@ match_v1(const struct sk_buff *skb,
 	 const struct net_device *out,
 	 const void *matchinfo,
 	 int offset,
+	 unsigned int protoff,
 	 int *hotdrop)
 {
 	u16 _ports[2], *pptr;
@@ -136,7 +138,7 @@ match_v1(const struct sk_buff *skb,
 	if (offset)
 		return 0;
=20
-	pptr =3D skb_header_pointer(skb, skb->nh.iph->ihl * 4,
+	pptr =3D skb_header_pointer(skb, protoff,
 				  sizeof(_ports), _ports);
 	if (pptr =3D=3D NULL) {
 		/* We've been asked to examine this packet, and we
@@ -154,7 +156,7 @@ match_v1(const struct sk_buff *skb,
 /* Called when user tries to insert an entry of this type. */
 static int
 checkentry(const char *tablename,
-	   const struct ipt_ip *ip,
+	   const void *ip,
 	   void *matchinfo,
 	   unsigned int matchsize,
 	   unsigned int hook_mask)
@@ -164,7 +166,7 @@ checkentry(const char *tablename,
=20
 static int
 checkentry_v1(const char *tablename,
-	      const struct ipt_ip *ip,
+	      const void *ip,
 	      void *matchinfo,
 	      unsigned int matchsize,
 	      unsigned int hook_mask)
diff --git a/net/ipv4/netfilter/ipt_owner.c b/net/ipv4/netfilter/ipt_owner.c
index 0cee286..4843d0c 100644
--- a/net/ipv4/netfilter/ipt_owner.c
+++ b/net/ipv4/netfilter/ipt_owner.c
@@ -27,6 +27,7 @@ match(const struct sk_buff *skb,
       const struct net_device *out,
       const void *matchinfo,
       int offset,
+      unsigned int protoff,
       int *hotdrop)
 {
 	const struct ipt_owner_info *info =3D matchinfo;
@@ -51,7 +52,7 @@ match(const struct sk_buff *skb,
=20
 static int
 checkentry(const char *tablename,
-           const struct ipt_ip *ip,
+           const void *ip,
            void *matchinfo,
            unsigned int matchsize,
            unsigned int hook_mask)
diff --git a/net/ipv4/netfilter/ipt_physdev.c b/net/ipv4/netfilter/ipt_phys=
dev.c
deleted file mode 100644
index 03f5548..0000000
--- a/net/ipv4/netfilter/ipt_physdev.c
+++ /dev/null
@@ -1,135 +0,0 @@
-/* Kernel module to match the bridge port in and
- * out device for IP packets coming into contact with a bridge. */
-
-/* (C) 2001-2003 Bart De Schuymer <bdschuym@pandora.be>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/module.h>
-#include <linux/netdevice.h>
-#include <linux/skbuff.h>
-#include <linux/netfilter_ipv4/ipt_physdev.h>
-#include <linux/netfilter_ipv4/ip_tables.h>
-#include <linux/netfilter_bridge.h>
-#define MATCH   1
-#define NOMATCH 0
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Bart De Schuymer <bdschuym@pandora.be>");
-MODULE_DESCRIPTION("iptables bridge physical device match module");
-
-static int
-match(const struct sk_buff *skb,
-      const struct net_device *in,
-      const struct net_device *out,
-      const void *matchinfo,
-      int offset,
-      int *hotdrop)
-{
-	int i;
-	static const char nulldevname[IFNAMSIZ];
-	const struct ipt_physdev_info *info =3D matchinfo;
-	unsigned int ret;
-	const char *indev, *outdev;
-	struct nf_bridge_info *nf_bridge;
-
-	/* Not a bridged IP packet or no info available yet:
-	 * LOCAL_OUT/mangle and LOCAL_OUT/nat don't know if
-	 * the destination device will be a bridge. */
-	if (!(nf_bridge =3D skb->nf_bridge)) {
-		/* Return MATCH if the invert flags of the used options are on */
-		if ((info->bitmask & IPT_PHYSDEV_OP_BRIDGED) &&
-		    !(info->invert & IPT_PHYSDEV_OP_BRIDGED))
-			return NOMATCH;
-		if ((info->bitmask & IPT_PHYSDEV_OP_ISIN) &&
-		    !(info->invert & IPT_PHYSDEV_OP_ISIN))
-			return NOMATCH;
-		if ((info->bitmask & IPT_PHYSDEV_OP_ISOUT) &&
-		    !(info->invert & IPT_PHYSDEV_OP_ISOUT))
-			return NOMATCH;
-		if ((info->bitmask & IPT_PHYSDEV_OP_IN) &&
-		    !(info->invert & IPT_PHYSDEV_OP_IN))
-			return NOMATCH;
-		if ((info->bitmask & IPT_PHYSDEV_OP_OUT) &&
-		    !(info->invert & IPT_PHYSDEV_OP_OUT))
-			return NOMATCH;
-		return MATCH;
-	}
-
-	/* This only makes sense in the FORWARD and POSTROUTING chains */
-	if ((info->bitmask & IPT_PHYSDEV_OP_BRIDGED) &&
-	    (!!(nf_bridge->mask & BRNF_BRIDGED) ^
-	    !(info->invert & IPT_PHYSDEV_OP_BRIDGED)))
-		return NOMATCH;
-
-	if ((info->bitmask & IPT_PHYSDEV_OP_ISIN &&
-	    (!nf_bridge->physindev ^ !!(info->invert & IPT_PHYSDEV_OP_ISIN))) ||
-	    (info->bitmask & IPT_PHYSDEV_OP_ISOUT &&
-	    (!nf_bridge->physoutdev ^ !!(info->invert & IPT_PHYSDEV_OP_ISOUT))))
-		return NOMATCH;
-
-	if (!(info->bitmask & IPT_PHYSDEV_OP_IN))
-		goto match_outdev;
-	indev =3D nf_bridge->physindev ? nf_bridge->physindev->name : nulldevname;
-	for (i =3D 0, ret =3D 0; i < IFNAMSIZ/sizeof(unsigned int); i++) {
-		ret |=3D (((const unsigned int *)indev)[i]
-			^ ((const unsigned int *)info->physindev)[i])
-			& ((const unsigned int *)info->in_mask)[i];
-	}
-
-	if ((ret =3D=3D 0) ^ !(info->invert & IPT_PHYSDEV_OP_IN))
-		return NOMATCH;
-
-match_outdev:
-	if (!(info->bitmask & IPT_PHYSDEV_OP_OUT))
-		return MATCH;
-	outdev =3D nf_bridge->physoutdev ?
-		 nf_bridge->physoutdev->name : nulldevname;
-	for (i =3D 0, ret =3D 0; i < IFNAMSIZ/sizeof(unsigned int); i++) {
-		ret |=3D (((const unsigned int *)outdev)[i]
-			^ ((const unsigned int *)info->physoutdev)[i])
-			& ((const unsigned int *)info->out_mask)[i];
-	}
-
-	return (ret !=3D 0) ^ !(info->invert & IPT_PHYSDEV_OP_OUT);
-}
-
-static int
-checkentry(const char *tablename,
-		       const struct ipt_ip *ip,
-		       void *matchinfo,
-		       unsigned int matchsize,
-		       unsigned int hook_mask)
-{
-	const struct ipt_physdev_info *info =3D matchinfo;
-
-	if (matchsize !=3D IPT_ALIGN(sizeof(struct ipt_physdev_info)))
-		return 0;
-	if (!(info->bitmask & IPT_PHYSDEV_OP_MASK) ||
-	    info->bitmask & ~IPT_PHYSDEV_OP_MASK)
-		return 0;
-	return 1;
-}
-
-static struct ipt_match physdev_match =3D {
-	.name		=3D "physdev",
-	.match		=3D &match,
-	.checkentry	=3D &checkentry,
-	.me		=3D THIS_MODULE,
-};
-
-static int __init init(void)
-{
-	return ipt_register_match(&physdev_match);
-}
-
-static void __exit fini(void)
-{
-	ipt_unregister_match(&physdev_match);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv4/netfilter/ipt_pkttype.c b/net/ipv4/netfilter/ipt_pktt=
ype.c
deleted file mode 100644
index 8ddb1dc..0000000
--- a/net/ipv4/netfilter/ipt_pkttype.c
+++ /dev/null
@@ -1,70 +0,0 @@
-/* (C) 1999-2001 Michal Ludvig <michal@logix.cz>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/if_ether.h>
-#include <linux/if_packet.h>
-
-#include <linux/netfilter_ipv4/ipt_pkttype.h>
-#include <linux/netfilter_ipv4/ip_tables.h>
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Michal Ludvig <michal@logix.cz>");
-MODULE_DESCRIPTION("IP tables match to match on linklayer packet type");
-
-static int match(const struct sk_buff *skb,
-      const struct net_device *in,
-      const struct net_device *out,
-      const void *matchinfo,
-      int offset,
-      int *hotdrop)
-{
-    const struct ipt_pkttype_info *info =3D matchinfo;
-
-    return (skb->pkt_type =3D=3D info->pkttype) ^ info->invert;
-}
-
-static int checkentry(const char *tablename,
-		   const struct ipt_ip *ip,
-		   void *matchinfo,
-		   unsigned int matchsize,
-		   unsigned int hook_mask)
-{
-/*
-	if (hook_mask
-	    & ~((1 << NF_IP_PRE_ROUTING) | (1 << NF_IP_LOCAL_IN)
-		| (1 << NF_IP_FORWARD))) {
-		printk("ipt_pkttype: only valid for PRE_ROUTING, LOCAL_IN or FORWARD.\n"=
);
-		return 0;
-	}
-*/
-	if (matchsize !=3D IPT_ALIGN(sizeof(struct ipt_pkttype_info)))
-		return 0;
-
-	return 1;
-}
-
-static struct ipt_match pkttype_match =3D {
-	.name		=3D "pkttype",
-	.match		=3D &match,
-	.checkentry	=3D &checkentry,
-	.me		=3D THIS_MODULE,
-};
-
-static int __init init(void)
-{
-	return ipt_register_match(&pkttype_match);
-}
-
-static void __exit fini(void)
-{
-	ipt_unregister_match(&pkttype_match);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv4/netfilter/ipt_realm.c b/net/ipv4/netfilter/ipt_realm.c
deleted file mode 100644
index 54a6897..0000000
--- a/net/ipv4/netfilter/ipt_realm.c
+++ /dev/null
@@ -1,76 +0,0 @@
-/* IP tables module for matching the routing realm
- *
- * $Id: ipt_realm.c,v 1.3 2004/03/05 13:25:40 laforge Exp $
- *
- * (C) 2003 by Sampsa Ranta <sampsa@netsonic.fi>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/netdevice.h>
-#include <net/route.h>
-
-#include <linux/netfilter_ipv4/ipt_realm.h>
-#include <linux/netfilter_ipv4/ip_tables.h>
-
-MODULE_AUTHOR("Sampsa Ranta <sampsa@netsonic.fi>");
-MODULE_LICENSE("GPL");
-MODULE_DESCRIPTION("iptables realm match");
-
-static int
-match(const struct sk_buff *skb,
-      const struct net_device *in,
-      const struct net_device *out,
-      const void *matchinfo,
-      int offset,
-      int *hotdrop)
-{
-	const struct ipt_realm_info *info =3D matchinfo;
-	struct dst_entry *dst =3D skb->dst;
-   =20
-	return (info->id =3D=3D (dst->tclassid & info->mask)) ^ info->invert;
-}
-
-static int check(const char *tablename,
-                 const struct ipt_ip *ip,
-                 void *matchinfo,
-                 unsigned int matchsize,
-                 unsigned int hook_mask)
-{
-	if (hook_mask
-	    & ~((1 << NF_IP_POST_ROUTING) | (1 << NF_IP_FORWARD) |
-	        (1 << NF_IP_LOCAL_OUT) | (1 << NF_IP_LOCAL_IN))) {
-		printk("ipt_realm: only valid for POST_ROUTING, LOCAL_OUT, "
-		       "LOCAL_IN or FORWARD.\n");
-		return 0;
-	}
-	if (matchsize !=3D IPT_ALIGN(sizeof(struct ipt_realm_info))) {
-		printk("ipt_realm: invalid matchsize.\n");
-		return 0;
-	}
-	return 1;
-}
-
-static struct ipt_match realm_match =3D {
-	.name		=3D "realm",
-	.match		=3D match,=20
-	.checkentry	=3D check,
-	.me		=3D THIS_MODULE
-};
-
-static int __init init(void)
-{
-	return ipt_register_match(&realm_match);
-}
-
-static void __exit fini(void)
-{
-	ipt_unregister_match(&realm_match);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv4/netfilter/ipt_recent.c b/net/ipv4/netfilter/ipt_recen=
t.c
index 5ddccb1..44611d6 100644
--- a/net/ipv4/netfilter/ipt_recent.c
+++ b/net/ipv4/netfilter/ipt_recent.c
@@ -104,6 +104,7 @@ match(const struct sk_buff *skb,
       const struct net_device *out,
       const void *matchinfo,
       int offset,
+      unsigned int protoff,
       int *hotdrop);
=20
 /* Function to hash a given address into the hash table of table_size size=
 */
@@ -317,7 +318,7 @@ static int ip_recent_ctrl(struct file *f
 	skb->nh.iph->daddr =3D 0;
 	/* Clear ttl since we have no way of knowing it */
 	skb->nh.iph->ttl =3D 0;
-	match(skb,NULL,NULL,info,0,NULL);
+	match(skb,NULL,NULL,info,0,0,NULL);
=20
 	kfree(skb->nh.iph);
 out_free_skb:
@@ -357,6 +358,7 @@ match(const struct sk_buff *skb,
       const struct net_device *out,
       const void *matchinfo,
       int offset,
+      unsigned int protoff,
       int *hotdrop)
 {
 	int pkt_count, hits_found, ans;
@@ -654,7 +656,7 @@ match(const struct sk_buff *skb,
  */
 static int
 checkentry(const char *tablename,
-           const struct ipt_ip *ip,
+           const void *ip,
            void *matchinfo,
            unsigned int matchsize,
            unsigned int hook_mask)
diff --git a/net/ipv4/netfilter/ipt_sctp.c b/net/ipv4/netfilter/ipt_sctp.c
deleted file mode 100644
index fe2b327..0000000
--- a/net/ipv4/netfilter/ipt_sctp.c
+++ /dev/null
@@ -1,203 +0,0 @@
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <net/ip.h>
-#include <linux/sctp.h>
-
-#include <linux/netfilter_ipv4/ip_tables.h>
-#include <linux/netfilter_ipv4/ipt_sctp.h>
-
-#ifdef DEBUG_SCTP
-#define duprintf(format, args...) printk(format , ## args)
-#else
-#define duprintf(format, args...)
-#endif
-
-#define SCCHECK(cond, option, flag, invflag) (!((flag) & (option)) \
-					      || (!!((invflag) & (option)) ^ (cond)))
-
-static int
-match_flags(const struct ipt_sctp_flag_info *flag_info,
-	    const int flag_count,
-	    u_int8_t chunktype,
-	    u_int8_t chunkflags)
-{
-	int i;
-
-	for (i =3D 0; i < flag_count; i++) {
-		if (flag_info[i].chunktype =3D=3D chunktype) {
-			return (chunkflags & flag_info[i].flag_mask) =3D=3D flag_info[i].flag;
-		}
-	}
-
-	return 1;
-}
-
-static int
-match_packet(const struct sk_buff *skb,
-	     const u_int32_t *chunkmap,
-	     int chunk_match_type,
-	     const struct ipt_sctp_flag_info *flag_info,
-	     const int flag_count,
-	     int *hotdrop)
-{
-	int offset;
-	u_int32_t chunkmapcopy[256 / sizeof (u_int32_t)];
-	sctp_chunkhdr_t _sch, *sch;
-
-#ifdef DEBUG_SCTP
-	int i =3D 0;
-#endif
-
-	if (chunk_match_type =3D=3D SCTP_CHUNK_MATCH_ALL) {
-		SCTP_CHUNKMAP_COPY(chunkmapcopy, chunkmap);
-	}
-
-	offset =3D skb->nh.iph->ihl * 4 + sizeof (sctp_sctphdr_t);
-	do {
-		sch =3D skb_header_pointer(skb, offset, sizeof(_sch), &_sch);
-		if (sch =3D=3D NULL) {
-			duprintf("Dropping invalid SCTP packet.\n");
-			*hotdrop =3D 1;
-			return 0;
-        	}
-
-		duprintf("Chunk num: %d\toffset: %d\ttype: %d\tlength: %d\tflags: %x\n",=
=20
-				++i, offset, sch->type, htons(sch->length), sch->flags);
-
-		offset +=3D (htons(sch->length) + 3) & ~3;
-
-		duprintf("skb->len: %d\toffset: %d\n", skb->len, offset);
-
-		if (SCTP_CHUNKMAP_IS_SET(chunkmap, sch->type)) {
-			switch (chunk_match_type) {
-			case SCTP_CHUNK_MATCH_ANY:
-				if (match_flags(flag_info, flag_count,=20
-					sch->type, sch->flags)) {
-					return 1;
-				}
-				break;
-
-			case SCTP_CHUNK_MATCH_ALL:
-				if (match_flags(flag_info, flag_count,=20
-					sch->type, sch->flags)) {
-					SCTP_CHUNKMAP_CLEAR(chunkmapcopy, sch->type);
-				}
-				break;
-
-			case SCTP_CHUNK_MATCH_ONLY:
-				if (!match_flags(flag_info, flag_count,=20
-					sch->type, sch->flags)) {
-					return 0;
-				}
-				break;
-			}
-		} else {
-			switch (chunk_match_type) {
-			case SCTP_CHUNK_MATCH_ONLY:
-				return 0;
-			}
-		}
-	} while (offset < skb->len);
-
-	switch (chunk_match_type) {
-	case SCTP_CHUNK_MATCH_ALL:
-		return SCTP_CHUNKMAP_IS_CLEAR(chunkmap);
-	case SCTP_CHUNK_MATCH_ANY:
-		return 0;
-	case SCTP_CHUNK_MATCH_ONLY:
-		return 1;
-	}
-
-	/* This will never be reached, but required to stop compiler whine */
-	return 0;
-}
-
-static int
-match(const struct sk_buff *skb,
-      const struct net_device *in,
-      const struct net_device *out,
-      const void *matchinfo,
-      int offset,
-      int *hotdrop)
-{
-	const struct ipt_sctp_info *info;
-	sctp_sctphdr_t _sh, *sh;
-
-	info =3D (const struct ipt_sctp_info *)matchinfo;
-
-	if (offset) {
-		duprintf("Dropping non-first fragment.. FIXME\n");
-		return 0;
-	}
-=09
-	sh =3D skb_header_pointer(skb, skb->nh.iph->ihl*4, sizeof(_sh), &_sh);
-	if (sh =3D=3D NULL) {
-		duprintf("Dropping evil TCP offset=3D0 tinygram.\n");
-		*hotdrop =3D 1;
-		return 0;
-       	}
-	duprintf("spt: %d\tdpt: %d\n", ntohs(sh->source), ntohs(sh->dest));
-
-	return  SCCHECK(((ntohs(sh->source) >=3D info->spts[0])=20
-			&& (ntohs(sh->source) <=3D info->spts[1])),=20
-		   	IPT_SCTP_SRC_PORTS, info->flags, info->invflags)
-		&& SCCHECK(((ntohs(sh->dest) >=3D info->dpts[0])=20
-			&& (ntohs(sh->dest) <=3D info->dpts[1])),=20
-			IPT_SCTP_DEST_PORTS, info->flags, info->invflags)
-		&& SCCHECK(match_packet(skb, info->chunkmap, info->chunk_match_type,
- 					info->flag_info, info->flag_count,=20
-					hotdrop),
-			   IPT_SCTP_CHUNK_TYPES, info->flags, info->invflags);
-}
-
-static int
-checkentry(const char *tablename,
-	   const struct ipt_ip *ip,
-	   void *matchinfo,
-	   unsigned int matchsize,
-	   unsigned int hook_mask)
-{
-	const struct ipt_sctp_info *info;
-
-	info =3D (const struct ipt_sctp_info *)matchinfo;
-
-	return ip->proto =3D=3D IPPROTO_SCTP
-		&& !(ip->invflags & IPT_INV_PROTO)
-		&& matchsize =3D=3D IPT_ALIGN(sizeof(struct ipt_sctp_info))
-		&& !(info->flags & ~IPT_SCTP_VALID_FLAGS)
-		&& !(info->invflags & ~IPT_SCTP_VALID_FLAGS)
-		&& !(info->invflags & ~info->flags)
-		&& ((!(info->flags & IPT_SCTP_CHUNK_TYPES)) ||=20
-			(info->chunk_match_type &
-				(SCTP_CHUNK_MATCH_ALL=20
-				| SCTP_CHUNK_MATCH_ANY
-				| SCTP_CHUNK_MATCH_ONLY)));
-}
-
-static struct ipt_match sctp_match =3D=20
-{=20
-	.list =3D { NULL, NULL},
-	.name =3D "sctp",
-	.match =3D &match,
-	.checkentry =3D &checkentry,
-	.destroy =3D NULL,
-	.me =3D THIS_MODULE
-};
-
-static int __init init(void)
-{
-	return ipt_register_match(&sctp_match);
-}
-
-static void __exit fini(void)
-{
-	ipt_unregister_match(&sctp_match);
-}
-
-module_init(init);
-module_exit(fini);
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Kiran Kumar Immidi");
-MODULE_DESCRIPTION("Match for SCTP protocol packets");
-
diff --git a/net/ipv4/netfilter/ipt_state.c b/net/ipv4/netfilter/ipt_state.c
deleted file mode 100644
index 4d7f16b..0000000
--- a/net/ipv4/netfilter/ipt_state.c
+++ /dev/null
@@ -1,74 +0,0 @@
-/* Kernel module to match connection tracking information. */
-
-/* (C) 1999-2001 Paul `Rusty' Russell
- * (C) 2002-2004 Netfilter Core Team <coreteam@netfilter.org>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <net/netfilter/nf_conntrack_compat.h>
-#include <linux/netfilter_ipv4/ip_tables.h>
-#include <linux/netfilter_ipv4/ipt_state.h>
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Rusty Russell <rusty@rustcorp.com.au>");
-MODULE_DESCRIPTION("iptables connection tracking state match module");
-
-static int
-match(const struct sk_buff *skb,
-      const struct net_device *in,
-      const struct net_device *out,
-      const void *matchinfo,
-      int offset,
-      int *hotdrop)
-{
-	const struct ipt_state_info *sinfo =3D matchinfo;
-	enum ip_conntrack_info ctinfo;
-	unsigned int statebit;
-
-	if (nf_ct_is_untracked(skb))
-		statebit =3D IPT_STATE_UNTRACKED;
-	else if (!nf_ct_get_ctinfo(skb, &ctinfo))
-		statebit =3D IPT_STATE_INVALID;
-	else
-		statebit =3D IPT_STATE_BIT(ctinfo);
-
-	return (sinfo->statemask & statebit);
-}
-
-static int check(const char *tablename,
-		 const struct ipt_ip *ip,
-		 void *matchinfo,
-		 unsigned int matchsize,
-		 unsigned int hook_mask)
-{
-	if (matchsize !=3D IPT_ALIGN(sizeof(struct ipt_state_info)))
-		return 0;
-
-	return 1;
-}
-
-static struct ipt_match state_match =3D {
-	.name		=3D "state",
-	.match		=3D &match,
-	.checkentry	=3D &check,
-	.me		=3D THIS_MODULE,
-};
-
-static int __init init(void)
-{
-	need_ip_conntrack();
-	return ipt_register_match(&state_match);
-}
-
-static void __exit fini(void)
-{
-	ipt_unregister_match(&state_match);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv4/netfilter/ipt_string.c b/net/ipv4/netfilter/ipt_strin=
g.c
deleted file mode 100644
index b5def20..0000000
--- a/net/ipv4/netfilter/ipt_string.c
+++ /dev/null
@@ -1,91 +0,0 @@
-/* String matching match for iptables
- *=20
- * (C) 2005 Pablo Neira Ayuso <pablo@eurodev.net>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/init.h>
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/skbuff.h>
-#include <linux/netfilter_ipv4/ip_tables.h>
-#include <linux/netfilter_ipv4/ipt_string.h>
-#include <linux/textsearch.h>
-
-MODULE_AUTHOR("Pablo Neira Ayuso <pablo@eurodev.net>");
-MODULE_DESCRIPTION("IP tables string match module");
-MODULE_LICENSE("GPL");
-
-static int match(const struct sk_buff *skb,
-		 const struct net_device *in,
-		 const struct net_device *out,
-		 const void *matchinfo,
-		 int offset,
-		 int *hotdrop)
-{
-	struct ts_state state;
-	struct ipt_string_info *conf =3D (struct ipt_string_info *) matchinfo;
-
-	memset(&state, 0, sizeof(struct ts_state));
-
-	return (skb_find_text((struct sk_buff *)skb, conf->from_offset,=20
-			     conf->to_offset, conf->config, &state)=20
-			     !=3D UINT_MAX) && !conf->invert;
-}
-
-#define STRING_TEXT_PRIV(m) ((struct ipt_string_info *) m)
-
-static int checkentry(const char *tablename,
-		      const struct ipt_ip *ip,
-		      void *matchinfo,
-		      unsigned int matchsize,
-		      unsigned int hook_mask)
-{
-	struct ipt_string_info *conf =3D matchinfo;
-	struct ts_config *ts_conf;
-
-	if (matchsize !=3D IPT_ALIGN(sizeof(struct ipt_string_info)))
-		return 0;
-
-	/* Damn, can't handle this case properly with iptables... */
-	if (conf->from_offset > conf->to_offset)
-		return 0;
-
-	ts_conf =3D textsearch_prepare(conf->algo, conf->pattern, conf->patlen,
-				     GFP_KERNEL, TS_AUTOLOAD);
-	if (IS_ERR(ts_conf))
-		return 0;
-
-	conf->config =3D ts_conf;
-
-	return 1;
-}
-
-static void destroy(void *matchinfo, unsigned int matchsize)
-{
-	textsearch_destroy(STRING_TEXT_PRIV(matchinfo)->config);
-}
-
-static struct ipt_match string_match =3D {
-	.name 		=3D "string",
-	.match 		=3D match,
-	.checkentry	=3D checkentry,
-	.destroy 	=3D destroy,
-	.me 		=3D THIS_MODULE
-};
-
-static int __init init(void)
-{
-	return ipt_register_match(&string_match);
-}
-
-static void __exit fini(void)
-{
-	ipt_unregister_match(&string_match);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv4/netfilter/ipt_tcpmss.c b/net/ipv4/netfilter/ipt_tcpms=
s.c
deleted file mode 100644
index 4dc9b16..0000000
--- a/net/ipv4/netfilter/ipt_tcpmss.c
+++ /dev/null
@@ -1,127 +0,0 @@
-/* Kernel module to match TCP MSS values. */
-
-/* Copyright (C) 2000 Marc Boucher <marc@mbsi.ca>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <net/tcp.h>
-
-#include <linux/netfilter_ipv4/ipt_tcpmss.h>
-#include <linux/netfilter_ipv4/ip_tables.h>
-
-#define TH_SYN 0x02
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Marc Boucher <marc@mbsi.ca>");
-MODULE_DESCRIPTION("iptables TCP MSS match module");
-
-/* Returns 1 if the mss option is set and matched by the range, 0 otherwis=
e */
-static inline int
-mssoption_match(u_int16_t min, u_int16_t max,
-		const struct sk_buff *skb,
-		int invert,
-		int *hotdrop)
-{
-	struct tcphdr _tcph, *th;
-	/* tcp.doff is only 4 bits, ie. max 15 * 4 bytes */
-	u8 _opt[15 * 4 - sizeof(_tcph)], *op;
-	unsigned int i, optlen;
-
-	/* If we don't have the whole header, drop packet. */
-	th =3D skb_header_pointer(skb, skb->nh.iph->ihl * 4,
-				sizeof(_tcph), &_tcph);
-	if (th =3D=3D NULL)
-		goto dropit;
-
-	/* Malformed. */
-	if (th->doff*4 < sizeof(*th))
-		goto dropit;
-
-	optlen =3D th->doff*4 - sizeof(*th);
-	if (!optlen)
-		goto out;
-
-	/* Truncated options. */
-	op =3D skb_header_pointer(skb, skb->nh.iph->ihl * 4 + sizeof(*th),
-				optlen, _opt);
-	if (op =3D=3D NULL)
-		goto dropit;
-
-	for (i =3D 0; i < optlen; ) {
-		if (op[i] =3D=3D TCPOPT_MSS
-		    && (optlen - i) >=3D TCPOLEN_MSS
-		    && op[i+1] =3D=3D TCPOLEN_MSS) {
-			u_int16_t mssval;
-
-			mssval =3D (op[i+2] << 8) | op[i+3];
-		=09
-			return (mssval >=3D min && mssval <=3D max) ^ invert;
-		}
-		if (op[i] < 2) i++;
-		else i +=3D op[i+1]?:1;
-	}
-out:
-	return invert;
-
- dropit:
-	*hotdrop =3D 1;
-	return 0;
-}
-
-static int
-match(const struct sk_buff *skb,
-      const struct net_device *in,
-      const struct net_device *out,
-      const void *matchinfo,
-      int offset,
-      int *hotdrop)
-{
-	const struct ipt_tcpmss_match_info *info =3D matchinfo;
-
-	return mssoption_match(info->mss_min, info->mss_max, skb,
-			       info->invert, hotdrop);
-}
-
-static int
-checkentry(const char *tablename,
-           const struct ipt_ip *ip,
-           void *matchinfo,
-           unsigned int matchsize,
-           unsigned int hook_mask)
-{
-	if (matchsize !=3D IPT_ALIGN(sizeof(struct ipt_tcpmss_match_info)))
-		return 0;
-
-	/* Must specify -p tcp */
-	if (ip->proto !=3D IPPROTO_TCP || (ip->invflags & IPT_INV_PROTO)) {
-		printk("tcpmss: Only works on TCP packets\n");
-		return 0;
-	}
-
-	return 1;
-}
-
-static struct ipt_match tcpmss_match =3D {
-	.name		=3D "tcpmss",
-	.match		=3D &match,
-	.checkentry	=3D &checkentry,
-	.me		=3D THIS_MODULE,
-};
-
-static int __init init(void)
-{
-	return ipt_register_match(&tcpmss_match);
-}
-
-static void __exit fini(void)
-{
-	ipt_unregister_match(&tcpmss_match);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv4/netfilter/ipt_tos.c b/net/ipv4/netfilter/ipt_tos.c
index 086a1bb..9ab765e 100644
--- a/net/ipv4/netfilter/ipt_tos.c
+++ b/net/ipv4/netfilter/ipt_tos.c
@@ -23,6 +23,7 @@ match(const struct sk_buff *skb,
       const struct net_device *out,
       const void *matchinfo,
       int offset,
+      unsigned int protoff,
       int *hotdrop)
 {
 	const struct ipt_tos_info *info =3D matchinfo;
@@ -32,7 +33,7 @@ match(const struct sk_buff *skb,
=20
 static int
 checkentry(const char *tablename,
-           const struct ipt_ip *ip,
+           const void *ip,
            void *matchinfo,
            unsigned int matchsize,
            unsigned int hook_mask)
diff --git a/net/ipv4/netfilter/ipt_ttl.c b/net/ipv4/netfilter/ipt_ttl.c
index 219aa9d..82da53f 100644
--- a/net/ipv4/netfilter/ipt_ttl.c
+++ b/net/ipv4/netfilter/ipt_ttl.c
@@ -21,7 +21,7 @@ MODULE_LICENSE("GPL");
=20
 static int match(const struct sk_buff *skb, const struct net_device *in,
 		 const struct net_device *out, const void *matchinfo,
-		 int offset, int *hotdrop)
+		 int offset, unsigned int protoff, int *hotdrop)
 {
 	const struct ipt_ttl_info *info =3D matchinfo;
=20
@@ -47,7 +47,7 @@ static int match(const struct sk_buff *s
 	return 0;
 }
=20
-static int checkentry(const char *tablename, const struct ipt_ip *ip,
+static int checkentry(const char *tablename, const void  *ip,
 		      void *matchinfo, unsigned int matchsize,
 		      unsigned int hook_mask)
 {
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptab=
le_filter.c
index 260a4f0..212a307 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -78,7 +78,8 @@ static struct ipt_table packet_filter =3D=20
 	.name		=3D "filter",
 	.valid_hooks	=3D FILTER_VALID_HOOKS,
 	.lock		=3D RW_LOCK_UNLOCKED,
-	.me		=3D THIS_MODULE
+	.me		=3D THIS_MODULE,
+	.af		=3D AF_INET,
 };
=20
 /* The work comes in here from netfilter.c. */
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptab=
le_mangle.c
index 160eb11..3212a5c 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -109,6 +109,7 @@ static struct ipt_table packet_mangler =3D
 	.valid_hooks	=3D MANGLE_VALID_HOOKS,
 	.lock		=3D RW_LOCK_UNLOCKED,
 	.me		=3D THIS_MODULE,
+	.af		=3D AF_INET,
 };
=20
 /* The work comes in here from netfilter.c. */
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_=
raw.c
index 47449ba..fdb9e9c 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -83,7 +83,8 @@ static struct ipt_table packet_raw =3D {=20
 	.name =3D "raw",=20
 	.valid_hooks =3D  RAW_VALID_HOOKS,=20
 	.lock =3D RW_LOCK_UNLOCKED,=20
-	.me =3D THIS_MODULE
+	.me =3D THIS_MODULE,
+	.af =3D AF_INET,
 };
=20
 /* The work comes in here from netfilter.c. */
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netf=
ilter/nf_conntrack_l3proto_ipv4.c
index 0c56c52..167619f 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -575,7 +575,7 @@ MODULE_LICENSE("GPL");
=20
 static int __init init(void)
 {
-	need_nf_conntrack();
+	need_conntrack();
 	return init_or_cleanup(1);
 }
=20
@@ -587,9 +587,4 @@ static void __exit fini(void)
 module_init(init);
 module_exit(fini);
=20
-void need_ip_conntrack(void)
-{
-}
-
-EXPORT_SYMBOL(need_ip_conntrack);
 EXPORT_SYMBOL(nf_ct_ipv4_gather_frags);
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 105dd69..2d6f8ec 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -41,6 +41,7 @@ config IP6_NF_QUEUE
=20
 config IP6_NF_IPTABLES
 	tristate "IP6 tables support (required for filtering/masq/NAT)"
+	depends on NETFILTER_XTABLES
 	help
 	  ip6tables is a general, extensible packet identification framework.
 	  Currently only the packet filtering and packet mangling subsystem
@@ -50,25 +51,6 @@ config IP6_NF_IPTABLES
 	  To compile it as a module, choose M here.  If unsure, say N.
=20
 # The simple matches.
-config IP6_NF_MATCH_LIMIT
-	tristate "limit match support"
-	depends on IP6_NF_IPTABLES
-	help
-	  limit matching allows you to control the rate at which a rule can be
-	  matched: mainly useful in combination with the LOG target ("LOG
-	  target support", below) and to avoid some Denial of Service attacks.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
-config IP6_NF_MATCH_MAC
-	tristate "MAC address match support"
-	depends on IP6_NF_IPTABLES
-	help
-	  mac matching allows you to match packets based on the source
-	  Ethernet address of the packet.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 config IP6_NF_MATCH_RT
 	tristate "Routing header match support"
 	depends on IP6_NF_IPTABLES
@@ -124,16 +106,6 @@ config IP6_NF_MATCH_OWNER
=20
 	  To compile it as a module, choose M here.  If unsure, say N.
=20
-config IP6_NF_MATCH_MARK
-	tristate "netfilter MARK match support"
-	depends on IP6_NF_IPTABLES
-	help
-	  Netfilter mark matching allows you to match packets based on the
-	  `nfmark' value in the packet.  This can be set by the MARK target
-	  (see below).
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 config IP6_NF_MATCH_IPV6HEADER
 	tristate "IPv6 Extension Headers Match"
 	depends on IP6_NF_IPTABLES
@@ -151,15 +123,6 @@ config IP6_NF_MATCH_AHESP
=20
 	  To compile it as a module, choose M here.  If unsure, say N.
=20
-config IP6_NF_MATCH_LENGTH
-	tristate "Packet Length match support"
-	depends on IP6_NF_IPTABLES
-	help
-	  This option allows you to match the length of a packet against a
-	  specific value or range of values.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 config IP6_NF_MATCH_EUI64
 	tristate "EUI64 address check"
 	depends on IP6_NF_IPTABLES
@@ -170,15 +133,6 @@ config IP6_NF_MATCH_EUI64
=20
 	  To compile it as a module, choose M here.  If unsure, say N.
=20
-config IP6_NF_MATCH_PHYSDEV
-	tristate "Physdev match support"
-	depends on IP6_NF_IPTABLES && BRIDGE_NETFILTER
-	help
-	  Physdev packet matching matches against the physical bridge ports
-	  the IP packet arrived on or will leave by.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 config IP6_NF_MATCH_POLICY
 	tristate "IPsec policy match support"
 	depends on IP6_NF_IPTABLES && XFRM
@@ -219,17 +173,6 @@ config IP6_NF_TARGET_REJECT
=20
 	  To compile it as a module, choose M here.  If unsure, say N.
=20
-config IP6_NF_TARGET_NFQUEUE
-	tristate "NFQUEUE Target Support"
-	depends on IP6_NF_IPTABLES
-	help
-	  This Target replaced the old obsolete QUEUE target.
-
-	  As opposed to QUEUE, it supports 65535 different queues,
-	  not just one.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 config IP6_NF_MANGLE
 	tristate "Packet mangling"
 	depends on IP6_NF_IPTABLES
@@ -240,19 +183,6 @@ config IP6_NF_MANGLE
=20
 	  To compile it as a module, choose M here.  If unsure, say N.
=20
-config IP6_NF_TARGET_MARK
-	tristate "MARK target support"
-	depends on IP6_NF_MANGLE
-	help
-	  This option adds a `MARK' target, which allows you to create rules
-	  in the `mangle' table which alter the netfilter mark (nfmark) field
-	  associated with the packet packet prior to routing. This can change
-	  the routing method (see `Use netfilter MARK value as routing
-	  key') and can also be used by other subsystems to change their
-	  behavior.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 config IP6_NF_TARGET_HL
 	tristate  'HL (hoplimit) target support'
 	depends on IP6_NF_MANGLE
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index c0c809b..663b474 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -4,10 +4,7 @@
=20
 # Link order matters here.
 obj-$(CONFIG_IP6_NF_IPTABLES) +=3D ip6_tables.o
-obj-$(CONFIG_IP6_NF_MATCH_LIMIT) +=3D ip6t_limit.o
-obj-$(CONFIG_IP6_NF_MATCH_MARK) +=3D ip6t_mark.o
 obj-$(CONFIG_IP6_NF_MATCH_LENGTH) +=3D ip6t_length.o
-obj-$(CONFIG_IP6_NF_MATCH_MAC) +=3D ip6t_mac.o
 obj-$(CONFIG_IP6_NF_MATCH_RT) +=3D ip6t_rt.o
 obj-$(CONFIG_IP6_NF_MATCH_OPTS) +=3D ip6t_hbh.o ip6t_dst.o
 obj-$(CONFIG_IP6_NF_MATCH_IPV6HEADER) +=3D ip6t_ipv6header.o
@@ -17,12 +14,9 @@ obj-$(CONFIG_IP6_NF_MATCH_POLICY) +=3D ip6
 obj-$(CONFIG_IP6_NF_MATCH_EUI64) +=3D ip6t_eui64.o
 obj-$(CONFIG_IP6_NF_MATCH_MULTIPORT) +=3D ip6t_multiport.o
 obj-$(CONFIG_IP6_NF_MATCH_OWNER) +=3D ip6t_owner.o
-obj-$(CONFIG_IP6_NF_MATCH_PHYSDEV) +=3D ip6t_physdev.o
 obj-$(CONFIG_IP6_NF_FILTER) +=3D ip6table_filter.o
 obj-$(CONFIG_IP6_NF_MANGLE) +=3D ip6table_mangle.o
-obj-$(CONFIG_IP6_NF_TARGET_MARK) +=3D ip6t_MARK.o
 obj-$(CONFIG_IP6_NF_TARGET_HL) +=3D ip6t_HL.o
-obj-$(CONFIG_IP6_NF_TARGET_NFQUEUE) +=3D ip6t_NFQUEUE.o
 obj-$(CONFIG_IP6_NF_QUEUE) +=3D ip6_queue.o
 obj-$(CONFIG_IP6_NF_TARGET_LOG) +=3D ip6t_LOG.o
 obj-$(CONFIG_IP6_NF_RAW) +=3D ip6table_raw.o
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_table=
s.c
index 1390370..847068f 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -13,6 +13,9 @@
  * 	  a table
  * 06 Jun 2002 Andras Kis-Szabo <kisza@sch.bme.hu>
  *      - new extension header parser code
+ * 15 Oct 2005 Harald Welte <laforge@netfilter.org>
+ * 	- Unification of {ip,ip6}_tables into x_tables
+ * 	- Removed tcp and udp code, since it's not ipv6 specific
  */
=20
 #include <linux/capability.h>
@@ -23,8 +26,6 @@
 #include <linux/vmalloc.h>
 #include <linux/netdevice.h>
 #include <linux/module.h>
-#include <linux/tcp.h>
-#include <linux/udp.h>
 #include <linux/icmpv6.h>
 #include <net/ipv6.h>
 #include <asm/uaccess.h>
@@ -33,6 +34,7 @@
 #include <linux/cpumask.h>
=20
 #include <linux/netfilter_ipv6/ip6_tables.h>
+#include <linux/netfilter/x_tables.h>
=20
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
@@ -67,13 +69,8 @@ do {								\
 #else
 #define IP_NF_ASSERT(x)
 #endif
-#define SMP_ALIGN(x) (((x) + SMP_CACHE_BYTES-1) & ~(SMP_CACHE_BYTES-1))
=20
-static DECLARE_MUTEX(ip6t_mutex);
=20
-/* Must have mutex */
-#define ASSERT_READ_LOCK(x) IP_NF_ASSERT(down_trylock(&ip6t_mutex) !=3D 0)
-#define ASSERT_WRITE_LOCK(x) IP_NF_ASSERT(down_trylock(&ip6t_mutex) !=3D 0)
 #include <linux/netfilter_ipv4/listhelp.h>
=20
 #if 0
@@ -91,30 +88,6 @@ static DECLARE_MUTEX(ip6t_mutex);
=20
    Hence the start of any table is given by get_table() below.  */
=20
-/* The table itself */
-struct ip6t_table_info
-{
-	/* Size per table */
-	unsigned int size;
-	/* Number of entries: FIXME. --RR */
-	unsigned int number;
-	/* Initial number of entries. Needed for module usage count */
-	unsigned int initial_entries;
-
-	/* Entry points and underflows */
-	unsigned int hook_entry[NF_IP6_NUMHOOKS];
-	unsigned int underflow[NF_IP6_NUMHOOKS];
-
-	/* ip6t_entry tables: one per CPU */
-	void *entries[NR_CPUS];
-};
-
-static LIST_HEAD(ip6t_target);
-static LIST_HEAD(ip6t_match);
-static LIST_HEAD(ip6t_tables);
-#define SET_COUNTER(c,b,p) do { (c).bcnt =3D (b); (c).pcnt =3D (p); } whil=
e(0)
-#define ADD_COUNTER(c,b,p) do { (c).bcnt +=3D (b); (c).pcnt +=3D (p); } wh=
ile(0)
-
 #if 0
 #define down(x) do { printk("DOWN:%u:" #x "\n", __LINE__); down(x); } whil=
e(0)
 #define down_interruptible(x) ({ int __r; printk("DOWNi:%u:" #x "\n", __LI=
NE__); __r =3D down_interruptible(x); if (__r !=3D 0) printk("ABORT-DOWNi:%=
u\n", __LINE__); __r; })
@@ -297,7 +270,7 @@ ip6t_do_table(struct sk_buff **pskb,
 	      unsigned int hook,
 	      const struct net_device *in,
 	      const struct net_device *out,
-	      struct ip6t_table *table,
+	      struct xt_table *table,
 	      void *userdata)
 {
 	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(lon=
g))));
@@ -309,6 +282,7 @@ ip6t_do_table(struct sk_buff **pskb,
 	const char *indev, *outdev;
 	void *table_base;
 	struct ip6t_entry *e, *back;
+	struct xt_table_info *private;
=20
 	/* Initialization */
 	indev =3D in ? in->name : nulldevname;
@@ -321,9 +295,10 @@ ip6t_do_table(struct sk_buff **pskb,
 	 * match it. */
=20
 	read_lock_bh(&table->lock);
+	private =3D table->private;
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
-	table_base =3D (void *)table->private->entries[smp_processor_id()];
-	e =3D get_entry(table_base, table->private->hook_entry[hook]);
+	table_base =3D (void *)private->entries[smp_processor_id()];
+	e =3D get_entry(table_base, private->hook_entry[hook]);
=20
 #ifdef CONFIG_NETFILTER_DEBUG
 	/* Check noone else using our table */
@@ -339,7 +314,7 @@ ip6t_do_table(struct sk_buff **pskb,
 #endif
=20
 	/* For return from builtin chain */
-	back =3D get_entry(table_base, table->private->underflow[hook]);
+	back =3D get_entry(table_base, private->underflow[hook]);
=20
 	do {
 		IP_NF_ASSERT(e);
@@ -439,145 +414,6 @@ ip6t_do_table(struct sk_buff **pskb,
 #endif
 }
=20
-/*
- * These are weird, but module loading must not be done with mutex
- * held (since they will register), and we have to have a single
- * function to use try_then_request_module().
- */
-
-/* Find table by name, grabs mutex & ref.  Returns ERR_PTR() on error. */
-static inline struct ip6t_table *find_table_lock(const char *name)
-{
-	struct ip6t_table *t;
-
-	if (down_interruptible(&ip6t_mutex) !=3D 0)
-		return ERR_PTR(-EINTR);
-
-	list_for_each_entry(t, &ip6t_tables, list)
-		if (strcmp(t->name, name) =3D=3D 0 && try_module_get(t->me))
-			return t;
-	up(&ip6t_mutex);
-	return NULL;
-}
-
-/* Find match, grabs ref.  Returns ERR_PTR() on error. */
-static inline struct ip6t_match *find_match(const char *name, u8 revision)
-{
-	struct ip6t_match *m;
-	int err =3D 0;
-
-	if (down_interruptible(&ip6t_mutex) !=3D 0)
-		return ERR_PTR(-EINTR);
-
-	list_for_each_entry(m, &ip6t_match, list) {
-		if (strcmp(m->name, name) =3D=3D 0) {
-			if (m->revision =3D=3D revision) {
-				if (try_module_get(m->me)) {
-					up(&ip6t_mutex);
-					return m;
-				}
-			} else
-				err =3D -EPROTOTYPE; /* Found something. */
-		}
-	}
-	up(&ip6t_mutex);
-	return ERR_PTR(err);
-}
-
-/* Find target, grabs ref.  Returns ERR_PTR() on error. */
-static inline struct ip6t_target *find_target(const char *name, u8 revisio=
n)
-{
-	struct ip6t_target *t;
-	int err =3D 0;
-
-	if (down_interruptible(&ip6t_mutex) !=3D 0)
-		return ERR_PTR(-EINTR);
-
-	list_for_each_entry(t, &ip6t_target, list) {
-		if (strcmp(t->name, name) =3D=3D 0) {
-			if (t->revision =3D=3D revision) {
-				if (try_module_get(t->me)) {
-					up(&ip6t_mutex);
-					return t;
-				}
-			} else
-				err =3D -EPROTOTYPE; /* Found something. */
-		}
-	}
-	up(&ip6t_mutex);
-	return ERR_PTR(err);
-}
-
-struct ip6t_target *ip6t_find_target(const char *name, u8 revision)
-{
-	struct ip6t_target *target;
-
-	target =3D try_then_request_module(find_target(name, revision),
-					 "ip6t_%s", name);
-	if (IS_ERR(target) || !target)
-		return NULL;
-	return target;
-}
-
-static int match_revfn(const char *name, u8 revision, int *bestp)
-{
-	struct ip6t_match *m;
-	int have_rev =3D 0;
-
-	list_for_each_entry(m, &ip6t_match, list) {
-		if (strcmp(m->name, name) =3D=3D 0) {
-			if (m->revision > *bestp)
-				*bestp =3D m->revision;
-			if (m->revision =3D=3D revision)
-				have_rev =3D 1;
-		}
-	}
-	return have_rev;
-}
-
-static int target_revfn(const char *name, u8 revision, int *bestp)
-{
-	struct ip6t_target *t;
-	int have_rev =3D 0;
-
-	list_for_each_entry(t, &ip6t_target, list) {
-		if (strcmp(t->name, name) =3D=3D 0) {
-			if (t->revision > *bestp)
-				*bestp =3D t->revision;
-			if (t->revision =3D=3D revision)
-				have_rev =3D 1;
-		}
-	}
-	return have_rev;
-}
-
-/* Returns true or fals (if no such extension at all) */
-static inline int find_revision(const char *name, u8 revision,
-				int (*revfn)(const char *, u8, int *),
-				int *err)
-{
-	int have_rev, best =3D -1;
-
-	if (down_interruptible(&ip6t_mutex) !=3D 0) {
-		*err =3D -EINTR;
-		return 1;
-	}
-	have_rev =3D revfn(name, revision, &best);
-	up(&ip6t_mutex);
-
-	/* Nothing at all?  Return 0 to try loading module. */
-	if (best =3D=3D -1) {
-		*err =3D -ENOENT;
-		return 0;
-	}
-
-	*err =3D best;
-	if (!have_rev)
-		*err =3D -EPROTONOSUPPORT;
-	return 1;
-}
-
-
 /* All zeroes =3D=3D unconditional rule. */
 static inline int
 unconditional(const struct ip6t_ip6 *ipv6)
@@ -594,7 +430,7 @@ unconditional(const struct ip6t_ip6 *ipv
 /* Figures out from what hook each rule can be called: returns 0 if
    there are loops.  Puts hook bitmask in comefrom. */
 static int
-mark_source_chains(struct ip6t_table_info *newinfo,
+mark_source_chains(struct xt_table_info *newinfo,
 		   unsigned int valid_hooks, void *entry0)
 {
 	unsigned int hook;
@@ -740,11 +576,11 @@ check_match(struct ip6t_entry_match *m,
 {
 	struct ip6t_match *match;
=20
-	match =3D try_then_request_module(find_match(m->u.user.name,
-						   m->u.user.revision),
+	match =3D try_then_request_module(xt_find_match(AF_INET6, m->u.user.name,
+			      		m->u.user.revision),
 					"ip6t_%s", m->u.user.name);
 	if (IS_ERR(match) || !match) {
-		duprintf("check_match: `%s' not found\n", m->u.user.name);
+	  	duprintf("check_match: `%s' not found\n", m->u.user.name);
 		return match ? PTR_ERR(match) : -ENOENT;
 	}
 	m->u.kernel.match =3D match;
@@ -785,8 +621,9 @@ check_entry(struct ip6t_entry *e, const=20
 		goto cleanup_matches;
=20
 	t =3D ip6t_get_target(e);
-	target =3D try_then_request_module(find_target(t->u.user.name,
-						     t->u.user.revision),
+	target =3D try_then_request_module(xt_find_target(AF_INET6,
+							t->u.user.name,
+							t->u.user.revision),
 					 "ip6t_%s", t->u.user.name);
 	if (IS_ERR(target) || !target) {
 		duprintf("check_entry: `%s' not found\n", t->u.user.name);
@@ -822,7 +659,7 @@ check_entry(struct ip6t_entry *e, const=20
=20
 static inline int
 check_entry_size_and_hooks(struct ip6t_entry *e,
-			   struct ip6t_table_info *newinfo,
+			   struct xt_table_info *newinfo,
 			   unsigned char *base,
 			   unsigned char *limit,
 			   const unsigned int *hook_entries,
@@ -856,7 +693,7 @@ check_entry_size_and_hooks(struct ip6t_e
            < 0 (not IP6T_RETURN). --RR */
=20
 	/* Clear counters and comefrom */
-	e->counters =3D ((struct ip6t_counters) { 0, 0 });
+	e->counters =3D ((struct xt_counters) { 0, 0 });
 	e->comefrom =3D 0;
=20
 	(*i)++;
@@ -886,7 +723,7 @@ cleanup_entry(struct ip6t_entry *e, unsi
 static int
 translate_table(const char *name,
 		unsigned int valid_hooks,
-		struct ip6t_table_info *newinfo,
+		struct xt_table_info *newinfo,
 		void *entry0,
 		unsigned int size,
 		unsigned int number,
@@ -963,48 +800,10 @@ translate_table(const char *name,
 	return ret;
 }
=20
-static struct ip6t_table_info *
-replace_table(struct ip6t_table *table,
-	      unsigned int num_counters,
-	      struct ip6t_table_info *newinfo,
-	      int *error)
-{
-	struct ip6t_table_info *oldinfo;
-
-#ifdef CONFIG_NETFILTER_DEBUG
-	{
-		int cpu;
-
-		for_each_cpu(cpu) {
-			struct ip6t_entry *table_base =3D newinfo->entries[cpu];
-			if (table_base)
-				table_base->comefrom =3D 0xdead57ac;
-		}
-	}
-#endif
-
-	/* Do the substitution. */
-	write_lock_bh(&table->lock);
-	/* Check inside lock: is the old number correct? */
-	if (num_counters !=3D table->private->number) {
-		duprintf("num_counters !=3D table->private->number (%u/%u)\n",
-			 num_counters, table->private->number);
-		write_unlock_bh(&table->lock);
-		*error =3D -EAGAIN;
-		return NULL;
-	}
-	oldinfo =3D table->private;
-	table->private =3D newinfo;
-	newinfo->initial_entries =3D oldinfo->initial_entries;
-	write_unlock_bh(&table->lock);
-
-	return oldinfo;
-}
-
 /* Gets counters. */
 static inline int
 add_entry_to_counter(const struct ip6t_entry *e,
-		     struct ip6t_counters total[],
+		     struct xt_counters total[],
 		     unsigned int *i)
 {
 	ADD_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
@@ -1025,8 +824,8 @@ set_entry_to_counter(const struct ip6t_e
 }
=20
 static void
-get_counters(const struct ip6t_table_info *t,
-	     struct ip6t_counters counters[])
+get_counters(const struct xt_table_info *t,
+	     struct xt_counters counters[])
 {
 	unsigned int cpu;
 	unsigned int i;
@@ -1060,19 +859,20 @@ get_counters(const struct ip6t_table_inf
=20
 static int
 copy_entries_to_user(unsigned int total_size,
-		     struct ip6t_table *table,
+		     struct xt_table *table,
 		     void __user *userptr)
 {
 	unsigned int off, num, countersize;
 	struct ip6t_entry *e;
-	struct ip6t_counters *counters;
+	struct xt_counters *counters;
+	struct xt_table_info *private =3D table->private;
 	int ret =3D 0;
 	void *loc_cpu_entry;
=20
 	/* We need atomic snapshot of counters: rest doesn't change
 	   (other than comefrom, which userspace doesn't care
 	   about). */
-	countersize =3D sizeof(struct ip6t_counters) * table->private->number;
+	countersize =3D sizeof(struct xt_counters) * private->number;
 	counters =3D vmalloc(countersize);
=20
 	if (counters =3D=3D NULL)
@@ -1080,11 +880,11 @@ copy_entries_to_user(unsigned int total_
=20
 	/* First, sum counters... */
 	write_lock_bh(&table->lock);
-	get_counters(table->private, counters);
+	get_counters(private, counters);
 	write_unlock_bh(&table->lock);
=20
 	/* choose the copy that is on ourc node/cpu */
-	loc_cpu_entry =3D table->private->entries[raw_smp_processor_id()];
+	loc_cpu_entry =3D private->entries[raw_smp_processor_id()];
 	if (copy_to_user(userptr, loc_cpu_entry, total_size) !=3D 0) {
 		ret =3D -EFAULT;
 		goto free_counters;
@@ -1143,87 +943,42 @@ get_entries(const struct ip6t_get_entrie
 	    struct ip6t_get_entries __user *uptr)
 {
 	int ret;
-	struct ip6t_table *t;
+	struct xt_table *t;
=20
-	t =3D find_table_lock(entries->name);
+	t =3D xt_find_table_lock(AF_INET6, entries->name);
 	if (t && !IS_ERR(t)) {
-		duprintf("t->private->number =3D %u\n",
-			 t->private->number);
-		if (entries->size =3D=3D t->private->size)
-			ret =3D copy_entries_to_user(t->private->size,
+		struct xt_table_info *private =3D t->private;
+		duprintf("t->private->number =3D %u\n", private->number);
+		if (entries->size =3D=3D private->size)
+			ret =3D copy_entries_to_user(private->size,
 						   t, uptr->entrytable);
 		else {
 			duprintf("get_entries: I've got %u not %u!\n",
-				 t->private->size,
-				 entries->size);
+				 private->size, entries->size);
 			ret =3D -EINVAL;
 		}
 		module_put(t->me);
-		up(&ip6t_mutex);
+		xt_table_unlock(t);
 	} else
 		ret =3D t ? PTR_ERR(t) : -ENOENT;
=20
 	return ret;
 }
=20
-static void free_table_info(struct ip6t_table_info *info)
-{
-	int cpu;
-	for_each_cpu(cpu) {
-		if (info->size <=3D PAGE_SIZE)
-			kfree(info->entries[cpu]);
-		else
-			vfree(info->entries[cpu]);
-	}
-	kfree(info);
-}
-
-static struct ip6t_table_info *alloc_table_info(unsigned int size)
-{
-	struct ip6t_table_info *newinfo;
-	int cpu;
-
-	newinfo =3D kzalloc(sizeof(struct ip6t_table_info), GFP_KERNEL);
-	if (!newinfo)
-		return NULL;
-
-	newinfo->size =3D size;
-
-	for_each_cpu(cpu) {
-		if (size <=3D PAGE_SIZE)
-			newinfo->entries[cpu] =3D kmalloc_node(size,
-							GFP_KERNEL,
-							cpu_to_node(cpu));
-		else
-			newinfo->entries[cpu] =3D vmalloc_node(size,
-							     cpu_to_node(cpu));
-		if (newinfo->entries[cpu] =3D=3D NULL) {
-			free_table_info(newinfo);
-			return NULL;
-		}
-	}
-
-	return newinfo;
-}
-
 static int
 do_replace(void __user *user, unsigned int len)
 {
 	int ret;
 	struct ip6t_replace tmp;
-	struct ip6t_table *t;
-	struct ip6t_table_info *newinfo, *oldinfo;
-	struct ip6t_counters *counters;
+	struct xt_table *t;
+	struct xt_table_info *newinfo, *oldinfo;
+	struct xt_counters *counters;
 	void *loc_cpu_entry, *loc_cpu_old_entry;
=20
 	if (copy_from_user(&tmp, user, sizeof(tmp)) !=3D 0)
 		return -EFAULT;
=20
-	/* Pedantry: prevent them from hitting BUG() in vmalloc.c --RR */
-	if ((SMP_ALIGN(tmp.size) >> PAGE_SHIFT) + 2 > num_physpages)
-		return -ENOMEM;
-
-	newinfo =3D alloc_table_info(tmp.size);
+	newinfo =3D xt_alloc_table_info(tmp.size);
 	if (!newinfo)
 		return -ENOMEM;
=20
@@ -1235,7 +990,7 @@ do_replace(void __user *user, unsigned i
 		goto free_newinfo;
 	}
=20
-	counters =3D vmalloc(tmp.num_counters * sizeof(struct ip6t_counters));
+	counters =3D vmalloc(tmp.num_counters * sizeof(struct xt_counters));
 	if (!counters) {
 		ret =3D -ENOMEM;
 		goto free_newinfo;
@@ -1249,7 +1004,7 @@ do_replace(void __user *user, unsigned i
=20
 	duprintf("ip_tables: Translated table\n");
=20
-	t =3D try_then_request_module(find_table_lock(tmp.name),
+	t =3D try_then_request_module(xt_find_table_lock(AF_INET6, tmp.name),
 				    "ip6table_%s", tmp.name);
 	if (!t || IS_ERR(t)) {
 		ret =3D t ? PTR_ERR(t) : -ENOENT;
@@ -1264,7 +1019,7 @@ do_replace(void __user *user, unsigned i
 		goto put_module;
 	}
=20
-	oldinfo =3D replace_table(t, tmp.num_counters, newinfo, &ret);
+	oldinfo =3D xt_replace_table(t, tmp.num_counters, newinfo, &ret);
 	if (!oldinfo)
 		goto put_module;
=20
@@ -1283,23 +1038,23 @@ do_replace(void __user *user, unsigned i
 	/* Decrease module usage counts and free resource */
 	loc_cpu_old_entry =3D oldinfo->entries[raw_smp_processor_id()];
 	IP6T_ENTRY_ITERATE(loc_cpu_old_entry, oldinfo->size, cleanup_entry,NULL);
-	free_table_info(oldinfo);
+	xt_free_table_info(oldinfo);
 	if (copy_to_user(tmp.counters, counters,
-			 sizeof(struct ip6t_counters) * tmp.num_counters) !=3D 0)
+			 sizeof(struct xt_counters) * tmp.num_counters) !=3D 0)
 		ret =3D -EFAULT;
 	vfree(counters);
-	up(&ip6t_mutex);
+	xt_table_unlock(t);
 	return ret;
=20
  put_module:
 	module_put(t->me);
-	up(&ip6t_mutex);
+	xt_table_unlock(t);
  free_newinfo_counters_untrans:
 	IP6T_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry,NULL);
  free_newinfo_counters:
 	vfree(counters);
  free_newinfo:
-	free_table_info(newinfo);
+	xt_free_table_info(newinfo);
 	return ret;
 }
=20
@@ -1307,7 +1062,7 @@ do_replace(void __user *user, unsigned i
  * and everything is OK. */
 static inline int
 add_counter_to_entry(struct ip6t_entry *e,
-		     const struct ip6t_counters addme[],
+		     const struct xt_counters addme[],
 		     unsigned int *i)
 {
 #if 0
@@ -1329,15 +1084,16 @@ static int
 do_add_counters(void __user *user, unsigned int len)
 {
 	unsigned int i;
-	struct ip6t_counters_info tmp, *paddc;
-	struct ip6t_table *t;
+	struct xt_counters_info tmp, *paddc;
+	struct xt_table_info *private;
+	struct xt_table *t;
 	int ret =3D 0;
 	void *loc_cpu_entry;
=20
 	if (copy_from_user(&tmp, user, sizeof(tmp)) !=3D 0)
 		return -EFAULT;
=20
-	if (len !=3D sizeof(tmp) + tmp.num_counters*sizeof(struct ip6t_counters))
+	if (len !=3D sizeof(tmp) + tmp.num_counters*sizeof(struct xt_counters))
 		return -EINVAL;
=20
 	paddc =3D vmalloc(len);
@@ -1349,29 +1105,30 @@ do_add_counters(void __user *user, unsig
 		goto free;
 	}
=20
-	t =3D find_table_lock(tmp.name);
+	t =3D xt_find_table_lock(AF_INET6, tmp.name);
 	if (!t || IS_ERR(t)) {
 		ret =3D t ? PTR_ERR(t) : -ENOENT;
 		goto free;
 	}
=20
 	write_lock_bh(&t->lock);
-	if (t->private->number !=3D paddc->num_counters) {
+	private =3D t->private;
+	if (private->number !=3D paddc->num_counters) {
 		ret =3D -EINVAL;
 		goto unlock_up_free;
 	}
=20
 	i =3D 0;
 	/* Choose the copy that is on our node */
-	loc_cpu_entry =3D t->private->entries[smp_processor_id()];
+	loc_cpu_entry =3D private->entries[smp_processor_id()];
 	IP6T_ENTRY_ITERATE(loc_cpu_entry,
-			  t->private->size,
+			  private->size,
 			  add_counter_to_entry,
 			  paddc->counters,
 			  &i);
  unlock_up_free:
 	write_unlock_bh(&t->lock);
-	up(&ip6t_mutex);
+	xt_table_unlock(t);
 	module_put(t->me);
  free:
 	vfree(paddc);
@@ -1415,7 +1172,7 @@ do_ip6t_get_ctl(struct sock *sk, int cmd
 	switch (cmd) {
 	case IP6T_SO_GET_INFO: {
 		char name[IP6T_TABLE_MAXNAMELEN];
-		struct ip6t_table *t;
+		struct xt_table *t;
=20
 		if (*len !=3D sizeof(struct ip6t_getinfo)) {
 			duprintf("length %u !=3D %u\n", *len,
@@ -1430,25 +1187,26 @@ do_ip6t_get_ctl(struct sock *sk, int cmd
 		}
 		name[IP6T_TABLE_MAXNAMELEN-1] =3D '\0';
=20
-		t =3D try_then_request_module(find_table_lock(name),
+		t =3D try_then_request_module(xt_find_table_lock(AF_INET6, name),
 					    "ip6table_%s", name);
 		if (t && !IS_ERR(t)) {
 			struct ip6t_getinfo info;
+			struct xt_table_info *private =3D t->private;
=20
 			info.valid_hooks =3D t->valid_hooks;
-			memcpy(info.hook_entry, t->private->hook_entry,
+			memcpy(info.hook_entry, private->hook_entry,
 			       sizeof(info.hook_entry));
-			memcpy(info.underflow, t->private->underflow,
+			memcpy(info.underflow, private->underflow,
 			       sizeof(info.underflow));
-			info.num_entries =3D t->private->number;
-			info.size =3D t->private->size;
+			info.num_entries =3D private->number;
+			info.size =3D private->size;
 			memcpy(info.name, name, sizeof(info.name));
=20
 			if (copy_to_user(user, &info, *len) !=3D 0)
 				ret =3D -EFAULT;
 			else
 				ret =3D 0;
-			up(&ip6t_mutex);
+			xt_table_unlock(t);
 			module_put(t->me);
 		} else
 			ret =3D t ? PTR_ERR(t) : -ENOENT;
@@ -1475,7 +1233,7 @@ do_ip6t_get_ctl(struct sock *sk, int cmd
 	case IP6T_SO_GET_REVISION_MATCH:
 	case IP6T_SO_GET_REVISION_TARGET: {
 		struct ip6t_get_revision rev;
-		int (*revfn)(const char *, u8, int *);
+		int target;
=20
 		if (*len !=3D sizeof(rev)) {
 			ret =3D -EINVAL;
@@ -1487,12 +1245,13 @@ do_ip6t_get_ctl(struct sock *sk, int cmd
 		}
=20
 		if (cmd =3D=3D IP6T_SO_GET_REVISION_TARGET)
-			revfn =3D target_revfn;
+			target =3D 1;
 		else
-			revfn =3D match_revfn;
+			target =3D 0;
=20
-		try_then_request_module(find_revision(rev.name, rev.revision,
-						      revfn, &ret),
+		try_then_request_module(xt_find_revision(AF_INET6, rev.name,
+							 rev.revision,
+							 target, &ret),
 					"ip6t_%s", rev.name);
 		break;
 	}
@@ -1505,61 +1264,16 @@ do_ip6t_get_ctl(struct sock *sk, int cmd
 	return ret;
 }
=20
-/* Registration hooks for targets. */
-int
-ip6t_register_target(struct ip6t_target *target)
-{
-	int ret;
-
-	ret =3D down_interruptible(&ip6t_mutex);
-	if (ret !=3D 0)
-		return ret;
-	list_add(&target->list, &ip6t_target);
-	up(&ip6t_mutex);
-	return ret;
-}
-
-void
-ip6t_unregister_target(struct ip6t_target *target)
-{
-	down(&ip6t_mutex);
-	LIST_DELETE(&ip6t_target, target);
-	up(&ip6t_mutex);
-}
-
-int
-ip6t_register_match(struct ip6t_match *match)
-{
-	int ret;
-
-	ret =3D down_interruptible(&ip6t_mutex);
-	if (ret !=3D 0)
-		return ret;
-
-	list_add(&match->list, &ip6t_match);
-	up(&ip6t_mutex);
-
-	return ret;
-}
-
-void
-ip6t_unregister_match(struct ip6t_match *match)
-{
-	down(&ip6t_mutex);
-	LIST_DELETE(&ip6t_match, match);
-	up(&ip6t_mutex);
-}
-
-int ip6t_register_table(struct ip6t_table *table,
+int ip6t_register_table(struct xt_table *table,
 			const struct ip6t_replace *repl)
 {
 	int ret;
-	struct ip6t_table_info *newinfo;
-	static struct ip6t_table_info bootstrap
+	struct xt_table_info *newinfo;
+	static struct xt_table_info bootstrap
 		=3D { 0, 0, 0, { 0 }, { 0 }, { } };
 	void *loc_cpu_entry;
=20
-	newinfo =3D alloc_table_info(repl->size);
+	newinfo =3D xt_alloc_table_info(repl->size);
 	if (!newinfo)
 		return -ENOMEM;
=20
@@ -1573,244 +1287,29 @@ int ip6t_register_table(struct ip6t_tabl
 			      repl->hook_entry,
 			      repl->underflow);
 	if (ret !=3D 0) {
-		free_table_info(newinfo);
+		xt_free_table_info(newinfo);
 		return ret;
 	}
=20
-	ret =3D down_interruptible(&ip6t_mutex);
-	if (ret !=3D 0) {
-		free_table_info(newinfo);
+	if (xt_register_table(table, &bootstrap, newinfo) !=3D 0) {
+		xt_free_table_info(newinfo);
 		return ret;
 	}
=20
-	/* Don't autoload: we'd eat our tail... */
-	if (list_named_find(&ip6t_tables, table->name)) {
-		ret =3D -EEXIST;
-		goto free_unlock;
-	}
-
-	/* Simplifies replace_table code. */
-	table->private =3D &bootstrap;
-	if (!replace_table(table, 0, newinfo, &ret))
-		goto free_unlock;
-
-	duprintf("table->private->number =3D %u\n",
-		 table->private->number);
-
-	/* save number of initial entries */
-	table->private->initial_entries =3D table->private->number;
-
-	rwlock_init(&table->lock);
-	list_prepend(&ip6t_tables, table);
-
- unlock:
-	up(&ip6t_mutex);
-	return ret;
-
- free_unlock:
-	free_table_info(newinfo);
-	goto unlock;
+	return 0;
 }
=20
-void ip6t_unregister_table(struct ip6t_table *table)
+void ip6t_unregister_table(struct xt_table *table)
 {
+	struct xt_table_info *private;
 	void *loc_cpu_entry;
=20
-	down(&ip6t_mutex);
-	LIST_DELETE(&ip6t_tables, table);
-	up(&ip6t_mutex);
+	private =3D xt_unregister_table(table);
=20
 	/* Decrease module usage counts and free resources */
-	loc_cpu_entry =3D table->private->entries[raw_smp_processor_id()];
-	IP6T_ENTRY_ITERATE(loc_cpu_entry, table->private->size,
-			  cleanup_entry, NULL);
-	free_table_info(table->private);
-}
-
-/* Returns 1 if the port is matched by the range, 0 otherwise */
-static inline int
-port_match(u_int16_t min, u_int16_t max, u_int16_t port, int invert)
-{
-	int ret;
-
-	ret =3D (port >=3D min && port <=3D max) ^ invert;
-	return ret;
-}
-
-static int
-tcp_find_option(u_int8_t option,
-		const struct sk_buff *skb,
-		unsigned int tcpoff,
-		unsigned int optlen,
-		int invert,
-		int *hotdrop)
-{
-	/* tcp.doff is only 4 bits, ie. max 15 * 4 bytes */
-	u_int8_t _opt[60 - sizeof(struct tcphdr)], *op;
-	unsigned int i;
-
-	duprintf("tcp_match: finding option\n");
-	if (!optlen)
-		return invert;
-	/* If we don't have the whole header, drop packet. */
-	op =3D skb_header_pointer(skb, tcpoff + sizeof(struct tcphdr), optlen,
-				_opt);
-	if (op =3D=3D NULL) {
-		*hotdrop =3D 1;
-		return 0;
-	}
-
-	for (i =3D 0; i < optlen; ) {
-		if (op[i] =3D=3D option) return !invert;
-		if (op[i] < 2) i++;
-		else i +=3D op[i+1]?:1;
-	}
-
-	return invert;
-}
-
-static int
-tcp_match(const struct sk_buff *skb,
-	  const struct net_device *in,
-	  const struct net_device *out,
-	  const void *matchinfo,
-	  int offset,
-	  unsigned int protoff,
-	  int *hotdrop)
-{
-	struct tcphdr _tcph, *th;
-	const struct ip6t_tcp *tcpinfo =3D matchinfo;
-
-	if (offset) {
-		/* To quote Alan:
-
-		   Don't allow a fragment of TCP 8 bytes in. Nobody normal
-		   causes this. Its a cracker trying to break in by doing a
-		   flag overwrite to pass the direction checks.
-		*/
-		if (offset =3D=3D 1) {
-			duprintf("Dropping evil TCP offset=3D1 frag.\n");
-			*hotdrop =3D 1;
-		}
-		/* Must not be a fragment. */
-		return 0;
-	}
-
-#define FWINVTCP(bool,invflg) ((bool) ^ !!(tcpinfo->invflags & invflg))
-
-	th =3D skb_header_pointer(skb, protoff, sizeof(_tcph), &_tcph);
-	if (th =3D=3D NULL) {
-		/* We've been asked to examine this packet, and we
-		   can't.  Hence, no choice but to drop. */
-		duprintf("Dropping evil TCP offset=3D0 tinygram.\n");
-		*hotdrop =3D 1;
-		return 0;
-	}
-
-	if (!port_match(tcpinfo->spts[0], tcpinfo->spts[1],
-			ntohs(th->source),
-			!!(tcpinfo->invflags & IP6T_TCP_INV_SRCPT)))
-		return 0;
-	if (!port_match(tcpinfo->dpts[0], tcpinfo->dpts[1],
-			ntohs(th->dest),
-			!!(tcpinfo->invflags & IP6T_TCP_INV_DSTPT)))
-		return 0;
-	if (!FWINVTCP((((unsigned char *)th)[13] & tcpinfo->flg_mask)
-		      =3D=3D tcpinfo->flg_cmp,
-		      IP6T_TCP_INV_FLAGS))
-		return 0;
-	if (tcpinfo->option) {
-		if (th->doff * 4 < sizeof(_tcph)) {
-			*hotdrop =3D 1;
-			return 0;
-		}
-		if (!tcp_find_option(tcpinfo->option, skb, protoff,
-				     th->doff*4 - sizeof(*th),
-				     tcpinfo->invflags & IP6T_TCP_INV_OPTION,
-				     hotdrop))
-			return 0;
-	}
-	return 1;
-}
-
-/* Called when user tries to insert an entry of this type. */
-static int
-tcp_checkentry(const char *tablename,
-	       const struct ip6t_ip6 *ipv6,
-	       void *matchinfo,
-	       unsigned int matchsize,
-	       unsigned int hook_mask)
-{
-	const struct ip6t_tcp *tcpinfo =3D matchinfo;
-
-	/* Must specify proto =3D=3D TCP, and no unknown invflags */
-	return ipv6->proto =3D=3D IPPROTO_TCP
-		&& !(ipv6->invflags & IP6T_INV_PROTO)
-		&& matchsize =3D=3D IP6T_ALIGN(sizeof(struct ip6t_tcp))
-		&& !(tcpinfo->invflags & ~IP6T_TCP_INV_MASK);
-}
-
-static int
-udp_match(const struct sk_buff *skb,
-	  const struct net_device *in,
-	  const struct net_device *out,
-	  const void *matchinfo,
-	  int offset,
-	  unsigned int protoff,
-	  int *hotdrop)
-{
-	struct udphdr _udph, *uh;
-	const struct ip6t_udp *udpinfo =3D matchinfo;
-
-	/* Must not be a fragment. */
-	if (offset)
-		return 0;
-
-	uh =3D skb_header_pointer(skb, protoff, sizeof(_udph), &_udph);
-	if (uh =3D=3D NULL) {
-		/* We've been asked to examine this packet, and we
-		   can't.  Hence, no choice but to drop. */
-		duprintf("Dropping evil UDP tinygram.\n");
-		*hotdrop =3D 1;
-		return 0;
-	}
-
-	return port_match(udpinfo->spts[0], udpinfo->spts[1],
-			  ntohs(uh->source),
-			  !!(udpinfo->invflags & IP6T_UDP_INV_SRCPT))
-		&& port_match(udpinfo->dpts[0], udpinfo->dpts[1],
-			      ntohs(uh->dest),
-			      !!(udpinfo->invflags & IP6T_UDP_INV_DSTPT));
-}
-
-/* Called when user tries to insert an entry of this type. */
-static int
-udp_checkentry(const char *tablename,
-	       const struct ip6t_ip6 *ipv6,
-	       void *matchinfo,
-	       unsigned int matchinfosize,
-	       unsigned int hook_mask)
-{
-	const struct ip6t_udp *udpinfo =3D matchinfo;
-
-	/* Must specify proto =3D=3D UDP, and no unknown invflags */
-	if (ipv6->proto !=3D IPPROTO_UDP || (ipv6->invflags & IP6T_INV_PROTO)) {
-		duprintf("ip6t_udp: Protocol %u !=3D %u\n", ipv6->proto,
-			 IPPROTO_UDP);
-		return 0;
-	}
-	if (matchinfosize !=3D IP6T_ALIGN(sizeof(struct ip6t_udp))) {
-		duprintf("ip6t_udp: matchsize %u !=3D %u\n",
-			 matchinfosize, IP6T_ALIGN(sizeof(struct ip6t_udp)));
-		return 0;
-	}
-	if (udpinfo->invflags & ~IP6T_UDP_INV_MASK) {
-		duprintf("ip6t_udp: unknown flags %X\n",
-			 udpinfo->invflags);
-		return 0;
-	}
-
-	return 1;
+	loc_cpu_entry =3D private->entries[raw_smp_processor_id()];
+	IP6T_ENTRY_ITERATE(loc_cpu_entry, private->size, cleanup_entry, NULL);
+	xt_free_table_info(private);
 }
=20
 /* Returns 1 if the type and code is matched by the range, 0 otherwise */
@@ -1858,11 +1357,12 @@ icmp6_match(const struct sk_buff *skb,
 /* Called when user tries to insert an entry of this type. */
 static int
 icmp6_checkentry(const char *tablename,
-	   const struct ip6t_ip6 *ipv6,
+	   const void *entry,
 	   void *matchinfo,
 	   unsigned int matchsize,
 	   unsigned int hook_mask)
 {
+	const struct ip6t_ip6 *ipv6 =3D entry;
 	const struct ip6t_icmp *icmpinfo =3D matchinfo;
=20
 	/* Must specify proto =3D=3D ICMP, and no unknown invflags */
@@ -1892,164 +1392,42 @@ static struct nf_sockopt_ops ip6t_sockop
 	.get		=3D do_ip6t_get_ctl,
 };
=20
-static struct ip6t_match tcp_matchstruct =3D {
-	.name		=3D "tcp",
-	.match		=3D &tcp_match,
-	.checkentry	=3D &tcp_checkentry,
-};
-
-static struct ip6t_match udp_matchstruct =3D {
-	.name		=3D "udp",
-	.match		=3D &udp_match,
-	.checkentry	=3D &udp_checkentry,
-};
-
 static struct ip6t_match icmp6_matchstruct =3D {
 	.name		=3D "icmp6",
 	.match		=3D &icmp6_match,
 	.checkentry	=3D &icmp6_checkentry,
 };
=20
-#ifdef CONFIG_PROC_FS
-static inline int print_name(const char *i,
-			     off_t start_offset, char *buffer, int length,
-			     off_t *pos, unsigned int *count)
-{
-	if ((*count)++ >=3D start_offset) {
-		unsigned int namelen;
-
-		namelen =3D sprintf(buffer + *pos, "%s\n",
-				  i + sizeof(struct list_head));
-		if (*pos + namelen > length) {
-			/* Stop iterating */
-			return 1;
-		}
-		*pos +=3D namelen;
-	}
-	return 0;
-}
-
-static inline int print_target(const struct ip6t_target *t,
-                               off_t start_offset, char *buffer, int lengt=
h,
-                               off_t *pos, unsigned int *count)
-{
-	if (t =3D=3D &ip6t_standard_target || t =3D=3D &ip6t_error_target)
-		return 0;
-	return print_name((char *)t, start_offset, buffer, length, pos, count);
-}
-
-static int ip6t_get_tables(char *buffer, char **start, off_t offset, int l=
ength)
-{
-	off_t pos =3D 0;
-	unsigned int count =3D 0;
-
-	if (down_interruptible(&ip6t_mutex) !=3D 0)
-		return 0;
-
-	LIST_FIND(&ip6t_tables, print_name, char *,
-		  offset, buffer, length, &pos, &count);
-
-	up(&ip6t_mutex);
-
-	/* `start' hack - see fs/proc/generic.c line ~105 */
-	*start=3D(char *)((unsigned long)count-offset);
-	return pos;
-}
-
-static int ip6t_get_targets(char *buffer, char **start, off_t offset, int =
length)
-{
-	off_t pos =3D 0;
-	unsigned int count =3D 0;
-
-	if (down_interruptible(&ip6t_mutex) !=3D 0)
-		return 0;
-
-	LIST_FIND(&ip6t_target, print_target, struct ip6t_target *,
-		  offset, buffer, length, &pos, &count);
-
-	up(&ip6t_mutex);
-
-	*start =3D (char *)((unsigned long)count - offset);
-	return pos;
-}
-
-static int ip6t_get_matches(char *buffer, char **start, off_t offset, int =
length)
-{
-	off_t pos =3D 0;
-	unsigned int count =3D 0;
-
-	if (down_interruptible(&ip6t_mutex) !=3D 0)
-		return 0;
-
-	LIST_FIND(&ip6t_match, print_name, char *,
-		  offset, buffer, length, &pos, &count);
-
-	up(&ip6t_mutex);
-
-	*start =3D (char *)((unsigned long)count - offset);
-	return pos;
-}
-
-static const struct { char *name; get_info_t *get_info; } ip6t_proc_entry[=
] =3D
-{ { "ip6_tables_names", ip6t_get_tables },
-  { "ip6_tables_targets", ip6t_get_targets },
-  { "ip6_tables_matches", ip6t_get_matches },
-  { NULL, NULL} };
-#endif /*CONFIG_PROC_FS*/
-
 static int __init init(void)
 {
 	int ret;
=20
+	xt_proto_init(AF_INET6);
+
 	/* Noone else will be downing sem now, so we won't sleep */
-	down(&ip6t_mutex);
-	list_append(&ip6t_target, &ip6t_standard_target);
-	list_append(&ip6t_target, &ip6t_error_target);
-	list_append(&ip6t_match, &tcp_matchstruct);
-	list_append(&ip6t_match, &udp_matchstruct);
-	list_append(&ip6t_match, &icmp6_matchstruct);
-	up(&ip6t_mutex);
+	xt_register_target(AF_INET6, &ip6t_standard_target);
+	xt_register_target(AF_INET6, &ip6t_error_target);
+	xt_register_match(AF_INET6, &icmp6_matchstruct);
=20
 	/* Register setsockopt */
 	ret =3D nf_register_sockopt(&ip6t_sockopts);
 	if (ret < 0) {
 		duprintf("Unable to register sockopts.\n");
+		xt_proto_fini(AF_INET6);
 		return ret;
 	}
=20
-#ifdef CONFIG_PROC_FS
-	{
-		struct proc_dir_entry *proc;
-		int i;
-
-		for (i =3D 0; ip6t_proc_entry[i].name; i++) {
-			proc =3D proc_net_create(ip6t_proc_entry[i].name, 0,
-					       ip6t_proc_entry[i].get_info);
-			if (!proc) {
-				while (--i >=3D 0)
-				       proc_net_remove(ip6t_proc_entry[i].name);
-				nf_unregister_sockopt(&ip6t_sockopts);
-				return -ENOMEM;
-			}
-			proc->owner =3D THIS_MODULE;
-		}
-	}
-#endif
-
-	printk("ip6_tables: (C) 2000-2002 Netfilter core team\n");
+	printk("ip6_tables: (C) 2000-2006 Netfilter Core Team\n");
 	return 0;
 }
=20
 static void __exit fini(void)
 {
 	nf_unregister_sockopt(&ip6t_sockopts);
-#ifdef CONFIG_PROC_FS
-	{
-		int i;
-		for (i =3D 0; ip6t_proc_entry[i].name; i++)
-			proc_net_remove(ip6t_proc_entry[i].name);
-	}
-#endif
+	xt_unregister_match(AF_INET6, &icmp6_matchstruct);
+	xt_unregister_target(AF_INET6, &ip6t_error_target);
+	xt_unregister_target(AF_INET6, &ip6t_standard_target);
+	xt_proto_fini(AF_INET6);
 }
=20
 /*
@@ -2128,10 +1506,6 @@ int ipv6_find_hdr(const struct sk_buff *
 EXPORT_SYMBOL(ip6t_register_table);
 EXPORT_SYMBOL(ip6t_unregister_table);
 EXPORT_SYMBOL(ip6t_do_table);
-EXPORT_SYMBOL(ip6t_register_match);
-EXPORT_SYMBOL(ip6t_unregister_match);
-EXPORT_SYMBOL(ip6t_register_target);
-EXPORT_SYMBOL(ip6t_unregister_target);
 EXPORT_SYMBOL(ip6t_ext_hdr);
 EXPORT_SYMBOL(ipv6_find_hdr);
 EXPORT_SYMBOL(ip6_masked_addrcmp);
diff --git a/net/ipv6/netfilter/ip6t_HL.c b/net/ipv6/netfilter/ip6t_HL.c
index 8f5549b..306200c 100644
--- a/net/ipv6/netfilter/ip6t_HL.c
+++ b/net/ipv6/netfilter/ip6t_HL.c
@@ -62,7 +62,7 @@ static unsigned int ip6t_hl_target(struc
 }
=20
 static int ip6t_hl_checkentry(const char *tablename,
-		const struct ip6t_entry *e,
+		const void *entry,
 		void *targinfo,
 		unsigned int targinfosize,
 		unsigned int hook_mask)
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index ae4653b..fc19d8a 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -444,7 +444,7 @@ ip6t_log_target(struct sk_buff **pskb,
=20
=20
 static int ip6t_log_checkentry(const char *tablename,
-			       const struct ip6t_entry *e,
+			       const void *entry,
 			       void *targinfo,
 			       unsigned int targinfosize,
 			       unsigned int hook_mask)
diff --git a/net/ipv6/netfilter/ip6t_MARK.c b/net/ipv6/netfilter/ip6t_MARK.c
deleted file mode 100644
index eab8fb8..0000000
--- a/net/ipv6/netfilter/ip6t_MARK.c
+++ /dev/null
@@ -1,81 +0,0 @@
-/* This is a module which is used for setting the NFMARK field of an skb. =
*/
-
-/* (C) 1999-2001 Marc Boucher <marc@mbsi.ca>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/ip.h>
-#include <net/checksum.h>
-
-#include <linux/netfilter_ipv6/ip6_tables.h>
-#include <linux/netfilter_ipv6/ip6t_MARK.h>
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
-
-static unsigned int
-target(struct sk_buff **pskb,
-       const struct net_device *in,
-       const struct net_device *out,
-       unsigned int hooknum,
-       const void *targinfo,
-       void *userinfo)
-{
-	const struct ip6t_mark_target_info *markinfo =3D targinfo;
-
-	if((*pskb)->nfmark !=3D markinfo->mark)
-		(*pskb)->nfmark =3D markinfo->mark;
-
-	return IP6T_CONTINUE;
-}
-
-static int
-checkentry(const char *tablename,
-	   const struct ip6t_entry *e,
-           void *targinfo,
-           unsigned int targinfosize,
-           unsigned int hook_mask)
-{
-	if (targinfosize !=3D IP6T_ALIGN(sizeof(struct ip6t_mark_target_info))) {
-		printk(KERN_WARNING "MARK: targinfosize %u !=3D %Zu\n",
-		       targinfosize,
-		       IP6T_ALIGN(sizeof(struct ip6t_mark_target_info)));
-		return 0;
-	}
-
-	if (strcmp(tablename, "mangle") !=3D 0) {
-		printk(KERN_WARNING "MARK: can only be called from \"mangle\" table, not=
 \"%s\"\n", tablename);
-		return 0;
-	}
-
-	return 1;
-}
-
-static struct ip6t_target ip6t_mark_reg =3D {=20
-	.name		=3D "MARK",
-	.target		=3D target,
-	.checkentry	=3D checkentry,
-	.me		=3D THIS_MODULE
-};
-
-static int __init init(void)
-{
-	printk(KERN_DEBUG "registering ipv6 mark target\n");
-	if (ip6t_register_target(&ip6t_mark_reg))
-		return -EINVAL;
-
-	return 0;
-}
-
-static void __exit fini(void)
-{
-	ip6t_unregister_target(&ip6t_mark_reg);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv6/netfilter/ip6t_NFQUEUE.c b/net/ipv6/netfilter/ip6t_NF=
QUEUE.c
deleted file mode 100644
index c6e3730..0000000
--- a/net/ipv6/netfilter/ip6t_NFQUEUE.c
+++ /dev/null
@@ -1,70 +0,0 @@
-/* ip6tables module for using new netfilter netlink queue
- *
- * (C) 2005 by Harald Welte <laforge@netfilter.org>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as=20
- * published by the Free Software Foundation.
- *=20
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-
-#include <linux/netfilter.h>
-#include <linux/netfilter_ipv6/ip6_tables.h>
-#include <linux/netfilter_ipv4/ipt_NFQUEUE.h>
-
-MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
-MODULE_DESCRIPTION("ip6tables NFQUEUE target");
-MODULE_LICENSE("GPL");
-
-static unsigned int
-target(struct sk_buff **pskb,
-       const struct net_device *in,
-       const struct net_device *out,
-       unsigned int hooknum,
-       const void *targinfo,
-       void *userinfo)
-{
-	const struct ipt_NFQ_info *tinfo =3D targinfo;
-
-	return NF_QUEUE_NR(tinfo->queuenum);
-}
-
-static int
-checkentry(const char *tablename,
-	   const struct ip6t_entry *e,
-           void *targinfo,
-           unsigned int targinfosize,
-           unsigned int hook_mask)
-{
-	if (targinfosize !=3D IP6T_ALIGN(sizeof(struct ipt_NFQ_info))) {
-		printk(KERN_WARNING "NFQUEUE: targinfosize %u !=3D %Zu\n",
-		       targinfosize,
-		       IP6T_ALIGN(sizeof(struct ipt_NFQ_info)));
-		return 0;
-	}
-
-	return 1;
-}
-
-static struct ip6t_target ipt_NFQ_reg =3D {
-	.name		=3D "NFQUEUE",
-	.target		=3D target,
-	.checkentry	=3D checkentry,
-	.me		=3D THIS_MODULE,
-};
-
-static int __init init(void)
-{
-	return ip6t_register_target(&ipt_NFQ_reg);
-}
-
-static void __exit fini(void)
-{
-	ip6t_unregister_target(&ipt_NFQ_reg);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJ=
ECT.c
index b03e87a..c745717 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -218,12 +218,13 @@ static unsigned int reject6_target(struc
 }
=20
 static int check(const char *tablename,
-		 const struct ip6t_entry *e,
+		 const void *entry,
 		 void *targinfo,
 		 unsigned int targinfosize,
 		 unsigned int hook_mask)
 {
  	const struct ip6t_reject_info *rejinfo =3D targinfo;
+	const struct ip6t_entry *e =3D entry;
=20
  	if (targinfosize !=3D IP6T_ALIGN(sizeof(struct ip6t_reject_info))) {
   		DEBUGP("ip6t_REJECT: targinfosize %u !=3D 0\n", targinfosize);
diff --git a/net/ipv6/netfilter/ip6t_ah.c b/net/ipv6/netfilter/ip6t_ah.c
index f5c1a7f..219a303 100644
--- a/net/ipv6/netfilter/ip6t_ah.c
+++ b/net/ipv6/netfilter/ip6t_ah.c
@@ -98,7 +98,7 @@ match(const struct sk_buff *skb,
 /* Called when user tries to insert an entry of this type. */
 static int
 checkentry(const char *tablename,
-          const struct ip6t_ip6 *ip,
+          const void *entry,
           void *matchinfo,
           unsigned int matchinfosize,
           unsigned int hook_mask)
diff --git a/net/ipv6/netfilter/ip6t_dst.c b/net/ipv6/netfilter/ip6t_dst.c
index 48cf5f9..80fe826 100644
--- a/net/ipv6/netfilter/ip6t_dst.c
+++ b/net/ipv6/netfilter/ip6t_dst.c
@@ -178,7 +178,7 @@ match(const struct sk_buff *skb,
 /* Called when user tries to insert an entry of this type. */
 static int
 checkentry(const char *tablename,
-          const struct ip6t_ip6 *ip,
+          const void *info,
           void *matchinfo,
           unsigned int matchinfosize,
           unsigned int hook_mask)
diff --git a/net/ipv6/netfilter/ip6t_esp.c b/net/ipv6/netfilter/ip6t_esp.c
index e1828f6..724285d 100644
--- a/net/ipv6/netfilter/ip6t_esp.c
+++ b/net/ipv6/netfilter/ip6t_esp.c
@@ -76,7 +76,7 @@ match(const struct sk_buff *skb,
 /* Called when user tries to insert an entry of this type. */
 static int
 checkentry(const char *tablename,
-	   const struct ip6t_ip6 *ip,
+	   const void *ip,
 	   void *matchinfo,
 	   unsigned int matchinfosize,
 	   unsigned int hook_mask)
diff --git a/net/ipv6/netfilter/ip6t_eui64.c b/net/ipv6/netfilter/ip6t_eui6=
4.c
index 616c2cb..ddf5f57 100644
--- a/net/ipv6/netfilter/ip6t_eui64.c
+++ b/net/ipv6/netfilter/ip6t_eui64.c
@@ -62,7 +62,7 @@ match(const struct sk_buff *skb,
=20
 static int
 ip6t_eui64_checkentry(const char *tablename,
-		   const struct ip6t_ip6 *ip,
+		   const void  *ip,
 		   void *matchinfo,
 		   unsigned int matchsize,
 		   unsigned int hook_mask)
diff --git a/net/ipv6/netfilter/ip6t_frag.c b/net/ipv6/netfilter/ip6t_frag.c
index d1549b2..a9964b9 100644
--- a/net/ipv6/netfilter/ip6t_frag.c
+++ b/net/ipv6/netfilter/ip6t_frag.c
@@ -115,7 +115,7 @@ match(const struct sk_buff *skb,
 /* Called when user tries to insert an entry of this type. */
 static int
 checkentry(const char *tablename,
-          const struct ip6t_ip6 *ip,
+          const void *ip,
           void *matchinfo,
           unsigned int matchinfosize,
           unsigned int hook_mask)
diff --git a/net/ipv6/netfilter/ip6t_hbh.c b/net/ipv6/netfilter/ip6t_hbh.c
index e3bc8e2..ed8ded1 100644
--- a/net/ipv6/netfilter/ip6t_hbh.c
+++ b/net/ipv6/netfilter/ip6t_hbh.c
@@ -178,7 +178,7 @@ match(const struct sk_buff *skb,
 /* Called when user tries to insert an entry of this type. */
 static int
 checkentry(const char *tablename,
-          const struct ip6t_ip6 *ip,
+          const void *entry,
           void *matchinfo,
           unsigned int matchinfosize,
           unsigned int hook_mask)
diff --git a/net/ipv6/netfilter/ip6t_hl.c b/net/ipv6/netfilter/ip6t_hl.c
index 0beaff5..c5d9079 100644
--- a/net/ipv6/netfilter/ip6t_hl.c
+++ b/net/ipv6/netfilter/ip6t_hl.c
@@ -48,7 +48,7 @@ static int match(const struct sk_buff *s
 	return 0;
 }
=20
-static int checkentry(const char *tablename, const struct ip6t_ip6 *ip,
+static int checkentry(const char *tablename, const void *entry,
 		      void *matchinfo, unsigned int matchsize,
 		      unsigned int hook_mask)
 {
diff --git a/net/ipv6/netfilter/ip6t_ipv6header.c b/net/ipv6/netfilter/ip6t=
_ipv6header.c
index 32e67f0..fda1cea 100644
--- a/net/ipv6/netfilter/ip6t_ipv6header.c
+++ b/net/ipv6/netfilter/ip6t_ipv6header.c
@@ -124,7 +124,7 @@ ipv6header_match(const struct sk_buff *s
=20
 static int
 ipv6header_checkentry(const char *tablename,
-		      const struct ip6t_ip6 *ip,
+		      const void *ip,
 		      void *matchinfo,
 		      unsigned int matchsize,
 		      unsigned int hook_mask)
diff --git a/net/ipv6/netfilter/ip6t_length.c b/net/ipv6/netfilter/ip6t_len=
gth.c
deleted file mode 100644
index e0537d3..0000000
--- a/net/ipv6/netfilter/ip6t_length.c
+++ /dev/null
@@ -1,66 +0,0 @@
-/* Length Match - IPv6 Port */
-
-/* (C) 1999-2001 James Morris <jmorros@intercode.com.au>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/netfilter_ipv6/ip6t_length.h>
-#include <linux/netfilter_ipv6/ip6_tables.h>
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("James Morris <jmorris@intercode.com.au>");
-MODULE_DESCRIPTION("IPv6 packet length match");
-
-static int
-match(const struct sk_buff *skb,
-      const struct net_device *in,
-      const struct net_device *out,
-      const void *matchinfo,
-      int offset,
-      unsigned int protoff,
-      int *hotdrop)
-{
-	const struct ip6t_length_info *info =3D matchinfo;
-	u_int16_t pktlen =3D ntohs(skb->nh.ipv6h->payload_len) + sizeof(struct ip=
v6hdr);
-=09
-	return (pktlen >=3D info->min && pktlen <=3D info->max) ^ info->invert;
-}
-
-static int
-checkentry(const char *tablename,
-           const struct ip6t_ip6 *ip,
-           void *matchinfo,
-           unsigned int matchsize,
-           unsigned int hook_mask)
-{
-	if (matchsize !=3D IP6T_ALIGN(sizeof(struct ip6t_length_info)))
-		return 0;
-
-	return 1;
-}
-
-static struct ip6t_match length_match =3D {
-	.name		=3D "length",
-	.match		=3D &match,
-	.checkentry	=3D &checkentry,
-	.me		=3D THIS_MODULE,
-};
-
-static int __init init(void)
-{
-	return ip6t_register_match(&length_match);
-}
-
-static void __exit fini(void)
-{
-	ip6t_unregister_match(&length_match);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv6/netfilter/ip6t_limit.c b/net/ipv6/netfilter/ip6t_limi=
t.c
deleted file mode 100644
index fb782f6..0000000
--- a/net/ipv6/netfilter/ip6t_limit.c
+++ /dev/null
@@ -1,147 +0,0 @@
-/* Kernel module to control the rate
- *
- * 2 September 1999: Changed from the target RATE to the match
- *                   `limit', removed logging.  Did I mention that
- *                   Alexey is a fucking genius?
- *                   Rusty Russell (rusty@rustcorp.com.au).  */
-
-/* (C) 1999 J=E9r=F4me de Vivie <devivie@info.enserb.u-bordeaux.fr>
- * (C) 1999 Herv=E9 Eychenne <eychenne@info.enserb.u-bordeaux.fr>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/spinlock.h>
-#include <linux/interrupt.h>
-
-#include <linux/netfilter_ipv6/ip6_tables.h>
-#include <linux/netfilter_ipv6/ip6t_limit.h>
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Herve Eychenne <rv@wallfire.org>");
-MODULE_DESCRIPTION("rate limiting within ip6tables");
-
-/* The algorithm used is the Simple Token Bucket Filter (TBF)
- * see net/sched/sch_tbf.c in the linux source tree
- */
-
-static DEFINE_SPINLOCK(limit_lock);
-
-/* Rusty: This is my (non-mathematically-inclined) understanding of
-   this algorithm.  The `average rate' in jiffies becomes your initial
-   amount of credit `credit' and the most credit you can ever have
-   `credit_cap'.  The `peak rate' becomes the cost of passing the
-   test, `cost'.
-
-   `prev' tracks the last packet hit: you gain one credit per jiffy.
-   If you get credit balance more than this, the extra credit is
-   discarded.  Every time the match passes, you lose `cost' credits;
-   if you don't have that many, the test fails.
-
-   See Alexey's formal explanation in net/sched/sch_tbf.c.
-
-   To avoid underflow, we multiply by 128 (ie. you get 128 credits per
-   jiffy).  Hence a cost of 2^32-1, means one pass per 32768 seconds
-   at 1024HZ (or one every 9 hours).  A cost of 1 means 12800 passes
-   per second at 100HZ.  */
-
-#define CREDITS_PER_JIFFY 128
-
-static int
-ip6t_limit_match(const struct sk_buff *skb,
-		const struct net_device *in,
-		const struct net_device *out,
-		const void *matchinfo,
-		int offset,
-		unsigned int protoff,
-		int *hotdrop)
-{
-	struct ip6t_rateinfo *r =3D ((struct ip6t_rateinfo *)matchinfo)->master;
-	unsigned long now =3D jiffies;
-
-	spin_lock_bh(&limit_lock);
-	r->credit +=3D (now - xchg(&r->prev, now)) * CREDITS_PER_JIFFY;
-	if (r->credit > r->credit_cap)
-		r->credit =3D r->credit_cap;
-
-	if (r->credit >=3D r->cost) {
-		/* We're not limited. */
-		r->credit -=3D r->cost;
-		spin_unlock_bh(&limit_lock);
-		return 1;
-	}
-
-       	spin_unlock_bh(&limit_lock);
-	return 0;
-}
-
-/* Precision saver. */
-static u_int32_t
-user2credits(u_int32_t user)
-{
-	/* If multiplying would overflow... */
-	if (user > 0xFFFFFFFF / (HZ*CREDITS_PER_JIFFY))
-		/* Divide first. */
-		return (user / IP6T_LIMIT_SCALE) * HZ * CREDITS_PER_JIFFY;
-
-	return (user * HZ * CREDITS_PER_JIFFY) / IP6T_LIMIT_SCALE;
-}
-
-static int
-ip6t_limit_checkentry(const char *tablename,
-		     const struct ip6t_ip6 *ip,
-		     void *matchinfo,
-		     unsigned int matchsize,
-		     unsigned int hook_mask)
-{
-	struct ip6t_rateinfo *r =3D matchinfo;
-
-	if (matchsize !=3D IP6T_ALIGN(sizeof(struct ip6t_rateinfo)))
-		return 0;
-
-	/* Check for overflow. */
-	if (r->burst =3D=3D 0
-	    || user2credits(r->avg * r->burst) < user2credits(r->avg)) {
-		printk("Call rusty: overflow in ip6t_limit: %u/%u\n",
-		       r->avg, r->burst);
-		return 0;
-	}
-
-	/* User avg in seconds * IP6T_LIMIT_SCALE: convert to jiffies *
-	   128. */
-	r->prev =3D jiffies;
-	r->credit =3D user2credits(r->avg * r->burst);	 /* Credits full. */
-	r->credit_cap =3D user2credits(r->avg * r->burst); /* Credits full. */
-	r->cost =3D user2credits(r->avg);
-
-	/* For SMP, we only want to use one set of counters. */
-	r->master =3D r;
-
-	return 1;
-}
-
-static struct ip6t_match ip6t_limit_reg =3D {
-	.name		=3D "limit",
-	.match		=3D ip6t_limit_match,
-	.checkentry	=3D ip6t_limit_checkentry,
-	.me		=3D THIS_MODULE,
-};
-
-static int __init init(void)
-{
-	if (ip6t_register_match(&ip6t_limit_reg))
-		return -EINVAL;
-	return 0;
-}
-
-static void __exit fini(void)
-{
-	ip6t_unregister_match(&ip6t_limit_reg);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv6/netfilter/ip6t_mac.c b/net/ipv6/netfilter/ip6t_mac.c
deleted file mode 100644
index c848152..0000000
--- a/net/ipv6/netfilter/ip6t_mac.c
+++ /dev/null
@@ -1,81 +0,0 @@
-/* Kernel module to match MAC address parameters. */
-
-/* (C) 1999-2001 Paul `Rusty' Russell
- * (C) 2002-2004 Netfilter Core Team <coreteam@netfilter.org>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/if_ether.h>
-#include <linux/etherdevice.h>
-
-#include <linux/netfilter_ipv6/ip6t_mac.h>
-#include <linux/netfilter_ipv6/ip6_tables.h>
-
-MODULE_LICENSE("GPL");
-MODULE_DESCRIPTION("MAC address matching module for IPv6");
-MODULE_AUTHOR("Netfilter Core Teaam <coreteam@netfilter.org>");
-
-static int
-match(const struct sk_buff *skb,
-      const struct net_device *in,
-      const struct net_device *out,
-      const void *matchinfo,
-      int offset,
-      unsigned int protoff,
-      int *hotdrop)
-{
-    const struct ip6t_mac_info *info =3D matchinfo;
-
-    /* Is mac pointer valid? */
-    return (skb->mac.raw >=3D skb->head
-	    && (skb->mac.raw + ETH_HLEN) <=3D skb->data
-	    /* If so, compare... */
-	    && ((!compare_ether_addr(eth_hdr(skb)->h_source, info->srcaddr))
-		^ info->invert));
-}
-
-static int
-ip6t_mac_checkentry(const char *tablename,
-		   const struct ip6t_ip6 *ip,
-		   void *matchinfo,
-		   unsigned int matchsize,
-		   unsigned int hook_mask)
-{
-	if (hook_mask
-	    & ~((1 << NF_IP6_PRE_ROUTING) | (1 << NF_IP6_LOCAL_IN)
-		| (1 << NF_IP6_FORWARD))) {
-		printk("ip6t_mac: only valid for PRE_ROUTING, LOCAL_IN or"
-		       " FORWARD\n");
-		return 0;
-	}
-
-	if (matchsize !=3D IP6T_ALIGN(sizeof(struct ip6t_mac_info)))
-		return 0;
-
-	return 1;
-}
-
-static struct ip6t_match mac_match =3D {
-	.name		=3D "mac",
-	.match		=3D &match,
-	.checkentry	=3D &ip6t_mac_checkentry,
-	.me		=3D THIS_MODULE,
-};
-
-static int __init init(void)
-{
-	return ip6t_register_match(&mac_match);
-}
-
-static void __exit fini(void)
-{
-	ip6t_unregister_match(&mac_match);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv6/netfilter/ip6t_mark.c b/net/ipv6/netfilter/ip6t_mark.c
deleted file mode 100644
index affc3de..0000000
--- a/net/ipv6/netfilter/ip6t_mark.c
+++ /dev/null
@@ -1,66 +0,0 @@
-/* Kernel module to match NFMARK values. */
-
-/* (C) 1999-2001 Marc Boucher <marc@mbsi.ca>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-
-#include <linux/netfilter_ipv6/ip6t_mark.h>
-#include <linux/netfilter_ipv6/ip6_tables.h>
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
-MODULE_DESCRIPTION("ip6tables mark match");
-
-static int
-match(const struct sk_buff *skb,
-      const struct net_device *in,
-      const struct net_device *out,
-      const void *matchinfo,
-      int offset,
-      unsigned int protoff,
-      int *hotdrop)
-{
-	const struct ip6t_mark_info *info =3D matchinfo;
-
-	return ((skb->nfmark & info->mask) =3D=3D info->mark) ^ info->invert;
-}
-
-static int
-checkentry(const char *tablename,
-           const struct ip6t_ip6 *ip,
-           void *matchinfo,
-           unsigned int matchsize,
-           unsigned int hook_mask)
-{
-	if (matchsize !=3D IP6T_ALIGN(sizeof(struct ip6t_mark_info)))
-		return 0;
-
-	return 1;
-}
-
-static struct ip6t_match mark_match =3D {
-	.name		=3D "mark",
-	.match		=3D &match,
-	.checkentry	=3D &checkentry,
-	.me		=3D THIS_MODULE,
-};
-
-static int __init init(void)
-{
-	return ip6t_register_match(&mark_match);
-}
-
-static void __exit fini(void)
-{
-	ip6t_unregister_match(&mark_match);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv6/netfilter/ip6t_multiport.c b/net/ipv6/netfilter/ip6t_=
multiport.c
index 6e32461..49f7829 100644
--- a/net/ipv6/netfilter/ip6t_multiport.c
+++ b/net/ipv6/netfilter/ip6t_multiport.c
@@ -84,11 +84,12 @@ match(const struct sk_buff *skb,
 /* Called when user tries to insert an entry of this type. */
 static int
 checkentry(const char *tablename,
-	   const struct ip6t_ip6 *ip,
+	   const void *info,
 	   void *matchinfo,
 	   unsigned int matchsize,
 	   unsigned int hook_mask)
 {
+	const struct ip6t_ip6 *ip =3D info;
 	const struct ip6t_multiport *multiinfo =3D matchinfo;
=20
 	if (matchsize !=3D IP6T_ALIGN(sizeof(struct ip6t_multiport)))
diff --git a/net/ipv6/netfilter/ip6t_owner.c b/net/ipv6/netfilter/ip6t_owne=
r.c
index 4de4cda..5409b37 100644
--- a/net/ipv6/netfilter/ip6t_owner.c
+++ b/net/ipv6/netfilter/ip6t_owner.c
@@ -53,7 +53,7 @@ match(const struct sk_buff *skb,
=20
 static int
 checkentry(const char *tablename,
-           const struct ip6t_ip6 *ip,
+           const void  *ip,
            void *matchinfo,
            unsigned int matchsize,
            unsigned int hook_mask)
diff --git a/net/ipv6/netfilter/ip6t_physdev.c b/net/ipv6/netfilter/ip6t_ph=
ysdev.c
deleted file mode 100644
index 71515c8..0000000
--- a/net/ipv6/netfilter/ip6t_physdev.c
+++ /dev/null
@@ -1,135 +0,0 @@
-/* Kernel module to match the bridge port in and
- * out device for IP packets coming into contact with a bridge. */
-
-/* (C) 2001-2003 Bart De Schuymer <bdschuym@pandora.be>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/netfilter_ipv6/ip6t_physdev.h>
-#include <linux/netfilter_ipv6/ip6_tables.h>
-#include <linux/netfilter_bridge.h>
-#define MATCH   1
-#define NOMATCH 0
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Bart De Schuymer <bdschuym@pandora.be>");
-MODULE_DESCRIPTION("iptables bridge physical device match module");
-
-static int
-match(const struct sk_buff *skb,
-      const struct net_device *in,
-      const struct net_device *out,
-      const void *matchinfo,
-      int offset,
-      unsigned int protoff,
-      int *hotdrop)
-{
-	int i;
-	static const char nulldevname[IFNAMSIZ];
-	const struct ip6t_physdev_info *info =3D matchinfo;
-	unsigned int ret;
-	const char *indev, *outdev;
-	struct nf_bridge_info *nf_bridge;
-
-	/* Not a bridged IP packet or no info available yet:
-	 * LOCAL_OUT/mangle and LOCAL_OUT/nat don't know if
-	 * the destination device will be a bridge. */
-	if (!(nf_bridge =3D skb->nf_bridge)) {
-		/* Return MATCH if the invert flags of the used options are on */
-		if ((info->bitmask & IP6T_PHYSDEV_OP_BRIDGED) &&
-		    !(info->invert & IP6T_PHYSDEV_OP_BRIDGED))
-			return NOMATCH;
-		if ((info->bitmask & IP6T_PHYSDEV_OP_ISIN) &&
-		    !(info->invert & IP6T_PHYSDEV_OP_ISIN))
-			return NOMATCH;
-		if ((info->bitmask & IP6T_PHYSDEV_OP_ISOUT) &&
-		    !(info->invert & IP6T_PHYSDEV_OP_ISOUT))
-			return NOMATCH;
-		if ((info->bitmask & IP6T_PHYSDEV_OP_IN) &&
-		    !(info->invert & IP6T_PHYSDEV_OP_IN))
-			return NOMATCH;
-		if ((info->bitmask & IP6T_PHYSDEV_OP_OUT) &&
-		    !(info->invert & IP6T_PHYSDEV_OP_OUT))
-			return NOMATCH;
-		return MATCH;
-	}
-
-	/* This only makes sense in the FORWARD and POSTROUTING chains */
-	if ((info->bitmask & IP6T_PHYSDEV_OP_BRIDGED) &&
-	    (!!(nf_bridge->mask & BRNF_BRIDGED) ^
-	    !(info->invert & IP6T_PHYSDEV_OP_BRIDGED)))
-		return NOMATCH;
-
-	if ((info->bitmask & IP6T_PHYSDEV_OP_ISIN &&
-	    (!nf_bridge->physindev ^ !!(info->invert & IP6T_PHYSDEV_OP_ISIN))) ||
-	    (info->bitmask & IP6T_PHYSDEV_OP_ISOUT &&
-	    (!nf_bridge->physoutdev ^ !!(info->invert & IP6T_PHYSDEV_OP_ISOUT))))
-		return NOMATCH;
-
-	if (!(info->bitmask & IP6T_PHYSDEV_OP_IN))
-		goto match_outdev;
-	indev =3D nf_bridge->physindev ? nf_bridge->physindev->name : nulldevname;
-	for (i =3D 0, ret =3D 0; i < IFNAMSIZ/sizeof(unsigned int); i++) {
-		ret |=3D (((const unsigned int *)indev)[i]
-			^ ((const unsigned int *)info->physindev)[i])
-			& ((const unsigned int *)info->in_mask)[i];
-	}
-
-	if ((ret =3D=3D 0) ^ !(info->invert & IP6T_PHYSDEV_OP_IN))
-		return NOMATCH;
-
-match_outdev:
-	if (!(info->bitmask & IP6T_PHYSDEV_OP_OUT))
-		return MATCH;
-	outdev =3D nf_bridge->physoutdev ?
-		 nf_bridge->physoutdev->name : nulldevname;
-	for (i =3D 0, ret =3D 0; i < IFNAMSIZ/sizeof(unsigned int); i++) {
-		ret |=3D (((const unsigned int *)outdev)[i]
-			^ ((const unsigned int *)info->physoutdev)[i])
-			& ((const unsigned int *)info->out_mask)[i];
-	}
-
-	return (ret !=3D 0) ^ !(info->invert & IP6T_PHYSDEV_OP_OUT);
-}
-
-static int
-checkentry(const char *tablename,
-		       const struct ip6t_ip6 *ip,
-		       void *matchinfo,
-		       unsigned int matchsize,
-		       unsigned int hook_mask)
-{
-	const struct ip6t_physdev_info *info =3D matchinfo;
-
-	if (matchsize !=3D IP6T_ALIGN(sizeof(struct ip6t_physdev_info)))
-		return 0;
-	if (!(info->bitmask & IP6T_PHYSDEV_OP_MASK) ||
-	    info->bitmask & ~IP6T_PHYSDEV_OP_MASK)
-		return 0;
-	return 1;
-}
-
-static struct ip6t_match physdev_match =3D {
-	.name		=3D "physdev",
-	.match		=3D &match,
-	.checkentry	=3D &checkentry,
-	.me		=3D THIS_MODULE,
-};
-
-static int __init init(void)
-{
-	return ip6t_register_match(&physdev_match);
-}
-
-static void __exit fini(void)
-{
-	ip6t_unregister_match(&physdev_match);
-}
-
-module_init(init);
-module_exit(fini);
diff --git a/net/ipv6/netfilter/ip6t_rt.c b/net/ipv6/netfilter/ip6t_rt.c
index c1e770e..8465b43 100644
--- a/net/ipv6/netfilter/ip6t_rt.c
+++ b/net/ipv6/netfilter/ip6t_rt.c
@@ -183,7 +183,7 @@ match(const struct sk_buff *skb,
 /* Called when user tries to insert an entry of this type. */
 static int
 checkentry(const char *tablename,
-          const struct ip6t_ip6 *ip,
+          const void *entry,
           void *matchinfo,
           unsigned int matchinfosize,
           unsigned int hook_mask)
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6t=
able_filter.c
index 4c00286..ce4a968 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -97,6 +97,7 @@ static struct ip6t_table packet_filter =3D
 	.valid_hooks	=3D FILTER_VALID_HOOKS,
 	.lock		=3D RW_LOCK_UNLOCKED,
 	.me		=3D THIS_MODULE,
+	.af		=3D AF_INET6,
 };
=20
 /* The work comes in here from netfilter.c. */
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6t=
able_mangle.c
index 85c1e6e..30a4627 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -127,6 +127,7 @@ static struct ip6t_table packet_mangler=20
 	.valid_hooks	=3D MANGLE_VALID_HOOKS,
 	.lock		=3D RW_LOCK_UNLOCKED,
 	.me		=3D THIS_MODULE,
+	.af		=3D AF_INET6,
 };
=20
 /* The work comes in here from netfilter.c. */
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6tabl=
e_raw.c
index c2982ef..db28ba3 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -106,11 +106,12 @@ static struct
 	}
 };
=20
-static struct ip6t_table packet_raw =3D {=20
+static struct xt_table packet_raw =3D {=20
 	.name =3D "raw",=20
 	.valid_hooks =3D RAW_VALID_HOOKS,=20
 	.lock =3D RW_LOCK_UNLOCKED,=20
-	.me =3D THIS_MODULE
+	.me =3D THIS_MODULE,
+	.af =3D AF_INET6,
 };
=20
 /* The work comes in here from netfilter.c. */
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netf=
ilter/nf_conntrack_l3proto_ipv6.c
index e57d6fc..92ad53d 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -584,7 +584,7 @@ MODULE_AUTHOR("Yasuyuki KOZAKAI @USAGI <
=20
 static int __init init(void)
 {
-	need_nf_conntrack();
+	need_conntrack();
 	return init_or_cleanup(1);
 }
=20
@@ -595,9 +595,3 @@ static void __exit fini(void)
=20
 module_init(init);
 module_exit(fini);
-
-void need_ip6_conntrack(void)
-{
-}
-
-EXPORT_SYMBOL(need_ip6_conntrack);
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/n=
f_conntrack_reasm.c
index f3e5ffb..84ef9a1 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -70,8 +70,8 @@ struct nf_ct_frag6_skb_cb
=20
 struct nf_ct_frag6_queue
 {
-	struct nf_ct_frag6_queue	*next;
-	struct list_head lru_list;		/* lru list member	*/
+	struct hlist_node	list;
+	struct list_head	lru_list;	/* lru list member	*/
=20
 	__u32			id;		/* fragment id		*/
 	struct in6_addr		saddr;
@@ -90,14 +90,13 @@ struct nf_ct_frag6_queue
 #define FIRST_IN		2
 #define LAST_IN			1
 	__u16			nhoffset;
-	struct nf_ct_frag6_queue	**pprev;
 };
=20
 /* Hash table. */
=20
 #define FRAG6Q_HASHSZ	64
=20
-static struct nf_ct_frag6_queue *nf_ct_frag6_hash[FRAG6Q_HASHSZ];
+static struct hlist_head nf_ct_frag6_hash[FRAG6Q_HASHSZ];
 static DEFINE_RWLOCK(nf_ct_frag6_lock);
 static u32 nf_ct_frag6_hash_rnd;
 static LIST_HEAD(nf_ct_frag6_lru_list);
@@ -105,9 +104,7 @@ int nf_ct_frag6_nqueues =3D 0;
=20
 static __inline__ void __fq_unlink(struct nf_ct_frag6_queue *fq)
 {
-	if (fq->next)
-		fq->next->pprev =3D fq->pprev;
-	*fq->pprev =3D fq->next;
+	hlist_del(&fq->list);
 	list_del(&fq->lru_list);
 	nf_ct_frag6_nqueues--;
 }
@@ -158,28 +155,18 @@ static void nf_ct_frag6_secret_rebuild(u
 	get_random_bytes(&nf_ct_frag6_hash_rnd, sizeof(u32));
 	for (i =3D 0; i < FRAG6Q_HASHSZ; i++) {
 		struct nf_ct_frag6_queue *q;
+		struct hlist_node *p, *n;
=20
-		q =3D nf_ct_frag6_hash[i];
-		while (q) {
-			struct nf_ct_frag6_queue *next =3D q->next;
+		hlist_for_each_entry_safe(q, p, n, &nf_ct_frag6_hash[i], list) {
 			unsigned int hval =3D ip6qhashfn(q->id,
 						       &q->saddr,
 						       &q->daddr);
-
 			if (hval !=3D i) {
-				/* Unlink. */
-				if (q->next)
-					q->next->pprev =3D q->pprev;
-				*q->pprev =3D q->next;
-
+				hlist_del(&q->list);
 				/* Relink to new hash chain. */
-				if ((q->next =3D nf_ct_frag6_hash[hval]) !=3D NULL)
-					q->next->pprev =3D &q->next;
-				nf_ct_frag6_hash[hval] =3D q;
-				q->pprev =3D &nf_ct_frag6_hash[hval];
+				hlist_add_head(&q->list,
+					       &nf_ct_frag6_hash[hval]);
 			}
-
-			q =3D next;
 		}
 	}
 	write_unlock(&nf_ct_frag6_lock);
@@ -314,15 +301,17 @@ out:
=20
 /* Creation primitives. */
=20
-
 static struct nf_ct_frag6_queue *nf_ct_frag6_intern(unsigned int hash,
 					  struct nf_ct_frag6_queue *fq_in)
 {
 	struct nf_ct_frag6_queue *fq;
+#ifdef CONFIG_SMP
+	struct hlist_node *n;
+#endif
=20
 	write_lock(&nf_ct_frag6_lock);
 #ifdef CONFIG_SMP
-	for (fq =3D nf_ct_frag6_hash[hash]; fq; fq =3D fq->next) {
+	hlist_for_each_entry(fq, n, &nf_ct_frag6_hash[hash], list) {
 		if (fq->id =3D=3D fq_in->id &&=20
 		    !ipv6_addr_cmp(&fq_in->saddr, &fq->saddr) &&
 		    !ipv6_addr_cmp(&fq_in->daddr, &fq->daddr)) {
@@ -340,10 +329,7 @@ static struct nf_ct_frag6_queue *nf_ct_f
 		atomic_inc(&fq->refcnt);
=20
 	atomic_inc(&fq->refcnt);
-	if ((fq->next =3D nf_ct_frag6_hash[hash]) !=3D NULL)
-		fq->next->pprev =3D &fq->next;
-	nf_ct_frag6_hash[hash] =3D fq;
-	fq->pprev =3D &nf_ct_frag6_hash[hash];
+	hlist_add_head(&fq->list, &nf_ct_frag6_hash[hash]);
 	INIT_LIST_HEAD(&fq->lru_list);
 	list_add_tail(&fq->lru_list, &nf_ct_frag6_lru_list);
 	nf_ct_frag6_nqueues++;
@@ -384,10 +370,11 @@ static __inline__ struct nf_ct_frag6_que
 fq_find(u32 id, struct in6_addr *src, struct in6_addr *dst)
 {
 	struct nf_ct_frag6_queue *fq;
+	struct hlist_node *n;
 	unsigned int hash =3D ip6qhashfn(id, src, dst);
=20
 	read_lock(&nf_ct_frag6_lock);
-	for (fq =3D nf_ct_frag6_hash[hash]; fq; fq =3D fq->next) {
+	hlist_for_each_entry(fq, n, &nf_ct_frag6_hash[hash], list) {
 		if (fq->id =3D=3D id &&=20
 		    !ipv6_addr_cmp(src, &fq->saddr) &&
 		    !ipv6_addr_cmp(dst, &fq->daddr)) {
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 7d55f9c..99c0a0f 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -103,3 +103,261 @@ config NF_CT_NETLINK
 	  This option enables support for a netlink-based userspace interface
=20
 endmenu
+
+config NETFILTER_XTABLES
+	tristate "Netfilter Xtables support (required for ip_tables)"
+	help
+	  This is required if you intend to use any of ip_tables,
+	  ip6_tables or arp_tables.
+
+# alphabetically ordered list of targets
+
+config NETFILTER_XT_TARGET_CLASSIFY
+	tristate '"CLASSIFY" target support'
+	depends on NETFILTER_XTABLES
+	help
+	  This option adds a `CLASSIFY' target, which enables the user to set
+	  the priority of a packet. Some qdiscs can use this value for
+	  classification, among these are:
+
+  	  atm, cbq, dsmark, pfifo_fast, htb, prio
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
+config NETFILTER_XT_TARGET_CONNMARK
+	tristate  '"CONNMARK" target support'
+	depends on NETFILTER_XTABLES
+	depends on IP_NF_MANGLE || IP6_NF_MANGLE
+	depends on (IP_NF_CONNTRACK && IP_NF_CONNTRACK_MARK) || (NF_CONNTRACK_MAR=
K && NF_CONNTRACK_IPV4)
+	help
+	  This option adds a `CONNMARK' target, which allows one to manipulate
+	  the connection mark value.  Similar to the MARK target, but
+	  affects the connection mark value rather than the packet mark value.
+=09
+	  If you want to compile it as a module, say M here and read
+	  <file:Documentation/modules.txt>.  The module will be called
+	  ipt_CONNMARK.o.  If unsure, say `N'.
+
+config NETFILTER_XT_TARGET_MARK
+	tristate '"MARK" target support'
+	depends on NETFILTER_XTABLES
+	help
+	  This option adds a `MARK' target, which allows you to create rules
+	  in the `mangle' table which alter the netfilter mark (nfmark) field
+	  associated with the packet prior to routing. This can change
+	  the routing method (see `Use netfilter MARK value as routing
+	  key') and can also be used by other subsystems to change their
+	  behavior.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
+config NETFILTER_XT_TARGET_NFQUEUE
+	tristate '"NFQUEUE" target Support'
+	depends on NETFILTER_XTABLES
+	help
+	  This Target replaced the old obsolete QUEUE target.
+
+	  As opposed to QUEUE, it supports 65535 different queues,
+	  not just one.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
+config NETFILTER_XT_TARGET_NOTRACK
+	tristate  '"NOTRACK" target support'
+	depends on NETFILTER_XTABLES
+	depends on IP_NF_RAW || IP6_NF_RAW
+	depends on IP_NF_CONNTRACK || NF_CONNTRACK
+	help
+	  The NOTRACK target allows a select rule to specify
+	  which packets *not* to enter the conntrack/NAT
+	  subsystem with all the consequences (no ICMP error tracking,
+	  no protocol helpers for the selected packets).
+=09
+	  If you want to compile it as a module, say M here and read
+	  <file:Documentation/modules.txt>.  If unsure, say `N'.
+
+config NETFILTER_XT_MATCH_COMMENT
+	tristate  '"comment" match support'
+	depends on NETFILTER_XTABLES
+	help
+	  This option adds a `comment' dummy-match, which allows you to put
+	  comments in your iptables ruleset.
+
+	  If you want to compile it as a module, say M here and read
+	  <file:Documentation/modules.txt>.  If unsure, say `N'.
+
+config NETFILTER_XT_MATCH_CONNBYTES
+	tristate  '"connbytes" per-connection counter match support'
+	depends on NETFILTER_XTABLES
+	depends on (IP_NF_CONNTRACK && IP_NF_CT_ACCT) || NF_CT_ACCT
+	help
+	  This option adds a `connbytes' match, which allows you to match the
+	  number of bytes and/or packets for each direction within a connection.
+
+	  If you want to compile it as a module, say M here and read
+	  <file:Documentation/modules.txt>.  If unsure, say `N'.
+
+config NETFILTER_XT_MATCH_CONNMARK
+	tristate  '"connmark" connection mark match support'
+	depends on NETFILTER_XTABLES
+	depends on (IP_NF_CONNTRACK && IP_NF_CONNTRACK_MARK) || NF_CONNTRACK_MARK
+	help
+	  This option adds a `connmark' match, which allows you to match the
+	  connection mark value previously set for the session by `CONNMARK'.=20
+=09
+	  If you want to compile it as a module, say M here and read
+	  <file:Documentation/modules.txt>.  The module will be called
+	  ipt_connmark.o.  If unsure, say `N'.
+
+config NETFILTER_XT_MATCH_CONNTRACK
+	tristate '"conntrack" connection tracking match support'
+	depends on NETFILTER_XTABLES
+	depends on IP_NF_CONNTRACK || NF_CONNTRACK
+	help
+	  This is a general conntrack match module, a superset of the state match.
+
+	  It allows matching on additional conntrack information, which is
+	  useful in complex configurations, such as NAT gateways with multiple
+	  internet links or tunnels.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
+config NETFILTER_XT_MATCH_DCCP
+	tristate  '"DCCP" protocol match support'
+	depends on NETFILTER_XTABLES
+	help
+	  With this option enabled, you will be able to use the iptables
+	  `dccp' match in order to match on DCCP source/destination ports
+	  and DCCP flags.
+
+	  If you want to compile it as a module, say M here and read
+	  <file:Documentation/modules.txt>.  If unsure, say `N'.
+
+config NETFILTER_XT_MATCH_HELPER
+	tristate '"helper" match support'
+	depends on NETFILTER_XTABLES
+	depends on IP_NF_CONNTRACK || NF_CONNTRACK
+	help
+	  Helper matching allows you to match packets in dynamic connections
+	  tracked by a conntrack-helper, ie. ip_conntrack_ftp
+
+	  To compile it as a module, choose M here.  If unsure, say Y.
+
+config NETFILTER_XT_MATCH_LENGTH
+	tristate '"length" match support'
+	depends on NETFILTER_XTABLES
+	help
+	  This option allows you to match the length of a packet against a
+	  specific value or range of values.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
+config NETFILTER_XT_MATCH_LIMIT
+	tristate '"limit" match support'
+	depends on NETFILTER_XTABLES
+	help
+	  limit matching allows you to control the rate at which a rule can be
+	  matched: mainly useful in combination with the LOG target ("LOG
+	  target support", below) and to avoid some Denial of Service attacks.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
+config NETFILTER_XT_MATCH_MAC
+	tristate '"mac" address match support'
+	depends on NETFILTER_XTABLES
+	help
+	  MAC matching allows you to match packets based on the source
+	  Ethernet address of the packet.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
+config NETFILTER_XT_MATCH_MARK
+	tristate '"mark" match support'
+	depends on NETFILTER_XTABLES
+	help
+	  Netfilter mark matching allows you to match packets based on the
+	  `nfmark' value in the packet.  This can be set by the MARK target
+	  (see below).
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
+config NETFILTER_XT_MATCH_PHYSDEV
+	tristate '"physdev" match support'
+	depends on NETFILTER_XTABLES && BRIDGE_NETFILTER
+	help
+	  Physdev packet matching matches against the physical bridge ports
+	  the IP packet arrived on or will leave by.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
+config NETFILTER_XT_MATCH_PKTTYPE
+	tristate '"pkttype" packet type match support'
+	depends on NETFILTER_XTABLES
+	help
+	  Packet type matching allows you to match a packet by
+	  its "class", eg. BROADCAST, MULTICAST, ...
+
+	  Typical usage:
+	  iptables -A INPUT -m pkttype --pkt-type broadcast -j LOG
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
+config NETFILTER_XT_MATCH_REALM
+	tristate  '"realm" match support'
+	depends on NETFILTER_XTABLES
+	select NET_CLS_ROUTE
+	help
+	  This option adds a `realm' match, which allows you to use the realm
+	  key from the routing subsystem inside iptables.
+=09
+	  This match pretty much resembles the CONFIG_NET_CLS_ROUTE4 option=20
+	  in tc world.
+=09
+	  If you want to compile it as a module, say M here and read
+	  <file:Documentation/modules.txt>.  If unsure, say `N'.
+
+config NETFILTER_XT_MATCH_SCTP
+	tristate  '"sctp" protocol match support'
+	depends on NETFILTER_XTABLES
+	help
+	  With this option enabled, you will be able to use the=20
+	  `sctp' match in order to match on SCTP source/destination ports
+	  and SCTP chunk types.
+
+	  If you want to compile it as a module, say M here and read
+	  <file:Documentation/modules.txt>.  If unsure, say `N'.
+
+config NETFILTER_XT_MATCH_STATE
+	tristate '"state" match support'
+	depends on NETFILTER_XTABLES
+	depends on IP_NF_CONNTRACK || NF_CONNTRACK
+	help
+	  Connection state matching allows you to match packets based on their
+	  relationship to a tracked connection (ie. previous packets).  This
+	  is a powerful tool for packet classification.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
+config NETFILTER_XT_MATCH_STRING
+	tristate  '"string" match support'
+	depends on NETFILTER_XTABLES
+	select TEXTSEARCH
+	select TEXTSEARCH_KMP
+	select TEXTSEARCH_BM
+	select TEXTSEARCH_FSM
+	help
+	  This option adds a `string' match, which allows you to look for
+	  pattern matchings in packets.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
+config NETFILTER_XT_MATCH_TCPMSS
+	tristate '"tcpmss" match support'
+	depends on NETFILTER_XTABLES
+	help
+	  This option adds a `tcpmss' match, which allows you to examine the
+	  MSS value of TCP SYN packets, which control the maximum packet size
+	  for that connection.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index cb21831..746172e 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -1,4 +1,5 @@
 netfilter-objs :=3D core.o nf_log.o nf_queue.o nf_sockopt.o
+nf_conntrack-objs	:=3D nf_conntrack_core.o nf_conntrack_standalone.o nf_co=
nntrack_l3proto_generic.o nf_conntrack_proto_generic.o nf_conntrack_proto_t=
cp.o nf_conntrack_proto_udp.o
=20
 obj-$(CONFIG_NETFILTER) =3D netfilter.o
=20
@@ -6,13 +7,43 @@ obj-$(CONFIG_NETFILTER_NETLINK) +=3D nfnet
 obj-$(CONFIG_NETFILTER_NETLINK_QUEUE) +=3D nfnetlink_queue.o
 obj-$(CONFIG_NETFILTER_NETLINK_LOG) +=3D nfnetlink_log.o
=20
-nf_conntrack-objs	:=3D nf_conntrack_core.o nf_conntrack_standalone.o nf_co=
nntrack_l3proto_generic.o nf_conntrack_proto_generic.o nf_conntrack_proto_t=
cp.o nf_conntrack_proto_udp.o
-
+# connection tracking
 obj-$(CONFIG_NF_CONNTRACK) +=3D nf_conntrack.o
-obj-$(CONFIG_NF_CONNTRACK_FTP) +=3D nf_conntrack_ftp.o
=20
 # SCTP protocol connection tracking
 obj-$(CONFIG_NF_CT_PROTO_SCTP) +=3D nf_conntrack_proto_sctp.o
=20
 # netlink interface for nf_conntrack
 obj-$(CONFIG_NF_CT_NETLINK) +=3D nf_conntrack_netlink.o
+
+# connection tracking helpers
+obj-$(CONFIG_NF_CONNTRACK_FTP) +=3D nf_conntrack_ftp.o
+
+# generic X tables=20
+obj-$(CONFIG_NETFILTER_XTABLES) +=3D x_tables.o xt_tcpudp.o
+
+# targets
+obj-$(CONFIG_NETFILTER_XT_TARGET_CLASSIFY) +=3D xt_CLASSIFY.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_CONNMARK) +=3D xt_CONNMARK.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_MARK) +=3D xt_MARK.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_NFQUEUE) +=3D xt_NFQUEUE.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_NOTRACK) +=3D xt_NOTRACK.o
+
+# matches
+obj-$(CONFIG_NETFILTER_XT_MATCH_COMMENT) +=3D xt_comment.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_CONNBYTES) +=3D xt_connbytes.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_CONNMARK) +=3D xt_connmark.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_CONNTRACK) +=3D xt_conntrack.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_DCCP) +=3D xt_dccp.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_HELPER) +=3D xt_helper.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_LENGTH) +=3D xt_length.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_LIMIT) +=3D xt_limit.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_MAC) +=3D xt_mac.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_MARK) +=3D xt_mark.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_PKTTYPE) +=3D xt_pkttype.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_REALM) +=3D xt_realm.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_SCTP) +=3D xt_sctp.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_STATE) +=3D xt_state.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_STRING) +=3D xt_string.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_TCPMSS) +=3D xt_tcpmss.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_PHYSDEV) +=3D xt_physdev.o
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_con=
ntrack_standalone.c
index 3531d14..617599a 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -821,7 +821,7 @@ module_exit(fini);
=20
 /* Some modules need us, but don't depend directly on any symbol.
    They should call this. */
-void need_nf_conntrack(void)
+void need_conntrack(void)
 {
 }
=20
@@ -841,7 +841,7 @@ EXPORT_SYMBOL(nf_conntrack_protocol_unre
 EXPORT_SYMBOL(nf_ct_invert_tuplepr);
 EXPORT_SYMBOL(nf_conntrack_alter_reply);
 EXPORT_SYMBOL(nf_conntrack_destroyed);
-EXPORT_SYMBOL(need_nf_conntrack);
+EXPORT_SYMBOL(need_conntrack);
 EXPORT_SYMBOL(nf_conntrack_helper_register);
 EXPORT_SYMBOL(nf_conntrack_helper_unregister);
 EXPORT_SYMBOL(nf_ct_iterate_cleanup);
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
new file mode 100644
index 0000000..d7817af
--- /dev/null
+++ b/net/netfilter/x_tables.c
@@ -0,0 +1,624 @@
+/*
+ * x_tables core - Backend for {ip,ip6,arp}_tables
+ *
+ * Copyright (C) 2006-2006 Harald Welte <laforge@netfilter.org>
+ *
+ * Based on existing ip_tables code which is
+ *   Copyright (C) 1999 Paul `Rusty' Russell & Michael J. Neuling
+ *   Copyright (C) 2000-2005 Netfilter Core Team <coreteam@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/socket.h>
+#include <linux/net.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+#include <linux/string.h>
+#include <linux/vmalloc.h>
+
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter_arp.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
+MODULE_DESCRIPTION("[ip,ip6,arp]_tables backend module");
+
+#define SMP_ALIGN(x) (((x) + SMP_CACHE_BYTES-1) & ~(SMP_CACHE_BYTES-1))
+
+struct xt_af {
+	struct semaphore mutex;
+	struct list_head match;
+	struct list_head target;
+	struct list_head tables;
+};
+
+static struct xt_af *xt;
+
+#ifdef DEBUG_IP_FIREWALL_USER
+#define duprintf(format, args...) printk(format , ## args)
+#else
+#define duprintf(format, args...)
+#endif
+
+enum {
+	TABLE,
+	TARGET,
+	MATCH,
+};
+
+/* Registration hooks for targets. */
+int
+xt_register_target(int af, struct xt_target *target)
+{
+	int ret;
+
+	ret =3D down_interruptible(&xt[af].mutex);
+	if (ret !=3D 0)
+		return ret;
+	list_add(&target->list, &xt[af].target);
+	up(&xt[af].mutex);
+	return ret;
+}
+EXPORT_SYMBOL(xt_register_target);
+
+void
+xt_unregister_target(int af, struct xt_target *target)
+{
+	down(&xt[af].mutex);
+	LIST_DELETE(&xt[af].target, target);
+	up(&xt[af].mutex);
+}
+EXPORT_SYMBOL(xt_unregister_target);
+
+int
+xt_register_match(int af, struct xt_match *match)
+{
+	int ret;
+
+	ret =3D down_interruptible(&xt[af].mutex);
+	if (ret !=3D 0)
+		return ret;
+
+	list_add(&match->list, &xt[af].match);
+	up(&xt[af].mutex);
+
+	return ret;
+}
+EXPORT_SYMBOL(xt_register_match);
+
+void
+xt_unregister_match(int af, struct xt_match *match)
+{
+	down(&xt[af].mutex);
+	LIST_DELETE(&xt[af].match, match);
+	up(&xt[af].mutex);
+}
+EXPORT_SYMBOL(xt_unregister_match);
+
+
+/*
+ * These are weird, but module loading must not be done with mutex
+ * held (since they will register), and we have to have a single
+ * function to use try_then_request_module().
+ */
+
+/* Find match, grabs ref.  Returns ERR_PTR() on error. */
+struct xt_match *xt_find_match(int af, const char *name, u8 revision)
+{
+	struct xt_match *m;
+	int err =3D 0;
+
+	if (down_interruptible(&xt[af].mutex) !=3D 0)
+		return ERR_PTR(-EINTR);
+
+	list_for_each_entry(m, &xt[af].match, list) {
+		if (strcmp(m->name, name) =3D=3D 0) {
+			if (m->revision =3D=3D revision) {
+				if (try_module_get(m->me)) {
+					up(&xt[af].mutex);
+					return m;
+				}
+			} else
+				err =3D -EPROTOTYPE; /* Found something. */
+		}
+	}
+	up(&xt[af].mutex);
+	return ERR_PTR(err);
+}
+EXPORT_SYMBOL(xt_find_match);
+
+/* Find target, grabs ref.  Returns ERR_PTR() on error. */
+struct xt_target *xt_find_target(int af, const char *name, u8 revision)
+{
+	struct xt_target *t;
+	int err =3D 0;
+
+	if (down_interruptible(&xt[af].mutex) !=3D 0)
+		return ERR_PTR(-EINTR);
+
+	list_for_each_entry(t, &xt[af].target, list) {
+		if (strcmp(t->name, name) =3D=3D 0) {
+			if (t->revision =3D=3D revision) {
+				if (try_module_get(t->me)) {
+					up(&xt[af].mutex);
+					return t;
+				}
+			} else
+				err =3D -EPROTOTYPE; /* Found something. */
+		}
+	}
+	up(&xt[af].mutex);
+	return ERR_PTR(err);
+}
+EXPORT_SYMBOL(xt_find_target);
+
+static const char *xt_prefix[NPROTO] =3D {
+	[AF_INET] 	=3D "ipt_%s",
+	[AF_INET6] 	=3D "ip6t_%s",
+	[NF_ARP]	=3D "arpt_%s",
+};
+
+struct xt_target *xt_request_find_target(int af, const char *name, u8 revi=
sion)
+{
+	struct xt_target *target;
+
+	target =3D try_then_request_module(xt_find_target(af, name, revision),
+					 xt_prefix[af], name);
+	if (IS_ERR(target) || !target)
+		return NULL;
+	return target;
+}
+EXPORT_SYMBOL_GPL(xt_request_find_target);
+
+static int match_revfn(int af, const char *name, u8 revision, int *bestp)
+{
+	struct xt_match *m;
+	int have_rev =3D 0;
+
+	list_for_each_entry(m, &xt[af].match, list) {
+		if (strcmp(m->name, name) =3D=3D 0) {
+			if (m->revision > *bestp)
+				*bestp =3D m->revision;
+			if (m->revision =3D=3D revision)
+				have_rev =3D 1;
+		}
+	}
+	return have_rev;
+}
+
+static int target_revfn(int af, const char *name, u8 revision, int *bestp)
+{
+	struct xt_target *t;
+	int have_rev =3D 0;
+
+	list_for_each_entry(t, &xt[af].target, list) {
+		if (strcmp(t->name, name) =3D=3D 0) {
+			if (t->revision > *bestp)
+				*bestp =3D t->revision;
+			if (t->revision =3D=3D revision)
+				have_rev =3D 1;
+		}
+	}
+	return have_rev;
+}
+
+/* Returns true or false (if no such extension at all) */
+int xt_find_revision(int af, const char *name, u8 revision, int target,
+		     int *err)
+{
+	int have_rev, best =3D -1;
+
+	if (down_interruptible(&xt[af].mutex) !=3D 0) {
+		*err =3D -EINTR;
+		return 1;
+	}
+	if (target =3D=3D 1)
+		have_rev =3D target_revfn(af, name, revision, &best);
+	else
+		have_rev =3D match_revfn(af, name, revision, &best);
+	up(&xt[af].mutex);
+
+	/* Nothing at all?  Return 0 to try loading module. */
+	if (best =3D=3D -1) {
+		*err =3D -ENOENT;
+		return 0;
+	}
+
+	*err =3D best;
+	if (!have_rev)
+		*err =3D -EPROTONOSUPPORT;
+	return 1;
+}
+EXPORT_SYMBOL_GPL(xt_find_revision);
+
+struct xt_table_info *xt_alloc_table_info(unsigned int size)
+{
+	struct xt_table_info *newinfo;
+	int cpu;
+
+	/* Pedantry: prevent them from hitting BUG() in vmalloc.c --RR */
+	if ((SMP_ALIGN(size) >> PAGE_SHIFT) + 2 > num_physpages)
+		return NULL;
+
+	newinfo =3D kzalloc(sizeof(struct xt_table_info), GFP_KERNEL);
+	if (!newinfo)
+		return NULL;
+
+	newinfo->size =3D size;
+
+	for_each_cpu(cpu) {
+		if (size <=3D PAGE_SIZE)
+			newinfo->entries[cpu] =3D kmalloc_node(size,
+							GFP_KERNEL,
+							cpu_to_node(cpu));
+		else
+			newinfo->entries[cpu] =3D vmalloc_node(size,
+							cpu_to_node(cpu));
+
+		if (newinfo->entries[cpu] =3D=3D NULL) {
+			xt_free_table_info(newinfo);
+			return NULL;
+		}
+	}
+
+	return newinfo;
+}
+EXPORT_SYMBOL(xt_alloc_table_info);
+
+void xt_free_table_info(struct xt_table_info *info)
+{
+	int cpu;
+
+	for_each_cpu(cpu) {
+		if (info->size <=3D PAGE_SIZE)
+			kfree(info->entries[cpu]);
+		else
+			vfree(info->entries[cpu]);
+	}
+	kfree(info);
+}
+EXPORT_SYMBOL(xt_free_table_info);
+
+/* Find table by name, grabs mutex & ref.  Returns ERR_PTR() on error. */
+struct xt_table *xt_find_table_lock(int af, const char *name)
+{
+	struct xt_table *t;
+
+	if (down_interruptible(&xt[af].mutex) !=3D 0)
+		return ERR_PTR(-EINTR);
+
+	list_for_each_entry(t, &xt[af].tables, list)
+		if (strcmp(t->name, name) =3D=3D 0 && try_module_get(t->me))
+			return t;
+	up(&xt[af].mutex);
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(xt_find_table_lock);
+
+void xt_table_unlock(struct xt_table *table)
+{
+	up(&xt[table->af].mutex);
+}
+EXPORT_SYMBOL_GPL(xt_table_unlock);
+
+
+struct xt_table_info *
+xt_replace_table(struct xt_table *table,
+	      unsigned int num_counters,
+	      struct xt_table_info *newinfo,
+	      int *error)
+{
+	struct xt_table_info *oldinfo, *private;
+
+	/* Do the substitution. */
+	write_lock_bh(&table->lock);
+	private =3D table->private;
+	/* Check inside lock: is the old number correct? */
+	if (num_counters !=3D private->number) {
+		duprintf("num_counters !=3D table->private->number (%u/%u)\n",
+			 num_counters, private->number);
+		write_unlock_bh(&table->lock);
+		*error =3D -EAGAIN;
+		return NULL;
+	}
+	oldinfo =3D private;
+	table->private =3D newinfo;
+	newinfo->initial_entries =3D oldinfo->initial_entries;
+	write_unlock_bh(&table->lock);
+
+	return oldinfo;
+}
+EXPORT_SYMBOL_GPL(xt_replace_table);
+
+int xt_register_table(struct xt_table *table,
+		      struct xt_table_info *bootstrap,
+		      struct xt_table_info *newinfo)
+{
+	int ret;
+	struct xt_table_info *private;
+
+	ret =3D down_interruptible(&xt[table->af].mutex);
+	if (ret !=3D 0)
+		return ret;
+
+	/* Don't autoload: we'd eat our tail... */
+	if (list_named_find(&xt[table->af].tables, table->name)) {
+		ret =3D -EEXIST;
+		goto unlock;
+	}
+
+	/* Simplifies replace_table code. */
+	table->private =3D bootstrap;
+	if (!xt_replace_table(table, 0, newinfo, &ret))
+		goto unlock;
+
+	private =3D table->private;
+	duprintf("table->private->number =3D %u\n", private->number);
+
+	/* save number of initial entries */
+	private->initial_entries =3D private->number;
+
+	rwlock_init(&table->lock);
+	list_prepend(&xt[table->af].tables, table);
+
+	ret =3D 0;
+ unlock:
+	up(&xt[table->af].mutex);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(xt_register_table);
+
+void *xt_unregister_table(struct xt_table *table)
+{
+	struct xt_table_info *private;
+
+	down(&xt[table->af].mutex);
+	private =3D table->private;
+	LIST_DELETE(&xt[table->af].tables, table);
+	up(&xt[table->af].mutex);
+
+	return private;
+}
+EXPORT_SYMBOL_GPL(xt_unregister_table);
+
+#ifdef CONFIG_PROC_FS
+static char *xt_proto_prefix[NPROTO] =3D {
+	[AF_INET]	=3D "ip",
+	[AF_INET6]	=3D "ip6",
+	[NF_ARP]	=3D "arp",
+};
+
+static struct list_head *xt_get_idx(struct list_head *list, struct seq_fil=
e *seq, loff_t pos)
+{
+	struct list_head *head =3D list->next;
+
+	if (!head || list_empty(list))
+		return NULL;
+
+	while (pos && (head =3D head->next)) {
+		if (head =3D=3D list)
+			return NULL;
+		pos--;
+	}
+	return pos ? NULL : head;
+}
+
+static struct list_head *type2list(u_int16_t af, u_int16_t type)
+{
+	struct list_head *list;
+
+	switch (type) {
+	case TARGET:
+		list =3D &xt[af].target;
+		break;
+	case MATCH:
+		list =3D &xt[af].match;
+		break;
+	case TABLE:
+		list =3D &xt[af].tables;
+		break;
+	default:
+		list =3D NULL;
+		break;
+	}
+
+	return list;
+}
+
+static void *xt_tgt_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	struct proc_dir_entry *pde =3D (struct proc_dir_entry *) seq->private;
+	u_int16_t af =3D (unsigned long)pde->data & 0xffff;
+	u_int16_t type =3D (unsigned long)pde->data >> 16;
+	struct list_head *list;
+
+	if (af >=3D NPROTO)
+		return NULL;
+
+	list =3D type2list(af, type);
+	if (!list)
+		return NULL;
+
+	if (down_interruptible(&xt[af].mutex) !=3D 0)
+		return NULL;
+=09
+	return xt_get_idx(list, seq, *pos);
+}
+
+static void *xt_tgt_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct proc_dir_entry *pde =3D seq->private;
+	u_int16_t af =3D (unsigned long)pde->data & 0xffff;
+	u_int16_t type =3D (unsigned long)pde->data >> 16;
+	struct list_head *list;
+
+	if (af >=3D NPROTO)
+		return NULL;
+=09
+	list =3D type2list(af, type);
+	if (!list)
+		return NULL;
+
+	(*pos)++;
+	return xt_get_idx(list, seq, *pos);
+}
+
+static void xt_tgt_seq_stop(struct seq_file *seq, void *v)
+{
+	struct proc_dir_entry *pde =3D seq->private;
+	u_int16_t af =3D (unsigned long)pde->data & 0xffff;
+
+	up(&xt[af].mutex);
+}
+
+static int xt_name_seq_show(struct seq_file *seq, void *v)
+{
+	char *name =3D (char *)v + sizeof(struct list_head);
+
+	if (strlen(name))
+		return seq_printf(seq, "%s\n", name);
+	else
+		return 0;
+}
+
+static struct seq_operations xt_tgt_seq_ops =3D {
+	.start	=3D xt_tgt_seq_start,
+	.next	=3D xt_tgt_seq_next,
+	.stop	=3D xt_tgt_seq_stop,
+	.show	=3D xt_name_seq_show,
+};
+
+static int xt_tgt_open(struct inode *inode, struct file *file)
+{
+	int ret;
+
+	ret =3D seq_open(file, &xt_tgt_seq_ops);
+	if (!ret) {
+		struct seq_file *seq =3D file->private_data;
+		struct proc_dir_entry *pde =3D PDE(inode);
+
+		seq->private =3D pde;
+	}
+
+	return ret;
+}
+
+static struct file_operations xt_file_ops =3D {
+	.owner	 =3D THIS_MODULE,
+	.open	 =3D xt_tgt_open,
+	.read	 =3D seq_read,
+	.llseek	 =3D seq_lseek,
+	.release =3D seq_release,
+};
+
+#define FORMAT_TABLES	"_tables_names"
+#define	FORMAT_MATCHES	"_tables_matches"
+#define FORMAT_TARGETS 	"_tables_targets"
+
+#endif /* CONFIG_PROC_FS */
+
+int xt_proto_init(int af)
+{
+#ifdef CONFIG_PROC_FS
+	char buf[XT_FUNCTION_MAXNAMELEN];
+	struct proc_dir_entry *proc;
+#endif
+
+	if (af >=3D NPROTO)
+		return -EINVAL;
+
+
+#ifdef CONFIG_PROC_FS
+	strlcpy(buf, xt_proto_prefix[af], sizeof(buf));
+	strlcat(buf, FORMAT_TABLES, sizeof(buf));
+	proc =3D proc_net_fops_create(buf, 0440, &xt_file_ops);
+	if (!proc)
+		goto out;
+	proc->data =3D (void *) ((unsigned long) af | (TABLE << 16));
+
+
+	strlcpy(buf, xt_proto_prefix[af], sizeof(buf));
+	strlcat(buf, FORMAT_MATCHES, sizeof(buf));
+	proc =3D proc_net_fops_create(buf, 0440, &xt_file_ops);
+	if (!proc)
+		goto out_remove_tables;
+	proc->data =3D (void *) ((unsigned long) af | (MATCH << 16));
+
+	strlcpy(buf, xt_proto_prefix[af], sizeof(buf));
+	strlcat(buf, FORMAT_TARGETS, sizeof(buf));
+	proc =3D proc_net_fops_create(buf, 0440, &xt_file_ops);
+	if (!proc)
+		goto out_remove_matches;
+	proc->data =3D (void *) ((unsigned long) af | (TARGET << 16));
+#endif
+
+	return 0;
+
+#ifdef CONFIG_PROC_FS
+out_remove_matches:
+	strlcpy(buf, xt_proto_prefix[af], sizeof(buf));
+	strlcat(buf, FORMAT_MATCHES, sizeof(buf));
+	proc_net_remove(buf);
+
+out_remove_tables:
+	strlcpy(buf, xt_proto_prefix[af], sizeof(buf));
+	strlcat(buf, FORMAT_TABLES, sizeof(buf));
+	proc_net_remove(buf);
+out:
+	return -1;
+#endif
+}
+EXPORT_SYMBOL_GPL(xt_proto_init);
+
+void xt_proto_fini(int af)
+{
+#ifdef CONFIG_PROC_FS
+	char buf[XT_FUNCTION_MAXNAMELEN];
+
+	strlcpy(buf, xt_proto_prefix[af], sizeof(buf));
+	strlcat(buf, FORMAT_TABLES, sizeof(buf));
+	proc_net_remove(buf);
+
+	strlcpy(buf, xt_proto_prefix[af], sizeof(buf));
+	strlcat(buf, FORMAT_TARGETS, sizeof(buf));
+	proc_net_remove(buf);
+
+	strlcpy(buf, xt_proto_prefix[af], sizeof(buf));
+	strlcat(buf, FORMAT_MATCHES, sizeof(buf));
+	proc_net_remove(buf);
+#endif /*CONFIG_PROC_FS*/
+}
+EXPORT_SYMBOL_GPL(xt_proto_fini);
+
+
+static int __init xt_init(void)
+{
+	int i;
+
+	xt =3D kmalloc(sizeof(struct xt_af) * NPROTO, GFP_KERNEL);
+	if (!xt)
+		return -ENOMEM;
+
+	for (i =3D 0; i < NPROTO; i++) {
+		init_MUTEX(&xt[i].mutex);
+		INIT_LIST_HEAD(&xt[i].target);
+		INIT_LIST_HEAD(&xt[i].match);
+		INIT_LIST_HEAD(&xt[i].tables);
+	}
+	return 0;
+}
+
+static void __exit xt_fini(void)
+{
+	kfree(xt);
+}
+
+module_init(xt_init);
+module_exit(xt_fini);
+
diff --git a/net/netfilter/xt_CLASSIFY.c b/net/netfilter/xt_CLASSIFY.c
new file mode 100644
index 0000000..78ee266
--- /dev/null
+++ b/net/netfilter/xt_CLASSIFY.c
@@ -0,0 +1,109 @@
+/*
+ * This is a module which is used for setting the skb->priority field
+ * of an skb for qdisc classification.
+ */
+
+/* (C) 2001-2002 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <net/checksum.h>
+
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_CLASSIFY.h>
+
+MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("iptables qdisc classification target module");
+MODULE_ALIAS("ipt_CLASSIFY");
+
+static unsigned int
+target(struct sk_buff **pskb,
+       const struct net_device *in,
+       const struct net_device *out,
+       unsigned int hooknum,
+       const void *targinfo,
+       void *userinfo)
+{
+	const struct xt_classify_target_info *clinfo =3D targinfo;
+
+	if ((*pskb)->priority !=3D clinfo->priority)
+		(*pskb)->priority =3D clinfo->priority;
+
+	return XT_CONTINUE;
+}
+
+static int
+checkentry(const char *tablename,
+           const void *e,
+           void *targinfo,
+           unsigned int targinfosize,
+           unsigned int hook_mask)
+{
+	if (targinfosize !=3D XT_ALIGN(sizeof(struct xt_classify_target_info))){
+		printk(KERN_ERR "CLASSIFY: invalid size (%u !=3D %Zu).\n",
+		       targinfosize,
+		       XT_ALIGN(sizeof(struct xt_classify_target_info)));
+		return 0;
+	}
+=09
+	if (hook_mask & ~((1 << NF_IP_LOCAL_OUT) | (1 << NF_IP_FORWARD) |
+	                  (1 << NF_IP_POST_ROUTING))) {
+		printk(KERN_ERR "CLASSIFY: only valid in LOCAL_OUT, FORWARD "
+		                "and POST_ROUTING.\n");
+		return 0;
+	}
+
+	if (strcmp(tablename, "mangle") !=3D 0) {
+		printk(KERN_ERR "CLASSIFY: can only be called from "
+		                "\"mangle\" table, not \"%s\".\n",
+		                tablename);
+		return 0;
+	}
+
+	return 1;
+}
+
+static struct xt_target classify_reg =3D {=20
+	.name 		=3D "CLASSIFY",=20
+	.target 	=3D target,
+	.checkentry	=3D checkentry,
+	.me 		=3D THIS_MODULE,
+};
+static struct xt_target classify6_reg =3D {=20
+	.name 		=3D "CLASSIFY",=20
+	.target 	=3D target,
+	.checkentry	=3D checkentry,
+	.me 		=3D THIS_MODULE,
+};
+
+
+static int __init init(void)
+{
+	int ret;
+
+	ret =3D xt_register_target(AF_INET, &classify_reg);
+	if (ret)
+		return ret;
+
+	ret =3D xt_register_target(AF_INET6, &classify6_reg);
+	if (ret)
+		xt_unregister_target(AF_INET, &classify_reg);
+
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_target(AF_INET, &classify_reg);
+	xt_unregister_target(AF_INET6, &classify6_reg);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/netfilter/xt_CONNMARK.c b/net/netfilter/xt_CONNMARK.c
new file mode 100644
index 0000000..22506e3
--- /dev/null
+++ b/net/netfilter/xt_CONNMARK.c
@@ -0,0 +1,141 @@
+/* This kernel module is used to modify the connection mark values, or
+ * to optionally restore the skb nfmark from the connection mark
+ *
+ * Copyright (C) 2002,2004 MARA Systems AB <http://www.marasystems.com>
+ * by Henrik Nordstrom <hno@marasystems.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  U=
SA
+ */
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <net/checksum.h>
+
+MODULE_AUTHOR("Henrik Nordstrom <hno@marasytems.com>");
+MODULE_DESCRIPTION("IP tables CONNMARK matching module");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("ipt_CONNMARK");
+
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_CONNMARK.h>
+#include <net/netfilter/nf_conntrack_compat.h>
+
+static unsigned int
+target(struct sk_buff **pskb,
+       const struct net_device *in,
+       const struct net_device *out,
+       unsigned int hooknum,
+       const void *targinfo,
+       void *userinfo)
+{
+	const struct xt_connmark_target_info *markinfo =3D targinfo;
+	u_int32_t diff;
+	u_int32_t nfmark;
+	u_int32_t newmark;
+	u_int32_t ctinfo;
+	u_int32_t *ctmark =3D nf_ct_get_mark(*pskb, &ctinfo);
+
+	if (ctmark) {
+	    switch(markinfo->mode) {
+	    case XT_CONNMARK_SET:
+		newmark =3D (*ctmark & ~markinfo->mask) | markinfo->mark;
+		if (newmark !=3D *ctmark)
+		    *ctmark =3D newmark;
+		break;
+	    case XT_CONNMARK_SAVE:
+		newmark =3D (*ctmark & ~markinfo->mask) | ((*pskb)->nfmark & markinfo->m=
ask);
+		if (*ctmark !=3D newmark)
+		    *ctmark =3D newmark;
+		break;
+	    case XT_CONNMARK_RESTORE:
+		nfmark =3D (*pskb)->nfmark;
+		diff =3D (*ctmark ^ nfmark) & markinfo->mask;
+		if (diff !=3D 0)
+		    (*pskb)->nfmark =3D nfmark ^ diff;
+		break;
+	    }
+	}
+
+	return XT_CONTINUE;
+}
+
+static int
+checkentry(const char *tablename,
+	   const void *entry,
+	   void *targinfo,
+	   unsigned int targinfosize,
+	   unsigned int hook_mask)
+{
+	struct xt_connmark_target_info *matchinfo =3D targinfo;
+	if (targinfosize !=3D XT_ALIGN(sizeof(struct xt_connmark_target_info))) {
+		printk(KERN_WARNING "CONNMARK: targinfosize %u !=3D %Zu\n",
+		       targinfosize,
+		       XT_ALIGN(sizeof(struct xt_connmark_target_info)));
+		return 0;
+	}
+
+	if (matchinfo->mode =3D=3D XT_CONNMARK_RESTORE) {
+	    if (strcmp(tablename, "mangle") !=3D 0) {
+		    printk(KERN_WARNING "CONNMARK: restore can only be called from \"man=
gle\" table, not \"%s\"\n", tablename);
+		    return 0;
+	    }
+	}
+
+	if (matchinfo->mark > 0xffffffff || matchinfo->mask > 0xffffffff) {
+		printk(KERN_WARNING "CONNMARK: Only supports 32bit mark\n");
+		return 0;
+	}
+
+	return 1;
+}
+
+static struct xt_target connmark_reg =3D {
+	.name =3D "CONNMARK",
+	.target =3D &target,
+	.checkentry =3D &checkentry,
+	.me =3D THIS_MODULE
+};
+static struct xt_target connmark6_reg =3D {
+	.name =3D "CONNMARK",
+	.target =3D &target,
+	.checkentry =3D &checkentry,
+	.me =3D THIS_MODULE
+};
+
+static int __init init(void)
+{
+	int ret;
+
+	need_conntrack();
+
+	ret =3D xt_register_target(AF_INET, &connmark_reg);
+	if (ret)
+		return ret;
+
+	ret =3D xt_register_target(AF_INET6, &connmark6_reg);
+	if (ret)
+		xt_unregister_target(AF_INET, &connmark_reg);
+
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_target(AF_INET, &connmark_reg);
+	xt_unregister_target(AF_INET6, &connmark6_reg);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/netfilter/xt_MARK.c b/net/netfilter/xt_MARK.c
new file mode 100644
index 0000000..0c11ee9
--- /dev/null
+++ b/net/netfilter/xt_MARK.c
@@ -0,0 +1,191 @@
+/* This is a module which is used for setting the NFMARK field of an skb. =
*/
+
+/* (C) 1999-2001 Marc Boucher <marc@mbsi.ca>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <net/checksum.h>
+
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_MARK.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Marc Boucher <marc@mbsi.ca>");
+MODULE_DESCRIPTION("ip[6]tables MARK modification module");
+MODULE_ALIAS("ipt_MARK");
+MODULE_ALIAS("ip6t_MARK");
+
+static unsigned int
+target_v0(struct sk_buff **pskb,
+	  const struct net_device *in,
+	  const struct net_device *out,
+	  unsigned int hooknum,
+	  const void *targinfo,
+	  void *userinfo)
+{
+	const struct xt_mark_target_info *markinfo =3D targinfo;
+
+	if((*pskb)->nfmark !=3D markinfo->mark)
+		(*pskb)->nfmark =3D markinfo->mark;
+
+	return XT_CONTINUE;
+}
+
+static unsigned int
+target_v1(struct sk_buff **pskb,
+	  const struct net_device *in,
+	  const struct net_device *out,
+	  unsigned int hooknum,
+	  const void *targinfo,
+	  void *userinfo)
+{
+	const struct xt_mark_target_info_v1 *markinfo =3D targinfo;
+	int mark =3D 0;
+
+	switch (markinfo->mode) {
+	case XT_MARK_SET:
+		mark =3D markinfo->mark;
+		break;
+	=09
+	case XT_MARK_AND:
+		mark =3D (*pskb)->nfmark & markinfo->mark;
+		break;
+	=09
+	case XT_MARK_OR:
+		mark =3D (*pskb)->nfmark | markinfo->mark;
+		break;
+	}
+
+	if((*pskb)->nfmark !=3D mark)
+		(*pskb)->nfmark =3D mark;
+
+	return XT_CONTINUE;
+}
+
+
+static int
+checkentry_v0(const char *tablename,
+	      const void *entry,
+	      void *targinfo,
+	      unsigned int targinfosize,
+	      unsigned int hook_mask)
+{
+	struct xt_mark_target_info *markinfo =3D targinfo;
+
+	if (targinfosize !=3D XT_ALIGN(sizeof(struct xt_mark_target_info))) {
+		printk(KERN_WARNING "MARK: targinfosize %u !=3D %Zu\n",
+		       targinfosize,
+		       XT_ALIGN(sizeof(struct xt_mark_target_info)));
+		return 0;
+	}
+
+	if (strcmp(tablename, "mangle") !=3D 0) {
+		printk(KERN_WARNING "MARK: can only be called from \"mangle\" table, not=
 \"%s\"\n", tablename);
+		return 0;
+	}
+
+	if (markinfo->mark > 0xffffffff) {
+		printk(KERN_WARNING "MARK: Only supports 32bit wide mark\n");
+		return 0;
+	}
+
+	return 1;
+}
+
+static int
+checkentry_v1(const char *tablename,
+	      const void *entry,
+	      void *targinfo,
+	      unsigned int targinfosize,
+	      unsigned int hook_mask)
+{
+	struct xt_mark_target_info_v1 *markinfo =3D targinfo;
+
+	if (targinfosize !=3D XT_ALIGN(sizeof(struct xt_mark_target_info_v1))){
+		printk(KERN_WARNING "MARK: targinfosize %u !=3D %Zu\n",
+		       targinfosize,
+		       XT_ALIGN(sizeof(struct xt_mark_target_info_v1)));
+		return 0;
+	}
+
+	if (strcmp(tablename, "mangle") !=3D 0) {
+		printk(KERN_WARNING "MARK: can only be called from \"mangle\" table, not=
 \"%s\"\n", tablename);
+		return 0;
+	}
+
+	if (markinfo->mode !=3D XT_MARK_SET
+	    && markinfo->mode !=3D XT_MARK_AND
+	    && markinfo->mode !=3D XT_MARK_OR) {
+		printk(KERN_WARNING "MARK: unknown mode %u\n",
+		       markinfo->mode);
+		return 0;
+	}
+
+	if (markinfo->mark > 0xffffffff) {
+		printk(KERN_WARNING "MARK: Only supports 32bit wide mark\n");
+		return 0;
+	}
+
+	return 1;
+}
+
+static struct xt_target ipt_mark_reg_v0 =3D {
+	.name		=3D "MARK",
+	.target		=3D target_v0,
+	.checkentry	=3D checkentry_v0,
+	.me		=3D THIS_MODULE,
+	.revision	=3D 0,
+};
+
+static struct xt_target ipt_mark_reg_v1 =3D {
+	.name		=3D "MARK",
+	.target		=3D target_v1,
+	.checkentry	=3D checkentry_v1,
+	.me		=3D THIS_MODULE,
+	.revision	=3D 1,
+};
+
+static struct xt_target ip6t_mark_reg_v0 =3D {
+	.name		=3D "MARK",
+	.target		=3D target_v0,
+	.checkentry	=3D checkentry_v0,
+	.me		=3D THIS_MODULE,
+	.revision	=3D 0,
+};
+
+static int __init init(void)
+{
+	int err;
+
+	err =3D xt_register_target(AF_INET, &ipt_mark_reg_v0);
+	if (err)
+		return err;
+
+	err =3D xt_register_target(AF_INET, &ipt_mark_reg_v1);
+	if (err)
+		xt_unregister_target(AF_INET, &ipt_mark_reg_v0);
+
+	err =3D xt_register_target(AF_INET6, &ip6t_mark_reg_v0);
+	if (err) {
+		xt_unregister_target(AF_INET, &ipt_mark_reg_v0);
+		xt_unregister_target(AF_INET, &ipt_mark_reg_v1);
+	}
+
+	return err;
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_target(AF_INET, &ipt_mark_reg_v0);
+	xt_unregister_target(AF_INET, &ipt_mark_reg_v1);
+	xt_unregister_target(AF_INET6, &ip6t_mark_reg_v0);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
new file mode 100644
index 0000000..8b76b6f
--- /dev/null
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -0,0 +1,107 @@
+/* iptables module for using new netfilter netlink queue
+ *
+ * (C) 2005 by Harald Welte <laforge@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as=20
+ * published by the Free Software Foundation.
+ *=20
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+
+#include <linux/netfilter.h>
+#include <linux/netfilter_arp.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_NFQUEUE.h>
+
+MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
+MODULE_DESCRIPTION("[ip,ip6,arp]_tables NFQUEUE target");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("ipt_NFQUEUE");
+MODULE_ALIAS("ip6t_NFQUEUE");
+MODULE_ALIAS("arpt_NFQUEUE");
+
+static unsigned int
+target(struct sk_buff **pskb,
+       const struct net_device *in,
+       const struct net_device *out,
+       unsigned int hooknum,
+       const void *targinfo,
+       void *userinfo)
+{
+	const struct xt_NFQ_info *tinfo =3D targinfo;
+
+	return NF_QUEUE_NR(tinfo->queuenum);
+}
+
+static int
+checkentry(const char *tablename,
+	   const void *entry,
+           void *targinfo,
+           unsigned int targinfosize,
+           unsigned int hook_mask)
+{
+	if (targinfosize !=3D XT_ALIGN(sizeof(struct xt_NFQ_info))) {
+		printk(KERN_WARNING "NFQUEUE: targinfosize %u !=3D %Zu\n",
+		       targinfosize,
+		       XT_ALIGN(sizeof(struct xt_NFQ_info)));
+		return 0;
+	}
+
+	return 1;
+}
+
+static struct xt_target ipt_NFQ_reg =3D {
+	.name		=3D "NFQUEUE",
+	.target		=3D target,
+	.checkentry	=3D checkentry,
+	.me		=3D THIS_MODULE,
+};
+
+static struct xt_target ip6t_NFQ_reg =3D {
+	.name		=3D "NFQUEUE",
+	.target		=3D target,
+	.checkentry	=3D checkentry,
+	.me		=3D THIS_MODULE,
+};
+
+static struct xt_target arpt_NFQ_reg =3D {
+	.name		=3D "NFQUEUE",
+	.target		=3D target,
+	.checkentry	=3D checkentry,
+	.me		=3D THIS_MODULE,
+};
+
+static int __init init(void)
+{
+	int ret;
+	ret =3D xt_register_target(AF_INET, &ipt_NFQ_reg);
+	if (ret)
+		return ret;
+	ret =3D xt_register_target(AF_INET6, &ip6t_NFQ_reg);
+	if (ret)
+		goto out_ip;
+	ret =3D xt_register_target(NF_ARP, &arpt_NFQ_reg);
+	if (ret)
+		goto out_ip6;
+
+	return ret;
+out_ip6:
+	xt_unregister_target(AF_INET6, &ip6t_NFQ_reg);
+out_ip:
+	xt_unregister_target(AF_INET, &ipt_NFQ_reg);
+
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_target(NF_ARP, &arpt_NFQ_reg);
+	xt_unregister_target(AF_INET6, &ip6t_NFQ_reg);
+	xt_unregister_target(AF_INET, &ipt_NFQ_reg);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/netfilter/xt_NOTRACK.c b/net/netfilter/xt_NOTRACK.c
new file mode 100644
index 0000000..24d477a
--- /dev/null
+++ b/net/netfilter/xt_NOTRACK.c
@@ -0,0 +1,92 @@
+/* This is a module which is used for setting up fake conntracks
+ * on packets so that they are not seen by the conntrack/NAT code.
+ */
+#include <linux/module.h>
+#include <linux/skbuff.h>
+
+#include <linux/netfilter/x_tables.h>
+#include <net/netfilter/nf_conntrack_compat.h>
+
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("ipt_NOTRACK");
+
+static unsigned int
+target(struct sk_buff **pskb,
+       const struct net_device *in,
+       const struct net_device *out,
+       unsigned int hooknum,
+       const void *targinfo,
+       void *userinfo)
+{
+	/* Previously seen (loopback)? Ignore. */
+	if ((*pskb)->nfct !=3D NULL)
+		return XT_CONTINUE;
+
+	/* Attach fake conntrack entry.=20
+	   If there is a real ct entry correspondig to this packet,=20
+	   it'll hang aroun till timing out. We don't deal with it
+	   for performance reasons. JK */
+	nf_ct_untrack(*pskb);
+	(*pskb)->nfctinfo =3D IP_CT_NEW;
+	nf_conntrack_get((*pskb)->nfct);
+
+	return XT_CONTINUE;
+}
+
+static int
+checkentry(const char *tablename,
+	   const void *entry,
+           void *targinfo,
+           unsigned int targinfosize,
+           unsigned int hook_mask)
+{
+	if (targinfosize !=3D 0) {
+		printk(KERN_WARNING "NOTRACK: targinfosize %u !=3D 0\n",
+		       targinfosize);
+		return 0;
+	}
+
+	if (strcmp(tablename, "raw") !=3D 0) {
+		printk(KERN_WARNING "NOTRACK: can only be called from \"raw\" table, not=
 \"%s\"\n", tablename);
+		return 0;
+	}
+
+	return 1;
+}
+
+static struct xt_target notrack_reg =3D {=20
+	.name =3D "NOTRACK",=20
+	.target =3D target,=20
+	.checkentry =3D checkentry,
+	.me =3D THIS_MODULE,
+};
+static struct xt_target notrack6_reg =3D {=20
+	.name =3D "NOTRACK",=20
+	.target =3D target,=20
+	.checkentry =3D checkentry,
+	.me =3D THIS_MODULE,
+};
+
+static int __init init(void)
+{
+	int ret;
+
+	ret =3D xt_register_target(AF_INET, &notrack_reg);
+	if (ret)
+		return ret;
+
+	ret =3D xt_register_target(AF_INET6, &notrack6_reg);
+	if (ret)
+		xt_unregister_target(AF_INET, &notrack_reg);
+
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_target(AF_INET6, &notrack6_reg);
+	xt_unregister_target(AF_INET, &notrack_reg);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/netfilter/xt_comment.c b/net/netfilter/xt_comment.c
new file mode 100644
index 0000000..4ba6fd6
--- /dev/null
+++ b/net/netfilter/xt_comment.c
@@ -0,0 +1,80 @@
+/*
+ * Implements a dummy match to allow attaching comments to rules
+ *
+ * 2003-05-13 Brad Fisher (brad@info-link.net)
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_comment.h>
+
+MODULE_AUTHOR("Brad Fisher <brad@info-link.net>");
+MODULE_DESCRIPTION("iptables comment match module");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("ipt_comment");
+MODULE_ALIAS("ip6t_comment");
+
+static int
+match(const struct sk_buff *skb,
+      const struct net_device *in,
+      const struct net_device *out,
+      const void *matchinfo,
+      int offset,
+      unsigned int protooff,
+      int *hotdrop)
+{
+	/* We always match */
+	return 1;
+}
+
+static int
+checkentry(const char *tablename,
+           const void *ip,
+           void *matchinfo,
+           unsigned int matchsize,
+           unsigned int hook_mask)
+{
+	/* Check the size */
+	if (matchsize !=3D XT_ALIGN(sizeof(struct xt_comment_info)))
+		return 0;
+	return 1;
+}
+
+static struct xt_match comment_match =3D {
+	.name		=3D "comment",
+	.match		=3D match,
+	.checkentry	=3D checkentry,
+	.me		=3D THIS_MODULE
+};
+
+static struct xt_match comment6_match =3D {
+	.name		=3D "comment",
+	.match		=3D match,
+	.checkentry	=3D checkentry,
+	.me		=3D THIS_MODULE
+};
+
+static int __init init(void)
+{
+	int ret;
+
+	ret =3D xt_register_match(AF_INET, &comment_match);
+	if (ret)
+		return ret;
+
+	ret =3D xt_register_match(AF_INET6, &comment6_match);
+	if (ret)
+		xt_unregister_match(AF_INET, &comment_match);
+
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_match(AF_INET, &comment_match);
+	xt_unregister_match(AF_INET6, &comment6_match);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/netfilter/xt_connbytes.c b/net/netfilter/xt_connbytes.c
new file mode 100644
index 0000000..150d2a4
--- /dev/null
+++ b/net/netfilter/xt_connbytes.c
@@ -0,0 +1,180 @@
+/* Kernel module to match connection tracking byte counter.
+ * GPL (C) 2002 Martin Devera (devik@cdi.cz).
+ *
+ * 2004-07-20 Harald Welte <laforge@netfilter.org>
+ * 	- reimplemented to use per-connection accounting counters
+ * 	- add functionality to match number of packets
+ * 	- add functionality to match average packet size
+ * 	- add support to match directions seperately
+ * 2005-10-16 Harald Welte <laforge@netfilter.org>
+ * 	- Port to x_tables
+ *
+ */
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <net/netfilter/nf_conntrack_compat.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_connbytes.h>
+
+#include <asm/div64.h>
+#include <asm/bitops.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
+MODULE_DESCRIPTION("iptables match for matching number of pkts/bytes per c=
onnection");
+MODULE_ALIAS("ipt_connbytes");
+
+/* 64bit divisor, dividend and result. dynamic precision */
+static u_int64_t div64_64(u_int64_t dividend, u_int64_t divisor)
+{
+	u_int32_t d =3D divisor;
+
+	if (divisor > 0xffffffffULL) {
+		unsigned int shift =3D fls(divisor >> 32);
+
+		d =3D divisor >> shift;
+		dividend >>=3D shift;
+	}
+
+	do_div(dividend, d);
+	return dividend;
+}
+
+static int
+match(const struct sk_buff *skb,
+      const struct net_device *in,
+      const struct net_device *out,
+      const void *matchinfo,
+      int offset,
+      unsigned int protoff,
+      int *hotdrop)
+{
+	const struct xt_connbytes_info *sinfo =3D matchinfo;
+	u_int64_t what =3D 0;	/* initialize to make gcc happy */
+	const struct ip_conntrack_counter *counters;
+
+	if (!(counters =3D nf_ct_get_counters(skb)))
+		return 0; /* no match */
+
+	switch (sinfo->what) {
+	case XT_CONNBYTES_PKTS:
+		switch (sinfo->direction) {
+		case XT_CONNBYTES_DIR_ORIGINAL:
+			what =3D counters[IP_CT_DIR_ORIGINAL].packets;
+			break;
+		case XT_CONNBYTES_DIR_REPLY:
+			what =3D counters[IP_CT_DIR_REPLY].packets;
+			break;
+		case XT_CONNBYTES_DIR_BOTH:
+			what =3D counters[IP_CT_DIR_ORIGINAL].packets;
+			what +=3D counters[IP_CT_DIR_REPLY].packets;
+			break;
+		}
+		break;
+	case XT_CONNBYTES_BYTES:
+		switch (sinfo->direction) {
+		case XT_CONNBYTES_DIR_ORIGINAL:
+			what =3D counters[IP_CT_DIR_ORIGINAL].bytes;
+			break;
+		case XT_CONNBYTES_DIR_REPLY:
+			what =3D counters[IP_CT_DIR_REPLY].bytes;
+			break;
+		case XT_CONNBYTES_DIR_BOTH:
+			what =3D counters[IP_CT_DIR_ORIGINAL].bytes;
+			what +=3D counters[IP_CT_DIR_REPLY].bytes;
+			break;
+		}
+		break;
+	case XT_CONNBYTES_AVGPKT:
+		switch (sinfo->direction) {
+		case XT_CONNBYTES_DIR_ORIGINAL:
+			what =3D div64_64(counters[IP_CT_DIR_ORIGINAL].bytes,
+					counters[IP_CT_DIR_ORIGINAL].packets);
+			break;
+		case XT_CONNBYTES_DIR_REPLY:
+			what =3D div64_64(counters[IP_CT_DIR_REPLY].bytes,
+					counters[IP_CT_DIR_REPLY].packets);
+			break;
+		case XT_CONNBYTES_DIR_BOTH:
+			{
+				u_int64_t bytes;
+				u_int64_t pkts;
+				bytes =3D counters[IP_CT_DIR_ORIGINAL].bytes +
+					counters[IP_CT_DIR_REPLY].bytes;
+				pkts =3D counters[IP_CT_DIR_ORIGINAL].packets+
+					counters[IP_CT_DIR_REPLY].packets;
+
+				/* FIXME_THEORETICAL: what to do if sum
+				 * overflows ? */
+
+				what =3D div64_64(bytes, pkts);
+			}
+			break;
+		}
+		break;
+	}
+
+	if (sinfo->count.to)
+		return (what <=3D sinfo->count.to && what >=3D sinfo->count.from);
+	else
+		return (what >=3D sinfo->count.from);
+}
+
+static int check(const char *tablename,
+		 const void *ip,
+		 void *matchinfo,
+		 unsigned int matchsize,
+		 unsigned int hook_mask)
+{
+	const struct xt_connbytes_info *sinfo =3D matchinfo;
+
+	if (matchsize !=3D XT_ALIGN(sizeof(struct xt_connbytes_info)))
+		return 0;
+
+	if (sinfo->what !=3D XT_CONNBYTES_PKTS &&
+	    sinfo->what !=3D XT_CONNBYTES_BYTES &&
+	    sinfo->what !=3D XT_CONNBYTES_AVGPKT)
+		return 0;
+
+	if (sinfo->direction !=3D XT_CONNBYTES_DIR_ORIGINAL &&
+	    sinfo->direction !=3D XT_CONNBYTES_DIR_REPLY &&
+	    sinfo->direction !=3D XT_CONNBYTES_DIR_BOTH)
+		return 0;
+
+	return 1;
+}
+
+static struct xt_match connbytes_match =3D {
+	.name		=3D "connbytes",
+	.match		=3D &match,
+	.checkentry	=3D &check,
+	.me		=3D THIS_MODULE
+};
+static struct xt_match connbytes6_match =3D {
+	.name		=3D "connbytes",
+	.match		=3D &match,
+	.checkentry	=3D &check,
+	.me		=3D THIS_MODULE
+};
+
+static int __init init(void)
+{
+	int ret;
+	ret =3D xt_register_match(AF_INET, &connbytes_match);
+	if (ret)
+		return ret;
+
+	ret =3D xt_register_match(AF_INET6, &connbytes6_match);
+	if (ret)
+		xt_unregister_match(AF_INET, &connbytes_match);
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_match(AF_INET, &connbytes_match);
+	xt_unregister_match(AF_INET6, &connbytes6_match);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/netfilter/xt_connmark.c b/net/netfilter/xt_connmark.c
new file mode 100644
index 0000000..d06e925
--- /dev/null
+++ b/net/netfilter/xt_connmark.c
@@ -0,0 +1,109 @@
+/* This kernel module matches connection mark values set by the
+ * CONNMARK target
+ *
+ * Copyright (C) 2002,2004 MARA Systems AB <http://www.marasystems.com>
+ * by Henrik Nordstrom <hno@marasystems.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  U=
SA
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+
+MODULE_AUTHOR("Henrik Nordstrom <hno@marasytems.com>");
+MODULE_DESCRIPTION("IP tables connmark match module");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("ipt_connmark");
+
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_connmark.h>
+#include <net/netfilter/nf_conntrack_compat.h>
+
+static int
+match(const struct sk_buff *skb,
+      const struct net_device *in,
+      const struct net_device *out,
+      const void *matchinfo,
+      int offset,
+      unsigned int protoff,
+      int *hotdrop)
+{
+	const struct xt_connmark_info *info =3D matchinfo;
+	u_int32_t ctinfo;
+	const u_int32_t *ctmark =3D nf_ct_get_mark(skb, &ctinfo);
+	if (!ctmark)
+		return 0;
+
+	return (((*ctmark) & info->mask) =3D=3D info->mark) ^ info->invert;
+}
+
+static int
+checkentry(const char *tablename,
+	   const void *ip,
+	   void *matchinfo,
+	   unsigned int matchsize,
+	   unsigned int hook_mask)
+{
+	struct xt_connmark_info *cm =3D=20
+				(struct xt_connmark_info *)matchinfo;
+	if (matchsize !=3D XT_ALIGN(sizeof(struct xt_connmark_info)))
+		return 0;
+
+	if (cm->mark > 0xffffffff || cm->mask > 0xffffffff) {
+		printk(KERN_WARNING "connmark: only support 32bit mark\n");
+		return 0;
+	}
+
+	return 1;
+}
+
+static struct xt_match connmark_match =3D {
+	.name =3D "connmark",
+	.match =3D &match,
+	.checkentry =3D &checkentry,
+	.me =3D THIS_MODULE
+};
+static struct xt_match connmark6_match =3D {
+	.name =3D "connmark",
+	.match =3D &match,
+	.checkentry =3D &checkentry,
+	.me =3D THIS_MODULE
+};
+
+
+static int __init init(void)
+{
+	int ret;
+
+	need_conntrack();
+
+	ret =3D xt_register_match(AF_INET, &connmark_match);
+	if (ret)
+		return ret;
+
+	ret =3D xt_register_match(AF_INET6, &connmark6_match);
+	if (ret)
+		xt_unregister_match(AF_INET, &connmark_match);
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_match(AF_INET6, &connmark6_match);
+	xt_unregister_match(AF_INET, &connmark_match);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.c
new file mode 100644
index 0000000..ffdebc9
--- /dev/null
+++ b/net/netfilter/xt_conntrack.c
@@ -0,0 +1,238 @@
+/* Kernel module to match connection tracking information.
+ * Superset of Rusty's minimalistic state match.
+ *
+ * (C) 2001  Marc Boucher (marc@mbsi.ca).
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+
+#if defined(CONFIG_IP_NF_CONNTRACK) || defined(CONFIG_IP_NF_CONNTRACK_MODU=
LE)
+#include <linux/netfilter_ipv4/ip_conntrack.h>
+#include <linux/netfilter_ipv4/ip_conntrack_tuple.h>
+#else
+#include <net/netfilter/nf_conntrack.h>
+#endif
+
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_conntrack.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Marc Boucher <marc@mbsi.ca>");
+MODULE_DESCRIPTION("iptables connection tracking match module");
+MODULE_ALIAS("ipt_conntrack");
+
+#if defined(CONFIG_IP_NF_CONNTRACK) || defined(CONFIG_IP_NF_CONNTRACK_MODU=
LE)
+
+static int
+match(const struct sk_buff *skb,
+      const struct net_device *in,
+      const struct net_device *out,
+      const void *matchinfo,
+      int offset,
+      unsigned int protoff,
+      int *hotdrop)
+{
+	const struct xt_conntrack_info *sinfo =3D matchinfo;
+	struct ip_conntrack *ct;
+	enum ip_conntrack_info ctinfo;
+	unsigned int statebit;
+
+	ct =3D ip_conntrack_get((struct sk_buff *)skb, &ctinfo);
+
+#define FWINV(bool,invflg) ((bool) ^ !!(sinfo->invflags & invflg))
+
+	if (ct =3D=3D &ip_conntrack_untracked)
+		statebit =3D XT_CONNTRACK_STATE_UNTRACKED;
+	else if (ct)
+ 		statebit =3D XT_CONNTRACK_STATE_BIT(ctinfo);
+ 	else
+ 		statebit =3D XT_CONNTRACK_STATE_INVALID;
+=20
+	if(sinfo->flags & XT_CONNTRACK_STATE) {
+		if (ct) {
+			if(ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.ip !=3D
+			    ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.ip)
+				statebit |=3D XT_CONNTRACK_STATE_SNAT;
+
+			if(ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.ip !=3D
+			    ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.ip)
+				statebit |=3D XT_CONNTRACK_STATE_DNAT;
+		}
+
+		if (FWINV((statebit & sinfo->statemask) =3D=3D 0, XT_CONNTRACK_STATE))
+			return 0;
+	}
+
+	if(sinfo->flags & XT_CONNTRACK_PROTO) {
+		if (!ct || FWINV(ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.protonum !=
=3D sinfo->tuple[IP_CT_DIR_ORIGINAL].dst.protonum, XT_CONNTRACK_PROTO))
+                	return 0;
+	}
+
+	if(sinfo->flags & XT_CONNTRACK_ORIGSRC) {
+		if (!ct || FWINV((ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.ip&sinfo->=
sipmsk[IP_CT_DIR_ORIGINAL].s_addr) !=3D sinfo->tuple[IP_CT_DIR_ORIGINAL].sr=
c.ip, XT_CONNTRACK_ORIGSRC))
+			return 0;
+	}
+
+	if(sinfo->flags & XT_CONNTRACK_ORIGDST) {
+		if (!ct || FWINV((ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.ip&sinfo->=
dipmsk[IP_CT_DIR_ORIGINAL].s_addr) !=3D sinfo->tuple[IP_CT_DIR_ORIGINAL].ds=
t.ip, XT_CONNTRACK_ORIGDST))
+			return 0;
+	}
+
+	if(sinfo->flags & XT_CONNTRACK_REPLSRC) {
+		if (!ct || FWINV((ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.ip&sinfo->sip=
msk[IP_CT_DIR_REPLY].s_addr) !=3D sinfo->tuple[IP_CT_DIR_REPLY].src.ip, XT_=
CONNTRACK_REPLSRC))
+			return 0;
+	}
+
+	if(sinfo->flags & XT_CONNTRACK_REPLDST) {
+		if (!ct || FWINV((ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.ip&sinfo->dip=
msk[IP_CT_DIR_REPLY].s_addr) !=3D sinfo->tuple[IP_CT_DIR_REPLY].dst.ip, XT_=
CONNTRACK_REPLDST))
+			return 0;
+	}
+
+	if(sinfo->flags & XT_CONNTRACK_STATUS) {
+		if (!ct || FWINV((ct->status & sinfo->statusmask) =3D=3D 0, XT_CONNTRACK=
_STATUS))
+			return 0;
+	}
+
+	if(sinfo->flags & XT_CONNTRACK_EXPIRES) {
+		unsigned long expires;
+
+		if(!ct)
+			return 0;
+
+		expires =3D timer_pending(&ct->timeout) ? (ct->timeout.expires - jiffies=
)/HZ : 0;
+
+		if (FWINV(!(expires >=3D sinfo->expires_min && expires <=3D sinfo->expir=
es_max), XT_CONNTRACK_EXPIRES))
+			return 0;
+	}
+
+	return 1;
+}
+
+#else /* CONFIG_IP_NF_CONNTRACK */
+static int
+match(const struct sk_buff *skb,
+      const struct net_device *in,
+      const struct net_device *out,
+      const void *matchinfo,
+      int offset,
+      unsigned int protoff,
+      int *hotdrop)
+{
+	const struct xt_conntrack_info *sinfo =3D matchinfo;
+	struct nf_conn *ct;
+	enum ip_conntrack_info ctinfo;
+	unsigned int statebit;
+
+	ct =3D nf_ct_get((struct sk_buff *)skb, &ctinfo);
+
+#define FWINV(bool,invflg) ((bool) ^ !!(sinfo->invflags & invflg))
+
+	if (ct =3D=3D &nf_conntrack_untracked)
+		statebit =3D XT_CONNTRACK_STATE_UNTRACKED;
+	else if (ct)
+ 		statebit =3D XT_CONNTRACK_STATE_BIT(ctinfo);
+ 	else
+ 		statebit =3D XT_CONNTRACK_STATE_INVALID;
+=20
+	if(sinfo->flags & XT_CONNTRACK_STATE) {
+		if (ct) {
+			if(ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3.ip !=3D
+			    ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.u3.ip)
+				statebit |=3D XT_CONNTRACK_STATE_SNAT;
+
+			if(ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.u3.ip !=3D
+			    ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u3.ip)
+				statebit |=3D XT_CONNTRACK_STATE_DNAT;
+		}
+
+		if (FWINV((statebit & sinfo->statemask) =3D=3D 0, XT_CONNTRACK_STATE))
+			return 0;
+	}
+
+	if(sinfo->flags & XT_CONNTRACK_PROTO) {
+		if (!ct || FWINV(ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.protonum !=
=3D sinfo->tuple[IP_CT_DIR_ORIGINAL].dst.protonum, XT_CONNTRACK_PROTO))
+                	return 0;
+	}
+
+	if(sinfo->flags & XT_CONNTRACK_ORIGSRC) {
+		if (!ct || FWINV((ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3.ip&sinf=
o->sipmsk[IP_CT_DIR_ORIGINAL].s_addr) !=3D sinfo->tuple[IP_CT_DIR_ORIGINAL]=
=2Esrc.ip, XT_CONNTRACK_ORIGSRC))
+			return 0;
+	}
+
+	if(sinfo->flags & XT_CONNTRACK_ORIGDST) {
+		if (!ct || FWINV((ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.u3.ip&sinf=
o->dipmsk[IP_CT_DIR_ORIGINAL].s_addr) !=3D sinfo->tuple[IP_CT_DIR_ORIGINAL]=
=2Edst.ip, XT_CONNTRACK_ORIGDST))
+			return 0;
+	}
+
+	if(sinfo->flags & XT_CONNTRACK_REPLSRC) {
+		if (!ct || FWINV((ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u3.ip&sinfo->=
sipmsk[IP_CT_DIR_REPLY].s_addr) !=3D sinfo->tuple[IP_CT_DIR_REPLY].src.ip, =
XT_CONNTRACK_REPLSRC))
+			return 0;
+	}
+
+	if(sinfo->flags & XT_CONNTRACK_REPLDST) {
+		if (!ct || FWINV((ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.u3.ip&sinfo->=
dipmsk[IP_CT_DIR_REPLY].s_addr) !=3D sinfo->tuple[IP_CT_DIR_REPLY].dst.ip, =
XT_CONNTRACK_REPLDST))
+			return 0;
+	}
+
+	if(sinfo->flags & XT_CONNTRACK_STATUS) {
+		if (!ct || FWINV((ct->status & sinfo->statusmask) =3D=3D 0, XT_CONNTRACK=
_STATUS))
+			return 0;
+	}
+
+	if(sinfo->flags & XT_CONNTRACK_EXPIRES) {
+		unsigned long expires;
+
+		if(!ct)
+			return 0;
+
+		expires =3D timer_pending(&ct->timeout) ? (ct->timeout.expires - jiffies=
)/HZ : 0;
+
+		if (FWINV(!(expires >=3D sinfo->expires_min && expires <=3D sinfo->expir=
es_max), XT_CONNTRACK_EXPIRES))
+			return 0;
+	}
+
+	return 1;
+}
+
+#endif /* CONFIG_NF_IP_CONNTRACK */
+
+static int check(const char *tablename,
+		 const void *ip,
+		 void *matchinfo,
+		 unsigned int matchsize,
+		 unsigned int hook_mask)
+{
+	if (matchsize !=3D XT_ALIGN(sizeof(struct xt_conntrack_info)))
+		return 0;
+
+	return 1;
+}
+
+static struct xt_match conntrack_match =3D {
+	.name		=3D "conntrack",
+	.match		=3D &match,
+	.checkentry	=3D &check,
+	.me		=3D THIS_MODULE,
+};
+
+static int __init init(void)
+{
+	int ret;
+	need_conntrack();
+	ret =3D xt_register_match(AF_INET, &conntrack_match);
+
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_match(AF_INET, &conntrack_match);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/netfilter/xt_dccp.c b/net/netfilter/xt_dccp.c
new file mode 100644
index 0000000..779f42f
--- /dev/null
+++ b/net/netfilter/xt_dccp.c
@@ -0,0 +1,221 @@
+/*
+ * iptables module for DCCP protocol header matching
+ *
+ * (C) 2005 by Harald Welte <laforge@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <net/ip.h>
+#include <linux/dccp.h>
+
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_dccp.h>
+
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter_ipv6/ip6_tables.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
+MODULE_DESCRIPTION("Match for DCCP protocol packets");
+MODULE_ALIAS("ipt_dccp");
+
+#define DCCHECK(cond, option, flag, invflag) (!((flag) & (option)) \
+		                  || (!!((invflag) & (option)) ^ (cond)))
+
+static unsigned char *dccp_optbuf;
+static DEFINE_SPINLOCK(dccp_buflock);
+
+static inline int
+dccp_find_option(u_int8_t option,
+		 const struct sk_buff *skb,
+		 unsigned int protoff,
+		 const struct dccp_hdr *dh,
+		 int *hotdrop)
+{
+	/* tcp.doff is only 4 bits, ie. max 15 * 4 bytes */
+	unsigned char *op;
+	unsigned int optoff =3D __dccp_hdr_len(dh);
+	unsigned int optlen =3D dh->dccph_doff*4 - __dccp_hdr_len(dh);
+	unsigned int i;
+
+	if (dh->dccph_doff * 4 < __dccp_hdr_len(dh)) {
+		*hotdrop =3D 1;
+		return 0;
+	}
+
+	if (!optlen)
+		return 0;
+
+	spin_lock_bh(&dccp_buflock);
+	op =3D skb_header_pointer(skb, protoff + optoff, optlen, dccp_optbuf);
+	if (op =3D=3D NULL) {
+		/* If we don't have the whole header, drop packet. */
+		spin_unlock_bh(&dccp_buflock);
+		*hotdrop =3D 1;
+		return 0;
+	}
+
+	for (i =3D 0; i < optlen; ) {
+		if (op[i] =3D=3D option) {
+			spin_unlock_bh(&dccp_buflock);
+			return 1;
+		}
+
+		if (op[i] < 2)=20
+			i++;
+		else=20
+			i +=3D op[i+1]?:1;
+	}
+
+	spin_unlock_bh(&dccp_buflock);
+	return 0;
+}
+
+
+static inline int
+match_types(const struct dccp_hdr *dh, u_int16_t typemask)
+{
+	return (typemask & (1 << dh->dccph_type));
+}
+
+static inline int
+match_option(u_int8_t option, const struct sk_buff *skb, unsigned int prot=
off,
+	     const struct dccp_hdr *dh, int *hotdrop)
+{
+	return dccp_find_option(option, skb, protoff, dh, hotdrop);
+}
+
+static int
+match(const struct sk_buff *skb,
+      const struct net_device *in,
+      const struct net_device *out,
+      const void *matchinfo,
+      int offset,
+      unsigned int protoff,
+      int *hotdrop)
+{
+	const struct xt_dccp_info *info =3D=20
+				(const struct xt_dccp_info *)matchinfo;
+	struct dccp_hdr _dh, *dh;
+
+	if (offset)
+		return 0;
+=09
+	dh =3D skb_header_pointer(skb, protoff, sizeof(_dh), &_dh);
+	if (dh =3D=3D NULL) {
+		*hotdrop =3D 1;
+		return 0;
+       	}
+
+	return  DCCHECK(((ntohs(dh->dccph_sport) >=3D info->spts[0])=20
+			&& (ntohs(dh->dccph_sport) <=3D info->spts[1])),=20
+		   	XT_DCCP_SRC_PORTS, info->flags, info->invflags)
+		&& DCCHECK(((ntohs(dh->dccph_dport) >=3D info->dpts[0])=20
+			&& (ntohs(dh->dccph_dport) <=3D info->dpts[1])),=20
+			XT_DCCP_DEST_PORTS, info->flags, info->invflags)
+		&& DCCHECK(match_types(dh, info->typemask),
+			   XT_DCCP_TYPE, info->flags, info->invflags)
+		&& DCCHECK(match_option(info->option, skb, protoff, dh,
+					hotdrop),
+			   XT_DCCP_OPTION, info->flags, info->invflags);
+}
+
+static int
+checkentry(const char *tablename,
+	   const void *inf,
+	   void *matchinfo,
+	   unsigned int matchsize,
+	   unsigned int hook_mask)
+{
+	const struct ipt_ip *ip =3D inf;
+	const struct xt_dccp_info *info;
+
+	info =3D (const struct xt_dccp_info *)matchinfo;
+
+	return ip->proto =3D=3D IPPROTO_DCCP
+		&& !(ip->invflags & XT_INV_PROTO)
+		&& matchsize =3D=3D XT_ALIGN(sizeof(struct xt_dccp_info))
+		&& !(info->flags & ~XT_DCCP_VALID_FLAGS)
+		&& !(info->invflags & ~XT_DCCP_VALID_FLAGS)
+		&& !(info->invflags & ~info->flags);
+}
+
+static int
+checkentry6(const char *tablename,
+	   const void *inf,
+	   void *matchinfo,
+	   unsigned int matchsize,
+	   unsigned int hook_mask)
+{
+	const struct ip6t_ip6 *ip =3D inf;
+	const struct xt_dccp_info *info;
+
+	info =3D (const struct xt_dccp_info *)matchinfo;
+
+	return ip->proto =3D=3D IPPROTO_DCCP
+		&& !(ip->invflags & XT_INV_PROTO)
+		&& matchsize =3D=3D XT_ALIGN(sizeof(struct xt_dccp_info))
+		&& !(info->flags & ~XT_DCCP_VALID_FLAGS)
+		&& !(info->invflags & ~XT_DCCP_VALID_FLAGS)
+		&& !(info->invflags & ~info->flags);
+}
+
+
+static struct xt_match dccp_match =3D=20
+{=20
+	.name 		=3D "dccp",
+	.match		=3D &match,
+	.checkentry	=3D &checkentry,
+	.me 		=3D THIS_MODULE,
+};
+static struct xt_match dccp6_match =3D=20
+{=20
+	.name 		=3D "dccp",
+	.match		=3D &match,
+	.checkentry	=3D &checkentry6,
+	.me 		=3D THIS_MODULE,
+};
+
+
+static int __init init(void)
+{
+	int ret;
+
+	/* doff is 8 bits, so the maximum option size is (4*256).  Don't put
+	 * this in BSS since DaveM is worried about locked TLB's for kernel
+	 * BSS. */
+	dccp_optbuf =3D kmalloc(256 * 4, GFP_KERNEL);
+	if (!dccp_optbuf)
+		return -ENOMEM;
+	ret =3D xt_register_match(AF_INET, &dccp_match);
+	if (ret)
+		goto out_kfree;
+	ret =3D xt_register_match(AF_INET6, &dccp6_match);
+	if (ret)
+		goto out_unreg;
+
+	return ret;
+
+out_unreg:
+	xt_unregister_match(AF_INET, &dccp_match);
+out_kfree:
+	kfree(dccp_optbuf);
+
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_match(AF_INET6, &dccp6_match);
+	xt_unregister_match(AF_INET, &dccp_match);
+	kfree(dccp_optbuf);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/netfilter/xt_helper.c b/net/netfilter/xt_helper.c
new file mode 100644
index 0000000..38b6715
--- /dev/null
+++ b/net/netfilter/xt_helper.c
@@ -0,0 +1,188 @@
+/* iptables module to match on related connections */
+/*
+ * (C) 2001 Martin Josefsson <gandalf@wlug.westbo.se>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ *   19 Mar 2002 Harald Welte <laforge@gnumonks.org>:
+ *   		 - Port to newnat infrastructure
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/netfilter.h>
+#if defined(CONFIG_IP_NF_CONNTRACK) || defined(CONFIG_IP_NF_CONNTRACK_MODU=
LE)
+#include <linux/netfilter_ipv4/ip_conntrack.h>
+#include <linux/netfilter_ipv4/ip_conntrack_core.h>
+#include <linux/netfilter_ipv4/ip_conntrack_helper.h>
+#else
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_core.h>
+#include <net/netfilter/nf_conntrack_helper.h>
+#endif
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_helper.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Martin Josefsson <gandalf@netfilter.org>");
+MODULE_DESCRIPTION("iptables helper match module");
+MODULE_ALIAS("ipt_helper");
+MODULE_ALIAS("ip6t_helper");
+
+#if 0
+#define DEBUGP printk
+#else
+#define DEBUGP(format, args...)
+#endif
+
+#if defined(CONFIG_IP_NF_CONNTRACK) || defined(CONFIG_IP_NF_CONNTRACK_MODU=
LE)
+static int
+match(const struct sk_buff *skb,
+      const struct net_device *in,
+      const struct net_device *out,
+      const void *matchinfo,
+      int offset,
+      unsigned int protoff,
+      int *hotdrop)
+{
+	const struct xt_helper_info *info =3D matchinfo;
+	struct ip_conntrack *ct;
+	enum ip_conntrack_info ctinfo;
+	int ret =3D info->invert;
+=09
+	ct =3D ip_conntrack_get((struct sk_buff *)skb, &ctinfo);
+	if (!ct) {
+		DEBUGP("xt_helper: Eek! invalid conntrack?\n");
+		return ret;
+	}
+
+	if (!ct->master) {
+		DEBUGP("xt_helper: conntrack %p has no master\n", ct);
+		return ret;
+	}
+
+	read_lock_bh(&ip_conntrack_lock);
+	if (!ct->master->helper) {
+		DEBUGP("xt_helper: master ct %p has no helper\n",=20
+			exp->expectant);
+		goto out_unlock;
+	}
+
+	DEBUGP("master's name =3D %s , info->name =3D %s\n",=20
+		ct->master->helper->name, info->name);
+
+	if (info->name[0] =3D=3D '\0')
+		ret ^=3D 1;
+	else
+		ret ^=3D !strncmp(ct->master->helper->name, info->name,=20
+		                strlen(ct->master->helper->name));
+out_unlock:
+	read_unlock_bh(&ip_conntrack_lock);
+	return ret;
+}
+
+#else /* CONFIG_IP_NF_CONNTRACK */
+
+static int
+match(const struct sk_buff *skb,
+      const struct net_device *in,
+      const struct net_device *out,
+      const void *matchinfo,
+      int offset,
+      unsigned int protoff,
+      int *hotdrop)
+{
+	const struct xt_helper_info *info =3D matchinfo;
+	struct nf_conn *ct;
+	enum ip_conntrack_info ctinfo;
+	int ret =3D info->invert;
+=09
+	ct =3D nf_ct_get((struct sk_buff *)skb, &ctinfo);
+	if (!ct) {
+		DEBUGP("xt_helper: Eek! invalid conntrack?\n");
+		return ret;
+	}
+
+	if (!ct->master) {
+		DEBUGP("xt_helper: conntrack %p has no master\n", ct);
+		return ret;
+	}
+
+	read_lock_bh(&nf_conntrack_lock);
+	if (!ct->master->helper) {
+		DEBUGP("xt_helper: master ct %p has no helper\n",=20
+			exp->expectant);
+		goto out_unlock;
+	}
+
+	DEBUGP("master's name =3D %s , info->name =3D %s\n",=20
+		ct->master->helper->name, info->name);
+
+	if (info->name[0] =3D=3D '\0')
+		ret ^=3D 1;
+	else
+		ret ^=3D !strncmp(ct->master->helper->name, info->name,=20
+		                strlen(ct->master->helper->name));
+out_unlock:
+	read_unlock_bh(&nf_conntrack_lock);
+	return ret;
+}
+#endif
+
+static int check(const char *tablename,
+		 const void *inf,
+		 void *matchinfo,
+		 unsigned int matchsize,
+		 unsigned int hook_mask)
+{
+	struct xt_helper_info *info =3D matchinfo;
+
+	info->name[29] =3D '\0';
+
+	/* verify size */
+	if (matchsize !=3D XT_ALIGN(sizeof(struct xt_helper_info)))
+		return 0;
+
+	return 1;
+}
+
+static struct xt_match helper_match =3D {
+	.name		=3D "helper",
+	.match		=3D &match,
+	.checkentry	=3D &check,
+	.me		=3D THIS_MODULE,
+};
+static struct xt_match helper6_match =3D {
+	.name		=3D "helper",
+	.match		=3D &match,
+	.checkentry	=3D &check,
+	.me		=3D THIS_MODULE,
+};
+
+static int __init init(void)
+{
+	int ret;
+	need_conntrack();
+
+	ret =3D xt_register_match(AF_INET, &helper_match);
+	if (ret < 0)
+		return ret;
+
+	ret =3D xt_register_match(AF_INET6, &helper6_match);
+	if (ret < 0)
+		xt_unregister_match(AF_INET, &helper_match);
+
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_match(AF_INET, &helper_match);
+	xt_unregister_match(AF_INET6, &helper6_match);
+}
+
+module_init(init);
+module_exit(fini);
+
diff --git a/net/netfilter/xt_length.c b/net/netfilter/xt_length.c
new file mode 100644
index 0000000..ab6c710
--- /dev/null
+++ b/net/netfilter/xt_length.c
@@ -0,0 +1,98 @@
+/* Kernel module to match packet length. */
+/* (C) 1999-2001 James Morris <jmorros@intercode.com.au>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <net/ip.h>
+
+#include <linux/netfilter/xt_length.h>
+#include <linux/netfilter/x_tables.h>
+
+MODULE_AUTHOR("James Morris <jmorris@intercode.com.au>");
+MODULE_DESCRIPTION("IP tables packet length matching module");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("ipt_length");
+MODULE_ALIAS("ip6t_length");
+
+static int
+match(const struct sk_buff *skb,
+      const struct net_device *in,
+      const struct net_device *out,
+      const void *matchinfo,
+      int offset,
+      unsigned int protoff,
+      int *hotdrop)
+{
+	const struct xt_length_info *info =3D matchinfo;
+	u_int16_t pktlen =3D ntohs(skb->nh.iph->tot_len);
+=09
+	return (pktlen >=3D info->min && pktlen <=3D info->max) ^ info->invert;
+}
+
+static int
+match6(const struct sk_buff *skb,
+       const struct net_device *in,
+       const struct net_device *out,
+       const void *matchinfo,
+       int offset,
+       unsigned int protoff,
+       int *hotdrop)
+{
+	const struct xt_length_info *info =3D matchinfo;
+	u_int16_t pktlen =3D ntohs(skb->nh.ipv6h->payload_len) + sizeof(struct ip=
v6hdr);
+=09
+	return (pktlen >=3D info->min && pktlen <=3D info->max) ^ info->invert;
+}
+
+static int
+checkentry(const char *tablename,
+           const void *ip,
+           void *matchinfo,
+           unsigned int matchsize,
+           unsigned int hook_mask)
+{
+	if (matchsize !=3D XT_ALIGN(sizeof(struct xt_length_info)))
+		return 0;
+
+	return 1;
+}
+
+static struct xt_match length_match =3D {
+	.name		=3D "length",
+	.match		=3D &match,
+	.checkentry	=3D &checkentry,
+	.me		=3D THIS_MODULE,
+};
+static struct xt_match length6_match =3D {
+	.name		=3D "length",
+	.match		=3D &match6,
+	.checkentry	=3D &checkentry,
+	.me		=3D THIS_MODULE,
+};
+
+static int __init init(void)
+{
+	int ret;
+	ret =3D xt_register_match(AF_INET, &length_match);
+	if (ret)
+		return ret;
+	ret =3D xt_register_match(AF_INET6, &length6_match);
+	if (ret)
+		xt_unregister_match(AF_INET, &length_match);
+
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_match(AF_INET, &length_match);
+	xt_unregister_match(AF_INET6, &length6_match);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/netfilter/xt_limit.c b/net/netfilter/xt_limit.c
new file mode 100644
index 0000000..15e4050
--- /dev/null
+++ b/net/netfilter/xt_limit.c
@@ -0,0 +1,175 @@
+/* Kernel module to control the rate
+ *
+ * 2 September 1999: Changed from the target RATE to the match
+ *                   `limit', removed logging.  Did I mention that
+ *                   Alexey is a fucking genius?
+ *                   Rusty Russell (rusty@rustcorp.com.au).  */
+
+/* (C) 1999 J=E9r=F4me de Vivie <devivie@info.enserb.u-bordeaux.fr>
+ * (C) 1999 Herv=E9 Eychenne <eychenne@info.enserb.u-bordeaux.fr>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/interrupt.h>
+
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_limit.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Herve Eychenne <rv@wallfire.org>");
+MODULE_DESCRIPTION("iptables rate limit match");
+MODULE_ALIAS("ipt_limit");
+MODULE_ALIAS("ip6t_limit");
+
+/* The algorithm used is the Simple Token Bucket Filter (TBF)
+ * see net/sched/sch_tbf.c in the linux source tree
+ */
+
+static DEFINE_SPINLOCK(limit_lock);
+
+/* Rusty: This is my (non-mathematically-inclined) understanding of
+   this algorithm.  The `average rate' in jiffies becomes your initial
+   amount of credit `credit' and the most credit you can ever have
+   `credit_cap'.  The `peak rate' becomes the cost of passing the
+   test, `cost'.
+
+   `prev' tracks the last packet hit: you gain one credit per jiffy.
+   If you get credit balance more than this, the extra credit is
+   discarded.  Every time the match passes, you lose `cost' credits;
+   if you don't have that many, the test fails.
+
+   See Alexey's formal explanation in net/sched/sch_tbf.c.
+
+   To get the maxmum range, we multiply by this factor (ie. you get N
+   credits per jiffy).  We want to allow a rate as low as 1 per day
+   (slowest userspace tool allows), which means
+   CREDITS_PER_JIFFY*HZ*60*60*24 < 2^32. ie. */
+#define MAX_CPJ (0xFFFFFFFF / (HZ*60*60*24))
+
+/* Repeated shift and or gives us all 1s, final shift and add 1 gives
+ * us the power of 2 below the theoretical max, so GCC simply does a
+ * shift. */
+#define _POW2_BELOW2(x) ((x)|((x)>>1))
+#define _POW2_BELOW4(x) (_POW2_BELOW2(x)|_POW2_BELOW2((x)>>2))
+#define _POW2_BELOW8(x) (_POW2_BELOW4(x)|_POW2_BELOW4((x)>>4))
+#define _POW2_BELOW16(x) (_POW2_BELOW8(x)|_POW2_BELOW8((x)>>8))
+#define _POW2_BELOW32(x) (_POW2_BELOW16(x)|_POW2_BELOW16((x)>>16))
+#define POW2_BELOW32(x) ((_POW2_BELOW32(x)>>1) + 1)
+
+#define CREDITS_PER_JIFFY POW2_BELOW32(MAX_CPJ)
+
+static int
+ipt_limit_match(const struct sk_buff *skb,
+		const struct net_device *in,
+		const struct net_device *out,
+		const void *matchinfo,
+		int offset,
+		unsigned int protoff,
+		int *hotdrop)
+{
+	struct xt_rateinfo *r =3D ((struct xt_rateinfo *)matchinfo)->master;
+	unsigned long now =3D jiffies;
+
+	spin_lock_bh(&limit_lock);
+	r->credit +=3D (now - xchg(&r->prev, now)) * CREDITS_PER_JIFFY;
+	if (r->credit > r->credit_cap)
+		r->credit =3D r->credit_cap;
+
+	if (r->credit >=3D r->cost) {
+		/* We're not limited. */
+		r->credit -=3D r->cost;
+		spin_unlock_bh(&limit_lock);
+		return 1;
+	}
+
+       	spin_unlock_bh(&limit_lock);
+	return 0;
+}
+
+/* Precision saver. */
+static u_int32_t
+user2credits(u_int32_t user)
+{
+	/* If multiplying would overflow... */
+	if (user > 0xFFFFFFFF / (HZ*CREDITS_PER_JIFFY))
+		/* Divide first. */
+		return (user / XT_LIMIT_SCALE) * HZ * CREDITS_PER_JIFFY;
+
+	return (user * HZ * CREDITS_PER_JIFFY) / XT_LIMIT_SCALE;
+}
+
+static int
+ipt_limit_checkentry(const char *tablename,
+		     const void *inf,
+		     void *matchinfo,
+		     unsigned int matchsize,
+		     unsigned int hook_mask)
+{
+	struct xt_rateinfo *r =3D matchinfo;
+
+	if (matchsize !=3D XT_ALIGN(sizeof(struct xt_rateinfo)))
+		return 0;
+
+	/* Check for overflow. */
+	if (r->burst =3D=3D 0
+	    || user2credits(r->avg * r->burst) < user2credits(r->avg)) {
+		printk("Overflow in xt_limit, try lower: %u/%u\n",
+		       r->avg, r->burst);
+		return 0;
+	}
+
+	/* User avg in seconds * XT_LIMIT_SCALE: convert to jiffies *
+	   128. */
+	r->prev =3D jiffies;
+	r->credit =3D user2credits(r->avg * r->burst);	 /* Credits full. */
+	r->credit_cap =3D user2credits(r->avg * r->burst); /* Credits full. */
+	r->cost =3D user2credits(r->avg);
+
+	/* For SMP, we only want to use one set of counters. */
+	r->master =3D r;
+
+	return 1;
+}
+
+static struct xt_match ipt_limit_reg =3D {
+	.name		=3D "limit",
+	.match		=3D ipt_limit_match,
+	.checkentry	=3D ipt_limit_checkentry,
+	.me		=3D THIS_MODULE,
+};
+static struct xt_match limit6_reg =3D {
+	.name		=3D "limit",
+	.match		=3D ipt_limit_match,
+	.checkentry	=3D ipt_limit_checkentry,
+	.me		=3D THIS_MODULE,
+};
+
+static int __init init(void)
+{
+	int ret;
+=09
+	ret =3D xt_register_match(AF_INET, &ipt_limit_reg);
+	if (ret)
+		return ret;
+=09
+	ret =3D xt_register_match(AF_INET6, &limit6_reg);
+	if (ret)
+		xt_unregister_match(AF_INET, &ipt_limit_reg);
+
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_match(AF_INET, &ipt_limit_reg);
+	xt_unregister_match(AF_INET6, &limit6_reg);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/netfilter/xt_mac.c b/net/netfilter/xt_mac.c
new file mode 100644
index 0000000..0461dcb
--- /dev/null
+++ b/net/netfilter/xt_mac.c
@@ -0,0 +1,100 @@
+/* Kernel module to match MAC address parameters. */
+
+/* (C) 1999-2001 Paul `Rusty' Russell
+ * (C) 2002-2004 Netfilter Core Team <coreteam@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/if_ether.h>
+#include <linux/etherdevice.h>
+
+#include <linux/netfilter_ipv4.h>
+#include <linux/netfilter/xt_mac.h>
+#include <linux/netfilter/x_tables.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
+MODULE_DESCRIPTION("iptables mac matching module");
+MODULE_ALIAS("ipt_mac");
+MODULE_ALIAS("ip6t_mac");
+
+static int
+match(const struct sk_buff *skb,
+      const struct net_device *in,
+      const struct net_device *out,
+      const void *matchinfo,
+      int offset,
+      unsigned int protoff,
+      int *hotdrop)
+{
+    const struct xt_mac_info *info =3D matchinfo;
+
+    /* Is mac pointer valid? */
+    return (skb->mac.raw >=3D skb->head
+	    && (skb->mac.raw + ETH_HLEN) <=3D skb->data
+	    /* If so, compare... */
+	    && ((!compare_ether_addr(eth_hdr(skb)->h_source, info->srcaddr))
+		^ info->invert));
+}
+
+static int
+ipt_mac_checkentry(const char *tablename,
+		   const void *inf,
+		   void *matchinfo,
+		   unsigned int matchsize,
+		   unsigned int hook_mask)
+{
+	/* FORWARD isn't always valid, but it's nice to be able to do --RR */
+	if (hook_mask
+	    & ~((1 << NF_IP_PRE_ROUTING) | (1 << NF_IP_LOCAL_IN)
+		| (1 << NF_IP_FORWARD))) {
+		printk("xt_mac: only valid for PRE_ROUTING, LOCAL_IN or FORWARD.\n");
+		return 0;
+	}
+
+	if (matchsize !=3D XT_ALIGN(sizeof(struct xt_mac_info)))
+		return 0;
+
+	return 1;
+}
+
+static struct xt_match mac_match =3D {
+	.name		=3D "mac",
+	.match		=3D &match,
+	.checkentry	=3D &ipt_mac_checkentry,
+	.me		=3D THIS_MODULE,
+};
+static struct xt_match mac6_match =3D {
+	.name		=3D "mac",
+	.match		=3D &match,
+	.checkentry	=3D &ipt_mac_checkentry,
+	.me		=3D THIS_MODULE,
+};
+
+static int __init init(void)
+{
+	int ret;
+	ret =3D xt_register_match(AF_INET, &mac_match);
+	if (ret)
+		return ret;
+
+	ret =3D xt_register_match(AF_INET6, &mac6_match);
+	if (ret)
+		xt_unregister_match(AF_INET, &mac_match);
+
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_match(AF_INET, &mac_match);
+	xt_unregister_match(AF_INET6, &mac6_match);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/netfilter/xt_mark.c b/net/netfilter/xt_mark.c
new file mode 100644
index 0000000..2a0ac62
--- /dev/null
+++ b/net/netfilter/xt_mark.c
@@ -0,0 +1,91 @@
+/* Kernel module to match NFMARK values. */
+
+/* (C) 1999-2001 Marc Boucher <marc@mbsi.ca>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+
+#include <linux/netfilter/xt_mark.h>
+#include <linux/netfilter/x_tables.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Marc Boucher <marc@mbsi.ca>");
+MODULE_DESCRIPTION("iptables mark matching module");
+MODULE_ALIAS("ipt_mark");
+MODULE_ALIAS("ip6t_mark");
+
+static int
+match(const struct sk_buff *skb,
+      const struct net_device *in,
+      const struct net_device *out,
+      const void *matchinfo,
+      int offset,
+      unsigned int protoff,
+      int *hotdrop)
+{
+	const struct xt_mark_info *info =3D matchinfo;
+
+	return ((skb->nfmark & info->mask) =3D=3D info->mark) ^ info->invert;
+}
+
+static int
+checkentry(const char *tablename,
+           const void *entry,
+           void *matchinfo,
+           unsigned int matchsize,
+           unsigned int hook_mask)
+{
+	struct xt_mark_info *minfo =3D (struct xt_mark_info *) matchinfo;
+
+	if (matchsize !=3D XT_ALIGN(sizeof(struct xt_mark_info)))
+		return 0;
+
+	if (minfo->mark > 0xffffffff || minfo->mask > 0xffffffff) {
+		printk(KERN_WARNING "mark: only supports 32bit mark\n");
+		return 0;
+	}
+
+	return 1;
+}
+
+static struct xt_match mark_match =3D {
+	.name		=3D "mark",
+	.match		=3D &match,
+	.checkentry	=3D &checkentry,
+	.me		=3D THIS_MODULE,
+};
+
+static struct xt_match mark6_match =3D {
+	.name		=3D "mark",
+	.match		=3D &match,
+	.checkentry	=3D &checkentry,
+	.me		=3D THIS_MODULE,
+};
+
+static int __init init(void)
+{
+	int ret;
+	ret =3D xt_register_match(AF_INET, &mark_match);
+	if (ret)
+		return ret;
+
+	ret =3D xt_register_match(AF_INET6, &mark6_match);
+	if (ret)
+		xt_unregister_match(AF_INET, &mark_match);
+
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_match(AF_INET, &mark_match);
+	xt_unregister_match(AF_INET6, &mark6_match);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
new file mode 100644
index 0000000..19bb57c
--- /dev/null
+++ b/net/netfilter/xt_physdev.c
@@ -0,0 +1,155 @@
+/* Kernel module to match the bridge port in and
+ * out device for IP packets coming into contact with a bridge. */
+
+/* (C) 2001-2003 Bart De Schuymer <bdschuym@pandora.be>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/netfilter/xt_physdev.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter_bridge.h>
+#define MATCH   1
+#define NOMATCH 0
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Bart De Schuymer <bdschuym@pandora.be>");
+MODULE_DESCRIPTION("iptables bridge physical device match module");
+MODULE_ALIAS("ipt_physdev");
+MODULE_ALIAS("ip6t_physdev");
+
+static int
+match(const struct sk_buff *skb,
+      const struct net_device *in,
+      const struct net_device *out,
+      const void *matchinfo,
+      int offset,
+      unsigned int protoff,
+      int *hotdrop)
+{
+	int i;
+	static const char nulldevname[IFNAMSIZ];
+	const struct xt_physdev_info *info =3D matchinfo;
+	unsigned int ret;
+	const char *indev, *outdev;
+	struct nf_bridge_info *nf_bridge;
+
+	/* Not a bridged IP packet or no info available yet:
+	 * LOCAL_OUT/mangle and LOCAL_OUT/nat don't know if
+	 * the destination device will be a bridge. */
+	if (!(nf_bridge =3D skb->nf_bridge)) {
+		/* Return MATCH if the invert flags of the used options are on */
+		if ((info->bitmask & XT_PHYSDEV_OP_BRIDGED) &&
+		    !(info->invert & XT_PHYSDEV_OP_BRIDGED))
+			return NOMATCH;
+		if ((info->bitmask & XT_PHYSDEV_OP_ISIN) &&
+		    !(info->invert & XT_PHYSDEV_OP_ISIN))
+			return NOMATCH;
+		if ((info->bitmask & XT_PHYSDEV_OP_ISOUT) &&
+		    !(info->invert & XT_PHYSDEV_OP_ISOUT))
+			return NOMATCH;
+		if ((info->bitmask & XT_PHYSDEV_OP_IN) &&
+		    !(info->invert & XT_PHYSDEV_OP_IN))
+			return NOMATCH;
+		if ((info->bitmask & XT_PHYSDEV_OP_OUT) &&
+		    !(info->invert & XT_PHYSDEV_OP_OUT))
+			return NOMATCH;
+		return MATCH;
+	}
+
+	/* This only makes sense in the FORWARD and POSTROUTING chains */
+	if ((info->bitmask & XT_PHYSDEV_OP_BRIDGED) &&
+	    (!!(nf_bridge->mask & BRNF_BRIDGED) ^
+	    !(info->invert & XT_PHYSDEV_OP_BRIDGED)))
+		return NOMATCH;
+
+	if ((info->bitmask & XT_PHYSDEV_OP_ISIN &&
+	    (!nf_bridge->physindev ^ !!(info->invert & XT_PHYSDEV_OP_ISIN))) ||
+	    (info->bitmask & XT_PHYSDEV_OP_ISOUT &&
+	    (!nf_bridge->physoutdev ^ !!(info->invert & XT_PHYSDEV_OP_ISOUT))))
+		return NOMATCH;
+
+	if (!(info->bitmask & XT_PHYSDEV_OP_IN))
+		goto match_outdev;
+	indev =3D nf_bridge->physindev ? nf_bridge->physindev->name : nulldevname;
+	for (i =3D 0, ret =3D 0; i < IFNAMSIZ/sizeof(unsigned int); i++) {
+		ret |=3D (((const unsigned int *)indev)[i]
+			^ ((const unsigned int *)info->physindev)[i])
+			& ((const unsigned int *)info->in_mask)[i];
+	}
+
+	if ((ret =3D=3D 0) ^ !(info->invert & XT_PHYSDEV_OP_IN))
+		return NOMATCH;
+
+match_outdev:
+	if (!(info->bitmask & XT_PHYSDEV_OP_OUT))
+		return MATCH;
+	outdev =3D nf_bridge->physoutdev ?
+		 nf_bridge->physoutdev->name : nulldevname;
+	for (i =3D 0, ret =3D 0; i < IFNAMSIZ/sizeof(unsigned int); i++) {
+		ret |=3D (((const unsigned int *)outdev)[i]
+			^ ((const unsigned int *)info->physoutdev)[i])
+			& ((const unsigned int *)info->out_mask)[i];
+	}
+
+	return (ret !=3D 0) ^ !(info->invert & XT_PHYSDEV_OP_OUT);
+}
+
+static int
+checkentry(const char *tablename,
+		       const void *ip,
+		       void *matchinfo,
+		       unsigned int matchsize,
+		       unsigned int hook_mask)
+{
+	const struct xt_physdev_info *info =3D matchinfo;
+
+	if (matchsize !=3D XT_ALIGN(sizeof(struct xt_physdev_info)))
+		return 0;
+	if (!(info->bitmask & XT_PHYSDEV_OP_MASK) ||
+	    info->bitmask & ~XT_PHYSDEV_OP_MASK)
+		return 0;
+	return 1;
+}
+
+static struct xt_match physdev_match =3D {
+	.name		=3D "physdev",
+	.match		=3D &match,
+	.checkentry	=3D &checkentry,
+	.me		=3D THIS_MODULE,
+};
+
+static struct xt_match physdev6_match =3D {
+	.name		=3D "physdev",
+	.match		=3D &match,
+	.checkentry	=3D &checkentry,
+	.me		=3D THIS_MODULE,
+};
+
+static int __init init(void)
+{
+	int ret;
+
+	ret =3D xt_register_match(AF_INET, &physdev_match);
+	if (ret < 0)
+		return ret;
+
+	ret =3D xt_register_match(AF_INET6, &physdev6_match);
+	if (ret < 0)
+		xt_unregister_match(AF_INET, &physdev_match);
+
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_match(AF_INET, &physdev_match);
+	xt_unregister_match(AF_INET6, &physdev6_match);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/netfilter/xt_pkttype.c b/net/netfilter/xt_pkttype.c
new file mode 100644
index 0000000..ab1b263
--- /dev/null
+++ b/net/netfilter/xt_pkttype.c
@@ -0,0 +1,82 @@
+/* (C) 1999-2001 Michal Ludvig <michal@logix.cz>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/if_ether.h>
+#include <linux/if_packet.h>
+
+#include <linux/netfilter/xt_pkttype.h>
+#include <linux/netfilter/x_tables.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Michal Ludvig <michal@logix.cz>");
+MODULE_DESCRIPTION("IP tables match to match on linklayer packet type");
+MODULE_ALIAS("ipt_pkttype");
+MODULE_ALIAS("ip6t_pkttype");
+
+static int match(const struct sk_buff *skb,
+      const struct net_device *in,
+      const struct net_device *out,
+      const void *matchinfo,
+      int offset,
+      unsigned int protoff,
+      int *hotdrop)
+{
+	const struct xt_pkttype_info *info =3D matchinfo;
+
+	return (skb->pkt_type =3D=3D info->pkttype) ^ info->invert;
+}
+
+static int checkentry(const char *tablename,
+		   const void *ip,
+		   void *matchinfo,
+		   unsigned int matchsize,
+		   unsigned int hook_mask)
+{
+	if (matchsize !=3D XT_ALIGN(sizeof(struct xt_pkttype_info)))
+		return 0;
+
+	return 1;
+}
+
+static struct xt_match pkttype_match =3D {
+	.name		=3D "pkttype",
+	.match		=3D &match,
+	.checkentry	=3D &checkentry,
+	.me		=3D THIS_MODULE,
+};
+static struct xt_match pkttype6_match =3D {
+	.name		=3D "pkttype",
+	.match		=3D &match,
+	.checkentry	=3D &checkentry,
+	.me		=3D THIS_MODULE,
+};
+
+
+static int __init init(void)
+{
+	int ret;
+	ret =3D xt_register_match(AF_INET, &pkttype_match);
+	if (ret)
+		return ret;
+
+	ret =3D xt_register_match(AF_INET6, &pkttype6_match);
+	if (ret)
+		xt_unregister_match(AF_INET, &pkttype_match);
+
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_match(AF_INET, &pkttype_match);
+	xt_unregister_match(AF_INET6, &pkttype6_match);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/netfilter/xt_realm.c b/net/netfilter/xt_realm.c
new file mode 100644
index 0000000..2b7e178
--- /dev/null
+++ b/net/netfilter/xt_realm.c
@@ -0,0 +1,79 @@
+/* IP tables module for matching the routing realm
+ *
+ * $Id: ipt_realm.c,v 1.3 2004/03/05 13:25:40 laforge Exp $
+ *
+ * (C) 2003 by Sampsa Ranta <sampsa@netsonic.fi>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <net/route.h>
+
+#include <linux/netfilter_ipv4.h>
+#include <linux/netfilter/xt_realm.h>
+#include <linux/netfilter/x_tables.h>
+
+MODULE_AUTHOR("Sampsa Ranta <sampsa@netsonic.fi>");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("X_tables realm match");
+MODULE_ALIAS("ipt_realm");
+
+static int
+match(const struct sk_buff *skb,
+      const struct net_device *in,
+      const struct net_device *out,
+      const void *matchinfo,
+      int offset,
+      unsigned int protoff,
+      int *hotdrop)
+{
+	const struct xt_realm_info *info =3D matchinfo;
+	struct dst_entry *dst =3D skb->dst;
+   =20
+	return (info->id =3D=3D (dst->tclassid & info->mask)) ^ info->invert;
+}
+
+static int check(const char *tablename,
+                 const void *ip,
+                 void *matchinfo,
+                 unsigned int matchsize,
+                 unsigned int hook_mask)
+{
+	if (hook_mask
+	    & ~((1 << NF_IP_POST_ROUTING) | (1 << NF_IP_FORWARD) |
+	        (1 << NF_IP_LOCAL_OUT) | (1 << NF_IP_LOCAL_IN))) {
+		printk("xt_realm: only valid for POST_ROUTING, LOCAL_OUT, "
+		       "LOCAL_IN or FORWARD.\n");
+		return 0;
+	}
+	if (matchsize !=3D XT_ALIGN(sizeof(struct xt_realm_info))) {
+		printk("xt_realm: invalid matchsize.\n");
+		return 0;
+	}
+	return 1;
+}
+
+static struct xt_match realm_match =3D {
+	.name		=3D "realm",
+	.match		=3D match,=20
+	.checkentry	=3D check,
+	.me		=3D THIS_MODULE
+};
+
+static int __init init(void)
+{
+	return xt_register_match(AF_INET, &realm_match);
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_match(AF_INET, &realm_match);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/netfilter/xt_sctp.c b/net/netfilter/xt_sctp.c
new file mode 100644
index 0000000..10fbfc5
--- /dev/null
+++ b/net/netfilter/xt_sctp.c
@@ -0,0 +1,250 @@
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <net/ip.h>
+#include <net/ipv6.h>
+#include <linux/sctp.h>
+
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_sctp.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter_ipv6/ip6_tables.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Kiran Kumar Immidi");
+MODULE_DESCRIPTION("Match for SCTP protocol packets");
+MODULE_ALIAS("ipt_sctp");
+
+#ifdef DEBUG_SCTP
+#define duprintf(format, args...) printk(format , ## args)
+#else
+#define duprintf(format, args...)
+#endif
+
+#define SCCHECK(cond, option, flag, invflag) (!((flag) & (option)) \
+					      || (!!((invflag) & (option)) ^ (cond)))
+
+static int
+match_flags(const struct xt_sctp_flag_info *flag_info,
+	    const int flag_count,
+	    u_int8_t chunktype,
+	    u_int8_t chunkflags)
+{
+	int i;
+
+	for (i =3D 0; i < flag_count; i++) {
+		if (flag_info[i].chunktype =3D=3D chunktype) {
+			return (chunkflags & flag_info[i].flag_mask) =3D=3D flag_info[i].flag;
+		}
+	}
+
+	return 1;
+}
+
+static inline int
+match_packet(const struct sk_buff *skb,
+	     unsigned int offset,
+	     const u_int32_t *chunkmap,
+	     int chunk_match_type,
+	     const struct xt_sctp_flag_info *flag_info,
+	     const int flag_count,
+	     int *hotdrop)
+{
+	u_int32_t chunkmapcopy[256 / sizeof (u_int32_t)];
+	sctp_chunkhdr_t _sch, *sch;
+
+#ifdef DEBUG_SCTP
+	int i =3D 0;
+#endif
+
+	if (chunk_match_type =3D=3D SCTP_CHUNK_MATCH_ALL) {
+		SCTP_CHUNKMAP_COPY(chunkmapcopy, chunkmap);
+	}
+
+	do {
+		sch =3D skb_header_pointer(skb, offset, sizeof(_sch), &_sch);
+		if (sch =3D=3D NULL) {
+			duprintf("Dropping invalid SCTP packet.\n");
+			*hotdrop =3D 1;
+			return 0;
+        	}
+
+		duprintf("Chunk num: %d\toffset: %d\ttype: %d\tlength: %d\tflags: %x\n",=
=20
+				++i, offset, sch->type, htons(sch->length), sch->flags);
+
+		offset +=3D (htons(sch->length) + 3) & ~3;
+
+		duprintf("skb->len: %d\toffset: %d\n", skb->len, offset);
+
+		if (SCTP_CHUNKMAP_IS_SET(chunkmap, sch->type)) {
+			switch (chunk_match_type) {
+			case SCTP_CHUNK_MATCH_ANY:
+				if (match_flags(flag_info, flag_count,=20
+					sch->type, sch->flags)) {
+					return 1;
+				}
+				break;
+
+			case SCTP_CHUNK_MATCH_ALL:
+				if (match_flags(flag_info, flag_count,=20
+					sch->type, sch->flags)) {
+					SCTP_CHUNKMAP_CLEAR(chunkmapcopy, sch->type);
+				}
+				break;
+
+			case SCTP_CHUNK_MATCH_ONLY:
+				if (!match_flags(flag_info, flag_count,=20
+					sch->type, sch->flags)) {
+					return 0;
+				}
+				break;
+			}
+		} else {
+			switch (chunk_match_type) {
+			case SCTP_CHUNK_MATCH_ONLY:
+				return 0;
+			}
+		}
+	} while (offset < skb->len);
+
+	switch (chunk_match_type) {
+	case SCTP_CHUNK_MATCH_ALL:
+		return SCTP_CHUNKMAP_IS_CLEAR(chunkmap);
+	case SCTP_CHUNK_MATCH_ANY:
+		return 0;
+	case SCTP_CHUNK_MATCH_ONLY:
+		return 1;
+	}
+
+	/* This will never be reached, but required to stop compiler whine */
+	return 0;
+}
+
+static int
+match(const struct sk_buff *skb,
+      const struct net_device *in,
+      const struct net_device *out,
+      const void *matchinfo,
+      int offset,
+      unsigned int protoff,
+      int *hotdrop)
+{
+	const struct xt_sctp_info *info;
+	sctp_sctphdr_t _sh, *sh;
+
+	info =3D (const struct xt_sctp_info *)matchinfo;
+
+	if (offset) {
+		duprintf("Dropping non-first fragment.. FIXME\n");
+		return 0;
+	}
+=09
+	sh =3D skb_header_pointer(skb, protoff, sizeof(_sh), &_sh);
+	if (sh =3D=3D NULL) {
+		duprintf("Dropping evil TCP offset=3D0 tinygram.\n");
+		*hotdrop =3D 1;
+		return 0;
+       	}
+	duprintf("spt: %d\tdpt: %d\n", ntohs(sh->source), ntohs(sh->dest));
+
+	return  SCCHECK(((ntohs(sh->source) >=3D info->spts[0])=20
+			&& (ntohs(sh->source) <=3D info->spts[1])),=20
+		   	XT_SCTP_SRC_PORTS, info->flags, info->invflags)
+		&& SCCHECK(((ntohs(sh->dest) >=3D info->dpts[0])=20
+			&& (ntohs(sh->dest) <=3D info->dpts[1])),=20
+			XT_SCTP_DEST_PORTS, info->flags, info->invflags)
+		&& SCCHECK(match_packet(skb, protoff,
+					info->chunkmap, info->chunk_match_type,
+ 					info->flag_info, info->flag_count,=20
+					hotdrop),
+			   XT_SCTP_CHUNK_TYPES, info->flags, info->invflags);
+}
+
+static int
+checkentry(const char *tablename,
+	   const void *inf,
+	   void *matchinfo,
+	   unsigned int matchsize,
+	   unsigned int hook_mask)
+{
+	const struct xt_sctp_info *info;
+	const struct ipt_ip *ip =3D inf;
+
+	info =3D (const struct xt_sctp_info *)matchinfo;
+
+	return ip->proto =3D=3D IPPROTO_SCTP
+		&& !(ip->invflags & XT_INV_PROTO)
+		&& matchsize =3D=3D XT_ALIGN(sizeof(struct xt_sctp_info))
+		&& !(info->flags & ~XT_SCTP_VALID_FLAGS)
+		&& !(info->invflags & ~XT_SCTP_VALID_FLAGS)
+		&& !(info->invflags & ~info->flags)
+		&& ((!(info->flags & XT_SCTP_CHUNK_TYPES)) ||=20
+			(info->chunk_match_type &
+				(SCTP_CHUNK_MATCH_ALL=20
+				| SCTP_CHUNK_MATCH_ANY
+				| SCTP_CHUNK_MATCH_ONLY)));
+}
+
+static int
+checkentry6(const char *tablename,
+	   const void *inf,
+	   void *matchinfo,
+	   unsigned int matchsize,
+	   unsigned int hook_mask)
+{
+	const struct xt_sctp_info *info;
+	const struct ip6t_ip6 *ip =3D inf;
+
+	info =3D (const struct xt_sctp_info *)matchinfo;
+
+	return ip->proto =3D=3D IPPROTO_SCTP
+		&& !(ip->invflags & XT_INV_PROTO)
+		&& matchsize =3D=3D XT_ALIGN(sizeof(struct xt_sctp_info))
+		&& !(info->flags & ~XT_SCTP_VALID_FLAGS)
+		&& !(info->invflags & ~XT_SCTP_VALID_FLAGS)
+		&& !(info->invflags & ~info->flags)
+		&& ((!(info->flags & XT_SCTP_CHUNK_TYPES)) ||=20
+			(info->chunk_match_type &
+				(SCTP_CHUNK_MATCH_ALL=20
+				| SCTP_CHUNK_MATCH_ANY
+				| SCTP_CHUNK_MATCH_ONLY)));
+}
+
+
+static struct xt_match sctp_match =3D=20
+{=20
+	.name =3D "sctp",
+	.match =3D &match,
+	.checkentry =3D &checkentry,
+	.me =3D THIS_MODULE
+};
+static struct xt_match sctp6_match =3D=20
+{=20
+	.name =3D "sctp",
+	.match =3D &match,
+	.checkentry =3D &checkentry6,
+	.me =3D THIS_MODULE
+};
+
+
+static int __init init(void)
+{
+	int ret;
+	ret =3D xt_register_match(AF_INET, &sctp_match);
+	if (ret)
+		return ret;
+
+	ret =3D xt_register_match(AF_INET6, &sctp6_match);
+	if (ret)
+		xt_unregister_match(AF_INET, &sctp_match);
+
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_match(AF_INET6, &sctp6_match);
+	xt_unregister_match(AF_INET, &sctp_match);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/netfilter/xt_state.c b/net/netfilter/xt_state.c
new file mode 100644
index 0000000..39ce808
--- /dev/null
+++ b/net/netfilter/xt_state.c
@@ -0,0 +1,96 @@
+/* Kernel module to match connection tracking information. */
+
+/* (C) 1999-2001 Paul `Rusty' Russell
+ * (C) 2002-2005 Netfilter Core Team <coreteam@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <net/netfilter/nf_conntrack_compat.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_state.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Rusty Russell <rusty@rustcorp.com.au>");
+MODULE_DESCRIPTION("ip[6]_tables connection tracking state match module");
+MODULE_ALIAS("ipt_state");
+MODULE_ALIAS("ip6t_state");
+
+static int
+match(const struct sk_buff *skb,
+      const struct net_device *in,
+      const struct net_device *out,
+      const void *matchinfo,
+      int offset,
+      unsigned int protoff,
+      int *hotdrop)
+{
+	const struct xt_state_info *sinfo =3D matchinfo;
+	enum ip_conntrack_info ctinfo;
+	unsigned int statebit;
+
+	if (nf_ct_is_untracked(skb))
+		statebit =3D XT_STATE_UNTRACKED;
+	else if (!nf_ct_get_ctinfo(skb, &ctinfo))
+		statebit =3D XT_STATE_INVALID;
+	else
+		statebit =3D XT_STATE_BIT(ctinfo);
+
+	return (sinfo->statemask & statebit);
+}
+
+static int check(const char *tablename,
+		 const void *ip,
+		 void *matchinfo,
+		 unsigned int matchsize,
+		 unsigned int hook_mask)
+{
+	if (matchsize !=3D XT_ALIGN(sizeof(struct xt_state_info)))
+		return 0;
+
+	return 1;
+}
+
+static struct xt_match state_match =3D {
+	.name		=3D "state",
+	.match		=3D &match,
+	.checkentry	=3D &check,
+	.me		=3D THIS_MODULE,
+};
+
+static struct xt_match state6_match =3D {
+	.name		=3D "state",
+	.match		=3D &match,
+	.checkentry	=3D &check,
+	.me		=3D THIS_MODULE,
+};
+
+static int __init init(void)
+{
+	int ret;
+
+	need_conntrack();
+
+	ret =3D xt_register_match(AF_INET, &state_match);
+	if (ret < 0)
+		return ret;
+
+	ret =3D xt_register_match(AF_INET6, &state6_match);
+	if (ret < 0)
+		xt_unregister_match(AF_INET,&state_match);
+
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_match(AF_INET, &state_match);
+	xt_unregister_match(AF_INET6, &state6_match);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/netfilter/xt_string.c b/net/netfilter/xt_string.c
new file mode 100644
index 0000000..7c7d5c8
--- /dev/null
+++ b/net/netfilter/xt_string.c
@@ -0,0 +1,111 @@
+/* String matching match for iptables
+ *=20
+ * (C) 2005 Pablo Neira Ayuso <pablo@eurodev.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/skbuff.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_string.h>
+#include <linux/textsearch.h>
+
+MODULE_AUTHOR("Pablo Neira Ayuso <pablo@eurodev.net>");
+MODULE_DESCRIPTION("IP tables string match module");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("ipt_string");
+MODULE_ALIAS("ip6t_string");
+
+static int match(const struct sk_buff *skb,
+		 const struct net_device *in,
+		 const struct net_device *out,
+		 const void *matchinfo,
+		 int offset,
+		 unsigned int protoff,
+		 int *hotdrop)
+{
+	struct ts_state state;
+	struct xt_string_info *conf =3D (struct xt_string_info *) matchinfo;
+
+	memset(&state, 0, sizeof(struct ts_state));
+
+	return (skb_find_text((struct sk_buff *)skb, conf->from_offset,=20
+			     conf->to_offset, conf->config, &state)=20
+			     !=3D UINT_MAX) && !conf->invert;
+}
+
+#define STRING_TEXT_PRIV(m) ((struct xt_string_info *) m)
+
+static int checkentry(const char *tablename,
+		      const void *ip,
+		      void *matchinfo,
+		      unsigned int matchsize,
+		      unsigned int hook_mask)
+{
+	struct xt_string_info *conf =3D matchinfo;
+	struct ts_config *ts_conf;
+
+	if (matchsize !=3D XT_ALIGN(sizeof(struct xt_string_info)))
+		return 0;
+
+	/* Damn, can't handle this case properly with iptables... */
+	if (conf->from_offset > conf->to_offset)
+		return 0;
+
+	ts_conf =3D textsearch_prepare(conf->algo, conf->pattern, conf->patlen,
+				     GFP_KERNEL, TS_AUTOLOAD);
+	if (IS_ERR(ts_conf))
+		return 0;
+
+	conf->config =3D ts_conf;
+
+	return 1;
+}
+
+static void destroy(void *matchinfo, unsigned int matchsize)
+{
+	textsearch_destroy(STRING_TEXT_PRIV(matchinfo)->config);
+}
+
+static struct xt_match string_match =3D {
+	.name 		=3D "string",
+	.match 		=3D match,
+	.checkentry	=3D checkentry,
+	.destroy 	=3D destroy,
+	.me 		=3D THIS_MODULE
+};
+static struct xt_match string6_match =3D {
+	.name 		=3D "string",
+	.match 		=3D match,
+	.checkentry	=3D checkentry,
+	.destroy 	=3D destroy,
+	.me 		=3D THIS_MODULE
+};
+
+static int __init init(void)
+{
+	int ret;
+
+	ret =3D xt_register_match(AF_INET, &string_match);
+	if (ret)
+		return ret;
+	ret =3D xt_register_match(AF_INET6, &string6_match);
+	if (ret)
+		xt_unregister_match(AF_INET, &string_match);
+
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_match(AF_INET, &string_match);
+	xt_unregister_match(AF_INET6, &string6_match);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/netfilter/xt_tcpmss.c b/net/netfilter/xt_tcpmss.c
new file mode 100644
index 0000000..acf7f53
--- /dev/null
+++ b/net/netfilter/xt_tcpmss.c
@@ -0,0 +1,172 @@
+/* Kernel module to match TCP MSS values. */
+
+/* Copyright (C) 2000 Marc Boucher <marc@mbsi.ca>
+ * Portions (C) 2005 by Harald Welte <laforge@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <net/tcp.h>
+
+#include <linux/netfilter/xt_tcpmss.h>
+#include <linux/netfilter/x_tables.h>
+
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter_ipv6/ip6_tables.h>
+
+#define TH_SYN 0x02
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Marc Boucher <marc@mbsi.ca>");
+MODULE_DESCRIPTION("iptables TCP MSS match module");
+MODULE_ALIAS("ipt_tcpmss");
+
+/* Returns 1 if the mss option is set and matched by the range, 0 otherwis=
e */
+static inline int
+mssoption_match(u_int16_t min, u_int16_t max,
+		const struct sk_buff *skb,
+		unsigned int protoff,
+		int invert,
+		int *hotdrop)
+{
+	struct tcphdr _tcph, *th;
+	/* tcp.doff is only 4 bits, ie. max 15 * 4 bytes */
+	u8 _opt[15 * 4 - sizeof(_tcph)], *op;
+	unsigned int i, optlen;
+
+	/* If we don't have the whole header, drop packet. */
+	th =3D skb_header_pointer(skb, protoff, sizeof(_tcph), &_tcph);
+	if (th =3D=3D NULL)
+		goto dropit;
+
+	/* Malformed. */
+	if (th->doff*4 < sizeof(*th))
+		goto dropit;
+
+	optlen =3D th->doff*4 - sizeof(*th);
+	if (!optlen)
+		goto out;
+
+	/* Truncated options. */
+	op =3D skb_header_pointer(skb, protoff + sizeof(*th), optlen, _opt);
+	if (op =3D=3D NULL)
+		goto dropit;
+
+	for (i =3D 0; i < optlen; ) {
+		if (op[i] =3D=3D TCPOPT_MSS
+		    && (optlen - i) >=3D TCPOLEN_MSS
+		    && op[i+1] =3D=3D TCPOLEN_MSS) {
+			u_int16_t mssval;
+
+			mssval =3D (op[i+2] << 8) | op[i+3];
+		=09
+			return (mssval >=3D min && mssval <=3D max) ^ invert;
+		}
+		if (op[i] < 2) i++;
+		else i +=3D op[i+1]?:1;
+	}
+out:
+	return invert;
+
+ dropit:
+	*hotdrop =3D 1;
+	return 0;
+}
+
+static int
+match(const struct sk_buff *skb,
+      const struct net_device *in,
+      const struct net_device *out,
+      const void *matchinfo,
+      int offset,
+      unsigned int protoff,
+      int *hotdrop)
+{
+	const struct xt_tcpmss_match_info *info =3D matchinfo;
+
+	return mssoption_match(info->mss_min, info->mss_max, skb, protoff,
+			       info->invert, hotdrop);
+}
+
+static int
+checkentry(const char *tablename,
+           const void *ipinfo,
+           void *matchinfo,
+           unsigned int matchsize,
+           unsigned int hook_mask)
+{
+	const struct ipt_ip *ip =3D ipinfo;
+	if (matchsize !=3D XT_ALIGN(sizeof(struct xt_tcpmss_match_info)))
+		return 0;
+
+	/* Must specify -p tcp */
+	if (ip->proto !=3D IPPROTO_TCP || (ip->invflags & IPT_INV_PROTO)) {
+		printk("tcpmss: Only works on TCP packets\n");
+		return 0;
+	}
+
+	return 1;
+}
+
+static int
+checkentry6(const char *tablename,
+	   const void *ipinfo,
+           void *matchinfo,
+           unsigned int matchsize,
+           unsigned int hook_mask)
+{
+	const struct ip6t_ip6 *ip =3D ipinfo;
+
+	if (matchsize !=3D XT_ALIGN(sizeof(struct xt_tcpmss_match_info)))
+		return 0;
+
+	/* Must specify -p tcp */
+	if (ip->proto !=3D IPPROTO_TCP || (ip->invflags & XT_INV_PROTO)) {
+		printk("tcpmss: Only works on TCP packets\n");
+		return 0;
+	}
+
+	return 1;
+}
+
+static struct xt_match tcpmss_match =3D {
+	.name		=3D "tcpmss",
+	.match		=3D &match,
+	.checkentry	=3D &checkentry,
+	.me		=3D THIS_MODULE,
+};
+
+static struct xt_match tcpmss6_match =3D {
+	.name		=3D "tcpmss",
+	.match		=3D &match,
+	.checkentry	=3D &checkentry6,
+	.me		=3D THIS_MODULE,
+};
+
+
+static int __init init(void)
+{
+	int ret;
+	ret =3D xt_register_match(AF_INET, &tcpmss_match);
+	if (ret)
+		return ret;
+
+	ret =3D xt_register_match(AF_INET6, &tcpmss6_match);
+	if (ret)
+		xt_unregister_match(AF_INET, &tcpmss_match);
+
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_match(AF_INET6, &tcpmss6_match);
+	xt_unregister_match(AF_INET, &tcpmss_match);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/netfilter/xt_tcpudp.c b/net/netfilter/xt_tcpudp.c
new file mode 100644
index 0000000..33f86fd
--- /dev/null
+++ b/net/netfilter/xt_tcpudp.c
@@ -0,0 +1,333 @@
+#include <linux/types.h>
+#include <linux/module.h>
+#include <net/ip.h>
+#include <net/ipv6.h>
+#include <net/tcp.h>
+#include <net/udp.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_tcpudp.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter_ipv6/ip6_tables.h>
+
+MODULE_DESCRIPTION("x_tables match for TCP and UDP, supports IPv4 and IPv6=
");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("xt_tcp");
+MODULE_ALIAS("xt_udp");
+MODULE_ALIAS("ipt_udp");
+MODULE_ALIAS("ipt_tcp");
+MODULE_ALIAS("ip6t_udp");
+MODULE_ALIAS("ip6t_tcp");
+
+#ifdef DEBUG_IP_FIREWALL_USER
+#define duprintf(format, args...) printk(format , ## args)
+#else
+#define duprintf(format, args...)
+#endif
+
+
+/* Returns 1 if the port is matched by the range, 0 otherwise */
+static inline int
+port_match(u_int16_t min, u_int16_t max, u_int16_t port, int invert)
+{
+	int ret;
+
+	ret =3D (port >=3D min && port <=3D max) ^ invert;
+	return ret;
+}
+
+static int
+tcp_find_option(u_int8_t option,
+		const struct sk_buff *skb,
+		unsigned int protoff,
+		unsigned int optlen,
+		int invert,
+		int *hotdrop)
+{
+	/* tcp.doff is only 4 bits, ie. max 15 * 4 bytes */
+	u_int8_t _opt[60 - sizeof(struct tcphdr)], *op;
+	unsigned int i;
+
+	duprintf("tcp_match: finding option\n");
+
+	if (!optlen)
+		return invert;
+
+	/* If we don't have the whole header, drop packet. */
+	op =3D skb_header_pointer(skb, protoff + sizeof(struct tcphdr),
+				optlen, _opt);
+	if (op =3D=3D NULL) {
+		*hotdrop =3D 1;
+		return 0;
+	}
+
+	for (i =3D 0; i < optlen; ) {
+		if (op[i] =3D=3D option) return !invert;
+		if (op[i] < 2) i++;
+		else i +=3D op[i+1]?:1;
+	}
+
+	return invert;
+}
+
+static int
+tcp_match(const struct sk_buff *skb,
+	  const struct net_device *in,
+	  const struct net_device *out,
+	  const void *matchinfo,
+	  int offset,
+	  unsigned int protoff,
+	  int *hotdrop)
+{
+	struct tcphdr _tcph, *th;
+	const struct xt_tcp *tcpinfo =3D matchinfo;
+
+	if (offset) {
+		/* To quote Alan:
+
+		   Don't allow a fragment of TCP 8 bytes in. Nobody normal
+		   causes this. Its a cracker trying to break in by doing a
+		   flag overwrite to pass the direction checks.
+		*/
+		if (offset =3D=3D 1) {
+			duprintf("Dropping evil TCP offset=3D1 frag.\n");
+			*hotdrop =3D 1;
+		}
+		/* Must not be a fragment. */
+		return 0;
+	}
+
+#define FWINVTCP(bool,invflg) ((bool) ^ !!(tcpinfo->invflags & invflg))
+
+	th =3D skb_header_pointer(skb, protoff, sizeof(_tcph), &_tcph);
+	if (th =3D=3D NULL) {
+		/* We've been asked to examine this packet, and we
+		   can't.  Hence, no choice but to drop. */
+		duprintf("Dropping evil TCP offset=3D0 tinygram.\n");
+		*hotdrop =3D 1;
+		return 0;
+	}
+
+	if (!port_match(tcpinfo->spts[0], tcpinfo->spts[1],
+			ntohs(th->source),
+			!!(tcpinfo->invflags & XT_TCP_INV_SRCPT)))
+		return 0;
+	if (!port_match(tcpinfo->dpts[0], tcpinfo->dpts[1],
+			ntohs(th->dest),
+			!!(tcpinfo->invflags & XT_TCP_INV_DSTPT)))
+		return 0;
+	if (!FWINVTCP((((unsigned char *)th)[13] & tcpinfo->flg_mask)
+		      =3D=3D tcpinfo->flg_cmp,
+		      XT_TCP_INV_FLAGS))
+		return 0;
+	if (tcpinfo->option) {
+		if (th->doff * 4 < sizeof(_tcph)) {
+			*hotdrop =3D 1;
+			return 0;
+		}
+		if (!tcp_find_option(tcpinfo->option, skb, protoff,
+				     th->doff*4 - sizeof(_tcph),
+				     tcpinfo->invflags & XT_TCP_INV_OPTION,
+				     hotdrop))
+			return 0;
+	}
+	return 1;
+}
+
+/* Called when user tries to insert an entry of this type. */
+static int
+tcp_checkentry(const char *tablename,
+	       const void *info,
+	       void *matchinfo,
+	       unsigned int matchsize,
+	       unsigned int hook_mask)
+{
+	const struct ipt_ip *ip =3D info;
+	const struct xt_tcp *tcpinfo =3D matchinfo;
+
+	/* Must specify proto =3D=3D TCP, and no unknown invflags */
+	return ip->proto =3D=3D IPPROTO_TCP
+		&& !(ip->invflags & XT_INV_PROTO)
+		&& matchsize =3D=3D XT_ALIGN(sizeof(struct xt_tcp))
+		&& !(tcpinfo->invflags & ~XT_TCP_INV_MASK);
+}
+
+/* Called when user tries to insert an entry of this type. */
+static int
+tcp6_checkentry(const char *tablename,
+	       const void *entry,
+	       void *matchinfo,
+	       unsigned int matchsize,
+	       unsigned int hook_mask)
+{
+	const struct ip6t_ip6 *ipv6 =3D entry;
+	const struct xt_tcp *tcpinfo =3D matchinfo;
+
+	/* Must specify proto =3D=3D TCP, and no unknown invflags */
+	return ipv6->proto =3D=3D IPPROTO_TCP
+		&& !(ipv6->invflags & XT_INV_PROTO)
+		&& matchsize =3D=3D XT_ALIGN(sizeof(struct xt_tcp))
+		&& !(tcpinfo->invflags & ~XT_TCP_INV_MASK);
+}
+
+
+static int
+udp_match(const struct sk_buff *skb,
+	  const struct net_device *in,
+	  const struct net_device *out,
+	  const void *matchinfo,
+	  int offset,
+	  unsigned int protoff,
+	  int *hotdrop)
+{
+	struct udphdr _udph, *uh;
+	const struct xt_udp *udpinfo =3D matchinfo;
+
+	/* Must not be a fragment. */
+	if (offset)
+		return 0;
+
+	uh =3D skb_header_pointer(skb, protoff, sizeof(_udph), &_udph);
+	if (uh =3D=3D NULL) {
+		/* We've been asked to examine this packet, and we
+		   can't.  Hence, no choice but to drop. */
+		duprintf("Dropping evil UDP tinygram.\n");
+		*hotdrop =3D 1;
+		return 0;
+	}
+
+	return port_match(udpinfo->spts[0], udpinfo->spts[1],
+			  ntohs(uh->source),
+			  !!(udpinfo->invflags & XT_UDP_INV_SRCPT))
+		&& port_match(udpinfo->dpts[0], udpinfo->dpts[1],
+			      ntohs(uh->dest),
+			      !!(udpinfo->invflags & XT_UDP_INV_DSTPT));
+}
+
+/* Called when user tries to insert an entry of this type. */
+static int
+udp_checkentry(const char *tablename,
+	       const void *info,
+	       void *matchinfo,
+	       unsigned int matchinfosize,
+	       unsigned int hook_mask)
+{
+	const struct ipt_ip *ip =3D info;
+	const struct xt_udp *udpinfo =3D matchinfo;
+
+	/* Must specify proto =3D=3D UDP, and no unknown invflags */
+	if (ip->proto !=3D IPPROTO_UDP || (ip->invflags & XT_INV_PROTO)) {
+		duprintf("ipt_udp: Protocol %u !=3D %u\n", ip->proto,
+			 IPPROTO_UDP);
+		return 0;
+	}
+	if (matchinfosize !=3D XT_ALIGN(sizeof(struct xt_udp))) {
+		duprintf("ipt_udp: matchsize %u !=3D %u\n",
+			 matchinfosize, XT_ALIGN(sizeof(struct xt_udp)));
+		return 0;
+	}
+	if (udpinfo->invflags & ~XT_UDP_INV_MASK) {
+		duprintf("ipt_udp: unknown flags %X\n",
+			 udpinfo->invflags);
+		return 0;
+	}
+
+	return 1;
+}
+
+/* Called when user tries to insert an entry of this type. */
+static int
+udp6_checkentry(const char *tablename,
+	       const void *entry,
+	       void *matchinfo,
+	       unsigned int matchinfosize,
+	       unsigned int hook_mask)
+{
+	const struct ip6t_ip6 *ipv6 =3D entry;
+	const struct xt_udp *udpinfo =3D matchinfo;
+
+	/* Must specify proto =3D=3D UDP, and no unknown invflags */
+	if (ipv6->proto !=3D IPPROTO_UDP || (ipv6->invflags & XT_INV_PROTO)) {
+		duprintf("ip6t_udp: Protocol %u !=3D %u\n", ipv6->proto,
+			 IPPROTO_UDP);
+		return 0;
+	}
+	if (matchinfosize !=3D XT_ALIGN(sizeof(struct xt_udp))) {
+		duprintf("ip6t_udp: matchsize %u !=3D %u\n",
+			 matchinfosize, XT_ALIGN(sizeof(struct xt_udp)));
+		return 0;
+	}
+	if (udpinfo->invflags & ~XT_UDP_INV_MASK) {
+		duprintf("ip6t_udp: unknown flags %X\n",
+			 udpinfo->invflags);
+		return 0;
+	}
+
+	return 1;
+}
+
+static struct xt_match tcp_matchstruct =3D {
+	.name		=3D "tcp",
+	.match		=3D &tcp_match,
+	.checkentry	=3D &tcp_checkentry,
+	.me		=3D THIS_MODULE,
+};
+static struct xt_match tcp6_matchstruct =3D {
+	.name		=3D "tcp",
+	.match		=3D &tcp_match,
+	.checkentry	=3D &tcp6_checkentry,
+	.me		=3D THIS_MODULE,
+};
+
+static struct xt_match udp_matchstruct =3D {
+	.name		=3D "udp",
+	.match		=3D &udp_match,
+	.checkentry	=3D &udp_checkentry,
+	.me		=3D THIS_MODULE,
+};
+static struct xt_match udp6_matchstruct =3D {
+	.name		=3D "udp",
+	.match		=3D &udp_match,
+	.checkentry	=3D &udp6_checkentry,
+	.me		=3D THIS_MODULE,
+};
+
+static int __init init(void)
+{
+	int ret;
+	ret =3D xt_register_match(AF_INET, &tcp_matchstruct);
+	if (ret)
+		return ret;
+
+	ret =3D xt_register_match(AF_INET6, &tcp6_matchstruct);
+	if (ret)
+		goto out_unreg_tcp;
+
+	ret =3D xt_register_match(AF_INET, &udp_matchstruct);
+	if (ret)
+		goto out_unreg_tcp6;
+=09
+	ret =3D xt_register_match(AF_INET6, &udp6_matchstruct);
+	if (ret)
+		goto out_unreg_udp;
+
+	return ret;
+
+out_unreg_udp:
+	xt_unregister_match(AF_INET, &tcp_matchstruct);
+out_unreg_tcp6:
+	xt_unregister_match(AF_INET6, &tcp6_matchstruct);
+out_unreg_tcp:
+	xt_unregister_match(AF_INET, &tcp_matchstruct);
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_match(AF_INET6, &udp6_matchstruct);
+	xt_unregister_match(AF_INET, &udp_matchstruct);
+	xt_unregister_match(AF_INET6, &tcp6_matchstruct);
+	xt_unregister_match(AF_INET, &tcp_matchstruct);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index b500193..39a22a3 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -62,7 +62,7 @@ ipt_init_target(struct ipt_entry_target=20
 	struct ipt_target *target;
 	int ret =3D 0;
=20
-	target =3D ipt_find_target(t->u.user.name, t->u.user.revision);
+	target =3D xt_find_target(AF_INET, t->u.user.name, t->u.user.revision);
 	if (!target)
 		return -ENOENT;
=20
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--67L3nkltNbzPAvlZ
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFDxsBmXaXGVTD0i/8RAoJkAJ9Ja8MqtIYaQTx4oRSQIA2ZTNbtIgCghcs2
WcA8rDkL2pUOSDANzqZygi0=
=fpAl
-----END PGP SIGNATURE-----

--67L3nkltNbzPAvlZ--
