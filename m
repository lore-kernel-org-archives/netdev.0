From: paul.moore@hp.com
Subject: [PATCH 4/7] NetLabel: core NetLabel subsystem
Date: Mon, 17 Jul 2006 11:52:28 -0400
Message-ID: <20060717155823.771011000@hp.com>
References: <20060717155224.060020000@hp.com>
Cc: davem@davemloft.net, sds@epoch.ncsc.mil, jmorris@redhat.com,
	pratt@argus-systems.com, Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:30902 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1750906AbWGQP61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2006 11:58:27 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-core
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new kernel subsystem, NetLabel, to provide explicit packet labeling 
services (CIPSO, RIPSO, etc.) to LSM developers.  NetLabel is designed to work
in conjunction with a LSM to intercept and decode security labels on incoming
network packets as well as ensure that outgoing network packets are labeled
according to the security mechanism employed by the LSM.  The NetLabel
subsystem is configured through a Generic NETLINK interface described in the
header files included in this patch.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 net/Makefile                       |    1 
 net/netlabel/Kconfig               |   14 
 net/netlabel/Makefile              |   16 
 net/netlabel/netlabel_cipso_v4.h   |  217 +++++++++++++
 net/netlabel/netlabel_domainhash.c |  504 ++++++++++++++++++++++++++++++
 net/netlabel/netlabel_domainhash.h |   63 +++
 net/netlabel/netlabel_kapi.c       |  299 +++++++++++++++++
 net/netlabel/netlabel_mgmt.c       |  615 +++++++++++++++++++++++++++++++++++++
 net/netlabel/netlabel_mgmt.h       |  249 ++++++++++++++
 net/netlabel/netlabel_unlabeled.h  |   98 +++++
 net/netlabel/netlabel_user.c       |  160 +++++++++
 net/netlabel/netlabel_user.h       |  207 ++++++++++++
 12 files changed, 2443 insertions(+)

Index: linux-2.6.18-rc2/net/Makefile
===================================================================
--- linux-2.6.18-rc2.orig/net/Makefile
+++ linux-2.6.18-rc2/net/Makefile
@@ -46,6 +46,7 @@ obj-$(CONFIG_IP_DCCP)		+= dccp/
 obj-$(CONFIG_IP_SCTP)		+= sctp/
 obj-$(CONFIG_IEEE80211)		+= ieee80211/
 obj-$(CONFIG_TIPC)		+= tipc/
+obj-$(CONFIG_NETLABEL)		+= netlabel/
 
 ifeq ($(CONFIG_NET),y)
 obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
