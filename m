From: James Morris <jmorris@namei.org>
Subject: [RFC][SECMARK 07/08] Add selinux_relabel_packet_permission() to
 SELinux API
Date: Sun, 7 May 2006 11:39:27 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605071138260.8588@d.namei>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, netfilter-devel@lists.samba.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Daniel J Walsh <dwalsh@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.sea5.speakeasy.net ([69.17.117.8]:3513 "EHLO
	mail6.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932187AbWEGPj3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 May 2006 11:39:29 -0400
To: selinux@tycho.nsa.gov
In-Reply-To: <Pine.LNX.4.64.0605071104590.8588@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a new function to the SELinux kernel API, 
selinux_relabel_packet_permission(), which is to be invoked when labeling 
packets via SECMARK.

The security policy must allow the specified label to be set by the 
current task for the permission to be granted.

It is implicit that packets are being labeled from the default unlabeled 
type.


Signed-off-by: James Morris <jmorris@namei.org>

---

 include/linux/selinux.h    |   16 ++++++++++++++++
 security/selinux/exports.c |   11 +++++++++++
 2 files changed, 27 insertions(+)

diff -purN -X dontdiff linux-2.6.17-rc3-git7.p/include/linux/selinux.h linux-2.6.17-rc3-git7.w/include/linux/selinux.h
--- linux-2.6.17-rc3-git7.p/include/linux/selinux.h	2006-05-07 00:10:56.000000000 -0400
+++ linux-2.6.17-rc3-git7.w/include/linux/selinux.h	2006-05-07 00:33:00.000000000 -0400
@@ -129,6 +129,17 @@ void selinux_get_task_sid(struct task_st
  */
 int selinux_string_to_sid(char *str, u32 *sid);
 
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
+
 #else
 
 static inline int selinux_audit_rule_init(u32 field, u32 op,
@@ -188,6 +199,11 @@ static inline int selinux_string_to_sid(
        return 0;
 }
 
+static inline int selinux_relabel_packet_permission(u32 sid)
+{
+	return 0;
+}
+
 #endif	/* CONFIG_SECURITY_SELINUX */
 
 #endif /* _LINUX_SELINUX_H */
diff -purN -X dontdiff linux-2.6.17-rc3-git7.p/security/selinux/exports.c linux-2.6.17-rc3-git7.w/security/selinux/exports.c
--- linux-2.6.17-rc3-git7.p/security/selinux/exports.c	2006-05-07 00:10:56.000000000 -0400
+++ linux-2.6.17-rc3-git7.w/security/selinux/exports.c	2006-05-07 00:24:22.000000000 -0400
@@ -83,3 +83,14 @@ int selinux_string_to_sid(char *str, u32
 }
 EXPORT_SYMBOL_GPL(selinux_string_to_sid);
 
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
