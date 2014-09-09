From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next 03/20] ipvs: Pass destination address family to ip_vs_trash_get_dest
Date: Tue, 9 Sep 2014 16:40:22 -0700
Message-ID: <1410306039-2977-4-git-send-email-agartrell@fb.com>
References: <1410306039-2977-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <horms@verge.net.au>, <ja@ssi.bg>, <lvs-devel@vger.kernel.org>,
	<kernel-team@fb.com>, <ps@fb.com>, Alex Gartrell <agartrell@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:59985 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753246AbaIIXlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 19:41:03 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id s89NcJ8T004964
	for <netdev@vger.kernel.org>; Tue, 9 Sep 2014 16:41:02 -0700
Received: from mail.thefacebook.com (mailwest.thefacebook.com [173.252.71.148])
	by mx0b-00082601.pphosted.com with ESMTP id 1pab9xg12t-13
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 16:41:02 -0700
Received: from facebook.com (2401:db00:20:7017:face:0:13:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 bc3b5b3c387a11e482360002c9521c9e-a11e83f0 for <netdev@vger.kernel.org>;	Tue,
 09 Sep 2014 16:40:52 -0700
In-Reply-To: <1410306039-2977-1-git-send-email-agartrell@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Part of a series of diffs to tease out destination family from virtual
family.  This diff just adds a parameter to ip_vs_trash_get and then uses
it for comparison rather than svc->af.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index a8589df..33d04ee 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -657,8 +657,8 @@ static void __ip_vs_dst_cache_reset(struct ip_vs_dest *dest)
  *  scheduling.
  */
 static struct ip_vs_dest *
-ip_vs_trash_get_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
-		     __be16 dport)
+ip_vs_trash_get_dest(struct ip_vs_service *svc, int dest_af,
+		     const union nf_inet_addr *daddr, __be16 dport)
 {
 	struct ip_vs_dest *dest;
 	struct netns_ipvs *ipvs = net_ipvs(svc->net);
@@ -671,11 +671,11 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
 		IP_VS_DBG_BUF(3, "Destination %u/%s:%u still in trash, "
 			      "dest->refcnt=%d\n",
 			      dest->vfwmark,
-			      IP_VS_DBG_ADDR(svc->af, &dest->addr),
+			      IP_VS_DBG_ADDR(dest->af, &dest->addr),
 			      ntohs(dest->port),
 			      atomic_read(&dest->refcnt));
-		if (dest->af == svc->af &&
-		    ip_vs_addr_equal(svc->af, &dest->addr, daddr) &&
+		if (dest->af == dest_af &&
+		    ip_vs_addr_equal(dest_af, &dest->addr, daddr) &&
 		    dest->port == dport &&
 		    dest->vfwmark == svc->fwmark &&
 		    dest->protocol == svc->protocol &&
@@ -950,7 +950,7 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	 * Check if the dest already exists in the trash and
 	 * is from the same service
 	 */
-	dest = ip_vs_trash_get_dest(svc, &daddr, dport);
+	dest = ip_vs_trash_get_dest(svc, udest->af, &daddr, dport);
 
 	if (dest != NULL) {
 		IP_VS_DBG_BUF(3, "Get destination %s:%u from trash, "
-- 
1.8.1
