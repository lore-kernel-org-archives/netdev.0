From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net v2 2/2] net_sched: fix all the madness of tc filter chain
Date: Thu, 7 Sep 2017 10:45:49 -0700
Message-ID: <CAM_iQpXsYc1cfZmuFKGH1O-FPJr9+NJqZTTB5z1oJVGYgvkV+Q@mail.gmail.com>
References: <20170907042607.24413-1-xiyou.wangcong@gmail.com>
 <20170907042607.24413-2-xiyou.wangcong@gmail.com> <20170907063216.GB1967@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35471 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755484AbdIGRqK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 13:46:10 -0400
Received: by mail-pg0-f66.google.com with SMTP id q68so192721pgq.2
        for <netdev@vger.kernel.org>; Thu, 07 Sep 2017 10:46:09 -0700 (PDT)
In-Reply-To: <20170907063216.GB1967@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 6, 2017 at 11:32 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Thu, Sep 07, 2017 at 06:26:07AM CEST, xiyou.wangcong@gmail.com wrote:
>>This patch fixes the following madness of tc filter chain:
>
> Could you avoid expressive words like "madness" and such?
> Please be technical.
>

If the following 2a) 2b) 2c) 2d) are not enough to show the madness,
I don't know any other to show it. Madness is for code, not for you
or any other person, so 100% technical.

>
>>
>>1) tcf_chain_destroy() is called by both tcf_block_put() and
>>   tcf_chain_put().  tcf_chain_put() is correctly refcnt'ed and paired
>>   with tcf_chain_get(), but tcf_block_put() is not, it should be paired
>>   with tcf_block_get() which means we still need to decrease the refcnt.
>>   Think it in another way: if we call tcf_bock_put() immediately after
>>   tcf_block_get(), could we get effectively a nop? This causes a memory
>>   leak as reported by Jakub.
>>
>>2) tp proto should hold a refcnt to the chain too. This significantly
>>   simplifies the logic:
>>
>>2a) Chain 0 is no longer special, it is created and refcnted by tp
>>    like any other chains. All the ugliness in tcf_chain_put() can be
>>    gone!
>>
>>2b) No need to handle the flushing oddly, because block still holds
>>    chain 0, it can not be released, this guarantees block is the last
>>    user.
>>
>>2c) The race condition with RCU callbacks is easier to handle with just
>>    a rcu_barrier()! Much easier to understand, nothing to hide! Thanks
>>    to the previous patch. Please see also the comments in code.
>>
>>2d) Make the code understandable by humans, much less error-prone.
>>
>>Fixes: 744a4cf63e52 ("net: sched: fix use after free when tcf_chain_destroy is called multiple times")
>>Fixes: 5bc1701881e3 ("net: sched: introduce multichain support for filters")
>>Reported-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>>Cc: Jiri Pirko <jiri@mellanox.com>
>>Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>>---
>> net/sched/cls_api.c | 38 ++++++++++++++++++++++----------------
>> 1 file changed, 22 insertions(+), 16 deletions(-)
>>
>>diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
>>index 6c5ea84d2682..e9060dc36519 100644
>>--- a/net/sched/cls_api.c
>>+++ b/net/sched/cls_api.c
>>@@ -209,21 +209,20 @@ static void tcf_chain_flush(struct tcf_chain *chain)
>>               RCU_INIT_POINTER(*chain->p_filter_chain, NULL);
>>       while ((tp = rtnl_dereference(chain->filter_chain)) != NULL) {
>>               RCU_INIT_POINTER(chain->filter_chain, tp->next);
>>+              tcf_chain_put(chain);
>>               tcf_proto_destroy(tp);
>>       }
>> }
>>
>> static void tcf_chain_destroy(struct tcf_chain *chain)
>> {
>>-      /* May be already removed from the list by the previous call. */
>>-      if (!list_empty(&chain->list))
>>-              list_del_init(&chain->list);
>>+      list_del(&chain->list);
>>+      kfree(chain);
>>+}
>>
>>-      /* There might still be a reference held when we got here from
>>-       * tcf_block_put. Wait for the user to drop reference before free.
>>-       */
>>-      if (!chain->refcnt)
>>-              kfree(chain);
>>+static void tcf_chain_hold(struct tcf_chain *chain)
>>+{
>>+      ++chain->refcnt;
>> }
>>
>> struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index,
>>@@ -233,7 +232,7 @@ struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index,
>>
>>       list_for_each_entry(chain, &block->chain_list, list) {
>>               if (chain->index == chain_index) {
>>-                      chain->refcnt++;
>>+                      tcf_chain_hold(chain);
>>                       return chain;
>>               }
>>       }
>>@@ -246,10 +245,7 @@ EXPORT_SYMBOL(tcf_chain_get);
>>
>> void tcf_chain_put(struct tcf_chain *chain)
>> {
>>-      /* Destroy unused chain, with exception of chain 0, which is the
>>-       * default one and has to be always present.
>>-       */
>>-      if (--chain->refcnt == 0 && !chain->filter_chain && chain->index != 0)
>>+      if (--chain->refcnt == 0)
>
> Okay, so you take the reference for every goto_chain action and every
> tp, right? Note that for chain 0, you hold one more reference (due to
> the creation). That is probably ok as we need chain 0 not to go away
> even if all tps and goto_chain actions are gone.

Yeah, this is the core of the patch.

>
>
>>               tcf_chain_destroy(chain);
>> }
>> EXPORT_SYMBOL(tcf_chain_put);
>>@@ -294,10 +290,18 @@ void tcf_block_put(struct tcf_block *block)
>>       if (!block)
>>               return;
>>
>>-      list_for_each_entry_safe(chain, tmp, &block->chain_list, list) {
>>+      /* Standalone actions are not allowed to jump to any chain, and
>>+       * bound actions should be all removed after flushing. However,
>>+       * filters are destroyed in RCU callbacks, we have to flush and wait
>>+       * for them before releasing this refcnt, otherwise we race with RCU
>>+       * callbacks!!!
>
> Why the "!!!"? Please avoid that. Not necessary at all.


Because we don't have lock here, we have to pay more extra
attention to it. Playing list without lock is like playing fire. I use "!!!" to
draw people's attention when they touch it, perhaps "XXX" is better?


>
>
>>+       */
>>+      list_for_each_entry(chain, &block->chain_list, list)
>>               tcf_chain_flush(chain);
>>-              tcf_chain_destroy(chain);
>>-      }
>>+      rcu_barrier();
>
> This actually tries to fix another bug I discovered yesterday. Good.
>

