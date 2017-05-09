From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] ipv4: restore rt->fi for reference counting
Date: Tue, 9 May 2017 09:44:36 -0700
Message-ID: <CAM_iQpWQoLppsMfDOQWsdifGd56CAY24tCNm0Jm02QCe7ZThOw@mail.gmail.com>
References: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com>
 <20170508.143557.105629611489969352.davem@davemloft.net> <1494288080.7796.59.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170508.212211.1291611254198273979.davem@davemloft.net> <1494296302.7796.61.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:34070 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751306AbdEIQo6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 12:44:58 -0400
Received: by mail-lf0-f65.google.com with SMTP id q24so524024lfb.1
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 09:44:57 -0700 (PDT)
In-Reply-To: <1494296302.7796.61.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 8, 2017 at 7:18 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2017-05-08 at 21:22 -0400, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Mon, 08 May 2017 17:01:20 -0700
>>
>> > On Mon, 2017-05-08 at 14:35 -0400, David Miller wrote:
>> >> From: Cong Wang <xiyou.wangcong@gmail.com>
>> >> Date: Thu,  4 May 2017 14:54:17 -0700
>> >>
>> >> > IPv4 dst could use fi->fib_metrics to store metrics but fib_info
>> >> > itself is refcnt'ed, so without taking a refcnt fi and
>> >> > fi->fib_metrics could be freed while dst metrics still points to
>> >> > it. This triggers use-after-free as reported by Andrey twice.
>> >> >
>> >> > This patch reverts commit 2860583fe840 ("ipv4: Kill rt->fi") to
>> >> > restore this reference counting. It is a quick fix for -net and
>> >> > -stable, for -net-next, as Eric suggested, we can consider doing
>> >> > reference counting for metrics itself instead of relying on fib_info.
>> >> >
>> >> > IPv6 is very different, it copies or steals the metrics from mx6_config
>> >> > in fib6_commit_metrics() so probably doesn't need a refcnt.
>> >> >
>> >> > Decnet has already done the refcnt'ing, see dn_fib_semantic_match().
>> >> >
>> >> > Fixes: 2860583fe840 ("ipv4: Kill rt->fi")
>> >> > Reported-by: Andrey Konovalov <andreyknvl@google.com>
>> >> > Tested-by: Andrey Konovalov <andreyknvl@google.com>
>> >> > Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> >>
>> >> Applied and queued up for -stable, thanks.
>> >
>> > Although I now have on latest net tree these messages when I reboot my
>> > test machine.
>> >
>> > [  224.085873] unregister_netdevice: waiting for eth0 to become free. Usage count = 43
>>
>> Strange, the refcounting looks quite OK in the patch you're quoting.
>> I looked over it a few times and cannot figure out a possible cause
>> there.


Eric, how did you produce it?
I guess it's because of nh_dev which is the only netdevice pointer inside
fib_info. Let me take a deeper look.

>>
>> I am assuming you are quite confident it is this change?
>
> At least, reverting the patch resolves the issue for me.
>
> Keeping fib (and their reference to netdev) is apparently too much,
> we probably need to implement a refcount on the metrics themselves,
> being stand alone objects.

I don't disagree, just that it may need to change too much code which
goes beyond a stable candidate.

Thanks for the bug report!
