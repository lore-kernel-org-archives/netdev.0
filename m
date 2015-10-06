From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 2/3] s390/qeth: optimize MAC handling in rx_mode callback
Date: Tue,  6 Oct 2015 15:12:28 +0200
Message-ID: <1444137149-919-3-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1444137149-919-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com,
	Lakhvich Dmitriy <ldmitriy@ru.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:45153 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752482AbbJFNM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 09:12:57 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Tue, 6 Oct 2015 14:12:54 +0100
In-Reply-To: <1444137149-919-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lakhvich Dmitriy <ldmitriy@ru.ibm.com>

In layer2 mode of the qeth driver, MAC address lists
from struct net_device require mapping to the OSA-card.
The existing implementation is inefficient for lists with
more than several MAC addresses, since for every
ndo_set_rx_mode callback it removes all MAC addresses first,
and then registers the current MAC address list.
This patch changes implementation of ndo_set_rx_mode callback
in qeth, only performing hardware registration/removal for
new/deleted addresses. To shorten lookup of MAC addresses
registered addresses are kept in a hashtable instead of a
linear list.

Signed-off-by: Lakhvich Dmitriy <ldmitriy@ru.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Reviewed-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Reviewed-by: Thomas Richter <tmricht@de.ibm.com>
Tested-by: Christian Borntraeger <borntraeger@de.ibm.com>
---
 drivers/s390/net/qeth_core.h    |  19 ++++--
 drivers/s390/net/qeth_l2_main.c | 137 ++++++++++++++++++++++++++++------------
 2 files changed, 111 insertions(+), 45 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 6719447d..1766a20 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -18,6 +18,7 @@
 #include <linux/bitops.h>
 #include <linux/seq_file.h>
 #include <linux/ethtool.h>
+#include <linux/hashtable.h>
 
 #include <net/ipv6.h>
 #include <net/if_inet6.h>
@@ -739,11 +740,17 @@ struct qeth_vlan_vid {
 	unsigned short vid;
 };
 
