From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH/RFC v2 net-next] ravb: unmap descriptors when freeing
 rings
Date: Mon, 23 Jan 2017 10:19:58 +0100
Message-ID: <20170123091958.GE31651@verge.net.au>
References: <1483613000-537-1-git-send-email-horms+renesas@verge.net.au>
 <6fcec500-bed6-ffa3-2887-d45b34703682@cogentembedded.com>
 <20170112091116.GC7724@verge.net.au>
 <3e1d4324-4288-8d65-56fd-8c3e7283020b@cogentembedded.com>
 <20170112131821.GA16060@verge.net.au>
 <8ab10450-5fe3-bc33-6c66-6f3ea861f561@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8ab10450-5fe3-bc33-6c66-6f3ea861f561@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 16, 2017 at 11:41:51PM +0300, Sergei Shtylyov wrote:
> Hello!
> 
> On 01/12/2017 04:18 PM, Simon Horman wrote:
> 
> >...
> 
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
> 
>    After looking at this issue for another time, I'll vote for (a). Sorry
> for back-and-forth on this matter -- I somehow thought we could do a better
> job by scanning all the TX ring...

No problem. I also have had several opinions on this over time.
I'll see about respinning the patch.

> 
> >Ok, something like this?
> >
> >@@ -215,6 +225,30 @@ static void ravb_ring_free(struct net_device *ndev, int q)
> > 	}
> >
> > 	if (priv->tx_ring[q]) {
> >+		for (; priv->cur_tx[q] - priv->dirty_tx[q] > 0; priv->dirty_tx[q]++) {
> >+			struct ravb_tx_desc *desc;
> >+			int entry;
> >+
> >+			entry = priv->dirty_tx[q] % (priv->num_tx_ring[q] *
> >+						     NUM_TX_DESC);
> >+			desc = &priv->tx_ring[q][entry];
> >+
> >+			/* Free the original skb. */
> >+			if (priv->tx_skb[q][entry / NUM_TX_DESC]) {
> >+				u32 size = le16_to_cpu(desc->ds_tagl) & TX_DS;
> >+
> >+				dma_unmap_single(ndev->dev.parent,
> >+						 le32_to_cpu(desc->dptr),
> >+						 size, DMA_TO_DEVICE);
> >+				/* Last packet descriptor? */
> >+				if (entry % NUM_TX_DESC == NUM_TX_DESC - 1) {
> >+					entry /= NUM_TX_DESC;
> >+					dev_kfree_skb_any(priv->tx_skb[q][entry]);
> >+					priv->tx_skb[q][entry] = NULL;
> >+				}
> >+			}
> >+		}
> >+
> 
>    This is only different from ravb_tx_free() by not stopping on unfinished
> descriptor, so we must be good with adding an extra param to it...
> 
> [...]
> 
> MBR, Sergei
> 
