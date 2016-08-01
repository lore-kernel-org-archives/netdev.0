From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: Re: [PATCH 2/2] nvme-rdma: Add handling for connecting to IPv6
	targets
Date: Mon, 1 Aug 2016 13:09:03 +0200
Message-ID: <20160801110903.GH16141@lst.de>
References: <1469950060-18098-1-git-send-email-roland@kernel.org> <1469950060-18098-2-git-send-email-roland@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <axboe-b10kYP2dOMg@public.gmane.org>, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>,
	linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1469950060-18098-2-git-send-email-roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Roland,

On Sun, Jul 31, 2016 at 12:27:40AM -0700, Roland Dreier wrote:
> From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
> 
> If a target address does not parse as IPv4, try parsing it as IPv6
> (including handling '%<scope-id>' suffixes for link-local addresses).

The code below looks fine to me, but is there any chance to add it to
net/ as a generic helper?  It's a little sad this sort of code would
have to live in each driver trying to parse IP addresses.

> Signed-off-by: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
> ---
>  drivers/nvme/host/rdma.c | 55 ++++++++++++++++++++++++++++++++++++++----------
>  1 file changed, 44 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/nvme/host/rdma.c b/drivers/nvme/host/rdma.c
> index b96b88369871..dd4aa54cd709 100644
> --- a/drivers/nvme/host/rdma.c
> +++ b/drivers/nvme/host/rdma.c
> @@ -138,6 +138,7 @@ struct nvme_rdma_ctrl {
>  	union {
>  		struct sockaddr addr;
>  		struct sockaddr_in addr_in;
> +		struct sockaddr_in6 addr_in6;
>  	};
>  
>  	struct nvme_ctrl	ctrl;
> @@ -1847,19 +1848,51 @@ out_free_io_queues:
>  	return ret;
>  }
>  
> -static int nvme_rdma_parse_ipaddr(struct sockaddr_in *in_addr, char *p)
> +static int nvme_rdma_parse_ipaddr(struct sockaddr *addr, char *p)
>  {
> -	u8 *addr = (u8 *)&in_addr->sin_addr.s_addr;
>  	size_t buflen = strlen(p);
>  
> -	/* XXX: handle IPv6 addresses */
> +	if (buflen <= INET_ADDRSTRLEN) {
> +		struct sockaddr_in *addr4 = (struct sockaddr_in *) addr;
> +		if (in4_pton(p, buflen, (u8 *) &addr4->sin_addr.s_addr,
> +			     '\0', NULL) > 0) {
> +			addr4->sin_family = AF_INET;
> +			return 0;
> +		}
> +	}
>  
> -	if (buflen > INET_ADDRSTRLEN)
> -		return -EINVAL;
> -	if (in4_pton(p, buflen, addr, '\0', NULL) == 0)
> -		return -EINVAL;
> -	in_addr->sin_family = AF_INET;
> -	return 0;
> +	if (buflen <= INET6_ADDRSTRLEN) {
> +		struct sockaddr_in6 *addr6 = (struct sockaddr_in6 *) addr;
> +		const char *scope_delim;
> +
> +		if (in6_pton(p, buflen, (u8 *) &addr6->sin6_addr.s6_addr,
> +			     '%', &scope_delim) == 0)
> +			return -EINVAL;
> +		addr6->sin6_family = AF_INET6;
> +
> +		if (ipv6_addr_type(&addr6->sin6_addr) & IPV6_ADDR_LINKLOCAL &&
> +		    p + buflen != scope_delim && *scope_delim == '%') {
> +			char scope_id[16];
> +			size_t scope_len = min_t(size_t, sizeof scope_id,
> +						 p + buflen - scope_delim - 1);
> +			struct net_device *dev;
> +
> +			memcpy(scope_id, scope_delim + 1, scope_len);
> +			scope_id[scope_len] = '\0';
> +
> +			/* XXX: what network namespace should we use? */
> +			dev = dev_get_by_name(&init_net, scope_id);
> +			if (dev) {
> +				addr6->sin6_scope_id = dev->ifindex;
> +				dev_put(dev);
> +			} else if (kstrtouint(scope_id, 0, &addr6->sin6_scope_id))
> +				return -EINVAL;
> +		}
> +
> +		return 0;
> +	}
> +
> +	return -EINVAL;
>  }
>  
>  static struct nvme_ctrl *nvme_rdma_create_ctrl(struct device *dev,
> @@ -1875,7 +1908,7 @@ static struct nvme_ctrl *nvme_rdma_create_ctrl(struct device *dev,
>  	ctrl->ctrl.opts = opts;
>  	INIT_LIST_HEAD(&ctrl->list);
>  
> -	ret = nvme_rdma_parse_ipaddr(&ctrl->addr_in, opts->traddr);
> +	ret = nvme_rdma_parse_ipaddr(&ctrl->addr, opts->traddr);
>  	if (ret) {
>  		pr_err("malformed IP address passed: %s\n", opts->traddr);
>  		goto out_free_ctrl;
> @@ -1949,7 +1982,7 @@ static struct nvme_ctrl *nvme_rdma_create_ctrl(struct device *dev,
>  	changed = nvme_change_ctrl_state(&ctrl->ctrl, NVME_CTRL_LIVE);
>  	WARN_ON_ONCE(!changed);
>  
> -	dev_info(ctrl->ctrl.device, "new ctrl: NQN \"%s\", addr %pISp\n",
> +	dev_info(ctrl->ctrl.device, "new ctrl: NQN \"%s\", addr %pISpcs\n",
>  		ctrl->ctrl.opts->subsysnqn, &ctrl->addr);
>  
>  	kref_get(&ctrl->ctrl.kref);
> -- 
> 2.7.4
---end quoted text---
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
