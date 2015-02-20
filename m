From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: Port STP state after removing port from bridge
Date: Fri, 20 Feb 2015 07:03:24 -0800
Message-ID: <CAE4R7bAN7QrJcjUCbAJ86tb9YDNGJfYeq3fdqh-a3Xnc+4S+Zg@mail.gmail.com>
References: <CAGVrzcZMV3vSd3hEsXqk6BtyU-Ts9=oJvb79DTZp25TnnGm5CQ@mail.gmail.com>
	<CAE4R7bBSbwi93t05Z+rB2JgzFYdZ+m44AFSzU7JkwdHRWzz1Mw@mail.gmail.com>
	<20150220100046.GB2008@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:57370 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754195AbbBTPDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 10:03:24 -0500
Received: by mail-qa0-f49.google.com with SMTP id w8so12638155qac.8
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 07:03:24 -0800 (PST)
In-Reply-To: <20150220100046.GB2008@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 20, 2015 at 2:00 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Fri, Feb 20, 2015 at 05:45:01AM CET, sfeldma@gmail.com wrote:
>>On Wed, Feb 18, 2015 at 11:39 PM, Florian Fainelli <f.fainelli@gmail.com>
>>wrote:
>>
>>> Hi,
>>>
>>> It just occured to me that the following sequence:
>>>
>>> brctl addbr br0
>>> brctl addif br0 port0
>>> ... STP happens
>>> brctl delif br0 port0
>>>
>>> will leave port0 in STP disabled state, because the bridge code will
>>> set the STP state to DISABLED, and only a down/up sequence can bring
>>> it back to FORWARDING.
>>>
>>> Is this something that we should somehow fix? As an user it seems a
>>> little convoluted having to do a down/up sequence to restore things. I
>>> believe however that it is valid for the bridge layer to mark a port
>>> as DISABLED when removing it. This is typically not noticed or even
>>> remotely a problem with software bridges because we cannot enforce an
>>> actual STP state at the HW level.
>>>
>>> Let me know your thoughts.
>>>
>>>
>>The fix in rocker would be:
>>
>>diff --git a/drivers/net/ethernet/rocker/rocker.c
>>b/drivers/net/ethernet/rocker/rocker.c
>>index 34389b6a..e2004fb 100644
>>--- a/drivers/net/ethernet/rocker/rocker.c
>>+++ b/drivers/net/ethernet/rocker/rocker.c
>>@@ -4456,8 +4456,10 @@ static int rocker_port_bridge_leave(struct
>>rocker_port *rocker_port)
>>                rocker_port_internal_vlan_id_get(rocker_port,
>>                                                 rocker_port->dev->ifindex);
>>        err = rocker_port_vlan(rocker_port, 0, 0);
>>+       if (err)
>>+               return err;
>>
>>-       return err;
>>+       return rocker_port_stp_update(rocker_port, BR_STATE_FORWARDING);
>> }
>>
>>
>>This will return the port back to it's initial state of
>>BR_STATE_FORWARDING, after it's removed from the bridge.
>>
>>I'll include this patch in the rocker pile to be pushed later.
>>
>>-scott
>
>
> I'm not sure, but wouldn't it be nicer it the bridge code would set
> state to disabled before the port is removed from the bridge?

When the port is removed from a bridge, for example with brctl delif,
the bridge driver puts port in BR_STATE_DISABLED and then sends
netdevice event NETDEV_CHANGEUPPER.  In response to
NETDEV_CHANGEUPPER, the rocker driver is returning port back to
BR_STATE_FORWARDING (the initial state for an un-bridged port).  So
this preserves bridge behavior for non-switchdev uses.  Does this
answer the question, or did I miss understand your question?

-scott
