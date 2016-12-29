From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 10/14] bnxt_en: Add IPV6 hardware RFS support.
Date: Thu, 29 Dec 2016 12:13:40 -0500
Message-ID: <1483031624-20076-11-git-send-email-michael.chan@broadcom.com>
References: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:36567 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753333AbcL2ROJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 12:14:09 -0500
Received: by mail-pg0-f47.google.com with SMTP id f188so168383803pgc.3
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2016 09:14:09 -0800 (PST)
In-Reply-To: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Accept ipv6 flows in .ndo_rx_flow_steer() and support ETHTOOL_GRXCLSRULE
ipv6 flows.

Signed-off-by: Michael Chan <michael.chan@broadocm.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 32 +++++++++++---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 53 +++++++++++++++++------
 2 files changed, 66 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 0ca530e..4d478e7 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3316,10 +3316,26 @@ static int bnxt_hwrm_cfa_ntuple_filter_alloc(struct bnxt *bp,
 	req.ip_addr_type = CFA_NTUPLE_FILTER_ALLOC_REQ_IP_ADDR_TYPE_IPV4;
 	req.ip_protocol = keys->basic.ip_proto;
 
-	req.src_ipaddr[0] = keys->addrs.v4addrs.src;
-	req.src_ipaddr_mask[0] = cpu_to_be32(0xffffffff);
-	req.dst_ipaddr[0] = keys->addrs.v4addrs.dst;
-	req.dst_ipaddr_mask[0] = cpu_to_be32(0xffffffff);
+	if (keys->basic.n_proto == htons(ETH_P_IPV6)) {
+		int i;
+
+		req.ethertype = htons(ETH_P_IPV6);
+		req.ip_addr_type =
+			CFA_NTUPLE_FILTER_ALLOC_REQ_IP_ADDR_TYPE_IPV6;
+		*(struct in6_addr *)&req.src_ipaddr[0] =
+			keys->addrs.v6addrs.src;
+		*(struct in6_addr *)&req.dst_ipaddr[0] =
+			keys->addrs.v6addrs.dst;
+		for (i = 0; i < 4; i++) {
+			req.src_ipaddr_mask[i] = cpu_to_be32(0xffffffff);
+			req.dst_ipaddr_mask[i] = cpu_to_be32(0xffffffff);
+		}
+	} else {
+		req.src_ipaddr[0] = keys->addrs.v4addrs.src;
+		req.src_ipaddr_mask[0] = cpu_to_be32(0xffffffff);
+		req.dst_ipaddr[0] = keys->addrs.v4addrs.dst;
+		req.dst_ipaddr_mask[0] = cpu_to_be32(0xffffffff);
+	}
 
 	req.src_port = keys->ports.src;
 	req.src_port_mask = cpu_to_be16(0xffff);
@@ -6588,12 +6604,18 @@ static int bnxt_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
 		goto err_free;
 	}
 
