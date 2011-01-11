From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] iproute2: allow to specify truncation bits on auth algo
Date: Tue, 11 Jan 2011 17:32:46 +0100
Message-ID: <4D2C862E.5000602@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080306000208070609080206"
To: Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46532 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932209Ab1AKQcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 11:32:52 -0500
Received: by wyb28 with SMTP id 28so20636547wyb.19
        for <netdev@vger.kernel.org>; Tue, 11 Jan 2011 08:32:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080306000208070609080206
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

here is a patch against iproute2 to allow user to set a state with a specific 
auth length.

Example:
$ ip xfrm state add src 10.16.0.72 dst 10.16.0.121 proto ah spi 0x10000000 
auth-trunc "sha256" "azertyuiopqsdfghjklmwxcvbn123456" 96 mode tunnel
$ ip xfrm state
src 10.16.0.72 dst 10.16.0.121
         proto ah spi 0x10000000 reqid 0 mode tunnel
         replay-window 0
         auth-trunc hmac(sha256) 
0x617a6572747975696f707173646667686a6b6c6d77786376626e313233343536 96
         sel src 0.0.0.0/0 dst 0.0.0.0/0

Regards,
Nicolas

--------------080306000208070609080206
Content-Type: text/x-patch;
 name="0001-iproute2-allow-to-specify-truncation-bits-on-auth-a.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-iproute2-allow-to-specify-truncation-bits-on-auth-a.pat";
 filename*1="ch"

>From 522ed7348cdf3b6f501af2a5a5d989de1696565a Mon Sep 17 00:00:00 2001
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 23 Dec 2010 06:48:12 -0500
Subject: [PATCH] iproute2: allow to specify truncation bits on auth algo

Attribute XFRMA_ALG_AUTH_TRUNC can be used to specify
truncation bits, so we add a new algo type: auth-trunc.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/ipxfrm.c     |   28 +++++++++++++++++++++++++++-
 ip/xfrm_state.c |   48 ++++++++++++++++++++++++++++++++----------------
 2 files changed, 59 insertions(+), 17 deletions(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 9753822..e01cadb 100644
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
index 38d4039..550a965 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -90,11 +90,12 @@ static void usage(void)
 
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
 
@@ -340,6 +341,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 			case XFRMA_ALG_AEAD:
 			case XFRMA_ALG_CRYPT:
 			case XFRMA_ALG_AUTH:
+			case XFRMA_ALG_AUTH_TRUNC:
 			case XFRMA_ALG_COMP:
 			{
 				/* ALGO */
@@ -347,11 +349,12 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
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
@@ -368,6 +371,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 					ealgop = *argv;
 					break;
 				case XFRMA_ALG_AUTH:
+				case XFRMA_ALG_AUTH_TRUNC:
 					if (aalgop)
 						duparg("ALGOTYPE", *argv);
 					aalgop = *argv;
@@ -395,21 +399,33 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
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


--------------080306000208070609080206--
