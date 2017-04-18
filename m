From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [Patch net-next v3] net_sched: move the empty tp check from ->destroy()
 to ->delete()
Date: Tue, 18 Apr 2017 19:01:29 +0200
Message-ID: <58F64669.1080608@iogearbox.net>
References: <1492453840-15816-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>, lucasb@mojatatu.com
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41756 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932534AbdDRRBe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 13:01:34 -0400
In-Reply-To: <1492453840-15816-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Cong,

sorry for the late reply. Generally the patch looks good to me, just
a few comments inline:

On 04/17/2017 08:30 PM, Cong Wang wrote:
> Roi reported we could have a race condition where in ->classify() path
> we dereference tp->root and meanwhile a parallel ->destroy() makes it
> a NULL.

Correct.

> This is possible because ->destroy() could be called when deleting
> a filter to check if we are the last one in tp, this tp is still
> linked and visible at that time.
>
> Daniel fixed this in commit d936377414fa
> ("net, sched: respect rcu grace period on cls destruction"), but
> the root cause of this problem is the semantic of ->destroy(), it
> does two things (for non-force case):
>
> 1) check if tp is empty
> 2) if tp is empty we could really destroy it
>
> and its caller, if cares, needs to check its return value to see if
> it is really destroyed. Therefore we can't unlink tp unless we know
> it is empty.
>
> As suggested by Daniel, we could actually move the test logic to ->delete()
> so that we can safely unlink tp after ->delete() tells us the last one is
> just deleted and before ->destroy().
>
> What's more, even we unlink it before ->destroy(), it could still have
> readers since we don't wait for a grace period here, we should not modify
> tp->root in ->destroy() either.

Here seems to be a bit of a mixup in this analysis, imo. The issue
that Roi reported back then was exactly the one that d936377414fa ("net,
sched: respect rcu grace period on cls destruction") fixed, which
affected flower and other classifiers:

     Roi reported a crash in flower where tp->root was NULL in ->classify()
     callbacks. Reason is that in ->destroy() tp->root is set to NULL via
     RCU_INIT_POINTER(). It's problematic for some of the classifiers, because
     this doesn't respect RCU grace period for them, and as a result, still
     outstanding readers from tc_classify() will try to blindly dereference
     a NULL tp->root.

The ->delete() callback was never used by Roi back then, he said that
he just removed the ingress qdisc in his test, which implicitly purges
all cls attached to it via tcf_destroy_chain(). So the above description
with regards to the "root cause" of Roi's reported issue is not correct.

The issue that this patch fixes is an _independent_ race that we found
while auditing the code when looking into Roi's report back then. It
fixes commit 1e052be69d04 ("net_sched: destroy proto tp when all filters
are gone"), which added the RCU_INIT_POINTER() after the tcf_destroy() in
RTM_DELTFILTER case. That part of the description looks good, where you
describe that "[...] we need to move the test logic to ->delete(), so
that we can safely unlink tp after ->delete() tells us the last one is
just deleted and before ->destroy()."

Please also add Fixes tag, so it can be better tracked for backports.

Fixes: 1e052be69d04 ("net_sched: destroy proto tp when all filters are gone")

> Reported-by: Roi Dayan <roid@mellanox.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: John Fastabend <john.fastabend@gmail.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
[...]

> diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
> index 9962090..d388536 100644
> --- a/net/sched/cls_fw.c
> +++ b/net/sched/cls_fw.c
[...]
> @@ -150,17 +144,17 @@ static bool fw_destroy(struct tcf_proto *tp, bool force)
>   			call_rcu(&f->rcu, fw_delete_filter);
>   		}
>   	}
> -	RCU_INIT_POINTER(tp->root, NULL);
>   	kfree_rcu(head, rcu);
> -	return true;
>   }

> diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
> index a371075..8e2baf8 100644
> --- a/net/sched/cls_route.c
> +++ b/net/sched/cls_route.c
> @@ -312,12 +305,10 @@ static bool route4_destroy(struct tcf_proto *tp, bool force)
>   			kfree_rcu(b, rcu);
>   		}
>   	}
> -	RCU_INIT_POINTER(tp->root, NULL);
>   	kfree_rcu(head, rcu);
> -	return true;
>   }

> diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
> index d7f2923..9e3748b 100644
> --- a/net/sched/cls_rsvp.h
> +++ b/net/sched/cls_rsvp.h
> @@ -302,22 +302,13 @@ static void rsvp_delete_filter(struct tcf_proto *tp, struct rsvp_filter *f)
[...]
> -	}
> -
> -	RCU_INIT_POINTER(tp->root, NULL);
> +		return;
>
>   	for (h1 = 0; h1 < 256; h1++) {
>   		struct rsvp_session *s;
> @@ -337,10 +328,9 @@ static bool rsvp_destroy(struct tcf_proto *tp, bool force)
[...]

The above three RCU_INIT_POINTER(tp->root, NULL) are independent
of the fix and actually do no harm right now. I described that in
d936377414fa ("net, sched: respect rcu grace period on cls destruction")
as well, meaning that they each handle tp->root being NULL in ->classify()
path (for historic reasons), so this is handled gracefully, readers use
rcu_dereference_bh(tp->root) and test for this being NULL.

But I agree that this could be cleaned up along with the check in the
->classify() callbacks for these three (not sure if really worth it,
though). However, such cleanup should be a separate patch and not
included in this fix.

Other than the mentioned things, this looks good to me.

Thanks,
Daniel
