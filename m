From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH net-next] bridge: fix NULL pointer deref in br_handle_frame
Date: Fri, 13 Sep 2013 11:09:47 +0800
Message-ID: <1379041787-14232-1-git-send-email-zhiguohong@tencent.com>
References: <1378988195-2710-1-git-send-email-zhiguohong@tencent.com>
Cc: davem@davemloft.net, zhiguohong@tencent.com,
	eric.dumazet@gmail.com, vyasevic@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:41076 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944Ab3IMDMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 23:12:36 -0400
Received: by mail-pd0-f179.google.com with SMTP id v10so662188pde.10
        for <netdev@vger.kernel.org>; Thu, 12 Sep 2013 20:12:35 -0700 (PDT)
In-Reply-To: <1378988195-2710-1-git-send-email-zhiguohong@tencent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hong Zhiguo <zhiguohong@tencent.com>

I got an Oops on my box when br_handle_frame is called between these
2 lines of del_nbp:
	dev->priv_flags &= ~IFF_BRIDGE_PORT;
	/* --> br_handle_frame is called at this time */
	netdev_rx_handler_unregister(dev);

In br_handle_frame the return of br_port_get_rcu(dev) is dereferenced
without check but br_port_get_rcu(dev) returns NULL if:
	!(dev->priv_flags & IFF_BRIDGE_PORT)

In my first fix I moved netdev_rx_handler_unregister up. Eric Dumazet
pointed out the testing of IFF_BRIDGE_PORT is not necessary here since
we're in rcu_read_lock and we have synchronize_net() in
netdev_rx_handler_unregister. This fix removed the testing of
IFF_BRIDGE_PORT.

I tested the fix on my box with script doing "brctl addif" and "brctl
delif" repeatedly while a lot of broadcast frame present on the LAN.
I added msleep in del_nbp between setting of priv_flags and unregister
so it's easy to reproduce the oops without the fix.

I'll send another patch to net-next to take care of br_netfilter and
ebtable if necessary(seems there's NULL check following but I'll
have a look).

The Oops(some lines omitted):
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
 net/bridge/br_input.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index a2fd37e..2244049 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -60,7 +60,7 @@ static int br_pass_frame_up(struct sk_buff *skb)
 int br_handle_frame_finish(struct sk_buff *skb)
 {
 	const unsigned char *dest = eth_hdr(skb)->h_dest;
-	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
+	struct net_bridge_port *p = rcu_dereference(skb->dev->rx_handler_data);
 	struct net_bridge *br;
 	struct net_bridge_fdb_entry *dst;
 	struct net_bridge_mdb_entry *mdst;
@@ -143,7 +143,7 @@ drop:
 /* note: already called with rcu_read_lock */
 static int br_handle_local_finish(struct sk_buff *skb)
 {
-	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
+	struct net_bridge_port *p = rcu_dereference(skb->dev->rx_handler_data);
 	u16 vid = 0;
 
 	br_vlan_get_tag(skb, &vid);
@@ -173,7 +173,7 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 	if (!skb)
 		return RX_HANDLER_CONSUMED;
 
-	p = br_port_get_rcu(skb->dev);
+	p = rcu_dereference(skb->dev->rx_handler_data);
 
 	if (unlikely(is_link_local_ether_addr(dest))) {
 		/*
-- 
1.8.1.2
