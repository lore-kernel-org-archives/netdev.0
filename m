From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/7] cxgb3 - fix netpoll hanlder
Date: Mon, 28 May 2007 18:35:07 -0400
Message-ID: <465B591B.1010507@garzik.org>
References: <20070526225952.12115.30971.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48864 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751442AbXE1WfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 May 2007 18:35:09 -0400
In-Reply-To: <20070526225952.12115.30971.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

divy@chelsio.com wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Fix netpoll handler to work with line interrupt, msi and msi-x.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/cxgb3/cxgb3_main.c |   12 +++++++++---
>  drivers/net/cxgb3/sge.c        |    1 -
>  2 files changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
> index 67b4b21..e0ef724 100644
> --- a/drivers/net/cxgb3/cxgb3_main.c
> +++ b/drivers/net/cxgb3/cxgb3_main.c
> @@ -2076,10 +2076,16 @@ static void vlan_rx_kill_vid(struct net_
>  static void cxgb_netpoll(struct net_device *dev)
>  {
>  	struct adapter *adapter = dev->priv;
> -	struct sge_qset *qs = dev2qset(dev);
> +	struct port_info *pi = netdev_priv(dev);
> +	int qidx;
>  
> -	t3_intr_handler(adapter, qs->rspq.polling) (adapter->pdev->irq,
> -						    adapter);
> +	for (qidx = pi->first_qset; qidx < pi->first_qset + pi->nqsets; qidx++) {
> +		struct sge_qset *qs = &adapter->sge.qs[qidx];
> +		
> +		t3_intr_handler(adapter, qs->rspq.polling) (0, 
> +					(adapter->flags & USING_MSIX) ?
> +					(void *)qs : (void *)adapter);

Remove needless casts to void*


