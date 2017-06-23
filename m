From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/6] xfrm: NULL dereference on allocation failure
Date: Fri, 23 Jun 2017 09:06:32 +0200
Message-ID: <1498201594-10835-5-git-send-email-steffen.klassert@secunet.com>
References: <1498201594-10835-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:47086 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751366AbdFWHGo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Jun 2017 03:06:44 -0400
In-Reply-To: <1498201594-10835-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>

The default error code in pfkey_msg2xfrm_state() is -ENOBUFS.  We
added a new call to security_xfrm_state_alloc() which sets "err" to zero
so there several places where we can return ERR_PTR(0) if kmalloc()
fails.  The caller is expecting error pointers so it leads to a NULL
dereference.

Fixes: df71837d5024 ("[LSM-IPSec]: Security association restriction.")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/key/af_key.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 2b82ada..b1432b6 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1157,6 +1157,7 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
 			goto out;
 	}
 
+	err = -ENOBUFS;
 	key = ext_hdrs[SADB_EXT_KEY_AUTH - 1];
 	if (sa->sadb_sa_auth) {
 		int keysize = 0;
-- 
2.7.4
