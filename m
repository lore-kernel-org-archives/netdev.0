From: paul.moore@hp.com
Subject: [PATCH 6/7] NetLabel: SELinux support
Date: Mon, 17 Jul 2006 11:52:30 -0400
Message-ID: <20060717155825.246489000@hp.com>
References: <20060717155224.060020000@hp.com>
Cc: davem@davemloft.net, sds@epoch.ncsc.mil, jmorris@redhat.com,
	pratt@argus-systems.com, Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:47584 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1750904AbWGQP61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2006 11:58:27 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-selinux-2.6.18
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add NetLabel support to the SELinux LSM and modify the socket_post_create() LSM
hook to return an error code.  The most significant part of this patch is the
addition of NetLabel hooks into the following SELinux LSM hooks:

 * selinux_file_permission()
 * selinux_socket_sendmsg()
 * selinux_socket_post_create()
 * selinux_socket_accept()
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

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 include/linux/security.h                    |   25 -
 net/socket.c                                |   17 
 security/dummy.c                            |    6 
 security/selinux/hooks.c                    |   53 ++
 security/selinux/include/objsec.h           |   13 
 security/selinux/include/selinux_netlabel.h |  100 +++++
 security/selinux/ss/ebitmap.c               |  152 +++++++
 security/selinux/ss/ebitmap.h               |    6 
 security/selinux/ss/mls.c                   |  152 +++++++
 security/selinux/ss/mls.h                   |   21 +
 security/selinux/ss/services.c              |  555 ++++++++++++++++++++++++++++
 11 files changed, 1070 insertions(+), 30 deletions(-)

