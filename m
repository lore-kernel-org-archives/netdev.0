From: baker.kernel@gmail.com
Subject: [PATCH net-next] xfrm: check function pointer of xfrm_mgr before use it
Date: Sun, 10 Nov 2013 22:25:56 +0800
Message-ID: <1384093556-8987-1-git-send-email-baker.kernel@gmail.com>
Cc: netdev@vger.kernel.org, "baker.zhang" <baker.kernel@gmail.com>
To: herbert@gondor.apana.org.au, davem@davemloft.net,
	steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:64965 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425Ab3KJO0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Nov 2013 09:26:25 -0500
Received: by mail-pb0-f47.google.com with SMTP id rq2so1219870pbb.34
        for <netdev@vger.kernel.org>; Sun, 10 Nov 2013 06:26:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "baker.zhang" <baker.kernel@gmail.com>

Signed-off-by: baker.zhang <baker.kernel@gmail.com>
---
For current kernel source, there is no problem.

In our vpn product, we need a xfrm_km in kernel module
to monitor the xfrm state change.
thus, the 'acquire' and 'compile_policy' may be NULL.

So I think we should do the check before use it.

 net/xfrm/xfrm_state.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index b9c3f9e..541f684 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1679,9 +1679,11 @@ int km_query(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *pol)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(km, &xfrm_km_list, list) {
-		acqret = km->acquire(x, t, pol);
-		if (!acqret)
-			err = acqret;
+		if (km->acquire) {
+			acqret = km->acquire(x, t, pol);
+			if (!acqret)
+				err = acqret;
+		}
 	}
 	rcu_read_unlock();
 	return err;
@@ -1783,10 +1785,12 @@ int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optval, int optlen
 	err = -EINVAL;
 	rcu_read_lock();
 	list_for_each_entry_rcu(km, &xfrm_km_list, list) {
-		pol = km->compile_policy(sk, optname, data,
-					 optlen, &err);
-		if (err >= 0)
-			break;
+		if (km->compile_policy) {
+			pol = km->compile_policy(sk, optname, data,
+					optlen, &err);
+			if (err >= 0)
+				break;
+		}
 	}
 	rcu_read_unlock();
 
-- 
1.8.3.2
