From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH] bridge: Enable configuration of ageing interval for
 bridges and switch devices.
Date: Wed, 19 Aug 2015 10:53:57 -0700
Message-ID: <CAE4R7bD-r1=xo2+HMKdPpf7A3Vd7SXYsxm=xC0oNANtuG+F4iw@mail.gmail.com>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9E1E8D@SJEXCHMB14.corp.ad.broadcom.com>
 <alpine.DEB.2.02.1508172358470.13562@rocker1.rocker.net> <77EF4405DD4BB54AACCE7DB593DF6A9A9E2BFE@SJEXCHMB14.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Premkumar Jonnala <pjonnala@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:36218 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752396AbbHSRyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 13:54:17 -0400
Received: by oiev193 with SMTP id v193so7785532oie.3
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 10:54:17 -0700 (PDT)
In-Reply-To: <77EF4405DD4BB54AACCE7DB593DF6A9A9E2BFE@SJEXCHMB14.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 19, 2015 at 2:34 AM, Premkumar Jonnala
<pjonnala@broadcom.com> wrote:
> Hello Scott,
>
> Thank you for the diff and comments.   Please see my comments inline.
>
>> -----Original Message-----
>> From: Scott Feldman [mailto:sfeldma@gmail.com]
>> Sent: Tuesday, August 18, 2015 12:48 PM
>> To: Premkumar Jonnala
>> Cc: netdev@vger.kernel.org
>> Subject: Re: [PATCH] bridge: Enable configuration of ageing interval for bridges
>> and switch devices.
>>
>>
>>
>> On Fri, 14 Aug 2015, Premkumar Jonnala wrote:
>>
>> > Bridge devices have ageing interval used to age out MAC addresses
>> > from FDB.  This ageing interval was not configuratble.
>> >
>> > Enable netlink based configuration of ageing interval for bridges and
>> > switch devices.  The ageing interval changes the timer used to purge
>> > inactive FDB entries in bridges.  The ageing interval config is
>> > propagated to switch devices, so that platform or hardware based
>> > ageing works according to configuration.
>> >
>> > Signed-off-by: Premkumar Jonnala <pjonnala@broadcom.com>
>>
>> Hi Premkumar,
>>
>> I agree with Roopa that we should use existing IFLA_BR_AGEING_TIME.
>
> What is the motivation for using 'ip link' command to configure bridge attributes?  IMHO,
> bridge command is better suited for that.

Can you extend bridge command to allow setting/getting these bridge
attrs?  Looks like you construct a RTM_NEWLINK IFLA_INFO_DATA msg.  No
changes needed to the kernel.

bridge link set dev br0 ageing_time 1000

 --or--

ip link set dev br0 type bridge ageing_time 1000

>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>> index 0f2408f..01401ea 100644
>> --- a/net/bridge/br_netlink.c
>> +++ b/net/bridge/br_netlink.c
>> @@ -759,9 +759,9 @@ static int br_changelink(struct net_device *brdev, struct
>> nlattr *tb[],
>>       }
>>
>>       if (data[IFLA_BR_AGEING_TIME]) {
>> -             u32 ageing_time = nla_get_u32(data[IFLA_BR_AGEING_TIME]);
>
> Should we do some range checking here to ensure that the value is within a certain range.
> IEEE 802.1d recommends that the ageing time be between 10 sec and 1 million seconds.

Sure, but make that a separate patch.

>> +int br_set_ageing_time(struct net_bridge *br, u32 ageing_time)
>> +{
>> +     struct switchdev_attr attr = {
>> +             .id = SWITCHDEV_ATTR_BRIDGE,
>> +             .flags = SWITCHDEV_F_SKIP_EOPNOTSUPP,
>> +             .u.bridge.attr = IFLA_BR_AGEING_TIME,
>> +             .u.bridge.val = ageing_time,
>> +     };
>> +     int err;
>> +
>> +     err = switchdev_port_attr_set(br->dev, &attr);
>> +     if (err)
>> +             return err;
>> +
>> +     br->ageing_time = clock_t_to_jiffies(ageing_time);
>
> Should we restart the timer here the new time takes effect?

I don't know...I just copied what the original code did.  If it does
need to be restarted, break that out as a separate patch.

-scott
