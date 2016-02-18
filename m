From: David Wragg <david@weave.works>
Subject: [PATCH net v3] geneve: Refine MTU limit
Date: Thu, 18 Feb 2016 17:43:29 +0000
Message-ID: <1455817409-15995-1-git-send-email-david@weave.works>
Cc: Jesse Gross <jesse@kernel.org>, Tom Herbert <tom@herbertland.com>,
	David Wragg <david@weave.works>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:33642 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271AbcBRRne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 12:43:34 -0500
Received: by mail-wm0-f52.google.com with SMTP id g62so36062466wme.0
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 09:43:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calculate the maximum MTU taking into account the size of headers
involved in GENEVE encapsulation, as for other tunnel types.

Changes in v3:
- Correct comment style
Changes in v2:
- Conform more closely to ip_tunnel_change_mtu
- Exclude GENEVE options from max MTU calculation

Signed-off-by: David Wragg <david@weave.works>
---
 drivers/net/geneve.c | 27 ++++++++++++++++++++++-----
 1 file changed, 22 insertions(+), 5 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 028e387..7097570 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1039,17 +1039,34 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 	return geneve_xmit_skb(skb, dev, info);
 }
 
-static int geneve_change_mtu(struct net_device *dev, int new_mtu)
+static int __geneve_change_mtu(struct net_device *dev, int new_mtu, bool strict)
 {
-	/* GENEVE overhead is not fixed, so we can't enforce a more
-	 * precise max MTU.
+	/* The max_mtu calculation does not take account of GENEVE
+	 * options, to avoid excluding potentially valid
+	 * configurations.
 	 */
-	if (new_mtu < 68 || new_mtu > IP_MAX_MTU)
+	int max_mtu = IP_MAX_MTU - GENEVE_BASE_HLEN - sizeof(struct iphdr)
+		- dev->hard_header_len;
+
+	if (new_mtu < 68)
 		return -EINVAL;
+
+	if (new_mtu > max_mtu) {
+		if (strict)
+			return -EINVAL;
+
+		new_mtu = max_mtu;
+	}
+
 	dev->mtu = new_mtu;
 	return 0;
 }
 
+static int geneve_change_mtu(struct net_device *dev, int new_mtu)
+{
+	return __geneve_change_mtu(dev, new_mtu, true);
+}
+
 static int geneve_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 {
 	struct ip_tunnel_info *info = skb_tunnel_info(skb);
@@ -1459,7 +1476,7 @@ struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 	/* openvswitch users expect packet sizes to be unrestricted,
 	 * so set the largest MTU we can.
 	 */
-	err = geneve_change_mtu(dev, IP_MAX_MTU);
+	err = __geneve_change_mtu(dev, IP_MAX_MTU, false);
 	if (err)
 		goto err;
 
-- 
2.5.0
