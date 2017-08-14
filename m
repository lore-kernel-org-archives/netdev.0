From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] tcp: ulp: avoid module refcnt leak in tcp_set_ulp
Date: Mon, 14 Aug 2017 18:04:24 +0200
Message-ID: <776711b75a664f4a61da8d32eab15d3e794cabe7.1502725540.git.sd@queasysnail.net>
Cc: Sabrina Dubroca <sd@queasysnail.net>,
        Dave Watson <davejwatson@fb.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Tom Herbert <tom@quantonium.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56312 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751441AbdHNQFA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 12:05:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__tcp_ulp_find_autoload returns tcp_ulp_ops after taking a reference on
the module. Then, if ->init fails, tcp_set_ulp propagates the error but
nothing releases that reference.

Fixes: 734942cc4ea6 ("tcp: ULP infrastructure")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
Tom, the generalized ULP version has the same problem in ulp_set().

 net/ipv4/tcp_ulp.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_ulp.c b/net/ipv4/tcp_ulp.c
index 2417f55374c5..6bb9e14c710a 100644
--- a/net/ipv4/tcp_ulp.c
+++ b/net/ipv4/tcp_ulp.c
@@ -122,14 +122,14 @@ int tcp_set_ulp(struct sock *sk, const char *name)
 
 	ulp_ops = __tcp_ulp_find_autoload(name);
 	if (!ulp_ops)
-		err = -ENOENT;
-	else
-		err = ulp_ops->init(sk);
+		return -ENOENT;
 
-	if (err)
-		goto out;
+	err = ulp_ops->init(sk);
+	if (err) {
+		module_put(ulp_ops->owner);
+		return err;
+	}
 
 	icsk->icsk_ulp_ops = ulp_ops;
- out:
-	return err;
+	return 0;
 }
-- 
2.14.0
