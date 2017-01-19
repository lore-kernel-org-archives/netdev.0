From: Paul Blakey <paulb@mellanox.com>
Subject: [PATCH net-next V4] tc: flower: Refactor matching flags to be more user friendly
Date: Thu, 19 Jan 2017 16:17:48 +0200
Message-ID: <1484835468-46051-1-git-send-email-paulb@mellanox.com>
Cc: Jiri Pirko <jiri@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Simon Horman <simon.horman@netronome.com>,
        Paul Blakey <paulb@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47875 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752865AbdASOYn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 09:24:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of "magic numbers" we can now specify each flag
by name. Prefix of "no"  (e.g nofrag) unsets the flag,
otherwise it wil be set.

Example:
    # add a flower filter that will drop fragmented packets
    tc filter add dev ens4f0 protocol ip parent ffff: \
            flower \
            src_mac e4:1d:2d:fd:8b:01 \
            dst_mac e4:1d:2d:fd:8b:02 \
            indev ens4f0 \
            ip_flags frag \
    action drop

    # add a flower filter that will drop non-fragmented packets
    tc filter add dev ens4f0 protocol ip parent ffff: \
            flower \
            src_mac e4:1d:2d:fd:8b:01 \
            dst_mac e4:1d:2d:fd:8b:02 \
            indev ens4f0 \
            ip_flags nofrag \
    action drop

Fixes: 22a8f019891c ('tc: flower: support matching flags')
Signed-off-by: Paul Blakey <paulb@mellanox.com>
Reviewed-by: Roi Dayan <roid@mellanox.com>
---

Hi,
Added a framework to add new flags more easily, such 
as the upcoming tcp_flags (see kernel cls_flower), and other ip_flags.

Thanks,
     Paul.


Changelog:

v4:
Changed prefix in manpage as well.

v3:
Changed prefix to "no" instead of "no_".

v2:
Changed delimiter to "/" to avoid shell pipe errors.


 man/man8/tc-flower.8 |  12 +++++-
 tc/f_flower.c        | 117 ++++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 102 insertions(+), 27 deletions(-)

diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index 2dd2c5e..2bdd2ef 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -46,7 +46,9 @@ flower \- flow based traffic control filter
 .BR enc_dst_ip " | " enc_src_ip " } { "
 .IR ipv4_address " | " ipv6_address " } | "
 .B enc_dst_port
-.IR port_number
+.IR port_number " | "
+.BR ip_flags
+.IR IP_FLAGS
 .SH DESCRIPTION
 The
 .B flower
@@ -183,13 +185,19 @@ prefix length. If the prefix is missing, \fBtc\fR assumes a full-length
 host match.  Dst port
 .I NUMBER
 is a 16 bit UDP dst port.
+.TP
+.BI ip_flags " IP_FLAGS"
+.I IP_FLAGS
+may be either
+.BR frag " or " nofrag
+to match on fragmented packets or not respectively.
 .SH NOTES
 As stated above where applicable, matches of a certain layer implicitly depend
 on the matches of the next lower layer. Precisely, layer one and two matches
 (\fBindev\fR,  \fBdst_mac\fR and \fBsrc_mac\fR)
 have no dependency, layer three matches
 (\fBip_proto\fR, \fBdst_ip\fR, \fBsrc_ip\fR, \fBarp_tip\fR, \fBarp_sip\fR,
-\fBarp_op\fR, \fBarp_tha\fR and \fBarp_sha\fR)
+\fBarp_op\fR, \fBarp_tha\fR, \fBarp_sha\fR and \fBip_flags\fR)
 depend on the
 .B protocol
 option of tc filter, layer four port matches
diff --git a/tc/f_flower.c b/tc/f_flower.c
index d301db3..3dffe2b 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -24,6 +24,10 @@
 #include "tc_util.h"
 #include "rt_names.h"
 
