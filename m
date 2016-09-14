From: Michael Ma <make0818@gmail.com>
Subject: Re: Modification to skb->queue_mapping affecting performance
Date: Tue, 13 Sep 2016 22:19:05 -0700
Message-ID: <CAAmHdhzfSP+b+XCaHh=bA--_=Wk=ui3-9Z9idWUpQqJiYJ5=Ew@mail.gmail.com>
References: <CAAmHdhxyrwJXHysUU6KoXeTaRHK8Mxr5PH9j4drR_87T+Wnypg@mail.gmail.com>
 <1473808021.18970.246.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAAmHdhw6JXYtYNjcJchieW-KcwRkNnFmXTRTXrLQS_Kh+rfP2w@mail.gmail.com>
 <1473811749.18970.259.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAAmHdhy_=GJKBE9=YD2n8MZOaBzD_JJrk4i8Rq43ob2HbWqbCA@mail.gmail.com>
 <1473815917.18970.266.camel@edumazet-glaptop3.roam.corp.google.com> <CAAmHdhxGBBOCebkvq43pwsaZ8HcULZmXnikQAtc2uLBMWZgXjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:32964 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752470AbcINFTH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 01:19:07 -0400
Received: by mail-it0-f46.google.com with SMTP id x192so3904501itb.0
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 22:19:07 -0700 (PDT)
In-Reply-To: <CAAmHdhxGBBOCebkvq43pwsaZ8HcULZmXnikQAtc2uLBMWZgXjA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-09-13 22:13 GMT-07:00 Michael Ma <make0818@gmail.com>:
> 2016-09-13 18:18 GMT-07:00 Eric Dumazet <eric.dumazet@gmail.com>:
>> On Tue, 2016-09-13 at 17:23 -0700, Michael Ma wrote:
>>
>>> If I understand correctly this is still to associate a qdisc with each
>>> ifb TXQ. How should I do this if I want to use HTB? I guess I'll need
>>> to divide the bandwidth of each class in HTB by the number of TX
>>> queues for each individual HTB qdisc associated?
>>>
>>> My original idea was to attach a HTB qdisc for each ifb queue
>>> representing a set of flows not sharing bandwidth with others so that
>>> root lock contention still happens but only affects flows in the same
>>> HTB. Did I understand the root lock contention issue incorrectly for
>>> ifb? I do see some comments in __dev_queue_xmit() about using a
>>> different code path for software devices which bypasses
>>> __dev_xmit_skb(). Does this mean ifb won't go through
>>> __dev_xmit_skb()?
>>
>> You can install HTB on all of your MQ children for sure.
>>
>> Again, there is no qdisc lock contention if you properly use MQ.
>>
>> Now if you _need_ to install a single qdisc for whatever reason, then
>> maybe you want to use a single rx queue on the NIC, to reduce lock
>> contention ;)

Yes - this might reduce lock contention but there would still be
contention and I'm really looking for more concurrency...

>>
>>
> I don't intend to install multiple qdisc - the only reason that I'm
> doing this now is to leverage MQ to workaround the lock contention,
> and based on the profile this all worked. However to simplify the way
> to setup HTB I wanted to use TXQ to partition HTB classes so that a
> HTB class only belongs to one TXQ, which also requires mapping skb to
> TXQ using some rules (here I'm using priority but I assume it's
> straightforward to use other information such as classid). And the
> problem I found here is that when using priority to infer the TXQ so
> that queue_mapping is changed, bandwidth is affected significantly -
> the only thing I can guess is that due to queue switch, there are more
> cache misses assuming processor cores have a static mapping to all the
> queues. Any suggestion on what to do next for the investigation?
>
> I would also guess that this should be a common problem if anyone
> wants to use MQ+IFB to workaround the qdisc lock contention on the
> receiver side and classful qdisc is used on IFB, but haven't really
> found a similar thread here...

Hi Cong - I saw quite some threads from you regarding to ingress qdisc
+ MQ and issues for queue_mapping. Do you by any chance have a similar
setup? (classful qdiscs associated to the queues of IFB which requires
queue_mapping modification so that the qdisc selection is done at
queue selection time based on information such as skb
priority/classid. Would appreciate any suggestions.
