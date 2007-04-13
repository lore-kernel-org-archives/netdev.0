From: Joy Latten <latten@austin.ibm.com>
Subject: PATCH[1/1]: kernel panic when large security contexts in ACQUIRE
Date: Fri, 13 Apr 2007 10:04:47 -0500
Message-ID: <200704131504.l3DF4lYF031824@faith.austin.ibm.com>
Cc: davem@davemloft.net, jmorris@namei.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:43156 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754042AbXDMPVq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Apr 2007 11:21:46 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l3DFLj4G031338
	for <netdev@vger.kernel.org>; Fri, 13 Apr 2007 11:21:45 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l3DFLjl7225922
	for <netdev@vger.kernel.org>; Fri, 13 Apr 2007 11:21:45 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l3DFLjuu003596
	for <netdev@vger.kernel.org>; Fri, 13 Apr 2007 11:21:45 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When sending a security context of 50+ characters in an ACQUIRE 
message, following kernel panic occurred.

kernel BUG in xfrm_send_acquire at net/xfrm/xfrm_user.c:1781!
cpu 0x3: Vector: 700 (Program Check) at [c0000000421bb2e0]
    pc: c00000000033b074: .xfrm_send_acquire+0x240/0x2c8
    lr: c00000000033b014: .xfrm_send_acquire+0x1e0/0x2c8
    sp: c0000000421bb560
   msr: 8000000000029032
  current = 0xc00000000fce8f00
  paca    = 0xc000000000464b00
    pid   = 2303, comm = ping
kernel BUG in xfrm_send_acquire at net/xfrm/xfrm_user.c:1781!
enter ? for help
3:mon> t
[c0000000421bb650] c00000000033538c .km_query+0x6c/0xec
[c0000000421bb6f0] c000000000337374 .xfrm_state_find+0x7f4/0xb88
[c0000000421bb7f0] c000000000332350 .xfrm_tmpl_resolve+0xc4/0x21c
[c0000000421bb8d0] c0000000003326e8 .xfrm_lookup+0x1a0/0x5b0
[c0000000421bba00] c0000000002e6ea0 .ip_route_output_flow+0x88/0xb4
[c0000000421bbaa0] c0000000003106d8 .ip4_datagram_connect+0x218/0x374
[c0000000421bbbd0] c00000000031bc00 .inet_dgram_connect+0xac/0xd4
[c0000000421bbc60] c0000000002b11ac .sys_connect+0xd8/0x120
[c0000000421bbd90] c0000000002d38d0 .compat_sys_socketcall+0xdc/0x214
[c0000000421bbe30] c00000000000869c syscall_exit+0x0/0x40
--- Exception: c00 (System Call) at 0000000007f0ca9c
SP (fc0ef8f0) is in userspace


We are using size of security context from xfrm_policy to determine
how much space to alloc skb and then putting security context from
xfrm_state into skb. Should have been using size of security context 
from xfrm_state to alloc skb. Following fix does that

Please let me know if this is acceptable.
Patch was built and tested against 2.6.21-rc6-git5. 

Regards,
Joy

Signed-off-by: Joy Latten <latten@austin.ibm.com>


diff -urpN linux-2.6.20/net/xfrm/xfrm_user.c linux-2.6.20.patch/net/xfrm/xfrm_user.c
--- linux-2.6.20/net/xfrm/xfrm_user.c	2007-04-12 15:12:27.000000000 -0500
+++ linux-2.6.20.patch/net/xfrm/xfrm_user.c	2007-04-13 09:32:35.000000000 -0500
@@ -272,9 +272,8 @@ static int attach_encap_tmpl(struct xfrm
 }
 
 
-static inline int xfrm_user_sec_ctx_size(struct xfrm_policy *xp)
+static inline int xfrm_user_sec_ctx_size(struct xfrm_sec_ctx *xfrm_ctx)
 {
-	struct xfrm_sec_ctx *xfrm_ctx = xp->security;
 	int len = 0;
 
 	if (xfrm_ctx) {
@@ -2170,7 +2169,7 @@ static int xfrm_send_acquire(struct xfrm
 
 	len = RTA_SPACE(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
 	len += NLMSG_SPACE(sizeof(struct xfrm_user_acquire));
-	len += RTA_SPACE(xfrm_user_sec_ctx_size(xp));
+	len += RTA_SPACE(xfrm_user_sec_ctx_size(x->security));
 #ifdef CONFIG_XFRM_SUB_POLICY
 	len += RTA_SPACE(sizeof(struct xfrm_userpolicy_type));
 #endif
@@ -2280,7 +2279,7 @@ static int xfrm_exp_policy_notify(struct
 
 	len = RTA_SPACE(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
 	len += NLMSG_SPACE(sizeof(struct xfrm_user_polexpire));
-	len += RTA_SPACE(xfrm_user_sec_ctx_size(xp));
+	len += RTA_SPACE(xfrm_user_sec_ctx_size(xp->security));
 #ifdef CONFIG_XFRM_SUB_POLICY
 	len += RTA_SPACE(sizeof(struct xfrm_userpolicy_type));
 #endif
