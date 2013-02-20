From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: fix phy_device_free memory leak
Date: Tue, 19 Feb 2013 22:48:36 -0500 (EST)
Message-ID: <20130219.224836.2280761384227580667.davem@davemloft.net>
References: <20130219193646.GA10851@bordel.klfree.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: oss@malat.biz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40173 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935692Ab3BTDsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 22:48:38 -0500
In-Reply-To: <20130219193646.GA10851@bordel.klfree.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Malat <oss@malat.biz>
Date: Tue, 19 Feb 2013 20:36:46 +0100

> From: Petr Malat <oss@malat.biz>
> 
> Fix memory leak in phy_device_free() for the case when phy_device*
> returned by phy_device_create() is not registered in the system.
> 
> Bug description:
> phy_device_create() sets name of kobject using dev_set_name(), which 
> allocates memory using kvasprintf(), but this memory isn't freed if 
> the underlying device isn't registered properly, because kobject_cleanup()
> is not called in that case. This can happen (and actually is happening on 
> our machines) if phy_device_register(), called by mdiobus_scan(), fails. 
> 
> Patch description:
> Name is freed by phy_device_free(). In the case a device is released 
> trough kobject_cleanup()->device_release()->phy_device_release(), the name
> is set to NULL and it is not freed by phy_device_free(), because it will 
> be freed later by kobject_cleanup().
> 
> Signed-off-by: Petr Malat <oss@malat.biz>
> ---
> Please put me on CC, I'm not signed into the mailing list.

I think it's cleaner to have phy_device_register() use the kobject
reference count properly.

Have it first go:

	device_initialize(&phydev->dev);

And change the device_register() to device_add().

Finally, on the failure paths, do a put_device().

No funny NULL pointer assignments and state to maintainer, just using
kobject reference counting to handle it all transparently.
