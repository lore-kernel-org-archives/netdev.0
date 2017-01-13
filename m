From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH/RFC v2 net-next] ravb: unmap descriptors when freeing
 rings
Date: Fri, 13 Jan 2017 13:01:35 +0100
Message-ID: <20170113120133.GA31006@verge.net.au>
References: <1483613000-537-1-git-send-email-horms+renesas@verge.net.au>
 <6fcec500-bed6-ffa3-2887-d45b34703682@cogentembedded.com>
 <20170112091116.GC7724@verge.net.au>
 <3e1d4324-4288-8d65-56fd-8c3e7283020b@cogentembedded.com>
 <20170112131821.GA16060@verge.net.au>
 <dc41bc36-8239-39d7-def1-a60603e3890a@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <dc41bc36-8239-39d7-def1-a60603e3890a@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 12, 2017 at 07:33:51PM +0300, Sergei Shtylyov wrote:
> On 01/12/2017 04:18 PM, Simon Horman wrote:
> 
> >...
> >
> >>>>  Here, it stop once an untransmitted buffer is encountered...
> >>>
> >>>Yes, I see that now.
> >>>
> >>>I wonder if we should:
> >>>
> >>>a) paramatise ravb_tx_free() so it may either clear all transmitted buffers
> >>>  (current behaviour) or all buffers (new behaviour).
> >>>b) provide a different version of this loop in ravb_ring_free()
> >>>
> >>>What are your thoughts?
> >>
> >>   I'm voting for (b).
> >
> >Ok, something like this?
> >
> >@@ -215,6 +225,30 @@ static void ravb_ring_free(struct net_device *ndev, int q)
> > 	}
> >
> > 	if (priv->tx_ring[q]) {
> >+		for (; priv->cur_tx[q] - priv->dirty_tx[q] > 0; priv->dirty_tx[q]++) {
> 
>    You're still copying the loop logic from ravb_tx_free() while we (I
> think) need a simple loop over all the descriptor ring.

I thought the above may be better as it seems to me that only descriptors
in the range described above could need to be freed. But simpler may be
better. And I also noticed several other problems with the code I posted
yesterday afternoon.

How about something like this?

@@ -215,6 +225,17 @@ static void ravb_ring_free(struct net_device *ndev, int q)
 	}
 
 	if (priv->tx_ring[q]) {
+		for (i = 0; i < priv->num_tx_ring[q] * NUM_TX_DESC; i++) {
+			struct ravb_tx_desc *desc = &priv->tx_ring[q][i];
+
+			if (desc->die_dt != DT_EEMPTY) {
+				u32 size = le16_to_cpu(desc->ds_tagl) & TX_DS;
+
+				dma_unmap_single(ndev->dev.parent,
+						 le32_to_cpu(desc->dptr),
+						 size, DMA_TO_DEVICE);
+			}
+		}
 		ring_size = sizeof(struct ravb_tx_desc) *
 			    (priv->num_tx_ring[q] * NUM_TX_DESC + 1);
 		dma_free_coherent(ndev->dev.parent, ring_size, priv->tx_ring[q],
