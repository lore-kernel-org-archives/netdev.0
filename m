From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH 3/3] etherdev: Use skb->data to retrieve Ethernet header
 instead of eth_hdr
Date: Thu, 30 Apr 2015 14:53:59 -0700
Message-ID: <20150430215359.1798.79917.stgit@ahduyck-vm-fedora22>
References: <20150430214917.1798.49769.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34091 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752192AbbD3VyA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 17:54:00 -0400
In-Reply-To: <20150430214917.1798.49769.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid recomputing the Ethernet header location and instead just use the
pointer provided by skb->data.  The problem with using eth_hdr is that the
compiler wasn't smart enough to realize that skb->head + skb->mac_header
was the same thing as skb->data before it added ETH_HLEN.  By just caching
it off before calling skb_pull_inline we can avoid a few unnecessary
instructions.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ethernet/eth.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 21c211e9fd5a..314e4c5a5a5e 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -156,8 +156,9 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 
 	skb->dev = dev;
 	skb_reset_mac_header(skb);
+
+	eth = (struct ethhdr *)skb->data;
 	skb_pull_inline(skb, ETH_HLEN);
-	eth = eth_hdr(skb);
 
 	if (unlikely(is_multicast_ether_addr_64bits(eth->h_dest))) {
 		if (ether_addr_equal_64bits(eth->h_dest, dev->broadcast))
