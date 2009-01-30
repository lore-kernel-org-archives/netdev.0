From: Olivier MATZ <olivier.matz@6wind.com>
Subject: [PATCH] sctp: chunkmap size is too large
Date: Fri, 30 Jan 2009 16:43:07 +0100
Message-ID: <4983200B.2080707@6wind.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020706030404030103070902"
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Patrick McHardy <kaber@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:1211 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754717AbZA3QFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 11:05:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020706030404030103070902
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi all,

I think that the chunkmap field in struct xt_sctp_info is
too large: we have 256 chunk types and it's a bitfield,
so the table should be 256 bits (8 uint32_t) instead
of 64 uint32_t.

I updated the size of the table, and I did some cosmetic
changes in SCTP_CHUNKMAP_* macros (use a mask instead of
a modulo).

  netfilter/xt_sctp.h       |   30 ++++++++++++++++--------------
  netfilter_ipv4/ipt_sctp.h |   30 ++++++++++++++++--------------
  2 files changed, 32 insertions(+), 28 deletions(-)

Can someone have a look at it ? Please CC me for any replies
as I'm not on the list.

Thanks,
Olivier

--------------020706030404030103070902
Content-Type: text/x-patch;
 name="linux_sctp_chunkmap_too_large.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux_sctp_chunkmap_too_large.diff"

diff -r ce4087e26684 include/linux/netfilter/xt_sctp.h
--- a/include/linux/netfilter/xt_sctp.h	Wed Jan 28 20:01:08 2009 +0000
+++ b/include/linux/netfilter/xt_sctp.h	Fri Jan 30 16:25:55 2009 +0100
@@ -15,11 +15,13 @@
 
 #define XT_NUM_SCTP_FLAGS	4
 
+#define sizeof_bits(type) (sizeof(type) * 8)
+
 struct xt_sctp_info {
 	u_int16_t dpts[2];  /* Min, Max */
 	u_int16_t spts[2];  /* Min, Max */
 
-	u_int32_t chunkmap[256 / sizeof (u_int32_t)];  /* Bit mask of chunks to be matched according to RFC 2960 */
+	u_int32_t chunkmap[256 / sizeof_bits(u_int32_t)];  /* Bit mask of chunks to be matched according to RFC 2960 */
 
 #define SCTP_CHUNK_MATCH_ANY   0x01  /* Match if any of the chunk types are present */
 #define SCTP_CHUNK_MATCH_ALL   0x02  /* Match if all of the chunk types are present */
@@ -33,24 +35,24 @@
 	u_int32_t invflags;
 };
 
-#define bytes(type) (sizeof(type) * 8)
+#define SCTP_MODULO(chunktype, type) (chunktype & (sizeof_bits(type)-1))
 
-#define SCTP_CHUNKMAP_SET(chunkmap, type) 		\
-	do { 						\
-		(chunkmap)[type / bytes(u_int32_t)] |= 	\
-			1 << (type % bytes(u_int32_t));	\
+#define SCTP_CHUNKMAP_SET(chunkmap, chunktype)				\
+	do {								\
+		chunkmap[chunktype / sizeof_bits(u_int32_t)] |=		\
+			1 << SCTP_MODULO(chunktype, u_int32_t);		\
 	} while (0)
 
-#define SCTP_CHUNKMAP_CLEAR(chunkmap, type)		 	\
-	do {							\
-		(chunkmap)[type / bytes(u_int32_t)] &= 		\
-			~(1 << (type % bytes(u_int32_t)));	\
+#define SCTP_CHUNKMAP_CLEAR(chunkmap, chunktype)		 	\
+	do {								\
+		chunkmap[chunktype / sizeof_bits(u_int32_t)] &=		\
+			~(1 << SCTP_MODULO(chunktype, u_int32_t));	\
 	} while (0)
 
-#define SCTP_CHUNKMAP_IS_SET(chunkmap, type) 			\
-({								\
-	((chunkmap)[type / bytes (u_int32_t)] & 		\
-		(1 << (type % bytes (u_int32_t)))) ? 1: 0;	\
+#define SCTP_CHUNKMAP_IS_SET(chunkmap, chunktype) 			\
+({									\
+	(chunkmap[chunktype / sizeof_bits(u_int32_t)] &			\
+	 (1 << SCTP_MODULO(chunktype, u_int32_t))) ? 1 : 0;		\
 })
 
 #define SCTP_CHUNKMAP_RESET(chunkmap) \
diff -r ce4087e26684 include/linux/netfilter_ipv4/ipt_sctp.h
--- a/include/linux/netfilter_ipv4/ipt_sctp.h	Wed Jan 28 20:01:08 2009 +0000
+++ b/include/linux/netfilter_ipv4/ipt_sctp.h	Fri Jan 30 16:25:55 2009 +0100
@@ -16,11 +16,13 @@
 
 #define IPT_NUM_SCTP_FLAGS	4
 
+#define sizeof_bits(type) (sizeof(type) * 8)
+
 struct ipt_sctp_info {
 	u_int16_t dpts[2];  /* Min, Max */
 	u_int16_t spts[2];  /* Min, Max */
 
-	u_int32_t chunkmap[256 / sizeof (u_int32_t)];  /* Bit mask of chunks to be matched according to RFC 2960 */
+	u_int32_t chunkmap[256 / sizeof_bits(u_int32_t)];  /* Bit mask of chunks to be matched according to RFC 2960 */
 
 #define SCTP_CHUNK_MATCH_ANY   0x01  /* Match if any of the chunk types are present */
 #define SCTP_CHUNK_MATCH_ALL   0x02  /* Match if all of the chunk types are present */
@@ -34,24 +36,24 @@
 	u_int32_t invflags;
 };
 
-#define bytes(type) (sizeof(type) * 8)
+#define SCTP_MODULO(chunktype, type) (chunktype & (sizeof_bits(type)-1))
 
-#define SCTP_CHUNKMAP_SET(chunkmap, type) 		\
-	do { 						\
-		chunkmap[type / bytes(u_int32_t)] |= 	\
-			1 << (type % bytes(u_int32_t));	\
+#define SCTP_CHUNKMAP_SET(chunkmap, chunktype)				\
+	do {								\
+		chunkmap[chunktype / sizeof_bits(u_int32_t)] |=		\
+			1 << SCTP_MODULO(chunktype, u_int32_t);		\
 	} while (0)
 
-#define SCTP_CHUNKMAP_CLEAR(chunkmap, type)		 	\
-	do {							\
-		chunkmap[type / bytes(u_int32_t)] &= 		\
-			~(1 << (type % bytes(u_int32_t)));	\
+#define SCTP_CHUNKMAP_CLEAR(chunkmap, chunktype)		 	\
+	do {								\
+		chunkmap[chunktype / sizeof_bits(u_int32_t)] &=		\
+			~(1 << SCTP_MODULO(chunktype, u_int32_t));	\
 	} while (0)
 
-#define SCTP_CHUNKMAP_IS_SET(chunkmap, type) 			\
-({								\
-	(chunkmap[type / bytes (u_int32_t)] & 			\
-		(1 << (type % bytes (u_int32_t)))) ? 1: 0;	\
+#define SCTP_CHUNKMAP_IS_SET(chunkmap, chunktype) 			\
+({									\
+	(chunkmap[chunktype / sizeof_bits(u_int32_t)] &			\
+	 (1 << SCTP_MODULO(chunktype, u_int32_t))) ? 1 : 0;		\
 })
 
 #define SCTP_CHUNKMAP_RESET(chunkmap) 				\

--------------020706030404030103070902--
