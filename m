From: kaber@trash.net
Subject: [PATCH 21/37] IPVS: Add expire_quiescent_template()
Date: Tue, 15 Mar 2011 20:44:01 +0100
Message-ID: <1300218257-26953-22-git-send-email-kaber@trash.net>
References: <1300218257-26953-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49425 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758488Ab1COToa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 15:44:30 -0400
In-Reply-To: <1300218257-26953-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>

In preparation for not including sysctl_expire_quiescent_template in
struct netns_ipvs when CONFIG_SYCTL is not defined.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 9c2a517..f289306 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -680,6 +680,16 @@ static inline void ip_vs_unbind_dest(struct ip_vs_conn *cp)
 	atomic_dec(&dest->refcnt);
 }
 
+static int expire_quiescent_template(struct netns_ipvs *ipvs,
+				     struct ip_vs_dest *dest)
+{
+#ifdef CONFIG_SYSCTL
+	return ipvs->sysctl_expire_quiescent_template &&
+		(atomic_read(&dest->weight) == 0);
+#else
+	return 0;
+#endif
+}
 
 /*
  *	Checking if the destination of a connection template is available.
@@ -696,8 +706,7 @@ int ip_vs_check_template(struct ip_vs_conn *ct)
 	 */
 	if ((dest == NULL) ||
 	    !(dest->flags & IP_VS_DEST_F_AVAILABLE) ||
-	    (ipvs->sysctl_expire_quiescent_template &&
-	     (atomic_read(&dest->weight) == 0))) {
+	    expire_quiescent_template(ipvs, dest)) {
 		IP_VS_DBG_BUF(9, "check_template: dest not available for "
 			      "protocol %s s:%s:%d v:%s:%d "
 			      "-> d:%s:%d\n",
-- 
1.7.2.3

