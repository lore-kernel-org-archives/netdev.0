From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 08/13] qeth: optimize IP handling in rx_mode callback
Date: Thu, 16 Jun 2016 16:18:58 +0200
Message-ID: <1466086743-55484-9-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1466086743-55484-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:34145 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754502AbcFPOTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 10:19:40 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5GEIwNj070760
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:19:35 -0400
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com [195.75.94.112])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23kq6y8p9t-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:19:34 -0400
Received: from localhost
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Thu, 16 Jun 2016 15:19:31 +0100
In-Reply-To: <1466086743-55484-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lakhvich Dmitriy <LDmitriy@ru.ibm.com>

In layer3 mode of the qeth driver, multicast IP addresses
from struct net_device and other type of IP addresses
from other sources require mapping to the OSA-card.
This patch simplifies the IP address mapping logic, and changes imple-
mentation of ndo_set_rx_mode callback and ip notifier events.
Addresses are stored in private hashtables instead of lists now.
It allows hardware registration/removal for new/deleted multicast
addresses only.

Signed-off-by: Lakhvich Dmitriy <ldmitriy@ru.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Evgeny Cherkashin <Eugene.Crosser@ru.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  20 +-
 drivers/s390/net/qeth_core_main.c |  10 -
 drivers/s390/net/qeth_l2.h        |   7 +
 drivers/s390/net/qeth_l2_main.c   |  12 +-
 drivers/s390/net/qeth_l3.h        |  31 +-
 drivers/s390/net/qeth_l3_main.c   | 782 +++++++++++++++++++-------------------
 drivers/s390/net/qeth_l3_sys.c    |  78 ++--
 7 files changed, 482 insertions(+), 458 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index b4f14e4..ab0a171 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -561,7 +561,6 @@ enum qeth_ip_types {
 	QETH_IP_TYPE_NORMAL,
 	QETH_IP_TYPE_VIPA,
 	QETH_IP_TYPE_RXIP,
-	QETH_IP_TYPE_DEL_ALL_MC,
 };
 
 enum qeth_cmd_buffer_state {
@@ -742,17 +741,10 @@ struct qeth_vlan_vid {
 	unsigned short vid;
 };
 
-enum qeth_mac_disposition {
-	QETH_DISP_MAC_DELETE = 0,
-	QETH_DISP_MAC_DO_NOTHING = 1,
-	QETH_DISP_MAC_ADD = 2,
-};
-
-struct qeth_mac {
-	u8 mac_addr[OSA_ADDR_LEN];
-	u8 is_uc:1;
-	u8 disp_flag:2;
-	struct hlist_node hnode;
+enum qeth_addr_disposition {
+	QETH_DISP_ADDR_DELETE = 0,
+	QETH_DISP_ADDR_DO_NOTHING = 1,
+	QETH_DISP_ADDR_ADD = 2,
 };
 
 struct qeth_rx {
@@ -800,6 +792,8 @@ struct qeth_card {
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	struct list_head vid_list;
 	DECLARE_HASHTABLE(mac_htable, 4);
+	DECLARE_HASHTABLE(ip_htable, 4);
+	DECLARE_HASHTABLE(ip_mc_htable, 4);
 	struct work_struct kernel_thread_starter;
 	spinlock_t thread_mask_lock;
 	unsigned long thread_start_mask;
@@ -807,8 +801,6 @@ struct qeth_card {
 	unsigned long thread_running_mask;
 	struct task_struct *recovery_task;
 	spinlock_t ip_lock;
-	struct list_head ip_list;
-	struct list_head *ip_tbd_list;
 	struct qeth_ipato ipato;
 	struct list_head cmd_waiter_list;
 	/* QDIO buffer handling */
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 9806ee0..ede9ed8 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1464,8 +1464,6 @@ static int qeth_setup_card(struct qeth_card *card)
 	card->thread_allowed_mask = 0;
 	card->thread_running_mask = 0;
 	INIT_WORK(&card->kernel_thread_starter, qeth_start_kernel_thread);
-	INIT_LIST_HEAD(&card->ip_list);
-	INIT_LIST_HEAD(card->ip_tbd_list);
 	INIT_LIST_HEAD(&card->cmd_waiter_list);
 	init_waitqueue_head(&card->wait_q);
 	/* initial options */
@@ -1500,11 +1498,6 @@ static struct qeth_card *qeth_alloc_card(void)
 	if (!card)
 		goto out;
 	QETH_DBF_HEX(SETUP, 2, &card, sizeof(void *));
-	card->ip_tbd_list = kzalloc(sizeof(struct list_head), GFP_KERNEL);
-	if (!card->ip_tbd_list) {
-		QETH_DBF_TEXT(SETUP, 0, "iptbdnom");
-		goto out_card;
-	}
 	if (qeth_setup_channel(&card->read))
 		goto out_ip;
 	if (qeth_setup_channel(&card->write))
@@ -1517,8 +1510,6 @@ static struct qeth_card *qeth_alloc_card(void)
 out_channel:
 	qeth_clean_channel(&card->read);
 out_ip:
-	kfree(card->ip_tbd_list);
-out_card:
 	kfree(card);
 out:
 	return NULL;
@@ -4980,7 +4971,6 @@ static void qeth_core_free_card(struct qeth_card *card)
 	qeth_clean_channel(&card->write);
 	if (card->dev)
 		free_netdev(card->dev);
-	kfree(card->ip_tbd_list);
 	qeth_free_qdio_buffers(card);
 	unregister_service_level(&card->qeth_service_level);
 	kfree(card);
diff --git a/drivers/s390/net/qeth_l2.h b/drivers/s390/net/qeth_l2.h
index 0767556..29d9fb3 100644
--- a/drivers/s390/net/qeth_l2.h
+++ b/drivers/s390/net/qeth_l2.h
@@ -12,4 +12,11 @@ int qeth_l2_create_device_attributes(struct device *);
 void qeth_l2_remove_device_attributes(struct device *);
 void qeth_l2_setup_bridgeport_attrs(struct qeth_card *card);
 
+struct qeth_mac {
+	u8 mac_addr[OSA_ADDR_LEN];
+	u8 is_uc:1;
+	u8 disp_flag:2;
+	struct hlist_node hnode;
+};
+
 #endif /* __QETH_L2_H__ */
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 08b5fa9..2a331d1 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -780,7 +780,7 @@ qeth_l2_add_mac(struct qeth_card *card, struct netdev_hw_addr *ha, u8 is_uc)
 			qeth_l2_mac_hash(ha->addr)) {
 		if (is_uc == mac->is_uc &&
 		    !memcmp(ha->addr, mac->mac_addr, OSA_ADDR_LEN)) {
-			mac->disp_flag = QETH_DISP_MAC_DO_NOTHING;
+			mac->disp_flag = QETH_DISP_ADDR_DO_NOTHING;
 			return;
 		}
 	}
@@ -792,7 +792,7 @@ qeth_l2_add_mac(struct qeth_card *card, struct netdev_hw_addr *ha, u8 is_uc)
 
 	memcpy(mac->mac_addr, ha->addr, OSA_ADDR_LEN);
 	mac->is_uc = is_uc;
-	mac->disp_flag = QETH_DISP_MAC_ADD;
+	mac->disp_flag = QETH_DISP_ADDR_ADD;
 
 	hash_add(card->mac_htable, &mac->hnode,
 			qeth_l2_mac_hash(mac->mac_addr));
@@ -825,7 +825,7 @@ static void qeth_l2_set_rx_mode(struct net_device *dev)
 		qeth_l2_add_mac(card, ha, 1);
 
 	hash_for_each_safe(card->mac_htable, i, tmp, mac, hnode) {
-		if (mac->disp_flag == QETH_DISP_MAC_DELETE) {
+		if (mac->disp_flag == QETH_DISP_ADDR_DELETE) {
 			if (!mac->is_uc)
 				rc = qeth_l2_send_delgroupmac(card,
 						mac->mac_addr);
@@ -837,15 +837,15 @@ static void qeth_l2_set_rx_mode(struct net_device *dev)
 			hash_del(&mac->hnode);
 			kfree(mac);
 
-		} else if (mac->disp_flag == QETH_DISP_MAC_ADD) {
+		} else if (mac->disp_flag == QETH_DISP_ADDR_ADD) {
 			rc = qeth_l2_write_mac(card, mac);
 			if (rc) {
 				hash_del(&mac->hnode);
 				kfree(mac);
 			} else
-				mac->disp_flag = QETH_DISP_MAC_DELETE;
+				mac->disp_flag = QETH_DISP_ADDR_DELETE;
 		} else
-			mac->disp_flag = QETH_DISP_MAC_DELETE;
+			mac->disp_flag = QETH_DISP_ADDR_DELETE;
 	}
 
 	spin_unlock_bh(&card->mclock);
diff --git a/drivers/s390/net/qeth_l3.h b/drivers/s390/net/qeth_l3.h
index 551a4b4..26f7953 100644
--- a/drivers/s390/net/qeth_l3.h
+++ b/drivers/s390/net/qeth_l3.h
@@ -10,16 +10,23 @@
 #define __QETH_L3_H__
 
 #include "qeth_core.h"
+#include <linux/hashtable.h>
 
 #define QETH_SNIFF_AVAIL	0x0008
 
 struct qeth_ipaddr {
-	struct list_head entry;
+	struct hlist_node hnode;
 	enum qeth_ip_types type;
 	enum qeth_ipa_setdelip_flags set_flags;
 	enum qeth_ipa_setdelip_flags del_flags;
-	int is_multicast;
-	int users;
+	u8 is_multicast:1;
+	u8 in_progress:1;
+	u8 disp_flag:2;
+
+	/* is changed only for normal ip addresses
+	 * for non-normal addresses it always is  1
+	 */
+	int  ref_counter;
 	enum qeth_prot_versions proto;
 	unsigned char mac[OSA_ADDR_LEN];
 	union {
@@ -32,7 +39,24 @@ struct qeth_ipaddr {
 			unsigned int pfxlen;
 		} a6;
 	} u;
+
 };
+static inline  u64 qeth_l3_ipaddr_hash(struct qeth_ipaddr *addr)
+{
+	u64  ret = 0;
+	u8 *point;
+
+	if (addr->proto == QETH_PROT_IPV6) {
+		point = (u8 *) &addr->u.a6.addr;
+		ret = get_unaligned((u64 *)point) ^
+			get_unaligned((u64 *) (point + 8));
+	}
+	if (addr->proto == QETH_PROT_IPV4) {
+		point = (u8 *) &addr->u.a4.addr;
+		ret = get_unaligned((u32 *) point);
+	}
+	return ret;
+}
 
 struct qeth_ipato_entry {
 	struct list_head entry;
@@ -60,6 +84,5 @@ int qeth_l3_is_addr_covered_by_ipato(struct qeth_card *, struct qeth_ipaddr *);
 struct qeth_ipaddr *qeth_l3_get_addr_buffer(enum qeth_prot_versions);
 int qeth_l3_add_ip(struct qeth_card *, struct qeth_ipaddr *);
 int qeth_l3_delete_ip(struct qeth_card *, struct qeth_ipaddr *);
-void qeth_l3_set_ip_addr_list(struct qeth_card *);
 
 #endif /* __QETH_L3_H__ */
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 51077fb..6e7d06c 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -30,6 +30,7 @@
 #include <net/ip6_fib.h>
 #include <net/ip6_checksum.h>
 #include <net/iucv/af_iucv.h>
+#include <linux/hashtable.h>
 
 #include "qeth_l3.h"
 
@@ -57,7 +58,7 @@ static int qeth_l3_isxdigit(char *buf)
 
 static void qeth_l3_ipaddr4_to_string(const __u8 *addr, char *buf)
 {
-	sprintf(buf, "%i.%i.%i.%i", addr[0], addr[1], addr[2], addr[3]);
+	sprintf(buf, "%pI4", addr);
 }
 
 static int qeth_l3_string_to_ipaddr4(const char *buf, __u8 *addr)
@@ -204,104 +205,129 @@ int qeth_l3_is_addr_covered_by_ipato(struct qeth_card *card,
 	return rc;
 }
 
-/*
- * Add IP to be added to todo list. If there is already an "add todo"
- * in this list we just incremenent the reference count.
- * Returns 0 if we  just incremented reference count.
- */
-static int __qeth_l3_insert_ip_todo(struct qeth_card *card,
-					struct qeth_ipaddr *addr, int add)
+inline int
+qeth_l3_ipaddrs_is_equal(struct qeth_ipaddr *addr1, struct qeth_ipaddr *addr2)
 {
-	struct qeth_ipaddr *tmp, *t;
-	int found = 0;
+	return addr1->proto == addr2->proto &&
+		!memcmp(&addr1->u, &addr2->u, sizeof(addr1->u))  &&
+		!memcmp(&addr1->mac, &addr2->mac, sizeof(addr1->mac));
+}
 
-	if (card->options.sniffer)
-		return 0;
-	list_for_each_entry_safe(tmp, t, card->ip_tbd_list, entry) {
-		if ((addr->type == QETH_IP_TYPE_DEL_ALL_MC) &&
-		    (tmp->type == QETH_IP_TYPE_DEL_ALL_MC))
-			return 0;
-		if ((tmp->proto        == QETH_PROT_IPV4)     &&
-		    (addr->proto       == QETH_PROT_IPV4)     &&
-		    (tmp->type         == addr->type)         &&
-		    (tmp->is_multicast == addr->is_multicast) &&
-		    (tmp->u.a4.addr    == addr->u.a4.addr)    &&
-		    (tmp->u.a4.mask    == addr->u.a4.mask)) {
-			found = 1;
-			break;
-		}
-		if ((tmp->proto        == QETH_PROT_IPV6)      &&
-		    (addr->proto       == QETH_PROT_IPV6)      &&
-		    (tmp->type         == addr->type)          &&
-		    (tmp->is_multicast == addr->is_multicast)  &&
-		    (tmp->u.a6.pfxlen  == addr->u.a6.pfxlen)   &&
-		    (memcmp(&tmp->u.a6.addr, &addr->u.a6.addr,
-			    sizeof(struct in6_addr)) == 0)) {
-			found = 1;
-			break;
-		}
-	}
-	if (found) {
-		if (addr->users != 0)
-			tmp->users += addr->users;
-		else
-			tmp->users += add ? 1 : -1;
-		if (tmp->users == 0) {
-			list_del(&tmp->entry);
-			kfree(tmp);
-		}
-		return 0;
+static struct qeth_ipaddr *
+qeth_l3_ip_from_hash(struct qeth_card *card, struct qeth_ipaddr *tmp_addr)
+{
+	struct qeth_ipaddr *addr;
+
+	if (tmp_addr->is_multicast) {
+		hash_for_each_possible(card->ip_mc_htable,  addr,
+				hnode, qeth_l3_ipaddr_hash(tmp_addr))
+			if (qeth_l3_ipaddrs_is_equal(tmp_addr, addr))
+				return addr;
 	} else {
-		if (addr->type == QETH_IP_TYPE_DEL_ALL_MC)
-			list_add(&addr->entry, card->ip_tbd_list);
-		else {
-			if (addr->users == 0)
-				addr->users += add ? 1 : -1;
-			if (add && (addr->type == QETH_IP_TYPE_NORMAL) &&
-			    qeth_l3_is_addr_covered_by_ipato(card, addr)) {
-				QETH_CARD_TEXT(card, 2, "tkovaddr");
-				addr->set_flags |= QETH_IPA_SETIP_TAKEOVER_FLAG;
-			}
-			list_add_tail(&addr->entry, card->ip_tbd_list);
-		}
-		return 1;
+		hash_for_each_possible(card->ip_htable,  addr,
+				hnode, qeth_l3_ipaddr_hash(tmp_addr))
+			if (qeth_l3_ipaddrs_is_equal(tmp_addr, addr))
+				return addr;
 	}
+
+	return NULL;
 }
 
-int qeth_l3_delete_ip(struct qeth_card *card, struct qeth_ipaddr *addr)
+int qeth_l3_delete_ip(struct qeth_card *card, struct qeth_ipaddr *tmp_addr)
 {
-	unsigned long flags;
 	int rc = 0;
+	struct qeth_ipaddr *addr;
 
 	QETH_CARD_TEXT(card, 4, "delip");
 
-	if (addr->proto == QETH_PROT_IPV4)
-		QETH_CARD_HEX(card, 4, &addr->u.a4.addr, 4);
+	if (tmp_addr->proto == QETH_PROT_IPV4)
+		QETH_CARD_HEX(card, 4, &tmp_addr->u.a4.addr, 4);
 	else {
-		QETH_CARD_HEX(card, 4, &addr->u.a6.addr, 8);
-		QETH_CARD_HEX(card, 4, ((char *)&addr->u.a6.addr) + 8, 8);
+		QETH_CARD_HEX(card, 4, &tmp_addr->u.a6.addr, 8);
+		QETH_CARD_HEX(card, 4, ((char *)&tmp_addr->u.a6.addr) + 8, 8);
 	}
-	spin_lock_irqsave(&card->ip_lock, flags);
-	rc = __qeth_l3_insert_ip_todo(card, addr, 0);
-	spin_unlock_irqrestore(&card->ip_lock, flags);
+
+	addr = qeth_l3_ip_from_hash(card, tmp_addr);
+	if (!addr)
+		return -ENOENT;
+
+	addr->ref_counter--;
+	if (addr->type == QETH_IP_TYPE_NORMAL && addr->ref_counter > 0)
+		return rc;
+	if (addr->in_progress)
+		return -EINPROGRESS;
+
+	rc = qeth_l3_deregister_addr_entry(card, addr);
+
+	hash_del(&addr->hnode);
+	kfree(addr);
+
 	return rc;
 }
 
-int qeth_l3_add_ip(struct qeth_card *card, struct qeth_ipaddr *addr)
+int qeth_l3_add_ip(struct qeth_card *card, struct qeth_ipaddr *tmp_addr)
 {
-	unsigned long flags;
 	int rc = 0;
+	struct qeth_ipaddr *addr;
 
 	QETH_CARD_TEXT(card, 4, "addip");
-	if (addr->proto == QETH_PROT_IPV4)
-		QETH_CARD_HEX(card, 4, &addr->u.a4.addr, 4);
+
+	if (tmp_addr->proto == QETH_PROT_IPV4)
+		QETH_CARD_HEX(card, 4, &tmp_addr->u.a4.addr, 4);
 	else {
-		QETH_CARD_HEX(card, 4, &addr->u.a6.addr, 8);
-		QETH_CARD_HEX(card, 4, ((char *)&addr->u.a6.addr) + 8, 8);
+		QETH_CARD_HEX(card, 4, &tmp_addr->u.a6.addr, 8);
+		QETH_CARD_HEX(card, 4, ((char *)&tmp_addr->u.a6.addr) + 8, 8);
+	}
+
+	addr = qeth_l3_ip_from_hash(card, tmp_addr);
+	if (!addr) {
+		addr = qeth_l3_get_addr_buffer(tmp_addr->proto);
+		if (!addr)
+			return -ENOMEM;
+
+		memcpy(addr, tmp_addr, sizeof(struct qeth_ipaddr));
+		addr->ref_counter = 1;
+
+		if (addr->type == QETH_IP_TYPE_NORMAL  &&
+				qeth_l3_is_addr_covered_by_ipato(card, addr)) {
+			QETH_CARD_TEXT(card, 2, "tkovaddr");
+			addr->set_flags |= QETH_IPA_SETIP_TAKEOVER_FLAG;
+		}
+		hash_add(card->ip_htable, &addr->hnode,
+				qeth_l3_ipaddr_hash(addr));
+
+		/* qeth_l3_register_addr_entry can go to sleep
+		 * if we add a IPV4 addr. It is caused by the reason
+		 * that SETIP ipa cmd starts ARP staff for IPV4 addr.
+		 * Thus we should unlock spinlock, and make a protection
+		 * using in_progress variable to indicate that there is
+		 * an hardware operation with this IPV4 address
+		 */
+		if (addr->proto == QETH_PROT_IPV4) {
+			addr->in_progress = 1;
+			spin_unlock_bh(&card->ip_lock);
+			rc = qeth_l3_register_addr_entry(card, addr);
+			spin_lock_bh(&card->ip_lock);
+			addr->in_progress = 0;
+		} else
+			rc = qeth_l3_register_addr_entry(card, addr);
+
+		if (!rc || (rc == IPA_RC_DUPLICATE_IP_ADDRESS) ||
+				(rc == IPA_RC_LAN_OFFLINE)) {
+			addr->disp_flag = QETH_DISP_ADDR_DO_NOTHING;
+			if (addr->ref_counter < 1) {
+				qeth_l3_delete_ip(card, addr);
+				kfree(addr);
+			}
+		} else {
+			hash_del(&addr->hnode);
+			kfree(addr);
+		}
+	} else {
+			if (addr->type == QETH_IP_TYPE_NORMAL)
+				addr->ref_counter++;
 	}
-	spin_lock_irqsave(&card->ip_lock, flags);
-	rc = __qeth_l3_insert_ip_todo(card, addr, 1);
-	spin_unlock_irqrestore(&card->ip_lock, flags);
+
 	return rc;
 }
 
@@ -312,229 +338,88 @@ struct qeth_ipaddr *qeth_l3_get_addr_buffer(
 	struct qeth_ipaddr *addr;
 
 	addr = kzalloc(sizeof(struct qeth_ipaddr), GFP_ATOMIC);
-	if (addr == NULL) {
+	if (!addr)
 		return NULL;
-	}
+
 	addr->type = QETH_IP_TYPE_NORMAL;
+	addr->disp_flag = QETH_DISP_ADDR_DO_NOTHING;
 	addr->proto = prot;
-	return addr;
-}
 
-static void qeth_l3_delete_mc_addresses(struct qeth_card *card)
-{
-	struct qeth_ipaddr *iptodo;
-	unsigned long flags;
-
-	QETH_CARD_TEXT(card, 4, "delmc");
-	iptodo = qeth_l3_get_addr_buffer(QETH_PROT_IPV4);
-	if (!iptodo) {
-		QETH_CARD_TEXT(card, 2, "dmcnomem");
-		return;
-	}
-	iptodo->type = QETH_IP_TYPE_DEL_ALL_MC;
-	spin_lock_irqsave(&card->ip_lock, flags);
-	if (!__qeth_l3_insert_ip_todo(card, iptodo, 0))
-		kfree(iptodo);
-	spin_unlock_irqrestore(&card->ip_lock, flags);
+	return addr;
 }
 
-/*
- * Add/remove address to/from card's ip list, i.e. try to add or remove
- * reference to/from an IP address that is already registered on the card.
- * Returns:
- *	0  address was on card and its reference count has been adjusted,
- *	   but is still > 0, so nothing has to be done
- *	   also returns 0 if card was not on card and the todo was to delete
- *	   the address -> there is also nothing to be done
- *	1  address was not on card and the todo is to add it to the card's ip
- *	   list
- *	-1 address was on card and its reference count has been decremented
- *	   to <= 0 by the todo -> address must be removed from card
- */
-static int __qeth_l3_ref_ip_on_card(struct qeth_card *card,
-		struct qeth_ipaddr *todo, struct qeth_ipaddr **__addr)
+static void qeth_l3_clear_ip_htable(struct qeth_card *card, int recover)
 {
 	struct qeth_ipaddr *addr;
-	int found = 0;
-
-	list_for_each_entry(addr, &card->ip_list, entry) {
-		if ((addr->proto == QETH_PROT_IPV4) &&
-		    (todo->proto == QETH_PROT_IPV4) &&
-		    (addr->type == todo->type) &&
-		    (addr->u.a4.addr == todo->u.a4.addr) &&
-		    (addr->u.a4.mask == todo->u.a4.mask)) {
-			found = 1;
-			break;
-		}
-		if ((addr->proto == QETH_PROT_IPV6) &&
-		    (todo->proto == QETH_PROT_IPV6) &&
-		    (addr->type == todo->type) &&
-		    (addr->u.a6.pfxlen == todo->u.a6.pfxlen) &&
-		    (memcmp(&addr->u.a6.addr, &todo->u.a6.addr,
-			    sizeof(struct in6_addr)) == 0)) {
-			found = 1;
-			break;
-		}
-	}
-	if (found) {
-		addr->users += todo->users;
-		if (addr->users <= 0) {
-			*__addr = addr;
-			return -1;
-		} else {
-			/* for VIPA and RXIP limit refcount to 1 */
-			if (addr->type != QETH_IP_TYPE_NORMAL)
-				addr->users = 1;
-			return 0;
-		}
-	}
-	if (todo->users > 0) {
-		/* for VIPA and RXIP limit refcount to 1 */
-		if (todo->type != QETH_IP_TYPE_NORMAL)
-			todo->users = 1;
-		return 1;
-	} else
-		return 0;
-}
-
-static void __qeth_l3_delete_all_mc(struct qeth_card *card,
-					unsigned long *flags)
-{
-	struct list_head fail_list;
-	struct qeth_ipaddr *addr, *tmp;
-	int rc;
-
-	INIT_LIST_HEAD(&fail_list);
-again:
-	list_for_each_entry_safe(addr, tmp, &card->ip_list, entry) {
-		if (addr->is_multicast) {
-			list_del(&addr->entry);
-			spin_unlock_irqrestore(&card->ip_lock, *flags);
-			rc = qeth_l3_deregister_addr_entry(card, addr);
-			spin_lock_irqsave(&card->ip_lock, *flags);
-			if (!rc || (rc == IPA_RC_MC_ADDR_NOT_FOUND))
-				kfree(addr);
-			else
-				list_add_tail(&addr->entry, &fail_list);
-			goto again;
-		}
-	}
-	list_splice(&fail_list, &card->ip_list);
-}
-
-void qeth_l3_set_ip_addr_list(struct qeth_card *card)
-{
-	struct list_head *tbd_list;
-	struct qeth_ipaddr *todo, *addr;
-	unsigned long flags;
-	int rc;
+	struct hlist_node *tmp;
+	int i;
 
-	QETH_CARD_TEXT(card, 2, "sdiplist");
-	QETH_CARD_HEX(card, 2, &card, sizeof(void *));
+	QETH_CARD_TEXT(card, 4, "clearip");
 
-	if (!qeth_card_hw_is_reachable(card) || card->options.sniffer)
+	if (recover && card->options.sniffer)
 		return;
 
-	spin_lock_irqsave(&card->ip_lock, flags);
-	tbd_list = card->ip_tbd_list;
-	card->ip_tbd_list = kzalloc(sizeof(struct list_head), GFP_ATOMIC);
-	if (!card->ip_tbd_list) {
-		QETH_CARD_TEXT(card, 0, "silnomem");
-		card->ip_tbd_list = tbd_list;
-		spin_unlock_irqrestore(&card->ip_lock, flags);
-		return;
-	} else
-		INIT_LIST_HEAD(card->ip_tbd_list);
-
-	while (!list_empty(tbd_list)) {
-		todo = list_entry(tbd_list->next, struct qeth_ipaddr, entry);
-		list_del(&todo->entry);
-		if (todo->type == QETH_IP_TYPE_DEL_ALL_MC) {
-			__qeth_l3_delete_all_mc(card, &flags);
-			kfree(todo);
+	spin_lock_bh(&card->ip_lock);
+
+	hash_for_each_safe(card->ip_htable, i, tmp, addr, hnode) {
+		if (!recover) {
+			hash_del(&addr->hnode);
+			kfree(addr);
 			continue;
 		}
-		rc = __qeth_l3_ref_ip_on_card(card, todo, &addr);
-		if (rc == 0) {
-			/* nothing to be done; only adjusted refcount */
-			kfree(todo);
-		} else if (rc == 1) {
-			/* new entry to be added to on-card list */
-			spin_unlock_irqrestore(&card->ip_lock, flags);
-			rc = qeth_l3_register_addr_entry(card, todo);
-			spin_lock_irqsave(&card->ip_lock, flags);
-			if (!rc || (rc == IPA_RC_LAN_OFFLINE))
-				list_add_tail(&todo->entry, &card->ip_list);
-			else
-				kfree(todo);
-		} else if (rc == -1) {
-			/* on-card entry to be removed */
-			list_del_init(&addr->entry);
-			spin_unlock_irqrestore(&card->ip_lock, flags);
-			rc = qeth_l3_deregister_addr_entry(card, addr);
-			spin_lock_irqsave(&card->ip_lock, flags);
-			if (!rc || (rc == IPA_RC_IP_ADDRESS_NOT_DEFINED))
-				kfree(addr);
-			else
-				list_add_tail(&addr->entry, &card->ip_list);
-			kfree(todo);
-		}
+		addr->disp_flag = QETH_DISP_ADDR_ADD;
 	}
-	spin_unlock_irqrestore(&card->ip_lock, flags);
-	kfree(tbd_list);
-}
 
-static void qeth_l3_clear_ip_list(struct qeth_card *card, int recover)
-{
-	struct qeth_ipaddr *addr, *tmp;
-	unsigned long flags;
+	spin_unlock_bh(&card->ip_lock);
 
-	QETH_CARD_TEXT(card, 4, "clearip");
-	if (recover && card->options.sniffer)
-		return;
-	spin_lock_irqsave(&card->ip_lock, flags);
-	/* clear todo list */
-	list_for_each_entry_safe(addr, tmp, card->ip_tbd_list, entry) {
-		list_del(&addr->entry);
+	spin_lock_bh(&card->mclock);
+
+	hash_for_each_safe(card->ip_mc_htable, i, tmp, addr, hnode) {
+		hash_del(&addr->hnode);
 		kfree(addr);
 	}
 
-	while (!list_empty(&card->ip_list)) {
-		addr = list_entry(card->ip_list.next,
-				  struct qeth_ipaddr, entry);
-		list_del_init(&addr->entry);
-		if (!recover || addr->is_multicast) {
-			kfree(addr);
-			continue;
-		}
-		list_add_tail(&addr->entry, card->ip_tbd_list);
-	}
-	spin_unlock_irqrestore(&card->ip_lock, flags);
-}
+	spin_unlock_bh(&card->mclock);
+
 
-static int qeth_l3_address_exists_in_list(struct list_head *list,
-		struct qeth_ipaddr *addr, int same_type)
+}
+static void qeth_l3_recover_ip(struct qeth_card *card)
 {
-	struct qeth_ipaddr *tmp;
+	struct qeth_ipaddr *addr;
+	struct hlist_node *tmp;
+	int i;
+	int rc;
 
-	list_for_each_entry(tmp, list, entry) {
-		if ((tmp->proto == QETH_PROT_IPV4) &&
-		    (addr->proto == QETH_PROT_IPV4) &&
-		    ((same_type && (tmp->type == addr->type)) ||
-		    (!same_type && (tmp->type != addr->type))) &&
-		    (tmp->u.a4.addr == addr->u.a4.addr))
-			return 1;
+	QETH_CARD_TEXT(card, 4, "recoverip");
+
+	spin_lock_bh(&card->ip_lock);
+
+	hash_for_each_safe(card->ip_htable, i, tmp, addr, hnode) {
+		if (addr->disp_flag == QETH_DISP_ADDR_ADD) {
+			if (addr->proto == QETH_PROT_IPV4) {
+				addr->in_progress = 1;
+				spin_unlock_bh(&card->ip_lock);
+				rc = qeth_l3_register_addr_entry(card, addr);
+				spin_lock_bh(&card->ip_lock);
+				addr->in_progress = 0;
+			} else
+				rc = qeth_l3_register_addr_entry(card, addr);
+
+			if (!rc) {
+				addr->disp_flag = QETH_DISP_ADDR_DO_NOTHING;
+				if (addr->ref_counter < 1) {
+					qeth_l3_delete_ip(card, addr);
+					kfree(addr);
+				}
+			} else {
+				hash_del(&addr->hnode);
+				kfree(addr);
+			}
+		}
+	}
 
-		if ((tmp->proto == QETH_PROT_IPV6) &&
-		    (addr->proto == QETH_PROT_IPV6) &&
-		    ((same_type && (tmp->type == addr->type)) ||
-		    (!same_type && (tmp->type != addr->type))) &&
-		    (memcmp(&tmp->u.a6.addr, &addr->u.a6.addr,
-			    sizeof(struct in6_addr)) == 0))
-			return 1;
+	spin_unlock_bh(&card->ip_lock);
 
-	}
-	return 0;
 }
 
 static int qeth_l3_send_setdelmc(struct qeth_card *card,
@@ -712,27 +597,28 @@ int qeth_l3_setrouting_v6(struct qeth_card *card)
  */
 static void qeth_l3_clear_ipato_list(struct qeth_card *card)
 {
-
 	struct qeth_ipato_entry *ipatoe, *tmp;
-	unsigned long flags;
 
-	spin_lock_irqsave(&card->ip_lock, flags);
+	spin_lock_bh(&card->ip_lock);
+
 	list_for_each_entry_safe(ipatoe, tmp, &card->ipato.entries, entry) {
 		list_del(&ipatoe->entry);
 		kfree(ipatoe);
 	}
-	spin_unlock_irqrestore(&card->ip_lock, flags);
+
+	spin_unlock_bh(&card->ip_lock);
 }
 
 int qeth_l3_add_ipato_entry(struct qeth_card *card,
 				struct qeth_ipato_entry *new)
 {
 	struct qeth_ipato_entry *ipatoe;
-	unsigned long flags;
 	int rc = 0;
 
 	QETH_CARD_TEXT(card, 2, "addipato");
-	spin_lock_irqsave(&card->ip_lock, flags);
+
+	spin_lock_bh(&card->ip_lock);
+
 	list_for_each_entry(ipatoe, &card->ipato.entries, entry) {
 		if (ipatoe->proto != new->proto)
 			continue;
@@ -743,10 +629,12 @@ int qeth_l3_add_ipato_entry(struct qeth_card *card,
 			break;
 		}
 	}
+
 	if (!rc)
 		list_add_tail(&new->entry, &card->ipato.entries);
 
-	spin_unlock_irqrestore(&card->ip_lock, flags);
+	spin_unlock_bh(&card->ip_lock);
+
 	return rc;
 }
 
@@ -754,10 +642,11 @@ void qeth_l3_del_ipato_entry(struct qeth_card *card,
 		enum qeth_prot_versions proto, u8 *addr, int mask_bits)
 {
 	struct qeth_ipato_entry *ipatoe, *tmp;
-	unsigned long flags;
 
 	QETH_CARD_TEXT(card, 2, "delipato");
-	spin_lock_irqsave(&card->ip_lock, flags);
+
+	spin_lock_bh(&card->ip_lock);
+
 	list_for_each_entry_safe(ipatoe, tmp, &card->ipato.entries, entry) {
 		if (ipatoe->proto != proto)
 			continue;
@@ -768,7 +657,8 @@ void qeth_l3_del_ipato_entry(struct qeth_card *card,
 			kfree(ipatoe);
 		}
 	}
-	spin_unlock_irqrestore(&card->ip_lock, flags);
+
+	spin_unlock_bh(&card->ip_lock);
 }
 
 /*
@@ -778,7 +668,6 @@ int qeth_l3_add_vipa(struct qeth_card *card, enum qeth_prot_versions proto,
 	      const u8 *addr)
 {
 	struct qeth_ipaddr *ipaddr;
-	unsigned long flags;
 	int rc = 0;
 
 	ipaddr = qeth_l3_get_addr_buffer(proto);
@@ -797,18 +686,18 @@ int qeth_l3_add_vipa(struct qeth_card *card, enum qeth_prot_versions proto,
 		ipaddr->del_flags = QETH_IPA_DELIP_VIPA_FLAG;
 	} else
 		return -ENOMEM;
-	spin_lock_irqsave(&card->ip_lock, flags);
-	if (qeth_l3_address_exists_in_list(&card->ip_list, ipaddr, 0) ||
-	    qeth_l3_address_exists_in_list(card->ip_tbd_list, ipaddr, 0))
+
+	spin_lock_bh(&card->ip_lock);
+
+	if (!qeth_l3_ip_from_hash(card, ipaddr))
 		rc = -EEXIST;
-	spin_unlock_irqrestore(&card->ip_lock, flags);
-	if (rc) {
-		kfree(ipaddr);
-		return rc;
-	}
-	if (!qeth_l3_add_ip(card, ipaddr))
-		kfree(ipaddr);
-	qeth_l3_set_ip_addr_list(card);
+	else
+		qeth_l3_add_ip(card, ipaddr);
+
+	spin_unlock_bh(&card->ip_lock);
+
+	kfree(ipaddr);
+
 	return rc;
 }
 
@@ -831,9 +720,12 @@ void qeth_l3_del_vipa(struct qeth_card *card, enum qeth_prot_versions proto,
 		ipaddr->type = QETH_IP_TYPE_VIPA;
 	} else
 		return;
-	if (!qeth_l3_delete_ip(card, ipaddr))
-		kfree(ipaddr);
-	qeth_l3_set_ip_addr_list(card);
+
+	spin_lock_bh(&card->ip_lock);
+	qeth_l3_delete_ip(card, ipaddr);
+	spin_unlock_bh(&card->ip_lock);
+
+	kfree(ipaddr);
 }
 
 /*
@@ -843,7 +735,6 @@ int qeth_l3_add_rxip(struct qeth_card *card, enum qeth_prot_versions proto,
 	      const u8 *addr)
 {
 	struct qeth_ipaddr *ipaddr;
-	unsigned long flags;
 	int rc = 0;
 
 	ipaddr = qeth_l3_get_addr_buffer(proto);
@@ -857,24 +748,25 @@ int qeth_l3_add_rxip(struct qeth_card *card, enum qeth_prot_versions proto,
 			memcpy(&ipaddr->u.a6.addr, addr, 16);
 			ipaddr->u.a6.pfxlen = 0;
 		}
+
 		ipaddr->type = QETH_IP_TYPE_RXIP;
 		ipaddr->set_flags = QETH_IPA_SETIP_TAKEOVER_FLAG;
 		ipaddr->del_flags = 0;
 	} else
 		return -ENOMEM;
-	spin_lock_irqsave(&card->ip_lock, flags);
-	if (qeth_l3_address_exists_in_list(&card->ip_list, ipaddr, 0) ||
-	    qeth_l3_address_exists_in_list(card->ip_tbd_list, ipaddr, 0))
+
+	spin_lock_bh(&card->ip_lock);
+
+	if (!qeth_l3_ip_from_hash(card, ipaddr))
 		rc = -EEXIST;
-	spin_unlock_irqrestore(&card->ip_lock, flags);
-	if (rc) {
-		kfree(ipaddr);
-		return rc;
-	}
-	if (!qeth_l3_add_ip(card, ipaddr))
-		kfree(ipaddr);
-	qeth_l3_set_ip_addr_list(card);
-	return 0;
+	else
+		qeth_l3_add_ip(card, ipaddr);
+
+	spin_unlock_bh(&card->ip_lock);
+
+	kfree(ipaddr);
+
+	return rc;
 }
 
 void qeth_l3_del_rxip(struct qeth_card *card, enum qeth_prot_versions proto,
@@ -896,9 +788,12 @@ void qeth_l3_del_rxip(struct qeth_card *card, enum qeth_prot_versions proto,
 		ipaddr->type = QETH_IP_TYPE_RXIP;
 	} else
 		return;
-	if (!qeth_l3_delete_ip(card, ipaddr))
-		kfree(ipaddr);
-	qeth_l3_set_ip_addr_list(card);
+
+	spin_lock_bh(&card->ip_lock);
+	qeth_l3_delete_ip(card, ipaddr);
+	spin_unlock_bh(&card->ip_lock);
+
+	kfree(ipaddr);
 }
 
 static int qeth_l3_register_addr_entry(struct qeth_card *card,
@@ -908,6 +803,7 @@ static int qeth_l3_register_addr_entry(struct qeth_card *card,
 	int rc = 0;
 	int cnt = 3;
 
+
 	if (addr->proto == QETH_PROT_IPV4) {
 		QETH_CARD_TEXT(card, 2, "setaddr4");
 		QETH_CARD_HEX(card, 3, &addr->u.a4.addr, sizeof(int));
@@ -1507,31 +1403,99 @@ qeth_diags_trace(struct qeth_card *card, enum qeth_diags_trace_cmds diags_cmd)
 	return qeth_send_ipa_cmd(card, iob, qeth_diags_trace_cb, NULL);
 }
 
-static void qeth_l3_get_mac_for_ipm(__u32 ipm, char *mac,
-				struct net_device *dev)
+static void qeth_l3_get_mac_for_ipm(__u32 ipm, char *mac)
 {
 	ip_eth_mc_map(ipm, mac);
 }
 
-static void qeth_l3_add_mc(struct qeth_card *card, struct in_device *in4_dev)
+static void qeth_l3_mark_all_mc_to_be_deleted(struct qeth_card *card)
+{
+	struct qeth_ipaddr *addr;
+	int i;
+
+	hash_for_each(card->ip_mc_htable, i, addr, hnode)
+		addr->disp_flag = QETH_DISP_ADDR_DELETE;
+
+}
+
+static void qeth_l3_add_all_new_mc(struct qeth_card *card)
+{
+	struct qeth_ipaddr *addr;
+	struct hlist_node *tmp;
+	int i;
+	int rc;
+
+	hash_for_each_safe(card->ip_mc_htable, i, tmp, addr, hnode) {
+		if (addr->disp_flag == QETH_DISP_ADDR_ADD) {
+			rc = qeth_l3_register_addr_entry(card, addr);
+			if (!rc || (rc == IPA_RC_LAN_OFFLINE))
+				addr->ref_counter = 1;
+			else {
+				hash_del(&addr->hnode);
+				kfree(addr);
+			}
+		}
+	}
+
+}
+
+static void qeth_l3_delete_nonused_mc(struct qeth_card *card)
+{
+	struct qeth_ipaddr *addr;
+	struct hlist_node *tmp;
+	int i;
+	int rc;
+
+	hash_for_each_safe(card->ip_mc_htable, i, tmp, addr, hnode) {
+		if (addr->disp_flag == QETH_DISP_ADDR_DELETE) {
+			rc = qeth_l3_deregister_addr_entry(card, addr);
+			if (!rc || (rc == IPA_RC_MC_ADDR_NOT_FOUND)) {
+				hash_del(&addr->hnode);
+				kfree(addr);
+			}
+		}
+	}
+
+}
+
+
+static void
+qeth_l3_add_mc_to_hash(struct qeth_card *card, struct in_device *in4_dev)
 {
-	struct qeth_ipaddr *ipm;
 	struct ip_mc_list *im4;
+	struct qeth_ipaddr *tmp, *ipm;
 	char buf[MAX_ADDR_LEN];
 
 	QETH_CARD_TEXT(card, 4, "addmc");
+
+	tmp = qeth_l3_get_addr_buffer(QETH_PROT_IPV4);
+		if (!tmp)
+			return;
+
 	for (im4 = rcu_dereference(in4_dev->mc_list); im4 != NULL;
 	     im4 = rcu_dereference(im4->next_rcu)) {
-		qeth_l3_get_mac_for_ipm(im4->multiaddr, buf, in4_dev->dev);
-		ipm = qeth_l3_get_addr_buffer(QETH_PROT_IPV4);
-		if (!ipm)
-			continue;
-		ipm->u.a4.addr = im4->multiaddr;
-		memcpy(ipm->mac, buf, OSA_ADDR_LEN);
-		ipm->is_multicast = 1;
-		if (!qeth_l3_add_ip(card, ipm))
-			kfree(ipm);
+		qeth_l3_get_mac_for_ipm(im4->multiaddr, buf);
+
+		tmp->u.a4.addr = im4->multiaddr;
+		memcpy(tmp->mac, buf, sizeof(tmp->mac));
+
+		ipm = qeth_l3_ip_from_hash(card, tmp);
+		if (ipm) {
+			ipm->disp_flag = QETH_DISP_ADDR_DO_NOTHING;
+		} else {
+			ipm = qeth_l3_get_addr_buffer(QETH_PROT_IPV4);
+			if (!ipm)
+				continue;
+			memcpy(ipm->mac, buf, sizeof(tmp->mac));
+			ipm->u.a4.addr = im4->multiaddr;
+			ipm->is_multicast = 1;
+			ipm->disp_flag = QETH_DISP_ADDR_ADD;
+			hash_add(card->ip_mc_htable,
+					&ipm->hnode, qeth_l3_ipaddr_hash(ipm));
+		}
 	}
+
+	kfree(tmp);
 }
 
 /* called with rcu_read_lock */
@@ -1541,6 +1505,7 @@ static void qeth_l3_add_vlan_mc(struct qeth_card *card)
 	u16 vid;
 
 	QETH_CARD_TEXT(card, 4, "addmcvl");
+
 	if (!qeth_is_supported(card, IPA_FULL_VLAN))
 		return;
 
@@ -1555,7 +1520,7 @@ static void qeth_l3_add_vlan_mc(struct qeth_card *card)
 		in_dev = __in_dev_get_rcu(netdev);
 		if (!in_dev)
 			continue;
-		qeth_l3_add_mc(card, in_dev);
+		qeth_l3_add_mc_to_hash(card, in_dev);
 	}
 }
 
@@ -1564,36 +1529,60 @@ static void qeth_l3_add_multicast_ipv4(struct qeth_card *card)
 	struct in_device *in4_dev;
 
 	QETH_CARD_TEXT(card, 4, "chkmcv4");
+
 	rcu_read_lock();
 	in4_dev = __in_dev_get_rcu(card->dev);
 	if (in4_dev == NULL)
 		goto unlock;
-	qeth_l3_add_mc(card, in4_dev);
+	qeth_l3_add_mc_to_hash(card, in4_dev);
 	qeth_l3_add_vlan_mc(card);
 unlock:
 	rcu_read_unlock();
 }
 
 #ifdef CONFIG_QETH_IPV6
-static void qeth_l3_add_mc6(struct qeth_card *card, struct inet6_dev *in6_dev)
+static void
+qeth_l3_add_mc6_to_hash(struct qeth_card *card, struct inet6_dev *in6_dev)
 {
 	struct qeth_ipaddr *ipm;
 	struct ifmcaddr6 *im6;
+	struct qeth_ipaddr *tmp;
 	char buf[MAX_ADDR_LEN];
 
 	QETH_CARD_TEXT(card, 4, "addmc6");
+
+	tmp = qeth_l3_get_addr_buffer(QETH_PROT_IPV6);
+		if (!tmp)
+			return;
+
 	for (im6 = in6_dev->mc_list; im6 != NULL; im6 = im6->next) {
 		ndisc_mc_map(&im6->mca_addr, buf, in6_dev->dev, 0);
+
+		memcpy(tmp->mac, buf, sizeof(tmp->mac));
+		memcpy(&tmp->u.a6.addr, &im6->mca_addr.s6_addr,
+		       sizeof(struct in6_addr));
+		tmp->is_multicast = 1;
+
+		ipm = qeth_l3_ip_from_hash(card, tmp);
+		if (ipm) {
+			ipm->disp_flag = QETH_DISP_ADDR_DO_NOTHING;
+			continue;
+		}
+
 		ipm = qeth_l3_get_addr_buffer(QETH_PROT_IPV6);
 		if (!ipm)
 			continue;
-		ipm->is_multicast = 1;
+
 		memcpy(ipm->mac, buf, OSA_ADDR_LEN);
 		memcpy(&ipm->u.a6.addr, &im6->mca_addr.s6_addr,
 		       sizeof(struct in6_addr));
-		if (!qeth_l3_add_ip(card, ipm))
-			kfree(ipm);
+		ipm->is_multicast = 1;
+		ipm->disp_flag = QETH_DISP_ADDR_ADD;
+		hash_add(card->ip_mc_htable,
+				&ipm->hnode, qeth_l3_ipaddr_hash(ipm));
+
 	}
+	kfree(tmp);
 }
 
 /* called with rcu_read_lock */
@@ -1603,6 +1592,7 @@ static void qeth_l3_add_vlan_mc6(struct qeth_card *card)
 	u16 vid;
 
 	QETH_CARD_TEXT(card, 4, "admc6vl");
+
 	if (!qeth_is_supported(card, IPA_FULL_VLAN))
 		return;
 
@@ -1618,7 +1608,7 @@ static void qeth_l3_add_vlan_mc6(struct qeth_card *card)
 		if (!in_dev)
 			continue;
 		read_lock_bh(&in_dev->lock);
-		qeth_l3_add_mc6(card, in_dev);
+		qeth_l3_add_mc6_to_hash(card, in_dev);
 		read_unlock_bh(&in_dev->lock);
 		in6_dev_put(in_dev);
 	}
@@ -1629,14 +1619,16 @@ static void qeth_l3_add_multicast_ipv6(struct qeth_card *card)
 	struct inet6_dev *in6_dev;
 
 	QETH_CARD_TEXT(card, 4, "chkmcv6");
+
 	if (!qeth_is_supported(card, IPA_IPV6))
 		return ;
 	in6_dev = in6_dev_get(card->dev);
-	if (in6_dev == NULL)
+	if (!in6_dev)
 		return;
+
 	rcu_read_lock();
 	read_lock_bh(&in6_dev->lock);
-	qeth_l3_add_mc6(card, in6_dev);
+	qeth_l3_add_mc6_to_hash(card, in6_dev);
 	qeth_l3_add_vlan_mc6(card);
 	read_unlock_bh(&in6_dev->lock);
 	rcu_read_unlock();
@@ -1660,16 +1652,23 @@ static void qeth_l3_free_vlan_addresses4(struct qeth_card *card,
 	in_dev = in_dev_get(netdev);
 	if (!in_dev)
 		return;
+
+	addr = qeth_l3_get_addr_buffer(QETH_PROT_IPV4);
+	if (!addr)
+		return;
+
+	spin_lock_bh(&card->ip_lock);
+
 	for (ifa = in_dev->ifa_list; ifa; ifa = ifa->ifa_next) {
-		addr = qeth_l3_get_addr_buffer(QETH_PROT_IPV4);
-		if (addr) {
-			addr->u.a4.addr = ifa->ifa_address;
-			addr->u.a4.mask = ifa->ifa_mask;
-			addr->type = QETH_IP_TYPE_NORMAL;
-			if (!qeth_l3_delete_ip(card, addr))
-				kfree(addr);
-		}
+		addr->u.a4.addr = ifa->ifa_address;
+		addr->u.a4.mask = ifa->ifa_mask;
+		addr->type = QETH_IP_TYPE_NORMAL;
+		qeth_l3_delete_ip(card, addr);
 	}
+
+	spin_unlock_bh(&card->ip_lock);
+
+	kfree(addr);
 	in_dev_put(in_dev);
 }
 
@@ -1687,20 +1686,28 @@ static void qeth_l3_free_vlan_addresses6(struct qeth_card *card,
 	netdev = __vlan_find_dev_deep_rcu(card->dev, htons(ETH_P_8021Q), vid);
 	if (!netdev)
 		return;
+
 	in6_dev = in6_dev_get(netdev);
 	if (!in6_dev)
 		return;
+
+	addr = qeth_l3_get_addr_buffer(QETH_PROT_IPV6);
+	if (!addr)
+		return;
+
+	spin_lock_bh(&card->ip_lock);
+
 	list_for_each_entry(ifa, &in6_dev->addr_list, if_list) {
-		addr = qeth_l3_get_addr_buffer(QETH_PROT_IPV6);
-		if (addr) {
-			memcpy(&addr->u.a6.addr, &ifa->addr,
-			       sizeof(struct in6_addr));
-			addr->u.a6.pfxlen = ifa->prefix_len;
-			addr->type = QETH_IP_TYPE_NORMAL;
-			if (!qeth_l3_delete_ip(card, addr))
-				kfree(addr);
-		}
+		memcpy(&addr->u.a6.addr, &ifa->addr,
+		       sizeof(struct in6_addr));
+		addr->u.a6.pfxlen = ifa->prefix_len;
+		addr->type = QETH_IP_TYPE_NORMAL;
+		qeth_l3_delete_ip(card, addr);
 	}
+
+	spin_unlock_bh(&card->ip_lock);
+
+	kfree(addr);
 	in6_dev_put(in6_dev);
 #endif /* CONFIG_QETH_IPV6 */
 }
@@ -1727,18 +1734,16 @@ static int qeth_l3_vlan_rx_kill_vid(struct net_device *dev,
 				    __be16 proto, u16 vid)
 {
 	struct qeth_card *card = dev->ml_priv;
-	unsigned long flags;
 
 	QETH_CARD_TEXT_(card, 4, "kid:%d", vid);
+
 	if (qeth_wait_for_threads(card, QETH_RECOVER_THREAD)) {
 		QETH_CARD_TEXT(card, 3, "kidREC");
 		return 0;
 	}
-	spin_lock_irqsave(&card->vlanlock, flags);
 	/* unregister IP addresses of vlan device */
 	qeth_l3_free_vlan_addresses(card, vid);
 	clear_bit(vid, card->active_vlans);
-	spin_unlock_irqrestore(&card->vlanlock, flags);
 	qeth_l3_set_multicast_list(card->dev);
 	return 0;
 }
@@ -1994,8 +1999,8 @@ static int qeth_l3_verify_vlan_dev(struct net_device *dev,
 static int qeth_l3_verify_dev(struct net_device *dev)
 {
 	struct qeth_card *card;
-	unsigned long flags;
 	int rc = 0;
+	unsigned long flags;
 
 	read_lock_irqsave(&qeth_core_card_list.rwlock, flags);
 	list_for_each_entry(card, &qeth_core_card_list.list, list) {
@@ -2051,7 +2056,7 @@ static void qeth_l3_stop_card(struct qeth_card *card, int recovery_mode)
 		card->state = CARD_STATE_SOFTSETUP;
 	}
 	if (card->state == CARD_STATE_SOFTSETUP) {
-		qeth_l3_clear_ip_list(card, 1);
+		qeth_l3_clear_ip_htable(card, 1);
 		qeth_clear_ipacmd_list(card);
 		card->state = CARD_STATE_HARDSETUP;
 	}
@@ -2106,12 +2111,20 @@ static void qeth_l3_set_multicast_list(struct net_device *dev)
 	    (card->state != CARD_STATE_UP))
 		return;
 	if (!card->options.sniffer) {
-		qeth_l3_delete_mc_addresses(card);
+
+		spin_lock_bh(&card->mclock);
+
+		qeth_l3_mark_all_mc_to_be_deleted(card);
+
 		qeth_l3_add_multicast_ipv4(card);
 #ifdef CONFIG_QETH_IPV6
 		qeth_l3_add_multicast_ipv6(card);
 #endif
-		qeth_l3_set_ip_addr_list(card);
+		qeth_l3_delete_nonused_mc(card);
+		qeth_l3_add_all_new_mc(card);
+
+		spin_unlock_bh(&card->mclock);
+
 		if (!qeth_adp_supported(card, IPA_SETADP_SET_PROMISC_MODE))
 			return;
 	}
@@ -3261,7 +3274,7 @@ static void qeth_l3_remove_device(struct ccwgroup_device *cgdev)
 		card->dev = NULL;
 	}
 
-	qeth_l3_clear_ip_list(card, 0);
+	qeth_l3_clear_ip_htable(card, 0);
 	qeth_l3_clear_ipato_list(card);
 	return;
 }
@@ -3346,7 +3359,7 @@ contin:
 	card->state = CARD_STATE_SOFTSETUP;
 
 	qeth_set_allowed_threads(card, 0xffffffff, 0);
-	qeth_l3_set_ip_addr_list(card);
+	qeth_l3_recover_ip(card);
 	if (card->lan_online)
 		netif_carrier_on(card->dev);
 	else
@@ -3547,6 +3560,7 @@ EXPORT_SYMBOL_GPL(qeth_l3_discipline);
 static int qeth_l3_ip_event(struct notifier_block *this,
 			    unsigned long event, void *ptr)
 {
+
 	struct in_ifaddr *ifa = (struct in_ifaddr *)ptr;
 	struct net_device *dev = (struct net_device *)ifa->ifa_dev->dev;
 	struct qeth_ipaddr *addr;
@@ -3561,27 +3575,27 @@ static int qeth_l3_ip_event(struct notifier_block *this,
 	QETH_CARD_TEXT(card, 3, "ipevent");
 
 	addr = qeth_l3_get_addr_buffer(QETH_PROT_IPV4);
-	if (addr != NULL) {
+	if (addr) {
 		addr->u.a4.addr = ifa->ifa_address;
 		addr->u.a4.mask = ifa->ifa_mask;
 		addr->type = QETH_IP_TYPE_NORMAL;
 	} else
-		goto out;
+		return NOTIFY_DONE;
 
 	switch (event) {
 	case NETDEV_UP:
-		if (!qeth_l3_add_ip(card, addr))
-			kfree(addr);
+		spin_lock_bh(&card->ip_lock);
+		qeth_l3_add_ip(card, addr);
+		spin_unlock_bh(&card->ip_lock);
 		break;
 	case NETDEV_DOWN:
-		if (!qeth_l3_delete_ip(card, addr))
-			kfree(addr);
-		break;
-	default:
+		spin_lock_bh(&card->ip_lock);
+		qeth_l3_delete_ip(card, addr);
+		spin_unlock_bh(&card->ip_lock);
 		break;
 	}
-	qeth_l3_set_ip_addr_list(card);
-out:
+
+	kfree(addr);
 	return NOTIFY_DONE;
 }
 
@@ -3610,27 +3624,27 @@ static int qeth_l3_ip6_event(struct notifier_block *this,
 		return NOTIFY_DONE;
 
 	addr = qeth_l3_get_addr_buffer(QETH_PROT_IPV6);
-	if (addr != NULL) {
+	if (addr) {
 		memcpy(&addr->u.a6.addr, &ifa->addr, sizeof(struct in6_addr));
 		addr->u.a6.pfxlen = ifa->prefix_len;
 		addr->type = QETH_IP_TYPE_NORMAL;
 	} else
-		goto out;
+		return NOTIFY_DONE;
 
 	switch (event) {
 	case NETDEV_UP:
-		if (!qeth_l3_add_ip(card, addr))
-			kfree(addr);
+		spin_lock_bh(&card->ip_lock);
+		qeth_l3_add_ip(card, addr);
+		spin_unlock_bh(&card->ip_lock);
 		break;
 	case NETDEV_DOWN:
-		if (!qeth_l3_delete_ip(card, addr))
-			kfree(addr);
-		break;
-	default:
+		spin_lock_bh(&card->ip_lock);
+		qeth_l3_delete_ip(card, addr);
+		spin_unlock_bh(&card->ip_lock);
 		break;
 	}
-	qeth_l3_set_ip_addr_list(card);
-out:
+
+	kfree(addr);
 	return NOTIFY_DONE;
 }
 
diff --git a/drivers/s390/net/qeth_l3_sys.c b/drivers/s390/net/qeth_l3_sys.c
index 386eb7b..65645b1 100644
--- a/drivers/s390/net/qeth_l3_sys.c
+++ b/drivers/s390/net/qeth_l3_sys.c
@@ -8,6 +8,7 @@
 
 #include <linux/slab.h>
 #include <asm/ebcdic.h>
+#include <linux/hashtable.h>
 #include "qeth_l3.h"
 
 #define QETH_DEVICE_ATTR(_id, _name, _mode, _show, _store) \
@@ -285,19 +286,19 @@ static ssize_t qeth_l3_dev_hsuid_store(struct device *dev,
 	if (card->options.hsuid[0]) {
 		/* delete old ip address */
 		addr = qeth_l3_get_addr_buffer(QETH_PROT_IPV6);
-		if (addr != NULL) {
-			addr->u.a6.addr.s6_addr32[0] = 0xfe800000;
-			addr->u.a6.addr.s6_addr32[1] = 0x00000000;
-			for (i = 8; i < 16; i++)
-				addr->u.a6.addr.s6_addr[i] =
-					card->options.hsuid[i - 8];
-			addr->u.a6.pfxlen = 0;
-			addr->type = QETH_IP_TYPE_NORMAL;
-		} else
+		if (!addr)
 			return -ENOMEM;
-		if (!qeth_l3_delete_ip(card, addr))
-			kfree(addr);
-		qeth_l3_set_ip_addr_list(card);
+
+		addr->u.a6.addr.s6_addr32[0] = 0xfe800000;
+		addr->u.a6.addr.s6_addr32[1] = 0x00000000;
+		for (i = 8; i < 16; i++)
+			addr->u.a6.addr.s6_addr[i] =
+				card->options.hsuid[i - 8];
+		addr->u.a6.pfxlen = 0;
+		addr->type = QETH_IP_TYPE_NORMAL;
+
+		qeth_l3_delete_ip(card, addr);
+		kfree(addr);
 	}
 
 	if (strlen(tmp) == 0) {
@@ -328,9 +329,8 @@ static ssize_t qeth_l3_dev_hsuid_store(struct device *dev,
 		addr->type = QETH_IP_TYPE_NORMAL;
 	} else
 		return -ENOMEM;
-	if (!qeth_l3_add_ip(card, addr))
-		kfree(addr);
-	qeth_l3_set_ip_addr_list(card);
+	qeth_l3_add_ip(card, addr);
+	kfree(addr);
 
 	return count;
 }
@@ -367,8 +367,8 @@ static ssize_t qeth_l3_dev_ipato_enable_store(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
 {
 	struct qeth_card *card = dev_get_drvdata(dev);
-	struct qeth_ipaddr *tmpipa, *t;
-	int rc = 0;
+	struct qeth_ipaddr *addr;
+	int i, rc = 0;
 
 	if (!card)
 		return -EINVAL;
@@ -384,21 +384,20 @@ static ssize_t qeth_l3_dev_ipato_enable_store(struct device *dev,
 		card->ipato.enabled = (card->ipato.enabled)? 0 : 1;
 	} else if (sysfs_streq(buf, "1")) {
 		card->ipato.enabled = 1;
-		list_for_each_entry_safe(tmpipa, t, card->ip_tbd_list, entry) {
-			if ((tmpipa->type == QETH_IP_TYPE_NORMAL) &&
-				qeth_l3_is_addr_covered_by_ipato(card, tmpipa))
-				tmpipa->set_flags |=
+		hash_for_each(card->ip_htable, i, addr, hnode) {
+				if ((addr->type == QETH_IP_TYPE_NORMAL) &&
+				qeth_l3_is_addr_covered_by_ipato(card, addr))
+					addr->set_flags |=
 					QETH_IPA_SETIP_TAKEOVER_FLAG;
-		}
-
+			}
 	} else if (sysfs_streq(buf, "0")) {
 		card->ipato.enabled = 0;
-		list_for_each_entry_safe(tmpipa, t, card->ip_tbd_list, entry) {
-			if (tmpipa->set_flags &
-				QETH_IPA_SETIP_TAKEOVER_FLAG)
-				tmpipa->set_flags &=
-					~QETH_IPA_SETIP_TAKEOVER_FLAG;
-		}
+		hash_for_each(card->ip_htable, i, addr, hnode) {
+			if (addr->set_flags &
+			QETH_IPA_SETIP_TAKEOVER_FLAG)
+				addr->set_flags &=
+				~QETH_IPA_SETIP_TAKEOVER_FLAG;
+			}
 	} else
 		rc = -EINVAL;
 out:
@@ -452,7 +451,6 @@ static ssize_t qeth_l3_dev_ipato_add_show(char *buf, struct qeth_card *card,
 			enum qeth_prot_versions proto)
 {
 	struct qeth_ipato_entry *ipatoe;
-	unsigned long flags;
 	char addr_str[40];
 	int entry_len; /* length of 1 entry string, differs between v4 and v6 */
 	int i = 0;
@@ -460,7 +458,7 @@ static ssize_t qeth_l3_dev_ipato_add_show(char *buf, struct qeth_card *card,
 	entry_len = (proto == QETH_PROT_IPV4)? 12 : 40;
 	/* add strlen for "/<mask>\n" */
 	entry_len += (proto == QETH_PROT_IPV4)? 5 : 6;
-	spin_lock_irqsave(&card->ip_lock, flags);
+	spin_lock_bh(&card->ip_lock);
 	list_for_each_entry(ipatoe, &card->ipato.entries, entry) {
 		if (ipatoe->proto != proto)
 			continue;
@@ -473,7 +471,7 @@ static ssize_t qeth_l3_dev_ipato_add_show(char *buf, struct qeth_card *card,
 		i += snprintf(buf + i, PAGE_SIZE - i,
 			      "%s/%i\n", addr_str, ipatoe->mask_bits);
 	}
-	spin_unlock_irqrestore(&card->ip_lock, flags);
+	spin_unlock_bh(&card->ip_lock);
 	i += snprintf(buf + i, PAGE_SIZE - i, "\n");
 
 	return i;
@@ -689,15 +687,15 @@ static ssize_t qeth_l3_dev_vipa_add_show(char *buf, struct qeth_card *card,
 			enum qeth_prot_versions proto)
 {
 	struct qeth_ipaddr *ipaddr;
+	struct hlist_node  *tmp;
 	char addr_str[40];
 	int entry_len; /* length of 1 entry string, differs between v4 and v6 */
-	unsigned long flags;
 	int i = 0;
 
 	entry_len = (proto == QETH_PROT_IPV4)? 12 : 40;
 	entry_len += 2; /* \n + terminator */
-	spin_lock_irqsave(&card->ip_lock, flags);
-	list_for_each_entry(ipaddr, &card->ip_list, entry) {
+	spin_lock_bh(&card->ip_lock);
+	hash_for_each_safe(card->ip_htable, i, tmp, ipaddr, hnode) {
 		if (ipaddr->proto != proto)
 			continue;
 		if (ipaddr->type != QETH_IP_TYPE_VIPA)
@@ -711,7 +709,7 @@ static ssize_t qeth_l3_dev_vipa_add_show(char *buf, struct qeth_card *card,
 			addr_str);
 		i += snprintf(buf + i, PAGE_SIZE - i, "%s\n", addr_str);
 	}
-	spin_unlock_irqrestore(&card->ip_lock, flags);
+	spin_unlock_bh(&card->ip_lock);
 	i += snprintf(buf + i, PAGE_SIZE - i, "\n");
 
 	return i;
@@ -851,15 +849,15 @@ static ssize_t qeth_l3_dev_rxip_add_show(char *buf, struct qeth_card *card,
 		       enum qeth_prot_versions proto)
 {
 	struct qeth_ipaddr *ipaddr;
+	struct hlist_node *tmp;
 	char addr_str[40];
 	int entry_len; /* length of 1 entry string, differs between v4 and v6 */
-	unsigned long flags;
 	int i = 0;
 
 	entry_len = (proto == QETH_PROT_IPV4)? 12 : 40;
 	entry_len += 2; /* \n + terminator */
-	spin_lock_irqsave(&card->ip_lock, flags);
-	list_for_each_entry(ipaddr, &card->ip_list, entry) {
+	spin_lock_bh(&card->ip_lock);
+	hash_for_each_safe(card->ip_htable, i, tmp, ipaddr, hnode) {
 		if (ipaddr->proto != proto)
 			continue;
 		if (ipaddr->type != QETH_IP_TYPE_RXIP)
@@ -873,7 +871,7 @@ static ssize_t qeth_l3_dev_rxip_add_show(char *buf, struct qeth_card *card,
 			addr_str);
 		i += snprintf(buf + i, PAGE_SIZE - i, "%s\n", addr_str);
 	}
-	spin_unlock_irqrestore(&card->ip_lock, flags);
+	spin_unlock_bh(&card->ip_lock);
 	i += snprintf(buf + i, PAGE_SIZE - i, "\n");
 
 	return i;
-- 
2.6.6
