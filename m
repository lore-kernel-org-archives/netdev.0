From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [RFC 1/3] secid reconciliation on inbound
Date: Tue, 01 Aug 2006 17:08:26 -0500
Message-ID: <44CFD0DA.9060205@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, sds@tycho.nsa.gov, chanson@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:12366 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1751216AbWHAWIu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 18:08:50 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently a packet accumulates multiple security identifiers, each of a
different class, as it enters the system. This patch set reconciles these
identifiers into a single identifier while also allowing LSM (SELinux is
addressed in this patch set) to impose flow control checks based on the
identifiers.

The reconciliation steps for SELinux are explained in the Labeled Networking
document at:
http://marc.theaimsgroup.com/?l=linux-netdev&m=115136637800361&w=2

The following are the identifiers handled here:

1. secmark on the skb
2. xfrm security identifier associated with the skb if it used any xfrms,
   a zero secid otherwise.

This patch: Add new flask definitions to SELinux

Adds a new avperm "come_thru" to arbitrate among the identifiers on the
inbound (input/forward). Also adds a new avperm "go_thru" to enable flow
control checks on the outbound (output/forward), addressed in a later
patch.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 av_perm_to_string.h |    2 ++
 av_permissions.h    |    2 ++
 2 files changed, 4 insertions(+)

--- linux-2.6.17.child_sock/security/selinux/include/av_permissions.h	2006-07-31 09:36:24.000000000 -0500
+++ linux-2.6.17/security/selinux/include/av_permissions.h	2006-07-31 10:20:16.000000000 -0500
@@ -962,6 +962,8 @@
 #define PACKET__SEND                              0x00000001UL
 #define PACKET__RECV                              0x00000002UL
 #define PACKET__RELABELTO                         0x00000004UL
+#define PACKET__COME_THRU                         0x00000008UL
+#define PACKET__GO_THRU                           0x00000010UL
 
 #define KEY__VIEW                                 0x00000001UL
 #define KEY__READ                                 0x00000002UL
--- linux-2.6.17.child_sock/security/selinux/include/av_perm_to_string.h	2006-07-31 09:36:24.000000000 -0500
+++ linux-2.6.17/security/selinux/include/av_perm_to_string.h	2006-07-31 10:20:16.000000000 -0500
@@ -245,6 +245,8 @@
    S_(SECCLASS_PACKET, PACKET__SEND, "send")
    S_(SECCLASS_PACKET, PACKET__RECV, "recv")
    S_(SECCLASS_PACKET, PACKET__RELABELTO, "relabelto")
+   S_(SECCLASS_PACKET, PACKET__COME_THRU, "come_thru")
+   S_(SECCLASS_PACKET, PACKET__GO_THRU, "go_thru")
    S_(SECCLASS_KEY, KEY__VIEW, "view")
    S_(SECCLASS_KEY, KEY__READ, "read")
    S_(SECCLASS_KEY, KEY__WRITE, "write")
