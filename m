From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] xen-netback: fix a BUG() during initialization
Date: Fri, 19 Jun 2015 16:37:39 +0100
Message-ID: <20150619153739.GL28194@zion.uk.xensource.com>
References: <1434716511-25657-1-git-send-email-imrep.amz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, "Palik, Imre" <imrep@amazon.de>,
	Matt Wilson <msw@amazon.com>
To: Imre Palik <imrep.amz@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1434716511-25657-1-git-send-email-imrep.amz@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 19, 2015 at 02:21:51PM +0200, Imre Palik wrote:
> From: "Palik, Imre" <imrep@amazon.de>
> 
> Commit edafc132baac ("xen-netback: making the bandwidth limiter runtime settable")
> introduced the capability to change the bandwidth rate limit at runtime.
> But it also introduced a possible crashing bug.
> 
> If netback receives two XenbusStateConnected without getting the
> hotplug-status watch firing in between, then it will try to register the
> watches for the rate limiter again.  But this triggers a BUG() in the watch
> registration code.
> 
> The fix modifies connect() to remove the possibly existing packet-rate
> watches before trying to install those watches.  This behaviour is in line
> with how connect() deals with the hotplug-status watch.
> 
> Signed-off-by: Imre Palik <imrep@amazon.de>
> Cc: Matt Wilson <msw@amazon.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>

> ---
>  drivers/net/xen-netback/xenbus.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
> index 968787a..ec383b0 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -681,6 +681,9 @@ static int xen_register_watchers(struct xenbus_device *dev, struct xenvif *vif)
>  	char *node;
>  	unsigned maxlen = strlen(dev->nodename) + sizeof("/rate");
>  
> +	if (vif->credit_watch.node)
> +		return -EADDRINUSE;
> +
>  	node = kmalloc(maxlen, GFP_KERNEL);
>  	if (!node)
>  		return -ENOMEM;
> @@ -770,6 +773,7 @@ static void connect(struct backend_info *be)
>  	}
>  
>  	xen_net_read_rate(dev, &credit_bytes, &credit_usec);
> +	xen_unregister_watchers(be->vif);
>  	xen_register_watchers(dev, be->vif);
>  	read_xenbus_vif_flags(be);
>  
> -- 
> 1.7.9.5
