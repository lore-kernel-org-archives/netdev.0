From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [ESP] Only one algorithm is required
Date: Sat, 14 Aug 2004 20:48:07 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040814104807.GA20572@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="tKW2IUtsqtDRztdT"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--tKW2IUtsqtDRztdT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

In a previous, I moved the encap_type checks in esp4.c from the packet
processing path to xfrm_user/af_key.  This isn't ideal since those encap
types only make sense for esp4.

The following patch moves it back into esp4.c.  The difference is
that it's now done in init_state so that it's only done once rather
than per-packet.

I've also added encap_type checks for every transform.  This means
that people attaching encap objects to AH/IPCOMP/IPIP will now get
errors.  That should be fine as no major KM does this.

Please note that the error returned is now EINVAL instead of
ENOPROTOOPT.  This shouldn't break anything since KMs only test
the errno from setsockopt() for NAT-T support rather than add_sa
where it would be too late anyway.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--tKW2IUtsqtDRztdT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=encap-check

===== net/ipv4/ah4.c 1.39 vs edited =====
--- 1.39/net/ipv4/ah4.c	2004-08-02 17:53:26 +10:00
+++ edited/net/ipv4/ah4.c	2004-08-12 19:37:27 +10:00
@@ -214,6 +214,9 @@
 	if (x->aalg->alg_key_len > 512)
 		goto error;
 
+	if (x->encap)
+		goto error;
+
 	ahp = kmalloc(sizeof(*ahp), GFP_KERNEL);
 	if (ahp == NULL)
 		return -ENOMEM;
===== net/ipv4/esp4.c 1.54 vs edited =====
--- 1.54/net/ipv4/esp4.c	2004-08-02 17:53:26 +10:00
+++ edited/net/ipv4/esp4.c	2004-08-12 19:47:07 +10:00
@@ -436,6 +436,7 @@
 
 		switch (encap->encap_type) {
 		default:
+			goto error;
 		case UDP_ENCAP_ESPINUDP:
 			x->props.header_len += sizeof(struct udphdr);
 			break;
@@ -449,15 +450,9 @@
 	return 0;
 
 error:
-	if (esp) {
-		if (esp->auth.tfm)
-			crypto_free_tfm(esp->auth.tfm);
-		if (esp->auth.work_icv)
-			kfree(esp->auth.work_icv);
-		if (esp->conf.tfm)
-			crypto_free_tfm(esp->conf.tfm);
-		kfree(esp);
-	}
+	x->data = esp;
+	esp_destroy(x);
+	x->data = NULL;
 	return -EINVAL;
 }
 
===== net/ipv4/ipcomp.c 1.29 vs edited =====
--- 1.29/net/ipv4/ipcomp.c	2004-08-02 17:53:26 +10:00
+++ edited/net/ipv4/ipcomp.c	2004-08-12 19:44:39 +10:00
@@ -288,6 +288,9 @@
 	if (!x->calg)
 		goto out;
 
+	if (x->encap)
+		goto out;
+
 	err = -ENOMEM;
 	ipcd = kmalloc(sizeof(*ipcd), GFP_KERNEL);
 	if (!ipcd)
===== net/ipv4/xfrm4_tunnel.c 1.15 vs edited =====
--- 1.15/net/ipv4/xfrm4_tunnel.c	2004-08-02 18:13:28 +10:00
+++ edited/net/ipv4/xfrm4_tunnel.c	2004-08-12 19:48:55 +10:00
@@ -84,6 +84,10 @@
 {
 	if (!x->props.mode)
 		return -EINVAL;
+
+	if (x->encap)
+		return -EINVAL;
+
 	x->props.header_len = sizeof(struct iphdr);
 
 	return 0;
===== net/ipv6/ah6.c 1.39 vs edited =====
--- 1.39/net/ipv6/ah6.c	2004-08-02 17:53:26 +10:00
+++ edited/net/ipv6/ah6.c	2004-08-12 19:47:45 +10:00
@@ -353,6 +353,9 @@
 	if (x->aalg->alg_key_len > 512)
 		goto error;
 
+	if (x->encap)
+		goto error;
+
 	ahp = kmalloc(sizeof(*ahp), GFP_KERNEL);
 	if (ahp == NULL)
 		return -ENOMEM;
===== net/ipv6/esp6.c 1.35 vs edited =====
--- 1.35/net/ipv6/esp6.c	2004-08-02 17:53:26 +10:00
+++ edited/net/ipv6/esp6.c	2004-08-12 19:48:01 +10:00
@@ -309,6 +309,9 @@
 	if (x->ealg == NULL)
 		goto error;
 
+	if (x->encap)
+		goto error;
+
 	esp = kmalloc(sizeof(*esp), GFP_KERNEL);
 	if (esp == NULL)
 		return -ENOMEM;
===== net/ipv6/ipcomp6.c 1.20 vs edited =====
--- 1.20/net/ipv6/ipcomp6.c	2004-08-02 17:53:26 +10:00
+++ edited/net/ipv6/ipcomp6.c	2004-08-12 19:48:23 +10:00
@@ -284,6 +284,9 @@
 	if (!x->calg)
 		goto out;
 
+	if (x->encap)
+		goto out;
+
 	err = -ENOMEM;
 	ipcd = kmalloc(sizeof(*ipcd), GFP_KERNEL);
 	if (!ipcd)
===== net/ipv6/xfrm6_tunnel.c 1.5 vs edited =====
--- 1.5/net/ipv6/xfrm6_tunnel.c	2004-08-02 18:13:28 +10:00
+++ edited/net/ipv6/xfrm6_tunnel.c	2004-08-12 19:48:43 +10:00
@@ -517,6 +517,9 @@
 	if (!x->props.mode)
 		return -EINVAL;
 
+	if (x->encap)
+		return -EINVAL;
+
 	x->props.header_len = sizeof(struct ipv6hdr);
 
 	return 0;
===== net/key/af_key.c 1.66 vs edited =====
--- 1.66/net/key/af_key.c	2004-08-02 07:15:03 +10:00
+++ edited/net/key/af_key.c	2004-08-12 19:50:30 +10:00
@@ -1075,15 +1075,6 @@
 		n_type = ext_hdrs[SADB_X_EXT_NAT_T_TYPE-1];
 		natt->encap_type = n_type->sadb_x_nat_t_type_type;
 
-		switch (natt->encap_type) {
-		case UDP_ENCAP_ESPINUDP:
-		case UDP_ENCAP_ESPINUDP_NON_IKE:
-			break;
-		default:
-			err = -ENOPROTOOPT;
-			goto out;
-		}
-
 		if (ext_hdrs[SADB_X_EXT_NAT_T_SPORT-1]) {
 			struct sadb_x_nat_t_port* n_port =
 				ext_hdrs[SADB_X_EXT_NAT_T_SPORT-1];
===== net/xfrm/xfrm_user.c 1.47 vs edited =====
--- 1.47/net/xfrm/xfrm_user.c	2004-07-30 21:16:40 +10:00
+++ edited/net/xfrm/xfrm_user.c	2004-08-12 19:51:50 +10:00
@@ -78,15 +78,6 @@
 	if ((rt->rta_len - sizeof(*rt)) < sizeof(*encap))
 		return -EINVAL;
 
-	encap = RTA_DATA(rt);
-	switch (encap->encap_type) {
-	case UDP_ENCAP_ESPINUDP:
-	case UDP_ENCAP_ESPINUDP_NON_IKE:
-		break;
-	default:
-		return -ENOPROTOOPT;
-	}
-
 	return 0;
 }
 

--tKW2IUtsqtDRztdT--
