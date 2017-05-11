From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] mdio: mux: Correct mdio_mux_init error path issues
Date: Thu, 11 May 2017 10:05:27 -0700
Message-ID: <d4126200-c1c1-1adc-120d-5fa55bf28ce5@gmail.com>
References: <1494429627-5527-1-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com, andrew@lunn.ch
To: Jon Mason <jon.mason@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1494429627-5527-1-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/10/2017 08:20 AM, Jon Mason wrote:
> There is a potential unnecessary refcount decriment on error path of
> put_device(&pb->mii_bus->dev), as it is possible to avoid the
> of_mdio_find_bus() call if mux_bus is specified by the calling function.
> 
> The same put_device() is not called in the error path if the
> devm_kzalloc of pb fails.  This caused the variable used in the
> put_device() to be changed, as the pb pointer was obviously not set up.
> 
> There is an unnecessary of_node_get() on child_bus_node if the
> of_mdiobus_register() is successful, as the
> for_each_available_child_of_node() automatically increments this.
> Thus the refcount on this node will always be +1 more than it should be.
> 
> There is no of_node_put() on child_bus_node if the of_mdiobus_register()
> call fails.
> 
> Finally, it is lacking devm_kfree() of pb in the error path.  While this
> might not be technically necessary, it was present in other parts of the
> function.  So, I am adding it where necessary to make it uniform.
> 
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> Fixes: f20e6657a875 ("mdio: mux: Enhanced MDIO mux framework for integrated multiplexers")
> Fixes: 0ca2997d1452 ("netdev/of/phy: Add MDIO bus multiplexer support.")

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Please include "net" in the subject for future submissions, thanks!

> ---
>  drivers/net/phy/mdio-mux.c | 12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/phy/mdio-mux.c b/drivers/net/phy/mdio-mux.c
> index 963838d4fac1..6943c5ece44a 100644
> --- a/drivers/net/phy/mdio-mux.c
> +++ b/drivers/net/phy/mdio-mux.c
> @@ -122,10 +122,9 @@ int mdio_mux_init(struct device *dev,
>  	pb = devm_kzalloc(dev, sizeof(*pb), GFP_KERNEL);
>  	if (pb == NULL) {
>  		ret_val = -ENOMEM;
> -		goto err_parent_bus;
> +		goto err_pb_kz;
>  	}
>  
> -
>  	pb->switch_data = data;
>  	pb->switch_fn = switch_fn;
>  	pb->current_child = -1;
> @@ -154,6 +153,7 @@ int mdio_mux_init(struct device *dev,
>  		cb->mii_bus = mdiobus_alloc();
>  		if (!cb->mii_bus) {
>  			ret_val = -ENOMEM;
> +			devm_kfree(dev, cb);
>  			of_node_put(child_bus_node);
>  			break;
>  		}
> @@ -169,8 +169,8 @@ int mdio_mux_init(struct device *dev,
>  		if (r) {
>  			mdiobus_free(cb->mii_bus);
>  			devm_kfree(dev, cb);
> +			of_node_put(child_bus_node);
>  		} else {
> -			of_node_get(child_bus_node);
>  			cb->next = pb->children;
>  			pb->children = cb;
>  		}
> @@ -181,9 +181,11 @@ int mdio_mux_init(struct device *dev,
>  		return 0;
>  	}
>  
> +	devm_kfree(dev, pb);
> +err_pb_kz:
>  	/* balance the reference of_mdio_find_bus() took */
> -	put_device(&pb->mii_bus->dev);
> -
> +	if (!mux_bus)
> +		put_device(&parent_bus->dev);
>  err_parent_bus:
>  	of_node_put(parent_bus_node);
>  	return ret_val;
> 


-- 
Florian
