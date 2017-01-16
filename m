From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: sctp: kernel memory overwrite attempt detected in sctp_getsockopt_assoc_stats
Date: Mon, 16 Jan 2017 15:03:43 +0100
Message-ID: <CACT4Y+aoRnZyPYM=Bz3RLWhK+MYrQJBZ22TijJd=fzHp9KG+9A@mail.gmail.com>
References: <CACT4Y+ZDPa+spEh6P_ip9=hsNfeZ8KJfwJu5jTrPKVkGJUaZSg@mail.gmail.com>
 <20170115203515.GA6274@neilslaptop.think-freely.org> <CACT4Y+Zp4cruuKtf7fkSeLFbYLzTOD79Y2c+cCrHx-pbEXC_6A@mail.gmail.com>
 <20170116135743.GC30105@hmswarspite.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vladislav Yasevich <vyasevich@gmail.com>,
        David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Kees Cook <keescook@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:34637 "EHLO
        mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751388AbdAPOEG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 09:04:06 -0500
Received: by mail-lf0-f42.google.com with SMTP id v186so83965000lfa.1
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 06:04:05 -0800 (PST)
In-Reply-To: <20170116135743.GC30105@hmswarspite.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 16, 2017 at 2:57 PM, Neil Horman <nhorman@tuxdriver.com> wrote:
> On Mon, Jan 16, 2017 at 08:11:40AM +0100, Dmitry Vyukov wrote:
>> On Sun, Jan 15, 2017 at 9:35 PM, Neil Horman <nhorman@tuxdriver.com> wrote:
>> > On Sun, Jan 15, 2017 at 06:29:59PM +0100, Dmitry Vyukov wrote:
>> >> Hello,
>> >>
>> >> I've enabled CONFIG_HARDENED_USERCOPY_PAGESPAN on syzkaller fuzzer and
>> >> now I am seeing lots of:
>> >>
>> > If I'm not mistaken, its because thats specifically what that option does.  From
>> > the Kconfig:
>> > onfig HARDENED_USERCOPY_PAGESPAN
>> >         bool "Refuse to copy allocations that span multiple pages"
>> >         depends on HARDENED_USERCOPY
>> >         depends on EXPERT
>> >         help
>> >           When a multi-page allocation is done without __GFP_COMP,
>> >           hardened usercopy will reject attempts to copy it. There are,
>> >           however, several cases of this in the kernel that have not all
>> >           been removed. This config is intended to be used only while
>> >           trying to find such users.
>> >
>> > So, if the fuzzer does a setsockopt and the data it passes crosses a page
>> > boundary, it seems like this will get triggered.  Based on the fact that its
>> > only used to find users that do this, it seems like not the sort of thing that
>> > you want enabled while running a fuzzer that might do it arbitrarily.
>>
>>
>> The code also takes into account compound pages. As far as I
>> understand the intention of the check is to effectively find
>> out-of-bounds copies (e.g. goes beyond the current heap allocation). I
>> would expect that stacks are allocated as compound pages and don't
>> trigger this check. I don't see it is firing in other similar places.
>>
> Honestly, I'm not overly familiar with stack page allocation, at least not so
> far as compound vs. single page allocation is concerned.  I suppose the question
> your really asking here is: Have you found a case in which the syscall fuzzer
> has forced the allocation of an insecure non-compound page on the stack, or is
> this a false positive warning.  I can't provide the answer to that.


Yes. I added Kees, author of CONFIG_HARDENED_USERCOPY_PAGESPAN, to To line.
Kees, is this a false positive?
