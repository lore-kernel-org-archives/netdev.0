From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 13/14] netpoll: re-enable irq in poll_napi()
Date: Fri, 10 Aug 2012 15:10:36 +0800
Message-ID: <1344582637-18261-14-git-send-email-amwang@redhat.com>
References: <1344582637-18261-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>, David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2916 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755784Ab2HJHL1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2012 03:11:27 -0400
In-Reply-To: <1344582637-18261-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

napi->poll() needs IRQ enabled, so we have to re-enable IRQ before
calling it.

Cc: David Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/core/netpoll.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index e4ba3e7..346b1eb 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -168,16 +168,24 @@ static void poll_napi(struct net_device *dev)
 	struct napi_struct *napi;
 	int budget = 16;
 
+	WARN_ON_ONCE(!irqs_disabled());
+
 	list_for_each_entry(napi, &dev->napi_list, dev_list) {
+		local_irq_enable();
 		if (napi->poll_owner != smp_processor_id() &&
 		    spin_trylock(&napi->poll_lock)) {
+			rcu_read_lock_bh();
 			budget = poll_one_napi(rcu_dereference_bh(dev->npinfo),
 					       napi, budget);
+			rcu_read_unlock_bh();
 			spin_unlock(&napi->poll_lock);
 
-			if (!budget)
+			if (!budget) {
+				local_irq_disable();
 				break;
+			}
 		}
+		local_irq_disable();
 	}
 }
 
-- 
1.7.7.6
