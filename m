From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] virtio_net: fix truesize underestimation
Date: Thu, 20 Oct 2011 11:14:46 +0200
Message-ID: <1319102086.3781.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org,
	Krishna Kumar <krkumar2@in.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:41500 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268Ab1JTJOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 05:14:50 -0400
Received: by yxl42 with SMTP id 42so12325yxl.19
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 02:14:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We must account in skb->truesize, the size of the fragments, not the
used part of them.

Doing this work is important to avoid unexpected OOM situations.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Rusty Russell <rusty@rustcorp.com.au>
CC: "Michael S. Tsirkin" <mst@redhat.com>
CC: virtualization@lists.linux-foundation.org
CC: Krishna Kumar <krkumar2@in.ibm.com>
---
 drivers/net/virtio_net.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index abbf34f..765ab9a 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -150,6 +150,7 @@ static void set_skb_frag(struct sk_buff *skb, struct page *page,
 
 	skb->data_len += size;
 	skb->len += size;
+	skb->truesize += PAGE_SIZE;
 	skb_shinfo(skb)->nr_frags++;
 	*len -= size;
 }
@@ -287,7 +288,6 @@ static void receive_buf(struct net_device *dev, void *buf, unsigned int len)
 	}
 
 	hdr = skb_vnet_hdr(skb);
-	skb->truesize += skb->data_len;
 
 	u64_stats_update_begin(&stats->syncp);
 	stats->rx_bytes += skb->len;
