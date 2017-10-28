From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: Use common error handling code in vxcan_newlink()
Date: Sat, 28 Oct 2017 08:48:16 +0200
Message-ID: <2ab5d794-7a5c-9036-835c-67cfcc541795@hartkopp.net>
References: <2e600d9a-faec-dd39-08f0-5a7fb260d7ca@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <2e600d9a-faec-dd39-08f0-5a7fb260d7ca@users.sourceforge.net>
Content-Language: en-US
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Markus,

On 10/27/2017 10:30 PM, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Fri, 27 Oct 2017 22:22:24 +0200
> 
> * Add a jump target so that a bit of exception handling can be better
>    reused at the end of this function.
> 
> * Adjust two condition checks.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>   drivers/net/can/vxcan.c | 16 ++++++++--------
>   1 file changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/can/vxcan.c b/drivers/net/can/vxcan.c
> index 8404e8852a0f..97f250cbc4ff 100644
> --- a/drivers/net/can/vxcan.c
> +++ b/drivers/net/can/vxcan.c
> @@ -227,10 +227,8 @@ static int vxcan_newlink(struct net *net, struct net_device *dev,
>   	netif_carrier_off(peer);
>   
>   	err = rtnl_configure_link(peer, ifmp);
> -	if (err < 0) {
> -		unregister_netdevice(peer);
> -		return err;
> -	}
> +	if (err)
> +		goto unregister_network_device;

You are changing semantic in the if-statement here.

I would be fine with the patch if you revert that if-statement as I 
would like to stay on the behavior from veth.c in veth_newlink().

Regards,
Oliver

>   
>   	/* register first device */
>   	if (tb[IFLA_IFNAME])
> @@ -239,10 +237,8 @@ static int vxcan_newlink(struct net *net, struct net_device *dev,
>   		snprintf(dev->name, IFNAMSIZ, DRV_NAME "%%d");
>   
>   	err = register_netdevice(dev);
> -	if (err < 0) {
> -		unregister_netdevice(peer);
> -		return err;
> -	}
> +	if (err)
> +		goto unregister_network_device;
>   
>   	netif_carrier_off(dev);
>   
> @@ -254,6 +250,10 @@ static int vxcan_newlink(struct net *net, struct net_device *dev,
>   	rcu_assign_pointer(priv->peer, dev);
>   
>   	return 0;
> +
> +unregister_network_device:
> +	unregister_netdevice(peer);
> +	return err;
>   }
>   
>   static void vxcan_dellink(struct net_device *dev, struct list_head *head)
> 
