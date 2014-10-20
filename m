From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] xfrm: add support of ESN and anti-replay window
Date: Mon, 20 Oct 2014 11:23:04 +0200
Message-ID: <1413796984-9867-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, dingzhi <zhi.ding@6wind.com>,
	Adrien Mazarguil <adrien.mazarguil@6wind.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:41932 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285AbaJTJX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 05:23:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: dingzhi <zhi.ding@6wind.com>

This patch allows to configure ESN and anti-replay window.

Signed-off-by: dingzhi <zhi.ding@6wind.com>
Signed-off-by: Adrien Mazarguil <adrien.mazarguil@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/ipxfrm.c     | 57 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 ip/xfrm_state.c | 59 ++++++++++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 109 insertions(+), 7 deletions(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index f5f78ca6b968..659fa6b64579 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -806,6 +806,62 @@ void xfrm_xfrma_print(struct rtattr *tb[], __u16 family,
 		fprintf(fp, "%s", _SL_);
 	}
 
+	if (tb[XFRMA_REPLAY_VAL]) {
+		struct xfrm_replay_state *replay;
+
+		if (prefix)
+			fputs(prefix, fp);
+		fprintf(fp, "anti-replay context: ");
+
+		if (RTA_PAYLOAD(tb[XFRMA_REPLAY_VAL]) < sizeof(*replay)) {
+			fprintf(fp, "(ERROR truncated)");
+			fprintf(fp, "%s", _SL_);
+			return;
+		}
+
+		replay = (struct xfrm_replay_state *)RTA_DATA(tb[XFRMA_REPLAY_VAL]);
+		fprintf(fp, "seq 0x%x, oseq 0x%x, bitmap 0x%08x",
+			replay->seq, replay->oseq, replay->bitmap);
+		fprintf(fp, "%s", _SL_);
+	}
+
+	if (tb[XFRMA_REPLAY_ESN_VAL]) {
+		struct xfrm_replay_state_esn *replay;
+		unsigned int i, j;
+
+		if (prefix)
+			fputs(prefix, fp);
+		fprintf(fp, "anti-replay esn context:");
+
+		if (RTA_PAYLOAD(tb[XFRMA_REPLAY_ESN_VAL]) < sizeof(*replay)) {
+			fprintf(fp, "(ERROR truncated)");
+			fprintf(fp, "%s", _SL_);
+			return;
+		}
+		fprintf(fp, "%s", _SL_);
+
+		replay = (struct xfrm_replay_state_esn *)RTA_DATA(tb[XFRMA_REPLAY_ESN_VAL]);
+		if (prefix)
+			fputs(prefix, fp);
+		fprintf(fp, " seq-hi 0x%x, seq 0x%x, oseq-hi 0x%0x, oseq 0x%0x",
+			replay->seq_hi, replay->seq, replay->oseq_hi,
+			replay->oseq);
+		fprintf(fp, "%s", _SL_);
+		if (prefix)
+			fputs(prefix, fp);
+		fprintf(fp, " replay_window %u, bitmap-length %u",
+			replay->replay_window, replay->bmp_len);
+		for (i = replay->bmp_len, j = 0; i; i--) {
+			if (j++ % 8 == 0) {
+				fprintf(fp, "%s", _SL_);
+				if (prefix)
+					fputs(prefix, fp);
+				fprintf(fp, " ");
+			}
+			fprintf(fp, "%08x ", replay->bmp[i - 1]);
+		}
+		fprintf(fp, "%s", _SL_);
+	}
 }
 
 static int xfrm_selector_iszero(struct xfrm_selector *s)
@@ -849,6 +905,7 @@ void xfrm_state_info_print(struct xfrm_usersa_info *xsinfo,
 		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_ICMP, "icmp");
 		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_AF_UNSPEC, "af-unspec");
 		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_ALIGN4, "align4");
+		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_ESN, "esn");
 		if (flags)
 			fprintf(fp, "%x", flags);
 	}
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index fe7708e533f3..2ad3d8d37fbe 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -58,6 +58,7 @@ static void usage(void)
 	fprintf(stderr, "Usage: ip xfrm state { add | update } ID [ ALGO-LIST ] [ mode MODE ]\n");
 	fprintf(stderr, "        [ mark MARK [ mask MASK ] ] [ reqid REQID ] [ seq SEQ ]\n");
 	fprintf(stderr, "        [ replay-window SIZE ] [ replay-seq SEQ ] [ replay-oseq SEQ ]\n");
+	fprintf(stderr, "        [ replay-seq-hi SEQ ] [ replay-oseq-hi SEQ ]\n");
 	fprintf(stderr, "        [ flag FLAG-LIST ] [ sel SELECTOR ] [ LIMIT-LIST ] [ encap ENCAP ]\n");
 	fprintf(stderr, "        [ coa ADDR[/PLEN] ] [ ctx CTX ] [ extra-flag EXTRA-FLAG-LIST ]\n");
 	fprintf(stderr, "Usage: ip xfrm state allocspi ID [ mode MODE ] [ mark MARK [ mask MASK ] ]\n");
@@ -87,7 +88,7 @@ static void usage(void)
 	fprintf(stderr, " ALGO-NAME\n");
 	fprintf(stderr, "MODE := transport | tunnel | beet | ro | in_trigger\n");
 	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] FLAG\n");
