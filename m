From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net PATCH] flow_dissector: Fix unaligned access in
 __skb_flow_dissector when used by eth_get_headlen
Date: Fri, 29 Jan 2016 18:49:05 -0800
Message-ID: <20160130024556.6227.51798.stgit@localhost.localdomain>
References: <20160129180651.GA17127@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	eric.dumazet@gmail.com, tom@herbertland.com
To: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33096 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753158AbcA3CtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 21:49:08 -0500
Received: by mail-pa0-f52.google.com with SMTP id cy9so50649849pac.0
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 18:49:07 -0800 (PST)
In-Reply-To: <20160129180651.GA17127@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes an issue with unaligned accesses when using
eth_get_headlen on a page that was DMA aligned instead of being IP aligned.
The fact is when trying to check the length we don't need to be looking at
the flow label so we can reorder the checks to first check if we are
supposed to gather the flow label and then make the call to actually get
it.

Reported-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---

 net/core/flow_dissector.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index d79699c9d1b9..f09114f8ee33 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -208,7 +208,6 @@ ip:
 	case htons(ETH_P_IPV6): {
 		const struct ipv6hdr *iph;
 		struct ipv6hdr _iph;
-		__be32 flow_label;
 
 ipv6:
 		iph = __skb_header_pointer(skb, nhoff, sizeof(_iph), data, hlen, &_iph);
@@ -230,17 +229,19 @@ ipv6:
 			key_control->addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
 		}
 
-		flow_label = ip6_flowlabel(iph);
-		if (flow_label) {
-			if (dissector_uses_key(flow_dissector,
-					       FLOW_DISSECTOR_KEY_FLOW_LABEL)) {
+		if (dissector_uses_key(flow_dissector,
+				       FLOW_DISSECTOR_KEY_FLOW_LABEL)) {
+			__be32 flow_label = ip6_flowlabel(iph);
+
+			if (flow_label) {
 				key_tags = skb_flow_dissector_target(flow_dissector,
 								     FLOW_DISSECTOR_KEY_FLOW_LABEL,
 								     target_container);
 				key_tags->flow_label = ntohl(flow_label);
+
+				if (flags & FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL)
+					goto out_good;
 			}
-			if (flags & FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL)
-				goto out_good;
 		}
 
 		if (flags & FLOW_DISSECTOR_F_STOP_AT_L3)
