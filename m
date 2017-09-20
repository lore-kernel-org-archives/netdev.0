From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH] net_sched/hfsc: fix curve activation in hfsc_change_class()
Date: Wed, 20 Sep 2017 15:46:11 +0300
Message-ID: <150591157194.113686.4485981339195559372.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forwardcorp1o.cmail.yandex.net ([37.9.109.47]:33172 "EHLO
        forwardcorp1o.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751680AbdITMqQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 08:46:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If real-time or fair-share curves are enabled in hfsc_change_class()
class isn't inserted into rb-trees yet. Thus init_ed() and init_vf()
must be called in place of update_ed() and update_vf().

Remove isn't required because for now curves cannot be disabled.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 net/sched/sch_hfsc.c |   23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index daaf214e5201..3f88b75488b0 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -958,6 +958,8 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	}
 
 	if (cl != NULL) {
+		int old_flags;
+
 		if (parentid) {
 			if (cl->cl_parent &&
 			    cl->cl_parent->cl_common.classid != parentid)
@@ -978,6 +980,8 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 		}
 
 		sch_tree_lock(sch);
+		old_flags = cl->cl_flags;
+
 		if (rsc != NULL)
 			hfsc_change_rsc(cl, rsc, cur_time);
 		if (fsc != NULL)
@@ -986,10 +990,21 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 			hfsc_change_usc(cl, usc, cur_time);
 
 		if (cl->qdisc->q.qlen != 0) {
-			if (cl->cl_flags & HFSC_RSC)
-				update_ed(cl, qdisc_peek_len(cl->qdisc));
-			if (cl->cl_flags & HFSC_FSC)
-				update_vf(cl, 0, cur_time);
+			int len = qdisc_peek_len(cl->qdisc);
+
+			if (cl->cl_flags & HFSC_RSC) {
+				if (old_flags & HFSC_RSC)
+					update_ed(cl, len);
+				else
+					init_ed(cl, len);
+			}
+
+			if (cl->cl_flags & HFSC_FSC) {
+				if (old_flags & HFSC_FSC)
+					update_vf(cl, 0, cur_time);
+				else
+					init_vf(cl, len);
+			}
 		}
 		sch_tree_unlock(sch);
 
