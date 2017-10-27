From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net 01/16] net_sched: introduce a workqueue for RCU
 callbacks of tc filter
Date: Thu, 26 Oct 2017 21:28:01 -0700
Message-ID: <CAM_iQpUB_y5=Pa9z5Vq+Ves9GhT5COXvRbDtRZo2xqxjo__vmw@mail.gmail.com>
References: <20171027012443.3306-1-xiyou.wangcong@gmail.com>
 <20171027012443.3306-2-xiyou.wangcong@gmail.com> <1509077103.11887.23.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Chris Mi <chrism@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>,
        John Fastabend <john.fastabend@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:54327 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750795AbdJ0E2W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 00:28:22 -0400
Received: by mail-pf0-f193.google.com with SMTP id n89so4068870pfk.11
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 21:28:22 -0700 (PDT)
In-Reply-To: <1509077103.11887.23.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 26, 2017 at 9:05 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2017-10-26 at 18:24 -0700, Cong Wang wrote:
>> ...
>
>> On the other hand, this makes tcf_block_put() ugly and
>> harder to understand. Since David and Eric strongly dislike
>> adding synchronize_rcu(), this is probably the only
>> solution that could make everyone happy.
>
>
> ...
>
>> +static void tcf_block_put_deferred(struct work_struct *work)
>> +{
>> +     struct tcf_block *block = container_of(work, struct tcf_block, work);
>> +     struct tcf_chain *chain;
>>
>> +     rtnl_lock();
>>       /* Hold a refcnt for all chains, except 0, in case they are gone. */
>>       list_for_each_entry(chain, &block->chain_list, list)
>>               if (chain->index)
>> @@ -292,13 +308,27 @@ void tcf_block_put(struct tcf_block *block)
>>       list_for_each_entry(chain, &block->chain_list, list)
>>               tcf_chain_flush(chain);
>>
>> -     /* Wait for RCU callbacks to release the reference count. */
>> +     INIT_WORK(&block->work, tcf_block_put_final);
>> +     /* Wait for RCU callbacks to release the reference count and make
>> +      * sure their works have been queued before this.
>> +      */
>>       rcu_barrier();
>> +     tcf_queue_work(&block->work);
>> +     rtnl_unlock();
>> +}
>
>
> On a loaded server, rcu_barrier() typically takes 4 ms.
>
> Way better than synchronize_rcu() (about 90 ms) but still an issue when
> holding RTNL.
>
> We have thousands of filters, and management daemon restarts and rebuild
> TC hierarchy from scratch.
>
> Simply getting rid of 1000 old filters might block RTNL for a while, or
> maybe I misunderstood your patches.
>

Paul pointed out the same.

As I replied, this rcu_barrier() is NOT added by this patchset, it is already
there in current master branch.
