From: kaber@trash.net
Subject: [PATCH 19/72] IPVS: Allow null argument to ip_vs_scheduler_put()
Date: Thu, 21 Oct 2010 17:19:06 +0200
Message-ID: <1287674399-31455-20-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59992 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752310Ab0JUPUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:06 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>

This simplifies caller logic sightly.

Signed-off-by: Simon Horman <horms@verge.net.au>
Acked-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_ctl.c   |   13 ++++---------
 net/netfilter/ipvs/ip_vs_sched.c |    2 +-
 2 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index e4ec8f3..f7afcfe 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1144,7 +1144,7 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 	if (sched == NULL) {
 		pr_info("Scheduler module ip_vs_%s not found\n", u->sched_name);
 		ret = -ENOENT;
-		goto out_mod_dec;
+		goto out_err;
 	}
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1204,7 +1204,7 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 	*svc_p = svc;
 	return 0;
 
-  out_err:
+ out_err:
 	if (svc != NULL) {
 		if (svc->scheduler)
 			ip_vs_unbind_scheduler(svc);
@@ -1217,7 +1217,6 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 	}
 	ip_vs_scheduler_put(sched);
 
-  out_mod_dec:
 	/* decrease the module use count */
 	ip_vs_use_count_dec();
 
@@ -1300,10 +1299,7 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 #ifdef CONFIG_IP_VS_IPV6
   out:
 #endif
-
-	if (old_sched)
-		ip_vs_scheduler_put(old_sched);
-
+	ip_vs_scheduler_put(old_sched);
 	return ret;
 }
 
@@ -1327,8 +1323,7 @@ static void __ip_vs_del_service(struct ip_vs_service *svc)
 	/* Unbind scheduler */
 	old_sched = svc->scheduler;
 	ip_vs_unbind_scheduler(svc);
-	if (old_sched)
-		ip_vs_scheduler_put(old_sched);
+	ip_vs_scheduler_put(old_sched);
 
 	/* Unbind app inc */
 	if (svc->inc) {
diff --git a/net/netfilter/ipvs/ip_vs_sched.c b/net/netfilter/ipvs/ip_vs_sched.c
index 727e45b..9f94e32 100644
--- a/net/netfilter/ipvs/ip_vs_sched.c
+++ b/net/netfilter/ipvs/ip_vs_sched.c
@@ -159,7 +159,7 @@ struct ip_vs_scheduler *ip_vs_scheduler_get(const char *sched_name)
 
 void ip_vs_scheduler_put(struct ip_vs_scheduler *scheduler)
 {
-	if (scheduler->module)
+	if (scheduler && scheduler->module)
 		module_put(scheduler->module);
 }
 
-- 
1.7.1

