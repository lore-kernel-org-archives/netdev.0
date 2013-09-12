From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH net-next] fix NULL pointer dereference in br_handle_frame
Date: Thu, 12 Sep 2013 20:16:35 +0800
Message-ID: <1378988195-2710-1-git-send-email-zhiguohong@tencent.com>
Cc: davem@davemloft.net, zhiguohong@tencent.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:58618 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753528Ab3ILMS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 08:18:57 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so10444920pbb.5
        for <netdev@vger.kernel.org>; Thu, 12 Sep 2013 05:18:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hong Zhiguo <zhiguohong@tencent.com>

In function netdev_rx_handler_unregister it's said that:

/* a reader seeing a non NULL rx_handler in a rcu_read_lock()
 * section has a guarantee to see a non NULL rx_handler_data
 * as well.
 */

This is true. But br_port_get_rcu(dev) returns NULL if:
	!(dev->priv_flags & IFF_BRIDGE_PORT)

And this happended on my box when br_handle_frame is called
between these 2 lines of del_nbp:

	dev->priv_flags &= ~IFF_BRIDGE_PORT;
	/* --> br_handle_frame is called at this time */
	netdev_upper_dev_unlink(dev, br->dev);

I got below Oops(some lines omitted):
BUG: unable to handle kernel NULL pointer dereference at 0000000000000021
IP: [<ffffffff8150901d>] br_handle_frame+0xed/0x230
Oops: 0000 [#1] PREEMPT SMP
RIP: 0010:[<ffffffff8150901d>]  [<ffffffff8150901d>] br_handle_frame+0xed/0x230
RSP: 0018:ffff880030403c10  EFLAGS: 00010286
Stack:
 ffff88002c945700 ffffffff81508f30 0000000000000000 ffff88002d41e000
 ffff880030403c98 ffffffff81477acb ffffffff81477821 ffff880030403c68
 ffffffff81090e10 00ff88002d545c80 ffff88002c945700 ffffffff81aa50c0
Call Trace:
 <IRQ>
 [<ffffffff81508f30>] ? br_handle_frame_finish+0x300/0x300
 [<ffffffff81477acb>] __netif_receive_skb_core+0x39b/0x880

Signed-off-by: Hong Zhiguo <zhiguohong@tencent.com>
---
 net/bridge/br_if.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index c41d5fb..bd21159 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -133,6 +133,8 @@ static void del_nbp(struct net_bridge_port *p)
 
 	sysfs_remove_link(br->ifobj, p->dev->name);
 
+	netdev_rx_handler_unregister(dev);
+
 	dev_set_promiscuity(dev, -1);
 
 	spin_lock_bh(&br->lock);
@@ -148,8 +150,6 @@ static void del_nbp(struct net_bridge_port *p)
 
 	dev->priv_flags &= ~IFF_BRIDGE_PORT;
 
-	netdev_rx_handler_unregister(dev);
-
 	netdev_upper_dev_unlink(dev, br->dev);
 
 	br_multicast_del_port(p);
-- 
1.8.1.2
