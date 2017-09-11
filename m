From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net v2 2/2] net_sched: fix all the madness of tc filter chain
Date: Mon, 11 Sep 2017 14:14:54 -0700
Message-ID: <CAM_iQpV2p25iZg7sd7jpcN0nuAPmwVUa3-J8F_oGC26aTTPtWw@mail.gmail.com>
References: <20170907042607.24413-1-xiyou.wangcong@gmail.com>
 <20170907042607.24413-2-xiyou.wangcong@gmail.com> <20170907063216.GB1967@nanopsycho>
 <CAM_iQpXsYc1cfZmuFKGH1O-FPJr9+NJqZTTB5z1oJVGYgvkV+Q@mail.gmail.com>
 <20170907205239.GF1967@nanopsycho> <CAM_iQpUJLfkq0ys3XNchPVXBpF4yoNaBG_L7UjiSMW7_9NyYaQ@mail.gmail.com>
 <20170910143300.GB1860@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36746 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751483AbdIKVPP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 17:15:15 -0400
Received: by mail-pf0-f181.google.com with SMTP id e199so15707330pfh.3
        for <netdev@vger.kernel.org>; Mon, 11 Sep 2017 14:15:15 -0700 (PDT)
In-Reply-To: <20170910143300.GB1860@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 10, 2017 at 7:33 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Fri, Sep 08, 2017 at 06:37:55PM CEST, xiyou.wangcong@gmail.com wrote:
>>On Thu, Sep 7, 2017 at 1:52 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> Thu, Sep 07, 2017 at 07:45:49PM CEST, xiyou.wangcong@gmail.com wrote:
>>>>Yes it is for chain 0, because block holds a reference to chain 0 during
>>>>creation. Non-0 chains are created with refcnt==1 too but paired with
>>>>tcf_chain_put() rather than tcf_block_put(). This is what makes chain 0
>>>>not special w.r.t. refcnt.
>>>
>>> So you need to tcf_chain_put only chain 0 here, right? The rest of the
>>> chains get destroyed by the previous list_for_each_entry iteration when
>>> flush happens and actions destroy happens what decrements recnt to 0
>>> there.
>>
>>
>>This is correct. And it should be only chain 0 after flush.
>>
>>>
>>> What do I miss, who would still hold reference for non-0 chains when all
>>> tps and all goto_chain actions are gone?
>>
>>No one. This is totally correct and is exactly what this patch intends to do.
>>
>>Look, this is why we never need an object with refcnt==0 to exist. ;)
>
> So, I understand that correctly, good. But this is a problem.
>
> When you do:
>        list_for_each_entry(chain, &block->chain_list, list)
>                 tcf_chain_flush(chain);
>
> The reference may get dropped for chains to 0 (for those that does not
> have a goto_chain action holding a ref), and therefore they get freed
> within the loop. That is problematic when you do the traversing of the
> list. You may use list_for_each_entry_safe, but there is another issue:
>
> As a part of tcf_chain_flush destruction, act goto_chain destruction may
> get scheduled by call_rcu. That may be the last reference held for the
> chain. So you race between this loop and rcu callback.
>
> Consider following example:
>
> chain0  - has only one rule with goto_chain 22 action
> chain22 - no rule (refcnt 1 because of the action mentioned above)
>
>          CPU0                            CPU1
>
>     tcf_chain_flush(0)
>                -> call_rcu(free_tcf)
>                                           free_tcf
>                                              ->tcf_chain_put(22)
>                                                  ->tcf_chain_destroy(22)
>                                                      ->kfree(22)


Looks like all due to the lack of locking on block->chain_list.
I thought the rcu_barrier() could properly handle this,
but seems still not, probably I need to move it in the loop,
I am still not 100% sure if it is totally safe with
list_for_each_safe():


-       list_for_each_entry(chain, &block->chain_list, list)
+       list_for_each_entry_safe(chain, tmp, &block->chain_list, list) {
                tcf_chain_flush(chain);
-       rcu_barrier();
+               rcu_barrier(); // are we safe now???
+       }


>     tcf_chain_flush(22)...use-after-free
>

Same race could happen with your code too, right?
chain 22 still has refcnt==1 so chain_put() will destroy
it in flush() too. So this is not a regression.

I know you have list_for_each_safe() but you lack of
rcu_barrier(). This is why I said the lack of locking is
the cause, not your code or my code.


>
> So what I suggest in order to prevent this is to change your code to
> something like:
>
>         /* To avoid race between getting reference in the next loop and
>          * rcu callbacks from deleleted actions freeing the chain.
>          */
>         rcu_barrier();
>
>         list_for_each_entry(chain, &block->chain_list, list)
>                 if (chain->index) /* we already hold ref to chain 0 */
>                         tcf_chain_hold(chain);
>
>         list_for_each_entry(chain, &block->chain_list, list)
>                 tcf_chain_flush(chain);
>
>         /* Wait for rcu callbacks from deleleted actions that were
>          * sheduled as a result of tcf_chain_flush in the previous loop.
>          * This is not absolutelly necessary, as the chain may live after
>          * the tcf_chain_put is called in the next iteration and would
>          * get freed on tcf_chain_put call from rcu callback later on.
>          */
>         rcu_barrier();
>
>         /* Now we are sure that we are the only one holding a reference
>          * to all chains, drop it and let them go.
>          */
>         list_for_each_entry_safe(chain, tmp, &block->chain_list, list)
>                 tcf_chain_put(chain);
>         kfree(block);
>
> Does this make sense?

Yeah, but again this is all due to lack of locking. Do we really
have to to be such complex or just use either a) proper sync
with rcu_barrier() or b) proper locking on chain_list (with RCU
of course)?

Thanks.