-struct qeth_mc_mac {
-	struct list_head list;
-	__u8 mc_addr[MAX_ADDR_LEN];
-	unsigned char mc_addrlen;
-	int is_vmac;
+enum qeth_mac_disposition {
+	QETH_DISP_MAC_DELETE = 0,
+	QETH_DISP_MAC_DO_NOTHING = 1,
+	QETH_DISP_MAC_ADD = 2,
+};
+
+struct qeth_mac {
+	u8 mac_addr[OSA_ADDR_LEN];
+	u8 is_uc:1;
+	u8 disp_flag:2;
+	struct hlist_node hnode;
 };
 
 struct qeth_rx {
@@ -790,7 +797,7 @@ struct qeth_card {
 	spinlock_t mclock;
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	struct list_head vid_list;
-	struct list_head mc_list;
+	DECLARE_HASHTABLE(mac_htable, 4);
 	struct work_struct kernel_thread_starter;
 	spinlock_t thread_mask_lock;
 	unsigned long thread_start_mask;
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index b6eabfa..8f1b091 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -19,7 +19,9 @@
 #include <linux/mii.h>
 #include <linux/ip.h>
 #include <linux/list.h>
-
+#include <linux/hash.h>
+#include <linux/hashtable.h>
+#include <linux/string.h>
 #include "qeth_core.h"
 #include "qeth_l2.h"
 
@@ -28,7 +30,7 @@ static int qeth_l2_stop(struct net_device *);
 static int qeth_l2_send_delmac(struct qeth_card *, __u8 *);
 static int qeth_l2_send_setdelmac(struct qeth_card *, __u8 *,
 			   enum qeth_ipa_cmds);
-static void qeth_l2_set_multicast_list(struct net_device *);
+static void qeth_l2_set_rx_mode(struct net_device *);
 static int qeth_l2_recover(void *);
 static void qeth_bridgeport_query_support(struct qeth_card *card);
 static void qeth_bridge_state_change(struct qeth_card *card,
@@ -193,49 +195,44 @@ static int qeth_l2_send_delgroupmac(struct qeth_card *card, __u8 *mac)
 	return rc;
 }
 
-static void qeth_l2_add_mc(struct qeth_card *card, __u8 *mac, int vmac)
+static inline u32 qeth_l2_mac_hash(const u8 *addr)
 {
-	struct qeth_mc_mac *mc;
-	int rc;
-
-	mc = kmalloc(sizeof(struct qeth_mc_mac), GFP_ATOMIC);
+	return get_unaligned((u32 *)(&addr[2]));
+}
 
-	if (!mc)
-		return;
+static int qeth_l2_write_mac(struct qeth_card *card, struct qeth_mac *mac)
+{
 
-	memcpy(mc->mc_addr, mac, OSA_ADDR_LEN);
-	mc->mc_addrlen = OSA_ADDR_LEN;
-	mc->is_vmac = vmac;
+	int rc;
 
-	if (vmac) {
+	if (mac->is_uc) {
 		rc = qeth_setdel_makerc(card,
-			qeth_l2_send_setdelmac(card, mac, IPA_CMD_SETVMAC));
+				qeth_l2_send_setdelmac(card, mac->mac_addr,
+						IPA_CMD_SETVMAC));
 	} else {
 		rc = qeth_setdel_makerc(card,
-			qeth_l2_send_setgroupmac(card, mac));
+				qeth_l2_send_setgroupmac(card, mac->mac_addr));
 	}
-
-	if (!rc)
-		list_add_tail(&mc->list, &card->mc_list);
-	else
-		kfree(mc);
+	return rc;
 }
 
-static void qeth_l2_del_all_mc(struct qeth_card *card, int del)
+static void qeth_l2_del_all_macs(struct qeth_card *card, int del)
 {
-	struct qeth_mc_mac *mc, *tmp;
+	struct qeth_mac *mac;
+	struct hlist_node *tmp;
+	int i;
 
 	spin_lock_bh(&card->mclock);
-	list_for_each_entry_safe(mc, tmp, &card->mc_list, list) {
+	hash_for_each_safe(card->mac_htable, i, tmp, mac, hnode) {
 		if (del) {
-			if (mc->is_vmac)
-				qeth_l2_send_setdelmac(card, mc->mc_addr,
-					IPA_CMD_DELVMAC);
+			if (mac->is_uc)
+				qeth_l2_send_setdelmac(card, mac->mac_addr,
+						IPA_CMD_DELVMAC);
 			else
-				qeth_l2_send_delgroupmac(card, mc->mc_addr);
+				qeth_l2_send_delgroupmac(card, mac->mac_addr);
 		}
-		list_del(&mc->list);
-		kfree(mc);
+		hash_del(&mac->hnode);
+		kfree(mac);
 	}
 	spin_unlock_bh(&card->mclock);
 }
@@ -403,7 +400,7 @@ static int qeth_l2_vlan_rx_kill_vid(struct net_device *dev,
 		rc = qeth_l2_send_setdelvlan(card, vid, IPA_CMD_DELVLAN);
 		kfree(tmpid);
 	}
-	qeth_l2_set_multicast_list(card->dev);
+	qeth_l2_set_rx_mode(card->dev);
 	return rc;
 }
 
@@ -460,7 +457,7 @@ static void qeth_l2_stop_card(struct qeth_card *card, int recovery_mode)
 		card->state = CARD_STATE_SOFTSETUP;
 	}
 	if (card->state == CARD_STATE_SOFTSETUP) {
-		qeth_l2_del_all_mc(card, 0);
+		qeth_l2_del_all_macs(card, 0);
 		qeth_clear_ipacmd_list(card);
 		card->state = CARD_STATE_HARDSETUP;
 	}
@@ -768,29 +765,91 @@ static void qeth_promisc_to_bridge(struct qeth_card *card)
 		card->options.sbp.role = role;
 		card->info.promisc_mode = promisc_mode;
 	}
+
+}
+/* New MAC address is added to the hash table and marked to be written on card
+ * only if there is not in the hash table storage already
+ *
+*/
+static	void
+qeth_l2_add_mac(struct qeth_card *card, struct netdev_hw_addr *ha, u8 is_uc)
+{
+	struct qeth_mac *mac;
+
+	hash_for_each_possible(card->mac_htable, mac, hnode,
+			qeth_l2_mac_hash(ha->addr)) {
+		if (is_uc == mac->is_uc &&
+		    !memcmp(ha->addr, mac->mac_addr, OSA_ADDR_LEN)) {
+			mac->disp_flag = QETH_DISP_MAC_DO_NOTHING;
+			return;
+		}
+	}
+
+	mac = kzalloc(sizeof(struct qeth_mac), GFP_ATOMIC);
+
+	if (!mac)
+		return;
+
+	memcpy(mac->mac_addr, ha->addr, OSA_ADDR_LEN);
+	mac->is_uc = is_uc;
+	mac->disp_flag = QETH_DISP_MAC_ADD;
+
+	hash_add(card->mac_htable, &mac->hnode,
+			qeth_l2_mac_hash(mac->mac_addr));
+
 }
 
