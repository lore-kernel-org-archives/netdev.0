From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 2/3] [IPROUTE2] ip: xfrm: Fix policy and state flags.
Date: Fri, 24 Aug 2007 11:05:18 +0900
Message-ID: <11879211182007-git-send-email-nakam@linux-ipv6.org>
Cc: Masahide NAKAMURA <nakam@linux-ipv6.org>
To: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:44739 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1765764AbXHXC0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 22:26:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

o Support policy flag with string format.
  Note that kernel defines only one name "localok" for the flag
  and it has not had any effect currently.
o Support state flag value XFRM_STATE_NOPMTUDISC.
o Fix to show detailed flags value when "-s" option is used.
o Fix minor typo.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 ip/ipxfrm.c      |   18 +++++++++++++---
 ip/xfrm.h        |    1 +
 ip/xfrm_policy.c |   55 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 ip/xfrm_state.c  |    6 +++-
 4 files changed, 72 insertions(+), 8 deletions(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index d9b0e3b..359a2d2 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -745,12 +745,13 @@ void xfrm_state_info_print(struct xfrm_usersa_info *xsinfo,
 		fprintf(fp, "flag ");
 		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_NOECN, "noecn");
 		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_DECAP_DSCP, "decap-dscp");
+		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_NOPMTUDISC, "nopmtudisc");
 		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_WILDRECV, "wildrecv");
 		if (flags)
 			fprintf(fp, "%x", flags);
-		if (show_stats > 0)
-			fprintf(fp, " (0x%s)", strxf_mask8(flags));
 	}
+	if (show_stats > 0)
+		fprintf(fp, " (0x%s)", strxf_mask8(xsinfo->flags));
 	fprintf(fp, "%s", _SL_);
 
 	xfrm_xfrma_print(tb, xsinfo->family, fp, buf);
@@ -845,10 +846,19 @@ void xfrm_policy_info_print(struct xfrm_userpolicy_info *xpinfo,
 	}
 	fprintf(fp, " ");
 
-	if (show_stats > 0) {
+	if (show_stats > 0)
 		fprintf(fp, "share %s ", strxf_share(xpinfo->share));
-		fprintf(fp, "flag 0x%s", strxf_mask8(xpinfo->flags));
+
+	if (show_stats > 0 || xpinfo->flags) {
+		__u8 flags = xpinfo->flags;
+
+		fprintf(fp, "flag ");
+		XFRM_FLAG_PRINT(fp, flags, XFRM_POLICY_LOCALOK, "localok");
+		if (flags)
+			fprintf(fp, "%x", flags);
 	}
+	if (show_stats > 0)
+		fprintf(fp, " (0x%s)", strxf_mask8(xpinfo->flags));
 	fprintf(fp, "%s", _SL_);
 
 	if (show_stats > 0)
diff --git a/ip/xfrm.h b/ip/xfrm.h
index 71345b9..335c2a5 100644
--- a/ip/xfrm.h
+++ b/ip/xfrm.h
@@ -98,6 +98,7 @@ struct xfrm_filter {
 	__u32 index_mask;
 	__u8 action_mask;
 	__u32 priority_mask;
+	__u8 policy_flags_mask;
 
 	__u8 ptype;
 	__u8 ptype_mask;
diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index f4488ac..419ca67 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -54,10 +54,10 @@ static void usage(void) __attribute__((noreturn));
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ip xfrm policy { add | update } dir DIR SELECTOR [ index INDEX ] [ ptype PTYPE ]\n");
-	fprintf(stderr, "        [ action ACTION ] [ priority PRIORITY ] [ LIMIT-LIST ] [ TMPL-LIST ]\n");
+	fprintf(stderr, "        [ action ACTION ] [ priority PRIORITY ] [ flag FLAG-LIST ] [ LIMIT-LIST ] [ TMPL-LIST ]\n");
 	fprintf(stderr, "Usage: ip xfrm policy { delete | get } dir DIR [ SELECTOR | index INDEX ] [ ptype PTYPE ]\n");
 	fprintf(stderr, "Usage: ip xfrm policy { deleteall | list } [ dir DIR ] [ SELECTOR ]\n");
-	fprintf(stderr, "        [ index INDEX ] [ action ACTION ] [ priority PRIORITY ]\n");
+	fprintf(stderr, "        [ index INDEX ] [ action ACTION ] [ priority PRIORITY ]  [ flag FLAG-LIST ]\n");
 	fprintf(stderr, "Usage: ip xfrm policy flush [ ptype PTYPE ]\n");
 	fprintf(stderr, "Usage: ip xfrm count\n");
 	fprintf(stderr, "PTYPE := [ main | sub ](default=main)\n");
@@ -74,6 +74,9 @@ static void usage(void)
 
 	//fprintf(stderr, "PRIORITY - priority value(default=0)\n");
 
+	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] FLAG\n");
+	fprintf(stderr, "FLAG := [ localok ]\n");
+
 	fprintf(stderr, "LIMIT-LIST := [ LIMIT-LIST ] | [ limit LIMIT ]\n");
 	fprintf(stderr, "LIMIT := [ [time-soft|time-hard|time-use-soft|time-use-hard] SECONDS ] |\n");
 	fprintf(stderr, "         [ [byte-soft|byte-hard] SIZE ] | [ [packet-soft|packet-hard] NUMBER ]\n");
@@ -135,6 +138,39 @@ static int xfrm_policy_ptype_parse(__u8 *ptype, int *argcp, char ***argvp)
 	return 0;
 }
 
