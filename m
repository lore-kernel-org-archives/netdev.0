From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 7/7] [NEIGH]: Move netlink neighbour table bits to linux/neighbour.h
Date: Mon, 07 Aug 2006 00:00:07 +0200
Message-ID: <20060807171051.472450752@postel.suug.ch>
References: <20060807170944.259251279@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:7886 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932229AbWHGRMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 13:12:41 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_neightbl_header
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rtnetlink_rcv_msg() is not longer required to parse attributes
for the neighbour tables layer, remove dependency on obsolete and
buggy rta_buf.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/include/linux/neighbour.h
===================================================================
--- net-2.6.19.git.orig/include/linux/neighbour.h
+++ net-2.6.19.git/include/linux/neighbour.h
@@ -62,4 +62,98 @@ struct nda_cacheinfo
 	__u32		ndm_refcnt;
 };
 
+/*****************************************************************
+ *		Neighbour tables specific messages.
+ *
+ * To retrieve the neighbour tables send RTM_GETNEIGHTBL with the
+ * NLM_F_DUMP flag set. Every neighbour table configuration is
+ * spread over multiple messages to avoid running into message
+ * size limits on systems with many interfaces. The first message
+ * in the sequence transports all not device specific data such as
+ * statistics, configuration, and the default parameter set.
+ * This message is followed by 0..n messages carrying device
+ * specific parameter sets.
+ * Although the ordering should be sufficient, NDTA_NAME can be
+ * used to identify sequences. The initial message can be identified
+ * by checking for NDTA_CONFIG. The device specific messages do
+ * not contain this TLV but have NDTPA_IFINDEX set to the
+ * corresponding interface index.
+ *
+ * To change neighbour table attributes, send RTM_SETNEIGHTBL
+ * with NDTA_NAME set. Changeable attribute include NDTA_THRESH[1-3],
+ * NDTA_GC_INTERVAL, and all TLVs in NDTA_PARMS unless marked
+ * otherwise. Device specific parameter sets can be changed by
+ * setting NDTPA_IFINDEX to the interface index of the corresponding
+ * device.
+ ****/
+
+struct ndt_stats
+{
+	__u64		ndts_allocs;
+	__u64		ndts_destroys;
+	__u64		ndts_hash_grows;
+	__u64		ndts_res_failed;
+	__u64		ndts_lookups;
+	__u64		ndts_hits;
+	__u64		ndts_rcv_probes_mcast;
+	__u64		ndts_rcv_probes_ucast;
+	__u64		ndts_periodic_gc_runs;
+	__u64		ndts_forced_gc_runs;
+};
+
+enum {
+	NDTPA_UNSPEC,
+	NDTPA_IFINDEX,			/* u32, unchangeable */
+	NDTPA_REFCNT,			/* u32, read-only */
+	NDTPA_REACHABLE_TIME,		/* u64, read-only, msecs */
+	NDTPA_BASE_REACHABLE_TIME,	/* u64, msecs */
+	NDTPA_RETRANS_TIME,		/* u64, msecs */
+	NDTPA_GC_STALETIME,		/* u64, msecs */
+	NDTPA_DELAY_PROBE_TIME,		/* u64, msecs */
+	NDTPA_QUEUE_LEN,		/* u32 */
+	NDTPA_APP_PROBES,		/* u32 */
+	NDTPA_UCAST_PROBES,		/* u32 */
+	NDTPA_MCAST_PROBES,		/* u32 */
+	NDTPA_ANYCAST_DELAY,		/* u64, msecs */
+	NDTPA_PROXY_DELAY,		/* u64, msecs */
+	NDTPA_PROXY_QLEN,		/* u32 */
+	NDTPA_LOCKTIME,			/* u64, msecs */
+	__NDTPA_MAX
+};
+#define NDTPA_MAX (__NDTPA_MAX - 1)
+
+struct ndtmsg
+{
+	__u8		ndtm_family;
+	__u8		ndtm_pad1;
+	__u16		ndtm_pad2;
+};
+
+struct ndt_config
+{
+	__u16		ndtc_key_len;
+	__u16		ndtc_entry_size;
+	__u32		ndtc_entries;
+	__u32		ndtc_last_flush;	/* delta to now in msecs */
+	__u32		ndtc_last_rand;		/* delta to now in msecs */
+	__u32		ndtc_hash_rnd;
+	__u32		ndtc_hash_mask;
+	__u32		ndtc_hash_chain_gc;
+	__u32		ndtc_proxy_qlen;
+};
+
+enum {
+	NDTA_UNSPEC,
+	NDTA_NAME,			/* char *, unchangeable */
+	NDTA_THRESH1,			/* u32 */
+	NDTA_THRESH2,			/* u32 */
+	NDTA_THRESH3,			/* u32 */
+	NDTA_CONFIG,			/* struct ndt_config, read-only */
+	NDTA_PARMS,			/* nested TLV NDTPA_* */
+	NDTA_STATS,			/* struct ndt_stats, read-only */
+	NDTA_GC_INTERVAL,		/* u64, msecs */
+	__NDTA_MAX
+};
+#define NDTA_MAX (__NDTA_MAX - 1)
+
 #endif
Index: net-2.6.19.git/include/linux/rtnetlink.h
===================================================================
--- net-2.6.19.git.orig/include/linux/rtnetlink.h
+++ net-2.6.19.git/include/linux/rtnetlink.h
@@ -384,107 +384,6 @@ struct rta_session
 	} u;
 };
 
