From: Minoru Usui <usui@mxm.nes.nec.co.jp>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Fri, 29 May 2009 14:18:30 +0900
Message-ID: <20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: containers@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:60111 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbZE2Fq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 01:46:57 -0400
In-Reply-To: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, 

On Thu, 21 May 2009 09:22:56 +0900
Minoru Usui <usui@mxm.nes.nec.co.jp> wrote:

> Hi
> 
> Unfortunately this is only panic report.
> 
> I used cgroup net_cls subsystem, then kernel panic occured.
> I attach panic message and kernel config in this mail's last paragraph.
> If my operation is wrong, could you tell me how to use net_cls and
> where the documentation is. 
> 
> # But I think panic is very bad even if my operation is wrong.

I investigated this problem, and I found a bug in tc_ctl_tfilter() in net/sched/cls_api.c.

When 'tc filter add' command is executed and proto-tcf does not exist, 
tcf_ctl_tfilter() allocates, initializes and chanins proto-tcf(tp) to
cops->tcf_chain()'s chain before calling tp->ops->change().

If tp->ops->change() returns an error, tcf_ctl_tfilter() returns an error
too, but proto-tcf(tp) is not unchained yet. 

I think tcf_ctl_tfilter() shouldn't chain proto-tcf to the chain before it returns
an error.

Signed-off-by: Minoru Usui <usui@mxm.nes.nec.co.jp>

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 0759f32..756148b 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -266,11 +266,6 @@ replay:
 			goto errout;
 		}
 
-		spin_lock_bh(root_lock);
-		tp->next = *back;
-		*back = tp;
-		spin_unlock_bh(root_lock);
-
 	} else if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], tp->ops->kind))
 		goto errout;
 
@@ -314,8 +309,17 @@ replay:
 	}
 
 	err = tp->ops->change(tp, cl, t->tcm_handle, tca, &fh);
-	if (err == 0)
-		tfilter_notify(skb, n, tp, fh, RTM_NEWTFILTER);
+	if (err) {
+		tcf_destroy(tp);
+		goto errout;
+	}
+
+	spin_lock_bh(root_lock);
+	tp->next = *back;
+	*back = tp;
+	spin_unlock_bh(root_lock);
+
+	tfilter_notify(skb, n, tp, fh, RTM_NEWTFILTER);
 
 errout:
 	if (cl)

-- 
Minoru Usui <usui@mxm.nes.nec.co.jp>