-static void qeth_l2_set_multicast_list(struct net_device *dev)
+static void qeth_l2_set_rx_mode(struct net_device *dev)
 {
 	struct qeth_card *card = dev->ml_priv;
 	struct netdev_hw_addr *ha;
+	struct qeth_mac *mac;
+	struct hlist_node *tmp;
+	int i;
+	int rc;
 
 	if (card->info.type == QETH_CARD_TYPE_OSN)
-		return ;
+		return;
 
 	QETH_CARD_TEXT(card, 3, "setmulti");
 	if (qeth_threads_running(card, QETH_RECOVER_THREAD) &&
 	    (card->state != CARD_STATE_UP))
 		return;
-	qeth_l2_del_all_mc(card, 1);
+
 	spin_lock_bh(&card->mclock);
+
 	netdev_for_each_mc_addr(ha, dev)
-		qeth_l2_add_mc(card, ha->addr, 0);
+		qeth_l2_add_mac(card, ha, 0);
 
 	netdev_for_each_uc_addr(ha, dev)
-		qeth_l2_add_mc(card, ha->addr, 1);
+		qeth_l2_add_mac(card, ha, 1);
+
+	hash_for_each_safe(card->mac_htable, i, tmp, mac, hnode) {
+		if (mac->disp_flag == QETH_DISP_MAC_DELETE) {
+			if (!mac->is_uc)
+				rc = qeth_l2_send_delgroupmac(card,
+						mac->mac_addr);
+			else {
+				rc = qeth_l2_send_setdelmac(card, mac->mac_addr,
+						IPA_CMD_DELVMAC);
+			}
+
+			hash_del(&mac->hnode);
+			kfree(mac);
+
+		} else if (mac->disp_flag == QETH_DISP_MAC_ADD) {
+			rc = qeth_l2_write_mac(card, mac);
+			if (rc) {
+				hash_del(&mac->hnode);
+				kfree(mac);
+			} else
+				mac->disp_flag = QETH_DISP_MAC_DELETE;
+		} else
+			mac->disp_flag = QETH_DISP_MAC_DELETE;
+	}
 
 	spin_unlock_bh(&card->mclock);
+
 	if (qeth_adp_supported(card, IPA_SETADP_SET_PROMISC_MODE))
 		qeth_setadp_promisc_mode(card);
 	else
@@ -974,7 +1033,7 @@ static int qeth_l2_probe_device(struct ccwgroup_device *gdev)
 
 	qeth_l2_create_device_attributes(&gdev->dev);
 	INIT_LIST_HEAD(&card->vid_list);
-	INIT_LIST_HEAD(&card->mc_list);
+	hash_init(card->mac_htable);
 	card->options.layer2 = 1;
 	card->info.hwtrap = 0;
 	return 0;
@@ -1020,7 +1079,7 @@ static const struct net_device_ops qeth_l2_netdev_ops = {
 	.ndo_get_stats		= qeth_get_stats,
 	.ndo_start_xmit		= qeth_l2_hard_start_xmit,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_rx_mode	= qeth_l2_set_multicast_list,
+	.ndo_set_rx_mode	= qeth_l2_set_rx_mode,
 	.ndo_do_ioctl	   	= qeth_l2_do_ioctl,
 	.ndo_set_mac_address    = qeth_l2_set_mac_address,
 	.ndo_change_mtu	   	= qeth_change_mtu,
@@ -1179,7 +1238,7 @@ contin:
 			rtnl_unlock();
 		}
 		/* this also sets saved unicast addresses */
-		qeth_l2_set_multicast_list(card->dev);
+		qeth_l2_set_rx_mode(card->dev);
 	}
 	/* let user_space know that device is online */
 	kobject_uevent(&gdev->dev.kobj, KOBJ_CHANGE);
-- 
2.3.9
