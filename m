From: paul.moore@hp.com
Subject: [PATCH-v01 2/7] NetLabel: core network changes
Date: Thu, 03 Aug 2006 16:09:30 -0400
Message-ID: <20060803201555.460092000@flek.zko.hp.com>
References: <20060803200928.721027000@flek.zko.hp.com>
Cc: linda.knippers@hp.com, sds@tycho.nsa.gov, jmorris@namei.org,
	davem@davemloft.net, Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:37073 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S932566AbWHCUQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 16:16:00 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-net_core-2.6.19
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changes to the core network stack to support the NetLabel subsystem.  This
includes changes to the IPv4 option handling to support CIPSO labels.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 include/linux/ip.h       |    1 
 include/net/cipso_ipv4.h |  250 ++++++++++++++++++++++++++++++++++++++++
 include/net/inet_sock.h  |    2 
 include/net/netlabel.h   |  291 +++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/ah4.c           |    2 
 net/ipv4/ip_options.c    |   19 +++
 6 files changed, 563 insertions(+), 2 deletions(-)

Index: net-2.6.19/include/linux/ip.h
===================================================================
--- net-2.6.19.orig/include/linux/ip.h
+++ net-2.6.19/include/linux/ip.h
@@ -57,6 +57,7 @@
 #define IPOPT_SEC	(2 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_LSRR	(3 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_TIMESTAMP	(4 |IPOPT_MEASUREMENT)
+#define IPOPT_CIPSO	(6 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_RR	(7 |IPOPT_CONTROL)
 #define IPOPT_SID	(8 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_SSRR	(9 |IPOPT_CONTROL|IPOPT_COPY)
