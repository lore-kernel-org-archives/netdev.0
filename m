From: Paul Moore <paul@paul-moore.com>
Subject: Re: [Patch net] net: saving irq context for peernet2id()
Date: Fri, 21 Oct 2016 16:03:53 -0400
Message-ID: <CAHC9VhRQ9YAr9eHYg2HWusuCZd714tK6SSr3Et8beb77w37TUA@mail.gmail.com>
References: <1476946352-15770-1-git-send-email-xiyou.wangcong@gmail.com>
 <2707c52d-88ec-7b93-f96e-eeaffc952c9c@tycho.nsa.gov> <CAM_iQpWD3WiX1ZX+3LJ8vbJc42K1jZcZ4-f6MO5kzZY-+Szkqw@mail.gmail.com>
 <CAHC9VhSronk914-0QZd7cPBEAOvSzN++Umc=_aueeCuOB9iG8Q@mail.gmail.com>
 <CAM_iQpVFWzUm2BJZUs+-LWpKA8kubuKhzyE01_V69TEsrFnm-Q@mail.gmail.com>
 <CAHC9VhQWWDHnQGv+feXZ_CDrkftuRkKLtKvXkpN0pqh6e6hMPQ@mail.gmail.com> <CAM_iQpV0vfwsToR=maxhGM+fvQLX9zqcpp14A-C9JNzLfKJy9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Smalley <sds@tycho.nsa.gov>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Elad Raz <e@eladraz.com>, Richard Guy Briggs <rgb@redhat.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f66.google.com ([209.85.213.66]:36323 "EHLO
        mail-vk0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935985AbcJUUDz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 16:03:55 -0400
Received: by mail-vk0-f66.google.com with SMTP id b186so5224397vkb.3
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 13:03:55 -0700 (PDT)
In-Reply-To: <CAM_iQpV0vfwsToR=maxhGM+fvQLX9zqcpp14A-C9JNzLfKJy9g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 21, 2016 at 2:02 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Fri, Oct 21, 2016 at 9:19 AM, Paul Moore <paul@paul-moore.com> wrote:
>> On Thu, Oct 20, 2016 at 7:35 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> This is what I did in the follow up patch. I attach the updated version
>>> in this email for you to review ...
>>
>> I think there is still some confusion.  The second patch you posted
>> still has two queues with potentially duplicated (minus the length
>> tweaks) skbs.
>
> The current code without my patch is already this, the only difference
> is there is no queue for multicast case, duplication is already there.

The difference is the period of time where the skbs are duplicated.
You patch duplicates the skb and then queues them, I'm suggesting
putting a single skb in the queue and then only duplicating it once it
has been pulled off the queue.

> So, why do you expect me to fix two problems in one patch? This
> is totally unfair, it is probably based on your eager to revert...

All I've been asking for this week is a fix before -rc2 is released; I
think I've been pretty clear and consistent about that.  At the start
of the week I didn't care if it was a revert or some other fix, so
long as the fix was relatively small and easily verified/tested.  I
did say that if we got to the end of the week and we didn't have a
solution in place I would advocate for a revert.  It's Friday
afternoon as I type this.

I've also been pretty clear from the very beginning that I don't
consider a rework of the audit multicast code to be a candidate for
4.9-rcX, that is -next material as far as I'm concerned.  I'll readily
admit that perhaps I'm more conservative than most maintainers, but I
take that approach to try to keep from breaking other subsystems (and
avoid situations like these, because this thread is so much fun after
all).

>> What I am talking about is queuing the skb in audit_log_end(), without
>> any modification, waking up the kauditd_thread, and then letting the
>> kauditd_thread() function do both the netlink multicast and unicast
>> sends, complete with the skb_copy() and length tweaks.  This way we
>> only queue one copy of the skb.  To help make this more clear, I'll
>> work up a patch and CC you.
>
> Sure, I hate the skb_copy() too since it could be in a IRQ handler,
> I didn't remove it because that would make the patch more complicated
> than the current one. We can always improve this later for the next merge
> window, can't we? Why are you pushing something irrelevant to my
> patch to make it unnecessarily complicated?

I don't even know where to begin ... please just re-read what I've
said above as well as previously this week.  I just want a simple fix
for 4.9-rc.  I'm not going to sign-off/ack a rework of the audit
multicast code for 4.9-rc.

>> However, let me say this one more time: this is *NOT* a change I want
>> to make during the -rcX cycle, this is a change that we should do for
>> -next and submit during the next merge window after is has been tested
>> and soaked in linux-next.  Given where we are at right now - it's
>> Friday and I expect -rc2 on Sunday - I think the best course of action
>> is to revert the original patch and move on.  I'm going to do that now
>> and I'll submit it to netdev as soon as I've done some basic sanity
>> checks.
>
> The problem with this is: I would have to revert this revert for the next
> merge window, in the end you would have the following in git log:
>
> 1) original one
> 2) revert
> 3) audit fix
> 4) revert the above revert
>
> comparing with:
>
> 1) original one
> 2) audit fix
>
> You just want to make things unnecessarily complicated.

No.  What I want, (one more time) is a fix in -rc2.

> You need to really CALM DOWN, -rc2 is NOT late, assuming -rc7 is the final
> release candidate, we still have 5 weeks to fix it, why are you so scared?

We don't know each other, in fact before this week I'm not sure we've
even emailed each other (my apologies if we have), so I'm just
ignoring statements like the above, but just some advice (feel free to
ignore): I don't think anyone ever responds well to demands to "CALM
DOWN", especially when I feel my side of the conversation has been
quite civil.

> We have dealt much more complicated patch/backport for networking
> for -stable. Please don't panic.

-- 
paul moore
www.paul-moore.com
