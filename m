From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH] firewire net: Use LL_RESERVED_SPACE(), HH_DATA_OFF().
Date: Sun, 20 Jan 2013 17:03:07 +0900
Message-ID: <50FBA4BB.4010008@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:48268 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750896Ab3ATIDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 03:03:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/net.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index df6a1ca..2b27bff 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -270,7 +270,7 @@ static int fwnet_header_cache(const struct neighbour *neigh,
 	if (type == cpu_to_be16(ETH_P_802_3))
 		return -1;
 	net = neigh->dev;
-	h = (struct fwnet_header *)((u8 *)hh->hh_data + 16 - sizeof(*h));
+	h = (struct fwnet_header *)((u8 *)hh->hh_data + HH_DATA_OFF(sizeof(*h)));
 	h->h_proto = type;
 	memcpy(h->h_dest, neigh->ha, net->addr_len);
 	hh->hh_len = FWNET_HLEN;
@@ -282,7 +282,7 @@ static int fwnet_header_cache(const struct neighbour *neigh,
 static void fwnet_header_cache_update(struct hh_cache *hh,
 		const struct net_device *net, const unsigned char *haddr)
 {
-	memcpy((u8 *)hh->hh_data + 16 - FWNET_HLEN, haddr, net->addr_len);
+	memcpy((u8 *)hh->hh_data + HH_DATA_OFF(FWNET_HLEN), haddr, net->addr_len);
 }
 
 static int fwnet_header_parse(const struct sk_buff *skb, unsigned char *haddr)
@@ -398,11 +398,11 @@ static struct fwnet_partial_datagram *fwnet_pd_new(struct net_device *net,
 
 	new->datagram_label = datagram_label;
 	new->datagram_size = dg_size;
-	new->skb = dev_alloc_skb(dg_size + net->hard_header_len + 15);
+	new->skb = dev_alloc_skb(dg_size + LL_RESERVED_SPACE(net));
 	if (new->skb == NULL)
 		goto fail_w_fi;
 
-	skb_reserve(new->skb, (net->hard_header_len + 15) & ~15);
+	skb_reserve(new->skb, LL_RESERVED_SPACE(net));
 	new->pbuf = skb_put(new->skb, dg_size);
 	memcpy(new->pbuf + frag_off, frag_buf, frag_len);
 	list_add_tail(&new->pd_link, &peer->pd_list);
@@ -690,14 +690,14 @@ static int fwnet_incoming_packet(struct fwnet_device *dev, __be32 *buf, int len,
 		buf++;
 		len -= RFC2374_UNFRAG_HDR_SIZE;
 
-		skb = dev_alloc_skb(len + net->hard_header_len + 15);
+		skb = dev_alloc_skb(len + LL_RESERVED_SPACE(net));
 		if (unlikely(!skb)) {
 			dev_err(&net->dev, "out of memory\n");
 			net->stats.rx_dropped++;
 
 			return -ENOMEM;
 		}
-		skb_reserve(skb, (net->hard_header_len + 15) & ~15);
+		skb_reserve(skb, LL_RESERVED_SPACE(net));
 		memcpy(skb_put(skb, len), buf, len);
 
 		return fwnet_finish_incoming_packet(net, skb, source_node_id,
-- 
1.7.9.5