Index: net-2.6.19/include/net/cipso_ipv4.h
===================================================================
--- /dev/null
+++ net-2.6.19/include/net/cipso_ipv4.h
@@ -0,0 +1,250 @@
+/*
+ * CIPSO - Commercial IP Security Option
+ *
+ * This is an implementation of the CIPSO 2.2 protocol as specified in
+ * draft-ietf-cipso-ipsecurity-01.txt with additional tag types as found in
+ * FIPS-188, copies of both documents can be found in the Documentation
+ * directory.  While CIPSO never became a full IETF RFC standard many vendors
+ * have chosen to adopt the protocol and over the years it has become a
+ * de-facto standard for labeled networking.
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
+#ifndef _CIPSO_IPV4_H
+#define _CIPSO_IPV4_H
+
+#include <linux/types.h>
+#include <linux/rcupdate.h>
+#include <linux/list.h>
+#include <net/netlabel.h>
+
+/* known doi values */
+#define CIPSO_V4_DOI_UNKNOWN          0x00000000
+
+/* tag types */
+#define CIPSO_V4_TAG_INVALID          0
+#define CIPSO_V4_TAG_RBITMAP          1
+#define CIPSO_V4_TAG_ENUM             2
+#define CIPSO_V4_TAG_RANGE            5
+#define CIPSO_V4_TAG_PBITMAP          6
+#define CIPSO_V4_TAG_FREEFORM         7
+
+/* doi mapping types */
+#define CIPSO_V4_MAP_UNKNOWN          0
+#define CIPSO_V4_MAP_STD              1
+#define CIPSO_V4_MAP_PASS             2
+
+/* limits */
+#define CIPSO_V4_MAX_REM_LVLS         256
+#define CIPSO_V4_INV_LVL              0x80000000
+#define CIPSO_V4_MAX_LOC_LVLS         (CIPSO_V4_INV_LVL - 1)
+#define CIPSO_V4_MAX_REM_CATS         65536
+#define CIPSO_V4_INV_CAT              0x80000000
+#define CIPSO_V4_MAX_LOC_CATS         (CIPSO_V4_INV_CAT - 1)
+
+/*
+ * CIPSO DOI definitions
+ */
+
+/* DOI definition struct */
+#define CIPSO_V4_TAG_MAXCNT           5
+struct cipso_v4_doi {
+	u32 doi;
+	u32 type;
+	union {
+		struct cipso_v4_std_map_tbl *std;
+	} map;
+	u8 tags[CIPSO_V4_TAG_MAXCNT];
+
+	u32 valid;
+	struct list_head list;
+	struct rcu_head rcu;
+	struct list_head dom_list;
+};
+
+/* Standard CIPSO mapping table */
+/* NOTE: the highest order bit (i.e. 0x80000000) is an 'invalid' flag, if the
+ *       bit is set then consider that value as unspecified, meaning the
+ *       mapping for that particular level/category is invalid */
+struct cipso_v4_std_map_tbl {
+	struct {
+		u32 *cipso;
+		u32 *local;
+		u32 cipso_size;
+		u32 local_size;
+	} lvl;
+	struct {
+		u32 *cipso;
+		u32 *local;
+		u32 cipso_size;
+		u32 local_size;
+	} cat;
+};
+
+/*
+ * Sysctl Variables
+ */
+
+#ifdef CONFIG_NETLABEL
+extern int cipso_v4_cache_enabled;
+extern int cipso_v4_cache_bucketsize;
+extern int cipso_v4_rbm_optfmt;
+extern int cipso_v4_rbm_strictvalid;
+#endif
+
+/*
+ * Helper Functions
+ */
+
+#define CIPSO_V4_OPTEXIST(x) (IPCB(x)->opt.cipso != 0)
+#define CIPSO_V4_OPTPTR(x) ((x)->nh.raw + IPCB(x)->opt.cipso)
+
+/*
+ * DOI List Functions
+ */
+
+#ifdef CONFIG_NETLABEL
+int cipso_v4_doi_add(struct cipso_v4_doi *doi_def);
+int cipso_v4_doi_remove(u32 doi, void (*callback) (struct rcu_head * head));
+struct cipso_v4_doi *cipso_v4_doi_getdef(u32 doi);
+struct sk_buff *cipso_v4_doi_dump_all(size_t headroom);
+struct sk_buff *cipso_v4_doi_dump(u32 doi, size_t headroom);
+int cipso_v4_doi_domhsh_add(struct cipso_v4_doi *doi_def, const char *domain);
+int cipso_v4_doi_domhsh_remove(struct cipso_v4_doi *doi_def,
+			       const char *domain);
+#else
+static inline int cipso_v4_doi_add(struct cipso_v4_doi *doi_def)
+{
+	return -ENOSYS;
+}
+
+static inline int cipso_v4_doi_remove(u32 doi,
+				    void (*callback) (struct rcu_head * head))
+{
+	return 0;
+}
+
+static inline struct cipso_v4_doi *cipso_v4_doi_getdef(u32 doi)
+{
+	return NULL;
+}
+
+static inline struct sk_buff *cipso_v4_doi_dump_all(size_t headroom)
+{
+	return NULL;
+}
+
+static inline struct sk_buff *cipso_v4_doi_dump(u32 doi, size_t headroom)
+{
+	return NULL;
+}
+
+static inline int cipso_v4_doi_domhsh_add(struct cipso_v4_doi *doi_def,
+					  const char *domain)
+{
+	return -ENOSYS;
+}
+
+static inline int cipso_v4_doi_domhsh_remove(struct cipso_v4_doi *doi_def,
+					     const char *domain)
+{
+	return 0;
+}
+#endif /* CONFIG_NETLABEL */
+
+/*
+ * Label Mapping Cache Functions
+ */
+
+#ifdef CONFIG_NETLABEL
+void cipso_v4_cache_invalidate(void);
+int cipso_v4_cache_add(const struct sk_buff *skb,
+		       const struct netlbl_lsm_secattr *secattr);
+#else
+static inline void cipso_v4_cache_invalidate(void)
+{
+	return;
+}
+
+static inline int cipso_v4_cache_add(const struct sk_buff *skb,
+				     const struct netlbl_lsm_secattr *secattr)
+{
+	return 0;
+}
+#endif /* CONFIG_NETLABEL */
+
+/*
+ * Protocol Handling Functions
+ */
+
+#ifdef CONFIG_NETLABEL
+void cipso_v4_error(struct sk_buff *skb, int error, u32 gateway);
+int cipso_v4_socket_setopt(struct socket *sock,
+			   unsigned char *opt,
+			   u32 opt_len);
+int cipso_v4_socket_setattr(const struct socket *sock,
+			    const struct cipso_v4_doi *doi_def,
+			    const struct netlbl_lsm_secattr *secattr);
+int cipso_v4_socket_getopt(const struct socket *sock,
+			   unsigned char **opt,
+			   u32 *opt_len);
+int cipso_v4_socket_getattr(const struct socket *sock,
+			    struct netlbl_lsm_secattr *secattr);
+int cipso_v4_skbuff_getattr(const struct sk_buff *skb,
+			    struct netlbl_lsm_secattr *secattr);
+int cipso_v4_validate(unsigned char **option);
+#else
+static inline void cipso_v4_error(struct sk_buff *skb,
+				  int error,
+				  u32 gateway)
+{
+	return;
+}
+
+static inline int cipso_v4_socket_setattr(const struct socket *sock,
+				  const struct cipso_v4_doi *doi_def,
+				  const struct netlbl_lsm_secattr *secattr)
+{
+	return -ENOSYS;
+}
+
+static inline int cipso_v4_socket_getattr(const struct socket *sock,
+					  struct netlbl_lsm_secattr *secattr)
+{
+	return -ENOSYS;
+}
+
+static inline int cipso_v4_skbuff_getattr(const struct sk_buff *skb,
+					  struct netlbl_lsm_secattr *secattr)
+{
+	return -ENOSYS;
+}
+
+static inline int cipso_v4_validate(unsigned char **option)
+{
+	return -ENOSYS;
+}
+#endif /* CONFIG_NETLABEL */
+
+#endif /* _CIPSO_IPV4_H */
Index: net-2.6.19/include/net/inet_sock.h
===================================================================
--- net-2.6.19.orig/include/net/inet_sock.h
+++ net-2.6.19/include/net/inet_sock.h
@@ -51,7 +51,7 @@ struct ip_options {
 			ts_needtime:1,
 			ts_needaddr:1;
 	unsigned char	router_alert;
-	unsigned char	__pad1;
+	unsigned char	cipso;
 	unsigned char	__pad2;
 	unsigned char	__data[0];
 };
