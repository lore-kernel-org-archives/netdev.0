From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: [PATCH net] pkt_sched: fq: avoid hang when quantum 0
Date: Tue,  3 Feb 2015 17:49:18 +0100
Message-ID: <1422982158-12530-1-git-send-email-kennetkl@ifi.uio.no>
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out4.uio.no ([129.240.10.15]:51551 "EHLO mail-out4.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752494AbbBCQuQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 11:50:16 -0500
Received: from mail-mx6.uio.no ([129.240.10.40])
	by mail-out4.uio.no with esmtp (Exim 4.80.1)
	(envelope-from <kennetkl@ifi.uio.no>)
	id 1YIgg2-0001Ph-8r
	for netdev@vger.kernel.org; Tue, 03 Feb 2015 17:50:14 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Configuring fq with quantum 0 hangs the system, presumably because of a
non-interruptible infinite loop. Either way quantum 0 does not make sense.

Reproduce with:
sudo tc qdisc add dev lo root fq quantum 0 initial_quantum 0
ping 127.0.0.1

Signed-off-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
---
 net/sched/sch_fq.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 2a50f5c..313794b 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -670,8 +670,14 @@ static int fq_change(struct Qdisc *sch, struct nlattr *opt)
 	if (tb[TCA_FQ_FLOW_PLIMIT])
 		q->flow_plimit = nla_get_u32(tb[TCA_FQ_FLOW_PLIMIT]);
 
-	if (tb[TCA_FQ_QUANTUM])
-		q->quantum = nla_get_u32(tb[TCA_FQ_QUANTUM]);
+	if (tb[TCA_FQ_QUANTUM]) {
+		u32 quantum = nla_get_u32(tb[TCA_FQ_QUANTUM]);
+
+		if (quantum > 0)
+			q->quantum = quantum;
+		else
+			err = -EINVAL;
+	}
 
 	if (tb[TCA_FQ_INITIAL_QUANTUM])
 		q->initial_quantum = nla_get_u32(tb[TCA_FQ_INITIAL_QUANTUM]);
-- 
1.9.1
