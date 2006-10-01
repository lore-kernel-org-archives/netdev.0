From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 1/9] secid reconciliation-v04
Date: Sun, 01 Oct 2006 16:26:20 -0500
Message-ID: <4520327C.7080506@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, jmorris@namei.org, sds@tycho.nsa.gov,
	paul.moore@hp.com, eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:31844 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932395AbWJAV0s
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Oct 2006 17:26:48 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset helps with leveraging secmark in defining fine-grained security
check points with support for a. a default place holder domain defined using
secmark for each of the check points and b. flow control and reconciliation
of domains entering/leaving the system.

The reconciliation steps for SELinux are explained in the Labeled Networking
document at:
http://marc.theaimsgroup.com/?l=linux-netdev&m=115136637800361&w=2

Also please refer to the discussion at:
http://marc.theaimsgroup.com/?l=selinux&m=115885031311565&w=2

The following are the identifiers handled here:

1. secmark on the skb
2. xfrm security identifier associated with the skb if it used any xfrms,
 a zero secid otherwise.

The following features are included:

- Retain secmark (from the originating socket/flow) on loopback traffic;
  this traffic is now flow controlled on the outbound only.

- When multiple iptables labeling rules are present (e.g.: both on PREROUTING and INPUT)
	INBOUND: The label in the last rule will prevail.
	OUTBOUND: secmark (from the originating socket) is flow-controlled against
		the label on the first rule, and, if it passes, the label on the
		first rule overrides the secmark (from the originating socket).
		This secmark is flow controlled against labels on the subsequent
		rules, each time, overridden by those labels.

- Forwarded packets: The FORWARD chain is treated as an outbound chain for flow
  control purposes. e.g: label with PREROUTING and flow-control with FORWARD or
  POSTROUTING.

- SELinux postroute_last hook: unfortunately, the secmark Vs. UNLABELED SID check
  will be done for ALL traffic (couldn't figure out a way to except traffic already
  processed by (CONN)SECMARK outbound rules).


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
