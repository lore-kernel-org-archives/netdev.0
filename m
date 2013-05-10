From: Andy Lutomirski <luto@amacapital.net>
Subject: [PATCH] sfc: Enable accelerated RFS on vlans
Date: Fri, 10 May 2013 16:51:33 -0700
Message-ID: <4bdabd4670b726348cdcdc0d2d635dd660671ee3.1368229353.git.luto@amacapital.net>
Cc: Andy Lutomirski <luto@amacapital.net>
To: netdev@vger.kernel.org,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f50.google.com ([209.85.210.50]:49008 "EHLO
	mail-da0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753928Ab3EJXvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 May 2013 19:51:39 -0400
Received: by mail-da0-f50.google.com with SMTP id i23so2496627dad.9
        for <netdev@vger.kernel.org>; Fri, 10 May 2013 16:51:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As far as I know, the hardware doesn't support matching on both IP
fields and vlan tag, but it can at least match on the vlan tag.

Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---

Tested on the OpenOnload version of the driver, but the patch is the same
other than some offset.

With this patch, accelerated RFS works for me.  (Oddly, some packets end
up on otherwise idle cores, even when those cores have weight zero in
ethtool --set-rxfh-indir; I'm not sure what's going on there.)

 drivers/net/ethernet/sfc/filter.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/filter.c b/drivers/net/ethernet/sfc/filter.c
index 8af42cd..5313ffe 100644
--- a/drivers/net/ethernet/sfc/filter.c
+++ b/drivers/net/ethernet/sfc/filter.c
@@ -1076,8 +1076,21 @@ int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
 
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
1.8.1.4
