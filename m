From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IP] xfrm: Allow replay setting
Date: Wed, 23 Apr 2008 15:42:32 +0800
Message-ID: <20080423074232.GA29974@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36580 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750963AbYDWHmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 03:42:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen:

[IP] xfrm: Allow replay setting

For certain applications there is a requirement to start the
sequence number from a point other than the default.  As it
is the kernel provides an interface to do that but it isn't
available through the ip(8) command.  Since we're encouraging
people to migrate over to ip(8) for manual keying, it is useful
to have this ability there.

This patch adds support for setting replay sequence numbers
through ip(8).

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 93b4a2a..a369222 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -57,7 +57,8 @@ static void usage(void)
 {
 	fprintf(stderr, "Usage: ip xfrm state { add | update } ID [ XFRM_OPT ] [ mode MODE ]\n");
 	fprintf(stderr, "        [ reqid REQID ] [ seq SEQ ] [ replay-window SIZE ] [ flag FLAG-LIST ]\n");
-	fprintf(stderr, "        [ encap ENCAP ] [ sel SELECTOR ] [ LIMIT-LIST ]\n");
+	fprintf(stderr, "        [ encap ENCAP ] [ sel SELECTOR ] [ replay-seq SEQ ]\n");
+	fprintf(stderr, "        [ replay-oseq SEQ ] [ LIMIT-LIST ]\n");
 	fprintf(stderr, "Usage: ip xfrm state allocspi ID [ mode MODE ] [ reqid REQID ] [ seq SEQ ]\n");
 	fprintf(stderr, "        [ min SPI max SPI ]\n");
 	fprintf(stderr, "Usage: ip xfrm state { delete | get } ID\n");
@@ -232,6 +233,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 		struct xfrm_usersa_info xsinfo;
 		char   			buf[RTA_BUF_SIZE];
 	} req;
+	struct xfrm_replay_state replay;
 	char *idp = NULL;
 	char *ealgop = NULL;
 	char *aalgop = NULL;
@@ -239,6 +241,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 	char *coap = NULL;
 
 	memset(&req, 0, sizeof(req));
+	memset(&replay, 0, sizeof(replay));
 
 	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.xsinfo));
 	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
@@ -264,6 +267,14 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 			NEXT_ARG();
 			if (get_u8(&req.xsinfo.replay_window, *argv, 0))
 				invarg("\"replay-window\" value is invalid", *argv);
+		} else if (strcmp(*argv, "replay-seq") == 0) {
+			NEXT_ARG();
+			if (get_u32(&replay.seq, *argv, 0))
+				invarg("\"replay-seq\" value is invalid", *argv);
+		} else if (strcmp(*argv, "replay-oseq") == 0) {
+			NEXT_ARG();
+			if (get_u32(&replay.oseq, *argv, 0))
+				invarg("\"replay-oseq\" value is invalid", *argv);
 		} else if (strcmp(*argv, "flag") == 0) {
 			NEXT_ARG();
 			xfrm_state_flag_parse(&req.xsinfo.flags, &argc, &argv);
@@ -386,6 +397,10 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 		argc--; argv++;
 	}
 
+	if (replay.seq || replay.oseq)
+		addattr_l(&req.n, sizeof(req.buf), XFRMA_REPLAY_VAL,
+			  (void *)&replay, sizeof(replay));
+
 	if (!idp) {
 		fprintf(stderr, "Not enough information: \"ID\" is required\n");
 		exit(1);
