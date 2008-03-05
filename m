From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPROUTE] xfrm: Add combined-mode algorithm support
Date: Wed, 5 Mar 2008 19:54:29 +0800
Message-ID: <20080305115429.GA28102@gondor.apana.org.au>
References: <20080305114643.GA27967@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58709 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753872AbYCELyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 06:54:32 -0500
Content-Disposition: inline
In-Reply-To: <20080305114643.GA27967@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen:

Here's the patch to add combined-mode algorithm support to ip(8).

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 80dbb52..0a7d39a 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -154,7 +154,8 @@ const char *strxf_xfrmproto(__u8 proto)
 
 static const struct typeent algo_types[]= {
 	{ "enc", XFRMA_ALG_CRYPT }, { "auth", XFRMA_ALG_AUTH },
-	{ "comp", XFRMA_ALG_COMP }, { NULL, -1 }
+	{ "comp", XFRMA_ALG_COMP }, { "aead", XFRMA_ALG_AEAD },
+	{ NULL, -1 }
 };
 
 int xfrm_algotype_getbyname(char *name)
@@ -525,8 +526,8 @@ void xfrm_selector_print(struct xfrm_selector *sel, __u16 family,
 	fprintf(fp, "%s", _SL_);
 }
 
-static void xfrm_algo_print(struct xfrm_algo *algo, int type, int len,
-			    FILE *fp, const char *prefix)
+static void __xfrm_algo_print(struct xfrm_algo *algo, int type, int len,
+			      FILE *fp, const char *prefix, int newline)
 {
 	int keylen;
 	int i;
@@ -558,6 +559,32 @@ static void xfrm_algo_print(struct xfrm_algo *algo, int type, int len,
 		fprintf(fp, " (%d bits)", algo->alg_key_len);
 
  fin:
+	if (newline)
+		fprintf(fp, "%s", _SL_);
+}
+
+static inline void xfrm_algo_print(struct xfrm_algo *algo, int type, int len,
+				   FILE *fp, const char *prefix)
+{
+	return __xfrm_algo_print(algo, type, len, fp, prefix, 1);
+}
+
+static void xfrm_aead_print(struct xfrm_algo_aead *algo, int len,
+			    FILE *fp, const char *prefix)
+{
+	struct {
+		struct xfrm_algo algo;
+		char key[algo->alg_key_len / 8];
+	} base;
+
+	memcpy(base.algo.alg_name, algo->alg_name, sizeof(base.algo.alg_name));
+	base.algo.alg_key_len = algo->alg_key_len;
+	memcpy(base.algo.alg_key, algo->alg_key, algo->alg_key_len / 8);
+
+	__xfrm_algo_print(&base.algo, XFRMA_ALG_AEAD, len, fp, prefix, 0);
+
+	fprintf(fp, " %d", algo->alg_icv_len);
+
 	fprintf(fp, "%s", _SL_);
 }
 
@@ -635,6 +662,12 @@ void xfrm_xfrma_print(struct rtattr *tb[], __u16 family,
 				XFRMA_ALG_AUTH, RTA_PAYLOAD(rta), fp, prefix);
 	}
 
+	if (tb[XFRMA_ALG_AEAD]) {
+		struct rtattr *rta = tb[XFRMA_ALG_AEAD];
+		xfrm_aead_print((struct xfrm_algo_aead *)RTA_DATA(rta),
+				RTA_PAYLOAD(rta), fp, prefix);
+	}
+
 	if (tb[XFRMA_ALG_CRYPT]) {
 		struct rtattr *rta = tb[XFRMA_ALG_CRYPT];
 		xfrm_algo_print((struct xfrm_algo *) RTA_DATA(rta),
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 0e21203..d821924 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -88,8 +88,10 @@ static void usage(void)
         fprintf(stderr, "ENCAP-TYPE := espinudp | espinudp-nonike\n");
 
 	fprintf(stderr, "ALGO-LIST := [ ALGO-LIST ] | [ ALGO ]\n");
-	fprintf(stderr, "ALGO := ALGO_TYPE ALGO_NAME ALGO_KEY\n");
+	fprintf(stderr, "ALGO := ALGO_TYPE ALGO_NAME ALGO_KEY "
+			"[ ALGO_ICV_LEN ]\n");
 	fprintf(stderr, "ALGO_TYPE := [ ");
+	fprintf(stderr, "%s | ", strxf_algotype(XFRMA_ALG_AEAD));
 	fprintf(stderr, "%s | ", strxf_algotype(XFRMA_ALG_CRYPT));
 	fprintf(stderr, "%s | ", strxf_algotype(XFRMA_ALG_AUTH));
 	fprintf(stderr, "%s ", strxf_algotype(XFRMA_ALG_COMP));
@@ -112,7 +114,7 @@ static void usage(void)
 }
 
 static int xfrm_algo_parse(struct xfrm_algo *alg, enum xfrm_attr_type_t type,
-			   char *name, char *key, int max)
+			   char *name, char *key, char *buf, int max)
 {
 	int len;
 	int slen = strlen(key);
@@ -152,7 +154,7 @@ static int xfrm_algo_parse(struct xfrm_algo *alg, enum xfrm_attr_type_t type,
 			if (get_u8(&val, vbuf, 16))
 				invarg("\"ALGOKEY\" is invalid", key);
 
-			alg->alg_key[j] = val;
+			buf[j] = val;
 		}
 	} else {
 		len = slen;
@@ -160,7 +162,7 @@ static int xfrm_algo_parse(struct xfrm_algo *alg, enum xfrm_attr_type_t type,
 			if (len > max)
 				invarg("\"ALGOKEY\" makes buffer overflow\n", key);
 
-			strncpy(alg->alg_key, key, len);
+			strncpy(buf, key, len);
 		}
 	}
 
@@ -233,6 +235,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 		char   			buf[RTA_BUF_SIZE];
 	} req;
 	char *idp = NULL;
+	char *aeadop = NULL;
 	char *ealgop = NULL;
 	char *aalgop = NULL;
 	char *calgop = NULL;
@@ -316,20 +319,31 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 			/* try to assume ALGO */
 			int type = xfrm_algotype_getbyname(*argv);
 			switch (type) {
+			case XFRMA_ALG_AEAD:
 			case XFRMA_ALG_CRYPT:
 			case XFRMA_ALG_AUTH:
 			case XFRMA_ALG_COMP:
 			{
 				/* ALGO */
 				struct {
-					struct xfrm_algo alg;
+					union {
+						struct xfrm_algo alg;
+						struct xfrm_algo_aead aead;
+					} u;
 					char buf[XFRM_ALGO_KEY_BUF_SIZE];
-				} alg;
+				} alg = {};
 				int len;
+				__u32 icvlen;
 				char *name;
 				char *key;
+				char *buf;
 
 				switch (type) {
+				case XFRMA_ALG_AEAD:
+					if (aeadop)
+						duparg("ALGOTYPE", *argv);
+					aeadop = *argv;
+					break;
 				case XFRMA_ALG_CRYPT:
 					if (ealgop)
 						duparg("ALGOTYPE", *argv);
@@ -360,11 +374,27 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 				NEXT_ARG();
 				key = *argv;
 
-				memset(&alg, 0, sizeof(alg));
+				buf = alg.u.alg.alg_key;
+				len = sizeof(alg.u.alg);
+
+				if (type != XFRMA_ALG_AEAD)
+					goto parse_algo;
+
+				if (!NEXT_ARG_OK())
+					missarg("ALGOICVLEN");
+				NEXT_ARG();
+				if (get_u32(&icvlen, *argv, 0))
+					invarg("\"aead\" ICV length is invalid",
+					       *argv);
+				alg.u.aead.alg_icv_len = icvlen;
+
+				buf = alg.u.aead.alg_key;
+				len = sizeof(alg.u.aead);
 
+parse_algo:
 				xfrm_algo_parse((void *)&alg, type, name, key,
-						sizeof(alg.buf));
-				len = sizeof(struct xfrm_algo) + alg.alg.alg_key_len;
+						buf, sizeof(alg.buf));
+				len += alg.u.alg.alg_key_len;
 
 				addattr_l(&req.n, sizeof(req.buf), type,
 					  (void *)&alg, len);
@@ -417,7 +447,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 		break;
 	}
 
-	if (ealgop || aalgop || calgop) {
+	if (aeadop || ealgop || aalgop || calgop) {
 		if (!xfrm_xfrmproto_is_ipsec(req.xsinfo.id.proto)) {
 			fprintf(stderr, "\"ALGO\" is invalid with proto=%s\n",
 				strxf_xfrmproto(req.xsinfo.id.proto));
