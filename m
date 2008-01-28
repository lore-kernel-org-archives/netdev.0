From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH][INET_DIAG]: Fix inet_diag_lock_handler error path
Date: Mon, 28 Jan 2008 00:20:50 -0200
Message-ID: <20080128022050.GQ27661@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, spike@ml.yaroslavl.ru,
	netdev@vger.kernel.org, stable@kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53586 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752449AbYA1CVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jan 2008 21:21:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: http://bugzilla.kernel.org/show_bug.cgi?id=9825

The inet_diag_lock_handler function uses ERR_PTR to encode errors but
its callers were testing against NULL.

This only happens when the only inet_diag modular user, DCCP, is not
built into the kernel or available as a module.

Also there was a problem with not dropping the mutex lock when a handler
was not found, also fixed in this patch.

This caused an OOPS and ss would then hang on subsequent calls, as
&inet_diag_table_mutex was being left locked.

Thanks to spike at ml.yaroslavl.ru for report it after trying 'ss -d'
on a kernel that doesn't have DCCP available.

This bug was introduced in cset
d523a328fb0271e1a763e985a21f2488fd816e7e, after 2.6.24-rc3, so just
2.6.24 seems to be affected.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index e468e7a..6d2979c 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -259,8 +259,10 @@ static int inet_diag_get_exact(struct sk_buff *in_skb,
 	const struct inet_diag_handler *handler;
 
 	handler = inet_diag_lock_handler(nlh->nlmsg_type);
-	if (!handler)
-		return -ENOENT;
+	if (IS_ERR(handler)) {
+		err = PTR_ERR(handler);
+		goto unlock;
+	}
 
 	hashinfo = handler->idiag_hashinfo;
 	err = -EINVAL;
@@ -708,8 +710,8 @@ static int inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	struct inet_hashinfo *hashinfo;
 
 	handler = inet_diag_lock_handler(cb->nlh->nlmsg_type);
-	if (!handler)
-		goto no_handler;
+	if (IS_ERR(handler))
+		goto unlock;
 
 	hashinfo = handler->idiag_hashinfo;
 
@@ -838,7 +840,6 @@ done:
 	cb->args[2] = num;
 unlock:
 	inet_diag_unlock_handler(handler);
-no_handler:
 	return skb->len;
 }
 
