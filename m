From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH RFC v1 0/7] net: phy: Ethernet PHY powerdown optimization
Date: Wed, 20 Nov 2013 22:20:50 +0100
Message-ID: <528D27B2.4000707@gmail.com>
References: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com> <20131120.153642.2045230991917379052.davem@davemloft.net> <528D217B.5020500@gmail.com> <CAGVrzcZ5wV2eHPNfr-xToOEc6jbBJXiNQ+OtZv2j+yGbS9YW-w@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:38412 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755254Ab3KTVUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 16:20:55 -0500
In-Reply-To: <CAGVrzcZ5wV2eHPNfr-xToOEc6jbBJXiNQ+OtZv2j+yGbS9YW-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/20/2013 10:10 PM, Florian Fainelli wrote:
> 2013/11/20 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>:
>> On 11/20/2013 09:36 PM, David Miller wrote:
>>>
>>> From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
>>> Date: Wed, 20 Nov 2013 21:21:46 +0100
>>>
>>>> Ethernet PHYs consume a significant amount of power when link is
>>>> detected.
>>>> Especially, for embedded systems it can be easily 20-40% of total system
>>>> power. Now, currently most likely all ethernet drivers leave PHYs powered
>>>> on, even if the device is taken down. Also, some stupid boot loaders
>>>> power
>>>> on all PHYs available.
>>>>
>>>> This RFC deals with saving power consumed by ethernet PHYs, that have no
>>>> corresponding ethernet device driver or are attached to ethernet devices
>>>> which are taken down by user request, i.e. ifconfig ethN down. Ports with
>>>> no link, i.e. cable removed, are already quite good at power saving due
>>>> to
>>>> PHY internal link detection.
>>>
>>>
>>> The idea is sound and the goal is of course valuable, but it brings up
>>> a chronically reoccurring issue as of late.
>>>
>>> You cannot reset the PHY or take it down without somehow retaining the
>>> settings the PHY had when you bring it back up.
>>
>>
>> Right, as far as I understand BMCR powerdown, i.e. what is called in
>> genphy_suspend/resume, powers down the PHY but _does_ retain PHY config.
>> It is not resetting the device.
>
> Right that's also my understanding of how BMCR powerdown works. That
> said, I am relatively sure that we can find PHY devices for which this
> is not true.

No doubt.

> As for the PHY state machine, I think we need a new state
> PHY_SUSPENDED  and upon calling phy_start() we make sure that we treat
> PHY_SUSPENDED just like we treat PHY_HALTED today since that would
> make sure that the PHY parameters are applied correctly upon resume
> (interrupt configuration, autoneg and and such).
>
> There is still some discussion on how we should deal with
> auto-suspending the PHY when phy_stop() is called, and how does that
> differ from the PHY_HALTED state? So this also raises the question of
> whether PHY_HALTED is really different from PHY_SUSPENDED. The only
> difference with your patches would be that we have put the PHY into a
> low-power mode.

Well, I haven't thought about WoL and stuff and how the driver should
leave the PHY for that to work. Suspend support isn't really spread
among ARM SoCs :P

But if you can run some tests on non-ARM platforms you might already
been testing with, I am sure we can work it out. Maybe, we just have
PHY_SUSPENDED and deal with it differently if any regressions pop up?

Also, suspend_unused and auto-suspend on phy_stop can be disabled by
default for some kernel versions until we have enough coverage?

>> I haven't checked a lot of datasheets but [1] notes that "registers will
>> preserve their configuration". Even if we have PHYs that do not preserve
>> it, they should have a device specific callback for suspend/resume that
>> takes care of preserving it.
>
> Right, but the PHY driver should only take care of restoring "state
> less" PHY context, while the PHY state machine has to restore a "state
> aware" PHY device context. So for quirky PHY chips, or those having
> advanced power management features, we definitively need the two to be
> helping each other.

I see it was a good idea to send the RFC early. The savings are
impressive but I was already quite sure that it has the potential to
break (at least) the quirky PHYs.

Sebastian

>>
>> [1] http://www.ti.com/lit/an/snoa463a/snoa463a.pdf
>>
>>
>>> If I ifdown/ifup a device, my ethtool link configuration better be
>>> retained.
>>>
>>> This means the PHY layer must have a way to reprogram the device when
>>> it is brought back up, with whatever settings the software state
>>> things are there.
>>>
>>
>>
>> _______________________________________________
>> linux-arm-kernel mailing list
>> linux-arm-kernel@lists.infradead.org
>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>
>
>
