From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next] net/core: ensure features get disabled on new
 lower devs
Date: Tue, 3 Nov 2015 13:17:17 -0800
Message-ID: <5639245D.7000501@gmail.com>
References: <1446519359-21400-1-git-send-email-jarod@redhat.com>
 <1446583017-19021-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Michal Kubecek <mkubecek@suse.cz>, netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446583017-19021-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/03/2015 12:36 PM, Jarod Wilson wrote:
> With moving netdev_sync_lower_features() after the .ndo_set_features
> calls, I neglected to verify that devices added *after* a flag had been
> disabled on an upper device were properly added with that flag disabled as
> well. This currently happens, because we exit __netdev_update_features()
> when we see dev->features == features for the upper dev. We can retain the
> optimization of leaving without calling .ndo_set_features with a bit of
> tweaking and a goto here.
>
> Changing err to ret was somewhat arbitrary and makes the patch look more
> involved, but seems to better fit the altered use.
>
> Fixes: fd867d51f ("net/core: generic support for disabling netdev features down stack")
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Eric Dumazet <edumazet@google.com>
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <gospo@cumulusnetworks.com>
> CC: Jiri Pirko <jiri@resnulli.us>
> CC: Nikolay Aleksandrov <razor@blackwall.org>
> CC: Michal Kubecek <mkubecek@suse.cz>
> CC: Alexander Duyck <alexander.duyck@gmail.com>
> CC: netdev@vger.kernel.org
> Signed-off-by: Jarod Wilson <jarod@redhat.com>
> ---
>   net/core/dev.c | 21 ++++++++++++---------
>   1 file changed, 12 insertions(+), 9 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 8ce3f74..90e0a62 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6402,7 +6402,7 @@ int __netdev_update_features(struct net_device *dev)
>   	struct net_device *upper, *lower;
>   	netdev_features_t features;
>   	struct list_head *iter;
> -	int err = 0;
> +	int ret = 0;
>
>   	ASSERT_RTNL();
>
> @@ -6419,31 +6419,34 @@ int __netdev_update_features(struct net_device *dev)
>   		features = netdev_sync_upper_features(dev, upper, features);
>
>   	if (dev->features == features)
> -		return 0;
> +		goto sync_lower;
>
>   	netdev_dbg(dev, "Features changed: %pNF -> %pNF\n",
>   		&dev->features, &features);
>
>   	if (dev->netdev_ops->ndo_set_features)
> -		err = dev->netdev_ops->ndo_set_features(dev, features);
> +		ret = dev->netdev_ops->ndo_set_features(dev, features);
>
> -	if (unlikely(err < 0)) {
> +	if (unlikely(ret < 0)) {
>   		netdev_err(dev,
>   			"set_features() failed (%d); wanted %pNF, left %pNF\n",
> -			err, &features, &dev->features);
> +			ret, &features, &dev->features);
>   		return -1;
>   	}
>
> +	if (!ret) {
> +		dev->features = features;
> +		ret = 1;
> +	}
> +

I would take the "ret = 1;" out of the if statement and let it stay here 
by itself.  Technically anything that traversed this path was returning 
1 previously so we probably want to retain that behavior.

> +sync_lower:
>   	/* some features must be disabled on lower devices when disabled
>   	 * on an upper device (think: bonding master or bridge)
>   	 */
>   	netdev_for_each_lower_dev(dev, lower, iter)
>   		netdev_sync_lower_features(dev, lower, features);
>
> -	if (!err)
> -		dev->features = features;

You could just alter the if statement here to check for a non-zero ret 
value since you should have it as either 0 or 1.  It shouldn't have any 
other values.

That way you will have disabled the feature on the lower devices before 
advertising that it has been disabled on the upper device.

> -	return 1;
> +	return ret;
>   }
>
>   /**
>
