From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v2 3/7] netlabel: Add a generic way to create ordered
	linked lists of network addrs
Date: Mon, 11 Aug 2008 18:24:11 -0400
Message-ID: <20080811222411.22551.29795.stgit@flek.lan>
References: <20080811212640.22551.17728.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:32251 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752676AbYHKWYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 18:24:20 -0400
In-Reply-To: <20080811212640.22551.17728.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create an ordered IP address linked list mechanism similar to the core
kernel's linked list construct.  The idea behind this list functionality
is to create an extensibile linked list ordered by IP address mask to
ease the matching of network addresses.  The linked list is ordered with
larger address masks at the front of the list and shorter address masks
at the end to facilitate overriding network entries with individual host
or subnet entries.

Signed-off-by: XXX
---

 net/netlabel/Makefile             |    3 
 net/netlabel/netlabel_addrlist.c  |  258 +++++++++++++++++++++++++++++
 net/netlabel/netlabel_addrlist.h  |  162 ++++++++++++++++++
 net/netlabel/netlabel_unlabeled.c |  329 +++++++++++++------------------------
 4 files changed, 538 insertions(+), 214 deletions(-)

diff --git a/net/netlabel/Makefile b/net/netlabel/Makefile
index 8af18c0..ea750e9 100644
--- a/net/netlabel/Makefile
+++ b/net/netlabel/Makefile
@@ -5,7 +5,8 @@
 #
 
 # base objects
-obj-y	:= netlabel_user.o netlabel_kapi.o netlabel_domainhash.o
+obj-y	:= netlabel_user.o netlabel_kapi.o
+obj-y	+= netlabel_domainhash.o netlabel_addrlist.o
 
 # management objects
 obj-y	+= netlabel_mgmt.o
