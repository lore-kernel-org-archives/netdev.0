From: James Morris <jmorris@namei.org>
Subject: [PATCH 02/07] secmark: Add SELinux exports
Date: Thu, 18 May 2006 05:23:42 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605180522520.569@d.namei>
References: <Pine.LNX.4.64.0605180458130.569@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Smalley <sds@tycho.nsa.gov>, netdev@vger.kernel.org,
	Karl MacMillan <kmacmillan@tresys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.sea5.speakeasy.net ([69.17.117.8]:27340 "EHLO
	mail6.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751034AbWERJXo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 May 2006 05:23:44 -0400
To: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0605180458130.569@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch exports adds new functions to the in-kernel SELinux API in 
support of the new secmark-based packet controls.

Please apply.

Signed-off-by: James Morris <jmorris@namei.org>

---

 include/linux/selinux.h    |   32 ++++++++++++++++++++++++++++++++
 security/selinux/exports.c |   22 ++++++++++++++++++++++
 2 files changed, 54 insertions(+)


diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/include/linux/selinux.h linux-2.6.17-rc4-mm1.w/include/linux/selinux.h
--- linux-2.6.17-rc4-mm1.p/include/linux/selinux.h	2006-05-17 01:03:34.000000000 -0400
+++ linux-2.6.17-rc4-mm1.w/include/linux/selinux.h	2006-05-17 01:18:57.000000000 -0400
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
diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/security/selinux/exports.c linux-2.6.17-rc4-mm1.w/security/selinux/exports.c
--- linux-2.6.17-rc4-mm1.p/security/selinux/exports.c	2006-05-17 01:03:34.000000000 -0400
+++ linux-2.6.17-rc4-mm1.w/security/selinux/exports.c	2006-05-17 01:18:57.000000000 -0400
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
