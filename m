From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] qlcnic: dont assume NET_IP_ALIGN is 2
Date: Fri, 17 Sep 2010 11:57:28 +0200
Message-ID: <1284717448.3391.75.camel@edumazet-laptop>
References: <1284700483-16397-1-git-send-email-amit.salecha@qlogic.com>
	 <1284700483-16397-2-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com, David Miller <davem@davemloft.net>
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:64617 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831Ab0IQJ5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 05:57:32 -0400
Received: by wwb31 with SMTP id 31so623965wwb.1
        for <netdev@vger.kernel.org>; Fri, 17 Sep 2010 02:57:31 -0700 (PDT)
In-Reply-To: <1284700483-16397-2-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Amit, I noticed following bug in qlnic driver.

Also, skb->truesize should not be changed by drivers, unless dealing
with fragments.

When you have :
	skb->truesize = skb->len + sizeof(struct sk_buff);

you are lying to stack that can queue many "small" UDP packets,
accouting for small packets in socket rcvbuf, while the truesize was
really 1532 + sizeof(struct sk_buff)

Could you take a look ?

Thanks


[PATCH] qlcnic: dont assume NET_IP_ALIGN is 2

qlcnic driver allocates rx skbs and gives to hardware too bytes of extra
storage, allowing for corruption of kernel data.

NET_IP_ALIGN being 0 on some platforms (including x86), drivers should
not assume it's 2.

rds_ring->skb_size = rds_ring->dma_size + NET_IP_ALIGN;
...
skb = dev_alloc_skb(rds_ring->skb_size);
skb_reserve(skb, 2);
pci_map_single(pdev, skb->data, rds_ring->dma_size, PCI_DMA_FROMDEVICE);

(and rds_ring->skb_size == rds_ring->dma_size) -> bug


Because of extra alignment (1500 + 32) -> four extra bytes are available
before the struct skb_shared_info, so corruption is not noticed.

Note: this driver could use netdev_alloc_skb_ip_align()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 75ba744..60ab753 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -1316,7 +1316,7 @@ qlcnic_alloc_rx_skb(struct qlcnic_adapter *adapter,
 		return -ENOMEM;
 	}
 
-	skb_reserve(skb, 2);
+	skb_reserve(skb, NET_IP_ALIGN);
 
 	dma = pci_map_single(pdev, skb->data,
 			rds_ring->dma_size, PCI_DMA_FROMDEVICE);


