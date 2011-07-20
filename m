From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 39/47] qeth: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:41 +0200
Message-ID: <1311173689-17419-40-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	ursula.braun@de.ibm.com, blaschka@linux.vnet.ibm.com,
	linux390@de.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13348 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752310Ab1GTO4N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:56:13 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill card->vlangrp and qeth_l3_vlan_rx_register

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/s390/net/qeth_core.h      |    2 +-
 drivers/s390/net/qeth_core_main.c |    1 -
 drivers/s390/net/qeth_l3_main.c   |  100 +++++++++++++++++--------------------
 3 files changed, 47 insertions(+), 56 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index d3cee33..26a4110 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -720,7 +720,7 @@ struct qeth_card {
 	wait_queue_head_t wait_q;
 	spinlock_t vlanlock;
 	spinlock_t mclock;
-	struct vlan_group *vlangrp;
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	struct list_head vid_list;
 	struct list_head mc_list;
 	struct work_struct kernel_thread_starter;
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index dd08f7b..4550573 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1097,7 +1097,6 @@ static int qeth_setup_card(struct qeth_card *card)
 	card->dev = NULL;
 	spin_lock_init(&card->vlanlock);
 	spin_lock_init(&card->mclock);
-	card->vlangrp = NULL;
 	spin_lock_init(&card->lock);
 	spin_lock_init(&card->ip_lock);
 	spin_lock_init(&card->thread_mask_lock);
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index e2c9ac5..fafb8c2 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -13,6 +13,7 @@
 
 #include <linux/module.h>
 #include <linux/moduleparam.h>
+#include <linux/bitops.h>
 #include <linux/string.h>
 #include <linux/errno.h>
 #include <linux/kernel.h>
@@ -23,6 +24,7 @@
 #include <linux/inetdevice.h>
 #include <linux/igmp.h>
 #include <linux/slab.h>
+#include <linux/if_vlan.h>
 
 #include <net/ip.h>
 #include <net/arp.h>
@@ -1696,16 +1698,18 @@ static void qeth_l3_add_mc(struct qeth_card *card, struct in_device *in4_dev)
 static void qeth_l3_add_vlan_mc(struct qeth_card *card)
 {
 	struct in_device *in_dev;
-	struct vlan_group *vg;
-	int i;
+	u16 vid;
 
 	QETH_CARD_TEXT(card, 4, "addmcvl");
-	if (!qeth_is_supported(card, IPA_FULL_VLAN) || (card->vlangrp == NULL))
+	if (!qeth_is_supported(card, IPA_FULL_VLAN))
 		return;
 
-	vg = card->vlangrp;
-	for (i = 0; i < VLAN_N_VID; i++) {
-		struct net_device *netdev = vlan_group_get_device(vg, i);
+	for_each_set_bit(vid, card->active_vlans, VLAN_N_VID) {
+		struct net_device *netdev;
+
+		rcu_read_lock();
+		netdev = __vlan_find_dev_deep(card->dev, vid);
+		rcu_read_unlock();
 		if (netdev == NULL ||
 		    !(netdev->flags & IFF_UP))
 			continue;
@@ -1759,16 +1763,16 @@ static void qeth_l3_add_mc6(struct qeth_card *card, struct inet6_dev *in6_dev)
 static void qeth_l3_add_vlan_mc6(struct qeth_card *card)
 {
 	struct inet6_dev *in_dev;
-	struct vlan_group *vg;
-	int i;
+	u16 vid;
 
 	QETH_CARD_TEXT(card, 4, "admc6vl");
-	if (!qeth_is_supported(card, IPA_FULL_VLAN) || (card->vlangrp == NULL))
+	if (!qeth_is_supported(card, IPA_FULL_VLAN))
 		return;
 
-	vg = card->vlangrp;
-	for (i = 0; i < VLAN_N_VID; i++) {
-		struct net_device *netdev = vlan_group_get_device(vg, i);
+	for_each_set_bit(vid, card->active_vlans, VLAN_N_VID) {
+		struct net_device *netdev;
+
+		netdev = __vlan_find_dev_deep(card->dev, vid);
 		if (netdev == NULL ||
 		    !(netdev->flags & IFF_UP))
 			continue;
@@ -1806,10 +1810,12 @@ static void qeth_l3_free_vlan_addresses4(struct qeth_card *card,
 	struct in_device *in_dev;
 	struct in_ifaddr *ifa;
 	struct qeth_ipaddr *addr;
+	struct net_device *netdev;
 
 	QETH_CARD_TEXT(card, 4, "frvaddr4");
 
-	in_dev = in_dev_get(vlan_group_get_device(card->vlangrp, vid));
+	netdev = __vlan_find_dev_deep(card->dev, vid);
+	in_dev = in_dev_get(netdev);
 	if (!in_dev)
 		return;
 	for (ifa = in_dev->ifa_list; ifa; ifa = ifa->ifa_next) {
@@ -1832,10 +1838,12 @@ static void qeth_l3_free_vlan_addresses6(struct qeth_card *card,
 	struct inet6_dev *in6_dev;
 	struct inet6_ifaddr *ifa;
 	struct qeth_ipaddr *addr;
+	struct net_device *netdev;
 
 	QETH_CARD_TEXT(card, 4, "frvaddr6");
 
-	in6_dev = in6_dev_get(vlan_group_get_device(card->vlangrp, vid));
+	netdev = __vlan_find_dev_deep(card->dev, vid);
+	in6_dev = in6_dev_get(netdev);
 	if (!in6_dev)
 		return;
 	list_for_each_entry(ifa, &in6_dev->addr_list, if_list) {
@@ -1856,26 +1864,15 @@ static void qeth_l3_free_vlan_addresses6(struct qeth_card *card,
 static void qeth_l3_free_vlan_addresses(struct qeth_card *card,
 			unsigned short vid)
 {
-	if (!card->vlangrp)
-		return;
 	qeth_l3_free_vlan_addresses4(card, vid);
 	qeth_l3_free_vlan_addresses6(card, vid);
 }
 
-static void qeth_l3_vlan_rx_register(struct net_device *dev,
-			struct vlan_group *grp)
+static void qeth_l3_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 {
 	struct qeth_card *card = dev->ml_priv;
-	unsigned long flags;
-
-	QETH_CARD_TEXT(card, 4, "vlanreg");
-	spin_lock_irqsave(&card->vlanlock, flags);
-	card->vlangrp = grp;
-	spin_unlock_irqrestore(&card->vlanlock, flags);
-}
 
-static void qeth_l3_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
-{
+	set_bit(vid, card->active_vlans);
 	return;
 }
 
@@ -1892,7 +1889,7 @@ static void qeth_l3_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 	spin_lock_irqsave(&card->vlanlock, flags);
 	/* unregister IP addresses of vlan device */
 	qeth_l3_free_vlan_addresses(card, vid);
-	vlan_group_set_device(card->vlangrp, vid, NULL);
+	clear_bit(vid, card->active_vlans);
 	spin_unlock_irqrestore(&card->vlanlock, flags);
 	qeth_l3_set_multicast_list(card->dev);
 }
@@ -2014,10 +2011,8 @@ static int qeth_l3_process_inbound_buffer(struct qeth_card *card,
 						      &vlan_tag);
 			len = skb->len;
 			if (is_vlan && !card->options.sniffer)
-				vlan_gro_receive(&card->napi, card->vlangrp,
-					vlan_tag, skb);
-			else
-				napi_gro_receive(&card->napi, skb);
+				__vlan_hwaccel_put_tag(skb, vlan_tag);
+			napi_gro_receive(&card->napi, skb);
 			break;
 		case QETH_HEADER_TYPE_LAYER2: /* for HiperSockets sniffer */
 			skb->pkt_type = PACKET_HOST;
@@ -2118,15 +2113,15 @@ static int qeth_l3_verify_vlan_dev(struct net_device *dev,
 			struct qeth_card *card)
 {
 	int rc = 0;
-	struct vlan_group *vg;
-	int i;
+	u16 vid;
 
-	vg = card->vlangrp;
-	if (!vg)
-		return rc;
+	for_each_set_bit(vid, card->active_vlans, VLAN_N_VID) {
+		struct net_device *netdev;
 
-	for (i = 0; i < VLAN_N_VID; i++) {
-		if (vlan_group_get_device(vg, i) == dev) {
+		rcu_read_lock();
+		netdev = __vlan_find_dev_deep(dev, vid);
+		rcu_read_unlock();
+		if (netdev == dev) {
 			rc = QETH_VLAN_CARD;
 			break;
 		}
@@ -2803,7 +2798,7 @@ static void qeth_l3_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
 	 * before we're going to overwrite this location with next hop ip.
 	 * v6 uses passthrough, v4 sets the tag in the QDIO header.
 	 */
-	if (card->vlangrp && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		if ((ipv == 4) || (card->info.type == QETH_CARD_TYPE_IQD))
 			hdr->hdr.l3.ext_flags = QETH_HDR_EXT_VLAN_FRAME;
 		else
@@ -2988,8 +2983,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				skb_pull(new_skb, ETH_HLEN);
 		}
 
-		if (ipv != 4 && card->vlangrp &&
-				vlan_tx_tag_present(new_skb)) {
+		if (ipv != 4 && vlan_tx_tag_present(new_skb)) {
 			skb_push(new_skb, VLAN_HLEN);
 			skb_copy_to_linear_data(new_skb, new_skb->data + 4, 4);
 			skb_copy_to_linear_data_offset(new_skb, 4,
@@ -3233,14 +3227,13 @@ static const struct net_device_ops qeth_l3_netdev_ops = {
 	.ndo_start_xmit		= qeth_l3_hard_start_xmit,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_multicast_list = qeth_l3_set_multicast_list,
-	.ndo_do_ioctl	   	= qeth_l3_do_ioctl,
-	.ndo_change_mtu	   	= qeth_change_mtu,
-	.ndo_fix_features   	= qeth_l3_fix_features,
-	.ndo_set_features   	= qeth_l3_set_features,
-	.ndo_vlan_rx_register	= qeth_l3_vlan_rx_register,
+	.ndo_do_ioctl		= qeth_l3_do_ioctl,
+	.ndo_change_mtu		= qeth_change_mtu,
+	.ndo_fix_features	= qeth_l3_fix_features,
+	.ndo_set_features	= qeth_l3_set_features,
 	.ndo_vlan_rx_add_vid	= qeth_l3_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid   = qeth_l3_vlan_rx_kill_vid,
-	.ndo_tx_timeout	   	= qeth_tx_timeout,
+	.ndo_tx_timeout		= qeth_tx_timeout,
 };
 
 static const struct net_device_ops qeth_l3_osa_netdev_ops = {
@@ -3250,14 +3243,13 @@ static const struct net_device_ops qeth_l3_osa_netdev_ops = {
 	.ndo_start_xmit		= qeth_l3_hard_start_xmit,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_multicast_list = qeth_l3_set_multicast_list,
-	.ndo_do_ioctl	   	= qeth_l3_do_ioctl,
-	.ndo_change_mtu	   	= qeth_change_mtu,
-	.ndo_fix_features   	= qeth_l3_fix_features,
-	.ndo_set_features   	= qeth_l3_set_features,
-	.ndo_vlan_rx_register	= qeth_l3_vlan_rx_register,
+	.ndo_do_ioctl		= qeth_l3_do_ioctl,
+	.ndo_change_mtu		= qeth_change_mtu,
+	.ndo_fix_features	= qeth_l3_fix_features,
+	.ndo_set_features	= qeth_l3_set_features,
 	.ndo_vlan_rx_add_vid	= qeth_l3_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid   = qeth_l3_vlan_rx_kill_vid,
-	.ndo_tx_timeout	   	= qeth_tx_timeout,
+	.ndo_tx_timeout		= qeth_tx_timeout,
 	.ndo_neigh_setup	= qeth_l3_neigh_setup,
 };
 
-- 
1.7.6

