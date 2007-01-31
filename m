From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH] [v3] PA Semi PWRficient Ethernet driver
Date: Wed, 31 Jan 2007 13:44:31 +0100
Message-ID: <200701311344.31692.netdev@axxeo.de>
References: <20070129060852.GA7814@lixom.net> <20070130014434.GC18935@lixom.net> <20070131054457.GA32043@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Christoph Hellwig <hch@infradead.org>
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:57885 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933202AbXAaMo7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 07:44:59 -0500
In-Reply-To: <20070131054457.GA32043@lixom.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Olof Johansson schrieb:
[...]
> +static int pasemi_mac_close(struct net_device *dev)
> +{
[..]
> +	do {
> +		pci_read_config_dword(mac->dma_pdev,
> +				      PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch),
> +				      &stat);
> +	} while (stat & PAS_DMA_TXCHAN_TCMDSTA_ACT);
> +
> +	do {
> +		pci_read_config_dword(mac->dma_pdev,
> +				      PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch),
> +				      &stat);
> +	} while (stat & PAS_DMA_RXCHAN_CCMDSTA_ACT);
> +
> +	do {
> +		pci_read_config_dword(mac->dma_pdev,
> +				      PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
> +				      &stat);
> +	} while (stat & PAS_DMA_RXINT_RCMDSTA_ACT);

You might want to write these loops like that:

#define MAX_READ_TRIES 10000
unsigned int tries;
unsigned int state;
for(tries=0; tries < MAX_READ_TRIES; tries++)
{
	read_stat(&stat);
	if ((stat & STATE_FLAG) == 0);
		break;
	cond_resched();
}
if (stat & STATE_FLAG) {
	dev_err(&mac->pdev->dev, "Failed to stop device, possible hardware error?\n");
        /* Panic, disable device, mark unusable, whatever is better than hanging here */
}

That way you:
- Let you give other processes a chance to run, 
  while you wait for your hardware state to change 
  (if your hardware can tolerate these latencies).
- can somehow handle hardware failure and at least give the user a clue
  what is happening.

Regards

Ingo Oeser
