From: Joy Latten <latten@austin.ibm.com>
Subject: [PATCH]: Add security check before flushing SAD/SPD
Date: Thu, 22 Mar 2007 12:35:39 -0600
Message-ID: <200703221835.l2MIZdDw007850@faith.austin.ibm.com>
Cc: davem@davemloft.net, jmorris@namei.org, vyekkirala@trustedcs.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:45007 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934186AbXCVSwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 14:52:02 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l2MIoFEm008950
	for <netdev@vger.kernel.org>; Thu, 22 Mar 2007 14:50:15 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2MIq1U4054268
	for <netdev@vger.kernel.org>; Thu, 22 Mar 2007 12:52:01 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2MIq0QU026527
	for <netdev@vger.kernel.org>; Thu, 22 Mar 2007 12:52:01 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Within selinux we check for authorization before deleting entries from
SAD and SPD. 

We are not checking for authorization when flushing the SPD and
the SAD. It was perhaps missed in original patch.

This patch adds security check when flushing entries from SAD and SPD.

Please let me know if this patch is ok.
It was built against linux-2.6.21-rc4-git5. I have also tested it.

Joy

Signed-off-by: Joy Latten<latten@austin.ibm.com>


diff -urpN linux-2.6.20.orig/net/xfrm/xfrm_policy.c linux-2.6.20/net/xfrm/xfrm_policy.c
--- linux-2.6.20.orig/net/xfrm/xfrm_policy.c	2007-03-21 14:25:51.000000000 -0500
+++ linux-2.6.20/net/xfrm/xfrm_policy.c	2007-03-21 14:30:59.000000000 -0500
@@ -829,6 +829,8 @@ void xfrm_policy_flush(u8 type, struct x
 				     &xfrm_policy_inexact[dir], bydst) {
 			if (pol->type != type)
 				continue;
+			if (security_xfrm_policy_delete(pol))
+				continue;
 			hlist_del(&pol->bydst);
 			hlist_del(&pol->byidx);
 			write_unlock_bh(&xfrm_policy_lock);
@@ -850,6 +852,8 @@ void xfrm_policy_flush(u8 type, struct x
 					     bydst) {
 				if (pol->type != type)
 					continue;
+				if (security_xfrm_policy_delete(pol))
+					continue;
 				hlist_del(&pol->bydst);
 				hlist_del(&pol->byidx);
 				write_unlock_bh(&xfrm_policy_lock);
diff -urpN linux-2.6.20.orig/net/xfrm/xfrm_state.c linux-2.6.20/net/xfrm/xfrm_state.c
--- linux-2.6.20.orig/net/xfrm/xfrm_state.c	2007-03-21 14:25:51.000000000 -0500
+++ linux-2.6.20/net/xfrm/xfrm_state.c	2007-03-21 14:27:48.000000000 -0500
@@ -400,7 +400,8 @@ void xfrm_state_flush(u8 proto, struct x
 restart:
 		hlist_for_each_entry(x, entry, xfrm_state_bydst+i, bydst) {
 			if (!xfrm_state_kern(x) &&
-			    xfrm_id_proto_match(x->id.proto, proto)) {
+			    xfrm_id_proto_match(x->id.proto, proto) &&
+			    !security_xfrm_state_delete(x)) {
 				xfrm_state_hold(x);
 				spin_unlock_bh(&xfrm_state_lock);
 
