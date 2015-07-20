From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net] net: sched: validate that class is found in qdisc_tree_decrease_qlen
Date: Mon, 20 Jul 2015 12:38:33 -0700
Message-ID: <1437421113-2792450-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <eric.dumazet@gmail.com>,
	<kernel-team@fb.com>, <stable@vger.kernel.org>,
	Alex Gartrell <agartrell@fb.com>
To: <xiyou.wangcong@gmail.com>, <jhs@mojatatu.com>,
	<davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

First, vehement apologies for sending an RFC patch against such an old
kernel.  This is (potentially) a bug fix for a crash that we've been seeing
in 3.2 and 3.10, and, AFAICT, the underlying issue has not been addressed.

We have an application that invokes tc to delete the root every time the
config changes. As a result we stress the cleanup code and were seeing the
following panic:

  crash> bt
  PID: 630839  TASK: ffff8823c990d280  CPU: 14  COMMAND: "tc"
   [... snip ...]
   #8 [ffff8820ceec17a0] page_fault at ffffffff8160a8c2
      [exception RIP: htb_qlen_notify+24]
      RIP: ffffffffa0841718  RSP: ffff8820ceec1858  RFLAGS: 00010282
      RAX: 0000000000000000  RBX: 0000000000000000  RCX: ffff88241747b400
      RDX: ffff88241747b408  RSI: 0000000000000000  RDI: ffff8811fb27d000
      RBP: ffff8820ceec1868   R8: ffff88120cdeff24   R9: ffff88120cdeff30
      R10: 0000000000000bd4  R11: ffffffffa0840919  R12: ffffffffa0843340
      R13: 0000000000000000  R14: 0000000000000001  R15: ffff8808dae5c2e8
      ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
   #9 [...] qdisc_tree_decrease_qlen at ffffffff81565375
  #10 [...] fq_codel_dequeue at ffffffffa084e0a0 [sch_fq_codel]
  #11 [...] fq_codel_reset at ffffffffa084e2f8 [sch_fq_codel]
  #12 [...] qdisc_destroy at ffffffff81560d2d
  #13 [...] htb_destroy_class at ffffffffa08408f8 [sch_htb]
  #14 [...] htb_put at ffffffffa084095c [sch_htb]
  #15 [...] tc_ctl_tclass at ffffffff815645a3
  #16 [...] rtnetlink_rcv_msg at ffffffff81552cb0
  [... snip ...]

To my understanding, the following situation is taking place.

  tc_ctl_tclass
   -> htb_delete
     -> class is deleted from clhash
   -> htb_put
     -> qdisc_destroy
       -> fq_codel_reset
         -> fq_codel_dequeue
           -> qdidsc_tree_decrease_qlen
             -> cl = htb_get # returns NULL, removed in htb_delete
               -> htb_qlen_notify(sch, NULL) # BOOM

This patch checks cl for 0 before invoking qlen_notify and put.  The notify
is not necessary in this case, as the parent has already been deactivated
anyway.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/sched/sch_api.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index f06aa01..46be5e5 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -762,8 +762,15 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
 		cops = sch->ops->cl_ops;
 		if (cops->qlen_notify) {
 			cl = cops->get(sch, parentid);
-			cops->qlen_notify(sch, cl);
-			cops->put(sch, cl);
+			/* This will be 0 in the event that cl is being
+			 * destroyed, in which case we should not attempt
+			 * to invoke qlen_notify upon it (it must be
+			 * cleaned up otherwise anyway.
+			 */
+			if (cl != 0) {
+				cops->qlen_notify(sch, cl);
+				cops->put(sch, cl);
+			}
 		}
 		sch->q.qlen -= n;
 		__qdisc_qstats_drop(sch, drops);
-- 
Alex Gartrell <agartrell@fb.com>
