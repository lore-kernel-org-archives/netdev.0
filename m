From: paul.moore@hp.com
Subject: [PATCH 2/7] NetLabel: core network changes
Date: Fri, 14 Jul 2006 14:57:41 -0400
Message-ID: <20060714185914.416432000@flek.zko.hp.com>
References: <20060714185739.780700000@flek.zko.hp.com>
Cc: davem@davemloft.net, sds@epoch.ncsc.mil, jmorris@redhat.com,
	pratt@argus-systems.com, Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:27070 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1161292AbWGNS7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 14:59:17 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-net_core-2.6.18
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changes to the core network stack to support the NetLabel subsystem.  This
includes changes to the IPv4 option handling to support CIPSO labels, and a new
NetLabel hook in inet_accept() to handle NetLabel attributes across accept()
calls done by in-kernel daemons.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 include/linux/ip.h       |    1 
 include/net/cipso_ipv4.h |  266 ++++++++++++++++++++
 include/net/inet_sock.h  |    2 
 include/net/netlabel.h   |  615 +++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/af_inet.c       |    3 
 net/ipv4/ah4.c           |    2 
 net/ipv4/ip_options.c    |   19 +
 7 files changed, 906 insertions(+), 2 deletions(-)

Index: linux-2.6.18-rc1/include/linux/ip.h
===================================================================
--- linux-2.6.18-rc1.orig/include/linux/ip.h
+++ linux-2.6.18-rc1/include/linux/ip.h
@@ -57,6 +57,7 @@
 #define IPOPT_SEC	(2 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_LSRR	(3 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_TIMESTAMP	(4 |IPOPT_MEASUREMENT)
+#define IPOPT_CIPSO	(6 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_RR	(7 |IPOPT_CONTROL)
 #define IPOPT_SID	(8 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_SSRR	(9 |IPOPT_CONTROL|IPOPT_COPY)
Index: linux-2.6.18-rc1/include/net/cipso_ipv4.h
===================================================================
--- /dev/null
+++ linux-2.6.18-rc1/include/net/cipso_ipv4.h
@@ -0,0 +1,266 @@
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
+int cipso_v4_doi_remove(const u32 doi,
+			void (*callback) (struct rcu_head * head));
+struct cipso_v4_doi *cipso_v4_doi_getdef(const u32 doi);
+struct sk_buff *cipso_v4_doi_dump_all(const size_t headroom);
+struct sk_buff *cipso_v4_doi_dump(const u32 doi, const size_t headroom);
+int cipso_v4_doi_domhsh_add(struct cipso_v4_doi *doi_def, const char *domain);
+int cipso_v4_doi_domhsh_remove(struct cipso_v4_doi *doi_def,
+			       const char *domain);
+#else
+static inline int cipso_v4_doi_add(struct cipso_v4_doi *doi_def)
+{
+	return -ENOSYS;
+}
+
+static inline int cipso_v4_doi_remove(const u32 doi,
+				    void (*callback) (struct rcu_head * head))
+{
+	return 0;
+}
+
+static inline struct cipso_v4_doi *cipso_v4_doi_getdef(const u32 doi)
+{
+	return NULL;
+}
+
+static inline struct sk_buff *cipso_v4_doi_dump_all(const size_t headroom)
+{
+	return NULL;
+}
+
+static inline struct sk_buff *cipso_v4_doi_dump(const u32 doi,
+						const size_t headroom)
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
+void cipso_v4_error(struct sk_buff *skb, const int error, const u32 gateway);
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
+				  const int error,
+				  const u32 gateway)
+{
+	return;
+}
+
+static inline int cipso_v4_socket_setopt(struct socket *sock,
+					 unsigned char *opt,
+					 u32 opt_len)
+{
+	return -ENOSYS;
+}
+
+static inline int cipso_v4_socket_setattr(const struct socket *sock,
+				  const struct cipso_v4_doi *doi_def,
+				  const struct netlbl_lsm_secattr *secattr)
+{
+	return -ENOSYS;
+}
+
+static inline int cipso_v4_socket_getopt(const struct socket *sock,
+					 unsigned char **opt,
+					 u32 *opt_len)
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
Index: linux-2.6.18-rc1/include/net/inet_sock.h
===================================================================
--- linux-2.6.18-rc1.orig/include/net/inet_sock.h
+++ linux-2.6.18-rc1/include/net/inet_sock.h
@@ -51,7 +51,7 @@ struct ip_options {
 			ts_needtime:1,
 			ts_needaddr:1;
 	unsigned char	router_alert;
-	unsigned char	__pad1;
+	unsigned char	cipso;
 	unsigned char	__pad2;
 	unsigned char	__data[0];
 };
