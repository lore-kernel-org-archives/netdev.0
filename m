From: Anton Nayshtut <Anton.Nayshtut@wilocity.com>
Subject: [PATCH 1/4] bonding: L2DA mode added
Date: Thu, 21 Nov 2013 16:55:35 +0200
Message-ID: <1385045738-29726-2-git-send-email-Anton.Nayshtut@wilocity.com>
References: <1385045738-29726-1-git-send-email-Anton.Nayshtut@wilocity.com>
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Anton Nayshtut <Anton.Nayshtut@wilocity.com>,
	Erez Kirshenbaum <Erez.Kirshenbaum@wilocity.com>,
	Boris Lapshin <Boris.Lapshin@wilocity.com>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1385045738-29726-1-git-send-email-Anton.Nayshtut@wilocity.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patches introduces L2DA bonding module with all the data structures and
interfaces. It's not integrated yet.

Signed-off-by: Anton Nayshtut <Anton.Nayshtut@wilocity.com>
Signed-off-by: Erez Kirshenbaum <Erez.Kirshenbaum@wilocity.com>
Signed-off-by: Boris Lapshin <Boris.Lapshin@wilocity.com>
---
 drivers/net/bonding/Makefile    |   2 +-
 drivers/net/bonding/bond_l2da.c | 425 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_l2da.h |  56 ++++++
 drivers/net/bonding/bonding.h   |   2 +
 4 files changed, 484 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/bonding/bond_l2da.c
 create mode 100644 drivers/net/bonding/bond_l2da.h

diff --git a/drivers/net/bonding/Makefile b/drivers/net/bonding/Makefile
index 5a5d720..3eecd54 100644
--- a/drivers/net/bonding/Makefile
+++ b/drivers/net/bonding/Makefile
@@ -4,7 +4,7 @@
 
 obj-$(CONFIG_BONDING) += bonding.o
 
-bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o bond_debugfs.o bond_netlink.o bond_options.o
+bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o bond_debugfs.o bond_netlink.o bond_options.o bond_l2da.o
 
 proc-$(CONFIG_PROC_FS) += bond_procfs.o
 bonding-objs += $(proc-y)
