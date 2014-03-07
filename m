From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH net-next 2/2] gianfar: Make multi-queue polling optional
Date: Fri, 7 Mar 2014 14:52:32 +0200
Message-ID: <5319C110.2060901@freescale.com>
References: <1394008119-27899-1-git-send-email-claudiu.manoil@freescale.com>	<1394008119-27899-3-git-send-email-claudiu.manoil@freescale.com> <20140306.165236.1656673150420499957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe001.messaging.microsoft.com ([216.32.180.11]:53958
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752532AbaCGMwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 07:52:44 -0500
In-Reply-To: <20140306.165236.1656673150420499957.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/6/2014 11:52 PM, David Miller wrote:
> From: Claudiu Manoil <claudiu.manoil@freescale.com>
> Date: Wed, 5 Mar 2014 10:28:39 +0200
>
>> For the newer controllers (etsec2 models) the driver currently
>> supports 8 Tx and Rx DMA rings (aka HW queues).  However, there
>> are only 2 pairs of Rx/Tx interrupt lines, as these controllers
>> are integrated in low power SoCs with 2 CPUs at most.  As a result,
>> there are at most 2 NAPI instances that have to service multiple
>> Tx and Rx queues for these devices.  This complicates the NAPI
>> polling routine having to iterate over the mutiple Rx/Tx queues
>> hooked to the same interrupt lines.  And there's also an overhead
>> at HW level, as the controller needs to service all the 8 Tx rings
>> in a round robin manner.  The cumulated overhead shows up for mutiple
>> parrallel Tx flows transmitted by the kernel stack, when the driver
>> usually starts returning NETDEV_TX_BUSY and leading to NETDEV WATCHDOG
>> Tx timeout triggering if the Tx path is congested for too long.
>>
>> As an alternative, this patch makes the driver support only one
>> Tx/Rx DMA ring per NAPI instace (per interrupt group or pair
>> of Tx/Rx interrupt lines) by default.  The simplified single queue
>> polling routine (gfar_poll_sq) will be the default napi poll routine
>> for the etsec2 devices too.  Only small adjustments needed to be made
>> to link the Tx/Rx HW queues with each NAPI instance (2 in this case).
>> The gfar_poll_sq() is already succefully used by older SQ_SG (single
>> interrupt group) controllers.  And there's also a significat memory
>> footprint reduction by supporting 2 Rx/Tx DMA rings (at most), instead
>> of 8.
>>
>> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
>
> This patch is not OK.
>
> First of all, you are disabling multi-queue for other devices.
>
> You're adding a CPP check for a macro that is set by nothing.
>
> Determine the condition to limit the number of queues at run-time.
>
>

Hi David,

Thanks for reviewing this and for the concerns.
I agree that using CPP defines is ugly.  I reworked
the 2nd patch to do these checks at run-time.

For your first concern, the "fsl,etsec2" models are the
only devices for which multi-queue NAPI polling is used.
The other devices work in SQ_SG mode, they support a single
pair of Rx/Tx queues and already use single queue NAPI polling.

The "fsl,etsec2" models work in MQ_MG_MODE (Multi-Group) because
they have 2 separate pairs of Rx/Tx interrupt lines
(aka interrupt groups), so they can work with 2 (Rx/Tx) NAPI
instances serving one (Rx/Tx) queue each.
So because these devices can support 2 Rx and 2 TX queues,
they are still multi-queue, but they can be serviced with the
simplified SQ NAPI poll routine, per interrupt group
(NAPI instance).

However, enabling support for all the 8 RX and 8 TX hw queues
turns out to be a problem as the combined processing overhead is
too much: multi-queue polling per NAPI instance + eTSEC
controller having to service the 8 Tx queues round-robin.
And this results in serious Tx congestion (and Tx timeout).

As I see it, multi-queue NAPI polling not only creates issues
but is not justified for this linux driver.  However, instead
of removing this code altogether I thought it would be safer
to still keep it in the driver for a while, and do some
checks to limit the number of queues at runtime.

Hopefully this explains the problem a bit clearer.

Thanks.
Claudiu
