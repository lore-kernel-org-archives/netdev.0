From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix race condition in enc28j60 driver
Date: Sat, 02 Jul 2016 14:49:19 -0400 (EDT)
Message-ID: <20160702.144919.52232813385388603.davem@davemloft.net>
References: <1467395070-8632-1-git-send-email-sergio.valverde@hpe.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mhei@heimpold.de, dompe@hpe.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sergio.valverde@hpe.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [184.105.139.130] ([184.105.139.130]:37714 "EHLO
	shards.monkeyblade.net" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750746AbcGBStW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 14:49:22 -0400
In-Reply-To: <1467395070-8632-1-git-send-email-sergio.valverde@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergio Valverde < sergio.valverde@hpe.com >
Date: Fri,  1 Jul 2016 11:44:30 -0600

> From: Sergio Valverde <sergio.valverde@hpe.com>
> 
> The interrupt worker code for the enc28j60 relies only on the TXIF flag to
> determinate if the packet transmission was completed. However the datasheet
> specifies in section 12.1.3 that TXERIF will clear the TXRTS after a
> transmit abort. Also in section 12.1.4 that TXIF will be set
> when TXRTS transitions from '1' to '0'. Therefore the TXIF flag is enabled
> during transmission errors.
> 
> This causes a race condition, since the worker code will invoke
> enc28j60_tx_clear() -> netif_wake_queue(), potentially invoking the
> ndo_start_xmit function to send a new packet. The enc28j60_send_packet function
> uses a workqueue that invokes enc28j60_hw_tx(). In between this function is
> called, the worker from the interrupt handler will enter the path for error
> handler because of the TXERIF flag, causing to invoke enc28j60_tx_clear() again
> and releasing the packet scheduled for transmission, causing a kernel crash with
> due a NULL pointer.
> 
> These crashes due a NULL pointer were observed under stress conditions of the
> device. A BUG_ON() sequence was used to validate the issue was fixed, and has
> been running without problems for 2 years now.
> 
> Signed-off-by: Diego Dompe <dompe@hpe.com>
> Acked-by: Sergio Valverde <sergio.valverde@hpe.com>

Applied.
