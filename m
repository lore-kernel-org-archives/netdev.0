From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [XFRM] Probe selected algorithm only
Date: Fri, 21 Jan 2005 21:19:38 +1100
Message-ID: <20050121101938.GA1133@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="G4iJoqBmSsgzjUCe"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This patch removes an annoying problem in xfrm_user.  As it is every
time an SA is added it probes every known algorithm in the universe.
Now if they all existed it would be OK.  However, for the ones which
don't actually exist this causes multiple /sbin/modprobe processes to
be spawned which slows the system down when you're adding hundreds of
SAs.

Since we know the type of algorithm required when we're adding a new
SA, we can get away with only probing the selected algorithms.  This
is what the following patch does for xfrm_user.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/linux/crypto.h 1.31 vs edited =====
--- 1.31/include/linux/crypto.h	2004-12-01 17:00:21 +11:00
+++ edited/include/linux/crypto.h	2005-01-21 21:11:45 +11:00
@@ -16,6 +16,7 @@
 #ifndef _LINUX_CRYPTO_H
 #define _LINUX_CRYPTO_H
 
+#include <linux/config.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
@@ -121,7 +122,14 @@
 /*
  * Algorithm query interface.
  */
+#ifdef CONFIG_CRYPTO
 int crypto_alg_available(const char *name, u32 flags);
+#else
+static inline int crypto_alg_available(const char *name, u32 flags)
+{
+	return 0;
+}
+#endif
 
 /*
  * Transforms: user-instantiated objects which encapsulate algorithms
===== include/net/xfrm.h 1.73 vs edited =====
--- 1.73/include/net/xfrm.h	2004-12-28 14:49:57 +11:00
+++ edited/include/net/xfrm.h	2005-01-21 21:02:36 +11:00
@@ -873,9 +873,9 @@
 extern struct xfrm_algo_desc *xfrm_aalg_get_byid(int alg_id);
 extern struct xfrm_algo_desc *xfrm_ealg_get_byid(int alg_id);
 extern struct xfrm_algo_desc *xfrm_calg_get_byid(int alg_id);
-extern struct xfrm_algo_desc *xfrm_aalg_get_byname(char *name);
-extern struct xfrm_algo_desc *xfrm_ealg_get_byname(char *name);
-extern struct xfrm_algo_desc *xfrm_calg_get_byname(char *name);
+extern struct xfrm_algo_desc *xfrm_aalg_get_byname(char *name, int probe);
+extern struct xfrm_algo_desc *xfrm_ealg_get_byname(char *name, int probe);
+extern struct xfrm_algo_desc *xfrm_calg_get_byname(char *name, int probe);
 
 struct crypto_tfm;
 typedef void (icv_update_fn_t)(struct crypto_tfm *, struct scatterlist *, unsigned int);
===== net/ipv4/ah4.c 1.40 vs edited =====
--- 1.40/net/ipv4/ah4.c	2004-08-22 15:00:07 +10:00
+++ edited/net/ipv4/ah4.c	2005-01-21 21:03:39 +11:00
@@ -236,7 +236,7 @@
 	 * we need for AH processing.  This lookup cannot fail here
 	 * after a successful crypto_alloc_tfm().
 	 */
