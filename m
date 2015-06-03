From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC 3/9] net: dsa: mv88e6xxx: add support for VTU ops
Date: Tue, 2 Jun 2015 23:53:16 -0700
Message-ID: <CAE4R7bCEqszSew4RadLoB-PcY0g74F+sLKQL42TgsfG8_89_Kg@mail.gmail.com>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1433208470-25338-4-git-send-email-vivien.didelot@savoirfairelinux.com>
 <556D522E.90607@roeck-us.net> <CAE4R7bChwW1awn8V6k7bF13v15_kPF0ui3NvyV2WkqN0XuTUqw@mail.gmail.com>
 <556E2EC2.3020104@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>,
	Chris Healy <cphealy@gmail.com>
To: nolan <nolan@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:34816 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783AbbFCGxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 02:53:37 -0400
In-Reply-To: <556E2EC2.3020104@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 2, 2015 at 3:31 PM, nolan <nolan@cumulusnetworks.com> wrote:
> On 06/02/2015 12:44 AM, Scott Feldman wrote:
>>
>> That brings up an interesting point about having multiple bridges with
>> the same vlan configured.  I struggled with that problem with rocker
>> also and I don't have an answer other than "don't do that".  Or,
>> better put, if you have multiple bridge on the same vlan, just use one
>> bridge for that vlan.  Otherwise, I don't know how at the device level
>> to partition the vlan between the bridges.  Maybe that's what Vivien
>> is facing also?  I can see how this works for software-only bridges,
>> because they should be isolated from each other and independent.  But
>> when offloading to a device which sees VLAN XXX global across the
>> entire switch, I don't see how we can preserve the bridge boundaries.
>
>
> Scott,
>
> I'm confused by this.  I think you're saying this config is problematic:
>
> br0: eth0.100, eth1.100
> br1: eth2.100, eth3.100
>
>
> But this works fine today.

Ya, this is going to work because br0 and br1 are bridging untagged
traffic, but br0 and br1 have different internal VLAN ids for untagged
traffic, so there is no crosstalk between bridges.

(I'm assuming since you used the ethX.100 format, you've vconfig
created a vlan interface on ethX and added the vlan interface to brY).
The vlan interface eats the vlan tag and the bridge sees untagged
traffic.

> Could you clarify the issue you're referring to?

I'm talking about bridging tagged traffic.  E.g.:

ip link add name br0 type bridge
ip link add name br1 type bridge

ip link set dev sw1p1 master br0
ip link set dev sw1p2 master br0
ip link set dev sw1p3 master br1
ip link set dev sw1p4 master br1

bridge vlan add vid 100 dev sw1p1
bridge vlan add vid 100 dev sw1p2
bridge vlan add vid 100 dev sw1p3
bridge vlan add vid 100 dev sw1p4

Now the ports are trunking vlan 100 and the bridge/device see tagged
traffic.  If the device used floods vlan 100 pkt to all ports in vlan
100, it'll flood to a port outside the bridge.  Oops!  For the device
I'm using (rocker w/ OF-DPA) the bridging table matches on vlan ID and
mac_dst.  There is no prevision to isolate vlans per bridge.

How do you solve the above case with your hardware?
