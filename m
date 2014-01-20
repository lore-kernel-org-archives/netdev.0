From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH 2/2] net/cxgb4: Don't retrieve stats during recovery
Date: Mon, 20 Jan 2014 14:05:18 -0800
Message-ID: <52DD9D9E.3010205@chelsio.com>
References: <1390187144-15495-1-git-send-email-shangw@linux.vnet.ibm.com> <1390187144-15495-2-git-send-email-shangw@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Gavin Shan <shangw@linux.vnet.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:38109
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751517AbaATXAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 18:00:12 -0500
In-Reply-To: <1390187144-15495-2-git-send-email-shangw@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/19/2014 07:05 PM, Gavin Shan wrote:
> We possiblly retrieve the adapter's statistics during EEH recovery
> and that should be disallowed. Otherwise, it would possibly incur
> replicate EEH error and EEH recovery is going to fail eventually.
> The patch checks if the PCI device is off-line before statistic
> retrieval.

The net_devices are detached during EEH so I think netif_device_present 
is a better check than pci_channel_offline.  I am not sure such a test 
should be left to each driver though.  If you do end up putting it in 
the driver it needs better synchronization with the EEH handlers as Ben 
mentioned.

>
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> ---
>   drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   11 +++++++++++
>   1 file changed, 11 insertions(+)
>
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> index c8eafbf..b0e72fb 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> @@ -4288,6 +4288,17 @@ static struct rtnl_link_stats64 *cxgb_get_stats(struct net_device *dev,
>   	struct port_info *p = netdev_priv(dev);
>   	struct adapter *adapter = p->adapter;
>
> +	/*
> +	 * We possibly retrieve the statistics while the PCI
> +	 * device is off-line. That would cause the recovery
> +	 * on off-lined PCI device going to fail. So it's
> +	 * reasonable to block it during the recovery period.
> +	 */
> +	if (pci_channel_offline(adapter->pdev)) {
> +		memset(ns, 0, sizeof(*ns));
> +		return ns;
> +	}
> +
>   	spin_lock(&adapter->stats_lock);
>   	t4_get_port_stats(adapter, p->tx_chan, &stats);
>   	spin_unlock(&adapter->stats_lock);
>
