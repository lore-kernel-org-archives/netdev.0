From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6 3/3] bonding/vlan: Fix mangled NAs on slaves
 without VLAN tag insertion
Date: Mon, 13 Dec 2010 18:20:24 +0000
Message-ID: <1292264424.9860.15.camel@bwh-desktop>
References: <1292264216.9860.11.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:35459 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757641Ab0LMSU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 13:20:27 -0500
In-Reply-To: <1292264216.9860.11.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bond_na_send() attempts to insert a VLAN tag in between building and
sending packets of the respective formats.  If the slave does not
implement hardware VLAN tag insertion then vlan_put_tag() will mangle
the network-layer header because the Ethernet header is not present at
this point (unlike in bond_arp_send()).

Fix this by adding the tag out-of-line and relying on
dev_hard_start_xmit() to insert it inline if necessary.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/bonding/bond_ipv6.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_ipv6.c b/drivers/net/bonding/bond_ipv6.c
index 121b073..84fbd4e 100644
--- a/drivers/net/bonding/bond_ipv6.c
+++ b/drivers/net/bonding/bond_ipv6.c
@@ -88,7 +88,12 @@ static void bond_na_send(struct net_device *slave_dev,
 	}
 
 	if (vlan_id) {
-		skb = vlan_put_tag(skb, vlan_id);
+		/* The Ethernet header is not present yet, so it is
+		 * too early to insert a VLAN tag.  Force use of an
+		 * out-of-line tag here and let dev_hard_start_xmit()
+		 * insert it if the slave hardware can't.
+		 */
+		skb = __vlan_hwaccel_put_tag(skb, vlan_id);
 		if (!skb) {
 			pr_err("failed to insert VLAN tag\n");
 			return;
-- 
1.7.3.2


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

