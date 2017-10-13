From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net-next PATCH 2/2] macvlan: Only update pkt_type if destination
 MAC address matches
Date: Fri, 13 Oct 2017 13:40:31 -0700
Message-ID: <20171013204030.16950.96375.stgit@localhost.localdomain>
References: <20171013203726.16950.32584.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:47374 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752333AbdJMUkc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 16:40:32 -0400
Received: by mail-pg0-f66.google.com with SMTP id r25so2066973pgn.4
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 13:40:32 -0700 (PDT)
In-Reply-To: <20171013203726.16950.32584.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch updates the pkt_type to PACKET_HOST only if the destination MAC
address matches on the on the source based macvlan. It didn't make sense to
be updating broadcast, multicast, and non-local destined frames with
PACKET_HOST.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/macvlan.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index fb1c9e095d0c..b0cd866915d7 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -413,7 +413,9 @@ static void macvlan_forward_source_one(struct sk_buff *skb,
 
 	len = nskb->len + ETH_HLEN;
 	nskb->dev = dev;
-	nskb->pkt_type = PACKET_HOST;
+
+	if (ether_addr_equal_64bits(eth_hdr(skb)->h_dest, dev->dev_addr))
+		nskb->pkt_type = PACKET_HOST;
 
 	ret = netif_rx(nskb);
 	macvlan_count_rx(vlan, len, ret == NET_RX_SUCCESS, false);
