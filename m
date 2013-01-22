From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: BUG in netxen_release_tx_buffers when TSO enabled on kernels >=
 3.3 and <= 3.6
Date: Tue, 22 Jan 2013 19:36:51 +0000
Message-ID: <1358883411.2892.11.camel@bwh-desktop.uk.solarflarecom.com>
References: <1659861.dHpGAGoXHj@cpaasch-mac>
	 <1358861524.3464.3768.camel@edumazet-glaptop>
	 <1358862966.3464.3797.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <christoph.paasch@uclouvain.be>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51650 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625Ab3AVTgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 14:36:55 -0500
In-Reply-To: <1358862966.3464.3797.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-22 at 05:56 -0800, Eric Dumazet wrote:
> On Tue, 2013-01-22 at 05:32 -0800, Eric Dumazet wrote:
> 
> > 
> > Something doesn't properly test MAX_SKB_FRAGS, we should track it and
> > fix.
> 
> I guess netxen driver has a bug.
> 
> Please try the following patch :
> 
> diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
> index bc165f4..695667d 100644
> --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
> +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
> @@ -144,7 +144,7 @@ void netxen_release_tx_buffers(struct netxen_adapter *adapter)
>  					 buffrag->length, PCI_DMA_TODEVICE);
>  			buffrag->dma = 0ULL;
>  		}
> -		for (j = 0; j < cmd_buf->frag_count; j++) {
> +		for (j = 1; j < cmd_buf->frag_count; j++) {
>  			buffrag++;
>  			if (buffrag->dma) {
>  				pci_unmap_page(adapter->pdev, buffrag->dma,
> 

There's another bug right here, which is that 0 is a valid DMA address
in some systems.  The driver should be calling pci_dma_mapping_error()
to find out whether an address is valid or not.  But it also wants to be
able to assign an invalid address to netxen_skb_frag::dma, and
unfortunately there is no way to do that in the current DMA API.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
