From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Qdisc->u32_node - licence to kill
Date: Mon, 7 Aug 2017 16:21:12 -0700
Message-ID: <CAM_iQpUZdv1sg+6jY862=GbWaC8x9XN9Ed-uaKi6_RT12sFj6w@mail.gmail.com>
References: <20170807164100.GK2085@nanopsycho.orion> <5988A7A2.3090200@gmail.com>
 <20170807190624.GL2085@nanopsycho.orion> <5988C55B.60204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        mlxsw@mellanox.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f173.google.com ([209.85.217.173]:36788 "EHLO
        mail-ua0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751881AbdHGXVd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 19:21:33 -0400
Received: by mail-ua0-f173.google.com with SMTP id k43so8037163uaf.3
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 16:21:33 -0700 (PDT)
In-Reply-To: <5988C55B.60204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 7, 2017 at 12:54 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> On 08/07/2017 12:06 PM, Jiri Pirko wrote:
>> Mon, Aug 07, 2017 at 07:47:14PM CEST, john.fastabend@gmail.com wrote:
>>> On 08/07/2017 09:41 AM, Jiri Pirko wrote:
>>>> Hi Jamal/Cong/David/all.
>>>>
>>>> Digging in the u32 code deeper now. I need to get rid of tp->q for shared
>>>> blocks, but I found out about this:
>>>>
>>>> struct Qdisc {
>>>>     ......
>>>>         void                    *u32_node;
>>>>     ......
>>>> };
>>>>
>>>> Yeah, ugly. u32 uses it to store some shared data, tp_c. It actually
>>>> stores a linked list of all hashtables added to one qdiscs.
>>>>
>>>> So basically what you have is, you have 1 root ht per prio/pref. Then
>>>> you can have multiple hts, linked from any other ht, does not matter in
>>>> which prio/pref they are.
>>>>
>>>
>>> We can create arbitrary hash tables here independent of prio/pref via
>>> TCA_U32_DIVISOR. Then these can be linked to other hash tables via
>>> TCA_U32_LINK commands.
>>
>> Yeah, that's what I thought.
>>
>>
>>>
>>> prio/pref does not really play any part here from my reading, except as
>>> a further specifier in the walk callbacks. Making it a useful filter on
>>> dump operations.
>>
>> Not correct. prio/pref is one level up priority, independent on specific
>> cls implementation. You can have cls_u32 instance on prio 10 and
>> cls_flower instance on prio 20. Both work.
>
> ah right, lets make sure I got this right then (its been awhile since I've
> read this code). So the tcf_ctl_tfilter hook walks classifiers, inserting the
> classifier by prio. Then tcf_classify walks the list of classifiers looking
> for any matches, specifically any return codes it recognizes or a return code
> greater than zero. u32 though has this link notion that allows users to jump
> to other u32 classifiers that are in this list, because it has a global hash
> table list. So the per prio classifier isolation is not true in u32 case.

u32 filter supports multiple hash tables within a qdisc, struct
tc_u_common is supposed to link them together. This has to be
per qdisc because all of these hash tables belong to one qdisc
and their ID's are unique within the qdisc.

I dislike it too, and I actually tried to improve it in the past,
unfortunately didn't make any real progress. I think we can
definitely make it less ugly, but I don't think we can totally
get rid of it because of the design of u32.

Similar for tp->data.
