From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH] ipv6 mcast: Fix incorrect use of pskb_may_pull().
Date: Tue, 25 Dec 2012 23:41:29 +0900
Message-ID: <50D9BB19.2080801@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:38827 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751669Ab2LYOla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Dec 2012 09:41:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pskb_may_pull(skb, len) ensures that data between
skb->data and skb->data + len - 1 can be accessed as a
linear buffer.  When pskb_may_pull() is being used multiple
times for the same buffer without skb_pull(), the length
is not accumulated internally, and caller must do.

For example, assuming that we have done:
  pskb_may_pull(skb, sizeof(struct icmp6hdr));
Afterwards, we have to do:
  pskb_may_pull(skb, sizeof(struct mldv2_query))
instead of:
  pskb_may_pull(skb, sizeof(struct mldv2_query) -
                sizeof(struct icmp6hdr))

This incorrect use may cause bad thing if someone sends a message
with extension headers so that the message is fragmented just
after the icmpv6 header.

Of course we can try pulling step by step but there is almost
no benefit to doing so;  MLD is our final protocol and we are
going to access almost the whole message as a linear buffer
anyway.

So, let's linearlize the buffer just after the trivial
sanity checks on IPv6 and ICMPv6 header in
igmp6_event_{query,report}().

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/mcast.c |   22 ++++++----------------
 1 file changed, 6 insertions(+), 16 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 28dfa5f..6b42b563 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1124,9 +1124,6 @@ int igmp6_event_query(struct sk_buff *skb)
 	int mark = 0;
 	int len;
 
-	if (!pskb_may_pull(skb, sizeof(struct in6_addr)))
-		return -EINVAL;
-
 	/* compute payload length excluding extension headers */
 	len = ntohs(ipv6_hdr(skb)->payload_len) + sizeof(struct ipv6hdr);
 	len -= skb_network_header_len(skb);
@@ -1136,10 +1133,12 @@ int igmp6_event_query(struct sk_buff *skb)
 		return -EINVAL;
 
 	idev = __in6_dev_get(skb->dev);
-
 	if (idev == NULL)
 		return 0;
 
+	if (!pskb_may_pull(skb, skb->len))
+		return -EINVAL;
+
 	mld = (struct mld_msg *)icmp6_hdr(skb);
 	group = &mld->mld_mca;
 	group_type = ipv6_addr_type(group);
@@ -1165,11 +1164,6 @@ int igmp6_event_query(struct sk_buff *skb)
 		/* clear deleted report items */
 		mld_clear_delrec(idev);
 	} else if (len >= 28) {
-		int srcs_offset = sizeof(struct mld2_query) -
-				  sizeof(struct icmp6hdr);
-		if (!pskb_may_pull(skb, srcs_offset))
-			return -EINVAL;
-
 		mlh2 = (struct mld2_query *)skb_transport_header(skb);
 		max_delay = (MLDV2_MRC(ntohs(mlh2->mld2q_mrc))*HZ)/1000;
 		if (!max_delay)
@@ -1186,10 +1180,6 @@ int igmp6_event_query(struct sk_buff *skb)
 		}
 		/* mark sources to include, if group & source-specific */
 		if (mlh2->mld2q_nsrcs != 0) {
-			if (!pskb_may_pull(skb, srcs_offset +
-			    ntohs(mlh2->mld2q_nsrcs) * sizeof(struct in6_addr)))
-				return -EINVAL;
-
 			mlh2 = (struct mld2_query *)skb_transport_header(skb);
 			mark = 1;
 		}
@@ -1248,9 +1238,6 @@ int igmp6_event_report(struct sk_buff *skb)
 	    skb->pkt_type != PACKET_BROADCAST)
 		return 0;
 
-	if (!pskb_may_pull(skb, sizeof(*mld) - sizeof(struct icmp6hdr)))
-		return -EINVAL;
-
 	mld = (struct mld_msg *)icmp6_hdr(skb);
 
 	/* Drop reports with not link local source */
@@ -1263,6 +1250,9 @@ int igmp6_event_report(struct sk_buff *skb)
 	if (idev == NULL)
 		return -ENODEV;
 
+	if (!pskb_may_pull(skb, sizeof(*mld)))
+		return -EINVAL;
+
 	/*
 	 *	Cancel the timer for this group
 	 */
-- 
1.7.9.5
