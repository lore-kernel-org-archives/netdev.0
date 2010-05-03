From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Subject: RE: [patch 01/13] KS8851: Fix ks8851 snl transmit problem
Date: Mon, 3 May 2010 12:06:21 -0700
Message-ID: <14385191E87B904DBD836449AA30269D6DE63A@MORGANITE.micrel.com>
References: <20100429231621.015936077@fluff.org.uk><20100429231739.509103394@fluff.org.uk> <20100502.223852.219748077.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <support@tincantools.com>
To: "David Miller" <davem@davemloft.net>, <ben@simtec.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c11o145.mxlogic.net ([208.65.144.68]:58129 "EHLO
	p01c11o145.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755912Ab0ECTOf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 15:14:35 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20100502.223852.219748077.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Ben Dooks <ben@simtec.co.uk>
> Date: Fri, 30 Apr 2010 00:16:22 +0100
> 
>> From: Tristram Ha <Tristram.Ha@micrel.com>
>> 
>> This fixes a transmit problem of the ks8851 snl network driver.
>> 
>> Under heavy TCP traffic the device will stop transmitting. Turning
off
>> the transmit interrupt avoids this issue.  A new workqueue was
>> implemented to replace the functionality of the transmit interrupt
processing.
>> 
>> Signed-off-by: Tristram Ha <Tristram.Ha@micrel.com>
> 
> Please, try to fix this properly.  Unless you have a known chip errata
with the TX interrupt
> that cannot be worked around reasonably, which would need to be
detailed and explained
> completely in the commit log message, you should try to figure out
what the real problem is.  
> 
> Otherwise just tossing everything to a workqueue looks like a hack, at
best.
> 
> I suspect you have some kind of race between IRQ processing and the
> ->ndo_start_xmit() handler, so you end up missing a queue wakeup.
> Either that or you end up misprogramming the hardware due to the race.
> 
> There is no way I'm applying this as-is.

As I explained a long time ago (last year), this patch is no longer
considered as a fix but for performance.

The transmit done interrupt in the KSZ8851 chips is not required for
normal operation.  Turning it off actually will improve transmit
performance because the system will not be interrupted every time a
packet is sent.

This driver runs on SPI bus.  Just reading register requires a workqueue
because it cannot be done under interrupt context.  Processing the
transmit interrupt requires scheduling a workqueue anyway.

I tested the driver under the Beagle Zippy2 board with a 24 MHz SPI bus
clock, which limits the throughput to 10 Mbps.  On other systems the
transmit performance improvement may be greater, but I do not have that
data to back me up.

If you feel strongly that this workqueue implementation is not
appropriate, then please disregard the patch.
