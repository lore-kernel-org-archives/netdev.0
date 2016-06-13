From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net_sched: prio: rollback allocations if prio_init()
 fails
Date: Sun, 12 Jun 2016 22:03:51 -0700
Message-ID: <1465794231.7945.150.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465773707.7945.133.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpXY0Ce5hbXYGOcd-N1tb9BH33JYXFQdmWEbsc5SWYsV8A@mail.gmail.com>
	 <1465792157.7945.145.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33794 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715AbcFMFDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 01:03:54 -0400
Received: by mail-it0-f68.google.com with SMTP id d71so5925337ith.1
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 22:03:54 -0700 (PDT)
In-Reply-To: <1465792157.7945.145.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Now prio_init() can return -ENOMEM, it also has to make sure
any allocated qdisc are freed, since the caller (qdisc_create()) wont
call ->destroy() handler for us.

Fixes: cbdf45116478 ("net_sched: prio: properly report out of memory errors")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/sch_prio.c |   14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 071718bccdab..9b703f2c921b 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -221,20 +221,18 @@ static int prio_tune(struct Qdisc *sch, struct nlattr *opt)
 static int prio_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
-	int i;
+	int err, i;
 
 	for (i = 0; i < TCQ_PRIO_BANDS; i++)
 		q->queues[i] = &noop_qdisc;
 
-	if (opt == NULL) {
+	if (!opt)
 		return -EINVAL;
-	} else {
-		int err;
 
-		if ((err = prio_tune(sch, opt)) != 0)
-			return err;
-	}
-	return 0;
+	err = prio_tune(sch, opt);
+	if (err)
+		prio_destroy(sch);
+	return err;
 }
 
 static int prio_dump(struct Qdisc *sch, struct sk_buff *skb)
