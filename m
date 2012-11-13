From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] 8021q: validate SAN MAC address
Date: Tue, 13 Nov 2012 16:53:00 -0500 (EST)
Message-ID: <20121113.165300.1149843648625252626.davem@davemloft.net>
References: <1352501644-8444-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50174 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752632Ab2KMVxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 16:53:04 -0500
In-Reply-To: <1352501644-8444-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 9 Nov 2012 14:54:04 -0800

> Some bnx2x multi-function devices are configured for FCoE only in
> a PCI function and only has a SAN MAC address.  The current code
> will fail ->ndo_validate_addr() when a VLAN device is brought up
> over such a device.
> 
> Check the real device's dev_addrs[] for a valid SAN MAC address
> when validating the MAC address if the regular MAC address is not
> valid.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

I've read this thread and I still don't think this is a nice
change at all.

It's beyond hackish to allow configuring a VLAN with a completely
invalid MAC address just because the underlying real device just so
happens to have a storage MAC address.

I can only assume that, in this case, this code block is triggered
in vlan_dev_open():

	if (!ether_addr_equal(dev->dev_addr, real_dev->dev_addr)) {
		err = dev_uc_add(real_dev, dev->dev_addr);
		if (err < 0)
			goto out;
	}

And if so we're adding an invalid ethernet address to the underlying
device's UC list.  Yet another terrible aspect of this situation.

The more I look into this situation the more it looks like piling crap
on top of crap on top of crap.  It's a long depency chain of special
cases just to get this weird setup working.

I'm sorry, I'm not making the situation even worse by applying this
patch.  If you want to have real bypasses to allow VLAN VIDs to
be configured on SAN devices, create a real interface for it, rather
than hack to shreds the stuff we have already.

Thanks.
