From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/4] net: dsa: mv88e6xxx: fix hardware bridging
Date: Wed, 14 Oct 2015 18:44:42 -0700
Message-ID: <561F050A.6060708@gmail.com>
References: <1444601318-20561-1-git-send-email-vivien.didelot@savoirfairelinux.com> <20151014224617.GA10146@lunn.ch> <20151015012854.GA10868@ketchup.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151015012854.GA10868@ketchup.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14/10/15 18:28, Vivien Didelot wrote:
> On Oct. Thursday 15 (42) 12:46 AM, Andrew Lunn wrote:
>> On Sun, Oct 11, 2015 at 06:08:34PM -0400, Vivien Didelot wrote:
>>> DSA and its drivers currently hook the NETDEV_CHANGEUPPER net_device event in
>>> order to configure the VLAN map of every port.
>>>
>>> This VLAN map is a feature of these switch chips to hardcode and restrict which
>>> output ports a given input port can egress frames to.
>>>
>>> A Linux bridge is a simple untagged VLAN propagated by the bridge code itself.
>>> With a proper 802.1Q support, a driver does not need this hook anymore, and
>>> will simply program the related VLAN object.
>>>
>>> This patchset improves the hardware bridging code in the mv88e6xxx driver with
>>> a strict 802.1Q mode.
>>
>> Hi Vivien
>>
>> I just tested this as part of net-next/master, and found a problem....
>>
>> If i do:
>>
>> ip link set lan0 up
>> ip addr add 192.168.10.2/24 dev lan0
>>
>> It will not ping. Looking in sys/kernel/debug/dsa0/stats i see
>> broadcast packets, probably ARP, being received at the port.
>> But they are not being forwarded out the CPU port.
>>
>> If however i do
>>
>> brctl addbr br0
>> brctl addif br0 lan0
>> ip addr add 192.168.10.2/24 dev br0
>> ip link set br0 up
>>
>> i can ping.
>>
>> So it looks like we are too restrictive by default. You should be able
>> to use interfaces as they are, without a bridge.
> 
> Correct, if the ports are not in a VLAN by default, they cannot talk.

The expectation for DSA devices, if no bridge device is configured is to
have each port be able to talk to the CPU port only, but this has to
work out of the box.

> 
> If you want to, I think the special VLAN 0 can be used for that purpose.
> IIRC, in a given configuration, Linux add the interfaces (thus programs
> the hardware) with VLAN 0. I'm not sure when, maybe when the
> .ndo_vlan_rx_add_vid is implemented, I need to give it a shot.

But if you do that, won't that put all DSA ports into VLAN 0? Would not
that break isolation between each ports as expected for a DSA switch?

> 
> Otherwise, I can send you a patch configuring the VLAN 0 on switch
> setup if this is the behavior we want.
> 
> Thanks,
> -v
> 


-- 
Florian
