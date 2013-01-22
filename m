From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG in netxen_release_tx_buffers when TSO enabled on kernels
 >= 3.3 and <= 3.6
Date: Tue, 22 Jan 2013 08:33:05 -0800
Message-ID: <1358872385.3464.3940.camel@edumazet-glaptop>
References: <1659861.dHpGAGoXHj@cpaasch-mac>
	 <1358862966.3464.3797.camel@edumazet-glaptop>
	 <2166577.r0iRQtU7qE@cpaasch-mac>  <3172160.NCYvLW6RVJ@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:37614 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754468Ab3AVQdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 11:33:10 -0500
Received: by mail-da0-f51.google.com with SMTP id i30so3292933dad.38
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 08:33:10 -0800 (PST)
In-Reply-To: <3172160.NCYvLW6RVJ@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Tue, 2013-01-22 at 16:43 +0100, Christoph Paasch wrote:
> In netxen_map_tx_skb() I think we also have to set nf->dma to 0ULL (like the 
> diff below).
> 
> Otherwise, netxen_release_tx_buffer() may try to unmap something that has 
> already been unmapped.
> 
> I'm not sure - I don't feel very comfortable in driver-code...

It seems fine to me, here is the official combined patch, feel
free to add your 'Signed-off-by'

Thanks !

[PATCH] netxen: fix off by one bug in netxen_release_tx_buffer()

Christoph Paasch found netxen could trigger a BUG in its dismantle
phase, in netxen_release_tx_buffer(), using full size TSO packets.

cmd_buf->frag_count includes the skb->data part, so the loop must
start at index 1 instead of 0, or else we can make an out
of bound access to cmd_buff->frag_array[MAX_SKB_FRAGS + 2]

Christoph provided the fixes in netxen_map_tx_skb() function.
In case of a dma mapping error, its better to clear the dma fields
so that we don't try to unmap them again in netxen_release_tx_buffer()

Reported-by: Christoph Paasch <christoph.paasch@uclouvain.be>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Tested-by: Christoph Paasch <christoph.paasch@uclouvain.be>
Cc: Sony Chacko <sony.chacko@qlogic.com>
Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c |    2 +-
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c |    2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
index bc165f4..695667d 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
@@ -144,7 +144,7 @@ void netxen_release_tx_buffers(struct netxen_adapter *adapter)
 					 buffrag->length, PCI_DMA_TODEVICE);
 			buffrag->dma = 0ULL;
 		}
-		for (j = 0; j < cmd_buf->frag_count; j++) {
+		for (j = 1; j < cmd_buf->frag_count; j++) {
 			buffrag++;
 			if (buffrag->dma) {
 				pci_unmap_page(adapter->pdev, buffrag->dma,
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 6098fd4a..69e321a 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -1963,10 +1963,12 @@ unwind:
 	while (--i >= 0) {
 		nf = &pbuf->frag_array[i+1];
 		pci_unmap_page(pdev, nf->dma, nf->length, PCI_DMA_TODEVICE);
+		nf->dma = 0ULL;
 	}
 
 	nf = &pbuf->frag_array[0];
 	pci_unmap_single(pdev, nf->dma, skb_headlen(skb), PCI_DMA_TODEVICE);
+	nf->dma = 0ULL;
 
 out_err:
 	return -ENOMEM;
