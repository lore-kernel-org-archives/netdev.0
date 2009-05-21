From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] cls_cgroup: read classid atomically in classifier
Date: Thu, 21 May 2009 21:44:48 +0200
Message-ID: <20090521194447.GA3388@psychotron.englab.brq.redhat.com>
References: <20090521183100.12678.28835.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lizf@cn.fujitsu.com, akpm@linux-foundation.org,
	davem@davemloft.net, tgraf@suug.ch, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Menage <menage@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:56224 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753362AbZEUTri (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2009 15:47:38 -0400
Content-Disposition: inline
In-Reply-To: <20090521183100.12678.28835.stgit@menage.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, May 21, 2009 at 08:31:26PM CEST, menage@google.com wrote:
>cls_cgroup: read classid atomically in classifier
>
>Avoid reading the unsynchronized value cs->classid multiple times,
>since it could change concurrently from non-zero to zero; this would
>result in the classifier returning a positive result with a bogus
>(zero) classid.
>
>Signed-off-by: Paul Menage <menage@google.com>
>Reviewed-by: Li Zefan <lizf@cn.fujitsu.com>
>
>---
>
>Resending to cc netdev@vger.kernel.org as requested by DaveM
>
> net/sched/cls_cgroup.c |   22 +++++++++++-----------
> 1 files changed, 11 insertions(+), 11 deletions(-)
>
>diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
>index 1ab4542..4ece6e0 100644
>--- a/net/sched/cls_cgroup.c
>+++ b/net/sched/cls_cgroup.c
>@@ -98,8 +98,7 @@ static int cls_cgroup_classify(struct sk_buff *skb, struct tcf_proto *tp,
> 			       struct tcf_result *res)
> {
> 	struct cls_cgroup_head *head = tp->root;
>-	struct cgroup_cls_state *cs;
>-	int ret = 0;
>+        u32 classid;
  ^^^^^^^^ How about using TAB instead?
> 
> 	/*
> 	 * Due to the nature of the classifier it is required to ignore all
>@@ -115,17 +114,18 @@ static int cls_cgroup_classify(struct sk_buff *skb, struct tcf_proto *tp,
> 		return -1;
> 
> 	rcu_read_lock();
>-	cs = task_cls_state(current);
>-	if (cs->classid && tcf_em_tree_match(skb, &head->ematches, NULL)) {
>-		res->classid = cs->classid;
>-		res->class = 0;
>-		ret = tcf_exts_exec(skb, &head->exts, res);
>-	} else
>-		ret = -1;
>-
>+	classid = task_cls_state(current)->classid;
> 	rcu_read_unlock();
> 
>-	return ret;
>+	if (!classid)
>+		return -1;
>+
>+	if (!tcf_em_tree_match(skb, &head->ematches, NULL))
>+		return -1;
>+
>+	res->classid = classid;
>+	res->class = 0;
>+	return tcf_exts_exec(skb, &head->exts, res);
> }
> 
> static unsigned long cls_cgroup_get(struct tcf_proto *tp, u32 handle)
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
