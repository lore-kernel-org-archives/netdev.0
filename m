From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/4] net: dsa: Utilize switchdev_port_bridge_getlink_deferred()
Date: Mon,  9 Jan 2017 11:45:03 -0800
Message-ID: <20170109194503.10713-5-f.fainelli@gmail.com>
References: <20170109194503.10713-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, jiri@resnulli.us,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34302 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763772AbdAITpP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 14:45:15 -0500
Received: by mail-pf0-f195.google.com with SMTP id y143so4012806pfb.1
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 11:45:14 -0800 (PST)
In-Reply-To: <20170109194503.10713-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes the following sleeping in atomic splat:

[   69.008021] BUG: sleeping function called from invalid context at kernel/locking/mutex.c:752
[   69.016523] in_atomic(): 1, irqs_disabled(): 0, pid: 1528, name: bridge
[   69.023167] INFO: lockdep is turned off.
[   69.027118] CPU: 1 PID: 1528 Comm: bridge Not tainted 4.10.0-rc2-00131-g719651624789-dirty #205
[   69.035840] Hardware name: Broadcom STB (Flattened Device Tree)
[   69.041796] [<c020fc40>] (unwind_backtrace) from [<c020ba28>] (show_stack+0x10/0x14)
[   69.049570] [<c020ba28>] (show_stack) from [<c04fb91c>] (dump_stack+0xb0/0xdc)
[   69.056823] [<c04fb91c>] (dump_stack) from [<c0244d00>] (___might_sleep+0x1a4/0x2a4)
[   69.064599] [<c0244d00>] (___might_sleep) from [<c08f3eb8>] (mutex_lock_nested+0x28/0x7d8)
[   69.072897] [<c08f3eb8>] (mutex_lock_nested) from [<c0674dbc>] (b53_vlan_dump+0x2c/0x104)
[   69.081105] [<c0674dbc>] (b53_vlan_dump) from [<c08eba88>] (switchdev_port_obj_dump_now+0x30/0x6c)
[   69.090094] [<c08eba88>] (switchdev_port_obj_dump_now) from [<c08ebb00>] (switchdev_port_obj_dump+0x3c/0x98)
[   69.099950] [<c08ebb00>] (switchdev_port_obj_dump) from [<c08ebc34>] (switchdev_port_vlan_fill+0x68/0x90)
[   69.109550] [<c08ebc34>] (switchdev_port_vlan_fill) from [<c07f13a4>] (ndo_dflt_bridge_getlink+0x28c/0x4fc)
[   69.119320] [<c07f13a4>] (ndo_dflt_bridge_getlink) from [<c08eb2c8>] (switchdev_port_bridge_getlink+0xc4/0xd4)
[   69.129350] [<c08eb2c8>] (switchdev_port_bridge_getlink) from [<c07f0b10>] (rtnl_bridge_getlink+0x12c/0x28c)
[   69.139206] [<c07f0b10>] (rtnl_bridge_getlink) from [<c0802e28>] (netlink_dump+0xe8/0x268)
[   69.147495] [<c0802e28>] (netlink_dump) from [<c0803864>] (__netlink_dump_start+0x12c/0x18c)
[   69.155958] [<c0803864>] (__netlink_dump_start) from [<c07f3c34>] (rtnetlink_rcv_msg+0x11c/0x228)
[   69.164857] [<c07f3c34>] (rtnetlink_rcv_msg) from [<c0805e3c>] (netlink_rcv_skb+0xc4/0xd8)
[   69.173145] [<c0805e3c>] (netlink_rcv_skb) from [<c07f1110>] (rtnetlink_rcv+0x28/0x30)
[   69.181087] [<c07f1110>] (rtnetlink_rcv) from [<c080577c>] (netlink_unicast+0x16c/0x238)
[   69.189201] [<c080577c>] (netlink_unicast) from [<c0805c3c>] (netlink_sendmsg+0x350/0x364)
[   69.197493] [<c0805c3c>] (netlink_sendmsg) from [<c07beab0>] (sock_sendmsg+0x14/0x24)
[   69.205350] [<c07beab0>] (sock_sendmsg) from [<c07bfdbc>] (SyS_sendto+0xb8/0xe0)
[   69.212769] [<c07bfdbc>] (SyS_sendto) from [<c07bfdfc>] (SyS_send+0x18/0x20)
[   69.219841] [<c07bfdfc>] (SyS_send) from [<c0208100>] (ret_fast_syscall+0x0/0x1c)

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/slave.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 5cd5b8137c08..b38536f951ea 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1038,7 +1038,7 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_netpoll_cleanup	= dsa_slave_netpoll_cleanup,
 	.ndo_poll_controller	= dsa_slave_poll_controller,
 #endif
-	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
+	.ndo_bridge_getlink	= switchdev_port_bridge_getlink_deferred,
 	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
 	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
 	.ndo_get_phys_port_id	= dsa_slave_get_phys_port_id,
-- 
2.9.3
