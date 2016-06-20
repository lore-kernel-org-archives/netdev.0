From: Huw Davies <huw@codeweavers.com>
Subject: [PATCH v4 03/19] netlabel: Initial support for the CALIPSO netlink protocol.
Date: Mon, 20 Jun 2016 14:36:43 +0100
Message-ID: <1466429819-12707-4-git-send-email-huw@codeweavers.com>
Cc: Paul Moore <pmoore@redhat.com>
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

CALIPSO is a packet labelling protocol for IPv6 which is very similar
to CIPSO.  It is specified in RFC 5570.  Much of the code is based on
the current CIPSO code.

This adds support for adding passthrough-type CALIPSO DOIs through the
NLBL_CALIPSO_C_ADD command.  It requires attributes:

 NLBL_CALIPSO_A_TYPE which must be CALIPSO_MAP_PASS.
 NLBL_CALIPSO_A_DOI.

In passthrough mode the CALIPSO engine will map MLS secattr levels
and categories directly to the packet label.

At this stage, the major difference between this and the CIPSO
code is that IPv6 may be compiled as a module.  To allow for
this the CALIPSO functions are registered at module init time.

Signed-off-by: Huw Davies <huw@codeweavers.com>
---
 include/net/calipso.h           |  79 +++++++++++++++
 include/net/netlabel.h          |  23 +++++
 include/uapi/linux/audit.h      |   2 +
 net/ipv6/Makefile               |   1 +
 net/ipv6/af_inet6.c             |   9 +-
 net/ipv6/calipso.c              | 169 +++++++++++++++++++++++++++++++
 net/netlabel/Makefile           |   2 +-
 net/netlabel/netlabel_calipso.c | 216 ++++++++++++++++++++++++++++++++++++++++
 net/netlabel/netlabel_calipso.h |  90 +++++++++++++++++
 net/netlabel/netlabel_kapi.c    |   1 +
 net/netlabel/netlabel_mgmt.c    |   9 ++
 net/netlabel/netlabel_user.c    |   5 +
 12 files changed, 604 insertions(+), 2 deletions(-)
 create mode 100644 include/net/calipso.h
 create mode 100644 net/ipv6/calipso.c
 create mode 100644 net/netlabel/netlabel_calipso.c
 create mode 100644 net/netlabel/netlabel_calipso.h

diff --git a/include/net/calipso.h b/include/net/calipso.h
new file mode 100644
index 0000000..38dbb47
--- /dev/null
+++ b/include/net/calipso.h
@@ -0,0 +1,79 @@
+/*
+ * CALIPSO - Common Architecture Label IPv6 Security Option
+ *
+ * This is an implementation of the CALIPSO protocol as specified in
+ * RFC 5570.
+ *
+ * Authors: Paul Moore <paul@paul-moore.com>
+ *          Huw Davies <huw@codeweavers.com>
+ *
+ */
+
+/*
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ * (c) Copyright Huw Davies <huw@codeweavers.com>, 2015
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
+ * along with this program;  if not, see <http://www.gnu.org/licenses/>.
+ *
+ */
+
+#ifndef _CALIPSO_H
+#define _CALIPSO_H
+
+#include <linux/types.h>
+#include <linux/rcupdate.h>
+#include <linux/list.h>
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <net/netlabel.h>
+#include <net/request_sock.h>
+#include <linux/atomic.h>
+#include <asm/unaligned.h>
+
+/* known doi values */
+#define CALIPSO_DOI_UNKNOWN          0x00000000
+
+/* doi mapping types */
+#define CALIPSO_MAP_UNKNOWN          0
+#define CALIPSO_MAP_PASS             2
+
+/*
+ * CALIPSO DOI definitions
+ */
+
+/* DOI definition struct */
+struct calipso_doi {
+	u32 doi;
+	u32 type;
+
+	atomic_t refcount;
+	struct list_head list;
+	struct rcu_head rcu;
+};
+
+#ifdef CONFIG_NETLABEL
+int __init calipso_init(void);
+void calipso_exit(void);
+#else
+static inline int __init calipso_init(void)
+{
+	return 0;
+}
+
+static inline void calipso_exit(void)
+{
+}
+#endif /* CONFIG_NETLABEL */
+
+#endif /* _CALIPSO_H */
diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index 7b5a300..6af1bb6 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -40,6 +40,7 @@
 #include <linux/atomic.h>
 
 struct cipso_v4_doi;
