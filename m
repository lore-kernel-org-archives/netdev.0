From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 1/7] secid reconciliation-v03
Date: Thu, 28 Sep 2006 21:32:50 -0500
Message-ID: <451C85D2.8020506@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, jmorris@namei.org, sds@tycho.nsa.gov,
	paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:59582 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1161287AbWI2CdI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 22:33:08 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset helps one leverage secmark in defining fine-grained security
check points with support for a. a default place holder domain defined using
secmark for each of the check points and b. flow control and reconciliation
of domains entering/leaving the system.

The reconciliation steps for SELinux are explained in the Labeled Networking
document at:
http://marc.theaimsgroup.com/?l=linux-netdev&m=115136637800361&w=2
with the change that SELinux transition rules are used when available
to arrive at the new secid.

Also please refer to the discussion at:
http://marc.theaimsgroup.com/?l=selinux&m=115885031311565&w=2

The following are the identifiers handled here:

1. secmark on the skb
2. xfrm security identifier associated with the skb if it used any xfrms,
 a zero secid otherwise.

This patch: Add new flask definitions to SELinux

Adds a new avperm "flow_in" to arbitrate among the identifiers on the
inbound (input/forward). Also adds a new avperm "flow_out" to enable flow
control checks on the outbound (output/forward), addressed in this patch
as well.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 security/selinux/include/av_perm_to_string.h |    2 ++
 security/selinux/include/av_permissions.h    |    2 ++
 2 files changed, 4 insertions(+)

diff --git a/security/selinux/include/av_perm_to_string.h b/security/selinux/include/av_perm_to_string.h
index 09fc8a2..1e65d28 100644
--- a/security/selinux/include/av_perm_to_string.h
+++ b/security/selinux/include/av_perm_to_string.h
@@ -245,6 +245,8 @@
    S_(SECCLASS_PACKET, PACKET__SEND, "send")
    S_(SECCLASS_PACKET, PACKET__RECV, "recv")
    S_(SECCLASS_PACKET, PACKET__RELABELTO, "relabelto")
+   S_(SECCLASS_PACKET, PACKET__FLOW_IN, "flow_in")
+   S_(SECCLASS_PACKET, PACKET__FLOW_OUT, "flow_out")
    S_(SECCLASS_KEY, KEY__VIEW, "view")
    S_(SECCLASS_KEY, KEY__READ, "read")
    S_(SECCLASS_KEY, KEY__WRITE, "write")
diff --git a/security/selinux/include/av_permissions.h b/security/selinux/include/av_permissions.h
index 81f4f52..2faf3d8 100644
--- a/security/selinux/include/av_permissions.h
+++ b/security/selinux/include/av_permissions.h
@@ -962,6 +962,8 @@ #define APPLETALK_SOCKET__NAME_BIND     
 #define PACKET__SEND                              0x00000001UL
 #define PACKET__RECV                              0x00000002UL
 #define PACKET__RELABELTO                         0x00000004UL
+#define PACKET__FLOW_IN                           0x00000008UL
+#define PACKET__FLOW_OUT                          0x00000010UL
 
 #define KEY__VIEW                                 0x00000001UL
 #define KEY__READ                                 0x00000002UL
