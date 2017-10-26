From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] Revert "rtnetlink: check DO_SETLINK_NOTIFY correctly
 in do_setlink"
Date: Thu, 26 Oct 2017 12:18:08 +0200
Message-ID: <adf3cc8e-7ff2-2abd-2de3-05bc442ac78f@6wind.com>
References: <47e8fd3f-fa47-0e3b-1041-b931c64aa45b@6wind.com>
 <20171026082153.8042-1-nicolas.dichtel@6wind.com>
 <CADvbK_cbQ5LWYYV189xfo6R=SXpf76u=4CsVCssZeifhNYkCzA@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem <davem@davemloft.net>, network dev <netdev@vger.kernel.org>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Vlad Yasevich <vyasevic@redhat.com>,
        David Ahern <dsahern@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:43266 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751457AbdJZKSL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 06:18:11 -0400
Received: by mail-wm0-f54.google.com with SMTP id m72so18886761wmc.0
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 03:18:11 -0700 (PDT)
In-Reply-To: <CADvbK_cbQ5LWYYV189xfo6R=SXpf76u=4CsVCssZeifhNYkCzA@mail.gmail.com>
Content-Language: fr
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/10/2017 à 11:10, Xin Long a écrit :
[snip]
>> --- a/net/core/rtnetlink.c
>> +++ b/net/core/rtnetlink.c
>> @@ -2251,7 +2251,7 @@ static int do_setlink(const struct sk_buff *skb,
>>
>>  errout:
>>         if (status & DO_SETLINK_MODIFIED) {
>> -               if ((status & DO_SETLINK_NOTIFY) == DO_SETLINK_NOTIFY)
>> +               if (status & DO_SETLINK_NOTIFY)
> Just few questions about this ?
> 
> 1. the check is meaningless here. As it would also return true.
Right.

> 
> 2. why do you think it should be done only for the changes via netlink,
>     what about the changes via net-sysfs, dev_ioctl ?
I don't think it should be done for netlink only. I fixed the problem I
saw/reproduced.

> 
> 3. how about the duplicated notifications issue ?
In fact, it seems it's a bit hard for me to remember exactly how I fixed this in
the past :/

The explanation is in the initial patch:

"The new flag has been set only when the change did not cause a call to the
notifier chain and/or to the netlink notification functions."

It means that each time DO_SETLINK_MODIFY is set, we know that a netlink message
was already sent (by a call to call_netdevice_notifiers() with a event in the
white list of rtnetlink_event() or by a call to rtmsg_ifinfo_event()).

Thus:
1/ your patch is good and this revert is wrong (sorry for that)

2/ When the patch was done, rtnetlink_event() had a black list, not a white list
(see commit 5138e86f1760 ("rtnetlink: Convert rtnetlink_event to white list")).
So, I audit the places where DO_SETLINK_MODIFY is used. A event (in the white
list) is effectively sent when this flag is set.

3/ Vlad, did you find a change for which a netlink message is missing?

Comments are welcomed ;-)

Regards,
Nicolas