+struct calipso_doi;
 
 /*
  * NetLabel - A management interface for maintaining network packet label
@@ -94,6 +95,8 @@ struct cipso_v4_doi;
 #define NETLBL_NLTYPE_UNLABELED_NAME    "NLBL_UNLBL"
 #define NETLBL_NLTYPE_ADDRSELECT        6
 #define NETLBL_NLTYPE_ADDRSELECT_NAME   "NLBL_ADRSEL"
+#define NETLBL_NLTYPE_CALIPSO           7
+#define NETLBL_NLTYPE_CALIPSO_NAME      "NLBL_CALIPSO"
 
 /*
  * NetLabel - Kernel API for accessing the network packet label mappings.
@@ -216,6 +219,23 @@ struct netlbl_lsm_secattr {
 	} attr;
 };
 
+/**
+ * struct netlbl_calipso_ops - NetLabel CALIPSO operations
+ * @doi_add: add a CALIPSO DOI
+ * @doi_free: free a CALIPSO DOI
+ *
+ * Description:
+ * This structure is filled out by the CALIPSO engine and passed
+ * to the NetLabel core via a call to netlbl_calipso_ops_register().
+ * It enables the CALIPSO engine (and hence IPv6) to be compiled
+ * as a module.
+ */
+struct netlbl_calipso_ops {
+	int (*doi_add)(struct calipso_doi *doi_def,
+		       struct netlbl_audit *audit_info);
+	void (*doi_free)(struct calipso_doi *doi_def);
+};
+
 /*
  * LSM security attribute operations (inline)
  */
@@ -598,4 +618,7 @@ static inline struct audit_buffer *netlbl_audit_start(int type,
 }
 #endif /* CONFIG_NETLABEL */
 
+const struct netlbl_calipso_ops *
+netlbl_calipso_ops_register(const struct netlbl_calipso_ops *ops);
+
 #endif /* _NETLABEL_H */
diff --git a/include/uapi/linux/audit.h b/include/uapi/linux/audit.h
index d820aa9..82e8aa5 100644
--- a/include/uapi/linux/audit.h
+++ b/include/uapi/linux/audit.h
@@ -130,6 +130,8 @@
 #define AUDIT_MAC_IPSEC_EVENT	1415	/* Audit an IPSec event */
 #define AUDIT_MAC_UNLBL_STCADD	1416	/* NetLabel: add a static label */
 #define AUDIT_MAC_UNLBL_STCDEL	1417	/* NetLabel: del a static label */
+#define AUDIT_MAC_CALIPSO_ADD	1418	/* NetLabel: add CALIPSO DOI entry */
+#define AUDIT_MAC_CALIPSO_DEL	1419	/* NetLabel: del CALIPSO DOI entry */
 
 #define AUDIT_FIRST_KERN_ANOM_MSG   1700
 #define AUDIT_LAST_KERN_ANOM_MSG    1799
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 2fbd90b..88ad447 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -21,6 +21,7 @@ ipv6-$(CONFIG_NETFILTER) += netfilter.o
 ipv6-$(CONFIG_IPV6_MULTIPLE_TABLES) += fib6_rules.o
 ipv6-$(CONFIG_PROC_FS) += proc.o
 ipv6-$(CONFIG_SYN_COOKIES) += syncookies.o
+ipv6-$(CONFIG_NETLABEL) += calipso.o
 
 ipv6-objs += $(ipv6-y)
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index b11c37c..c241c18 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -60,6 +60,7 @@
 #ifdef CONFIG_IPV6_TUNNEL
 #include <net/ip6_tunnel.h>
 #endif
+#include <net/calipso.h>
 
 #include <asm/uaccess.h>
 #include <linux/mroute6.h>
@@ -970,6 +971,10 @@ static int __init inet6_init(void)
 	if (err)
 		goto pingv6_fail;
 
+	err = calipso_init();
+	if (err)
+		goto calipso_fail;
+
 #ifdef CONFIG_SYSCTL
 	err = ipv6_sysctl_register();
 	if (err)
@@ -980,8 +985,10 @@ out:
 
 #ifdef CONFIG_SYSCTL
 sysctl_fail:
-	pingv6_exit();
+	calipso_exit();
 #endif
+calipso_fail:
+	pingv6_exit();
 pingv6_fail:
 	ipv6_packet_cleanup();
 ipv6_packet_fail:
diff --git a/net/ipv6/calipso.c b/net/ipv6/calipso.c
new file mode 100644
index 0000000..aa44310
--- /dev/null
+++ b/net/ipv6/calipso.c
@@ -0,0 +1,169 @@
+/*
+ * CALIPSO - Common Architecture Label IPv6 Security Option
+ *
+ * This is an implementation of the CALIPSO protocol as specified in
+ * RFC 5570.
+ *
+ * Authors: Paul Moore <paul.moore@hp.com>
+ *          Huw Davies <huw@codeweavers.com>
+ *
+ */
+
+/* (c) Copyright Hewlett-Packard Development Company, L.P., 2006, 2008
+ * (c) Copyright Huw Davies <huw@codeweavers.com>, 2015
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
+ * along with this program;  if not, see <http://www.gnu.org/licenses/>.
+ *
+ */
+
+#include <linux/init.h>
+#include <linux/types.h>
+#include <linux/rcupdate.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/string.h>
+#include <linux/jhash.h>
+#include <linux/audit.h>
+#include <linux/slab.h>
+#include <net/ip.h>
+#include <net/icmp.h>
+#include <net/tcp.h>
+#include <net/netlabel.h>
+#include <net/calipso.h>
+#include <linux/atomic.h>
+#include <linux/bug.h>
+#include <asm/unaligned.h>
+
+/* List of available DOI definitions */
+static DEFINE_SPINLOCK(calipso_doi_list_lock);
+static LIST_HEAD(calipso_doi_list);
+
+/* DOI List Functions
+ */
+
+/**
+ * calipso_doi_search - Searches for a DOI definition
+ * @doi: the DOI to search for
+ *
+ * Description:
+ * Search the DOI definition list for a DOI definition with a DOI value that
+ * matches @doi.  The caller is responsible for calling rcu_read_[un]lock().
+ * Returns a pointer to the DOI definition on success and NULL on failure.
+ */
+static struct calipso_doi *calipso_doi_search(u32 doi)
+{
+	struct calipso_doi *iter;
+
+	list_for_each_entry_rcu(iter, &calipso_doi_list, list)
+		if (iter->doi == doi && atomic_read(&iter->refcount))
+			return iter;
+	return NULL;
+}
+
+/**
+ * calipso_doi_add - Add a new DOI to the CALIPSO protocol engine
+ * @doi_def: the DOI structure
+ * @audit_info: NetLabel audit information
+ *
+ * Description:
+ * The caller defines a new DOI for use by the CALIPSO engine and calls this
+ * function to add it to the list of acceptable domains.  The caller must
+ * ensure that the mapping table specified in @doi_def->map meets all of the
+ * requirements of the mapping type (see calipso.h for details).  Returns
+ * zero on success and non-zero on failure.
+ *
+ */
+static int calipso_doi_add(struct calipso_doi *doi_def,
+			   struct netlbl_audit *audit_info)
+{
+	int ret_val = -EINVAL;
+	u32 doi;
+	u32 doi_type;
+	struct audit_buffer *audit_buf;
+
+	doi = doi_def->doi;
+	doi_type = doi_def->type;
+
+	if (doi_def->doi == CALIPSO_DOI_UNKNOWN)
+		goto doi_add_return;
+
+	atomic_set(&doi_def->refcount, 1);
+
+	spin_lock(&calipso_doi_list_lock);
+	if (calipso_doi_search(doi_def->doi)) {
+		spin_unlock(&calipso_doi_list_lock);
+		ret_val = -EEXIST;
+		goto doi_add_return;
+	}
+	list_add_tail_rcu(&doi_def->list, &calipso_doi_list);
+	spin_unlock(&calipso_doi_list_lock);
+	ret_val = 0;
+
+doi_add_return:
+	audit_buf = netlbl_audit_start(AUDIT_MAC_CALIPSO_ADD, audit_info);
+	if (audit_buf) {
+		const char *type_str;
+
+		switch (doi_type) {
+		case CALIPSO_MAP_PASS:
+			type_str = "pass";
+			break;
+		default:
+			type_str = "(unknown)";
+		}
+		audit_log_format(audit_buf,
+				 " calipso_doi=%u calipso_type=%s res=%u",
+				 doi, type_str, ret_val == 0 ? 1 : 0);
+		audit_log_end(audit_buf);
+	}
+
+	return ret_val;
+}
+
+/**
+ * calipso_doi_free - Frees a DOI definition
+ * @doi_def: the DOI definition
+ *
+ * Description:
+ * This function frees all of the memory associated with a DOI definition.
+ *
+ */
+static void calipso_doi_free(struct calipso_doi *doi_def)
+{
+	kfree(doi_def);
+}
+
+static const struct netlbl_calipso_ops ops = {
+	.doi_add          = calipso_doi_add,
+	.doi_free         = calipso_doi_free,
+};
+
+/**
+ * calipso_init - Initialize the CALIPSO module
+ *
+ * Description:
+ * Initialize the CALIPSO module and prepare it for use.  Returns zero on
+ * success and negative values on failure.
+ *
+ */
+int __init calipso_init(void)
+{
+	netlbl_calipso_ops_register(&ops);
+	return 0;
+}
+
+void calipso_exit(void)
+{
+	netlbl_calipso_ops_register(NULL);
+}
diff --git a/net/netlabel/Makefile b/net/netlabel/Makefile
index d2732fc..d341ede 100644
--- a/net/netlabel/Makefile
+++ b/net/netlabel/Makefile
@@ -12,4 +12,4 @@ obj-y	+= netlabel_mgmt.o
 # protocol modules
 obj-y	+= netlabel_unlabeled.o
 obj-y	+= netlabel_cipso_v4.o
