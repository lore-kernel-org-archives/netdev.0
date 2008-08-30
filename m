From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: iproute2 and aead
Date: Sat, 30 Aug 2008 14:57:10 +1000
Message-ID: <20080830045710.GA17501@gondor.apana.org.au>
References: <61362e760808131459l1548c956s47b4e5d3c67144fa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Barry G <mr.scada@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59316 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750737AbYH3E5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Aug 2008 00:57:19 -0400
Content-Disposition: inline
In-Reply-To: <61362e760808131459l1548c956s47b4e5d3c67144fa@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 13, 2008 at 02:59:41PM -0700, Barry G wrote:
> 
> I am using iproute2 to try to load authenc(hmac(sha256),cbc(aes))
> connections using the talitos driver.  Do I need to use the aead
> ALGO_TYPE?  If so, do you have a tree for iproute2 with
> the patch in it?  Any plans to push it to iproute2?

Sorry, I forgot to push it upstream.

ip: xfrm: Add AEAD support

This patch allows the user to create/manage AEAD algorithms with
the ip xfrm command.  AEAD algorithms are also known as combined-
mode algorithms.  They provide the functionality of encryption
algorithms as well as authentication algorithms.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index f2bbf4b..67ebd59 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -96,6 +96,13 @@ struct xfrm_algo {
 	char	alg_key[0];
 };
 
+struct xfrm_algo_aead {
+	char		alg_name[64];
+	unsigned int	alg_key_len;	/* in bits */
+	unsigned int	alg_icv_len;	/* in bits */
+	char		alg_key[0];
+};
+
 struct xfrm_stats {
 	__u32	replay_window;
 	__u32	replay;
@@ -205,6 +212,16 @@ enum xfrm_attr_type_t {
 	XFRMA_SA,
 	XFRMA_POLICY,
 	XFRMA_SEC_CTX,		/* struct xfrm_sec_ctx */
+	XFRMA_LTIME_VAL,
+	XFRMA_REPLAY_VAL,
+	XFRMA_REPLAY_THRESH,
+	XFRMA_ETIMER_THRESH,
+	XFRMA_SRCADDR,		/* xfrm_address_t */
+	XFRMA_COADDR,		/* xfrm_address_t */
+	XFRMA_LASTUSED,
+	XFRMA_POLICY_TYPE,	/* struct xfrm_userpolicy_type */
+	XFRMA_MIGRATE,
+	XFRMA_ALG_AEAD,		/* struct xfrm_algo_aead */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 8baaabd..ed96564 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -138,7 +138,8 @@ const char *strxf_xfrmproto(__u8 proto)
 
 static const struct typeent algo_types[]= {
 	{ "enc", XFRMA_ALG_CRYPT }, { "auth", XFRMA_ALG_AUTH },
-	{ "comp", XFRMA_ALG_COMP }, { NULL, -1 }
+	{ "comp", XFRMA_ALG_COMP }, { "aead", XFRMA_ALG_AEAD },
+	{ NULL, -1 }
 };
 
 int xfrm_algotype_getbyname(char *name)
@@ -476,8 +477,8 @@ void xfrm_selector_print(struct xfrm_selector *sel, __u16 family,
 	fprintf(fp, "%s", _SL_);
 }
 
-static void xfrm_algo_print(struct xfrm_algo *algo, int type, int len,
-			    FILE *fp, const char *prefix)
+static void __xfrm_algo_print(struct xfrm_algo *algo, int type, int len,
+			      FILE *fp, const char *prefix, int newline)
 {
 	int keylen;
 	int i;
@@ -509,6 +510,32 @@ static void xfrm_algo_print(struct xfrm_algo *algo, int type, int len,
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
 
@@ -586,6 +613,12 @@ void xfrm_xfrma_print(struct rtattr *tb[], __u16 family,
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
index 3eefaff..030d713 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -85,8 +85,10 @@ static void usage(void)
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
@@ -109,7 +111,7 @@ static void usage(void)
 }
 
 static int xfrm_algo_parse(struct xfrm_algo *alg, enum xfrm_attr_type_t type,
-			   char *name, char *key, int max)
+			   char *name, char *key, char *buf, int max)
 {
 	int len;
 	int slen = strlen(key);
@@ -149,7 +151,7 @@ static int xfrm_algo_parse(struct xfrm_algo *alg, enum xfrm_attr_type_t type,
 			if (get_u8(&val, vbuf, 16))
 				invarg("\"ALGOKEY\" is invalid", key);
 
-			alg->alg_key[j] = val;
+			buf[j] = val;
 		}
 	} else {
 		len = slen;
@@ -157,7 +159,7 @@ static int xfrm_algo_parse(struct xfrm_algo *alg, enum xfrm_attr_type_t type,
 			if (len > max)
 				invarg("\"ALGOKEY\" makes buffer overflow\n", key);
 
-			strncpy(alg->alg_key, key, len);
+			strncpy(buf, key, len);
 		}
 	}
 
@@ -228,6 +230,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 		char   			buf[RTA_BUF_SIZE];
 	} req;
 	char *idp = NULL;
+	char *aeadop = NULL;
 	char *ealgop = NULL;
 	char *aalgop = NULL;
 	char *calgop = NULL;
@@ -289,20 +292,31 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
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
@@ -333,11 +347,27 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
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
@@ -364,7 +394,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 		exit(1);
 	}
 
-	if (ealgop || aalgop || calgop) {
+	if (aeadop || ealgop || aalgop || calgop) {
 		if (req.xsinfo.id.proto != IPPROTO_ESP &&
 		    req.xsinfo.id.proto != IPPROTO_AH &&
 		    req.xsinfo.id.proto != IPPROTO_COMP) {
