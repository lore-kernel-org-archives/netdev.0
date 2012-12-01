From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 01/13] sfc: Fix byte order warnings for ethtool RX
 filter interface
Date: Sat, 1 Dec 2012 04:41:33 +0000
Message-ID: <1354336893.2640.40.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:55599 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747Ab2LAElh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 23:41:37 -0500
In-Reply-To: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sparse has got a bit more picky since I last ran it over this.  Add
forced casts for use of ~0 as a big-endian value.  Undo the pointless
optimisation of parameter validation with '|'; using '||' avoids these
warnings.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ethtool.c |   25 ++++++++++++++-----------
 1 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 90f078e..8e61cd0 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -816,6 +816,9 @@ static int efx_ethtool_reset(struct net_device *net_dev, u32 *flags)
 /* MAC address mask including only MC flag */
 static const u8 mac_addr_mc_mask[ETH_ALEN] = { 0x01, 0, 0, 0, 0, 0 };
 
+#define IP4_ADDR_FULL_MASK	((__force __be32)~0)
+#define PORT_FULL_MASK		((__force __be16)~0)
+
 static int efx_ethtool_get_class_rule(struct efx_nic *efx,
 				      struct ethtool_rx_flow_spec *rule)
 {
@@ -865,12 +868,12 @@ static int efx_ethtool_get_class_rule(struct efx_nic *efx,
 			&spec, &proto, &ip_entry->ip4dst, &ip_entry->pdst,
 			&ip_entry->ip4src, &ip_entry->psrc);
 		EFX_WARN_ON_PARANOID(rc);
-		ip_mask->ip4src = ~0;
-		ip_mask->psrc = ~0;
+		ip_mask->ip4src = IP4_ADDR_FULL_MASK;
+		ip_mask->psrc = PORT_FULL_MASK;
 	}
 	rule->flow_type = (proto == IPPROTO_TCP) ? TCP_V4_FLOW : UDP_V4_FLOW;
-	ip_mask->ip4dst = ~0;
-	ip_mask->pdst = ~0;
+	ip_mask->ip4dst = IP4_ADDR_FULL_MASK;
+	ip_mask->pdst = PORT_FULL_MASK;
 	return rc;
 }
 
@@ -971,7 +974,7 @@ static int efx_ethtool_set_class_rule(struct efx_nic *efx,
 
 	/* Check for unsupported extensions */
 	if ((rule->flow_type & FLOW_EXT) &&
-	    (rule->m_ext.vlan_etype | rule->m_ext.data[0] |
+	    (rule->m_ext.vlan_etype || rule->m_ext.data[0] ||
 	     rule->m_ext.data[1]))
 		return -EINVAL;
 
@@ -986,16 +989,16 @@ static int efx_ethtool_set_class_rule(struct efx_nic *efx,
 			    IPPROTO_TCP : IPPROTO_UDP);
 
 		/* Must match all of destination, */
-		if ((__force u32)~ip_mask->ip4dst |
-		    (__force u16)~ip_mask->pdst)
+		if (!(ip_mask->ip4dst == IP4_ADDR_FULL_MASK &&
+		      ip_mask->pdst == PORT_FULL_MASK))
 			return -EINVAL;
 		/* all or none of source, */
-		if ((ip_mask->ip4src | ip_mask->psrc) &&
-		    ((__force u32)~ip_mask->ip4src |
-		     (__force u16)~ip_mask->psrc))
+		if ((ip_mask->ip4src || ip_mask->psrc) &&
+		    !(ip_mask->ip4src == IP4_ADDR_FULL_MASK &&
+		      ip_mask->psrc == PORT_FULL_MASK))
 			return -EINVAL;
 		/* and nothing else */
-		if (ip_mask->tos | rule->m_ext.vlan_tci)
+		if (ip_mask->tos || rule->m_ext.vlan_tci)
 			return -EINVAL;
 
 		if (ip_mask->ip4src)
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
