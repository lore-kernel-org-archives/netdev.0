From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/3] xfrm: policy: init locks early
Date: Mon, 6 Mar 2017 07:57:26 +0100
Message-ID: <1488783448-12588-2-git-send-email-steffen.klassert@secunet.com>
References: <1488783448-12588-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:35448 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752746AbdCFG6O (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Mar 2017 01:58:14 -0500
In-Reply-To: <1488783448-12588-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Dmitry reports following splat:
 INFO: trying to register non-static key.
 the code is fine but needs lockdep annotation.
 turning off the locking correctness validator.
 CPU: 0 PID: 13059 Comm: syz-executor1 Not tainted 4.10.0-rc7-next-20170207 #1
[..]
 spin_lock_bh include/linux/spinlock.h:304 [inline]
 xfrm_policy_flush+0x32/0x470 net/xfrm/xfrm_policy.c:963
 xfrm_policy_fini+0xbf/0x560 net/xfrm/xfrm_policy.c:3041
 xfrm_net_init+0x79f/0x9e0 net/xfrm/xfrm_policy.c:3091
 ops_init+0x10a/0x530 net/core/net_namespace.c:115
 setup_net+0x2ed/0x690 net/core/net_namespace.c:291
 copy_net_ns+0x26c/0x530 net/core/net_namespace.c:396
 create_new_namespaces+0x409/0x860 kernel/nsproxy.c:106
 unshare_nsproxy_namespaces+0xae/0x1e0 kernel/nsproxy.c:205
 SYSC_unshare kernel/fork.c:2281 [inline]

Problem is that when we get error during xfrm_net_init we will call
xfrm_policy_fini which will acquire xfrm_policy_lock before it was
initialized.  Just move it around so locks get set up first.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Fixes: 283bc9f35bbbcb0e9 ("xfrm: Namespacify xfrm state/policy locks")
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 177e208..3c8f5b7 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -3062,6 +3062,11 @@ static int __net_init xfrm_net_init(struct net *net)
 {
 	int rv;
 
+	/* Initialize the per-net locks here */
+	spin_lock_init(&net->xfrm.xfrm_state_lock);
+	spin_lock_init(&net->xfrm.xfrm_policy_lock);
+	mutex_init(&net->xfrm.xfrm_cfg_mutex);
+
 	rv = xfrm_statistics_init(net);
 	if (rv < 0)
 		goto out_statistics;
@@ -3078,11 +3083,6 @@ static int __net_init xfrm_net_init(struct net *net)
 	if (rv < 0)
 		goto out;
 
-	/* Initialize the per-net locks here */
-	spin_lock_init(&net->xfrm.xfrm_state_lock);
-	spin_lock_init(&net->xfrm.xfrm_policy_lock);
-	mutex_init(&net->xfrm.xfrm_cfg_mutex);
-
 	return 0;
 
 out:
-- 
1.9.1
