From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 6/7] sctp: remove unnecessary byteshifting, calculate directly in big-endian
Date: Sat, 19 Jul 2008 00:26:51 -0400
Message-ID: <12164416191723-git-send-email-vladislav.yasevich@hp.com>
References: <12164416121552-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	Harvey Harrison <harvey.harrison@gmail.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:45822 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752531AbYGSE20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 00:28:26 -0400
In-Reply-To: <12164416121552-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/checksum.h            |   23 ++++++++++++++---------
 net/ipv4/netfilter/nf_nat_proto_sctp.c |    4 ++--
 net/sctp/input.c                       |    4 ++--
 net/sctp/output.c                      |    4 ++--
 4 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/include/net/sctp/checksum.h b/include/net/sctp/checksum.h
index ba75c67..b799fb2 100644
--- a/include/net/sctp/checksum.h
+++ b/include/net/sctp/checksum.h
@@ -46,9 +46,14 @@
 #include <net/sctp/sctp.h>
 #include <linux/crc32c.h>
 
-static inline __u32 sctp_start_cksum(__u8 *buffer, __u16 length)
+static inline __be32 sctp_crc32c(__be32 crc, u8 *buffer, u16 length)
 {
-	__u32 crc = ~(__u32) 0;
+	return (__force __be32)crc32c((__force u32)crc, buffer, length);
+}
+
+static inline __be32 sctp_start_cksum(__u8 *buffer, __u16 length)
+{
+	__be32 crc = ~cpu_to_be32(0);
 	__u8  zero[sizeof(__u32)] = {0};
 
 	/* Optimize this routine to be SCTP specific, knowing how
@@ -56,23 +61,23 @@ static inline __u32 sctp_start_cksum(__u8 *buffer, __u16 length)
 	 */
 
 	/* Calculate CRC up to the checksum. */
-	crc = crc32c(crc, buffer, sizeof(struct sctphdr) - sizeof(__u32));
+	crc = sctp_crc32c(crc, buffer, sizeof(struct sctphdr) - sizeof(__u32));
 
 	/* Skip checksum field of the header. */
-	crc = crc32c(crc, zero, sizeof(__u32));
+	crc = sctp_crc32c(crc, zero, sizeof(__u32));
 
 	/* Calculate the rest of the CRC. */
-	crc = crc32c(crc, &buffer[sizeof(struct sctphdr)],
+	crc = sctp_crc32c(crc, &buffer[sizeof(struct sctphdr)],
 			    length - sizeof(struct sctphdr));
 	return crc;
 }
 
-static inline __u32 sctp_update_cksum(__u8 *buffer, __u16 length, __u32 crc32)
+static inline __be32 sctp_update_cksum(__u8 *buffer, __u16 length, __be32 crc32)
 {
-	return crc32c(crc32, buffer, length);
+	return sctp_crc32c(crc32, buffer, length);
 }
 
-static inline __u32 sctp_end_cksum(__u32 crc32)
+static inline __be32 sctp_end_cksum(__be32 crc32)
 {
-	return ntohl(~crc32);
+	return ~crc32;
 }
diff --git a/net/ipv4/netfilter/nf_nat_proto_sctp.c b/net/ipv4/netfilter/nf_nat_proto_sctp.c
index 82e4c0e..65e470b 100644
--- a/net/ipv4/netfilter/nf_nat_proto_sctp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_sctp.c
@@ -36,7 +36,7 @@ sctp_manip_pkt(struct sk_buff *skb,
 	sctp_sctphdr_t *hdr;
 	unsigned int hdroff = iphdroff + iph->ihl*4;
 	__be32 oldip, newip;
-	u32 crc32;
+	__be32 crc32;
 
 	if (!skb_make_writable(skb, hdroff + sizeof(*hdr)))
 		return false;
@@ -61,7 +61,7 @@ sctp_manip_pkt(struct sk_buff *skb,
 		crc32 = sctp_update_cksum((u8 *)skb->data, skb_headlen(skb),
 					  crc32);
 	crc32 = sctp_end_cksum(crc32);
-	hdr->checksum = htonl(crc32);
+	hdr->checksum = crc32;
 
 	return true;
 }
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 5ed93c0..a49fa80 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -83,8 +83,8 @@ static inline int sctp_rcv_checksum(struct sk_buff *skb)
 {
 	struct sk_buff *list = skb_shinfo(skb)->frag_list;
 	struct sctphdr *sh = sctp_hdr(skb);
-	__u32 cmp = ntohl(sh->checksum);
-	__u32 val = sctp_start_cksum((__u8 *)sh, skb_headlen(skb));
+	__be32 cmp = sh->checksum;
+	__be32 val = sctp_start_cksum((__u8 *)sh, skb_headlen(skb));
 
 	for (; list; list = list->next)
 		val = sctp_update_cksum((__u8 *)list->data, skb_headlen(list),
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 9a63a3f..4568464 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -365,7 +365,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	struct sctp_transport *tp = packet->transport;
 	struct sctp_association *asoc = tp->asoc;
 	struct sctphdr *sh;
-	__u32 crc32 = 0;
+	__be32 crc32 = __constant_cpu_to_be32(0);
 	struct sk_buff *nskb;
 	struct sctp_chunk *chunk, *tmp;
 	struct sock *sk;
@@ -538,7 +538,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	/* 3) Put the resultant value into the checksum field in the
 	 *    common header, and leave the rest of the bits unchanged.
 	 */
-	sh->checksum = htonl(crc32);
+	sh->checksum = crc32;
 
 	/* IP layer ECN support
 	 * From RFC 2481
-- 
1.5.2.5

