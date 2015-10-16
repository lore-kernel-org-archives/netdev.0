From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH 1/1] xen-netfront: update num_queues to real created
Date: Fri, 16 Oct 2015 11:56:57 +0100
Message-ID: <20151016105657.GN32638@zion.uk.xensource.com>
References: <561F10A7.80305@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <wei.liu2@citrix.com>, Ian Campbell <ian.campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	<netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	<stable@vger.kernel.org>, David Vrabel <david.vrabel@citrix.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: Joe Jin <joe.jin@oracle.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <561F10A7.80305@oracle.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CC David and Boris (Konrad was already a recipient).

On Thu, Oct 15, 2015 at 10:34:15AM +0800, Joe Jin wrote:
> Sometimes xennet_create_queues() may failed to created all requested
> queues, we need to update num_queues to real created to avoid NULL
> pointer dereference.
> 
> Signed-off-by: Joe Jin <joe.jin@oracle.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/xen-netfront.c |    9 ++++++---
>  1 files changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index f821a97..d580aec 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -1746,7 +1746,7 @@ static int xennet_create_queues(struct netfront_info *info,
>  		dev_err(&info->netdev->dev, "no queues\n");
>  		return -EINVAL;
>  	}
> -	return 0;
> +	return num_queues;
>  }
>  
>  /* Common code used when first setting up, and when resuming. */
> @@ -1788,9 +1788,12 @@ static int talk_to_netback(struct xenbus_device *dev,
>  	if (info->queues)
>  		xennet_destroy_queues(info);
>  
> -	err = xennet_create_queues(info, num_queues);
> -	if (err < 0)
> +	/* Update queues number to real created */
> +	num_queues = xennet_create_queues(info, num_queues);
> +	if (num_queues < 0) {
> +		err = num_queues;
>  		goto destroy_ring;
> +	}
>  
>  	/* Create shared ring, alloc event channel -- for each queue */
>  	for (i = 0; i < num_queues; ++i) {
> -- 
> 1.7.1