diff --git a/drivers/net/bonding/bond_l2da.c b/drivers/net/bonding/bond_l2da.c
new file mode 100644
index 0000000..01d0d40
--- /dev/null
+++ b/drivers/net/bonding/bond_l2da.c
@@ -0,0 +1,425 @@
+/*  Copyright(c) 2013 Wilocity Ltd. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include "bonding.h"
+#include "bond_l2da.h"
+#include <linux/etherdevice.h>
+
+struct l2da_bond_matrix_entry {
+	struct hlist_node hnode;
+	unsigned char     h_dest[ETH_ALEN];
+	struct slave     *slave;
+};
+
+
+#define BOND_L2DA_INFO(bond)     ((bond)->l2da_info)
+#define SLAVE_L2DA_INFO(bond)    ((slave)->l2da_info)
+#define SLAVE_BY_L2DA_INFO(info) container_of(info, struct slave, l2da_info)
+
+#define SLAVE_CAN_XMIT(slave)    (IS_UP((slave)->dev) && \
+				  ((slave)->link == BOND_LINK_UP) && \
+				  bond_is_active_slave(slave))
+
+/**
+ * _bond_l2da_slave_name - returns slave name
+ * @slave: slave struct to work on
+ *
+ * Returns @slave network device name, or "null" if it can't be found.
+ */
+static inline const char *_bond_l2da_slave_name(struct slave *slave)
+{
+	if (slave && slave->dev)
+		return netdev_name(slave->dev);
+	return "null";
+}
+
+/**
+ * _bond_l2da_hash_val - hash function for L2DA map hash table
+ * @da: DA to be used as a hash key
+ *
+ * Returns hash value for @da
+ */
+static inline u32 _bond_l2da_hash_val(const unsigned char *da)
+{
+	return da[ETH_ALEN - 2];
+}
+
+/**
+ * _bond_l2da_find_entry_unsafe - searches for DA:iface mapping within the map
+ * @bond_info: L2DA bonding struct to work on
+ * @da: DA to be used as a key
+ *
+ * Returns map entry for @da, or %NULL if it can't be found.
+ *
+ * The function must be called under the L2DA bonding struct lock.
+ */
+static struct l2da_bond_matrix_entry *
+_bond_l2da_find_entry_unsafe(struct l2da_bond_info *bond_info,
+			     const unsigned char *da)
+{
+	struct l2da_bond_matrix_entry *entry = NULL;
+	u32 hash_val = 0;
+	BUG_ON(da == NULL);
+
+	hash_val = _bond_l2da_hash_val(da);
+	hash_for_each_possible(bond_info->da_matrix, entry, hnode, hash_val) {
+		if (!compare_ether_addr(entry->h_dest, da))
+			return entry;
+	}
+	return NULL;
+}
+
+/**
+ * _bond_l2da_select_fallback_slave_unsafe - selects a random fallback slave
+ *                                           (if needed)
+ * @bond: bonding struct to work on
+ *
+ * The function must be called under the L2DA bonding struct lock.
+ */
+static void
+_bond_l2da_select_fallback_slave_unsafe(struct bonding *bond)
+{
+	struct l2da_bond_info *bond_info = &BOND_L2DA_INFO(bond);
+	struct slave *slave;
+	struct slave *fallback_slave = bond_info->fallback_slave;
+	struct list_head *iter;
+
+	/* No need for fallback slave while default slave is OK */
+	if (bond_info->default_slave &&
+	    SLAVE_CAN_XMIT(bond_info->default_slave)) {
+		fallback_slave = NULL;
+		goto out;
+	}
+
+	/* Current fallback slave is OK */
+	if (bond_info->fallback_slave &&
+	    SLAVE_CAN_XMIT(bond_info->fallback_slave))
+		goto out;
+
+	/* Select new fallback slave */
+	fallback_slave = NULL;
+	bond_for_each_slave(bond, slave, iter) {
+		if (slave != bond_info->default_slave &&
+		    SLAVE_CAN_XMIT(slave)) {
+			fallback_slave = slave;
+			goto out;
+		}
+	}
+
+out:
+	if (fallback_slave != bond_info->fallback_slave) {
+		pr_info("bond_l2da fallback slave set to %s\n",
+				_bond_l2da_slave_name(fallback_slave));
+		bond_info->fallback_slave = fallback_slave;
+	}
+}
+
+/**
+ * _bond_l2da_remove_entries_unsafe - removes all iface mappings from the map
+ * @bond_info: L2DA bonding struct to work on
+ * @slave: slave whose mappings have to be removed
+ *
+ * The function must be called under the L2DA bonding struct lock.
+ */
+static void _bond_l2da_remove_entries_unsafe(struct l2da_bond_info *bond_info,
+					     struct slave *slave)
+{
+	struct l2da_bond_matrix_entry *entry = NULL;
+	struct hlist_node *tmp;
+	int bkt;
+	hash_for_each_safe(bond_info->da_matrix, bkt, tmp, entry, hnode) {
+		/* NULL slave means "remove all" */
+		if (!slave || entry->slave == slave) {
+			hash_del(&entry->hnode);
+			kfree(entry);
+		}
+	}
+}
+
+/**
+ * bond_l2da_initialize - initializes a bond's L2DA context
+ * @bond: bonding struct to work on
+ */
+int bond_l2da_initialize(struct bonding *bond)
+{
+	struct l2da_bond_info *bond_info = &BOND_L2DA_INFO(bond);
+	memset(bond_info, 0, sizeof(*bond_info));
+	hash_init(bond_info->da_matrix);
+	rwlock_init(&bond_info->lock);
+	bond_info->default_slave = NULL;
+	pr_info("bond_l2da initialized\n");
+	return 0;
+}
+
+/**
+ * bond_l2da_deinitialize - deinitializes a bond's L2DA context
+ * @bond: bonding struct to work on
+ */
+void bond_l2da_deinitialize(struct bonding *bond)
+{
+	struct l2da_bond_info *bond_info = &BOND_L2DA_INFO(bond);
+	/* Kick off any bonds registered  */
+	write_lock_bh(&bond_info->lock);
+	_bond_l2da_remove_entries_unsafe(bond_info, NULL);
+	write_unlock_bh(&bond_info->lock);
+	BUG_ON(!hash_empty(bond_info->da_matrix));
+	memset(bond_info, 0, sizeof(*bond_info)); /* for debugging purposes */
+	pr_info("bond_l2da de-initialized\n");
+}
+
+/**
+ * bond_l2da_slave_init - initializes a slave
+ * @bond: bonding struct to work on
+ * @slave: slave struct to work on
+ *
+ * Assigns default and fallback slaves (if needed).
+ */
+int bond_l2da_slave_init(struct bonding *bond, struct slave *slave)
+{
+	struct l2da_bond_info *bond_info = &BOND_L2DA_INFO(bond);
+	write_lock_bh(&bond_info->lock);
+	if (!bond_info->default_slave) {
+		bond_info->default_slave = slave;
+		pr_info("bond_l2da default slave initially set to %s\n",
+			_bond_l2da_slave_name(slave));
+	}
+	_bond_l2da_select_fallback_slave_unsafe(bond);
+	write_unlock_bh(&bond_info->lock);
+	return 0;
+}
+
+/**
+ * bond_l2da_slave_deinit - deinitializes a slave
+ * @slave: slave struct to work on
+ *
+ * Removes all matrix entries for this slave, re-assigns default and fallback
+ * slaves (if needed).
+ */
+void bond_l2da_slave_deinit(struct bonding *bond, struct slave *slave)
+{
+	struct l2da_bond_info *bond_info = &BOND_L2DA_INFO(bond);
+	write_lock_bh(&bond_info->lock);
+	if (slave == bond_info->default_slave) {
+		/* default slave has gone, so let's use some other slave as
+		 * a new default
+		 */
+		bond_info->default_slave = bond_first_slave(bond);
+		pr_info("bond_l2da default slave set to %s\n",
+			_bond_l2da_slave_name(bond_info->default_slave));
+	}
+	_bond_l2da_remove_entries_unsafe(bond_info, slave);
+	_bond_l2da_select_fallback_slave_unsafe(bond);
+	write_unlock_bh(&bond_info->lock);
+}
+
+/**
+ * bond_l2da_xmit - transmits skb in L2DA mode
+ * @skb: skb to transmit
+ * @dev: bonding net device
+ */
+int bond_l2da_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct bonding *bond = netdev_priv(dev);
+	struct l2da_bond_info *bond_info = &BOND_L2DA_INFO(bond);
+	struct ethhdr *eth_data;
+	struct l2da_bond_matrix_entry *entry;
+	int res = 1;
+
+	skb_reset_mac_header(skb);
+	eth_data = eth_hdr(skb);
+
+	read_lock_bh(&bond_info->lock);
+	entry = _bond_l2da_find_entry_unsafe(bond_info, eth_data->h_dest);
+	if (entry && entry->slave && SLAVE_CAN_XMIT(entry->slave)) {
+		/* if a slave configured  for this DA and it's OK - use it */
+		res = bond_dev_queue_xmit(bond, skb, entry->slave->dev);
+	} else if (bond_info->default_slave &&
+		 SLAVE_CAN_XMIT(bond_info->default_slave)) {
+		/* otherwise, if default slave configured and OK - use it */
+		res = bond_dev_queue_xmit(bond, skb,
+					  bond_info->default_slave->dev);
+	} else if (bond_info->fallback_slave) {
+		/* otherwise, if fallback slave selected - use it */
+		res = bond_dev_queue_xmit(bond, skb,
+					  bond_info->fallback_slave->dev);
+	}
+	read_unlock_bh(&bond_info->lock);
+
+	if (res) {
+		/* no suitable interface, frame not sent */
+		kfree_skb(skb);
+	}
+
+	return NETDEV_TX_OK;
+}
+
+/**
+ * bond_l2da_set_default_slave - sends default slave
+ * @bond: bonding struct to work on
+ * @slave: slave struct whose link status changed
+ */
+void bond_l2da_set_default_slave(struct bonding *bond, struct slave *slave)
+{
+	struct l2da_bond_info *bond_info = &BOND_L2DA_INFO(bond);
+	write_lock_bh(&bond_info->lock);
+	bond_info->default_slave = slave;
+	pr_info("bond_l2da default slave set to %s\n",
+			_bond_l2da_slave_name(slave));
+	_bond_l2da_select_fallback_slave_unsafe(bond);
+	write_unlock_bh(&bond_info->lock);
+}
+
+/**
+ * bond_l2da_get_default_slave_name - gets name of currently configured default
+ *                                    slave
+ * @bond: bonding struct to work on
+ * @buf: destination buffer
+ * @size: destination buffer size
+ */
+int bond_l2da_get_default_slave_name(struct bonding *bond, char *buf, int size)
+{
+	struct l2da_bond_info *bond_info = &BOND_L2DA_INFO(bond);
+
+	if (!buf || size < IFNAMSIZ)
+		return -EINVAL;
+
+	*buf = 0;
+
+	read_lock_bh(&bond_info->lock);
+	if (bond_info->default_slave) {
+		strncpy(buf, netdev_name(bond_info->default_slave->dev),
+			IFNAMSIZ);
+	}
+	read_unlock_bh(&bond_info->lock);
+	return 0;
+}
+
+/**
+ * bond_l2da_set_da_slave - adds DA:slave mapping
+ * @bond: bonding struct to work on
+ * @da: desired L2 destination address to map
+ * @slave: slave to be used for sending packets to desired destination address
+ */
+int bond_l2da_set_da_slave(struct bonding *bond, const unsigned char *da,
+		struct slave *slave)
+{
+	struct l2da_bond_info *bond_info = &BOND_L2DA_INFO(bond);
+	struct l2da_bond_matrix_entry *entry;
+	struct slave *prev_slave = NULL;
+
+	write_lock_bh(&bond_info->lock);
+	entry = _bond_l2da_find_entry_unsafe(bond_info, da);
+	if (entry) {
+		prev_slave = entry->slave;
+		entry->slave = slave;
+	} else {
+		entry = kmalloc(sizeof(*entry), GFP_ATOMIC);
+		if (entry) {
+			entry->slave = slave;
+			memcpy(entry->h_dest, da, ETH_ALEN);
+			hash_add(bond_info->da_matrix, &entry->hnode,
+					_bond_l2da_hash_val(da));
+		}
+	}
+	write_unlock_bh(&bond_info->lock);
+
+	if (!entry) {
+		pr_err("bond_l2da: pair node cannot be allocated for [%pM:%s]\n",
+			da, _bond_l2da_slave_name(slave));
+		return -ENOMEM;
+	}
+
+	pr_info("bond_l2da: pair %s [%pM:%s]\n",
+		prev_slave ? "changed" : "added",
+		da, _bond_l2da_slave_name(slave));
+
+	return 0;
+}
+
+/**
+ * bond_l2da_del_da - removes DA mapping
+ * @bond: bonding struct to work on
+ * @da: L2 destination address whose mapping has to be removed
+ */
+int bond_l2da_del_da(struct bonding *bond, const unsigned char *da)
+{
+	struct l2da_bond_info *bond_info = &BOND_L2DA_INFO(bond);
+	struct l2da_bond_matrix_entry *entry;
+
+	write_lock_bh(&bond_info->lock);
+	entry = _bond_l2da_find_entry_unsafe(bond_info, da);
+	if (entry)
+		hash_del(&entry->hnode);
+	write_unlock_bh(&bond_info->lock);
+
+	if (!entry) {
+		pr_err("bond_l2da: pair node cannot be found for %pM\n",
+			da);
+		return -ENOENT;
+	}
+
+	pr_info("bond_l2da: pair deleted [%pM:%s]\n",
+			da, _bond_l2da_slave_name(entry->slave));
+	kfree(entry);
+	return 0;
+}
+
+/**
+ * bond_l2da_handle_link_change - handle a slave's link status change indication
+ * @bond: bonding struct to work on
+ * @slave: slave struct whose link status changed
+ *
+ * Handle re-selection of fallback slave (if needed).
+ */
+void bond_l2da_handle_link_change(struct bonding *bond, struct slave *slave)
+{
+	struct l2da_bond_info *bond_info = &BOND_L2DA_INFO(bond);
+
+	write_lock_bh(&bond_info->lock);
+	_bond_l2da_select_fallback_slave_unsafe(bond);
+	write_unlock_bh(&bond_info->lock);
+}
+
+/**
+ * bond_l2da_call_foreach - iterates over L2DA map
+ * @bond: bonding struct to work on
+ * @clb: callback function to be called for every mapping entry found
+ * @ctx: user context to be passed to callback
+ *
+ * Callback function can return non-zero value to stop iteration.
+ */
+void bond_l2da_call_foreach(struct bonding *bond,
+		int (*clb)(const unsigned char *da, struct slave *slave,
+			   void *ctx),
+		void *ctx)
+{
+	struct l2da_bond_info *bond_info = &BOND_L2DA_INFO(bond);
+	struct l2da_bond_matrix_entry *entry;
+	int bkt;
+
+	BUG_ON(!clb);
+
+	read_lock_bh(&bond_info->lock);
+	hash_for_each(bond_info->da_matrix, bkt, entry, hnode) {
+		if (clb(entry->h_dest, entry->slave, ctx))
+			break;
+	}
+	read_unlock_bh(&bond_info->lock);
+}
+
diff --git a/drivers/net/bonding/bond_l2da.h b/drivers/net/bonding/bond_l2da.h
new file mode 100644
index 0000000..4a3b88f
--- /dev/null
+++ b/drivers/net/bonding/bond_l2da.h
@@ -0,0 +1,56 @@
+/* Copyright(c) 2013 Wilocity Ltd. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the
+ * Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
+ * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+ * for more details.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ */
+#ifndef __BOND_L2DA_H__
+#define __BOND_L2DA_H__
+
+#include <linux/list.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/hashtable.h>
+#include <linux/rwlock.h>
+
+#define BOND_L2A_HASHTABLE_BITS 3
+
+/* L2DA Exported structures to the main bonding code */
+struct l2da_bond_info {
+	DECLARE_HASHTABLE(da_matrix, BOND_L2A_HASHTABLE_BITS); /*DA:iface map*/
+	struct slave    *default_slave; /* Default slave */
+	struct slave    *fallback_slave; /* A random fallback slave to be used
+					  * in case default should be used while
+					  * it cannot transmit
+					  */
+	rwlock_t         lock;
+};
+
+/* l2DA Exported functions to the main bonding code */
+int bond_l2da_initialize(struct bonding *bond);
+void bond_l2da_deinitialize(struct bonding *bond);
+int bond_l2da_slave_init(struct bonding *bond, struct slave *slave);
+void bond_l2da_slave_deinit(struct bonding *bond, struct slave *slave);
+int bond_l2da_xmit(struct sk_buff *skb, struct net_device *dev);
+void bond_l2da_set_default_slave(struct bonding *bond, struct slave *slave);
+int bond_l2da_get_default_slave_name(struct bonding *bond, char *buf, int size);
+int bond_l2da_set_da_slave(struct bonding *bond, const unsigned char *da,
+		struct slave *slave);
+int bond_l2da_del_da(struct bonding *bond, const unsigned char *da);
+void bond_l2da_handle_link_change(struct bonding *bond, struct slave *slave);
+void bond_l2da_call_foreach(struct bonding *bond,
+		int (*clb)(const unsigned char *da,
+			   struct slave *slave, void *ctx),
+		void *ctx);
+
+#endif /* __BOND_L2DA_H__ */
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ca31286..2069584 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -25,6 +25,7 @@
 #include <linux/etherdevice.h>
 #include "bond_3ad.h"
 #include "bond_alb.h"
+#include "bond_l2da.h"
 
 #define DRV_VERSION	"3.7.1"
 #define DRV_RELDATE	"April 27, 2011"
@@ -229,6 +230,7 @@ struct bonding {
 	u32      rr_tx_counter;
 	struct   ad_bond_info ad_info;
 	struct   alb_bond_info alb_info;
+	struct   l2da_bond_info l2da_info;
 	struct   bond_params params;
 	struct   workqueue_struct *wq;
 	struct   delayed_work mii_work;
-- 
1.8.3.1
