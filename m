From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net] net_sched: remove tcf_block_put_deferred()
Date: Wed, 1 Nov 2017 09:11:06 +0100
Message-ID: <20171101081106.GA1977@nanopsycho.orion>
References: <20171030181009.18340-1-xiyou.wangcong@gmail.com>
 <20171031104043.GH1972@nanopsycho.orion>
 <CAM_iQpUn+Z1DMAYnOuRw81pRPBaQ15q9jN-vH-VyVp_Vg9u9RA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        John Fastabend <john.fastabend@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:44494 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752202AbdKAILK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 04:11:10 -0400
Received: by mail-wm0-f65.google.com with SMTP id n74so15632576wmi.1
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 01:11:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpUn+Z1DMAYnOuRw81pRPBaQ15q9jN-vH-VyVp_Vg9u9RA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 31, 2017 at 10:47:48PM CET, xiyou.wangcong@gmail.com wrote:
>On Tue, Oct 31, 2017 at 3:40 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Mon, Oct 30, 2017 at 07:10:09PM CET, xiyou.wangcong@gmail.com wrote:
>>>In commit 7aa0045dadb6 ("net_sched: introduce a workqueue for RCU callbacks of tc filter")
>>>I defer tcf_chain_flush() to a workqueue, this causes a use-after-free
>>>because qdisc is already destroyed after we queue this work.
>>>
>>>The tcf_block_put_deferred() is no longer necessary after we get RTNL
>>>for each tc filter destroy work, no others could jump in at this point.
>>>Same for tcf_chain_hold(), we are fully serialized now.
>>>
>>>This also reduces one indirection therefore makes the code more
>>>readable. Note this brings back a rcu_barrier(), however comparing
>>>to the code prior to commit 7aa0045dadb6 we still reduced one
>>>rcu_barrier(). For net-next, we can consider to refcnt tcf block to
>>>avoid it.
>>>
>>>Fixes: 7aa0045dadb6 ("net_sched: introduce a workqueue for RCU callbacks of tc filter")
>>>Cc: Daniel Borkmann <daniel@iogearbox.net>
>>>Cc: Jiri Pirko <jiri@resnulli.us>
>>>Cc: John Fastabend <john.fastabend@gmail.com>
>>>Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>>>Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
>>>Cc: Eric Dumazet <edumazet@google.com>
>>>Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>>>---
>>> net/sched/cls_api.c | 37 ++++++++-----------------------------
>>> 1 file changed, 8 insertions(+), 29 deletions(-)
>>>
>>>diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
>>>index 231181c602ed..b2d310745487 100644
>>>--- a/net/sched/cls_api.c
>>>+++ b/net/sched/cls_api.c
>>>@@ -280,8 +280,8 @@ static void tcf_block_put_final(struct work_struct *work)
>>>       struct tcf_block *block = container_of(work, struct tcf_block, work);
>>>       struct tcf_chain *chain, *tmp;
>>>
>>>-      /* At this point, all the chains should have refcnt == 1. */
>>>       rtnl_lock();
>>>+      /* Only chain 0 should be still here. */
>>>       list_for_each_entry_safe(chain, tmp, &block->chain_list, list)
>>>               tcf_chain_put(chain);
>>>       rtnl_unlock();
>>>@@ -289,23 +289,17 @@ static void tcf_block_put_final(struct work_struct *work)
>>> }
>>>
>>> /* XXX: Standalone actions are not allowed to jump to any chain, and bound
>>>- * actions should be all removed after flushing. However, filters are destroyed
>>>- * in RCU callbacks, we have to hold the chains first, otherwise we would
>>>- * always race with RCU callbacks on this list without proper locking.
>>>+ * actions should be all removed after flushing. However, filters are now
>>>+ * destroyed in tc filter workqueue with RTNL lock, they can not race here.
>>>  */
>>>-static void tcf_block_put_deferred(struct work_struct *work)
>>>+void tcf_block_put(struct tcf_block *block)
>>> {
>>>-      struct tcf_block *block = container_of(work, struct tcf_block, work);
>>>-      struct tcf_chain *chain;
>>>+      struct tcf_chain *chain, *tmp;
>>>
>>>-      rtnl_lock();
>>>-      /* Hold a refcnt for all chains, except 0, in case they are gone. */
>>>-      list_for_each_entry(chain, &block->chain_list, list)
>>>-              if (chain->index)
>>>-                      tcf_chain_hold(chain);
>>>+      if (!block)
>>>+              return;
>>>
>>>-      /* No race on the list, because no chain could be destroyed. */
>>>-      list_for_each_entry(chain, &block->chain_list, list)
>>>+      list_for_each_entry_safe(chain, tmp, &block->chain_list, list)
>>>               tcf_chain_flush(chain);
>>
>> The reason for the hold above was to avoid use after free in this loop.
>> Consider following example:
>>
>> chain1
>>   1 filter with action goto_chain 2
>> chain2
>>   empty
>>
>> Now in your list_for_each_entry_safe loop, chain1 is flushed, action is
>> removed and chain is put:
>> tcf_action_goto_chain_fini->tcf_chain_put(2)
>>
>> Given the fact chain2 is empty, this put would lead to tcf_chain_destroy(2)
>>
>> Then in another iteration of list_for_each_entry_safe you are using
>> already freed chain.
>>
>> Am I missing something that prevents this?
>
>Actions are destroyed in filter's ->destroy(), and all filters now
>use RCU callback+workqueue to defer the tcf_action_goto_chain_fini()
>and with RTNL, so this function won't be executed until we release
>RTNL. This is what I mean by "fully serialized".

Ah! I see it now. You did that in the previous patchset. It confused me
that you remove the hold now.

I don't see any issue now. Thanks!
