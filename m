From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netfront: avoid crashing on resume after a failure
 in talk_to_netback()
Date: Thu, 04 May 2017 11:21:50 -0400 (EDT)
Message-ID: <20170504.112150.391662736580694835.davem@davemloft.net>
References: <20170504122304.11735-1-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, boris.ostrovsky@oracle.com,
        jgross@suse.com
To: vkuznets@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56002 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754710AbdEDPWC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 11:22:02 -0400
In-Reply-To: <20170504122304.11735-1-vkuznets@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vitaly Kuznetsov <vkuznets@redhat.com>
Date: Thu,  4 May 2017 14:23:04 +0200

> Unavoidable crashes in netfront_resume() and netback_changed() after a
> previous fail in talk_to_netback() (e.g. when we fail to read MAC from
> xenstore) were discovered. The failure path in talk_to_netback() does
> unregister/free for netdev but we don't reset drvdata and we try accessing
> it again after resume.
> 
> Reset drvdata in netback_changed() the same way we reset it in
> netfront_probe() and check for NULL in both netfront_resume() and
> netback_changed() to properly handle the situation.
> 
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>

The circumstances under which netfront_probe() NULLs out the device
private is different than what you propose here, which is to do it
on a live device in netback_changed() whilst mutliple susbsytems
have a reference to this device and can call into the driver still.

It is only legal to do this in the probe function because such
references and execution possibilities do not exist at that point.

What really needs to happen is that the xenbus_driver must be told to
unregister this xen device and stop making calls into the driver for
it before you release the netdev state.

That is the only reasonable way to fix this bug.

Thanks.
