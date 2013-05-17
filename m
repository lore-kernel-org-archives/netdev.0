From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] ip/xfrm: all to set flag XFRM_SA_XFLAG_DONT_ENCAP_DSCP
Date: Fri, 17 May 2013 10:36:15 +0200
Message-ID: <1368779775-5210-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:54202 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487Ab3EQIgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 04:36:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the display part, we print extra-flags only if show_stats is set, like for
standard flags.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/ipxfrm.c     | 10 ++++++++++
 ip/xfrm_state.c | 45 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 54 insertions(+), 1 deletion(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 0495ff4..0a3a9fb 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -856,6 +856,16 @@ void xfrm_state_info_print(struct xfrm_usersa_info *xsinfo,
 		if (flags)
 			fprintf(fp, "%x", flags);
 	}
+	if (show_stats > 0 || tb[XFRMA_SA_EXTRA_FLAGS]) {
+		__u32 extra_flags = *(__u32 *)RTA_DATA(tb[XFRMA_SA_EXTRA_FLAGS]);
+
+		fprintf(fp, "extra_flag ");
+		XFRM_FLAG_PRINT(fp, extra_flags,
+				XFRM_SA_XFLAG_DONT_ENCAP_DSCP,
+				"dont-encap-dscp");
+		if (extra_flags)
+			fprintf(fp, "%x", extra_flags);
+	}
 	if (show_stats > 0)
 		fprintf(fp, " (0x%s)", strxf_mask8(xsinfo->flags));
 	fprintf(fp, "%s", _SL_);
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 61a8f02..389942c 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -60,7 +60,7 @@ static void usage(void)
 	fprintf(stderr, "        [ mark MARK [ mask MASK ] ] [ reqid REQID ] [ seq SEQ ]\n");
 	fprintf(stderr, "        [ replay-window SIZE ] [ replay-seq SEQ ] [ replay-oseq SEQ ]\n");
 	fprintf(stderr, "        [ flag FLAG-LIST ] [ sel SELECTOR ] [ LIMIT-LIST ] [ encap ENCAP ]\n");
-	fprintf(stderr, "        [ coa ADDR[/PLEN] ] [ ctx CTX ]\n");
+	fprintf(stderr, "        [ coa ADDR[/PLEN] ] [ ctx CTX ] [ extra-flag EXTRA-FLAG-LIST ]\n");
 	fprintf(stderr, "Usage: ip xfrm state allocspi ID [ mode MODE ] [ mark MARK [ mask MASK ] ]\n");
 	fprintf(stderr, "        [ reqid REQID ] [ seq SEQ ] [ min SPI max SPI ]\n");
 	fprintf(stderr, "Usage: ip xfrm state { delete | get } ID [ mark MARK [ mask MASK ] ]\n");
@@ -89,6 +89,8 @@ static void usage(void)
 	fprintf(stderr, "MODE := transport | tunnel | beet | ro | in_trigger\n");
 	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] FLAG\n");
 	fprintf(stderr, "FLAG := noecn | decap-dscp | nopmtudisc | wildrecv | icmp | af-unspec | align4\n");
+	fprintf(stderr, "EXTRA-FLAG-LIST := [ EXTRA-FLAG-LIST ] EXTRA-FLAG\n");
+	fprintf(stderr, "EXTRA-FLAG := dont-encap-dscp\n");
 	fprintf(stderr, "SELECTOR := [ src ADDR[/PLEN] ] [ dst ADDR[/PLEN] ] [ dev DEV ] [ UPSPEC ]\n");
 	fprintf(stderr, "UPSPEC := proto { { ");
 	fprintf(stderr, "%s | ", strxf_proto(IPPROTO_TCP));
@@ -230,6 +232,39 @@ static int xfrm_state_flag_parse(__u8 *flags, int *argcp, char ***argvp)
 	return 0;
 }
 
+static int xfrm_state_extra_flag_parse(__u32 *extra_flags, int *argcp, char ***argvp)
+{
+	int argc = *argcp;
+	char **argv = *argvp;
+	int len = strlen(*argv);
+
+	if (len > 2 && strncmp(*argv, "0x", 2) == 0) {
+		__u32 val = 0;
+
+		if (get_u32(&val, *argv, 16))
+			invarg("\"EXTRA-FLAG\" is invalid", *argv);
+		*extra_flags = val;
+	} else {
+		while (1) {
+			if (strcmp(*argv, "dont-encap-dscp") == 0)
+				*extra_flags |= XFRM_SA_XFLAG_DONT_ENCAP_DSCP;
+			else {
+				PREV_ARG(); /* back track */
+				break;
+			}
+
+			if (!NEXT_ARG_OK())
+				break;
+			NEXT_ARG();
+		}
+	}
+
+	*argcp = argc;
+	*argvp = argv;
+
+	return 0;
+}
+
 static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 {
 	struct rtnl_handle rth;
@@ -246,6 +281,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 	char *calgop = NULL;
 	char *coap = NULL;
 	char *sctxp = NULL;
+	__u32 extra_flags = 0;
 	struct xfrm_mark mark = {0, 0};
 	struct {
 		struct xfrm_user_sec_ctx sctx;
@@ -293,6 +329,9 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 		} else if (strcmp(*argv, "flag") == 0) {
 			NEXT_ARG();
 			xfrm_state_flag_parse(&req.xsinfo.flags, &argc, &argv);
+		} else if (strcmp(*argv, "extra-flag") == 0) {
+			NEXT_ARG();
+			xfrm_state_extra_flag_parse(&extra_flags, &argc, &argv);
 		} else if (strcmp(*argv, "sel") == 0) {
 			NEXT_ARG();
 			preferred_family = AF_UNSPEC;
@@ -480,6 +519,10 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 		addattr_l(&req.n, sizeof(req.buf), XFRMA_REPLAY_VAL,
 			  (void *)&replay, sizeof(replay));
 
+	if (extra_flags)
+		addattr32(&req.n, sizeof(req.buf), XFRMA_SA_EXTRA_FLAGS,
+			  extra_flags);
+
 	if (!idp) {
 		fprintf(stderr, "Not enough information: ID is required\n");
 		exit(1);
-- 
1.8.2.1
