From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net] net_sched: act_mirred: full rcu conversion
Date: Mon, 12 Sep 2016 08:34:47 -0700
Message-ID: <57D6CB17.6030007@gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472795840-31901-6-git-send-email-xiyou.wangcong@gmail.com>
 <1473173528.10725.14.camel@edumazet-glaptop3.roam.corp.google.com>
 <57D0FF87.604@gmail.com>
 <1473341283.15733.33.camel@edumazet-glaptop3.roam.corp.google.com>
 <1473348943.15733.57.camel@edumazet-glaptop3.roam.corp.google.com>
 <57D1881B.6090009@gmail.com>
 <1473349900.15733.59.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpV+ybrM_ebgwX5ZohmKvWZo-8znXkgJv1LhDAC9=3u9Xw@mail.gmail.com>
 <57D2DAD1.5000306@gmail.com>
 <CAM_iQpXycdn9_LW_qYzUe5T97ABOj3KrivjCB5ho9wbKeFR0MQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:32879 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932972AbcILPfC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 11:35:02 -0400
Received: by mail-pa0-f66.google.com with SMTP id h5so7948793pao.0
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 08:35:02 -0700 (PDT)
In-Reply-To: <CAM_iQpXycdn9_LW_qYzUe5T97ABOj3KrivjCB5ho9wbKeFR0MQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-11 11:12 PM, Cong Wang wrote:
> On Fri, Sep 9, 2016 at 8:52 AM, John Fastabend <john.fastabend@gmail.com> wrote:
>> On 16-09-08 10:26 PM, Cong Wang wrote:
>>> On Thu, Sep 8, 2016 at 8:51 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>>> On Thu, 2016-09-08 at 08:47 -0700, John Fastabend wrote:
>>>>
>>>>> Works for me. FWIW I find this plenty straightforward and don't really
>>>>> see the need to make the hash table itself rcu friendly.
>>>>>
>>>>> Acked-by: John Fastabend <john.r.fastabend@intel.com>
>>>>>
>>>>
>>>> Yes, it seems this hash table is used in control path, with RTNL held
>>>> anyway.
>>>
>>> Seriously? You never read hashtable in fast path?? I think you need
>>> to wake up.
>>>
>>
>> But the actions use refcnt'ing and should never be decremented to zero
>> as long as they can still be referenced by an active filter. If each
>> action handles its parameters like mirred/gact then I don't see why its
>> necessary.
> 
> This is correct, by "read" I meant "dereference", the tc actions
> are now permanently stored in hashtable directly, so "reading"
> a tc action is reading from hashtable.
> 
> Sorry if this wasn't clear.
> 

OK, but with the current code there is no need to protect the hash table
with an RCU semantics. The ref counting ensures the hash table entries
are always available and any 'replace' commands on actions are handled
internally in the action itself with rcu_assign_pointer replacing old
params with new params. The fast path readers will always read a
consistent set of parameters in this scheme.

So no need for an rcu hash table. The reference count though should
likely be atomic because not all increments/decrements are protected by
RTNL lock.

.John
