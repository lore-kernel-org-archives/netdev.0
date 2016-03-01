From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC] net: Fix race condition when removing qdisc
Date: Tue, 1 Mar 2016 15:16:37 -0800
Message-ID: <1456874197-3036009-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <brakmo@fb.com>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:15067 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751878AbcCAXQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 18:16:42 -0500
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.15.0.59/8.15.0.59) with SMTP id u21N93pw029233
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2016 15:16:41 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 21dfb6hucp-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 15:16:41 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 a771572ee00311e591450002c99293a0-f0bee270 for <netdev@vger.kernel.org>;	Tue,
 01 Mar 2016 15:16:40 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are seeing a number of softlockups occurring with HTB upon removing
the qdisc. We are still attempting to repro the exact circumstances,
however looking at the code I'm very suspicious of this block in
net_tx_action and its interaction with dev_deactivate (called through
tc_modify_qdisc):

       if (!test_bit(__QDISC_STATE_DEACTIVATED,
		     &q->state)) {
	       __netif_reschedule(q);
       } else {
	       smp_mb__before_atomic();
	       clear_bit(__QDISC_STATE_SCHED,
			 &q->state);
       }

I think the following scenario could lead to badness:

0) net_tx_action spin_trylock fails, taking non-locked block
1) net_tx_action checks for __QDISC_STATE_DEACTIVATED, it's not set
   at this point
2) dev_deactive has lock and sets __QDISC_STATE_DEACTIVATED
3) dev_deactivate_many performs some_qdisc_is_busy(dev), neither
   __QDISC_STATE_SCHED nor __QDISC_STATE_BUSY are set at this
  point, so some_qdisc_busy fails (not seen as busy)
4) net_tx_action sets __QDISC_STATE_SCHED

At this point dev_deactivate_many finishes so the qdisc may
be freed in the tc_modify_qdisc path, however the qdisc is
also "successfully" rescheduled to run by net_tx_action.

The propsed fix for this is to eliminate the spin_trylock in
net_tx_action and always take the lock.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/core/dev.c | 24 ++++++++----------------
 1 file changed, 8 insertions(+), 16 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index edb7179..77ec0c1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3855,22 +3855,14 @@ static void net_tx_action(struct softirq_action *h)
 			head = head->next_sched;
 
 			root_lock = qdisc_lock(q);
-			if (spin_trylock(root_lock)) {
-				smp_mb__before_atomic();
-				clear_bit(__QDISC_STATE_SCHED,
-					  &q->state);
-				qdisc_run(q);
-				spin_unlock(root_lock);
-			} else {
-				if (!test_bit(__QDISC_STATE_DEACTIVATED,
-					      &q->state)) {
-					__netif_reschedule(q);
-				} else {
-					smp_mb__before_atomic();
-					clear_bit(__QDISC_STATE_SCHED,
-						  &q->state);
-				}
-			}
+			spin_lock(root_lock);
+
+			smp_mb__before_atomic();
+			clear_bit(__QDISC_STATE_SCHED,
+				  &q->state);
+			qdisc_run(q);
+
+			spin_unlock(root_lock);
 		}
 	}
 }
-- 
2.6.5
