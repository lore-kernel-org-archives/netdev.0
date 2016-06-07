From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [PATCH iproute2] tc: f_u32: Add support for skip_hw and skip_sw flags
Date: Tue,  7 Jun 2016 15:59:39 -0700
Message-ID: <1465340379-4709-1-git-send-email-sridhar.samudrala@intel.com>
To: john.r.fastabend@intel.com, jakub.kicinski@netronome.com,
	netdev@vger.kernel.org, shemming@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58771 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751212AbcFGXF2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2016 19:05:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On devices that support TC U32 offloads, these flags enable a filter to be
added only to HW or only to SW. skip_sw and skip_hw are mutually exclusive
flags. By default without any flags, the filter is added to both HW and SW,
but no error checks are done in case of failure to add to HW.
With skip-sw, failure to add to HW is treated as an error.

Here is a sample script that adds 2 filters, one with skip_sw and the other
with skip_hw flag.

   # add ingress qdisc
   tc qdisc add dev p4p1 ingress

   # enable hw tc offload.
   ethtool -K p4p1 hw-tc-offload on

   # add u32 filter with skip-sw flag.
   tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
      handle 800:0:1 u32 ht 800: flowid 800:1 \
      skip-sw \
      match ip src 192.168.1.0/24 \
      action drop

   # add u32 filter with skip-hw flag.
   tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
      handle 800:0:2 u32 ht 800: flowid 800:2 \
      skip-hw \
      match ip src 192.168.2.0/24 \
      action drop

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
---
 tc/f_u32.c | 30 +++++++++++++++++++++++++++++-
 1 file changed, 29 insertions(+), 1 deletion(-)

diff --git a/tc/f_u32.c b/tc/f_u32.c
index 6299515..f26fdea 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -30,7 +30,7 @@ extern int show_pretty;
 
 static void explain(void)
 {
-	fprintf(stderr, "Usage: ... u32 [ match SELECTOR ... ] [ link HTID ] [ classid CLASSID ]\n");
+	fprintf(stderr, "Usage: ... u32 [ match SELECTOR ... ] [ link HTID ] [ classid CLASSID ] [skip_hw | skip_sw]\n");
 	fprintf(stderr, "               [ action ACTION_SPEC ] [ offset OFFSET_SPEC ]\n");
 	fprintf(stderr, "               [ ht HTID ] [ hashkey HASHKEY_SPEC ]\n");
 	fprintf(stderr, "               [ sample SAMPLE ]\n");
@@ -992,6 +992,7 @@ static int u32_parse_opt(struct filter_util *qu, char *handle,
 	int sample_ok = 0;
 	__u32 htid = 0;
 	__u32 order = 0;
+	__u32 flags = 0;
 
 	memset(&sel, 0, sizeof(sel));
 
@@ -1149,6 +1150,14 @@ static int u32_parse_opt(struct filter_util *qu, char *handle,
 			}
 			terminal_ok++;
 			continue;
+		} else if (strcmp(*argv, "skip_hw") == 0) {
+			NEXT_ARG();
+			flags |= TCA_CLS_FLAGS_SKIP_HW;
+			continue;
+		} else if (strcmp(*argv, "skip_sw") == 0) {
+			NEXT_ARG();
+			flags |= TCA_CLS_FLAGS_SKIP_SW;
+			continue;
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -1177,6 +1186,16 @@ static int u32_parse_opt(struct filter_util *qu, char *handle,
 	if (sel_ok)
 		addattr_l(n, MAX_MSG, TCA_U32_SEL, &sel,
 			  sizeof(sel.sel) + sel.sel.nkeys * sizeof(struct tc_u32_key));
+
+	if (flags) {
+		if (!(flags ^ (TCA_CLS_FLAGS_SKIP_HW | TCA_CLS_FLAGS_SKIP_SW))) {
+			fprintf(stderr, "skip_hw and skip_sw are mutually "
+				"exclusive flags. Only one can be set\n");
+			return -1;
+		}
+		addattr_l(n, MAX_MSG, TCA_U32_FLAGS, &flags, 4);
+	}
+
 	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
 	return 0;
 }
@@ -1232,6 +1251,15 @@ static int u32_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt,
 			sprint_u32_handle(rta_getattr_u32(tb[TCA_U32_LINK]), b1));
 	}
 
+	if (tb[TCA_U32_FLAGS]) {
+		__u32 flags = rta_getattr_u32(tb[TCA_U32_FLAGS]);
+
+		if (flags & TCA_CLS_FLAGS_SKIP_HW)
+			fprintf(f, "skip_hw ");
+		if (flags & TCA_CLS_FLAGS_SKIP_SW)
+			fprintf(f, "skip_sw ");
+	}
+
 	if (tb[TCA_U32_PCNT]) {
 		if (RTA_PAYLOAD(tb[TCA_U32_PCNT])  < sizeof(*pf)) {
 			fprintf(f, "Broken perf counters\n");
-- 
2.1.0
