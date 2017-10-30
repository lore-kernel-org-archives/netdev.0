From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: More painful merges...
Date: Mon, 30 Oct 2017 09:40:51 -0700
Message-ID: <CAM_iQpVnWQ++Ld-=KD8VjVOn--uQfkb5Q_DRg1Xw_pZ02mB-NQ@mail.gmail.com>
References: <20171030.211551.790664985307439262.davem@davemloft.net> <CAM_iQpUTauPL7Z_s-0kbp+nbg17fniMBhOyQ4tDVVmC=qFFy=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        John Fastabend <john.fastabend@gmail.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:56974 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932369AbdJ3QlM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 12:41:12 -0400
Received: by mail-pg0-f68.google.com with SMTP id m18so12085965pgd.13
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 09:41:12 -0700 (PDT)
In-Reply-To: <CAM_iQpUTauPL7Z_s-0kbp+nbg17fniMBhOyQ4tDVVmC=qFFy=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 30, 2017 at 8:58 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Mon, Oct 30, 2017 at 5:15 AM, David Miller <davem@davemloft.net> wrote:
>>
>> BPF and tc action bug fixes in 'net' caused some extremely
>> painful merges with 'net-next'.
>>
>> Could the interested parties please take a look at 'net-next'
>> and send me any necessary fixes, as I did the best that I
>> could.
>>
>
> The tcf_block_put_ext() part looks good to me. I will run
> some tests to make sure.
>

Hmm, there is some bug in tcf_unbind_filter() after this
merge, but that is not your fault. In net-next, we use
tp->chain after it is freed:

static inline void
 tcf_unbind_filter(struct tcf_proto *tp, struct tcf_result *r)
 {
+       struct Qdisc *q = tp->chain->block->q;
        unsigned long cl;

+       if (!q)
+               return;
        if ((cl = __cls_set_class(&r->class, 0)) != 0)
-               tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
+               q->ops->cl_ops->unbind_tcf(q, cl);
 }

I will provide a fix.

Just FYI.
