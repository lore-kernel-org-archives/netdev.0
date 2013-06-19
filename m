From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 05/11] sfc: Enable accelerated RFS on vlans
Date: Wed, 19 Jun 2013 23:19:16 +0100
Message-ID: <1371680356.1956.112.camel@bwh-desktop.uk.level5networks.com>
References: <1371680169.1956.107.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Andy Lutomirski" <luto@amacapital.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:10413 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935220Ab3FSWTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 18:19:20 -0400
In-Reply-To: <1371680169.1956.107.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Lutomirski <luto@amacapital.net>

As far as I know, the hardware doesn't support matching on both IP
fields and vlan tag, but it can at least match on the IP fields.

Signed-off-by: Andy Lutomirski <luto@amacapital.net>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/filter.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/filter.c b/drivers/net/ethernet/sfc/filter.c
index 2397f0e..b74a60a 100644
--- a/drivers/net/ethernet/sfc/filter.c
+++ b/drivers/net/ethernet/sfc/filter.c
@@ -1185,8 +1185,21 @@ int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
 
 	nhoff = skb_network_offset(skb);
 
-	if (skb->protocol != htons(ETH_P_IP))
+	if (skb->protocol == htons(ETH_P_8021Q)) {
+		EFX_BUG_ON_PARANOID(skb_headlen(skb) <
+				    nhoff + sizeof(struct vlan_hdr));
+		if (((const struct vlan_hdr *)skb->data + nhoff)->
+		    h_vlan_encapsulated_proto != htons(ETH_P_IP))
+			return -EPROTONOSUPPORT;
+
+		/* This is IP over 802.1q VLAN.  We can't filter on the
+		 * IP 5-tuple and the vlan together, so just strip the
+		 * vlan header and filter on the IP part.
+		 */
+		nhoff += sizeof(struct vlan_hdr);
+	} else if (skb->protocol != htons(ETH_P_IP)) {
 		return -EPROTONOSUPPORT;
+	}
 
 	/* RFS must validate the IP header length before calling us */
 	EFX_BUG_ON_PARANOID(skb_headlen(skb) < nhoff + sizeof(*ip));


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
