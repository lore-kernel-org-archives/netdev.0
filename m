From: kaber@trash.net
Subject: [PATCH 42/72] Fixed race condition at ip_vs.ko module init.
Date: Thu, 21 Oct 2010 17:19:29 +0200
Message-ID: <1287674399-31455-43-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eduardo Blanco <ejblanco@google.com>

Lists were initialized after the module was registered.  Multiple ipvsadm
processes at module load triggered a race condition that resulted in a null
pointer dereference in do_ip_vs_get_ctl(). As a result, __ip_vs_mutex
was left locked preventing all further ipvsadm commands.

Signed-off-by: Eduardo J. Blanco <ejblanco@google.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index a697591..0b884d3 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3400,6 +3400,16 @@ int __init ip_vs_control_init(void)
 
 	EnterFunction(2);
 
+	/* Initialize ip_vs_svc_table, ip_vs_svc_fwm_table, ip_vs_rtable */
+	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++)  {
+		INIT_LIST_HEAD(&ip_vs_svc_table[idx]);
+		INIT_LIST_HEAD(&ip_vs_svc_fwm_table[idx]);
+	}
+	for(idx = 0; idx < IP_VS_RTAB_SIZE; idx++)  {
+		INIT_LIST_HEAD(&ip_vs_rtable[idx]);
+	}
+	smp_wmb();
+
 	ret = nf_register_sockopt(&ip_vs_sockopts);
 	if (ret) {
 		pr_err("cannot register sockopt.\n");
@@ -3418,15 +3428,6 @@ int __init ip_vs_control_init(void)
 
 	sysctl_header = register_sysctl_paths(net_vs_ctl_path, vs_vars);
 
-	/* Initialize ip_vs_svc_table, ip_vs_svc_fwm_table, ip_vs_rtable */
-	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++)  {
-		INIT_LIST_HEAD(&ip_vs_svc_table[idx]);
-		INIT_LIST_HEAD(&ip_vs_svc_fwm_table[idx]);
-	}
-	for(idx = 0; idx < IP_VS_RTAB_SIZE; idx++)  {
-		INIT_LIST_HEAD(&ip_vs_rtable[idx]);
-	}
-
 	ip_vs_new_estimator(&ip_vs_stats);
 
 	/* Hook the defense timer */
-- 
1.7.1

