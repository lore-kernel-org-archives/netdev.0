From: Thomas Graf <tgraf@suug.ch>
Subject: [NETLINK]: Introduce nested and byteorder flag to netlink attribute
Date: Wed, 12 Sep 2007 14:41:45 +0200
Message-ID: <20070912124145.GC18480@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:33614 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965995AbXILMlZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 08:41:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change allows the generic attribute interface to be used within
the netfilter subsystem where this flag was initially introduced.

The byte-order flag is yet unused, it's intended use is to
allow automatic byte order convertions for all atomic types.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.24/include/linux/netlink.h
===================================================================
--- net-2.6.24.orig/include/linux/netlink.h	2007-09-12 13:29:49.000000000 +0200
+++ net-2.6.24/include/linux/netlink.h	2007-09-12 13:59:41.000000000 +0200
@@ -129,6 +129,20 @@
 	__u16           nla_type;
 };
 
+/*
+ * nla_type (16 bits)
+ * +---+---+-------------------------------+
+ * | N | O | Attribute Type                |
+ * +---+---+-------------------------------+
+ * N := Carries nested attributes
+ * O := Payload stored in network byte order
+ *
+ * Note: The N and O flag are mutually exclusive.
+ */
+#define NLA_F_NESTED		(1 << 15)
+#define NLA_F_NET_BYTEORDER	(1 << 14)
+#define NLA_TYPE_MASK		~(NLA_F_NESTED | NLA_F_NET_BYTEORDER)
+
 #define NLA_ALIGNTO		4
 #define NLA_ALIGN(len)		(((len) + NLA_ALIGNTO - 1) & ~(NLA_ALIGNTO - 1))
 #define NLA_HDRLEN		((int) NLA_ALIGN(sizeof(struct nlattr)))
Index: net-2.6.24/include/net/netlink.h
===================================================================
--- net-2.6.24.orig/include/net/netlink.h	2007-09-12 13:29:50.000000000 +0200
+++ net-2.6.24/include/net/netlink.h	2007-09-12 14:17:56.000000000 +0200
@@ -667,6 +667,15 @@
 }
 
 /**
+ * nla_type - attribute type
+ * @nla: netlink attribute
+ */
+static inline int nla_type(const struct nlattr *nla)
+{
+	return nla->nla_type & NLA_TYPE_MASK;
+}
+
+/**
  * nla_data - head of payload
  * @nla: netlink attribute
  */
