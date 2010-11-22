From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC] [PATCH] iproute2: Add IPsec extended sequence number support
Date: Mon, 22 Nov 2010 11:37:13 +0100
Message-ID: <20101122103713.GO1868@secunet.com>
References: <20101122102455.GC1868@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Gruenbacher <agruen@suse.de>,
	Alex Badea <abadea@ixiacom.com>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101122102455.GC1868@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/linux/xfrm.h |   12 ++++++++++++
 ip/ipxfrm.c          |    8 +++++++-
 ip/xfrm_state.c      |   37 +++++++++++++++++++++++++++++--------
 3 files changed, 48 insertions(+), 9 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 07f2b63..dd6928d 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -84,6 +84,16 @@ struct xfrm_replay_state {
 	__u32	bitmap;
 };
 
+struct xfrm_replay_state_esn {
+	unsigned int	len;
+	__u32	oseq;
+	__u32	oseq_hi;
+	__u32	seq;
+	__u32	seq_hi;
+	__u32	replay_window;
+	__u32	bmp[0];
+};
+
 struct xfrm_algo {
 	char		alg_name[64];
 	unsigned int	alg_key_len;    /* in bits */
@@ -283,6 +293,7 @@ enum xfrm_attr_type_t {
 	XFRMA_KMADDRESS,        /* struct xfrm_user_kmaddress */
 	XFRMA_ALG_AUTH_TRUNC,	/* struct xfrm_algo_auth */
 	XFRMA_MARK,		/* struct xfrm_mark */
+	XFRMA_REPLAY_ESN_VAL,	/* struct xfrm_replay_esn */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
@@ -349,6 +360,7 @@ struct xfrm_usersa_info {
 #define XFRM_STATE_WILDRECV	8
 #define XFRM_STATE_ICMP		16
 #define XFRM_STATE_AF_UNSPEC	32
+#define XFRM_STATE_ESN          64
 };
 
 struct xfrm_usersa_id {
diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 99a6756..548e4a4 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -665,6 +665,12 @@ done:
 void xfrm_xfrma_print(struct rtattr *tb[], __u16 family,
 		      FILE *fp, const char *prefix)
 {
+
+	if (tb[XFRMA_REPLAY_ESN_VAL]) {
+		struct rtattr *rta = tb[XFRMA_REPLAY_ESN_VAL];
+		struct xfrm_replay_state_esn *repl = (struct xfrm_replay_state_esn *) RTA_DATA(rta);
+		fprintf(fp, "\treplay-window %u\n", repl->replay_window);
+	}
 	if (tb[XFRMA_MARK]) {
 		struct rtattr *rta = tb[XFRMA_MARK];
 		struct xfrm_mark *m = (struct xfrm_mark *) RTA_DATA(rta);
@@ -809,7 +815,6 @@ void xfrm_state_info_print(struct xfrm_usersa_info *xsinfo,
 	STRBUF_CAT(buf, "\t");
 
 	fputs(buf, fp);
-	fprintf(fp, "replay-window %u ", xsinfo->replay_window);
 	if (show_stats > 0)
 		fprintf(fp, "seq 0x%08u ", xsinfo->seq);
 	if (show_stats > 0 || xsinfo->flags) {
@@ -822,6 +827,7 @@ void xfrm_state_info_print(struct xfrm_usersa_info *xsinfo,
 		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_WILDRECV, "wildrecv");
 		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_ICMP, "icmp");
 		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_AF_UNSPEC, "af-unspec");
+		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_ESN, "replay-esn");
 		if (flags)
 			fprintf(fp, "%x", flags);
 	}
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 38d4039..4c66923 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -50,15 +50,16 @@
 #define NLMSG_BUF_SIZE 4096
 #define RTA_BUF_SIZE 2048
 #define XFRM_ALGO_KEY_BUF_SIZE 512
+#define XFRM_REPLAY_BMP_SIZE_U32 16
 
 static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ip xfrm state { add | update } ID [ XFRM_OPT ] [ mode MODE ]\n");
-	fprintf(stderr, "        [ reqid REQID ] [ seq SEQ ] [ replay-window SIZE ] [ flag FLAG-LIST ]\n");
+	fprintf(stderr, "        [ reqid REQID ] [ seq SEQ ][ replay-window SIZE ] [ flag FLAG-LIST ]\n");
 	fprintf(stderr, "        [ encap ENCAP ] [ sel SELECTOR ] [ replay-seq SEQ ]\n");
-	fprintf(stderr, "        [ replay-oseq SEQ ] [ LIMIT-LIST ]\n");
+	fprintf(stderr, "        [ replay-oseq SEQ ] [ replay-seqhi SEQ ] [ replay-oseqhi SEQ ] [ LIMIT-LIST ]\n");
 	fprintf(stderr, "Usage: ip xfrm state allocspi ID [ mode MODE ] [ reqid REQID ] [ seq SEQ ]\n");
 	fprintf(stderr, "        [ min SPI max SPI ]\n");
 	fprintf(stderr, "Usage: ip xfrm state { delete | get } ID\n");
@@ -214,6 +215,8 @@ static int xfrm_state_flag_parse(__u8 *flags, int *argcp, char ***argvp)
 				*flags |= XFRM_STATE_ICMP;
 			else if (strcmp(*argv, "af-unspec") == 0)
 				*flags |= XFRM_STATE_AF_UNSPEC;
+			else if (strcmp(*argv, "replay-esn") == 0)
+				*flags |= XFRM_STATE_ESN;
 			else {
 				PREV_ARG(); /* back track */
 				break;
@@ -239,7 +242,11 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 		struct xfrm_usersa_info xsinfo;
 		char   			buf[RTA_BUF_SIZE];
 	} req;
-	struct xfrm_replay_state replay;
+	struct {
+		struct xfrm_replay_state_esn state;
+		__u32 bmp[XFRM_REPLAY_BMP_SIZE_U32];
+	} replay;
+
 	char *idp = NULL;
 	char *aeadop = NULL;
 	char *ealgop = NULL;
@@ -249,8 +256,11 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 	struct xfrm_mark mark = {0, 0};
 
 	memset(&req, 0, sizeof(req));
+
 	memset(&replay, 0, sizeof(replay));
 
+	replay.state.len = sizeof(replay);
+
 	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.xsinfo));
 	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
 	req.n.nlmsg_type = cmd;
@@ -275,16 +285,24 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 			xfrm_seq_parse(&req.xsinfo.seq, &argc, &argv);
 		} else if (strcmp(*argv, "replay-window") == 0) {
 			NEXT_ARG();
-			if (get_u8(&req.xsinfo.replay_window, *argv, 0))
+			if (get_u32(&replay.state.replay_window, *argv, 0))
 				invarg("\"replay-window\" value is invalid", *argv);
 		} else if (strcmp(*argv, "replay-seq") == 0) {
 			NEXT_ARG();
-			if (get_u32(&replay.seq, *argv, 0))
+			if (get_u32(&replay.state.seq, *argv, 0))
 				invarg("\"replay-seq\" value is invalid", *argv);
 		} else if (strcmp(*argv, "replay-oseq") == 0) {
 			NEXT_ARG();
-			if (get_u32(&replay.oseq, *argv, 0))
+			if (get_u32(&replay.state.oseq, *argv, 0))
 				invarg("\"replay-oseq\" value is invalid", *argv);
+		} else if (strcmp(*argv, "replay-seqhi") == 0) {
+			NEXT_ARG();
+			if (get_u32(&replay.state.seq_hi, *argv, 0))
+				invarg("\"replay-seqhi\" value is invalid", *argv);
+		} else if (strcmp(*argv, "replay-oseqhi") == 0) {
+			NEXT_ARG();
+			if (get_u32(&replay.state.oseq_hi, *argv, 0))
+				invarg("\"replay-oseqhi\" value is invalid", *argv);
 		} else if (strcmp(*argv, "flag") == 0) {
 			NEXT_ARG();
 			xfrm_state_flag_parse(&req.xsinfo.flags, &argc, &argv);
@@ -434,9 +452,12 @@ parse_algo:
 		argc--; argv++;
 	}
 
-	if (replay.seq || replay.oseq)
-		addattr_l(&req.n, sizeof(req.buf), XFRMA_REPLAY_VAL,
+	if (replay.state.replay_window || replay.state.seq || replay.state.oseq ||
+	    replay.state.seq_hi || replay.state.oseq_hi ) {
+
+		addattr_l(&req.n, sizeof(req.buf), XFRMA_REPLAY_ESN_VAL,
 			  (void *)&replay, sizeof(replay));
+	}
 
 	if (!idp) {
 		fprintf(stderr, "Not enough information: \"ID\" is required\n");
-- 
1.7.0.4