Index: net-2.6.19/include/net/netlabel.h
===================================================================
--- /dev/null
+++ net-2.6.19/include/net/netlabel.h
@@ -0,0 +1,291 @@
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
+ * NetLabel makes use of the Generic NETLINK mechanism as a transport layer to
+ * send messages between kernel and user space.  The general format of a
+ * NetLabel message is shown below:
+ *
+ *  +-----------------+-------------------+--------- --- -- -
+ *  | struct nlmsghdr | struct genlmsghdr | payload
+ *  +-----------------+-------------------+--------- --- -- -
+ *
+ * The 'nlmsghdr' and 'genlmsghdr' structs should be dealt with like normal.
+ * The payload is dependent on the subsystem specified in the
+ * 'nlmsghdr->nlmsg_type' and should be defined below, supporting functions
+ * should be defined in the corresponding net/netlabel/netlabel_<subsys>.h|c
+ * file.  All of the fields in the NetLabel payload are NETLINK attributes, the
+ * length of each field is the length of the NETLINK attribute payload, see
+ * include/net/netlink.h for more information on NETLINK attributes.
+ *
+ */
+
+/*
+ * NetLabel NETLINK protocol
+ */
+
+#define NETLBL_PROTO_VERSION            1
+
+/* NetLabel NETLINK types/families */
+#define NETLBL_NLTYPE_NONE              0
+#define NETLBL_NLTYPE_MGMT              1
+#define NETLBL_NLTYPE_MGMT_NAME         "NLBL_MGMT"
+#define NETLBL_NLTYPE_RIPSO             2
+#define NETLBL_NLTYPE_RIPSO_NAME        "NLBL_RIPSO"
+#define NETLBL_NLTYPE_CIPSOV4           3
+#define NETLBL_NLTYPE_CIPSOV4_NAME      "NLBL_CIPSOv4"
+#define NETLBL_NLTYPE_CIPSOV6           4
+#define NETLBL_NLTYPE_CIPSOV6_NAME      "NLBL_CIPSOv6"
+#define NETLBL_NLTYPE_UNLABELED         5
+#define NETLBL_NLTYPE_UNLABELED_NAME    "NLBL_UNLBL"
+
+/* NetLabel return codes */
+#define NETLBL_E_OK                     0
+
+/*
+ * Helper functions
+ */
+
+#define NETLBL_LEN_U8                   nla_total_size(sizeof(u8))
+#define NETLBL_LEN_U16                  nla_total_size(sizeof(u16))
+#define NETLBL_LEN_U32                  nla_total_size(sizeof(u32))
+
+/**
+ * netlbl_netlink_alloc_skb - Allocate a NETLINK message buffer
+ * @head: the amount of headroom in bytes
+ * @body: the desired size (minus headroom) in bytes
+ * @gfp_flags: the alloc flags to pass to alloc_skb()
+ *
+ * Description:
+ * Allocate a NETLINK message buffer based on the sizes given in @head and
+ * @body.  If @head is greater than zero skb_reserve() is called to reserve
+ * @head bytes at the start of the buffer.  Returns a valid sk_buff pointer on
+ * success, NULL on failure.
+ *
+ */
+static inline struct sk_buff *netlbl_netlink_alloc_skb(size_t head,
+						       size_t body,
+						       int gfp_flags)
+{
+	struct sk_buff *skb;
+
+	skb = alloc_skb(NLMSG_ALIGN(head + body), gfp_flags);
+	if (skb == NULL)
+		return NULL;
+	if (head > 0) {
+		skb_reserve(skb, head);
+		if (skb_tailroom(skb) < body) {
+			kfree_skb(skb);
+			return NULL;
+		}
+	}
+
+	return skb;
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
+	u32 mls_lvl_vld;
+	unsigned char *mls_cat;
+	size_t mls_cat_len;
+
+	struct netlbl_lsm_cache cache;
+};
+
+/*
+ * LSM security attribute operations
+ */
+
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
+static inline int netlbl_secattr_init(struct netlbl_lsm_secattr *secattr)
+{
+	memset(secattr, 0, sizeof(*secattr));
+	return 0;
+}
+
+/**
+ * netlbl_secattr_destroy - Clears a netlbl_lsm_secattr struct
+ * @secattr: the struct to clear
+ * @clear_cache: cache clear flag
+ *
+ * Description:
+ * Destroys the @secattr struct, including freeing all of the internal buffers.
+ * If @clear_cache is true then free the cache fields, otherwise leave them
+ * intact.  The struct must be reset with a call to netlbl_secattr_init()
+ * before reuse.
+ *
+ */
+static inline void netlbl_secattr_destroy(struct netlbl_lsm_secattr *secattr,
+					  u32 clear_cache)
+{
+	if (clear_cache && secattr->cache.data != NULL && secattr->cache.free)
+		secattr->cache.free(secattr->cache.data);
+	kfree(secattr->domain);
+	kfree(secattr->mls_cat);
+}
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
+static inline struct netlbl_lsm_secattr *netlbl_secattr_alloc(int flags)
+{
+	return kzalloc(sizeof(struct netlbl_lsm_secattr), flags);
+}
+
+/**
+ * netlbl_secattr_free - Frees a netlbl_lsm_secattr struct
+ * @secattr: the struct to free
+ * @clear_cache: cache clear flag
+ *
+ * Description:
+ * Frees @secattr including all of the internal buffers.  If @clear_cache is
+ * true then free the cache fields, otherwise leave them intact.
+ *
+ */
+static inline void netlbl_secattr_free(struct netlbl_lsm_secattr *secattr,
+				       u32 clear_cache)
+{
+	netlbl_secattr_destroy(secattr, clear_cache);
+	kfree(secattr);
+}
+
+/*
+ * LSM protocol operations
+ */
+
+#ifdef CONFIG_NETLABEL
+int netlbl_socket_setattr(const struct socket *sock,
+			  const struct netlbl_lsm_secattr *secattr);
+int netlbl_socket_getattr(const struct socket *sock,
+			  struct netlbl_lsm_secattr *secattr);
+int netlbl_skbuff_getattr(const struct sk_buff *skb,
+			  struct netlbl_lsm_secattr *secattr);
+void netlbl_skbuff_err(struct sk_buff *skb, int error);
+#else
+static inline int netlbl_socket_setattr(const struct socket *sock,
+				     const struct netlbl_lsm_secattr *secattr)
+{
+	return -ENOSYS;
+}
+
+static inline int netlbl_socket_getattr(const struct socket *sock,
+					struct netlbl_lsm_secattr *secattr)
+{
+	return -ENOSYS;
+}
+
+static inline int netlbl_skbuff_getattr(const struct sk_buff *skb,
+					struct netlbl_lsm_secattr *secattr)
+{
+	return -ENOSYS;
+}
+
+static inline void netlbl_skbuff_err(struct sk_buff *skb, int error)
+{
+	return;
+}
+#endif /* CONFIG_NETLABEL */
+
+/*
+ * LSM label mapping cache operations
+ */
+
+#ifdef CONFIG_NETLABEL
+void netlbl_cache_invalidate(void);
+int netlbl_cache_add(const struct sk_buff *skb,
+		     const struct netlbl_lsm_secattr *secattr);
+#else
+static inline void netlbl_cache_invalidate(void)
+{
+	return;
+}
+
+static inline int netlbl_cache_add(const struct sk_buff *skb,
+				   const struct netlbl_lsm_secattr *secattr)
+{
+	return 0;
+}
+#endif /* CONFIG_NETLABEL */
+
+#endif /* _NETLABEL_H */
Index: net-2.6.19/net/ipv4/ah4.c
===================================================================
--- net-2.6.19.orig/net/ipv4/ah4.c
+++ net-2.6.19/net/ipv4/ah4.c
@@ -34,7 +34,7 @@ static int ip_clear_mutable_options(stru
 		switch (*optptr) {
 		case IPOPT_SEC:
 		case 0x85:	/* Some "Extended Security" crap. */
-		case 0x86:	/* Another "Commercial Security" crap. */
+		case IPOPT_CIPSO:
 		case IPOPT_RA:
 		case 0x80|21:	/* RFC1770 */
 			break;
Index: net-2.6.19/net/ipv4/ip_options.c
===================================================================
--- net-2.6.19.orig/net/ipv4/ip_options.c
+++ net-2.6.19/net/ipv4/ip_options.c
@@ -24,6 +24,7 @@
 #include <net/ip.h>
 #include <net/icmp.h>
 #include <net/route.h>
+#include <net/cipso_ipv4.h>
 
 /* 
  * Write options to IP header, record destination address to
@@ -194,6 +195,13 @@ int ip_options_echo(struct ip_options * 
 			dopt->is_strictroute = sopt->is_strictroute;
 		}
 	}
+	if (sopt->cipso) {
+		optlen  = sptr[sopt->cipso+1];
+		dopt->cipso = dopt->optlen+sizeof(struct iphdr);
+		memcpy(dptr, sptr+sopt->cipso, optlen);
+		dptr += optlen;
+		dopt->optlen += optlen;
+	}
 	while (dopt->optlen & 3) {
 		*dptr++ = IPOPT_END;
 		dopt->optlen++;
@@ -434,6 +442,17 @@ int ip_options_compile(struct ip_options
 			if (optptr[2] == 0 && optptr[3] == 0)
 				opt->router_alert = optptr - iph;
 			break;
+		      case IPOPT_CIPSO:
+		        if (opt->cipso) {
+				pp_ptr = optptr;
+				goto error;
+			}
+			opt->cipso = optptr - iph;
+		        if (cipso_v4_validate(&optptr)) {
+				pp_ptr = optptr;
+				goto error;
+			}
+			break;
 		      case IPOPT_SEC:
 		      case IPOPT_SID:
 		      default:

--
paul moore
linux security @ hp
