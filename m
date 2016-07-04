From: Amir Vadai <amir@vadai.me>
Subject: [PATCH iproute2] tc: flower: Add skip_{hw|sw} support
Date: Mon,  4 Jul 2016 10:34:11 +0300
Message-ID: <20160704073411.17633-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35646 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898AbcGDHea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 03:34:30 -0400
Received: by mail-wm0-f67.google.com with SMTP id a66so19511686wme.2
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2016 00:34:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirva@mellanox.com>

On devices that support TC flower offloads, these flags enable a filter to be
added only to HW or only to SW. skip_sw and skip_hw are mutually exclusive
flags. By default without any flags, the filter is added to both HW and SW,
but no error checks are done in case of failure to add to HW.
With skip-sw, failure to add to HW is treated as an error.

Here is a sample script that adds 2 filters, one with skip_sw and the other
with skip_hw flag.

   # add ingress qdisc
   tc qdisc add dev enp0s9 ingress

   # enable hw tc offload.
   ethtool -K enp0s9 hw-tc-offload on

   # add a flower filter with skip-sw flag.
   tc filter add dev enp0s9 protocol ip parent ffff: flower \
	   ip_proto 1 indev enp0s9 skip_sw \
	   action drop

   # add a flower filter with skip-hw flag.
   tc filter add dev enp0s9 protocol ip parent ffff: flower \
	   ip_proto 3 indev enp0s9 skip_hw \
	   action drop

Signed-off-by: Amir Vadai <amirva@mellanox.com>
---
 man/man8/tc-flower.8 | 11 ++++++++++-
 tc/f_flower.c        | 17 +++++++++++++++++
 2 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index df4d8e1..9ae10e6 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -18,7 +18,9 @@ flower \- flow based traffic control filter
 .ti -8
 .IR MATCH " := { "
 .B indev
-.IR ifname " | { "
+.IR ifname " | "
+.BR skip_sw " | " skip_hw
+.R " | { "
 .BR dst_mac " | " src_mac " } "
 .IR mac_address " | "
 .BR eth_type " { " ipv4 " | " ipv6 " | "
@@ -55,6 +57,13 @@ is the name of an interface which must exist at the time of
 .B tc
 invocation.
 .TP
+.BI skip_sw
+Do not process filter by software. If hardware has no offload support for this
+filter, or TC offload is not enabled for the interface, operation will fail.
+.TP
+.BI skip_hw
+Do not process filter by hardware.
+.TP
 .BI dst_mac " mac_address"
 .TQ
 .BI src_mac " mac_address"
diff --git a/tc/f_flower.c b/tc/f_flower.c
index fd2014b..7b46ceb 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -25,6 +25,7 @@
 static void explain(void)
 {
 	fprintf(stderr, "Usage: ... flower [ MATCH-LIST ]\n");
+	fprintf(stderr, "                  [ skip_sw | skip_hw ]\n");
 	fprintf(stderr, "                  [ action ACTION-SPEC ] [ classid CLASSID ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: MATCH-LIST := [ MATCH-LIST ] MATCH\n");
@@ -167,6 +168,7 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 	struct rtattr *tail;
 	__be16 eth_type = TC_H_MIN(t->tcm_info);
 	__u8 ip_proto = 0xff;
+	__u32 flags = 0;
 
 	if (handle) {
 		ret = get_u32(&t->tcm_handle, handle, 0);
@@ -196,6 +198,10 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 				return -1;
 			}
 			addattr_l(n, MAX_MSG, TCA_FLOWER_CLASSID, &handle, 4);
+		} else if (matches(*argv, "skip_hw") == 0) {
+			flags |= TCA_CLS_FLAGS_SKIP_HW;
+		} else if (matches(*argv, "skip_sw") == 0) {
+			flags |= TCA_CLS_FLAGS_SKIP_SW;
 		} else if (matches(*argv, "indev") == 0) {
 			char ifname[IFNAMSIZ];
 
@@ -294,6 +300,8 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 	}
 
 parse_done:
+	addattr32(n, MAX_MSG, TCA_FLOWER_FLAGS, flags);
+
 	ret = addattr16(n, MAX_MSG, TCA_FLOWER_KEY_ETH_TYPE, eth_type);
 	if (ret) {
 		fprintf(stderr, "Illegal \"eth_type\"(0x%x)\n",
@@ -498,6 +506,15 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 			  tb[TCA_FLOWER_KEY_TCP_SRC],
 			  tb[TCA_FLOWER_KEY_UDP_SRC]);
 
+	if (tb[TCA_FLOWER_FLAGS])  {
+		__u32 flags = rta_getattr_u32(tb[TCA_FLOWER_FLAGS]);
+
+		if (flags & TCA_CLS_FLAGS_SKIP_HW)
+			fprintf(f, "\n  skip_hw");
+		if (flags & TCA_CLS_FLAGS_SKIP_SW)
+			fprintf(f, "\n  skip_sw");
+	}
+
 	if (tb[TCA_FLOWER_ACT]) {
 		tc_print_action(f, tb[TCA_FLOWER_ACT]);
 	}
-- 
2.9.0
