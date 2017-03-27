From: Benjamin LaHaise <benjamin.lahaise@netronome.com>
Subject: [RFC PATCH iproute2 net-next] tc flower: support for matching MPLS
Date: Mon, 27 Mar 2017 14:25:49 -0400
Message-ID: <20170327182549.GA3961@nvt-d.home.kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:36883 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751634AbdC0SfC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 14:35:02 -0400
Received: by mail-it0-f52.google.com with SMTP id 190so64023489itm.0
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 11:35:01 -0700 (PDT)
Received: from nvt-d.home.kvack.org ([205.233.59.54])
        by smtp.gmail.com with ESMTPSA id i195sm181016ita.17.2017.03.27.11.25.51
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Mar 2017 11:25:51 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[RFC until kernel code is accepted/rejected]

This patch adds support to the iproute2 tc filter command for matching MPLS
labels in the flower classifier.  The ability to match the Time To Live,
Bottom Of Stack, Traffic Control and Label fields are added as options to
the flower filter.

Signed-off-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>
Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index 7a69f2a..f1129e3 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -432,6 +432,11 @@ enum {
 	TCA_FLOWER_KEY_ARP_THA,		/* ETH_ALEN */
 	TCA_FLOWER_KEY_ARP_THA_MASK,	/* ETH_ALEN */
 
+	TCA_FLOWER_KEY_MPLS_TTL,	/* u8 - 8 bits */
+	TCA_FLOWER_KEY_MPLS_BOS,	/* u8 - 1 bit */
+	TCA_FLOWER_KEY_MPLS_TC,		/* u8 - 3 bits */
+	TCA_FLOWER_KEY_MPLS_LABEL,	/* be32 - 20 bits */
+
 	__TCA_FLOWER_MAX,
 };
 
diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index fc5bac5..6ce2d56 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -29,6 +29,14 @@ flower \- flow based traffic control filter
 .IR PRIORITY " | "
 .BR vlan_ethtype " { " ipv4 " | " ipv6 " | "
 .IR ETH_TYPE " } | "
+.B mpls_label
+.IR LABEL " | "
+.B mpls_tc
+.IR TC " | "
+.B mpls_bos
+.IR BOS " | "
+.B mpls_ttl
+.IR TTL " | "
 .BR ip_proto " { " tcp " | " udp " | " sctp " | " icmp " | " icmpv6 " | "
 .IR IP_PROTO " } | { "
 .BR dst_ip " | " src_ip " } "
@@ -113,6 +121,27 @@ may be either
 .BR ipv4 ", " ipv6
 or an unsigned 16bit value in hexadecimal format.
 .TP
+.BI mpls_label " LABEL"
+Match the outermost MPLS label id in an MPLS packet.
+.I LABEL
+is an unsigned 20 bit value in decimal format.
+.TP
+.BI mpls_tc " TC"
+Match on the MPLS TC field, which is typically used for packet priority.
+.I TC
+is an unsigned 3 bit value in decimal format.
+.TP
+.BI mpls_bos " BOS"
+Match on the MPLS Bottom Of Stack field in the outermost MPLS label.
+.I BOS
+is a 1 bit value.
+.TP
+.BI mpls_ttl " TTL"
+Match on the MPLS Time To Live field.
+.I TTL
+is an unsigned 8 bit value which matches the MPLS TTL field in the outermost
+label.
+.TP
 .BI ip_proto " IP_PROTO"
 Match on layer four protocol.
 .I IP_PROTO
diff --git a/tc/f_flower.c b/tc/f_flower.c
index 5aac4a0..af9ef3d 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -19,6 +19,7 @@
 #include <linux/if_ether.h>
 #include <linux/ip.h>
 #include <linux/tc_act/tc_vlan.h>
+#include <linux/mpls.h>
 
 #include "utils.h"
 #include "tc_util.h"
@@ -53,6 +54,10 @@ static void explain(void)
 		"                       dst_mac MASKED-LLADDR |\n"
 		"                       src_mac MASKED-LLADDR |\n"
 		"                       ip_proto [tcp | udp | sctp | icmp | icmpv6 | IP-PROTO ] |\n"
