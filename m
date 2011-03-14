From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: [PATCH 1/2] macvlan : fix checksums error when we are in bridge mode
Date: Mon, 14 Mar 2011 17:08:07 +0100
Message-ID: <1300118888-2311-1-git-send-email-daniel.lezcano@free.fr>
Cc: kaber@trash.net, nightnord@gmail.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([194.196.100.161]:55355 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753500Ab1CNQIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 12:08:19 -0400
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate1.uk.ibm.com (8.13.1/8.13.1) with ESMTP id p2EG8HW7015534
	for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 16:08:17 GMT
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2EG8Zn71745064
	for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 16:08:35 GMT
Received: from d06av06.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2EG8GSo022907
	for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 10:08:17 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the lower device has offloading capabilities, the packets checksums
are not computed. That leads to have any macvlan port in bridge mode to
not work because the packets are dropped due to a bad checksum.

If the macvlan is in bridge mode, the packet is forwarded to another
macvlan port and reach the network stack where it looks for a checksum
but this one was not computed due to the offloading of the lower device.
In this case, we have to set the packet with CHECKSUM_UNNECESSARY
when it is forwarded to a bridged port and restore the previous value of
ip_summed when the packet goes to the lowerdev.

Signed-off-by: Daniel Lezcano <daniel.lezcano@free.fr>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Andrian Nord <nightnord@gmail.com>
---
 drivers/net/macvlan.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 6ed577b..497991b 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -219,9 +219,11 @@ static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	const struct macvlan_dev *vlan = netdev_priv(dev);
 	const struct macvlan_port *port = vlan->port;
 	const struct macvlan_dev *dest;
+	__u8 ip_summed = skb->ip_summed;
 
 	if (vlan->mode == MACVLAN_MODE_BRIDGE) {
 		const struct ethhdr *eth = (void *)skb->data;
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 		/* send to other bridge ports directly */
 		if (is_multicast_ether_addr(eth->h_dest)) {
@@ -241,6 +243,7 @@ static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 xmit_world:
+	skb->ip_summed = ip_summed;
 	skb_set_dev(skb, vlan->lowerdev);
 	return dev_queue_xmit(skb);
 }
-- 
1.7.1

