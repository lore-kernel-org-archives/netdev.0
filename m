From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 3/3] qeth: fix VLAN related compilation errors
Date: Sun, 21 Apr 2013 12:09:34 +0200
Message-ID: <1366538974-4589-3-git-send-email-kaber@trash.net>
References: <1366538974-4589-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, amwang@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62322 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752882Ab3DUKJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Apr 2013 06:09:44 -0400
In-Reply-To: <1366538974-4589-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   drivers/s390/net/qeth_l3_main.c: In function 'qeth_l3_add_vlan_mc':
>> drivers/s390/net/qeth_l3_main.c:1662:3: error: too few arguments to function '__vlan_find_dev_deep'
   include/linux/if_vlan.h:88:27: note: declared here
   drivers/s390/net/qeth_l3_main.c: In function 'qeth_l3_add_vlan_mc6':
>> drivers/s390/net/qeth_l3_main.c:1723:3: error: too few arguments to function '__vlan_find_dev_deep'
   include/linux/if_vlan.h:88:27: note: declared here
   drivers/s390/net/qeth_l3_main.c: In function 'qeth_l3_free_vlan_addresses4':
>> drivers/s390/net/qeth_l3_main.c:1767:2: error: too few arguments to function '__vlan_find_dev_deep'
   include/linux/if_vlan.h:88:27: note: declared here
   drivers/s390/net/qeth_l3_main.c: In function 'qeth_l3_free_vlan_addresses6':
>> drivers/s390/net/qeth_l3_main.c:1797:2: error: too few arguments to function '__vlan_find_dev_deep'
   include/linux/if_vlan.h:88:27: note: declared here
   drivers/s390/net/qeth_l3_main.c: In function 'qeth_l3_process_inbound_buffer':
>> drivers/s390/net/qeth_l3_main.c:1980:6: error: too few arguments to function '__vlan_hwaccel_put_tag'
   include/linux/if_vlan.h:234:31: note: declared here
   drivers/s390/net/qeth_l3_main.c: In function 'qeth_l3_verify_vlan_dev':
>> drivers/s390/net/qeth_l3_main.c:2089:3: error: too few arguments to function '__vlan_find_dev_deep'
   include/linux/if_vlan.h:88:27: note: declared here

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 drivers/s390/net/qeth_l3_main.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 6426868..c915e5c 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1659,7 +1659,8 @@ static void qeth_l3_add_vlan_mc(struct qeth_card *card)
 	for_each_set_bit(vid, card->active_vlans, VLAN_N_VID) {
 		struct net_device *netdev;
 
-		netdev = __vlan_find_dev_deep(card->dev, vid);
+		netdev = __vlan_find_dev_deep(card->dev, htons(ETH_P_8021Q),
+					      vid);
 		if (netdev == NULL ||
 		    !(netdev->flags & IFF_UP))
 			continue;
@@ -1720,7 +1721,8 @@ static void qeth_l3_add_vlan_mc6(struct qeth_card *card)
 	for_each_set_bit(vid, card->active_vlans, VLAN_N_VID) {
 		struct net_device *netdev;
 
-		netdev = __vlan_find_dev_deep(card->dev, vid);
+		netdev = __vlan_find_dev_deep(card->dev, htons(ETH_P_8021Q),
+					      vid);
 		if (netdev == NULL ||
 		    !(netdev->flags & IFF_UP))
 			continue;
@@ -1764,7 +1766,7 @@ static void qeth_l3_free_vlan_addresses4(struct qeth_card *card,
 
 	QETH_CARD_TEXT(card, 4, "frvaddr4");
 
-	netdev = __vlan_find_dev_deep(card->dev, vid);
+	netdev = __vlan_find_dev_deep(card->dev, htons(ETH_P_8021Q), vid);
 	if (!netdev)
 		return;
 	in_dev = in_dev_get(netdev);
@@ -1794,7 +1796,7 @@ static void qeth_l3_free_vlan_addresses6(struct qeth_card *card,
 
 	QETH_CARD_TEXT(card, 4, "frvaddr6");
 
-	netdev = __vlan_find_dev_deep(card->dev, vid);
+	netdev = __vlan_find_dev_deep(card->dev, htons(ETH_P_8021Q), vid);
 	if (!netdev)
 		return;
 	in6_dev = in6_dev_get(netdev);
@@ -1977,7 +1979,8 @@ static int qeth_l3_process_inbound_buffer(struct qeth_card *card,
 						      &vlan_tag);
 				len = skb->len;
 				if (is_vlan && !card->options.sniffer)
-					__vlan_hwaccel_put_tag(skb, vlan_tag);
+					__vlan_hwaccel_put_tag(skb,
+						htons(ETH_P_8021Q), vlan_tag);
 				napi_gro_receive(&card->napi, skb);
 			}
 			break;
@@ -2086,7 +2089,8 @@ static int qeth_l3_verify_vlan_dev(struct net_device *dev,
 		struct net_device *netdev;
 
 		rcu_read_lock();
-		netdev = __vlan_find_dev_deep(card->dev, vid);
+		netdev = __vlan_find_dev_deep(card->dev, htons(ETH_P_8021Q),
+					      vid);
 		rcu_read_unlock();
 		if (netdev == dev) {
 			rc = QETH_VLAN_CARD;
-- 
1.8.1.4