Index: linux-2.6.18-rc2/include/linux/security.h
===================================================================
--- linux-2.6.18-rc2.orig/include/linux/security.h
+++ linux-2.6.18-rc2/include/linux/security.h
@@ -1296,8 +1296,8 @@ struct security_operations {
 	int (*unix_may_send) (struct socket * sock, struct socket * other);
 
 	int (*socket_create) (int family, int type, int protocol, int kern);
-	void (*socket_post_create) (struct socket * sock, int family,
-				    int type, int protocol, int kern);
+	int (*socket_post_create) (struct socket * sock, int family,
+				   int type, int protocol, int kern);
 	int (*socket_bind) (struct socket * sock,
 			    struct sockaddr * address, int addrlen);
 	int (*socket_connect) (struct socket * sock,
@@ -2748,13 +2748,13 @@ static inline int security_socket_create
 	return security_ops->socket_create(family, type, protocol, kern);
 }
 
-static inline void security_socket_post_create(struct socket * sock, 
-					       int family,
-					       int type, 
-					       int protocol, int kern)
+static inline int security_socket_post_create(struct socket * sock,
+					      int family,
+					      int type,
+					      int protocol, int kern)
 {
-	security_ops->socket_post_create(sock, family, type,
-					 protocol, kern);
+	return security_ops->socket_post_create(sock, family, type,
+						protocol, kern);
 }
 
 static inline int security_socket_bind(struct socket * sock, 
@@ -2880,11 +2880,12 @@ static inline int security_socket_create
 	return 0;
 }
 
-static inline void security_socket_post_create(struct socket * sock, 
-					       int family,
-					       int type, 
-					       int protocol, int kern)
+static inline int security_socket_post_create(struct socket * sock,
+					      int family,
+					      int type,
+					      int protocol, int kern)
 {
+	return 0;
 }
 
 static inline int security_socket_bind(struct socket * sock, 
Index: linux-2.6.18-rc2/net/socket.c
===================================================================
--- linux-2.6.18-rc2.orig/net/socket.c
+++ linux-2.6.18-rc2/net/socket.c
@@ -973,11 +973,18 @@ int sock_create_lite(int family, int typ
 		goto out;
 	}
 
-	security_socket_post_create(sock, family, type, protocol, 1);
 	sock->type = type;
+	err = security_socket_post_create(sock, family, type, protocol, 1);
+	if (err)
+		goto out_release;
+
 out:
 	*res = sock;
 	return err;
+out_release:
+	sock_release(sock);
+	sock = NULL;
+	goto out;
 }
 
 /* No kernel lock held - perfect */
@@ -1213,7 +1220,9 @@ static int __sock_create(int family, int
 	 */
 	module_put(net_families[family]->owner);
 	*res = sock;
-	security_socket_post_create(sock, family, type, protocol, kern);
+	err = security_socket_post_create(sock, family, type, protocol, kern);
+	if (err)
+		goto out_release;
 
 out:
 	net_family_read_unlock();
@@ -1443,13 +1452,13 @@ asmlinkage long sys_accept(int fd, struc
 			goto out_fd;
 	}
 
+	security_socket_post_accept(sock, newsock);
+
 	/* File flags are not inherited via accept() unlike another OSes. */
 
 	fd_install(newfd, newfile);
 	err = newfd;
 
-	security_socket_post_accept(sock, newsock);
-
 out_put:
 	fput_light(sock->file, fput_needed);
 out:
Index: linux-2.6.18-rc2/security/dummy.c
===================================================================
--- linux-2.6.18-rc2.orig/security/dummy.c
+++ linux-2.6.18-rc2/security/dummy.c
@@ -709,10 +709,10 @@ static int dummy_socket_create (int fami
 	return 0;
 }
 
-static void dummy_socket_post_create (struct socket *sock, int family, int type,
-				      int protocol, int kern)
+static int dummy_socket_post_create (struct socket *sock, int family, int type,
+				     int protocol, int kern)
 {
-	return;
+	return 0;
 }
 
 static int dummy_socket_bind (struct socket *sock, struct sockaddr *address,
Index: linux-2.6.18-rc2/security/selinux/hooks.c
===================================================================
--- linux-2.6.18-rc2.orig/security/selinux/hooks.c
+++ linux-2.6.18-rc2/security/selinux/hooks.c
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
@@ -2400,6 +2403,7 @@ static int selinux_inode_listsecurity(st
 
 static int selinux_file_permission(struct file *file, int mask)
 {
+	int rc;
 	struct inode *inode = file->f_dentry->d_inode;
 
 	if (!mask) {
@@ -2411,8 +2415,12 @@ static int selinux_file_permission(struc
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
@@ -3063,8 +3071,8 @@ out:
 	return err;
 }
 
-static void selinux_socket_post_create(struct socket *sock, int family,
-				       int type, int protocol, int kern)
+static int selinux_socket_post_create(struct socket *sock, int family,
+				      int type, int protocol, int kern)
 {
 	struct inode_security_struct *isec;
 	struct task_security_struct *tsec;
@@ -3078,7 +3086,7 @@ static void selinux_socket_post_create(s
 	isec->sid = kern ? SECINITSID_KERNEL : newsid;
 	isec->initialized = 1;
 
-	return;
+	return selinux_netlbl_socket_create(sock, family, isec->sid);
 }
 
 /* Range of port numbers used to automatically bind.
@@ -3253,13 +3261,25 @@ static int selinux_socket_accept(struct 
 	newisec->sid = isec->sid;
 	newisec->initialized = 1;
 
-	return 0;
+	return selinux_netlbl_socket_accept(sock, newsock);
+}
+
+static void selinux_socket_post_accept(struct socket *sock,
+				       struct socket *newsock)
+{
+	selinux_netlbl_socket_post_accept(sock, newsock);
 }
 
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
@@ -3467,6 +3487,10 @@ static int selinux_socket_sock_rcv_skb(s
 	if (err)
 		goto out;
 
+	err = selinux_netlbl_sock_rcv_skb(sk, skb, sock_class, sock_sid, &ad);
+	if (err)
+		goto out;
+
 	err = selinux_xfrm_sock_rcv_skb(sock_sid, skb);
 out:	
 	return err;
@@ -3490,8 +3514,10 @@ static int selinux_socket_getpeersec_str
 		peer_sid = ssec->peer_sid;
 	}
 	else if (isec->sclass == SECCLASS_TCP_SOCKET) {
-		peer_sid = selinux_socket_getpeer_stream(sock->sk);
-
+		peer_sid = selinux_netlbl_socket_getpeersec_stream(sock);
+		if (peer_sid == SECSID_NULL ||
+		    peer_sid == SECINITSID_UNLABELED)
+			peer_sid = selinux_socket_getpeer_stream(sock->sk);
 		if (peer_sid == SECSID_NULL) {
 			err = -ENOPROTOOPT;
 			goto out;
@@ -3532,8 +3558,12 @@ static int selinux_socket_getpeersec_dgr
 	if (skb->sk->sk_family == PF_UNIX)
 		selinux_get_inode_sid(SOCK_INODE(skb->sk->sk_socket),
 				      &peer_sid);
-	else
-		peer_sid = selinux_socket_getpeer_dgram(skb);
+	else {
+		peer_sid = selinux_netlbl_socket_getpeersec_dgram(skb);
+		if (peer_sid == SECSID_NULL ||
+		    peer_sid == SECINITSID_UNLABELED)
+			peer_sid = selinux_socket_getpeer_dgram(skb);
+	}
 
 	if (peer_sid == SECSID_NULL)
 		return -EINVAL;
@@ -4596,6 +4626,7 @@ static struct security_operations selinu
 	.socket_connect =		selinux_socket_connect,
 	.socket_listen =		selinux_socket_listen,
 	.socket_accept =		selinux_socket_accept,
+	.socket_post_accept =		selinux_socket_post_accept,
 	.socket_sendmsg =		selinux_socket_sendmsg,
 	.socket_recvmsg =		selinux_socket_recvmsg,
 	.socket_getsockname =		selinux_socket_getsockname,
Index: linux-2.6.18-rc2/security/selinux/include/objsec.h
===================================================================
--- linux-2.6.18-rc2.orig/security/selinux/include/objsec.h
+++ linux-2.6.18-rc2/security/selinux/include/objsec.h
@@ -37,6 +37,16 @@ struct task_security_struct {
 	u32 ptrace_sid;      /* SID of ptrace parent */
 };
 
+struct netlbl_security_struct {
+	u32 peer_sid;             /* SID of the connected peer */
+	enum {                    /* NetLabel state */
+		NLBL_UNSET = 0,
+		NLBL_ACCEPT,
+		NLBL_REQUIRE,
+		NLBL_LABELED,
+	} state;
+};
+
 struct inode_security_struct {
         struct inode *inode;           /* back pointer to inode object */
 	struct list_head list;         /* list of inode_security_struct */
@@ -46,6 +56,9 @@ struct inode_security_struct {
 	unsigned char initialized;     /* initialization flag */
 	struct semaphore sem;
 	unsigned char inherit;         /* inherit SID from parent entry */
+#ifdef CONFIG_NETLABEL
+	struct netlbl_security_struct netlbl;
+#endif
 };
 
 struct file_security_struct {
Index: linux-2.6.18-rc2/security/selinux/include/selinux_netlabel.h
===================================================================
--- /dev/null
+++ linux-2.6.18-rc2/security/selinux/include/selinux_netlabel.h
@@ -0,0 +1,100 @@
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
+int selinux_netlbl_inode_permission(struct inode *inode,
+				    int mask);
+
+int selinux_netlbl_socket_create(struct socket *sock,
+				 int sock_family,
+				 u32 sid);
+int selinux_netlbl_socket_accept(struct socket *sock,
+				 struct socket *newsock);
+void selinux_netlbl_socket_post_accept(struct socket *sock,
+				       struct socket *newsock);
+int selinux_netlbl_sock_rcv_skb(struct sock *sk,
+				struct sk_buff *skb,
+				u16 sock_class,
+				u32 sock_sid,
+				struct avc_audit_data *ad);
+u32 selinux_netlbl_socket_getpeersec_stream(struct socket *sock);
+u32 selinux_netlbl_socket_getpeersec_dgram(struct sk_buff *skb);
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
+					       int sock_family,
+					       u32 sid)
+{
+	return 0;
+}
+
+static inline int selinux_netlbl_socket_accept(struct socket *sock,
+					       struct socket *newsock)
+{
+	return 0;
+}
+
+static inline void selinux_netlbl_socket_post_accept(struct socket *sock,
+						     struct socket *newsock)
+{
+	return;
+}
+
+static inline int selinux_netlbl_sock_rcv_skb(struct sock *sk,
+					      struct sk_buff *skb,
+					      u16 sock_class,
+					      u32 sock_sid,
+					      struct avc_audit_data *ad)
+{
+	return 0;
+}
+
+static inline u32 selinux_netlbl_socket_getpeersec_stream(struct socket *sock)
+{
+	return SECSID_NULL;
+}
+
+static inline u32 selinux_netlbl_socket_getpeersec_dgram(struct sk_buff *skb)
+{
+	return SECSID_NULL;
+}
+#endif /* CONFIG_NETLABEL */
+
+#endif
Index: linux-2.6.18-rc2/security/selinux/ss/ebitmap.c
===================================================================
--- linux-2.6.18-rc2.orig/security/selinux/ss/ebitmap.c
+++ linux-2.6.18-rc2/security/selinux/ss/ebitmap.c
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
@@ -59,6 +67,150 @@ int ebitmap_cpy(struct ebitmap *dst, str
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
+		   size_t *dst_len)
+{
+	size_t bitmap_len;
+	unsigned char *bitmap;
+	struct ebitmap_node *iter_node;
+	MAPTYPE node_val;
+	size_t bitmap_byte;
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
+		   size_t src_len,
+		   struct ebitmap *dst)
+{
+	size_t src_off = 0;
+	struct ebitmap_node *node_new;
+	struct ebitmap_node *node_last = NULL;
+	size_t src_rem = src_len;
+	MAPTYPE tmp_val;
+	size_t iter;
+	size_t iter_bit;
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
Index: linux-2.6.18-rc2/security/selinux/ss/ebitmap.h
===================================================================
--- linux-2.6.18-rc2.orig/security/selinux/ss/ebitmap.h
+++ linux-2.6.18-rc2/security/selinux/ss/ebitmap.h
@@ -69,6 +69,12 @@ static inline int ebitmap_node_get_bit(s
 
 int ebitmap_cmp(struct ebitmap *e1, struct ebitmap *e2);
 int ebitmap_cpy(struct ebitmap *dst, struct ebitmap *src);
+int ebitmap_export(const struct ebitmap *src,
+		   unsigned char **dst,
+		   size_t *dst_len);
+int ebitmap_import(const unsigned char *src,
+		   size_t src_len,
+		   struct ebitmap *dst);
 int ebitmap_contains(struct ebitmap *e1, struct ebitmap *e2);
 int ebitmap_get_bit(struct ebitmap *e, unsigned long bit);
 int ebitmap_set_bit(struct ebitmap *e, unsigned long bit, int value);
Index: linux-2.6.18-rc2/security/selinux/ss/mls.c
===================================================================
--- linux-2.6.18-rc2.orig/security/selinux/ss/mls.c
+++ linux-2.6.18-rc2/security/selinux/ss/mls.c
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
@@ -585,3 +592,148 @@ int mls_compute_sid(struct context *scon
 	return -EINVAL;
 }
 
+/**
+ * mls_export_lvl - Export the MLS sensitivity levels
+ * @context: the security context
+ * @low: the low sensitivity level
+ * @high: the high sensitivity level
+ *
+ * Description:
+ * Given the security context copy the low MLS sensitivity level into lvl_low
+ * and the high sensitivity level in lvl_high.  The MLS levels are only
+ * exported if the pointers are not NULL, if they are NULL then that level is
+ * not exported.
+ *
+ */
+void mls_export_lvl(const struct context *context, u32 *low, u32 *high)
+{
+	if (!selinux_mls_enabled)
+		return;
+
+	if (low != NULL)
+		*low = context->range.level[0].sens - 1;
+	if (high != NULL)
+		*high = context->range.level[1].sens - 1;
+}
+
+/**
+ * mls_import_lvl - Import the MLS sensitivity levels
+ * @context: the security context
+ * @low: the low sensitivity level
+ * @high: the high sensitivity level
+ *
+ * Description:
+ * Given the security context and the two sensitivty levels, set the MLS levels
+ * in the context according the two given as parameters.  Returns zero on
+ * success, negative values on failure.
+ *
+ */
+void mls_import_lvl(struct context *context, u32 low, u32 high)
+{
+	if (!selinux_mls_enabled)
+		return;
+
+	context->range.level[0].sens = low + 1;
+	context->range.level[1].sens = high + 1;
+}
+
+/**
+ * mls_export_cat - Export the MLS categories
+ * @context: the security context
+ * @low: the low category
+ * @low_len: length of the cat_low bitmap in bytes
+ * @high: the high category
+ * @high_len: length of the cat_high bitmap in bytes
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
+		   unsigned char **low,
+		   size_t *low_len,
+		   unsigned char **high,
+		   size_t *high_len)
+{
+	int rc = -EPERM;
+
+	if (!selinux_mls_enabled)
+		return 0;
+
+	if (low != NULL) {
+		rc = ebitmap_export(&context->range.level[0].cat,
+				    low,
+				    low_len);
+		if (rc != 0)
+			goto export_cat_failure;
+	}
+	if (high != NULL) {
+		rc = ebitmap_export(&context->range.level[1].cat,
+				    high,
+				    high_len);
+		if (rc != 0)
+			goto export_cat_failure;
+	}
+
+	return 0;
+
+export_cat_failure:
+	if (low != NULL)
+		kfree(*low);
+	if (high != NULL)
+		kfree(*high);
+	return rc;
+}
+
+/**
+ * mls_import_cat - Import the MLS categories
+ * @context: the security context
+ * @low: the low category
+ * @low_len: length of the cat_low bitmap in bytes
+ * @high: the high category
+ * @high_len: length of the cat_high bitmap in bytes
+ *
+ * Description:
+ * Given the security context and the two category bitmap strings import the
+ * categories into the security context.  The MLS categories are only imported
+ * if the pointers are not NULL, if they are NULL they are skipped.  Returns
+ * zero on success, negative values on failure.
+ *
+ */
+int mls_import_cat(struct context *context,
+		   const unsigned char *low,
+		   size_t low_len,
+		   const unsigned char *high,
+		   size_t high_len)
+{
+	int rc = -EPERM;
+
+	if (!selinux_mls_enabled)
+		return 0;
+
+	if (low != NULL) {
+		rc = ebitmap_import(low,
+				    low_len,
+				    &context->range.level[0].cat);
+		if (rc != 0)
+			goto import_cat_failure;
+	}
+	if (high != NULL) {
+		rc = ebitmap_import(high,
+				    high_len,
+				    &context->range.level[1].cat);
+		if (rc != 0)
+			goto import_cat_failure;
+	}
+
+	return 0;
+
+import_cat_failure:
+	ebitmap_destroy(&context->range.level[0].cat);
+	ebitmap_destroy(&context->range.level[1].cat);
+	return rc;
+}
Index: linux-2.6.18-rc2/security/selinux/ss/mls.h
===================================================================
--- linux-2.6.18-rc2.orig/security/selinux/ss/mls.h
+++ linux-2.6.18-rc2/security/selinux/ss/mls.h
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
@@ -42,5 +49,19 @@ int mls_compute_sid(struct context *scon
 int mls_setup_user_range(struct context *fromcon, struct user_datum *user,
                          struct context *usercon);
 
+void mls_export_lvl(const struct context *context, u32 *low, u32 *high);
+void mls_import_lvl(struct context *context, u32 low, u32 high);
+
+int mls_export_cat(const struct context *context,
+		   unsigned char **low,
+		   size_t *low_len,
+		   unsigned char **high,
+		   size_t *high_len);
+int mls_import_cat(struct context *context,
+		   const unsigned char *low,
+		   size_t low_len,
+		   const unsigned char *high,
+		   size_t high_len);
+
 #endif	/* _SS_MLS_H */
 
Index: linux-2.6.18-rc2/security/selinux/ss/services.c
===================================================================
--- linux-2.6.18-rc2.orig/security/selinux/ss/services.c
+++ linux-2.6.18-rc2/security/selinux/ss/services.c
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
@@ -29,6 +34,8 @@
 #include <linux/sched.h>
 #include <linux/audit.h>
 #include <linux/mutex.h>
+#include <net/sock.h>
+#include <net/netlabel.h>
 
 #include "flask.h"
 #include "avc.h"
@@ -40,6 +47,8 @@
 #include "services.h"
 #include "conditional.h"
 #include "mls.h"
+#include "objsec.h"
+#include "selinux_netlabel.h"
 
 extern void selnl_notify_policyload(u32 seqno);
 unsigned int policydb_loaded_version;
@@ -1241,6 +1250,7 @@ int security_load_policy(void *data, siz
 		selinux_complete_init();
 		avc_ss_reset(seqno);
 		selnl_notify_policyload(seqno);
+		selinux_netlbl_cache_invalidate();
 		return 0;
 	}
 
@@ -1295,6 +1305,7 @@ int security_load_policy(void *data, siz
 
 	avc_ss_reset(seqno);
 	selnl_notify_policyload(seqno);
+	selinux_netlbl_cache_invalidate();
 
 	return 0;
 
@@ -2064,3 +2075,547 @@ void selinux_audit_set_callback(int (*ca
 {
 	aurule_callback = callback;
 }
+
+#ifdef CONFIG_NETLABEL
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
+	u32 cache_clear = 1;
+
+	netlbl_secattr_init(&secattr);
+
+	cache = kzalloc(sizeof(*cache),	GFP_ATOMIC);
+	if (cache == NULL)
+		goto netlbl_cache_add_return;
+	secattr.cache.free = selinux_netlbl_cache_free;
+	secattr.cache.data = (void *)cache;
+
+	cache->type = NETLBL_CACHE_T_MLSLBL;
+	if (ebitmap_cpy(&cache->data.mls_label.cat,
+			&ctx->range.level[0].cat) != 0)
+		goto netlbl_cache_add_return;
+	cache->data.mls_label.sens = ctx->range.level[0].sens;
+
+	if (netlbl_cache_add(skb, &secattr) != 0)
+		goto netlbl_cache_add_return;
+	cache_clear = 0;
+
+netlbl_cache_add_return:
+	netlbl_secattr_destroy(&secattr, cache_clear);
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
+					 struct netlbl_lsm_secattr *secattr,
+					 u32 base_sid,
+					 u32 *sid)
+{
+	int rc = -EIDRM;
+	struct context *ctx;
+	struct context ctx_new;
+	struct netlbl_cache *cache;
+	u32 ctx_new_destroy = 0;
+
+	POLICY_RDLOCK;
+
+	if (secattr->cache.data) {
+		cache = NETLBL_CACHE(secattr->cache.data);
+		switch (cache->type) {
+		case NETLBL_CACHE_T_SID:
+			*sid = cache->data.sid;
+			break;
+		case NETLBL_CACHE_T_MLSLBL:
+			ctx = sidtab_search(&sidtab, base_sid);
+			if (ctx == NULL)
+				goto netlbl_secattr_to_sid_return;
+			rc = context_cpy(&ctx_new, ctx);
+			if (rc != 0)
+				goto netlbl_secattr_to_sid_return;
+			ctx_new_destroy = 1;
+			mls_context_destroy(&ctx_new);
+
+			ctx_new.range.level[0].sens =
+				cache->data.mls_label.sens;
+			rc = ebitmap_cpy(&ctx_new.range.level[0].cat,
+					 &cache->data.mls_label.cat);
+			if (rc != 0)
+				goto netlbl_secattr_to_sid_return;
+			ctx_new.range.level[1].sens =
+				cache->data.mls_label.sens;
+			rc = ebitmap_cpy(&ctx_new.range.level[1].cat,
+					 &cache->data.mls_label.cat);
+			if (rc != 0)
+				goto netlbl_secattr_to_sid_return;
+
+			rc = sidtab_context_to_sid(&sidtab, &ctx_new, sid);
+			break;
+		default:
+			goto netlbl_secattr_to_sid_return;
+		}
+	} else if (secattr->mls_lvl_vld) {
+		ctx = sidtab_search(&sidtab, base_sid);
+		if (ctx == NULL)
+			goto netlbl_secattr_to_sid_return;
+		rc = context_cpy(&ctx_new, ctx);
+		if (rc != 0)
+			goto netlbl_secattr_to_sid_return;
+		ctx_new_destroy = 1;
+		mls_context_destroy(&ctx_new);
+
+		mls_import_lvl(&ctx_new, secattr->mls_lvl, secattr->mls_lvl);
+		if (secattr->mls_cat) {
+			if (mls_import_cat(&ctx_new,
+					   secattr->mls_cat,
+					   secattr->mls_cat_len,
+					   secattr->mls_cat,
+					   secattr->mls_cat_len) != 0)
+				goto netlbl_secattr_to_sid_return;
+		}
+
+		rc = mls_context_isvalid(&policydb, &ctx_new);
+		if (rc != 1)
+			goto netlbl_secattr_to_sid_return;
+
+		if (skb != NULL)
+			selinux_netlbl_cache_add(skb, &ctx_new);
+
+		rc = sidtab_context_to_sid(&sidtab, &ctx_new, sid);
+	} else
+		*sid = SECINITSID_UNLABELED;
+
+	rc = 0;
+
+netlbl_secattr_to_sid_return:
+	POLICY_RDUNLOCK;
+	if (ctx_new_destroy)
+		context_destroy(&ctx_new);
+	return rc;
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
+					u32 base_sid,
+					u32 *sid)
+{
+	int rc;
+	struct netlbl_lsm_secattr secattr;
+
+	netlbl_secattr_init(&secattr);
+	rc = netlbl_skbuff_getattr(skb, &secattr);
+	if (rc == 0)
+		rc = selinux_netlbl_secattr_to_sid(skb,
+						   &secattr,
+						   base_sid,
+						   sid);
+	netlbl_secattr_destroy(&secattr, 0);
+	return rc;
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
+					int sock_family,
+					u32 sid)
+{
+	int rc;
+	struct inode_security_struct *isec = SOCK_INODE(sock)->i_security;
+	struct netlbl_lsm_secattr secattr;
+	struct context *ctx;
+
+	if (!ss_initialized)
+		return 0;
+
+	POLICY_RDLOCK;
+
+	ctx = sidtab_search(&sidtab, sid);
+	if (ctx != NULL) {
+		netlbl_secattr_init(&secattr);
+		secattr.domain = kstrdup(
+			policydb.p_type_val_to_name[ctx->type - 1],
+			GFP_ATOMIC);
+		mls_export_lvl(ctx, &secattr.mls_lvl, NULL);
+		secattr.mls_lvl_vld = 1;
+		mls_export_cat(ctx,
+			       &secattr.mls_cat,
+			       &secattr.mls_cat_len,
+			       NULL,
+			       NULL);
+
+		rc = netlbl_socket_setattr(sock, &secattr);
+		if (rc == 0)
+			isec->netlbl.state = NLBL_LABELED;
+
+		netlbl_secattr_destroy(&secattr, 0);
+	} else
+		rc = -ENOENT;
+
+	POLICY_RDUNLOCK;
+
+	return rc;
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
+static int selinux_netlbl_socket_peeksid(struct socket *sock,
+					 u32 *sid)
+{
+        int rc;
+	struct netlbl_lsm_secattr secattr;
+        struct inode_security_struct *isec = SOCK_INODE(sock)->i_security;
+
+        netlbl_secattr_init(&secattr);
+        rc = netlbl_socket_peekattr(sock, &secattr);
+        if (rc == 0)
+                rc = selinux_netlbl_secattr_to_sid(NULL,
+						   &secattr,
+						   isec->sid,
+						   sid);
+        netlbl_secattr_destroy(&secattr, 0);
+        return rc;
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
+				 int sock_family,
+				 u32 sid)
+{
+	struct inode_security_struct *isec;
+
+	if (sock_family != PF_INET)
+		return 0;
+
+	isec = SOCK_INODE(sock)->i_security;
+	isec->netlbl.state = NLBL_REQUIRE;
+	return selinux_netlbl_socket_setsid(sock, sock_family, sid);
+}
+
+/**
+ * selinux_netlbl_socket_accept - NetLabel accept hook
+ * @sock: the original socket
+ * @newsock: the new accept()ed socket
+ *
+ * Description:
+ * Mark @newsock as requiring a NetLabel label and do setup required for
+ * further processing by the post_accept and sock_rcv_skb hooks.  Returns zero
+ * on success, negative values on failure.
+ *
+ */
+int selinux_netlbl_socket_accept(struct socket *sock, struct socket *newsock)
+{
+	struct inode_security_struct *isec;
+	struct inode_security_struct *newisec;
+
+	isec = SOCK_INODE(sock)->i_security;
+	if (isec->netlbl.state == NLBL_UNSET)
+		return 0;
+
+	newisec = SOCK_INODE(newsock)->i_security;
+	newisec->netlbl.state = NLBL_ACCEPT;
+
+	return 0;
+}
+
+/**
+ * selinux_netlbl_socket_post_accept - NetLabel post_accept hook
+ * @sock: the original socket
+ * @newsock: the new accept()ed socket
+ *
+ * Description:
+ * Attempt to label a socket using the NetLabel mechanism based on the
+ * connection and the original/parent socket's SID.
+ *
+ */
+void selinux_netlbl_socket_post_accept(struct socket *sock,
+				       struct socket *newsock)
+{
+	struct inode_security_struct *newisec;
+	struct netlbl_lsm_secattr secattr;
+
+	newisec = SOCK_INODE(newsock)->i_security;
+	if (newisec->netlbl.state != NLBL_ACCEPT)
+		return;
+	netlbl_secattr_init(&secattr);
+	if (netlbl_socket_getattr(newsock, &secattr) != 0)
+		goto netlbl_socket_post_accept_return;
+	newisec = SOCK_INODE(newsock)->i_security;
+	if (selinux_netlbl_secattr_to_sid(NULL,
+					  &secattr,
+					  newisec->sid,
+					  &newisec->netlbl.peer_sid) != 0)
+		goto netlbl_socket_post_accept_return;
+	newisec->sid = newisec->netlbl.peer_sid;
+
+	/* Try to set the NetLabel here to try and save some time in
+	 * selinux_netlbl_inode_permission() later. */
+	selinux_netlbl_socket_setsid(newsock,
+				     newsock->sk->sk_family,
+				     newisec->sid);
+
+netlbl_socket_post_accept_return:
+	if (newisec->netlbl.state != NLBL_LABELED)
+		newisec->netlbl.state = NLBL_REQUIRE;
+	netlbl_secattr_destroy(&secattr, 0);
+}
+
+/**
+ * selinux_netlbl_inode_permission - Verify the file/socket is NetLabel labeled
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
+	int rc = 0;
+	struct inode_security_struct *isec = inode->i_security;
+	struct netlbl_security_struct *nlblsec = &isec->netlbl;
+	struct socket *sock;
+
+	down(&isec->sem);
+	if (nlblsec->state == NLBL_REQUIRE &&
+	    (mask & (MAY_WRITE | MAY_APPEND))) {
+		sock = SOCKET_I(inode);
+		rc = selinux_netlbl_socket_setsid(sock,
+						  sock->sk->sk_family,
+						  isec->sid);
+	}
+	up(&isec->sem);
+
+	return rc;
+}
+
+/**
+ * selinux_netlbl_sock_rcv_skb - Do an inbound access check using NetLabel
+ * @sk: the packet's sock
+ * @skb: the packet
+ * @sock_class: the socket class
+ * @sock_sid: the socket's SID
+ * @ad: the audit data
+ *
+ * Description:
+ * Fetch the NetLabel security attributes from @skb and perform an access check
+ * against the receiving socket.  Returns zero on success, negative values on
+ * error.
+ *
+ */
+int selinux_netlbl_sock_rcv_skb(struct sock *sk,
+				struct sk_buff *skb,
+				u16 sock_class,
+				u32 sock_sid,
+				struct avc_audit_data *ad)
+{
+	int rc;
+	u32 netlbl_sid;
+	u32 recv_perm;
+
+	rc = selinux_netlbl_skbuff_getsid(skb, sock_sid, &netlbl_sid);
+	if (rc != 0)
+		return rc;
+
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
+		rc = avc_has_perm(sock_sid,
+				  netlbl_sid,
+				  sock_class,
+				  recv_perm,
+				  ad);
+		if (rc != 0) {
+			struct inode_security_struct *isec;
+			u32 netlbl_send_err = 1;
+
+			read_lock_bh(&sk->sk_callback_lock);
+			isec = SOCK_INODE(sk->sk_socket)->i_security;
+			if (isec->netlbl.state == NLBL_ACCEPT)
+				netlbl_send_err = 0;
+			read_unlock_bh(&sk->sk_callback_lock);
+
+			if (netlbl_send_err)
+				netlbl_skbuff_err(skb, rc);
+		}
+	}
+
+	return rc;
+}
+
+/**
+ * selinux_netlbl_socket_peersid - Return the peer SID of a connected socket
+ * @sock: the socket
+ *
+ * Description:
+ * Examine @sock to find the connected peer's SID, if that is not possibile
+ * check the socket's receive queue and take the SID from the incoming
+ * packets.  Returns the SID on success or SECSID_NULL on error.
+ *
+ */
+u32 selinux_netlbl_socket_getpeersec_stream(struct socket *sock)
+{
+	u32 peer_sid;
+	struct inode_security_struct *isec = SOCK_INODE(sock)->i_security;
+
+	if (isec->netlbl.peer_sid != 0)
+		peer_sid = isec->netlbl.peer_sid;
+	else {
+		if (selinux_netlbl_socket_peeksid(sock, &peer_sid) != 0)
+			peer_sid = SECSID_NULL;
+	}
+
+	return peer_sid;
+}
+
+/**
+ * selinux_netlbl_socket_getpeersec_dgram - Return the SID of a NetLabel packet
+ * @skb: the packet
+ *
+ * Description:
+ * Examine @skb to find the SID assigned to it by NetLabel.  Returns the SID on
+ * success, SECSID_NULL on error.
+ *
+ */
+u32 selinux_netlbl_socket_getpeersec_dgram(struct sk_buff *skb)
+{
+	int peer_sid;
+	struct sock *sk = skb->sk;
+	struct inode_security_struct *isec;
+
+	if (sk == NULL)
+		return SECSID_NULL;
+
+	read_lock_bh(&skb->sk->sk_callback_lock);
+	if (skb->sk->sk_socket == NULL) {
+		read_unlock_bh(&skb->sk->sk_callback_lock);
+		return SECSID_NULL;
+	}
+	isec = SOCK_INODE(skb->sk->sk_socket)->i_security;
+	if (selinux_netlbl_skbuff_getsid(skb, isec->sid, &peer_sid) != 0)
+		peer_sid = SECSID_NULL;
+	read_unlock_bh(&sk->sk_callback_lock);
+
+	return peer_sid;
+}
+#endif /* CONFIG_NETLABEL */

--
paul moore
linux security @ hp
