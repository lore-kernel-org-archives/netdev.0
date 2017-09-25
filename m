From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next v2] net_sched: use idr to allocate bpf filter handles
Date: Mon, 25 Sep 2017 16:11:07 -0700
Message-ID: <CAM_iQpUKURMfZOyTMbgVFG43rgUg8-3yAAVtEmPja5T6xkZpjA@mail.gmail.com>
References: <20170925171351.4956-1-xiyou.wangcong@gmail.com> <59C97244.30301@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Chris Mi <chrism@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:51008 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934254AbdIYXL2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 19:11:28 -0400
Received: by mail-pg0-f47.google.com with SMTP id p5so4870181pgn.7
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 16:11:28 -0700 (PDT)
In-Reply-To: <59C97244.30301@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 25, 2017 at 2:16 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 09/25/2017 07:13 PM, Cong Wang wrote:
>>         ret = cls_bpf_offload(tp, prog, oldprog);
>>         if (ret) {
>> +               if (!oldprog)
>> +                       idr_remove_ext(&head->handle_idr, prog->handle);
>
>
> Shouldn't we also call idr_remove_ext() when there was an
> oldprog, but we didn't care about reusing the same handle,
> so it was handle == 0 initially?

When oldprog is non-NULL, we are replacing the oldprog with
a new one, therefore we should call idr_replace_ext() which
happens after this. So no need to call idr_remove_ext() at
this point.



>
> There's this condition in the code before above idr allocations,
> I think also in other classifiers:
>
>         if (oldprog) {
>                 if (handle && oldprog->handle != handle) {
>                         ret = -EINVAL;
>                         goto errout;
>                 }
>         }

Sure. If we use handle to find oldprog, it should have the
same handle. cls_bpf_get() guarantees it. This check is
redundant.

>
>>                 __cls_bpf_delete_prog(prog);
>>                 return ret;
>>         }
>> @@ -499,6 +494,7 @@ static int cls_bpf_change(struct net *net, struct
>> sk_buff *in_skb,
>>                 prog->gen_flags |= TCA_CLS_FLAGS_NOT_IN_HW;
>>
>>         if (oldprog) {
>> +               idr_replace_ext(&head->handle_idr, prog, handle);
>
>
> And here, we should probably use prog->handle for the above
> mentioned case as well, no?

Since are replacing oldprog with a new one, prog->handle is
same with handle.


>
> Would be great if all this (and e.g. the fact that we use idr itself)
> could optionally be hidden behind some handle generator api given
> we could reuse that api also for cls_basic and cls_u32. Could also
> be followed-up perhaps.
>

Yeah, the idr_alloc_ext(.., handle, handle+1,) is ugly. Ideally we should
specify the range during initialization rather than in each idr_alloc_ext().
Commit c15ab236d69d already did the same thing. We can refactor
this later.