diff --git a/net/netlabel/netlabel_addrlist.c b/net/netlabel/netlabel_addrlist.c
new file mode 100644
index 0000000..dd928aa
--- /dev/null
+++ b/net/netlabel/netlabel_addrlist.c
@@ -0,0 +1,258 @@
+/*
+ * NetLabel Network Address Lists
+ *
+ * This file contains network address list functions used to manage ordered
+ * lists of network addresses for use by the NetLabel subsystem.  The NetLabel
+ * system manages static and dynamic label mappings for network protocols such
+ * as CIPSO and RIPSO.
+ *
+ * Author: Paul Moore <paul.moore@hp.com>
+ *
+ */
+
+/*
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2008
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
+#include <linux/spinlock.h>
+#include <linux/in.h>
+#include <linux/in6.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <net/ip.h>
+#include <net/ipv6.h>
+
+#include "netlabel_addrlist.h"
+
+/*
+ * Address List Functions
+ */
+
+/**
+ * netlbl_af4list_search - Search for a matching IPv4 address entry
+ * @addr: IPv4 address
+ * @head: the list head
+ *
+ * Description:
+ * Searches the IPv4 address list given by @head.  If a matching address entry
+ * is found it is returned, otherwise NULL is returned.  The caller is
+ * responsible for calling the rcu_read_[un]lock() functions.
+ *
+ */
+struct netlbl_af4list *netlbl_af4list_search(__be32 addr,
+					     struct list_head *head)
+{
+	struct netlbl_af4list *iter;
+
+	list_for_each_entry_rcu(iter, head, list)
+		if (iter->valid && (addr & iter->mask) == iter->addr)
+			return iter;
+
+	return NULL;
+}
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+/**
+ * netlbl_af6list_search - Search for a matching IPv6 address entry
+ * @addr: IPv6 address
+ * @head: the list head
+ *
+ * Description:
+ * Searches the IPv6 address list given by @head.  If a matching address entry
+ * is found it is returned, otherwise NULL is returned.  The caller is
+ * responsible for calling the rcu_read_[un]lock() functions.
+ *
+ */
+struct netlbl_af6list *netlbl_af6list_search(const struct in6_addr *addr,
+					     struct list_head *head)
+{
+	struct netlbl_af6list *iter;
+
+	list_for_each_entry_rcu(iter, head, list)
+		if (iter->valid &&
+		    ipv6_masked_addr_cmp(&iter->addr, &iter->mask, addr) == 0)
+			return iter;
+
+	return NULL;
+}
+#endif /* IPv6 */
+
+/**
+ * netlbl_af4list_add - Add a new IPv4 address entry to a list
+ * @entry: address entry
+ * @head: the list head
+ *
+ * Description:
+ * Add a new address entry to the list pointed to by @head.  On success zero is
+ * returned, otherwise a negative value is returned.  The caller is responsible
+ * for calling the necessary locking functions.
+ *
+ */
+int netlbl_af4list_add(struct netlbl_af4list *entry, struct list_head *head)
+{
+	struct netlbl_af4list *iter;
+
+	iter = netlbl_af4list_search(entry->addr, head);
+	if (iter != NULL &&
+	    iter->addr == entry->addr && iter->mask == entry->mask)
+		return -EEXIST;
+
+	/* in order to speed up address searches through the list (the common
+	 * case) we need to keep the list in order based on the size of the
+	 * address mask such that the entry with the widest mask (smallest
+	 * numerical value) appears first in the list */
+	list_for_each_entry_rcu(iter, head, list)
+		if (iter->valid &&
+		    ntohl(entry->mask) > ntohl(iter->mask)) {
+			__list_add_rcu(&entry->list,
+				       iter->list.prev,
+				       &iter->list);
+			return 0;
+		}
+	list_add_tail_rcu(&entry->list, head);
+	return 0;
+}
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+/**
+ * netlbl_af6list_add - Add a new IPv6 address entry to a list
+ * @entry: address entry
+ * @head: the list head
+ *
+ * Description:
+ * Add a new address entry to the list pointed to by @head.  On success zero is
+ * returned, otherwise a negative value is returned.  The caller is responsible
+ * for calling the necessary locking functions.
+ *
+ */
+int netlbl_af6list_add(struct netlbl_af6list *entry, struct list_head *head)
+{
+	struct netlbl_af6list *iter;
+
+	iter = netlbl_af6list_search(&entry->addr, head);
+	if (iter != NULL &&
+	    ipv6_addr_equal(&iter->addr, &entry->addr) &&
+	    ipv6_addr_equal(&iter->mask, &entry->mask))
+		return -EEXIST;
+
+	/* in order to speed up address searches through the list (the common
+	 * case) we need to keep the list in order based on the size of the
+	 * address mask such that the entry with the widest mask (smallest
+	 * numerical value) appears first in the list */
+	list_for_each_entry_rcu(iter, head, list)
+		if (iter->valid &&
+		    ipv6_addr_cmp(&entry->mask, &iter->mask) > 0) {
+			__list_add_rcu(&entry->list,
+				       iter->list.prev,
+				       &iter->list);
+			return 0;
+		}
+	list_add_tail_rcu(&entry->list, head);
+	return 0;
+}
+#endif /* IPv6 */
+
+/**
+ * netlbl_af4list_remove_entry - Remove an IPv4 address entry
+ * @entry: address entry
+ *
+ * Description:
+ * Remove the specified IP address entry.  The caller is responsible for
+ * calling the necessary locking functions.
+ *
+ */
+void netlbl_af4list_remove_entry(struct netlbl_af4list *entry)
+{
+	entry->valid = 0;
+	list_del_rcu(&entry->list);
+}
+
+/**
+ * netlbl_af4list_remove - Remove an IPv4 address entry
+ * @addr: IP address
+ * @mask: IP address mask
+ * @head: the list head
+ *
+ * Description:
+ * Remove an IP address entry from the list pointed to by @head.  Returns the
+ * entry on success, NULL on failure.  The caller is responsible for calling
+ * the necessary locking functions.
+ *
+ */
+struct netlbl_af4list *netlbl_af4list_remove(__be32 addr, __be32 mask,
+					     struct list_head *head)
+{
+	struct netlbl_af4list *entry;
+
+	entry = netlbl_af4list_search(addr, head);
+	if (entry != NULL && entry->addr == addr && entry->mask == mask) {
+		netlbl_af4list_remove_entry(entry);
+		return entry;
+	}
+
+	return NULL;
+}
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+/**
+ * netlbl_af6list_remove_entry - Remove an IPv6 address entry
+ * @entry: address entry
+ *
+ * Description:
+ * Remove the specified IP address entry.  The caller is responsible for
+ * calling the necessary locking functions.
+ *
+ */
+void netlbl_af6list_remove_entry(struct netlbl_af6list *entry)
+{
+	entry->valid = 0;
+	list_del_rcu(&entry->list);
+}
+
+/**
+ * netlbl_af6list_remove - Remove an IPv6 address entry
+ * @addr: IP address
+ * @mask: IP address mask
+ * @head: the list head
+ *
+ * Description:
+ * Remove an IP address entry from the list pointed to by @head.  Returns the
+ * entry on success, NULL on failure.  The caller is responsible for calling
+ * the necessary locking functions.
+ *
+ */
+struct netlbl_af6list *netlbl_af6list_remove(const struct in6_addr *addr,
+					     const struct in6_addr *mask,
+					     struct list_head *head)
+{
+	struct netlbl_af6list *entry;
+
+	entry = netlbl_af6list_search(addr, head);
+	if (entry != NULL &&
+	    ipv6_addr_equal(&entry->addr, addr) &&
+	    ipv6_addr_equal(&entry->mask, mask)) {
+		netlbl_af6list_remove_entry(entry);
+		return entry;
+	}
+
+	return NULL;
+}
+#endif /* IPv6 */
diff --git a/net/netlabel/netlabel_addrlist.h b/net/netlabel/netlabel_addrlist.h
new file mode 100644
index 0000000..d521762
--- /dev/null
+++ b/net/netlabel/netlabel_addrlist.h
@@ -0,0 +1,162 @@
+/*
+ * NetLabel Network Address Lists
+ *
+ * This file contains network address list functions used to manage ordered
+ * lists of network addresses for use by the NetLabel subsystem.  The NetLabel
+ * system manages static and dynamic label mappings for network protocols such
+ * as CIPSO and RIPSO.
+ *
+ * Author: Paul Moore <paul.moore@hp.com>
+ *
+ */
+
+/*
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2008
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
+#ifndef _NETLABEL_ADDRLIST_H
+#define _NETLABEL_ADDRLIST_H
+
+#include <linux/types.h>
+#include <linux/rcupdate.h>
+#include <linux/list.h>
+#include <linux/in6.h>
+
+/* XXX - needs documentation */
+struct netlbl_af4list {
+	__be32 addr;
+	__be32 mask;
+
+	u32 valid;
+	struct list_head list;
+};
+
+/* XXX - needs documentation */
+struct netlbl_af6list {
+	struct in6_addr addr;
+	struct in6_addr mask;
+
+	u32 valid;
+	struct list_head list;
+};
+
+#define __af4list_entry(ptr) container_of(ptr, struct netlbl_af4list, list)
+
+static inline struct netlbl_af4list *__af4list_valid(struct list_head *s,
+						     struct list_head *h)
+{
+	struct list_head *i = s;
+	struct netlbl_af4list *n = __af4list_entry(s);
+	while (i != h && !n->valid) {
+		i = i->next;
+		n = __af4list_entry(i);
+	}
+	return n;
+}
+
+static inline struct netlbl_af4list *__af4list_valid_rcu(struct list_head *s,
+							 struct list_head *h)
+{
+	struct list_head *i = s;
+	struct netlbl_af4list *n = __af4list_entry(s);
+	while (i != h && !n->valid) {
+		i = rcu_dereference(i->next);
+		n = __af4list_entry(i);
+	}
+	return n;
+}
+
+#define netlbl_af4list_foreach(iter, head)				\
+	for (iter = __af4list_valid((head)->next, head);		\
+	     prefetch(iter->list.next), &iter->list != (head);		\
+	     iter = __af4list_valid(iter->list.next, head))
+
+#define netlbl_af4list_foreach_rcu(iter, head)				\
+	for (iter = __af4list_valid_rcu((head)->next, head);		\
+	     prefetch(iter->list.next),	&iter->list != (head);		\
+	     iter = __af4list_valid_rcu(iter->list.next, head))
+
+#define netlbl_af4list_foreach_safe(iter, tmp, head)			\
+	for (iter = __af4list_valid((head)->next, head),		\
+		     tmp = __af4list_valid(iter->list.next, head);	\
+	     &iter->list != (head);					\
+	     iter = tmp, tmp = __af4list_valid(iter->list.next, head))
+
+int netlbl_af4list_add(struct netlbl_af4list *entry,
+		       struct list_head *head);
+struct netlbl_af4list *netlbl_af4list_remove(__be32 addr, __be32 mask,
+					     struct list_head *head);
+void netlbl_af4list_remove_entry(struct netlbl_af4list *entry);
+struct netlbl_af4list *netlbl_af4list_search(__be32 addr,
+					     struct list_head *head);
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+
+#define __af6list_entry(ptr) container_of(ptr, struct netlbl_af6list, list)
+
+static inline struct netlbl_af6list *__af6list_valid(struct list_head *s,
+						     struct list_head *h)
+{
+	struct list_head *i = s;
+	struct netlbl_af6list *n = __af6list_entry(s);
+	while (i != h && !n->valid) {
+		i = i->next;
+		n = __af6list_entry(i);
+	}
+	return n;
+}
+
+static inline struct netlbl_af6list *__af6list_valid_rcu(struct list_head *s,
+							 struct list_head *h)
+{
+	struct list_head *i = s;
+	struct netlbl_af6list *n = __af6list_entry(s);
+	while (i != h && !n->valid) {
+		i = rcu_dereference(i->next);
+		n = __af6list_entry(i);
+	}
+	return n;
+}
+
+#define netlbl_af6list_foreach(iter, head)				\
+	for (iter = __af6list_valid((head)->next, head);		\
+	     prefetch(iter->list.next),	&iter->list != (head);		\
+	     iter = __af6list_valid(iter->list.next, head))
+
+#define netlbl_af6list_foreach_rcu(iter, head)				\
+	for (iter = __af6list_valid_rcu((head)->next, head);		\
+	     prefetch(iter->list.next),	&iter->list != (head);		\
+	     iter = __af6list_valid_rcu(iter->list.next, head))
+
+#define netlbl_af6list_foreach_safe(iter, tmp, head)			\
+	for (iter = __af6list_valid((head)->next, head),		\
+		     tmp = __af6list_valid(iter->list.next, head);	\
+	     &iter->list != (head);					\
+	     iter = tmp, tmp = __af6list_valid(iter->list.next, head))
+
+int netlbl_af6list_add(struct netlbl_af6list *entry,
+		       struct list_head *head);
+struct netlbl_af6list *netlbl_af6list_remove(const struct in6_addr *addr,
+					     const struct in6_addr *mask,
+					     struct list_head *head);
+void netlbl_af6list_remove_entry(struct netlbl_af6list *entry);
+struct netlbl_af6list *netlbl_af6list_search(const struct in6_addr *addr,
+					     struct list_head *head);
+#endif /* IPV6 */
+
+#endif
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 921c118..c2ca224 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -54,6 +54,7 @@
 #include <asm/atomic.h>
 
 #include "netlabel_user.h"
