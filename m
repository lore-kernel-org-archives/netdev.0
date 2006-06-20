From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: FOR REFERENCE ONLY: MLSXFRM: Add support to serefpolicy
Date: Tue, 20 Jun 2006 13:24:23 -0500
Message-ID: <44983D57.4050704@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:59254 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1750792AbWFTSYc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 14:24:32 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch has been included here just for reference. It will be submitted
to the serefpolicy list later.

This patch adds a polmatch avperm to arbitrate flow/state's access to
a xfrm policy. It also defines MLS policy for association { sendto,
recvfrom, polmatch }.

NOTE: When an inbound packet is not using an IPSec SA, a check is performed
between the socket label and the unlabeled sid (SYSTEM_HIGH MLS label). For
MLS purposes however, the target of the check should be the MLS label taken
from the node sid (or secmark in the new secmark world). This would present
a severe performance overhead (to make a new sid based on the unlabeled sid
with the MLS taken from the node sid or secmark and then using this sid as
the target). While discussions are ongoing on fine tuning the networking
design in the context of secmark, IPSec, netlabel, etc., I have chosen to
currently make an exception for unlabeled_t SAs if TE policy allowed it. A
similar problem exists for the outbound case and it has been similarly
handled in the policy below (by making an exception for unlabeled_t).



--- serefpolicy-2.2.34/policy/mls       2006-04-20 07:18:44.000000000 -0500
+++ serefpolicy-2.2.34.ipsec/policy/mls 2006-05-11 10:04:29.000000000 -0500
@@ -671,4 +671,18 @@
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
+         (( l1 dom l2 ) and ( h1 domby h2 ));
+
+
 ') dnl end enable_mls
--- serefpolicy-2.2.34/policy/flask/access_vectors      2006-04-20 07:18:44.000000000 -0500
+++ serefpolicy-2.2.34.ipsec/policy/flask/access_vectors        2006-04-27 10:34:44.000000000 -0500
@@ -602,6 +602,7 @@
        sendto
        recvfrom
        setcontext
+       polmatch
 }

 # Updated Netlink class for KOBJECT_UEVENT family.