-
+obj-$(subst m,y,$(CONFIG_IPV6)) += netlabel_calipso.o
diff --git a/net/netlabel/netlabel_calipso.c b/net/netlabel/netlabel_calipso.c
new file mode 100644
index 0000000..8a113f9
--- /dev/null
+++ b/net/netlabel/netlabel_calipso.c
@@ -0,0 +1,216 @@
+/*
+ * NetLabel CALIPSO/IPv6 Support
+ *
+ * This file defines the CALIPSO/IPv6 functions for the NetLabel system.  The
+ * NetLabel system manages static and dynamic label mappings for network
+ * protocols such as CIPSO and CALIPSO.
+ *
+ * Authors: Paul Moore <paul@paul-moore.com>
+ *          Huw Davies <huw@codeweavers.com>
+ *
+ */
+
+/* (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ * (c) Copyright Huw Davies <huw@codeweavers.com>, 2015
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
+ * along with this program;  if not, see <http://www.gnu.org/licenses/>.
+ *
+ */
+
+#include <linux/types.h>
+#include <linux/socket.h>
+#include <linux/string.h>
+#include <linux/skbuff.h>
+#include <linux/audit.h>
+#include <linux/slab.h>
+#include <net/sock.h>
+#include <net/netlink.h>
+#include <net/genetlink.h>
+#include <net/netlabel.h>
+#include <net/calipso.h>
+#include <linux/atomic.h>
+
+#include "netlabel_user.h"
+#include "netlabel_calipso.h"
+#include "netlabel_mgmt.h"
+#include "netlabel_domainhash.h"
+
+/* NetLabel Generic NETLINK CALIPSO family */
+static struct genl_family netlbl_calipso_gnl_family = {
+	.id = GENL_ID_GENERATE,
+	.hdrsize = 0,
+	.name = NETLBL_NLTYPE_CALIPSO_NAME,
+	.version = NETLBL_PROTO_VERSION,
+	.maxattr = NLBL_CALIPSO_A_MAX,
+};
+
+/* NetLabel Netlink attribute policy */
+static const struct nla_policy calipso_genl_policy[NLBL_CALIPSO_A_MAX + 1] = {
+	[NLBL_CALIPSO_A_DOI] = { .type = NLA_U32 },
+	[NLBL_CALIPSO_A_MTYPE] = { .type = NLA_U32 },
+};
+
+/* NetLabel Command Handlers
+ */
+/**
+ * netlbl_calipso_add_pass - Adds a CALIPSO pass DOI definition
+ * @info: the Generic NETLINK info block
+ * @audit_info: NetLabel audit information
+ *
+ * Description:
+ * Create a new CALIPSO_MAP_PASS DOI definition based on the given ADD message
+ * and add it to the CALIPSO engine.  Return zero on success and non-zero on
+ * error.
+ *
+ */
+static int netlbl_calipso_add_pass(struct genl_info *info,
+				   struct netlbl_audit *audit_info)
+{
+	int ret_val;
+	struct calipso_doi *doi_def = NULL;
+
+	doi_def = kmalloc(sizeof(*doi_def), GFP_KERNEL);
+	if (!doi_def)
+		return -ENOMEM;
+	doi_def->type = CALIPSO_MAP_PASS;
+	doi_def->doi = nla_get_u32(info->attrs[NLBL_CALIPSO_A_DOI]);
+	ret_val = calipso_doi_add(doi_def, audit_info);
+	if (ret_val != 0)
+		calipso_doi_free(doi_def);
+
+	return ret_val;
+}
+
+/**
+ * netlbl_calipso_add - Handle an ADD message
+ * @skb: the NETLINK buffer
+ * @info: the Generic NETLINK info block
+ *
+ * Description:
+ * Create a new DOI definition based on the given ADD message and add it to the
+ * CALIPSO engine.  Returns zero on success, negative values on failure.
+ *
+ */
+static int netlbl_calipso_add(struct sk_buff *skb, struct genl_info *info)
+
+{
+	int ret_val = -EINVAL;
+	struct netlbl_audit audit_info;
+
+	if (!info->attrs[NLBL_CALIPSO_A_DOI] ||
+	    !info->attrs[NLBL_CALIPSO_A_MTYPE])
+		return -EINVAL;
+
+	netlbl_netlink_auditinfo(skb, &audit_info);
+	switch (nla_get_u32(info->attrs[NLBL_CALIPSO_A_MTYPE])) {
+	case CALIPSO_MAP_PASS:
+		ret_val = netlbl_calipso_add_pass(info, &audit_info);
+		break;
+	}
+	if (ret_val == 0)
+		atomic_inc(&netlabel_mgmt_protocount);
+
+	return ret_val;
+}
+
+/* NetLabel Generic NETLINK Command Definitions
+ */
+
+static const struct genl_ops netlbl_calipso_ops[] = {
+	{
+	.cmd = NLBL_CALIPSO_C_ADD,
+	.flags = GENL_ADMIN_PERM,
+	.policy = calipso_genl_policy,
+	.doit = netlbl_calipso_add,
+	.dumpit = NULL,
+	},
+};
+
+/* NetLabel Generic NETLINK Protocol Functions
+ */
+
+/**
+ * netlbl_calipso_genl_init - Register the CALIPSO NetLabel component
+ *
+ * Description:
+ * Register the CALIPSO packet NetLabel component with the Generic NETLINK
+ * mechanism.  Returns zero on success, negative values on failure.
+ *
+ */
+int __init netlbl_calipso_genl_init(void)
+{
+	return genl_register_family_with_ops(&netlbl_calipso_gnl_family,
+					     netlbl_calipso_ops);
+}
+
+static const struct netlbl_calipso_ops *calipso_ops;
+
+/**
+ * netlbl_calipso_ops_register - Register the CALIPSO operations
+ *
+ * Description:
+ * Register the CALIPSO packet engine operations.
+ *
+ */
+const struct netlbl_calipso_ops *
+netlbl_calipso_ops_register(const struct netlbl_calipso_ops *ops)
+{
+	return xchg(&calipso_ops, ops);
+}
+EXPORT_SYMBOL(netlbl_calipso_ops_register);
+
+static const struct netlbl_calipso_ops *netlbl_calipso_ops_get(void)
+{
+	return ACCESS_ONCE(calipso_ops);
+}
+
+/**
+ * calipso_doi_add - Add a new DOI to the CALIPSO protocol engine
+ * @doi_def: the DOI structure
+ * @audit_info: NetLabel audit information
+ *
+ * Description:
+ * The caller defines a new DOI for use by the CALIPSO engine and calls this
+ * function to add it to the list of acceptable domains.  The caller must
+ * ensure that the mapping table specified in @doi_def->map meets all of the
+ * requirements of the mapping type (see calipso.h for details).  Returns
+ * zero on success and non-zero on failure.
+ *
+ */
+int calipso_doi_add(struct calipso_doi *doi_def,
+		    struct netlbl_audit *audit_info)
+{
+	int ret_val = -ENOMSG;
+	const struct netlbl_calipso_ops *ops = netlbl_calipso_ops_get();
+
+	if (ops)
+		ret_val = ops->doi_add(doi_def, audit_info);
+	return ret_val;
+}
+
+/**
+ * calipso_doi_free - Frees a DOI definition
+ * @doi_def: the DOI definition
+ *
+ * Description:
+ * This function frees all of the memory associated with a DOI definition.
+ *
+ */
+void calipso_doi_free(struct calipso_doi *doi_def)
+{
+	const struct netlbl_calipso_ops *ops = netlbl_calipso_ops_get();
+
+	if (ops)
+		ops->doi_free(doi_def);
+}
diff --git a/net/netlabel/netlabel_calipso.h b/net/netlabel/netlabel_calipso.h
new file mode 100644
index 0000000..f78790a
--- /dev/null
+++ b/net/netlabel/netlabel_calipso.h
@@ -0,0 +1,90 @@
+/*
+ * NetLabel CALIPSO Support
+ *
+ * This file defines the CALIPSO functions for the NetLabel system.  The
+ * NetLabel system manages static and dynamic label mappings for network
+ * protocols such as CIPSO and RIPSO.
+ *
+ * Authors: Paul Moore <paul@paul-moore.com>
+ *          Huw Davies <huw@codeweavers.com>
+ *
+ */
+
+/* (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ * (c) Copyright Huw Davies <huw@codeweavers.com>, 2015
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
+ * along with this program;  if not, see <http://www.gnu.org/licenses/>.
+ *
+ */
+
+#ifndef _NETLABEL_CALIPSO
+#define _NETLABEL_CALIPSO
+
+#include <net/netlabel.h>
+#include <net/calipso.h>
+
+/* The following NetLabel payloads are supported by the CALIPSO subsystem.
+ *
+ * o ADD:
+ *   Sent by an application to add a new DOI mapping table.
+ *
+ *   Required attributes:
+ *
+ *     NLBL_CALIPSO_A_DOI
+ *     NLBL_CALIPSO_A_MTYPE
+ *
+ *   If using CALIPSO_MAP_PASS no additional attributes are required.
+ *
+ */
+
+/* NetLabel CALIPSO commands */
+enum {
+	NLBL_CALIPSO_C_UNSPEC,
+	NLBL_CALIPSO_C_ADD,
+	NLBL_CALIPSO_C_REMOVE,
+	NLBL_CALIPSO_C_LIST,
+	NLBL_CALIPSO_C_LISTALL,
+	__NLBL_CALIPSO_C_MAX,
+};
+
+/* NetLabel CALIPSO attributes */
+enum {
+	NLBL_CALIPSO_A_UNSPEC,
+	NLBL_CALIPSO_A_DOI,
+	/* (NLA_U32)
+	 * the DOI value */
+	NLBL_CALIPSO_A_MTYPE,
+	/* (NLA_U32)
+	 * the mapping table type (defined in the calipso.h header as
+	 * CALIPSO_MAP_*) */
+	__NLBL_CALIPSO_A_MAX,
+};
+
+#define NLBL_CALIPSO_A_MAX (__NLBL_CALIPSO_A_MAX - 1)
+
+/* NetLabel protocol functions */
+#if IS_ENABLED(CONFIG_IPV6)
+int netlbl_calipso_genl_init(void);
+#else
+static inline int netlbl_calipso_genl_init(void)
+{
+	return 0;
+}
+#endif
+
+int calipso_doi_add(struct calipso_doi *doi_def,
+		    struct netlbl_audit *audit_info);
+void calipso_doi_free(struct calipso_doi *doi_def);
+
+#endif
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 3b62707..55c59a0 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -1163,6 +1163,7 @@ struct audit_buffer *netlbl_audit_start(int type,
 {
 	return netlbl_audit_start_common(type, audit_info);
 }
+EXPORT_SYMBOL(netlbl_audit_start);
 
 /*
  * Setup Functions
diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index b2aeb5d..975b1e9 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -674,6 +674,15 @@ static int netlbl_mgmt_protocols(struct sk_buff *skb,
 			goto protocols_return;
 		protos_sent++;
 	}
+#if IS_ENABLED(CONFIG_IPV6)
+	if (protos_sent == 2) {
+		if (netlbl_mgmt_protocols_cb(skb,
+					     cb,
+					     NETLBL_NLTYPE_CALIPSO) < 0)
+			goto protocols_return;
+		protos_sent++;
+	}
+#endif
 
 protocols_return:
 	cb->args[0] = protos_sent;
diff --git a/net/netlabel/netlabel_user.c b/net/netlabel/netlabel_user.c
index adf8b79..58495f4 100644
--- a/net/netlabel/netlabel_user.c
+++ b/net/netlabel/netlabel_user.c
@@ -44,6 +44,7 @@
 #include "netlabel_mgmt.h"
 #include "netlabel_unlabeled.h"
 #include "netlabel_cipso_v4.h"
+#include "netlabel_calipso.h"
 #include "netlabel_user.h"
 
 /*
@@ -71,6 +72,10 @@ int __init netlbl_netlink_init(void)
 	if (ret_val != 0)
 		return ret_val;
 
+	ret_val = netlbl_calipso_genl_init();
+	if (ret_val != 0)
+		return ret_val;
+
 	return netlbl_unlabel_genl_init();
 }
 
-- 
2.7.4

