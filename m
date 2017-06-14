From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH] xfrm: Oops on error in pfkey_msg2xfrm_state()
Date: Wed, 14 Jun 2017 13:34:05 +0300
Message-ID: <20170614103405.GI29394@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:36005 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750728AbdFNKea (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 06:34:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some missing error codes here so we accidentally return NULL
instead of an error pointer.  It results in a NULL pointer dereference.

Fixes: df71837d5024 ("[LSM-IPSec]: Security association restriction.")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
This goes through Steffen's tree I presume.  It aplies to net.

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 86051b5879f2..0fa678fa3b73 100644
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
