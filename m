From: Paul Moore <paul.moore@hp.com>
Subject: [RFC 4/4] NetLabel
Date: Thu, 25 May 2006 16:06:53 -0400
Message-ID: <44760E5D.3090708@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@redhat.com>,
	Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:31713 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S1030397AbWEYUG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 16:06:56 -0400
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds NetLabel support to SELinux.

 hooks.c            |   64 ++++++++++-
 include/security.h |    6 +
 ss/ebitmap.c       |  155 +++++++++++++++++++++++++++
 ss/ebitmap.h       |    6 +
 ss/mls.c           |  160 ++++++++++++++++++++++++++++
 ss/mls.h           |   25 ++++
 ss/services.c      |  252 +++++++++++++++++++++++++++++++++++++++++++++
 xfrm.c             |   22 +--
 8 files changed, 670 insertions(+), 20 deletions(-)

--- linux-2.6.16.i686/security/selinux/hooks.c	2006-05-23 11:35:16.000000000 -0400
+++ linux-2.6.16.i686-cipso/security/selinux/hooks.c	2006-05-24 10:30:50.000000000 -0400
@@ -12,6 +12,8 @@
  *  Copyright (C) 2003 Red Hat, Inc., James Morris <jmorris@redhat.com>
  *  Copyright (C) 2004-2005 Trusted Computer Solutions, Inc.
  *                          <dgoeddel@trustedcs.com>
+ *  Copyright (C) 2006 Hewlett-Packard Development Company, L.P.
+ *                     Paul Moore, <paul.moore@hp.com>
  *
  *	This program is free software; you can redistribute it and/or modify
  *	it under the terms of the GNU General Public License version 2,
@@ -69,6 +71,7 @@
 #include <linux/sysctl.h>
 #include <linux/audit.h>
 #include <linux/string.h>
+#include <net/netlabel.h>
 
 #include "avc.h"
 #include "objsec.h"
@@ -2935,6 +2938,16 @@ static void selinux_socket_post_create(s
 	isec->sid = kern ? SECINITSID_KERNEL : tsec->sid;
 	isec->initialized = 1;
 
+#ifdef CONFIG_NETLABEL        
+	if (family == PF_INET)
+		/* PM - this will throw errors unless netlabel is configured
+		   so if you enable netlabel you must make sure you configure
+		   it early in your init scripts (i.e. before you bring up
+		   networking) ... or should we just drop the BUG_ON() and
+		   audit the failure? */
+		BUG_ON(security_netlbl_socket_setsid(sock, isec->sid));
+#endif /* CONFIG_NETLABEL */
+
 	return;
 }
 
@@ -3113,6 +3126,21 @@ static int selinux_socket_accept(struct 
 	return 0;
 }
 
