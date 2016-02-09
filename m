From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net PATCH v2] flow_dissector: Fix unaligned access in
 __skb_flow_dissector when used by eth_get_headlen
Date: Tue, 09 Feb 2016 02:49:54 -0800
Message-ID: <20160209104929.14628.52355.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, davem@davemloft.net
To: netdev@vger.kernel.org, alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36631 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089AbcBIKt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 05:49:56 -0500
Received: by mail-pa0-f41.google.com with SMTP id yy13so89587037pab.3
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 02:49:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes an issue with unaligned accesses when using
eth_get_headlen on a page that was DMA aligned instead of being IP aligned.
The fact is when trying to check the length we don't need to be looking at
the flow label so we can reorder the checks to first check if we are
supposed to gather the flow label and then make the call to actually get
it.

v2:  Updated path so that either STOP_AT_FLOW_LABEL or KEY_FLOW_LABEL can
     cause us to check for the flow label.

Reported-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/core/flow_dissector.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index c992463c03d7..699b2c415cb0 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -209,7 +209,6 @@ ip:
 	case htons(ETH_P_IPV6): {
 		const struct ipv6hdr *iph;
 		struct ipv6hdr _iph;
-		__be32 flow_label;
 
 ipv6:
 		iph = __skb_header_pointer(skb, nhoff, sizeof(_iph), data, hlen, &_iph);
@@ -230,8 +229,12 @@ ipv6:
 			key_control->addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
 		}
 
-		flow_label = ip6_flowlabel(iph);
-		if (flow_label) {
+		if ((dissector_uses_key(flow_dissector,
+					FLOW_DISSECTOR_KEY_FLOW_LABEL) ||
+		     (flags & FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL)) &&
+		    ip6_flowlabel(iph)) {
+			__be32 flow_label = ip6_flowlabel(iph);
+
 			if (dissector_uses_key(flow_dissector,
 					       FLOW_DISSECTOR_KEY_FLOW_LABEL)) {
 				key_tags = skb_flow_dissector_target(flow_dissector,
