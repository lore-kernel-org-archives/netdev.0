From: paul.moore@hp.com
Subject: [RFC 5/7] NetLabel: SELinux support
Date: Wed, 21 Jun 2006 15:42:40 -0400
Message-ID: <20060621200033.140169000@flek.zko.hp.com>
References: <20060621194234.979661000@flek.zko.hp.com>
Cc: jmorris@redhat.com, sgrubb@redhat.com, sds@epoch.ncsc.mil
Return-path: <redhat-lspp-bounces@redhat.com>
To: redhat-lspp@redhat.com, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
Content-Disposition: inline; filename=netlabel-selinux-2.6.17
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/redhat-lspp>,
	<mailto:redhat-lspp-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/redhat-lspp>
List-Post: <mailto:redhat-lspp@redhat.com>
List-Help: <mailto:redhat-lspp-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/redhat-lspp>,
	<mailto:redhat-lspp-request@redhat.com?subject=subscribe>
Sender: redhat-lspp-bounces@redhat.com
Errors-To: redhat-lspp-bounces@redhat.com
List-Id: netdev.vger.kernel.org

Add NetLabel support to the SELinux LSM.  The most significant part of this
patch is the addition of NetLabel hooks into the following SELinux LSM hooks:

 * selinux_file_permission()
 * selinux_socket_sendmsg()
 * selinux_socket_post_create()
 * selinux_socket_post_accept() [NEW]
 * selinux_socket_sock_rcv_skb()
 * selinux_socket_getpeersec_stream()
 * selinux_socket_getpeersec_dgram()

The basic reasoning behind this patch is that outgoing packets are "NetLabel'd"
by labeling their socket and the NetLabel security attributes are checked via
the additional hook in selinux_socket_sock_rcv_skb().  NetLabel itself is only
a labeling mechanism, similar to filesystem extended attributes, it is up to
the SELinux enforcement mechanism to perform the actual access checks.

In addition to the changes outlined above this patch also includes some changes
to the extended bitmap (ebitmap) and multi-level security (mls) code to import
and export SELinux TE/MLS attributes into and out of NetLabel.
---
 security/selinux/hooks.c                     |   59 ++
 security/selinux/include/av_inherit.h        |    1 
 security/selinux/include/av_perm_to_string.h |    1 
 security/selinux/include/av_permissions.h    |    1 
 security/selinux/include/flask.h             |    1 
 security/selinux/include/objsec.h            |   11 
 security/selinux/include/security.h          |    2 
 security/selinux/include/selinux_netlabel.h  |   94 ++++
 security/selinux/nlmsgtab.c                  |   15 
 security/selinux/ss/Makefile                 |    3 
 security/selinux/ss/ebitmap.c                |  155 +++++++
 security/selinux/ss/ebitmap.h                |    6 
 security/selinux/ss/mls.c                    |  160 +++++++
 security/selinux/ss/mls.h                    |   25 +
 security/selinux/ss/selinux_netlabel.c       |  574 +++++++++++++++++++++++++++
 security/selinux/ss/services.c               |   12 
 security/selinux/ss/services.h               |    2 
 17 files changed, 1109 insertions(+), 13 deletions(-)

Index: linux-2.6.17.i686-quilt/security/selinux/hooks.c
===================================================================
--- linux-2.6.17.i686-quilt.orig/security/selinux/hooks.c
+++ linux-2.6.17.i686-quilt/security/selinux/hooks.c
@@ -12,6 +12,8 @@
  *  Copyright (C) 2003 Red Hat, Inc., James Morris <jmorris@redhat.com>
  *  Copyright (C) 2004-2005 Trusted Computer Solutions, Inc.
  *                          <dgoeddel@trustedcs.com>
+ *  Copyright (C) 2006 Hewlett-Packard Development Company, L.P.
+ *                     Paul Moore, <paul.moore@hp.com>
  *
  *	This program is free software; you can redistribute it and/or modify
  *	it under the terms of the GNU General Public License version 2,
@@ -74,6 +76,7 @@
 #include "objsec.h"
 #include "netif.h"
 #include "xfrm.h"
+#include "selinux_netlabel.h"
 
 #define XATTR_SELINUX_SUFFIX "selinux"
 #define XATTR_NAME_SELINUX XATTR_SECURITY_PREFIX XATTR_SELINUX_SUFFIX
