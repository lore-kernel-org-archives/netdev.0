From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH] net/sched/sch_htb: clamp xstats tokens to fit into 32-bit
 int
Date: Sat, 16 Jul 2016 17:08:56 +0300
Message-ID: <146867813621.23552.6234170020058724059.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In kernel HTB keeps tokens in signed 64-bit in nanoseconds. In netlink
protocol these values are converted into pshed ticks (64ns for now) and
truncated to 32-bit. In struct tc_htb_xstats fields "tokens" and "ctokens"
are declared as unsigned 32-bit but they could be negative thus tool 'tc'
prints them as signed. Big values loose higher bits and/or become negative.

This patch clamps tokens in xstat into range from INT_MIN to INT_MAX.
In this way it's easier to understand what's going on here.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 net/sched/sch_htb.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 62f9d8100c6e..052f84d6cc23 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1140,8 +1140,10 @@ htb_dump_class_stats(struct Qdisc *sch, unsigned long arg, struct gnet_dump *d)
 
 	if (!cl->level && cl->un.leaf.q)
 		qlen = cl->un.leaf.q->q.qlen;
-	cl->xstats.tokens = PSCHED_NS2TICKS(cl->tokens);
-	cl->xstats.ctokens = PSCHED_NS2TICKS(cl->ctokens);
+	cl->xstats.tokens = clamp_t(s64, PSCHED_NS2TICKS(cl->tokens),
+				    INT_MIN, INT_MAX);
+	cl->xstats.ctokens = clamp_t(s64, PSCHED_NS2TICKS(cl->ctokens),
+				     INT_MIN, INT_MAX);
 
 	if (gnet_stats_copy_basic(d, NULL, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, NULL, &cl->rate_est) < 0 ||
