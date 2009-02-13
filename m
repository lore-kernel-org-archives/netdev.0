From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next 2/4] sctp: Clean up sctp checksumming code
Date: Fri, 13 Feb 2009 13:33:42 -0500
Message-ID: <1234550024-30915-3-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:21635 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752724AbZBMSdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 13:33:49 -0500
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sctp crc32c checksum is always generated in little endian.
So, we clean up the code to treat it as little endian and remove
all the __force casts.

Suggested by Herbert Xu.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/linux/sctp.h        |    2 +-
 include/net/sctp/checksum.h |   14 +++++++-------
 net/sctp/input.c            |   11 ++++++-----
 net/sctp/output.c           |   14 ++++++--------
 4 files changed, 20 insertions(+), 21 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 8ba1c32..4c02baf 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -60,7 +60,7 @@ typedef struct sctphdr {
 	__be16 source;
 	__be16 dest;
 	__be32 vtag;
-	__be32 checksum;
+	__le32 checksum;
 } __attribute__((packed)) sctp_sctphdr_t;
 
 #ifdef __KERNEL__
diff --git a/include/net/sctp/checksum.h b/include/net/sctp/checksum.h
index 2fec3c3..befc8d2 100644
--- a/include/net/sctp/checksum.h
+++ b/include/net/sctp/checksum.h
@@ -46,14 +46,14 @@
 #include <net/sctp/sctp.h>
 #include <linux/crc32c.h>
 
-static inline __be32 sctp_crc32c(__be32 crc, u8 *buffer, u16 length)
+static inline __u32 sctp_crc32c(__u32 crc, u8 *buffer, u16 length)
 {
-	return (__force __be32)crc32c((__force u32)crc, buffer, length);
+	return crc32c(crc, buffer, length);
 }
 
-static inline __be32 sctp_start_cksum(__u8 *buffer, __u16 length)
+static inline __u32 sctp_start_cksum(__u8 *buffer, __u16 length)
 {
-	__be32 crc = ~cpu_to_be32(0);
+	__u32 crc = ~(__u32)0;
 	__u8  zero[sizeof(__u32)] = {0};
 
 	/* Optimize this routine to be SCTP specific, knowing how
@@ -72,12 +72,12 @@ static inline __be32 sctp_start_cksum(__u8 *buffer, __u16 length)
 	return crc;
 }
 
-static inline __be32 sctp_update_cksum(__u8 *buffer, __u16 length, __be32 crc32)
+static inline __u32 sctp_update_cksum(__u8 *buffer, __u16 length, __u32 crc32)
 {
 	return sctp_crc32c(crc32, buffer, length);
 }
 
-static inline __be32 sctp_end_cksum(__be32 crc32)
+static inline __le32 sctp_end_cksum(__be32 crc32)
 {
-	return (__force __be32)~cpu_to_le32((__force u32)crc32);
+	return cpu_to_le32(~crc32);
 }
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 693fd08..d2e9880 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -83,14 +83,15 @@ static inline int sctp_rcv_checksum(struct sk_buff *skb)
 {
 	struct sk_buff *list = skb_shinfo(skb)->frag_list;
 	struct sctphdr *sh = sctp_hdr(skb);
-	__be32 cmp = sh->checksum;
-	__be32 val = sctp_start_cksum((__u8 *)sh, skb_headlen(skb));
+	__le32 cmp = sh->checksum;
+	__le32 val;
+	__u32 tmp = sctp_start_cksum((__u8 *)sh, skb_headlen(skb));
 
 	for (; list; list = list->next)
-		val = sctp_update_cksum((__u8 *)list->data, skb_headlen(list),
-					val);
+		tmp = sctp_update_cksum((__u8 *)list->data, skb_headlen(list),
+					tmp);
 
-	val = sctp_end_cksum(val);
+	val = sctp_end_cksum(tmp);
 
 	if (val != cmp) {
 		/* CRC failure, dump it. */
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 2d65b7a..07d5890 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -367,7 +367,6 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	struct sctp_transport *tp = packet->transport;
 	struct sctp_association *asoc = tp->asoc;
 	struct sctphdr *sh;
-	__be32 crc32 = cpu_to_be32(0);
 	struct sk_buff *nskb;
 	struct sctp_chunk *chunk, *tmp;
 	struct sock *sk;
@@ -532,16 +531,15 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	 * by CRC32-C as described in <draft-ietf-tsvwg-sctpcsum-02.txt>.
 	 */
 	if (!sctp_checksum_disable && !(dst->dev->features & NETIF_F_NO_CSUM)) {
-		crc32 = sctp_start_cksum((__u8 *)sh, cksum_buf_len);
-		crc32 = sctp_end_cksum(crc32);
+		__u32 crc32 = sctp_start_cksum((__u8 *)sh, cksum_buf_len);
+
+		/* 3) Put the resultant value into the checksum field in the
+		 *    common header, and leave the rest of the bits unchanged.
+		 */
+		sh->checksum = sctp_end_cksum(crc32);
 	} else
 		nskb->ip_summed = CHECKSUM_UNNECESSARY;
 
-	/* 3) Put the resultant value into the checksum field in the
-	 *    common header, and leave the rest of the bits unchanged.
-	 */
-	sh->checksum = crc32;
-
 	/* IP layer ECN support
 	 * From RFC 2481
 	 *  "The ECN-Capable Transport (ECT) bit would be set by the
-- 
1.5.4.3

