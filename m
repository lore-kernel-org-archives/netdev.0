From: kaber@trash.net
Subject: [PATCH 20/72] IPVS: ip_vs_{un,}bind_scheduler NULL arguments
Date: Thu, 21 Oct 2010 17:19:07 +0200
Message-ID: <1287674399-31455-21-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>

In general NULL arguments aren't passed by the few callers that exist,
so don't test for them.

The exception is to make passing NULL to ip_vs_unbind_scheduler() a noop.

Signed-off-by: Simon Horman <horms@verge.net.au>
Acked-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_ctl.c   |    3 +--
 net/netfilter/ipvs/ip_vs_sched.c |   23 +++--------------------
 2 files changed, 4 insertions(+), 22 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index f7afcfe..5f20caf 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1206,8 +1206,7 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 
  out_err:
 	if (svc != NULL) {
-		if (svc->scheduler)
-			ip_vs_unbind_scheduler(svc);
+		ip_vs_unbind_scheduler(svc);
 		if (svc->inc) {
 			local_bh_disable();
 			ip_vs_app_inc_put(svc->inc);
diff --git a/net/netfilter/ipvs/ip_vs_sched.c b/net/netfilter/ipvs/ip_vs_sched.c
index 9f94e32..076ebe0 100644
--- a/net/netfilter/ipvs/ip_vs_sched.c
+++ b/net/netfilter/ipvs/ip_vs_sched.c
@@ -46,15 +46,6 @@ int ip_vs_bind_scheduler(struct ip_vs_service *svc,
 {
 	int ret;
 
-	if (svc == NULL) {
-		pr_err("%s(): svc arg NULL\n", __func__);
-		return -EINVAL;
-	}
-	if (scheduler == NULL) {
-		pr_err("%s(): scheduler arg NULL\n", __func__);
-		return -EINVAL;
-	}
-
 	svc->scheduler = scheduler;
 
 	if (scheduler->init_service) {
@@ -74,18 +65,10 @@ int ip_vs_bind_scheduler(struct ip_vs_service *svc,
  */
 int ip_vs_unbind_scheduler(struct ip_vs_service *svc)
 {
-	struct ip_vs_scheduler *sched;
+	struct ip_vs_scheduler *sched = svc->scheduler;
 
-	if (svc == NULL) {
-		pr_err("%s(): svc arg NULL\n", __func__);
-		return -EINVAL;
-	}
-
-	sched = svc->scheduler;
-	if (sched == NULL) {
-		pr_err("%s(): svc isn't bound\n", __func__);
-		return -EINVAL;
-	}
+	if (!sched)
+		return 0;
 
 	if (sched->done_service) {
 		if (sched->done_service(svc) != 0) {
-- 
1.7.1

