From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmveth: Add function to enable live MAC address
 changes
Date: Fri, 27 Feb 2015 17:22:06 -0500 (EST)
Message-ID: <20150227.172206.206607639934597507.davem@davemloft.net>
References: <1424910864-32266-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755192AbbB0WWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 17:22:08 -0500
In-Reply-To: <1424910864-32266-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Wed, 25 Feb 2015 18:34:24 -0600

> Add a function that will enable changing the MAC address
> of an ibmveth interface while it is still running.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/ibm/ibmveth.c | 20 +++++++++++++++++++-
>  1 file changed, 19 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
> index 21978cc..6e44357 100644
> --- a/drivers/net/ethernet/ibm/ibmveth.c
> +++ b/drivers/net/ethernet/ibm/ibmveth.c
> @@ -1327,6 +1327,24 @@ static unsigned long ibmveth_get_desired_dma(struct vio_dev *vdev)
>  	return ret;
>  }
>  
> +static int ibmveth_set_mac_addr(struct net_device *dev, void *p)
> +{
> +	struct ibmveth_adapter *adapter = netdev_priv(dev);
> +	struct sockaddr *addr = p;
> +	u64 mac_address;
> +	int rc;
> +
> +	if (!is_valid_ether_addr(addr->sa_data))
> +		return -EADDRNOTAVAIL;
> +
> +	ether_addr_copy(dev->dev_addr, addr->sa_data);
> +
> +	mac_address = ibmveth_encode_mac_addr(dev->dev_addr);
> +	rc = h_change_logical_lan_mac(adapter->vdev->unit_address, mac_address);

As others have said, if this hypervisor call fails you must not change
dev->dev_addr.  It must always be in sync with "the hardware."
