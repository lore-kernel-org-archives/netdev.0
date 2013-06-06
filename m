From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next PATCH 4/8] macvtap: introduce macvtap_get_vlan()
Date: Thu, 6 Jun 2013 14:05:15 +0300
Message-ID: <20130606110515.GC8626@redhat.com>
References: <1370512480-14272-1-git-send-email-jasowang@redhat.com>
 <1370512480-14272-5-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sergei.shtylyov@cogentembedded.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1370512480-14272-5-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 06, 2013 at 05:54:36PM +0800, Jason Wang wrote:
> Factor out the device holding logic to a macvtap_get_vlan(), this will be also
> used by multiqueue API.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/macvtap.c |   27 ++++++++++++++++++++-------
>  1 files changed, 20 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 8949631..d18130b 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -893,6 +893,24 @@ out:
>  	return ret;
>  }
>  
> +static struct macvlan_dev *macvtap_get_vlan(struct macvtap_queue *q)
> +{
> +	struct macvlan_dev *vlan;
> +
> +	rcu_read_lock_bh();
> +	vlan = rcu_dereference_bh(q->vlan);
> +	if (vlan)
> +		dev_hold(vlan->dev);
> +	rcu_read_unlock_bh();
> +
> +	return vlan;
> +}
> +
> +static void macvtap_put_vlan(struct macvlan_dev *vlan)
> +{
> +	dev_put(vlan->dev);
> +}
> +
>  /*
>   * provide compatibility with generic tun/tap interface
>   */
> @@ -924,12 +942,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
>  		return ret;
>  
>  	case TUNGETIFF:
> -		rcu_read_lock_bh();
> -		vlan = rcu_dereference_bh(q->vlan);
> -		if (vlan)
> -			dev_hold(vlan->dev);
> -		rcu_read_unlock_bh();
> -
> +		vlan = macvtap_get_vlan(q);
>  		if (!vlan)
>  			return -ENOLINK;
>  
> @@ -937,7 +950,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
>  		if (copy_to_user(&ifr->ifr_name, vlan->dev->name, IFNAMSIZ) ||
>  		    put_user(q->flags, &ifr->ifr_flags))
>  			ret = -EFAULT;
> -		dev_put(vlan->dev);
> +		macvtap_put_vlan(vlan);
>  		return ret;
>  
>  	case TUNGETFEATURES:
> -- 
> 1.7.1
