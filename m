From: John Crispin <john@phrozen.org>
Subject: Re: dsa: handling more than 1 cpu port
Date: Wed, 14 Dec 2016 16:45:42 +0100
Message-ID: <f0a13fbd-863e-99e0-579d-6623cf68a069@phrozen.org>
References: <1671ae82-c213-7611-584f-02a3b1d5dff9@phrozen.org>
 <20161214103153.GC27370@lunn.ch>
 <0f82a785-b31c-0428-eb07-a9464a0c5ddd@phrozen.org>
 <20161214110058.GE27370@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:49780 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932789AbcLNPp5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Dec 2016 10:45:57 -0500
In-Reply-To: <20161214110058.GE27370@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 14/12/2016 12:00, Andrew Lunn wrote:
> On Wed, Dec 14, 2016 at 11:35:30AM +0100, John Crispin wrote:
>>
>>
>> On 14/12/2016 11:31, Andrew Lunn wrote:
>>> On Wed, Dec 14, 2016 at 11:01:54AM +0100, John Crispin wrote:
>>>> Hi Andrew,
>>>>
>>>> switches supported by qca8k have 2 gmacs that we can wire an external
>>>> mii interface to. Usually this is used to wire 2 of the SoCs MACs to the
>>>> switch. Thw switch itself is aware of one of the MACs being the cpu port
>>>> and expects this to be port/mac0. Using the other will break the
>>>> hardware offloading features.
>>>
>>> Just to be sure here. There is no way to use the second port connected
>>> to the CPU as a CPU port?
>>
>> both macs are considered cpu ports and both allow for the tag to be
>> injected. for HW NAT/routing/... offloading to work, the lan ports neet
>> to trunk via port0 and not port6 however.
> 
> Maybe you can do a restricted version of the generic solution. LAN
> ports are mapped to cpu port0. WAN port to cpu port 6?
> 
>>> The Marvell chips do allow this. So i developed a proof of concept
>>> which had a mapping between cpu ports and slave ports. slave port X
>>> should you cpu port y for its traffic. This never got past proof of
>>> concept. 
>>>
>>> If this can be made to work for qca8k, i would prefer having this
>>> general concept, than specific hacks for pass through.
>>
>> oh cool, can you send those patches my way please ? how do you configure
>> this from userland ? does the cpu port get its on swdev which i just add
>> to my lan bridge and then add the 2nd cpu port to the wan bridge ?
> 
> https://github.com/lunn/linux/tree/v4.1-rc4-net-next-multiple-cpu
> 
> You don't configure anything from userland. Which was actually a
> criticism. It is in device tree. But my solution is generic. Having
> one WAN port and four bridges LAN ports is a pure marketing
> requirement. The hardware will happily do two WAN ports and 3 LAN
> ports, for example. And the switch is happy to take traffic for the
> WAN port and a LAN port over the same CPU port, and keep the traffic
> separate. So we can have some form of load balancing. We are not
> limited to 1->1, 1->4, we can do 1->2, 1->3 to increase the overall
> performance. And to the user it is all transparent.
> 
> This PoC is for the old DSA binding. The new binding makes it easier
> to express this. Which is one of the reasons for the new binding.
> 
> 	Andrew
> 

Hi Andrew,

spent some time looking at this and thinking about possible solutions.
my initial idea was to detect which cpu port to based on the cpu port
being included inside the bridge. however that wont allow us to control
ports using the tag outside of a bridge. i think that your approach is
the only sane one. we could add a sysfs interface later, allowing us to
change the default cpu port <-> mappings, but the device tree needs to
include some sane defaults. i'll use your patches as a base for a series.

	John
