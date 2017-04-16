From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH linux 2/2] net sched actions: fix refcount decrement on
 error
Date: Sun, 16 Apr 2017 10:30:04 -0400
Message-ID: <c0557c79-c426-f81a-2238-4494bfb9fb32@mojatatu.com>
References: <20170412142140.26649-1-w.bumiller@proxmox.com>
 <20170412142140.26649-3-w.bumiller@proxmox.com>
 <CAM_iQpUxgF2X9z+mNhBUtPJsFPy8pyiDDhqz726Qt_aeEeLpeA@mail.gmail.com>
 <20170413080648.bbiikladwevaribf@olga.proxmox.com>
 <CAM_iQpUWASuFdzLc6j+EyCj68=BnT6-bKXr=e=858Zkf9f6dSg@mail.gmail.com>
 <20170414090853.oqqdsu6xufr4n2nv@olga.proxmox.com>
 <CAM_iQpWSszPtMSG+vb+sowDcBeerWwufYARXmaiU-D4KJsyq8w@mail.gmail.com>
 <1985738840.18.1492282135309@webmail.proxmox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Roman Mashak <mrv@mojatatu.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wolfgang Bumiller <w.bumiller@proxmox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:34105 "EHLO
        mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755352AbdDPOaI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Apr 2017 10:30:08 -0400
Received: by mail-io0-f171.google.com with SMTP id a103so133092045ioj.1
        for <netdev@vger.kernel.org>; Sun, 16 Apr 2017 07:30:08 -0700 (PDT)
In-Reply-To: <1985738840.18.1492282135309@webmail.proxmox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Wolfgang, can you _please_ stop cc-ing lkml? Everybody you need to deal
with is on netdev.

On 17-04-15 02:48 PM, Wolfgang Bumiller wrote:
>

>>
>>> So I'm not sure exactly how the module and tc_action counts are related
>>> (and I usually like to understand my own patches ;-) ).
>>
>>

Every time we add an action, refcnt goes up. Every time we bind an
action to a filter the refcnt + bindcnt goes up.
Reverse for everytime we delete a filter or action. The action does
not get destroyed because the filter was deleted.
Everytime the action gets its refcount bumped up (for either of the
two reasons described above), the module ref needs incrementing.
Everytime the action refcnt goes down the module ref needs to be
decremented.

Only when both refcnt and bind cnt go to at least zero do we really
delete/destroy.

>> Each action holds a refcnt to its module, each filter holds a refcnt to
>> its bound or referenced (unbound) action.
>>
>>
>>> Maybe I'm missing something obvious but I'm currently a bit confused as
>>> to whether the tcf_hash_release() call there is okay, or should have its
>>> return value checked or should depend on ->init()'s ACT_P_CREATED value
>>> as well?
>>>
>>
>> I think it's the same? If we have ACT_P_CREATED here, tcf_hash_release()
>> will return ACT_P_DELETED for sure because the newly created action has
>> refcnt==1?
>
> Makes sense on the one hand, but for ACT_P_DELETED both ref and bind
> count need to reach 0, so I'm still concerned that the different behaviors
> I mentioned above might be problematic if we use ACT_P_CREATED only.
> (It also means my patches still leak a count - which is probably still
> better than the previous underflow, but ultimately doesn't satisfy me.)
> Should I still resend it this way for the record with the Acked-bys?
> (Since given the fact that with unprivileged containers it's possible to
> trigger this access and potentially crash the kernel I strongly feel that
> some version of this should end up in the 4.11 release.)
>

I think that is an unrelated code path, current issue is on the
create/replace code path. We need to separate delete from get - we
just havent got around to it yet. Followup patches will make sense.
Agree, this change should go in quickly..

Actually - come to think of it: You should probably leave the module
put to the end instead of the beginning because it protects against
another entry unloading the module while we are still processing.

Just post the patch - we'll help reviewing it.

cheers,
jamal
