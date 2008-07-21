From: David Miller <davem@davemloft.net>
Subject: Re: [crash, bisected] Kernel BUG at ffffffff8079afb1
 (__netif_schedule())
Date: Mon, 21 Jul 2008 08:07:27 -0700 (PDT)
Message-ID: <20080721.080727.10939720.davem@davemloft.net>
References: <20080720.104411.81744468.davem@davemloft.net>
	<20080721133059.GA30637@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49988
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751099AbYGUPH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 11:07:27 -0400
In-Reply-To: <20080721133059.GA30637@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 21 Jul 2008 15:30:59 +0200

> -tip testing on latest -git (v2.6.26-5253-g14b395e) triggered the 
> following boot crash on a Core2Duo 64-bit testsystem:
> 
> ADDRCONF(NETDEV_UP): eth0: link is not ready
> eth0: Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX

Should be fixed by:

e1000: resolve tx multiqueue bug

With the recent changes to tx mutiqueue, e1000 was not calling
netif_start_queue() before calling netif_wake_queue().
This causes an oops during loading of the driver.

(Based on commit d55b53fff0c2ddb639dca04c3f5a0854f292d982
("igb/ixgbe/e1000e: resolve tx multiqueue bug").)

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index f8df8bd..cf12b05 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1472,6 +1472,8 @@ e1000_open(struct net_device *netdev)
 
 	e1000_irq_enable(adapter);
 
+	netif_start_queue(netdev);
+
 	/* fire a link status change interrupt to start the watchdog */
 	E1000_WRITE_REG(&adapter->hw, ICS, E1000_ICS_LSC);
 
