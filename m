From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 4/7] netns: Add an explicit rcu_barrier to unregister_pernet_{device|subsys}
Date: Thu,  3 Dec 2009 04:29:06 -0800
Message-ID: <1259843349-3810-4-git-send-email-ebiederm@xmission.com>
References: <m11vjcnsyr.fsf@fess.ebiederm.org>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:54565 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753012AbZLCM31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 07:29:27 -0500
In-Reply-To: <m11vjcnsyr.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

This allows namespace exit methods to batch work that comes requires an
rcu barrier using call_rcu without having to treat the
unregister_pernet_operations cases specially.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/core/net_namespace.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 4026a4c..bd8c471 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -413,8 +413,11 @@ again:
 		}
 	}
 	error = __register_pernet_operations(list, ops);
-	if (error && ops->id)
-		ida_remove(&net_generic_ids, *ops->id);
+	if (error) {
+		rcu_barrier();
+		if (ops->id)
+			ida_remove(&net_generic_ids, *ops->id);
+	}
 
 	return error;
 }
@@ -423,6 +426,7 @@ static void unregister_pernet_operations(struct pernet_operations *ops)
 {
 	
 	__unregister_pernet_operations(ops);
+	rcu_barrier();
 	if (ops->id)
 		ida_remove(&net_generic_ids, *ops->id);
 }
-- 
1.6.5.2.143.g8cc62