@@ -2293,6 +2296,7 @@ static int selinux_inode_listsecurity(st
 
 static int selinux_file_permission(struct file *file, int mask)
 {
+	int rc;
 	struct inode *inode = file->f_dentry->d_inode;
 
 	if (!mask) {
@@ -2304,8 +2308,12 @@ static int selinux_file_permission(struc
 	if ((file->f_flags & O_APPEND) && (mask & MAY_WRITE))
 		mask |= MAY_APPEND;
 
-	return file_has_perm(current, file,
-			     file_mask_to_av(inode->i_mode, mask));
+	rc = file_has_perm(current, file,
+			   file_mask_to_av(inode->i_mode, mask));
+	if (rc)
+		return rc;
+
+	return selinux_netlbl_inode_permission(inode, mask);
 }
 
 static int selinux_file_alloc_security(struct file *file)
@@ -2922,8 +2930,8 @@ out:
 	return err;
 }
 
-static void selinux_socket_post_create(struct socket *sock, int family,
-				       int type, int protocol, int kern)
+static int selinux_socket_post_create(struct socket *sock, int family,
+				      int type, int protocol, int kern)
 {
 	struct inode_security_struct *isec;
 	struct task_security_struct *tsec;
@@ -2935,7 +2943,7 @@ static void selinux_socket_post_create(s
 	isec->sid = kern ? SECINITSID_KERNEL : tsec->sid;
 	isec->initialized = 1;
 
-	return;
+	return selinux_netlbl_socket_create(sock, family, isec->sid);
 }
 
 /* Range of port numbers used to automatically bind.
@@ -3113,10 +3121,24 @@ static int selinux_socket_accept(struct 
 	return 0;
 }
 
+#ifdef CONFIG_NETLABEL
+static void selinux_socket_post_accept(struct socket *sock,
+				       struct socket *newsock)
+{
+	selinux_netlbl_socket_accept(sock, newsock);
+}
+#endif /* CONFIG_NETLABEL */
+
 static int selinux_socket_sendmsg(struct socket *sock, struct msghdr *msg,
  				  int size)
 {
-	return socket_has_perm(current, sock, SOCKET__WRITE);
+	int rc;
+
+	rc = socket_has_perm(current, sock, SOCKET__WRITE);
+	if (rc)
+		return rc;
+
+	return selinux_netlbl_inode_permission(SOCK_INODE(sock), MAY_WRITE);
 }
 
 static int selinux_socket_recvmsg(struct socket *sock, struct msghdr *msg,
@@ -3306,10 +3328,15 @@ static int selinux_socket_sock_rcv_skb(s
 
 		err = avc_has_perm(sock_sid, port_sid,
 				   sock_class, recv_perm, &ad);
+		if (err)
+			goto out;
 	}
 
-	if (!err)
-		err = selinux_xfrm_sock_rcv_skb(sock_sid, skb);
+	err = selinux_netlbl_sock_rcv_skb(sock_class, sock_sid, skb, &ad);
+	if (err)
+		goto out;
+
+	err = selinux_xfrm_sock_rcv_skb(sock_sid, skb);
 
 out:	
 	return err;
@@ -3333,8 +3360,9 @@ static int selinux_socket_getpeersec_str
 		peer_sid = ssec->peer_sid;
 	}
 	else if (isec->sclass == SECCLASS_TCP_SOCKET) {
-		peer_sid = selinux_socket_getpeer_stream(sock->sk);
-
+		err = selinux_netlbl_socket_getpeersec_stream(sock, &peer_sid);
+		if (err || peer_sid == SECSID_NULL)
+			peer_sid = selinux_socket_getpeer_stream(sock->sk);
 		if (peer_sid == SECSID_NULL) {
 			err = -ENOPROTOOPT;
 			goto out;
@@ -3369,8 +3397,12 @@ out:	
 
 static int selinux_socket_getpeersec_dgram(struct sk_buff *skb, char **secdata, u32 *seclen)
 {
-	int err = 0;
-	u32 peer_sid = selinux_socket_getpeer_dgram(skb);
+	int err;
+	u32 peer_sid;
+
+	err = selinux_netlbl_socket_getpeersec_dgram(skb, &peer_sid);
+	if (err || peer_sid == SECSID_NULL)
+		peer_sid = selinux_socket_getpeer_dgram(skb);
 
 	if (peer_sid == SECSID_NULL)
 		return -EINVAL;
@@ -4353,6 +4385,9 @@ static struct security_operations selinu
 	.socket_connect =		selinux_socket_connect,
 	.socket_listen =		selinux_socket_listen,
 	.socket_accept =		selinux_socket_accept,
+#ifdef CONFIG_NETLABEL
+	.socket_post_accept =		selinux_socket_post_accept,
+#endif
 	.socket_sendmsg =		selinux_socket_sendmsg,
 	.socket_recvmsg =		selinux_socket_recvmsg,
 	.socket_getsockname =		selinux_socket_getsockname,
Index: linux-2.6.17.i686-quilt/security/selinux/include/av_inherit.h
===================================================================
--- linux-2.6.17.i686-quilt.orig/security/selinux/include/av_inherit.h
+++ linux-2.6.17.i686-quilt/security/selinux/include/av_inherit.h
@@ -29,3 +29,4 @@
    S_(SECCLASS_NETLINK_IP6FW_SOCKET, socket, 0x00400000UL)
    S_(SECCLASS_NETLINK_DNRT_SOCKET, socket, 0x00400000UL)
    S_(SECCLASS_NETLINK_KOBJECT_UEVENT_SOCKET, socket, 0x00400000UL)
+   S_(SECCLASS_NETLINK_NETLABEL_SOCKET, socket, 0x00400000UL)
Index: linux-2.6.17.i686-quilt/security/selinux/include/av_perm_to_string.h
===================================================================
--- linux-2.6.17.i686-quilt.orig/security/selinux/include/av_perm_to_string.h
+++ linux-2.6.17.i686-quilt/security/selinux/include/av_perm_to_string.h
@@ -239,3 +239,4 @@
    S_(SECCLASS_ASSOCIATION, ASSOCIATION__SENDTO, "sendto")
    S_(SECCLASS_ASSOCIATION, ASSOCIATION__RECVFROM, "recvfrom")
    S_(SECCLASS_ASSOCIATION, ASSOCIATION__SETCONTEXT, "setcontext")
+   S_(SECCLASS_NETLINK_NETLABEL_SOCKET, NETLINK_NETLABEL_SOCKET__NLMSG_WRITE, "nlmsg_write")
Index: linux-2.6.17.i686-quilt/security/selinux/include/av_permissions.h
===================================================================
--- linux-2.6.17.i686-quilt.orig/security/selinux/include/av_permissions.h
+++ linux-2.6.17.i686-quilt/security/selinux/include/av_permissions.h
@@ -933,3 +933,4 @@
 #define NETLINK_KOBJECT_UEVENT_SOCKET__SEND_MSG   0x00100000UL
 #define NETLINK_KOBJECT_UEVENT_SOCKET__NAME_BIND  0x00200000UL
 
+#define NETLINK_NETLABEL_SOCKET__NLMSG_WRITE      0x00000001UL
Index: linux-2.6.17.i686-quilt/security/selinux/include/flask.h
===================================================================
--- linux-2.6.17.i686-quilt.orig/security/selinux/include/flask.h
+++ linux-2.6.17.i686-quilt/security/selinux/include/flask.h
@@ -60,6 +60,7 @@
 #define SECCLASS_NSCD                                    53
 #define SECCLASS_ASSOCIATION                             54
 #define SECCLASS_NETLINK_KOBJECT_UEVENT_SOCKET           55
+#define SECCLASS_NETLINK_NETLABEL_SOCKET                 56
 
 /*
  * Security identifier indices for initial entities
Index: linux-2.6.17.i686-quilt/security/selinux/include/objsec.h
===================================================================
--- linux-2.6.17.i686-quilt.orig/security/selinux/include/objsec.h
+++ linux-2.6.17.i686-quilt/security/selinux/include/objsec.h
@@ -35,6 +35,14 @@ struct task_security_struct {
 	u32 ptrace_sid;      /* SID of ptrace parent */
 };
 
+struct netlbl_security_struct {
+	u32 netlbl_sid;           /* SID used to set the NetLabel */
+	u32 peer_sid;             /* SID of the connected peer */
+	u32 req_netlbl:1,         /* socket requires a NetLabel label */
+	    labeled:1,            /* socket is labeled with NetLabel */
+	    __unused:30;
+};
+
 struct inode_security_struct {
         struct inode *inode;           /* back pointer to inode object */
 	struct list_head list;         /* list of inode_security_struct */
@@ -44,6 +52,9 @@ struct inode_security_struct {
 	unsigned char initialized;     /* initialization flag */
 	struct semaphore sem;
 	unsigned char inherit;         /* inherit SID from parent entry */
+#ifdef CONFIG_NETLABEL
+	struct netlbl_security_struct netlbl;
+#endif
 };
 
 struct file_security_struct {
Index: linux-2.6.17.i686-quilt/security/selinux/include/security.h
===================================================================
--- linux-2.6.17.i686-quilt.orig/security/selinux/include/security.h
+++ linux-2.6.17.i686-quilt/security/selinux/include/security.h
@@ -8,6 +8,8 @@
 #ifndef _SELINUX_SECURITY_H_
 #define _SELINUX_SECURITY_H_
 
+#include <linux/skbuff.h>
+
 #include "flask.h"
 
 #define SECSID_NULL			0x00000000 /* unspecified SID */
Index: linux-2.6.17.i686-quilt/security/selinux/include/selinux_netlabel.h
===================================================================
--- /dev/null
+++ linux-2.6.17.i686-quilt/security/selinux/include/selinux_netlabel.h
@@ -0,0 +1,94 @@
+/*
+ * SELinux interface to the NetLabel subsystem
+ *
+ * Author : Paul Moore <paul.moore@hp.com>
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
+#ifndef _SELINUX_NETLABEL_H_
+#define _SELINUX_NETLABEL_H_
+
+#ifdef CONFIG_NETLABEL
+void selinux_netlbl_cache_invalidate(void);
+
+int selinux_netlbl_inode_permission(struct inode *inode, int mask);
+
+int selinux_netlbl_socket_create(struct socket *sock,
+				 const int sock_family,
+				 u32 sid);
+void selinux_netlbl_socket_accept(struct socket *sock, struct socket *newsock);
+int selinux_netlbl_sock_rcv_skb(const u16 sock_class,
+				const u32 sock_sid,
+				struct sk_buff *skb,
+				struct avc_audit_data *ad);
+int selinux_netlbl_socket_getpeersec_stream(struct socket *sock,
+					    u32 *peer_sid);
+int selinux_netlbl_socket_getpeersec_dgram(struct sk_buff *skb, u32 *peer_sid);
+#else
+static inline void selinux_netlbl_cache_invalidate(void)
+{
+	return;
+}
+
+static inline int selinux_netlbl_inode_permission(struct inode *inode,
+						  int mask)
+{
+	return 0;
+}
+
+static inline int selinux_netlbl_socket_create(struct socket *sock,
+					       const int sock_family,
+					       u32 sid)
+{
+	return 0;
+}
+
+static inline void selinux_netlbl_socket_accept(struct socket *sock,
+						struct socket *newsock)
+{
+	return;
+}
+
+static inline int selinux_netlbl_sock_rcv_skb(const u16 sock_class,
+					      const u32 sock_sid,
+					      struct sk_buff *skb,
+					      struct avc_audit_data *ad)
+{
+	return 0;
+}
+
+static inline int selinux_netlbl_socket_getpeersec_stream(struct socket *sock,
+							  u32 *peer_sid)
+{
+	*peer_sid = SECSID_NULL;
+	return 0;
+}
+
+static inline int selinux_netlbl_socket_getpeersec_dgram(struct sk_buff *skb,
+							 u32 *peer_sid)
+{
+	*peer_sid = SECSID_NULL;
+	return 0;
+}
+#endif /* CONFIG_NETLABEL */
+
+#endif
Index: linux-2.6.17.i686-quilt/security/selinux/nlmsgtab.c
===================================================================
--- linux-2.6.17.i686-quilt.orig/security/selinux/nlmsgtab.c
+++ linux-2.6.17.i686-quilt/security/selinux/nlmsgtab.c
@@ -19,6 +19,7 @@
 #include <linux/inet_diag.h>
 #include <linux/xfrm.h>
 #include <linux/audit.h>
+#include <net/netlabel.h>
 
 #include "flask.h"
 #include "av_permissions.h"
@@ -116,6 +117,15 @@ static struct nlmsg_perm nlmsg_audit_per
 	{ AUDIT_WATCH_LIST,	NETLINK_AUDIT_SOCKET__NLMSG_READPRIV },
 };
 
+static struct nlmsg_perm nlmsg_netlabel_perms[] =
+{
+	{ NETLBL_NLTYPE_NONE,        NETLINK_NETLABEL_SOCKET__NLMSG_WRITE },
+	{ NETLBL_NLTYPE_MGMT,        NETLINK_NETLABEL_SOCKET__NLMSG_WRITE },
+	{ NETLBL_NLTYPE_RIPSO,       NETLINK_NETLABEL_SOCKET__NLMSG_WRITE },
+	{ NETLBL_NLTYPE_CIPSOV4,     NETLINK_NETLABEL_SOCKET__NLMSG_WRITE },
+	{ NETLBL_NLTYPE_CIPSOV6,     NETLINK_NETLABEL_SOCKET__NLMSG_WRITE },
+	{ NETLBL_NLTYPE_UNLABELED,   NETLINK_NETLABEL_SOCKET__NLMSG_WRITE },
+};
 
 static int nlmsg_perm(u16 nlmsg_type, u32 *perm, struct nlmsg_perm *tab, size_t tabsize)
 {
@@ -169,6 +179,11 @@ int selinux_nlmsg_lookup(u16 sclass, u16
 		}
 		break;
 
+	case SECCLASS_NETLINK_NETLABEL_SOCKET:
+		err = nlmsg_perm(nlmsg_type, perm, nlmsg_netlabel_perms,
+				 sizeof(nlmsg_netlabel_perms));
+		break;
+
 	/* No messaging from userspace, or class unknown/unhandled */
 	default:
 		err = -ENOENT;
Index: linux-2.6.17.i686-quilt/security/selinux/ss/Makefile
===================================================================
--- linux-2.6.17.i686-quilt.orig/security/selinux/ss/Makefile
+++ linux-2.6.17.i686-quilt/security/selinux/ss/Makefile
@@ -7,3 +7,6 @@ obj-y := ss.o
 
 ss-y := ebitmap.o hashtab.o symtab.o sidtab.o avtab.o policydb.o services.o conditional.o mls.o
 
+ifeq ($(CONFIG_NETLABEL),y)
+obj-y += selinux_netlabel.o
+endif
Index: linux-2.6.17.i686-quilt/security/selinux/ss/ebitmap.c
===================================================================
--- linux-2.6.17.i686-quilt.orig/security/selinux/ss/ebitmap.c
+++ linux-2.6.17.i686-quilt/security/selinux/ss/ebitmap.c
@@ -3,6 +3,14 @@
  *
  * Author : Stephen Smalley, <sds@epoch.ncsc.mil>
  */
+/*
+ * Updated: Hewlett-Packard <paul.moore@hp.com>
+ *
+ *      Added ebitmap_export() and ebitmap_import()
+ *
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ */
+
 #include <linux/kernel.h>
 #include <linux/slab.h>
 #include <linux/errno.h>
@@ -59,6 +67,153 @@ int ebitmap_cpy(struct ebitmap *dst, str
 	return 0;
 }
 
+/**
+ * ebitmap_export - Export an ebitmap to a unsigned char bitmap string
+ * @src: the ebitmap to export
+ * @dst: the resulting bitmap string
+ * @dst_len: length of dst in bytes
+ *
+ * Description:
+ * Allocate a buffer at least src->highbit bits long and export the extensible
+ * bitmap into the buffer.  The bitmap string will be in little endian format,
+ * i.e. LSB first.  The value returned in dst_len may not the true size of the
+ * buffer as the length of the buffer is rounded up to a multiple of MAPTYPE.
+ * The caller must free the buffer when finished. Returns zero on success,
+ * negative values on failure.
+ *
+ */
+int ebitmap_export(const struct ebitmap *src,
+		   unsigned char **dst,
+		   u32 *dst_len)
+{
+	u32 bitmap_len;
+	unsigned char *bitmap;
+	struct ebitmap_node *iter_node;
+	MAPTYPE node_val;
+	u32 bitmap_byte;
+	unsigned char bitmask;
+
+	if (src == NULL || dst == NULL || dst_len == NULL)
+		return -EINVAL;
+
+	*dst = NULL;
+	*dst_len = 0;
+
+	bitmap_len = src->highbit / 8;
+	if (src->highbit % 8 > 0)
+		bitmap_len += 1;
+	if (bitmap_len == 0)
+		return -EINVAL;
+
+	bitmap = kzalloc(bitmap_len + sizeof(MAPTYPE) -
+			 (bitmap_len % sizeof(MAPTYPE)),
+			 GFP_ATOMIC);
+	if (bitmap == NULL)
+		return -ENOMEM;
+
+	/* PM - there _has_ to be a faster way to do this, work on this more */
+	iter_node = src->node;
+	do {
+		bitmap_byte = iter_node->startbit / 8;
+		bitmask = 0x80;
+		node_val = iter_node->map;
+		do {
+			if (bitmask == 0) {
+				bitmap_byte++;
+				bitmask = 0x80;
+			}
+			if (node_val & (MAPTYPE)0x01)
+				bitmap[bitmap_byte] |= bitmask;
+			node_val >>= 1;
+			bitmask >>= 1;
+		} while (node_val > 0);
+		iter_node = iter_node->next;
+	} while (iter_node);
+
+	*dst = bitmap;
+	*dst_len = bitmap_len;
+	return 0;
+}
+
+/**
+ * ebitmap_import - Import an unsigned char bitmap string into an ebitmap
+ * @src: the bitmap string
+ * @src_len: the bitmap length in bytes
+ * @dst: the empty ebitmap
+ *
+ * Description:
+ * This function takes a little endian bitmap string in src and imports it into
+ * the ebitmap pointed to by dst.  Returns zero on success, negative values on
+ * failure.
+ *
+ */
+int ebitmap_import(const unsigned char *src,
+		   const u32 src_len,
+		   struct ebitmap *dst)
+{
+	u32 src_off = 0;
+	struct ebitmap_node *node_new;
+	struct ebitmap_node *node_last = NULL;
+	u32 src_rem = src_len;
+	MAPTYPE tmp_val;
+	u32 iter;
+	u32 iter_bit;
+	unsigned char src_byte;
+
+	if (src == NULL || dst == NULL || src_len == 0)
+		return -EINVAL;
+
+	do {
+		node_new = kzalloc(sizeof(*node_new), GFP_ATOMIC);
+		if (node_new == NULL) {
+			ebitmap_destroy(dst);
+			return -ENOMEM;
+		}
+
+		/* PM - there _has_ to be a faster way to do this,
+		   work on this more */
+		if (src_rem >= sizeof(MAPTYPE))
+			iter = sizeof(MAPTYPE);
+		else
+			iter = src_rem;
+		tmp_val = 0;
+		while (iter > 0) {
+			src_byte = src[src_off + --iter];
+			if (src_byte > 0)
+				for (iter_bit = 0; iter_bit < 8; iter_bit++) {
+					tmp_val <<= 1;
+					tmp_val |= src_byte & 0x01;
+					src_byte >>= 1;
+				}
+			else
+				tmp_val <<= 8;
+		}
+		node_new->map = tmp_val;
+		node_new->startbit = src_off * 8;
+
+		if (node_last != NULL)
+			node_last->next = node_new;
+		else
+			dst->node = node_new;
+		node_last = node_new;
+
+		if (src_rem >= sizeof(MAPTYPE)) {
+			src_off += sizeof(MAPTYPE);
+			src_rem -= sizeof(MAPTYPE);
+		} else
+			src_off += src_rem;
+	} while (src_off < src_len);
+
+	tmp_val = node_last->map;
+	dst->highbit = node_last->startbit;
+	while (tmp_val >= 1) {
+		dst->highbit += 1;
+		tmp_val >>= 1;
+	}
+
+	return 0;
+}
+
 int ebitmap_contains(struct ebitmap *e1, struct ebitmap *e2)
 {
 	struct ebitmap_node *n1, *n2;
Index: linux-2.6.17.i686-quilt/security/selinux/ss/ebitmap.h
===================================================================
--- linux-2.6.17.i686-quilt.orig/security/selinux/ss/ebitmap.h
+++ linux-2.6.17.i686-quilt/security/selinux/ss/ebitmap.h
@@ -69,6 +69,12 @@ static inline int ebitmap_node_get_bit(s
 
 int ebitmap_cmp(struct ebitmap *e1, struct ebitmap *e2);
 int ebitmap_cpy(struct ebitmap *dst, struct ebitmap *src);
+int ebitmap_export(const struct ebitmap *src,
+		   unsigned char **dst,
+		   u32 *dst_len);
+int ebitmap_import(const unsigned char *src,
+		   const u32 src_len,
+		   struct ebitmap *dst);
 int ebitmap_contains(struct ebitmap *e1, struct ebitmap *e2);
 int ebitmap_get_bit(struct ebitmap *e, unsigned long bit);
 int ebitmap_set_bit(struct ebitmap *e, unsigned long bit, int value);
Index: linux-2.6.17.i686-quilt/security/selinux/ss/mls.c
===================================================================
--- linux-2.6.17.i686-quilt.orig/security/selinux/ss/mls.c
+++ linux-2.6.17.i686-quilt/security/selinux/ss/mls.c
@@ -10,6 +10,13 @@
  *
  * Copyright (C) 2004-2006 Trusted Computer Solutions, Inc.
  */
+/*
+ * Updated: Hewlett-Packard <paul.moore@hp.com>
+ *
+ *      Added support to import/export the MLS label
+ *
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ */
 
 #include <linux/kernel.h>
 #include <linux/slab.h>
@@ -585,3 +592,156 @@ int mls_compute_sid(struct context *scon
 	return -EINVAL;
 }
 
+/**
+ * mls_export_lvl - Export the MLS sensitivity levels
+ * @context: the security context
+ * @lvl_low: the low sensitivity level
+ * @lvl_high: the high sensitivity level
+ *
+ * Description:
+ * Given the security context copy the low MLS sensitivity level into lvl_low
+ * and the high sensitivity level in lvl_high.  The MLS levels are only
+ * exported if the pointers are not NULL, if they are NULL then that level is
+ * not exported.  Returns zero on success, negative values on failure.
+ *
+ */
+int mls_export_lvl(const struct context *context, u32 *lvl_low, u32 *lvl_high)
+{
+	if (!selinux_mls_enabled)
+		return 0;
+
+	if (lvl_low != NULL)
+		*lvl_low = context->range.level[0].sens - 1;
+	if (lvl_high != NULL)
+		*lvl_high = context->range.level[1].sens - 1;
+
+	return 0;
+}
+
+/**
+ * mls_import_lvl - Import the MLS sensitivity levels
+ * @context: the security context
+ * @lvl_low: the low sensitivity level
+ * @lvl_high: the high sensitivity level
+ *
+ * Description:
+ * Given the security context and the two sensitivty levels, set the MLS levels
+ * in the context according the two given as parameters.  Returns zero on
+ * success, negative values on failure.
+ *
+ */
+int mls_import_lvl(struct context *context,
+		   const u32 lvl_low,
+		   const u32 lvl_high)
+{
+	if (!selinux_mls_enabled)
+		return 0;
+
+	context->range.level[0].sens = lvl_low + 1;
+	context->range.level[1].sens = lvl_high + 1;
+
+	return 0;
+}
+
+/**
+ * mls_export_cat - Export the MLS categories
+ * @context: the security context
+ * @cat_low: the low category
+ * @cat_low_len: length of the cat_low bitmap in bytes
+ * @cat_high: the high category
+ * @cat_high_len: length of the cat_high bitmap in bytes
+ *
+ * Description:
+ * Given the security context export the low MLS category bitmap into cat_low
+ * and the high category bitmap into cat_high.  The MLS categories are only
+ * exported if the pointers are not NULL, if they are NULL then that level is
+ * not exported.  The caller is responsibile for freeing the memory when
+ * finished.  Returns zero on success, negative values on failure.
+ *
+ */
+int mls_export_cat(const struct context *context,
+		   unsigned char **cat_low,
+		   u32 *cat_low_len,
+		   unsigned char **cat_high,
+		   u32 *cat_high_len)
+{
+	int ret_val = -EPERM;
+
+	if (!selinux_mls_enabled)
+		return 0;
+
+	if (cat_low != NULL && cat_low_len != NULL) {
+		ret_val = ebitmap_export(&context->range.level[0].cat,
+					 cat_low,
+					 cat_low_len);
+		if (ret_val != 0)
+			goto export_cat_failure;
+	}
+	if (cat_high != NULL && cat_high_len != NULL) {
+		ret_val = ebitmap_export(&context->range.level[1].cat,
+					 cat_high,
+					 cat_high_len);
+		if (ret_val != 0)
+			goto export_cat_failure;
+	}
+
+	return 0;
+
+export_cat_failure:
+	if (cat_low != NULL && *cat_low != NULL)
+		kfree(*cat_low);
+	if (cat_high != NULL && *cat_high != NULL)
+		kfree(*cat_high);
+	return ret_val;
+}
+
+/**
+ * mls_import_cat - Import the MLS categories
+ * @context: the security context
+ * @cat_low: the low category
+ * @cat_low_len: length of the cat_low bitmap in bytes
+ * @cat_high: the high category
+ * @cat_high_len: length of the cat_high bitmap in bytes
+ *
+ * Description:
+ * Given the security context and the two category bitmap strings import the
+ * categories into the security context.  The MLS categories are only imported
+ * if the pointers are not NULL, if they are NULL they are skipped.  Returns
+ * zero on success, negative values on failure.
+ *
+ */
+int mls_import_cat(struct context *context,
+		   const unsigned char *cat_low,
+		   const u32 cat_low_len,
+		   const unsigned char *cat_high,
+		   const u32 cat_high_len)
+{
+	int ret_val = -EPERM;
+
+	if (!selinux_mls_enabled)
+		return 0;
+
+	if (cat_low != NULL && cat_low_len > 0) {
+		ret_val = ebitmap_import(cat_low,
+					 cat_low_len,
+					 &context->range.level[0].cat);
+		if (ret_val != 0)
+			goto import_cat_failure;
+	}
+	if (cat_high != NULL && cat_high_len > 0) {
+		ret_val = ebitmap_import(cat_high,
+					 cat_high_len,
+					 &context->range.level[1].cat);
+		if (ret_val != 0)
+			goto import_cat_failure;
+	}
+
+	return 0;
+
+import_cat_failure:
+	if (cat_low)
+		ebitmap_destroy(&context->range.level[0].cat);
+	if (cat_high)
+		ebitmap_destroy(&context->range.level[1].cat);
+	return ret_val;
+}
Index: linux-2.6.17.i686-quilt/security/selinux/ss/mls.h
===================================================================
--- linux-2.6.17.i686-quilt.orig/security/selinux/ss/mls.h
+++ linux-2.6.17.i686-quilt/security/selinux/ss/mls.h
@@ -10,6 +10,13 @@
  *
  * Copyright (C) 2004-2006 Trusted Computer Solutions, Inc.
  */
+/*
+ * Updated: Hewlett-Packard <paul.moore@hp.com>
+ *
+ *      Added support to import/export the MLS label
+ *
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ */
 
 #ifndef _SS_MLS_H_
 #define _SS_MLS_H_
@@ -42,5 +49,23 @@ int mls_compute_sid(struct context *scon
 int mls_setup_user_range(struct context *fromcon, struct user_datum *user,
                          struct context *usercon);
 
+int mls_export_lvl(const struct context *context,
+		   u32 *lvl_low,
+		   u32 *lvl_high);
+int mls_import_lvl(struct context *context,
+		   const u32 lvl_low,
+		   const u32 lvl_high);
+
+int mls_export_cat(const struct context *context,
+                   unsigned char **cat_low,
+                   u32 *cat_low_len,
+                   unsigned char **cat_high,
+                   u32 *cat_high_len);
+int mls_import_cat(struct context *context,
+                   const unsigned char *cat_low,
+                   const u32 cat_low_len,
+                   const unsigned char *cat_high,
+                   const u32 cat_high_len);
+
 #endif	/* _SS_MLS_H */
 
Index: linux-2.6.17.i686-quilt/security/selinux/ss/selinux_netlabel.c
===================================================================
--- /dev/null
+++ linux-2.6.17.i686-quilt/security/selinux/ss/selinux_netlabel.c
@@ -0,0 +1,574 @@
+/*
+ * SELinux interface to the NetLabel subsystem
+ *
+ * Author : Paul Moore <paul.moore@hp.com>
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
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/audit.h>
+#include <net/sock.h>
+#include <net/netlabel.h>
+
+#include "avc.h"
+#include "context.h"
+#include "sidtab.h"
+#include "services.h"
+#include "mls.h"
+#include "objsec.h"
+
+/*
+ * This is the structure we store inside the NetLabel cache block.
+ */
+#define NETLBL_CACHE(x)           ((struct netlbl_cache *)(x))
+#define NETLBL_CACHE_T_NONE       0
+#define NETLBL_CACHE_T_SID        1
+#define NETLBL_CACHE_T_MLSLBL     2
+struct netlbl_cache {
+	u32 type;
+	union {
+		u32 sid;
+		struct mls_level mls_label;
+	} data;
+};
+
+/**
+ * selinux_netlbl_cache_free - Free the NetLabel cached data
+ * @data: the data to free
+ *
+ * Description:
+ * This function is intended to be used as the free() callback inside the
+ * netlbl_lsm_cache structure.
+ *
+ */
+static void selinux_netlbl_cache_free(const void *data)
+{
+	struct netlbl_cache *cache = NETLBL_CACHE(data);
+	switch (cache->type) {
+	case NETLBL_CACHE_T_MLSLBL:
+		ebitmap_destroy(&cache->data.mls_label.cat);
+		break;
+	}
+	kfree(data);
+}
+
+/**
+ * selinux_netlbl_cache_add - Add an entry to the NetLabel cache
+ * @skb: the packet
+ * @ctx: the SELinux context
+ *
+ * Description:
+ * Attempt to cache the context in @ctx, which was derived from the packet in
+ * @skb, in the NetLabel subsystem cache.
+ *
+ */
+static void selinux_netlbl_cache_add(struct sk_buff *skb, struct context *ctx)
+{
+	struct netlbl_cache *cache = NULL;
+	struct netlbl_lsm_secattr secattr;
+
+	netlbl_secattr_init(&secattr);
+
+	cache = kzalloc(sizeof(*cache),	GFP_ATOMIC);
+	if (cache == NULL)
+		goto netlbl_cache_add_return;
+	secattr.cache.free = selinux_netlbl_cache_free;
+	secattr.cache.data = (void *)cache;
+	secattr.set_cache = 1;
+
+	if (ebitmap_cpy(&cache->data.mls_label.cat,
+			&ctx->range.level[0].cat) != 0)
+		goto netlbl_cache_add_return;
+	cache->data.mls_label.sens = ctx->range.level[0].sens;
+	cache->type = NETLBL_CACHE_T_MLSLBL;
+
+	if (netlbl_cache_add(skb, &secattr) != 0)
+		goto netlbl_cache_add_return;
+	secattr.set_cache = 0;
+
+netlbl_cache_add_return:
+	netlbl_secattr_destroy(&secattr);
+}
+
+/**
+ * selinux_netlbl_cache_invalidate - Invalidate the NetLabel cache
+ *
+ * Description:
+ * Invalidate the NetLabel security attribute mapping cache.
+ *
+ */
+void selinux_netlbl_cache_invalidate(void)
+{
+	netlbl_cache_invalidate();
+}
+
+/**
+ * selinux_netlbl_domain_export - Exports the type of a given context
+ * @context: the security context
+ * @scontext: the resulting type string
+ * @scontext_len: the length of scontext including the NULL byte
+ *
+ * Description:
+ * Allocate a buffer for the type name specified in context and copy the type
+ * name into the buffer.  The caller must free the buffer when finished.
+ * Returns zero on success, negative values on failure.
+ *
+ */
+static int selinux_netlbl_domain_export(const struct context *context,
+					char **scontext,
+					u32 *scontext_len)
+{
+	char *str;
+	u32 str_len;
+
+	*scontext = NULL;
+	if (scontext_len != NULL)
+		*scontext_len = 0;
+	str_len = strlen(policydb.p_type_val_to_name[context->type - 1]) + 1;
+	str = kmalloc(str_len, GFP_ATOMIC);
+	if (str == NULL)
+		return -ENOMEM;
+	strcpy(str, policydb.p_type_val_to_name[context->type - 1]);
+
+	*scontext = str;
+	if (scontext_len != NULL)
+		*scontext_len = str_len;
+	return 0;
+}
+
+/**
+ * selinux_netlbl_secattr_to_sid - Convert a NetLabel secattr to a SELinux SID
+ * @skb: the network packet
+ * @secattr: the NetLabel packet security attributes
+ * @base_sid: the SELinux SID to use as a context for MLS only attributes
+ * @sid: the SELinux SID
+ *
+ * Description:
+ * Convert the given NetLabel packet security attributes in @secattr into a
+ * SELinux SID.  If the @secattr field does not contain a full SELinux
+ * SID/context then use the context in @base_sid as the foundation.  If @skb
+ * is not NULL attempt to cache as much data as possibile.  Returns zero on
+ * success, negative values on failure.
+ *
+ */
+static int selinux_netlbl_secattr_to_sid(struct sk_buff *skb,
+					  struct netlbl_lsm_secattr *secattr,
+					  const u32 base_sid,
+					  u32 *sid)
+{
+	int ret_val = -EIDRM;
+	struct context *ctx;
+	struct context ctx_new;
+	struct netlbl_cache *cache;
+	u32 ctx_new_destroy = 0;
+
+	if (secattr->set_cache) {
+		cache = NETLBL_CACHE(secattr->cache.data);
+		switch (cache->type) {
+		case NETLBL_CACHE_T_SID:
+			*sid = cache->data.sid;
+			break;
+		case NETLBL_CACHE_T_MLSLBL:
+			ctx = sidtab_search(&sidtab, base_sid);
+			if (ctx == NULL)
+				goto netlbl_secattr_to_sid_failure;
+			ret_val = context_cpy(&ctx_new, ctx);
+			if (ret_val != 0)
+				goto netlbl_secattr_to_sid_failure;
+			ctx_new_destroy = 1;
+			mls_context_destroy(&ctx_new);
+
+			ctx_new.range.level[0].sens =
+				cache->data.mls_label.sens;
+			ret_val = ebitmap_cpy(&ctx_new.range.level[0].cat,
+					      &cache->data.mls_label.cat);
+			if (ret_val != 0)
+				goto netlbl_secattr_to_sid_failure;
+			ctx_new.range.level[1].sens =
+				cache->data.mls_label.sens;
+			ret_val = ebitmap_cpy(&ctx_new.range.level[1].cat,
+					      &cache->data.mls_label.cat);
+			if (ret_val != 0)
+				goto netlbl_secattr_to_sid_failure;
+
+			ret_val = sidtab_context_to_sid(&sidtab,
+							&ctx_new,
+							sid);
+			break;
+		default:
+			goto netlbl_secattr_to_sid_failure;
+		}
+	} else if (secattr->set_mls_lvl) {
+		ctx = sidtab_search(&sidtab, base_sid);
+		if (ctx == NULL)
+			goto netlbl_secattr_to_sid_failure;
+		ret_val = context_cpy(&ctx_new, ctx);
+		if (ret_val != 0)
+			goto netlbl_secattr_to_sid_failure;
+		ctx_new_destroy = 1;
+		mls_context_destroy(&ctx_new);
+
+		if (mls_import_lvl(&ctx_new,
+				   secattr->mls_lvl,
+				   secattr->mls_lvl) != 0)
+			goto netlbl_secattr_to_sid_failure;
+		if (secattr->set_mls_cat) {
+			if (mls_import_cat(&ctx_new,
+					   secattr->mls_cat,
+					   secattr->mls_cat_len,
+					   secattr->mls_cat,
+					   secattr->mls_cat_len) != 0)
+				goto netlbl_secattr_to_sid_failure;
+		}
+
+		ret_val = mls_context_isvalid(&policydb, &ctx_new);
+		if (ret_val != 1)
+			goto netlbl_secattr_to_sid_failure;
+
+		if (skb != NULL)
+			selinux_netlbl_cache_add(skb, &ctx_new);
+
+		ret_val = sidtab_context_to_sid(&sidtab, &ctx_new, sid);
+	} else
+		*sid = SECINITSID_UNLABELED;
+
+	ret_val = 0;
+
+netlbl_secattr_to_sid_failure:
+	if (ctx_new_destroy)
+		context_destroy(&ctx_new);
+	return ret_val;
+}
+
+/**
+ * selinux_netlbl_skbuff_getsid - Get the sid of a packet using NetLabel
+ * @skb: the packet
+ * @base_sid: the SELinux SID to use as a context for MLS only attributes
+ * @sid: the SID
+ *
+ * Description:
+ * Call the NetLabel mechanism to get the security attributes of the given
+ * packet and use those attributes to determine the correct context/SID to
+ * assign to the packet.  Returns zero on success, negative values on failure.
+ *
+ */
+static int selinux_netlbl_skbuff_getsid(struct sk_buff *skb,
+					const u32 base_sid,
+					u32 *sid)
+{
+	int ret_val;
+	struct netlbl_lsm_secattr secattr;
+
+	netlbl_secattr_init(&secattr);
+	ret_val = netlbl_skbuff_getattr(skb, &secattr);
+	if (ret_val == 0)
+		ret_val = selinux_netlbl_secattr_to_sid(skb,
+							 &secattr,
+							 base_sid,
+							 sid);
+
+	secattr.set_cache = 0;
+	netlbl_secattr_destroy(&secattr);
+
+	return ret_val;
+}
+
+/**
+ * selinux_netlbl_socket_setsid - Label a socket using the NetLabel mechanism
+ * @sock: the socket to label
+ * @sock_family: the socket family
+ * @sid: the SID to use
+ *
+ * Description:
+ * Attempt to label a socket using the NetLabel mechanism using the given
+ * SID.  Returns zero values on success, negative values on failure.
+ *
+ */
+static int selinux_netlbl_socket_setsid(struct socket *sock,
+					const int sock_family,
+					u32 sid)
+{
+	int ret_val;
+	struct inode_security_struct *isec = SOCK_INODE(sock)->i_security;
+	struct netlbl_lsm_secattr secattr;
+	struct context *ctx;
+
+	ctx = sidtab_search(&sidtab, sid);
+	if (ctx != NULL) {
+		netlbl_secattr_init(&secattr);
+
+		if (selinux_netlbl_domain_export(ctx,
+						 &secattr.domain,
+						 NULL) == 0)
+			secattr.set_domain = 1;
+		if (mls_export_lvl(ctx, &secattr.mls_lvl, NULL) == 0)
+			secattr.set_mls_lvl = 1;
+		if (mls_export_cat(ctx,
+				   &secattr.mls_cat,
+				   &secattr.mls_cat_len,
+				   NULL,
+				   NULL) == 0)
+			secattr.set_mls_cat = 1;
+
+		ret_val = netlbl_socket_setattr(sock, &secattr);
+		if (ret_val == 0) {
+			isec->netlbl.netlbl_sid = sid;
+			isec->netlbl.labeled = 1;
+		}
+
+		netlbl_secattr_destroy(&secattr);
+	} else
+		ret_val = -ENOENT;
+
+	return ret_val;
+}
+
+/**
+ * selinux_netlbl_socket_peeksid - Get the SID of the first queued packet
+ * @sock: the socket to query
+ * @sid: the packet's SID
+ *
+ * Description:
+ * Examine the first incoming packet in the socket's queue and determine the
+ * packet's SELinux SID.  Return zero on success, negative values on failure.
+ *
+ */
+static int selinux_netlbl_socket_peeksid(struct socket *sock, u32 *sid)
+{
+        int ret_val;
+	struct netlbl_lsm_secattr secattr;
+        struct inode_security_struct *isec = SOCK_INODE(sock)->i_security;
+
+        netlbl_secattr_init(&secattr);
+        ret_val = netlbl_socket_peekattr(sock, &secattr);
+        if (ret_val == 0)
+                ret_val = selinux_netlbl_secattr_to_sid(NULL,
+							&secattr,
+							isec->sid,
+							sid);
+
+        secattr.set_cache = 0;
+        netlbl_secattr_destroy(&secattr);
+
+        return ret_val;
+}
+
+/**
+ * selinux_netlbl_socket_create - Label a socket using the NetLabel mechanism
+ * @sock: the socket to label
+ * @sock_family: the socket family
+ * @sid: the SID to use
+ *
+ * Description:
+ * Attempt to label a socket using the NetLabel mechanism using the given
+ * SID.  Returns zero values on success, negative values on failure.
+ *
+ */
+int selinux_netlbl_socket_create(struct socket *sock,
+				 const int sock_family,
+				 u32 sid)
+{
+	struct inode_security_struct *isec;
+
+	if (!ss_initialized || sock_family != PF_INET)
+		return 0;
+
+	isec = SOCK_INODE(sock)->i_security;
+	isec->netlbl.req_netlbl = 1;
+
+	/* PM - should we audit failures, or at the very least do a printk()
+	   so users are not left wondering? */
+	return selinux_netlbl_socket_setsid(sock, sock_family, sid);
+}
+
+/**
+ * selinux_netlbl_socket_accept - Handle the labeling of an accept()ed socket
+ * @sock: the original socket
+ * @newsock: the new accept()ed socket
+ *
+ * Description:
+ * Attempt to label a socket using the NetLabel mechanism based on the packets
+ * in the queue and the original socket's SID.
+ *
+ */
+void selinux_netlbl_socket_accept(struct socket *sock, struct socket *newsock)
+{
+	int ret_val;
+	struct inode_security_struct *newisec;
+	struct netlbl_lsm_secattr secattr;
+
+	if (!ss_initialized ||
+	    newsock->sk == NULL || newsock->sk->sk_family != PF_INET)
+		return;
+
+	newisec = SOCK_INODE(newsock)->i_security;
+	newisec->netlbl.req_netlbl = 1;
+
+	netlbl_secattr_init(&secattr);
+	ret_val = netlbl_socket_getattr(newsock, &secattr);
+	if (ret_val == 0)
+		ret_val = selinux_netlbl_secattr_to_sid(NULL,
+						    &secattr,
+						    newisec->sid,
+						    &newisec->netlbl.peer_sid);
+	if (ret_val != 0)
+		newisec->netlbl.peer_sid = SECSID_NULL;
+	secattr.set_cache = 0;
+	netlbl_secattr_destroy(&secattr);
+}
+
+/**
+ * selinux_netlbl_file_permission - Very the file/socket is NetLabel labeled
+ * @inode: the file descriptor's inode
+ * @mask: the permission mask
+ *
+ * Description:
+ * Looks at a file's inode and if it is marked as a socket protected by
+ * NetLabel then verify that the socket has been labeled, if not try to label
+ * the socket now with the task's SID.  Returns zero on success, negative
+ * values on failure.
+ *
+ */
+int selinux_netlbl_inode_permission(struct inode *inode, int mask)
+{
+	int ret_val = 0;
+	struct inode_security_struct *isec = inode->i_security;
+	struct task_security_struct *tsec;
+	struct netlbl_security_struct *netlbl_sec = &isec->netlbl;
+	struct socket *sock;
+
+	if (netlbl_sec->req_netlbl && (mask & (MAY_WRITE | MAY_APPEND))) {
+		tsec = current->security;
+		if (netlbl_sec->labeled == 0) {
+			sock = SOCKET_I(inode);
+			ret_val = selinux_netlbl_socket_setsid(sock,
+							  sock->sk->sk_family,
+							  tsec->sid);
+		} else if (netlbl_sec->netlbl_sid != tsec->sid &&
+			   netlbl_sec->netlbl_sid != SECINITSID_KERNEL)
+			ret_val = -EACCES;
+	}
+
+	return ret_val;
+}
+
+/**
+ * selinux_netlbl_sock_rcv_skb - Do an inbound access check using NetLabel
+ * @sock_class: the socket class
+ * @sock_sid: the socket's SID
+ * @skb: the incoming packet
+ * @ad: the audit data
+ *
+ * Description:
+ * Fetch the NetLabel security attributes from @skb and perform an access check
+ * against the receiving socket.  Returns zero on success, negative values on
+ * error.
+ *
+ */
+int selinux_netlbl_sock_rcv_skb(const u16 sock_class,
+				const u32 sock_sid,
+				struct sk_buff *skb,
+				struct avc_audit_data *ad)
+{
+	int ret_val;
+	u32 netlbl_sid;
+	u32 recv_perm;
+
+	ret_val = selinux_netlbl_skbuff_getsid(skb, sock_sid, &netlbl_sid);
+	if (ret_val)
+		goto netlbl_sock_rcv_skb;
+
+	/* PM - at some point we want to do an unlabeled check here too but
+	   we need a way to enable/disable NetLabel checks at runtime first,
+	   see RH BZ #195238 for more details */
+	if (netlbl_sid != SECINITSID_UNLABELED) {
+		switch (sock_class) {
+		case SECCLASS_UDP_SOCKET:
+			recv_perm = UDP_SOCKET__RECV_MSG;
+			break;
+		case SECCLASS_TCP_SOCKET:
+			recv_perm = TCP_SOCKET__RECV_MSG;
+			break;
+		default:
+			recv_perm = RAWIP_SOCKET__RECV_MSG;
+			break;
+		}
+
+		ret_val = avc_has_perm(sock_sid,
+				       netlbl_sid,
+				       sock_class,
+				       recv_perm,
+				       ad);
+		if (ret_val)
+			netlbl_skbuff_err(skb, ret_val);
+	}
+
+netlbl_sock_rcv_skb:
+	return ret_val;
+}
+
+/**
+ * selinux_netlbl_socket_peersid - Return the peer SID of a connected socket
+ * @sock: the socket
+ * @peer_sid: the peer SID
+ *
+ * Description:
+ * Examine @sock to find the connected peer's SID, if that is not possibile
+ * check the socket's receive queue and take the SID from the incoming
+ * packets.  Returns zero on success, negative values on error.
+ *
+ */
+int selinux_netlbl_socket_getpeersec_stream(struct socket *sock, u32 *peer_sid)
+{
+	int ret_val = 0;
+	struct inode_security_struct *isec = SOCK_INODE(sock)->i_security;
+
+	if (isec->netlbl.peer_sid == 0)
+		ret_val = selinux_netlbl_socket_peeksid(sock, peer_sid);
+	else
+		*peer_sid = isec->netlbl.peer_sid;
+
+	return ret_val;
+}
+
+/**
+ * selinux_netlbl_socket_getpeersec_dgram - Return the SID of a NetLabel packet
+ * @skb: the packet
+ * @peer_sid: the packet's SID
+ *
+ * Description:
+ * Examine @skb to find the SID assigned to it by NetLabel.  Returns zero on
+ * success, negative values on error.
+ *
+ */
+int selinux_netlbl_socket_getpeersec_dgram(struct sk_buff *skb, u32 *peer_sid)
+{
+	struct inode_security_struct *isec;
+
+	if (skb->sk == NULL || skb->sk->sk_socket == NULL)
+		return -ENOPROTOOPT;
+
+	isec = SOCK_INODE(skb->sk->sk_socket)->i_security;
+
+	return selinux_netlbl_skbuff_getsid(skb, isec->sid, peer_sid);
+}
Index: linux-2.6.17.i686-quilt/security/selinux/ss/services.c
===================================================================
--- linux-2.6.17.i686-quilt.orig/security/selinux/ss/services.c
+++ linux-2.6.17.i686-quilt/security/selinux/ss/services.c
@@ -13,6 +13,11 @@
  *
  * 	Added conditional policy language extensions
  *
+ * Updated: Hewlett-Packard <paul.moore@hp.com>
+ *
+ *      Added support for NetLabel
+ *
+ * Copyright (C) 2006 Hewlett-Packard Development Company, L.P.
  * Copyright (C) 2004-2006 Trusted Computer Solutions, Inc.
  * Copyright (C) 2003 - 2004 Tresys Technology, LLC
  * Copyright (C) 2003 Red Hat, Inc., James Morris <jmorris@redhat.com>
@@ -29,6 +34,7 @@
 #include <linux/sched.h>
 #include <linux/audit.h>
 #include <linux/mutex.h>
+#include <net/sock.h>
 
 #include "flask.h"
 #include "avc.h"
@@ -40,6 +46,8 @@
 #include "services.h"
 #include "conditional.h"
 #include "mls.h"
+#include "objsec.h"
+#include "selinux_netlabel.h"
 
 extern void selnl_notify_policyload(u32 seqno);
 unsigned int policydb_loaded_version;
@@ -54,7 +62,7 @@ static DEFINE_MUTEX(load_mutex);
 #define LOAD_LOCK mutex_lock(&load_mutex)
 #define LOAD_UNLOCK mutex_unlock(&load_mutex)
 
-static struct sidtab sidtab;
+struct sidtab sidtab;
 struct policydb policydb;
 int ss_initialized = 0;
 
@@ -1241,6 +1249,7 @@ int security_load_policy(void *data, siz
 		selinux_complete_init();
 		avc_ss_reset(seqno);
 		selnl_notify_policyload(seqno);
+		selinux_netlbl_cache_invalidate();
 		return 0;
 	}
 
@@ -1295,6 +1304,7 @@ int security_load_policy(void *data, siz
 
 	avc_ss_reset(seqno);
 	selnl_notify_policyload(seqno);
+	selinux_netlbl_cache_invalidate();
 
 	return 0;
 
Index: linux-2.6.17.i686-quilt/security/selinux/ss/services.h
===================================================================
--- linux-2.6.17.i686-quilt.orig/security/selinux/ss/services.h
+++ linux-2.6.17.i686-quilt/security/selinux/ss/services.h
@@ -9,7 +9,9 @@
 #include "policydb.h"
 #include "sidtab.h"
 
+extern struct sidtab sidtab;
 extern struct policydb policydb;
+extern int ss_initialized;
 
 #endif	/* _SS_SERVICES_H_ */
 

--
paul moore
linux security @ hp
