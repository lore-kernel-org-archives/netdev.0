From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH] net: xen-netback: correctly restart Tx
 after a VM restore/migrate
Date: Fri, 30 Sep 2011 17:45:05 +0100
Message-ID: <1317401105.26672.319.camel@zakaz.uk.xensource.com>
References: <1317400671-21236-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"David S. Miller" <davem@davemloft.net>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <1317400671-21236-1-git-send-email-david.vrabel@citrix.com>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On Fri, 2011-09-30 at 17:37 +0100, David Vrabel wrote:
> If a VM is saved and restored (or migrated) the netback driver will no
> longer process any Tx packets from the frontend.  xenvif_up() does not
> schedule the processing of any pending Tx requests from the front end
> because the carrier is off.  Without this initial kick the frontend
> just adds Tx requests to the ring without raising an event (until the
> ring is full).
> 
> This was caused by 47103041e91794acdbc6165da0ae288d844c820b (net:
> xen-netback: convert to hw_features) which reordered the calls to
> xenvif_up() and netif_carrier_on() in xenvif_connect().

Ah, so the bit of that patch which moved "netif_carrier_on(vif->dev);"
should have actually moved the entire block
 	netif_carrier_on(vif->dev);
	if (netif_running(vif->dev))
		xenvif_up(vif);

Since it it is logically a single thing. Make sense. Thanks!

> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Acked-by: Ian Campbell <ian.campbell@citrix.com>

Ian.

> ---
>  drivers/net/xen-netback/interface.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index 0ca86f9..1825629 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -327,12 +327,12 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
>  	xenvif_get(vif);
>  
>  	rtnl_lock();
> -	if (netif_running(vif->dev))
> -		xenvif_up(vif);
>  	if (!vif->can_sg && vif->dev->mtu > ETH_DATA_LEN)
>  		dev_set_mtu(vif->dev, ETH_DATA_LEN);
>  	netdev_update_features(vif->dev);
>  	netif_carrier_on(vif->dev);
> +	if (netif_running(vif->dev))
> +		xenvif_up(vif);
>  	rtnl_unlock();
>  
>  	return 0;
