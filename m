From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net_sched: htb: do not setup default rate
 estimators
Date: Thu, 06 Jun 2013 14:53:16 -0700
Message-ID: <1370555596.24311.390.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:53458 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751908Ab3FFVxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jun 2013 17:53:18 -0400
Received: by mail-pd0-f174.google.com with SMTP id 10so2949310pdc.33
        for <netdev@vger.kernel.org>; Thu, 06 Jun 2013 14:53:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

With a thousand htb classes, est_timer() spends ~5 million cpu cycles
and throws out cpu cache, because each htb class has a default
rate estimator (est 4sec 16sec).

Most users do not use default rate estimators, so switch htb
to not setup ones.

Add a module parameter (htb_rate_est) so that users relying
on this default rate estimator can revert the behavior.

echo 1 >/sys/module/sch_htb/parameters/htb_rate_est

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Google-Bug-Id: 9316866

 net/sched/sch_htb.c |   18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index adaedd7..d0ee132 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -65,6 +65,10 @@ static int htb_hysteresis __read_mostly = 0; /* whether to use mode hysteresis f
 module_param    (htb_hysteresis, int, 0640);
 MODULE_PARM_DESC(htb_hysteresis, "Hysteresis mode, less CPU load, less accurate");
 
+static int htb_rate_est = 0; /* htb classes have a default rate estimator */
+module_param(htb_rate_est, int, 0640);
+MODULE_PARM_DESC(htb_rate_est, "setup a default rate estimator (4sec 16sec) for htb classes");
+
 /* used internaly to keep status of single class */
 enum htb_cmode {
 	HTB_CANT_SEND,		/* class can't send and can't borrow */
@@ -1366,12 +1370,14 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		if (!cl)
 			goto failure;
 
-		err = gen_new_estimator(&cl->bstats, &cl->rate_est,
-					qdisc_root_sleeping_lock(sch),
-					tca[TCA_RATE] ? : &est.nla);
-		if (err) {
-			kfree(cl);
-			goto failure;
+		if (htb_rate_est || tca[TCA_RATE]) {
+			err = gen_new_estimator(&cl->bstats, &cl->rate_est,
+						qdisc_root_sleeping_lock(sch),
+						tca[TCA_RATE] ? : &est.nla);
+			if (err) {
+				kfree(cl);
+				goto failure;
+			}
 		}
 
 		cl->refcnt = 1;
