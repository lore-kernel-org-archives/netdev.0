From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: Re: [PATCH 1/2] net_sched: call qlen_notify only if child qdisc is
 empty
Date: Wed, 16 Aug 2017 20:32:22 +0300
Message-ID: <76cee262-9616-fc4b-6dda-5651905ec33d@yandex-team.ru>
References: <150280439968.717891.6476652519937001709.stgit@buzz>
 <CAM_iQpWmJsMWrqoA3h1eLkssaMXOc6kbsj75S9mdSokFKunumw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Jiri Kosina <jkosina@suse.cz>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forwardcorp1o.cmail.yandex.net ([37.9.109.47]:49658 "EHLO
        forwardcorp1o.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751640AbdHPRc3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 13:32:29 -0400
In-Reply-To: <CAM_iQpWmJsMWrqoA3h1eLkssaMXOc6kbsj75S9mdSokFKunumw@mail.gmail.com>
Content-Language: ru-RU
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 16.08.2017 20:22, Cong Wang wrote:
> On Tue, Aug 15, 2017 at 6:39 AM, Konstantin Khlebnikov
> <khlebnikov@yandex-team.ru> wrote:
>> This callback is used for deactivating class in parent qdisc.
>> This is cheaper to test queue length right here.
>>
>> Also this allows to catch draining screwed backlog and prevent
>> second deactivation of already inactive parent class which will
>> crash kernel for sure. Kernel with print warning at destruction
>> of child qdisc where no packets but backlog is not zero.
> 
> Good cleanup. Please explicitly mark patches like this as
> for net-next.
> 
> Just one comment below.
> 
> 
>> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
>> index bd24a550e0f9..18da45c0769c 100644
>> --- a/net/sched/sch_api.c
>> +++ b/net/sched/sch_api.c
>> @@ -752,6 +752,7 @@ void qdisc_tree_reduce_backlog(struct Qdisc *sch, unsigned int n,
>>          const struct Qdisc_class_ops *cops;
>>          unsigned long cl;
>>          u32 parentid;
>> +       bool notify;
>>          int drops;
>>
>>          if (n == 0 && len == 0)
>> @@ -764,6 +765,13 @@ void qdisc_tree_reduce_backlog(struct Qdisc *sch, unsigned int n,
>>
>>                  if (sch->flags & TCQ_F_NOPARENT)
>>                          break;
>> +               /* Notify parent qdisc only if child qdisc becomes empty.
>> +                *
>> +                * If child was empty even before update then backlog
>> +                * counter is screwed and we skip notification because
>> +                * parent class is already passive.
>> +                */
>> +               notify = !sch->q.qlen && !WARN_ON_ONCE(!n);
> 
> Since 'n' never changes in this function, can we just move
> this WARN_ON_ONCE() right before the loop??
> 

Here warning evaluated only if qlen is zero.
'n' could be zero not together with non-zero 'len' and zero 'qlen'.
This means queue already was empty before reduce but caller somehow reduced it even further.
