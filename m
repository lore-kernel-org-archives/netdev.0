From: Paul Moore <paul.moore@hp.com>
Subject: [RFC 2/4] NetLabel
Date: Thu, 25 May 2006 16:06:27 -0400
Message-ID: <44760E43.2060908@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@redhat.com>,
	Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:20161 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1030385AbWEYUGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 16:06:30 -0400
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is the core NetLabel subsystem.

 include/linux/netlink.h            |    1
 include/net/netlabel.h             |  355 +++++++++++++++
 net/Kconfig                        |    2
 net/Makefile                       |    1
 net/ipv4/Makefile                  |    1
 net/netlabel/Kconfig               |   47 +
 net/netlabel/Makefile              |   15
 net/netlabel/netlabel_domainhash.c |  629 ++++++++++++++++++++++++++
 net/netlabel/netlabel_domainhash.h |   64 ++
 net/netlabel/netlabel_kapi.c       |  374 +++++++++++++++
 net/netlabel/netlabel_mgmt.c       |  686 +++++++++++++++++++++++++++++
 net/netlabel/netlabel_mgmt.h       |  265 +++++++++++
 net/netlabel/netlabel_unlabeled.c  |  289 ++++++++++++
 net/netlabel/netlabel_unlabeled.h  |   90 +++
 net/netlabel/netlabel_user.c       |  166 +++++++
 net/netlabel/netlabel_user.h       |   42 +
 16 files changed, 3027 insertions(+)

--- linux-2.6.16.i686/include/linux/netlink.h	2006-05-23 11:34:52.000000000 -0400
+++ linux-2.6.16.i686-cipso/include/linux/netlink.h	2006-05-23 15:48:49.000000000 -0400
@@ -21,6 +21,7 @@
 #define NETLINK_DNRTMSG		14	/* DECnet routing messages */
 #define NETLINK_KOBJECT_UEVENT	15	/* Kernel messages to userspace */
 #define NETLINK_GENERIC		16
+#define NETLINK_NETLABEL	17	/* Network packet labeling */
 
 #define MAX_LINKS 32		
 
--- linux-2.6.16.i686/include/net/netlabel.h	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.6.16.i686-cipso/include/net/netlabel.h	2006-05-17 11:04:14.000000000 -0400
@@ -0,0 +1,355 @@
+/*
+ * NetLabel System
+ *
+ * The NetLabel system manages static and dynamic label mappings for network 
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
+#ifndef _NETLABEL_H
+#define _NETLABEL_H
+
+#include <linux/types.h>
+#include <linux/skbuff.h>
+#include <net/netlink.h>
+
+/*
+ * NetLabel - A management interface for maintaining network packet label
+ *            mapping tables for explicit packet labling protocols.
+ *
+ * Network protocols such as CIPSO and RIPSO require a label translation layer
+ * to convert the label on the packet into something meaningful on the host
+ * machine.  In the current Linux implementation these mapping tables live
+ * inside the kernel; NetLabel provides a mechanism for user space applications
+ * to manage these mapping tables.
+ *
+ * NetLabel makes use of NETLINK as a transport layer to send messages between
+ * kernel and user space.  The general format of a NetLabel message is shown
+ * below:
+ *
+ *  +----------+------------------+--------- --- -- -
+ *  | nlmsghdr | subsystem header | payload
+ *  +----------+------------------+--------- --- -- -
+ *
+ * The 'nlmsghdr' struct should be dealt with like any other NETLINK 'nlmsghdr'
+ * struct.  The subsystem header structure is dependent on the subsystem
+ * specified in the 'nlmsghdr->nlmsg_type' and should be defined below,
+ * supporting functions should be defined in the corresponding
+ * net/netlabel/netlabel_<subsys>.h|c file.
+ *
+ */
+
+/*
+ * NetLabel NETLINK protocol
+ */
+
+#define NETLBL_VER_STR              "0.11"
+#define NETLBL_VER_DATE             "04122006"
+
+/* NetLabel NETLINK groups */
+#define NETLBL_NLGRP_NONE           0x00000000
+#define NETLBL_NLGRP_MAX            0xffffffff
+
+/* NetLabel NETLINK types */
+#define NETLBL_NLTYPE_NONE          0
+#define NETLBL_NLTYPE_MGMT          1
+#define NETLBL_NLTYPE_RIPSO         2
+#define NETLBL_NLTYPE_CIPSOV4       3
+#define NETLBL_NLTYPE_CIPSOV6       4
+#define NETLBL_NLTYPE_UNLABELED     5
+
+/* Generic return codes */
+#define NETLBL_E_OK         0
+#define NETLBL_E_ERR        1
+#define NETLBL_E_BADCMD     16
+
+/*
+ * Helper functions
+ */
+
+/**
+ * netlbl_put_u8 - Write a u8 value into a buffer
+ * @buffer: the buffer
+ * @val: the value
+ *
+ * Description:
+ * Write the value specified in @val into the buffer specified by @buffer.
+ *
+ */
+static inline void netlbl_put_u8(unsigned char *buffer, const u8 val)
+{
+	*(u8 *)buffer = val;
+}
+
+/**
+ * netlbl_put_u32 - Write a u32 value into a buffer
+ * @buffer: the buffer
+ * @val: the value
+ *
+ * Description:
+ * Write the value specified in @val into the buffer specified by @buffer.
+ *
+ */
+static inline void netlbl_put_u32(unsigned char *buffer, const u32 val)
+{
+	*(u32 *)buffer = val;
+}
+
+/**
+ * netlbl_put_str - Write a string into a buffer
+ * @buffer: the buffer
+ * @val: the string
+ *
+ * Description:
+ * Write the string specified in @val into the buffer specified by @buffer.
+ *
+ */
+static inline void netlbl_put_str(unsigned char *buffer, const char *val)
+{
+	strcpy((char *)buffer, val);
+}
+
+/**
+ * netlbl_put_hdr - Write a NETLINK header into a buffer
+ * @buffer: the buffer
+ * @msg_type: the NETLINK message type
+ * @msg_len: the NETLINK message length
+ * @msg_flags: the NETLINK message flags
+ * @msg_pid: the NETLINK message PID
+ * @msg_seq: the NETLINK message sequence number
+ *
+ * Description:
+ * Use the given values to write a NETLINK header into the given buffer.
+ *
+ */
+static inline void netlbl_put_hdr(unsigned char *buffer,
+				  const u32 msg_type,
+				  const u16 msg_len,
+				  const u16 msg_flags, 
+				  const u32 msg_pid, 
+				  const u32 msg_seq)
+{
+	struct nlmsghdr *hdr = (struct nlmsghdr *)buffer;
+	hdr->nlmsg_len = msg_len;
+	hdr->nlmsg_type = msg_type;
+	hdr->nlmsg_flags = msg_flags;
+	hdr->nlmsg_seq = msg_seq;
+	hdr->nlmsg_pid = msg_pid;
+}
+
+/**
+ * netlbl_put_u8 - Write a u8 value into a buffer and increment the buffer
+ * @buffer: the buffer
+ * @val: the value
+ *
+ * Description:
+ * Write the value specified in @val into the buffer specified by @buffer
+ * and advance the buffer pointer past the newly written value.
+ *
+ */
+static inline void netlbl_putinc_u8(unsigned char **buffer, const u8 val)
+{
+	netlbl_put_u8(*buffer, val);
+	*buffer += sizeof(u8);
+}
+
+/**
+ * netlbl_put_u32 - Write a u32 value into a buffer and increment the buffer
+ * @buffer: the buffer
+ * @val: the value
+ *
+ * Description:
+ * Write the value specified in @val into the buffer specified by @buffer
+ * and advance the buffer pointer past the newly written value.
+ *
+ */
+static inline void netlbl_putinc_u32(unsigned char **buffer, const u32 val)
+{
+	netlbl_put_u32(*buffer, val);
+	*buffer += sizeof(u32);
+}
+
+/**
+ * netlbl_put_u8 - Write a string into a buffer and increment the buffer
+ * @buffer: the buffer
+ * @val: the value
+ *
+ * Description:
+ * Write the string specified in @val into the buffer specified by @buffer
+ * and advance the buffer pointer past the newly written value.
+ *
+ */
+static inline void netlbl_putinc_str(unsigned char **buffer, const char *val)
+{
+	netlbl_put_str(*buffer, val);
+	*buffer += strlen(val) + 1;
+}
+
+/**
+ * netlbl_put_hdr - Write a NETLINK header into a buffer and increment the ptr
+ * @buffer: the buffer
+ * @msg_type: the NETLINK message type
+ * @msg_len: the NETLINK message length
+ * @msg_flags: the NETLINK message flags
+ * @msg_pid: the NETLINK message PID
+ * @msg_seq: the NETLINK message sequence number
+ *
+ * Description:
+ * Use the given values to write a NETLINK header into the given buffer and
+ * then increment the buffer pointer past the header.
+ *
+ */
+static inline void netlbl_putinc_hdr(unsigned char **buffer,
+				     const u32 msg_type,
+				     const u16 msg_len,
+				     const u16 msg_flags, 
+				     const u32 msg_pid, 
+				     const u32 msg_seq)
+{
+	netlbl_put_hdr(*buffer, 
+		       msg_type, 
+		       msg_len, 
+		       msg_flags, 
+		       msg_pid, 
+		       msg_seq);
+	*buffer += NLMSG_HDRLEN;
+}
+
+/**
+ * netlbl_get_u8 - Read a u8 value from a buffer
+ * @buffer: the buffer
+ *
+ * Description:
+ * Return a u8 value pointed to by @buffer.
+ *
+ */
+static inline u8 netlbl_get_u8(const unsigned char *buffer)
+{
+	return *(u8 *)buffer;
+}
+
+/**
+ * netlbl_get_u32 - Read a u32 value from a buffer
+ * @buffer: the buffer
+ *
+ * Description:
+ * Return a u8 value pointed to by @buffer.
+ *
+ */
+static inline u32 netlbl_get_u32(const unsigned char *buffer)
+{
+	return *(u32 *)buffer;
+}
+
+/**
+ * netlbl_getinc_u8 - Read a u8 value from a buffer and increment the buffer
+ * @buffer: the buffer
+ *
+ * Description:
+ * Return a u8 value pointed to by @buffer and increment the buffer pointer
+ * past the value.
+ *
+ */
+static inline u8 netlbl_getinc_u8(unsigned char **buffer)
+{
+	u8 val = netlbl_get_u8(*buffer);
+	*buffer += sizeof(u8);
+	return val;
+}
+
+/**
+ * netlbl_getinc_u32 - Read a u32 value from a buffer and increment the buffer
+ * @buffer: the buffer
+ *
+ * Description:
+ * Return a u32 value pointed to by @buffer and increment the buffer pointer
+ * past the value.
+ *
+ */
+static inline u32 netlbl_getinc_u32(unsigned char **buffer)
+{
+	u32 val = netlbl_get_u32(*buffer);
+	*buffer += sizeof(u32);
+	return val;
+}
+
+/*
+ * NetLabel - Kernel API for accessing the network packet label mappings.
+ *
+ * The following functions are provided for use by other kernel modules,
+ * specifically kernel LSM modules, to provide a consistent, transparent API
+ * for dealing with explicit packet labeling protocols such as CIPSO and
+ * RIPSO.  The functions defined here are implemented in the 
+ * net/netlabel/netlabel_kapi.c file.
+ *
+ */
+
+/* Domain mapping definition struct */
+struct netlbl_dom_map;
+
+/* Domain mapping operations */
+int netlbl_domhsh_remove(const char *domain);
+
+/* LSM security attributes */
+struct netlbl_lsm_cache {
+	void (*free) (const void *data);
+	void *data;
+};
+struct netlbl_lsm_secattr {
+	char *domain;
+
+	u32 mls_lvl;
+	unsigned char *mls_cat;
+	u32 mls_cat_len;
+
+	struct netlbl_lsm_cache cache;
+
+	u32 set_domain:1, 
+	    set_mls_lvl:1,
+	    set_mls_cat:1,
+	    set_cache:1,
+	    unused:28;
+};
+
+/* LSM security attribute operations */
+struct netlbl_lsm_secattr *netlbl_secattr_alloc(const int flags);
+void netlbl_secattr_free(struct netlbl_lsm_secattr *secattr);
+int netlbl_secattr_init(struct netlbl_lsm_secattr *secattr);
+void netlbl_secattr_destroy(struct netlbl_lsm_secattr *secattr);
+
+/* LSM protocol operations */
+int netlbl_socket_setattr(const struct socket *sock,
+			  const struct netlbl_lsm_secattr *secattr);
+int netlbl_socket_peekattr(const struct socket *sock, 
+			   struct netlbl_lsm_secattr *secattr);
+int netlbl_skbuff_getattr(const struct sk_buff *skb, 
+			  struct netlbl_lsm_secattr *secattr);
+int netlbl_skbuff_err(struct sk_buff *skb, int error);
+
+/* LSM label mapping cache operations */
+int netlbl_cache_invalidate(void);
+int netlbl_cache_add(const struct sk_buff *skb, 
+		     const struct netlbl_lsm_secattr *secattr);
+
+#endif /* _NETLABEL_H */
--- linux-2.6.16.i686/net/ipv4/Makefile	2006-05-23 11:34:55.000000000 -0400
+++ linux-2.6.16.i686-cipso/net/ipv4/Makefile	2006-05-23 15:52:36.000000000 -0400
@@ -42,6 +42,7 @@ obj-$(CONFIG_TCP_CONG_HYBLA) += tcp_hybl
 obj-$(CONFIG_TCP_CONG_HTCP) += tcp_htcp.o
 obj-$(CONFIG_TCP_CONG_VEGAS) += tcp_vegas.o
 obj-$(CONFIG_TCP_CONG_SCALABLE) += tcp_scalable.o
