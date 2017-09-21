From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: usb/net/p54: trying to register non-static key in p54_unregister_leds
Date: Thu, 21 Sep 2017 20:22:45 +0200
Message-ID: <CAAeHK+wWRZuCDNhoZJ0ACDhiNQw8tVRp2HW0j1EDH0HOe523xA@mail.gmail.com>
References: <CAAeHK+xPoNn7i5xOzEqHX6tfDpmpb1rd0hcAxZpTHKi6B8xzsw@mail.gmail.com>
 <2277141.bYDD1vAb9W@debian64> <1505937307.3026.20.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Christian Lamparter <chunkeey@googlemail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        Stephen Boyd <sboyd@codeaurora.org>, Tejun Heo <tj@kernel.org>,
        Yong Zhang <yong.zhang0@gmail.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505937307.3026.20.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 20, 2017 at 9:55 PM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> On Wed, 2017-09-20 at 21:27 +0200, Christian Lamparter wrote:
>
>> It seems this is caused as a result of:
>>     -> lock_map_acquire(&work->lockdep_map);
>>           lock_map_release(&work->lockdep_map);
>>
>>     in flush_work() [0]
>
> Agree.
>
>> This was added by:
>>
>>       commit 0976dfc1d0cd80a4e9dfaf87bd8744612bde475a
>>       Author: Stephen Boyd <sboyd@codeaurora.org>
>>       Date:   Fri Apr 20 17:28:50 2012 -0700
>>
>>       workqueue: Catch more locking problems with flush_work()
>
> Yes, but that doesn't matter.
>
>> Looking at the Stephen's patch, it's clear that it was made
>> with "static DECLARE_WORK(work, my_work)" in mind. However
>> p54's led_work is "per-device", hence it is stored in the
>> devices context p54_common, which is dynamically allocated.
>> So, maybe revert Stephen's patch?
>
> I disagree - as the lockdep warning says:
>
>> > INFO: trying to register non-static key.
>> > the code is fine but needs lockdep annotation.
>> > turning off the locking correctness validator.
>
> What it needs is to actually correctly go through initializing the work
> at least once.
>
> Without more information, I can't really say what's going on, but I
> assume that something is failing and p54_unregister_leds() is getting
> invoked without p54_init_leds() having been invoked, so essentially
> it's trying to flush a work that was never initialized?
>
> INIT_DELAYED_WORK() does, after all, initialize the lockdep map
> properly via __INIT_WORK().

Since I'm able to reproduce this, please let me know if you need me to
collect some debug traces to help with the triage.

Thanks!

>
> johannes
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.
