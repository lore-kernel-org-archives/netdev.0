From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 13:06:51 -0500
Message-ID: <20160129180651.GA17127@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:38025 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbcA2SHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 13:07:03 -0500
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u0TI72aR011673
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 18:07:02 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0021.oracle.com (8.13.8/8.13.8) with ESMTP id u0TI72ZK009947
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 18:07:02 GMT
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
	by userv0121.oracle.com (8.13.8/8.13.8) with ESMTP id u0TI72UM014431
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 18:07:02 GMT
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There is an unaligned access at __skb_flow_dissect when it calls
ip6_flowlabel() with the call stack

  __skb_flow_dissect+0x2a8/0x87c
  eth_get_headlen+0x5c/0xaxa4
  ixgbe_clean_rx_irq+0x5cc/0xb20 [ixgbe]
  ixgbe_poll+0x5a4/0x760 [ixgbe]
  net_rx_action+0x13c/0x354
    :

Essentially, ixgbe_pull_tail() is trying to figure out how much
to pull, in order to have an aligned buffer:

        pull_len = eth_get_headlen(va, IXGBE_RX_HDR_SIZE);

        /* align pull length to size of long to optimize memcpy performance */
        skb_copy_to_linear_data(skb, va, ALIGN(pull_len, sizeof(long)));

and seems like the unaligned access is unavoidable here (see comments
in __skb_get_poff, for example).

This (below) is what I came up with, to get rid of the unaligned access
errors on sparc, Is there a better solution? (Not having access
to struct ip6_hdr in this file made put_unaligned usage non-obvious)


--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -102,6 +102,17 @@ __be32 __skb_flow_get_ports(const struct sk_buff *skb, int 
 }
 EXPORT_SYMBOL(__skb_flow_get_ports);
 
+static inline __be32 ip6_flowlabel_align(const u8 *hdr)
+{
+       union {
+               __u8 w[4];
+               __u32 flow;
+       } ip6_flow;
+
+       memcpy(ip6_flow.w, hdr, 4);
+       return (ip6_flow.flow & IPV6_FLOWLABEL_MASK);
+}
+
 /**
  * __skb_flow_dissect - extract the flow_keys struct and return it
  * @skb: sk_buff to extract the flow from, can be NULL if the rest are specifie
@@ -230,7 +241,7 @@ ipv6:
                        key_control->addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
                }
 
-               flow_label = ip6_flowlabel(iph);
+               flow_label = ip6_flowlabel_align((const u8 *)iph);
                if (flow_label) {
                        if (dissector_uses_key(flow_dissector,
                                               FLOW_DISSECTOR_KEY_FLOW_LABEL)) {