-	aalg_desc = xfrm_aalg_get_byname(x->aalg->alg_name);
+	aalg_desc = xfrm_aalg_get_byname(x->aalg->alg_name, 0);
 	BUG_ON(!aalg_desc);
 
 	if (aalg_desc->uinfo.auth.icv_fullbits/8 !=
===== net/ipv4/esp4.c 1.54 vs edited =====
--- 1.54/net/ipv4/esp4.c	2004-08-22 15:00:07 +10:00
+++ edited/net/ipv4/esp4.c	2005-01-21 21:04:37 +11:00
@@ -392,7 +392,7 @@
 			goto error;
 		esp->auth.icv = esp_hmac_digest;
 
-		aalg_desc = xfrm_aalg_get_byname(x->aalg->alg_name);
+		aalg_desc = xfrm_aalg_get_byname(x->aalg->alg_name, 0);
 		BUG_ON(!aalg_desc);
 
 		if (aalg_desc->uinfo.auth.icv_fullbits/8 !=
===== net/ipv4/ipcomp.c 1.30 vs edited =====
--- 1.30/net/ipv4/ipcomp.c	2004-09-11 07:36:51 +10:00
+++ edited/net/ipv4/ipcomp.c	2005-01-21 21:04:40 +11:00
@@ -472,7 +472,7 @@
 			goto error_tunnel;
 	}
 
-	calg_desc = xfrm_calg_get_byname(x->calg->alg_name);
+	calg_desc = xfrm_calg_get_byname(x->calg->alg_name, 0);
 	BUG_ON(!calg_desc);
 	ipcd->threshold = calg_desc->uinfo.comp.threshold;
 	x->data = ipcd;
===== net/ipv6/ah6.c 1.41 vs edited =====
--- 1.41/net/ipv6/ah6.c	2004-08-22 15:00:07 +10:00
+++ edited/net/ipv6/ah6.c	2005-01-21 21:04:45 +11:00
@@ -375,7 +375,7 @@
 	 * we need for AH processing.  This lookup cannot fail here
 	 * after a successful crypto_alloc_tfm().
 	 */
-	aalg_desc = xfrm_aalg_get_byname(x->aalg->alg_name);
+	aalg_desc = xfrm_aalg_get_byname(x->aalg->alg_name, 0);
 	BUG_ON(!aalg_desc);
 
 	if (aalg_desc->uinfo.auth.icv_fullbits/8 !=
===== net/ipv6/esp6.c 1.37 vs edited =====
--- 1.37/net/ipv6/esp6.c	2004-08-22 15:00:07 +10:00
+++ edited/net/ipv6/esp6.c	2005-01-21 21:04:48 +11:00
@@ -329,7 +329,7 @@
 			goto error;
 		esp->auth.icv = esp_hmac_digest;
  
-		aalg_desc = xfrm_aalg_get_byname(x->aalg->alg_name);
+		aalg_desc = xfrm_aalg_get_byname(x->aalg->alg_name, 0);
 		BUG_ON(!aalg_desc);
  
 		if (aalg_desc->uinfo.auth.icv_fullbits/8 !=
===== net/ipv6/ipcomp6.c 1.19 vs edited =====
--- 1.19/net/ipv6/ipcomp6.c	2004-09-11 07:36:51 +10:00
+++ edited/net/ipv6/ipcomp6.c	2005-01-21 21:04:51 +11:00
@@ -468,7 +468,7 @@
 			goto error_tunnel;
 	}
 
-	calg_desc = xfrm_calg_get_byname(x->calg->alg_name);
+	calg_desc = xfrm_calg_get_byname(x->calg->alg_name, 0);
 	BUG_ON(!calg_desc);
 	ipcd->threshold = calg_desc->uinfo.comp.threshold;
 	x->data = ipcd;
===== net/xfrm/xfrm_algo.c 1.15 vs edited =====
--- 1.15/net/xfrm/xfrm_algo.c	2004-12-28 13:33:32 +11:00
+++ edited/net/xfrm/xfrm_algo.c	2005-01-21 21:17:12 +11:00
@@ -13,6 +13,7 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/pfkeyv2.h>
+#include <linux/crypto.h>
 #include <net/xfrm.h>
 #if defined(CONFIG_INET_AH) || defined(CONFIG_INET_AH_MODULE) || defined(CONFIG_INET6_AH) || defined(CONFIG_INET6_AH_MODULE)
 #include <net/ah.h>
@@ -346,58 +347,48 @@
 	return NULL;
 }
 
-struct xfrm_algo_desc *xfrm_aalg_get_byname(char *name)
+static struct xfrm_algo_desc *xfrm_get_byname(struct xfrm_algo_desc *list,
+					      int entries, char *name,
+					      int probe)
 {
-	int i;
+	int i, status;
 
 	if (!name)
 		return NULL;
 
-	for (i=0; i < aalg_entries(); i++) {
-		if (strcmp(name, aalg_list[i].name) == 0) {
-			if (aalg_list[i].available)
-				return &aalg_list[i];
-			else
-				break;
-		}
+	for (i = 0; i < entries; i++) {
+		if (!strcmp(name, list[i].name))
+			continue;
+
+		if (list[i].available)
+			return &list[i];
+
+		if (!probe)
+			break;
+
+		status = crypto_alg_available(name, 0);
+		if (!status)
+			break;
+
+		list[i].available = status;
+		return &list[i];
 	}
 	return NULL;
 }
 
-struct xfrm_algo_desc *xfrm_ealg_get_byname(char *name)
+struct xfrm_algo_desc *xfrm_aalg_get_byname(char *name, int probe)
 {
-	int i;
-
-	if (!name)
-		return NULL;
-
-	for (i=0; i < ealg_entries(); i++) {
-		if (strcmp(name, ealg_list[i].name) == 0) {
-			if (ealg_list[i].available)
-				return &ealg_list[i];
-			else
-				break;
-		}
-	}
-	return NULL;
+	return xfrm_get_byname(aalg_list, aalg_entries(), name, probe);
 }
 
-struct xfrm_algo_desc *xfrm_calg_get_byname(char *name)
+struct xfrm_algo_desc *xfrm_ealg_get_byname(char *name, int probe)
 {
-	int i;
-
-	if (!name)
-		return NULL;
+	return xfrm_get_byname(ealg_list, ealg_entries(), name, probe);
+}
 
-	for (i=0; i < calg_entries(); i++) {
-		if (strcmp(name, calg_list[i].name) == 0) {
-			if (calg_list[i].available)
-				return &calg_list[i];
-			else
-				break;
-		}
-	}
-	return NULL;
+struct xfrm_algo_desc *xfrm_calg_get_byname(char *name, int probe)
+{
+	return xfrm_get_byname(calg_list, calg_entries(), name, probe);
 }
 
 struct xfrm_algo_desc *xfrm_aalg_get_byidx(unsigned int idx)
===== net/xfrm/xfrm_user.c 1.51 vs edited =====
--- 1.51/net/xfrm/xfrm_user.c	2004-12-28 13:33:32 +11:00
+++ edited/net/xfrm/xfrm_user.c	2005-01-21 21:05:50 +11:00
@@ -156,7 +156,7 @@
 }
 
 static int attach_one_algo(struct xfrm_algo **algpp, u8 *props,
-			   struct xfrm_algo_desc *(*get_byname)(char *),
+			   struct xfrm_algo_desc *(*get_byname)(char *, int),
 			   struct rtattr *u_arg)
 {
 	struct rtattr *rta = u_arg;
@@ -168,7 +168,7 @@
 
 	ualg = RTA_DATA(rta);
 
-	algo = get_byname(ualg->alg_name);
+	algo = get_byname(ualg->alg_name, 1);
 	if (!algo)
 		return -ENOSYS;
 	*props = algo->desc.sadb_alg_id;
@@ -272,8 +272,6 @@
 	err = verify_newsa_info(p, (struct rtattr **) xfrma);
 	if (err)
 		return err;
-
-	xfrm_probe_algs();
 
 	x = xfrm_state_construct(p, (struct rtattr **) xfrma, &err);
 	if (!x)

--G4iJoqBmSsgzjUCe--
