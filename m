From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next,1/2] add iovnl netlink support
Date: Wed, 21 Apr 2010 21:39:21 +0200
Message-ID: <201004212139.22421.arnd@arndb.de>
References: <C7F354F4.29CC8%scofeldm@cisco.com> <201004211952.29145.arnd@arndb.de> <20100421181021.GC25928@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <scofeldm@cisco.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Chris Wright <chrisw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:50396 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756209Ab0DUTj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 15:39:26 -0400
In-Reply-To: <20100421181021.GC25928@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 21 April 2010, Chris Wright wrote:
> * Arnd Bergmann (arnd@arndb.de) wrote:
> > On Wednesday 21 April 2010, Chris Wright wrote:
> > > * Arnd Bergmann (arnd@arndb.de) wrote:
> > > > Since it seems what you really want to do is to do the exchange with the
> > > > switch from here, maybe the hardware configuration part should be moved
> > > > the DCB interface?
> > > 
> > > I suppose this would work  (although it's a bit odd being out of scope
> > > of DCB spec).
> > 
> > It could be anywhere, it doesn't have to be the DCB interface, but could
> > be anything ranging from ethtool to iplink I guess. And we should define
> > it in a way that works for any SR-IOV card, whether it's using Cisco's
> > protocol in firmware, 802.1Qbg VDP in firmware, lldpad to do VDP or
> > none of the above and just provides an internal switch like all the
> > existing NICs.
> 
> Heh, that's exactly what iovnl does ;-)

No, according to what you write below, it's exactly what iovnl does *not* do,
i.e. part 1 in my list.

> > 1. Setting up the slave device
> >  a) create an SR-IOV VF to assign to a guest
> >  b) create a macvtap device to pass to qemu or vhost
> >  c) attach a tap device to a bridge
> >  d) create a macvlan device and put it into a container
> >  e) create a virtual interface for a VMDq adapter
> 
> OK, but iovnl isn't doing this.

The set_mac_vlan that Scott's patch adds seems to implement 1a), as far
as I can tell. Interestingly, this is not actually implemented in
the enic driver in patch 2/2. So if we all agree that this is out of the
scope of iovnl, let's just remove it from the interface and find another
way for it (ethtool, iplink, ..., as listed above).

Note that we still need to pass the MAC address and VLAN ID (or a list
of these) to the external switch, my point is just that this should be
separate from enforcing it in the hypervisor.

> > 2) Registering the slave with the switch
> >  a) use Cisco protocol in enic firmware (see patch 2/2)
> >  b) use standard VDP in lldpad
> >  c) use reverse-engineered cisco protocol in some user tool for
> >     non-enic adapters.
> >  d) use standard VDP in firmware (hopefully this never happens)
> >  e) do nothing at all (as we do today)
> 
> And this is the step that is the main purpose of iovnl.
> 
> Here's the simplest snippet of libvirt to show this.  It sends
> set_port_profile netlink messages and then creates macvtap.  As simple
> as it gets...
> 
> --- a/src/qemu/qemu_conf.c
> +++ b/src/qemu/qemu_conf.c
> @@ -1470,6 +1470,11 @@ qemudPhysIfaceConnect(virConnectPtr conn,
>          net->model && STREQ(net->model, "virtio"))
>          vnet_hdr = 1;
>  
> +    setPortProfileId(net->data.direct.linkdev,
> +                      net->data.direct.mode,
> +                      net->data.direct.profileid,
> +                      net->mac);
> +
>      rc = openMacvtapTap(net->ifname, net->mac, linkdev, brmode,
>                          &res_ifname, vnet_hdr);

Ok. In case of VDP, I guess this needs to be extended with the vlan ID
that has been configured, and possibly with a UUID, because we need to
pass the same one on the target machine if we migrate it.

Alternatively, the setPortProfileId could figure out the MAC address and
VLAN ID from the device itself, but then we don't need to pass either of
them.

	Arnd
