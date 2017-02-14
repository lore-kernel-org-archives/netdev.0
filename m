From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC v2 1/8] xdp: Infrastructure to generalize XDP
Date: Tue, 14 Feb 2017 13:07:35 -0800
Message-ID: <CALx6S35C3SYvaBT93VsDJW4gej30MXD1PqjN53cfqG00L=NM3g@mail.gmail.com>
References: <20170208234127.3041579-1-tom@herbertland.com> <20170208234127.3041579-2-tom@herbertland.com>
 <20170214213157.32e37148@redhat.com> <CALx6S34mpo+Q_gsP37ENDqC8yEhk9s=in9v0S_c26z0JTM=adQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:34015 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753047AbdBNVHg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 16:07:36 -0500
Received: by mail-qk0-f194.google.com with SMTP id e1so20898626qkh.1
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2017 13:07:36 -0800 (PST)
In-Reply-To: <CALx6S34mpo+Q_gsP37ENDqC8yEhk9s=in9v0S_c26z0JTM=adQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 14, 2017 at 12:47 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Tue, Feb 14, 2017 at 12:31 PM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
>> On Wed, 8 Feb 2017 15:41:20 -0800
>> Tom Herbert <tom@herbertland.com> wrote:
>>
>>> +static inline int __xdp_run_one_hook(struct xdp_hook *hook,
>>> +                                  struct xdp_buff *xdp)
>>> +{
>>> +     void *priv = rcu_dereference(hook->priv);
>>> +
>>> +     if (hook->is_bpf) {
>>> +             /* Run BPF programs directly do avoid one layer of
>>> +              * indirection.
>>> +              */
>>> +             return BPF_PROG_RUN((struct bpf_prog *)priv, (void *)xdp);
>>> +     } else {
>>> +             return hook->hookfn(priv, xdp);
>>> +     }
>>> +}
>>> +
>>> +/* Core function to run the XDP hooks. This must be as fast as possible */
>>> +static inline int __xdp_hook_run(struct xdp_hook_set *hook_set,
>>> +                              struct xdp_buff *xdp,
>>> +                              struct xdp_hook **last_hook)
>>> +{
>>> +     struct xdp_hook *hook;
>>> +     int i, ret;
>>> +
>>> +     if (unlikely(!hook_set))
>>> +             return XDP_PASS;
>>> +
>>> +     hook = &hook_set->hooks[0];
>>> +     ret = __xdp_run_one_hook(hook, xdp);
>>> +     *last_hook = hook;
>>> +
>>> +     for (i = 1; i < hook_set->num; i++) {
>>> +             if (ret != XDP_PASS)
>>> +                     break;
>>> +             hook = &hook_set->hooks[i];
>>> +             ret = __xdp_run_one_hook(hook, xdp);
>>> +     }
>>> +
>>> +     return ret;
>>> +}
>>
>> There is one basic problem with this approach.  There is no bulking and
>> no reuse of instruction cache.  There is no revolution in this approach.
>> We will end-up with the same known performance problems when more hook
>> users get added.
>>
>> Calling N-number of hooks per every packet, will just end-up flushing
>> the instruction cache (like the issues we have today).
>>
>> Instead take N-packets, and then call the hooks by turn (store action
>> verdicts in packet-vector).  Such an architecture would be inline with
>> that VPP, Snabb and DPDK is doing.  Optimizing icache usage, and opens
>> up for smarter prefetching of lookup tables.  Imagine, having hook-1
>> identify lookup bucket and start prefetch, hook-2 access the bucket and
>> prefetch table data, and hook-3 read data.  This is what DPDK is doing
>> see[1], and VPP is doing similar tricks to get it to scale to large
>> route lookup tables.
>>
> Conceptually, that's a good extension, basically provide VPP-like
> interface in the kernel. Unfortunately though, we need the return
> codes to be processed in the driver so that API and driver model would
> have to change more. If we do this I suggest it's done sooner than
> later, as more drivers adopt XDP changing all the drivers for that API
> become much harder (as I saw with just the second version of this
> patch).
>

Off the top of my head... I'd say may we might be able to have a
minimally invasive interface with something like:

XDP_RUN(hook, xdp, drv_xdp_handle_action)

This replaces xdp_run and return codes are processed in the called
functions. Its a macro so that xdp_handle_action can be inlined.
Batching could then be done in the backend XDP so that it would be
transparent to the driver. We'd also probably want another call like
so the driver can flush the queued packets when exiting the rx loop.
Something like:

XDP_FLUSH(xdp, drv_xdp_handle_action)

The hook then contains a function callback that gives an array of
pages to a function and returns an array of actions.

Tom