+#include "netlabel_addrlist.h"
 #include "netlabel_domainhash.h"
 #include "netlabel_unlabeled.h"
 #include "netlabel_mgmt.h"
@@ -76,22 +77,20 @@ struct netlbl_unlhsh_tbl {
 	struct list_head *tbl;
 	u32 size;
 };
+#define netlbl_unlhsh_addr4_entry(iter) \
+	container_of(iter, struct netlbl_unlhsh_addr4, list)
 struct netlbl_unlhsh_addr4 {
-	__be32 addr;
-	__be32 mask;
 	u32 secid;
 
-	u32 valid;
-	struct list_head list;
+	struct netlbl_af4list list;
 	struct rcu_head rcu;
 };
+#define netlbl_unlhsh_addr6_entry(iter) \
+	container_of(iter, struct netlbl_unlhsh_addr6, list)
 struct netlbl_unlhsh_addr6 {
-	struct in6_addr addr;
-	struct in6_addr mask;
 	u32 secid;
 
-	u32 valid;
-	struct list_head list;
+	struct netlbl_af6list list;
 	struct rcu_head rcu;
 };
 struct netlbl_unlhsh_iface {
@@ -274,26 +273,24 @@ static void netlbl_unlhsh_free_addr6(struct rcu_head *entry)
 static void netlbl_unlhsh_free_iface(struct rcu_head *entry)
 {
 	struct netlbl_unlhsh_iface *iface;
-	struct netlbl_unlhsh_addr4 *iter4;
-	struct netlbl_unlhsh_addr4 *tmp4;
-	struct netlbl_unlhsh_addr6 *iter6;
-	struct netlbl_unlhsh_addr6 *tmp6;
+	struct netlbl_af4list *iter4;
+	struct netlbl_af4list *tmp4;
+	struct netlbl_af6list *iter6;
+	struct netlbl_af6list *tmp6;
 
 	iface = container_of(entry, struct netlbl_unlhsh_iface, rcu);
 
 	/* no need for locks here since we are the only one with access to this
 	 * structure */
 
-	list_for_each_entry_safe(iter4, tmp4, &iface->addr4_list, list)
-		if (iter4->valid) {
-			list_del_rcu(&iter4->list);
-			kfree(iter4);
-		}
-	list_for_each_entry_safe(iter6, tmp6, &iface->addr6_list, list)
-		if (iter6->valid) {
-			list_del_rcu(&iter6->list);
-			kfree(iter6);
-		}
+	netlbl_af4list_foreach_safe(iter4, tmp4, &iface->addr4_list) {
+		netlbl_af4list_remove_entry(iter4);
+		kfree(netlbl_unlhsh_addr4_entry(iter4));
+	}
+	netlbl_af6list_foreach_safe(iter6, tmp6, &iface->addr6_list) {
+		netlbl_af6list_remove_entry(iter6);
+		kfree(netlbl_unlhsh_addr6_entry(iter6));
+	}
 	kfree(iface);
 }
 
@@ -316,59 +313,6 @@ static u32 netlbl_unlhsh_hash(int ifindex)
 }
 
 /**
- * netlbl_unlhsh_search_addr4 - Search for a matching IPv4 address entry
- * @addr: IPv4 address
- * @iface: the network interface entry
- *
- * Description:
- * Searches the IPv4 address list of the network interface specified by @iface.
- * If a matching address entry is found it is returned, otherwise NULL is
- * returned.  The caller is responsible for calling the rcu_read_[un]lock()
- * functions.
- *
- */
-static struct netlbl_unlhsh_addr4 *netlbl_unlhsh_search_addr4(
-	                               __be32 addr,
-	                               const struct netlbl_unlhsh_iface *iface)
-{
-	struct netlbl_unlhsh_addr4 *iter;
-
-	list_for_each_entry_rcu(iter, &iface->addr4_list, list)
-		if (iter->valid && (addr & iter->mask) == iter->addr)
-			return iter;
-
-	return NULL;
-}
-
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-/**
- * netlbl_unlhsh_search_addr6 - Search for a matching IPv6 address entry
- * @addr: IPv6 address
- * @iface: the network interface entry
- *
- * Description:
- * Searches the IPv6 address list of the network interface specified by @iface.
- * If a matching address entry is found it is returned, otherwise NULL is
- * returned.  The caller is responsible for calling the rcu_read_[un]lock()
- * functions.
- *
- */
-static struct netlbl_unlhsh_addr6 *netlbl_unlhsh_search_addr6(
-	                               const struct in6_addr *addr,
-	                               const struct netlbl_unlhsh_iface *iface)
-{
-	struct netlbl_unlhsh_addr6 *iter;
-
-	list_for_each_entry_rcu(iter, &iface->addr6_list, list)
-		if (iter->valid &&
-		    ipv6_masked_addr_cmp(&iter->addr, &iter->mask, addr) == 0)
-		return iter;
-
-	return NULL;
-}
-#endif /* IPv6 */
-
-/**
  * netlbl_unlhsh_search_iface - Search for a matching interface entry
  * @ifindex: the network interface
  *
@@ -439,43 +383,26 @@ static int netlbl_unlhsh_add_addr4(struct netlbl_unlhsh_iface *iface,
 				   const struct in_addr *mask,
 				   u32 secid)
 {
+	int ret_val;
 	struct netlbl_unlhsh_addr4 *entry;
-	struct netlbl_unlhsh_addr4 *iter;
 
 	entry = kzalloc(sizeof(*entry), GFP_ATOMIC);
 	if (entry == NULL)
 		return -ENOMEM;
 
-	entry->addr = addr->s_addr & mask->s_addr;
-	entry->mask = mask->s_addr;
-	entry->secid = secid;
-	entry->valid = 1;
+	entry->list.addr = addr->s_addr & mask->s_addr;
+	entry->list.mask = mask->s_addr;
+	entry->list.valid = 1;
 	INIT_RCU_HEAD(&entry->rcu);
+	entry->secid = secid;
 
 	spin_lock(&netlbl_unlhsh_lock);
-	iter = netlbl_unlhsh_search_addr4(entry->addr, iface);
-	if (iter != NULL &&
-	    iter->addr == addr->s_addr && iter->mask == mask->s_addr) {
-		spin_unlock(&netlbl_unlhsh_lock);
-		kfree(entry);
-		return -EEXIST;
-	}
-	/* in order to speed up address searches through the list (the common
-	 * case) we need to keep the list in order based on the size of the
-	 * address mask such that the entry with the widest mask (smallest
-	 * numerical value) appears first in the list */
-	list_for_each_entry_rcu(iter, &iface->addr4_list, list)
-		if (iter->valid &&
-		    ntohl(entry->mask) > ntohl(iter->mask)) {
-			__list_add_rcu(&entry->list,
-				       iter->list.prev,
-				       &iter->list);
-			spin_unlock(&netlbl_unlhsh_lock);
-			return 0;
-		}
-	list_add_tail_rcu(&entry->list, &iface->addr4_list);
+	ret_val = netlbl_af4list_add(&entry->list, &iface->addr4_list);
 	spin_unlock(&netlbl_unlhsh_lock);
