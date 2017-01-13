From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] atm: remove an unnecessary loop
Date: Fri, 13 Jan 2017 10:18:32 -0800
Message-ID: <CAM_iQpUCVh9y8uhZ8Hj0mcjgfMGUQDvaEvSu5Wur1oVn+EZNGQ@mail.gmail.com>
References: <CAM_iQpX2TipBW2Pm-OHRobfZaVoV9_D8Se8u9oKryt96SZFRkA@mail.gmail.com>
 <20170113132346.GA19220@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Michal Hocko <mhocko@kernel.org>,
        Chas Williams <3chas3@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35612 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750789AbdAMSSx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 13:18:53 -0500
Received: by mail-qt0-f193.google.com with SMTP id f4so7168440qte.2
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 10:18:53 -0800 (PST)
In-Reply-To: <20170113132346.GA19220@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 13, 2017 at 5:23 AM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Cong Wang <xiyou.wangcong@gmail.com> :
> [...]
>> alloc_skb(GFP_KERNEL) itself is sleeping, so the new wait api is still
>> needed.
>
> The task state change warning is the symptom.
>
> The deeply nested alloc_skb is the problem.
>
> Diagnosis: nesting is wrong. It makes zero sense. Fix it and the
> implicit task state change problem automagically goes away.
>
> alloc_skb() does not need to be in the "while" loop.

This is exactly what I describe in my changelog, don't know
why you want to repeat it...


>
> alloc_skb() does not need to be in the {prepare_to_wait/add_wait_queue ...
> finish_wait/remove_wait_queue} block.
>

If you ever read the followup patch of this one, you will find:

"
Of course, the logic itself is suspicious, other sendmsg()
could handle skb allocation failure very well, not sure
why ATM has to wait for a successful one here. But probably
it is too late to change since the errno and behavior is
visible to user-space. So just leave the logic as it is.
"


> alloc_tx() is not correctly named: given its original content, it deserves
> to be called something like:

Please don't expect me to fix many things in one patch, let's
fix each of them separately, agreed?

>
> "wait_for_decent_tx_drain_and_alloc_by_hand_coz_i_dont_trust_the_mm_subsystem_and_i_dont_know_what_i_want"
>
> I claim that:
> - alloc_tx() should only perform the "wait_for_decent_tx_drain" part
> - alloc_skb() ought to be done directly in vcc_sendmsg
> - alloc_skb() failure can be handled gracefully in vcc_sendmsg
> - alloc_skb() may use a (m->msg_flags & MSG_DONTWAIT) dependant
>   GFP_{KERNEL / ATOMIC} flag
> - most of it can be done in a longterm maintenance pain minimizing
>   way. Call it a side-effect: I don't claim that it *must* be done
>   this way.

Never disagree, but again, please ensure there is no API brokeness
as I mentioned in the followup patch which you missed. Apparently
my ATM knowledge is not enough to justify the API/ABI.

Thanks.
