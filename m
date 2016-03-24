From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: Fix extra refcount release in
 netpoll_cleanup()
Date: Thu, 24 Mar 2016 14:57:45 -0400 (EDT)
Message-ID: <20160324.145745.451518711282450835.davem@davemloft.net>
References: <20160324161334.31279.26510.stgit@bhelgaas-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@cumulusnetworks.com, netdev@vger.kernel.org,
	nhorman@redhat.com, aduyck@mirantis.com,
	linux-kernel@vger.kernel.org
To: bhelgaas@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52453 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462AbcCXS5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 14:57:48 -0400
In-Reply-To: <20160324161334.31279.26510.stgit@bhelgaas-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bjorn Helgaas <bhelgaas@google.com>
Date: Thu, 24 Mar 2016 11:13:34 -0500

> netpoll_setup() does a dev_hold() on np->dev, the netpoll device.  If it
> fails, it correctly does a dev_put() but leaves np->dev set.  If we call
> netpoll_cleanup() after the failure, np->dev is still set so we do another
> dev_put(), which decrements the refcount an extra time.
> 
> It's questionable to call netpoll_cleanup() after netpoll_setup() fails,
> but it can be difficult to find the problem, and we can easily avoid it in
> this case.  The extra decrements can lead to hangs like this:
> 
>   unregister_netdevice: waiting for bond0 to become free. Usage count = -3
> 
> In __netpoll_setup(), don't set np->dev until we know we're going to
> succeed.
> 
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>

The reason this bug exists is because the thing doing the reference
counting is separated from the thing that assigns the device pointer.

That's how this was allowed to happen.

If you instead do the np->dev = dev; assignment where the get is
performed, and do a np->dev = NULL; where the error path puts
the reference, everything is obvious and this error is unlikely to
be reintroduced.

So could you please implement your fix like that?

Thanks.
