From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 3/3] Fix for IPsec leakage with SELinux enabled - V.03: Process
 security errors for scket policies also
Date: Thu, 05 Oct 2006 15:42:35 -0500
Message-ID: <45256E3B.7070508@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, jmorris@namei.org, sds@tycho.nsa.gov,
	eparis@redhat.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:31420 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932127AbWJEUnz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 16:43:55 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This treats the security errors encountered in the case of
socket policy matching, the same as how these are treated in
the case of main/sub policies, which is to return a full lookup
failure.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 net/xfrm/xfrm_policy.c |   26 ++++++++++++++++++--------
 1 file changed, 18 insertions(+), 8 deletions(-)

--- net-2.6.sid5/net/xfrm/xfrm_policy.c	2006-10-05 14:36:07.000000000 -0500
+++ net-2.6/net/xfrm/xfrm_policy.c	2006-10-05 14:38:32.000000000 -0500
@@ -1013,12 +1013,16 @@ static struct xfrm_policy *xfrm_sk_polic
 						sk->sk_family);
  		int err = 0;
 
-		if (match)
-		  err = security_xfrm_policy_lookup(pol, fl->secid, policy_to_flow_dir(dir));
-
- 		if (match && !err)
-			xfrm_pol_hold(pol);
-		else
+		if (match) {
+			err = security_xfrm_policy_lookup(pol, fl->secid,
+					policy_to_flow_dir(dir));
+			if (!err)
+				xfrm_pol_hold(pol);
+			else if (err == -ESRCH)
+				pol = NULL;
+			else
+				pol = ERR_PTR(err);
+		} else
 			pol = NULL;
 	}
 	read_unlock_bh(&xfrm_policy_lock);
@@ -1310,8 +1314,11 @@ restart:
 	pol_dead = 0;
 	xfrm_nr = 0;
 
-	if (sk && sk->sk_policy[1])
+	if (sk && sk->sk_policy[1]) {
 		policy = xfrm_sk_policy_lookup(sk, XFRM_POLICY_OUT, fl);
+		if (IS_ERR(policy))
+			return PTR_ERR(policy);
+	}
 
 	if (!policy) {
 		/* To accelerate a bit...  */
@@ -1604,8 +1611,11 @@ int __xfrm_policy_check(struct sock *sk,
 	}
 
 	pol = NULL;
-	if (sk && sk->sk_policy[dir])
+	if (sk && sk->sk_policy[dir]) {
 		pol = xfrm_sk_policy_lookup(sk, dir, &fl);
+		if (IS_ERR(pol))
+			return 0;
+	}
 
 	if (!pol)
 		pol = flow_cache_lookup(&fl, family, fl_dir,
