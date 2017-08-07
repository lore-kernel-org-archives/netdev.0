From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Qdisc->u32_node - licence to kill
Date: Mon, 7 Aug 2017 21:06:24 +0200
Message-ID: <20170807190624.GL2085@nanopsycho.orion>
References: <20170807164100.GK2085@nanopsycho.orion>
 <5988A7A2.3090200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, davem@davemloft.net,
        netdev@vger.kernel.org, mlxsw@mellanox.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f180.google.com ([209.85.128.180]:37461 "EHLO
        mail-wr0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751508AbdHGTG1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 15:06:27 -0400
Received: by mail-wr0-f180.google.com with SMTP id 33so5032791wrz.4
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 12:06:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5988A7A2.3090200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Aug 07, 2017 at 07:47:14PM CEST, john.fastabend@gmail.com wrote:
>On 08/07/2017 09:41 AM, Jiri Pirko wrote:
>> Hi Jamal/Cong/David/all.
>> 
>> Digging in the u32 code deeper now. I need to get rid of tp->q for shared
>> blocks, but I found out about this:
>> 
>> struct Qdisc {
>> 	......
>>         void                    *u32_node;
>> 	......
>> };
>> 
>> Yeah, ugly. u32 uses it to store some shared data, tp_c. It actually
>> stores a linked list of all hashtables added to one qdiscs.
>> 
>> So basically what you have is, you have 1 root ht per prio/pref. Then
>> you can have multiple hts, linked from any other ht, does not matter in
>> which prio/pref they are.
>> 
>
>We can create arbitrary hash tables here independent of prio/pref via
>TCA_U32_DIVISOR. Then these can be linked to other hash tables via
>TCA_U32_LINK commands.

Yeah, that's what I thought.


>
>prio/pref does not really play any part here from my reading, except as
>a further specifier in the walk callbacks. Making it a useful filter on
>dump operations.

Not correct. prio/pref is one level up priority, independent on specific
cls implementation. You can have cls_u32 instance on prio 10 and
cls_flower instance on prio 20. Both work.

In fact, the current u32 "linking" ignores the upper level
prio/pref and breakes user assumptions when he inserts rules with
specific prio.


>
>> Do I understand that correctly that prio/pref only has meaning if
>> linking does not take place, because if there is linking, the prio/pref
>> of inserted rule is simply ignored?
>
>I think even then the prio/pref meaning is dubious, from u32_change,

Please see tc_ctl_tfilter. That is where prio/pref is processed. What
you describe is one level down.


>
>                for (pins = rtnl_dereference(*ins); pins;
>                     ins = &pins->next, pins = rtnl_dereference(*ins))
>                        if (TC_U32_NODE(handle) < TC_U32_NODE(pins->handle))
>                                break;
>
>I think the list insert is done via handle not via prio/pref.
>
>> 
>> That is the most confusing thing I saw in net/sched/ so far. 
>> Is this a bug? Sounds like one.
>> 
>
>I don't think this is a bug at very least I don't see how we can
>change it without breaking users. I know people depend on the hash map
>capabilities and linking logic.

Do they insert rules into multiple hashtables with different prio? Why?
What is the usecase?


>
>> Did someone introduce *u32_node (formerly static struct tc_u_common
>> *u32_list;) just to allow this weirdness?
>> 
>> Can I just remove this shared tp_c and make the linking to other
>> hashtables only possible within the same prio/pref? That would make
>> sense to me.
>> 
>
>The idea to make linking hash tables only possible within the same
>prio/pref will break existing programs. We can't do this its part of
>UAPI now and people depend on it.

That's why I asked if that is a bug. I still feel it is. But I
definitelly understand your concern. I'm just trying to figure out how
to resolve this misdesign :(
