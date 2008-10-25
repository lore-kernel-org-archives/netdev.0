From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] oops in net_rx_action on 64-bit powerpc
Date: Sat, 25 Oct 2008 00:17:03 -0700 (PDT)
Message-ID: <20081025.001703.261277154.davem@davemloft.net>
References: <49025C94.60406@nortel.com>
	<20081024.164128.113131091.davem@davemloft.net>
	<4902B1D8.8070800@nortel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, romieu@fr.zoreil.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org
To: cfriesen@nortel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42591
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751081AbYJYHRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2008 03:17:25 -0400
In-Reply-To: <4902B1D8.8070800@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Chris Friesen" <cfriesen@nortel.com>
Date: Fri, 24 Oct 2008 23:42:48 -0600

> David Miller wrote:
> > From: "Chris Friesen" <cfriesen@nortel.com>
> > Date: Fri, 24 Oct 2008 17:39:00 -0600
> > 
> >> So...it would appear that the NAPI code is somehow buggy, and
> >> 6ba33ac should probably be reverted until the problem is found and
> >> fixed.
> > No I think the problem is simple enough that someone should study the
> > ->poll() routine quickly and audit it's return values.
>
> Assuming that amd8111e_rx_poll() is the proper routine, there is
> only one exit point, and it returns "num_rx_pkt".  This variable is
> initialized to zero and increments for each packet sent up the
> stack.

The problematic case in this routine seem to be when the driver
processes exactly "budget" number of packets.

In this case it should not call __netif_rx_complete(), it should instead
use the rx_not_empty label.

Probably the simplest fix is to get rid of the rx_not_empty label and
protect the entire:

	/* Receive descriptor is empty now */
	spin_lock_irqsave(&lp->lock, flags);
	__netif_rx_complete(dev, napi);
	writel(VAL0|RINTEN0, mmio + INTEN0);
	writel(VAL2 | RDMD0, mmio + CMD0);
	spin_unlock_irqrestore(&lp->lock, flags);

code block with a test such as:

	if (rx_pkt_limit > 0)

(yes, greater than zero, not >= 0)

then replace the rx_not_empty goto with a simple break.
