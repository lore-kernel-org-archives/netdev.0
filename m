From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 2/3] net: dsa: integrate with SWITCHDEV for
 HW bridging
Date: Tue, 24 Feb 2015 13:21:17 -0800
Message-ID: <54ECEB4D.1050904@gmail.com>
References: <1424808511-18222-1-git-send-email-f.fainelli@gmail.com> <1424808511-18222-3-git-send-email-f.fainelli@gmail.com> <20150224204336.GA18025@roeck-us.net> <54ECE3DF.50503@gmail.com> <20150224205810.GA18293@roeck-us.net> <54ECE770.3090608@gmail.com> <20150224211505.GC18293@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, andrew@lunn.ch,
	cphealy@gmail.com
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34720 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505AbbBXVVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 16:21:37 -0500
Received: by pdjg10 with SMTP id g10so36276338pdj.1
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 13:21:37 -0800 (PST)
In-Reply-To: <20150224211505.GC18293@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/02/15 13:15, Guenter Roeck wrote:
> On Tue, Feb 24, 2015 at 01:04:48PM -0800, Florian Fainelli wrote:
>> On 24/02/15 12:58, Guenter Roeck wrote:
>>> On Tue, Feb 24, 2015 at 12:49:35PM -0800, Florian Fainelli wrote:
>>>> On 24/02/15 12:43, Guenter Roeck wrote:
>>>>> Hi Florian,
>>>>>
>>>>> On Tue, Feb 24, 2015 at 12:08:30PM -0800, Florian Fainelli wrote:
>>>>>> In order to support bridging offloads in DSA switch drivers, select
>>>>>> NET_SWITCHDEV to get access to the port_stp_update and parent_get_id
>>>>>> NDOs that we are required to implement.
>>>>>>
>>>>>> To facilitate the integratation at the DSA driver level, we implement 3
>>>>>> types of operations:
>>>>>>
>>>>>> - port_join_bridge
>>>>>> - port_leave_bridge
>>>>>> - port_stp_update
>>>>>>
>>>>>> DSA will resolve which switch ports that are currently bridge port
>>>>>> members as some Switch hardware/drivers need to know about that to limit
>>>>>> the register programming to just the relevant registers (especially for
>>>>>> slow MDIO buses).
>>>>>>
>>>>>> We also take care of setting the correct STP state when slave network
>>>>>> devices are brought up/down while being bridge members.
>>>>>>
>>>>>> Finally, when a port is leaving the bridge, we make sure we set in
>>>>>> BR_STATE_FORWARDING state, otherwise the bridge layer would leave it
>>>>>> disabled as a result of having left the bridge.
>>>>>>
>>>>>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>>>>>> ---
>>>>> [ ... ]
>>>>>
>>>>>>  
>>>>>> +/* Return a bitmask of all ports being currently bridged within a given bridge
>>>>>> + * device. Note that on leave, the mask will still return the bitmask of ports
>>>>>> + * currently bridged, prior to port removal, and this is exactly what we want.
>>>>>> + */
>>>>>> +static u32 dsa_slave_br_port_mask(struct dsa_switch *ds,
>>>>>> +				  struct net_device *bridge)
>>>>>> +{
>>>>>> +	struct dsa_slave_priv *p;
>>>>>> +	unsigned int port;
>>>>>> +	u32 mask = 0;
>>>>>> +
>>>>>> +	for (port = 0; port < DSA_MAX_PORTS; port++) {
>>>>>> +		if (!((1 << port) & ds->phys_port_mask))
>>>>>> +			continue;
>>>>>> +
>>>>>> +		p = netdev_priv(ds->ports[port]);
>>>>>> +
>>>>>
>>>>> ds->ports[port] can still be NULL here since the function can be called
>>>>> before all ports are initialized (which is what I had actually seen).
>>>>
>>>> Can it now? I re-ordered the patches such that your change comes first
>>>> (and I forgot to update the commit message) and by the time we get
>>>> called from register_netdev(), ds->ports[port] has already been assigned.
>>>>
>>>> Am I missing something here?
>>>
>>> Yes, because phys_port_mask is set to include _all_ ports, not just
>>> the ones already registered.
>>>
>>> Assume ports 0..2 have been registered, phys_port_mask is 0x1f, and
>>> dsa_slave_br_port_mask is called for a state change on port 0.
>>> The loop will check ports 3 and 4 which have not yet been registered.
>>
>> Ok, I re-added the check.
>>
>>>
>>> Strictly speaking we might want to consider adding the same check
>>> into the suspend and resume functions, at least if suspend  /remove
>>> can ever happen before the system is fully initialized.
>>
>> Yes, that is possibly a problem, I don't think I could reproduce that
>> with my current setup because everything needs to be built into the kernel.
> 
> Does suspend/resume have anything to do with building code into the kernel ?

How do you suspend while you are initializing and have not scheduled any
user-space program, that's what I am referring to here, I am guaranteed
that all the slave network interfaces have been created before I even
schedule any user-space application.

> 
> There may be a more practical problem trying to reproduce this; you would
> have to somehow manage to suspend the system in the maybe one second
> or less where phys_port_mask is already initialized but not the slave ports.
> 
> I'll submit a patch to address that problem, just to be sure, following the
> logic of better safe than sorry.
> 
> Would it make sense to introduce a macro such as ds_port_initialized(ds, port)
> or ds_port_configured(ds, port) to check for this condition ? I see that it is
> used it in the bcm_sf2 driver's suspend/remove functions as well.

Sure, go ahead and we can update some of the existing code based on that.
-- 
Florian