-	return 0;
+
+	if (ret_val != 0)
+		kfree(entry);
+	return ret_val;
 }
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
@@ -498,47 +425,29 @@ static int netlbl_unlhsh_add_addr6(struct netlbl_unlhsh_iface *iface,
 				   const struct in6_addr *mask,
 				   u32 secid)
 {
+	int ret_val;
 	struct netlbl_unlhsh_addr6 *entry;
-	struct netlbl_unlhsh_addr6 *iter;
 
 	entry = kzalloc(sizeof(*entry), GFP_ATOMIC);
 	if (entry == NULL)
 		return -ENOMEM;
 
-	ipv6_addr_copy(&entry->addr, addr);
-	entry->addr.s6_addr32[0] &= mask->s6_addr32[0];
-	entry->addr.s6_addr32[1] &= mask->s6_addr32[1];
-	entry->addr.s6_addr32[2] &= mask->s6_addr32[2];
-	entry->addr.s6_addr32[3] &= mask->s6_addr32[3];
-	ipv6_addr_copy(&entry->mask, mask);
-	entry->secid = secid;
-	entry->valid = 1;
+	ipv6_addr_copy(&entry->list.addr, addr);
+	entry->list.addr.s6_addr32[0] &= mask->s6_addr32[0];
+	entry->list.addr.s6_addr32[1] &= mask->s6_addr32[1];
+	entry->list.addr.s6_addr32[2] &= mask->s6_addr32[2];
+	entry->list.addr.s6_addr32[3] &= mask->s6_addr32[3];
+	ipv6_addr_copy(&entry->list.mask, mask);
+	entry->list.valid = 1;
 	INIT_RCU_HEAD(&entry->rcu);
+	entry->secid = secid;
 
 	spin_lock(&netlbl_unlhsh_lock);
-	iter = netlbl_unlhsh_search_addr6(&entry->addr, iface);
-	if (iter != NULL &&
-	    (ipv6_addr_equal(&iter->addr, addr) &&
-	     ipv6_addr_equal(&iter->mask, mask))) {
-		spin_unlock(&netlbl_unlhsh_lock);
-		kfree(entry);
-		return -EEXIST;
-	}
-	/* in order to speed up address searches through the list (the common
-	 * case) we need to keep the list in order based on the size of the
-	 * address mask such that the entry with the widest mask (smallest
-	 * numerical value) appears first in the list */
-	list_for_each_entry_rcu(iter, &iface->addr6_list, list)
-		if (iter->valid &&
-		    ipv6_addr_cmp(&entry->mask, &iter->mask) > 0) {
-			__list_add_rcu(&entry->list,
-				       iter->list.prev,
-				       &iter->list);
-			spin_unlock(&netlbl_unlhsh_lock);
-			return 0;
-		}
-	list_add_tail_rcu(&entry->list, &iface->addr6_list);
+	ret_val = netlbl_af6list_add(&entry->list, &iface->addr6_list);
 	spin_unlock(&netlbl_unlhsh_lock);
+
+	if (ret_val != 0)
+		kfree(entry);
 	return 0;
 }
 #endif /* IPv6 */
