From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Proper suspend/resume flow
Date: Sat, 29 Mar 2014 20:19:39 +0000
Message-ID: <20140329201939.GX7528@n2100.arm.linux.org.uk>
References: <20140326115828.GZ7528@n2100.arm.linux.org.uk> <1396111046.2898.88.camel@deadeye.wl.decadent.org.uk> <20140329180347.GW7528@n2100.arm.linux.org.uk> <1396123694.2898.93.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:42656 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751991AbaC2UUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 16:20:00 -0400
Content-Disposition: inline
In-Reply-To: <1396123694.2898.93.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 29, 2014 at 08:08:14PM +0000, Ben Hutchings wrote:
> On Sat, 2014-03-29 at 18:03 +0000, Russell King - ARM Linux wrote:
> [...]
> > That said, for the case where a network driver does all it's packet
> > processing in the NAPI poll function, I think calling napi_disable()
> > is a good way to ensure that the poll function is not running, and
> > therefore there are can be no netif_wake_queue() calls - or anything
> > other than the ndo_start_xmit touching the rings or the device.  This
> > is needed anyway to stop receive packet processing looking at its
> > ring.
> > 
> > So, I've now come to this sequence:
> > 
> > suspend()
> > {
> > 	if (netif_running()) {
> > 		napi_disable();
> > 		netif_tx_lock();
> > 		netif_device_detach();
> > 		netif_tx_unlock();
> > 	}
> > 	... suspend device ...
> > }
> [...]
> 
> This is missing netif_stop_queue(), but I assume you do that somewhere
> after netif_device_detach().  I think this should work.

Ah, that's covered by netif_device_detach():

        if (test_and_clear_bit(__LINK_STATE_PRESENT, &dev->state) &&
            netif_running(dev)) {
                netif_tx_stop_all_queues(dev);
        }

provided __LINK_STATE_PRESENT was previously set, and the interface
was running.

netif_tx_stop_all_queues() is:

        for (i = 0; i < dev->num_tx_queues; i++) {
                struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
                netif_tx_stop_queue(txq);
        }

so with the above sequence, we end up stopping all queues under the
xmit lock.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.
