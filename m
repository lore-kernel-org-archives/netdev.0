From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/6] xfrm: Oops on error in pfkey_msg2xfrm_state()
Date: Fri, 23 Jun 2017 09:06:31 +0200
Message-ID: <1498201594-10835-4-git-send-email-steffen.klassert@secunet.com>
References: <1498201594-10835-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:47052 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750902AbdFWHGn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Jun 2017 03:06:43 -0400
In-Reply-To: <1498201594-10835-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>

There are some missing error codes here so we accidentally return NULL
instead of an error pointer.  It results in a NULL pointer dereference.

Fixes: df71837d5024 ("[LSM-IPSec]: Security association restriction.")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/key/af_key.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 5103f92..2b82ada 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1168,8 +1168,10 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
 		if (key)
 			keysize = (key->sadb_key_bits + 7) / 8;
 		x->aalg = kmalloc(sizeof(*x->aalg) + keysize, GFP_KERNEL);
-		if (!x->aalg)
+		if (!x->aalg) {
+			err = -ENOMEM;
 			goto out;
+		}
 		strcpy(x->aalg->alg_name, a->name);
 		x->aalg->alg_key_len = 0;
 		if (key) {
@@ -1188,8 +1190,10 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
 				goto out;
 			}
 			x->calg = kmalloc(sizeof(*x->calg), GFP_KERNEL);
-			if (!x->calg)
+			if (!x->calg) {
+				err = -ENOMEM;
 				goto out;
+			}
 			strcpy(x->calg->alg_name, a->name);
 			x->props.calgo = sa->sadb_sa_encrypt;
 		} else {
@@ -1203,8 +1207,10 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
 			if (key)
 				keysize = (key->sadb_key_bits + 7) / 8;
 			x->ealg = kmalloc(sizeof(*x->ealg) + keysize, GFP_KERNEL);
-			if (!x->ealg)
+			if (!x->ealg) {
+				err = -ENOMEM;
 				goto out;
+			}
 			strcpy(x->ealg->alg_name, a->name);
 			x->ealg->alg_key_len = 0;
 			if (key) {
@@ -1249,8 +1255,10 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
 		struct xfrm_encap_tmpl *natt;
 
 		x->encap = kmalloc(sizeof(*x->encap), GFP_KERNEL);
-		if (!x->encap)
+		if (!x->encap) {
+			err = -ENOMEM;
 			goto out;
+		}
 
 		natt = x->encap;
 		n_type = ext_hdrs[SADB_X_EXT_NAT_T_TYPE-1];
-- 
2.7.4
