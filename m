From: Neal Cardwell <ncardwell@google.com>
Subject: Re: A buggy behavior for Linux TCP Reno and HTCP
Date: Sun, 23 Jul 2017 22:36:32 -0400
Message-ID: <CADVnQy=-m37Uxfg1=nJpkuy2CKTtW1fp2jG53Q+MNF7ifGvoHw@mail.gmail.com>
References: <CANdGJ5Qp1MoGfeSyAnEqYeSeEyoiH8e1j_Ut3F4PnLRBnqNNZg@mail.gmail.com>
 <CAK6E8=eP3jwTD5t7Cj3h_m4JTJ61p=roqsr02WiSHUANse1ynw@mail.gmail.com>
 <CANdGJ5SOUV1OoonC-3i=5MLUWvoHPBZgp19c3mJTTYbNr2yLeQ@mail.gmail.com>
 <CAK6E8=eWYybZZxkjjVXC_K7DfYayEg7gx0bPqKpwi6iuE+bh8Q@mail.gmail.com>
 <dc5db0ec-0746-d42e-5418-f621e1840bc0@unl.edu> <CADVnQynG0MZcuAPpZ+hiK-9Ounx8JKPWxvb1n3t-OyyC7=es_Q@mail.gmail.com>
 <CAK6E8=d+-kA_PyVgAoe0dtGg--ek0CurehQZ7JXo=32em2Gv+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Lisong Xu <xu@unl.edu>, Wei Sun <unlcsewsun@gmail.com>,
        netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:34621 "EHLO
        mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751858AbdGXChE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Jul 2017 22:37:04 -0400
Received: by mail-oi0-f50.google.com with SMTP id x3so10022462oia.1
        for <netdev@vger.kernel.org>; Sun, 23 Jul 2017 19:37:03 -0700 (PDT)
In-Reply-To: <CAK6E8=d+-kA_PyVgAoe0dtGg--ek0CurehQZ7JXo=32em2Gv+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 21, 2017 at 5:16 PM, Yuchung Cheng <ycheng@google.com> wrote:
> On Fri, Jul 21, 2017 at 1:46 PM, Neal Cardwell <ncardwell@google.com> wrote:
>> On Fri, Jul 21, 2017 at 4:27 PM, Lisong Xu <xu@unl.edu> wrote:
>>>
>>> Hi Yuchung,
>>>
>>> This test scenario is only one example to trigger this bug. In general, as
>>> long as cwnd <4, the undo function has this bug.
>>
>>
>> Yes, personally I agree that this seems like an issue that is general enough
>> to be worth fixing. In the sense that, if cwnd <4, then we may well be very
>> congested. So we don't want to get hit by this bug wherein an undo of a loss
>> recovery can cause cwnd to suddenly jump (from 1, 2, or 3) up to 4.
>>
>> Seems like any of the several CCs that use tcp_reno_undo_cwnd() have this
>> bug.
>>
>> I guess in my mind the only question is whether we want to add a
>> tcp_foo_undo_cwnd() and ca->loss_cwnd to every CC module to handle this
>> issue (i.e. make every CC module handle it the way CUBIC does), or (my
> I would prefer the former b/c loss_cwnd may not be universal TCP
> state, just like ssthresh carries no meaning in some CC (bbr). It also
> seems also more consistent with the recent change on undo
>
> commit e97991832a4ea4a5f47d65f068a4c966a2eb5730
> Author: Florian Westphal <fw@strlen.de>
> Date:   Mon Nov 21 14:18:38 2016 +0100
>
>     tcp: make undo_cwnd mandatory for congestion modules
>

You are certainly right that it is more pure to keep a CC detail like
that inside the CC module.

But it's a bit sad to me that we have 9 separate identical
implementations of a cwnd undo function, and that approach would add 6
more.

We do have tp->snd_ssthresh and tp->prior_ssthresh, even though not
all CC modules use ssthresh.

What if we call the field tp->prior_cwnd? Then at least we'd have some
nice symmetry:

- tp->snd_cwnd,  which is saved in tp->prior_cwnd  (and restored upon undo)
- tp->snd_ssthresh,  which is saved in tp-> prior_ssthresh  (and
restored upon undo)

That sounds appealing to me. WDYT?

neal
