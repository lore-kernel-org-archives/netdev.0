From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next-2.6 V5 PATCH 0/3] Add port-profile netlink support
Date: Thu, 6 May 2010 18:42:51 +0200
Message-ID: <201005061842.51981.arnd@arndb.de>
References: <C8083A0F.2EC10%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, chrisw@redhat.com
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:54446 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753388Ab0EFQnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 12:43:08 -0400
In-Reply-To: <C8083A0F.2EC10%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 06 May 2010, Scott Feldman wrote:
> On 5/6/10 6:51 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:
> 
> > On Thursday 06 May 2010, Scott Feldman wrote:
> >> The intent of this patch set is to cover both definitions of port-profile
> >> as defined by Cisco's enic use and as defined by VSI discover protocol (VDP),
> >> used in VEPA implemenations.  While both definitions are based on pre-
> >> standards, the concept of a port-profile to be applied to an external switch
> >> port on behalf of a virtual machine interface is common, as well as many
> >> of the fields defining the protocols.
> > 
> > The description no either no longer matches the patches, or you did not make
> > the
> > changes that were needed based on our last discussion.
> > 
> > What happened to the base-device argument that you were planning to pass?
> 
> Using the IFLA_VF_* model works better for us where the recipient of the
> netlink msg is the PF but the msg is to be applied to the VF.  The third
> patch illustrates how this fits nicely with SR-IOV devices.  The PF is the
> base device.

Ah, got it. I did not notice that you had put a vf field in there.
It now makes a lot more sense to me, and is more in line with what
we need for VDP.

It does however make me wonder how this could be implemented for
a software-only implementation of your protocol that does not refer
to vf numbers. One way would be to define the 'vf' field as implementation
specific and just use the ifindex in this case, which would also work
in case of network namespaces. Alternatively, it could use whatever
tag you use in your wire protocol (e.g. an S-VID)

Both are a bit of a stretch, but I see no technical problems with them.

> > The fields that I mentioned are needed for VDP
> > (associate/pre-associate/disassociate-flag,
> > VLAN ID, etc) are not there. I assume that means we should use a different
> > data structure for VDP, but then your description above should be updated
> > to state that this is no longer common for the two.
> > 
> > I'll follow up with a draft for VDP based on your definitions.
> 
> I tried to accommodate space for VDP, but was hoping you could add the
> definitions on top of what I had since your more familiar with VDP and can
> do the testing.
> 
> Also, I wasn't sure if you could use the existing IFLA_VF_VLAN msg to apply
> the VLAN ID or if you wanted VLAN ID also added to IFLA_VF_PORT_PROFILE.

The IFLA_VF_VLAN would not work well here because of the issue we discussed
before that I think we need to keep device setup separate from the protocol
exchange. IFLA_VF_VLAN configures the VLAN, while we need to tell the switch
about the configuration.

One (new) point that came up today is that your protocol is actually much
more closely related to the 'CDCP' protocol in 802.1Qbg than to 'VDP'.
I'll also try to make sure that we cover this case as well. It should
also be possible to do VDP over a dynamic enic VF and have multiple guests
using macvtap on that function, and there will probably be adapters that
need to use IFLA_VF_PORT_PROFILE (or another set) as the interface between
libvirt and the adapter firmware for doing CDCP.

To give some background, CDCP is an LLDP extension that is used to create
virtual channels between a physical NIC and the phys bridge on the other side,
using S-VLAN tagging. You can either assign one of these channels to a
guest directly (similar to what enic does), or use VDP on the channel
to connect multiple guests using a bridge device or macvtap in the same
way that we also do VDP on the physical device in the absence of CDCP.

	Arnd
