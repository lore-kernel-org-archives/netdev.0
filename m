From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] qdisc: fix a module refcount leak in qdisc_create_dflt()
Date: Wed, 24 Aug 2016 09:39:02 -0700
Message-ID: <1472056742.14381.93.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        John Fastabend <john.fastabend@gmail.com>,
        stephen hemminger <stephen@networkplumber.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35810 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755653AbcHXQvk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 12:51:40 -0400
Received: by mail-pf0-f195.google.com with SMTP id h186so1520492pfg.2
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 09:51:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Should qdisc_alloc() fail, we must release the module refcount
we got right before.

Fixes: 6da7c8fcbcbd ("qdisc: allow setting default queuing discipline")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_generic.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index e95b67cd5718..657c13362b19 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -643,18 +643,19 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
 	struct Qdisc *sch;
 
 	if (!try_module_get(ops->owner))
-		goto errout;
+		return NULL;
 
 	sch = qdisc_alloc(dev_queue, ops);
-	if (IS_ERR(sch))
-		goto errout;
+	if (IS_ERR(sch)) {
+		module_put(ops->owner);
+		return NULL;
+	}
 	sch->parent = parentid;
 
 	if (!ops->init || ops->init(sch, NULL) == 0)
 		return sch;
 
 	qdisc_destroy(sch);
-errout:
 	return NULL;
 }
 EXPORT_SYMBOL(qdisc_create_dflt);
