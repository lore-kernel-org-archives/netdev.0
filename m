From: kaber@trash.net
Subject: [PATCH 02/26] netfilter: ipset: IP set core support
Date: Thu,  3 Feb 2011 00:11:40 +0100
Message-ID: <1296688324-7830-3-git-send-email-kaber@trash.net>
References: <1296688324-7830-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1296688324-7830-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The patch adds the IP set core support to the kernel.

The IP set core implements a netlink (nfnetlink) based protocol by which
one can create, destroy, flush, rename, swap, list, save, restore sets,
and add, delete, test elements from userspace. For simplicity (and backward
compatibilty and for not to force ip(6)tables to be linked with a netlink
library) reasons a small getsockopt-based protocol is also kept in order
to communicate with the ip(6)tables match and target.

The netlink protocol passes all u16, etc values in network order with
NLA_F_NET_BYTEORDER flag. The protocol enforces the proper use of the
NLA_F_NESTED and NLA_F_NET_BYTEORDER flags.

For other kernel subsystems (netfilter match and target) the API contains
the functions to add, delete and test elements in sets and the required calls
to get/put refereces to the sets before those operations can be performed.

The set types (which are implemented in independent modules) are stored
in a simple RCU protected list. A set type may have variants: for example
without timeout or with timeout support, for IPv4 or for IPv6. The sets
(i.e. the pointers to the sets) are stored in an array. The sets are
identified by their index in the array, which makes possible easy and
fast swapping of sets. The array is protected indirectly by the nfnl
mutex from nfnetlink. The content of the sets are protected by the rwlock
of the set.

There are functional differences between the add/del/test functions
for the kernel and userspace:

- kernel add/del/test: works on the current packet (i.e. one element)
- kernel test: may trigger an "add" operation  in order to fill
  out unspecified parts of the element from the packet (like MAC address)
- userspace add/del: works on the netlink message and thus possibly
  on multiple elements from the IPSET_ATTR_ADT container attribute.
