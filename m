From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH] net: sched: lock imbalance in hhf qdisc
Date: Thu, 01 May 2014 08:30:22 -0700
Message-ID: <1398958222.29914.195.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140501151542.3649.8824.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, vtlam@google.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:33306 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752140AbaEAPaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 11:30:30 -0400
Received: by mail-oa0-f54.google.com with SMTP id i7so3766053oag.13
        for <netdev@vger.kernel.org>; Thu, 01 May 2014 08:30:29 -0700 (PDT)
In-Reply-To: <20140501151542.3649.8824.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-05-01 at 08:15 -0700, John Fastabend wrote:
> hhf_change() takes the sch_tree_lock and releases it but misses the error
> cases. Fix the missed case here.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  net/sched/sch_hhf.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
> index edee03d..1803f89 100644
> --- a/net/sched/sch_hhf.c
> +++ b/net/sched/sch_hhf.c
> @@ -565,8 +565,10 @@ static int hhf_change(struct Qdisc *sch, struct nlattr *opt)
>  		new_hhf_non_hh_weight = nla_get_u32(tb[TCA_HHF_NON_HH_WEIGHT]);
>  
>  	non_hh_quantum = (u64)new_quantum * new_hhf_non_hh_weight;
> -	if (non_hh_quantum > INT_MAX)
> +	if (non_hh_quantum > INT_MAX) {
> +		sch_tree_unlock(sch);
>  		return -EINVAL;
> +	}
>  	q->quantum = new_quantum;
>  	q->hhf_non_hh_weight = new_hhf_non_hh_weight;
>  

Good catch, could you refactor a bit more to do all checks before any
change ?

diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index edee03d922e2..6e957c3b9854 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -553,11 +553,6 @@ static int hhf_change(struct Qdisc *sch, struct nlattr *opt)
 	if (err < 0)
 		return err;
 
-	sch_tree_lock(sch);
-
-	if (tb[TCA_HHF_BACKLOG_LIMIT])
-		sch->limit = nla_get_u32(tb[TCA_HHF_BACKLOG_LIMIT]);
-
 	if (tb[TCA_HHF_QUANTUM])
 		new_quantum = nla_get_u32(tb[TCA_HHF_QUANTUM]);
 
@@ -567,6 +562,12 @@ static int hhf_change(struct Qdisc *sch, struct nlattr *opt)
 	non_hh_quantum = (u64)new_quantum * new_hhf_non_hh_weight;
 	if (non_hh_quantum > INT_MAX)
 		return -EINVAL;
+
+	sch_tree_lock(sch);
+
+	if (tb[TCA_HHF_BACKLOG_LIMIT])
+		sch->limit = nla_get_u32(tb[TCA_HHF_BACKLOG_LIMIT]);
+
 	q->quantum = new_quantum;
 	q->hhf_non_hh_weight = new_hhf_non_hh_weight;
 
