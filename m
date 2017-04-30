From: <ilant@mellanox.com>
Subject: [PATCH iproute2 net-next] ip xfrm: Add xfrm state crypto offload
Date: Sun, 30 Apr 2017 17:16:02 +0300
Message-ID: <20170430141602.30995-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>, Boris Pismenny <borisp@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr40052.outbound.protection.outlook.com ([40.107.4.52]:14630
        "EHLO EUR03-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1163684AbdD3OQ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 10:16:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Boris Pismenny <borisp@mellanox.com>

syntax:
ip xfrm state .... offload dev <if-name> dir <in or out>

Example to add inbound offload:
  ip xfrm state .... offload dev mlx0 dir in
Example to add outbound offload:
  ip xfrm state .... offload dev mlx0 dir out

Signed-off-by: Boris Pismenny <borisp@mellanox.com>
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
---
 ip/ipxfrm.c     | 19 +++++++++++++++++++
 ip/xfrm_state.c | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 68 insertions(+)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index b0cfac17..d5eb22e2 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -862,6 +862,25 @@ void xfrm_xfrma_print(struct rtattr *tb[], __u16 family,
 		}
 		fprintf(fp, "%s", _SL_);
 	}
+	if (tb[XFRMA_OFFLOAD_DEV]) {
+		struct xfrm_user_offload *xuo;
+
+		if (prefix)
+			fputs(prefix, fp);
+		fprintf(fp, "crypto offload parameters: ");
+
+		if (RTA_PAYLOAD(tb[XFRMA_OFFLOAD_DEV]) < sizeof(*xuo)) {
+			fprintf(fp, "(ERROR truncated)");
+			fprintf(fp, "%s", _SL_);
+			return;
+		}
+
+		xuo = (struct xfrm_user_offload *)
+			RTA_DATA(tb[XFRMA_OFFLOAD_DEV]);
+		fprintf(fp, "dev %s dir %s", ll_index_to_name(xuo->ifindex),
+			(xuo->flags & XFRM_OFFLOAD_INBOUND) ? "in" : "out");
+		fprintf(fp, "%s", _SL_);
+	}
 }
 
 static int xfrm_selector_iszero(struct xfrm_selector *s)
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index ea7d4f34..e11c93bf 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -60,6 +60,7 @@ static void usage(void)
 	fprintf(stderr, "        [ replay-seq-hi SEQ ] [ replay-oseq-hi SEQ ]\n");
 	fprintf(stderr, "        [ flag FLAG-LIST ] [ sel SELECTOR ] [ LIMIT-LIST ] [ encap ENCAP ]\n");
 	fprintf(stderr, "        [ coa ADDR[/PLEN] ] [ ctx CTX ] [ extra-flag EXTRA-FLAG-LIST ]\n");
+	fprintf(stderr, "        [ offload [dev DEV] dir DIR ]\n");
 	fprintf(stderr, "Usage: ip xfrm state allocspi ID [ mode MODE ] [ mark MARK [ mask MASK ] ]\n");
 	fprintf(stderr, "        [ reqid REQID ] [ seq SEQ ] [ min SPI max SPI ]\n");
 	fprintf(stderr, "Usage: ip xfrm state { delete | get } ID [ mark MARK [ mask MASK ] ]\n");
@@ -108,6 +109,7 @@ static void usage(void)
 	fprintf(stderr, "LIMIT := { time-soft | time-hard | time-use-soft | time-use-hard } SECONDS |\n");
 	fprintf(stderr, "         { byte-soft | byte-hard } SIZE | { packet-soft | packet-hard } COUNT\n");
 	fprintf(stderr, "ENCAP := { espinudp | espinudp-nonike } SPORT DPORT OADDR\n");
+	fprintf(stderr, "DIR := in | out\n");
 
 	exit(-1);
 }
@@ -264,6 +266,24 @@ static int xfrm_state_extra_flag_parse(__u32 *extra_flags, int *argcp, char ***a
 	return 0;
 }
 
+static int xfrm_offload_dir_parse(__u8 *dir, int *argcp, char ***argvp)
+{
+	int argc = *argcp;
+	char **argv = *argvp;
+
+	if (strcmp(*argv, "in") == 0)
+		*dir = XFRM_OFFLOAD_INBOUND;
+	else if (strcmp(*argv, "out") == 0)
+		*dir = 0;
+	else
+		invarg("DIR value is invalid", *argv);
+
+	*argcp = argc;
+	*argvp = argv;
+
+	return 0;
+}
+
 static int xfrm_state_modify(int cmd, unsigned int flags, int argc, char **argv)
 {
 	struct rtnl_handle rth;
@@ -283,6 +303,10 @@ static int xfrm_state_modify(int cmd, unsigned int flags, int argc, char **argv)
 	};
 	struct xfrm_replay_state replay = {};
 	struct xfrm_replay_state_esn replay_esn = {};
+	struct xfrm_user_offload xuo = {};
+	unsigned int ifindex = 0;
+	__u8 dir = 0;
+	bool is_offload = false;
 	__u32 replay_window = 0;
 	__u32 seq = 0, oseq = 0, seq_hi = 0, oseq_hi = 0;
 	char *idp = NULL;
@@ -394,6 +418,25 @@ static int xfrm_state_modify(int cmd, unsigned int flags, int argc, char **argv)
 			xfrm_sctx_parse((char *)&ctx.str, context, &ctx.sctx);
 			addattr_l(&req.n, sizeof(req.buf), XFRMA_SEC_CTX,
 				  (void *)&ctx, ctx.sctx.len);
+		} else if (strcmp(*argv, "offload") == 0) {
+			is_offload = true;
+			NEXT_ARG();
+			if (strcmp(*argv, "dev") == 0) {
+				NEXT_ARG();
+				ifindex = ll_name_to_index(*argv);
+				if (!ifindex) {
+					invarg("value after \"offload dev\" is invalid", *argv);
+					is_offload = false;
+				}
+				NEXT_ARG();
+			}
+			if (strcmp(*argv, "dir") == 0) {
+				NEXT_ARG();
+				xfrm_offload_dir_parse(&dir, &argc, &argv);
+			} else {
+				invarg("value after \"offload dir\" is invalid", *argv);
+				is_offload = false;
+			}
 		} else {
 			/* try to assume ALGO */
 			int type = xfrm_algotype_getbyname(*argv);
@@ -531,6 +574,12 @@ static int xfrm_state_modify(int cmd, unsigned int flags, int argc, char **argv)
 		exit(-1);
 	}
 
+	if (is_offload) {
+		xuo.ifindex = ifindex;
+		xuo.flags = dir;
+		addattr_l(&req.n, sizeof(req.buf), XFRMA_OFFLOAD_DEV, &xuo,
+			  sizeof(xuo));
+	}
 	if (req.xsinfo.flags & XFRM_STATE_ESN ||
 	    replay_window > (sizeof(replay.bitmap) * 8)) {
 		replay_esn.seq = seq;
-- 
2.11.0
