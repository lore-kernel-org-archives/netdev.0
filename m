From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: Proper suspend/resume flow
Date: Thu, 27 Mar 2014 12:10:33 +0200
Message-ID: <5333F919.7080405@freescale.com>
References: <20140326115828.GZ7528@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:4550 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753834AbaC0KKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 06:10:47 -0400
In-Reply-To: <20140326115828.GZ7528@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/26/2014 1:58 PM, Russell King - ARM Linux wrote:
> I think the right solution for a driver which does all its processing in
> the NAPI poll function would be:
>
> 	if (netif_running(ndev)) {
> 		napi_disable(napi);
> 		netif_device_detach(ndev);
> 		disable_hardware();
> 	}
>
> and upon resume, the reverse order.  The theory being:
>
> - napi_disable() is to stop the driver processing its rings and possibly
>    waking up the transmit queue(s) after the following netif_device_detach().
> - netif_device_detach() to stop new packets being queued to the device.


There's a risk to disabling the NAPI before stopping the transmission
(i.e. stopping the Tx queues).  The net stack might continue to enqueue
Tx packets and, if the Tx BD rings get full, the driver's start_xmit
will return TX_BUSY which leads to netdev watchdog triggering Tx
timeout (and the ndo_tx_timeout hook from the driver will re-enable the
Tx queues).
Maybe it's unlikely to get the BD rings full during suspend, but there's
another case too - BQL (if the driver supports BQL).  BQL needs a
confirmation for each xmitted byte, and the confirmation comes from
Tx completion processing from NAPI context (see
netdev_tx_completed_queue()).  If the confirmation is delayed too much,
BQL blocks the Tx queues to trigger the same netdev Tx timeout watchdog
mechanism.

I think there's a more general problem to this: how to properly stop
the Tx traffic from the driver.  And I think an approach to solve it
would be to stop the Tx queues (i.e. netif_tx_stop_all_queues()) before
disabling the NAPI processing, however the driver will need to use a
special state flag (like "DOWN" or "RESETTING") to prevent waking up
the Tx queues from NAPI while the Tx traffic is being stopped.
There are some drivers implementing such "synchronization" flags to
prevent the Tx congestion mechanism to wake up the Tx queues while the
device is resetting or brought down.  But there's no generic
implementation for this (there are differences in implementation from
driver to driver).

Claudiu