@@ -719,22 +628,21 @@ static int netlbl_unlhsh_remove_addr4(struct net *net,
 				      const struct in_addr *mask,
 				      struct netlbl_audit *audit_info)
 {
-	int ret_val = -ENOENT;
+	int ret_val = 0;
+	struct netlbl_af4list *list_entry;
 	struct netlbl_unlhsh_addr4 *entry;
-	struct audit_buffer *audit_buf = NULL;
+	struct audit_buffer *audit_buf;
 	struct net_device *dev;
-	char *secctx = NULL;
+	char *secctx;
 	u32 secctx_len;
 
 	spin_lock(&netlbl_unlhsh_lock);
-	entry = netlbl_unlhsh_search_addr4(addr->s_addr, iface);
-	if (entry != NULL &&
-	    entry->addr == addr->s_addr && entry->mask == mask->s_addr) {
-		entry->valid = 0;
-		list_del_rcu(&entry->list);
-		ret_val = 0;
-	}
+	list_entry = netlbl_af4list_remove(addr->s_addr, mask->s_addr,
+					   &iface->addr4_list);
 	spin_unlock(&netlbl_unlhsh_lock);
+	if (list_entry == NULL)
+		ret_val = -ENOENT;
+	entry = netlbl_unlhsh_addr4_entry(list_entry);
 
 	audit_buf = netlbl_audit_start_common(AUDIT_MAC_UNLBL_STCDEL,
 					      audit_info);
@@ -742,12 +650,12 @@ static int netlbl_unlhsh_remove_addr4(struct net *net,
 		dev = dev_get_by_index(net, iface->ifindex);
 		netlbl_unlabel_audit_addr4(audit_buf,
 					   (dev != NULL ? dev->name : NULL),
-					   entry->addr, entry->mask);
+					   addr->s_addr, mask->s_addr);
 		if (dev != NULL)
 			dev_put(dev);
-		if (security_secid_to_secctx(entry->secid,
-					     &secctx,
-					     &secctx_len) == 0) {
+		if (entry && security_secid_to_secctx(entry->secid,
+						      &secctx,
+						      &secctx_len) == 0) {
 			audit_log_format(audit_buf, " sec_obj=%s", secctx);
 			security_release_secctx(secctx, secctx_len);
 		}
@@ -781,23 +689,20 @@ static int netlbl_unlhsh_remove_addr6(struct net *net,
 				      const struct in6_addr *mask,
 				      struct netlbl_audit *audit_info)
 {
-	int ret_val = -ENOENT;
+	int ret_val = 0;
+	struct netlbl_af6list *list_entry;
 	struct netlbl_unlhsh_addr6 *entry;
-	struct audit_buffer *audit_buf = NULL;
+	struct audit_buffer *audit_buf;
 	struct net_device *dev;
-	char *secctx = NULL;
+	char *secctx;
 	u32 secctx_len;
 
 	spin_lock(&netlbl_unlhsh_lock);
-	entry = netlbl_unlhsh_search_addr6(addr, iface);
-	if (entry != NULL &&
-	    (ipv6_addr_equal(&entry->addr, addr) &&
-	     ipv6_addr_equal(&entry->mask, mask))) {
-		entry->valid = 0;
-		list_del_rcu(&entry->list);
-		ret_val = 0;
-	}
+	list_entry = netlbl_af6list_remove(addr, mask, &iface->addr6_list);
 	spin_unlock(&netlbl_unlhsh_lock);
+	if (list_entry == NULL)
+		ret_val = -ENOENT;
+	entry = netlbl_unlhsh_addr6_entry(list_entry);
 
 	audit_buf = netlbl_audit_start_common(AUDIT_MAC_UNLBL_STCDEL,
 					      audit_info);
@@ -808,9 +713,9 @@ static int netlbl_unlhsh_remove_addr6(struct net *net,
 					   addr, mask);
 		if (dev != NULL)
 			dev_put(dev);
-		if (security_secid_to_secctx(entry->secid,
-					     &secctx,
-					     &secctx_len) == 0) {
+		if (entry && security_secid_to_secctx(entry->secid,
+						      &secctx,
+						      &secctx_len) == 0) {
 			audit_log_format(audit_buf, " sec_obj=%s", secctx);
 			security_release_secctx(secctx, secctx_len);
 		}
@@ -836,16 +741,14 @@ static int netlbl_unlhsh_remove_addr6(struct net *net,
  */
 static void netlbl_unlhsh_condremove_iface(struct netlbl_unlhsh_iface *iface)
 {
-	struct netlbl_unlhsh_addr4 *iter4;
-	struct netlbl_unlhsh_addr6 *iter6;
+	struct netlbl_af4list *iter4;
+	struct netlbl_af6list *iter6;
 
 	spin_lock(&netlbl_unlhsh_lock);
-	list_for_each_entry_rcu(iter4, &iface->addr4_list, list)
-		if (iter4->valid)
-			goto unlhsh_condremove_failure;
-	list_for_each_entry_rcu(iter6, &iface->addr6_list, list)
-		if (iter6->valid)
-			goto unlhsh_condremove_failure;
+	netlbl_af4list_foreach_rcu(iter4, &iface->addr4_list)
+		goto unlhsh_condremove_failure;
+	netlbl_af6list_foreach_rcu(iter6, &iface->addr6_list)
+		goto unlhsh_condremove_failure;
 	iface->valid = 0;
 	if (iface->ifindex > 0)
 		list_del_rcu(&iface->list);
@@ -1349,7 +1252,7 @@ static int netlbl_unlabel_staticlist_gen(u32 cmd,
 	if (addr4) {
 		struct in_addr addr_struct;
 
-		addr_struct.s_addr = addr4->addr;
+		addr_struct.s_addr = addr4->list.addr;
 		ret_val = nla_put(cb_arg->skb,
 				  NLBL_UNLABEL_A_IPV4ADDR,
 				  sizeof(struct in_addr),
@@ -1357,7 +1260,7 @@ static int netlbl_unlabel_staticlist_gen(u32 cmd,
 		if (ret_val != 0)
 			goto list_cb_failure;
 
-		addr_struct.s_addr = addr4->mask;
+		addr_struct.s_addr = addr4->list.mask;
 		ret_val = nla_put(cb_arg->skb,
 				  NLBL_UNLABEL_A_IPV4MASK,
 				  sizeof(struct in_addr),
@@ -1370,14 +1273,14 @@ static int netlbl_unlabel_staticlist_gen(u32 cmd,
 		ret_val = nla_put(cb_arg->skb,
 				  NLBL_UNLABEL_A_IPV6ADDR,
 				  sizeof(struct in6_addr),
-				  &addr6->addr);
+				  &addr6->list.addr);
 		if (ret_val != 0)
 			goto list_cb_failure;
 
 		ret_val = nla_put(cb_arg->skb,
 				  NLBL_UNLABEL_A_IPV6MASK,
 				  sizeof(struct in6_addr),
-				  &addr6->mask);
+				  &addr6->list.mask);
 		if (ret_val != 0)
 			goto list_cb_failure;
 
@@ -1425,8 +1328,8 @@ static int netlbl_unlabel_staticlist(struct sk_buff *skb,
 	u32 iter_bkt;
 	u32 iter_chain = 0, iter_addr4 = 0, iter_addr6 = 0;
 	struct netlbl_unlhsh_iface *iface;
-	struct netlbl_unlhsh_addr4 *addr4;
-	struct netlbl_unlhsh_addr6 *addr6;
+	struct netlbl_af4list *addr4;
+	struct netlbl_af6list *addr6;
 
 	cb_arg.nl_cb = cb;
 	cb_arg.skb = skb;
@@ -1442,33 +1345,31 @@ static int netlbl_unlabel_staticlist(struct sk_buff *skb,
 			if (!iface->valid ||
 			    iter_chain++ < skip_chain)
 				continue;
-			list_for_each_entry_rcu(addr4,
-						&iface->addr4_list,
-						list) {
-				if (!addr4->valid || iter_addr4++ < skip_addr4)
+			netlbl_af4list_foreach_rcu(addr4,
+						   &iface->addr4_list) {
+				if (iter_addr4++ < skip_addr4)
 					continue;
 				if (netlbl_unlabel_staticlist_gen(
-					             NLBL_UNLABEL_C_STATICLIST,
-						     iface,
-						     addr4,
-						     NULL,
-						     &cb_arg) < 0) {
+					      NLBL_UNLABEL_C_STATICLIST,
+					      iface,
+					      netlbl_unlhsh_addr4_entry(addr4),
+					      NULL,
+					      &cb_arg) < 0) {
 					iter_addr4--;
 					iter_chain--;
 					goto unlabel_staticlist_return;
 				}
 			}
-			list_for_each_entry_rcu(addr6,
-						&iface->addr6_list,
-						list) {
-				if (!addr6->valid || iter_addr6++ < skip_addr6)
+			netlbl_af6list_foreach_rcu(addr6,
+						   &iface->addr6_list) {
+				if (iter_addr6++ < skip_addr6)
 					continue;
 				if (netlbl_unlabel_staticlist_gen(
-						     NLBL_UNLABEL_C_STATICLIST,
-						     iface,
-						     NULL,
-						     addr6,
-						     &cb_arg) < 0) {
+					      NLBL_UNLABEL_C_STATICLIST,
+					      iface,
+					      NULL,
+					      netlbl_unlhsh_addr6_entry(addr6),
+					      &cb_arg) < 0) {
 					iter_addr6--;
 					iter_chain--;
 					goto unlabel_staticlist_return;
@@ -1505,8 +1406,8 @@ static int netlbl_unlabel_staticlistdef(struct sk_buff *skb,
 	u32 skip_addr4 = cb->args[0];
 	u32 skip_addr6 = cb->args[1];
 	u32 iter_addr4 = 0, iter_addr6 = 0;
-	struct netlbl_unlhsh_addr4 *addr4;
-	struct netlbl_unlhsh_addr6 *addr6;
+	struct netlbl_af4list *addr4;
+	struct netlbl_af6list *addr6;
 
 	cb_arg.nl_cb = cb;
 	cb_arg.skb = skb;
@@ -1517,26 +1418,26 @@ static int netlbl_unlabel_staticlistdef(struct sk_buff *skb,
 	if (iface == NULL || !iface->valid)
 		goto unlabel_staticlistdef_return;
 
-	list_for_each_entry_rcu(addr4, &iface->addr4_list, list) {
-		if (!addr4->valid || iter_addr4++ < skip_addr4)
+	netlbl_af4list_foreach_rcu(addr4, &iface->addr4_list) {
+		if (iter_addr4++ < skip_addr4)
 			continue;
 		if (netlbl_unlabel_staticlist_gen(NLBL_UNLABEL_C_STATICLISTDEF,
-					   iface,
-					   addr4,
-					   NULL,
-					   &cb_arg) < 0) {
+					      iface,
+					      netlbl_unlhsh_addr4_entry(addr4),
+					      NULL,
+					      &cb_arg) < 0) {
 			iter_addr4--;
 			goto unlabel_staticlistdef_return;
 		}
 	}
-	list_for_each_entry_rcu(addr6, &iface->addr6_list, list) {
-		if (!addr6->valid || iter_addr6++ < skip_addr6)
+	netlbl_af6list_foreach_rcu(addr6, &iface->addr6_list) {
+		if (iter_addr6++ < skip_addr6)
 			continue;
 		if (netlbl_unlabel_staticlist_gen(NLBL_UNLABEL_C_STATICLISTDEF,
-					   iface,
-					   NULL,
-					   addr6,
-					   &cb_arg) < 0) {
+					      iface,
+					      NULL,
+					      netlbl_unlhsh_addr6_entry(addr6),
+					      &cb_arg) < 0) {
 			iter_addr6--;
 			goto unlabel_staticlistdef_return;
 		}
@@ -1718,25 +1619,27 @@ int netlbl_unlabel_getattr(const struct sk_buff *skb,
 	switch (family) {
 	case PF_INET: {
 		struct iphdr *hdr4;
-		struct netlbl_unlhsh_addr4 *addr4;
+		struct netlbl_af4list *addr4;
 
 		hdr4 = ip_hdr(skb);
-		addr4 = netlbl_unlhsh_search_addr4(hdr4->saddr, iface);
+		addr4 = netlbl_af4list_search(hdr4->saddr,
+					      &iface->addr4_list);
 		if (addr4 == NULL)
 			goto unlabel_getattr_nolabel;
-		secattr->attr.secid = addr4->secid;
+		secattr->attr.secid = netlbl_unlhsh_addr4_entry(addr4)->secid;
 		break;
 	}
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case PF_INET6: {
 		struct ipv6hdr *hdr6;
-		struct netlbl_unlhsh_addr6 *addr6;
+		struct netlbl_af6list *addr6;
 
 		hdr6 = ipv6_hdr(skb);
-		addr6 = netlbl_unlhsh_search_addr6(&hdr6->saddr, iface);
+		addr6 = netlbl_af6list_search(&hdr6->saddr,
+					      &iface->addr6_list);
 		if (addr6 == NULL)
 			goto unlabel_getattr_nolabel;
-		secattr->attr.secid = addr6->secid;
+		secattr->attr.secid = netlbl_unlhsh_addr6_entry(addr6)->secid;
 		break;
 	}
 #endif /* IPv6 */

