From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Port STP state after removing port from bridge
Date: Sat, 21 Feb 2015 12:26:24 -0800
Message-ID: <CAGVrzcYvmr+5Tv5ioU16pWFeV-MT2CqOCytfDeYqgsOMWOdftg@mail.gmail.com>
References: <CAGVrzcZMV3vSd3hEsXqk6BtyU-Ts9=oJvb79DTZp25TnnGm5CQ@mail.gmail.com>
 <CAE4R7bBSbwi93t05Z+rB2JgzFYdZ+m44AFSzU7JkwdHRWzz1Mw@mail.gmail.com>
 <20150220100046.GB2008@nanopsycho.orion> <CAE4R7bAN7QrJcjUCbAJ86tb9YDNGJfYeq3fdqh-a3Xnc+4S+Zg@mail.gmail.com>
 <54E76912.3090203@gmail.com> <CAE4R7bBY2jF5PfOZOOtKGDRc22-kTr1731kiEpk+O2oE21KgEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:51320 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796AbbBUU1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2015 15:27:06 -0500
Received: by mail-ig0-f169.google.com with SMTP id hl2so13792764igb.0
        for <netdev@vger.kernel.org>; Sat, 21 Feb 2015 12:27:04 -0800 (PST)
In-Reply-To: <CAE4R7bBY2jF5PfOZOOtKGDRc22-kTr1731kiEpk+O2oE21KgEA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-02-21 11:43 GMT-08:00 Scott Feldman <sfeldma@gmail.com>:
> On Fri, Feb 20, 2015 at 9:04 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> On 20/02/15 07:03, Scott Feldman wrote:
>>> On Fri, Feb 20, 2015 at 2:00 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> Fri, Feb 20, 2015 at 05:45:01AM CET, sfeldma@gmail.com wrote:
>>>>> On Wed, Feb 18, 2015 at 11:39 PM, Florian Fainelli <f.fainelli@gmail.com>
>>>>> wrote:
>>>>>
>>>>>> Hi,
>>>>>>
>>>>>> It just occured to me that the following sequence:
>>>>>>
>>>>>> brctl addbr br0
>>>>>> brctl addif br0 port0
>>>>>> ... STP happens
>>>>>> brctl delif br0 port0
>>>>>>
>>>>>> will leave port0 in STP disabled state, because the bridge code will
>>>>>> set the STP state to DISABLED, and only a down/up sequence can bring
>>>>>> it back to FORWARDING.
>>>>>>
>>>>>> Is this something that we should somehow fix? As an user it seems a
>>>>>> little convoluted having to do a down/up sequence to restore things. I
>>>>>> believe however that it is valid for the bridge layer to mark a port
>>>>>> as DISABLED when removing it. This is typically not noticed or even
>>>>>> remotely a problem with software bridges because we cannot enforce an
>>>>>> actual STP state at the HW level.
>>>>>>
>>>>>> Let me know your thoughts.
>>>>>>
>>>>>>
>>>>> The fix in rocker would be:
>>>>>
>>>>> diff --git a/drivers/net/ethernet/rocker/rocker.c
>>>>> b/drivers/net/ethernet/rocker/rocker.c
>>>>> index 34389b6a..e2004fb 100644
>>>>> --- a/drivers/net/ethernet/rocker/rocker.c
>>>>> +++ b/drivers/net/ethernet/rocker/rocker.c
>>>>> @@ -4456,8 +4456,10 @@ static int rocker_port_bridge_leave(struct
>>>>> rocker_port *rocker_port)
>>>>>                rocker_port_internal_vlan_id_get(rocker_port,
>>>>>                                                 rocker_port->dev->ifindex);
>>>>>        err = rocker_port_vlan(rocker_port, 0, 0);
>>>>> +       if (err)
>>>>> +               return err;
>>>>>
>>>>> -       return err;
>>>>> +       return rocker_port_stp_update(rocker_port, BR_STATE_FORWARDING);
>>>>> }
>>>>>
>>>>>
>>>>> This will return the port back to it's initial state of
>>>>> BR_STATE_FORWARDING, after it's removed from the bridge.
>>>>>
>>>>> I'll include this patch in the rocker pile to be pushed later.
>>>>>
>>>>> -scott
>>>>
>>>>
>>>> I'm not sure, but wouldn't it be nicer it the bridge code would set
>>>> state to disabled before the port is removed from the bridge?
>>>
>>> When the port is removed from a bridge, for example with brctl delif,
>>> the bridge driver puts port in BR_STATE_DISABLED and then sends
>>> netdevice event NETDEV_CHANGEUPPER.  In response to
>>> NETDEV_CHANGEUPPER, the rocker driver is returning port back to
>>> BR_STATE_FORWARDING (the initial state for an un-bridged port).  So
>>> this preserves bridge behavior for non-switchdev uses.  Does this
>>> answer the question, or did I miss understand your question?
>>
>> I think what we want is a solution at the bridge level, we have rocker
>> now updating the STP state to BR_STATE_FORWARDING when a given
>> rocker_port leaves a bridge, and I also had a similar change in DSA.
>>
>> Something like this maybe (untested):
>>
>> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
>> index b087d278c679..d693a2a10b3c 100644
>> --- a/net/bridge/br_if.c
>> +++ b/net/bridge/br_if.c
>> @@ -242,6 +242,8 @@ static void del_nbp(struct net_bridge_port *p)
>>
>>         spin_lock_bh(&br->lock);
>>         br_stp_disable_port(p);
>> +       if (dev->features & NETIF_F_HW_SWITCH_OFFLOAD)
>> +               br_set_state(p, BR_STATE_FORWARDING);
>>         spin_unlock_bh(&br->lock);
>>
>>         br_ifinfo_notify(RTM_DELLINK, p);
>
> Acked-by: Scott Feldman <sfeldma@gmail.com>
>
> I like it.  I tested your version with rocker and it works great.  (I
> removed my version).  Would you push this one when things open up?

Ok, thanks for testing!
-- 
Florian
