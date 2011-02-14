From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6 8/9] jme: Don't show UDP Checksum error if HW misjudged
Date: Mon, 14 Feb 2011 12:27:41 +0800
Message-ID: <1297657662-30289-8-git-send-email-cooldavid@cooldavid.org>
References: <1297657662-30289-1-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>,
	"Aries Lee" <arieslee@jmicron.com>,
	"Devinchiu" <devinchiu@jmicron.com>,
	"Ethan Hsiao" <ethanhsiao@jmicron.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:48737 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755481Ab1BNE2o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Feb 2011 23:28:44 -0500
In-Reply-To: <1297657662-30289-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

Some JMicron Chip treat 0 as error checksum for UDP packets.
Which should be "No checksum needed".

Reported-by: Adam Swift <Adam.Swift@omnitude.net>
Confirmed-by: "Aries Lee" <arieslee@jmicron.com>
Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.c |   25 ++++++++++++++++++++++---
 1 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index ed35e17..5ced990 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -956,8 +956,27 @@ jme_disable_rx_engine(struct jme_adapter *jme)
 	jme_mac_rxclk_off(jme);
 }
 
+static u16
+jme_udpsum(struct sk_buff *skb)
+{
+	u16 csum = 0xFFFFu;
+
+	if (skb->protocol != htons(ETH_P_IP))
+		return csum;
+	skb_set_network_header(skb, ETH_HLEN);
+	if (ip_hdr(skb)->protocol != IPPROTO_UDP)
+		return csum;
+	skb_set_transport_header(skb,
+			ETH_HLEN + (ip_hdr(skb)->ihl << 2));
+	csum = udp_hdr(skb)->check;
+	skb_reset_transport_header(skb);
+	skb_reset_network_header(skb);
+
+	return csum;
+}
+
 static int
-jme_rxsum_ok(struct jme_adapter *jme, u16 flags)
+jme_rxsum_ok(struct jme_adapter *jme, u16 flags, struct sk_buff *skb)
 {
 	if (!(flags & (RXWBFLAG_TCPON | RXWBFLAG_UDPON | RXWBFLAG_IPV4)))
 		return false;
@@ -970,7 +989,7 @@ jme_rxsum_ok(struct jme_adapter *jme, u16 flags)
 	}
 
 	if (unlikely((flags & (RXWBFLAG_MF | RXWBFLAG_UDPON | RXWBFLAG_UDPCS))
-			== RXWBFLAG_UDPON)) {
+			== RXWBFLAG_UDPON) && jme_udpsum(skb)) {
 		if (flags & RXWBFLAG_IPV4)
 			netif_err(jme, rx_err, jme->dev, "UDP Checksum error\n");
 		return false;
@@ -1018,7 +1037,7 @@ jme_alloc_and_feed_skb(struct jme_adapter *jme, int idx)
 		skb_put(skb, framesize);
 		skb->protocol = eth_type_trans(skb, jme->dev);
 
-		if (jme_rxsum_ok(jme, le16_to_cpu(rxdesc->descwb.flags)))
+		if (jme_rxsum_ok(jme, le16_to_cpu(rxdesc->descwb.flags), skb))
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 		else
 			skb_checksum_none_assert(skb);
-- 
1.7.2.2

