From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/3] net: ipv6: igmp6_event_query: use msecs_to_jiffies
Date: Tue, 20 Aug 2013 12:22:00 +0200
Message-ID: <1376994122-3022-2-git-send-email-dborkman@redhat.com>
References: <1376994122-3022-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36009 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878Ab3HTKWI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 06:22:08 -0400
In-Reply-To: <1376994122-3022-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use proper API functions to calculate jiffies from milliseconds and
not the crude method of dividing HZ by a value. This ensures more
accurate values even in the case of strange HZ values. While at it,
also simplify code in the mlh2 case by using max().

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/ipv6/mcast.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 6c76df9..57863e2 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1150,9 +1150,7 @@ int igmp6_event_query(struct sk_buff *skb)
 		int switchback;
 		/* MLDv1 router present */
 
-		/* Translate milliseconds to jiffies */
-		max_delay = (ntohs(mld->mld_maxdelay)*HZ)/1000;
-
+		max_delay = msecs_to_jiffies(ntohs(mld->mld_maxdelay));
 		switchback = (idev->mc_qrv + 1) * max_delay;
 		idev->mc_v1_seen = jiffies + switchback;
 
@@ -1169,10 +1167,11 @@ int igmp6_event_query(struct sk_buff *skb)
 			return -EINVAL;
 
 		mlh2 = (struct mld2_query *)skb_transport_header(skb);
-		max_delay = (MLDV2_MRC(ntohs(mlh2->mld2q_mrc))*HZ)/1000;
-		if (!max_delay)
-			max_delay = 1;
+
+		max_delay = max(msecs_to_jiffies(MLDV2_MRC(ntohs(mlh2->mld2q_mrc))), 1UL);
+
 		idev->mc_maxdelay = max_delay;
+
 		if (mlh2->mld2q_qrv)
 			idev->mc_qrv = mlh2->mld2q_qrv;
 		if (group_type == IPV6_ADDR_ANY) { /* general query */
-- 
1.7.11.7
