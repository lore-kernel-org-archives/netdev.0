From: Benjamin Poirier <bpoirier@suse.com>
Subject: [PATCH] ipv6: Annotate change of locking mechanism for np->opt
Date: Wed, 17 Feb 2016 16:20:33 -0800
Message-ID: <1455754833-31567-1-git-send-email-bpoirier@suse.com>
Cc: linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50137 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161920AbcBRAVs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 19:21:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

follows up commit 45f6fad84cc3 ("ipv6: add complete rcu protection around
np->opt") which added mixed rcu/refcount protection to np->opt.

Given the current implementation of rcu_pointer_handoff(), this has no
effect at runtime.

Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
---
 include/net/ipv6.h | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 6570f37..f3c9857 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -259,8 +259,12 @@ static inline struct ipv6_txoptions *txopt_get(const struct ipv6_pinfo *np)
 
 	rcu_read_lock();
 	opt = rcu_dereference(np->opt);
-	if (opt && !atomic_inc_not_zero(&opt->refcnt))
-		opt = NULL;
+	if (opt) {
+		if (!atomic_inc_not_zero(&opt->refcnt))
+			opt = NULL;
+		else
+			opt = rcu_pointer_handoff(opt);
+	}
 	rcu_read_unlock();
 	return opt;
 }
-- 
2.7.0