Index: linux-2.6.18-rc1/include/net/netlabel.h
===================================================================
--- /dev/null
+++ linux-2.6.18-rc1/include/net/netlabel.h
@@ -0,0 +1,615 @@
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
+ * file.  All of the fields in the NetLabel payload should be aligned using
+ * the alignment functions provided.
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
+#define NETLBL_LEN_U8                   netlbl_align(1)
+#define NETLBL_LEN_U16                  netlbl_align(2)
+#define NETLBL_LEN_U32                  netlbl_align(4)
+/**
+ * netlbl_align - Align a NetLabel data chunk
+ * @len: the data chunk length
+ *
+ * Description:
+ * Return the aligned data chunk length.
+ *
+ */
+static inline size_t netlbl_align(const size_t length)
+{
+	return NLMSG_ALIGN(length);
+}
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
+ * netlbl_put_u16 - Write a u16 value into a buffer
+ * @buffer: the buffer
+ * @val: the value
+ *
+ * Description:
+ * Write the value specified in @val into the buffer specified by @buffer.
+ *
+ */
+static inline void netlbl_put_u16(unsigned char *buffer, const u16 val)
+{
+	*(u16 *)buffer = val;
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
+ * netlbl_putinc_u8 - Write a u8 value into a buffer and increment the buffer
+ * @buffer: the buffer
+ * @val: the value
+ * @rem_len: remaining length
+ *
+ * Description:
+ * Write the value specified in @val into the buffer specified by @buffer
+ * and advance the buffer pointer past the newly written value.  If @rem_len
+ * is not NULL then decrement it by the field length.
+ *
+ */
+static inline void netlbl_putinc_u8(unsigned char **buffer,
+				    const u8 val,
+				    ssize_t *rem_len)
+{
+	size_t len = netlbl_align(sizeof(u8));
+	netlbl_put_u8(*buffer, val);
+	*buffer += len;
+	if (rem_len != NULL)
+		*rem_len -= len;
+}
+
+/**
+ * netlbl_putinc_u16 - Write a u16 value into a buffer and increment the buffer
+ * @buffer: the buffer
+ * @val: the value
+ * @rem_len: remaining length
+ *
+ * Description:
+ * Write the value specified in @val into the buffer specified by @buffer
+ * and advance the buffer pointer past the newly written value.  If @rem_len
+ * is not NULL then decrement it by the field length.
+ *
+ */
+static inline void netlbl_putinc_u16(unsigned char **buffer,
+				     const u16 val,
+				     ssize_t *rem_len)
+{
+	size_t len = netlbl_align(sizeof(u16));
+	netlbl_put_u16(*buffer, val);
+	*buffer += len;
+	if (rem_len != NULL)
+		*rem_len -= len;
+}
+
+/**
+ * netlbl_putinc_u32 - Write a u32 value into a buffer and increment the buffer
+ * @buffer: the buffer
+ * @val: the value
+ * @rem_len: remaining length
+ *
+ * Description:
+ * Write the value specified in @val into the buffer specified by @buffer
+ * and advance the buffer pointer past the newly written value.  If @rem_len
+ * is not NULL then decrement it by the field length.
+ *
+ */
+static inline void netlbl_putinc_u32(unsigned char **buffer,
+				     const u32 val,
+				     ssize_t *rem_len)
+{
+	size_t len = netlbl_align(sizeof(u32));
+	netlbl_put_u32(*buffer, val);
+	*buffer += len;
+	if (rem_len != NULL)
+		*rem_len -= len;
+}
+
+/**
+ * netlbl_putinc_str - Write a string into a buffer and increment the buffer
+ * @buffer: the buffer
+ * @val: the value
+ * @rem_len: remaining length
+ *
+ * Description:
+ * Write the string specified in @val into the buffer specified by @buffer
+ * and advance the buffer pointer past the newly written value.  If @rem_len
+ * is not NULL then decrement it by the field length.
+ *
+ */
+static inline void netlbl_putinc_str(unsigned char **buffer,
+				     const char *val,
+				     ssize_t *rem_len)
+{
+	size_t len = netlbl_align(strlen(val) + 1);
+	strcpy((char *)*buffer, val);
+	*buffer += len;
+	if (rem_len != NULL)
+		*rem_len -= len;
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
+ * netlbl_get_u16 - Read a u16 value from a buffer
+ * @buffer: the buffer
+ *
+ * Description:
+ * Return a u16 value pointed to by @buffer.
+ *
+ */
+static inline u16 netlbl_get_u16(const unsigned char *buffer)
+{
+	return *(u16 *)buffer;
+}
+
+/**
+ * netlbl_get_u32 - Read a u32 value from a buffer
+ * @buffer: the buffer
+ *
+ * Description:
+ * Return a u32 value pointed to by @buffer.
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
+ * @rem_len: remaining length
+ *
+ * Description:
+ * Return a u8 value pointed to by @buffer and increment the buffer pointer
+ * past the value.  If @rem_len is not NULL, decrement it by the field size.
+ *
+ */
+static inline u8 netlbl_getinc_u8(unsigned char **buffer, ssize_t *rem_len)
+{
+	size_t len = netlbl_align(sizeof(u8));
+	u8 val = netlbl_get_u8(*buffer);
+	*buffer += len;
+	if (rem_len != NULL)
+		*rem_len -= len;
+	return val;
+}
+
+/**
+ * netlbl_getinc_u16 - Read a u16 value from a buffer and increment the buffer
+ * @buffer: the buffer
+ * @rem_len: remaining length
+ *
+ * Description:
+ * Return a u16 value pointed to by @buffer and increment the buffer pointer
+ * past the value.  If @rem_len is not NULL, decrement it by the field size.
+ *
+ */
+static inline u16 netlbl_getinc_u16(unsigned char **buffer, ssize_t *rem_len)
+{
+	size_t len = netlbl_align(sizeof(u16));
+	u16 val = netlbl_get_u16(*buffer);
+	*buffer += len;
+	if (rem_len != NULL)
+		*rem_len -= len;
+	return val;
+}
+
+/**
+ * netlbl_getinc_u32 - Read a u32 value from a buffer and increment the buffer
+ * @buffer: the buffer
+ * @rem_len: remaining length
+ *
+ * Description:
+ * Return a u32 value pointed to by @buffer and increment the buffer pointer
+ * past the value.  If @rem_len is not NULL, decrement it by the field size.
+ *
+ */
+static inline u32 netlbl_getinc_u32(unsigned char **buffer, ssize_t *rem_len)
+{
+	size_t len = netlbl_align(sizeof(u32));
+	u32 val = netlbl_get_u32(*buffer);
+	*buffer += len;
+	if (rem_len != NULL)
+		*rem_len -= len;
+	return val;
+}
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
+static inline struct sk_buff *netlbl_netlink_alloc_skb(const size_t head,
+						       const size_t body,
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
+					  const u32 clear_cache)
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
+static inline struct netlbl_lsm_secattr *netlbl_secattr_alloc(const int flags)
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
+				       const u32 clear_cache)
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
+int netlbl_socket_peekattr(const struct socket *sock,
+			   struct netlbl_lsm_secattr *secattr);
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
+static inline int netlbl_socket_peekattr(const struct socket *sock,
+					 struct netlbl_lsm_secattr *secattr)
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
+/*
+ * Network stack operations
+ */
+
+#ifdef CONFIG_NETLABEL
+void netlbl_socket_inet_accept(struct socket *sock, struct socket *newsock);
+#else
+static inline void netlbl_socket_inet_accept(struct socket *sock,
+					     struct socket *newsock)
+{
+	return;
+}
+#endif /* CONFIG_NETLABEL */
+
+#endif /* _NETLABEL_H */
Index: linux-2.6.18-rc1/net/ipv4/af_inet.c
===================================================================
--- linux-2.6.18-rc1.orig/net/ipv4/af_inet.c
+++ linux-2.6.18-rc1/net/ipv4/af_inet.c
@@ -115,6 +115,7 @@
 #ifdef CONFIG_IP_MROUTE
 #include <linux/mroute.h>
 #endif
+#include <net/netlabel.h>
 
 DEFINE_SNMP_STAT(struct linux_mib, net_statistics) __read_mostly;
 
@@ -617,6 +618,8 @@ int inet_accept(struct socket *sock, str
 
 	sock_graft(sk2, newsock);
 
+	netlbl_socket_inet_accept(sock, newsock);
+
 	newsock->state = SS_CONNECTED;
 	err = 0;
 	release_sock(sk2);
Index: linux-2.6.18-rc1/net/ipv4/ah4.c
===================================================================
--- linux-2.6.18-rc1.orig/net/ipv4/ah4.c
+++ linux-2.6.18-rc1/net/ipv4/ah4.c
@@ -34,7 +34,7 @@ static int ip_clear_mutable_options(stru
 		switch (*optptr) {
 		case IPOPT_SEC:
 		case 0x85:	/* Some "Extended Security" crap. */
-		case 0x86:	/* Another "Commercial Security" crap. */
+		case IPOPT_CIPSO:
 		case IPOPT_RA:
 		case 0x80|21:	/* RFC1770 */
 			break;
Index: linux-2.6.18-rc1/net/ipv4/ip_options.c
===================================================================
--- linux-2.6.18-rc1.orig/net/ipv4/ip_options.c
+++ linux-2.6.18-rc1/net/ipv4/ip_options.c
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
@@ -435,6 +443,17 @@ int ip_options_compile(struct ip_options
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
