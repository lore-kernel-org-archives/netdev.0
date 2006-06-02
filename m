From: akpm@osdl.org
Subject: [patch 08/17] secmark: Add SELinux exports
Date: Thu, 01 Jun 2006 20:32:29 -0700
Message-ID: <200606020328.k523SAmT028826@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:65204 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751202AbWFBD2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 23:28:17 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: James Morris <jmorris@namei.org>

Add and export new functions to the in-kernel SELinux API in support of the
new secmark-based packet controls.

Signed-off-by: James Morris <jmorris@namei.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 include/linux/selinux.h    |   32 ++++++++++++++++++++++++++++++++
 security/selinux/exports.c |   22 ++++++++++++++++++++++
 2 files changed, 54 insertions(+)

diff -puN include/linux/selinux.h~secmark-add-selinux-exports include/linux/selinux.h
--- devel/include/linux/selinux.h~secmark-add-selinux-exports	2006-06-01 20:31:50.000000000 -0700
+++ devel-akpm/include/linux/selinux.h	2006-06-01 20:31:50.000000000 -0700
@@ -118,6 +118,27 @@ void selinux_get_ipc_sid(const struct ke
  */
 void selinux_get_task_sid(struct task_struct *tsk, u32 *sid);
 
+/**
+ *     selinux_string_to_sid - map a security context string to a security ID
+ *     @str: the security context string to be mapped
+ *     @sid: ID value returned via this.
+ *
+ *     Returns 0 if successful, with the SID stored in sid.  A value
+ *     of zero for sid indicates no SID could be determined (but no error
+ *     occurred).
+ */
+int selinux_string_to_sid(char *str, u32 *sid);
+
+/**
+ *     selinux_relabel_packet_permission - check permission to relabel a packet
+ *     @sid: ID value to be applied to network packet (via SECMARK, most likely)
+ *
+ *     Returns 0 if the current task is allowed to label packets with the
+ *     supplied security ID.  Note that it is implicit that the packet is always
+ *     being relabeled from the default unlabled value, and that the access
+ *     control decision is made in the AVC.
+ */
+int selinux_relabel_packet_permission(u32 sid);
 
 #else
 
@@ -172,6 +193,17 @@ static inline void selinux_get_task_sid(
 	*sid = 0;
 }
 
+static inline int selinux_string_to_sid(const char *str, u32 *sid)
+{
+       *sid = 0;
+       return 0;
+}
+
+static inline int selinux_relabel_packet_permission(u32 sid)
+{
+	return 0;
+}
+
 #endif	/* CONFIG_SECURITY_SELINUX */
 
 #endif /* _LINUX_SELINUX_H */
diff -puN security/selinux/exports.c~secmark-add-selinux-exports security/selinux/exports.c
--- devel/security/selinux/exports.c~secmark-add-selinux-exports	2006-06-01 20:31:50.000000000 -0700
+++ devel-akpm/security/selinux/exports.c	2006-06-01 20:31:50.000000000 -0700
@@ -72,3 +72,25 @@ void selinux_get_task_sid(struct task_st
 	*sid = 0;
 }
 
+int selinux_string_to_sid(char *str, u32 *sid)
+{
+	if (selinux_enabled)
+		return security_context_to_sid(str, strlen(str), sid);
+	else {
+		*sid = 0;
+		return 0;
+	}
+}
+EXPORT_SYMBOL_GPL(selinux_string_to_sid);
+
+int selinux_relabel_packet_permission(u32 sid)
+{
+	if (selinux_enabled) {
+		struct task_security_struct *tsec = current->security;
+
+		return avc_has_perm(tsec->sid, sid, SECCLASS_PACKET,
+				    PACKET__RELABELTO, NULL);
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(selinux_relabel_packet_permission);
_