- userspace add: may trigger resizing of a set

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/ipset/ip_set.h         |  452 +++++++
 include/linux/netfilter/ipset/ip_set_getport.h |   11 +
 include/linux/netfilter/ipset/pfxlen.h         |   35 +
 net/netfilter/Kconfig                          |    2 +
 net/netfilter/Makefile                         |    3 +
 net/netfilter/ipset/Kconfig                    |   26 +
 net/netfilter/ipset/Makefile                   |    8 +
 net/netfilter/ipset/ip_set_core.c              | 1662 ++++++++++++++++++++++++
 net/netfilter/ipset/ip_set_getport.c           |  136 ++
 net/netfilter/ipset/pfxlen.c                   |  291 +++++
 10 files changed, 2626 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/ipset/ip_set.h
 create mode 100644 include/linux/netfilter/ipset/ip_set_getport.h
 create mode 100644 include/linux/netfilter/ipset/pfxlen.h
 create mode 100644 net/netfilter/ipset/Kconfig
 create mode 100644 net/netfilter/ipset/Makefile
 create mode 100644 net/netfilter/ipset/ip_set_core.c
 create mode 100644 net/netfilter/ipset/ip_set_getport.c
 create mode 100644 net/netfilter/ipset/pfxlen.c

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
new file mode 100644
index 0000000..ec333d8
--- /dev/null
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -0,0 +1,452 @@
+#ifndef _IP_SET_H
+#define _IP_SET_H
+
+/* Copyright (C) 2000-2002 Joakim Axelsson <gozem@linux.nu>
+ *                         Patrick Schaaf <bof@bof.de>
+ *                         Martin Josefsson <gandalf@wlug.westbo.se>
+ * Copyright (C) 2003-2011 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+/* The protocol version */
+#define IPSET_PROTOCOL		6
+
+/* The max length of strings including NUL: set and type identifiers */
+#define IPSET_MAXNAMELEN	32
+
+/* Message types and commands */
+enum ipset_cmd {
+	IPSET_CMD_NONE,
+	IPSET_CMD_PROTOCOL,	/* 1: Return protocol version */
+	IPSET_CMD_CREATE,	/* 2: Create a new (empty) set */
+	IPSET_CMD_DESTROY,	/* 3: Destroy a (empty) set */
+	IPSET_CMD_FLUSH,	/* 4: Remove all elements from a set */
+	IPSET_CMD_RENAME,	/* 5: Rename a set */
+	IPSET_CMD_SWAP,		/* 6: Swap two sets */
+	IPSET_CMD_LIST,		/* 7: List sets */
+	IPSET_CMD_SAVE,		/* 8: Save sets */
+	IPSET_CMD_ADD,		/* 9: Add an element to a set */
+	IPSET_CMD_DEL,		/* 10: Delete an element from a set */
+	IPSET_CMD_TEST,		/* 11: Test an element in a set */
+	IPSET_CMD_HEADER,	/* 12: Get set header data only */
+	IPSET_CMD_TYPE,		/* 13: Get set type */
+	IPSET_MSG_MAX,		/* Netlink message commands */
+
+	/* Commands in userspace: */
+	IPSET_CMD_RESTORE = IPSET_MSG_MAX, /* 14: Enter restore mode */
+	IPSET_CMD_HELP,		/* 15: Get help */
+	IPSET_CMD_VERSION,	/* 16: Get program version */
+	IPSET_CMD_QUIT,		/* 17: Quit from interactive mode */
+
+	IPSET_CMD_MAX,
+
+	IPSET_CMD_COMMIT = IPSET_CMD_MAX, /* 18: Commit buffered commands */
+};
+
+/* Attributes at command level */
+enum {
+	IPSET_ATTR_UNSPEC,
+	IPSET_ATTR_PROTOCOL,	/* 1: Protocol version */
+	IPSET_ATTR_SETNAME,	/* 2: Name of the set */
+	IPSET_ATTR_TYPENAME,	/* 3: Typename */
+	IPSET_ATTR_SETNAME2 = IPSET_ATTR_TYPENAME, /* Setname at rename/swap */
+	IPSET_ATTR_REVISION,	/* 4: Settype revision */
+	IPSET_ATTR_FAMILY,	/* 5: Settype family */
+	IPSET_ATTR_FLAGS,	/* 6: Flags at command level */
+	IPSET_ATTR_DATA,	/* 7: Nested attributes */
+	IPSET_ATTR_ADT,		/* 8: Multiple data containers */
+	IPSET_ATTR_LINENO,	/* 9: Restore lineno */
+	IPSET_ATTR_PROTOCOL_MIN, /* 10: Minimal supported version number */
+	IPSET_ATTR_REVISION_MIN	= IPSET_ATTR_PROTOCOL_MIN, /* type rev min */
+	__IPSET_ATTR_CMD_MAX,
+};
+#define IPSET_ATTR_CMD_MAX	(__IPSET_ATTR_CMD_MAX - 1)
+
+/* CADT specific attributes */
+enum {
+	IPSET_ATTR_IP = IPSET_ATTR_UNSPEC + 1,
+	IPSET_ATTR_IP_FROM = IPSET_ATTR_IP,
+	IPSET_ATTR_IP_TO,	/* 2 */
+	IPSET_ATTR_CIDR,	/* 3 */
+	IPSET_ATTR_PORT,	/* 4 */
+	IPSET_ATTR_PORT_FROM = IPSET_ATTR_PORT,
+	IPSET_ATTR_PORT_TO,	/* 5 */
+	IPSET_ATTR_TIMEOUT,	/* 6 */
+	IPSET_ATTR_PROTO,	/* 7 */
+	IPSET_ATTR_CADT_FLAGS,	/* 8 */
+	IPSET_ATTR_CADT_LINENO = IPSET_ATTR_LINENO,	/* 9 */
+	/* Reserve empty slots */
+	IPSET_ATTR_CADT_MAX = 16,
+	/* Create-only specific attributes */
+	IPSET_ATTR_GC,
+	IPSET_ATTR_HASHSIZE,
+	IPSET_ATTR_MAXELEM,
+	IPSET_ATTR_NETMASK,
+	IPSET_ATTR_PROBES,
+	IPSET_ATTR_RESIZE,
+	IPSET_ATTR_SIZE,
+	/* Kernel-only */
+	IPSET_ATTR_ELEMENTS,
+	IPSET_ATTR_REFERENCES,
+	IPSET_ATTR_MEMSIZE,
+
+	__IPSET_ATTR_CREATE_MAX,
+};
+#define IPSET_ATTR_CREATE_MAX	(__IPSET_ATTR_CREATE_MAX - 1)
+
+/* ADT specific attributes */
+enum {
+	IPSET_ATTR_ETHER = IPSET_ATTR_CADT_MAX + 1,
+	IPSET_ATTR_NAME,
+	IPSET_ATTR_NAMEREF,
+	IPSET_ATTR_IP2,
+	IPSET_ATTR_CIDR2,
+	__IPSET_ATTR_ADT_MAX,
+};
+#define IPSET_ATTR_ADT_MAX	(__IPSET_ATTR_ADT_MAX - 1)
+
+/* IP specific attributes */
+enum {
+	IPSET_ATTR_IPADDR_IPV4 = IPSET_ATTR_UNSPEC + 1,
+	IPSET_ATTR_IPADDR_IPV6,
+	__IPSET_ATTR_IPADDR_MAX,
+};
+#define IPSET_ATTR_IPADDR_MAX	(__IPSET_ATTR_IPADDR_MAX - 1)
+
+/* Error codes */
+enum ipset_errno {
+	IPSET_ERR_PRIVATE = 4096,
+	IPSET_ERR_PROTOCOL,
+	IPSET_ERR_FIND_TYPE,
+	IPSET_ERR_MAX_SETS,
+	IPSET_ERR_BUSY,
+	IPSET_ERR_EXIST_SETNAME2,
+	IPSET_ERR_TYPE_MISMATCH,
+	IPSET_ERR_EXIST,
+	IPSET_ERR_INVALID_CIDR,
+	IPSET_ERR_INVALID_NETMASK,
+	IPSET_ERR_INVALID_FAMILY,
+	IPSET_ERR_TIMEOUT,
+	IPSET_ERR_REFERENCED,
+	IPSET_ERR_IPADDR_IPV4,
+	IPSET_ERR_IPADDR_IPV6,
+
+	/* Type specific error codes */
+	IPSET_ERR_TYPE_SPECIFIC = 4352,
+};
+
+/* Flags at command level */
+enum ipset_cmd_flags {
+	IPSET_FLAG_BIT_EXIST	= 0,
+	IPSET_FLAG_EXIST	= (1 << IPSET_FLAG_BIT_EXIST),
+};
+
+/* Flags at CADT attribute level */
+enum ipset_cadt_flags {
+	IPSET_FLAG_BIT_BEFORE	= 0,
+	IPSET_FLAG_BEFORE	= (1 << IPSET_FLAG_BIT_BEFORE),
+};
+
+/* Commands with settype-specific attributes */
+enum ipset_adt {
+	IPSET_ADD,
+	IPSET_DEL,
+	IPSET_TEST,
+	IPSET_ADT_MAX,
+	IPSET_CREATE = IPSET_ADT_MAX,
+	IPSET_CADT_MAX,
+};
+
+#ifdef __KERNEL__
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/netlink.h>
+#include <linux/netfilter.h>
+#include <linux/vmalloc.h>
+#include <net/netlink.h>
+
+/* Sets are identified by an index in kernel space. Tweak with ip_set_id_t
+ * and IPSET_INVALID_ID if you want to increase the max number of sets.
+ */
+typedef u16 ip_set_id_t;
+
+#define IPSET_INVALID_ID		65535
+
+enum ip_set_dim {
+	IPSET_DIM_ZERO = 0,
+	IPSET_DIM_ONE,
+	IPSET_DIM_TWO,
+	IPSET_DIM_THREE,
+	/* Max dimension in elements.
+	 * If changed, new revision of iptables match/target is required.
+	 */
+	IPSET_DIM_MAX = 6,
+};
+
+/* Option flags for kernel operations */
+enum ip_set_kopt {
+	IPSET_INV_MATCH = (1 << IPSET_DIM_ZERO),
+	IPSET_DIM_ONE_SRC = (1 << IPSET_DIM_ONE),
+	IPSET_DIM_TWO_SRC = (1 << IPSET_DIM_TWO),
+	IPSET_DIM_THREE_SRC = (1 << IPSET_DIM_THREE),
+};
+
+/* Set features */
+enum ip_set_feature {
+	IPSET_TYPE_IP_FLAG = 0,
+	IPSET_TYPE_IP = (1 << IPSET_TYPE_IP_FLAG),
+	IPSET_TYPE_PORT_FLAG = 1,
+	IPSET_TYPE_PORT = (1 << IPSET_TYPE_PORT_FLAG),
+	IPSET_TYPE_MAC_FLAG = 2,
+	IPSET_TYPE_MAC = (1 << IPSET_TYPE_MAC_FLAG),
+	IPSET_TYPE_IP2_FLAG = 3,
+	IPSET_TYPE_IP2 = (1 << IPSET_TYPE_IP2_FLAG),
+	IPSET_TYPE_NAME_FLAG = 4,
+	IPSET_TYPE_NAME = (1 << IPSET_TYPE_NAME_FLAG),
+	/* Strictly speaking not a feature, but a flag for dumping:
+	 * this settype must be dumped last */
+	IPSET_DUMP_LAST_FLAG = 7,
+	IPSET_DUMP_LAST = (1 << IPSET_DUMP_LAST_FLAG),
+};
+
+struct ip_set;
+
+typedef int (*ipset_adtfn)(struct ip_set *set, void *value, u32 timeout);
+
+/* Set type, variant-specific part */
+struct ip_set_type_variant {
+	/* Kernelspace: test/add/del entries
+	 *		returns negative error code,
+	 *			zero for no match/success to add/delete
+	 *			positive for matching element */
+	int (*kadt)(struct ip_set *set, const struct sk_buff * skb,
+		    enum ipset_adt adt, u8 pf, u8 dim, u8 flags);
+
+	/* Userspace: test/add/del entries
+	 *		returns negative error code,
+	 *			zero for no match/success to add/delete
+	 *			positive for matching element */
+	int (*uadt)(struct ip_set *set, struct nlattr *tb[],
+		    enum ipset_adt adt, u32 *lineno, u32 flags);
+
+	/* Low level add/del/test functions */
+	ipset_adtfn adt[IPSET_ADT_MAX];
+
+	/* When adding entries and set is full, try to resize the set */
+	int (*resize)(struct ip_set *set, bool retried);
+	/* Destroy the set */
+	void (*destroy)(struct ip_set *set);
+	/* Flush the elements */
+	void (*flush)(struct ip_set *set);
+	/* Expire entries before listing */
+	void (*expire)(struct ip_set *set);
+	/* List set header data */
+	int (*head)(struct ip_set *set, struct sk_buff *skb);
+	/* List elements */
+	int (*list)(const struct ip_set *set, struct sk_buff *skb,
+		    struct netlink_callback *cb);
+
+	/* Return true if "b" set is the same as "a"
+	 * according to the create set parameters */
+	bool (*same_set)(const struct ip_set *a, const struct ip_set *b);
+};
+
+/* The core set type structure */
+struct ip_set_type {
+	struct list_head list;
+
+	/* Typename */
+	char name[IPSET_MAXNAMELEN];
+	/* Protocol version */
+	u8 protocol;
+	/* Set features to control swapping */
+	u8 features;
+	/* Set type dimension */
+	u8 dimension;
+	/* Supported family: may be AF_UNSPEC for both AF_INET/AF_INET6 */
+	u8 family;
+	/* Type revision */
+	u8 revision;
+
+	/* Create set */
+	int (*create)(struct ip_set *set, struct nlattr *tb[], u32 flags);
+
+	/* Attribute policies */
+	const struct nla_policy create_policy[IPSET_ATTR_CREATE_MAX + 1];
+	const struct nla_policy adt_policy[IPSET_ATTR_ADT_MAX + 1];
+
+	/* Set this to THIS_MODULE if you are a module, otherwise NULL */
+	struct module *me;
+};
+
+/* register and unregister set type */
+extern int ip_set_type_register(struct ip_set_type *set_type);
+extern void ip_set_type_unregister(struct ip_set_type *set_type);
+
+/* A generic IP set */
+struct ip_set {
+	/* The name of the set */
+	char name[IPSET_MAXNAMELEN];
+	/* Lock protecting the set data */
+	rwlock_t lock;
+	/* References to the set */
+	atomic_t ref;
+	/* The core set type */
+	struct ip_set_type *type;
+	/* The type variant doing the real job */
+	const struct ip_set_type_variant *variant;
+	/* The actual INET family of the set */
+	u8 family;
+	/* The type specific data */
+	void *data;
+};
+
+/* register and unregister set references */
+extern ip_set_id_t ip_set_get_byname(const char *name, struct ip_set **set);
+extern void ip_set_put_byindex(ip_set_id_t index);
+extern const char * ip_set_name_byindex(ip_set_id_t index);
+extern ip_set_id_t ip_set_nfnl_get(const char *name);
+extern ip_set_id_t ip_set_nfnl_get_byindex(ip_set_id_t index);
+extern void ip_set_nfnl_put(ip_set_id_t index);
+
+/* API for iptables set match, and SET target */
+extern int ip_set_add(ip_set_id_t id, const struct sk_buff *skb,
+		      u8 family, u8 dim, u8 flags);
+extern int ip_set_del(ip_set_id_t id, const struct sk_buff *skb,
+		      u8 family, u8 dim, u8 flags);
+extern int ip_set_test(ip_set_id_t id, const struct sk_buff *skb,
+		       u8 family, u8 dim, u8 flags);
+
+/* Utility functions */
+extern void * ip_set_alloc(size_t size);
+extern void ip_set_free(void *members);
+extern int ip_set_get_ipaddr4(struct nlattr *nla,  __be32 *ipaddr);
+extern int ip_set_get_ipaddr6(struct nlattr *nla, union nf_inet_addr *ipaddr);
+
+static inline int
+ip_set_get_hostipaddr4(struct nlattr *nla, u32 *ipaddr)
+{
+	__be32 ip;
+	int ret = ip_set_get_ipaddr4(nla, &ip);
+	
+	if (ret)
+		return ret;
+	*ipaddr = ntohl(ip);
+	return 0;
+}
+
+/* Ignore IPSET_ERR_EXIST errors if asked to do so? */
+static inline bool
+ip_set_eexist(int ret, u32 flags)
+{
+	return ret == -IPSET_ERR_EXIST && (flags & IPSET_FLAG_EXIST);
+}
+
+/* Check the NLA_F_NET_BYTEORDER flag */
+static inline bool
+ip_set_attr_netorder(struct nlattr *tb[], int type)
+{
+	return tb[type] && (tb[type]->nla_type & NLA_F_NET_BYTEORDER);
+}
+
+static inline bool
+ip_set_optattr_netorder(struct nlattr *tb[], int type)
+{
+	return !tb[type] || (tb[type]->nla_type & NLA_F_NET_BYTEORDER);
+}
+
+/* Useful converters */
+static inline u32
+ip_set_get_h32(const struct nlattr *attr)
+{
+	return ntohl(nla_get_be32(attr));
+}
+
+static inline u16
+ip_set_get_h16(const struct nlattr *attr)
+{
+	return ntohs(nla_get_be16(attr));
+}
+
+#define ipset_nest_start(skb, attr) nla_nest_start(skb, attr | NLA_F_NESTED)
+#define ipset_nest_end(skb, start)  nla_nest_end(skb, start)
+
+#define NLA_PUT_IPADDR4(skb, type, ipaddr)			\
+do {								\
+	struct nlattr *__nested = ipset_nest_start(skb, type);	\
+								\
+	if (!__nested)						\
+		goto nla_put_failure;				\
+	NLA_PUT_NET32(skb, IPSET_ATTR_IPADDR_IPV4, ipaddr);	\
+	ipset_nest_end(skb, __nested);				\
+} while (0)
+
+#define NLA_PUT_IPADDR6(skb, type, ipaddrptr)			\
+do {								\
+	struct nlattr *__nested = ipset_nest_start(skb, type);	\
+								\
+	if (!__nested)						\
+		goto nla_put_failure;				\
+	NLA_PUT(skb, IPSET_ATTR_IPADDR_IPV6,			\
+		sizeof(struct in6_addr), ipaddrptr);		\
+	ipset_nest_end(skb, __nested);				\
+} while (0)
+
+/* Get address from skbuff */
+static inline __be32
+ip4addr(const struct sk_buff *skb, bool src)
+{
+	return src ? ip_hdr(skb)->saddr : ip_hdr(skb)->daddr;
+}
+
+static inline void
+ip4addrptr(const struct sk_buff *skb, bool src, __be32 *addr)
+{
+	*addr = src ? ip_hdr(skb)->saddr : ip_hdr(skb)->daddr;
+}
+
+static inline void
+ip6addrptr(const struct sk_buff *skb, bool src, struct in6_addr *addr)
+{
+	memcpy(addr, src ? &ipv6_hdr(skb)->saddr : &ipv6_hdr(skb)->daddr,
+	       sizeof(*addr));
+}
+
+/* Calculate the bytes required to store the inclusive range of a-b */
+static inline int
+bitmap_bytes(u32 a, u32 b)
+{
+	return 4 * ((((b - a + 8) / 8) + 3) / 4);
+}
+
+/* Interface to iptables/ip6tables */
+
+#define SO_IP_SET		83
+
+union ip_set_name_index {
+	char name[IPSET_MAXNAMELEN];
+	ip_set_id_t index;
+};
+
+#define IP_SET_OP_GET_BYNAME	0x00000006	/* Get set index by name */
+struct ip_set_req_get_set {
+	unsigned op;
+	unsigned version;
+	union ip_set_name_index set;
+};
+
+#define IP_SET_OP_GET_BYINDEX	0x00000007	/* Get set name by index */
+/* Uses ip_set_req_get_set */
+
+#define IP_SET_OP_VERSION	0x00000100	/* Ask kernel version */
+struct ip_set_req_version {
+	unsigned op;
+	unsigned version;
+};
+
+#endif	/* __KERNEL__ */
+
+#endif /*_IP_SET_H */
diff --git a/include/linux/netfilter/ipset/ip_set_getport.h b/include/linux/netfilter/ipset/ip_set_getport.h
new file mode 100644
index 0000000..694c433
--- /dev/null
+++ b/include/linux/netfilter/ipset/ip_set_getport.h
@@ -0,0 +1,11 @@
+#ifndef _IP_SET_GETPORT_H
+#define _IP_SET_GETPORT_H
+
+extern bool ip_set_get_ip4_port(const struct sk_buff *skb, bool src,
+				__be16 *port, u8 *proto);
+extern bool ip_set_get_ip6_port(const struct sk_buff *skb, bool src,
+				__be16 *port, u8 *proto);
+extern bool ip_set_get_ip_port(const struct sk_buff *skb, u8 pf, bool src,
+				__be16 *port);
+
+#endif /*_IP_SET_GETPORT_H*/
diff --git a/include/linux/netfilter/ipset/pfxlen.h b/include/linux/netfilter/ipset/pfxlen.h
new file mode 100644
index 0000000..0e1fb50
--- /dev/null
+++ b/include/linux/netfilter/ipset/pfxlen.h
@@ -0,0 +1,35 @@
+#ifndef _PFXLEN_H
+#define _PFXLEN_H
+
+#include <asm/byteorder.h>
+#include <linux/netfilter.h> 
+
+/* Prefixlen maps, by Jan Engelhardt  */
+extern const union nf_inet_addr ip_set_netmask_map[];
+extern const union nf_inet_addr ip_set_hostmask_map[];
+
+static inline __be32
+ip_set_netmask(u8 pfxlen)
+{
+	return ip_set_netmask_map[pfxlen].ip;
+}
+
+static inline const __be32 *
+ip_set_netmask6(u8 pfxlen)
+{
+	return &ip_set_netmask_map[pfxlen].ip6[0];
+}
+
+static inline u32
+ip_set_hostmask(u8 pfxlen)
+{
+	return (__force u32) ip_set_hostmask_map[pfxlen].ip;
+}
+
+static inline const __be32 *
+ip_set_hostmask6(u8 pfxlen)
+{
+	return &ip_set_hostmask_map[pfxlen].ip6[0];
+}
+
+#endif /*_PFXLEN_H */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index faf7412..351abf8 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -1052,4 +1052,6 @@ endif # NETFILTER_XTABLES
 
 endmenu
 
