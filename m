From: James Morris <jmorris@namei.org>
Subject: [PATCH] xfrm: remove xerr_idxp from __xfrm_policy_check()
Date: Fri, 1 Sep 2006 01:01:18 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609010054280.22977@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.sea5.speakeasy.net ([69.17.117.8]:8077 "EHLO
	mail6.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932152AbWIAFBV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 01:01:21 -0400
Received: from megaweapon.nightmoose.net (HELO d.namei) ([66.92.66.197])
          (envelope-sender <jmorris@namei.org>)
          by mail6.sea5.speakeasy.net (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 1 Sep 2006 05:01:20 -0000
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It seems that during the MIPv6 respin, some code which was originally 
conditionally compiled around CONFIG_XFRM_ADVANCED was accidently left in 
after the config option was removed.

This patch removes an extraneous pointer (xerr_idxp) which is no longer 
needed.

Please review & apply.

Signed-off-by: James Morris <jmorris@namei.org>

---

 net/xfrm/xfrm_policy.c |   13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff -purN -X dontdiff net-2.6.19.o/net/xfrm/xfrm_policy.c net-2.6.19.x/net/xfrm/xfrm_policy.c
--- net-2.6.19.o/net/xfrm/xfrm_policy.c	2006-08-30 00:31:38.000000000 -0400
+++ net-2.6.19.x/net/xfrm/xfrm_policy.c	2006-09-01 00:40:25.000000000 -0400
@@ -1514,8 +1514,7 @@ static inline int secpath_has_nontranspo
 {
 	for (; k < sp->len; k++) {
 		if (sp->xvec[k]->props.mode != XFRM_MODE_TRANSPORT) {
-			if (idxp)
-				*idxp = k;
+			*idxp = k;
 			return 1;
 		}
 	}
@@ -1534,7 +1533,6 @@ int __xfrm_policy_check(struct sock *sk,
 	struct flowi fl;
 	u8 fl_dir = policy_to_flow_dir(dir);
 	int xerr_idx = -1;
-	int *xerr_idxp = &xerr_idx;
 
 	if (xfrm_decode_session(skb, &fl, family) < 0)
 		return 0;
@@ -1560,7 +1558,7 @@ int __xfrm_policy_check(struct sock *sk,
 					xfrm_policy_lookup);
 
 	if (!pol) {
-		if (skb->sp && secpath_has_nontransport(skb->sp, 0, xerr_idxp)) {
+		if (skb->sp && secpath_has_nontransport(skb->sp, 0, &xerr_idx)) {
 			xfrm_secpath_reject(xerr_idx, skb, &fl);
 			return 0;
 		}
@@ -1619,13 +1617,14 @@ int __xfrm_policy_check(struct sock *sk,
 		for (i = xfrm_nr-1, k = 0; i >= 0; i--) {
 			k = xfrm_policy_ok(tpp[i], sp, k, family);
 			if (k < 0) {
-				if (k < -1 && xerr_idxp)
-					*xerr_idxp = -(2+k);
+				if (k < -1)
+					/* "-2 - errored_index" returned */
+					xerr_idx = -(2+k);
 				goto reject;
 			}
 		}
 
-		if (secpath_has_nontransport(sp, k, xerr_idxp))
+		if (secpath_has_nontransport(sp, k, &xerr_idx))
 			goto reject;
 
 		xfrm_pols_put(pols, npols);
