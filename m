From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net, sched: fix soft lockup in tc_classify
Date: Fri, 23 Dec 2016 23:34:20 -0800
Message-ID: <CAM_iQpX2X-WHbf1VxfQzh_-YUEqk=o6B+uYfYhj_45jJGaFSfQ@mail.gmail.com>
References: <1954223e8b7aa90ff835357e8a3ef7537be33e43.1482337600.git.daniel@iogearbox.net>
 <CAM_iQpXadrGWJYqizEkq+xmMKVV9krrcCWKur=ZCRZBS9Mx_8w@mail.gmail.com>
 <CAM_iQpX3Sk_YGDmvY-yj0CxPbG5qfT7P7ioNgY5Lb_DqsTWh6Q@mail.gmail.com>
 <585ADFEB.3030206@iogearbox.net> <CAM_iQpUEUmJpjQYV7HV+4NVtGe6D-yZs6=YizcDtf7dogkNR0Q@mail.gmail.com>
 <585AEF24.4070800@iogearbox.net> <CAM_iQpW9Ly+fMEiBtHq4XwUgvt89-5uE2Bwdw1FXJGV3=eY1ZA@mail.gmail.com>
 <585C6F49.5030900@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Shahar Klein <shahark@mellanox.com>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Roi Dayan <roid@mellanox.com>, Jiri Pirko <jiri@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:32945 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752212AbcLXHel (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Dec 2016 02:34:41 -0500
Received: by mail-qt0-f196.google.com with SMTP id 41so7865424qtn.0
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2016 23:34:41 -0800 (PST)
In-Reply-To: <585C6F49.5030900@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 22, 2016 at 4:26 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 12/22/2016 08:05 PM, Cong Wang wrote:
>>
>> On Wed, Dec 21, 2016 at 1:07 PM, Daniel Borkmann <daniel@iogearbox.net>
>> wrote:
>>>
>>>
>>> Ok, you mean for net. In that case I prefer the smaller sized fix to be
>>> honest. It also covers everything from the point where we fetch the chain
>>> via cops->tcf_chain() to the end of the function, which is where most of
>>> the complexity resides, and only the two mentioned commits do the relock,
>>
>>
>> I really wish the problem is only about relocking, but look at the code,
>> the deeper reason why we have this bug is the complexity of the logic
>> inside tc_ctl_tfilter(): 1) the replay logic is hard, we have to make it
>> idempotent; 2) the request logic itself is hard, because of tc filter
>> design
>> and implementation.
>>
>> This is why I worry more than just relocking.
>
>
> But do you have a concrete 2nd issue/bug you're seeing? It rather sounds to
> me your argument is more about fear of complexity on tc framework itself.
> I agree it's complex, and tc_ctl_tfilter() is quite big in itself, where it
> would be good to reduce it's complexity into smaller pieces. But it's not
> really related to the fix itself, reducing complexity requires significantly
> more and deeper work on the code. We can rework tc_ctl_tfilter() in net-next
> to try to simplify it, sure, but I don't get why we have to discuss so much
> on this matter in this context, really.

Thanks for ignoring my point 1) above... You are dragging the discussion
further.


>
>>> so as a fix I think it's fine as-is. As mentioned, if there's need to
>>> refactor tc_ctl_tfilter() net-next would be better, imho.
>>
>>
>> Refactor is a too strong word, just moving the replay out is not a
>> refactor.
>> The end result will be still smaller than your commit d936377414fadbafb4,
>> which is already backported to stable.
>
>
> Commit d936377414fa is a whole different thing, and not related to the

Nope, you said "small", I show an example of non-small, perfectly fits
in the topic
and beats your argument w.r.t. patch size with your previous case.


> topic at all. The two-line changes with the initialization fix is quite
> straight forward and fixes a bug in the logic. It's also less complex in
> terms of lines but also in terms of complexity than to refactor or move the

Size doesn't tell everything, focus on the code:

1) With your current approach: we have to verify if 'tp_created' is really
correct in ALL cases including replay case; we also have to verify if any
other local variables are as correct as 'tp_created'.

2) With my proposed approach: replay case is much easier, compiler
does everything for us, the function itself is, and should be, good enough
for replaying, no need to track ANY local variables.

For me 2) is much better than 1). Don't look at size, look at the whole code
in a bigger picture.

> replay out. Moving it out contextually means that you also wouldn't rule
> out that things like nlmsg_parse(), or in-fact *any* of the
> __tc_ctl_tfilter()
> return paths could potentially return an error that suddenly would require
> a replay of the request. So, while moving it out fixes the bug, too, it also

The current replay loop already covers almost all of the function, so this
argument doesn't make sense.


> adds more potential points where you would go and replay the request where
> you didn't do so before and therefore also adds more complexity to the code
> that needs review/audit when fixing bugs since you don't have these
> hard/direct
> return paths anymore. Therefore I don't think it's better to go that way
> for the fix.

Please read the code again:

'goto replay' is located at line 383, tc_ctl_tfilter() ends at line 385

'replay' label is located at line 157, tc_ctl_tfilter() starts
(without local variables)
at line 153.

So, replay loop covers 227 lines of code, tc_ctl_tfilter() contains
233 lines of code,
therefore 97.4% of tc_ctl_tfilter() is the replay loop, moving it is
out is literately just
2.6%.

You call this refactor... Huh? Do your math please.