+static int xfrm_policy_flag_parse(__u8 *flags, int *argcp, char ***argvp)
+{
+	int argc = *argcp;
+	char **argv = *argvp;
+	int len = strlen(*argv);
+
+	if (len > 2 && strncmp(*argv, "0x", 2) == 0) {
+		__u8 val = 0;
+
+		if (get_u8(&val, *argv, 16))
+			invarg("\"FLAG\" is invalid", *argv);
+		*flags = val;
+	} else {
+		while (1) {
+			if (strcmp(*argv, "localok") == 0)
+				*flags |= XFRM_POLICY_LOCALOK;
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
 static int xfrm_tmpl_parse(struct xfrm_user_tmpl *tmpl,
 			   int *argcp, char ***argvp)
 {
@@ -245,6 +281,10 @@ static int xfrm_policy_modify(int cmd, unsigned flags, int argc, char **argv)
 			NEXT_ARG();
 			if (get_u32(&req.xpinfo.priority, *argv, 0))
 				invarg("\"PRIORITY\" is invalid", *argv);
+		} else if (strcmp(*argv, "flag") == 0) {
+			NEXT_ARG();
+			xfrm_policy_flag_parse(&req.xpinfo.flags, &argc,
+					       &argv);
 		} else if (strcmp(*argv, "limit") == 0) {
 			NEXT_ARG();
 			xfrm_lifetime_cfg_parse(&req.xpinfo.lft, &argc, &argv);
@@ -357,6 +397,10 @@ static int xfrm_policy_filter_match(struct xfrm_userpolicy_info *xpinfo,
 	if ((xpinfo->priority^filter.xpinfo.priority)&filter.priority_mask)
 		return 0;
 
+	if (filter.policy_flags_mask)
+		if ((xpinfo->flags & filter.xpinfo.flags) == 0)
+			return 0;
+
 	return 1;
 }
 
@@ -684,6 +728,13 @@ static int xfrm_policy_list_or_deleteall(int argc, char **argv, int deleteall)
 
 			filter.priority_mask = XFRM_FILTER_MASK_FULL;
 
+		} else if (strcmp(*argv, "flag") == 0) {
+			NEXT_ARG();
+			xfrm_policy_flag_parse(&filter.xpinfo.flags, &argc,
+					       &argv);
+
+			filter.policy_flags_mask = XFRM_FILTER_MASK_FULL;
+
 		} else {
 			if (selp)
 				invarg("unknown", *argv);
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 2b68f49..29604a5 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -62,7 +62,7 @@ static void usage(void)
 	fprintf(stderr, "        [ min SPI max SPI ]\n");
 	fprintf(stderr, "Usage: ip xfrm state { delete | get } ID\n");
 	fprintf(stderr, "Usage: ip xfrm state { deleteall | list } [ ID ] [ mode MODE ] [ reqid REQID ]\n");
-	fprintf(stderr, "        [ flag FLAG_LIST ]\n");
+	fprintf(stderr, "        [ flag FLAG-LIST ]\n");
 	fprintf(stderr, "Usage: ip xfrm state flush [ proto XFRM_PROTO ]\n");
 	fprintf(stderr, "Usage: ip xfrm state count \n");
 
@@ -82,7 +82,7 @@ static void usage(void)
  	//fprintf(stderr, "REQID - number(default=0)\n");
 
 	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] FLAG\n");
-	fprintf(stderr, "FLAG := [ noecn | decap-dscp | wildrecv ]\n");
+	fprintf(stderr, "FLAG := [ noecn | decap-dscp | nopmtudisc | wildrecv ]\n");
 
         fprintf(stderr, "ENCAP := ENCAP-TYPE SPORT DPORT OADDR\n");
         fprintf(stderr, "ENCAP-TYPE := espinudp | espinudp-nonike\n");
@@ -203,6 +203,8 @@ static int xfrm_state_flag_parse(__u8 *flags, int *argcp, char ***argvp)
 				*flags |= XFRM_STATE_NOECN;
 			else if (strcmp(*argv, "decap-dscp") == 0)
 				*flags |= XFRM_STATE_DECAP_DSCP;
+			else if (strcmp(*argv, "nopmtudisc") == 0)
+				*flags |= XFRM_STATE_NOPMTUDISC;
 			else if (strcmp(*argv, "wildrecv") == 0)
 				*flags |= XFRM_STATE_WILDRECV;
 			else {
-- 
1.4.4.2

