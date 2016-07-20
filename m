From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 20 Jul 2016 12:05:07 +1000
Message-ID: <20160720120507.0ee7b9f0@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/sched/sch_htb.c

between commit:

  338ed9b4de57 ("net_sched: sch_htb: export class backlog in dumps")

from the net tree and commit:

  0564bf0afae4 ("net/sched/sch_htb: clamp xstats tokens to fit into 32-bit int")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc net/sched/sch_htb.c
index 052f84d6cc23,91982d9784b3..000000000000
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@@ -1136,18 -1113,22 +1113,24 @@@ static in
  htb_dump_class_stats(struct Qdisc *sch, unsigned long arg, struct gnet_dump *d)
  {
  	struct htb_class *cl = (struct htb_class *)arg;
+ 	struct gnet_stats_queue qs = {
+ 		.drops = cl->drops,
+ 	};
  	__u32 qlen = 0;
  
- 	if (!cl->level && cl->un.leaf.q)
+ 	if (!cl->level && cl->un.leaf.q) {
  		qlen = cl->un.leaf.q->q.qlen;
+ 		qs.backlog = cl->un.leaf.q->qstats.backlog;
+ 	}
 -	cl->xstats.tokens = PSCHED_NS2TICKS(cl->tokens);
 -	cl->xstats.ctokens = PSCHED_NS2TICKS(cl->ctokens);
 +	cl->xstats.tokens = clamp_t(s64, PSCHED_NS2TICKS(cl->tokens),
 +				    INT_MIN, INT_MAX);
 +	cl->xstats.ctokens = clamp_t(s64, PSCHED_NS2TICKS(cl->ctokens),
 +				     INT_MIN, INT_MAX);
  
- 	if (gnet_stats_copy_basic(d, NULL, &cl->bstats) < 0 ||
+ 	if (gnet_stats_copy_basic(qdisc_root_sleeping_running(sch),
+ 				  d, NULL, &cl->bstats) < 0 ||
  	    gnet_stats_copy_rate_est(d, NULL, &cl->rate_est) < 0 ||
- 	    gnet_stats_copy_queue(d, NULL, &cl->qstats, qlen) < 0)
+ 	    gnet_stats_copy_queue(d, NULL, &qs, qlen) < 0)
  		return -1;
  
  	return gnet_stats_copy_app(d, &cl->xstats, sizeof(cl->xstats));
