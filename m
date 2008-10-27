From: hamid.jafarian@gmail.com (hamid jafarian)
Subject: [PATCH 03/05]IPtablestng/UserSpace - patch libip4tc.c
Date: Mon, 27 Oct 2008 08:55:59 +0330 (IRST)
Message-ID: <20081027052559.7DB80C64094@host1.ystp.ac.ir>
Cc: Netdev <netdev@vger.kernel.org>
To: Netfilter-devel <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
cc: Pablo Neira Ayuso <pablo@netfilter.org>
cc: Patrick McHardy <kaber@trash.net>
cc: Jan Engelhardt <jengelh@medozas.de>
cc: David Miller <davem@davemloft.net>
cc: Rusty Russell <rusty@rustcorp.com.au>
cc: Harald Welte <laforge@gnumonks.org>
cc: Eric Leblond <eric@inl.fr>
cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
cc: Amin Azez <azez@ufomechanic.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

redefine macroes to use new features.

he also create to new macroes named 'TC_GET_CLASSIFIER & TC_CHG_CLASSIFIER' to manage classifiers.

diff --git a/libiptc/libip4tc.c b/libiptc/libip4tc.c
index 71af17f..6ca45b2 100644
--- a/libiptc/libip4tc.c
+++ b/libiptc/libip4tc.c
@@ -41,25 +41,30 @@ typedef unsigned int socklen_t;
 #endif
 
 #define STRUCT_ENTRY_TARGET	struct ipt_entry_target
-#define STRUCT_ENTRY		struct ipt_entry
+#define STRUCT_ENTRY		struct pktt_entry
 #define STRUCT_ENTRY_MATCH	struct ipt_entry_match
-#define STRUCT_GETINFO		struct ipt_getinfo
-#define STRUCT_GET_ENTRIES	struct ipt_get_entries
-#define STRUCT_COUNTERS		struct ipt_counters
-#define STRUCT_COUNTERS_INFO	struct ipt_counters_info
+//#define STRUCT_GETINFO		struct ipt_getinfo
+//#define STRUCT_GET_ENTRIES	struct ipt_get_entries
+#define STRUCT_COUNTERS		struct pktt_counters
+//#define STRUCT_COUNTERS_INFO	struct ipt_counters_info
 #define STRUCT_STANDARD_TARGET	struct ipt_standard_target
-#define STRUCT_REPLACE		struct ipt_replace
+//#define STRUCT_REPLACE		struct ipt_replace
+#define STRUCT_TABLE_INFO       struct pkt_table_info
+#define STRUCT_CHAIN_INFO       struct pktt_chain_info
+#define STRUCT_CHAIN_TARGET     struct pktt_chain_target
+#define STRUCT_COMMAND          struct pktt_command
 
 #define STRUCT_TC_HANDLE	struct iptc_handle
 #define TC_HANDLE_T		iptc_handle_t
 
-#define ENTRY_ITERATE		IPT_ENTRY_ITERATE
-#define TABLE_MAXNAMELEN	IPT_TABLE_MAXNAMELEN
-#define FUNCTION_MAXNAMELEN	IPT_FUNCTION_MAXNAMELEN
+#define ENTRY_ITERATE		PKTT_ENTRY_ITERATE
+#define TABLE_MAXNAMELEN	PKTT_TABLE_MAXNAMELEN
+#define CHAIN_MAXNAMELEN	PKTT_CHAIN_MAXNAMELEN
+#define FUNCTION_MAXNAMELEN	PKTT_FUNCTION_MAXNAMELEN
 
 #define GET_TARGET		ipt_get_target
 
-#define ERROR_TARGET		IPT_ERROR_TARGET
+//#define ERROR_TARGET		IPT_ERROR_TARGET
 #define NUMHOOKS		NF_IP_NUMHOOKS
 
 #define IPT_CHAINLABEL		ipt_chainlabel
@@ -94,8 +99,8 @@ typedef unsigned int socklen_t;
 #define TC_FREE			iptc_free
 #define TC_COMMIT		iptc_commit
 #define TC_STRERROR		iptc_strerror
