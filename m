From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG] bnx2 + vlan + TSO : doesnt work
Date: Tue, 18 Jan 2011 00:41:09 +0100
Message-ID: <1295307669.3362.106.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59805 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123Ab1AQXlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 18:41:14 -0500
Received: by wyb28 with SMTP id 28so5550213wyb.19
        for <netdev@vger.kernel.org>; Mon, 17 Jan 2011 15:41:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oh well, my dev machine, with bnx2 and tg3 NICs, isnt working at all
with current linux-2.6 tree (I need vlans on my setup)

tg3 : vlan not working

bnx2 : vlan + TSO not working (or very slowly, since only non GSO frames
are OK)

I suspect recent commits from Jesse are the problem.
(bnx2_xmit() is feeded with zeroed vlan_tci skbs)

Maybe f01a5236bd4b1401 (net offloading: Generalize
netif_get_vlan_features().) ?

I dont see NETIF_F_HW_VLAN_TX being set in vlan_features in net drivers.
They only set this flag in dev->features

I dont think changing all drivers to also set vlan_features makes sense.

Is following patch the right path ? (It does solve my problem)

diff --git a/net/core/dev.c b/net/core/dev.c
index 54277df..5c13e55 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5265,6 +5265,9 @@ int register_netdevice(struct net_device *dev)
 	 */
 	dev->vlan_features |= (NETIF_F_GRO | NETIF_F_HIGHDMA);
 
+	/* allow netif_skb_features() not mask this bit from dev->features */
+	dev->vlan_features |= NETIF_F_HW_VLAN_TX;
+
 	ret = call_netdevice_notifiers(NETDEV_POST_INIT, dev);
 	ret = notifier_to_errno(ret);
 	if (ret)


