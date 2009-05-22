From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Code changes to handle dev private ioctl
Date: Fri, 22 May 2009 15:21:19 +0100
Message-ID: <1243002079.3192.11.camel@achroite>
References: <20090522133315.GA13610@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:52427 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753960AbZEVOVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 10:21:24 -0400
In-Reply-To: <20090522133315.GA13610@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-05-22 at 19:03 +0530, Sarveshwar Bandi wrote:
[...]
> diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
> index ae2f6b5..8329e07 100644
> --- a/drivers/net/benet/be_main.c
> +++ b/drivers/net/benet/be_main.c
> @@ -562,6 +562,53 @@ static void be_vlan_rem_vid(struct net_d
>  	be_vid_config(netdev);
>  }
>  
> +static int be_do_ioctl(struct net_device *netdev,
> +			struct ifreq *ifr, int cmd)
> +{
> +	struct be_adapter *adapter = netdev_priv(netdev);
> +	struct be_cmd_req_hdr req;
> +	struct be_cmd_resp_hdr *resp;
> +	void *data = ifr->ifr_data;
> +	void *va;
> +	dma_addr_t dma;
> +	u32 req_size, resp_size;
> +	int status;
> +
> +	switch (cmd) {
> +	case SIOCDEVPRIVATE:

This probably needs a capability check, depending on what it's actually
doing.  Most configuration ioctl implementation use:

		if (!capable(CAP_NET_ADMIN))
			return -EPERM;

> +		if (copy_from_user(&req, (struct be_cmd_req_hdr *)data,
> +			sizeof(struct be_cmd_req_hdr)))
> +			return -EFAULT;
> +
> +		req_size = req.request_length + sizeof(struct be_cmd_req_hdr);
> +
> +		va = pci_alloc_consistent(adapter->pdev, req_size, &dma);

Needs an error check.

> +		if (copy_from_user(va, (void *)data, req_size)) {
> +			pci_free_consistent(adapter->pdev, req_size, va, dma);
> +			return -EFAULT;
> +		}
> +
> +		status = be_cmd_pass_ext_ioctl(&adapter->ctrl, dma, req_size);
> +		if (!status) {
> +			resp = (struct be_cmd_resp_hdr *) va;
> +			resp_size = resp->response_length + sizeof(*resp);
> +			if (copy_to_user((void *)data, va, resp_size)) {
> +				pci_free_consistent(adapter->pdev,
> +							req_size, va, dma);
> +				return -EFAULT;
> +			}
> +		} else {
> +			pci_free_consistent(adapter->pdev, req_size, va, dma);
> +			return -EFAULT;

Why repeat this cleanup and return so many times?  Kernel style is to
put cleanup code at the end of the function and use "goto" to get there
in case of error.

> +		}
> +		pci_free_consistent(adapter->pdev, req_size, va, dma);
> +		break;
> +	default:
> +		return -EFAULT;
[...]

Should be -EOPNOTSUPP.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

