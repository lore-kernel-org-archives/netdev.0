From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/2] correct dev_alloc_skb kerneldoc
Date: Thu, 13 Jul 2006 22:36:16 +0200
Message-ID: <20060713203615.GA26954@lst.de>
References: <20060707155255.10f2e10f@dxpl.pdx.osdl.net> <20060707.165527.77037268.davem@davemloft.net> <20060708104811.GB31751@lst.de> <20060708.133738.123994596.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, netdev@vger.kernel.org, support@pathscale.com,
	samuel@sortiz.org, kkeil@suse.de, kai.germaschewski@gmx.de,
	chas@cmf.nrl.navy.mil, paulus@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:62107 "EHLO mail.lst.de")
	by vger.kernel.org with ESMTP id S1030366AbWGMUhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2006 16:37:12 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060708.133738.123994596.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 08, 2006 at 01:37:38PM -0700, David Miller wrote:
> > My plan is to give dev_alloc_skb a struct netdevice * argument and
> > introduce a alloc_netdev_node so the driver can tell what node the
> > device is on.  This gives a significant speedup for cell.  I already
> > have this implemented in fact but only converted a handfull of drivers.
> > 
> > Does this approach sound okay?
> 
> I do not think it is feasible to add a netdevice argument to
> such a widely used interface.
> 
> I would instead recommend that you add a new interface, and
> we convert drivers gradually.

I gave converting the dev_alloc_skb prototype everywhere a spin and it
doesn't look too bad.  There's only a few places that don't have a
netdevice at hand, and all these look bogus:

 - drivers/atm/{idt77252.c, nicstar.c}, drivers/usb/atm/usbatm.c:
	These use private skb queues and do odd things.  I can't see
	any point for using dev_alloc_skb with it's additional headroom
	reservation here.
 - drivers/isdn/<everything> :
	These don't even have a netdevice!  Also I can't see why they
	need the headroom.
 - drivers/net/{ppp_async.c,drivers/net/ppp_async.c}:
   	They take data from the underlying tty device.  Because of that
	there's not point for he additional headroom.
 - net/irda/*:
   	They allocate the skb in protocol code for TX.  Should probably
	do a normal alloc_skb like all the other protocol code.
 - drivers/infiniband/hw/ipath/ipath_driver.c:
   	Uses skbbuffs in a driver that has absolutely nothing to do
	with networking.  Duh..

I've added the respective maintainers to the cc list here so they can
comment on these usages.

The patchkit for this is at http://verein.lst.de/~hch/patches.skb.tgz, it
includes the first two cleanup patches I posted previously (Any plans
to put them in?), a patch to move __dev_alloc_skb out of line because
otherwise we'd need to include netdevice.h in skbuff.h which creates
lots of problems (and moving it out of lines shaves 10kb off a
allyesconfig), the dev_alloc_skb prototype changes and some experimental
patches to make dev_alloc_skb nodeaware.

> That netdevice argument is useful for other things.  For example,
> you can use it to apply a per-netdev random memory allocation
> failure setting, to test the robustness of drivers.  I came up
> with that idea something like 7 years ago but never got around
> to doing it :)

Sounds cool.  While doing the change I also noticed that assigning
skb->dev can move in there aswell, but I haven't done that change yet.
