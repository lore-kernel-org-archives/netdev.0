From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next,1/2] add iovnl netlink support
Date: Wed, 21 Apr 2010 16:54:17 -0700
Message-ID: <C7F4DE39.2A4C3%scofeldm@cisco.com>
References: <201004212313.05060.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@redhat.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:51523 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752290Ab0DUXyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 19:54:21 -0400
In-Reply-To: <201004212313.05060.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/21/10 2:13 PM, "Arnd Bergmann" <arnd@arndb.de> wrote:

> On Wednesday 21 April 2010, Scott Feldman wrote:
>> On 4/21/10 12:39 PM, "Arnd Bergmann" <arnd@arndb.de> wrote:
>> 
>>>>> 1. Setting up the slave device
>>>>>  a) create an SR-IOV VF to assign to a guest
>>>>>  b) create a macvtap device to pass to qemu or vhost
>>>>>  c) attach a tap device to a bridge
>>>>>  d) create a macvlan device and put it into a container
>>>>>  e) create a virtual interface for a VMDq adapter
>>>> 
>>>> OK, but iovnl isn't doing this.
>>> 
>>> The set_mac_vlan that Scott's patch adds seems to implement 1a), as far
>>> as I can tell. Interestingly, this is not actually implemented in
>>> the enic driver in patch 2/2. So if we all agree that this is out of the
>>> scope of iovnl, let's just remove it from the interface and find another
>>> way for it (ethtool, iplink, ..., as listed above).
>> 
>> You're right, not needed for enic since mac addr is included with
>> port-profile push and vlan membership is implied by port-profile.  So I put
>> set_mac_vlan in there basically to elicit feedback.
> 
> Ok. Two points though:
> 
> - when you say that the mac address is included in the port-profile push,
>   does that imply that the VF does not have a mac address prior to this?

Correct, VF has no mac addr prior to port-profile being applied.  The
mac_addr is the mac_addr of the VM guest interface that's to use the VF.  If
the port-profile defines L2 mac spoofing, for example, the switch wants to
know the mac address before i/o starts.   I/o doesn't start until
port-profile is applied and the switch virtual port is setup.

>   This would again mix the NIC configuration phase with the switch
>   association, which I think we really need to avoid if we want to be
>   able to implement the association in user space!
> 
> - The VLAN ID being implied in the port profile seems to be another
>   difference between what enic is doing and the current draft VDP
>   that will eventually become 802.1Qbg, and I fear that this difference
>   will be visible in the iovnl protocol.

It's not just a VLAN ID, but the entire VLAN membership for the switch
virtual port.  The port-profile may define a single native VLAN for access
mode on the switch port, or a trunk mode with a list of allowed vlans, with
on native vlan.

The key is the port-profile.  The port-profile resolves the configuration of
the switch virtual port.  The configuration of the switch virtual port
includes many setting like I mentioned earlier: VLAN membership, QoS (rate
limits, priority class, L2 security, etc).
 
>> There really wouldn't be much different between iplink and iovnl since
>> they're both rtnetlink...seems we should keep IOV-related APIs in one place.
>> Maybe there are other IOV APIs to add to iovnl in the future like:
>> 
>>     vf <- add_vf(pf)
>>     del_vf(pf, vf)
>> 
>> Ethtool doesn't seem the right place for this.
> 
> Right. My preference would probably be make these a subcategory of
> the if_link, and use the existing RTM_NEWLINK/RTM_DELLINK commands.
> This would make it resemble the existing interfaces and mean you can
> use
>
> ip link add link eth0 type macvlan    # for a container
> ip link add link eth0 type macvtap    # for qemu/vhost
> ip link add link eth0 type vf         # for device assignment
> 
> There are obviously significant differences between these three, but
> they also share enough of their properties to let us treat them
> in similar ways.
> 

I don't have strong preference for iovnl vs. extending if_link.  I thought I
had a reason against if_link, but I can't recall that now...it'll probably
come to me when I look at it again.  Let me look again...
 
> If we integrate the iovnl client into iproute2, the sequence for setting
> up an enic VF and associating it to the port profile could be
> 
> # create vf0, pass mac and vlan id to HW, no association yet
> ip link add link eth0 name vf0 type vf mac fe:dc:ba:12:34:56 vlan 78
> 
> # associate vf with port profile, mac address must match the one assigned
> #  to the interface before.
> ip iov assoc eth0 port-profile "general" host-uuid
> "dcf2a873-f5ee-41dd-a7ad-802a544e48c2" \
> mac fe:dc:ba:12:34:56

Ya, that sounds pretty close.  I still want the flexibility to direct ops to
a PF link for a VF link.

-scott

