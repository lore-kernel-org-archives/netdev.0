From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Fixed alg_key_len usage in attach_one_algo
Date: Thu, 19 May 2005 12:03:02 +1000
Message-ID: <20050519020302.GA20285@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="IS0zKkzwUGydFO0o"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This bug was discovered by a Linux box running in a remote corner
of Australia :)

The variable alg_key_len is in bits and not bytes.  The function
attach_one_algo is currently using it as if it were in bytes.
This causes it to read memory which may not be there.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-user-1

--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -162,6 +162,7 @@ static int attach_one_algo(struct xfrm_a
 	struct rtattr *rta = u_arg;
 	struct xfrm_algo *p, *ualg;
 	struct xfrm_algo_desc *algo;
+	int len;
 
 	if (!rta)
 		return 0;
@@ -173,11 +174,12 @@ static int attach_one_algo(struct xfrm_a
 		return -ENOSYS;
 	*props = algo->desc.sadb_alg_id;
 
-	p = kmalloc(sizeof(*ualg) + ualg->alg_key_len, GFP_KERNEL);
+	len = sizeof(*ualg) + (ualg->alg_key_len + 7U) / 8;
+	p = kmalloc(len, GFP_KERNEL);
 	if (!p)
 		return -ENOMEM;
 
-	memcpy(p, ualg, sizeof(*ualg) + ualg->alg_key_len);
+	memcpy(p, ualg, len);
 	*algpp = p;
 	return 0;
 }

--IS0zKkzwUGydFO0o--