-#define TC_NUM_RULES		iptc_num_rules
-#define TC_GET_RULE		iptc_get_rule
+#define TC_GET_CLASSIFIER       iptc_get_classifier
+#define TC_CHG_CLASSIFIER       iptc_chg_classifier
 
 #define TC_AF			AF_INET
 #define TC_IPPROTO		IPPROTO_IP
@@ -111,9 +116,11 @@ typedef unsigned int socklen_t;
 #define LABEL_ACCEPT		IPTC_LABEL_ACCEPT
 #define LABEL_DROP		IPTC_LABEL_DROP
 #define LABEL_QUEUE		IPTC_LABEL_QUEUE
+#define LABEL_CONTINUE          IPTC_LABEL_CONTINUE
 
 #define ALIGN			IPT_ALIGN
-#define RETURN			IPT_RETURN
+#define RETURN			PKTT_RETURN
+#define CONTINUE                PKTT_CONTINUE
 
 #include "libiptc.c"
 
@@ -124,15 +131,19 @@ typedef unsigned int socklen_t;
 (unsigned int)((n)&0xFF)
 
 #define IP_PARTS(n) IP_PARTS_NATIVE(ntohl(n))
-
+/*
+ * hm.t. pktt_entry modifier
+ */
+#define ip pkt_header.ip4
+#if 0
 int
 dump_entry(STRUCT_ENTRY *e, const TC_HANDLE_T handle)
 {
 	size_t i;
 	STRUCT_ENTRY_TARGET *t;
 
-	printf("Entry %u (%lu):\n", iptcb_entry2index(handle, e),
-	       iptcb_entry2offset(handle, e));
+	/*printf("Entry %u (%lu):\n", iptcb_entry2index(handle, e),
+	       iptcb_entry2offset(handle, e));*/
 	printf("SRC IP: %u.%u.%u.%u/%u.%u.%u.%u\n",
 	       IP_PARTS(e->ip.src.s_addr),IP_PARTS(e->ip.smsk.s_addr));
 	printf("DST IP: %u.%u.%u.%u/%u.%u.%u.%u\n",
@@ -148,7 +159,10 @@ dump_entry(STRUCT_ENTRY *e, const TC_HANDLE_T handle)
 	printf("Invflags: %02X\n", e->ip.invflags);
 	printf("Counters: %llu packets, %llu bytes\n",
 	       (unsigned long long)e->counters.pcnt, (unsigned long long)e->counters.bcnt);
-	printf("Cache: %08X\n", e->nfcache);
+	printf("Cache: %08X ", e->nfcache);
+	if (e->nfcache & NFC_ALTERED) printf("ALTERED ");
+	if (e->nfcache & NFC_UNKNOWN) printf("UNKNOWN ");
+	printf("\n");
 
 	IPT_MATCH_ITERATE(e, print_match);
 
@@ -162,6 +176,7 @@ dump_entry(STRUCT_ENTRY *e, const TC_HANDLE_T handle)
 			       : pos == -NF_DROP-1 ? "NF_DROP"
 			       : pos == -NF_QUEUE-1 ? "NF_QUEUE"
 			       : pos == RETURN ? "RETURN"
+			       : pos == CONTINUE ? "CONTINUE"
 			       : "UNKNOWN");
 		else
 			printf("verdict=%u\n", pos);
@@ -201,8 +216,9 @@ is_same(const STRUCT_ENTRY *a, const STRUCT_ENTRY *b, unsigned char *matchmask)
 			return NULL;
 	}
 
-	if (a->target_offset != b->target_offset
-	    || a->next_offset != b->next_offset)
+	if (a->nfcache != b->nfcache
+	    || a->target_offset != b->target_offset
+	    || a->size != b->size)
 		return NULL;
 
 	mptr = matchmask + sizeof(STRUCT_ENTRY);
@@ -213,7 +229,6 @@ is_same(const STRUCT_ENTRY *a, const STRUCT_ENTRY *b, unsigned char *matchmask)
 	return mptr;
 }
 
-#if 0
 /***************************** DEBUGGING ********************************/
 static inline int
 unconditional(const struct ipt_ip *ip)

