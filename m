From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] ipv4: igmp: fix a use after free
Date: Sat, 10 Jun 2017 02:05:42 +0800
Message-ID: <CADvbK_fbxdkZUdJK=qUx+neTNfiOUJrm3-AvBa2+a4eB1b+PWA@mail.gmail.com>
References: <CAAeHK+xmSxokDidhzP1VWgmbbwege4OaGvOA4PwTP1scs6J5zA@mail.gmail.com>
 <1496929425.736.73.camel@edumazet-glaptop3.roam.corp.google.com>
 <CADvbK_fWOFWZxKc8gbzeDeU1ALq5GHxKvoGsPt+GsdAP0a601w@mail.gmail.com>
 <1496954011.736.86.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpVu+sF4zGhGCYDV6J-+rN69zuMGGvGJpLajhYS-QfdUfQ@mail.gmail.com>
 <CADvbK_cv+yfZpa7y1+5a9mntTbkTmEu6YyR7pbHGAtH+5+RLRA@mail.gmail.com>
 <1497023774.736.92.camel@edumazet-glaptop3.roam.corp.google.com> <CAM_iQpVcLiE3ru1ukq9CCTvTN_+-77XapOWT=1EgF0DgB224-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:34866 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751554AbdFISFo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 14:05:44 -0400
Received: by mail-qt0-f193.google.com with SMTP id x58so16693968qtc.2
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 11:05:44 -0700 (PDT)
In-Reply-To: <CAM_iQpVcLiE3ru1ukq9CCTvTN_+-77XapOWT=1EgF0DgB224-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 10, 2017 at 1:01 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:

> On Fri, Jun 9, 2017 at 8:56 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Fri, 2017-06-09 at 14:24 +0800, Xin Long wrote:
>>> On Fri, Jun 9, 2017 at 8:59 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>>
>>> > On Thu, Jun 8, 2017 at 1:33 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> >> I mentioned (in https://lkml.org/lkml/2017/5/31/619 ) that we might need
>>> >> to defer freeing after rcu grace period but for some reason decided it
>>> >> was not needed.
>>> Yes, this one could fix it.
>>>
>>> >
>>> > This one makes sense, it is the second time I saw the use-after-free
>>> > in igmp code, both are because we don't respect the RCU rule to free
>>> > an element in the list.
>>> >
>>> >>
>>> >> What about :
>>> >
>>> > But not sure if all ip_ma_put() callers want ip_mc_clear_src().
>>> If that's problem, there may be another way:
>>>
>>>   leave ip_mc_clear_src as it is, just add pmc->lock to protect this call.
>>>
>>> this use-after-free was actually caused by using pmc->sources/tomb
>>> in add_grec while ip_mc_clear_src is freeing them. add_grec is already
>>> under pmc->lock, so to add pmc->lock for ip_mc_clear_src should be
>>> enough to protect the list pmc->sources/tomb.
>>>
>>> wdyt ?
>>
>> This would we weird.
>>
>> When we free skb components, we do not grab a spinlock.
>>
>> When we free something, just make sure we must be the last user of it.
>>
>> RCU rules -> Must respect RCU grace period before delete.
>>
>> No need for extra spinlock.
>
> This is what I thought in my first response, until I realized
> it is not pure RCU, otherwise pmc->lock should not be taken
> in igmpv3_send_cr(). It seems the code is mixing the use
> of spinlock and RCU.
rcu lock is for pmc not being freed, and spinlock is for pmc's
members' modification. is there some rule these two locks
should be mixed?


>
> We need RCU anyway, ip_check_mc_rcu() is the real fast
> path where we don't take spinlock. I think we will need more
> work.
It seems all add_grec() callings needs spinlock, maybe  add_grec
modifies pmc's member. it's hard to drop spinlock.

from ip_check_mc_rcu you mentioned about, it should be right
to call ip_mc_clear_src after rcu grace period, like Eric's patch.