+		"                       mpls_label LABEL |\n"
+		"                       mpls_tc TC |\n"
+		"                       mpls_bos BOS |\n"
+		"                       mpls_ttl TTL |\n"
 		"                       dst_ip PREFIX |\n"
 		"                       src_ip PREFIX |\n"
 		"                       dst_port PORT-NUMBER |\n"
@@ -599,6 +604,70 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 						 &vlan_ethtype, n);
 			if (ret < 0)
 				return -1;
+		} else if (matches(*argv, "mpls_label") == 0) {
+			__u32 label;
+
+			NEXT_ARG();
+			if (eth_type != htons(ETH_P_MPLS_UC) &&
+			    eth_type != htons(ETH_P_MPLS_MC)) {
+				fprintf(stderr,
+					"Can't set \"mpls_label\" if ethertype isn't MPLS\n");
+				return -1;
+			}
+			ret = get_u32(&label, *argv, 10);
+			if (ret < 0 || label & ~(MPLS_LS_LABEL_MASK >> MPLS_LS_LABEL_SHIFT)) {
+				fprintf(stderr, "Illegal \"mpls_label\"\n");
+				return -1;
+			}
+			addattr32(n, MAX_MSG, TCA_FLOWER_KEY_MPLS_LABEL, label);
+		} else if (matches(*argv, "mpls_tc") == 0) {
+			__u8 tc;
+
+			NEXT_ARG();
+			if (eth_type != htons(ETH_P_MPLS_UC) &&
+			    eth_type != htons(ETH_P_MPLS_MC)) {
+				fprintf(stderr,
+					"Can't set \"mpls_tc\" if ethertype isn't MPLS\n");
+				return -1;
+			}
+			ret = get_u8(&tc, *argv, 10);
+			if (ret < 0 || tc & ~(MPLS_LS_TC_MASK >> MPLS_LS_TC_SHIFT)) {
+				fprintf(stderr, "Illegal \"mpls_tc\"\n");
+				return -1;
+			}
+			addattr8(n, MAX_MSG, TCA_FLOWER_KEY_MPLS_TC, tc);
+		} else if (matches(*argv, "mpls_bos") == 0) {
+			__u8 bos;
+
+			NEXT_ARG();
+			if (eth_type != htons(ETH_P_MPLS_UC) &&
+			    eth_type != htons(ETH_P_MPLS_MC)) {
+				fprintf(stderr,
+					"Can't set \"mpls_bos\" if ethertype isn't MPLS\n");
+				return -1;
+			}
+			ret = get_u8(&bos, *argv, 10);
+			if (ret < 0 || bos & ~(MPLS_LS_S_MASK >> MPLS_LS_S_SHIFT)) {
+				fprintf(stderr, "Illegal \"mpls_bos\"\n");
+				return -1;
+			}
+			addattr8(n, MAX_MSG, TCA_FLOWER_KEY_MPLS_BOS, bos);
+		} else if (matches(*argv, "mpls_ttl") == 0) {
+			__u8 ttl;
+
+			NEXT_ARG();
+			if (eth_type != htons(ETH_P_MPLS_UC) &&
+			    eth_type != htons(ETH_P_MPLS_MC)) {
+				fprintf(stderr,
+					"Can't set \"mpls_ttl\" if ethertype isn't MPLS\n");
+				return -1;
+			}
+			ret = get_u8(&ttl, *argv, 10);
+			if (ret < 0 || ttl & ~(MPLS_LS_TTL_MASK >> MPLS_LS_TTL_SHIFT)) {
+				fprintf(stderr, "Illegal \"mpls_ttl\"\n");
+				return -1;
+			}
+			addattr8(n, MAX_MSG, TCA_FLOWER_KEY_MPLS_TTL, ttl);
 		} else if (matches(*argv, "dst_mac") == 0) {
 			NEXT_ARG();
 			ret = flower_parse_eth_addr(*argv,
