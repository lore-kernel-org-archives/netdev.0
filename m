From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH] net_sched: fix order of queue length updates in
 qdisc_replace()
Date: Sat, 19 Aug 2017 15:37:07 +0300
Message-ID: <150314622756.18396.5215271249872220640.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>, stable@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forwardcorp1j.cmail.yandex.net ([5.255.227.106]:54927 "EHLO
        forwardcorp1j.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751035AbdHSMhO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Aug 2017 08:37:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This important to call qdisc_tree_reduce_backlog() after changing queue
length. Parent qdisc should deactivate class in ->qlen_notify() called from
qdisc_tree_reduce_backlog() but this happens only if qdisc->q.qlen in zero.

Missed class deactivations leads to crashes/warnings at picking packets
from empty qdisc and corrupting state at reactivating this class in future.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Fixes: 86a7996cc8a0 ("net_sched: introduce qdisc_replace() helper")
Cc: Stable <stable@vger.kernel.org>
---
 include/net/sch_generic.h |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 1c123e2b2415..67f815e5d525 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -806,8 +806,11 @@ static inline struct Qdisc *qdisc_replace(struct Qdisc *sch, struct Qdisc *new,
 	old = *pold;
 	*pold = new;
 	if (old != NULL) {
-		qdisc_tree_reduce_backlog(old, old->q.qlen, old->qstats.backlog);
+		unsigned int qlen = old->q.qlen;
+		unsigned int backlog = old->qstats.backlog;
+
 		qdisc_reset(old);
+		qdisc_tree_reduce_backlog(old, qlen, backlog);
 	}
 	sch_tree_unlock(sch);
 
