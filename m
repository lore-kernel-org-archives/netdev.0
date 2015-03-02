From: Florian Westphal <fw@strlen.de>
Subject: [PATCH RFC 14/14] net: introduce and use KERNEL_MAX_HEADER_PARSE_ADDRLEN
Date: Mon,  2 Mar 2015 18:40:28 +0100
Message-ID: <1425318028-26531-15-git-send-email-fw@strlen.de>
References: <1425318028-26531-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54123 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754705AbbCBRkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 12:40:51 -0500
In-Reply-To: <1425318028-26531-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

af_packet sockets call dev->header_ops->parse to stash the hwaddr in
skb->cb.

This currently works without problems since no hw address exceeds 20
bytes.  When we'd reduce skb->cb in the future we might silently
corrupt fields after skb->cb.  So add compile-time assertions to all
implementations of header_ops->parse.

The largest address is infiniband (20); the largest address that can
be returned by a header_ops->parse call however is 16 (Firewire).

add KERNEL_MAX_HEADER_PARSE_ADDRLEN as a way to indicate the largest
possible value returned by dev_parse_header().

Original idea by David Miller.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/firewire/net.c                    | 1 +
 drivers/net/wireless/airo.c               | 2 ++
 drivers/net/wireless/hostap/hostap_main.c | 2 ++
 include/linux/netdevice.h                 | 7 +++++++
 net/ethernet/eth.c                        | 2 ++
 net/mac802154/iface.c                     | 1 +
 net/packet/af_packet.c                    | 3 ++-
 net/phonet/af_phonet.c                    | 2 ++
 8 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 2c68da1..ce7b45c 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -276,6 +276,7 @@ static void fwnet_header_cache_update(struct hh_cache *hh,
 static int fwnet_header_parse(const struct sk_buff *skb, unsigned char *haddr)
 {
 	memcpy(haddr, skb->dev->dev_addr, FWNET_ALEN);
+	dev_validate_header_parse_addrlen(FWNET_ALEN);
 
 	return FWNET_ALEN;
 }
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index e71a2ce..ba6497e 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -2438,6 +2438,8 @@ EXPORT_SYMBOL(stop_airo_card);
 static int wll_header_parse(const struct sk_buff *skb, unsigned char *haddr)
 {
 	memcpy(haddr, skb_mac_header(skb) + 10, ETH_ALEN);
+	dev_validate_header_parse_addrlen(ETH_ALEN);
+
 	return ETH_ALEN;
 }
 
diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index 52919ad..fe760e9 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -582,6 +582,8 @@ static int hostap_80211_header_parse(const struct sk_buff *skb,
 				     unsigned char *haddr)
 {
 	memcpy(haddr, skb_mac_header(skb) + 10, ETH_ALEN); /* addr2 */
+	dev_validate_header_parse_addrlen(ETH_ALEN);
+
 	return ETH_ALEN;
 }
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7427185..bd1365a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -268,6 +268,13 @@ struct header_ops {
 				const unsigned char *haddr);
 };
 
+/* largest possible return value of header_ops->parse methods */
+#define KERNEL_MAX_HEADER_PARSE_ADDRLEN	16
+static inline void dev_validate_header_parse_addrlen(unsigned int alen)
+{
+	BUILD_BUG_ON(alen > KERNEL_MAX_HEADER_PARSE_ADDRLEN);
+}
+
 /* These flag bits are private to the generic network queueing
  * layer, they may not be explicitly referenced by any other
  * code.
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 238f38d..6d27123 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -240,6 +240,8 @@ int eth_header_parse(const struct sk_buff *skb, unsigned char *haddr)
 {
 	const struct ethhdr *eth = eth_hdr(skb);
 	memcpy(haddr, eth->h_source, ETH_ALEN);
+	dev_validate_header_parse_addrlen(ETH_ALEN);
+
 	return ETH_ALEN;
 }
 EXPORT_SYMBOL(eth_header_parse);
diff --git a/net/mac802154/iface.c b/net/mac802154/iface.c
index 6fb6bdf..97eb50c 100644
--- a/net/mac802154/iface.c
+++ b/net/mac802154/iface.c
@@ -433,6 +433,7 @@ mac802154_header_parse(const struct sk_buff *skb, unsigned char *haddr)
 		return 0;
 	}
 
+	dev_validate_header_parse_addrlen(sizeof(*addr));
 	*addr = hdr.source;
 	return sizeof(*addr);
 }
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 9db8369..1a4dcbb 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1816,7 +1816,8 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 		skb = nskb;
 	}
 
-	sock_skb_cb_check_size(sizeof(*PACKET_SKB_CB(skb)) + MAX_ADDR_LEN - 8);
+	sock_skb_cb_check_size(sizeof(*PACKET_SKB_CB(skb)) +
+			       KERNEL_MAX_HEADER_PARSE_ADDRLEN);
 
 	sll = &PACKET_SKB_CB(skb)->sa.ll;
 	sll->sll_hatype = dev->type;
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 32ab87d..617ac42 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -146,6 +146,8 @@ static int pn_header_parse(const struct sk_buff *skb, unsigned char *haddr)
 {
 	const u8 *media = skb_mac_header(skb);
 	*haddr = *media;
+	dev_validate_header_parse_addrlen(sizeof(*haddr));
+
 	return 1;
 }
 
-- 
2.0.5
