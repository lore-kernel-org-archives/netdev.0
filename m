From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next 11/20] ipvs: address family of LBLCR entry depends on svc family
Date: Tue, 9 Sep 2014 16:40:30 -0700
Message-ID: <1410306039-2977-12-git-send-email-agartrell@fb.com>
References: <1410306039-2977-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <horms@verge.net.au>, <ja@ssi.bg>, <lvs-devel@vger.kernel.org>,
	<kernel-team@fb.com>, <ps@fb.com>, Alex Gartrell <agartrell@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:51633 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753177AbaIIXky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 19:40:54 -0400
Received: from pps.filterd (m0004348 [127.0.0.1])
	by m0004348.ppops.net (8.14.5/8.14.5) with SMTP id s89NYKZg014213
	for <netdev@vger.kernel.org>; Tue, 9 Sep 2014 16:40:54 -0700
Received: from mail.thefacebook.com (mailwest.thefacebook.com [173.252.71.148])
	by m0004348.ppops.net with ESMTP id 1p90t1c1tx-3
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 16:40:54 -0700
Received: from facebook.com (2401:db00:20:7017:face:0:13:0)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 bbf8d672387a11e487b70002c9dfb610-da6ea3f0 for <netdev@vger.kernel.org>;	Tue,
 09 Sep 2014 16:40:51 -0700
In-Reply-To: <1410306039-2977-1-git-send-email-agartrell@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

The LBLCR entries should use svc->af, not dest->af.
Needed to support svc->af != dest->af.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_lblcr.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 3f21a2f..2229d2d 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -362,18 +362,18 @@ ip_vs_lblcr_get(int af, struct ip_vs_lblcr_table *tbl,
  */
 static inline struct ip_vs_lblcr_entry *
 ip_vs_lblcr_new(struct ip_vs_lblcr_table *tbl, const union nf_inet_addr *daddr,
-		struct ip_vs_dest *dest)
+		u16 af, struct ip_vs_dest *dest)
 {
 	struct ip_vs_lblcr_entry *en;
 
-	en = ip_vs_lblcr_get(dest->af, tbl, daddr);
+	en = ip_vs_lblcr_get(af, tbl, daddr);
 	if (!en) {
 		en = kmalloc(sizeof(*en), GFP_ATOMIC);
 		if (!en)
 			return NULL;
 
-		en->af = dest->af;
-		ip_vs_addr_copy(dest->af, &en->addr, daddr);
+		en->af = af;
+		ip_vs_addr_copy(af, &en->addr, daddr);
 		en->lastuse = jiffies;
 
 		/* initialize its dest set */
@@ -706,13 +706,13 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	/* If we fail to create a cache entry, we'll just use the valid dest */
 	spin_lock_bh(&svc->sched_lock);
 	if (!tbl->dead)
-		ip_vs_lblcr_new(tbl, &iph->daddr, dest);
+		ip_vs_lblcr_new(tbl, &iph->daddr, svc->af, dest);
 	spin_unlock_bh(&svc->sched_lock);
 
 out:
 	IP_VS_DBG_BUF(6, "LBLCR: destination IP address %s --> server %s:%d\n",
 		      IP_VS_DBG_ADDR(svc->af, &iph->daddr),
-		      IP_VS_DBG_ADDR(svc->af, &dest->addr), ntohs(dest->port));
+		      IP_VS_DBG_ADDR(dest->af, &dest->addr), ntohs(dest->port));
 
 	return dest;
 }
-- 
1.8.1
