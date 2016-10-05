From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] Panic when tc_lookup_action_n finds a partially
 initialized action.
Date: Wed, 5 Oct 2016 11:07:59 -0700
Message-ID: <CAM_iQpVzExoYSk_GxBbFBEULcaGibSRKKL+FxRsBPjXPv3SrLA@mail.gmail.com>
References: <20161002031349.GB2635@templeofstupid.com> <CAM_iQpX1a1=3PmMAwMRDXpL3qjAskQ990FdxgyCg4T5p4=8G7Q@mail.gmail.com>
 <20161005065244.GA2245@templeofstupid.com> <CAM_iQpUya1ORUUNC9-spLKHjsjNyj6xHO79kvoDGaZcWT_mEwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Krister Johansen <kjlx@templeofstupid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35584 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754577AbcJESIU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 14:08:20 -0400
Received: by mail-it0-f68.google.com with SMTP id l13so12308024itl.2
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2016 11:08:20 -0700 (PDT)
In-Reply-To: <CAM_iQpUya1ORUUNC9-spLKHjsjNyj6xHO79kvoDGaZcWT_mEwg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 5, 2016 at 11:01 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Tue, Oct 4, 2016 at 11:52 PM, Krister Johansen
> <kjlx@templeofstupid.com> wrote:
>> On Mon, Oct 03, 2016 at 11:22:33AM -0700, Cong Wang wrote:
>>> Please try the attached patch. I also convert the read path to RCU
>>> to avoid a possible deadlock. A quick test shows no lockdep splat.
>>
>> I tried this patch, but it doesn't solve the problem.  I got a panic on
>> my very first try:
>
> Thanks for testing it.
>
>
>> The problem here is the same as before: by using RCU the race isn't
>> fixed because the module is still discoverable from act_base before the
>> pernet initialization is completed.
>>
>> You can see from the trap frame that the first two arguments to
>> tcf_hash_check were 0.  It couldn't look up the correct per-subsystem
>> pointer because the id hadn't yet been registered.
>
> I thought the problem is that we don't do pernet ops registration and
> action ops registration atomically therefore chose to use mutex+RCU,
> but I was wrong, the problem here is just ordering, we need to finish
> the pernet initialization before making action ops visible.
>
> If so, why not just reorder them? Does the attached patch make any
> sense now? Our pernet init doesn't rely on act_base, so even we have
> some race, the worst case is after we initialize the pernet netns for an
> action but its ops still not visible, which seems fine (at least no crash).

BTW, I should remove the 'if' check for unregister_pernet_subsys() in
tcf_unregister_action()... Otherwise the error path doesn't work. ;-)
