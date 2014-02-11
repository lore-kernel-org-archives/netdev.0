From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net,v2] hyperv: Fix the carrier status setting
Date: Tue, 11 Feb 2014 17:51:15 +0800
Message-ID: <52F9F293.7080601@redhat.com>
References: <1392056129-29398-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: driverdev-devel@linuxdriverproject.org, olaf@aepfle.de,
 linux-kernel@vger.kernel.org
To: Haiyang Zhang <haiyangz@microsoft.com>, davem@davemloft.net,
 netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1392056129-29398-1-git-send-email-haiyangz@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On 02/11/2014 02:15 AM, Haiyang Zhang wrote:
> Without this patch, the "cat /sys/class/net/ethN/operstate" shows
> "unknown", and "ethtool ethN" shows "Link detected: yes", when VM
> boots up with or without vNIC connected.
>
> This patch fixed the problem.
>
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> ---
>  drivers/net/hyperv/netvsc_drv.c |   24 +++++++++++++++---------
>  1 files changed, 15 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
> index 7756118..18916f7 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -88,8 +88,12 @@ static int netvsc_open(struct net_device *net)
>  {
>  	struct net_device_context *net_device_ctx = netdev_priv(net);
>  	struct hv_device *device_obj = net_device_ctx->device_ctx;
> +	struct netvsc_device *nvdev;
> +	struct rndis_device *rdev;
>  	int ret = 0;
>  
> +	netif_carrier_off(net);
> +
>  	/* Open up the device */
>  	ret = rndis_filter_open(device_obj);
>  	if (ret != 0) {
> @@ -99,6 +103,11 @@ static int netvsc_open(struct net_device *net)
>  
>  	netif_start_queue(net);
>  
> +	nvdev = hv_get_drvdata(device_obj);
> +	rdev = nvdev->extension;
> +	if (!rdev->link_state)

What if the link status interrupt comes here at this time?
> +		netif_carrier_on(net);
> +
>  	return ret;
>  }
>  
> @@ -229,15 +238,17 @@ void netvsc_linkstatus_callback(struct hv_device *device_obj,
>  	struct net_device *net;
>  	struct net_device_context *ndev_ctx;
>  	struct netvsc_device *net_device;
> +	struct rndis_device *rdev;
>  
>  	net_device = hv_get_drvdata(device_obj);
> +	rdev = net_device->extension;
> +
> +	rdev->link_state = status != 1;
> +
>  	net = net_device->ndev;
>  
> -	if (!net) {
> -		netdev_err(net, "got link status but net device "
> -				"not initialized yet\n");
> +	if (!net || net->reg_state != NETREG_REGISTERED)
>  		return;
> -	}
>  
>  	if (status == 1) {
>  		netif_carrier_on(net);
> @@ -414,9 +425,6 @@ static int netvsc_probe(struct hv_device *dev,
>  	if (!net)
>  		return -ENOMEM;
>  
> -	/* Set initial state */
> -	netif_carrier_off(net);
> -
>  	net_device_ctx = netdev_priv(net);
>  	net_device_ctx->device_ctx = dev;
>  	hv_set_drvdata(dev, net);
> @@ -443,8 +451,6 @@ static int netvsc_probe(struct hv_device *dev,
>  	}
>  	memcpy(net->dev_addr, device_info.mac_adr, ETH_ALEN);
>  
> -	netif_carrier_on(net);
> -
>  	ret = register_netdev(net);
>  	if (ret != 0) {
>  		pr_err("Unable to register netdev.\n");
