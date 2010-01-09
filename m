From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
Subject: Re: [PATCH] vxge: use pci_dma_mapping_error to test return value
Date: Sat, 9 Jan 2010 22:52:22 +0300
Message-ID: <20100109195222.GA4271@coldcone>
References: <20100105211659.GA12882@coldcone>
 <20100108.005528.263100819.davem@davemloft.net>
Reply-To: kirjanov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:52645 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739Ab0AITuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2010 14:50:39 -0500
Received: by fg-out-1718.google.com with SMTP id 22so213654fge.1
        for <netdev@vger.kernel.org>; Sat, 09 Jan 2010 11:50:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100108.005528.263100819.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 08, 2010 at 00:55 -0800, David Miller wrote:
> From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
> Date: Wed, 6 Jan 2010 00:16:59 +0300
> 
> > @@ -821,7 +821,7 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
> >  	int frg_cnt, first_frg_len;
> >  	skb_frag_t *frag;
> >  	int i = 0, j = 0, avail;
> > -	u64 dma_pointer;
> > +	dma_addr_t dma_pointer;
> >  	struct vxge_tx_priv *txdl_priv = NULL;
> >  	struct __vxge_hw_fifo *fifo_hw;
> >  	int offload_type;
> 
> This will cause build warnings on platforms withe dma_addr_t
> is some type other than "unsigned long long", such as on
> sparc64 where it is a u32.
> 
> This is because of the %ll printf format used to display it
> a few lines down from here.
My mistake. Fixed one.

pci_dma_mapping_error should be used to test return value of
pci_map_single or pci_map_page.

Signed-off-by: Denis Kirjanov <kirjanov@gmail.com>
---

 drivers/net/vxge/vxge-main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 0fdfd58..b9685e8 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -310,7 +310,7 @@ static int vxge_rx_map(void *dtrh, struct vxge_ring *ring)
 	dma_addr = pci_map_single(ring->pdev, rx_priv->skb_data,
 				rx_priv->data_size, PCI_DMA_FROMDEVICE);
 
-	if (dma_addr == 0) {
+	if (unlikely(pci_dma_mapping_error(ring->pdev, dma_addr))) {
 		ring->stats.pci_map_fail++;
 		return -EIO;
 	}
