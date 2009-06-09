From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 1/2] pkt_sched: Use PSCHED_SHIFT in PSCHED time conversion
Date: Tue, 9 Jun 2009 08:05:00 +0000
Message-ID: <20090609080500.GA5237@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Antonio Almeida <vexwek@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, Martin Devera <devik@cdi.cz>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>,
	Badalian Vyacheslav <slavon@bigtelecom.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:33173 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757466AbZFIIFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 04:05:06 -0400
Received: by ewy6 with SMTP id 6so4929033ewy.37
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2009 01:05:06 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use PSCHED_SHIFT constant instead of '10' in PSCHED_US2NS() and
PSCHED_NS2US() macros to enable changing this value later.

Additionally use PSCHED_SHIFT in sch_hfsc SM_SHIFT and ISM_SHIFT
definitions. This part of the patch is based on feedback from
Patrick McHardy <kaber@trash.net>.

Reported-by: Antonio Almeida <vexwek@gmail.com>
Tested-by: Antonio Almeida <vexwek@gmail.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 include/net/pkt_sched.h |    5 +++--
 net/sched/sch_hfsc.c    |    8 +++++---
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index e37fe31..cd0e026 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -42,8 +42,9 @@ typedef u64	psched_time_t;
 typedef long	psched_tdiff_t;
 
 /* Avoid doing 64 bit divide by 1000 */
-#define PSCHED_US2NS(x)			((s64)(x) << 10)
-#define PSCHED_NS2US(x)			((x) >> 10)
+#define PSCHED_SHIFT			10
+#define PSCHED_US2NS(x)			((s64)(x) << PSCHED_SHIFT)
+#define PSCHED_NS2US(x)			((x) >> PSCHED_SHIFT)
 
 #define PSCHED_TICKS_PER_SEC		PSCHED_NS2US(NSEC_PER_SEC)
 #define PSCHED_PASTPERFECT		0
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 5022f9c..362c281 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -372,7 +372,7 @@ cftree_update(struct hfsc_class *cl)
  *	ism: (psched_us/byte) << ISM_SHIFT
  *	dx: psched_us
  *
- * The clock source resolution with ktime is 1.024us.
+ * The clock source resolution with ktime and PSCHED_SHIFT 10 is 1.024us.
  *
  * sm and ism are scaled in order to keep effective digits.
  * SM_SHIFT and ISM_SHIFT are selected to keep at least 4 effective
@@ -383,9 +383,11 @@ cftree_update(struct hfsc_class *cl)
  *  bytes/1.024us 12.8e-3    128e-3     1280e-3    12800e-3   128000e-3
  *
  *  1.024us/byte  78.125     7.8125     0.78125    0.078125   0.0078125
+ *
+ * So, for PSCHED_SHIFT 10 we need: SM_SHIFT 20, ISM_SHIFT 18.
  */
-#define	SM_SHIFT	20
-#define	ISM_SHIFT	18
+#define	SM_SHIFT	(30 - PSCHED_SHIFT)
+#define	ISM_SHIFT	(8 + PSCHED_SHIFT)
 
 #define	SM_MASK		((1ULL << SM_SHIFT) - 1)
 #define	ISM_MASK	((1ULL << ISM_SHIFT) - 1)
