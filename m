From: Lucas Bates <lucasb@mojatatu.com>
Subject: Re: [Patch net 00/16] net_sched: fix races with RCU callbacks
Date: Tue, 31 Oct 2017 15:13:29 -0400
Message-ID: <CAMDBHYJiQWSW490syWS195vZ3iYLaczPtNt8aYdqska5q+YgHQ@mail.gmail.com>
References: <20171027012443.3306-1-xiyou.wangcong@gmail.com>
 <CAMDBHYJGU-8SgYnzMKJsD6QKdMBSi4evHxJi2p-fJ12+09fBsw@mail.gmail.com>
 <CAM_iQpW=1kbpLxwCbBtGj3D+aVy5QseEAU+omEJUmJJwJ6P58A@mail.gmail.com>
 <CAMDBHYJTMv4MDQENNKjOXaUBHyXicOnkM_j+i7__3d1CAgdVRg@mail.gmail.com>
 <CAM_iQpUTG6hzi=kPP2t=Svoj_MHgfcs7m+_ruWVafJq26RFV8g@mail.gmail.com>
 <0dfff609-d67e-0701-399f-1dbe2ef09bf3@mojatatu.com> <CAMDBHYJ2BpzSOm3dFV98sGe5mAHrQ_z=Vmx9oUo0e6AtqbTk5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Chris Mi <chrism@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>,
        John Fastabend <john.fastabend@gmail.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:51732 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753797AbdJaTNu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 15:13:50 -0400
Received: by mail-wm0-f67.google.com with SMTP id b9so948694wmh.0
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 12:13:50 -0700 (PDT)
In-Reply-To: <CAMDBHYJ2BpzSOm3dFV98sGe5mAHrQ_z=Vmx9oUo0e6AtqbTk5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 2:55 PM, Lucas Bates <lucasb@mojatatu.com> wrote:
> On Tue, Oct 31, 2017 at 7:00 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 17-10-31 01:44 AM, Cong Wang wrote:
>>>
>>> Can you try this patch? From your stack trace it is not clear where
>>> the cause is, but we know that the crash is in __tcf_idr_release(),
>>> this is how I came up with the following patch:
>>>
>>>
>>> diff --git a/include/net/act_api.h b/include/net/act_api.h
>>> index b944e0eb93be..5072446d5f06 100644
>>> --- a/include/net/act_api.h
>>> +++ b/include/net/act_api.h
>>> @@ -122,7 +122,9 @@ void tcf_idrinfo_destroy(const struct tc_action_ops
>>> *ops,
>>>
>>>   static inline void tc_action_net_exit(struct tc_action_net *tn)
>>>   {
>>> +       rtnl_lock();
>>>          tcf_idrinfo_destroy(tn->ops, tn->idrinfo);
>>> +       rtnl_unlock();
>>>          kfree(tn->idrinfo);
>>>   }
>>>
>>>
>>
>> Looks like an excellent bet;-> tdc kills the container at the end of the
>> test.
>
> Unfortunately it doesn't seem to have had any effect, I'm still seeing
> the same bug as yesterday. At Jamal's suggestion I put in a delay
> after tdc completed running the tests but before it deleted the
> container - and I didn't run into the bug after many runs. I had no
> luck getting serial console access on any of our other systems so I
> have another stack trace photo which I'll send to you directly.

I forgot to mention: it appears the bug appears to be related to
deleting the container. Test d052 is the last to run before tdc does
its teardown and deletes the container; if I add the sleep the bug
never gets triggered.
