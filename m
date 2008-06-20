From: Trent Piepho <tpiepho@freescale.com>
Subject: Re: phylib interrupt question
Date: Fri, 20 Jun 2008 13:34:46 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0806201319250.7584@t2.domain.actdsltmp>
References: <OF401D8BC0.37350235-ONC1257460.005643D3-80257460.00589565@smsc.com>
 <4B4372CF-7AE3-40B2-980D-4D65637E7382@freescale.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:43466 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758770AbYFTUhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 16:37:07 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.12.11/az33egw02) with ESMTP id m5KKb3bX023573
	for <netdev@vger.kernel.org>; Fri, 20 Jun 2008 13:37:04 -0700 (MST)
In-Reply-To: <4B4372CF-7AE3-40B2-980D-4D65637E7382@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 6 Jun 2008, Andy Fleming wrote:
> The Phylib supports *three* methods of link state detection:
>
> 1) The Phylib handles the irq.  To get this functionality, you set 
> phydev->irq to the irq number.  Obviously, this doesn't work if your PHY is 
> sending interrupts through your MAC's interrupt.  You don't want your MAC's 
> interrupts disabled while the PHY is being managed!

In my quest to decrease boot times, I've found something that seems odd about
the way phylib handles the phy IRQ.

phylib has a work queue, state_queue, that runs one per second
(PHY_STATE_TIME), in interrupt mode and polling mode.  In polling mode it
checks the phy status every other time it runs.  In interrupt mode only when
it's told.  Which makes me wonder if it really needs to always run once per
second in interrupt mode, but that's a different issue.

When a phy interrupt occurs, a different work queue, phy_queue which runs the
function phy_change(), is run.  It disables the irq, sets the phy state
machine to "changed", and re-enables the irq.  It's not clear to me why
interrupts need to be disabled, but that's not my point either.

My issue is that the code triggered by the irq never schedules the state_queue
work queue.  It sets the phy's state to changed, but doesn't actually _do_
anything.  The MAC, net layer, userspace, etc.  don't find out the link went
up or down until state_queue's timer runs the queue one second layer.

If you increase PHY_STATE_TIME to 10 seconds and un-plug/re-plug the cable,
you can see that it takes some time before the kernel responds to the link
change.  If you need to run DHCP to get your device online, then this waiting
time gets added to your boot time.

It seems like this simple patch is all that's needed to fix it:
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -728,6 +728,7 @@ static void phy_change(struct work_struct *work)
  	if (err)
 		goto irq_enable_err;

+	schedule_work(&phydev->state_queue);
  	return;

  irq_enable_err:


So is there any reason not to do this?