Index: net-2.6.24/net/ipv4/fib_frontend.c
===================================================================
--- net-2.6.24.orig/net/ipv4/fib_frontend.c	2007-09-12 13:29:51.000000000 +0200
+++ net-2.6.24/net/ipv4/fib_frontend.c	2007-09-12 13:59:41.000000000 +0200
@@ -487,7 +487,7 @@
 	}
 
 	nlmsg_for_each_attr(attr, nlh, sizeof(struct rtmsg), remaining) {
-		switch (attr->nla_type) {
+		switch (nla_type(attr)) {
 		case RTA_DST:
 			cfg->fc_dst = nla_get_be32(attr);
 			break;
Index: net-2.6.24/net/ipv4/fib_semantics.c
===================================================================
--- net-2.6.24.orig/net/ipv4/fib_semantics.c	2007-09-12 13:29:51.000000000 +0200
+++ net-2.6.24/net/ipv4/fib_semantics.c	2007-09-12 13:59:41.000000000 +0200
@@ -743,7 +743,7 @@
 		int remaining;
 
 		nla_for_each_attr(nla, cfg->fc_mx, cfg->fc_mx_len, remaining) {
-			int type = nla->nla_type;
+			int type = nla_type(nla);
 
 			if (type) {
 				if (type > RTAX_MAX)
Index: net-2.6.24/net/ipv6/route.c
===================================================================
--- net-2.6.24.orig/net/ipv6/route.c	2007-09-12 13:29:51.000000000 +0200
+++ net-2.6.24/net/ipv6/route.c	2007-09-12 13:59:41.000000000 +0200
@@ -1278,7 +1278,7 @@
 		int remaining;
 
 		nla_for_each_attr(nla, cfg->fc_mx, cfg->fc_mx_len, remaining) {
-			int type = nla->nla_type;
+			int type = nla_type(nla);
 
 			if (type) {
 				if (type > RTAX_MAX) {
Index: net-2.6.24/net/netlabel/netlabel_cipso_v4.c
===================================================================
--- net-2.6.24.orig/net/netlabel/netlabel_cipso_v4.c	2007-09-12 13:29:51.000000000 +0200
+++ net-2.6.24/net/netlabel/netlabel_cipso_v4.c	2007-09-12 13:59:41.000000000 +0200
@@ -130,7 +130,7 @@
 		return -EINVAL;
 
 	nla_for_each_nested(nla, info->attrs[NLBL_CIPSOV4_A_TAGLST], nla_rem)
-		if (nla->nla_type == NLBL_CIPSOV4_A_TAG) {
+		if (nla_type(nla) == NLBL_CIPSOV4_A_TAG) {
 			if (iter >= CIPSO_V4_TAG_MAXCNT)
 				return -EINVAL;
 			doi_def->tags[iter++] = nla_get_u8(nla);
@@ -192,13 +192,13 @@
 	nla_for_each_nested(nla_a,
 			    info->attrs[NLBL_CIPSOV4_A_MLSLVLLST],
 			    nla_a_rem)
-		if (nla_a->nla_type == NLBL_CIPSOV4_A_MLSLVL) {
+		if (nla_type(nla_a) == NLBL_CIPSOV4_A_MLSLVL) {
 			if (nla_validate_nested(nla_a,
 					    NLBL_CIPSOV4_A_MAX,
 					    netlbl_cipsov4_genl_policy) != 0)
 					goto add_std_failure;
 			nla_for_each_nested(nla_b, nla_a, nla_b_rem)
-				switch (nla_b->nla_type) {
+				switch (nla_type(nla_b)) {
 				case NLBL_CIPSOV4_A_MLSLVLLOC:
 					if (nla_get_u32(nla_b) >
 					    CIPSO_V4_MAX_LOC_LVLS)
@@ -240,7 +240,7 @@
 	nla_for_each_nested(nla_a,
 			    info->attrs[NLBL_CIPSOV4_A_MLSLVLLST],
 			    nla_a_rem)
-		if (nla_a->nla_type == NLBL_CIPSOV4_A_MLSLVL) {
+		if (nla_type(nla_a) == NLBL_CIPSOV4_A_MLSLVL) {
 			struct nlattr *lvl_loc;
 			struct nlattr *lvl_rem;
 
@@ -265,13 +265,13 @@
 		nla_for_each_nested(nla_a,
 				    info->attrs[NLBL_CIPSOV4_A_MLSCATLST],
 				    nla_a_rem)
-			if (nla_a->nla_type == NLBL_CIPSOV4_A_MLSCAT) {
+			if (nla_type(nla_a) == NLBL_CIPSOV4_A_MLSCAT) {
 				if (nla_validate_nested(nla_a,
 					      NLBL_CIPSOV4_A_MAX,
 					      netlbl_cipsov4_genl_policy) != 0)
 					goto add_std_failure;
 				nla_for_each_nested(nla_b, nla_a, nla_b_rem)
-					switch (nla_b->nla_type) {
+					switch (nla_type(nla_b)) {
 					case NLBL_CIPSOV4_A_MLSCATLOC:
 						if (nla_get_u32(nla_b) >
 						    CIPSO_V4_MAX_LOC_CATS)
@@ -315,7 +315,7 @@
 		nla_for_each_nested(nla_a,
 				    info->attrs[NLBL_CIPSOV4_A_MLSCATLST],
 				    nla_a_rem)
-			if (nla_a->nla_type == NLBL_CIPSOV4_A_MLSCAT) {
+			if (nla_type(nla_a) == NLBL_CIPSOV4_A_MLSCAT) {
 				struct nlattr *cat_loc;
 				struct nlattr *cat_rem;
 
Index: net-2.6.24/net/netlink/attr.c
===================================================================
--- net-2.6.24.orig/net/netlink/attr.c	2007-09-12 13:29:51.000000000 +0200
+++ net-2.6.24/net/netlink/attr.c	2007-09-12 14:10:51.000000000 +0200
@@ -27,12 +27,12 @@
 			const struct nla_policy *policy)
 {
 	const struct nla_policy *pt;
-	int minlen = 0, attrlen = nla_len(nla);
+	int minlen = 0, attrlen = nla_len(nla), type = nla_type(nla);
 
-	if (nla->nla_type <= 0 || nla->nla_type > maxtype)
+	if (type <= 0 || type > maxtype)
 		return 0;
 
-	pt = &policy[nla->nla_type];
+	pt = &policy[type];
 
 	BUG_ON(pt->type > NLA_TYPE_MAX);
 
@@ -149,7 +149,7 @@
 	memset(tb, 0, sizeof(struct nlattr *) * (maxtype + 1));
 
 	nla_for_each_attr(nla, head, len, rem) {
-		u16 type = nla->nla_type;
+		u16 type = nla_type(nla);
 
 		if (type > 0 && type <= maxtype) {
 			if (policy) {
@@ -185,7 +185,7 @@
 	int rem;
 
 	nla_for_each_attr(nla, head, len, rem)
-		if (nla->nla_type == attrtype)
+		if (nla_type(nla) == attrtype)
 			return nla;
 
 	return NULL;
