From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 3/3] Fix for IPsec leakage with SELinux enabled - V.04: Process
 security errors for scket policies also
Date: Mon, 09 Oct 2006 11:24:53 -0500
Message-ID: <452A77D5.1040803@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, sds@tycho.nsa.gov, netdev@vger.kernel.org,
	paul.moore@hp.com, eparis@redhat.com, sgrubb@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:5005 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932967AbWJIQZg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Oct 2006 12:25:36 -0400
To: davem@davemloft.net
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

--- net-2.6.leak2/net/xfrm/xfrm_policy.c	2006-10-09 10:50:32.000000000 -0500
+++ net-2.6.leak3/net/xfrm/xfrm_policy.c	2006-10-09 10:51:01.000000000 -0500
@@ -1016,12 +1016,16 @@ static struct xfrm_policy *xfrm_sk_polic
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
@@ -1313,8 +1317,11 @@ restart:
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
@@ -1607,8 +1614,11 @@ int __xfrm_policy_check(struct sock *sk,
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
