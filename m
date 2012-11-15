From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 2/4] xen/netback: Split one page pool into two(tx/rx)
 page pool.
Date: Thu, 15 Nov 2012 09:15:13 +0000
Message-ID: <1352970913.3499.47.camel@zakaz.uk.xensource.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>
	 <1352963089-599-1-git-send-email-annie.li@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Annie Li <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:29281 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992592Ab2KOJPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 04:15:16 -0500
In-Reply-To: <1352963089-599-1-git-send-email-annie.li@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-15 at 07:04 +0000, Annie Li wrote:
> For tx path, this implementation simplifies the work of searching out
> grant page from page pool based on grant reference.

It's still a linear search though, and it doesn't look much simpler to
me:
  	for (i = 0; i < count; i++) {
		if (tx_pool)
			vif = netbk->gnttab_tx_vif[i];
		else
			vif = netbk->gnttab_rx_vif[i];

		pers_entry = vif->persistent_gnt;
		gnt_count = &vif->persistent_gntcnt;
		gnt_total = MAXIMUM_OUTSTANDING_BLOCK_REQS;
becomes:
	for (i = 0; i < count; i++) {
		if (tx_pool) {
			vif = netbk->gnttab_tx_vif[i];
			gnt_count = &vif->persistent_tx_gntcnt;
			gnt_total = XEN_NETIF_TX_RING_SIZE;
			pers_entry = vif->persistent_tx_gnt;
		} else {
			vif = netbk->gnttab_rx_vif[i];
			gnt_count = &vif->persistent_rx_gntcnt;
			gnt_total = 2*XEN_NETIF_RX_RING_SIZE;
			pers_entry = vif->persistent_rx_gnt;
		}

> @@ -111,8 +109,16 @@ struct xenvif {
>  
>  	wait_queue_head_t waiting_to_free;
>  
> -	struct persistent_entry *persistent_gnt[MAXIMUM_OUTSTANDING_BLOCK_REQS];
> -	unsigned int persistent_gntcnt;
> +	struct persistent_entry *persistent_tx_gnt[XEN_NETIF_TX_RING_SIZE];
> +
> +	/*
> +	 * 2*XEN_NETIF_RX_RING_SIZE is for the case of each head/fragment page

Shouldn't that been incorporated into MAXIMUM_OUTSTANDING_BLOCK_REQS
(sic) too?

> +	 * using 2 copy operations.
> +	 */
> +	struct persistent_entry *persistent_rx_gnt[2*XEN_NETIF_RX_RING_SIZE];

What is the per-vif memory overhead after this change?

Ian.
