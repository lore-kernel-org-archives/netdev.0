From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] ip[6]: don't register inet[6]dev when dev is down
Date: Sat, 8 Jul 2017 11:44:14 -0700
Message-ID: <CAM_iQpU21rUQ9JWb8qzTs=V+bGC1TZ1HaWC-t1GkUqu5Ymdoxw@mail.gmail.com>
References: <20170705155725.15469-1-nicolas.dichtel@6wind.com> <20170708.110234.1001958921525251511.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Hongjun Li <hongjun.li@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:32843 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753061AbdGHSog (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Jul 2017 14:44:36 -0400
Received: by mail-wr0-f196.google.com with SMTP id x23so15225518wrb.0
        for <netdev@vger.kernel.org>; Sat, 08 Jul 2017 11:44:35 -0700 (PDT)
In-Reply-To: <20170708.110234.1001958921525251511.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 8, 2017 at 3:02 AM, David Miller <davem@davemloft.net> wrote:
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Wed,  5 Jul 2017 17:57:25 +0200
>
>> From: Hongjun Li <hongjun.li@6wind.com>
>>
>> When the netdev event NETDEV_CHANGEMTU is triggered, the inet[6]dev may be
>> created even if the corresponding device is down. This may lead to a leak
>> in the procfs when the device is unregistered, and finally trigger a
>> backtrace:
>  ...
>> When a device changes from one netns to another, it's first unregistered,
>> then the netns reference is updated and the dev is registered in the new
>> netns. Thus, when a slave moves to another netns, it is first
>> unregistered. This triggers a NETDEV_UNREGISTER event which is caught by
>> the bonding driver. The driver calls bond_release(), which calls
>> dev_set_mtu() and thus triggers NETDEV_CHANGEMTU (the device is still in
>> the old netns).
>>
>> Signed-off-by: Hongjun Li <hongjun.li@6wind.com>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
> I'm still not convinced about this.
>
> We have lots of code which iterates ipv6 idevs, and then has a
> check for IFF_UP.
>
> So having an idev attached to a down interface is not a bug nor
> illegal.
>
> In fact, addrconf_cleanup() walks all of the init_net idevs and
> calls addrconf_ifdown() with how=1 regardless of IFF_UP or not.
>
> This entire area is quite a mess.

+1. I fixed a nasty bug with how=1 for loopback before...

>
> Can you show exactly why the procfs state isn't cleaned up for
> these devices moving between namespaces?  Maybe that is the real
> bug and a better place to fix this.
>

It is because the ipv6_add_dev() adds these proc files back after
NETDEV_UNREGISTER event.
