From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] bonding/vlan: Avoid mangled NAs on slaves without VLAN tag
 insertion
Date: Mon, 07 Feb 2011 19:20:55 +0000
Message-ID: <1297106455.4077.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	bonding-devel@lists.sourceforge.net
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:18544 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754663Ab1BGTU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 14:20:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is related to commit f88a4a9b65a6f3422b81be995535d0e69df11bb8
upstream, but the bug cannot be properly fixed without the other
changes to VLAN tagging in 2.6.37.

bond_na_send() attempts to insert a VLAN tag in between building and
sending packets of the respective formats.  If the slave does not
implement hardware VLAN tag insertion then vlan_put_tag() will mangle
the network-layer header because the Ethernet header is not present at
this point (unlike in bond_arp_send()).

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This fix is applicable to versions [2.6.29, 2.6.36].  The context for
the second hunk needs to be reduced to 1 line for versions < 2.6.33
(git am -C1) as the logging call was changed.

Ben.

 drivers/net/bonding/bond_ipv6.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_ipv6.c b/drivers/net/bonding/bond_ipv6.c
index 121b073..78eb5fa 100644
--- a/drivers/net/bonding/bond_ipv6.c
+++ b/drivers/net/bonding/bond_ipv6.c
@@ -70,6 +70,13 @@ static void bond_na_send(struct net_device *slave_dev,
 	};
 	struct sk_buff *skb;
 
+	/* The Ethernet header is built in ndisc_send_skb(), not
+	 * ndisc_build_skb(), so we cannot insert a VLAN tag.  Only an
+	 * out-of-line tag inserted by the hardware will work.
+	 */
+	if (vlan_id && !(slave_dev->features & NETIF_F_HW_VLAN_TX))
+		return;
+
 	icmp6h.icmp6_router = router;
 	icmp6h.icmp6_solicited = 0;
 	icmp6h.icmp6_override = 1;
@@ -88,7 +95,7 @@ static void bond_na_send(struct net_device *slave_dev,
 	}
 
 	if (vlan_id) {
-		skb = vlan_put_tag(skb, vlan_id);
+		skb = __vlan_hwaccel_put_tag(skb, vlan_id);
 		if (!skb) {
 			pr_err("failed to insert VLAN tag\n");
 			return;
-- 
1.7.2.3


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