+enum flower_matching_flags {
+	FLOWER_IP_FLAGS,
+};
+
 enum flower_endpoint {
 	FLOWER_ENDPOINT_SRC,
 	FLOWER_ENDPOINT_DST
@@ -63,7 +67,7 @@ static void explain(void)
 		"                       enc_dst_ip [ IPV4-ADDR | IPV6-ADDR ] |\n"
 		"                       enc_src_ip [ IPV4-ADDR | IPV6-ADDR ] |\n"
 		"                       enc_key_id [ KEY-ID ] |\n"
-		"                       matching_flags MATCHING-FLAGS | \n"
+		"                       ip_flags IP-FLAGS | \n"
 		"                       enc_dst_port [ port_number ] }\n"
 		"       FILTERID := X:Y:Z\n"
 		"       MASKED_LLADDR := { LLADDR | LLADDR/MASK | LLADDR/BITS }\n"
@@ -136,28 +140,56 @@ static int flower_parse_vlan_eth_type(char *str, __be16 eth_type, int type,
 	return 0;
 }
 
-static int flower_parse_matching_flags(char *str, int type, int mask_type,
-				       struct nlmsghdr *n)
-{
-	__u32 mtf, mtf_mask;
-	char *c;
+struct flag_to_string {
+	int flag;
+	enum flower_matching_flags type;
+	char *string;
+};
 
-	c = strchr(str, '/');
-	if (c)
-		*c = '\0';
+static struct flag_to_string flags_str[] = {
+	{ TCA_FLOWER_KEY_FLAGS_IS_FRAGMENT, FLOWER_IP_FLAGS, "frag" },
+};
 
-	if (get_u32(&mtf, str, 0))
-		return -1;
+static int flower_parse_matching_flags(char *str,
+				       enum flower_matching_flags type,
+				       __u32 *mtf, __u32 *mtf_mask)
+{
+	char *token;
+	bool no;
+	bool found;
+	int i;
 
-	if (c) {
-		if (get_u32(&mtf_mask, ++c, 0))
+	token = strtok(str, "/");
+
+	while (token) {
+		if (!strncmp(token, "no", 2)) {
+			no = true;
+			token = strchr(token, '_') + 1;
+		} else
+			no = false;
+
+		found = false;
+		for (i = 0; i < ARRAY_SIZE(flags_str); i++) {
+			if (type != flags_str[i].type)
+				continue;
+
+			if (!strcmp(token, flags_str[i].string)) {
+				if (no)
+					*mtf &= ~flags_str[i].flag;
+				else
+					*mtf |= flags_str[i].flag;
+
+				*mtf_mask |= flags_str[i].flag;
+				found = true;
+				break;
+			}
+		}
+		if (!found)
 			return -1;
-	} else {
-		mtf_mask = 0xffffffff;
+
+		token = strtok(NULL, "/");
 	}
 
-	addattr32(n, MAX_MSG, type, htonl(mtf));
-	addattr32(n, MAX_MSG, mask_type, htonl(mtf_mask));
 	return 0;
 }
 
@@ -433,6 +465,8 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 	__be16 vlan_ethtype = 0;
 	__u8 ip_proto = 0xff;
 	__u32 flags = 0;
+	__u32 mtf = 0;
+	__u32 mtf_mask = 0;
 
 	if (handle) {
 		ret = get_u32(&t->tcm_handle, handle, 0);
@@ -462,14 +496,14 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 				return -1;
 			}
 			addattr_l(n, MAX_MSG, TCA_FLOWER_CLASSID, &handle, 4);
-		} else if (matches(*argv, "matching_flags") == 0) {
+		} else if (matches(*argv, "ip_flags") == 0) {
 			NEXT_ARG();
 			ret = flower_parse_matching_flags(*argv,
-							  TCA_FLOWER_KEY_FLAGS,
-							  TCA_FLOWER_KEY_FLAGS_MASK,
-							  n);
+							  FLOWER_IP_FLAGS,
+							  &mtf,
+							  &mtf_mask);
 			if (ret < 0) {
-				fprintf(stderr, "Illegal \"matching_flags\"\n");
+				fprintf(stderr, "Illegal \"ip_flags\"\n");
 				return -1;
 			}
 		} else if (matches(*argv, "skip_hw") == 0) {
@@ -723,6 +757,16 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 parse_done:
 	addattr32(n, MAX_MSG, TCA_FLOWER_FLAGS, flags);
 
+	if (mtf_mask) {
+		ret = addattr32(n, MAX_MSG, TCA_FLOWER_KEY_FLAGS, htonl(mtf));
+		if (ret)
+			return ret;
+
+		ret = addattr32(n, MAX_MSG, TCA_FLOWER_KEY_FLAGS_MASK, htonl(mtf_mask));
+		if (ret)
+			return ret;
+	}
+
 	ret = addattr16(n, MAX_MSG, TCA_FLOWER_KEY_ETH_TYPE, eth_type);
 	if (ret) {
 		fprintf(stderr, "Illegal \"eth_type\"(0x%x)\n",
@@ -828,14 +872,36 @@ static void flower_print_ip_proto(FILE *f, __u8 *p_ip_proto,
 }
 
 static void flower_print_matching_flags(FILE *f, char *name,
+					enum flower_matching_flags type,
 					struct rtattr *attr,
 					struct rtattr *mask_attr)
 {
+	int i;
+	int count = 0;
+	__u32 mtf;
+	__u32 mtf_mask;
+
 	if (!mask_attr || RTA_PAYLOAD(mask_attr) != 4)
 		return;
 
-	fprintf(f, "\n  %s 0x%08x/0x%08x", name, ntohl(rta_getattr_u32(attr)),
-		mask_attr ? ntohl(rta_getattr_u32(mask_attr)) : 0xffffffff);
+	mtf = ntohl(rta_getattr_u32(attr));
+	mtf_mask = ntohl(rta_getattr_u32(mask_attr));
+
+	for (i = 0; i < ARRAY_SIZE(flags_str); i++) {
+		if (type != flags_str[i].type)
+			continue;
+		if (mtf_mask & flags_str[i].flag) {
+			if (++count == 1)
+				fprintf(f, "\n  %s ", name);
+			else
+				fprintf(f, "/");
+
+			if (mtf & flags_str[i].flag)
+				fprintf(f, "%s", flags_str[i].string);
+			else
+				fprintf(f, "no%s", flags_str[i].string);
+		}
+	}
 }
 
 static void flower_print_ip_addr(FILE *f, char *name, __be16 eth_type,
@@ -1034,7 +1100,8 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 	flower_print_port(f, "enc_dst_port",
 			  tb[TCA_FLOWER_KEY_ENC_UDP_DST_PORT]);
 
-	flower_print_matching_flags(f, "matching_flags",
+	flower_print_matching_flags(f, "ip_flags",
+				    FLOWER_IP_FLAGS,
 				    tb[TCA_FLOWER_KEY_FLAGS],
 				    tb[TCA_FLOWER_KEY_FLAGS_MASK]);
 
-- 
2.7.4
