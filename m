From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC] Replacing qdisc tc_stats with generic statistics to make it extendable
Date: Wed, 6 Oct 2004 00:21:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041005222149.GA17186@postel.suug.ch>
References: <20041003213124.GG14344@postel.suug.ch> <20041003213954.GI14344@postel.suug.ch> <20041003161436.50293f9a.davem@davemloft.net> <20041003235737.GO14344@postel.suug.ch> <20041005140304.6d0d5f02.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041005140304.6d0d5f02.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20041005140304.6d0d5f02.davem@davemloft.net> 2004-10-05 14:03
> Ok, so I combined all of the work into one big patch
> and checked it into my tree as follows:

Looks good.

I have the following idea in mind, regarding on howto actually use this code.

(Qdisc API is being used for explanation)

 1) Introduce new qdisc op dump_stats in struct Qdisc_ops. (minor)
+   int         (*dump_stats)(struct Qdisc *, struct sk_buff *, struct gnet_dump *);

 2) Replace struct tc_stats in struct Qdisc with a list of generic network
    statistics common to all qdiscs (basic/queue/rate_est) (minor)

 3) Fix all statistic updates to use new structs (minor)

 4) Use new generic estimator (minor)

 5) Adapt tc_fill_qdisc and to use new gnet_stats API in compatibilty mode and call
    dump_stats if available.

+   if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
+       TCA_XSTATS, q->stats_lock, &dump) < 0)
+       goto rtattr_failure;
+
+   if (q->ops->dump_stats && q->ops->dump_stats(q, skb, &dump) < 0)
+       goto rtattr_failure;
+
+   if (gnet_stats_copy_basic(&dump, &q->bstats) < 0 ||
+#ifdef CONFIG_NET_ESTIMATOR
+       gnet_stats_copy_rate_est(&dump, &q->rate_est) < 0 ||
+#endif
+       gnet_stats_copy_queue(&dump, &q->qstats) < 0)
+       goto rtattr_failure;
+
+   if (gnet_stats_finish_copy(&dump) < 0)
        goto rtattr_failure;

 6) The qdisc implements dump_stats and dumps qdisc specific statistics
    such as the existing xstats. It may dump other generic statistics
    which are only used by this qdisc. The implementation of this
    callback is optional and only required if the qdisc has own
    statistics.

+static int cbq_dump_stats(struct Qdisc *sch, struct sk_buff *skb, struct gnet_dump *d)
+{
+   struct cbq_sched_data *q = qdisc_priv(sch);
+
+   q->link.xstats.avgidle = q->link.avgidle;
+   if (gnet_stats_copy_app(d, &q->link.xstats, sizeof(q->link.xstats)) < 0)
+       return -1;
+   return 0;
+}

 7) Remove old xstats copying code (some qdiscs, namely HTB, even copy TCA_STATS
    on their own which doesn't make sense)

Pros: 
 - All statistics nicely organized in one TLV (replaces TCA_STATS and TCA_XSTATS
   as a long term goal.)
 - TCA_STATS and TCA_XSTATS are still provided without the qdisc actually
   noticing.
 - Easy to add new statistics without the need to even think about
   compatibility.
 - The whole dumping process is correctly locked.
 - Qdiscs may add their own generic statistics if needed.
 - Qdiscs can correct/update statistics right before dumping to be as accurate
   as possible.

Cons:
 - Requires changing all qdiscs. (mostly minor changes)
 - (Would) break binary only qdiscs.

I've tested the above code for a few days but will continue to do so for a
few days.

Since this is pretty major and will touch a lot of code I'd be interested
if this is the right way to go and how to do it to make patch submission
as easy as possible.
Here would be my scenario on howto do it in several steps not breaking
anything in between:
Step 1: Use new generic networking statistics, update all qdiscs and
        switch to new estimator. Doesn't break anything but must be
        atomic.
Step 2-N: Add dump_stats and update qdiscs one after each other.

Thoughts?
