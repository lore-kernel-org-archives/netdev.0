From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 4/6][SCTP]: Don't do CRC32C checksum over loopback.
Date: Thu, 15 Jun 2006 15:46:26 -0700
Message-ID: <1150411586.6028.34.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:22437 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1750716AbWFOWrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2006 18:47:14 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5FMlDsB019911
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 15 Jun 2006 18:47:13 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5FMlDQ5262744
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 15 Jun 2006 18:47:13 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5FMlDAG010566
	for <netdev@vger.kernel.org>; Thu, 15 Jun 2006 18:47:13 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Don't do CRC32C checksum over loopback.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---

 net/sctp/input.c  |    3 ++-
 net/sctp/output.c |   48 +++++++++++++++++++++++++++---------------------
 2 files changed, 29 insertions(+), 22 deletions(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -141,7 +141,8 @@ int sctp_rcv(struct sk_buff *skb)
 	__skb_pull(skb, skb->h.raw - skb->data);
 	if (skb->len < sizeof(struct sctphdr))
 		goto discard_it;
-	if (sctp_rcv_checksum(skb) < 0)
+	if ((skb->ip_summed != CHECKSUM_UNNECESSARY) &&
+	    (sctp_rcv_checksum(skb) < 0))
 		goto discard_it;
 
 	skb_pull(skb, sizeof(struct sctphdr));
diff --git a/net/sctp/output.c b/net/sctp/output.c
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -295,14 +295,14 @@ int sctp_packet_transmit(struct sctp_pac
 	struct sctp_transport *tp = packet->transport;
 	struct sctp_association *asoc = tp->asoc;
 	struct sctphdr *sh;
-	__u32 crc32;
+	__u32 crc32 = 0;
 	struct sk_buff *nskb;
 	struct sctp_chunk *chunk, *tmp;
 	struct sock *sk;
 	int err = 0;
 	int padding;		/* How much padding do we need?  */
 	__u8 has_data = 0;
-	struct dst_entry *dst;
+	struct dst_entry *dst = tp->dst;
 
 	SCTP_DEBUG_PRINTK("%s: packet:%p\n", __FUNCTION__, packet);
 
@@ -327,6 +327,19 @@ int sctp_packet_transmit(struct sctp_pac
 	 */
 	skb_set_owner_w(nskb, sk);
 
+	/* The 'obsolete' field of dst is set to 2 when a dst is freed. */
+	if (!dst || (dst->obsolete > 1)) {
+		dst_release(dst);
+		sctp_transport_route(tp, NULL, sctp_sk(sk));
+		if (asoc && (asoc->param_flags & SPP_PMTUD_ENABLE)) {
+			sctp_assoc_sync_pmtu(asoc);
+		}
+	}
+	nskb->dst = dst_clone(tp->dst);
+	if (!nskb->dst)
+		goto no_route;
+	dst = nskb->dst;
+
 	/* Build the SCTP header.  */
 	sh = (struct sctphdr *)skb_push(nskb, sizeof(struct sctphdr));
 	sh->source = htons(packet->source_port);
@@ -350,7 +363,8 @@ int sctp_packet_transmit(struct sctp_pac
 	 * Note: Adler-32 is no longer applicable, as has been replaced
 	 * by CRC32-C as described in <draft-ietf-tsvwg-sctpcsum-02.txt>.
 	 */
-	crc32 = sctp_start_cksum((__u8 *)sh, sizeof(struct sctphdr));
+	if (!(dst->dev->features & NETIF_F_NO_CSUM))
+		crc32 = sctp_start_cksum((__u8 *)sh, sizeof(struct sctphdr));
 
 	/**
 	 * 6.10 Bundling
@@ -402,9 +416,14 @@ int sctp_packet_transmit(struct sctp_pac
 		if (padding)
 			memset(skb_put(chunk->skb, padding), 0, padding);
 
-		crc32 = sctp_update_copy_cksum(skb_put(nskb, chunk->skb->len),
-					       chunk->skb->data,
-					       chunk->skb->len, crc32);
+		if (dst->dev->features & NETIF_F_NO_CSUM)
+			memcpy(skb_put(nskb, chunk->skb->len),
+			       chunk->skb->data, chunk->skb->len);
+		else
+			crc32 = sctp_update_copy_cksum(skb_put(nskb,
+							chunk->skb->len),
+						chunk->skb->data,
+						chunk->skb->len, crc32);
 
 		SCTP_DEBUG_PRINTK("%s %p[%s] %s 0x%x, %s %d, %s %d, %s %d\n",
 				  "*** Chunk", chunk,
@@ -427,7 +446,8 @@ int sctp_packet_transmit(struct sctp_pac
 	}
 
 	/* Perform final transformation on checksum. */
-	crc32 = sctp_end_cksum(crc32);
+	if (!(dst->dev->features & NETIF_F_NO_CSUM))
+		crc32 = sctp_end_cksum(crc32);
 
 	/* 3) Put the resultant value into the checksum field in the
 	 *    common header, and leave the rest of the bits unchanged.
@@ -477,20 +497,6 @@ int sctp_packet_transmit(struct sctp_pac
 		}
 	}
 
-	dst = tp->dst;
-	/* The 'obsolete' field of dst is set to 2 when a dst is freed. */
-	if (!dst || (dst->obsolete > 1)) {
-		dst_release(dst);
-		sctp_transport_route(tp, NULL, sctp_sk(sk));
-		if (asoc->param_flags & SPP_PMTUD_ENABLE) {
-			sctp_assoc_sync_pmtu(asoc);
-		}
-	}
-
-	nskb->dst = dst_clone(tp->dst);
-	if (!nskb->dst)
-		goto no_route;
-
 	SCTP_DEBUG_PRINTK("***sctp_transmit_packet*** skb len %d\n",
 			  nskb->len);
 


