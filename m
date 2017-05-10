From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] ipv4: restore rt->fi for reference counting
Date: Wed, 10 May 2017 10:00:37 -0700
Message-ID: <CAM_iQpX22qTqo4yfM_Je1bvJHxjAGK_tvm5KgQSnJzsYq7K55Q@mail.gmail.com>
References: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com>
 <20170508.143557.105629611489969352.davem@davemloft.net> <1494288080.7796.59.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170508.212211.1291611254198273979.davem@davemloft.net> <1494296302.7796.61.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpWQoLppsMfDOQWsdifGd56CAY24tCNm0Jm02QCe7ZThOw@mail.gmail.com>
 <1494348962.7796.88.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpXADa6AyQ3X-EbmRPGCQArgPWygvHMYgWtfUYV082oF3Q@mail.gmail.com>
 <CAM_iQpVhdzeen+ZJ3jyK7Qb=yVuoRSZ7BFB3RoVMShY8KPBTZA@mail.gmail.com>
 <1494370367.7796.92.camel@edumazet-glaptop3.roam.corp.google.com>
 <1494370451.7796.93.camel@edumazet-glaptop3.roam.corp.google.com>
 <1494371348.7796.95.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpU+fXO7eFroAYMv6vqDzCK_ZYXjrTPAMfoDR2BDqaK9rQ@mail.gmail.com> <alpine.LFD.2.20.1705100937330.1938@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36762 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753133AbdEJRA7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 13:00:59 -0400
Received: by mail-wm0-f67.google.com with SMTP id u65so1115962wmu.3
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 10:00:58 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.20.1705100937330.1938@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 10, 2017 at 12:38 AM, Julian Anastasov <ja@ssi.bg> wrote:
>
>         Hello,
>
> On Tue, 9 May 2017, Cong Wang wrote:
>
>> > Also setting nexthop_nh->nh_dev to NULL looks quite dangerous
>> >
>> > We have plenty of sites doing :
>> >
>> > if (fi->fib_dev)
>> >     x = fi->fib_dev->field
>> >
>> > fib_route_seq_show() is one example.
>> >
>>
>> All of them take RCU read lock, so, as I explained in the code comment,
>> they all should be fine because of synchronize_net() on unregister path.
>> Do you see anything otherwise?
>
>         During NETDEV_UNREGISTER packets for dev should not
> be flying but packets for other devs can walk the nexthops
> for multipath routes. It is the rcu_barrier before
> NETDEV_UNREGISTER_FINAL that allows nh_dev to be set to NULL
> during this grace period but there are many places to fix that
> assume nh_dev!=NULL.

Excellent point. Unfortunately NETDEV_UNREGISTER_FINAL is not
yet captured by the fib event notifier.

I think readers are still safe to assume nh_dev!=NULL since we wait
for existing readers, readers coming later can't see it any more. Or
am I missing anything?

>
>         But why we leak routes? Is there some place that holds
> routes without listening for NETDEV_UNREGISTER? On fib_flush
> the infos are unlinked from trees, so after a grace period packets
> should not see/hold such infos. If we hold routes somewhere for
> long time, problem can happen also for routes with single nexthop.

My theory is that dst which holds a refcnt to fib_info (of course, after
this patch) is moved in GC after NETDEV_UNREGISTER but still
referenced somewhere, it therefore holds these nh_dev's, which
in turn hold back to the netdevice which is being unregistered, thus
Eric saw these refcnt leak warnings.

I am not sure if sitting in GC for a long time is problematic or not,
but from the code where we transfer dst->dev to loopback_dev,
it seems this is expected otherwise no need to transfer? But I don't
dig the history though.

Thanks.
