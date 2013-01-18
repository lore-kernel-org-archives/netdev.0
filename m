From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH RESEND 05/10] netfilter: ecache: move initial codes out of pernet_operations
Date: Fri, 18 Jan 2013 18:16:25 +0800
Message-ID: <1358504190-6094-5-git-send-email-gaofeng@cn.fujitsu.com>
References: <1358504190-6094-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net, ebiederm@xmission.com, canqunzhang@gmail.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58899 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751835Ab3ARKQS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2013 05:16:18 -0500
In-Reply-To: <1358504190-6094-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the global initial codes to the module_init/exit context.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netfilter/nf_conntrack_ecache.h | 19 +++++++++++----
 net/netfilter/nf_conntrack_core.c           | 15 ++++++++----
 net/netfilter/nf_conntrack_ecache.c         | 37 ++++++++++-------------------
 3 files changed, 39 insertions(+), 32 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_ecache.h b/include/net/netfilter/nf_conntrack_ecache.h
index 5654d29..092dc65 100644
--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -207,9 +207,11 @@ nf_ct_expect_event(enum ip_conntrack_expect_events event,
 	nf_ct_expect_event_report(event, exp, 0, 0);
 }
 
-extern int nf_conntrack_ecache_init(struct net *net);
-extern void nf_conntrack_ecache_fini(struct net *net);
+extern int nf_conntrack_ecache_pernet_init(struct net *net);
+extern void nf_conntrack_ecache_pernet_fini(struct net *net);
 
+extern int nf_conntrack_ecache_init(void);
+extern void nf_conntrack_ecache_fini(void);
 #else /* CONFIG_NF_CONNTRACK_EVENTS */
 
 static inline void nf_conntrack_event_cache(enum ip_conntrack_events event,
@@ -232,12 +234,21 @@ static inline void nf_ct_expect_event_report(enum ip_conntrack_expect_events e,
  					     u32 portid,
  					     int report) {}
 
-static inline int nf_conntrack_ecache_init(struct net *net)
+static inline int nf_conntrack_ecache_pernet_init(struct net *net)
 {
 	return 0;
 }
 
-static inline void nf_conntrack_ecache_fini(struct net *net)
+static inline void nf_conntrack_ecache_pernet_fini(struct net *net)
+{
+}
+
+static inline int nf_conntrack_ecache_init(void)
+{
+	return 0;
+}
+
+static inline void nf_conntrack_ecache_fini(void)
 {
 }
 #endif /* CONFIG_NF_CONNTRACK_EVENTS */
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index ad8100e0c..8a6c7b6 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1345,6 +1345,7 @@ void nf_conntrack_cleanup_end(void)
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	nf_ct_extend_unregister(&nf_ct_zone_extend);
 #endif
+	nf_conntrack_ecache_fini();
 	nf_conntrack_tstamp_fini();
 	nf_conntrack_acct_fini();
 	nf_conntrack_expect_fini();
@@ -1374,7 +1375,7 @@ void nf_conntrack_cleanup_net(struct net *net)
 	nf_conntrack_proto_fini(net);
 	nf_conntrack_helper_fini(net);
 	nf_conntrack_timeout_fini(net);
-	nf_conntrack_ecache_fini(net);
+	nf_conntrack_ecache_pernet_fini(net);
 	nf_conntrack_tstamp_pernet_fini(net);
 	nf_conntrack_acct_pernet_fini(net);
 	nf_conntrack_expect_pernet_fini(net);
@@ -1513,6 +1514,10 @@ int nf_conntrack_init_start(void)
 	if (ret < 0)
 		goto err_tstamp;
 
+	ret = nf_conntrack_ecache_init();
+	if (ret < 0)
+		goto err_ecache;
+
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	ret = nf_ct_extend_register(&nf_ct_zone_extend);
 	if (ret < 0)
@@ -1530,8 +1535,10 @@ int nf_conntrack_init_start(void)
 
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 err_extend:
-	nf_conntrack_tstamp_fini();
+	nf_conntrack_ecache_fini();
 #endif
+err_ecache:
+	nf_conntrack_tstamp_fini();
 err_tstamp:
 	nf_conntrack_acct_fini();
 err_acct:
@@ -1602,7 +1609,7 @@ int nf_conntrack_init_net(struct net *net)
 	ret = nf_conntrack_tstamp_pernet_init(net);
 	if (ret < 0)
 		goto err_tstamp;
-	ret = nf_conntrack_ecache_init(net);
+	ret = nf_conntrack_ecache_pernet_init(net);
 	if (ret < 0)
 		goto err_ecache;
 	ret = nf_conntrack_timeout_init(net);
@@ -1620,7 +1627,7 @@ err_proto:
 err_helper:
 	nf_conntrack_timeout_fini(net);
 err_timeout:
-	nf_conntrack_ecache_fini(net);
+	nf_conntrack_ecache_pernet_fini(net);
 err_ecache:
 	nf_conntrack_tstamp_pernet_fini(net);
 err_tstamp:
diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index faa978f..b5d2eb8 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -233,38 +233,27 @@ static void nf_conntrack_event_fini_sysctl(struct net *net)
 }
 #endif /* CONFIG_SYSCTL */
 
-int nf_conntrack_ecache_init(struct net *net)
+int nf_conntrack_ecache_pernet_init(struct net *net)
 {
-	int ret;
-
 	net->ct.sysctl_events = nf_ct_events;
 	net->ct.sysctl_events_retry_timeout = nf_ct_events_retry_timeout;
+	return nf_conntrack_event_init_sysctl(net);
+}
 
-	if (net_eq(net, &init_net)) {
-		ret = nf_ct_extend_register(&event_extend);
-		if (ret < 0) {
-			printk(KERN_ERR "nf_ct_event: Unable to register "
-					"event extension.\n");
-			goto out_extend_register;
-		}
-	}
+void nf_conntrack_ecache_pernet_fini(struct net *net)
+{
+	nf_conntrack_event_fini_sysctl(net);
+}
 
-	ret = nf_conntrack_event_init_sysctl(net);
+int nf_conntrack_ecache_init(void)
+{
+	int ret = nf_ct_extend_register(&event_extend);
 	if (ret < 0)
-		goto out_sysctl;
-
-	return 0;
-
-out_sysctl:
-	if (net_eq(net, &init_net))
-		nf_ct_extend_unregister(&event_extend);
-out_extend_register:
+		pr_err("nf_ct_event: Unable to register event extension.\n");
 	return ret;
 }
 
-void nf_conntrack_ecache_fini(struct net *net)
+void nf_conntrack_ecache_fini(void)
 {
-	nf_conntrack_event_fini_sysctl(net);
-	if (net_eq(net, &init_net))
-		nf_ct_extend_unregister(&event_extend);
+	nf_ct_extend_unregister(&event_extend);
 }
-- 
1.7.11.7
