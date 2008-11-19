From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-11-18
Date: Wed, 19 Nov 2008 02:33:38 +0100
Message-ID: <1227058418.4014.99.camel@johannes.berg>
References: <20081119000719.GA19756@tuxdriver.com>
	 (sfid-20081119_014629_475391_D51592F4)
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081119000719.GA19756-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> (sfid-20081119_014629_475391_D51592F4)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> and a final one fixes some mysterious DMA alignment problems
> that have been plaguing iwlwifi for some time.


> The following changes since commit 5f9021cfdc3524a4c5e3d7ae2d049eb7adcd6776:
>   Johannes Berg (1):
>         rtnetlink: propagate error from dev_change_flags in do_setlink()

heh.

>      iwlagn: fix RX skb alignment

So Luis pointed out a bug in that, it might be useful to squish in this
patch: http://marc.info/?l=linux-wireless&m=122705425425763&w=2

(also below for reference)

But we can also just add it on top, whichever way you prefer.

johannes
---
 drivers/net/wireless/iwlwifi/iwl-agn.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

--- everything.orig/drivers/net/wireless/iwlwifi/iwl-agn.c	2008-11-19 01:16:12.000000000 +0100
+++ everything/drivers/net/wireless/iwlwifi/iwl-agn.c	2008-11-19 01:19:13.000000000 +0100
@@ -1229,9 +1229,11 @@ void iwl_rx_handle(struct iwl_priv *priv
 
 		rxq->queue[i] = NULL;
 
-		pci_dma_sync_single_for_cpu(priv->pci_dev, rxb->aligned_dma_addr,
-					    priv->hw_params.rx_buf_size,
-					    PCI_DMA_FROMDEVICE);
+		dma_sync_single_range_for_cpu(
+				&priv->pci_dev->dev, rxb->real_dma_addr,
+				rxb->aligned_dma_addr - rxb->real_dma_addr,
+				priv->hw_params.rx_buf_size,
+				PCI_DMA_FROMDEVICE);
 		pkt = (struct iwl_rx_packet *)rxb->skb->data;
 
 		/* Reclaim a command buffer only if this packet is a response


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
