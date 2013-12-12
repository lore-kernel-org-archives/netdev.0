From: Qais Yousef <qais.yousef@imgtec.com>
Subject: [PATCH] net/sched/sch_tbf.c: fix linking error
Date: Thu, 12 Dec 2013 12:38:56 +0000
Message-ID: <1386851936-1582-1-git-send-email-qais.yousef@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Qais Yousef <qais.yousef@imgtec.com>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-next@vger.kernel.org>
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ERROR: "__udivdi3" [net/sched/sch_tbf.ko] undefined!

introduced by: cc106e441a63 (net: sched: tbf: fix the calculation of max_size)

which adds a 64 by 32 bit division without using do_div().
Fix it by using do_div(len/ 53) instead of len/53.

Signed-off-by: Qais Yousef <qais.yousef@imgtec.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-next@vger.kernel.org
---
We caught this error on linux-next today. This is my quick attemp of a fix.
If it's not appropriate or doesn't make sense my apologies and feel free to
resend a better fix :)

 net/sched/sch_tbf.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index a44928c..771cbec 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -131,8 +131,10 @@ static u64 psched_ns_t2l(const struct psched_ratecfg *r,
 
 	do_div(len, NSEC_PER_SEC);
 
-	if (unlikely(r->linklayer == TC_LINKLAYER_ATM))
-		len = (len / 53) * 48;
+	if (unlikely(r->linklayer == TC_LINKLAYER_ATM)) {
+		do_div(len, 53);
+		len *= 48;
+	}
 
 	if (len > r->overhead)
 		len -= r->overhead;
-- 
1.7.1
