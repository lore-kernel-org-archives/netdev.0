From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] (3/4) acenic - __iomem warnings cleanup
Date: Mon, 20 Sep 2004 11:45:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920114520.5bca1e56.davem@davemloft.net>
References: <20040920104431.0a96d6c1@dell_ss3.pdx.osdl.net>
	<414F199B.3090806@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, jes@wildopensource.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <414F199B.3090806@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 20 Sep 2004 13:55:39 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Stephen Hemminger wrote:
> > Remaining warnings are because tx_ring can be either in i/o or not
> > depending on the version of the card.
> 
> Where is this code?  I don't see any {in,out}[bwl] calls?
> 
> If this were true, we should use io{read,write}{8,16,32}...

The driver uses a single pointer that either goes to DMA descriptors
or I/O memory space.

See the assignment and usage of ap->tx_ring

	if (!ACE_IS_TIGON_I(ap)) {
		size = (sizeof(struct tx_desc) * MAX_TX_RING_ENTRIES);

		ap->tx_ring = pci_alloc_consistent(ap->pdev, size,
						   &ap->tx_ring_dma);

		if (ap->tx_ring == NULL)
			goto fail;
	}
 ...

	if (ACE_IS_TIGON_I(ap)) {
		ap->tx_ring = (struct tx_desc *)regs->Window;
		for (i = 0; i < (TIGON_I_TX_RING_ENTRIES * 
				 sizeof(struct tx_desc) / 4); i++) {
			writel(0, (unsigned long)ap->tx_ring + i * 4);
		}

		set_aceaddr(&info->tx_ctrl.rngptr, TX_RING_BASE);
	} else {
		memset(ap->tx_ring, 0,
		       MAX_TX_RING_ENTRIES * sizeof(struct tx_desc));

		set_aceaddr(&info->tx_ctrl.rngptr, ap->tx_ring_dma);
	}