-	if ((fkeys->basic.n_proto != htons(ETH_P_IP)) ||
+	if ((fkeys->basic.n_proto != htons(ETH_P_IP) &&
+	     fkeys->basic.n_proto != htons(ETH_P_IPV6)) ||
 	    ((fkeys->basic.ip_proto != IPPROTO_TCP) &&
 	     (fkeys->basic.ip_proto != IPPROTO_UDP))) {
 		rc = -EPROTONOSUPPORT;
 		goto err_free;
 	}
+	if (fkeys->basic.n_proto == htons(ETH_P_IPV6) &&
+	    bp->hwrm_spec_code < 0x10601) {
+		rc = -EPROTONOSUPPORT;
+		goto err_free;
+	}
 
 	memcpy(new_fltr->dst_mac_addr, eth->h_dest, ETH_ALEN);
 	memcpy(new_fltr->src_mac_addr, eth->h_source, ETH_ALEN);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 1cfa7a6..e6b1196 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -524,24 +524,49 @@ static int bnxt_grxclsrule(struct bnxt *bp, struct ethtool_rxnfc *cmd)
 
 fltr_found:
 	fkeys = &fltr->fkeys;
-	if (fkeys->basic.ip_proto == IPPROTO_TCP)
-		fs->flow_type = TCP_V4_FLOW;
-	else if (fkeys->basic.ip_proto == IPPROTO_UDP)
-		fs->flow_type = UDP_V4_FLOW;
-	else
-		goto fltr_err;
+	if (fkeys->basic.n_proto == htons(ETH_P_IP)) {
+		if (fkeys->basic.ip_proto == IPPROTO_TCP)
+			fs->flow_type = TCP_V4_FLOW;
+		else if (fkeys->basic.ip_proto == IPPROTO_UDP)
+			fs->flow_type = UDP_V4_FLOW;
+		else
+			goto fltr_err;
+
+		fs->h_u.tcp_ip4_spec.ip4src = fkeys->addrs.v4addrs.src;
+		fs->m_u.tcp_ip4_spec.ip4src = cpu_to_be32(~0);
+
+		fs->h_u.tcp_ip4_spec.ip4dst = fkeys->addrs.v4addrs.dst;
+		fs->m_u.tcp_ip4_spec.ip4dst = cpu_to_be32(~0);
 
-	fs->h_u.tcp_ip4_spec.ip4src = fkeys->addrs.v4addrs.src;
-	fs->m_u.tcp_ip4_spec.ip4src = cpu_to_be32(~0);
+		fs->h_u.tcp_ip4_spec.psrc = fkeys->ports.src;
+		fs->m_u.tcp_ip4_spec.psrc = cpu_to_be16(~0);
 
-	fs->h_u.tcp_ip4_spec.ip4dst = fkeys->addrs.v4addrs.dst;
-	fs->m_u.tcp_ip4_spec.ip4dst = cpu_to_be32(~0);
+		fs->h_u.tcp_ip4_spec.pdst = fkeys->ports.dst;
+		fs->m_u.tcp_ip4_spec.pdst = cpu_to_be16(~0);
+	} else {
+		int i;
 
-	fs->h_u.tcp_ip4_spec.psrc = fkeys->ports.src;
-	fs->m_u.tcp_ip4_spec.psrc = cpu_to_be16(~0);
+		if (fkeys->basic.ip_proto == IPPROTO_TCP)
+			fs->flow_type = TCP_V6_FLOW;
+		else if (fkeys->basic.ip_proto == IPPROTO_UDP)
+			fs->flow_type = UDP_V6_FLOW;
+		else
+			goto fltr_err;
+
+		*(struct in6_addr *)&fs->h_u.tcp_ip6_spec.ip6src[0] =
+			fkeys->addrs.v6addrs.src;
+		*(struct in6_addr *)&fs->h_u.tcp_ip6_spec.ip6dst[0] =
+			fkeys->addrs.v6addrs.dst;
+		for (i = 0; i < 4; i++) {
+			fs->m_u.tcp_ip6_spec.ip6src[i] = cpu_to_be32(~0);
+			fs->m_u.tcp_ip6_spec.ip6dst[i] = cpu_to_be32(~0);
+		}
+		fs->h_u.tcp_ip6_spec.psrc = fkeys->ports.src;
+		fs->m_u.tcp_ip6_spec.psrc = cpu_to_be16(~0);
 
-	fs->h_u.tcp_ip4_spec.pdst = fkeys->ports.dst;
-	fs->m_u.tcp_ip4_spec.pdst = cpu_to_be16(~0);
+		fs->h_u.tcp_ip6_spec.pdst = fkeys->ports.dst;
+		fs->m_u.tcp_ip6_spec.pdst = cpu_to_be16(~0);
+	}
 
 	fs->ring_cookie = fltr->rxq;
 	rc = 0;
-- 
1.8.3.1
