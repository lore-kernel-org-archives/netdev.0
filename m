From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 4/8] net: ipv6: mld: implement RFC3810 MLDv2 mode only
Date: Tue,  3 Sep 2013 09:59:34 +0200
Message-ID: <1378195178-21002-5-git-send-email-dborkman@redhat.com>
References: <1378195178-21002-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38935 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932497Ab3ICH7x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 03:59:53 -0400
In-Reply-To: <1378195178-21002-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC3810, 10. Security Considerations says under subsection 10.1.
Query Message:

  A forged Version 1 Query message will put MLDv2 listeners on that
  link in MLDv1 Host Compatibility Mode. This scenario can be avoided
  by providing MLDv2 hosts with a configuration option to ignore
  Version 1 messages completely.

Hence, implement a MLDv2-only mode that will ignore MLDv1 traffic:

  echo 2 > /proc/sys/net/ipv6/conf/ethX/force_mld_version

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/mcast.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 005b22f..02cd0c5 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1112,9 +1112,21 @@ static bool mld_marksources(struct ifmcaddr6 *pmc, int nsrcs,
 	return true;
 }
 
+static bool mld_in_v2_mode_only(const struct inet6_dev *idev)
+{
+	return dev_net(idev->dev)->ipv6.devconf_all->force_mld_version == 2;
+}
+
+static bool mld_in_v1_mode_only(const struct inet6_dev *idev)
+{
+	return dev_net(idev->dev)->ipv6.devconf_all->force_mld_version == 1;
+}
+
 static bool mld_in_v1_mode(const struct inet6_dev *idev)
 {
-	if (dev_net(idev->dev)->ipv6.devconf_all->force_mld_version == 1)
+	if (mld_in_v2_mode_only(idev))
+		return false;
+	if (mld_in_v1_mode_only(idev))
 		return true;
 	if (idev->cnf.force_mld_version == 1)
 		return true;
@@ -1223,7 +1235,6 @@ int igmp6_event_query(struct sk_buff *skb)
 		return -EINVAL;
 
 	idev = __in6_dev_get(skb->dev);
-
 	if (idev == NULL)
 		return 0;
 
@@ -1236,6 +1247,10 @@ int igmp6_event_query(struct sk_buff *skb)
 		return -EINVAL;
 
 	if (len == MLD_V1_QUERY_LEN) {
+		/* Ignore v1 queries */
+		if (mld_in_v2_mode_only(idev))
+			return 0;
+
 		/* MLDv1 router present */
 		max_delay = msecs_to_jiffies(ntohs(mld->mld_maxdelay));
 
-- 
1.7.11.7
