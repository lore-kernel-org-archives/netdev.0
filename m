From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Check encap_type at config time
Date: Fri, 25 Jun 2004 22:35:27 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040625123527.GA11685@gondor.apana.org.au>
References: <20040625121147.GA11231@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="7AUc2qLy4jB3hD7Z"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040625121147.GA11231@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--7AUc2qLy4jB3hD7Z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Jun 25, 2004 at 10:11:47PM +1000, herbert wrote:
> 
> PS I will be doing a similar patch for the encap_type in xfrm.

Here is the patch to check encap_type at the earliest possible
opportunity in xfrm_user/af_key.

This will allow us to assume in esp4 that the encap_type from x->encap
is always valid.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--7AUc2qLy4jB3hD7Z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/key/af_key.c 1.61 vs edited =====
--- 1.61/net/key/af_key.c	2004-06-06 18:27:42 +10:00
+++ edited/net/key/af_key.c	2004-06-25 19:33:51 +10:00
@@ -1075,6 +1075,15 @@
 		n_type = ext_hdrs[SADB_X_EXT_NAT_T_TYPE-1];
 		natt->encap_type = n_type->sadb_x_nat_t_type_type;
 
+		switch (natt->encap_type) {
+		case UDP_ENCAP_ESPINUDP:
+		case UDP_ENCAP_ESPINUDP_NON_IKE:
+			break;
+		default:
+			err = -ENOPROTOOPT;
+			goto out;
+		}
+
 		if (ext_hdrs[SADB_X_EXT_NAT_T_SPORT-1]) {
 			struct sadb_x_nat_t_port* n_port =
 				ext_hdrs[SADB_X_EXT_NAT_T_SPORT-1];
===== net/xfrm/xfrm_user.c 1.42 vs edited =====
--- 1.42/net/xfrm/xfrm_user.c	2004-03-25 09:18:34 +11:00
+++ edited/net/xfrm/xfrm_user.c	2004-06-25 19:33:51 +10:00
@@ -78,6 +78,15 @@
 	if ((rt->rta_len - sizeof(*rt)) < sizeof(*encap))
 		return -EINVAL;
 
+	encap = RTA_DATA(rt);
+	switch (encap->encap_type) {
+	case UDP_ENCAP_ESPINUDP:
+	case UDP_ENCAP_ESPINUDP_NON_IKE:
+		break;
+	default:
+		return -ENOPROTOOPT;
+	}
+
 	return 0;
 }
 

--7AUc2qLy4jB3hD7Z--
