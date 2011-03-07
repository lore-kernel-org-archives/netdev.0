From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6] net: reinject arps into bonding slave instead
 of master
Date: Mon, 7 Mar 2011 13:51:00 +0100
Message-ID: <20110307125059.GA6053@psychotron.brq.redhat.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com>
 <1299320969-7951-7-git-send-email-jpirko@redhat.com>
 <4D7249BA.8030401@gmail.com>
 <20110305144314.GC8573@psychotron.redhat.com>
 <4D724DB4.9020207@gmail.com>
 <4D737D00.20406@gmail.com>
 <20110306133413.GB2795@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58665 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751301Ab1CGMvM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 07:51:12 -0500
Content-Disposition: inline
In-Reply-To: <20110306133413.GB2795@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent patch "bonding: move processing of recv handlers into
handle_frame()" caused a regression on following net scheme:

eth0 - bond0 - bond0.5

where arp monitoring is happening over vlan. This patch fixes it by
reinjecting the arp packet into bonding slave device so the bonding
rx_handler can pickup and process it.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 net/core/dev.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index c71bd18..3d88458 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3094,12 +3094,12 @@ void netdev_rx_handler_unregister(struct net_device *dev)
 }
 EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
 
-static void vlan_on_bond_hook(struct sk_buff *skb)
+static void vlan_on_bond_hook(struct sk_buff *skb, struct net_device *orig_dev)
 {
 	/*
 	 * Make sure ARP frames received on VLAN interfaces stacked on
 	 * bonding interfaces still make their way to any base bonding
-	 * device that may have registered for a specific ptype.
+	 * device by reinjecting the frame into bonding slave (orig_dev)
 	 */
 	if (skb->dev->priv_flags & IFF_802_1Q_VLAN &&
 	    vlan_dev_real_dev(skb->dev)->priv_flags & IFF_BONDING &&
@@ -3108,7 +3108,7 @@ static void vlan_on_bond_hook(struct sk_buff *skb)
 
 		if (!skb2)
 			return;
-		skb2->dev = vlan_dev_real_dev(skb->dev);
+		skb2->dev = orig_dev;
 		netif_rx(skb2);
 	}
 }
@@ -3202,7 +3202,7 @@ ncls:
 			goto out;
 	}
 
-	vlan_on_bond_hook(skb);
+	vlan_on_bond_hook(skb, orig_dev);
 
 	/* deliver only exact match when indicated */
 	null_or_dev = deliver_exact ? skb->dev : NULL;
-- 
1.7.4

