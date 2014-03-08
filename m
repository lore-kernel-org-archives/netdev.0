From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] pkt_sched: move the sanity test in qdisc_list_add()
Date: Sat, 08 Mar 2014 08:01:19 -0800
Message-ID: <1394294479.20149.66.camel@edumazet-glaptop2.roam.corp.google.com>
References: <7625.1387476879@turing-police.cc.vt.edu>
	 <1387556764.19078.441.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	David Miller <davem@davemloft.net>,
	Mirco Tischler <mt-ml@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:61084 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbaCHQBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2014 11:01:21 -0500
Received: by mail-pa0-f47.google.com with SMTP id lj1so5445722pab.20
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2014 08:01:21 -0800 (PST)
In-Reply-To: <1387556764.19078.441.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

The WARN_ON(root == &noop_qdisc)) added in qdisc_list_add()
can trigger in normal conditions when devices are not up.
It should be done only right before the list_add_tail() call.

Fixes: e57a784d8cae4 ("pkt_sched: set root qdisc before change() in attach_default_qdiscs()")
Reported-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Tested-by: Mirco Tischler <mt-ml@gmx.de>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_api.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index c31190e29b90..17c03198ebbc 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -273,11 +273,12 @@ static struct Qdisc *qdisc_match_from_root(struct Qdisc *root, u32 handle)
 
 void qdisc_list_add(struct Qdisc *q)
 {
-	struct Qdisc *root = qdisc_dev(q)->qdisc;
+	if ((q->parent != TC_H_ROOT) && !(q->flags & TCQ_F_INGRESS)) {
+		struct Qdisc *root = qdisc_dev(q)->qdisc;
 
-	WARN_ON_ONCE(root == &noop_qdisc);
-	if ((q->parent != TC_H_ROOT) && !(q->flags & TCQ_F_INGRESS))
+		WARN_ON_ONCE(root == &noop_qdisc);
 		list_add_tail(&q->list, &root->list);
+	}
 }
 EXPORT_SYMBOL(qdisc_list_add);
 
