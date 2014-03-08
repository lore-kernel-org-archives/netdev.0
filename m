From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH] vmxnet3: fix netpoll race condition
Date: Fri, 7 Mar 2014 21:14:21 -0800 (PST)
Message-ID: <739029197.38929769.1394255661208.JavaMail.root@vmware.com>
References: <1394227527-31082-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "VMware, Inc." <pv-drivers@vmware.com>,
	"David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1394227527-31082-1-git-send-email-nhorman@tuxdriver.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for the patch Neil. 


> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> @@ -1762,11 +1762,13 @@ vmxnet3_netpoll(struct net_device *netdev)
>  {
>  	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
>  
> -	if (adapter->intr.mask_mode == VMXNET3_IMM_ACTIVE)
> -		vmxnet3_disable_all_intrs(adapter);
> -
> -	vmxnet3_do_poll(adapter, adapter->rx_queue[0].rx_ring[0].size);
> -	vmxnet3_enable_all_intrs(adapter);
> +	switch (adapter->intr.type) {
> +	case VMXNET3_IT_MSIX:
> +		vmxnet3_msix_rx(0, &adapter->rx_queue[0]);

This should be called for each rx queue, just calling it for
1st queue does not suffice.
Also there should be a break; here


> +	case VMXNET3_IT_MSI:
> +	default:
> +		vmxnet3_intr(0, adapter->netdev);
> +	}
