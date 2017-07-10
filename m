From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net: Fix inconsistent teardown and release of private netdev state.
Date: Mon, 10 Jul 2017 09:28:19 -0700
Message-ID: <CAM_iQpV67_6iCq__TGGkdwH-2A2=GwrO9ivss2qTSFVciNAFfg@mail.gmail.com>
References: <20170706142427.GA32086@zx2c4.com> <CAM_iQpV5hz-Nuw_s7A8w7KE-d3c-MELQjeYMjznh8Kg6DcZ+_Q@mail.gmail.com>
 <CAHmME9qjhOOGvOuXi0LEcEPE6Z5dK8MO-01dxb++RkAkpr91dw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36062 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754468AbdGJQ2l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 12:28:41 -0400
Received: by mail-lf0-f66.google.com with SMTP id f28so11340852lfi.3
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 09:28:40 -0700 (PDT)
In-Reply-To: <CAHmME9qjhOOGvOuXi0LEcEPE6Z5dK8MO-01dxb++RkAkpr91dw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 9, 2017 at 7:07 PM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> On Sat, Jul 8, 2017 at 12:39 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Thu, Jul 6, 2017 at 7:24 AM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
>>>         list_add(&priv->list, &list_of_things);
>>>
>>>         ret = register_netdevice(); // if ret is < 0, then destruct above is automatically called
>>>
>>>         // RACE WITH LIST_ADD/LIST_DEL!! It's impossible to call list_add only after
>>>         // things are brought up successfully. This is problematic.
>>>
>>>         if (!ret)
>>>                 pr_info("Yay it worked!\n");
>>
>> I fail to understand what you mean by RACE here.
>>
>> Here you should already have RTNL lock, so it can't race with any other
>> newlink() calls. In fact you can't acquire RTNL lock in your destructor
>> since register_netdevice() already gets it. Perhaps you mean
>> netdev_run_todo() calls it without RTNL lock?
>>
>> I don't know why you reorder the above list_add(), you can order it
>> as it was before, aka, call it after register_netdevice(), but you have to
>> init the priv->list now for the list_del() on error path.
>
> The race is that there's a state in which priv->list is part of
> list_of_things before the interface is actually successfully setup and
> ready to go.
>
> And no, it's not possible to order it _after_ register_netdevice,
> since register_netdevice might call priv_destructor, and
> priv_destructor calls list_del, so if it's not already on the list,
> we'll OOPS. In otherwords, API problem.


As I said, you have to initialize it, list_del() on an empty head
is literally a nop, why oops?
