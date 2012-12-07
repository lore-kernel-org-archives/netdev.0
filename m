From: Eric Leblond <eric@regit.org>
Subject: [RFC PATCH] af_packet: don't to defrag shared skb
Date: Fri,  7 Dec 2012 19:56:01 +0100
Message-ID: <1354906561-4695-1-git-send-email-eric@regit.org>
Cc: Eric Leblond <eric@regit.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ks28632.kimsufi.com ([91.121.96.152]:42619 "EHLO
	ks28632.kimsufi.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758Ab2LGS4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 13:56:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is adding a check on skb before trying to defrag the
packet for the hash computation in fanout mode. The goal of this
patch is to avoid an kernel crash in pskb_expand_head.
It appears that under some specific condition there is a shared
skb reaching the defrag code and this lead to a crash due to the
following code:

	if (skb_shared(skb))
		BUG();

I've observed this crash under the following condition:
 1. a program is listening to an wifi interface (let say wlan0)
 2. it is using fanout capture in flow load balancing mode
 3. defrag option is on on the fanout socket
 4. the interface disconnect (radio down for example)
 5. the interface reconnect (radio switched up)
 6. once reconnected a single packet is seen with skb->users=2
 7. the kernel crash in pskb_expand_head at skbuff.c:1035

[BBB55:744364] [<ffffffff812a2761>] ? __pskb_pull_tail+0x43x0x26f
[BB8S5.744395] [<ffffffff812d29Tb>] ? ip_check_defrag+ox3a/0x14a
[BBB55.744422] [<ffffffffB1344459>] ? packet_rcv_fanout+ox5e/oxf9
[BBBS5.7444S0] [<ffffffffB12aaS9b>] ? __netif_receive_skb+ox444/ox4f9
[BBB55.T4447B] [<ffffffffB12aa?e1>] ? netif_receive_skb+ox6d/0x?3
[BBB55.T4447B] [<ffffffffB12aa?e1>] ? ieee80211_deliver_skb+0xbd/0xfa [mac80211]
[BBB55.T4447B] [<ffffffffB12aa?e1>] ? ieee80211_rx_h_data+0x1e0/0x21a [mac80211]
[BBB55.T4447B] [<ffffffffB12aa?e1>] ? ieee80211_rx_handlers+0x3d5/0x480 [mac80211]
[BBB55.T4447B] [<ffffffffB12aa?e1>] ? __wake_up
[BBB55.T4447B] [<ffffffffB12aa?e1>] ? evdev_eventr+0xc0/0xcf [evdev]

Signed-off-by: Eric Leblond <eric@regit.org>
---
 net/packet/af_packet.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index e639645..4b453f8 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1110,7 +1110,7 @@ static int packet_rcv_fanout(struct sk_buff *skb, struct net_device *dev,
 	switch (f->type) {
 	case PACKET_FANOUT_HASH:
 	default:
-		if (f->defrag) {
+		if (f->defrag && !skb_shared(skb)) {
 			skb = ip_check_defrag(skb, IP_DEFRAG_AF_PACKET);
 			if (!skb)
 				return 0;
-- 
1.7.10.4
