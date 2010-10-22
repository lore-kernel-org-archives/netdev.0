From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6] net: Fix some corner cases in
 dev_can_checksum()
Date: Fri, 22 Oct 2010 15:12:19 +0100
Message-ID: <1287756739.2316.11.camel@achroite.uk.solarflarecom.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
	 <1287618974-4714-5-git-send-email-jesse@nicira.com>
	 <1287675008.2235.8.camel@achroite.uk.solarflarecom.com>
	 <AANLkTi=6erj4L7mwH4j1h+urPrc2PQu2xg7xTHkiM0A5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51295 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754896Ab0JVOMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 10:12:22 -0400
In-Reply-To: <AANLkTi=6erj4L7mwH4j1h+urPrc2PQu2xg7xTHkiM0A5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_can_checksum() incorrectly returns true in these cases:

1. The skb has both out-of-band and in-band VLAN tags and the device
   supports checksum offload for the encapsulated protocol but only with
   one layer of encapsulation.
2. The skb has a VLAN tag and the device supports generic checksumming
   but not in conjunction with VLAN encapsulation.

Rearrange the VLAN tag checks to avoid these.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
I don't know whether I have hardware that would cover these cases (our
NICs certainly don't), so instead I wrote some unit tests; I'll
follow-up with the test program.

Ben.

 net/core/dev.c |   16 ++++++----------
 1 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6d4218c..a698252 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1694,22 +1694,18 @@ static bool can_checksum_protocol(unsigned long features, __be16 protocol)
 
 static bool dev_can_checksum(struct net_device *dev, struct sk_buff *skb)
 {
+	__be16 protocol = skb->protocol;
 	int features = dev->features;
 
-	if (vlan_tx_tag_present(skb))
+	if (vlan_tx_tag_present(skb)) {
 		features &= dev->vlan_features;
-
-	if (can_checksum_protocol(features, skb->protocol))
-		return true;
-
-	if (skb->protocol == htons(ETH_P_8021Q)) {
+	} else if (protocol == htons(ETH_P_8021Q)) {
 		struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
-		if (can_checksum_protocol(dev->features & dev->vlan_features,
-					  veh->h_vlan_encapsulated_proto))
-			return true;
+		protocol = veh->h_vlan_encapsulated_proto;
+		features &= dev->vlan_features;
 	}
 
-	return false;
+	return can_checksum_protocol(features, protocol);
 }
 
 /**
-- 
1.7.2.1


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

