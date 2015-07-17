From: Alex Gartrell <agartrell@fb.com>
Subject: [RGC PATCH v3.10] net: sched: validate that class is found in qdisc_tree_decrease_qlen
Date: Fri, 17 Jul 2015 16:27:57 -0700
Message-ID: <1437175677-1252239-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, Alex Gartrell <agartrell@fb.com>
To: <jhs@mojatatu.com>, <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:64439 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753449AbbGQX2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 19:28:04 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6HNOTJP014147
	for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 16:28:03 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1vqapp04xj-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 16:28:03 -0700
Received: from facebook.com (2401:db00:20:7017:face:0:13:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 763bad662cdb11e5a50e24be0595f910-41f526b0 for <netdev@vger.kernel.org>;	Fri,
 17 Jul 2015 16:28:00 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First, vehement apologies for sending an RFC patch against such an old
kernel.  This is (potentially) a bug fix for a crash that we've been seeing
in 3.2 and 3.10, and, AFAICT, the underlying issue has not been addressed.

We have an application that invokes tc to delete the root every time the
config changes. As a result we stress the cleanup code and were seeing the
following panic:

  crash> bt
  PID: 630839  TASK: ffff8823c990d280  CPU: 14  COMMAND: "tc"
   #0 [ffff8820ceec1450] machine_kexec at ffffffff81036865
   #1 [ffff8820ceec14a0] crash_kexec at ffffffff810aa3e8
   #2 [ffff8820ceec1570] oops_end at ffffffff8160b458
   #3 [ffff8820ceec15a0] no_context at ffffffff816000e2
   #4 [ffff8820ceec1600] __bad_area_nosemaphore at ffffffff816002c7
   #5 [ffff8820ceec1650] bad_area at ffffffff81600515
   #6 [ffff8820ceec1680] __do_page_fault at ffffffff8160df9e
   #7 [ffff8820ceec1790] do_page_fault at ffffffff8160e09e
   #8 [ffff8820ceec17a0] page_fault at ffffffff8160a8c2
      [exception RIP: htb_qlen_notify+24]
      RIP: ffffffffa0841718  RSP: ffff8820ceec1858  RFLAGS: 00010282
      RAX: 0000000000000000  RBX: 0000000000000000  RCX: ffff88241747b400
      RDX: ffff88241747b408  RSI: 0000000000000000  RDI: ffff8811fb27d000
      RBP: ffff8820ceec1868   R8: ffff88120cdeff24   R9: ffff88120cdeff30
      R10: 0000000000000bd4  R11: ffffffffa0840919  R12: ffffffffa0843340
      R13: 0000000000000000  R14: 0000000000000001  R15: ffff8808dae5c2e8
      ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
   #9 [ffff8820ceec1870] qdisc_tree_decrease_qlen at ffffffff81565375
  #10 [ffff8820ceec18a0] fq_codel_dequeue at ffffffffa084e0a0 [sch_fq_codel]
  #11 [ffff8820ceec1940] fq_codel_reset at ffffffffa084e2f8 [sch_fq_codel]
  #12 [ffff8820ceec1960] qdisc_destroy at ffffffff81560d2d
  #13 [ffff8820ceec1980] htb_destroy_class at ffffffffa08408f8 [sch_htb]
  #14 [ffff8820ceec19a0] htb_put at ffffffffa084095c [sch_htb]
  #15 [ffff8820ceec19b0] tc_ctl_tclass at ffffffff815645a3
  #16 [ffff8820ceec1a60] rtnetlink_rcv_msg at ffffffff81552cb0
  #17 [ffff8820ceec1ae0] netlink_rcv_skb at ffffffff8156cfd1
  #18 [ffff8820ceec1b10] rtnetlink_rcv at ffffffff8154f7f5
  #19 [ffff8820ceec1b30] netlink_unicast at ffffffff8156c929
  #20 [ffff8820ceec1b80] netlink_sendmsg at ffffffff8156cc69
  #21 [ffff8820ceec1c10] sock_sendmsg at ffffffff81528cf6
  #22 [ffff8820ceec1d60] ___sys_sendmsg at ffffffff815290bc
  #23 [ffff8820ceec1f00] __sys_sendmsg at ffffffff8152c589
  #24 [ffff8820ceec1f70] sys_sendmsg at ffffffff8152c5e2
  #25 [ffff8820ceec1f80] system_call_fastpath at ffffffff816128c2
      RIP: 00007f31695448b0  RSP: 00007fffb1509538  RFLAGS: 00010293
      RAX: 000000000000002e  RBX: ffffffff816128c2  RCX: 0000000000000030
      RDX: 0000000000000000  RSI: 00007fffb15054d0  RDI: 0000000000000005
      RBP: 00007fffb150a5f0   R8: 0000000000000007   R9: 0000000000000000
      R10: 00007fffb1505230  R11: 0000000000000246  R12: ffffffff8152c5e2
      R13: ffff8820ceec1f78  R14: 0000000000642760  R15: 00007fffb15095b0
      ORIG_RAX: 000000000000002e  CS: 0033  SS: 002b

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
index 2d2f079..f5d48dd 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -700,8 +700,15 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
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
 	}
-- 
Alex Gartrell <agartrell@fb.com>
