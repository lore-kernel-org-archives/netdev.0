From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net_sched: use idr to allocate u32 filter handles
Date: Thu, 28 Sep 2017 15:19:05 -0700
Message-ID: <CAM_iQpWbiA4QZb8j8fau7kMhzeLpRppEMcmB80byqTUryPheOw@mail.gmail.com>
References: <20170921234302.26558-3-xiyou.wangcong@gmail.com> <20170928073423.GB15815@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Chris Mi <chrism@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35453 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750805AbdI1WT0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 18:19:26 -0400
Received: by mail-pg0-f66.google.com with SMTP id j16so3280192pga.2
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 15:19:26 -0700 (PDT)
In-Reply-To: <20170928073423.GB15815@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 28, 2017 at 12:34 AM, Simon Horman
<simon.horman@netronome.com> wrote:
> Hi Cong,
>
> this looks like a nice enhancement to me. Did you measure any performance
> benefit from it.  Perhaps it could be described in the changelog_ I also
> have a more detailed question below.

No, I am inspired by commit c15ab236d69d, don't measure it.


>
>> ---
>>  net/sched/cls_u32.c | 108 ++++++++++++++++++++++++++++++++--------------------
>>  1 file changed, 67 insertions(+), 41 deletions(-)
>>
>> diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
>> index 10b8d851fc6b..316b8a791b13 100644
>> --- a/net/sched/cls_u32.c
>> +++ b/net/sched/cls_u32.c
>> @@ -46,6 +46,7 @@
>
> ...
>
>> @@ -937,22 +940,33 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
>>                       return -EINVAL;
>>               if (TC_U32_KEY(handle))
>>                       return -EINVAL;
>> -             if (handle == 0) {
>> -                     handle = gen_new_htid(tp->data);
>> -                     if (handle == 0)
>> -                             return -ENOMEM;
>> -             }
>>               ht = kzalloc(sizeof(*ht) + divisor*sizeof(void *), GFP_KERNEL);
>>               if (ht == NULL)
>>                       return -ENOBUFS;
>> +             if (handle == 0) {
>> +                     handle = gen_new_htid(tp->data, ht);
>> +                     if (handle == 0) {
>> +                             kfree(ht);
>> +                             return -ENOMEM;
>> +                     }
>> +             } else {
>> +                     err = idr_alloc_ext(&tp_c->handle_idr, ht, NULL,
>> +                                         handle, handle + 1, GFP_KERNEL);
>> +                     if (err) {
>> +                             kfree(ht);
>> +                             return err;
>> +                     }
>
> The above seems to check that handle is not already in use and mark it as
> in use. But I don't see that logic in the code prior to this patch.
> Am I missing something? If not perhaps this portion should be a separate
> patch or described in the changelog.

The logic is in upper layer, tc_ctl_tfilter(). It tries to get a
filter by handle
(if non-zero), and errors out if we are creating a new filter with the same
handle.

At the point you quote above, 'n' is already NULL and 'handle' is non-zero,
which means there is no existing filter has same handle, it is safe to just
mark it as in-use.

Thanks.