+source "net/netfilter/ipset/Kconfig"
+
 source "net/netfilter/ipvs/Kconfig"
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 9ae6878..510b586 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -105,5 +105,8 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_TCPMSS) += xt_tcpmss.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_TIME) += xt_time.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_U32) += xt_u32.o
 
+# ipset
+obj-$(CONFIG_IP_SET) += ipset/
+
 # IPVS
 obj-$(CONFIG_IP_VS) += ipvs/
diff --git a/net/netfilter/ipset/Kconfig b/net/netfilter/ipset/Kconfig
new file mode 100644
index 0000000..5ade156
--- /dev/null
+++ b/net/netfilter/ipset/Kconfig
@@ -0,0 +1,26 @@
+menuconfig IP_SET
+	tristate "IP set support"
+	depends on INET && NETFILTER
+	help
+	  This option adds IP set support to the kernel.
+	  In order to define and use the sets, you need the userspace utility
+	  ipset(8). You can use the sets in netfilter via the "set" match
+	  and "SET" target.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
+if IP_SET
+
+config IP_SET_MAX
+	int "Maximum number of IP sets"
+	default 256
+	range 2 65534
+	depends on IP_SET
+	help
+	  You can define here default value of the maximum number 
+	  of IP sets for the kernel.
+
+	  The value can be overriden by the 'max_sets' module
+	  parameter of the 'ip_set' module.
+
+endif # IP_SET
diff --git a/net/netfilter/ipset/Makefile b/net/netfilter/ipset/Makefile
new file mode 100644
index 0000000..910cd42
--- /dev/null
+++ b/net/netfilter/ipset/Makefile
@@ -0,0 +1,8 @@
+#
+# Makefile for the ipset modules
+#
+
+ip_set-y := ip_set_core.o ip_set_getport.o pfxlen.o
+
+# ipset core
+obj-$(CONFIG_IP_SET) += ip_set.o
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
new file mode 100644
index 0000000..8a73624
--- /dev/null
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -0,0 +1,1662 @@
+/* Copyright (C) 2000-2002 Joakim Axelsson <gozem@linux.nu>
+ *                         Patrick Schaaf <bof@bof.de>
+ * Copyright (C) 2003-2011 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+/* Kernel module for IP set management */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/ip.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/netlink.h>
+#include <linux/rculist.h>
+#include <linux/version.h>
+#include <net/netlink.h>
+
+#include <linux/netfilter.h>
+#include <linux/netfilter/nfnetlink.h>
+#include <linux/netfilter/ipset/ip_set.h>
+
+static LIST_HEAD(ip_set_type_list);		/* all registered set types */
+static DEFINE_MUTEX(ip_set_type_mutex);		/* protects ip_set_type_list */
+
+static struct ip_set **ip_set_list;		/* all individual sets */
+static ip_set_id_t ip_set_max = CONFIG_IP_SET_MAX; /* max number of sets */
+
+#define STREQ(a, b)	(strncmp(a, b, IPSET_MAXNAMELEN) == 0)
+
+static unsigned int max_sets;
+
+module_param(max_sets, int, 0600);
+MODULE_PARM_DESC(max_sets, "maximal number of sets");
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
+MODULE_DESCRIPTION("core IP set support");
+MODULE_ALIAS_NFNL_SUBSYS(NFNL_SUBSYS_IPSET);
+
+/*
+ * The set types are implemented in modules and registered set types
+ * can be found in ip_set_type_list. Adding/deleting types is
+ * serialized by ip_set_type_mutex.
+ */
+
+static inline void
+ip_set_type_lock(void)
+{
+	mutex_lock(&ip_set_type_mutex);
+}
+
+static inline void
+ip_set_type_unlock(void)
+{
+	mutex_unlock(&ip_set_type_mutex);
+}
+
+/* Register and deregister settype */
+
+static struct ip_set_type *
+find_set_type(const char *name, u8 family, u8 revision)
+{
+	struct ip_set_type *type;
+
+	list_for_each_entry_rcu(type, &ip_set_type_list, list)
+		if (STREQ(type->name, name) &&
+		    (type->family == family || type->family == AF_UNSPEC) &&
+		    type->revision == revision)
+			return type;
+	return NULL;
+}
+
+/* Unlock, try to load a set type module and lock again */
+static int
+try_to_load_type(const char *name)
+{
+	nfnl_unlock();
+	pr_debug("try to load ip_set_%s\n", name);
+	if (request_module("ip_set_%s", name) < 0) {
+		pr_warning("Can't find ip_set type %s\n", name);
+		nfnl_lock();
+		return -IPSET_ERR_FIND_TYPE;
+	}
+	nfnl_lock();
+	return -EAGAIN;
+}
+
+/* Find a set type and reference it */
+static int
+find_set_type_get(const char *name, u8 family, u8 revision,
+		  struct ip_set_type **found)
+{
+	rcu_read_lock();
+	*found = find_set_type(name, family, revision);
+	if (*found) {
+		int err = !try_module_get((*found)->me);
+		rcu_read_unlock();
+		return err ? -EFAULT : 0;
+	}
+	rcu_read_unlock();
+
+	return try_to_load_type(name);
+}
+
+/* Find a given set type by name and family.
+ * If we succeeded, the supported minimal and maximum revisions are
+ * filled out.
+ */
+static int
+find_set_type_minmax(const char *name, u8 family, u8 *min, u8 *max)
+{
+	struct ip_set_type *type;
+	bool found = false;
+
+	*min = *max = 0;
+	rcu_read_lock();
+	list_for_each_entry_rcu(type, &ip_set_type_list, list)
+		if (STREQ(type->name, name) &&
+		    (type->family == family || type->family == AF_UNSPEC)) {
+			found = true;
+			if (type->revision < *min)
+				*min = type->revision;
+			else if (type->revision > *max)
+				*max = type->revision;
+		}
+	rcu_read_unlock();
+	if (found)
+		return 0;
+
+	return try_to_load_type(name);
+}
+
+#define family_name(f)	((f) == AF_INET ? "inet" : \
+			 (f) == AF_INET6 ? "inet6" : "any")
+
+/* Register a set type structure. The type is identified by
+ * the unique triple of name, family and revision.
+ */
+int
+ip_set_type_register(struct ip_set_type *type)
+{
+	int ret = 0;
+
+	if (type->protocol != IPSET_PROTOCOL) {
+		pr_warning("ip_set type %s, family %s, revision %u uses "
+			   "wrong protocol version %u (want %u)\n",
+			   type->name, family_name(type->family),
+			   type->revision, type->protocol, IPSET_PROTOCOL);
+		return -EINVAL;
+	}
+
+	ip_set_type_lock();
+	if (find_set_type(type->name, type->family, type->revision)) {
+		/* Duplicate! */
+		pr_warning("ip_set type %s, family %s, revision %u "
+			   "already registered!\n", type->name,
+			   family_name(type->family), type->revision);
+		ret = -EINVAL;
+		goto unlock;
+	}
+	list_add_rcu(&type->list, &ip_set_type_list);
+	pr_debug("type %s, family %s, revision %u registered.\n",
+		 type->name, family_name(type->family), type->revision);
+unlock:
+	ip_set_type_unlock();
+	return ret;
+}
+EXPORT_SYMBOL_GPL(ip_set_type_register);
+
+/* Unregister a set type. There's a small race with ip_set_create */
+void
+ip_set_type_unregister(struct ip_set_type *type)
+{
+	ip_set_type_lock();
+	if (!find_set_type(type->name, type->family, type->revision)) {
+		pr_warning("ip_set type %s, family %s, revision %u "
+			   "not registered\n", type->name,
+			   family_name(type->family), type->revision);
+		goto unlock;
+	}
+	list_del_rcu(&type->list);
+	pr_debug("type %s, family %s, revision %u unregistered.\n",
+		 type->name, family_name(type->family), type->revision);
+unlock:
+	ip_set_type_unlock();
+
+	synchronize_rcu();
+}
+EXPORT_SYMBOL_GPL(ip_set_type_unregister);
+
+/* Utility functions */
+void *
+ip_set_alloc(size_t size)
+{
+	void *members = NULL;
+
+	if (size < KMALLOC_MAX_SIZE)
+		members = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
+
+	if (members) {
+		pr_debug("%p: allocated with kmalloc\n", members);
+		return members;
+	}
+
+	members = vzalloc(size);
+	if (!members)
+		return NULL;
+	pr_debug("%p: allocated with vmalloc\n", members);
+
+	return members;
+}
+EXPORT_SYMBOL_GPL(ip_set_alloc);
+
+void
+ip_set_free(void *members)
+{
+	pr_debug("%p: free with %s\n", members,
+		 is_vmalloc_addr(members) ? "vfree" : "kfree");
+	if (is_vmalloc_addr(members))
+		vfree(members);
+	else
+		kfree(members);
+}
+EXPORT_SYMBOL_GPL(ip_set_free);
+
+static inline bool
+flag_nested(const struct nlattr *nla)
+{
+	return nla->nla_type & NLA_F_NESTED;
+}
+
+static const struct nla_policy ipaddr_policy[IPSET_ATTR_IPADDR_MAX + 1] = {
+	[IPSET_ATTR_IPADDR_IPV4]	= { .type = NLA_U32 },
+	[IPSET_ATTR_IPADDR_IPV6]	= { .type = NLA_BINARY,
+					    .len = sizeof(struct in6_addr) },
+};
+
+int
+ip_set_get_ipaddr4(struct nlattr *nla,  __be32 *ipaddr)
+{
+	struct nlattr *tb[IPSET_ATTR_IPADDR_MAX+1];
+
+	if (unlikely(!flag_nested(nla)))
+		return -IPSET_ERR_PROTOCOL;
+	if (nla_parse(tb, IPSET_ATTR_IPADDR_MAX, nla_data(nla), nla_len(nla),
+		      ipaddr_policy))
+		return -IPSET_ERR_PROTOCOL;
+	if (unlikely(!ip_set_attr_netorder(tb, IPSET_ATTR_IPADDR_IPV4)))
+		return -IPSET_ERR_PROTOCOL;
+
+	*ipaddr = nla_get_be32(tb[IPSET_ATTR_IPADDR_IPV4]);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ip_set_get_ipaddr4);
+
+int
+ip_set_get_ipaddr6(struct nlattr *nla, union nf_inet_addr *ipaddr)
+{
+	struct nlattr *tb[IPSET_ATTR_IPADDR_MAX+1];
+
+	if (unlikely(!flag_nested(nla)))
+		return -IPSET_ERR_PROTOCOL;
+
+	if (nla_parse(tb, IPSET_ATTR_IPADDR_MAX, nla_data(nla), nla_len(nla),
+		      ipaddr_policy))
+		return -IPSET_ERR_PROTOCOL;
+	if (unlikely(!ip_set_attr_netorder(tb, IPSET_ATTR_IPADDR_IPV6)))
+		return -IPSET_ERR_PROTOCOL;
+
+	memcpy(ipaddr, nla_data(tb[IPSET_ATTR_IPADDR_IPV6]),
+		sizeof(struct in6_addr));
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ip_set_get_ipaddr6);
+
+/*
+ * Creating/destroying/renaming/swapping affect the existence and
+ * the properties of a set. All of these can be executed from userspace
+ * only and serialized by the nfnl mutex indirectly from nfnetlink.
+ *
+ * Sets are identified by their index in ip_set_list and the index
+ * is used by the external references (set/SET netfilter modules).
+ *
+ * The set behind an index may change by swapping only, from userspace.
+ */
+
+static inline void
+__ip_set_get(ip_set_id_t index)
+{
+	atomic_inc(&ip_set_list[index]->ref);
+}
+
+static inline void
+__ip_set_put(ip_set_id_t index)
+{
+	atomic_dec(&ip_set_list[index]->ref);
+}
+
+/*
+ * Add, del and test set entries from kernel.
+ *
+ * The set behind the index must exist and must be referenced
+ * so it can't be destroyed (or changed) under our foot.
+ */
+
+int
+ip_set_test(ip_set_id_t index, const struct sk_buff *skb,
+	    u8 family, u8 dim, u8 flags)
+{
+	struct ip_set *set = ip_set_list[index];
+	int ret = 0;
+
+	BUG_ON(set == NULL || atomic_read(&set->ref) == 0);
+	pr_debug("set %s, index %u\n", set->name, index);
+
+	if (dim < set->type->dimension ||
+	    !(family == set->family || set->family == AF_UNSPEC))
+		return 0;
+
+	read_lock_bh(&set->lock);
+	ret = set->variant->kadt(set, skb, IPSET_TEST, family, dim, flags);
+	read_unlock_bh(&set->lock);
+
+	if (ret == -EAGAIN) {
+		/* Type requests element to be completed */
+		pr_debug("element must be competed, ADD is triggered\n");
+		write_lock_bh(&set->lock);
+		set->variant->kadt(set, skb, IPSET_ADD, family, dim, flags);
+		write_unlock_bh(&set->lock);
+		ret = 1;
+	}
+
+	/* Convert error codes to nomatch */
+	return (ret < 0 ? 0 : ret);
+}
+EXPORT_SYMBOL_GPL(ip_set_test);
+
+int
+ip_set_add(ip_set_id_t index, const struct sk_buff *skb,
+	   u8 family, u8 dim, u8 flags)
+{
+	struct ip_set *set = ip_set_list[index];
+	int ret;
+
+	BUG_ON(set == NULL || atomic_read(&set->ref) == 0);
+	pr_debug("set %s, index %u\n", set->name, index);
+
+	if (dim < set->type->dimension ||
+	    !(family == set->family || set->family == AF_UNSPEC))
+		return 0;
+
+	write_lock_bh(&set->lock);
+	ret = set->variant->kadt(set, skb, IPSET_ADD, family, dim, flags);
+	write_unlock_bh(&set->lock);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(ip_set_add);
+
+int
+ip_set_del(ip_set_id_t index, const struct sk_buff *skb,
+	   u8 family, u8 dim, u8 flags)
+{
+	struct ip_set *set = ip_set_list[index];
+	int ret = 0;
+
+	BUG_ON(set == NULL || atomic_read(&set->ref) == 0);
+	pr_debug("set %s, index %u\n", set->name, index);
+
+	if (dim < set->type->dimension ||
+	    !(family == set->family || set->family == AF_UNSPEC))
+		return 0;
+
+	write_lock_bh(&set->lock);
+	ret = set->variant->kadt(set, skb, IPSET_DEL, family, dim, flags);
+	write_unlock_bh(&set->lock);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(ip_set_del);
+
+/*
+ * Find set by name, reference it once. The reference makes sure the
+ * thing pointed to, does not go away under our feet.
+ *
+ * The nfnl mutex must already be activated.
+ */
+ip_set_id_t
+ip_set_get_byname(const char *name, struct ip_set **set)
+{
+	ip_set_id_t i, index = IPSET_INVALID_ID;
+	struct ip_set *s;
+
+	for (i = 0; i < ip_set_max; i++) {
+		s = ip_set_list[i];
+		if (s != NULL && STREQ(s->name, name)) {
+			__ip_set_get(i);
+			index = i;
+			*set = s;
+		}
+	}
+
+	return index;
+}
+EXPORT_SYMBOL_GPL(ip_set_get_byname);
+
+/*
+ * If the given set pointer points to a valid set, decrement
+ * reference count by 1. The caller shall not assume the index
+ * to be valid, after calling this function.
+ *
+ * The nfnl mutex must already be activated.
+ */
+void
+ip_set_put_byindex(ip_set_id_t index)
+{
+	if (ip_set_list[index] != NULL) {
+		BUG_ON(atomic_read(&ip_set_list[index]->ref) == 0);
+		__ip_set_put(index);
+	}
+}
+EXPORT_SYMBOL_GPL(ip_set_put_byindex);
+
+/*
+ * Get the name of a set behind a set index.
+ * We assume the set is referenced, so it does exist and
+ * can't be destroyed. The set cannot be renamed due to
+ * the referencing either.
+ *
+ * The nfnl mutex must already be activated.
+ */
+const char *
+ip_set_name_byindex(ip_set_id_t index)
+{
+	const struct ip_set *set = ip_set_list[index];
+
+	BUG_ON(set == NULL);
+	BUG_ON(atomic_read(&set->ref) == 0);
+
+	/* Referenced, so it's safe */
+	return set->name;
+}
+EXPORT_SYMBOL_GPL(ip_set_name_byindex);
+
+/*
+ * Routines to call by external subsystems, which do not
+ * call nfnl_lock for us.
+ */
+
+/*
+ * Find set by name, reference it once. The reference makes sure the
+ * thing pointed to, does not go away under our feet.
+ *
+ * The nfnl mutex is used in the function.
+ */
+ip_set_id_t
+ip_set_nfnl_get(const char *name)
+{
+	struct ip_set *s;
+	ip_set_id_t index;
+
+	nfnl_lock();
+	index = ip_set_get_byname(name, &s);
+	nfnl_unlock();
+
+	return index;
+}
+EXPORT_SYMBOL_GPL(ip_set_nfnl_get);
+
+/*
+ * Find set by index, reference it once. The reference makes sure the
+ * thing pointed to, does not go away under our feet.
+ *
+ * The nfnl mutex is used in the function.
+ */
+ip_set_id_t
+ip_set_nfnl_get_byindex(ip_set_id_t index)
+{
+	if (index > ip_set_max)
+		return IPSET_INVALID_ID;
+
+	nfnl_lock();
+	if (ip_set_list[index])
+		__ip_set_get(index);
+	else
+		index = IPSET_INVALID_ID;
+	nfnl_unlock();
+
+	return index;
+}
+EXPORT_SYMBOL_GPL(ip_set_nfnl_get_byindex);
+
+/*
+ * If the given set pointer points to a valid set, decrement
+ * reference count by 1. The caller shall not assume the index
+ * to be valid, after calling this function.
+ *
+ * The nfnl mutex is used in the function.
+ */
+void
+ip_set_nfnl_put(ip_set_id_t index)
+{
+	nfnl_lock();
+	if (ip_set_list[index] != NULL) {
+		BUG_ON(atomic_read(&ip_set_list[index]->ref) == 0);
+		__ip_set_put(index);
+	}
+	nfnl_unlock();
+}
+EXPORT_SYMBOL_GPL(ip_set_nfnl_put);
+
+/*
+ * Communication protocol with userspace over netlink.
+ *
+ * We already locked by nfnl_lock.
+ */
+
+static inline bool
+protocol_failed(const struct nlattr * const tb[])
+{
+	return !tb[IPSET_ATTR_PROTOCOL] ||
+	       nla_get_u8(tb[IPSET_ATTR_PROTOCOL]) != IPSET_PROTOCOL;
+}
+
+static inline u32
+flag_exist(const struct nlmsghdr *nlh)
+{
+	return nlh->nlmsg_flags & NLM_F_EXCL ? 0 : IPSET_FLAG_EXIST;
+}
+
+static struct nlmsghdr *
+start_msg(struct sk_buff *skb, u32 pid, u32 seq, unsigned int flags,
+	  enum ipset_cmd cmd)
+{
+	struct nlmsghdr *nlh;
+	struct nfgenmsg *nfmsg;
+
+	nlh = nlmsg_put(skb, pid, seq, cmd | (NFNL_SUBSYS_IPSET << 8),
+			sizeof(*nfmsg), flags);
+	if (nlh == NULL)
+		return NULL;
+
+	nfmsg = nlmsg_data(nlh);
+	nfmsg->nfgen_family = AF_INET;
+	nfmsg->version = NFNETLINK_V0;
+	nfmsg->res_id = 0;
+
+	return nlh;
+}
+
+/* Create a set */
+
+static const struct nla_policy ip_set_create_policy[IPSET_ATTR_CMD_MAX + 1] = {
+	[IPSET_ATTR_PROTOCOL]	= { .type = NLA_U8 },
+	[IPSET_ATTR_SETNAME]	= { .type = NLA_NUL_STRING,
+				    .len = IPSET_MAXNAMELEN - 1 },
+	[IPSET_ATTR_TYPENAME]	= { .type = NLA_NUL_STRING,
+				    .len = IPSET_MAXNAMELEN - 1},
+	[IPSET_ATTR_REVISION]	= { .type = NLA_U8 },
+	[IPSET_ATTR_FAMILY]	= { .type = NLA_U8 },
+	[IPSET_ATTR_DATA]	= { .type = NLA_NESTED },
+};
+
+static ip_set_id_t
+find_set_id(const char *name)
+{
+	ip_set_id_t i, index = IPSET_INVALID_ID;
+	const struct ip_set *set;
+
+	for (i = 0; index == IPSET_INVALID_ID && i < ip_set_max; i++) {
+		set = ip_set_list[i];
+		if (set != NULL && STREQ(set->name, name))
+			index = i;
+	}
+	return index;
+}
+
+static inline struct ip_set *
+find_set(const char *name)
+{
+	ip_set_id_t index = find_set_id(name);
+
+	return index == IPSET_INVALID_ID ? NULL : ip_set_list[index];
+}
+
+static int
+find_free_id(const char *name, ip_set_id_t *index, struct ip_set **set)
+{
+	ip_set_id_t i;
+
+	*index = IPSET_INVALID_ID;
+	for (i = 0;  i < ip_set_max; i++) {
+		if (ip_set_list[i] == NULL) {
+			if (*index == IPSET_INVALID_ID)
+				*index = i;
+		} else if (STREQ(name, ip_set_list[i]->name)) {
+			/* Name clash */
+			*set = ip_set_list[i];
+			return -EEXIST;
+		}
+	}
+	if (*index == IPSET_INVALID_ID)
+		/* No free slot remained */
+		return -IPSET_ERR_MAX_SETS;
+	return 0;
+}
+
+static int
+ip_set_create(struct sock *ctnl, struct sk_buff *skb,
+	      const struct nlmsghdr *nlh,
+	      const struct nlattr * const attr[])
+{
+	struct ip_set *set, *clash;
+	ip_set_id_t index = IPSET_INVALID_ID;
+	struct nlattr *tb[IPSET_ATTR_CREATE_MAX+1] = {};
+	const char *name, *typename;
+	u8 family, revision;
+	u32 flags = flag_exist(nlh);
+	int ret = 0;
+
+	if (unlikely(protocol_failed(attr) ||
+		     attr[IPSET_ATTR_SETNAME] == NULL ||
+		     attr[IPSET_ATTR_TYPENAME] == NULL ||
+		     attr[IPSET_ATTR_REVISION] == NULL ||
+		     attr[IPSET_ATTR_FAMILY] == NULL ||
+		     (attr[IPSET_ATTR_DATA] != NULL &&
+		      !flag_nested(attr[IPSET_ATTR_DATA]))))
+		return -IPSET_ERR_PROTOCOL;
+
+	name = nla_data(attr[IPSET_ATTR_SETNAME]);
+	typename = nla_data(attr[IPSET_ATTR_TYPENAME]);
+	family = nla_get_u8(attr[IPSET_ATTR_FAMILY]);
+	revision = nla_get_u8(attr[IPSET_ATTR_REVISION]);
+	pr_debug("setname: %s, typename: %s, family: %s, revision: %u\n",
+		 name, typename, family_name(family), revision);
+
+	/*
+	 * First, and without any locks, allocate and initialize
+	 * a normal base set structure.
+	 */
+	set = kzalloc(sizeof(struct ip_set), GFP_KERNEL);
+	if (!set)
+		return -ENOMEM;
+	rwlock_init(&set->lock);
+	strlcpy(set->name, name, IPSET_MAXNAMELEN);
+	atomic_set(&set->ref, 0);
+	set->family = family;
+
+	/*
+	 * Next, check that we know the type, and take
+	 * a reference on the type, to make sure it stays available
+	 * while constructing our new set.
+	 *
+	 * After referencing the type, we try to create the type
+	 * specific part of the set without holding any locks.
+	 */
+	ret = find_set_type_get(typename, family, revision, &(set->type));
+	if (ret)
+		goto out;
+
+	/*
+	 * Without holding any locks, create private part.
+	 */
+	if (attr[IPSET_ATTR_DATA] &&
+	    nla_parse(tb, IPSET_ATTR_CREATE_MAX,
+	    	      nla_data(attr[IPSET_ATTR_DATA]),
+	    	      nla_len(attr[IPSET_ATTR_DATA]),
+	    	      set->type->create_policy)) {
+	    	ret = -IPSET_ERR_PROTOCOL;
+	    	goto put_out;
+	}
+
+	ret = set->type->create(set, tb, flags);
+	if (ret != 0)
+		goto put_out;
+
+	/* BTW, ret==0 here. */
+
+	/*
+	 * Here, we have a valid, constructed set and we are protected
+	 * by nfnl_lock. Find the first free index in ip_set_list and
+	 * check clashing.
+	 */
+	if ((ret = find_free_id(set->name, &index, &clash)) != 0) {
+		/* If this is the same set and requested, ignore error */
+		if (ret == -EEXIST &&
+		    (flags & IPSET_FLAG_EXIST) &&
+		    STREQ(set->type->name, clash->type->name) &&
+		    set->type->family == clash->type->family &&
+		    set->type->revision == clash->type->revision &&
+		    set->variant->same_set(set, clash))
+			ret = 0;
+		goto cleanup;
+	}
+
+	/*
+	 * Finally! Add our shiny new set to the list, and be done.
+	 */
+	pr_debug("create: '%s' created with index %u!\n", set->name, index);
+	ip_set_list[index] = set;
+
+	return ret;
+
+cleanup:
+	set->variant->destroy(set);
+put_out:
+	module_put(set->type->me);
+out:
+	kfree(set);
+	return ret;
+}
+
+/* Destroy sets */
+
+static const struct nla_policy
+ip_set_setname_policy[IPSET_ATTR_CMD_MAX + 1] = {
+	[IPSET_ATTR_PROTOCOL]	= { .type = NLA_U8 },
+	[IPSET_ATTR_SETNAME]	= { .type = NLA_NUL_STRING,
+				    .len = IPSET_MAXNAMELEN - 1 },
+};
+
+static void
+ip_set_destroy_set(ip_set_id_t index)
+{
+	struct ip_set *set = ip_set_list[index];
+
+	pr_debug("set: %s\n",  set->name);
+	ip_set_list[index] = NULL;
+
+	/* Must call it without holding any lock */
+	set->variant->destroy(set);
+	module_put(set->type->me);
+	kfree(set);
+}
+
+static int
+ip_set_destroy(struct sock *ctnl, struct sk_buff *skb,
+	       const struct nlmsghdr *nlh,
+	       const struct nlattr * const attr[])
+{
+	ip_set_id_t i;
+
+	if (unlikely(protocol_failed(attr)))
+		return -IPSET_ERR_PROTOCOL;
+
+	/* References are protected by the nfnl mutex */
+	if (!attr[IPSET_ATTR_SETNAME]) {
+		for (i = 0; i < ip_set_max; i++) {
+			if (ip_set_list[i] != NULL &&
+			    (atomic_read(&ip_set_list[i]->ref)))
+				return -IPSET_ERR_BUSY;
+		}
+		for (i = 0; i < ip_set_max; i++) {
+			if (ip_set_list[i] != NULL)
+				ip_set_destroy_set(i);
+		}
+	} else {
+		i = find_set_id(nla_data(attr[IPSET_ATTR_SETNAME]));
+		if (i == IPSET_INVALID_ID)
+			return -ENOENT;
+		else if (atomic_read(&ip_set_list[i]->ref))
+			return -IPSET_ERR_BUSY;
+
+		ip_set_destroy_set(i);
+	}
+	return 0;
+}
+
+/* Flush sets */
+
+static void
+ip_set_flush_set(struct ip_set *set)
+{
+	pr_debug("set: %s\n",  set->name);
+
+	write_lock_bh(&set->lock);
+	set->variant->flush(set);
+	write_unlock_bh(&set->lock);
+}
+
+static int
+ip_set_flush(struct sock *ctnl, struct sk_buff *skb,
+	     const struct nlmsghdr *nlh,
+	     const struct nlattr * const attr[])
+{
+	ip_set_id_t i;
+
+	if (unlikely(protocol_failed(attr)))
+		return -EPROTO;
+
+	if (!attr[IPSET_ATTR_SETNAME]) {
+		for (i = 0; i < ip_set_max; i++)
+			if (ip_set_list[i] != NULL)
+				ip_set_flush_set(ip_set_list[i]);
+	} else {
+		i = find_set_id(nla_data(attr[IPSET_ATTR_SETNAME]));
+		if (i == IPSET_INVALID_ID)
+			return -ENOENT;
+
+		ip_set_flush_set(ip_set_list[i]);
+	}
+
+	return 0;
+}
+
+/* Rename a set */
+
+static const struct nla_policy
+ip_set_setname2_policy[IPSET_ATTR_CMD_MAX + 1] = {
+	[IPSET_ATTR_PROTOCOL]	= { .type = NLA_U8 },
+	[IPSET_ATTR_SETNAME]	= { .type = NLA_NUL_STRING,
+				    .len = IPSET_MAXNAMELEN - 1 },
+	[IPSET_ATTR_SETNAME2]	= { .type = NLA_NUL_STRING,
+				    .len = IPSET_MAXNAMELEN - 1 },
+};
+
+static int
+ip_set_rename(struct sock *ctnl, struct sk_buff *skb,
+	      const struct nlmsghdr *nlh,
+	      const struct nlattr * const attr[])
+{
+	struct ip_set *set;
+	const char *name2;
+	ip_set_id_t i;
+
+	if (unlikely(protocol_failed(attr) ||
+		     attr[IPSET_ATTR_SETNAME] == NULL ||
+		     attr[IPSET_ATTR_SETNAME2] == NULL))
+		return -IPSET_ERR_PROTOCOL;
+
+	set = find_set(nla_data(attr[IPSET_ATTR_SETNAME]));
+	if (set == NULL)
+		return -ENOENT;
+	if (atomic_read(&set->ref) != 0)
+		return -IPSET_ERR_REFERENCED;
+
+	name2 = nla_data(attr[IPSET_ATTR_SETNAME2]);
+	for (i = 0; i < ip_set_max; i++) {
+		if (ip_set_list[i] != NULL &&
+		    STREQ(ip_set_list[i]->name, name2))
+			return -IPSET_ERR_EXIST_SETNAME2;
+	}
+	strncpy(set->name, name2, IPSET_MAXNAMELEN);
+
+	return 0;
+}
+
+/* Swap two sets so that name/index points to the other.
+ * References and set names are also swapped.
+ *
+ * We are protected by the nfnl mutex and references are
+ * manipulated only by holding the mutex. The kernel interfaces
+ * do not hold the mutex but the pointer settings are atomic
+ * so the ip_set_list always contains valid pointers to the sets.
+ */
+
+static int
+ip_set_swap(struct sock *ctnl, struct sk_buff *skb,
+	    const struct nlmsghdr *nlh,
+	    const struct nlattr * const attr[])
+{
+	struct ip_set *from, *to;
+	ip_set_id_t from_id, to_id;
+	char from_name[IPSET_MAXNAMELEN];
+	u32 from_ref;
+
+	if (unlikely(protocol_failed(attr) ||
+		     attr[IPSET_ATTR_SETNAME] == NULL ||
+		     attr[IPSET_ATTR_SETNAME2] == NULL))
+		return -IPSET_ERR_PROTOCOL;
+
+	from_id = find_set_id(nla_data(attr[IPSET_ATTR_SETNAME]));
+	if (from_id == IPSET_INVALID_ID)
+		return -ENOENT;
+
+	to_id = find_set_id(nla_data(attr[IPSET_ATTR_SETNAME2]));
+	if (to_id == IPSET_INVALID_ID)
+		return -IPSET_ERR_EXIST_SETNAME2;
+
+	from = ip_set_list[from_id];
+	to = ip_set_list[to_id];
+
+	/* Features must not change.
+	 * Not an artifical restriction anymore, as we must prevent
+	 * possible loops created by swapping in setlist type of sets. */
+	if (!(from->type->features == to->type->features &&
+	      from->type->family == to->type->family))
+		return -IPSET_ERR_TYPE_MISMATCH;
+
+	/* No magic here: ref munging protected by the nfnl_lock */
+	strncpy(from_name, from->name, IPSET_MAXNAMELEN);
+	from_ref = atomic_read(&from->ref);
+
+	strncpy(from->name, to->name, IPSET_MAXNAMELEN);
+	atomic_set(&from->ref, atomic_read(&to->ref));
+	strncpy(to->name, from_name, IPSET_MAXNAMELEN);
+	atomic_set(&to->ref, from_ref);
+
+	ip_set_list[from_id] = to;
+	ip_set_list[to_id] = from;
+
+	return 0;
+}
+
+/* List/save set data */
+
+#define DUMP_INIT	0L
+#define DUMP_ALL	1L
+#define DUMP_ONE	2L
+#define DUMP_LAST	3L
+
+static int
+ip_set_dump_done(struct netlink_callback *cb)
+{
+	if (cb->args[2]) {
+		pr_debug("release set %s\n", ip_set_list[cb->args[1]]->name);
+		__ip_set_put((ip_set_id_t) cb->args[1]);
+	}
+	return 0;
+}
+
+static inline void
+dump_attrs(struct nlmsghdr *nlh)
+{
+	const struct nlattr *attr;
+	int rem;
+
+	pr_debug("dump nlmsg\n");
+	nlmsg_for_each_attr(attr, nlh, sizeof(struct nfgenmsg), rem) {
+		pr_debug("type: %u, len %u\n", nla_type(attr), attr->nla_len);
+	}
+}
+
+static int
+dump_init(struct netlink_callback *cb)
+{
+	struct nlmsghdr *nlh = nlmsg_hdr(cb->skb);
+	int min_len = NLMSG_SPACE(sizeof(struct nfgenmsg));
+	struct nlattr *cda[IPSET_ATTR_CMD_MAX+1];
+	struct nlattr *attr = (void *)nlh + min_len;
+	ip_set_id_t index;
+
+	/* Second pass, so parser can't fail */
+	nla_parse(cda, IPSET_ATTR_CMD_MAX,
+		  attr, nlh->nlmsg_len - min_len, ip_set_setname_policy);
+
+	/* cb->args[0] : dump single set/all sets
+	 *         [1] : set index
+	 *         [..]: type specific
+	 */
+
+	if (!cda[IPSET_ATTR_SETNAME]) {
+		cb->args[0] = DUMP_ALL;
+		return 0;
+	}
+
+	index = find_set_id(nla_data(cda[IPSET_ATTR_SETNAME]));
+	if (index == IPSET_INVALID_ID)
+		return -ENOENT;
+
+	cb->args[0] = DUMP_ONE;
+	cb->args[1] = index;
+	return 0;
+}
+
+static int
+ip_set_dump_start(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	ip_set_id_t index = IPSET_INVALID_ID, max;
+	struct ip_set *set = NULL;
+	struct nlmsghdr *nlh = NULL;
+	unsigned int flags = NETLINK_CB(cb->skb).pid ? NLM_F_MULTI : 0;
+	int ret = 0;
+
+	if (cb->args[0] == DUMP_INIT) {
+		ret = dump_init(cb);
+		if (ret < 0) {
+			nlh = nlmsg_hdr(cb->skb);
+			/* We have to create and send the error message
+			 * manually :-( */
+			if (nlh->nlmsg_flags & NLM_F_ACK)
+				netlink_ack(cb->skb, nlh, ret);
+			return ret;
+		}
+	}
+
+	if (cb->args[1] >= ip_set_max)
+		goto out;
+
+	pr_debug("args[0]: %ld args[1]: %ld\n", cb->args[0], cb->args[1]);
+	max = cb->args[0] == DUMP_ONE ? cb->args[1] + 1 : ip_set_max;
+	for (; cb->args[1] < max; cb->args[1]++) {
+		index = (ip_set_id_t) cb->args[1];
+		set = ip_set_list[index];
+		if (set == NULL) {
+			if (cb->args[0] == DUMP_ONE) {
+				ret = -ENOENT;
+				goto out;
+			}
+			continue;
+		}
+		/* When dumping all sets, we must dump "sorted"
+		 * so that lists (unions of sets) are dumped last.
+		 */
+		if (cb->args[0] != DUMP_ONE &&
+		    !((cb->args[0] == DUMP_ALL) ^
+		      (set->type->features & IPSET_DUMP_LAST)))
+			continue;
+		pr_debug("List set: %s\n", set->name);
+		if (!cb->args[2]) {
+			/* Start listing: make sure set won't be destroyed */
+			pr_debug("reference set\n");
+			__ip_set_get(index);
+		}
+		nlh = start_msg(skb, NETLINK_CB(cb->skb).pid,
+				cb->nlh->nlmsg_seq, flags,
+				IPSET_CMD_LIST);
+		if (!nlh) {
+			ret = -EMSGSIZE;
+			goto release_refcount;
+		}
+		NLA_PUT_U8(skb, IPSET_ATTR_PROTOCOL, IPSET_PROTOCOL);
+		NLA_PUT_STRING(skb, IPSET_ATTR_SETNAME, set->name);
+		switch (cb->args[2]) {
+		case 0:
+			/* Core header data */
+			NLA_PUT_STRING(skb, IPSET_ATTR_TYPENAME,
+				       set->type->name);
+			NLA_PUT_U8(skb, IPSET_ATTR_FAMILY,
+				   set->family);
+			NLA_PUT_U8(skb, IPSET_ATTR_REVISION,
+				   set->type->revision);
+			ret = set->variant->head(set, skb);
+			if (ret < 0)
+				goto release_refcount;
+			/* Fall through and add elements */
+		default:
+			read_lock_bh(&set->lock);
+			ret = set->variant->list(set, skb, cb);
+			read_unlock_bh(&set->lock);
+			if (!cb->args[2]) {
+				/* Set is done, proceed with next one */
+				if (cb->args[0] == DUMP_ONE)
+					cb->args[1] = IPSET_INVALID_ID;
+				else
+					cb->args[1]++;
+			}
+			goto release_refcount;
+		}
+	}
+	goto out;
+
+nla_put_failure:
+	ret = -EFAULT;
+release_refcount:
+	/* If there was an error or set is done, release set */
+	if (ret || !cb->args[2]) {
+		pr_debug("release set %s\n", ip_set_list[index]->name);
+		__ip_set_put(index);
+	}
+
+	/* If we dump all sets, continue with dumping last ones */
+	if (cb->args[0] == DUMP_ALL && cb->args[1] >= max && !cb->args[2])
+		cb->args[0] = DUMP_LAST;
+
+out:
+	if (nlh) {
+		nlmsg_end(skb, nlh);
+		pr_debug("nlmsg_len: %u\n", nlh->nlmsg_len);
+		dump_attrs(nlh);
+	}
+
+	return ret < 0 ? ret : skb->len;
+}
+
+static int
+ip_set_dump(struct sock *ctnl, struct sk_buff *skb,
+	    const struct nlmsghdr *nlh,
+	    const struct nlattr * const attr[])
+{
+	if (unlikely(protocol_failed(attr)))
+		return -IPSET_ERR_PROTOCOL;
+
+	return netlink_dump_start(ctnl, skb, nlh,
+				  ip_set_dump_start,
+				  ip_set_dump_done);
+}
+
+/* Add, del and test */
+
+static const struct nla_policy ip_set_adt_policy[IPSET_ATTR_CMD_MAX + 1] = {
+	[IPSET_ATTR_PROTOCOL]	= { .type = NLA_U8 },
+	[IPSET_ATTR_SETNAME]	= { .type = NLA_NUL_STRING,
+				    .len = IPSET_MAXNAMELEN - 1 },
+	[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
+	[IPSET_ATTR_DATA]	= { .type = NLA_NESTED },
+	[IPSET_ATTR_ADT]	= { .type = NLA_NESTED },
+};
+
+static int
+call_ad(struct sk_buff *skb, struct ip_set *set,
+	struct nlattr *tb[], enum ipset_adt adt,
+	u32 flags, bool use_lineno)
+{
+	int ret, retried = 0;
+	u32 lineno = 0;
+	bool eexist = flags & IPSET_FLAG_EXIST;
+
+	do {
+		write_lock_bh(&set->lock);
+		ret = set->variant->uadt(set, tb, adt, &lineno, flags);
+		write_unlock_bh(&set->lock);
+	} while (ret == -EAGAIN &&
+		 set->variant->resize &&
+		 (ret = set->variant->resize(set, retried++)) == 0);
+
+	if (!ret || (ret == -IPSET_ERR_EXIST && eexist))
+		return 0;
+	if (lineno && use_lineno) {
+		/* Error in restore/batch mode: send back lineno */
+		struct nlmsghdr *nlh = nlmsg_hdr(skb);
+		int min_len = NLMSG_SPACE(sizeof(struct nfgenmsg));
+		struct nlattr *cda[IPSET_ATTR_CMD_MAX+1];
+		struct nlattr *cmdattr = (void *)nlh + min_len;
+		u32 *errline;
+
+		nla_parse(cda, IPSET_ATTR_CMD_MAX,
+			  cmdattr, nlh->nlmsg_len - min_len,
+			  ip_set_adt_policy);
+
+		errline = nla_data(cda[IPSET_ATTR_LINENO]);
+
+		*errline = lineno;
+	}
+
+	return ret;
+}
+
+static int
+ip_set_uadd(struct sock *ctnl, struct sk_buff *skb,
+	    const struct nlmsghdr *nlh,
+	    const struct nlattr * const attr[])
+{
+	struct ip_set *set;
+	struct nlattr *tb[IPSET_ATTR_ADT_MAX+1] = {};
+	const struct nlattr *nla;
+	u32 flags = flag_exist(nlh);
+	bool use_lineno;
+	int ret = 0;
+
+	if (unlikely(protocol_failed(attr) ||
+		     attr[IPSET_ATTR_SETNAME] == NULL ||
+		     !((attr[IPSET_ATTR_DATA] != NULL) ^
+		       (attr[IPSET_ATTR_ADT] != NULL)) ||
+		     (attr[IPSET_ATTR_DATA] != NULL &&
+		      !flag_nested(attr[IPSET_ATTR_DATA])) ||
+		     (attr[IPSET_ATTR_ADT] != NULL &&
+		      (!flag_nested(attr[IPSET_ATTR_ADT]) ||
+		       attr[IPSET_ATTR_LINENO] == NULL))))
+		return -IPSET_ERR_PROTOCOL;
+
+	set = find_set(nla_data(attr[IPSET_ATTR_SETNAME]));
+	if (set == NULL)
+		return -ENOENT;
+
+	use_lineno = !!attr[IPSET_ATTR_LINENO];
+	if (attr[IPSET_ATTR_DATA]) {
+		if (nla_parse(tb, IPSET_ATTR_ADT_MAX,
+			      nla_data(attr[IPSET_ATTR_DATA]),
+			      nla_len(attr[IPSET_ATTR_DATA]),
+			      set->type->adt_policy))
+			return -IPSET_ERR_PROTOCOL;
+		ret = call_ad(skb, set, tb, IPSET_ADD, flags, use_lineno);
+	} else {
+		int nla_rem;
+
+		nla_for_each_nested(nla, attr[IPSET_ATTR_ADT], nla_rem) {
+			memset(tb, 0, sizeof(tb));
+			if (nla_type(nla) != IPSET_ATTR_DATA ||
+			    !flag_nested(nla) ||
+			    nla_parse(tb, IPSET_ATTR_ADT_MAX,
+			    	      nla_data(nla), nla_len(nla),
+			    	      set->type->adt_policy))
+				return -IPSET_ERR_PROTOCOL;
+			ret = call_ad(skb, set, tb, IPSET_ADD,
+				      flags, use_lineno);
+			if (ret < 0)
+				return ret;
+		}
+	}
+	return ret;
+}
+
+static int
+ip_set_udel(struct sock *ctnl, struct sk_buff *skb,
+	    const struct nlmsghdr *nlh,
+	    const struct nlattr * const attr[])
+{
+	struct ip_set *set;
+	struct nlattr *tb[IPSET_ATTR_ADT_MAX+1] = {};
+	const struct nlattr *nla;
+	u32 flags = flag_exist(nlh);
+	bool use_lineno;
+	int ret = 0;
+
+	if (unlikely(protocol_failed(attr) ||
+		     attr[IPSET_ATTR_SETNAME] == NULL ||
+		     !((attr[IPSET_ATTR_DATA] != NULL) ^
+		       (attr[IPSET_ATTR_ADT] != NULL)) ||
+		     (attr[IPSET_ATTR_DATA] != NULL &&
+		      !flag_nested(attr[IPSET_ATTR_DATA])) ||
+		     (attr[IPSET_ATTR_ADT] != NULL &&
+		      (!flag_nested(attr[IPSET_ATTR_ADT]) ||
+		       attr[IPSET_ATTR_LINENO] == NULL))))
+		return -IPSET_ERR_PROTOCOL;
+
+	set = find_set(nla_data(attr[IPSET_ATTR_SETNAME]));
+	if (set == NULL)
+		return -ENOENT;
+
+	use_lineno = !!attr[IPSET_ATTR_LINENO];
+	if (attr[IPSET_ATTR_DATA]) {
+		if (nla_parse(tb, IPSET_ATTR_ADT_MAX,
+			      nla_data(attr[IPSET_ATTR_DATA]),
+			      nla_len(attr[IPSET_ATTR_DATA]),
+			      set->type->adt_policy))
+			return -IPSET_ERR_PROTOCOL;
+		ret = call_ad(skb, set, tb, IPSET_DEL, flags, use_lineno);
+	} else {
+		int nla_rem;
+
+		nla_for_each_nested(nla, attr[IPSET_ATTR_ADT], nla_rem) {
+			memset(tb, 0, sizeof(*tb));
+			if (nla_type(nla) != IPSET_ATTR_DATA ||
+			    !flag_nested(nla) ||
+			    nla_parse(tb, IPSET_ATTR_ADT_MAX,
+			    	      nla_data(nla), nla_len(nla),
+			    	      set->type->adt_policy))
+				return -IPSET_ERR_PROTOCOL;
+			ret = call_ad(skb, set, tb, IPSET_DEL,
+				      flags, use_lineno);
+			if (ret < 0)
+				return ret;
+		}
+	}
+	return ret;
+}
+
+static int
+ip_set_utest(struct sock *ctnl, struct sk_buff *skb,
+	     const struct nlmsghdr *nlh,
+	     const struct nlattr * const attr[])
+{
+	struct ip_set *set;
+	struct nlattr *tb[IPSET_ATTR_ADT_MAX+1] = {};
+	int ret = 0;
+
+	if (unlikely(protocol_failed(attr) ||
+		     attr[IPSET_ATTR_SETNAME] == NULL ||
+		     attr[IPSET_ATTR_DATA] == NULL ||
+		     !flag_nested(attr[IPSET_ATTR_DATA])))
+		return -IPSET_ERR_PROTOCOL;
+
+	set = find_set(nla_data(attr[IPSET_ATTR_SETNAME]));
+	if (set == NULL)
+		return -ENOENT;
+
+	if (nla_parse(tb, IPSET_ATTR_ADT_MAX,
+		      nla_data(attr[IPSET_ATTR_DATA]),
+		      nla_len(attr[IPSET_ATTR_DATA]),
+		      set->type->adt_policy))
+		return -IPSET_ERR_PROTOCOL;
+
+	read_lock_bh(&set->lock);
+	ret = set->variant->uadt(set, tb, IPSET_TEST, NULL, 0);
+	read_unlock_bh(&set->lock);
+	/* Userspace can't trigger element to be re-added */
+	if (ret == -EAGAIN)
+		ret = 1;
+
+	return ret < 0 ? ret : ret > 0 ? 0 : -IPSET_ERR_EXIST;
+}
+
+/* Get headed data of a set */
+
+static int
+ip_set_header(struct sock *ctnl, struct sk_buff *skb,
+	      const struct nlmsghdr *nlh,
+	      const struct nlattr * const attr[])
+{
+	const struct ip_set *set;
+	struct sk_buff *skb2;
+	struct nlmsghdr *nlh2;
+	ip_set_id_t index;
+	int ret = 0;
+
+	if (unlikely(protocol_failed(attr) ||
+		     attr[IPSET_ATTR_SETNAME] == NULL))
+		return -IPSET_ERR_PROTOCOL;
+
+	index = find_set_id(nla_data(attr[IPSET_ATTR_SETNAME]));
+	if (index == IPSET_INVALID_ID)
+		return -ENOENT;
+	set = ip_set_list[index];
+
+	skb2 = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (skb2 == NULL)
+		return -ENOMEM;
+
+	nlh2 = start_msg(skb2, NETLINK_CB(skb).pid, nlh->nlmsg_seq, 0,
+			 IPSET_CMD_HEADER);
+	if (!nlh2)
+		goto nlmsg_failure;
+	NLA_PUT_U8(skb2, IPSET_ATTR_PROTOCOL, IPSET_PROTOCOL);
+	NLA_PUT_STRING(skb2, IPSET_ATTR_SETNAME, set->name);
+	NLA_PUT_STRING(skb2, IPSET_ATTR_TYPENAME, set->type->name);
+	NLA_PUT_U8(skb2, IPSET_ATTR_FAMILY, set->family);
+	NLA_PUT_U8(skb2, IPSET_ATTR_REVISION, set->type->revision);
+	nlmsg_end(skb2, nlh2);
+
+	ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).pid, MSG_DONTWAIT);
+	if (ret < 0)
+		return ret;
+
+	return 0;
+
+nla_put_failure:
+	nlmsg_cancel(skb2, nlh2);
+nlmsg_failure:
+	kfree_skb(skb2);
+	return -EMSGSIZE;
+}
+
+/* Get type data */
+
+static const struct nla_policy ip_set_type_policy[IPSET_ATTR_CMD_MAX + 1] = {
+	[IPSET_ATTR_PROTOCOL]	= { .type = NLA_U8 },
+	[IPSET_ATTR_TYPENAME]	= { .type = NLA_NUL_STRING,
+				    .len = IPSET_MAXNAMELEN - 1 },
+	[IPSET_ATTR_FAMILY]	= { .type = NLA_U8 },
+};
+
+static int
+ip_set_type(struct sock *ctnl, struct sk_buff *skb,
+	    const struct nlmsghdr *nlh,
+	    const struct nlattr * const attr[])
+{
+	struct sk_buff *skb2;
+	struct nlmsghdr *nlh2;
+	u8 family, min, max;
+	const char *typename;
+	int ret = 0;
+
+	if (unlikely(protocol_failed(attr) ||
+		     attr[IPSET_ATTR_TYPENAME] == NULL ||
+		     attr[IPSET_ATTR_FAMILY] == NULL))
+		return -IPSET_ERR_PROTOCOL;
+
+	family = nla_get_u8(attr[IPSET_ATTR_FAMILY]);
+	typename = nla_data(attr[IPSET_ATTR_TYPENAME]);
+	ret = find_set_type_minmax(typename, family, &min, &max);
+	if (ret)
+		return ret;
+
+	skb2 = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (skb2 == NULL)
+		return -ENOMEM;
+
+	nlh2 = start_msg(skb2, NETLINK_CB(skb).pid, nlh->nlmsg_seq, 0,
+			 IPSET_CMD_TYPE);
+	if (!nlh2)
+		goto nlmsg_failure;
+	NLA_PUT_U8(skb2, IPSET_ATTR_PROTOCOL, IPSET_PROTOCOL);
+	NLA_PUT_STRING(skb2, IPSET_ATTR_TYPENAME, typename);
+	NLA_PUT_U8(skb2, IPSET_ATTR_FAMILY, family);
+	NLA_PUT_U8(skb2, IPSET_ATTR_REVISION, max);
+	NLA_PUT_U8(skb2, IPSET_ATTR_REVISION_MIN, min);
+	nlmsg_end(skb2, nlh2);
+
+	pr_debug("Send TYPE, nlmsg_len: %u\n", nlh2->nlmsg_len);
+	ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).pid, MSG_DONTWAIT);
+	if (ret < 0)
+		return ret;
+
+	return 0;
+
+nla_put_failure:
+	nlmsg_cancel(skb2, nlh2);
+nlmsg_failure:
+	kfree_skb(skb2);
+	return -EMSGSIZE;
+}
+
+/* Get protocol version */
+
+static const struct nla_policy
+ip_set_protocol_policy[IPSET_ATTR_CMD_MAX + 1] = {
+	[IPSET_ATTR_PROTOCOL]	= { .type = NLA_U8 },
+};
+
+static int
+ip_set_protocol(struct sock *ctnl, struct sk_buff *skb,
+		const struct nlmsghdr *nlh,
+		const struct nlattr * const attr[])
+{
+	struct sk_buff *skb2;
+	struct nlmsghdr *nlh2;
+	int ret = 0;
+
+	if (unlikely(attr[IPSET_ATTR_PROTOCOL] == NULL))
+		return -IPSET_ERR_PROTOCOL;
+
+	skb2 = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (skb2 == NULL)
+		return -ENOMEM;
+
+	nlh2 = start_msg(skb2, NETLINK_CB(skb).pid, nlh->nlmsg_seq, 0,
+			 IPSET_CMD_PROTOCOL);
+	if (!nlh2)
+		goto nlmsg_failure;
+	NLA_PUT_U8(skb2, IPSET_ATTR_PROTOCOL, IPSET_PROTOCOL);
+	nlmsg_end(skb2, nlh2);
+
+	ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).pid, MSG_DONTWAIT);
+	if (ret < 0)
+		return ret;
+
+	return 0;
+
+nla_put_failure:
+	nlmsg_cancel(skb2, nlh2);
+nlmsg_failure:
+	kfree_skb(skb2);
+	return -EMSGSIZE;
+}
+
+static const struct nfnl_callback ip_set_netlink_subsys_cb[IPSET_MSG_MAX] = {
+	[IPSET_CMD_CREATE]	= {
+		.call		= ip_set_create,
+		.attr_count	= IPSET_ATTR_CMD_MAX,
+		.policy		= ip_set_create_policy,
+	},
+	[IPSET_CMD_DESTROY]	= {
+		.call		= ip_set_destroy,
+		.attr_count	= IPSET_ATTR_CMD_MAX,
+		.policy		= ip_set_setname_policy,
+	},
+	[IPSET_CMD_FLUSH]	= {
+		.call		= ip_set_flush,
+		.attr_count	= IPSET_ATTR_CMD_MAX,
+		.policy		= ip_set_setname_policy,
+	},
+	[IPSET_CMD_RENAME]	= {
+		.call		= ip_set_rename,
+		.attr_count	= IPSET_ATTR_CMD_MAX,
+		.policy		= ip_set_setname2_policy,
+	},
+	[IPSET_CMD_SWAP]	= {
+		.call		= ip_set_swap,
+		.attr_count	= IPSET_ATTR_CMD_MAX,
+		.policy		= ip_set_setname2_policy,
+	},
+	[IPSET_CMD_LIST]	= {
+		.call		= ip_set_dump,
+		.attr_count	= IPSET_ATTR_CMD_MAX,
+		.policy		= ip_set_setname_policy,
+	},
+	[IPSET_CMD_SAVE]	= {
+		.call		= ip_set_dump,
+		.attr_count	= IPSET_ATTR_CMD_MAX,
+		.policy		= ip_set_setname_policy,
+	},
+	[IPSET_CMD_ADD]	= {
+		.call		= ip_set_uadd,
+		.attr_count	= IPSET_ATTR_CMD_MAX,
+		.policy		= ip_set_adt_policy,
+	},
+	[IPSET_CMD_DEL]	= {
+		.call		= ip_set_udel,
+		.attr_count	= IPSET_ATTR_CMD_MAX,
+		.policy		= ip_set_adt_policy,
+	},
+	[IPSET_CMD_TEST]	= {
+		.call		= ip_set_utest,
+		.attr_count	= IPSET_ATTR_CMD_MAX,
+		.policy		= ip_set_adt_policy,
+	},
+	[IPSET_CMD_HEADER]	= {
+		.call		= ip_set_header,
+		.attr_count	= IPSET_ATTR_CMD_MAX,
+		.policy		= ip_set_setname_policy,
+	},
+	[IPSET_CMD_TYPE]	= {
+		.call		= ip_set_type,
+		.attr_count	= IPSET_ATTR_CMD_MAX,
+		.policy		= ip_set_type_policy,
+	},
+	[IPSET_CMD_PROTOCOL]	= {
+		.call		= ip_set_protocol,
+		.attr_count	= IPSET_ATTR_CMD_MAX,
+		.policy		= ip_set_protocol_policy,
+	},
+};
+
+static struct nfnetlink_subsystem ip_set_netlink_subsys __read_mostly = {
+	.name		= "ip_set",
+	.subsys_id	= NFNL_SUBSYS_IPSET,
+	.cb_count	= IPSET_MSG_MAX,
+	.cb		= ip_set_netlink_subsys_cb,
+};
+
+/* Interface to iptables/ip6tables */
+
+static int
+ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
+{
+	unsigned *op;
+	void *data;
+	int copylen = *len, ret = 0;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+	if (optval != SO_IP_SET)
+		return -EBADF;
+	if (*len < sizeof(unsigned))
+		return -EINVAL;
+
+	data = vmalloc(*len);
+	if (!data)
+		return -ENOMEM;
+	if (copy_from_user(data, user, *len) != 0) {
+		ret = -EFAULT;
+		goto done;
+	}
+	op = (unsigned *) data;
+
+	if (*op < IP_SET_OP_VERSION) {
+		/* Check the version at the beginning of operations */
+		struct ip_set_req_version *req_version = data;
+		if (req_version->version != IPSET_PROTOCOL) {
+			ret = -EPROTO;
+			goto done;
+		}
+	}
+
+	switch (*op) {
+	case IP_SET_OP_VERSION: {
+		struct ip_set_req_version *req_version = data;
+
+		if (*len != sizeof(struct ip_set_req_version)) {
+			ret = -EINVAL;
+			goto done;
+		}
+
+		req_version->version = IPSET_PROTOCOL;
+		ret = copy_to_user(user, req_version,
+				   sizeof(struct ip_set_req_version));
+		goto done;
+	}
+	case IP_SET_OP_GET_BYNAME: {
+		struct ip_set_req_get_set *req_get = data;
+
+		if (*len != sizeof(struct ip_set_req_get_set)) {
+			ret = -EINVAL;
+			goto done;
+		}
+		req_get->set.name[IPSET_MAXNAMELEN - 1] = '\0';
+		nfnl_lock();
+		req_get->set.index = find_set_id(req_get->set.name);
+		nfnl_unlock();
+		goto copy;
+	}
+	case IP_SET_OP_GET_BYINDEX: {
+		struct ip_set_req_get_set *req_get = data;
+
+		if (*len != sizeof(struct ip_set_req_get_set) ||
+		    req_get->set.index >= ip_set_max) {
+			ret = -EINVAL;
+			goto done;
+		}
+		nfnl_lock();
+		strncpy(req_get->set.name,
+			ip_set_list[req_get->set.index]
+				? ip_set_list[req_get->set.index]->name : "",
+			IPSET_MAXNAMELEN);
+		nfnl_unlock();
+		goto copy;
+	}
+	default:
+		ret = -EBADMSG;
+		goto done;
+	}	/* end of switch(op) */
+
+copy:
+	ret = copy_to_user(user, data, copylen);
+
+done:
+	vfree(data);
+	if (ret > 0)
+		ret = 0;
+	return ret;
+}
+
+static struct nf_sockopt_ops so_set __read_mostly = {
+	.pf		= PF_INET,
+	.get_optmin	= SO_IP_SET,
+	.get_optmax	= SO_IP_SET + 1,
+	.get		= &ip_set_sockfn_get,
+	.owner		= THIS_MODULE,
+};
+
+static int __init
+ip_set_init(void)
+{
+	int ret;
+
+	if (max_sets)
+		ip_set_max = max_sets;
+	if (ip_set_max >= IPSET_INVALID_ID)
+		ip_set_max = IPSET_INVALID_ID - 1;
+
+	ip_set_list = kzalloc(sizeof(struct ip_set *) * ip_set_max,
+			      GFP_KERNEL);
+	if (!ip_set_list) {
+		pr_err("ip_set: Unable to create ip_set_list\n");
+		return -ENOMEM;
+	}
+
+	ret = nfnetlink_subsys_register(&ip_set_netlink_subsys);
+	if (ret != 0) {
+		pr_err("ip_set: cannot register with nfnetlink.\n");
+		kfree(ip_set_list);
+		return ret;
+	}
+	ret = nf_register_sockopt(&so_set);
+	if (ret != 0) {
+		pr_err("SO_SET registry failed: %d\n", ret);
+		nfnetlink_subsys_unregister(&ip_set_netlink_subsys);
+		kfree(ip_set_list);
+		return ret;
+	}
+
+	pr_notice("ip_set: protocol %u\n", IPSET_PROTOCOL);
+	return 0;
+}
+
+static void __exit
+ip_set_fini(void)
+{
+	/* There can't be any existing set */
+	nf_unregister_sockopt(&so_set);
+	nfnetlink_subsys_unregister(&ip_set_netlink_subsys);
+	kfree(ip_set_list);
+	pr_debug("these are the famous last words\n");
+}
+
+module_init(ip_set_init);
+module_exit(ip_set_fini);
diff --git a/net/netfilter/ipset/ip_set_getport.c b/net/netfilter/ipset/ip_set_getport.c
new file mode 100644
index 0000000..76737bb
--- /dev/null
+++ b/net/netfilter/ipset/ip_set_getport.c
@@ -0,0 +1,136 @@
+/* Copyright (C) 2003-2011 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+/* Get Layer-4 data from the packets */
+
+#include <linux/ip.h>
+#include <linux/skbuff.h>
+#include <linux/icmp.h>
+#include <linux/icmpv6.h>
+#include <linux/netfilter_ipv6/ip6_tables.h>
+#include <net/ip.h>
+
+#include <linux/netfilter/ipset/ip_set_getport.h>
+
+/* We must handle non-linear skbs */
+static bool
+get_port(const struct sk_buff *skb, int protocol, unsigned int protooff,
+	 bool src, __be16 *port, u8 *proto)
+{
+	switch (protocol) {
+	case IPPROTO_TCP: {
+		struct tcphdr _tcph;
+		const struct tcphdr *th;
+
+		th = skb_header_pointer(skb, protooff, sizeof(_tcph), &_tcph);
+		if (th == NULL)
+			/* No choice either */
+			return false;
+
+		*port = src ? th->source : th->dest;
+		break;
+	}
+	case IPPROTO_UDP: {
+		struct udphdr _udph;
+		const struct udphdr *uh;
+
+		uh = skb_header_pointer(skb, protooff, sizeof(_udph), &_udph);
+		if (uh == NULL)
+			/* No choice either */
+			return false;
+
+		*port = src ? uh->source : uh->dest;
+		break;
+	}
+	case IPPROTO_ICMP: {
+		struct icmphdr _ich;
+		const struct icmphdr *ic;
+
+		ic = skb_header_pointer(skb, protooff, sizeof(_ich), &_ich);
+		if (ic == NULL)
+			return false;
+
+		*port = (__force __be16)htons((ic->type << 8) | ic->code);
+		break;
+	}
+	case IPPROTO_ICMPV6: {
+		struct icmp6hdr _ich;
+		const struct icmp6hdr *ic;
+
+		ic = skb_header_pointer(skb, protooff, sizeof(_ich), &_ich);
+		if (ic == NULL)
+			return false;
+
+		*port = (__force __be16)
+			htons((ic->icmp6_type << 8) | ic->icmp6_code);
+		break;
+	}
+	default:
+		break;
+	}
+	*proto = protocol;
+
+	return true;
+}
+
+bool
+ip_set_get_ip4_port(const struct sk_buff *skb, bool src,
+		    __be16 *port, u8 *proto)
+{
+	const struct iphdr *iph = ip_hdr(skb);
+	unsigned int protooff = ip_hdrlen(skb);
+	int protocol = iph->protocol;
+
+	/* See comments at tcp_match in ip_tables.c */
+	if (protocol <= 0 || (ntohs(iph->frag_off) & IP_OFFSET))
+		return false;
+
+	return get_port(skb, protocol, protooff, src, port, proto);
+}
+EXPORT_SYMBOL_GPL(ip_set_get_ip4_port);
+
+bool
+ip_set_get_ip6_port(const struct sk_buff *skb, bool src,
+		    __be16 *port, u8 *proto)
+{
+	unsigned int protooff = 0;
+	int protocol;
+	unsigned short fragoff;
+
+	protocol = ipv6_find_hdr(skb, &protooff, -1, &fragoff);
+	if (protocol <= 0 || fragoff)
+		return false;
+
+	return get_port(skb, protocol, protooff, src, port, proto);
+}
+EXPORT_SYMBOL_GPL(ip_set_get_ip6_port);
+
+bool
+ip_set_get_ip_port(const struct sk_buff *skb, u8 pf, bool src, __be16 *port)
+{
+	bool ret;
+	u8 proto;
+
+	switch (pf) {
+	case AF_INET:
+		ret = ip_set_get_ip4_port(skb, src, port, &proto);
+	case AF_INET6:
+		ret = ip_set_get_ip6_port(skb, src, port, &proto);
+	default:
+		return false;
+	}
+	if (!ret)
+		return ret;
+	switch (proto) {
+	case IPPROTO_TCP:
+	case IPPROTO_UDP:
+		return true;
+	default:
+		return false;
+	}
+}
+EXPORT_SYMBOL_GPL(ip_set_get_ip_port);
diff --git a/net/netfilter/ipset/pfxlen.c b/net/netfilter/ipset/pfxlen.c
new file mode 100644
index 0000000..23f8c81
--- /dev/null
+++ b/net/netfilter/ipset/pfxlen.c
@@ -0,0 +1,291 @@
+#include <linux/netfilter/ipset/pfxlen.h>
+
+/*
+ * Prefixlen maps for fast conversions, by Jan Engelhardt.
+ */
+
+#define E(a, b, c, d) \
+	{.ip6 = { \
+		__constant_htonl(a), __constant_htonl(b), \
+		__constant_htonl(c), __constant_htonl(d), \
+	} }
+
+/*
+ * This table works for both IPv4 and IPv6;
+ * just use prefixlen_netmask_map[prefixlength].ip.
+ */
+const union nf_inet_addr ip_set_netmask_map[] = {
+	E(0x00000000, 0x00000000, 0x00000000, 0x00000000),
+	E(0x80000000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xC0000000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xE0000000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xF0000000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xF8000000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFC000000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFE000000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFF000000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFF800000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFC00000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFE00000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFF00000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFF80000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFC0000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFE0000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFF0000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFF8000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFC000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFE000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFF000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFF800, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFC00, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFE00, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFF00, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFF80, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFC0, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFE0, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFF0, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFF8, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFC, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFE, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0x80000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xC0000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xE0000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xF0000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xF8000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFC000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFE000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFF000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFF800000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFC00000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFE00000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFF00000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFF80000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFC0000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFE0000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFF0000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFF8000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFC000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFE000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFF000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFF800, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFC00, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFE00, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFF00, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFF80, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFC0, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFE0, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFF0, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFF8, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFC, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFE, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0x80000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xC0000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xE0000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xF0000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xF8000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFC000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFE000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFF000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFF800000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFC00000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFE00000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFF00000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFF80000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFC0000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFE0000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFF0000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFF8000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFC000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFE000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFF000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFF800, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFC00, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFE00, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFF00, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFF80, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFC0, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFE0, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFF0, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFF8, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFC, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFE, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0x80000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xC0000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xE0000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xF0000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xF8000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFC000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFE000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFF000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFF800000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFC00000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFE00000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFF00000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFF80000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFC0000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFE0000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFF0000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFF8000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFC000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFE000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFF000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFF800),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFC00),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFE00),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFF00),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFF80),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFC0),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFE0),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFF0),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFF8),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFC),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFE),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF),
+};
+EXPORT_SYMBOL_GPL(ip_set_netmask_map);
+
+#undef  E
+#define E(a, b, c, d) 						\
+	{.ip6 = { (__force __be32) a, (__force __be32) b,	\
+		  (__force __be32) c, (__force __be32) d,	\
+	} }
+
+/*
+ * This table works for both IPv4 and IPv6;
+ * just use prefixlen_hostmask_map[prefixlength].ip.
+ */
+const union nf_inet_addr ip_set_hostmask_map[] = {
+	E(0x00000000, 0x00000000, 0x00000000, 0x00000000),
+	E(0x80000000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xC0000000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xE0000000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xF0000000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xF8000000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFC000000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFE000000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFF000000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFF800000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFC00000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFE00000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFF00000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFF80000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFC0000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFE0000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFF0000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFF8000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFC000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFE000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFF000, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFF800, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFC00, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFE00, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFF00, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFF80, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFC0, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFE0, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFF0, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFF8, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFC, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFE, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0x00000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0x80000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xC0000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xE0000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xF0000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xF8000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFC000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFE000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFF000000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFF800000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFC00000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFE00000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFF00000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFF80000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFC0000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFE0000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFF0000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFF8000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFC000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFE000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFF000, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFF800, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFC00, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFE00, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFF00, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFF80, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFC0, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFE0, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFF0, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFF8, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFC, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFE, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0x00000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0x80000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xC0000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xE0000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xF0000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xF8000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFC000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFE000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFF000000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFF800000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFC00000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFE00000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFF00000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFF80000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFC0000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFE0000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFF0000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFF8000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFC000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFE000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFF000, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFF800, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFC00, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFE00, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFF00, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFF80, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFC0, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFE0, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFF0, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFF8, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFC, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFE, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0x00000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0x80000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xC0000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xE0000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xF0000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xF8000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFC000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFE000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFF000000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFF800000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFC00000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFE00000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFF00000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFF80000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFC0000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFE0000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFF0000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFF8000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFC000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFE000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFF000),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFF800),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFC00),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFE00),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFF00),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFF80),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFC0),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFE0),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFF0),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFF8),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFC),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFE),
+	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF),
+};
+EXPORT_SYMBOL_GPL(ip_set_hostmask_map);
-- 
1.7.2.3

