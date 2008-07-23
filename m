From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] skge: resolve tx multiqueue bug
Date: Wed, 23 Jul 2008 16:50:13 +0800
Message-ID: <4886F0C5.7040605@cn.fujitsu.com>
References: <d4b984a30807210914nd4d0db5yb7b93ca5143ff0d5@mail.gmail.com> <20080721.092027.14394005.davem@davemloft.net> <d4b984a30807220254t1aaf6ac4q874329966511b0c5@mail.gmail.com> <20080723054039.GA2272@gentoox2.trippelsdorf.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alessandro Guido <ag@alessandroguido.name>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62350 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750721AbYGWIvz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2008 04:51:55 -0400
In-Reply-To: <20080723054039.GA2272@gentoox2.trippelsdorf.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Markus Trippelsdorf said the following on 2008-7-23 13:40:
> On Tue, Jul 22, 2008 at 11:54:26AM +0200, Alessandro Guido wrote:
>> Got a WARNING this morning (2.6.26-05752-g93ded9b) and I think it's related.
> 
> Same thing here (latest git):
> 
> skge eth1: enabling interface
> skge eth1: disabling interface
> ------------[ cut here ]------------
> WARNING: at net/core/dev.c:1344 __netif_schedule+0x24/0x6d()
> Pid: 1904, comm: ip Not tainted 2.6.26-06077-gc010b2f #33
> 
> Call Trace:
>  [<ffffffff8022e5f4>] warn_on_slowpath+0x4c/0x87
>  [<ffffffff802fc5cb>] delay_tsc+0x0/0x55
>  [<ffffffff802fc5cb>] delay_tsc+0x0/0x55
>  [<ffffffff802fc5e7>] delay_tsc+0x1c/0x55
>  [<ffffffff8037e2ee>] gm_phy_write+0x50/0x90
>  [<ffffffff8037e2f8>] gm_phy_write+0x5a/0x90
>  [<ffffffff8037f03f>] skge_led+0x1fb/0x20b
>  [<ffffffff804202e8>] __netif_schedule+0x24/0x6d
>  [<ffffffff80381298>] skge_down+0x440/0x4cf
>  [<ffffffff803814be>] skge_change_mtu+0x3d/0x61
>  [<ffffffff80420775>] dev_set_mtu+0x46/0x79
>  [<ffffffff80427a51>] do_setlink+0x1c5/0x31f
>  [<ffffffff804287d3>] rtnl_newlink+0x2b9/0x3e3
>  [<ffffffff804285a8>] rtnl_newlink+0x8e/0x3e3
>  [<ffffffff80428d69>] rtnetlink_rcv_msg+0x5a/0x1ea
>  [<ffffffff80428d0f>] rtnetlink_rcv_msg+0x0/0x1ea
>  [<ffffffff8042efde>] netlink_rcv_skb+0x34/0x7e
>  [<ffffffff80428d09>] rtnetlink_rcv+0x1f/0x25
>  [<ffffffff8042eb97>] netlink_unicast+0x119/0x17f
>  [<ffffffff8041b35d>] __alloc_skb+0x61/0x123
>  [<ffffffff8042ee37>] netlink_sendmsg+0x23a/0x24d
>  [<ffffffff804152e4>] sock_sendmsg+0xcb/0xe3
>  [<ffffffff8023f670>] autoremove_wake_function+0x0/0x2e
>  [<ffffffff80225643>] need_resched+0x1e/0x28
>  [<ffffffff804147d8>] move_addr_to_kernel+0x25/0x36
>  [<ffffffff8041c090>] verify_iovec+0x46/0x82
>  [<ffffffff80415513>] sys_sendmsg+0x217/0x28a
>  [<ffffffff8042e01e>] netlink_insert+0xfe/0x121
>  [<ffffffff80414b40>] sockfd_lookup_light+0x1a/0x52
>  [<ffffffff80261fe5>] __vma_link+0x58/0x61
>  [<ffffffff80262062>] vma_link+0x74/0x99
>  [<ffffffff802630ce>] do_brk+0x2c1/0x319
>  [<ffffffff8020b3eb>] system_call_after_swapgs+0x7b/0x80
> 
> ---[ end trace 92936ef183e09876 ]---
> skge eth1: enabling interface
> skge eth1: Link is up at 100 Mbps, full duplex, flow control both
> 

Markus, please try this.

- Add netif_start_queue() in ->open()
- netif_carrier_*() is enough, remove netif_*_queue()

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 2e26dce..7507585 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -1069,7 +1069,6 @@ static void skge_link_up(struct skge_port *skge)
 		    LED_BLK_OFF|LED_SYNC_OFF|LED_ON);
 
 	netif_carrier_on(skge->netdev);
-	netif_wake_queue(skge->netdev);
 
 	if (netif_msg_link(skge)) {
 		printk(KERN_INFO PFX
@@ -1084,7 +1083,6 @@ static void skge_link_down(struct skge_port *skge)
 {
 	skge_write8(skge->hw, SK_REG(skge->port, LNK_LED_REG), LED_OFF);
 	netif_carrier_off(skge->netdev);
-	netif_stop_queue(skge->netdev);
 
 	if (netif_msg_link(skge))
 		printk(KERN_INFO PFX "%s: Link is down.\n", skge->netdev->name);
@@ -2450,7 +2448,6 @@ static void skge_phy_reset(struct skge_port *skge)
 	int port = skge->port;
 	struct net_device *dev = hw->dev[port];
 
-	netif_stop_queue(skge->netdev);
 	netif_carrier_off(skge->netdev);
 
 	spin_lock_bh(&hw->phy_lock);
@@ -2640,6 +2637,7 @@ static int skge_up(struct net_device *dev)
 	spin_unlock_irq(&hw->hw_lock);
 
 	napi_enable(&skge->napi);
+	netif_start_queue(dev);
 	return 0;
 
  free_rx_ring:
@@ -3863,7 +3861,6 @@ static struct net_device *skge_devinit(struct skge_hw *hw, int port,
 
 	/* device is off until link detection */
 	netif_carrier_off(dev);
-	netif_stop_queue(dev);
 
 	return dev;
 }

