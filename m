From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 5/8] net: ipv6: mld: similarly to MLDv2 have min max_delay of 1
Date: Tue,  3 Sep 2013 09:59:35 +0200
Message-ID: <1378195178-21002-6-git-send-email-dborkman@redhat.com>
References: <1378195178-21002-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29601 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932502Ab3ICH7x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 03:59:53 -0400
In-Reply-To: <1378195178-21002-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly as we do in MLDv2 queries, set a forged MLDv1 query with
0 ms mld_maxdelay to minimum timer shot time of 1 jiffies. This is
eventually done in igmp6_group_queried() anyway, so we can simplify
a check there.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/mcast.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 02cd0c5..75a4324 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1040,12 +1040,9 @@ static void igmp6_group_queried(struct ifmcaddr6 *ma, unsigned long resptime)
 		delay = ma->mca_timer.expires - jiffies;
 	}
 
-	if (delay >= resptime) {
-		if (resptime)
-			delay = net_random() % resptime;
-		else
-			delay = 1;
-	}
+	if (delay >= resptime)
+		delay = net_random() % resptime;
+
 	ma->mca_timer.expires = jiffies + delay;
 	if (!mod_timer(&ma->mca_timer, jiffies + delay))
 		atomic_inc(&ma->mca_refcnt);
@@ -1247,12 +1244,15 @@ int igmp6_event_query(struct sk_buff *skb)
 		return -EINVAL;
 
 	if (len == MLD_V1_QUERY_LEN) {
+		unsigned long mldv1_md;
+
 		/* Ignore v1 queries */
 		if (mld_in_v2_mode_only(idev))
 			return 0;
 
 		/* MLDv1 router present */
-		max_delay = msecs_to_jiffies(ntohs(mld->mld_maxdelay));
+		mldv1_md = ntohs(mld->mld_maxdelay);
+		max_delay = max(msecs_to_jiffies(mldv1_md), 1UL);
 
 		mld_set_v1_mode(idev);
 
-- 
1.7.11.7
