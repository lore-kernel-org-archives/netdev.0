From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: [PATCH 01/19] [NETFILTER]: xt_sctp: simplify xt_sctp.h
Date: Tue, 4 Mar 2008 17:30:02 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0803041722300.7660@fbirervta.pbzchgretzou.qr>
References: <Pine.LNX.4.64.0803040519150.7660@fbirervta.pbzchgretzou.qr>
 <47CD6296.90303@trash.net> <Pine.LNX.4.64.0803041630440.7660@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:40653 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764749AbYCDQaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 11:30:06 -0500
In-Reply-To: <Pine.LNX.4.64.0803041630440.7660@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Is this transformation ok this way? Eyeballs please :)

===
commit c95858194ffe1fbe19fa99287c78c10046bb188b
Author: Jan Engelhardt <jengelh@computergmbh.de>
Date:   Tue Jan 29 16:53:31 2008 +0100

    [NETFILTER]: xt_sctp: simplify xt_sctp.h
    
    The use of xt_sctp.h flagged up -Wshadow warnings in userspace, which
    prompted me to look at it and clean it up. Basic operations have been
    directly replaced by library calls (memcpy, memset is both available
    in the kernel and userspace, and usually faster than a self-made
    loop). The is_set and is_clear functions now use a processing time
    shortcut, too.
    
    Signed-off-by: Jan Engelhardt <jengelh@computergmbh.de>
---
 include/linux/netfilter/xt_sctp.h |   84 ++++++++++++-----------------
 1 files changed, 35 insertions(+), 49 deletions(-)

diff --git a/include/linux/netfilter/xt_sctp.h b/include/linux/netfilter/xt_sctp.h
index dd5a4fd..32000ba 100644
--- a/include/linux/netfilter/xt_sctp.h
+++ b/include/linux/netfilter/xt_sctp.h
@@ -37,68 +37,54 @@ struct xt_sctp_info {
 
 #define SCTP_CHUNKMAP_SET(chunkmap, type) 		\
 	do { 						\
-		chunkmap[type / bytes(u_int32_t)] |= 	\
+		(chunkmap)[type / bytes(u_int32_t)] |= 	\
 			1 << (type % bytes(u_int32_t));	\
 	} while (0)
 
 #define SCTP_CHUNKMAP_CLEAR(chunkmap, type)		 	\
 	do {							\
-		chunkmap[type / bytes(u_int32_t)] &= 		\
+		(chunkmap)[type / bytes(u_int32_t)] &= 		\
 			~(1 << (type % bytes(u_int32_t)));	\
 	} while (0)
 
 #define SCTP_CHUNKMAP_IS_SET(chunkmap, type) 			\
 ({								\
-	(chunkmap[type / bytes (u_int32_t)] & 			\
+	((chunkmap)[type / bytes (u_int32_t)] & 		\
 		(1 << (type % bytes (u_int32_t)))) ? 1: 0;	\
 })
 
-#define SCTP_CHUNKMAP_RESET(chunkmap) 				\
-	do {							\
-		int i; 						\
-		for (i = 0; i < ARRAY_SIZE(chunkmap); i++)	\
-			chunkmap[i] = 0;			\
-	} while (0)
-
-#define SCTP_CHUNKMAP_SET_ALL(chunkmap) 			\
-	do {							\
-		int i; 						\
-		for (i = 0; i < ARRAY_SIZE(chunkmap); i++) 	\
-			chunkmap[i] = ~0;			\
-	} while (0)
-
-#define SCTP_CHUNKMAP_COPY(destmap, srcmap) 			\
-	do {							\
-		int i; 						\
-		for (i = 0; i < ARRAY_SIZE(srcmap); i++) 	\
-			destmap[i] = srcmap[i];			\
-	} while (0)
-
-#define SCTP_CHUNKMAP_IS_CLEAR(chunkmap) 		\
-({							\
-	int i; 						\
-	int flag = 1;					\
-	for (i = 0; i < ARRAY_SIZE(chunkmap); i++) {	\
-		if (chunkmap[i]) {			\
-			flag = 0;			\
-			break;				\
-		}					\
-	}						\
-        flag;						\
-})
-
-#define SCTP_CHUNKMAP_IS_ALL_SET(chunkmap) 		\
-({							\
-	int i; 						\
-	int flag = 1;					\
-	for (i = 0; i < ARRAY_SIZE(chunkmap); i++) {	\
-		if (chunkmap[i] != ~0) {		\
-			flag = 0;			\
-				break;			\
-		}					\
-	}						\
-        flag;						\
-})
+#define SCTP_CHUNKMAP_RESET(chunkmap) \
+	memset((chunkmap), 0, sizeof(chunkmap))
+
+#define SCTP_CHUNKMAP_SET_ALL(chunkmap) \
+	memset((chunkmap), ~0U, sizeof(chunkmap))
+
+#define SCTP_CHUNKMAP_COPY(destmap, srcmap) \
+	memcpy((destmap), (srcmap), sizeof(srcmap))
+
+#define SCTP_CHUNKMAP_IS_CLEAR(chunkmap) \
+	__sctp_chunkmap_is_clear((chunkmap), ARRAY_SIZE(chunkmap))
+static inline bool
+__sctp_chunkmap_is_clear(const u_int32_t *chunkmap, unsigned int n)
+{
+	unsigned int i;
+	for (i = 0; i < n; ++i)
+		if (chunkmap[i])
+			return false;
+	return true;
+}
+
+#define SCTP_CHUNKMAP_IS_ALL_SET(chunkmap) \
+	__sctp_chunkmap_is_all_set((chunkmap), ARRAY_SIZE(chunkmap))
+static inline bool
+__sctp_chunkmap_is_all_set(const u_int32_t *chunkmap, unsigned int n)
+{
+	unsigned int i;
+	for (i = 0; i < n; ++i)
+		if (chunkmap[i] != ~0U)
+			return false;
+	return true;
+}
 
 #endif /* _XT_SCTP_H_ */
 
