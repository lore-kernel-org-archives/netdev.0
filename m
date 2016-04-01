From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net PATCH 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Fri, 01 Apr 2016 11:05:31 -0700
Message-ID: <20160401180531.13882.44793.stgit@localhost.localdomain>
References: <20160401175741.13882.24175.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: herbert@gondor.apana.org.au, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34302 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753820AbcDASFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 14:05:34 -0400
Received: by mail-pf0-f170.google.com with SMTP id x3so96312820pfb.1
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 11:05:33 -0700 (PDT)
In-Reply-To: <20160401175741.13882.24175.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 6864 states that the IPv4 ID field MUST NOT be used for purposes other
than fragmentation and reassembly.  Currently we are looking at this field
as a way of identifying what frames can be aggregated and  which cannot for
GRO.  While this is valid for frames that do not have DF set, it is invalid
to do so if the bit is set.

In addition we were generating IPv4 ID collisions when 2 or more flows were
interleaved over the same tunnel.  To prevent that we store the result of
all IP ID checks via a "|=" instead of overwriting previous values.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/core/dev.c         |    1 +
 net/ipv4/af_inet.c     |   23 ++++++++++++++++-------
 net/ipv6/ip6_offload.c |    3 ---
 3 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 77a71cd68535..3429632398a4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4352,6 +4352,7 @@ static void gro_list_prepare(struct napi_struct *napi, struct sk_buff *skb)
 		unsigned long diffs;
 
 		NAPI_GRO_CB(p)->flush = 0;
+		NAPI_GRO_CB(p)->flush_id = 0;
 
 		if (hash != skb_get_hash_raw(p)) {
 			NAPI_GRO_CB(p)->same_flow = 0;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 9e481992dbae..7d8733393934 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1347,14 +1347,23 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
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
+		/* For non-atomic datagrams we need to save the IP ID offset
+		 * to be included later.  If the frame has the DF bit set
+		 * we must ignore the IP ID value as per RFC 6864.
+		 */
+		if (iph2->frag_off & htons(IP_DF))
+			continue;
+
+		/* We must save the offset as it is possible to have multiple
+		 * flows using the same protocol and address pairs so we
+		 * need to wait until we can validate this is part of the
+		 * same flow with a 5-tuple or better to avoid unnecessary
+		 * collisions between flows.
+		 */
+		NAPI_GRO_CB(p)->flush_id |= ntohs(iph2->id) ^
+					    (u16)(id - NAPI_GRO_CB(p)->count);
 	}
 
 	NAPI_GRO_CB(skb)->flush |= flush;
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 82e9f3076028..9aa53f64dffd 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -238,9 +238,6 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 		/* flush if Traffic Class fields are different */
 		NAPI_GRO_CB(p)->flush |= !!(first_word & htonl(0x0FF00000));
 		NAPI_GRO_CB(p)->flush |= flush;
-
-		/* Clear flush_id, there's really no concept of ID in IPv6. */
-		NAPI_GRO_CB(p)->flush_id = 0;
 	}
 
 	NAPI_GRO_CB(skb)->flush |= flush;
