From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Proper suspend/resume flow
Date: Thu, 27 Mar 2014 10:57:41 +0000
Message-ID: <20140327105741.GC7528@n2100.arm.linux.org.uk>
References: <20140326115828.GZ7528@n2100.arm.linux.org.uk> <5333F919.7080405@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:40309 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755024AbaC0K57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 06:57:59 -0400
Content-Disposition: inline
In-Reply-To: <5333F919.7080405@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 27, 2014 at 12:10:33PM +0200, Claudiu Manoil wrote:
> On 3/26/2014 1:58 PM, Russell King - ARM Linux wrote:
>> I think the right solution for a driver which does all its processing in
>> the NAPI poll function would be:
>>
>> 	if (netif_running(ndev)) {
>> 		napi_disable(napi);
>> 		netif_device_detach(ndev);
>> 		disable_hardware();
>> 	}
>>
>> and upon resume, the reverse order.  The theory being:
>>
>> - napi_disable() is to stop the driver processing its rings and possibly
>>    waking up the transmit queue(s) after the following netif_device_detach().
>> - netif_device_detach() to stop new packets being queued to the device.
>
>
> There's a risk to disabling the NAPI before stopping the transmission
> (i.e. stopping the Tx queues).  The net stack might continue to enqueue
> Tx packets and, if the Tx BD rings get full, the driver's start_xmit
> will return TX_BUSY which leads to netdev watchdog triggering Tx
> timeout (and the ndo_tx_timeout hook from the driver will re-enable the
> Tx queues).

Part of netif_device_detach()'s work is to stop the transmit queues in a
similar manner to the driver reporting "ring full", but before doing so,
it also marks the device not present.

The watchdog is conditional upon netif_device_present() returning true,
but as the device has been marked not-present, this test will fail.

When the device is resumed, and netif_device_attach() is called,
__netdev_watchdog_up() will also be called which reschedules the watchdog
for a new timeout grace period.

So I don't think that's an issue - I think we're safe from the watchdog
triggering.

> Maybe it's unlikely to get the BD rings full during suspend, but there's
> another case too - BQL (if the driver supports BQL).  BQL needs a
> confirmation for each xmitted byte, and the confirmation comes from
> Tx completion processing from NAPI context (see
> netdev_tx_completed_queue()).  If the confirmation is delayed too much,
> BQL blocks the Tx queues to trigger the same netdev Tx timeout watchdog
> mechanism.

One of the things FEC does when it resumes is to clean the transmit queue,
which with BQL ends up resetting the BQL counts (via netdev_reset_queue()).
Maybe that's something which should happen on the suspend path to clean
everything up in preparation?

> I think there's a more general problem to this: how to properly stop
> the Tx traffic from the driver.  And I think an approach to solve it
> would be to stop the Tx queues (i.e. netif_tx_stop_all_queues()) before
> disabling the NAPI processing, however the driver will need to use a
> special state flag (like "DOWN" or "RESETTING") to prevent waking up
> the Tx queues from NAPI while the Tx traffic is being stopped.
> There are some drivers implementing such "synchronization" flags to
> prevent the Tx congestion mechanism to wake up the Tx queues while the
> device is resetting or brought down.  But there's no generic
> implementation for this (there are differences in implementation from
> driver to driver).

If what I've said above is correct, then I don't think any of that is
necessary, and the sequence I mentioned in my initial email should work
fine.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.
