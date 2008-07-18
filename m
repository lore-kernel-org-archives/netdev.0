From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] igb/ixgbe/e1000e: resolve tx multiqueue bug
Date: Fri, 18 Jul 2008 04:37:08 -0700 (PDT)
Message-ID: <20080718.043708.19461520.davem@davemloft.net>
References: <20080718110225.20696.14881.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43492
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757311AbYGRLhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 07:37:08 -0400
In-Reply-To: <20080718110225.20696.14881.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 18 Jul 2008 04:02:25 -0700

> With the recent changes to tx mutiqueue, igb/ixgbe/e1000e was not calling
> netif_tx_start_all_queues() before calling netif_tx_wake_all_queues().
> This causes an issue during loading of the driver.
> 
> In addition, updated e1000e to use the updated tx mutliqueue api.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Thanks Jeff.  I've applied this to kill the BUG() triggers you were
seeing.

Background for everyone else:

1) These drivers have a watchdog handler that watches the PHY state
   and wakes the TX queue when the link comes up.

2) Since ->open() was not doing a start queue, we would do a wake
   queue while attached to the noop_qdisc

This causes the BUG check in netif_schedule() to trigger.

After some discussion with Jeff I've advised him that it's not
kosher for the driver to manage the TX queue wake state like
this in respose to link up and down events, but rather simply
maintaining the netif_carrier state is all that is needed.

When netif_carrier_ok() is false, we're attached to the noop_qdisc
which eats all packets and frees them up, never sending them down
to the device.

When netif_carrier_ok() is true, we attach to the configured normal
qdisc and packets begin flowing to the device again.

Jeff told me he will take a look more deeply into this.

