From: Paolo Valente <paolo.valente@unimore.it>
Subject: [PATCH 1/2] pkt_sched: sch_qfq: improve efficiency of make_eligible
Date: Wed, 10 Jul 2013 15:46:08 +0200
Message-ID: <1373463969-11285-2-git-send-email-paolo.valente@unimore.it>
References: <20130305.235006.1904081547083683406.davem@davemloft.net>
 <1373463969-11285-1-git-send-email-paolo.valente@unimore.it>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fchecconi@gmail.com, rizzo@iet.unipi.it,
	David Laight <David.Laight@ACULAB.COM>,
	Paolo Valente <paolo.valente@unimore.it>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, shemminger@vyatta.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1373463969-11285-1-git-send-email-paolo.valente@unimore.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In make_eligible, a mask is used to decide which groups must become eligible:
the i-th group becomes eligible only if the i-th bit of the mask (from the
right) is set. The mask is computed by left-shifting a 1 by a given number of
places, and decrementing the result.  The shift is performed on a ULL to avoid
problems in case the number of places to shift is higher than 31.  On a 32-bit
machine, this is more costly than working on an UL. This patch replaces such a
costly operation with two cheaper branches.

The trick is based on the following fact: in case of a shift of at least 32
places, the resulting mask has at least the 32 less significant bits set,
whereas the total number of groups is lower than 32.  As a consequence, in this
case it is enough to just set the 32 less significant bits of the mask with a
cheaper ~0UL. In the other case, the shift can be safely performed on a UL.

Reported-by: David S. Miller <davem@davemloft.net>
Reported-by: David Laight <David.Laight@ACULAB.COM>
Signed-off-by: Paolo Valente <paolo.valente@unimore.it>
---
 net/sched/sch_qfq.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index d51852b..2a0ed50 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -821,7 +821,14 @@ static void qfq_make_eligible(struct qfq_sched *q)
 	unsigned long old_vslot = q->oldV >> q->min_slot_shift;
 
 	if (vslot != old_vslot) {
-		unsigned long mask = (1ULL << fls(vslot ^ old_vslot)) - 1;
+		unsigned long mask;
+		int last_flip_pos = fls(vslot ^ old_vslot);
+
+		if (last_flip_pos > 31) /* higher than the number of groups */
+			mask = ~0UL;    /* make all groups eligible */
+		else
+			mask = (1UL << last_flip_pos) - 1;
+
 		qfq_move_groups(q, mask, IR, ER);
 		qfq_move_groups(q, mask, IB, EB);
 	}
-- 
1.8.1.2