+#ifdef CONFIG_NETLABEL
+static void selinux_socket_post_accept(struct socket *sock,
+				       struct socket *newsock)
+{
+	if (newsock->sk != NULL && newsock->sk->sk_family == PF_INET)
+		/* PM - see my comments in the socket_post_create() hook, the
+		   problem is not quite as bad here since you have already
+		   created at least one pf_inet socket and gotten traffic on
+		   it but the core question still remains: BUG() or audit? */
+		BUG_ON(security_netlbl_socket_setsid(newsock, 
+				      ((struct inode_security_struct *)
+				       SOCK_INODE(newsock)->i_security)->sid));
+}
+#endif /* CONFIG_NETLABEL */
+
 static int selinux_socket_sendmsg(struct socket *sock, struct msghdr *msg,
  				  int size)
 {
@@ -3221,6 +3249,9 @@ static int selinux_socket_sock_rcv_skb(s
 	struct socket *sock;
 	struct net_device *dev;
 	struct avc_audit_data ad;
+#ifdef CONFIG_NETLABEL
+	u32 netlbl_sid;
+#endif
 
 	family = sk->sk_family;
 	if (family != PF_INET && family != PF_INET6)
@@ -3270,6 +3301,7 @@ static int selinux_socket_sock_rcv_skb(s
 	default:
 		netif_perm = NETIF__RAWIP_RECV;
 		node_perm = NODE__RAWIP_RECV;
+		recv_perm = RAWIP_SOCKET__RECV_MSG;
 		break;
 	}
 
@@ -3294,7 +3326,7 @@ static int selinux_socket_sock_rcv_skb(s
 	if (err)
 		goto out;
 
-	if (recv_perm) {
+	if (recv_perm != 0 && recv_perm != RAWIP_SOCKET__RECV_MSG) {
 		u32 port_sid;
 
 		/* Fixme: make this more efficient */
@@ -3306,10 +3338,27 @@ static int selinux_socket_sock_rcv_skb(s
 
 		err = avc_has_perm(sock_sid, port_sid,
 				   sock_class, recv_perm, &ad);
+		if (err)
+			goto out;
 	}
 
-	if (!err)
-		err = selinux_xfrm_sock_rcv_skb(sock_sid, skb);
+	err = selinux_xfrm_sock_rcv_skb(sock_sid, skb);
+#ifdef CONFIG_NETLABEL
+	if (err == 0)
+		goto out;
+
+	err = security_netlbl_skbuff_getsid(skb, &netlbl_sid);
+	if (err)
+		goto out;
+        
+	err = avc_has_perm(sock_sid, 
+			   netlbl_sid, 
+			   sock_class, 
+			   recv_perm,
+			   &ad);
+	if (err)
+		netlbl_skbuff_err(skb, err);
+#endif /* CONFIG_NETLABEL */
 
 out:	
 	return err;
@@ -3334,7 +3383,11 @@ static int selinux_socket_getpeersec_str
 	}
 	else if (isec->sclass == SECCLASS_TCP_SOCKET) {
 		peer_sid = selinux_socket_getpeer_stream(sock->sk);
-
+#ifdef CONFIG_NETLABEL
+		if (peer_sid == SECSID_NULL && 
+		    security_netlbl_socket_peeksid(sock, &peer_sid) != 0)
+			peer_sid = SECSID_NULL;
+#endif
 		if (peer_sid == SECSID_NULL) {
 			err = -ENOPROTOOPT;
 			goto out;
@@ -4352,6 +4405,9 @@ static struct security_operations selinu
 	.socket_connect =		selinux_socket_connect,
 	.socket_listen =		selinux_socket_listen,
 	.socket_accept =		selinux_socket_accept,
+#ifdef CONFIG_NETLABEL
+	.socket_post_accept =		selinux_socket_post_accept,
+#endif
 	.socket_sendmsg =		selinux_socket_sendmsg,
 	.socket_recvmsg =		selinux_socket_recvmsg,
 	.socket_getsockname =		selinux_socket_getsockname,
--- linux-2.6.16.i686/security/selinux/include/security.h	2006-05-23 11:34:56.000000000 -0400
+++ linux-2.6.16.i686-cipso/security/selinux/include/security.h	2006-05-24 10:30:07.000000000 -0400
@@ -8,6 +8,8 @@
 #ifndef _SELINUX_SECURITY_H_
 #define _SELINUX_SECURITY_H_
 
+#include <linux/skbuff.h>
+
 #include "flask.h"
 
 #define SECSID_NULL			0x00000000 /* unspecified SID */
@@ -91,5 +93,9 @@ int security_fs_use(const char *fstype, 
 int security_genfs_sid(const char *fstype, char *name, u16 sclass,
 	u32 *sid);
 
+int security_netlbl_socket_setsid(const struct socket *sock, const u32 sid);
+int security_netlbl_socket_peeksid(const struct socket *sock, u32 *sid);
+int security_netlbl_skbuff_getsid(const struct sk_buff *skb, u32 *sid);
+
 #endif /* _SELINUX_SECURITY_H_ */
 
--- linux-2.6.16.i686/security/selinux/ss/ebitmap.c	2006-03-20 00:53:29.000000000 -0500
+++ linux-2.6.16.i686-cipso/security/selinux/ss/ebitmap.c	2006-05-24 10:32:29.000000000 -0400
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
+		node_new = kzalloc(sizeof(struct ebitmap_node), GFP_ATOMIC);
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
--- linux-2.6.16.i686/security/selinux/ss/ebitmap.h	2006-03-20 00:53:29.000000000 -0500
+++ linux-2.6.16.i686-cipso/security/selinux/ss/ebitmap.h	2006-05-24 10:32:53.000000000 -0400
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
--- linux-2.6.16.i686/security/selinux/ss/mls.c	2006-05-23 11:34:56.000000000 -0400
+++ linux-2.6.16.i686-cipso/security/selinux/ss/mls.c	2006-05-24 10:34:43.000000000 -0400
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
--- linux-2.6.16.i686/security/selinux/ss/mls.h	2006-05-23 11:34:56.000000000 -0400
+++ linux-2.6.16.i686-cipso/security/selinux/ss/mls.h	2006-05-24 10:35:33.000000000 -0400
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
 
--- linux-2.6.16.i686/security/selinux/ss/services.c	2006-05-23 11:35:05.000000000 -0400
+++ linux-2.6.16.i686-cipso/security/selinux/ss/services.c	2006-05-24 10:44:57.000000000 -0400
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
+#include <net/netlabel.h>
 
 #include "flask.h"
 #include "avc.h"
@@ -778,6 +784,40 @@ int security_context_to_sid_default(char
 	                                    sid, def_sid);
 }
 
+/**
+ * security_context_export_type - Exports the type of a given context
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
+static int security_context_export_type(const struct context *context, 
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
 static int compute_sid_handle_invalid_context(
 	struct context *scontext,
 	struct context *tcontext,
@@ -1241,6 +1281,9 @@ int security_load_policy(void *data, siz
 		selinux_complete_init();
 		avc_ss_reset(seqno);
 		selnl_notify_policyload(seqno);
+#ifdef CONFIG_NETLABEL
+		netlbl_cache_invalidate();
+#endif
 		return 0;
 	}
 
@@ -1295,6 +1338,9 @@ int security_load_policy(void *data, siz
 
 	avc_ss_reset(seqno);
 	selnl_notify_policyload(seqno);
+#ifdef CONFIG_NETLABEL
+	netlbl_cache_invalidate();
+#endif
 
 	return 0;
 
@@ -1817,6 +1863,212 @@ out:
 	return rc;
 }
 
+#ifdef CONFIG_NETLABEL
+/*
+ * This is the structure we store inside the NetLabel cache block.
+ */
+#define NETLBL_CACHE(x) ((struct netlbl_cache *)(x))
+struct netlbl_cache {
+	u32 sid;
+};
+
+/**
+ * security_netlbl_cache_free - Free the NetLabel cached data
+ * @data: the data to free
+ *
+ * Description:
+ * This function is intended to be used as the free() callback inside the
+ * netlbl_lsm_cache structure.
+ *
+ */
+static void security_netlbl_cache_free(const void *data)
+{
+	kfree(data);
+}
+
+/**
+ * security_netlbl_secattr_to_sid - Convert a NetLabel secattr to a SELinux SID
+ * @secattr: the NetLabel packet security attributes
+ * @sid: the SELinux SID
+ *
+ * Description:
+ * Convert the given NetLabel packet security attributes in @secattr into a
+ * SELinux SID.  Returns zero on success, negative values on failure.
+ *
+ */
+static inline int security_netlbl_secattr_to_sid(
+	struct netlbl_lsm_secattr *secattr,
+	u32 *sid)
+{
+	int ret_val = -EIDRM;
+	struct context *ctx;
+	struct context ctx_new;
+	u32 ctx_new_destroy = 0;
+
+	if (secattr->set_cache)
+		*sid = NETLBL_CACHE(secattr->cache.data)->sid;
+	else if (secattr->set_mls_lvl) {
+		ctx = sidtab_search(&sidtab, SECINITSID_NETMSG);
+		if (ctx == NULL)
+			goto netlbl_secattr_to_sid_failure;
+
+		context_init(&ctx_new);
+		ctx_new_destroy = 1;
+		ret_val = context_cpy(&ctx_new, ctx);
+		if (ret_val != 0)
+			goto netlbl_secattr_to_sid_failure;
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
+ * security_netlbl_socket_setsid - Label a socket using the NetLabel mechanism
+ * @sock: the socket to label
+ * @sid: the SID to use as the basis for the label
+ *
+ * Description:
+ * Attempt to label a socket using the NetLabel mechanism using the given
+ * SID.  Returns zero values on success, negative values on failure.
+ *
+ */
+int security_netlbl_socket_setsid(const struct socket *sock, const u32 sid)
+{
+	int ret_val;
+	struct netlbl_lsm_secattr secattr;
+	struct context *ctx;
+
+	if (!ss_initialized)
+		return 0;
+
+	ctx = sidtab_search(&sidtab, sid);
+	if (ctx != NULL) {
+		netlbl_secattr_init(&secattr);
+
+		if (security_context_export_type(ctx, 
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
+		netlbl_secattr_destroy(&secattr);
+	} else
+		ret_val = -ENOENT;
+
+	return ret_val;
+}
+
+/**
+ * security_netlbl_socket_peeksid - Get the SID of the first queued packet
+ * @sock: the socket to query
+ * @sid: the packet's SID
+ *
+ * Description:
+ * Examine the first incoming packet in the socket's queue and determine the
+ * packet's SELinux SID.  Return zero on success, negative values on failure.
+ *
+ */
+int security_netlbl_socket_peeksid(const struct socket *sock, u32 *sid)
+{
+	int ret_val;
+	struct netlbl_lsm_secattr secattr;
+
+	if (!ss_initialized)
+		return 0;
+
+	netlbl_secattr_init(&secattr);
+
+	ret_val = netlbl_socket_peekattr(sock, &secattr);
+	if (ret_val == 0)
+		ret_val = security_netlbl_secattr_to_sid(&secattr, sid);
+
+	secattr.set_cache = 0;
+	netlbl_secattr_destroy(&secattr);
+
+	return ret_val;
+}
+
+/**
+ * security_netlbl_skbuff_getsid - Get the sid of a packet using NetLabel
+ * @skb: the packet
+ * @sid: the SID
+ *
+ * Description:
+ * Call the NetLabel mechanism to get the security attributes of the given
+ * packet and use those attributes to determine the correct context/SID to
+ * assign to the packet.  Returns zero on success, negative values on failure.
+ *
+ */
+int security_netlbl_skbuff_getsid(const struct sk_buff *skb, u32 *sid)
+{
+	int ret_val;
+	struct netlbl_lsm_secattr secattr;
+	struct netlbl_cache *cache;
+
+	if (!ss_initialized)
+		return 0;
+
+	netlbl_secattr_init(&secattr);
+
+	ret_val = netlbl_skbuff_getattr(skb, &secattr);
+	if (ret_val == 0) {
+		ret_val = security_netlbl_secattr_to_sid(&secattr, sid);
+		if (secattr.set_cache == 0 && ret_val == 0) {
+			cache = kmalloc(sizeof(struct netlbl_cache),
+					GFP_ATOMIC);
+			if (cache != NULL) {
+				NETLBL_CACHE(cache)->sid = *sid;
+				secattr.cache.free = 
+					security_netlbl_cache_free;
+				secattr.cache.data = (void *)cache;
+				secattr.set_cache = 1;
+				if (netlbl_cache_add(skb, &secattr) != 0)
+					security_netlbl_cache_free(cache);
+			}
+		}
+	}
+
+	secattr.set_cache = 0;
+	netlbl_secattr_destroy(&secattr);
+
+	return ret_val;
+}
+#endif /* CONFIG_NETLABEL */
+
 struct selinux_audit_rule {
 	u32 au_seqno;
 	struct context au_ctxt;
--- linux-2.6.16.i686/security/selinux/xfrm.c	2006-05-23 11:34:56.000000000 -0400
+++ linux-2.6.16.i686-cipso/security/selinux/xfrm.c	2006-05-24 10:48:01.000000000 -0400
@@ -295,13 +295,13 @@ u32 selinux_socket_getpeer_dgram(struct 
 /*
  * LSM hook that controls access to unlabelled packets.  If
  * a xfrm_state is authorizable (defined by macro) then it was
- * already authorized by the IPSec process.  If not, then
- * we need to check for unlabelled access since this may not have
- * gone thru the IPSec process.
+ * already authorized by the IPsec process.  Return zero when the
+ * packet has been approved by the IPsec process, negative values
+ * otherwise.
  */
 int selinux_xfrm_sock_rcv_skb(u32 isec_sid, struct sk_buff *skb)
 {
-	int i, rc = 0;
+	int i;
 	struct sec_path *sp;
 
 	sp = skb->sp;
@@ -317,21 +317,11 @@ int selinux_xfrm_sock_rcv_skb(u32 isec_s
 			struct xfrm_state *x = sp->xvec[i];
 
 			if (x && selinux_authorizable_xfrm(x))
-				goto accept;
+				return 0;
 		}
 	}
 
-	/* check SELinux sock for unlabelled access */
-	rc = avc_has_perm(isec_sid, SECINITSID_UNLABELED, SECCLASS_ASSOCIATION,
-			  ASSOCIATION__RECVFROM, NULL);
-	if (rc)
-		goto drop;
-
-accept:
-	return 0;
-
-drop:
-	return rc;
+	return -ENOMSG;
 }
 
 /*