This on the other hand proves we should make the code clean
and understandable asap, not just wait for net-next.



>
>>+
>>+      list_for_each_entry_safe(chain, tmp, &block->chain_list, list)
>>+              tcf_chain_put(chain);
>
> Which reference are you putting here? For chain 0, that is the original
> reference due to creation from block_get. But how about the other
> chains? If you do flush all in the previous list iteration, they are
> removed there. Also note that they are removed from the list while
> iterating it.


Yes it is for chain 0, because block holds a reference to chain 0 during
creation. Non-0 chains are created with refcnt==1 too but paired with
tcf_chain_put() rather than tcf_block_put(). This is what makes chain 0
not special w.r.t. refcnt.


>
> I believe that you need to add tcf_chain_hold(chain) to the start of the
> previous list iteration to ensure all existing chains will stay, then
> you can put them here.

We don't need it, it is already perfectly paired with tcf_block_get().
Think about the following:

1)
tcf_block_get(...); // create chain 0 with refcnt=1
tcf_block_put(); // no tp, only chain 0 in chain_list
// chain 0 is put, refcnt=0, it is gone

2)
tcf_block_get(); // create chain 0 with refcnt=1
...
tcf_chain_get(11); // create chain 11 with refcnt=1
// one tp is inserted to chain 11, now refcnt==2
// in tc_ctl_tfilter()
tcf_chain_put(11); // paired with above get, refcnt==1
...
tcf_block_put(); // flush chain 11, tp removed, refcnt==0
// put chain 0 too, paired with block get, refcnt == 0
// both chain 0 and chain11 are gone



>
> Did you test this? I believe we need some simple test script.

Of course I did. I verified memleak is gone and tested basic
filters and gact actions with chain 0 and chain 11, everything
works as expected, I also added a printk() to verify the chain
is really gone as soon as all references are gone.

I will contribute my test cases back after I figure out how.
Also net-next is already closed.