+obj-$(CONFIG_NETLABEL_CIPSOV4) += cipso_ipv4.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o
--- linux-2.6.16.i686/net/Kconfig	2006-05-23 11:35:14.000000000 -0400
+++ linux-2.6.16.i686-cipso/net/Kconfig	2006-05-23 15:51:35.000000000 -0400
@@ -228,6 +228,8 @@ source "net/tux/Kconfig"
 config WIRELESS_EXT
 	bool
 
+source "net/netlabel/Kconfig"
+
 endif   # if NET
 endmenu # Networking
 
--- linux-2.6.16.i686/net/Makefile	2006-05-23 11:35:14.000000000 -0400
+++ linux-2.6.16.i686-cipso/net/Makefile	2006-05-23 15:52:03.000000000 -0400
@@ -47,6 +47,7 @@ obj-$(CONFIG_IP_DCCP)		+= dccp/
 obj-$(CONFIG_IP_SCTP)		+= sctp/
 obj-$(CONFIG_IEEE80211)		+= ieee80211/
 obj-$(CONFIG_TIPC)		+= tipc/
+obj-$(CONFIG_NETLABEL)		+= netlabel/
 
 ifeq ($(CONFIG_NET),y)
 obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
--- linux-2.6.16.i686/net/netlabel/Kconfig	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.6.16.i686-cipso/net/netlabel/Kconfig	2006-05-23 10:42:38.000000000 -0400
@@ -0,0 +1,47 @@
+#
+# NetLabel configuration
+#
+
+config NETLABEL
+	tristate "NetLabel subsystem support"
+	depends on NET && SECURITY
+	default n
+	---help---
+	  NetLabel provides support for network packet labeling protocols.  For
+	  more information see Documentation/netlabel.
+
+	  If you are unsure, say N.
+
+config NETLABEL_CIPSOV4
+	tristate "CIPSO for IPv4"
+	depends on NETLABEL
+	default n
+	---help---
+	  The Commercial IP Security Option (CIPSO) is commonly used in
+	  trusted multi-level security networks.  This implementation is based
+	  on the IETF draft draft-ietf-cipso-ipsecurity-01.txt and FIPS-188.
+
+	  If you are unsure say N.
+
+config NETLABEL_UNLABELED
+	tristate "Unlabeled packets"
+	depends on NETLABEL
+	default y
+	---help---
+	  This adds support for sending and receiving unlabeled packets through
+	  the NetLabel system.
+
+	  If you are unsure say Y.
+
+config NETLABEL_UNLABELED_DEFAULT
+	bool "Enable unlabeled traffic by default"
+	depends on NETLABEL_UNLABELED
+	default y
+	---help---
+	  Enabling this option allows unlabeled (i.e. normal) network traffic
+	  on the system without any user configuration at bootup.  Disabling
+	  this option means the user must configure the NetLabel subsystem
+	  before any type of network traffic can be sent or received on the
+	  system.
+
+	  If you are unsure say Y.
--- linux-2.6.16.i686/net/netlabel/Makefile	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.6.16.i686-cipso/net/netlabel/Makefile	2006-05-12 11:04:00.000000000 -0400
@@ -0,0 +1,15 @@
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
+obj-$(CONFIG_NETLABEL_UNLABELED)	+= netlabel_unlabeled.o
+obj-$(CONFIG_NETLABEL_CIPSOV4)		+= netlabel_cipso_v4.o
--- linux-2.6.16.i686/net/netlabel/netlabel_domainhash.c	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.6.16.i686-cipso/net/netlabel/netlabel_domainhash.c	2006-05-24 11:09:41.000000000 -0400
@@ -0,0 +1,629 @@
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
+   hash table should be okay */
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
+	if (ptr->domain)
+		kfree(ptr->domain);
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
+static inline u32 netlbl_domhsh_hash(const char *domain)
+{
+	char *p;
+	char *keyp = (char *)domain;
+	u32 size;
+	u32 val = 0;
+
+	/* This is taken (with slight modification) from 
+	   security/selinux/ss/symtab.c:symhash() */
+
+	size = strlen(keyp);
+	for (p = keyp; (p - keyp) < size; p++)
+		val = (val << 4 | (val >> (8 * sizeof(u32) - 4))) ^ (*p);
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
+static inline struct netlbl_dom_map *netlbl_domhsh_search(const char *domain, 
+							  const u32 def)
+{
+	u32 bkt;
+	struct netlbl_dom_map *iter;
+
+	if (domain != NULL) {
+		bkt = netlbl_domhsh_hash(domain);
+		list_for_each_entry_rcu(iter, &netlbl_domhsh->tbl[bkt], list)
+			if (strcmp(iter->domain, domain) == 0 && iter->valid)
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
+ * netlbl_user_init() during module load.  Returns zero on success, non-zero
+ * values on error.
+ *
+ */
+int netlbl_domhsh_init(const u32 size)
+{
+	u32 iter;
+	struct netlbl_domhsh_tbl *hsh_tbl;
+
+	BUG_ON(netlbl_domhsh);
+	BUG_ON(netlbl_domhsh_def);
+	if (size <= 0)
+		return -EINVAL;
+
+	hsh_tbl = kmalloc(sizeof(struct netlbl_domhsh_tbl), GFP_KERNEL);
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
+ * netlbl_domhsh_exit - Cleanup for the domain hash
+ *
+ * Description:
+ * Clears and frees the domain hash table.  No real serious effort is made
+ * towards locking but that shouldn't be an issue since we should only be
+ * called when the module is being unloaded.  Returns zero on success, non-zero
+ * values on error.
+ *
+ */
+int netlbl_domhsh_exit(void)
+{
+	u32 iter_bkt;
+	struct netlbl_domhsh_tbl *hsh_tbl;
+	struct netlbl_dom_map *iter_list;
+
+	BUG_ON(!netlbl_domhsh);
+
+	rcu_read_lock();
+	iter_list = rcu_dereference(netlbl_domhsh_def);
+	spin_lock(&netlbl_domhsh_def_lock);
+	rcu_assign_pointer(netlbl_domhsh_def, NULL);
+	spin_unlock(&netlbl_domhsh_def_lock);
+	rcu_read_unlock();
+
+	if (iter_list) {
+		synchronize_rcu();
+		netlbl_domhsh_free_entry(&iter_list->rcu);
+	}
+
+	rcu_read_lock();
+	hsh_tbl = rcu_dereference(netlbl_domhsh);
+	spin_lock(&netlbl_domhsh_lock);
+	rcu_assign_pointer(netlbl_domhsh, NULL);
+	spin_unlock(&netlbl_domhsh_lock);
+	rcu_read_unlock();
+
+	synchronize_rcu();
+
+	/* PM - it probably doesn't matter, but do we need to use the rcu list
+	   functions here since we are the only one who has access to the
+	   list now? */
+	for (iter_bkt = 0; iter_bkt < hsh_tbl->size; iter_bkt++)
+		list_for_each_entry_rcu(iter_list,
+					&hsh_tbl->tbl[iter_bkt], list) {
+			iter_list->valid = 0;
+			list_del_rcu(&iter_list->list);
+			netlbl_domhsh_free_entry(&iter_list->rcu);
+		}
+	kfree(hsh_tbl->tbl);
+	kfree(hsh_tbl);
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
+	int ret_val = -EPERM;
+	u32 bkt;
+
+	BUG_ON(entry == NULL);
+
+	switch (entry->type) {
+#ifdef CONFIG_NETLABEL_UNLABELED
+	case NETLBL_NLTYPE_UNLABELED:
+		ret_val = 0;
+		break;
+#endif
+#ifdef CONFIG_NETLABEL_CIPSOV4
+	case NETLBL_NLTYPE_CIPSOV4:
+		ret_val = cipso_v4_doi_domhsh_add(entry->type_def.cipsov4,
+						  entry->domain);
+		break;
+#endif
+	default:
+		BUG();
+	}
+	if (ret_val != 0)
+		return ret_val;
+
+	entry->valid = 1;
+	INIT_RCU_HEAD(&entry->rcu);
+
+	rcu_read_lock();
+	if (entry->domain != NULL &&
+	    netlbl_domhsh_search(entry->domain, 0) == NULL) {
+		bkt = netlbl_domhsh_hash(entry->domain);
+		spin_lock(&netlbl_domhsh_lock);
+		list_add_tail_rcu(&entry->list, &netlbl_domhsh->tbl[bkt]);
+		spin_unlock(&netlbl_domhsh_lock);
+	} else if (entry->domain == NULL &&
+		   rcu_dereference(netlbl_domhsh_def) == NULL) {
+		INIT_LIST_HEAD(&entry->list);
+		spin_lock(&netlbl_domhsh_def_lock);
+		rcu_assign_pointer(netlbl_domhsh_def, entry);
+		spin_unlock(&netlbl_domhsh_def_lock);
+	} else {
+		rcu_read_unlock();
+		switch (entry->type) {
+#ifdef CONFIG_NETLABEL_UNLABELED
+		case NETLBL_NLTYPE_UNLABELED:
+			break;
+#endif
+#ifdef CONFIG_NETLABEL_CIPSOV4
+		case NETLBL_NLTYPE_CIPSOV4:
+			if (cipso_v4_doi_domhsh_remove(entry->type_def.cipsov4,
+						       entry->domain) != 0)
+				BUG();
+			break;
+#endif
+		default:
+			BUG();
+		}
+		return -EPERM;
+	}
+	rcu_read_unlock();
+
+	return 0;
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
+	int ret_val = -EPERM;
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
+#ifdef CONFIG_NETLABEL_UNLABELED
+	case NETLBL_NLTYPE_UNLABELED:
+		break;
+#endif
+#ifdef CONFIG_NETLABEL_CIPSOV4
+	case NETLBL_NLTYPE_CIPSOV4:
+		if (cipso_v4_doi_domhsh_remove(entry->type_def.cipsov4,
+					       entry->domain) != 0)
+			goto remove_return;
+		break;
+#endif
+	default:
+		BUG();
+	}
+	if (entry != rcu_dereference(netlbl_domhsh_def)) {
+		spin_lock(&netlbl_domhsh_lock);
+		entry->valid = 0;
+		list_del_rcu(&entry->list);
+		spin_unlock(&netlbl_domhsh_lock);
+	} else {
+		spin_lock(&netlbl_domhsh_def_lock);
+		entry->valid = 0;
+		rcu_assign_pointer(netlbl_domhsh_def, NULL);
+		spin_unlock(&netlbl_domhsh_def_lock);
+	}
+	call_rcu(&entry->rcu, netlbl_domhsh_free_entry);
+
+	ret_val = 0;
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
+ * a nlmsghdr struct and a netlbl_mgmt_msghdr struct.  See netlabel.h for the
+ * DOMAIN message format.  Returns a pointer to a sk_buff on success, NULL on
+ * error.
+ *
+ */
+struct sk_buff *netlbl_domhsh_dump(void)
+{
+	struct sk_buff *skb;
+	unsigned char *buf;
+	u32 buf_len;
+	u32 bkt_iter;
+	u32 dom_cnt = 0;
+	struct netlbl_domhsh_tbl *hsh_tbl;
+	struct netlbl_dom_map *list_iter;
+	u32 tmp_len;
+
+	/* XXX - This is kinda ugly as we have to go through the table once to
+	   determine how large of a buffer we need, drop the locks, allocate
+	   the buffer, grab the locks, and finally fill the buffer.  The
+	   problem is that there is that open window where the table could
+	   grow and we will end up short on space. */
+
+	buf_len = 4;
+	rcu_read_lock();
+	hsh_tbl = rcu_dereference(netlbl_domhsh);
+	for (bkt_iter = 0; bkt_iter < hsh_tbl->size; bkt_iter++)
+		list_for_each_entry_rcu(list_iter,
+					&hsh_tbl->tbl[bkt_iter], list) {
+			buf_len += 9 + strlen(list_iter->domain);
+			switch (list_iter->type) {
+#ifdef CONFIG_NETLABEL_UNLABELED
+			case NETLBL_NLTYPE_UNLABELED:
+				break;
+#endif
+#ifdef CONFIG_NETLABEL_CIPSOV4
+			case NETLBL_NLTYPE_CIPSOV4:
+				buf_len += 8;
+				break;
+#endif
+			default:
+				rcu_read_unlock();
+				BUG();
+			}
+			dom_cnt++;
+		}
+	rcu_read_unlock();
+
+	skb = alloc_skb(NLMSG_SPACE(sizeof(struct netlbl_mgmt_msghdr) +
+				    buf_len), GFP_KERNEL);
+	if (skb == NULL)
+		return NULL;
+	skb_reserve(skb, NLMSG_SPACE(sizeof(struct netlbl_mgmt_msghdr)));
+	tmp_len = skb_tailroom(skb);
+	if (tmp_len < buf_len)
+		goto dump_failure;
+	buf = skb_put(skb, buf_len);
+	buf_len -= 4;
+	netlbl_putinc_u32(&buf, dom_cnt);
+
+	rcu_read_lock();
+	hsh_tbl = rcu_dereference(netlbl_domhsh);
+	for (bkt_iter = 0; bkt_iter < hsh_tbl->size; bkt_iter++)
+		list_for_each_entry_rcu(list_iter,
+					&hsh_tbl->tbl[bkt_iter], list) {
+			tmp_len = strlen(list_iter->domain) + 1;
+			if (buf_len < tmp_len + 8) {
+				rcu_read_unlock();
+				goto dump_failure;
+			}
+			buf_len -= tmp_len + 8;
+			netlbl_putinc_u32(&buf, tmp_len);
+			netlbl_putinc_str(&buf, list_iter->domain);
+			netlbl_putinc_u32(&buf, list_iter->type);
+			switch (list_iter->type) {
+#ifdef CONFIG_NETLABEL_UNLABELED
+			case NETLBL_NLTYPE_UNLABELED:
+				break;
+#endif
+#ifdef CONFIG_NETLABEL_CIPSOV4
+			case NETLBL_NLTYPE_CIPSOV4:
+				if (buf_len < 8) {
+					rcu_read_unlock();
+					goto dump_failure;
+				}
+				buf_len -= 8;
+				netlbl_putinc_u32(&buf,
+					    list_iter->type_def.cipsov4->type);
+				netlbl_putinc_u32(&buf,
+					    list_iter->type_def.cipsov4->doi);
+				break;
+#endif
+			default:
+				rcu_read_unlock();
+				BUG();
+			}
+		}
+	rcu_read_unlock();
+
+	return skb;
+
+dump_failure:
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
+ * skb_buff for a nlmsghdr struct and a netlbl_mgmt_msghdr struct.  See
+ * netlabel.h for the DEFDOMAIN message format.  Returns a pointer to a
+ * sk_buff on success, NULL on error.
+ *
+ */
+struct sk_buff *netlbl_domhsh_dump_default(void)
+{
+	struct sk_buff *skb;
+	unsigned char *buf;
+	u32 buf_len;
+	u32 tmp_len;
+	struct netlbl_dom_map *entry;
+
+	/* XXX - This is kinda ugly as we have to go look at the default 
+	   mapping once to determine how large of a buffer we need, drop the
+	   locks, allocate the buffer, grab the locks, and finally fill the
+	   buffer.  The problem is that there is that open window where the
+	   default mapping could change on us, if that is the case we fail. */
+
+	buf_len = 4;
+	rcu_read_lock();
+	entry = rcu_dereference(netlbl_domhsh_def);
+	if (entry != NULL)
+		switch (entry->type) {
+#ifdef CONFIG_NETLABEL_UNLABELED
+		case NETLBL_NLTYPE_UNLABELED:
+			break;
+#endif
+#ifdef CONFIG_NETLABEL_CIPSOV4
+		case NETLBL_NLTYPE_CIPSOV4:
+			buf_len += 8;
+			break;
+#endif
+		default:
+			BUG();
+		}
+	rcu_read_unlock();
+
+	skb = alloc_skb(NLMSG_SPACE(sizeof(struct netlbl_mgmt_msghdr) +
+				    buf_len), GFP_KERNEL);
+	if (skb == NULL)
+		return NULL;
+	skb_reserve(skb, NLMSG_SPACE(sizeof(struct netlbl_mgmt_msghdr)));
+	tmp_len = skb_tailroom(skb);
+	if (tmp_len < buf_len)
+		goto dump_default_failure;
+	buf = skb_put(skb, buf_len);
+
+	rcu_read_lock();
+	if (entry != rcu_dereference(netlbl_domhsh_def)) {
+		rcu_read_unlock();
+		goto dump_default_failure;
+	}
+	buf_len -= 4;
+	if (entry != NULL) {
+		netlbl_putinc_u32(&buf, entry->type);
+		switch (entry->type) {
+#ifdef CONFIG_NETLABEL_UNLABELED
+		case NETLBL_NLTYPE_UNLABELED:
+			break;
+#endif
+#ifdef CONFIG_NETLABEL_CIPSOV4
+		case NETLBL_NLTYPE_CIPSOV4:
+			if (buf_len < 8) {
+				rcu_read_unlock();
+				goto dump_default_failure;
+			}
+			buf_len -= 8;
+			netlbl_putinc_u32(&buf, entry->type_def.cipsov4->type);
+			netlbl_putinc_u32(&buf, entry->type_def.cipsov4->doi);
+			break;
+#endif
+		default:
+			rcu_read_unlock();
+			BUG();
+		}
+	} else
+		netlbl_putinc_u32(&buf, NETLBL_NLTYPE_NONE);
+	rcu_read_unlock();
+
+	return skb;
+
+dump_default_failure:
+	kfree_skb(skb);
+	return NULL;
+}
--- linux-2.6.16.i686/net/netlabel/netlabel_domainhash.h	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.6.16.i686-cipso/net/netlabel/netlabel_domainhash.h	2006-05-12 15:39:28.000000000 -0400
@@ -0,0 +1,64 @@
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
+/* init/exit functions */
+int netlbl_domhsh_init(const u32 size);
+int netlbl_domhsh_exit(void);
+
+/* Manipulate the domain hash table */
+int netlbl_domhsh_add(struct netlbl_dom_map *entry);
+int netlbl_domhsh_add_default(struct netlbl_dom_map *entry);
+int netlbl_domhsh_remove_default(void);
+struct netlbl_dom_map *netlbl_domhsh_getentry(const char *domain);
+struct sk_buff *netlbl_domhsh_dump(void);
+struct sk_buff *netlbl_domhsh_dump_default(void);
+
+#endif
--- linux-2.6.16.i686/net/netlabel/netlabel_kapi.c	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.6.16.i686-cipso/net/netlabel/netlabel_kapi.c	2006-05-25 11:30:04.000000000 -0400
@@ -0,0 +1,374 @@
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
+#include <linux/module.h>
+#include <linux/types.h>
+#include <net/ip.h>
+#include <net/netlabel.h>
+#include <net/cipso_ipv4.h>
+#include <asm/bug.h>
+
+#include "netlabel_domainhash.h"
+#include "netlabel_user.h"
+#include "netlabel_unlabeled.h"
+
+/*
+ * LSM Functions
+ */
+
+/**
+ * netlbl_secattr_alloc - Allocate and initialize a netlbl_lsm_secattr struct
+ * @flags: the memory allocation flags
+ *
+ * Description:
+ * Allocate and initialize a netlbl_lsm_secattr struct.  Returns a valid
+ * pointer on success, or NULL on failure.
+ *
+ */
+struct netlbl_lsm_secattr *netlbl_secattr_alloc(const int flags)
+{
+	return kzalloc(sizeof(struct netlbl_lsm_secattr), flags);
+}
+
+/**
+ * netlbl_secattr_free - Frees a netlbl_lsm_secattr struct
+ * @secattr: the struct to free
+ *
+ * Description:
+ * Frees @secattr including all of the internal buffers.
+ *
+ */
+void netlbl_secattr_free(struct netlbl_lsm_secattr *secattr)
+{
+	BUG_ON(secattr == NULL);
+	if (secattr->set_domain)
+		kfree(secattr->domain);
+	if (secattr->set_mls_cat)
+		kfree(secattr->mls_cat);
+	if (secattr->set_cache && secattr->cache.free)
+		secattr->cache.free(secattr->cache.data);
+	kfree(secattr);
+}
+
+/**
+ * netlbl_secattr_init - Initialize a netlbl_lsm_secattr struct
+ * @secattr: the struct to initialize
+ *
+ * Description:
+ * Initialize an already allocated netlbl_lsm_secattr struct.  Returns zero on
+ * success, negative values on error.
+ *
+ */
+int netlbl_secattr_init(struct netlbl_lsm_secattr *secattr)
+{
+	BUG_ON(secattr == NULL);
+	memset(secattr, 0, sizeof(struct netlbl_lsm_secattr));
+	return 0;
+}
+
+/**
+ * netlbl_secattr_destroy - Clears a netlbl_lsm_secattr struct
+ * @secattr: the struct to clear
+ *
+ * Description:
+ * Destroys the @secattr struct, including freeing all of the internal buffers.
+ * On return the struct is suitable for reuse.
+ *
+ */
+void netlbl_secattr_destroy(struct netlbl_lsm_secattr *secattr)
+{
+	BUG_ON(secattr == NULL);
+	if (secattr->set_domain)
+		kfree(secattr->domain);
+	if (secattr->set_mls_cat)
+		kfree(secattr->mls_cat);
+	if (secattr->set_cache && secattr->cache.free)
+		secattr->cache.free(secattr->cache.data);
+	memset(secattr, 0, sizeof(struct netlbl_lsm_secattr));
+}
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
+	int ret_val;
+	struct netlbl_dom_map *dom_entry;
+
+	BUG_ON(sock == NULL || sock->sk == NULL ||
+	       sock->sk->sk_family != PF_INET || secattr == NULL ||
+	       secattr->set_domain == 0);
+
+	rcu_read_lock();
+	dom_entry = netlbl_domhsh_getentry(secattr->domain);
+	if (dom_entry == NULL) {
+		rcu_read_unlock();
+		return -ENOENT;
+	}
+	switch (dom_entry->type) {
+#ifdef CONFIG_NETLABEL_CIPSOV4
+	case NETLBL_NLTYPE_CIPSOV4:
+		ret_val = cipso_v4_setopt(sock,
+					  dom_entry->type_def.cipsov4,
+					  secattr);
+		break;
+#endif
+#ifdef CONFIG_NETLABEL_UNLABELED
+	case NETLBL_NLTYPE_UNLABELED:
+		ret_val = 0;
+		break;
+#endif
+	default:
+		ret_val = -ENOENT;
+	}
+	rcu_read_unlock();
+
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
+	int ret_val = -ENOMSG;
+	struct sk_buff_head *sock_queue;
+	struct sk_buff *skb;
+	struct sk_buff *skb_tmp = NULL;
+
+	BUG_ON(sock == NULL || sock->sk == NULL || 
+	       sock->sk->sk_family != PF_INET || secattr == NULL);
+
+	sock_queue = &sock->sk->sk_receive_queue;
+	/* XXX - We could just take the lock here and do a skb_peek() but we
+	         might end up holding the lock for a long time so grab the
+		 lock, do a peek, and clone the result */
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
+ * netlbl_skbuff_getattr - Determine the security attributes of a packet
+ * @skb: the packet
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Examines the given packet to see if a recognized form of packet labeling
+ * is present, if so it parses the packet label and returns the security
+ * attributes in @secattr.  The caller must set the @secattr->lsm_type field
+ * before calling this function so we know what information to return.
+ * Returns zero on success, negative values on failure.
+ *
+ */
+int netlbl_skbuff_getattr(const struct sk_buff *skb, 
+			  struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val = -ENOMSG;
+
+	BUG_ON(skb == NULL || secattr == NULL);
+
+#ifdef CONFIG_NETLABEL_CIPSOV4
+	if (CIPSO_V4_OPTEXIST(skb)) {
+		ret_val = cipso_v4_getopt(skb, secattr);
+		goto skbuff_read_return;
+	}
+#endif
+
+#ifdef CONFIG_NETLABEL_UNLABELED
+	ret_val = netlbl_unlabel_getattr(skb, secattr);
+#endif
+
+skbuff_read_return:
+	return ret_val;
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
+ * according to the packet's labeling protocol.  Returns zero on success,
+ * negative values on failure.
+ *
+ */
+int netlbl_skbuff_err(struct sk_buff *skb, int error)
+{
+	BUG_ON(skb == NULL || error == 0);
+
+#ifdef CONFIG_NETLABEL_CIPSOV4
+	if (CIPSO_V4_OPTEXIST(skb))
+		return cipso_v4_error(skb, error, 0);
+#endif
+
+	return -ENOMSG;
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
+int netlbl_cache_invalidate(void)
+{
+	return cipso_v4_cache_invalidate();
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
+	int ret_val = -ENOMSG;
+
+	BUG_ON(skb == NULL || secattr == NULL);
+
+	if (secattr->set_cache != 1)
+		return -ENOMSG;
+
+	if (CIPSO_V4_OPTEXIST(skb))
+		ret_val = cipso_v4_cache_add(skb, secattr);
+
+	return ret_val;
+}
+
+/*
+ * Netfilter Functions
+ */
+
+/* XXX - TBD */
+
+/*
+ * Module Functions
+ */
+
+/**
+ * netlbl_init - Init for the NetLabel module
+ *
+ * Description:
+ * Perform the initialization of the NetLabel module before first use.
+ *
+ */
+static int __init netlbl_init(void)
+{
+	printk(KERN_INFO "NetLabel: Initializing (v%s %s)\n",
+	       NETLBL_VER_STR, NETLBL_VER_DATE);
+	printk(KERN_INFO "NetLabel:  domain hash size = %u\n",
+	       (1 << NETLBL_DOMHSH_BITSIZE));
+	printk(KERN_INFO "NetLabel:  protocols ="
+#ifdef CONFIG_NETLABEL_UNLABELED
+	       " UNLABELED"
+#endif
+#ifdef CONFIG_NETLABEL_CIPSOV4
+	       " CIPSOv4"
+#endif
+	       "\n");
+
+	if (netlbl_domhsh_init(NETLBL_DOMHSH_BITSIZE) != 0)
+		return -ENOMEM;
+	if (netlbl_netlink_init() != 0) {
+		netlbl_domhsh_exit();
+		return -ENOMEM;
+	}
+
+#ifdef CONFIG_NETLABEL_UNLABELED_DEFAULT
+	if (netlbl_unlabel_defconf() != 0) {
+		netlbl_netlink_exit();
+		netlbl_domhsh_exit();
+		return -ENOMEM;
+	}
+	printk(KERN_INFO "NetLabel:  unlabeled traffic allowed by default\n");
+#endif
+
+	return 0;
+}
+
+/**
+ * netlbl_exit - Cleanup for the NetLabel module
+ * 
+ * Description:
+ * Perform any cleanup required before removing the NetLabel module.
+ *
+ */
+static void __exit netlbl_exit(void)
+{
+	printk(KERN_INFO "NetLabel: Exiting\n");
+
+	netlbl_netlink_exit();
+	netlbl_domhsh_exit();
+}
+
+module_init(netlbl_init);
+module_exit(netlbl_exit);
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Paul Moore <paul.moore@hp.com>");
--- linux-2.6.16.i686/net/netlabel/netlabel_mgmt.c	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.6.16.i686-cipso/net/netlabel/netlabel_mgmt.c	2006-05-17 18:23:24.000000000 -0400
@@ -0,0 +1,686 @@
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
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/socket.h>
+#include <linux/string.h>
+#include <linux/skbuff.h>
+#include <net/sock.h>
+#include <net/netlink.h>
+#include <net/netlabel.h>
+#include <net/cipso_ipv4.h>
+
+#include "netlabel_domainhash.h"
+#include "netlabel_user.h"
+#include "netlabel_mgmt.h"
+
+/*
+ * Local Prototypes
+ */
+
+static int netlbl_mgmt_send_ack(const struct nlmsghdr *nl_hdr,
+				const u32 ret_code);
+
+/*
+ * Helper Functions
+ */
+
+/**
+ * netlbl_mgmt_put_hdr - Write a MGMT NetLabel header into a buffer
+ * @buffer: the buffer
+ * @opcode: the NetLabel Management opcode
+ *
+ * Description:
+ * Use the given values to write a NetLabel Management header into the given
+ * buffer.
+ *
+ */
+static inline void netlbl_mgmt_put_hdr(unsigned char *buffer, const u32 opcode)
+{
+	((struct netlbl_mgmt_msghdr *)buffer)->opcode = opcode;
+}
+
+/**
+ * netlbl_mgmt_putinc_hdr - Write a MGMT NetLabel header into a buffer
+ * @buffer: the buffer
+ * @opcode: the NetLabel Management opcode
+ *
+ * Description:
+ * Use the given values to write a NetLabel Management header into the given
+ * buffer and increment the buffer pointer past the header.
+ *
+ */
+static inline void netlbl_mgmt_putinc_hdr(unsigned char **buffer, 
+					  const u32 opcode)
+{
+	netlbl_mgmt_put_hdr(*buffer, opcode);
+	*buffer += sizeof(struct netlbl_mgmt_msghdr);
+}
+
+/**
+ * netlbl_mgmt_payload_len - Return the length of the payload
+ * @nl_hdr: NETLINK message header
+ *
+ * Description:
+ * This function returns the length of the NetLabel management payload.
+ *
+ */
+static inline u32 netlbl_mgmt_payload_len(const struct nlmsghdr *nl_hdr)
+{
+	if (nlmsg_len(nl_hdr) <= sizeof(struct netlbl_mgmt_msghdr))
+		return 0;
+	return nlmsg_len(nl_hdr) - sizeof(struct netlbl_mgmt_msghdr);
+}
+
+/**
+ * netlbl_mgmt_payload_data - Returns a pointer to the start of the data
+ * @nl_hdr: NETLINK message header
+ *
+ * Description:
+ * This function returns a pointer to the start of the NetLabel management
+ * payload.
+ *
+ */
+static inline unsigned char *netlbl_mgmt_payload_data(
+	const struct nlmsghdr *nl_hdr)
+{
+	return nlmsg_data(nl_hdr) + sizeof(struct netlbl_mgmt_msghdr);
+}
+
+/*
+ * Label Mapping Functions
+ */
+
+/**
+ * netlbl_mgmt_add - Handle an ADD message
+ * @nl_hdr: NETLINK message header
+ * @msg: the NetLabel management message
+ *
+ * Description:
+ * Process a user generated ADD message and add the domains from the message
+ * to the hash table.  See netlabel.h for a description of the message format.
+ * Returns zero on success and non-zero on error.
+ *
+ */
+static int netlbl_mgmt_add(const struct nlmsghdr *nl_hdr,
+			   const unsigned char *msg)
+{
+	int ret_val = -EINVAL;
+	unsigned char *msg_ptr = (unsigned char *)msg;
+	u32 msg_len = netlbl_mgmt_payload_len(nl_hdr);
+	u32 count;
+	struct netlbl_dom_map *entry = NULL;
+	u32 iter;
+	u32 tmp_val;
+	u32 rcu_locked = 0;
+
+	if (msg_len < 4)
+		goto add_failure;
+	count = netlbl_getinc_u32(&msg_ptr);
+	msg_len -= 4;
+
+	for (iter = 0; iter < count && msg_len > 0; iter++, entry = NULL) {
+		if (msg_len < 4)
+			goto add_failure;
+		tmp_val = netlbl_getinc_u32(&msg_ptr);
+		msg_len -= 4;
+		if (tmp_val == 0)
+			goto add_failure;
+		entry = kzalloc(sizeof(struct netlbl_dom_map), GFP_KERNEL);
+		if (entry == NULL) {
+			ret_val = -ENOMEM;
+			goto add_failure;
+		}
+
+		if (msg_len < tmp_val)
+			goto add_failure;
+		entry->domain = kmalloc(tmp_val, GFP_KERNEL);
+		if (entry->domain == NULL) {
+			ret_val = -ENOMEM;
+			goto add_failure;
+		}
+		strncpy(entry->domain, msg_ptr, tmp_val);
+		entry->domain[tmp_val - 1] = '\0';
+		msg_ptr += tmp_val;
+		msg_len -= tmp_val;
+
+		if (msg_len < 4)
+			goto add_failure;
+		tmp_val = netlbl_getinc_u32(&msg_ptr);
+		msg_len -= 4;
+		entry->type = tmp_val;
+		switch (tmp_val) {
+#ifdef CONFIG_NETLABEL_UNLABELED
+		case NETLBL_NLTYPE_UNLABELED:
+			break;
+#endif
+#ifdef CONFIG_NETLABEL_CIPSOV4
+		case NETLBL_NLTYPE_CIPSOV4:
+			if (msg_len < 8)
+				goto add_failure;
+			msg_ptr += 4;
+			tmp_val = netlbl_getinc_u32(&msg_ptr);
+			msg_len -= 8;
+			/* XXX - we should be holding a rcu_read_lock() here
+			   while we hold the result but since the entry
+			   will always be deleted when the CIPSO DOI
+			   is deleted we aren't going to keep the lock */
+			rcu_read_lock();
+			entry->type_def.cipsov4 = cipso_v4_doi_getdef(tmp_val);
+			if (entry->type_def.cipsov4 == NULL) {
+				rcu_read_unlock();
+				goto add_failure;
+			}
+			rcu_locked = 1;
+			break;
+#endif
+		default:
+			goto add_failure;
+		}
+
+		ret_val = netlbl_domhsh_add(entry);
+		if (rcu_locked) {
+			rcu_read_unlock();
+			rcu_locked = 0;
+		}
+		if (ret_val != 0)
+			goto add_failure;
+	}
+
+	netlbl_mgmt_send_ack(nl_hdr, NETLBL_MGMT_E_OK);
+	return 0;
+
+add_failure:
+	if (entry) {
+		if (entry->domain)
+			kfree(entry->domain);
+		kfree(entry);
+	}
+	netlbl_mgmt_send_ack(nl_hdr, NETLBL_MGMT_E_ERR);
+	return ret_val;
+}
+
+/**
+ * netlbl_mgmt_remove - Handle a REMOVE message
+ * @nl_hdr: NETLINK message header
+ * @msg: the NetLabel management message
+ *
+ * Description:
+ * Process a user generated REMOVE message and remove the specified domain
+ * mappings.  Returns zero on success and non-zero on error.
+ *
+ */
+static int netlbl_mgmt_remove(const struct nlmsghdr *nl_hdr,
+			      const unsigned char *msg)
+{
+	int ret_val = -EINVAL;
+	unsigned char *msg_ptr = (unsigned char *)msg;
+	u32 msg_len = netlbl_mgmt_payload_len(nl_hdr);
+	u32 count;
+	u32 iter;
+	u32 tmp_val;
+
+	if (msg_len < 4)
+		goto remove_failure;
+	count = netlbl_getinc_u32(&msg_ptr);
+	msg_len -= 4;
+
+	for (iter = 0; iter < count && msg_len > 0; iter++) {
+		if (msg_len < 4)
+			goto remove_failure;
+		tmp_val = netlbl_getinc_u32(&msg_ptr);
+		msg_len -= 4;
+		if (tmp_val == 0 ||
+		    msg_len < tmp_val || msg_ptr[tmp_val - 1] != '\0')
+			goto remove_failure;
+		ret_val = netlbl_domhsh_remove(msg_ptr);
+		msg_ptr += tmp_val;
+		msg_len -= tmp_val;
+		if (ret_val != 0)
+			goto remove_failure;
+	}
+
+	netlbl_mgmt_send_ack(nl_hdr, NETLBL_MGMT_E_OK);
+	return 0;
+
+remove_failure:
+	netlbl_mgmt_send_ack(nl_hdr, NETLBL_MGMT_E_ERR);
+	return ret_val;
+}
+
+/**
+ * netlbl_mgmt_list - Handle a LIST message
+ * @nl_hdr: NETLINK message header
+ * @msg: the NetLabel management message
+ *
+ * Description:
+ * Process a user generated LIST message and dumps the domain hash table in a
+ * form suitable for use in a kernel generated LIST message.  Returns
+ * zero on success and non-zero on error.
+ *
+ */
+static int netlbl_mgmt_list(const struct nlmsghdr *nl_hdr,
+			    const unsigned char *msg)
+{
+	int ret_val = -ENOMEM;
+	struct sk_buff *skb;
+	unsigned char *buf_ptr;
+
+	skb = netlbl_domhsh_dump();
+	if (skb == NULL)
+		goto list_return;
+	buf_ptr = skb_push(skb, 
+			   NLMSG_SPACE(sizeof(struct netlbl_mgmt_msghdr)));
+	if (buf_ptr == NULL) {
+		kfree_skb(skb);
+		ret_val = -EAGAIN;
+		goto list_return;
+	}
+	netlbl_putinc_hdr(&buf_ptr,
+			  NETLBL_NLTYPE_MGMT,
+			  skb->len, 0, nl_hdr->nlmsg_pid, 0);
+	netlbl_mgmt_putinc_hdr(&buf_ptr, NL_MGMT_LIST);
+
+	ret_val = netlbl_netlink_snd(skb, nl_hdr->nlmsg_pid);
+
+list_return:
+	if (ret_val != 0)
+		netlbl_mgmt_send_ack(nl_hdr, NETLBL_MGMT_E_ERR);
+	return ret_val;
+}
+
+/**
+ * netlbl_mgmt_adddef - Handle an ADDDEF message
+ * @nl_hdr: NETLINK message header
+ * @msg: the NetLabel management message
+ *
+ * Description:
+ * Process a user generated ADDDEF message and respond accordingly.  Returns
+ * zero on success and non-zero on error.
+ *
+ */
+static int netlbl_mgmt_adddef(const struct nlmsghdr *nl_hdr,
+			      const unsigned char *msg)
+{
+	int ret_val = -EINVAL;
+	unsigned char *msg_ptr = (unsigned char *)msg;
+	u32 msg_len = netlbl_mgmt_payload_len(nl_hdr);
+	u32 type;
+	struct netlbl_dom_map *entry = NULL;
+	u32 tmp_val;
+	u32 rcu_locked = 0;
+
+	if (msg_len < 4)
+		goto adddef_failure;
+	type = netlbl_getinc_u32(&msg_ptr);
+	msg_len -= 4;
+
+	entry = kzalloc(sizeof(struct netlbl_dom_map), GFP_KERNEL);
+	if (entry == NULL) {
+		ret_val = -ENOMEM;
+		goto adddef_failure;
+	}
+	entry->type = type;
+
+	switch (type) {
+#ifdef CONFIG_NETLABEL_UNLABELED
+	case NETLBL_NLTYPE_UNLABELED:
+		break;
+#endif
+#ifdef CONFIG_NETLABEL_CIPSOV4
+	case NETLBL_NLTYPE_CIPSOV4:
+		if (msg_len < 8)
+			goto adddef_failure;
+		msg_ptr += 4;
+		tmp_val = netlbl_getinc_u32(&msg_ptr);
+		msg_len -= 8;
+		/* XXX - we should be holding a rcu_read_lock here while we
+		   hold the result but since the entry will always be
+		   deleted when the CIPSO DOI is deleted we are going
+		   to skip the lock */
+		rcu_read_lock();
+		entry->type_def.cipsov4 = cipso_v4_doi_getdef(tmp_val);
+		if (entry->type_def.cipsov4 == NULL) {
+			rcu_read_unlock();
+			goto adddef_failure;
+		}
+		rcu_locked = 1;
+		break;
+#endif
+	default:
+		ret_val = -EINVAL;
+		goto adddef_failure;
+	}
+
+	ret_val = netlbl_domhsh_add_default(entry);
+	if (rcu_locked) {
+		rcu_read_unlock();
+		rcu_locked = 0;
+	}
+	if (ret_val != 0)
+		goto adddef_failure;
+
+	netlbl_mgmt_send_ack(nl_hdr, NETLBL_MGMT_E_OK);
+	return 0;
+
+adddef_failure:
+	if (entry)
+		kfree(entry);
+	netlbl_mgmt_send_ack(nl_hdr, NETLBL_MGMT_E_ERR);
+	return ret_val;
+}
+
+/**
+ * netlbl_mgmt_removedef - Handle a REMOVEDEF message
+ * @nl_hdr: NETLINK message header
+ * @msg: the NetLabel management message
+ *
+ * Description:
+ * Process a user generated REMOVEDEF message and remove the default domain
+ * mapping.  Returns zero on success and non-zero on error.
+ *
+ */
+static int netlbl_mgmt_removedef(const struct nlmsghdr *nl_hdr,
+				 const unsigned char *msg)
+{
+	int ret_val;
+
+	ret_val = netlbl_domhsh_remove_default();
+	if (ret_val == 0)
+		netlbl_mgmt_send_ack(nl_hdr, NETLBL_MGMT_E_OK);
+	else
+		netlbl_mgmt_send_ack(nl_hdr, NETLBL_MGMT_E_ERR);
+
+	return ret_val;
+}
+
+/**
+ * netlbl_mgmt_listdef - Handle a LISTDEF message
+ * @nl_hdr: NETLINK message header
+ * @msg: the NetLabel management message
+ *
+ * Description:
+ * Process a user generated LISTDEF message and dumps the default domain
+ * mapping in a form suitable for use in a kernel generated LISTDEF message.
+ * Returns zero on success and non-zero on error.
+ *
+ */
+static int netlbl_mgmt_listdef(const struct nlmsghdr *nl_hdr,
+			       const unsigned char *msg)
+{
+	int ret_val = -ENOMEM;
+	struct sk_buff *skb;
+	unsigned char *buf_ptr;
+
+	skb = netlbl_domhsh_dump_default();
+	if (skb == NULL)
+		goto listdef_return;
+	buf_ptr = skb_push(skb, 
+			   NLMSG_SPACE(sizeof(struct netlbl_mgmt_msghdr)));
+	if (buf_ptr == NULL) {
+		kfree_skb(skb);
+		ret_val = -EAGAIN;
+		goto listdef_return;
+	}
+	netlbl_putinc_hdr(&buf_ptr,
+			  NETLBL_NLTYPE_MGMT,
+			  skb->len, 0, nl_hdr->nlmsg_pid, 0);
+	netlbl_mgmt_putinc_hdr(&buf_ptr, NL_MGMT_LISTDEF);
+
+	ret_val = netlbl_netlink_snd(skb, nl_hdr->nlmsg_pid);
+
+listdef_return:
+	if (ret_val != 0)
+		netlbl_mgmt_send_ack(nl_hdr, NETLBL_MGMT_E_ERR);
+	return ret_val;
+}
+
+/**
+ * netlbl_mgmt_modules - Handle a MODULES message
+ * @nl_hdr: NETLINK message header
+ * @msg: the NetLabel management message
+ *
+ * Description:
+ * Process a user generated MODULES message and respond accordingly.  Returns
+ * zero on success and non-zero on error.
+ *
+ */
+static int netlbl_mgmt_modules(const struct nlmsghdr *nl_hdr,
+			       const unsigned char *msg)
+{
+	int ret_val = -EINVAL;
+	u32 mod_count = 0;
+	size_t msg_size;
+	size_t data_size;
+	struct sk_buff *skb = NULL;
+	struct nlmsghdr *nl_mgmt_hdr;
+	unsigned char *data;
+
+	if (netlbl_mgmt_payload_len(nl_hdr) < 4)
+		goto nlmsg_failure;
+	mod_count = netlbl_get_u32(msg);
+	if (mod_count != 0)
+		goto nlmsg_failure;
+
+#ifdef CONFIG_NETLABEL_UNLABELED
+	mod_count += 1;
+#endif
+#ifdef CONFIG_NETLABEL_CIPSOV4
+	mod_count += 1;
+#endif
+
+	data_size = sizeof(struct netlbl_mgmt_msghdr) + 4 + mod_count * 4;
+	msg_size = NLMSG_SPACE(data_size);
+
+	skb = alloc_skb(msg_size, GFP_KERNEL);
+	if (skb == NULL) {
+		ret_val = -ENOMEM;
+		goto nlmsg_failure;
+	}
+
+	nl_mgmt_hdr = NLMSG_PUT(skb,
+				nl_hdr->nlmsg_pid,
+				0, NETLBL_NLTYPE_MGMT, data_size);
+	nl_mgmt_hdr->nlmsg_len = msg_size;
+
+	data = NLMSG_DATA(nl_mgmt_hdr);
+	netlbl_mgmt_putinc_hdr(&data, NL_MGMT_MODULES);
+	netlbl_putinc_u32(&data, mod_count);
+#ifdef CONFIG_NETLABEL_UNLABELED
+	netlbl_putinc_u32(&data, NETLBL_NLTYPE_UNLABELED);
+#endif
+#ifdef CONFIG_NETLABEL_CIPSOV4
+	netlbl_putinc_u32(&data, NETLBL_NLTYPE_CIPSOV4);
+#endif
+
+	return netlbl_netlink_snd(skb, nl_hdr->nlmsg_pid);
+
+nlmsg_failure:
+	if (skb)
+		kfree_skb(skb);
+	netlbl_mgmt_send_ack(nl_hdr, NETLBL_MGMT_E_ERR);
+	return ret_val;
+}
+
+/**
+ * netlbl_mgmt_version - Handle a VERSION message
+ * @nl_hdr: NETLINK message header
+ * @msg: the NetLabel management message
+ *
+ * Description:
+ * Process a user generated VERSION message and respond accordingly.  Returns
+ * zero on success and non-zero on error.
+ *
+ */
+static int netlbl_mgmt_version(const struct nlmsghdr *nl_hdr,
+			       const unsigned char *msg)
+{
+	int ret_val = -EINVAL;
+	u32 str_len;
+	size_t msg_size;
+	size_t data_size;
+	struct sk_buff *skb = NULL;
+	struct nlmsghdr *nl_mgmt_hdr;
+	unsigned char *data;
+
+	if (netlbl_mgmt_payload_len(nl_hdr) < 4)
+		goto nlmsg_failure;
+	str_len = netlbl_get_u32(msg);
+	if (str_len != 0)
+		goto nlmsg_failure;
+
+	str_len = strlen(NETLBL_VER_STR) + 1;
+	data_size = sizeof(struct netlbl_mgmt_msghdr) + 4 + str_len;
+	msg_size = NLMSG_SPACE(data_size);
+
+	skb = alloc_skb(msg_size, GFP_KERNEL);
+	if (skb == NULL) {
+		ret_val = -ENOMEM;
+		goto nlmsg_failure;
+	}
+
+	nl_mgmt_hdr = NLMSG_PUT(skb,
+				nl_hdr->nlmsg_pid,
+				0, NETLBL_NLTYPE_MGMT, data_size);
+	nl_mgmt_hdr->nlmsg_len = msg_size;
+
+	data = NLMSG_DATA(nl_mgmt_hdr);
+	netlbl_mgmt_putinc_hdr(&data, NL_MGMT_VERSION);
+	netlbl_putinc_u32(&data, str_len);
+	netlbl_putinc_str(&data, NETLBL_VER_STR);
+
+	return netlbl_netlink_snd(skb, nl_hdr->nlmsg_pid);
+
+nlmsg_failure:
+	if (skb)
+		kfree_skb(skb);
+	netlbl_mgmt_send_ack(nl_hdr, NETLBL_MGMT_E_ERR);
+	return ret_val;
+}
+
+/*
+ * NetLabel Protocol Handlers
+ */
+
+/**
+ * netlbl_mgmt_send_ack - Send an ACK message
+ * @nl_hdr: NETLINK message header
+ * @ret_code: return code to use
+ *
+ * Description:
+ * This function sends an ACK message to the sender of the NETLINK message
+ * specified by @nl_hdr.  Returns negative values on error. 
+ *
+ */
+static int netlbl_mgmt_send_ack(const struct nlmsghdr *nl_hdr, 
+				const u32 ret_code)
+{
+	size_t msg_size;
+	size_t data_size;
+	struct sk_buff *skb;
+	struct nlmsghdr *nl_ack_hdr;
+	unsigned char *data;
+
+	data_size = sizeof(struct netlbl_mgmt_msghdr) + 8;
+	msg_size = NLMSG_SPACE(data_size);
+
+	skb = alloc_skb(msg_size, GFP_KERNEL);
+	if (skb == NULL)
+		return -ENOMEM;
+
+	nl_ack_hdr = NLMSG_PUT(skb,
+			       nl_hdr->nlmsg_pid,
+			       0, NETLBL_NLTYPE_MGMT, data_size);
+	nl_ack_hdr->nlmsg_len = msg_size;
+
+	data = NLMSG_DATA(nl_ack_hdr);
+	netlbl_mgmt_putinc_hdr(&data, NL_MGMT_ACK);
+	netlbl_putinc_u32(&data, nl_hdr->nlmsg_seq);
+	netlbl_putinc_u32(&data, ret_code);
+
+	return netlbl_netlink_snd(skb, nl_hdr->nlmsg_pid);
+
+nlmsg_failure:
+	kfree_skb(skb);
+	return -EPERM;
+}
+
+/**
+ * netlbl_mgmt_rcv - Process incoming NetLabel packets
+ * @nl_hdr: NETLINK message header
+ * @msg: pointer to the start of the NetLabel data
+ *
+ * Description:
+ * This function is reponsibile for reading all of the incoming NetLabel
+ * management traffic and dispatching it to the correct functions.
+ *
+ */
+void netlbl_mgmt_rcv(const struct nlmsghdr *nl_hdr, const unsigned char *msg)
+{
+	struct netlbl_mgmt_msghdr *nl_mgmt_hdr;
+
+	if (nl_hdr == NULL ||
+	    msg == NULL ||
+	    nlmsg_len(nl_hdr) < sizeof(struct netlbl_mgmt_msghdr))
+		return;
+
+	nl_mgmt_hdr = (struct netlbl_mgmt_msghdr *)msg;
+	switch (nl_mgmt_hdr->opcode) {
+	case NL_MGMT_ADD:
+		netlbl_mgmt_add(nl_hdr, netlbl_mgmt_payload_data(nl_hdr));
+		break;
+	case NL_MGMT_REMOVE:
+		netlbl_mgmt_remove(nl_hdr, netlbl_mgmt_payload_data(nl_hdr));
+		break;
+	case NL_MGMT_LIST:
+		netlbl_mgmt_list(nl_hdr, netlbl_mgmt_payload_data(nl_hdr));
+		break;
+	case NL_MGMT_ADDDEF:
+		netlbl_mgmt_adddef(nl_hdr, netlbl_mgmt_payload_data(nl_hdr));
+		break;
+	case NL_MGMT_REMOVEDEF:
+		netlbl_mgmt_removedef(nl_hdr, 
+				      netlbl_mgmt_payload_data(nl_hdr));
+		break;
+	case NL_MGMT_LISTDEF:
+		netlbl_mgmt_listdef(nl_hdr, netlbl_mgmt_payload_data(nl_hdr));
+		break;
+	case NL_MGMT_MODULES:
+		netlbl_mgmt_modules(nl_hdr, netlbl_mgmt_payload_data(nl_hdr));
+		break;
+	case NL_MGMT_VERSION:
+		netlbl_mgmt_version(nl_hdr, netlbl_mgmt_payload_data(nl_hdr));
+		break;
+	default:
+		netlbl_mgmt_send_ack(nl_hdr, NETLBL_MGMT_E_BADCMD);
+		return;
+	}
+}
--- linux-2.6.16.i686/net/netlabel/netlabel_mgmt.h	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.6.16.i686-cipso/net/netlabel/netlabel_mgmt.h	2006-05-16 12:17:42.000000000 -0400
@@ -0,0 +1,265 @@
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
+ *     return code: values specified in NETLBL_MGMT_E_*
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
+ *   +----------------+---------------+
+ *   | type (32 bits) | doi (32 bits) |
+ *   +----------------+---------------+
+ *
+ *     type: the CIPSO mapping table type (defined in the cipso_ipv4.h header
+ *           as CIPSO_V4_MAP_*)
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
+ *   +----------------+---------------+
+ *   | type (32 bits) | doi (32 bits) |
+ *   +----------------+---------------+
+ *
+ *     type: the CIPSO mapping table type (defined in the cipso_ipv4.h header
+ *           as CIPSO_V4_MAP_*)
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
+ *   in the kernel.  This message type is also used by the kernel to respond
+ *   to an application's MODULES message.
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
+ *   Sent by an application to request the NetLabel version string.  This
+ *   message type is also used by the kernel to respond to an VERSION request.
+ *
+ *   +--------------------------+
+ *   | version length (32 bits) | ...
+ *   +--------------------------+
+ *
+ *     version length: the length of the version string, if this is an
+ *                     application generated message and the value is zero then
+ *                     return the correct version string
+ *
+ *   +---------------------------+
+ *   | version string (variable) |
+ *   +---------------------------+
+ *
+ *     version string: the version string, NULL terminated
+ *
+ */
+
+/* MGMT message header */
+struct netlbl_mgmt_msghdr {
+	enum { NL_MGMT_NOOP,
+	       NL_MGMT_ACK,
+	       NL_MGMT_ADD,
+	       NL_MGMT_REMOVE,
+	       NL_MGMT_LIST,
+	       NL_MGMT_ADDDEF,
+	       NL_MGMT_REMOVEDEF,
+	       NL_MGMT_LISTDEF,
+	       NL_MGMT_MODULES,
+	       NL_MGMT_VERSION
+	} opcode;
+};
+
+/* MGMT ACK return codes */
+#define NETLBL_MGMT_E_OK         NETLBL_E_OK
+#define NETLBL_MGMT_E_ERR        NETLBL_E_ERR
+#define NETLBL_MGMT_E_BADCMD     NETLBL_E_BADCMD
+
+/* Process NetLabel management messages */
+void netlbl_mgmt_rcv(const struct nlmsghdr *nl_hdr, const unsigned char *msg);
+
+#endif
--- linux-2.6.16.i686/net/netlabel/netlabel_unlabeled.c	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.6.16.i686-cipso/net/netlabel/netlabel_unlabeled.c	2006-05-23 10:53:04.000000000 -0400
@@ -0,0 +1,289 @@
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
+#include <linux/types.h>
+#include <linux/rcupdate.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/socket.h>
+#include <linux/string.h>
+#include <linux/skbuff.h>
+#include <net/sock.h>
+#include <net/netlink.h>
+#include <net/netlabel.h>
+#include <asm/bug.h>
+
+#include "netlabel_user.h"
+#include "netlabel_domainhash.h"
+#include "netlabel_unlabeled.h"
+
+/* Accept unlabeled packets flag */
+static atomic_t netlabel_unlabel_accept_flg = ATOMIC_INIT(0);
+
+/*
+ * Local Prototypes
+ */
+
+static int netlbl_unlabel_send_ack(const struct nlmsghdr *nl_hdr,
+				   const u32 ret_code);
+
+/*
+ * Helper Functions
+ */
+
+/**
+ * netlbl_unlabel_put_hdr - Write a Unlabeled NetLabel header into a buffer
+ * @buffer: the buffer
+ * @opcode: the NetLabel Unlabeled opcode
+ *
+ * Description:
+ * Use the given values to write a NetLabel Unlabeled header into the given
+ * buffer.
+ *
+ */
+static inline void netlbl_unlabel_put_hdr(unsigned char *buffer,
+					  const u32 opcode)
+{
+	((struct netlbl_unlabel_msghdr *)buffer)->opcode = opcode;
+}
+
+/**
+ * netlbl_unlabel_putinc_hdr - Write a Unlabeled NetLabel header into a buffer
+ * @buffer: the buffer
+ * @opcode: the NetLabel Unlabeled opcode
+ *
+ * Description:
+ * Use the given values to write a NetLabel Unlabeled header into the given
+ * buffer and increment the buffer pointer past the header.
+ *
+ */
+static inline void netlbl_unlabel_putinc_hdr(unsigned char **buffer, 
+					     const u32 opcode)
+{
+	netlbl_unlabel_put_hdr(*buffer, opcode);
+	*buffer += sizeof(struct netlbl_unlabel_msghdr);
+}
+
+/**
+ * netlbl_unlabel_payload_len - Return the length of the payload
+ * @nl_hdr: NETLINK message header
+ *
+ * Description:
+ * This function returns the length of the NetLabel unlabeled payload.
+ *
+ */
+static inline u32 netlbl_unlabel_payload_len(const struct nlmsghdr *nl_hdr)
+{
+	if (nlmsg_len(nl_hdr) <= sizeof(struct netlbl_unlabel_msghdr))
+		return 0;
+	return nlmsg_len(nl_hdr) - sizeof(struct netlbl_unlabel_msghdr);
+}
+
+/**
+ * netlbl_unlabel_payload_data - Returns a pointer to the start of the data
+ * @nl_hdr: NETLINK message header
+ *
+ * Description:
+ * This function returns a pointer to the start of the NetLabel unlabeled
+ * payload.
+ *
+ */
+static inline unsigned char *netlbl_unlabel_payload_data(
+	const struct nlmsghdr *nl_hdr)
+{
+	return nlmsg_data(nl_hdr) + sizeof(struct netlbl_unlabel_msghdr);
+}
+
+/*
+ * Label Mapping Functions
+ */
+
+/**
+ * netlbl_unlabel_accept - Handle an ACCEPT message
+ * @nl_hdr: NETLINK message header
+ * @msg: the NetLabel management message
+ *
+ * Description:
+ * Process a user generated ACCEPT message and set the accept flag accordingly.
+ * Returns zero on success, negative values on error.
+ *
+ */
+static int netlbl_unlabel_accept(const struct nlmsghdr *nl_hdr, 
+				 const unsigned char *msg)
+{
+	u32 value;
+
+	if (netlbl_unlabel_payload_len(nl_hdr) == 4) {
+		value = netlbl_get_u32(msg);
+		if (value == 1 || value == 0) {
+			atomic_set(&netlabel_unlabel_accept_flg, value);
+			netlbl_unlabel_send_ack(nl_hdr, NETLBL_UNLABEL_E_OK);
+			return 0;
+		}
+	}
+
+	netlbl_unlabel_send_ack(nl_hdr, NETLBL_UNLABEL_E_ERR);
+	return -EINVAL;
+}
+
+/*
+ * NetLabel Protocol Handlers
+ */
+
+/**
+ * netlbl_unlabel_send_ack - Send an ACK message
+ * @nl_hdr: NETLINK message header
+ * @ret_code: return code to use
+ *
+ * Description:
+ * This function sends an ACK message to the sender of the NETLINK message
+ * specified by @nl_hdr.  Returns negative values on error. 
+ *
+ */
+static int netlbl_unlabel_send_ack(const struct nlmsghdr *nl_hdr,
+				   const u32 ret_code)
+{
+	size_t msg_size;
+	size_t data_size;
+	struct sk_buff *skb;
+	struct nlmsghdr *nl_ack_hdr;
+	unsigned char *data;
+
+	data_size = sizeof(struct netlbl_unlabel_msghdr) + 8;
+	msg_size = NLMSG_SPACE(data_size);
+
+	skb = alloc_skb(msg_size, GFP_KERNEL);
+	if (skb == NULL)
+		return -ENOMEM;
+
+	nl_ack_hdr = NLMSG_PUT(skb,
+			       nl_hdr->nlmsg_pid,
+			       0, NETLBL_NLTYPE_UNLABELED, data_size);
+	nl_ack_hdr->nlmsg_len = msg_size;
+
+	data = NLMSG_DATA(nl_ack_hdr);
+	netlbl_unlabel_putinc_hdr(&data, NL_UNL_ACK);
+	netlbl_putinc_u32(&data, nl_hdr->nlmsg_seq);
+	netlbl_putinc_u32(&data, ret_code);
+
+	return netlbl_netlink_snd(skb, nl_hdr->nlmsg_pid);
+
+nlmsg_failure:
+	kfree_skb(skb);
+	return -EPERM;
+}
+
+/**
+ * netlbl_unlabel_rcv - Process incoming NetLabel packets
+ * @nl_hdr: NETLINK message header
+ * @msg: pointer to the start of the NetLabel data
+ *
+ * Description:
+ * This function is reponsibile for reading all of the incoming Unlabeled
+ * NetLabel traffic and dispatching it to the correct Unlabeled functions.
+ *
+ */
+void netlbl_unlabel_rcv(const struct nlmsghdr *nl_hdr,
+			const unsigned char *msg)
+{
+	struct netlbl_unlabel_msghdr *nl_unl_hdr;
+
+	if (nl_hdr == NULL ||
+	    msg == NULL ||
+	    nlmsg_len(nl_hdr) < sizeof(struct netlbl_unlabel_msghdr))
+		return;
+
+	nl_unl_hdr = (struct netlbl_unlabel_msghdr *)msg;
+	switch (nl_unl_hdr->opcode) {
+	case NL_UNL_ACCEPT:
+		netlbl_unlabel_accept(nl_hdr,
+				      netlbl_unlabel_payload_data(nl_hdr));
+		break;
+	default:
+		netlbl_unlabel_send_ack(nl_hdr, NETLBL_UNLABEL_E_BADCMD);
+		return;
+	}
+}
+
+/*
+ * NetLabel KAPI Hooks
+ */
+
+/**
+ * netlbl_unlabel_getattr - Get the security attributes for an unlabled packet
+ * @skb: the packet
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Determine the security attributes, if any, for an unlabled packet and return
+ * them in @secattr.  Returns zero on success and negative values on failure.
+ *
+ */
+int netlbl_unlabel_getattr(const struct sk_buff *skb,
+			   struct netlbl_lsm_secattr *secattr)
+{
+	BUG_ON(skb == NULL || secattr == NULL);
+
+	if (atomic_read(&netlabel_unlabel_accept_flg) == 1) {
+		memset(secattr, 0, sizeof(struct netlbl_lsm_secattr));
+		return 0;
+	}
+
+	return -ENOMSG;
+}
+
+/**
+ * netlbl_unlabel_defconf - Set the default config to allow unlabeled packets
+ *
+ * Description:
+ * Set the default NetLabel configuration to allow incoming unlabeled packets
+ * and to send unlabeled network traffic by default.
+ *
+ */
+int netlbl_unlabel_defconf(void)
+{
+	int ret_val;
+	struct netlbl_dom_map *entry;
+
+	entry = kzalloc(sizeof(struct netlbl_dom_map), GFP_KERNEL);
+	if (entry == NULL)
+		return -ENOMEM;
+	entry->type = NETLBL_NLTYPE_UNLABELED;
+	ret_val = netlbl_domhsh_add_default(entry);
+	if (ret_val != 0)
+		return ret_val;
+
+	atomic_set(&netlabel_unlabel_accept_flg, 1);
+
+	return 0;
+}
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Paul Moore <paul.moore@hp.com>");
--- linux-2.6.16.i686/net/netlabel/netlabel_unlabeled.h	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.6.16.i686-cipso/net/netlabel/netlabel_unlabeled.h	2006-05-23 10:50:18.000000000 -0400
@@ -0,0 +1,90 @@
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
+ * The following NetLabel payloads are supported by the Unlabeled subsystem,
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
+ *     return code: values specified in NETLBL_UNLABEL_E_*
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
+ */
+
+/* Unlabeled message header */
+struct netlbl_unlabel_msghdr {
+	enum { NL_UNL_NOOP,
+	       NL_UNL_ACK,
+	       NL_UNL_ACCEPT
+	} opcode;
+};
+
+/* Unlabeled ACK return codes */
+#define NETLBL_UNLABEL_E_OK         NETLBL_E_OK
+#define NETLBL_UNLABEL_E_ERR        NETLBL_E_ERR
+#define NETLBL_UNLABEL_E_BADCMD     NETLBL_E_BADCMD
+
+/* Process Unlabeled NetLabel messages */
+void netlbl_unlabel_rcv(const struct nlmsghdr *nl_hdr, 
+			const unsigned char *msg);
+
+/* Process Unlabeled incoming network packets */
+int netlbl_unlabel_getattr(const struct sk_buff *skb,
+			   struct netlbl_lsm_secattr *secattr);
+
+/* Set the default configuration to allow Unlabeled packets */
+int netlbl_unlabel_defconf(void);
+
+#endif
--- linux-2.6.16.i686/net/netlabel/netlabel_user.c	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.6.16.i686-cipso/net/netlabel/netlabel_user.c	2006-05-17 18:24:33.000000000 -0400
@@ -0,0 +1,166 @@
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
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/socket.h>
+#include <net/sock.h>
+#include <net/netlink.h>
+#include <net/netlabel.h>
+#include <asm/bug.h>
+
+#include "netlabel_mgmt.h"
+#include "netlabel_unlabeled.h"
+#include "netlabel_cipso_v4.h"
+#include "netlabel_user.h"
+
+/* NETLINK socket */
+/* PM - do we need a lock (or something) around this? */
+static struct sock *netlbl_nl = NULL;
+
+/*
+ * NetLabel Functions
+ */
+
+/**
+ * netlbl_netlink_rcv - Catch incoming NETLINK packets
+ * @sk: the NETLINK socket
+ * @len: absolutely no clue, socket queue length maybe?
+ *
+ * Description:
+ * Receives the NETLINK packet, inspects the packet to determine the correct
+ * NetLabel subsystem and hands the packet off to the correct handler.
+ *
+ */
+static void netlbl_netlink_rcv(struct sock *sk, const int len)
+{
+	struct sk_buff *skb;
+	struct nlmsghdr *nl_hdr;
+
+	/* XXX - should this use netlink_run_queue() instead? */
+	while ((skb = skb_dequeue(&sk->sk_receive_queue)) != NULL) {
+		nl_hdr = (struct nlmsghdr *)skb->data;
+		switch (nl_hdr->nlmsg_type) {
+		case NETLBL_NLTYPE_MGMT:
+			netlbl_mgmt_rcv(nl_hdr, nlmsg_data(nl_hdr));
+			break;
+#ifdef CONFIG_NETLABEL_UNLABELED
+		case NETLBL_NLTYPE_UNLABELED:
+			netlbl_unlabel_rcv(nl_hdr, nlmsg_data(nl_hdr));
+			break;
+#endif
+#ifdef CONFIG_NETLABEL_CIPSOV4
+		case NETLBL_NLTYPE_CIPSOV4:
+			netlbl_cipsov4_rcv(nl_hdr, nlmsg_data(nl_hdr));
+			break;
+#endif
+		}
+		nlmsg_free(skb);
+	}
+}
+
+/**
+ * netlbl_netlink_init - Initialize the netlink socket
+ *
+ * Description:
+ * Create the netlink socket and do any other setup required.  Returns zero on
+ * success and non-zero on failure.
+ *
+ */
+int netlbl_netlink_init(void)
+{
+	BUG_ON(netlbl_nl);
+	/* XXX - it might be a good idea to spawn a thread here at startup to
+	   handle the updates to the label mapping databases and have the
+	   netlbl_netlink_rcv() function simply poke the thread but i am unsure
+	   and this approach is much simpler so it wins for now */
+	netlbl_nl = netlink_kernel_create(NETLINK_NETLABEL,
+					  NETLBL_NLGRP_MAX,
+					  netlbl_netlink_rcv, THIS_MODULE);
+	if (netlbl_nl == NULL)
+		return -ENOMEM;
+
+	return 0;
+}
+
+/**
+ * netlbl_exit - Release the netlink socket
+ * 
+ * Description:
+ * Close the netlink socket and do any other cleanup required.  Returns zero on
+ * success and non-zero on failure.
+ *
+ */
+int netlbl_netlink_exit(void)
+{
+	BUG_ON(!netlbl_nl);
+	/* XXX - if we do have a worker thread, see the above comment in 
+	   netlbl_netlink_init(), we should handle any cleanup here
+	   before we go away */
+	sock_release(netlbl_nl->sk_socket);
+
+	return 0;
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
+int netlbl_netlink_snd(struct sk_buff *skb, const u32 pid)
+{
+	return nlmsg_unicast(netlbl_nl, skb, pid);
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
+int netlbl_netlink_snd_multicast(struct sk_buff *skb, 
+				 const u32 pid, 
+				 const u32 group)
+{
+	return nlmsg_multicast(netlbl_nl, skb, pid, group);
+}
--- linux-2.6.16.i686/net/netlabel/netlabel_user.h	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.6.16.i686-cipso/net/netlabel/netlabel_user.h	2006-05-12 15:42:55.000000000 -0400
@@ -0,0 +1,42 @@
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
+/* NetLabel NETLINK I/O functions */
+int netlbl_netlink_init(void);
+int netlbl_netlink_exit(void);
+int netlbl_netlink_snd(struct sk_buff *skb, const u32 pid);
+int netlbl_netlink_snd_multicast(struct sk_buff *skb, 
+				 const u32 pid,
+				 const u32 group);
+
+#endif
