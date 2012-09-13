From: Cyril Chemparathy <cyril@ti.com>
Subject: [PATCH] sch_red: fix weighted average calculation
Date: Thu, 13 Sep 2012 09:43:40 -0400
Message-ID: <1347543820-27548-1-git-send-email-cyril@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <david.ward@ll.mit.edu>,
	<eric.dumazet@gmail.com>, <jdowdal@ti.com>,
	<paul.gortmaker@windriver.com>, Cyril Chemparathy <cyril@ti.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes an apparent bug in the running weighted average calculation
used in the RED algorithm.

Going by the described formula:
	   qavg = qavg*(1-W) + backlog*W
	=> qavg = qavg + (backlog - qavg) * W

... with W converted to a pre-calculated shift, this then becomes:
	qavg = qavg + (backlog - qavg) >> logW

... giving the modified expression introduced by this patch.

Signed-off-by: John Dowdal <jdowdal@ti.com>
---
 include/net/red.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/red.h b/include/net/red.h
index ef46058..05960a4 100644
--- a/include/net/red.h
+++ b/include/net/red.h
@@ -287,7 +287,7 @@ static inline unsigned long red_calc_qavg_no_idle_time(const struct red_parms *p
 	 *
 	 * --ANK (980924)
 	 */
-	return v->qavg + (backlog - (v->qavg >> p->Wlog));
+	return v->qavg + (backlog - v->qavg) >> p->Wlog;
 }
 
 static inline unsigned long red_calc_qavg(const struct red_parms *p,
-- 
1.7.9.5
