From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC 0/3] DSA and Marvell 88E6352 802.1q support
Date: Tue, 2 Jun 2015 19:23:46 -0400 (EDT)
Message-ID: <116966215.858744.1433287426356.JavaMail.zimbra@savoirfairelinux.com>
References: <556723FF.7030606@roeck-us.net> <1432849035-8499-1-git-send-email-vivien.didelot@savoirfairelinux.com> <CAE4R7bA43Jg5e+DSySvG4X2ka0CXEk9K6eVv5fdN37EcLBoF_A@mail.gmail.com> <429136619.719334.1433204323286.JavaMail.zimbra@savoirfairelinux.com> <CAE4R7bCOVF6hT1-s5a5+Fs-06ks478Y3EZ45NTA4QNpy5uu9nw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David <davem@davemloft.net>, netdev <netdev@vger.kernel.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	=?utf-8?Q?J=C3=A9rome?= Oufella
	<jerome.oufella@savoirfairelinux.com>,
	Chris Healy <cphealy@gmail.com>, Jiri Pirko <jiri@resnulli.us>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:58423 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443AbbFBXXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 19:23:51 -0400
In-Reply-To: <CAE4R7bCOVF6hT1-s5a5+Fs-06ks478Y3EZ45NTA4QNpy5uu9nw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Scott,

On Jun 2, 2015, at 2:18 AM, Scott Feldman sfeldma@gmail.com wrote:
> On Mon, Jun 1, 2015 at 5:18 PM, Vivien Didelot
> <vivien.didelot@savoirfairelinux.com> wrote:
>>
>> On May 29, 2015, at 1:02 AM, Scott Feldman sfeldma@gmail.com wrote:
>>> On Thu, May 28, 2015 at 2:37 PM, Vivien Didelot
>>> <vivien.didelot@savoirfairelinux.com> wrote:
>>>> This RFC is based on v4.1-rc3.
>>>>
>>>> It is meant to get a glance to the commits responsible to implement the
>>>> necessary NDOs between DSA and the Marvell 88E6352 switch driver.
>>>>
>>>> With this support, I am able to create VLANs with (un)tagged ports, setting
>>>> their default VID, from a bridge.
>>>>
>>>> To create a bridge containing all switch ports, with a VLAN ID 400, swp2 and
>>>> swp3 untagged (pvid), and swp4 tagged, the userspace commands look like this:
>>>>
>>>>     ip link add name br0 type bridge
>>>>     [...]
>>>>     ip link set dev swp2 up master br0
>>>>     [...]
>>>>     bridge vlan add vid 400 pvid untagged dev swp2
>>>>     bridge vlan add vid 400 pvid untagged dev swp3
>>>>     bridge vlan add vid 400 dev swp4
>>>>     [...]
>>>>     ip link add link br0 name br0.400 type vlan id 400
>>>>     [...]
>>>>     bridge vlan add dev br0 vid 400 self
>>>>
>>>> The code is currently being rebased to the latest net-next/master.
>>>>
>>>> Seems like the way to go now is through switchdev attr getter/setter...
>>>
>>> Indeed, for dsa_slave you should be able to port this to switchdev and
>>> set your ndo_bridge_setlink/dellink handlers to
>>> switchdev_port_bridge_setlink/dellink.  (And also implement the
>>> switchdev ops for vlans).
>>>
>>> If you use switchdev_port_bridge_setlink/dellink, you shouldn't need
>>> to implement ndo_vlan_rx_add_vid/ndo_vlan_rx_kill_vid at all.
>>
>> Scott,
>>
>> In fact I have to define these ndo, otherwise I get the "Buggy VLAN
>> acceleration in driver!" warning from net/core/dev.c and the switch
>> ports won't register.
>>
>> I'm actually defining a noop function for them in dsa_slave_netdev_ops.
>>
>> Is it correct to set NETIF_F_HW_VLAN_CTAG_FILTER in slave_dev->features?
> 
> If your nooping ndo VLAN ops then just remove setting
> NETIF_F_HW_VLAN_CTAG_FILTER and then you can remove the noop funcs.
> 
>>> The setlink/dellink callbacks will give the same info (and more, e.g.
>>> pvid, untagged flags) and you'll automatically get support for stacked
>>> drivers, for example if you bonded swp2/3 and then included that bond
>>> in your vlan bridge.  Your commands will be slightly modified: when
>>> adding the vid to the port, specify master and self:
>>>
>>> bridge vlan add vid 400 dev swp4 master self
>>
>> Thanks it works! Now the switch VLAN database is consistent with the
>> bridge commands, I'm sending a complete RFC very soon.
>>
>> Scott, David,
>>
>> I use this mail to expose a potential problem between iproute2 and the
>> kernel, found with my previous code. When issuing "ip link set dev swp0
>> master br0", ndo_vlan_rx_add_vid is called, but not ndo_bridge_setlink,
> 
> Remove NETIF_F_HW_VLAN_CTAG_FILTER and ndo_vlan_rx_add_vid will not be called.
> 
> Issuing "ip link set dev swp0 master br0" should only be setting the
> bridge member, not setting up any VLAN.  I suspect when you did this
> swp0 was admin UP and you're getting untagged VLAN 0 installed, which
> is the call to ndo_vlan_rx_add_vid.
> 
>> which results in an inconsistency between my switch VLAN database (and
>> port settings) and "bridge vlan", which shows "swp0   1 PVID Egress
>> Untagged".
> 
> So that is a result of /sys/class/net/br0/bridge/default_pvid set to
> 1.  If you don't want that, turn default_pvid off:
> 
> echo 0 >/sys/class/net/br0/bridge/default_pvid
> 
> Now you'll see "None" in the "bridge vlan" output.
> 
>> Seems like there is a call to ndo_bridge_setlink to add somewhere, but I
>> have no clue where.
>>
>> In the meantime, I call "bridge vlan add vid 1 dev swp0 pvid untagged
>> [master self]" at boot, to be consistent with the bridge output.
> 
> Or turn off default_pvid.

Thanks, I confirm both fixes work. Thanks a lot.
-v
