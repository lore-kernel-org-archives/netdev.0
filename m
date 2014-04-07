From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: 3.14 tc oops
Date: Mon, 07 Apr 2014 11:08:47 +0200
Message-ID: <53426B1F.9050405@redhat.com>
References: <1592838.91HrDxMk9i@comer> <CAM_iQpVgEtDqbK6-JoMn8-1D_cOsRTGPozvbmxbCBKi1+ss-rQ@mail.gmail.com> <CAM_iQpU+A+1FxFNkibvbkM=vkWVw7QmHJzE_AODVTgzUEjdeDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kelly Anderson <kelly@xilka.com>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5241 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753510AbaDGJIw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Apr 2014 05:08:52 -0400
In-Reply-To: <CAM_iQpU+A+1FxFNkibvbkM=vkWVw7QmHJzE_AODVTgzUEjdeDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Kelly, please also cc netdev]

On 04/07/2014 07:56 AM, Cong Wang wrote:
> On Thu, Apr 3, 2014 at 9:24 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Wed, Apr 2, 2014 at 7:24 AM, Kelly Anderson <kelly@xilka.com> wrote:
>>> Hi,
>>>
>>> I hit a kernel oops when starting traffic control on my armv7 router, I don't
>>> think the architecture is related, the same tc code worked perfectly with
>>> earlier kernel versions, i.e. 3.13.x.
>>>
>>> I also attached an object dump with line numbers to make identifying the
>>> problem a bit easier.
>>>
>>> Please cc me to keep me in the loop, I can test patches.
>>
>>
>> Thanks for the report! Looks like it is caused by one of my patches,
>> I will look into this shortly.
>>
>
> Which tc filter are you using on that htb qdisc? (tc filter show dev ....)
>
> I suspect it's tcindex filter, if so please try the following patch:
>
> diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
> index eed8404..14618cc 100644
> --- a/net/sched/cls_tcindex.c
> +++ b/net/sched/cls_tcindex.c
> @@ -298,8 +298,10 @@ tcindex_set_parms(struct net *net, struct
> tcf_proto *tp, unsigned long base,
>          tcf_exts_change(tp, &cr.exts, &e);
>
>          tcf_tree_lock(tp);
> -       if (old_r && old_r != r)
> +       if (old_r && old_r != r) {
>                  memset(old_r, 0, sizeof(*old_r));
> +               tcf_exts_init(&old_r->exts, TCA_TCINDEX_ACT,
> TCA_TCINDEX_POLICE);
> +       }
>
>          memcpy(p, &cp, sizeof(cp));
>          memcpy(r, &cr, sizeof(cr));
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
