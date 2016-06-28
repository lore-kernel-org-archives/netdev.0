From: Jiri Kosina <jikos@kernel.org>
Subject: [RFC PATCH] sch_tbf: avoid silent fallback to noop_qdisc (was Re:
 Deleting child qdisc doesn't reset parent to default qdisc?)
Date: Tue, 28 Jun 2016 18:49:28 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1606281846500.6874@cbobk.fhfr.pm>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm>  <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com>  <20160414151813.GE3715@orbyte.nwl.cc>  <alpine.LNX.2.00.1604141807350.27368@cbobk.fhfr.pm>
 <1460656170.10638.61.camel@edumazet-glaptop3.roam.corp.google.com>  <5710E1C1.2090209@mojatatu.com> <1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Phil Sutter <phil@nwl.cc>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:57854 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752297AbcF1Qtb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 12:49:31 -0400
In-Reply-To: <1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Apr 2016, Eric Dumazet wrote:

> Then you need to save the initial qdisc (bfifo for TBF) in a special
> place, to make sure the delete operation is guaranteed to succeed.
> 
> Or fail the delete if the bfifo can not be allocated.
> 
> I can tell that determinism if far more interesting than usability for
> some users occasionally playing with tc.
> 
> Surely the silent fallback to noop_qdisc is wrong.

So before we go further and fix the fact that we actually do have hidden 
qdiscs (by refactoring qdisc_match_from_root() and friends), I'd still 
like to bring the patch below up for consideration.

Thanks.




From: Jiri Kosina <jkosina@suse.cz>
Subject: [PATCH] sch_tbf: avoid silent fallback to noop_qdisc

TBF started its life as a classless qdisc with a single builtin FIFO queue
which was being shaped.

When it got later turned into classful qdisc, it was written in a way that
the fallback qdisc was noop_qdisc, which produces bad user experience (delete
of last manually added class doesn't reset it to initial default, but renders
networking unusable instead).

Switch the default fallback to bfifo; this also mimics how the other guys
(HTB, HFSC, CBQ, ...) are behaving.

Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 net/sched/sch_tbf.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 3161e49..b06dffe 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -508,8 +508,12 @@ static int tbf_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
 
-	if (new == NULL)
-		new = &noop_qdisc;
+	if (new == NULL) {
+		/* reset to default qdisc */
+		new = qdisc_create_dflt(sch->dev_queue, &bfifo_qdisc_ops, sch->parent);
+		if (!new)
+			return -ENOBUFS;
+	}
 
 	*old = qdisc_replace(sch, new, &q->qdisc);
 	return 0;
-- 
Jiri Kosina
SUSE Labs
