From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC PATCH] iproute2: Add IPsec extended sequence number support
Date: Tue, 8 Mar 2011 11:12:31 +0100
Message-ID: <20110308101230.GL31402@secunet.com>
References: <20110308100407.GB31402@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alex Badea <abadea@ixiacom.com>,
	Andreas Gruenbacher <agruen@suse.de>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110308100407.GB31402@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


---

The patch is based on branch 'net-next' of
git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

 include/linux/xfrm.h |   12 ++++++++++++
 ip/ipxfrm.c          |    8 +++++++-
 ip/xfrm_state.c      |   35 ++++++++++++++++++++++++++++-------
 3 files changed, 47 insertions(+), 8 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index b405b70..fcda53c 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -84,6 +84,16 @@ struct xfrm_replay_state {
 	__u32	bitmap;
 };
 
+struct xfrm_replay_state_esn {
+	unsigned int	bmp_len;
+	__u32		oseq;
+	__u32		seq;
+	__u32		oseq_hi;
+	__u32		seq_hi;
+	__u32	replay_window;
+	__u32	bmp[0];
+};
+
 struct xfrm_algo {
 	char		alg_name[64];
 	unsigned int	alg_key_len;    /* in bits */
@@ -284,6 +294,7 @@ enum xfrm_attr_type_t {
 	XFRMA_ALG_AUTH_TRUNC,	/* struct xfrm_algo_auth */
 	XFRMA_MARK,		/* struct xfrm_mark */
 	XFRMA_TFCPAD,		/* __u32 */
+	XFRMA_REPLAY_ESN_VAL,	/* struct xfrm_replay_esn */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
@@ -351,6 +362,7 @@ struct xfrm_usersa_info {
 #define XFRM_STATE_ICMP		16
 #define XFRM_STATE_AF_UNSPEC	32
 #define XFRM_STATE_ALIGN4	64
+#define XFRM_STATE_ESN          128
 };
 
 struct xfrm_usersa_id {
diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 0c7aaad..1dc496e 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -691,6 +691,12 @@ done:
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
@@ -841,7 +847,6 @@ void xfrm_state_info_print(struct xfrm_usersa_info *xsinfo,
 	STRBUF_CAT(buf, "\t");
 
 	fputs(buf, fp);
-	fprintf(fp, "replay-window %u ", xsinfo->replay_window);
 	if (show_stats > 0)
 		fprintf(fp, "seq 0x%08u ", xsinfo->seq);
 	if (show_stats > 0 || xsinfo->flags) {
@@ -855,6 +860,7 @@ void xfrm_state_info_print(struct xfrm_usersa_info *xsinfo,
 		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_ICMP, "icmp");
 		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_AF_UNSPEC, "af-unspec");
 		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_ALIGN4, "align4");
+		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_ESN, "replay-esn");
 		if (flags)
 			fprintf(fp, "%x", flags);
 	}
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 8ac3437..9a25ad3 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -51,6 +51,7 @@
 #define RTA_BUF_SIZE 2048
 #define XFRM_ALGO_KEY_BUF_SIZE 512
 #define CTX_BUF_SIZE 256
+#define XFRM_REPLAY_BMP_SIZE_U32 16
 
 static void usage(void) __attribute__((noreturn));
 
@@ -59,7 +60,7 @@ static void usage(void)
 	fprintf(stderr, "Usage: ip xfrm state { add | update } ID [ XFRM_OPT ] [ ctx SEC_CTX ] [ mode MODE ]\n");
 	fprintf(stderr, "        [ reqid REQID ] [ seq SEQ ] [ replay-window SIZE ] [ flag FLAG-LIST ]\n");
 	fprintf(stderr, "        [ encap ENCAP ] [ sel SELECTOR ] [ replay-seq SEQ ]\n");
-	fprintf(stderr, "        [ replay-oseq SEQ ] [ LIMIT-LIST ]\n");
+	fprintf(stderr, "        [ replay-oseq SEQ ] [ replay-seqhi SEQ ] [ replay-oseqhi SEQ ] [ LIMIT-LIST ]\n");
 	fprintf(stderr, "Usage: ip xfrm state allocspi ID [ mode MODE ] [ reqid REQID ] [ seq SEQ ]\n");
 	fprintf(stderr, "        [ min SPI max SPI ]\n");
 	fprintf(stderr, "Usage: ip xfrm state { delete | get } ID\n");
@@ -218,6 +219,8 @@ static int xfrm_state_flag_parse(__u8 *flags, int *argcp, char ***argvp)
 				*flags |= XFRM_STATE_AF_UNSPEC;
 			else if (strcmp(*argv, "align4") == 0)
 				*flags |= XFRM_STATE_ALIGN4;
+			else if (strcmp(*argv, "replay-esn") == 0)
+				*flags |= XFRM_STATE_ESN;
 			else {
 				PREV_ARG(); /* back track */
 				break;
@@ -243,7 +246,11 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
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
@@ -258,9 +265,12 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 	} ctx;
 
 	memset(&req, 0, sizeof(req));
+
 	memset(&replay, 0, sizeof(replay));
 	memset(&ctx, 0, sizeof(ctx));
 
+	replay.state.bmp_len = XFRM_REPLAY_BMP_SIZE_U32;
+
 	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.xsinfo));
 	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
 	req.n.nlmsg_type = cmd;
@@ -285,16 +295,24 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
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
@@ -472,9 +490,12 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
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
