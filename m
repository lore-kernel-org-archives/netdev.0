From: Chris Wright <chrisw@redhat.com>
Subject: Re: [net-next,1/2] add iovnl netlink support
Date: Wed, 21 Apr 2010 11:10:21 -0700
Message-ID: <20100421181021.GC25928@x200.localdomain>
References: <C7F354F4.29CC8%scofeldm@cisco.com>
 <201004211326.00974.arnd@arndb.de>
 <20100421161842.GB25928@x200.localdomain>
 <201004211952.29145.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@redhat.com>,
	Scott Feldman <scofeldm@cisco.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45712 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754062Ab0DUSKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Apr 2010 14:10:32 -0400
Content-Disposition: inline
In-Reply-To: <201004211952.29145.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Arnd Bergmann (arnd@arndb.de) wrote:
> On Wednesday 21 April 2010, Chris Wright wrote:
> > * Arnd Bergmann (arnd@arndb.de) wrote:
> > > Since it seems what you really want to do is to do the exchange with the
> > > switch from here, maybe the hardware configuration part should be moved
> > > the DCB interface?
> > 
> > I suppose this would work  (although it's a bit odd being out of scope
> > of DCB spec).
> 
> It could be anywhere, it doesn't have to be the DCB interface, but could
> be anything ranging from ethtool to iplink I guess. And we should define
> it in a way that works for any SR-IOV card, whether it's using Cisco's
> protocol in firmware, 802.1Qbg VDP in firmware, lldpad to do VDP or
> none of the above and just provides an internal switch like all the
> existing NICs.

Heh, that's exactly what iovnl does ;-)

> > I don't expect mgmt app to care about the implementation
> > specifics of an adapter, so it will always send this and iovnl message
> > too.  All as part of same setup.
> 
> Why? I really see these things as separate. Obviously a management
> tool like libvirt would need to do both these things eventually, but
> each of them has multiple options that can be combined in various
> ways:
> 
> 1. Setting up the slave device
>  a) create an SR-IOV VF to assign to a guest
>  b) create a macvtap device to pass to qemu or vhost
>  c) attach a tap device to a bridge
>  d) create a macvlan device and put it into a container
>  e) create a virtual interface for a VMDq adapter

OK, but iovnl isn't doing this.

> 2) Registering the slave with the switch
>  a) use Cisco protocol in enic firmware (see patch 2/2)
>  b) use standard VDP in lldpad
>  c) use reverse-engineered cisco protocol in some user tool for
>     non-enic adapters.
>  d) use standard VDP in firmware (hopefully this never happens)
>  e) do nothing at all (as we do today)

And this is the step that is the main purpose of iovnl.

Here's the simplest snippet of libvirt to show this.  It sends
set_port_profile netlink messages and then creates macvtap.  As simple
as it gets...

--- a/src/qemu/qemu_conf.c
+++ b/src/qemu/qemu_conf.c
@@ -1470,6 +1470,11 @@ qemudPhysIfaceConnect(virConnectPtr conn,
         net->model && STREQ(net->model, "virtio"))
         vnet_hdr = 1;
 
+    setPortProfileId(net->data.direct.linkdev,
+                      net->data.direct.mode,
+                      net->data.direct.profileid,
+                      net->mac);
+
     rc = openMacvtapTap(net->ifname, net->mac, linkdev, brmode,
                         &res_ifname, vnet_hdr);
