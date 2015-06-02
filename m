From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC 0/3] DSA and Marvell 88E6352 802.1q support
Date: Mon, 1 Jun 2015 20:18:43 -0400 (EDT)
Message-ID: <429136619.719334.1433204323286.JavaMail.zimbra@savoirfairelinux.com>
References: <556723FF.7030606@roeck-us.net> <1432849035-8499-1-git-send-email-vivien.didelot@savoirfairelinux.com> <CAE4R7bA43Jg5e+DSySvG4X2ka0CXEk9K6eVv5fdN37EcLBoF_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	=?utf-8?Q?J=C3=A9rome?= Oufella
	<jerome.oufella@savoirfairelinux.com>,
	Chris Healy <cphealy@gmail.com>, Jiri Pirko <jiri@resnulli.us>
To: Scott Feldman <sfeldma@gmail.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:58609 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755124AbbFBASs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 20:18:48 -0400
In-Reply-To: <CAE4R7bA43Jg5e+DSySvG4X2ka0CXEk9K6eVv5fdN37EcLBoF_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 29, 2015, at 1:02 AM, Scott Feldman sfeldma@gmail.com wrote:
> On Thu, May 28, 2015 at 2:37 PM, Vivien Didelot <vivien.didelot@savoirfairelinux.com> wrote:
>> This RFC is based on v4.1-rc3.
>>
>> It is meant to get a glance to the commits responsible to implement the
>> necessary NDOs between DSA and the Marvell 88E6352 switch driver.
>>
>> With this support, I am able to create VLANs with (un)tagged ports, setting
>> their default VID, from a bridge.
>>
>> To create a bridge containing all switch ports, with a VLAN ID 400, swp2 and
>> swp3 untagged (pvid), and swp4 tagged, the userspace commands look like this:
>>
>>     ip link add name br0 type bridge
>>     [...]
>>     ip link set dev swp2 up master br0
>>     [...]
>>     bridge vlan add vid 400 pvid untagged dev swp2
>>     bridge vlan add vid 400 pvid untagged dev swp3
>>     bridge vlan add vid 400 dev swp4
>>     [...]
>>     ip link add link br0 name br0.400 type vlan id 400
>>     [...]
>>     bridge vlan add dev br0 vid 400 self
>>
>> The code is currently being rebased to the latest net-next/master.
>>
>> Seems like the way to go now is through switchdev attr getter/setter...
> 
> Indeed, for dsa_slave you should be able to port this to switchdev and
> set your ndo_bridge_setlink/dellink handlers to
> switchdev_port_bridge_setlink/dellink.  (And also implement the
> switchdev ops for vlans).
> 
> If you use switchdev_port_bridge_setlink/dellink, you shouldn't need
> to implement ndo_vlan_rx_add_vid/ndo_vlan_rx_kill_vid at all.

Scott,

In fact I have to define these ndo, otherwise I get the "Buggy VLAN
acceleration in driver!" warning from net/core/dev.c and the switch
ports won't register.

I'm actually defining a noop function for them in dsa_slave_netdev_ops.

Is it correct to set NETIF_F_HW_VLAN_CTAG_FILTER in slave_dev->features?

> The setlink/dellink callbacks will give the same info (and more, e.g.
> pvid, untagged flags) and you'll automatically get support for stacked
> drivers, for example if you bonded swp2/3 and then included that bond
> in your vlan bridge.  Your commands will be slightly modified: when
> adding the vid to the port, specify master and self:
> 
> bridge vlan add vid 400 dev swp4 master self

Thanks it works! Now the switch VLAN database is consistent with the
bridge commands, I'm sending a complete RFC very soon.

Scott, David,

I use this mail to expose a potential problem between iproute2 and the
kernel, found with my previous code. When issuing "ip link set dev swp0
master br0", ndo_vlan_rx_add_vid is called, but not ndo_bridge_setlink,
which results in an inconsistency between my switch VLAN database (and
port settings) and "bridge vlan", which shows "swp0   1 PVID Egress
Untagged".

Seems like there is a call to ndo_bridge_setlink to add somewhere, but I
have no clue where.

In the meantime, I call "bridge vlan add vid 1 dev swp0 pvid untagged
[master self]" at boot, to be consistent with the bridge output.

Thanks,
-v
