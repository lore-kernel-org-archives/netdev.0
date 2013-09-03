From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v2 4/8] net: ipv6: mld: implement RFC3810 MLDv2 mode only
Date: Wed,  4 Sep 2013 00:19:40 +0200
Message-ID: <1378246784-21067-5-git-send-email-dborkman@redhat.com>
References: <1378246784-21067-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28130 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932892Ab3ICWUA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 18:20:00 -0400
In-Reply-To: <1378246784-21067-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC3810, 10. Security Considerations says under subsection 10.1.
Query Message:

  A forged Version 1 Query message will put MLDv2 listeners on that
  link in MLDv1 Host Compatibility Mode. This scenario can be avoided
  by providing MLDv2 hosts with a configuration option to ignore
  Version 1 messages completely.

Hence, implement a MLDv2-only mode that will ignore MLDv1 traffic:

  echo 2 > /proc/sys/net/ipv6/conf/ethX/force_mld_version  or
  echo 2 > /proc/sys/net/ipv6/conf/all/force_mld_version

Note that <all> device has a higher precedence as it was previously
also the case in the macro MLD_V1_SEEN() that would "short-circuit"
if condition on <all> case.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/mcast.c | 34 ++++++++++++++++++++++++++++++----
 1 file changed, 30 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 005b22f..24fdfbb 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1112,11 +1112,34 @@ static bool mld_marksources(struct ifmcaddr6 *pmc, int nsrcs,
 	return true;
 }
 
+static int mld_force_mld_version(const struct inet6_dev *idev)
+{
+	/* Normally, both are 0 here. If enforcement to a particular is
+	 * being used, individual device enforcement will have a lower
+	 * precedence over 'all' device (.../conf/all/force_mld_version).
+	 */
+
+	if (dev_net(idev->dev)->ipv6.devconf_all->force_mld_version != 0)
+		return dev_net(idev->dev)->ipv6.devconf_all->force_mld_version;
+	else
+		return idev->cnf.force_mld_version;
+}
+
+static bool mld_in_v2_mode_only(const struct inet6_dev *idev)
+{
+	return mld_force_mld_version(idev) == 2;
+}
+
+static bool mld_in_v1_mode_only(const struct inet6_dev *idev)
+{
+	return mld_force_mld_version(idev) == 1;
+}
+
 static bool mld_in_v1_mode(const struct inet6_dev *idev)
 {
-	if (dev_net(idev->dev)->ipv6.devconf_all->force_mld_version == 1)
-		return true;
-	if (idev->cnf.force_mld_version == 1)
+	if (mld_in_v2_mode_only(idev))
+		return false;
+	if (mld_in_v1_mode_only(idev))
 		return true;
 	if (idev->mc_v1_seen && time_before(jiffies, idev->mc_v1_seen))
 		return true;
@@ -1223,7 +1246,6 @@ int igmp6_event_query(struct sk_buff *skb)
 		return -EINVAL;
 
 	idev = __in6_dev_get(skb->dev);
-
 	if (idev == NULL)
 		return 0;
 
@@ -1236,6 +1258,10 @@ int igmp6_event_query(struct sk_buff *skb)
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
