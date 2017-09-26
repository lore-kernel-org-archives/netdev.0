From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: [RESEND] Re: usb/net/p54: trying to register non-static key in p54_unregister_leds
Date: Tue, 26 Sep 2017 17:06:31 +0200
Message-ID: <CAAeHK+zsRJcUVDUASBLBb9QyT9BgTevEe4SKkWPMqRKCMXbS8A@mail.gmail.com>
References: <CAAeHK+xPoNn7i5xOzEqHX6tfDpmpb1rd0hcAxZpTHKi6B8xzsw@mail.gmail.com>
 <1505937307.3026.20.camel@sipsolutions.net> <CAAeHK+wWRZuCDNhoZJ0ACDhiNQw8tVRp2HW0j1EDH0HOe523xA@mail.gmail.com>
 <2589427.Vd4nrgaY4N@debian64>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Johannes Berg <johannes@sipsolutions.net>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        Stephen Boyd <sboyd@codeaurora.org>, Tejun Heo <tj@kernel.org>,
        Yong Zhang <yong.zhang0@gmail.com>
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:52285 "EHLO
        mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031204AbdIZPGc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 11:06:32 -0400
Received: by mail-oi0-f43.google.com with SMTP id p126so12312518oih.9
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 08:06:32 -0700 (PDT)
In-Reply-To: <2589427.Vd4nrgaY4N@debian64>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 23, 2017 at 9:37 PM, 'Christian Lamparter' via syzkaller
<syzkaller@googlegroups.com> wrote:
> This got rejected by gmail once. Let's see if it works now.
>
> On Thursday, September 21, 2017 8:22:45 PM CEST Andrey Konovalov wrote:
>> On Wed, Sep 20, 2017 at 9:55 PM, Johannes Berg
>> <johannes@sipsolutions.net> wrote:
>> > On Wed, 2017-09-20 at 21:27 +0200, Christian Lamparter wrote:
>> >
>> >> It seems this is caused as a result of:
>> >>     -> lock_map_acquire(&work->lockdep_map);
>> >>           lock_map_release(&work->lockdep_map);
>> >>
>> >>     in flush_work() [0]
>> >
>> > Agree.
>> >
>> >> This was added by:
>> >>
>> >>       commit 0976dfc1d0cd80a4e9dfaf87bd8744612bde475a
>> >>       Author: Stephen Boyd <sboyd@codeaurora.org>
>> >>       Date:   Fri Apr 20 17:28:50 2012 -0700
>> >>
>> >>       workqueue: Catch more locking problems with flush_work()
>> >
>> > Yes, but that doesn't matter.
>> >
>> >> Looking at the Stephen's patch, it's clear that it was made
>> >> with "static DECLARE_WORK(work, my_work)" in mind. However
>> >> p54's led_work is "per-device", hence it is stored in the
>> >> devices context p54_common, which is dynamically allocated.
>> >> So, maybe revert Stephen's patch?
>> >
>> > I disagree - as the lockdep warning says:
>> >
>> >> > INFO: trying to register non-static key.
>> >> > the code is fine but needs lockdep annotation.
>> >> > turning off the locking correctness validator.
>> >
>> > What it needs is to actually correctly go through initializing the work
>> > at least once.
>> >
>> > Without more information, I can't really say what's going on, but I
>> > assume that something is failing and p54_unregister_leds() is getting
>> > invoked without p54_init_leds() having been invoked, so essentially
>> > it's trying to flush a work that was never initialized?
>> >
>> > INIT_DELAYED_WORK() does, after all, initialize the lockdep map
>> > properly via __INIT_WORK().
>
> Ok, thanks. This does indeed explain it.
>
> But this also begs the question: Is this really working then?
> From what I can tell, if CONFIG_LOCKDEP is not set then there's no BUG
> no WARN, no other splat or any other odd system behaviour. Does
> [cancel | flush]_[delayed_]work[_sync] really "just work" by *accident*,
> as long the delayed_work | work_struct is zeroed out?
> And should it work in the future as well?
>
>> Since I'm able to reproduce this, please let me know if you need me to
>> collect some debug traces to help with the triage.
>
> Do you want to take a shot at making a patch too? At a quick glance, it
> should be enough to move the [#ifdef CONFIG_P54_LEDS ... #endif] block
> in p54_unregister_common() into the if (priv->registered) { block
> (preferably before the ieee80211_unregister_hw(dev).

Just mailed a patch.

>
> Regards,
> Christian
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.
