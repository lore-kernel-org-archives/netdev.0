From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] ipv4/ipv6: multicast api unappropriate errno fix.
Date: Fri, 3 Aug 2012 15:06:45 +0800
Message-ID: <1343977605-14446-1-git-send-email-lw@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, dlstevens@us.ibm.com,
	Li Wei <lw@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:34844 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752929Ab2HCHHn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2012 03:07:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 917f2f105([IPV4]: multicast API "join" issues) corrected
some errno values but also caused unappropriate errno returned.

With an unjoined group address, return -EADDRNOTAVAIL would be
much better than -EINVAL.

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
 net/ipv4/igmp.c  |    8 +++-----
 net/ipv6/mcast.c |    8 +++-----
 2 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 6699f23..c45c092 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1933,10 +1933,8 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 		    (pmc->multi.imr_ifindex == imr.imr_ifindex))
 			break;
 	}
-	if (!pmc) {		/* must have a prior join */
-		err = -EINVAL;
-		goto done;
-	}
+	if (!pmc)		/* must have a prior join */
+		goto done;	/* err = -EADDRNOTAVAIL */
 	/* if a source filter was set, must be the same mode as before */
 	if (pmc->sflist) {
 		if (pmc->sfmode != omode) {
@@ -2076,7 +2074,7 @@ int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf, int ifindex)
 			break;
 	}
 	if (!pmc) {		/* must have a prior join */
-		err = -EINVAL;
+		err = -EADDRNOTAVAIL;
 		goto done;
 	}
 	if (msf->imsf_numsrc) {
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 92f8e48..89dcefd 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -347,10 +347,8 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 		if (ipv6_addr_equal(&pmc->addr, group))
 			break;
 	}
-	if (!pmc) {		/* must have a prior join */
-		err = -EINVAL;
-		goto done;
-	}
+	if (!pmc)		/* must have a prior join */
+		goto done;	/* err = -EADDRNOTAVAIL */
 	/* if a source filter was set, must be the same mode as before */
 	if (pmc->sflist) {
 		if (pmc->sfmode != omode) {
@@ -488,7 +486,7 @@ int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf)
 			break;
 	}
 	if (!pmc) {		/* must have a prior join */
-		err = -EINVAL;
+		err = -EADDRNOTAVAIL;
 		goto done;
 	}
 	if (gsf->gf_numsrc) {
-- 
1.7.10.1
