From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH 0/7 RFC] Netfilter/nf_tables ingress support
Date: Wed, 15 Apr 2015 00:35:16 -0700
Message-ID: <552E14B4.7060907@gmail.com>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org> <20150410132205.GF23070@casper.infradead.org> <20150410200901.GB5968@salvia> <20150412.211421.1771298417488412635.davem@davemloft.net> <20150413201913.GD20275@acer.localdomain> <552D07C4.1020509@mojatatu.com> <552D2E52.8020303@intel.com> <20150414153613.GA2781@Alexeis-MBP.westell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, pablo@netfilter.org,
	tgraf@suug.ch, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150414153613.GA2781@Alexeis-MBP.westell.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/14/2015 08:36 AM, Alexei Starovoitov wrote:
> On Tue, Apr 14, 2015 at 08:12:18AM -0700, John Fastabend wrote:
>>
>> I was hoping to push the skb lists onto something like rte_ring
>> used by the DPDK folks or possibly some of the lockless ring work Jesper
>> created. This is needed for many qdisc's to drop the qlock but not the
>> ingress qdisc. Been busy working on switch bits lately but might be
>> able to pick this up next merge window.
>
> I've spent quite a bit of time reanalyzying your work ;) It seems
> only trivial stuff left to drop ingress spinlock. Can you send me
> your TC test scripts ? I'm only starting building mine and they're
> not covering everything. Roughly I'm creating namespaces and running
> traffic between them while varying csum/gso/gro offload settings.
>

I'll dig up my scripts and post them to github this weekend. They
are a bit organized and all over the place at the moment.

Maybe we can build a master repository. I know there a lot of different
scripts running around, for example I already collected a few from
Jamal and I think Cong must have some as well.

Here is a patch that has been running on my dev box sans the quick
port to Dave's master tree. It seems to work at least it has been
running on my dev box for a few months. But I haven't had a chance to
run any recent perf numbers on it. Actually what I would really like
is to drop the lock on pfifo_fast with a lockless skb ring and make
drivers expose a descriptor ring per core (most already do anyways).

---

net: sched: run ingress qdisc without locks

From: John Fastabend <john.r.fastabend@intel.com>

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
  net/core/dev.c          |    2 --
  net/sched/sch_ingress.c |    3 ++-
  2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index af4a1b0..9b34a18 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3547,10 +3547,8 @@ static int ing_filter(struct sk_buff *skb, struct 
netdev_queue *rxq)

  	q = rcu_dereference(rxq->qdisc);
  	if (q != &noop_qdisc) {
-		spin_lock(qdisc_lock(q));
  		if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
  			result = qdisc_enqueue_root(skb, q);
-		spin_unlock(qdisc_lock(q));
  	}

  	return result;
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 4cdbfb8..a2542ac 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -69,7 +69,7 @@ static int ingress_enqueue(struct sk_buff *skb, struct 
Qdisc *sch)
  	switch (result) {
  	case TC_ACT_SHOT:
  		result = TC_ACT_SHOT;
-		qdisc_qstats_drop(sch);
+		qdisc_qstats_drop_cpu(sch);
  		break;
  	case TC_ACT_STOLEN:
  	case TC_ACT_QUEUED:
@@ -91,6 +91,7 @@ static int ingress_enqueue(struct sk_buff *skb, struct 
Qdisc *sch)
  static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
  {
  	net_inc_ingress_queue();
+	sch->flags |= TCQ_F_CPUSTATS;

  	return 0;
  }

-- 
John Fastabend         Intel Corporation
