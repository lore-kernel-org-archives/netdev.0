From: Ahmed Amamou <ahmed@gandi.net>
Subject: [PATCH RFC v2 21/21] net: handle packet split for trill
Date: Tue,  1 Sep 2015 17:43:16 +0200
Message-ID: <1441122196-11662-22-git-send-email-ahmed@gandi.net>
References: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Cc: William Dauchy <william@gandi.net>, Ahmed Amamou <ahmed@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:57164 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752755AbbIAPxm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 11:53:42 -0400
In-Reply-To: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Dauchy <william@gandi.net>

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: William Dauchy <william@gandi.net>
---
 net/core/flow_dissector.c | 31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 2a834c6..95c2794 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -18,6 +18,9 @@
 #include <linux/mpls.h>
 #include <net/flow_dissector.h>
 #include <scsi/fc/fc_fcoe.h>
+#ifdef CONFIG_TRILL
+#include <net/if_trill.h>
+#endif
 
 static bool skb_flow_dissector_uses_key(struct flow_dissector *flow_dissector,
 					enum flow_dissector_key_id key_id)
@@ -165,6 +168,34 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 
 again:
 	switch (proto) {
+#ifdef CONFIG_TRILL
+	case htons(ETH_P_TRILL): {
+		const struct trill_hdr *trillh;
+		struct trill_hdr _trillh;
+		const struct ethhdr *eth;
+		struct ethhdr _eth;
+		u8 trill_op_len;
+
+		trillh = __skb_header_pointer(skb, nhoff, sizeof(_trillh),
+					      data, hlen, &_trillh);
+		if (!trillh)
+			return false;
+		nhoff += sizeof(*trillh);
+		trill_op_len = trill_get_optslen(ntohs(trillh->th_flags));
+		if (trill_op_len)
+			nhoff += trill_op_len;
+
+		eth = __skb_header_pointer(skb, nhoff, sizeof(_eth), data,
+					   hlen, &_eth);
+		if (!eth)
+			return false;
+		proto = eth->h_proto;
+		nhoff += sizeof(*eth);
+
+		/* handle any vlan tag if present */
+		goto again;
+	}
+#endif
 	case htons(ETH_P_IP): {
 		const struct iphdr *iph;
 		struct iphdr _iph;
-- 
2.1.4