Index: linux-2.6.18-rc2/net/netlabel/Kconfig
===================================================================
--- /dev/null
+++ linux-2.6.18-rc2/net/netlabel/Kconfig
@@ -0,0 +1,14 @@
+#
+# NetLabel configuration
+#
+
+config NETLABEL
+	bool "NetLabel subsystem support"
+	depends on NET && SECURITY
+	default n
+	---help---
+	  NetLabel provides support for explicit network packet labeling
+	  protocols such as CIPSO and RIPSO.  For more information see
+	  Documentation/netlabel.
+
+	  If you are unsure, say N.
Index: linux-2.6.18-rc2/net/netlabel/Makefile
===================================================================
--- /dev/null
+++ linux-2.6.18-rc2/net/netlabel/Makefile
@@ -0,0 +1,16 @@
+#
+# Makefile for the NetLabel subsystem.
+#
+# Feb 9, 2006, Paul Moore <paul.moore@hp.com>
+#
+
+# base objects
+obj-y	:= netlabel_user.o netlabel_kapi.o netlabel_domainhash.o
+
+# management objects
+obj-y	+= netlabel_mgmt.o
+
+# protocol modules
+obj-y	+= netlabel_unlabeled.o
+obj-y	+= netlabel_cipso_v4.o
+
Index: linux-2.6.18-rc2/net/netlabel/netlabel_cipso_v4.h
===================================================================
--- /dev/null
+++ linux-2.6.18-rc2/net/netlabel/netlabel_cipso_v4.h
@@ -0,0 +1,217 @@
+/*
+ * NetLabel CIPSO/IPv4 Support
+ *
+ * This file defines the CIPSO/IPv4 functions for the NetLabel system.  The
+ * NetLabel system manages static and dynamic label mappings for network
+ * protocols such as CIPSO and RIPSO.
+ *
+ * Author: Paul Moore <paul.moore@hp.com>
+ *
+ */
+
+/*
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+
+#ifndef _NETLABEL_CIPSO_V4
+#define _NETLABEL_CIPSO_V4
+
+#include <net/netlabel.h>
+
+/*
+ * The following NetLabel payloads are supported by the CIPSO subsystem, all
+ * of which are preceeded by the nlmsghdr struct.
+ *
+ * o ACK:
+ *   Sent by the kernel in response to an applications message, applications
+ *   should never send this message.
+ *
+ *   +----------------------+-----------------------+
+ *   | seq number (32 bits) | return code (32 bits) |
+ *   +----------------------+-----------------------+
+ *
+ *     seq number:  the sequence number of the original message, taken from the
+ *                  nlmsghdr structure
+ *     return code: return value, based on errno values
+ *
+ * o ADD:
+ *   Sent by an application to add a new DOI mapping table, after completion
+ *   of the task the kernel should ACK this message.
+ *
+ *   +---------------+--------------------+---------------------+
+ *   | DOI (32 bits) | map type (32 bits) | tag count (32 bits) | ...
+ *   +---------------+--------------------+---------------------+
+ *
+ *   +-----------------+
+ *   | tag #X (8 bits) | ... repeated
+ *   +-----------------+
+ *
+ *   +-------------- ---- --- -- -
+ *   | mapping data
+ *   +-------------- ---- --- -- -
+ *
+ *     DOI:          the DOI value
+ *     map type:     the mapping table type (defined in the cipso_ipv4.h header
+ *                   as CIPSO_V4_MAP_*)
+ *     tag count:    the number of tags, must be greater than zero
+ *     tag:          the CIPSO tag for the DOI, tags listed first are given
+ *                   higher priorirty when sending packets
+ *     mapping data: specific to the map type (see below)
+ *
+ *   CIPSO_V4_MAP_STD
+ *
+ *   +------------------+-----------------------+----------------------+
+ *   | levels (32 bits) | max l level (32 bits) | max r level (8 bits) | ...
+ *   +------------------+-----------------------+----------------------+
+ *
+ *   +----------------------+---------------------+---------------------+
+ *   | categories (32 bits) | max l cat (32 bits) | max r cat (16 bits) | ...
+ *   +----------------------+---------------------+---------------------+
+ *
+ *   +--------------------------+-------------------------+
+ *   | local level #X (32 bits) | CIPSO level #X (8 bits) | ... repeated
+ *   +--------------------------+-------------------------+
+ *
+ *   +-----------------------------+-----------------------------+
+ *   | local category #X (32 bits) | CIPSO category #X (16 bits) | ... repeated
+ *   +-----------------------------+-----------------------------+
+ *
+ *     levels:         the number of level mappings
+ *     max l level:    the highest local level
+ *     max r level:    the highest remote/CIPSO level
+ *     categories:     the number of category mappings
+ *     max l cat:      the highest local category
+ *     max r cat:      the highest remote/CIPSO category
+ *     local level:    the local part of a level mapping
+ *     CIPSO level:    the remote/CIPSO part of a level mapping
+ *     local category: the local part of a category mapping
+ *     CIPSO category: the remote/CIPSO part of a category mapping
+ *
+ *   CIPSO_V4_MAP_PASS
+ *
+ *   No mapping data is needed for this map type.
+ *
+ * o REMOVE:
+ *   Sent by an application to remove a specific DOI mapping table from the
+ *   CIPSO V4 system.  The kernel should ACK this message.
+ *
+ *   +---------------+
+ *   | DOI (32 bits) |
+ *   +---------------+
+ *
+ *     DOI:          the DOI value
+ *
+ * o LIST:
+ *   Sent by an application to list the details of a DOI definition.  The
+ *   kernel should send an ACK on error or a response as indicated below.  The
+ *   application generated message format is shown below.
+ *
+ *   +---------------+
+ *   | DOI (32 bits) |
+ *   +---------------+
+ *
+ *     DOI:          the DOI value
+ *
+ *   The valid response message format depends on the type of the DOI mapping,
+ *   the known formats are shown below.
+ *
+ *   +--------------------+
+ *   | map type (32 bits) | ...
+ *   +--------------------+
+ *
+ *     map type:       the DOI mapping table type (defined in the cipso_ipv4.h
+ *                     header as CIPSO_V4_MAP_*)
+ *
+ *   (map type == CIPSO_V4_MAP_STD)
+ *
+ *   +----------------+------------------+----------------------+
+ *   | tags (32 bits) | levels (32 bits) | categories (32 bits) | ...
+ *   +----------------+------------------+----------------------+
+ *
+ *   +-----------------+
+ *   | tag #X (8 bits) | ... repeated
+ *   +-----------------+
+ *
+ *   +--------------------------+-------------------------+
+ *   | local level #X (32 bits) | CIPSO level #X (8 bits) | ... repeated
+ *   +--------------------------+-------------------------+
+ *
+ *   +-----------------------------+-----------------------------+
+ *   | local category #X (32 bits) | CIPSO category #X (16 bits) | ... repeated
+ *   +-----------------------------+-----------------------------+
+ *
+ *     tags:           the number of CIPSO tag types
+ *     levels:         the number of level mappings
+ *     categories:     the number of category mappings
+ *     tag:            the tag number, tags listed first are given higher
+ *                     priority when sending packets
+ *     local level:    the local part of a level mapping
+ *     CIPSO level:    the remote/CIPSO part of a level mapping
+ *     local category: the local part of a category mapping
+ *     CIPSO category: the remote/CIPSO part of a category mapping
+ *
+ *   (map type == CIPSO_V4_MAP_PASS)
+ *
+ *   +----------------+
+ *   | tags (32 bits) | ...
+ *   +----------------+
+ *
+ *   +-----------------+
+ *   | tag #X (8 bits) | ... repeated
+ *   +-----------------+
+ *
+ *     tags:           the number of CIPSO tag types
+ *     tag:            the tag number, tags listed first are given higher
+ *                     priority when sending packets
+ *
+ * o LISTALL:
+ *   This message is sent by an application to list the valid DOIs on the
+ *   system.  There is no payload and the kernel should respond with an ACK
+ *   or the following message.
+ *
+ *   +---------------------+------------------+-----------------------+
+ *   | DOI count (32 bits) | DOI #X (32 bits) | map type #X (32 bits) |
+ *   +---------------------+------------------+-----------------------+
+ *
+ *   +-----------------------+
+ *   | map type #X (32 bits) | ...
+ *   +-----------------------+
+ *
+ *     DOI count:      the number of DOIs
+ *     DOI:            the DOI value
+ *     map type:       the DOI mapping table type (defined in the cipso_ipv4.h
+ *                     header as CIPSO_V4_MAP_*)
+ *
+ */
+
+/* NetLabel CIPSOv4 commands */
+enum {
+	NLBL_CIPSOV4_C_UNSPEC,
+	NLBL_CIPSOV4_C_ACK,
+	NLBL_CIPSOV4_C_ADD,
+	NLBL_CIPSOV4_C_REMOVE,
+	NLBL_CIPSOV4_C_LIST,
+	NLBL_CIPSOV4_C_LISTALL,
+	__NLBL_CIPSOV4_C_MAX,
+};
+#define NLBL_CIPSOV4_C_MAX (__NLBL_CIPSOV4_C_MAX - 1)
+
+/* NetLabel protocol functions */
+int netlbl_cipsov4_genl_init(void);
+
+#endif
Index: linux-2.6.18-rc2/net/netlabel/netlabel_domainhash.c
===================================================================
--- /dev/null
+++ linux-2.6.18-rc2/net/netlabel/netlabel_domainhash.c
@@ -0,0 +1,504 @@
+/*
+ * NetLabel Domain Hash Table
+ *
+ * This file manages the domain hash table that NetLabel uses to determine
+ * which network labeling protocol to use for a given domain.  The NetLabel
+ * system manages static and dynamic label mappings for network protocols such
+ * as CIPSO and RIPSO.
+ *
+ * Author: Paul Moore <paul.moore@hp.com>
+ *
+ */
+
+/*
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+
+#include <linux/types.h>
+#include <linux/rcupdate.h>
+#include <linux/list.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/string.h>
+#include <net/netlabel.h>
+#include <net/cipso_ipv4.h>
+#include <asm/bug.h>
+
+#include "netlabel_mgmt.h"
+#include "netlabel_domainhash.h"
+
+struct netlbl_domhsh_tbl {
+	struct list_head *tbl;
+	u32 size;
+};
+
+/* Domain hash table */
+/* XXX - updates should be so rare that having one spinlock for the entire
+ * hash table should be okay */
+DEFINE_SPINLOCK(netlbl_domhsh_lock);
+static struct netlbl_domhsh_tbl *netlbl_domhsh = NULL;
+
+/* Default domain mapping */
+DEFINE_SPINLOCK(netlbl_domhsh_def_lock);
+static struct netlbl_dom_map *netlbl_domhsh_def = NULL;
+
+/*
+ * Domain Hash Table Helper Functions
+ */
+
+/**
+ * netlbl_domhsh_free_entry - Frees a domain hash table entry
+ * @entry: the entry's RCU field
+ *
+ * Description:
+ * This function is designed to be used as a callback to the call_rcu()
+ * function so that the memory allocated to a hash table entry can be released
+ * safely.
+ *
+ */
+static void netlbl_domhsh_free_entry(struct rcu_head *entry)
+{
+	struct netlbl_dom_map *ptr;
+
+	ptr = container_of(entry, struct netlbl_dom_map, rcu);
+	kfree(ptr->domain);
+	kfree(ptr);
+}
+
+/**
+ * netlbl_domhsh_hash - Hashing function for the domain hash table
+ * @domain: the domain name to hash
+ *
+ * Description:
+ * This is the hashing function for the domain hash table, it returns the
+ * correct bucket number for the domain.  The caller is responsibile for
+ * calling the rcu_read_[un]lock() functions.
+ *
+ */
+static u32 netlbl_domhsh_hash(const char *key)
+{
+	u32 iter;
+	u32 val;
+	u32 len;
+
+	/* This is taken (with slight modification) from
+	 * security/selinux/ss/symtab.c:symhash() */
+
+	for (iter = 0, val = 0, len = strlen(key); iter < len; iter++)
+		val = (val << 4 | (val >> (8 * sizeof(u32) - 4))) ^ key[iter];
+	return val & (rcu_dereference(netlbl_domhsh)->size - 1);
+}
+
+/**
+ * netlbl_domhsh_search - Search for a domain entry
+ * @domain: the domain
+ * @def: return default if no match is found
+ *
+ * Description:
+ * Searches the domain hash table and returns a pointer to the hash table
+ * entry if found, otherwise NULL is returned.  If @def is non-zero and a
+ * match is not found in the domain hash table the default mapping is returned
+ * if it exists.  The caller is responsibile for the rcu hash table locks
+ * (i.e. the caller much call rcu_read_[un]lock()).
+ *
+ */
+static struct netlbl_dom_map *netlbl_domhsh_search(const char *domain, u32 def)
+{
+	u32 bkt;
+	struct netlbl_dom_map *iter;
+
+	if (domain != NULL) {
+		bkt = netlbl_domhsh_hash(domain);
+		list_for_each_entry_rcu(iter, &netlbl_domhsh->tbl[bkt], list)
+			if (iter->valid && strcmp(iter->domain, domain) == 0)
+				return iter;
+	}
+
+	if (def != 0) {
+		iter = rcu_dereference(netlbl_domhsh_def);
+		if (iter != NULL && iter->valid)
+			return iter;
+	}
+
+	return NULL;
+}
+
+/*
+ * Domain Hash Table Functions
+ */
+
+/**
+ * netlbl_domhsh_init - Init for the domain hash
+ * @size: the number of bits to use for the hash buckets
+ *
+ * Description:
+ * Initializes the domain hash table, should be called only by
+ * netlbl_user_init() during initialization.  Returns zero on success, non-zero
+ * values on error.
+ *
+ */
+int netlbl_domhsh_init(u32 size)
+{
+	u32 iter;
+	struct netlbl_domhsh_tbl *hsh_tbl;
+
+	if (size == 0)
+		return -EINVAL;
+
+	hsh_tbl = kmalloc(sizeof(*hsh_tbl), GFP_KERNEL);
+	if (hsh_tbl == NULL)
+		return -ENOMEM;
+	hsh_tbl->size = 1 << size;
+	hsh_tbl->tbl = kcalloc(hsh_tbl->size,
+			       sizeof(struct list_head),
+			       GFP_KERNEL);
+	if (hsh_tbl->tbl == NULL) {
+		kfree(hsh_tbl);
+		return -ENOMEM;
+	}
+	for (iter = 0; iter < hsh_tbl->size; iter++)
+		INIT_LIST_HEAD(&hsh_tbl->tbl[iter]);
+
+	rcu_read_lock();
+	spin_lock(&netlbl_domhsh_lock);
+	rcu_assign_pointer(netlbl_domhsh, hsh_tbl);
+	spin_unlock(&netlbl_domhsh_lock);
+	rcu_read_unlock();
+
+	return 0;
+}
+
+/**
+ * netlbl_domhsh_add - Adds a entry to the domain hash table
+ * @entry: the entry to add
+ *
+ * Description:
+ * Adds a new entry to the domain hash table and handles any updates to the
+ * lower level protocol handler (i.e. CIPSO).  Returns zero on success,
+ * negative on failure.
+ *
+ */
+int netlbl_domhsh_add(struct netlbl_dom_map *entry)
+{
+	int ret_val;
+	u32 bkt;
+
+	switch (entry->type) {
+	case NETLBL_NLTYPE_UNLABELED:
+		ret_val = 0;
+		break;
+	case NETLBL_NLTYPE_CIPSOV4:
+		ret_val = cipso_v4_doi_domhsh_add(entry->type_def.cipsov4,
+						  entry->domain);
+		break;
+	default:
+		return -EINVAL;
+	}
+	if (ret_val != 0)
+		return ret_val;
+
+	entry->valid = 1;
+	INIT_RCU_HEAD(&entry->rcu);
+
+	ret_val = 0;
+	rcu_read_lock();
+	if (entry->domain != NULL) {
+		bkt = netlbl_domhsh_hash(entry->domain);
+		spin_lock(&netlbl_domhsh_lock);
+		if (netlbl_domhsh_search(entry->domain, 0) == NULL)
+			list_add_tail_rcu(&entry->list,
+					  &netlbl_domhsh->tbl[bkt]);
+		else
+			ret_val = -EEXIST;
+		spin_unlock(&netlbl_domhsh_lock);
+	} else if (entry->domain == NULL) {
+		INIT_LIST_HEAD(&entry->list);
+		spin_lock(&netlbl_domhsh_def_lock);
+		if (rcu_dereference(netlbl_domhsh_def) == NULL)
+			rcu_assign_pointer(netlbl_domhsh_def, entry);
+		else
+			ret_val = -EEXIST;
+		spin_unlock(&netlbl_domhsh_def_lock);
+	} else
+		ret_val = -EINVAL;
+	rcu_read_unlock();
+
+	if (ret_val != 0) {
+		switch (entry->type) {
+		case NETLBL_NLTYPE_CIPSOV4:
+			if (cipso_v4_doi_domhsh_remove(entry->type_def.cipsov4,
+						       entry->domain) != 0)
+				BUG();
+			break;
+		}
+	}
+
+	return ret_val;
+}
+
+/**
+ * netlbl_domhsh_add_default - Adds the default entry to the domain hash table
+ * @entry: the entry to add
+ *
+ * Description:
+ * Adds a new default entry to the domain hash table and handles any updates
+ * to the lower level protocol handler (i.e. CIPSO).  Returns zero on success,
+ * negative on failure.
+ *
+ */
+int netlbl_domhsh_add_default(struct netlbl_dom_map *entry)
+{
+	return netlbl_domhsh_add(entry);
+}
+
+/**
+ * netlbl_domhsh_remove - Removes an entry from the domain hash table
+ * @domain: the domain to remove
+ *
+ * Description:
+ * Removes an entry from the domain hash table and handles any updates to the
+ * lower level protocol handler (i.e. CIPSO).  Returns zero on success,
+ * negative on failure.
+ *
+ */
+int netlbl_domhsh_remove(const char *domain)
+{
+	int ret_val = -ENOENT;
+	struct netlbl_dom_map *entry;
+
+	rcu_read_lock();
+	if (domain != NULL)
+		entry = netlbl_domhsh_search(domain, 0);
+	else
+		entry = netlbl_domhsh_search(domain, 1);
+	if (entry == NULL)
+		goto remove_return;
+	switch (entry->type) {
+	case NETLBL_NLTYPE_UNLABELED:
+		break;
+	case NETLBL_NLTYPE_CIPSOV4:
+		ret_val = cipso_v4_doi_domhsh_remove(entry->type_def.cipsov4,
+						     entry->domain);
+		if (ret_val != 0)
+			goto remove_return;
+		break;
+	}
+	ret_val = 0;
+	if (entry != rcu_dereference(netlbl_domhsh_def)) {
+		spin_lock(&netlbl_domhsh_lock);
+		if (entry->valid) {
+			entry->valid = 0;
+			list_del_rcu(&entry->list);
+		} else
+			ret_val = -ENOENT;
+		spin_unlock(&netlbl_domhsh_lock);
+	} else {
+		spin_lock(&netlbl_domhsh_def_lock);
+		if (entry->valid) {
+			entry->valid = 0;
+			rcu_assign_pointer(netlbl_domhsh_def, NULL);
+		} else
+			ret_val = -ENOENT;
+		spin_unlock(&netlbl_domhsh_def_lock);
+	}
+	if (ret_val == 0)
+		call_rcu(&entry->rcu, netlbl_domhsh_free_entry);
+
+remove_return:
+	rcu_read_unlock();
+	return ret_val;
+}
+
+/**
+ * netlbl_domhsh_remove_default - Removes the default entry from the table
+ *
+ * Description:
+ * Removes/resets the default entry for the domain hash table and handles any
+ * updates to the lower level protocol handler (i.e. CIPSO).  Returns zero on
+ * success, non-zero on failure.
+ *
+ */
+int netlbl_domhsh_remove_default(void)
+{
+	return netlbl_domhsh_remove(NULL);
+}
+
+/**
+ * netlbl_domhsh_getentry - Get an entry from the domain hash table
+ * @domain: the domain name to search for
+ *
+ * Description:
+ * Look through the domain hash table searching for an entry to match @domain,
+ * return a pointer to a copy of the entry or NULL.  The caller is responsibile
+ * for ensuring that rcu_read_[un]lock() is called.
+ *
+ */
+struct netlbl_dom_map *netlbl_domhsh_getentry(const char *domain)
+{
+	return netlbl_domhsh_search(domain, 1);
+}
+
+/**
+ * netlbl_domhsh_dump - Dump the domain hash table into a sk_buff
+ *
+ * Description:
+ * Dump the domain hash table into a buffer suitable for returning to an
+ * application in response to a NetLabel management DOMAIN message.  This
+ * function may fail if another process is growing the hash table at the same
+ * time.  The returned sk_buff has room at the front of the sk_buff for
+ * @headroom bytes.  See netlabel.h for the DOMAIN message format.  Returns a
+ * pointer to a sk_buff on success, NULL on error.
+ *
+ */
+struct sk_buff *netlbl_domhsh_dump(size_t headroom)
+{
+	struct sk_buff *skb = NULL;
+	unsigned char *buf;
+	ssize_t buf_len;
+	u32 bkt_iter;
+	u32 dom_cnt = 0;
+	struct netlbl_domhsh_tbl *hsh_tbl;
+	struct netlbl_dom_map *list_iter;
+	ssize_t tmp_len;
+
+	buf_len = NETLBL_LEN_U32;
+	rcu_read_lock();
+	hsh_tbl = rcu_dereference(netlbl_domhsh);
+	for (bkt_iter = 0; bkt_iter < hsh_tbl->size; bkt_iter++)
+		list_for_each_entry_rcu(list_iter,
+					&hsh_tbl->tbl[bkt_iter], list) {
+			buf_len += 2 * NETLBL_LEN_U32 +
+				netlbl_align(strlen(list_iter->domain) + 1);
+			switch (list_iter->type) {
+			case NETLBL_NLTYPE_UNLABELED:
+				break;
+			case NETLBL_NLTYPE_CIPSOV4:
+				buf_len += 2 * NETLBL_LEN_U32;
+				break;
+			}
+			dom_cnt++;
+		}
+
+	skb = netlbl_netlink_alloc_skb(headroom, buf_len, GFP_ATOMIC);
+	if (skb == NULL)
+		goto dump_failure;
+	buf = skb_put(skb, buf_len);
+
+	netlbl_putinc_u32(&buf, dom_cnt, &buf_len);
+	hsh_tbl = rcu_dereference(netlbl_domhsh);
+	for (bkt_iter = 0; bkt_iter < hsh_tbl->size; bkt_iter++)
+		list_for_each_entry_rcu(list_iter,
+					&hsh_tbl->tbl[bkt_iter], list) {
+			tmp_len = netlbl_align(strlen(list_iter->domain) + 1);
+			if (buf_len < 2 * NETLBL_LEN_U32 + tmp_len)
+				goto dump_failure;
+			netlbl_putinc_u32(&buf, tmp_len, &buf_len);
+			netlbl_putinc_str(&buf, list_iter->domain, &buf_len);
+			netlbl_putinc_u32(&buf, list_iter->type, &buf_len);
+			switch (list_iter->type) {
+			case NETLBL_NLTYPE_UNLABELED:
+				break;
+			case NETLBL_NLTYPE_CIPSOV4:
+				if (buf_len < 2 * NETLBL_LEN_U32)
+					goto dump_failure;
+				netlbl_putinc_u32(
+					&buf,
+					list_iter->type_def.cipsov4->type,
+					&buf_len);
+				netlbl_putinc_u32(
+					&buf,
+					list_iter->type_def.cipsov4->doi,
+					&buf_len);
+				break;
+			}
+		}
+	rcu_read_unlock();
+
+	return skb;
+
+dump_failure:
+	rcu_read_unlock();
+	kfree_skb(skb);
+	return NULL;
+}
+
+/**
+ * netlbl_domhsh_dump_default - Dump the default domain mapping into a sk_buff
+ *
+ * Description:
+ * Dump the default domain mapping into a buffer suitable for returning to an
+ * application in response to a NetLabel management DEFDOMAIN message.  This
+ * function may fail if another process is changing the default domain mapping
+ * at the same time.  The returned sk_buff has room at the front of the
+ * skb_buff for @headroom bytes.  See netlabel.h for the DEFDOMAIN message
+ * format.  Returns a pointer to a sk_buff on success, NULL on error.
+ *
+ */
+struct sk_buff *netlbl_domhsh_dump_default(size_t headroom)
+{
+	struct sk_buff *skb;
+	unsigned char *buf;
+	ssize_t buf_len;
+	struct netlbl_dom_map *entry;
+
+	buf_len = NETLBL_LEN_U32;
+	rcu_read_lock();
+	entry = rcu_dereference(netlbl_domhsh_def);
+	if (entry != NULL)
+		switch (entry->type) {
+		case NETLBL_NLTYPE_UNLABELED:
+			break;
+		case NETLBL_NLTYPE_CIPSOV4:
+			buf_len += 2 * NETLBL_LEN_U32;
+			break;
+		}
+
+	skb = netlbl_netlink_alloc_skb(headroom, buf_len, GFP_ATOMIC);
+	if (skb == NULL)
+		goto dump_default_failure;
+	buf = skb_put(skb, buf_len);
+
+	if (entry != rcu_dereference(netlbl_domhsh_def))
+		goto dump_default_failure;
+	if (entry != NULL) {
+		netlbl_putinc_u32(&buf, entry->type, &buf_len);
+		switch (entry->type) {
+		case NETLBL_NLTYPE_UNLABELED:
+			break;
+		case NETLBL_NLTYPE_CIPSOV4:
+			if (buf_len < 2 * NETLBL_LEN_U32)
+				goto dump_default_failure;
+			netlbl_putinc_u32(&buf,
+					  entry->type_def.cipsov4->type,
+					  &buf_len);
+			netlbl_putinc_u32(&buf,
+					  entry->type_def.cipsov4->doi,
+					  &buf_len);
+			break;
+		}
+	} else
+		netlbl_putinc_u32(&buf, NETLBL_NLTYPE_NONE, &buf_len);
+	rcu_read_unlock();
+
+	return skb;
+
+dump_default_failure:
+	rcu_read_unlock();
+	kfree_skb(skb);
+	return NULL;
+}
Index: linux-2.6.18-rc2/net/netlabel/netlabel_domainhash.h
===================================================================
--- /dev/null
+++ linux-2.6.18-rc2/net/netlabel/netlabel_domainhash.h
@@ -0,0 +1,63 @@
+/*
+ * NetLabel Domain Hash Table
+ *
+ * This file manages the domain hash table that NetLabel uses to determine
+ * which network labeling protocol to use for a given domain.  The NetLabel
+ * system manages static and dynamic label mappings for network protocols such
+ * as CIPSO and RIPSO.
+ *
+ * Author: Paul Moore <paul.moore@hp.com>
+ *
+ */
+
+/*
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+
+#ifndef _NETLABEL_DOMAINHASH_H
+#define _NETLABEL_DOMAINHASH_H
+
+/* Domain hash table size */
+/* XXX - currently this number is an uneducated guess */
+#define NETLBL_DOMHSH_BITSIZE       7
+
+/* Domain mapping definition struct */
+struct netlbl_dom_map {
+	char *domain;
+	u32 type;
+	union {
+		struct cipso_v4_doi *cipsov4;
+	} type_def;
+
+	u32 valid;
+	struct list_head list;
+	struct rcu_head rcu;
+};
+
+/* init function */
+int netlbl_domhsh_init(u32 size);
+
+/* Manipulate the domain hash table */
+int netlbl_domhsh_add(struct netlbl_dom_map *entry);
+int netlbl_domhsh_add_default(struct netlbl_dom_map *entry);
+int netlbl_domhsh_remove_default(void);
+struct netlbl_dom_map *netlbl_domhsh_getentry(const char *domain);
+struct sk_buff *netlbl_domhsh_dump(size_t headroom);
+struct sk_buff *netlbl_domhsh_dump_default(size_t headroom);
+
+#endif
Index: linux-2.6.18-rc2/net/netlabel/netlabel_kapi.c
===================================================================
--- /dev/null
+++ linux-2.6.18-rc2/net/netlabel/netlabel_kapi.c
@@ -0,0 +1,299 @@
+/*
+ * NetLabel Kernel API
+ *
+ * This file defines the kernel API for the NetLabel system.  The NetLabel
+ * system manages static and dynamic label mappings for network protocols such
+ * as CIPSO and RIPSO.
+ *
+ * Author: Paul Moore <paul.moore@hp.com>
+ *
+ */
+
+/*
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+
+#include <linux/init.h>
+#include <linux/types.h>
+#include <net/ip.h>
+#include <net/netlabel.h>
+#include <net/cipso_ipv4.h>
+#include <asm/bug.h>
+
+#include "netlabel_domainhash.h"
+#include "netlabel_unlabeled.h"
+#include "netlabel_user.h"
+
+/*
+ * LSM Functions
+ */
+
+/**
+ * netlbl_socket_setattr - Label a socket using the correct protocol
+ * @sock: the socket to label
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Attach the correct label to the given socket using the security attributes
+ * specified in @secattr.  Returns zero on success, negative values on failure.
+ *
+ */
+int netlbl_socket_setattr(const struct socket *sock,
+			  const struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val = -ENOENT;
+	struct netlbl_dom_map *dom_entry;
+
+	rcu_read_lock();
+	dom_entry = netlbl_domhsh_getentry(secattr->domain);
+	if (dom_entry == NULL)
+		goto socket_setattr_return;
+	switch (dom_entry->type) {
+	case NETLBL_NLTYPE_CIPSOV4:
+		ret_val = cipso_v4_socket_setattr(sock,
+						  dom_entry->type_def.cipsov4,
+						  secattr);
+		break;
+	case NETLBL_NLTYPE_UNLABELED:
+		ret_val = 0;
+		break;
+	default:
+		ret_val = -ENOENT;
+	}
+
+socket_setattr_return:
+	rcu_read_unlock();
+	return ret_val;
+}
+
+/**
+ * netlbl_socket_peekattr - Get the security attributes on a queued packet
+ * @sock: the socket
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Peek at the incoming packet queue of @sock and return the security
+ * attributes of the first packet in the queue.  If there are no packets in
+ * the queue or no packets with security attributes return -ENOMSG.  Otherwise
+ * return zero on success, negative values on failure.
+ *
+ */
+int netlbl_socket_peekattr(const struct socket *sock,
+			   struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val;
+	struct sk_buff_head *sock_queue;
+	struct sk_buff *skb;
+	struct sk_buff *skb_tmp = NULL;
+
+	sock_queue = &sock->sk->sk_receive_queue;
+	/* We could just take the lock here and do a skb_peek() but we might
+	 * end up holding the lock for a long time so grab the lock, do a
+	 * peek, and clone the result */
+	spin_lock(&sock_queue->lock);
+	skb = skb_peek(sock_queue);
+	if (skb != NULL)
+		skb_tmp = skb_clone(skb, GFP_ATOMIC);
+	spin_unlock(&sock_queue->lock);
+	if (skb_tmp != NULL) {
+		ret_val = netlbl_skbuff_getattr(skb_tmp, secattr);
+		kfree_skb(skb_tmp);
+	} else
+		ret_val = -ENOMEM;
+
+	return ret_val;
+}
+
+/**
+ * netlbl_socket_getattr - Determine the security attributes of a socket
+ * @sock: the socket
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Examines the given socket to see any NetLabel style labeling has been
+ * applied to the socket, if so it parses the socket label and returns the
+ * security attributes in @secattr.  Returns zero on success, negative values
+ * on failure.
+ *
+ */
+int netlbl_socket_getattr(const struct socket *sock,
+			  struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val;
+
+	ret_val = cipso_v4_socket_getattr(sock, secattr);
+	if (ret_val == 0)
+		return 0;
+
+	return netlbl_unlabel_getattr(secattr);
+}
+
+/**
+ * netlbl_skbuff_getattr - Determine the security attributes of a packet
+ * @skb: the packet
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Examines the given packet to see if a recognized form of packet labeling
+ * is present, if so it parses the packet label and returns the security
+ * attributes in @secattr.  Returns zero on success, negative values on
+ * failure.
+ *
+ */
+int netlbl_skbuff_getattr(const struct sk_buff *skb,
+			  struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val;
+
+	ret_val = cipso_v4_skbuff_getattr(skb, secattr);
+	if (ret_val == 0)
+		return 0;
+
+	return netlbl_unlabel_getattr(secattr);
+}
+
+/**
+ * netlbl_skbuff_err - Handle a LSM error on a sk_buff
+ * @skb: the packet
+ * @error: the error code
+ *
+ * Description:
+ * Deal with a LSM problem when handling the packet in @skb, typically this is
+ * a permission denied problem (-EACCES).  The correct action is determined
+ * according to the packet's labeling protocol.
+ *
+ */
+void netlbl_skbuff_err(struct sk_buff *skb, int error)
+{
+	if (CIPSO_V4_OPTEXIST(skb))
+		cipso_v4_error(skb, error, 0);
+}
+
+/**
+ * netlbl_cache_invalidate - Invalidate all of the NetLabel protocol caches
+ *
+ * Description:
+ * For all of the NetLabel protocols that support some form of label mapping
+ * cache, invalidate the cache.  Returns zero on success, negative values on
+ * error.
+ *
+ */
+void netlbl_cache_invalidate(void)
+{
+	cipso_v4_cache_invalidate();
+}
+
+/**
+ * netlbl_cache_add - Add an entry to a NetLabel protocol cache
+ * @skb: the packet
+ * @secattr: the packet's security attributes
+ *
+ * Description:
+ * Add the LSM security attributes for the given packet to the underlying
+ * NetLabel protocol's label mapping cache.  Returns zero on success, negative
+ * values on error.
+ *
+ */
+int netlbl_cache_add(const struct sk_buff *skb,
+		     const struct netlbl_lsm_secattr *secattr)
+{
+	if (secattr->cache.data == NULL)
+		return -ENOMSG;
+
+	if (CIPSO_V4_OPTEXIST(skb))
+		return cipso_v4_cache_add(skb, secattr);
+
+	return -ENOMSG;
+}
+
+/*
+ * Network Stack Functions
+ */
+
+/**
+ * netlbl_socket_inet_accept - Preserve the NetLabel across an accept()
+ * @sock: the old socket
+ * @newsock: the new socket
+ *
+ * Description:
+ * For kernel threads only, clear the NetLabel from @newsock and copy the
+ * NetLabel from @sock.  The caller is responsibile for locking and releasing
+ * the sockets.
+ *
+ */
+void netlbl_socket_inet_accept(struct socket *sock, struct socket *newsock)
+{
+	unsigned char *opt;
+	u32 opt_len;
+
+	/* We are only interested in preserving the NetLabel on kernel
+	 * threads across an accept, the LSM should handle user level
+	 * accept calls. */
+	if (current->mm)
+		return;
+
+	if (cipso_v4_socket_getopt(sock, &opt, &opt_len) == 0 &&
+	    cipso_v4_socket_setopt(newsock, opt, opt_len) != 0)
+		printk(KERN_ERR
+		       "NetLabel: failed to set the CIPSOv4 option on a kernel"
+		       " socket\n");
+}
+
+/*
+ * Setup Functions
+ */
+
+/**
+ * netlbl_init - Initialize NetLabel
+ *
+ * Description:
+ * Perform the required NetLabel initialization before first use.
+ *
+ */
+static int __init netlbl_init(void)
+{
+	int ret_val;
+
+	printk(KERN_INFO "NetLabel: Initializing\n");
+	printk(KERN_INFO "NetLabel:  domain hash size = %u\n",
+	       (1 << NETLBL_DOMHSH_BITSIZE));
+	printk(KERN_INFO "NetLabel:  protocols ="
+	       " UNLABELED"
+	       " CIPSOv4"
+	       "\n");
+
+	ret_val = netlbl_domhsh_init(NETLBL_DOMHSH_BITSIZE);
+	if (ret_val != 0)
+		goto init_failure;
+
+	ret_val = netlbl_netlink_init();
+	if (ret_val != 0)
+		goto init_failure;
+
+	ret_val = netlbl_unlabel_defconf();
+	if (ret_val != 0)
+		goto init_failure;
+	printk(KERN_INFO "NetLabel:  unlabeled traffic allowed by default\n");
+
+	return 0;
+
+init_failure:
+	panic("NetLabel: failed to initialize properly (%d)\n", ret_val);
+}
+
+subsys_initcall(netlbl_init);
Index: linux-2.6.18-rc2/net/netlabel/netlabel_mgmt.c
===================================================================
--- /dev/null
+++ linux-2.6.18-rc2/net/netlabel/netlabel_mgmt.c
@@ -0,0 +1,615 @@
+/*
+ * NetLabel Management Support
+ *
+ * This file defines the management functions for the NetLabel system.  The
+ * NetLabel system manages static and dynamic label mappings for network
+ * protocols such as CIPSO and RIPSO.
+ *
+ * Author: Paul Moore <paul.moore@hp.com>
+ *
+ */
+
+/*
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+
+#include <linux/types.h>
+#include <linux/socket.h>
+#include <linux/string.h>
+#include <linux/skbuff.h>
+#include <net/sock.h>
+#include <net/netlink.h>
+#include <net/genetlink.h>
+#include <net/netlabel.h>
+#include <net/cipso_ipv4.h>
+
+#include "netlabel_domainhash.h"
+#include "netlabel_user.h"
+#include "netlabel_mgmt.h"
+
+/* NetLabel Generic NETLINK CIPSOv4 family */
+static struct genl_family netlbl_mgmt_gnl_family = {
+	.id = GENL_ID_GENERATE,
+	.hdrsize = 0,
+	.name = NETLBL_NLTYPE_MGMT_NAME,
+	.version = NETLBL_PROTO_VERSION,
+	.maxattr = 0,
+};
+
+
+/*
+ * NetLabel Command Handlers
+ */
+
+/**
+ * netlbl_mgmt_add - Handle an ADD message
+ * @skb: the NETLINK buffer
+ * @info: the Generic NETLINK info block
+ *
+ * Description:
+ * Process a user generated ADD message and add the domains from the message
+ * to the hash table.  See netlabel.h for a description of the message format.
+ * Returns zero on success, negative values on failure.
+ *
+ */
+static int netlbl_mgmt_add(struct sk_buff *skb, struct genl_info *info)
+{
+	int ret_val;
+	unsigned char *msg_ptr = netlbl_netlink_payload_data(skb);
+	ssize_t msg_len = netlbl_netlink_payload_len(skb);
+	u32 count;
+	struct netlbl_dom_map *entry = NULL;
+	u32 iter;
+	u32 tmp_val;
+
+	ret_val = netlbl_netlink_cap_check(skb, CAP_NET_ADMIN);
+	if (ret_val != 0)
+		goto add_failure;
+
+	if (msg_len < NETLBL_LEN_U32)
+		goto add_failure;
+	count = netlbl_getinc_u32(&msg_ptr, &msg_len);
+
+	for (iter = 0; iter < count && msg_len > 0; iter++, entry = NULL) {
+		if (msg_len < NETLBL_LEN_U32)
+			goto add_failure;
+		tmp_val = netlbl_getinc_u32(&msg_ptr, &msg_len);
+		if (tmp_val == 0)
+			goto add_failure;
+		entry = kzalloc(sizeof(*entry), GFP_KERNEL);
+		if (entry == NULL) {
+			ret_val = -ENOMEM;
+			goto add_failure;
+		}
+
+		if (msg_len < netlbl_align(tmp_val))
+			goto add_failure;
+		entry->domain = kmalloc(tmp_val, GFP_KERNEL);
+		if (entry->domain == NULL) {
+			ret_val = -ENOMEM;
+			goto add_failure;
+		}
+		strncpy(entry->domain, msg_ptr, tmp_val);
+		entry->domain[tmp_val - 1] = '\0';
+		msg_ptr += netlbl_align(tmp_val);
+		msg_len -= netlbl_align(tmp_val);
+
+		if (msg_len < NETLBL_LEN_U32)
+			goto add_failure;
+		tmp_val = netlbl_getinc_u32(&msg_ptr, &msg_len);
+		entry->type = tmp_val;
+		switch (tmp_val) {
+		case NETLBL_NLTYPE_UNLABELED:
+			ret_val = netlbl_domhsh_add(entry);
+			break;
+		case NETLBL_NLTYPE_CIPSOV4:
+			if (msg_len < NETLBL_LEN_U32)
+				goto add_failure;
+			tmp_val = netlbl_getinc_u32(&msg_ptr, &msg_len);
+			/* We should be holding a rcu_read_lock() here
+			 * while we hold the result but since the entry
+			 * will always be deleted when the CIPSO DOI
+			 * is deleted we aren't going to keep the lock. */
+			rcu_read_lock();
+			entry->type_def.cipsov4 = cipso_v4_doi_getdef(tmp_val);
+			if (entry->type_def.cipsov4 == NULL) {
+				rcu_read_unlock();
+				goto add_failure;
+			}
+			ret_val = netlbl_domhsh_add(entry);
+			rcu_read_unlock();
+			break;
+		default:
+			goto add_failure;
+		}
+		if (ret_val != 0)
+			goto add_failure;
+	}
+
+	netlbl_netlink_send_ack(info,
+				netlbl_mgmt_gnl_family.id,
+				NLBL_MGMT_C_ACK,
+				NETLBL_E_OK);
+	return 0;
+
+add_failure:
+	if (entry)
+		kfree(entry->domain);
+	kfree(entry);
+	netlbl_netlink_send_ack(info,
+				netlbl_mgmt_gnl_family.id,
+				NLBL_MGMT_C_ACK,
+				-ret_val);
+	return ret_val;
+}
+
+/**
+ * netlbl_mgmt_remove - Handle a REMOVE message
+ * @skb: the NETLINK buffer
+ * @info: the Generic NETLINK info block
+ *
+ * Description:
+ * Process a user generated REMOVE message and remove the specified domain
+ * mappings.  Returns zero on success, negative values on failure.
+ *
+ */
+static int netlbl_mgmt_remove(struct sk_buff *skb, struct genl_info *info)
+{
+	int ret_val;
+	unsigned char *msg_ptr = netlbl_netlink_payload_data(skb);
+	ssize_t msg_len = netlbl_netlink_payload_len(skb);
+	u32 count;
+	u32 iter;
+	u32 tmp_val;
+
+	ret_val = netlbl_netlink_cap_check(skb, CAP_NET_ADMIN);
+	if (ret_val != 0)
+		goto remove_return;
+
+	if (msg_len < NETLBL_LEN_U32)
+		goto remove_return;
+	count = netlbl_getinc_u32(&msg_ptr, &msg_len);
+
+	for (iter = 0; iter < count && msg_len > 0; iter++) {
+		if (msg_len < NETLBL_LEN_U32)
+			goto remove_return;
+		tmp_val = netlbl_getinc_u32(&msg_ptr, &msg_len);
+		if (tmp_val == 0 ||
+		    msg_len < tmp_val || msg_ptr[tmp_val - 1] != '\0')
+			goto remove_return;
+		ret_val = netlbl_domhsh_remove(msg_ptr);
+		msg_ptr += netlbl_align(tmp_val);
+		msg_len -= netlbl_align(tmp_val);
+		if (ret_val != 0)
+			goto remove_return;
+	}
+
+	ret_val = 0;
+
+remove_return:
+	netlbl_netlink_send_ack(info,
+				netlbl_mgmt_gnl_family.id,
+				NLBL_MGMT_C_ACK,
+				-ret_val);
+	return ret_val;
+}
+
+/**
+ * netlbl_mgmt_list - Handle a LIST message
+ * @skb: the NETLINK buffer
+ * @info: the Generic NETLINK info block
+ *
+ * Description:
+ * Process a user generated LIST message and dumps the domain hash table in a
+ * form suitable for use in a kernel generated LIST message.  Returns zero on
+ * success, negative values on failure.
+ *
+ */
+static int netlbl_mgmt_list(struct sk_buff *skb, struct genl_info *info)
+{
+	int ret_val = -ENOMEM;
+	struct sk_buff *ans_skb;
+
+	ans_skb = netlbl_domhsh_dump(NLMSG_SPACE(GENL_HDRLEN));
+	if (ans_skb == NULL)
+		goto list_failure;
+	netlbl_netlink_hdr_push(ans_skb,
+				info->snd_pid,
+				0,
+				0,
+				netlbl_mgmt_gnl_family.id,
+				NLBL_MGMT_C_LIST,
+				ans_skb->len);
+
+	ret_val = netlbl_netlink_snd(ans_skb, info->snd_pid);
+	if (ret_val != 0)
+		goto list_failure;
+
+	return 0;
+
+list_failure:
+	netlbl_netlink_send_ack(info,
+				netlbl_mgmt_gnl_family.id,
+				NLBL_MGMT_C_ACK,
+				-ret_val);
+	return ret_val;
+}
+
+/**
+ * netlbl_mgmt_adddef - Handle an ADDDEF message
+ * @skb: the NETLINK buffer
+ * @info: the Generic NETLINK info block
+ *
+ * Description:
+ * Process a user generated ADDDEF message and respond accordingly.  Returns
+ * zero on success, negative values on failure.
+ *
+ */
+static int netlbl_mgmt_adddef(struct sk_buff *skb, struct genl_info *info)
+{
+	int ret_val;
+	unsigned char *msg_ptr = netlbl_netlink_payload_data(skb);
+	ssize_t msg_len = netlbl_netlink_payload_len(skb);
+	struct netlbl_dom_map *entry = NULL;
+	u32 tmp_val;
+
+	ret_val = netlbl_netlink_cap_check(skb, CAP_NET_ADMIN);
+	if (ret_val != 0)
+		goto adddef_failure;
+
+	if (msg_len < NETLBL_LEN_U32)
+		goto adddef_failure;
+	tmp_val = netlbl_getinc_u32(&msg_ptr, &msg_len);
+
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
+	if (entry == NULL) {
+		ret_val = -ENOMEM;
+		goto adddef_failure;
+	}
+
+	entry->type = tmp_val;
+	switch (entry->type) {
+	case NETLBL_NLTYPE_UNLABELED:
+		ret_val = netlbl_domhsh_add_default(entry);
+		break;
+	case NETLBL_NLTYPE_CIPSOV4:
+		if (msg_len < NETLBL_LEN_U32)
+			goto adddef_failure;
+		tmp_val = netlbl_getinc_u32(&msg_ptr, &msg_len);
+		/* We should be holding a rcu_read_lock here while we
+		 * hold the result but since the entry will always be
+		 * deleted when the CIPSO DOI is deleted we are going
+		 * to skip the lock. */
+		rcu_read_lock();
+		entry->type_def.cipsov4 = cipso_v4_doi_getdef(tmp_val);
+		if (entry->type_def.cipsov4 == NULL) {
+			rcu_read_unlock();
+			goto adddef_failure;
+		}
+		ret_val = netlbl_domhsh_add_default(entry);
+		rcu_read_unlock();
+		break;
+	default:
+		ret_val = -EINVAL;
+		goto adddef_failure;
+	}
+	if (ret_val != 0)
+		goto adddef_failure;
+
+	netlbl_netlink_send_ack(info,
+				netlbl_mgmt_gnl_family.id,
+				NLBL_MGMT_C_ACK,
+				NETLBL_E_OK);
+	return 0;
+
+adddef_failure:
+	kfree(entry);
+	netlbl_netlink_send_ack(info,
+				netlbl_mgmt_gnl_family.id,
+				NLBL_MGMT_C_ACK,
+				-ret_val);
+	return ret_val;
+}
+
+/**
+ * netlbl_mgmt_removedef - Handle a REMOVEDEF message
+ * @skb: the NETLINK buffer
+ * @info: the Generic NETLINK info block
+ *
+ * Description:
+ * Process a user generated REMOVEDEF message and remove the default domain
+ * mapping.  Returns zero on success, negative values on failure.
+ *
+ */
+static int netlbl_mgmt_removedef(struct sk_buff *skb, struct genl_info *info)
+{
+	int ret_val;
+
+	ret_val = netlbl_netlink_cap_check(skb, CAP_NET_ADMIN);
+	if (ret_val != 0)
+		goto removedef_return;
+
+	ret_val = netlbl_domhsh_remove_default();
+
+removedef_return:
+	netlbl_netlink_send_ack(info,
+				netlbl_mgmt_gnl_family.id,
+				NLBL_MGMT_C_ACK,
+				-ret_val);
+	return ret_val;
+}
+
+/**
+ * netlbl_mgmt_listdef - Handle a LISTDEF message
+ * @skb: the NETLINK buffer
+ * @info: the Generic NETLINK info block
+ *
+ * Description:
+ * Process a user generated LISTDEF message and dumps the default domain
+ * mapping in a form suitable for use in a kernel generated LISTDEF message.
+ * Returns zero on success, negative values on failure.
+ *
+ */
+static int netlbl_mgmt_listdef(struct sk_buff *skb, struct genl_info *info)
+{
+	int ret_val = -ENOMEM;
+	struct sk_buff *ans_skb;
+
+	ans_skb = netlbl_domhsh_dump_default(NLMSG_SPACE(GENL_HDRLEN));
+	if (ans_skb == NULL)
+		goto listdef_failure;
+	netlbl_netlink_hdr_push(ans_skb,
+				info->snd_pid,
+				0,
+				0,
+				netlbl_mgmt_gnl_family.id,
+				NLBL_MGMT_C_LISTDEF,
+				ans_skb->len);
+
+	ret_val = netlbl_netlink_snd(ans_skb, info->snd_pid);
+	if (ret_val != 0)
+		goto listdef_failure;
+
+	return 0;
+
+listdef_failure:
+	netlbl_netlink_send_ack(info,
+				netlbl_mgmt_gnl_family.id,
+				NLBL_MGMT_C_ACK,
+				-ret_val);
+	return ret_val;
+}
+
+/**
+ * netlbl_mgmt_modules - Handle a MODULES message
+ * @skb: the NETLINK buffer
+ * @info: the Generic NETLINK info block
+ *
+ * Description:
+ * Process a user generated MODULES message and respond accordingly.
+ *
+ */
+static int netlbl_mgmt_modules(struct sk_buff *skb, struct genl_info *info)
+{
+	int ret_val = -ENOMEM;
+	u32 mod_count;
+	size_t data_size;
+	struct sk_buff *ans_skb = NULL;
+	unsigned char *data;
+
+	/* unlabeled + cipsov4 */
+	mod_count = 2;
+
+	data_size = GENL_HDRLEN + NETLBL_LEN_U32 + mod_count * NETLBL_LEN_U32;
+	ans_skb = netlbl_netlink_alloc_skb(0, data_size, GFP_KERNEL);
+	if (ans_skb == NULL)
+		goto modules_failure;
+
+	data = netlbl_netlink_hdr_put(ans_skb,
+				      info->snd_pid,
+				      0,
+				      0,
+				      netlbl_mgmt_gnl_family.id,
+				      NLBL_MGMT_C_MODULES,
+				      data_size);
+	if (data == NULL)
+		goto modules_failure;
+
+	netlbl_putinc_u32(&data, mod_count, NULL);
+	netlbl_putinc_u32(&data, NETLBL_NLTYPE_UNLABELED, NULL);
+	netlbl_putinc_u32(&data, NETLBL_NLTYPE_CIPSOV4, NULL);
+
+	ret_val = netlbl_netlink_snd(ans_skb, info->snd_pid);
+	if (ret_val != 0)
+		goto modules_failure;
+
+	return 0;
+
+modules_failure:
+	kfree_skb(ans_skb);
+	netlbl_netlink_send_ack(info,
+				netlbl_mgmt_gnl_family.id,
+				NLBL_MGMT_C_ACK,
+				-ret_val);
+	return ret_val;
+}
+
+/**
+ * netlbl_mgmt_version - Handle a VERSION message
+ * @skb: the NETLINK buffer
+ * @info: the Generic NETLINK info block
+ *
+ * Description:
+ * Process a user generated VERSION message and respond accordingly.  Returns
+ * zero on success, negative values on failure.
+ *
+ */
+static int netlbl_mgmt_version(struct sk_buff *skb, struct genl_info *info)
+{
+	int ret_val = -ENOMEM;
+	size_t data_size;
+	struct sk_buff *ans_skb = NULL;
+	unsigned char *data;
+
+	data_size = GENL_HDRLEN + NETLBL_LEN_U32;
+	ans_skb = netlbl_netlink_alloc_skb(0, data_size, GFP_KERNEL);
+	if (ans_skb == NULL)
+		goto version_failure;
+	data = netlbl_netlink_hdr_put(ans_skb,
+				      info->snd_pid,
+				      0,
+				      0,
+				      netlbl_mgmt_gnl_family.id,
+				      NLBL_MGMT_C_VERSION,
+				      data_size);
+	if (data == NULL)
+		goto version_failure;
+
+	netlbl_put_u32(data, NETLBL_PROTO_VERSION);
+
+	ret_val = netlbl_netlink_snd(ans_skb, info->snd_pid);
+	if (ret_val != 0)
+		goto version_failure;
+
+	return 0;
+
+version_failure:
+	kfree_skb(ans_skb);
+	netlbl_netlink_send_ack(info,
+				netlbl_mgmt_gnl_family.id,
+				NLBL_MGMT_C_ACK,
+				-ret_val);
+	return ret_val;
+}
+
+
+/*
+ * NetLabel Generic NETLINK Command Definitions
+ */
+
+static struct genl_ops netlbl_mgmt_genl_c_add = {
+	.cmd = NLBL_MGMT_C_ADD,
+	.flags = 0,
+	.doit = netlbl_mgmt_add,
+	.dumpit = NULL,
+};
+
+static struct genl_ops netlbl_mgmt_genl_c_remove = {
+	.cmd = NLBL_MGMT_C_REMOVE,
+	.flags = 0,
+	.doit = netlbl_mgmt_remove,
+	.dumpit = NULL,
+};
+
+static struct genl_ops netlbl_mgmt_genl_c_list = {
+	.cmd = NLBL_MGMT_C_LIST,
+	.flags = 0,
+	.doit = netlbl_mgmt_list,
+	.dumpit = NULL,
+};
+
+static struct genl_ops netlbl_mgmt_genl_c_adddef = {
+	.cmd = NLBL_MGMT_C_ADDDEF,
+	.flags = 0,
+	.doit = netlbl_mgmt_adddef,
+	.dumpit = NULL,
+};
+
+static struct genl_ops netlbl_mgmt_genl_c_removedef = {
+	.cmd = NLBL_MGMT_C_REMOVEDEF,
+	.flags = 0,
+	.doit = netlbl_mgmt_removedef,
+	.dumpit = NULL,
+};
+
+static struct genl_ops netlbl_mgmt_genl_c_listdef = {
+	.cmd = NLBL_MGMT_C_LISTDEF,
+	.flags = 0,
+	.doit = netlbl_mgmt_listdef,
+	.dumpit = NULL,
+};
+
+static struct genl_ops netlbl_mgmt_genl_c_modules = {
+	.cmd = NLBL_MGMT_C_MODULES,
+	.flags = 0,
+	.doit = netlbl_mgmt_modules,
+	.dumpit = NULL,
+};
+
+static struct genl_ops netlbl_mgmt_genl_c_version = {
+	.cmd = NLBL_MGMT_C_VERSION,
+	.flags = 0,
+	.doit = netlbl_mgmt_version,
+	.dumpit = NULL,
+};
+
+/*
+ * NetLabel Generic NETLINK Protocol Functions
+ */
+
+/**
+ * netlbl_mgmt_genl_init - Register the NetLabel management component
+ *
+ * Description:
+ * Register the NetLabel management component with the Generic NETLINK
+ * mechanism.  Returns zero on success, negative values on failure.
+ *
+ */
+int netlbl_mgmt_genl_init(void)
+{
+	int ret_val;
+
+	ret_val = genl_register_family(&netlbl_mgmt_gnl_family);
+	if (ret_val != 0)
+		return ret_val;
+
+	ret_val = genl_register_ops(&netlbl_mgmt_gnl_family,
+				    &netlbl_mgmt_genl_c_add);
+	if (ret_val != 0)
+		return ret_val;
+	ret_val = genl_register_ops(&netlbl_mgmt_gnl_family,
+				    &netlbl_mgmt_genl_c_remove);
+	if (ret_val != 0)
+		return ret_val;
+	ret_val = genl_register_ops(&netlbl_mgmt_gnl_family,
+				    &netlbl_mgmt_genl_c_list);
+	if (ret_val != 0)
+		return ret_val;
+	ret_val = genl_register_ops(&netlbl_mgmt_gnl_family,
+				    &netlbl_mgmt_genl_c_adddef);
+	if (ret_val != 0)
+		return ret_val;
+	ret_val = genl_register_ops(&netlbl_mgmt_gnl_family,
+				    &netlbl_mgmt_genl_c_removedef);
+	if (ret_val != 0)
+		return ret_val;
+	ret_val = genl_register_ops(&netlbl_mgmt_gnl_family,
+				    &netlbl_mgmt_genl_c_listdef);
+	if (ret_val != 0)
+		return ret_val;
+	ret_val = genl_register_ops(&netlbl_mgmt_gnl_family,
+				    &netlbl_mgmt_genl_c_modules);
+	if (ret_val != 0)
+		return ret_val;
+	ret_val = genl_register_ops(&netlbl_mgmt_gnl_family,
+				    &netlbl_mgmt_genl_c_version);
+	if (ret_val != 0)
+		return ret_val;
+
+	return 0;
+}
Index: linux-2.6.18-rc2/net/netlabel/netlabel_mgmt.h
===================================================================
--- /dev/null
+++ linux-2.6.18-rc2/net/netlabel/netlabel_mgmt.h
@@ -0,0 +1,249 @@
+/*
+ * NetLabel Management Support
+ *
+ * This file defines the management functions for the NetLabel system.  The
+ * NetLabel system manages static and dynamic label mappings for network
+ * protocols such as CIPSO and RIPSO.
+ *
+ * Author: Paul Moore <paul.moore@hp.com>
+ *
+ */
+
+/*
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+
+#ifndef _NETLABEL_MGMT_H
+#define _NETLABEL_MGMT_H
+
+#include <net/netlabel.h>
+
+/*
+ * The following NetLabel payloads are supported by the management interface,
+ * all of which are preceeded by the nlmsghdr struct.
+ *
+ * o ACK:
+ *   Sent by the kernel in response to an applications message, applications
+ *   should never send this message.
+ *
+ *   +----------------------+-----------------------+
+ *   | seq number (32 bits) | return code (32 bits) |
+ *   +----------------------+-----------------------+
+ *
+ *     seq number:  the sequence number of the original message, taken from the
+ *                  nlmsghdr structure
+ *     return code: return value, based on errno values
+ *
+ * o ADD:
+ *   Sent by an application to add a domain mapping to the NetLabel system.
+ *   The kernel should respond with an ACK.
+ *
+ *   +-------------------+
+ *   | domains (32 bits) | ...
+ *   +-------------------+
+ *
+ *     domains: the number of domains in the message
+ *
+ *   +-------------------------+--------------------------+
+ *   | domain length (32 bits) | domain string (variable) | ...
+ *   +-------------------------+--------------------------+
+ *
+ *   +-------------------------+-------------- ---- --- -- -
+ *   | protocol type (32 bits) | mapping data                ... repeated
+ *   +-------------------------+-------------- ---- --- -- -
+ *
+ *     domain length: the length of the "domain string" in bytes
+ *     domain string: the domain string, NULL terminated
+ *     protocol type: the protocol type (defined by NETLBL_NLTYPE_*)
+ *     mapping data:  specific to the map type (see below)
+ *
+ *   NETLBL_NLTYPE_UNLABELED
+ *
+ *     No mapping data for this protocol type.
+ *
+ *   NETLBL_NLTYPE_CIPSOV4
+ *
+ *   +---------------+
+ *   | doi (32 bits) |
+ *   +---------------+
+ *
+ *     doi:  the CIPSO DOI value
+ *
+ * o REMOVE:
+ *   Sent by an application to remove a domain mapping from the NetLabel
+ *   system.  The kernel should ACK this message.
+ *
+ *   +-------------------+
+ *   | domains (32 bits) | ...
+ *   +-------------------+
+ *
+ *     domains: the number of domains in the message
+ *
+ *   +-------------------------+--------------------------+
+ *   | domain length (32 bits) | domain string (variable) | ...
+ *   +-------------------------+--------------------------+
+ *
+ *     domain length: the length of the "domain string" in bytes
+ *     domain string: the domain string, NULL terminated
+ *
+ * o LIST:
+ *   This message can be sent either from an application or by the kernel in
+ *   response to an application generated LIST message.  When sent by an
+ *   application there is no payload.  The kernel should respond to a LIST
+ *   message either with a LIST message on success or an ACK message on
+ *   failure.
+ *
+ *   +-------------------+
+ *   | domains (32 bits) | ...
+ *   +-------------------+
+ *
+ *     domains: the number of domains in the message
+ *
+ *   +-------------------------+--------------------------+
+ *   | domain length (32 bits) | domain string (variable) | ...
+ *   +-------------------------+--------------------------+
+ *
+ *   +-------------------------+-------------- ---- --- -- -
+ *   | protocol type (32 bits) | mapping data                ... repeated
+ *   +-------------------------+-------------- ---- --- -- -
+ *
+ *     domain length: the length of the "domain string" in bytes
+ *     domain string: the domain string, NULL terminated
+ *     protocol type: the protocol type (defined by NETLBL_NLTYPE_*)
+ *     mapping data:  specific to the map type (see below)
+ *
+ *   NETLBL_NLTYPE_UNLABELED
+ *
+ *     No mapping data for this protocol type.
+ *
+ *   NETLBL_NLTYPE_CIPSOV4
+ *
+ *   +----------------+---------------+
+ *   | type (32 bits) | doi (32 bits) |
+ *   +----------------+---------------+
+ *
+ *     type: the CIPSO mapping table type (defined in the cipso_ipv4.h header
+ *           as CIPSO_V4_MAP_*)
+ *     doi:  the CIPSO DOI value
+ *
+ * o ADDDEF:
+ *   Sent by an application to set the default domain mapping for the NetLabel
+ *   system.  The kernel should respond with an ACK.
+ *
+ *   +-------------------------+-------------- ---- --- -- -
+ *   | protocol type (32 bits) | mapping data                ... repeated
+ *   +-------------------------+-------------- ---- --- -- -
+ *
+ *     protocol type: the protocol type (defined by NETLBL_NLTYPE_*)
+ *     mapping data:  specific to the map type (see below)
+ *
+ *   NETLBL_NLTYPE_UNLABELED
+ *
+ *     No mapping data for this protocol type.
+ *
+ *   NETLBL_NLTYPE_CIPSOV4
+ *
+ *   +---------------+
+ *   | doi (32 bits) |
+ *   +---------------+
+ *
+ *     doi:  the CIPSO DOI value
+ *
+ * o REMOVEDEF:
+ *   Sent by an application to remove the default domain mapping from the
+ *   NetLabel system, there is no payload.  The kernel should ACK this message.
+ *
+ * o LISTDEF:
+ *   This message can be sent either from an application or by the kernel in
+ *   response to an application generated LISTDEF message.  When sent by an
+ *   application there is no payload.  The kernel should respond to a
+ *   LISTDEF message either with a LISTDEF message on success or an ACK message
+ *   on failure.
+ *
+ *   +-------------------------+-------------- ---- --- -- -
+ *   | protocol type (32 bits) | mapping data                ... repeated
+ *   +-------------------------+-------------- ---- --- -- -
+ *
+ *     protocol type: the protocol type (defined by NETLBL_NLTYPE_*)
+ *     mapping data:  specific to the map type (see below)
+ *
+ *   NETLBL_NLTYPE_UNLABELED
+ *
+ *     No mapping data for this protocol type.
+ *
+ *   NETLBL_NLTYPE_CIPSOV4
+ *
+ *   +----------------+---------------+
+ *   | type (32 bits) | doi (32 bits) |
+ *   +----------------+---------------+
+ *
+ *     type: the CIPSO mapping table type (defined in the cipso_ipv4.h header
+ *           as CIPSO_V4_MAP_*)
+ *     doi:  the CIPSO DOI value
+ *
+ * o MODULES:
+ *   Sent by an application to request a list of configured NetLabel modules
+ *   in the kernel.  When sent by an application there is no payload.
+ *
+ *   +-------------------+
+ *   | modules (32 bits) | ...
+ *   +-------------------+
+ *
+ *     modules: the number of modules in the message, if this is an application
+ *              generated message and the value is zero then return a list of
+ *              the configured modules
+ *
+ *   +------------------+
+ *   | module (32 bits) | ... repeated
+ *   +------------------+
+ *
+ *     module: the module number as defined by NETLBL_NLTYPE_*
+ *
+ * o VERSION:
+ *   Sent by an application to request the NetLabel version string.  When sent
+ *   by an application there is no payload.  This message type is also used by
+ *   the kernel to respond to an VERSION request.
+ *
+ *   +-------------------+
+ *   | version (32 bits) |
+ *   +-------------------+
+ *
+ *     version: the protocol version number
+ *
+ */
+
+/* NetLabel Management commands */
+enum {
+	NLBL_MGMT_C_UNSPEC,
+	NLBL_MGMT_C_ACK,
+	NLBL_MGMT_C_ADD,
+	NLBL_MGMT_C_REMOVE,
+	NLBL_MGMT_C_LIST,
+	NLBL_MGMT_C_ADDDEF,
+	NLBL_MGMT_C_REMOVEDEF,
+	NLBL_MGMT_C_LISTDEF,
+	NLBL_MGMT_C_MODULES,
+	NLBL_MGMT_C_VERSION,
+	__NLBL_MGMT_C_MAX,
+};
+#define NLBL_MGMT_C_MAX (__NLBL_MGMT_C_MAX - 1)
+
+/* NetLabel protocol functions */
+int netlbl_mgmt_genl_init(void);
+
+#endif
Index: linux-2.6.18-rc2/net/netlabel/netlabel_unlabeled.h
===================================================================
--- /dev/null
+++ linux-2.6.18-rc2/net/netlabel/netlabel_unlabeled.h
@@ -0,0 +1,98 @@
+/*
+ * NetLabel Unlabeled Support
+ *
+ * This file defines functions for dealing with unlabeled packets for the
+ * NetLabel system.  The NetLabel system manages static and dynamic label
+ * mappings for network protocols such as CIPSO and RIPSO.
+ *
+ * Author: Paul Moore <paul.moore@hp.com>
+ *
+ */
+
+/*
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+
+#ifndef _NETLABEL_UNLABELED_H
+#define _NETLABEL_UNLABELED_H
+
+#include <net/netlabel.h>
+
+/*
+ * The following NetLabel payloads are supported by the Unlabeled subsystem.
+ *
+ * o ACK:
+ *   Sent by the kernel in response to an applications message, applications
+ *   should never send this message.
+ *
+ *   +----------------------+-----------------------+
+ *   | seq number (32 bits) | return code (32 bits) |
+ *   +----------------------+-----------------------+
+ *
+ *     seq number:  the sequence number of the original message, taken from the
+ *                  nlmsghdr structure
+ *     return code: return value, based on errno values
+ *
+ * o ACCEPT
+ *   This message is sent from an application to specify if the kernel should
+ *   allow unlabled packets to pass if they do not match any of the static
+ *   mappings defined in the unlabeled module.
+ *
+ *   +-----------------+
+ *   | allow (32 bits) |
+ *   +-----------------+
+ *
+ *     allow: if true (1) then allow the packets to pass, if false (0) then
+ *            reject the packets
+ *
+ * o LIST
+ *   This message can be sent either from an application or by the kernel in
+ *   response to an application generated LIST message.  When sent by an
+ *   application there is no payload.  The kernel should respond to a LIST
+ *   message either with a LIST message on success or an ACK message on
+ *   failure.
+ *
+ *   +-----------------------+
+ *   | accept flag (32 bits) |
+ *   +-----------------------+
+ *
+ *     accept flag: if true (1) then unlabeled packets are allowed to pass,
+ *                  if false (0) then unlabeled packets are rejected
+ *
+ */
+
+/* NetLabel Unlabeled commands */
+enum {
+	NLBL_UNLABEL_C_UNSPEC,
+	NLBL_UNLABEL_C_ACK,
+	NLBL_UNLABEL_C_ACCEPT,
+	NLBL_UNLABEL_C_LIST,
+	__NLBL_UNLABEL_C_MAX,
+};
+#define NLBL_UNLABEL_C_MAX (__NLBL_UNLABEL_C_MAX - 1)
+
+/* NetLabel protocol functions */
+int netlbl_unlabel_genl_init(void);
+
+/* Process Unlabeled incoming network packets */
+int netlbl_unlabel_getattr(struct netlbl_lsm_secattr *secattr);
+
+/* Set the default configuration to allow Unlabeled packets */
+int netlbl_unlabel_defconf(void);
+
+#endif
Index: linux-2.6.18-rc2/net/netlabel/netlabel_user.c
===================================================================
--- /dev/null
+++ linux-2.6.18-rc2/net/netlabel/netlabel_user.c
@@ -0,0 +1,160 @@
+/*
+ * NetLabel NETLINK Interface
+ *
+ * This file defines the NETLINK interface for the NetLabel system.  The
+ * NetLabel system manages static and dynamic label mappings for network
+ * protocols such as CIPSO and RIPSO.
+ *
+ * Author: Paul Moore <paul.moore@hp.com>
+ *
+ */
+
+/*
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+
+#include <linux/init.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/socket.h>
+#include <net/sock.h>
+#include <net/netlink.h>
+#include <net/genetlink.h>
+#include <net/netlabel.h>
+#include <asm/bug.h>
+
+#include "netlabel_mgmt.h"
+#include "netlabel_unlabeled.h"
+#include "netlabel_cipso_v4.h"
+#include "netlabel_user.h"
+
+/*
+ * NetLabel NETLINK Setup Functions
+ */
+
+/**
+ * netlbl_netlink_init - Initialize the NETLINK communication channel
+ *
+ * Description:
+ * Call out to the NetLabel components so they can register their families and
+ * commands with the Generic NETLINK mechanism.  Returns zero on success and
+ * non-zero on failure.
+ *
+ */
+int netlbl_netlink_init(void)
+{
+	int ret_val;
+
+	ret_val = netlbl_mgmt_genl_init();
+	if (ret_val != 0)
+		return ret_val;
+
+	ret_val = netlbl_cipsov4_genl_init();
+	if (ret_val != 0)
+		return ret_val;
+
+	ret_val = netlbl_unlabel_genl_init();
+	if (ret_val != 0)
+		return ret_val;
+
+	return 0;
+}
+
+/*
+ * NetLabel Common Protocol Functions
+ */
+
+/**
+ * netlbl_netlink_send_ack - Send an ACK message
+ * @info: the generic NETLINK information
+ * @genl_family: the generic NETLINK family ID value
+ * @ack_cmd: the generic NETLINK family ACK command value
+ * @ret_code: return code to use
+ *
+ * Description:
+ * This function sends an ACK message to the sender of the NETLINK message
+ * specified by @info.
+ *
+ */
+void netlbl_netlink_send_ack(const struct genl_info *info,
+			     u32 genl_family,
+			     u8 ack_cmd,
+			     u32 ret_code)
+{
+	size_t data_size;
+	struct sk_buff *skb;
+	unsigned char *data;
+
+	data_size = GENL_HDRLEN + 2 * NETLBL_LEN_U32;
+	skb = netlbl_netlink_alloc_skb(0, data_size, GFP_KERNEL);
+	if (skb == NULL)
+		return;
+
+	data = netlbl_netlink_hdr_put(skb,
+				      info->snd_pid,
+				      0,
+				      0,
+				      genl_family,
+				      ack_cmd,
+				      data_size);
+	if (data == NULL)
+		goto send_ack_failure;
+
+	netlbl_putinc_u32(&data, info->snd_seq, NULL);
+	netlbl_putinc_u32(&data, ret_code, NULL);
+
+	netlbl_netlink_snd(skb, info->snd_pid);
+	return;
+
+send_ack_failure:
+	kfree_skb(skb);
+}
+
+/*
+ * NETLINK I/O Functions
+ */
+
+/**
+ * netlbl_netlink_snd - Send a NetLabel message
+ * @skb: NetLabel message
+ * @pid: destination PID
+ *
+ * Description:
+ * Sends a unicast NetLabel message over the NETLINK socket.
+ *
+ */
+int netlbl_netlink_snd(struct sk_buff *skb, u32 pid)
+{
+	return genlmsg_unicast(skb, pid);
+}
+
+/**
+ * netlbl_netlink_snd - Send a NetLabel message
+ * @skb: NetLabel message
+ * @pid: sending PID
+ * @group: multicast group id
+ *
+ * Description:
+ * Sends a multicast NetLabel message over the NETLINK socket to all members
+ * of @group except @pid.
+ *
+ */
+int netlbl_netlink_snd_multicast(struct sk_buff *skb, u32 pid, u32 group)
+{
+	return genlmsg_multicast(skb, pid, group);
+}
Index: linux-2.6.18-rc2/net/netlabel/netlabel_user.h
===================================================================
--- /dev/null
+++ linux-2.6.18-rc2/net/netlabel/netlabel_user.h
@@ -0,0 +1,207 @@
+/*
+ * NetLabel NETLINK Interface
+ *
+ * This file defines the NETLINK interface for the NetLabel system.  The
+ * NetLabel system manages static and dynamic label mappings for network
+ * protocols such as CIPSO and RIPSO.
+ *
+ * Author: Paul Moore <paul.moore@hp.com>
+ *
+ */
+
+/*
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+
+#ifndef _NETLABEL_USER_H
+#define _NETLABEL_USER_H
+
+#include <linux/skbuff.h>
+#include <linux/capability.h>
+#include <linux/genetlink.h>
+#include <net/netlabel.h>
+#include <net/genetlink.h>
+
+/* NetLabel NETLINK helper functions */
+
+/**
+ * netlbl_netlink_cap_check - Check the NETLINK msg capabilities
+ * @skb: the NETLINK buffer
+ * @req_cap: the required capability
+ *
+ * Description:
+ * Check the NETLINK buffer's capabilities against the required capabilities.
+ * Returns zero on success, negative values on failure.
+ *
+ */
+static inline int netlbl_netlink_cap_check(const struct sk_buff *skb,
+					   kernel_cap_t req_cap)
+{
+	if (cap_raised(NETLINK_CB(skb).eff_cap, req_cap))
+		return 0;
+	return -EPERM;
+}
+
+/**
+ * netlbl_netlink_hdr_put - Write the NETLINK buffers into a buffer
+ * @skb: the buffer
+ * @pid: the PID of the receipient
+ * @seq: the sequence number
+ * @flags: NETLINK message flags
+ * @type: the generic NETLINK message family type
+ * @cmd: command
+ * @len: length
+ *
+ * Description:
+ * Write both a NETLINK nlmsghdr structure and a Generic NETLINK genlmsghdr
+ * struct to a buffer.  Returns a pointer to the start of the payload buffer
+ * on success or NULL on failure.
+ *
+ */
+static inline void __netlbl_netlink_hdr(unsigned char *buffer,
+					u32 pid,
+					u32 seq,
+					int flags,
+					int type,
+					u8 cmd,
+					int len)
+{
+	struct nlmsghdr *nlh;
+	struct genlmsghdr *hdr;
+
+	nlh = (struct nlmsghdr *)buffer;
+	nlh->nlmsg_type = type;
+	nlh->nlmsg_len = len;
+	nlh->nlmsg_flags = flags;
+	nlh->nlmsg_pid = pid;
+	nlh->nlmsg_seq = seq;
+
+	hdr = nlmsg_data(nlh);
+	hdr->cmd = cmd;
+	hdr->version = NETLBL_PROTO_VERSION;
+	hdr->reserved = 0;
+}
+
+/**
+ * netlbl_netlink_hdr_put - Write the NETLINK buffers into a sk_buff
+ * @skb: the packet
+ * @pid: the PID of the receipient
+ * @seq: the sequence number
+ * @flags: NETLINK message flags
+ * @type: the generic NETLINK message family type
+ * @cmd: command
+ * @len: length
+ *
+ * Description:
+ * Write both a NETLINK nlmsghdr structure and a Generic NETLINK genlmsghdr
+ * struct to the packet.  Returns a pointer to the start of the payload buffer
+ * on success or NULL on failure.
+ *
+ */
+static inline unsigned char *netlbl_netlink_hdr_put(struct sk_buff *skb,
+						    u32 pid,
+						    u32 seq,
+						    int flags,
+						    int type,
+						    u8 cmd,
+						    int len)
+{
+	struct nlmsghdr *nlh;
+	struct genlmsghdr *hdr;
+
+	nlh = nlmsg_put(skb, pid, seq, type, len, flags);
+	if (nlh == NULL)
+		return NULL;
+
+	hdr = nlmsg_data(nlh);
+	hdr->cmd = cmd;
+	hdr->version = NETLBL_PROTO_VERSION;
+	hdr->reserved = 0;
+
+	return (unsigned char *)hdr + GENL_HDRLEN;
+}
+
+/**
+ * netlbl_netlink_hdr_push - Write the NETLINK buffers into a sk_buff
+ * @skb: the packet
+ * @pid: the PID of the receipient
+ * @seq: the sequence number
+ * @flags: NETLINK message flags
+ * @type: the generic NETLINK message family type
+ * @cmd: command
+ * @len: length
+ *
+ * Description:
+ * Write both a NETLINK nlmsghdr structure and a Generic NETLINK genlmsghdr
+ * struct to the packet.
+ *
+ */
+static inline void netlbl_netlink_hdr_push(struct sk_buff *skb,
+					   u32 pid,
+					   u32 seq,
+					   int flags,
+					   int type,
+					   u8 cmd,
+					   int len)
+
+{
+	unsigned char *buf = skb_push(skb, NLMSG_SPACE(GENL_HDRLEN));
+	__netlbl_netlink_hdr(buf, pid, seq, flags, type, cmd, len);
+}
+
+/**
+ * netlbl_netlink_payload_len - Return the length of the payload
+ * @skb: the NETLINK buffer
+ *
+ * Description:
+ * This function returns the length of the NetLabel payload.
+ *
+ */
+static inline u32 netlbl_netlink_payload_len(const struct sk_buff *skb)
+{
+	return nlmsg_len((struct nlmsghdr *)skb->data) - GENL_HDRLEN;
+}
+
+/**
+ * netlbl_netlink_payload_data - Returns a pointer to the start of the payload
+ * @skb: the NETLINK buffer
+ *
+ * Description:
+ * This function returns a pointer to the start of the NetLabel payload.
+ *
+ */
+static inline unsigned char *netlbl_netlink_payload_data(
+	                                            const struct sk_buff *skb)
+{
+	return nlmsg_data((struct nlmsghdr *)skb->data) + GENL_HDRLEN;
+}
+
+/* NetLabel common protocol functions */
+
+void netlbl_netlink_send_ack(const struct genl_info *info,
+			     u32 genl_family,
+			     u8 ack_cmd,
+			     u32 ret_code);
+
+/* NetLabel NETLINK I/O functions */
+
+int netlbl_netlink_init(void);
+int netlbl_netlink_snd(struct sk_buff *skb, u32 pid);
+int netlbl_netlink_snd_multicast(struct sk_buff *skb, u32 pid, u32 group);
+
+#endif

--
paul moore
linux security @ hp
