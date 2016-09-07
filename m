From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC Patch net-next 0/6] net_sched: really switch to RCU for tc
 actions
Date: Wed, 7 Sep 2016 09:23:17 -0700
Message-ID: <57D03EF5.90602@gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35050 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757137AbcIGQX2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 12:23:28 -0400
Received: by mail-pa0-f67.google.com with SMTP id pp5so1113069pac.2
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 09:23:27 -0700 (PDT)
In-Reply-To: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-01 10:57 PM, Cong Wang wrote:
> Currently there are only two tc actions lockless:
> gact and mirred. But they are questionable because
> we don't have anything to prevent a parallel update
> on an existing tc action in hash table while reading
> it on fast path, this could be a problem when a tc
> action becomes complex.

hmm I'm trying to see where the questionable part is in the current
code? What is it exactly.

The calls to

	 tcf_lastuse_update(&m->tcf_tm);

for example are possibly wrong as that is a u64 may be set from
multiple cores. So fixing that seems like a good idea.

Actions themselves don't have a path to be "updated" while live do they?
iirc and I think a quick scan this morning of the code shows actions
have a refcnt and a "bind"/"release" action that increments/decrements
this counter. Both bind and release are protected via rtnl lock in the
control path.

I need to follow all the code paths but is there a way to remove an
action that still has a refcnt > 0? In other words does it need to be
removed from all filters before it can be deleted. If yes then by the
time it is removed (after rcu grace period) it should not be in use.
If no then I think there is a problem.

I'm looking at this code path here,

int __tcf_hash_release(struct tc_action *p, bool bind, bool strict)
{
        int ret = 0;

        if (p) {
                if (bind)
                        p->tcfa_bindcnt--;
                else if (strict && p->tcfa_bindcnt > 0)
                        return -EPERM;

                p->tcfa_refcnt--;
                if (p->tcfa_bindcnt <= 0 && p->tcfa_refcnt <= 0) {
                        if (p->ops->cleanup)
                                p->ops->cleanup(p, bind);
                        tcf_hash_destroy(p->hinfo, p);
                        ret = ACT_P_DELETED;
                }
        }

        return ret;
}

It looks to me that every call site that jumps here where its possible
an action is being used by a filter is "strict". And further filters
only release actions after an rcu grace period when being destroyed and
the filter is no longer using the action.

Although the refcnt should be atomic now that its being called from
outside the rtnl lock in rcu call back? At least it looks racy to me
at a glance this morning.

If the refcnt'ing is atomic then do we care/need the hash rcu bits? I'm
not seeing how it helps because in the fast path we don't even touch the
hash table we have a pointer to a refcnt'd action object.

What did I miss?

> 
> This patchset introduces a few new tc action API's
> based on RCU so that the fast path could now really
> be protected by RCU and we can update existing tc
> actions safely and race-freely.
> 
> Obviously this is still _not_ complete yet, I only
> modified mirred action to show the use case of
> the new API's, all the rest actions could switch to
> the new API's too. The new API's are a bit ugly too,
> any suggestion to improve them is welcome.
> 
> I tested mirred action with a few test cases, so far
> so good, at least no obvious bugs. ;)

Take a quick survey of the actions I didn't see any with global state.
But I didn't look at them all.

> 
> 
> Cong Wang (6):
>   net_sched: use RCU for action hash table
>   net_sched: introduce tcf_hash_replace()
>   net_sched: return NULL in tcf_hash_check()
>   net_sched: introduce tcf_hash_copy()
>   net_sched: use rcu in fast path
>   net_sched: switch to RCU API for act_mirred
> 
>  include/net/act_api.h  |  3 +++
>  net/sched/act_api.c    | 59 +++++++++++++++++++++++++++++++++++++++++++-------
>  net/sched/act_mirred.c | 41 ++++++++++++++++-------------------
>  3 files changed, 73 insertions(+), 30 deletions(-)
> 
