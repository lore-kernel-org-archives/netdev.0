From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH] atl1c: Fix misuse of netdev_alloc_skb in refilling
 rx ring
Date: Sun, 28 Jul 2013 13:08:33 -0700
Message-ID: <1375042113.3669.40.camel@edumazet-glaptop>
References: <87k3kbdcmy.fsf@canonical.com>
	 <1374960610.3607.13.camel@deadeye.wl.decadent.org.uk>
	 <1374969583.3669.23.camel@edumazet-glaptop>
	 <20130727.200205.67471633133830510.davem@davemloft.net>
	 <20130728104446.GB9876@neilslaptop.think-freely.org>
	 <1375028154.3669.30.camel@edumazet-glaptop>
	 <20130728185318.GA10795@neilslaptop.think-freely.org>
	 <1375039316.3669.36.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	luis.henriques@canonical.com, netdev@vger.kernel.org,
	jcliburn@gmail.com, stable@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1375039316.3669.36.camel@edumazet-glaptop>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-07-28 at 12:21 -0700, Eric Dumazet wrote:

> 
> btw, this driver leaks skb horribly in this error path :
> 
>                 if (rrs->word3 & (RRS_RX_ERR_SUM | RRS_802_3_LEN_ERR)) {
>                         atl1c_clean_rfd(rfd_ring, rrs, rfd_num);
>                                 if (netif_msg_rx_err(adapter))
>                                         dev_warn(&pdev->dev,
>                                                 "wrong packet! rrs word3 is %x\n",
>                                                 rrs->word3);
>                         continue;
>                 }

Possible fix would be :

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 786a874..e815c23 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1729,11 +1729,16 @@ static void atl1c_clean_rfd(struct atl1c_rfd_ring *rfd_ring,
 	u16 i;
 	u16 rfd_index;
 	struct atl1c_buffer *buffer_info = rfd_ring->buffer_info;
+	struct sk_buff *skb;
 
 	rfd_index = (rrs->word0 >> RRS_RX_RFD_INDEX_SHIFT) &
 			RRS_RX_RFD_INDEX_MASK;
 	for (i = 0; i < num; i++) {
-		buffer_info[rfd_index].skb = NULL;
+		skb = buffer_info[rfd_index].skb;
+		if (skb) {
+			kfree_skb(skb);
+			buffer_info[rfd_index].skb = NULL;
+		}
 		ATL1C_SET_BUFFER_STATE(&buffer_info[rfd_index],
 					ATL1C_BUFFER_FREE);
 		if (++rfd_index == rfd_ring->count)
@@ -1793,6 +1798,7 @@ rrs_checked:
 			pci_unmap_single(pdev, buffer_info->dma,
 				buffer_info->length, PCI_DMA_FROMDEVICE);
 			skb = buffer_info->skb;
+			buffer_info->skb = NULL;
 		} else {
 			/* TODO */
 			if (netif_msg_rx_err(adapter))
