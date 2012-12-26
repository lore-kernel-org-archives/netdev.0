From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH V2] ipv6 mcast: Fix incorrect use of pskb_may_pull().
Date: Wed, 26 Dec 2012 12:12:13 +0900
Message-ID: <50DA6B0D.6010500@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, erdnetdev@gmail.com
To: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39588 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753244Ab2LZDMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Dec 2012 22:12:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pskb_may_pull(skb, len) ensures that len bytes from skb->data
are available in a linear array.  When pskb_may_pull() is
being used multiple times for the same buffer without
skb_pull(), the length is not accumulated.

For example, assuming that we have done:
  pskb_may_pull(skb, sizeof(struct icmp6hdr))

Here, we have to do:
  pskb_may_pull(skb, sizeof(struct mld2_query))
instead of:
  pskb_may_pull(skb, sizeof(struct mld2_query) -
                sizeof(struct icmp6hdr))

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/mcast.c |   13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 28dfa5f..5d91832 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1124,7 +1124,7 @@ int igmp6_event_query(struct sk_buff *skb)
 	int mark = 0;
 	int len;
 
-	if (!pskb_may_pull(skb, sizeof(struct in6_addr)))
+	if (!pskb_may_pull(skb, sizeof(struct icmp6hdr) + sizeof(struct in6_addr)))
 		return -EINVAL;
 
 	/* compute payload length excluding extension headers */
@@ -1165,9 +1165,7 @@ int igmp6_event_query(struct sk_buff *skb)
 		/* clear deleted report items */
 		mld_clear_delrec(idev);
 	} else if (len >= 28) {
-		int srcs_offset = sizeof(struct mld2_query) -
-				  sizeof(struct icmp6hdr);
-		if (!pskb_may_pull(skb, srcs_offset))
+		if (!pskb_may_pull(skb, sizeof(struct mld2_query)))
 			return -EINVAL;
 
 		mlh2 = (struct mld2_query *)skb_transport_header(skb);
@@ -1186,8 +1184,9 @@ int igmp6_event_query(struct sk_buff *skb)
 		}
 		/* mark sources to include, if group & source-specific */
 		if (mlh2->mld2q_nsrcs != 0) {
-			if (!pskb_may_pull(skb, srcs_offset +
-			    ntohs(mlh2->mld2q_nsrcs) * sizeof(struct in6_addr)))
+			if (!pskb_may_pull(skb,
+					   sizeof(struct mld2_query) +
+					   ntohs(mlh2->mld2q_nsrcs) * sizeof(struct in6_addr)))
 				return -EINVAL;
 
 			mlh2 = (struct mld2_query *)skb_transport_header(skb);
@@ -1248,7 +1247,7 @@ int igmp6_event_report(struct sk_buff *skb)
 	    skb->pkt_type != PACKET_BROADCAST)
 		return 0;
 
-	if (!pskb_may_pull(skb, sizeof(*mld) - sizeof(struct icmp6hdr)))
+	if (!pskb_may_pull(skb, sizeof(*mld)))
 		return -EINVAL;
 
 	mld = (struct mld_msg *)icmp6_hdr(skb);
-- 
1.7.9.5
