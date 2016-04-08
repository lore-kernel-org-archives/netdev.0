From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 3/5] GRO: Add support for TCP with fixed IPv4 ID
 field, limit tunnel IP ID values
Date: Fri, 08 Apr 2016 16:33:24 -0400
Message-ID: <20160408203324.12838.12165.stgit@ahduyck-xeon-server>
References: <20160408203013.12838.63429.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: herbert@gondor.apana.org.au, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34669 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752950AbcDHUd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 16:33:28 -0400
Received: by mail-pa0-f52.google.com with SMTP id fe3so80684727pab.1
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 13:33:28 -0700 (PDT)
In-Reply-To: <20160408203013.12838.63429.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch does two things.

First it allows TCP to aggregate TCP frames with a fixed IPv4 ID field.  As
a result we should now be able to aggregate flows that were converted from
IPv6 to IPv4.  In addition this allows us more flexibility for future
implementations of segmentation as we may be able to use a fixed IP ID when
segmenting the flow.

The second thing this does is that it places limitations on the outer IPv4
ID header in the case of tunneled frames.  Specifically it forces the IP ID
to be incrementing by 1 unless the DF bit is set in the outer IPv4 header.
This way we can avoid creating overlapping series of IP IDs that could
possibly be fragmented if the frame goes through GRO and is then
resegmented via GSO.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 include/linux/netdevice.h |    5 ++++-
 net/core/dev.c            |    1 +
 net/ipv4/af_inet.c        |   35 ++++++++++++++++++++++++++++-------
 net/ipv4/tcp_offload.c    |   16 +++++++++++++++-
 net/ipv6/ip6_offload.c    |    8 ++++++--
 5 files changed, 54 insertions(+), 11 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ffc12f565ed9..a3ac84ac8cb0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2123,7 +2123,10 @@ struct napi_gro_cb {
 	/* Used in GRE, set in fou/gue_gro_receive */
 	u8	is_fou:1;
 
-	/* 6 bit hole */
+	/* Used to determine if flush_id can be ignored */
+	u8	is_atomic:1;
+
+	/* 5 bit hole */
 
 	/* used to support CHECKSUM_COMPLETE for tunneling protocols */
 	__wsum	csum;
diff --git a/net/core/dev.c b/net/core/dev.c
index 16def40dfbe8..235e0f3e34f0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4440,6 +4440,7 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 		NAPI_GRO_CB(skb)->free = 0;
 		NAPI_GRO_CB(skb)->encap_mark = 0;
 		NAPI_GRO_CB(skb)->is_fou = 0;
+		NAPI_GRO_CB(skb)->is_atomic = 1;
 		NAPI_GRO_CB(skb)->gro_remcsum_start = 0;
 
 		/* Setup for GRO checksum validation */
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 5bbea9a0ce96..8564cab96189 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1328,6 +1328,7 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 
 	for (p = *head; p; p = p->next) {
 		struct iphdr *iph2;
+		u16 flush_id;
 
 		if (!NAPI_GRO_CB(p)->same_flow)
 			continue;
@@ -1351,16 +1352,36 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 			(iph->tos ^ iph2->tos) |
 			((iph->frag_off ^ iph2->frag_off) & htons(IP_DF));
 
-		/* Save the IP ID check to be included later when we get to
-		 * the transport layer so only the inner most IP ID is checked.
-		 * This is because some GSO/TSO implementations do not
-		 * correctly increment the IP ID for the outer hdrs.
-		 */
-		NAPI_GRO_CB(p)->flush_id =
-			    ((u16)(ntohs(iph2->id) + NAPI_GRO_CB(p)->count) ^ id);
 		NAPI_GRO_CB(p)->flush |= flush;
+
+		/* We need to store of the IP ID check to be included later
+		 * when we can verify that this packet does in fact belong
+		 * to a given flow.
+		 */
+		flush_id = (u16)(id - ntohs(iph2->id));
+
+		/* This bit of code makes it much easier for us to identify
+		 * the cases where we are doing atomic vs non-atomic IP ID
+		 * checks.  Specifically an atomic check can return IP ID
+		 * values 0 - 0xFFFF, while a non-atomic check can only
+		 * return 0 or 0xFFFF.
+		 */
+		if (!NAPI_GRO_CB(p)->is_atomic ||
+		    !(iph->frag_off & htons(IP_DF))) {
+			flush_id ^= NAPI_GRO_CB(p)->count;
+			flush_id = flush_id ? 0xFFFF : 0;
+		}
+
+		/* If the previous IP ID value was based on an atomic
+		 * datagram we can overwrite the value and ignore it.
+		 */
+		if (NAPI_GRO_CB(skb)->is_atomic)
+			NAPI_GRO_CB(p)->flush_id = flush_id;
+		else
+			NAPI_GRO_CB(p)->flush_id |= flush_id;
 	}
 
+	NAPI_GRO_CB(skb)->is_atomic = !!(iph->frag_off & htons(IP_DF));
 	NAPI_GRO_CB(skb)->flush |= flush;
 	skb_set_network_header(skb, off);
 	/* The above will be needed by the transport layer if there is one
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 08dd25d835af..d1ffd55289bd 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -239,7 +239,7 @@ struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 
 found:
 	/* Include the IP ID check below from the inner most IP hdr */
-	flush = NAPI_GRO_CB(p)->flush | NAPI_GRO_CB(p)->flush_id;
+	flush = NAPI_GRO_CB(p)->flush;
 	flush |= (__force int)(flags & TCP_FLAG_CWR);
 	flush |= (__force int)((flags ^ tcp_flag_word(th2)) &
 		  ~(TCP_FLAG_CWR | TCP_FLAG_FIN | TCP_FLAG_PSH));
@@ -248,6 +248,17 @@ found:
 		flush |= *(u32 *)((u8 *)th + i) ^
 			 *(u32 *)((u8 *)th2 + i);
 
+	/* When we receive our second frame we can made a decision on if we
+	 * continue this flow as an atomic flow with a fixed ID or if we use
+	 * an incrementing ID.
+	 */
+	if (NAPI_GRO_CB(p)->flush_id != 1 ||
+	    NAPI_GRO_CB(p)->count != 1 ||
+	    !NAPI_GRO_CB(p)->is_atomic)
+		flush |= NAPI_GRO_CB(p)->flush_id;
+	else
+		NAPI_GRO_CB(p)->is_atomic = false;
+
 	mss = skb_shinfo(p)->gso_size;
 
 	flush |= (len - 1) >= mss;
@@ -316,6 +327,9 @@ static int tcp4_gro_complete(struct sk_buff *skb, int thoff)
 				  iph->daddr, 0);
 	skb_shinfo(skb)->gso_type |= SKB_GSO_TCPV4;
 
+	if (NAPI_GRO_CB(skb)->is_atomic)
+		skb_shinfo(skb)->gso_type |= SKB_GSO_TCP_FIXEDID;
+
 	return tcp_gro_complete(skb);
 }
 
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index b3a779393d71..061adcda65f3 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -240,10 +240,14 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 		NAPI_GRO_CB(p)->flush |= !!(first_word & htonl(0x0FF00000));
 		NAPI_GRO_CB(p)->flush |= flush;
 
-		/* Clear flush_id, there's really no concept of ID in IPv6. */
-		NAPI_GRO_CB(p)->flush_id = 0;
+		/* If the previous IP ID value was based on an atomic
+		 * datagram we can overwrite the value and ignore it.
+		 */
+		if (NAPI_GRO_CB(skb)->is_atomic)
+			NAPI_GRO_CB(p)->flush_id = 0;
 	}
 
+	NAPI_GRO_CB(skb)->is_atomic = true;
 	NAPI_GRO_CB(skb)->flush |= flush;
 
 	skb_gro_postpull_rcsum(skb, iph, nlen);
