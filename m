From: David Miller <davem@davemloft.net>
Subject: [PATCH 09/16] ipv6: Export ndisc option parsing from ndisc.c
Date: Thu, 12 Jul 2012 01:11:37 -0700 (PDT)
Message-ID: <20120712.011137.901142810809461522.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54753 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932104Ab2GLILi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 04:11:38 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 5172A5824C5
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 01:11:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is going to be used internally by the rt6 redirect code.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ndisc.h |   50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/ndisc.c    |   47 ++---------------------------------------------
 2 files changed, 52 insertions(+), 45 deletions(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index c02b6ad..96a3b5c 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -47,6 +47,8 @@ enum {
 #include <linux/icmpv6.h>
 #include <linux/in6.h>
 #include <linux/types.h>
+#include <linux/if_arp.h>
+#include <linux/netdevice.h>
 
 #include <net/neighbour.h>
 
@@ -80,6 +82,54 @@ struct nd_opt_hdr {
 	__u8		nd_opt_len;
 } __packed;
 
+/* ND options */
+struct ndisc_options {
+	struct nd_opt_hdr *nd_opt_array[__ND_OPT_ARRAY_MAX];
+#ifdef CONFIG_IPV6_ROUTE_INFO
+	struct nd_opt_hdr *nd_opts_ri;
+	struct nd_opt_hdr *nd_opts_ri_end;
+#endif
+	struct nd_opt_hdr *nd_useropts;
+	struct nd_opt_hdr *nd_useropts_end;
+};
+
+#define nd_opts_src_lladdr	nd_opt_array[ND_OPT_SOURCE_LL_ADDR]
+#define nd_opts_tgt_lladdr	nd_opt_array[ND_OPT_TARGET_LL_ADDR]
+#define nd_opts_pi		nd_opt_array[ND_OPT_PREFIX_INFO]
+#define nd_opts_pi_end		nd_opt_array[__ND_OPT_PREFIX_INFO_END]
+#define nd_opts_rh		nd_opt_array[ND_OPT_REDIRECT_HDR]
+#define nd_opts_mtu		nd_opt_array[ND_OPT_MTU]
+
+#define NDISC_OPT_SPACE(len) (((len)+2+7)&~7)
+
+extern struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
+						 struct ndisc_options *ndopts);
+
+/*
+ * Return the padding between the option length and the start of the
+ * link addr.  Currently only IP-over-InfiniBand needs this, although
+ * if RFC 3831 IPv6-over-Fibre Channel is ever implemented it may
+ * also need a pad of 2.
+ */
+static int ndisc_addr_option_pad(unsigned short type)
+{
+	switch (type) {
+	case ARPHRD_INFINIBAND: return 2;
+	default:                return 0;
+	}
+}
+
+static inline u8 *ndisc_opt_addr_data(struct nd_opt_hdr *p,
+				      struct net_device *dev)
+{
+	u8 *lladdr = (u8 *)(p + 1);
+	int lladdrlen = p->nd_opt_len << 3;
+	int prepad = ndisc_addr_option_pad(dev->type);
+	if (lladdrlen != NDISC_OPT_SPACE(dev->addr_len + prepad))
+		return NULL;
+	return lladdr + prepad;
+}
+
 static inline u32 ndisc_hashfn(const void *pkey, const struct net_device *dev, __u32 *hash_rnd)
 {
 	const u32 *p32 = pkey;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 0fddd57..a3189ba 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -143,40 +143,8 @@ struct neigh_table nd_tbl = {
 	.gc_thresh3 =	1024,
 };
 
-/* ND options */
-struct ndisc_options {
-	struct nd_opt_hdr *nd_opt_array[__ND_OPT_ARRAY_MAX];
-#ifdef CONFIG_IPV6_ROUTE_INFO
-	struct nd_opt_hdr *nd_opts_ri;
-	struct nd_opt_hdr *nd_opts_ri_end;
-#endif
-	struct nd_opt_hdr *nd_useropts;
-	struct nd_opt_hdr *nd_useropts_end;
-};
-
-#define nd_opts_src_lladdr	nd_opt_array[ND_OPT_SOURCE_LL_ADDR]
-#define nd_opts_tgt_lladdr	nd_opt_array[ND_OPT_TARGET_LL_ADDR]
-#define nd_opts_pi		nd_opt_array[ND_OPT_PREFIX_INFO]
-#define nd_opts_pi_end		nd_opt_array[__ND_OPT_PREFIX_INFO_END]
-#define nd_opts_rh		nd_opt_array[ND_OPT_REDIRECT_HDR]
-#define nd_opts_mtu		nd_opt_array[ND_OPT_MTU]
-
 #define NDISC_OPT_SPACE(len) (((len)+2+7)&~7)
 
-/*
- * Return the padding between the option length and the start of the
- * link addr.  Currently only IP-over-InfiniBand needs this, although
- * if RFC 3831 IPv6-over-Fibre Channel is ever implemented it may
- * also need a pad of 2.
- */
-static int ndisc_addr_option_pad(unsigned short type)
-{
-	switch (type) {
-	case ARPHRD_INFINIBAND: return 2;
-	default:                return 0;
-	}
-}
-
 static inline int ndisc_opt_addr_space(struct net_device *dev)
 {
 	return NDISC_OPT_SPACE(dev->addr_len + ndisc_addr_option_pad(dev->type));
@@ -233,8 +201,8 @@ static struct nd_opt_hdr *ndisc_next_useropt(struct nd_opt_hdr *cur,
 	return cur <= end && ndisc_is_useropt(cur) ? cur : NULL;
 }
 
-static struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
-						 struct ndisc_options *ndopts)
+struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
+					  struct ndisc_options *ndopts)
 {
 	struct nd_opt_hdr *nd_opt = (struct nd_opt_hdr *)opt;
 
@@ -297,17 +265,6 @@ static struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
 	return ndopts;
 }
 
-static inline u8 *ndisc_opt_addr_data(struct nd_opt_hdr *p,
-				      struct net_device *dev)
-{
-	u8 *lladdr = (u8 *)(p + 1);
-	int lladdrlen = p->nd_opt_len << 3;
-	int prepad = ndisc_addr_option_pad(dev->type);
-	if (lladdrlen != NDISC_OPT_SPACE(dev->addr_len + prepad))
-		return NULL;
-	return lladdr + prepad;
-}
-
 int ndisc_mc_map(const struct in6_addr *addr, char *buf, struct net_device *dev, int dir)
 {
 	switch (dev->type) {
-- 
1.7.10.4
