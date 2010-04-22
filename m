From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next,1/2] add iovnl netlink support
Date: Thu, 22 Apr 2010 14:49:23 +0200
Message-ID: <201004221449.23398.arnd@arndb.de>
References: <C7F4DE39.2A4C3%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:49284 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754522Ab0DVMt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 08:49:28 -0400
In-Reply-To: <C7F4DE39.2A4C3%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 22 April 2010, Scott Feldman wrote:
> On 4/21/10 2:13 PM, "Arnd Bergmann" <arnd@arndb.de> wrote:
> > On Wednesday 21 April 2010, Scott Feldman wrote:
> >> On 4/21/10 12:39 PM, "Arnd Bergmann" <arnd@arndb.de> wrote:
> >> You're right, not needed for enic since mac addr is included with
> >> port-profile push and vlan membership is implied by port-profile.  So I put
> >> set_mac_vlan in there basically to elicit feedback.
> > 
> > Ok. Two points though:
> > 
> > - when you say that the mac address is included in the port-profile push,
> >   does that imply that the VF does not have a mac address prior to this?
> 
> Correct, VF has no mac addr prior to port-profile being applied.  The
> mac_addr is the mac_addr of the VM guest interface that's to use the VF.  If
> the port-profile defines L2 mac spoofing, for example, the switch wants to
> know the mac address before i/o starts.   I/o doesn't start until
> port-profile is applied and the switch virtual port is setup.

Is it possible to split this this process, in order to make it more
closely resemble what we have when the registration is in user space?
This would mean that you assign a MAC address to the interface when the
interface gets created, and register the same MAC address at the switch
independent from the creation.

Obviously, if the port-profile (for enic) or the VSI list in the switch
enforces a the mac address and you pass one that's different from the
one that's set in the VF, it won't be able to send any data, but it
remains the job of the switch to enforce that case.

> It's not just a VLAN ID, but the entire VLAN membership for the switch
> virtual port.  The port-profile may define a single native VLAN for access
> mode on the switch port, or a trunk mode with a list of allowed vlans, with
> on native vlan.
> 
> The key is the port-profile.  The port-profile resolves the configuration of
> the switch virtual port.  The configuration of the switch virtual port
> includes many setting like I mentioned earlier: VLAN membership, QoS (rate
> limits, priority class, L2 security, etc).

Ok, I see.

> > If we integrate the iovnl client into iproute2, the sequence for setting
> > up an enic VF and associating it to the port profile could be
> > 
> > # create vf0, pass mac and vlan id to HW, no association yet
> > ip link add link eth0 name vf0 type vf mac fe:dc:ba:12:34:56 vlan 78
> > 
> > # associate vf with port profile, mac address must match the one assigned
> > #  to the interface before.
> > ip iov assoc eth0 port-profile "general" host-uuid
> > "dcf2a873-f5ee-41dd-a7ad-802a544e48c2" \
> > mac fe:dc:ba:12:34:56
> 
> Ya, that sounds pretty close.  I still want the flexibility to direct ops to
> a PF link for a VF link.

Does that mean you require passing both the PF and the VF name?

	Arnd