-
-
-/*****************************************************************
- *		Neighbour tables specific messages.
- *
- * To retrieve the neighbour tables send RTM_GETNEIGHTBL with the
- * NLM_F_DUMP flag set. Every neighbour table configuration is
- * spread over multiple messages to avoid running into message
- * size limits on systems with many interfaces. The first message
- * in the sequence transports all not device specific data such as
- * statistics, configuration, and the default parameter set.
- * This message is followed by 0..n messages carrying device
- * specific parameter sets.
- * Although the ordering should be sufficient, NDTA_NAME can be
- * used to identify sequences. The initial message can be identified
- * by checking for NDTA_CONFIG. The device specific messages do
- * not contain this TLV but have NDTPA_IFINDEX set to the
- * corresponding interface index.
- *
- * To change neighbour table attributes, send RTM_SETNEIGHTBL
- * with NDTA_NAME set. Changeable attribute include NDTA_THRESH[1-3],
- * NDTA_GC_INTERVAL, and all TLVs in NDTA_PARMS unless marked
- * otherwise. Device specific parameter sets can be changed by
- * setting NDTPA_IFINDEX to the interface index of the corresponding
- * device.
- ****/
-
-struct ndt_stats
-{
-	__u64		ndts_allocs;
-	__u64		ndts_destroys;
-	__u64		ndts_hash_grows;
-	__u64		ndts_res_failed;
-	__u64		ndts_lookups;
-	__u64		ndts_hits;
-	__u64		ndts_rcv_probes_mcast;
-	__u64		ndts_rcv_probes_ucast;
-	__u64		ndts_periodic_gc_runs;
-	__u64		ndts_forced_gc_runs;
-};
-
-enum {
-	NDTPA_UNSPEC,
-	NDTPA_IFINDEX,			/* u32, unchangeable */
-	NDTPA_REFCNT,			/* u32, read-only */
-	NDTPA_REACHABLE_TIME,		/* u64, read-only, msecs */
-	NDTPA_BASE_REACHABLE_TIME,	/* u64, msecs */
-	NDTPA_RETRANS_TIME,		/* u64, msecs */
-	NDTPA_GC_STALETIME,		/* u64, msecs */
-	NDTPA_DELAY_PROBE_TIME,		/* u64, msecs */
-	NDTPA_QUEUE_LEN,		/* u32 */
-	NDTPA_APP_PROBES,		/* u32 */
-	NDTPA_UCAST_PROBES,		/* u32 */
-	NDTPA_MCAST_PROBES,		/* u32 */
-	NDTPA_ANYCAST_DELAY,		/* u64, msecs */
-	NDTPA_PROXY_DELAY,		/* u64, msecs */
-	NDTPA_PROXY_QLEN,		/* u32 */
-	NDTPA_LOCKTIME,			/* u64, msecs */
-	__NDTPA_MAX
-};
-#define NDTPA_MAX (__NDTPA_MAX - 1)
-
-struct ndtmsg
-{
-	__u8		ndtm_family;
-	__u8		ndtm_pad1;
-	__u16		ndtm_pad2;
-};
-
-struct ndt_config
-{
-	__u16		ndtc_key_len;
-	__u16		ndtc_entry_size;
-	__u32		ndtc_entries;
-	__u32		ndtc_last_flush;	/* delta to now in msecs */
-	__u32		ndtc_last_rand;		/* delta to now in msecs */
-	__u32		ndtc_hash_rnd;
-	__u32		ndtc_hash_mask;
-	__u32		ndtc_hash_chain_gc;
-	__u32		ndtc_proxy_qlen;
-};
-
-enum {
-	NDTA_UNSPEC,
-	NDTA_NAME,			/* char *, unchangeable */
-	NDTA_THRESH1,			/* u32 */
-	NDTA_THRESH2,			/* u32 */
-	NDTA_THRESH3,			/* u32 */
-	NDTA_CONFIG,			/* struct ndt_config, read-only */
-	NDTA_PARMS,			/* nested TLV NDTPA_* */
-	NDTA_STATS,			/* struct ndt_stats, read-only */
-	NDTA_GC_INTERVAL,		/* u64, msecs */
-	__NDTA_MAX
-};
-#define NDTA_MAX (__NDTA_MAX - 1)
-
-#define NDTA_RTA(r) ((struct rtattr*)(((char*)(r)) + \
-		     NLMSG_ALIGN(sizeof(struct ndtmsg))))
-#define NDTA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ndtmsg))
-
-
 /****
  *		General form of address family dependent message.
  ****/
Index: net-2.6.19.git/net/core/rtnetlink.c
===================================================================
--- net-2.6.19.git.orig/net/core/rtnetlink.c
+++ net-2.6.19.git/net/core/rtnetlink.c
@@ -112,7 +112,6 @@ static const int rtm_min[RTM_NR_FAMILIES
 	[RTM_FAM(RTM_NEWPREFIX)]    = NLMSG_LENGTH(sizeof(struct rtgenmsg)),
 	[RTM_FAM(RTM_GETMULTICAST)] = NLMSG_LENGTH(sizeof(struct rtgenmsg)),
 	[RTM_FAM(RTM_GETANYCAST)]   = NLMSG_LENGTH(sizeof(struct rtgenmsg)),
-	[RTM_FAM(RTM_NEWNEIGHTBL)]  = NLMSG_LENGTH(sizeof(struct ndtmsg)),
 };
 
 static const int rta_max[RTM_NR_FAMILIES] =
@@ -125,7 +124,6 @@ static const int rta_max[RTM_NR_FAMILIES
 	[RTM_FAM(RTM_NEWTCLASS)]    = TCA_MAX,
 	[RTM_FAM(RTM_NEWTFILTER)]   = TCA_MAX,
 	[RTM_FAM(RTM_NEWACTION)]    = TCAA_MAX,
-	[RTM_FAM(RTM_NEWNEIGHTBL)]  = NDTA_MAX,
 };
 
 void __rta_fill(struct sk_buff *skb, int attrtype, int attrlen, const void *data)

