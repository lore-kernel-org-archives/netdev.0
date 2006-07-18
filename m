From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH FOR REFERENCE ONLY] MLSXFRM-v02: Add support to serefpolicy
Date: Tue, 18 Jul 2006 12:25:04 -0500
Message-ID: <44BD1970.7010207@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, latten@austin.ibm.com, sds@tycho.nsa.gov,
	tjaeger@cse.psu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:16006 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932319AbWGRRZc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 13:25:32 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch has been included here just for reference for anyone wanting to
try the patchset in enforcing mode. It will be submitted to the serefpolicy
list later.

This patch adds a polmatch avperm to arbitrate flow/state's access to
a xfrm policy. It also defines MLS policy for association { sendto,
recvfrom, polmatch }.

NOTE: When an inbound packet is not using an IPSec SA, a check is performed
between the socket label and the unlabeled sid (SYSTEM_HIGH MLS label). For
MLS purposes however, the target of the check should be the MLS label taken
from the node sid (or secmark in the new secmark world). This would present
a severe performance overhead (to make a new sid based on the unlabeled sid
with the MLS taken from the node sid or secmark and then using this sid as
the target). Pending reconciliation of the netlabel, ipsec and iptables contexts,
I have chosen to currently make an exception for unlabeled_t SAs if TE policy
allowed it. A similar problem exists for the outbound case and it has been similarly
handled in the policy below (by making an exception for unlabeled_t).

The mlsconstrains are from myself and the rest (sample/basic pieces to get
communication going without or with unlabeled IPSec) are from Joy Latten at IBM
(latten@austin.ibm.com).

diff -urpN serefpolicy-2.2.47.orig/policy/flask/access_vectors serefpolicy-2.2.47.diff/policy/flask/access_vectors
--- serefpolicy-2.2.47.orig/policy/flask/access_vectors	2006-07-11 05:15:39.000000000 -0500
+++ serefpolicy-2.2.47.diff/policy/flask/access_vectors	2006-07-11 07:43:37.000000000 -0500
@@ -602,6 +602,7 @@ class association
 	sendto
 	recvfrom
 	setcontext
+	polmatch
 }
 
 # Updated Netlink class for KOBJECT_UEVENT family.
diff -urpN serefpolicy-2.2.47.orig/policy/mls serefpolicy-2.2.47.diff/policy/mls
--- serefpolicy-2.2.47.orig/policy/mls	2006-07-11 05:15:39.000000000 -0500
+++ serefpolicy-2.2.47.diff/policy/mls	2006-07-11 07:44:23.000000000 -0500
@@ -671,4 +671,18 @@ mlsconstrain xinput { setattr relabelinp
 # these access vectors have no MLS restrictions
 # association *
 
+mlsconstrain association { recvfrom }
+        ((( l1 dom l2 ) and ( l1 domby h2 )) or
+         (( t1 == mlsnetreadtoclr ) and ( h1 dom l2 )) or
+         ( t1 == mlsnetread ) or
+         ( t2 == unlabeled_t ));
+
+mlsconstrain association { sendto }
+        ((( l1 dom l2 ) and ( l1 domby h2 )) or
+         ( t2 == unlabeled_t ));
+
+mlsconstrain association { polmatch }
+         ((( l1 dom l2 ) and ( h1 domby h2 )) or
+          ( t2 == unlabeled_t));
+
 ') dnl end enable_mls
diff -urpN serefpolicy-2.2.47.orig/policy/modules/kernel/kernel.if serefpolicy-2.2.47.diff/policy/modules/kernel/kernel.if
--- serefpolicy-2.2.47.orig/policy/modules/kernel/kernel.if	2006-07-11 05:15:39.000000000 -0500
+++ serefpolicy-2.2.47.diff/policy/modules/kernel/kernel.if	2006-07-14 04:29:32.000000000 -0500
@@ -2134,3 +2134,11 @@ interface(`kernel_dontaudit_list_all_pro
 	dontaudit $1 proc_type:dir list_dir_perms;
 	dontaudit $1 proc_type:file getattr;
 ')
+
+interface(`kernel_read_unlabeled_tcpsocket',`
+	gen_require(`
+		type unlabeled_t;
+	')
+
+	allow $1 unlabeled_t:tcp_socket { read write shutdown };
+')
diff -urpN serefpolicy-2.2.47.orig/policy/modules/kernel/kernel.te serefpolicy-2.2.47.diff/policy/modules/kernel/kernel.te
--- serefpolicy-2.2.47.orig/policy/modules/kernel/kernel.te	2006-07-11 05:15:39.000000000 -0500
+++ serefpolicy-2.2.47.diff/policy/modules/kernel/kernel.te	2006-07-14 04:28:18.000000000 -0500
@@ -332,6 +332,11 @@ optional_policy(`
 ifdef(`targeted_policy',`
 	allow unlabeled_t self:filesystem associate;
 ')
+# Joy
+allow unlabeled_t self:association *;
+corenet_tcp_sendrecv_generic_if(unlabeled_t)
+corenet_tcp_sendrecv_generic_node(unlabeled_t)
+corenet_tcp_sendrecv_generic_port(unlabeled_t)
 
 optional_policy(`
 	# If you load a new policy that removes active domains, processes can
diff -urpN serefpolicy-2.2.47.orig/policy/modules/system/unconfined.te serefpolicy-2.2.47.diff/policy/modules/system/unconfined.te
--- serefpolicy-2.2.47.orig/policy/modules/system/unconfined.te	2006-07-11 05:15:39.000000000 -0500
+++ serefpolicy-2.2.47.diff/policy/modules/system/unconfined.te	2006-07-14 04:32:33.000000000 -0500
@@ -29,6 +29,8 @@ unconfined_domain(unconfined_t)
 
 logging_send_syslog_msg(unconfined_t)
 
+kernel_read_unlabeled_tcpsocket(unconfined_t)
+
 ifdef(`targeted_policy',`
 	allow unconfined_t self:system syslog_read;
 	dontaudit unconfined_t self:capability sys_module;

