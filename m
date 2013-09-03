From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v2 2/8] net: ipv6: mld: clean up MLD_V1_SEEN macro
Date: Wed,  4 Sep 2013 00:19:38 +0200
Message-ID: <1378246784-21067-3-git-send-email-dborkman@redhat.com>
References: <1378246784-21067-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8190 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761173Ab3ICWTz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 18:19:55 -0400
In-Reply-To: <1378246784-21067-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the macro with a function to make it more readable. GCC will
eventually decide whether to inline this or not (also, that's not
fast-path anyway).

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/mcast.c | 34 +++++++++++++++++++++-------------
 1 file changed, 21 insertions(+), 13 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 8992ff2..f86e26b 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -95,6 +95,7 @@ static void mld_ifc_event(struct inet6_dev *idev);
 static void mld_add_delrec(struct inet6_dev *idev, struct ifmcaddr6 *pmc);
 static void mld_del_delrec(struct inet6_dev *idev, const struct in6_addr *addr);
 static void mld_clear_delrec(struct inet6_dev *idev);
+static bool mld_in_v1_mode(const struct inet6_dev *idev);
 static int sf_setstate(struct ifmcaddr6 *pmc);
 static void sf_markstate(struct ifmcaddr6 *pmc);
 static void ip6_mc_clear_src(struct ifmcaddr6 *pmc);
@@ -117,11 +118,6 @@ static int ip6_mc_leave_src(struct sock *sk, struct ipv6_mc_socklist *iml,
 #define MLD_V1_QUERY_LEN	24
 #define MLD_V2_QUERY_LEN_MIN	28
 
-#define MLD_V1_SEEN(idev) (dev_net((idev)->dev)->ipv6.devconf_all->force_mld_version == 1 || \
-		(idev)->cnf.force_mld_version == 1 || \
-		((idev)->mc_v1_seen && \
-		time_before(jiffies, (idev)->mc_v1_seen)))
-
 #define IPV6_MLD_MAX_MSF	64
 
 int sysctl_mld_max_msf __read_mostly = IPV6_MLD_MAX_MSF;
@@ -139,7 +135,7 @@ static int unsolicited_report_interval(struct inet6_dev *idev)
 {
 	int iv;
 
-	if (MLD_V1_SEEN(idev))
+	if (mld_in_v1_mode(idev))
 		iv = idev->cnf.mldv1_unsolicited_report_interval;
 	else
 		iv = idev->cnf.mldv2_unsolicited_report_interval;
@@ -695,7 +691,7 @@ static void igmp6_group_added(struct ifmcaddr6 *mc)
 	if (!(dev->flags & IFF_UP) || (mc->mca_flags & MAF_NOREPORT))
 		return;
 
-	if (MLD_V1_SEEN(mc->idev)) {
+	if (mld_in_v1_mode(mc->idev)) {
 		igmp6_join_group(mc);
 		return;
 	}
@@ -1116,6 +1112,18 @@ static bool mld_marksources(struct ifmcaddr6 *pmc, int nsrcs,
 	return true;
 }
 
+static bool mld_in_v1_mode(const struct inet6_dev *idev)
+{
+	if (dev_net(idev->dev)->ipv6.devconf_all->force_mld_version == 1)
+		return true;
+	if (idev->cnf.force_mld_version == 1)
+		return true;
+	if (idev->mc_v1_seen && time_before(jiffies, idev->mc_v1_seen))
+		return true;
+
+	return false;
+}
+
 static void mld_set_v1_mode(struct inet6_dev *idev)
 {
 	/* RFC3810, relevant sections:
@@ -1262,7 +1270,7 @@ int igmp6_event_query(struct sk_buff *skb)
 				  sizeof(struct icmp6hdr);
 
 		/* hosts need to stay in MLDv1 mode, discard MLDv2 queries */
-		if (MLD_V1_SEEN(idev))
+		if (mld_in_v1_mode(idev))
 			return 0;
 		if (!pskb_may_pull(skb, srcs_offset))
 			return -EINVAL;
@@ -1942,7 +1950,7 @@ err_out:
 
 static void mld_resend_report(struct inet6_dev *idev)
 {
-	if (MLD_V1_SEEN(idev)) {
+	if (mld_in_v1_mode(idev)) {
 		struct ifmcaddr6 *mcaddr;
 		read_lock_bh(&idev->lock);
 		for (mcaddr = idev->mc_list; mcaddr; mcaddr = mcaddr->next) {
@@ -2006,7 +2014,7 @@ static int ip6_mc_del1_src(struct ifmcaddr6 *pmc, int sfmode,
 		else
 			pmc->mca_sources = psf->sf_next;
 		if (psf->sf_oldin && !(pmc->mca_flags & MAF_NOREPORT) &&
-		    !MLD_V1_SEEN(idev)) {
+		    !mld_in_v1_mode(idev)) {
 			psf->sf_crcount = idev->mc_qrv;
 			psf->sf_next = pmc->mca_tomb;
 			pmc->mca_tomb = psf;
@@ -2306,7 +2314,7 @@ static int ip6_mc_leave_src(struct sock *sk, struct ipv6_mc_socklist *iml,
 
 static void igmp6_leave_group(struct ifmcaddr6 *ma)
 {
-	if (MLD_V1_SEEN(ma->idev)) {
+	if (mld_in_v1_mode(ma->idev)) {
 		if (ma->mca_flags & MAF_LAST_REPORTER)
 			igmp6_send(&ma->mca_addr, ma->idev->dev,
 				ICMPV6_MGM_REDUCTION);
@@ -2340,7 +2348,7 @@ static void mld_ifc_timer_expire(unsigned long data)
 
 static void mld_ifc_event(struct inet6_dev *idev)
 {
-	if (MLD_V1_SEEN(idev))
+	if (mld_in_v1_mode(idev))
 		return;
 	idev->mc_ifc_count = idev->mc_qrv;
 	mld_ifc_start_timer(idev, 1);
@@ -2351,7 +2359,7 @@ static void igmp6_timer_handler(unsigned long data)
 {
 	struct ifmcaddr6 *ma = (struct ifmcaddr6 *) data;
 
-	if (MLD_V1_SEEN(ma->idev))
+	if (mld_in_v1_mode(ma->idev))
 		igmp6_send(&ma->mca_addr, ma->idev->dev, ICMPV6_MGM_REPORT);
 	else
 		mld_send_report(ma->idev, ma);
-- 
1.7.11.7
