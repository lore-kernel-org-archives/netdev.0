From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Proper suspend/resume flow
Date: Wed, 26 Mar 2014 11:58:28 +0000
Message-ID: <20140326115828.GZ7528@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:39301 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751821AbaCZL6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 07:58:46 -0400
Received: from n2100.arm.linux.org.uk ([2001:4d48:ad52:3201:214:fdff:fe10:4f86]:59456)
	by pandora.arm.linux.org.uk with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.76)
	(envelope-from <linux@arm.linux.org.uk>)
	id 1WSmTk-0004Yv-Eh
	for netdev@vger.kernel.org; Wed, 26 Mar 2014 11:58:44 +0000
Received: from linux by n2100.arm.linux.org.uk with local (Exim 4.76)
	(envelope-from <linux@n2100.arm.linux.org.uk>)
	id 1WSmTV-0003Pr-En
	for netdev@vger.kernel.org; Wed, 26 Mar 2014 11:58:29 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been looking at the Freescale FEC driver recently, and I've noticed
that it's suspend path looks like this:

        if (netif_running(ndev)) {
                netif_device_detach(ndev);
                fec_stop(ndev);
        }

I believe this to be unsafe, because if the device is active, then we may
have packets in the transmit ring.  It may be possible for the ring to be
cleaned between netif_device_detach() and fec_stop(), resulting in a call
to netif_wake_queue(), which doesn't seem to take account of whether the
device has been detached.

I wondered if this was just limited to the freescale driver, and I found
a similar pattern in e1000e - __e1000e_shutdown() calls netif_device_detach()
as the very first thing, before doing anything else.  This seems to be a
common pattern.  8139cp.c does this, the second call seems to be rather
redundant:

        netif_device_detach (dev);
        netif_stop_queue (dev);

Tulip on the other hand shuts the hardware down and cleans the transmit
ring first before calling netif_device_detach(), thus ensuring that there
won't be any transmit completions before this call.  It doesn't stop the
queue before this, so presumably in a SMP environment, it is possible for
packets to get queued after the transmit ring has been cleaned.

So, what is the correct approach to suspending a net device?  When should
netif_device_detach() be called?

I think the right solution for a driver which does all its processing in
the NAPI poll function would be:

	if (netif_running(ndev)) {
		napi_disable(napi);
		netif_device_detach(ndev);
		disable_hardware();
	}

and upon resume, the reverse order.  The theory being:

- napi_disable() is to stop the driver processing its rings and possibly
  waking up the transmit queue(s) after the following netif_device_detach().
- netif_device_detach() to stop new packets being queued to the device.

Thanks.
