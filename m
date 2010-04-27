From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next-2.6 PATCH 1/2] Add ndo_set_vf_port_profile
Date: Tue, 27 Apr 2010 21:38:02 +0200
Message-ID: <201004272138.03193.arnd@arndb.de>
References: <C7FB77DB.2BC42%scofeldm@cisco.com> <201004271435.25480.arnd@arndb.de> <8966E338-1C9C-43D9-B6A3-A44349E7EE18@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <scofeldm@cisco.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"chrisw@redhat.com" <chrisw@redhat.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:58759 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754849Ab0D0Tid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 15:38:33 -0400
In-Reply-To: <8966E338-1C9C-43D9-B6A3-A44349E7EE18@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 27 April 2010 19:33:04 Anirban Chakraborty wrote:
> On Apr 27, 2010, at 5:35 AM, Arnd Bergmann wrote:
> > Anything that ties port profiles to VFs seems fundamentally flawed AFAICT,
> > at least when we want to extend this to adapters that don't do it in firmware.
> 
> Correct me if I am wrong. Shouldn't the port profile be tied to the physical NICs which are essentially
> PCI functions (be it PF or VF)? I'd think that a port profile would have configuration settings for all the
> physical NICs (PF/VF) of a specific physical port of the adapter. I liked the idea of querying the device
> for number of VFs as it will cover both SR-IOV and non SR-IOV PCI functions.

Yes, the port profile association is tied to whoever owns the link to the switch.
That can be a regular NIC, an SR-IOV PF, an ethernet bonding device or an S-component
implementing provider S-VLANs on top of any of these.

Usually it will be the same as a physical link, but in case of bonding it is two
physical links while in case of S-VLAN, you have multiple instances that each
have their own set of port profile association. If S-VLAN is implemented by
the NIC, that may be a VF.

Querying a PF for the number of VFs attached to it is a useful thing, but this
is independent of port profiles. Consider this (artificially complex) setup:

- eth0 is the PF of an SR-IOV NIC
- eth1 is a regular single-channel NIC
- vf0 is a VF of eth0, used by a guest using PCI passthrough mode on S-VLAN 2
- vf1 is a VF of eth0 owned by the host on S-VLAN 3
- vf1.23 is a VLAN port for VLAN 23 in S-VLAN 3
- br0 is a bridge connected to vf1
- br23 is a bridge VLAN device for br0
- vf2 is a VF of eth0 owned by the host on S-VLAN 4
- eth1.5 is a software vlan device for S-VLAN 4
- bond0 combines eth1.5 and vf2
- bond0.24 is a VLAN port for VLAN24 on bond0
- tap0 is a guest connected to br0 in trunk mode
- tap1 is a guest connected to br23 in access mode
- macvtap0 is a VEPA mode guest on bond0
- macvtap1 is a private mode guest on bond0.24

This means you have a total of five guests running, on vf0, tap0, tap1,
macvtap0 and macvtap1. Querying the number of VFs on eth0 will return '2',
for vf0 and vf1. What you are interested in however is which guests are
associated. Querying every single interface in the system will tell you

eth0: one guest (vf0)
vf1: two guests (tap0 and tap1)
bond0: two guests (macvtap0 and macvtap1)

	Arnd
