From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [net-next v3] bridge: trigger RTM_NEWLINK when interface is
 modified by bridge ioctl
Date: Thu, 21 Sep 2017 10:20:12 -0700
Message-ID: <CAJieiUjqttMeC24CzDa8Y8g=opRKoa2hbG2Cb+78u632vA3uqw@mail.gmail.com>
References: <20170920162140.369bb198@xeon-e3> <20170921100525.20395-1-vincent@bernat.im>
 <0cdf06b9-e67d-c035-e0f1-c4eb143bf631@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Vincent Bernat <vincent@bernat.im>,
        Stephen Hemminger <stephen@networkplumber.org>,
        David Miller <davem@davemloft.net>,
        bridge@lists.linux-foundation.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f177.google.com ([209.85.217.177]:54419 "EHLO
        mail-ua0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752450AbdIURUO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 13:20:14 -0400
Received: by mail-ua0-f177.google.com with SMTP id l94so4056333ual.11
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 10:20:13 -0700 (PDT)
In-Reply-To: <0cdf06b9-e67d-c035-e0f1-c4eb143bf631@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 21, 2017 at 9:43 AM, David Ahern <dsahern@gmail.com> wrote:
> On 9/21/17 4:05 AM, Vincent Bernat wrote:
>> Currently, there is a difference in netlink events received when an
>> interface is modified through bridge ioctl() or through netlink. This
>> patch generates additional events when an interface is added to or
>> removed from a bridge via ioctl().
>>
>> When adding then removing an interface from a bridge with netlink, we
>> get:
>>
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master bridge0 state UNKNOWN group default
>>     link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
>>     link/ether 9e:da:60:ee:cf:c8
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
>>     link/ether 9e:da:60:ee:cf:c8
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
>>     link/ether 9e:da:60:ee:cf:c8
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
>>     link/ether 9e:da:60:ee:cf:c8
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master bridge0 state UNKNOWN group default
>>     link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff
>>
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master bridge0 state UNKNOWN group default
>>     link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
>>     link/ether 9e:da:60:ee:cf:c8
>> Deleted 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
>>     link/ether 9e:da:60:ee:cf:c8
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default
>>     link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff
>>
>> When using ioctl():
>>
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master bridge0 state UNKNOWN group default
>>     link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
>>     link/ether 9e:da:60:ee:cf:c8
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
>>     link/ether 9e:da:60:ee:cf:c8
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
>>     link/ether 9e:da:60:ee:cf:c8
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master bridge0 state UNKNOWN group default
>>     link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff
>>
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master bridge0 state UNKNOWN group default
>>     link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
>>     link/ether 9e:da:60:ee:cf:c8
>> Deleted 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
>>     link/ether 9e:da:60:ee:cf:c8
>> 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default
>>     link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff
>>
>> Without this patch, the last netlink notification is not sent.
>>
>> Signed-off-by: Vincent Bernat <vincent@bernat.im>
>> ---
>>  net/bridge/br_ioctl.c | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
>> index 7970f8540cbb..66cd98772051 100644
>> --- a/net/bridge/br_ioctl.c
>> +++ b/net/bridge/br_ioctl.c
>> @@ -102,6 +102,9 @@ static int add_del_if(struct net_bridge *br, int ifindex, int isadd)
>>       else
>>               ret = br_del_if(br, dev);
>>
>> +     if (!ret)
>> +             rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_MASTER, GFP_KERNEL);
>> +
>>       return ret;
>>  }
>>
>>
>
> Agreed that this is needed for userspace to know about the master change
> when done through ioctl. The bridge code is emitting a lot of what
> appears to be redundant messages for both paths (netlink and ioctl).
>
> Reviewed-by: David Ahern <dsahern@gmail.com>
>


this patch seems fine...but ideally I would have assumed
netdev_upper_dev_unlink which
is eventually called in both paths would generate the RTN_NEWLINK
IFF_MASTER in response
to the NETDEV_CHANGEUPPER notifier. If we add it there now, it might
need some more fixes
to not generate redundant notifications for the netlink case.