-	fprintf(stderr, "FLAG := noecn | decap-dscp | nopmtudisc | wildrecv | icmp | af-unspec | align4\n");
+	fprintf(stderr, "FLAG := noecn | decap-dscp | nopmtudisc | wildrecv | icmp | af-unspec | align4 | esn\n");
 	fprintf(stderr, "EXTRA-FLAG-LIST := [ EXTRA-FLAG-LIST ] EXTRA-FLAG\n");
 	fprintf(stderr, "EXTRA-FLAG := dont-encap-dscp\n");
 	fprintf(stderr, "SELECTOR := [ src ADDR[/PLEN] ] [ dst ADDR[/PLEN] ] [ dev DEV ] [ UPSPEC ]\n");
@@ -214,6 +215,8 @@ static int xfrm_state_flag_parse(__u8 *flags, int *argcp, char ***argvp)
 				*flags |= XFRM_STATE_AF_UNSPEC;
 			else if (strcmp(*argv, "align4") == 0)
 				*flags |= XFRM_STATE_ALIGN4;
+			else if (strcmp(*argv, "esn") == 0)
+				*flags |= XFRM_STATE_ESN;
 			else {
 				PREV_ARG(); /* back track */
 				break;
@@ -273,6 +276,9 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 		char  			buf[RTA_BUF_SIZE];
 	} req;
 	struct xfrm_replay_state replay;
+	struct xfrm_replay_state_esn replay_esn;
+	__u32 replay_window = 0;
+	__u32 seq = 0, oseq = 0, seq_hi = 0, oseq_hi = 0;
 	char *idp = NULL;
 	char *aeadop = NULL;
 	char *ealgop = NULL;
@@ -289,6 +295,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 
 	memset(&req, 0, sizeof(req));
 	memset(&replay, 0, sizeof(replay));
+	memset(&replay_esn, 0, sizeof(replay_esn));
 	memset(&ctx, 0, sizeof(ctx));
 
 	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.xsinfo));
@@ -315,16 +322,24 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 			xfrm_seq_parse(&req.xsinfo.seq, &argc, &argv);
 		} else if (strcmp(*argv, "replay-window") == 0) {
 			NEXT_ARG();
-			if (get_u8(&req.xsinfo.replay_window, *argv, 0))
+			if (get_u32(&replay_window, *argv, 0))
 				invarg("value after \"replay-window\" is invalid", *argv);
 		} else if (strcmp(*argv, "replay-seq") == 0) {
 			NEXT_ARG();
-			if (get_u32(&replay.seq, *argv, 0))
+			if (get_u32(&seq, *argv, 0))
 				invarg("value after \"replay-seq\" is invalid", *argv);
+		} else if (strcmp(*argv, "replay-seq-hi") == 0) {
+			NEXT_ARG();
+			if (get_u32(&seq_hi, *argv, 0))
+				invarg("value after \"replay-seq-hi\" is invalid", *argv);
 		} else if (strcmp(*argv, "replay-oseq") == 0) {
 			NEXT_ARG();
-			if (get_u32(&replay.oseq, *argv, 0))
+			if (get_u32(&oseq, *argv, 0))
 				invarg("value after \"replay-oseq\" is invalid", *argv);
+		} else if (strcmp(*argv, "replay-oseq-hi") == 0) {
+			NEXT_ARG();
+			if (get_u32(&oseq_hi, *argv, 0))
+				invarg("value after \"replay-oseq-hi\" is invalid", *argv);
 		} else if (strcmp(*argv, "flag") == 0) {
 			NEXT_ARG();
 			xfrm_state_flag_parse(&req.xsinfo.flags, &argc, &argv);
@@ -514,9 +529,39 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 		argc--; argv++;
 	}
 
-	if (replay.seq || replay.oseq)
-		addattr_l(&req.n, sizeof(req.buf), XFRMA_REPLAY_VAL,
-			  (void *)&replay, sizeof(replay));
+	if (req.xsinfo.flags & XFRM_STATE_ESN &&
+	    replay_window == 0) {
+		fprintf(stderr, "Error: esn flag set without replay-window.\n");
+		exit(-1);
+	}
+
+	if (replay_window > XFRMA_REPLAY_ESN_MAX) {
+		fprintf(stderr,
+			"Error: replay-window (%u) > XFRMA_REPLAY_ESN_MAX (%u).\n",
+			replay_window, XFRMA_REPLAY_ESN_MAX);
+		exit(-1);
+	}
+
+	if (req.xsinfo.flags & XFRM_STATE_ESN ||
+	    replay_window > (sizeof(replay.bitmap) * 8)) {
+		replay_esn.seq = seq;
+		replay_esn.oseq = oseq;
+		replay_esn.seq_hi = seq_hi;
+		replay_esn.oseq_hi = oseq_hi;
+		replay_esn.replay_window = replay_window;
+		replay_esn.bmp_len = (replay_window + sizeof(__u32) * 8 - 1) /
+				     (sizeof(__u32) * 8);
+		addattr_l(&req.n, sizeof(req.buf), XFRMA_REPLAY_ESN_VAL,
+			  &replay_esn, sizeof(replay_esn));
+	} else {
+		if (seq || oseq) {
+			replay.seq = seq;
+			replay.oseq = oseq;
+			addattr_l(&req.n, sizeof(req.buf), XFRMA_REPLAY_VAL,
+				  &replay, sizeof(replay));
+		}
+		req.xsinfo.replay_window = replay_window;
+	}
 
 	if (extra_flags)
 		addattr32(&req.n, sizeof(req.buf), XFRMA_SA_EXTRA_FLAGS,
-- 
2.1.0
