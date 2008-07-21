From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Sun, 20 Jul 2008 22:11:06 -0700 (PDT)
Message-ID: <20080720.221106.201055562.davem@davemloft.net>
References: <20080720.181440.122144107.davem@davemloft.net>
	<20080721024056.GA4800@martell.zuzino.mipt.ru>
	<20080720.194856.92564555.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49010
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758170AbYGUFLH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 01:11:07 -0400
In-Reply-To: <20080720.194856.92564555.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sun, 20 Jul 2008 19:48:56 -0700 (PDT)

> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Mon, 21 Jul 2008 06:40:56 +0400
> 
> > OK, the problem is really this buglet:
> > 
> > 	BUG_ON(q == &noop_qdisc);
> > 	__netif_schedule
> > 	netif_tx_wake_queue
> > 	netif_wake_queue
> > 	atl1_check_link
> > 	atl1_up		or	atlx_link_chg_task
> > 				run_workqueue
> 
> Thanks for the backtrace I'll work on fixing this.

[ Jeff and co., this is basically the kind of patch I want
  to see eventually for the Intel drivers too... ]

Alexey, please try this patch:

atl1: Do not wake queue before queue has been started.

Based upon a bug report by Alexey Dobriyan.

Packet flow during link state events should not be done by
waking and stopping the TX queue anyways, that is handled
transparently by netif_carrier_{on,off}().

So, remove the netif_{wake,stop}_queue() calls in the link
check code, and add the necessary netif_start_queue() call
to atl1_up().

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 3e22e78..f12e3d1 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -1308,7 +1308,6 @@ static u32 atl1_check_link(struct atl1_adapter *adapter)
 				dev_info(&adapter->pdev->dev, "link is down\n");
 			adapter->link_speed = SPEED_0;
 			netif_carrier_off(netdev);
-			netif_stop_queue(netdev);
 		}
 		return 0;
 	}
@@ -1358,7 +1357,6 @@ static u32 atl1_check_link(struct atl1_adapter *adapter)
 		if (!netif_carrier_ok(netdev)) {
 			/* Link down -> Up */
 			netif_carrier_on(netdev);
-			netif_wake_queue(netdev);
 		}
 		return 0;
 	}
@@ -2627,6 +2625,7 @@ static s32 atl1_up(struct atl1_adapter *adapter)
 	mod_timer(&adapter->watchdog_timer, jiffies);
 	atlx_irq_enable(adapter);
 	atl1_check_link(adapter);
+	netif_start_queue(netdev);
 	return 0;
 
 err_up:
