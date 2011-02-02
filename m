From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] iproute2: allow to specify truncation bits on auth algo
Date: Wed, 02 Feb 2011 17:30:11 +0100
Message-ID: <4D498693.6020909@6wind.com>
References: <20110128045108.GA8351@gondor.apana.org.au>	<4D42839C.3050401@6wind.com> <20110128.114610.193716130.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090906030304090200030408"
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	christophe.gouault@6wind.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:51714 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754452Ab1BBQaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 11:30:16 -0500
Received: by fxm20 with SMTP id 20so148844fxm.19
        for <netdev@vger.kernel.org>; Wed, 02 Feb 2011 08:30:14 -0800 (PST)
In-Reply-To: <20110128.114610.193716130.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090906030304090200030408
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 28/01/2011 20:46, David Miller wrote:
> From: Nicolas Dichtel<nicolas.dichtel@6wind.com>
> Date: Fri, 28 Jan 2011 09:51:40 +0100
>
>> On 28/01/2011 05:51, Herbert Xu wrote:
>>> So perhaps an SA configuration flag is needed?
>> I agree. If David is ok, I will update the patch.
>
> Sounds good to me.
And the patch for iproute2.


Regards,
Nicolas

--------------090906030304090200030408
Content-Type: text/x-patch;
 name="0001-iproute2-allow-to-specify-truncation-bits-on-auth-a.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-iproute2-allow-to-specify-truncation-bits-on-auth-a.pat";
 filename*1="ch"

>From e0d84548d363cfa46a03719bc318ef52fa5ca98f Mon Sep 17 00:00:00 2001
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 23 Dec 2010 06:48:12 -0500
Subject: [PATCH] iproute2: allow to specify truncation bits on auth algo

Attribute XFRMA_ALG_AUTH_TRUNC can be used to specify
truncation bits, so we add a new algo type: auth-trunc.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/ipxfrm.c     |   28 +++++++++++++++++++++++++++-
 ip/xfrm_state.c |   50 +++++++++++++++++++++++++++++++++-----------------
 2 files changed, 60 insertions(+), 18 deletions(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index ba7360f..591f7bf 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -155,6 +155,7 @@ const char *strxf_xfrmproto(__u8 proto)
 static const struct typeent algo_types[]= {
 	{ "enc", XFRMA_ALG_CRYPT }, { "auth", XFRMA_ALG_AUTH },
 	{ "comp", XFRMA_ALG_COMP }, { "aead", XFRMA_ALG_AEAD },
+	{ "auth-trunc", XFRMA_ALG_AUTH_TRUNC },
 	{ NULL, -1 }
 };
 
@@ -570,6 +571,25 @@ static void xfrm_aead_print(struct xfrm_algo_aead *algo, int len,
 	fprintf(fp, "%s", _SL_);
 }
 
+static void xfrm_auth_trunc_print(struct xfrm_algo_auth *algo, int len,
+				  FILE *fp, const char *prefix)
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
+	__xfrm_algo_print(&base.algo, XFRMA_ALG_AUTH_TRUNC, len, fp, prefix, 0);
+
+	fprintf(fp, " %d", algo->alg_trunc_len);
+
+	fprintf(fp, "%s", _SL_);
+}
+
 static void xfrm_tmpl_print(struct xfrm_user_tmpl *tmpls, int len,
 			    __u16 family, FILE *fp, const char *prefix)
 {
@@ -677,12 +697,18 @@ void xfrm_xfrma_print(struct rtattr *tb[], __u16 family,
 		fprintf(fp, "\tmark %d/0x%x\n", m->v, m->m);
 	}
 
-	if (tb[XFRMA_ALG_AUTH]) {
+	if (tb[XFRMA_ALG_AUTH] && !tb[XFRMA_ALG_AUTH_TRUNC]) {
 		struct rtattr *rta = tb[XFRMA_ALG_AUTH];
 		xfrm_algo_print((struct xfrm_algo *) RTA_DATA(rta),
 				XFRMA_ALG_AUTH, RTA_PAYLOAD(rta), fp, prefix);
 	}
 
+	if (tb[XFRMA_ALG_AUTH_TRUNC]) {
+		struct rtattr *rta = tb[XFRMA_ALG_AUTH_TRUNC];
+		xfrm_auth_trunc_print((struct xfrm_algo_auth *) RTA_DATA(rta),
+				      RTA_PAYLOAD(rta), fp, prefix);
+	}
+
 	if (tb[XFRMA_ALG_AEAD]) {
 		struct rtattr *rta = tb[XFRMA_ALG_AEAD];
 		xfrm_aead_print((struct xfrm_algo_aead *)RTA_DATA(rta),
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 70f0a0b..5260d85 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -83,18 +83,19 @@ static void usage(void)
  	//fprintf(stderr, "REQID - number(default=0)\n");
 
 	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] FLAG\n");
-	fprintf(stderr, "FLAG := [ noecn | decap-dscp | nopmtudisc | wildrecv | icmp | af-unspec ]\n");
+	fprintf(stderr, "FLAG := [ noecn | decap-dscp | nopmtudisc | wildrecv | icmp | af-unspec | align4 ]\n");
 
         fprintf(stderr, "ENCAP := ENCAP-TYPE SPORT DPORT OADDR\n");
         fprintf(stderr, "ENCAP-TYPE := espinudp | espinudp-nonike\n");
 
 	fprintf(stderr, "ALGO-LIST := [ ALGO-LIST ] | [ ALGO ]\n");
 	fprintf(stderr, "ALGO := ALGO_TYPE ALGO_NAME ALGO_KEY "
-			"[ ALGO_ICV_LEN ]\n");
+			"[ ALGO_ICV_LEN | ALGO_TRUNC_LEN ]\n");
 	fprintf(stderr, "ALGO_TYPE := [ ");
 	fprintf(stderr, "%s | ", strxf_algotype(XFRMA_ALG_AEAD));
 	fprintf(stderr, "%s | ", strxf_algotype(XFRMA_ALG_CRYPT));
 	fprintf(stderr, "%s | ", strxf_algotype(XFRMA_ALG_AUTH));
+	fprintf(stderr, "%s | ", strxf_algotype(XFRMA_ALG_AUTH_TRUNC));
 	fprintf(stderr, "%s ", strxf_algotype(XFRMA_ALG_COMP));
 	fprintf(stderr, "]\n");
 
@@ -342,6 +343,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 			case XFRMA_ALG_AEAD:
 			case XFRMA_ALG_CRYPT:
 			case XFRMA_ALG_AUTH:
+			case XFRMA_ALG_AUTH_TRUNC:
 			case XFRMA_ALG_COMP:
 			{
 				/* ALGO */
@@ -349,11 +351,12 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 					union {
 						struct xfrm_algo alg;
 						struct xfrm_algo_aead aead;
+						struct xfrm_algo_auth auth;
 					} u;
 					char buf[XFRM_ALGO_KEY_BUF_SIZE];
 				} alg = {};
 				int len;
-				__u32 icvlen;
+				__u32 icvlen, trunclen;
 				char *name;
 				char *key;
 				char *buf;
@@ -370,6 +373,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 					ealgop = *argv;
 					break;
 				case XFRMA_ALG_AUTH:
+				case XFRMA_ALG_AUTH_TRUNC:
 					if (aalgop)
 						duparg("ALGOTYPE", *argv);
 					aalgop = *argv;
@@ -397,21 +401,33 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 				buf = alg.u.alg.alg_key;
 				len = sizeof(alg.u.alg);
 
-				if (type != XFRMA_ALG_AEAD)
-					goto parse_algo;
-
-				if (!NEXT_ARG_OK())
-					missarg("ALGOICVLEN");
-				NEXT_ARG();
-				if (get_u32(&icvlen, *argv, 0))
-					invarg("\"aead\" ICV length is invalid",
-					       *argv);
-				alg.u.aead.alg_icv_len = icvlen;
-
-				buf = alg.u.aead.alg_key;
-				len = sizeof(alg.u.aead);
+				switch (type) {
+				case XFRMA_ALG_AEAD:
+					if (!NEXT_ARG_OK())
+						missarg("ALGOICVLEN");
+					NEXT_ARG();
+					if (get_u32(&icvlen, *argv, 0))
+						invarg("\"aead\" ICV length is invalid",
+						       *argv);
+					alg.u.aead.alg_icv_len = icvlen;
+
+					buf = alg.u.aead.alg_key;
+					len = sizeof(alg.u.aead);
+					break;
+				case XFRMA_ALG_AUTH_TRUNC:
+					if (!NEXT_ARG_OK())
+						missarg("ALGOTRUNCLEN");
+					NEXT_ARG();
+					if (get_u32(&trunclen, *argv, 0))
+						invarg("\"auth\" trunc length is invalid",
+						       *argv);
+					alg.u.auth.alg_trunc_len = trunclen;
+
+					buf = alg.u.auth.alg_key;
+					len = sizeof(alg.u.auth);
+					break;
+				}
 
-parse_algo:
 				xfrm_algo_parse((void *)&alg, type, name, key,
 						buf, sizeof(alg.buf));
 				len += alg.u.alg.alg_key_len;
-- 
1.5.6.5


--------------090906030304090200030408--
