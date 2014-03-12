From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net-next] flowcache: Fix resource leaks on namespace exit.
Date: Wed, 12 Mar 2014 09:43:17 +0100
Message-ID: <20140312084317.GF32371@secunet.com>
References: <1394424146.3607.2.camel@edumazet-glaptop2.roam.corp.google.com>
 <1394424557.3607.4.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140310131909.33a3042c@north>
 <1394460276.3607.10.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140311014649.1716bde1@north>
 <20140311120059.GB32371@secunet.com>
 <1394541626.21721.24.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140311132030.GD32371@secunet.com>
 <20140311153029.1de9d6e9@north>
 <20140312083827.GE32371@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	Fan Du <fan.du@windriver.com>
To: Jakub =?utf-8?B?S2ljacWEc2tp?= <moorray3@wp.pl>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:58127 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752105AbaCLInV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 04:43:21 -0400
Content-Disposition: inline
In-Reply-To: <20140312083827.GE32371@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We leak an active timer, the hotcpu notifier and all allocated
resources when we exit a namespace. Fix this by introducing a
flow_cache_fini() function where we release the resources before
we exit.

Fixes: ca925cf1534e ("flowcache: Make flow cache name space aware")
Reported-by: Jakub Kicinski <moorray3@wp.pl>
Tested-by: Jakub Kicinski <moorray3@wp.pl>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Fan Du <fan.du@windriver.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/flow.h     |    1 +
 net/core/flow.c        |   19 +++++++++++++++++++
 net/xfrm/xfrm_policy.c |    7 ++++++-
 3 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index bee3741..64fd248 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -219,6 +219,7 @@ struct flow_cache_object *flow_cache_lookup(struct net *net,
 					    u8 dir, flow_resolve_t resolver,
 					    void *ctx);
 int flow_cache_init(struct net *net);
+void flow_cache_fini(struct net *net);
 
 void flow_cache_flush(struct net *net);
 void flow_cache_flush_deferred(struct net *net);
diff --git a/net/core/flow.c b/net/core/flow.c
index 102f8ea..31cfb36 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -484,3 +484,22 @@ err:
 	return -ENOMEM;
 }
 EXPORT_SYMBOL(flow_cache_init);
+
+void flow_cache_fini(struct net *net)
+{
+	int i;
+	struct flow_cache *fc = &net->xfrm.flow_cache_global;
+
+	del_timer_sync(&fc->rnd_timer);
+	unregister_hotcpu_notifier(&fc->hotcpu_notifier);
+
+	for_each_possible_cpu(i) {
+		struct flow_cache_percpu *fcp = per_cpu_ptr(fc->percpu, i);
+		kfree(fcp->hash_table);
+		fcp->hash_table = NULL;
+	}
+
+	free_percpu(fc->percpu);
+	fc->percpu = NULL;
+}
+EXPORT_SYMBOL(flow_cache_fini);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index a75fae4..f02f511 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2913,15 +2913,19 @@ static int __net_init xfrm_net_init(struct net *net)
 	rv = xfrm_sysctl_init(net);
 	if (rv < 0)
 		goto out_sysctl;
+	rv = flow_cache_init(net);
+	if (rv < 0)
+		goto out;
 
 	/* Initialize the per-net locks here */
 	spin_lock_init(&net->xfrm.xfrm_state_lock);
 	rwlock_init(&net->xfrm.xfrm_policy_lock);
 	mutex_init(&net->xfrm.xfrm_cfg_mutex);
 
-	flow_cache_init(net);
 	return 0;
 
+out:
+	xfrm_sysctl_fini(net);
 out_sysctl:
 	xfrm_policy_fini(net);
 out_policy:
@@ -2934,6 +2938,7 @@ out_statistics:
 
 static void __net_exit xfrm_net_exit(struct net *net)
 {
+	flow_cache_fini(net);
 	xfrm_sysctl_fini(net);
 	xfrm_policy_fini(net);
 	xfrm_state_fini(net);
-- 
1.7.9.5
