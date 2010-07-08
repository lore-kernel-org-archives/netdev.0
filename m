From: Kulikov Vasiliy <segooon@gmail.com>
Subject: Re: [PATCH 3/4] ll_temac: free everything on error path
Date: Thu, 8 Jul 2010 18:24:20 +0400
Message-ID: <20100708142418.GA30052@shinshilla>
References: <1278591012-3213-1-git-send-email-segooon@gmail.com>
 <AANLkTilm1b61ikLi28We3aLrF3Ld4c05oFZlh3K1pORe@mail.gmail.com>
 <20100708134651.GA27196@shinshilla>
 <AANLkTilMaITOMsn_9MmZ7-zHwpvTd2ZYjj4UUWOloYsn@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kernel Janitors <kernel-janitors@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	John Linn <john.linn@xilinx.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Jiri Pirko <jpirko@redhat.com>,
	Brian Hill <brian.hill@xilinx.com>, netdev@vger.kernel.org
To: dkirjanov@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:39739 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754286Ab0GHOY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 10:24:26 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTilMaITOMsn_9MmZ7-zHwpvTd2ZYjj4UUWOloYsn@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I just sent a patch that fixes this.
Hey, you forgot to CC me/kernel-janitors in your patch.

Anyway,
> /**
>+ *  * temac_dma_bd_release - Release buffer descriptor rings
>+ */
>+static void temac_dma_bd_release(struct net_device *ndev)
>+{
>+   struct temac_local *lp = netdev_priv(ndev);
>+   int i;
>+
>+   for (i = 0; i < RX_BD_NUM; i++) {
>+       if (lp->rx_skb[i]) {
            ^^^^^^^^^^
This can be NULL if kzalloc() failed.
>+           dma_unmap_single(ndev->dev.parent, lp->rx_bd_v[i].phys,
>+                   XTE_MAX_JUMBO_FRAME_SIZE, DMA_FROM_DEVICE);
>+           dev_kfree_skb(lp->rx_skb[i]);
>+       }
>+   }
>+   dma_free_coherent(ndev->dev.parent, sizeof(*lp->rx_bd_v) * RX_BD_NUM,
>+           lp->rx_bd_v, lp->rx_bd_p);
>+   dma_free_coherent(ndev->dev.parent, sizeof(*lp->tx_bd_v) * TX_BD_NUM,
>+           lp->tx_bd_v, lp->tx_bd_p);

These two DMA's can be unallocated if dma_alloc_coherent() failed.

I wanted to introduce many labels to divide these error cases because of it.

>+   kfree(lp->rx_skb);
>+}
