From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: Re: [PATCH] Add support for netconsole driver used on bridge device with VIF attached
Date: Tue, 29 Jan 2013 10:54:46 +0200
Message-ID: <201301291054.46405.yuval.shaia@oracle.com>
References: <5757e54b-902b-4338-8ac9-43857cd1906c@default> <50FD8243.6000501@oracle.com> <1358846612.3279.282.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23633 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754487Ab3A2Iy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 03:54:59 -0500
In-Reply-To: <1358846612.3279.282.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tuesday 22 January 2013 11:23:32 am Ian Campbell wrote:
> On Mon, 2013-01-21 at 18:00 +0000, yuval.shaia@oracle.com wrote:
> > On 01/21/2013 07:28 PM, Ian Campbell wrote:
> > > On Mon, 2013-01-21 at 17:17 +0000, Yuval Shaia wrote:
> > >> When starting a VM which has virtual interface attached to the same
> > >> bridge (i.e vif = [type=netfront,bridge=xenbr0'] in vm.cfg) which is
> > >> used for netconsole the
> > >> following message appears (after about 60 seconds) and VM creation
> > >> operation fails.
> > >>        Error: Device 0 (vif) could not be connected. Hotplug scripts
> > >> not working.
> > >
> > > I'm not sure how this can relate netconsole since this happens before
> > > the guest even runs, doesn't it?
> >
> > Running the same scenario without netconsole runs smoothly.
> 
> But why? I can't make sense of your scenario and therefore cannot
> explain why this patch would make any difference. Perhaps your patch is
> just papering over some other issue?
> 
> > >> As i see it, netconsole driver requires ndo_poll_controller from the
> > >> device's controlling driver (function __netpoll_setup in
> > >> net/core/netpoll.c), a thing that is not supported currently in
> > >> xen_netback driver which is the driver that runs on dom0 and serve
> > >> VM's virtual interface.
> > >
> > > Which domain is using netconsole? Is it dom0 or domU? What parameters
> > > do you give it?
> >
> > dom0.
> > parameters: netconsole=1111@src-ip/xenbr0,2002@dst-ip/dst-mac
> 
> You give these parameters to dom0 so that dom0's own logs are sent to
> some other host?
> 
> Are dst-ip and dst-mac a domain on the same host or are they some offbox
> logging service?
Sorry, my mistake, i should have attach network setup at first.
Anyway, here is my setup:
----------                       ----------
| Host A |--bond0--->|           | Host B |
|--------|           |--xenbr0   |        |
| VM A1  |--vif1.0-->|     |     |        |
----------                 |     ----------
                           |         |
                           V         V
---------------------------------------------
|                   LAN                     |
---------------------------------------------

I'm using netconsole to capture logs from  Host-A and send them to Host-B.
Host-A and Host-B are separate hosts (running XEN) which are  connected to the 
same LAN.
src-ip is Host-A address.
dst-ip/mac is Host-B address.

> 
> I can see why the *bridge* device might need an ndo_poll_controller hook
> in this setup but I can't see any reason why the netback device would
> need one.
> 
Please note that without netback driver netconsole runs fine, i.e before trying 
to create VM which attached to the bridge.
> > > I assume it is the domU but if that's the case I don't see why a
> > > netback rather than netfront patch would be required.
> > >
> > > Or is dom0 doing netconsole where the log receiver is a domU?
> >
> > Log received at dom0 as output of xm cr vm.cfg command.
> > netconsole is used on dom0 to monitor its log
> 
> Are you now saying that logging goes from domU to dom0? Which is it?
netback comes to play as soon as i'm attaching virtual interface to a bridge 
and since this bridge is under netconsole monitoring the function is 
triggered. Up to that point there is no issue getting logs in Host-B so i 
assume the problem is not with the bridge driver.
> 
> In this scenario there is really no reason I can see that netback would
> need an ndo_poll_controller hook -- that would be needed in the domU in
> the netfront driver.
> 
> Please can you explain the exact code path which results in this new
> hook being called.
> 
init_netconsole() in netconsole.c -> alloc_param_target() -> netpoll_setup() 
in netpoll.c -> __netpoll_setup() which check if ndo_poll_controller() 
operation is supported.
> BTW looking at the patch as it is any use of this hook should be wrapped
> in CONFIG_NET_POLL_CONTROLLER.
> 
> Ian.
> 
