From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH] smsc95xx: Add module parameter to override MAC address
Date: Fri, 25 Jun 2010 09:43:30 +0100
Message-ID: <OF60E8D688.255F8F16-ON8025774D.002E17AA-8025774D.002FEC33@smsc.com>
References: <1277367254-9345-1-git-send-email-s-jan@ti.com> <20100625012520.GA12650@verge.net.au> <4C2452ED.8020307@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Simon Horman <horms@verge.net.au>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	davem@davemloft.net, Ian.Saturley@smsc.com
To: Sebastien Jan <s-jan@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:55468 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752113Ab0FYI6u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jun 2010 04:58:50 -0400
In-Reply-To: <4C2452ED.8020307@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sebastien,

> > I'm confused as to why this is desirable when the mac address
> > can already be configured after module insertion via
> > smsc95xx_netdev_ops.eth_mac_addr().
> 
> For example for booting over NFS using a pre-defined MAC address, with 
> a minimal setup (no initrd). Or is there another way to force a MAC
> address for this use-case?

I can't see an existing way of specifying this as a kernel parameter
in Documentation/kernel-parameters.txt. netdev= doesn't have a mac
address parameter.

During development I initially had smsc95xx driver using this logic to
select a MAC address:

1. If net->dev_addr has already been set to a valid mac address (i.e. by
an administrator before bringing the device up) then use that address.

2. If the device is already currently set to a valid mac address then
use that address.  This could have been set by either the device's
EEPROM or by a previously running bootloader.

3. Generate a random mac address.

Unfortunately, this doesn't work so well as the usbnet framework sets
net->dev_addr to the USB node_id before calling our bind function, so
we usually matched at step 1 (and not with the desired outcome).  So
I removed step 1 because, as Simon mentioned, it's possible to change
the mac address after the device is brought up.

I can see you have a different use case, but I don't think this specific
driver is the place for this logic.  I'd rather see it added to either
the usbnet framework or (preferably) the netdev framework so *all*
ethernet drivers can do this the same way.  otherwise we could end up
with slight variations of this code in every single driver!

Steve
