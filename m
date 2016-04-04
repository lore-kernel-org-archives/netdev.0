From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net PATCH v2 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Mon, 04 Apr 2016 09:31:21 -0700
Message-ID: <20160404162818.14332.1076.stgit@localhost.localdomain>
References: <20160404162545.14332.653.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: herbert@gondor.apana.org.au, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36660 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260AbcDDQbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 12:31:23 -0400
Received: by mail-pf0-f178.google.com with SMTP id e128so125900034pfe.3
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 09:31:23 -0700 (PDT)
In-Reply-To: <20160404162545.14332.653.stgit@localhost.localdomain>
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

With this patch we support two different approaches for the IP ID field.
The first is a non-incrementing IP ID with DF bit set.  In such a case we
simply won't write to the flush_id field in the GRO context block.  The
other option is the legacy option in which the IP ID must increment by 1
for every packet we aggregate.

In the case of the non-incrementing IP ID we will end up losing the data
that the IP ID is fixed.  However as per RFC 6864 we should be able to
write any value into the IP ID when the DF bit is set so this should cause
minimal harm.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---

v2: Updated patch so that we now only support one of two options.  Either
    the IP ID is fixed with DF bit set, or the IP ID is incrementing.  That
    allows us to support the fixed ID case as occurs with IPv6 to IPv4
    header translation and what is likely already out there for some
    devices with tunnel headers.

 net/core/dev.c         |    1 +
 net/ipv4/af_inet.c     |   25 ++++++++++++++++++-------
 net/ipv6/ip6_offload.c |    3 ---
 3 files changed, 19 insertions(+), 10 deletions(-)

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
index 9e481992dbae..33f6335448a2 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1324,6 +1324,7 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 
 	for (p = *head; p; p = p->next) {
 		struct iphdr *iph2;
+		u16 flush_id;
 
 		if (!NAPI_GRO_CB(p)->same_flow)
 			continue;
@@ -1347,14 +1348,24 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
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
+		/* We must save the offset as it is possible to have multiple
+		 * flows using the same protocol and address pairs so we
+		 * need to wait until we can validate this is part of the
+		 * same flow with a 5-tuple or better to avoid unnecessary
+		 * collisions between flows.  We can support one of two
+		 * possible scenarios, either a fixed value with DF bit set
+		 * or an incrementing value with DF either set or unset.
+		 * In the case of a fixed value we will end up losing the
+		 * data that the IP ID was a fixed value, however per RFC
+		 * 6864 in such a case the actual value of the IP ID is
+		 * meant to be ignored anyway.
+		 */
+		flush_id = (u16)(id - ntohs(iph2->id));
+		if (flush_id || !(iph2->frag_off & htons(IP_DF)))
+			NAPI_GRO_CB(p)->flush_id |= flush_id ^
+						    NAPI_GRO_CB(p)->count;
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
