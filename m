From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] b44 1GB DMA workaround (was: b44: add 47xx support)
Date: Tue, 3 Aug 2004 18:39:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040803183919.2990d045.davem@redhat.com>
References: <200407232335.37809.jolt@tuxbox.org>
	<20040726141128.GA5435@ee.oulu.fi>
	<20040804003108.GA10445@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, jolt@tuxbox.org, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Pietikainen <pp@ee.oulu.fi>
In-Reply-To: <20040804003108.GA10445@ee.oulu.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 4 Aug 2004 03:31:08 +0300
Pekka Pietikainen <pp@ee.oulu.fi> wrote:

> +	if(mapping+len > B44_DMA_MASK) {
> +		/* Chip can't handle DMA to/from >1GB, use bounce buffer */
> +		pci_unmap_single(bp->pdev, mapping, len,PCI_DMA_TODEVICE);
> +		memcpy(bp->tx_bufs+entry*TX_PKT_BUF_SZ,skb->data,skb->len);
> +		skb->data=bp->tx_bufs+entry*TX_PKT_BUF_SZ;
> +		mapping = pci_map_single(bp->pdev, skb->data, len, PCI_DMA_TODEVICE);
> +	}

Changing skb->data is not legal.  Please implement this in
such a way that skb->data does not get modified.  By modifying
skb->data you will break things such as packet sniffers and
netfilter, and that's just the tip of the iceberg. :-)

I would suggest merely freeing up this TX skb, and marking the
entry in the b44 software state with some dummy skb pointer
such as (void *) 0x1UL or something like that to indicate
this case.
