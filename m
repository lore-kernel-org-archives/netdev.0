From: David Miller <davem@davemloft.net>
Subject: Re: 24rc8: unregister_netdevice: waiting for ... to become free
Date: Sat, 03 May 2008 21:11:09 -0700 (PDT)
Message-ID: <20080503.211109.71037948.davem@davemloft.net>
References: <008f01c8ac51$83dbd5d0$6400a8c0@bui.materna.com>
	<20080502.054536.109642865.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, g4klx@g4klx.demon.co.uk
To: devzero@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48571
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750696AbYEDELK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 00:11:10 -0400
In-Reply-To: <20080502.054536.109642865.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 02 May 2008 05:45:36 -0700 (PDT)

> From: "Roland" <devzero@web.de>
> Date: Fri, 2 May 2008 14:38:36 +0200
> 
> > it seems it`s lapbether driver
> > 
> > reproduce:
> > 
> > on system with pcnet32 (vmware) do
> > 
> > modprobe pcnet32
> > modprobe lapbether
> > modprobe -r lapbether
> > modprobe -r pcnet32 -> hang -> unregister_netdevice: waiting for eth0 to 
> > become free
> 
> lapbeth_cleanup_driver() unregisters the netdevice, but does not
> release the reference to lapbeth->ethdev in those device instances.
> 
> Once this happens, and the lapbeth_dev_notifier is unregistered,
> these references will leak forever.

Roland, does this fix your bug?

lapbeth: Release ->ethdev when unregistering device.

Otherwise it leaks forever.

Based upon a report by Roland <devzero@web.de>

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
index b5860b9..24fd613 100644
--- a/drivers/net/wan/lapbether.c
+++ b/drivers/net/wan/lapbether.c
@@ -459,6 +459,7 @@ static void __exit lapbeth_cleanup_driver(void)
 	list_for_each_safe(entry, tmp, &lapbeth_devices) {
 		lapbeth = list_entry(entry, struct lapbethdev, node);
 
+		dev_put(lapbeth->ethdev);
 		unregister_netdevice(lapbeth->axdev);
 	}
 	rtnl_unlock();
