From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH net-next] net/core: initial support for stacked dev
 feature toggles
Date: Fri, 23 Oct 2015 22:51:09 -0700
Message-ID: <562B1C4D.8050407@gmail.com>
References: <1445658019-58621-1-git-send-email-jarod@redhat.com>
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
In-Reply-To: <1445658019-58621-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/23/2015 08:40 PM, Jarod Wilson wrote:
> There are some netdev features that make little sense to toggle on and
> off in a stacked device setup on only one device in the stack. The prime
> example is a bonded connection, where it really doesn't make sense to
> disable LRO on the master, but not on any of the slaves, nor does it
> really make sense to be able to shut LRO off on a slave when its still
> enabled on the master.
>
> The strategy here is to add a section near the end of
> netdev_fix_features() that looks for upper and lower netdevs, then make
> sure certain feature flags match both up and down the stack. At present,
> only the LRO flag is included.
>
> This has been successfully tested with bnx2x, qlcnic and netxen network
> cards as slaves in a bond interface. Turning LRO on or off on the master
> also turns it on or off on each of the slaves, new slaves are added with
> LRO in the same state as the master, and LRO can't be toggled on the
> slaves.
>
> Also, this should largely remove the need for dev_disable_lro(), and most,
> if not all, of its call sites can be replaced by simply making sure
> NETIF_F_LRO isn't included in the relevant device's feature flags.
>
> Note that this patch is driven by bug reports from users saying it was
> confusing that bonds and slaves had different settings for the same
> features, and while it won't be 100% in sync if a lower device doesn't
> support a feature like LRO, I think this is a good step in the right
> direction.
>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Eric Dumazet <edumazet@google.com>
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <gospo@cumulusnetworks.com>
> CC: Jiri Pirko <jiri@resnulli.us>
> CC: Nikolay Aleksandrov <razor@blackwall.org>
> CC: Michal Kubecek <mkubecek@suse.cz>
> CC: netdev@vger.kernel.org
> Signed-off-by: Jarod Wilson <jarod@redhat.com>
> ---
>   net/core/dev.c | 57 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>   1 file changed, 57 insertions(+)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 1225b4b..26f4e2d 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6261,9 +6261,57 @@ static void rollback_registered(struct net_device *dev)
>   	list_del(&single);
>   }
>
> +static netdev_features_t netdev_sync_upper_features(struct net_device *lower,
> +	struct net_device *upper, netdev_features_t features)
> +{
> +	netdev_features_t want = upper->wanted_features & lower->hw_features;
> +
> +	if (!(upper->wanted_features & NETIF_F_LRO)
> +	    && (features & NETIF_F_LRO)) {
> +		netdev_info(lower, "Dropping LRO, upper dev %s has it off.\n",
> +			   upper->name);
> +		features &= ~NETIF_F_LRO;
> +	} else if ((want & NETIF_F_LRO) && !(features & NETIF_F_LRO)) {
> +		netdev_info(lower, "Keeping LRO, upper dev %s has it on.\n",
> +			   upper->name);
> +		features |= NETIF_F_LRO;
> +	}
> +
> +	return features;
> +}
> +

I'd say to drop the second half of this statement.  LRO is a feature 
that should be enabled explicitly per interface.  If someone enables LRO 
on the master they may only want it on one interface.  The fact is there 
are some implementations of LRO that work better than others so you want 
to give the end user the option to mix and match.

> +static void netdev_sync_lower_features(struct net_device *upper,
> +	struct net_device *lower, netdev_features_t features)
> +{
> +	netdev_features_t want = features & lower->hw_features;
> +
> +	if (!(features & NETIF_F_LRO) && (lower->features & NETIF_F_LRO)) {
> +		netdev_info(upper, "Disabling LRO on lower dev %s.\n",
> +			   lower->name);
> +		upper->wanted_features &= ~NETIF_F_LRO;
> +		lower->wanted_features &= ~NETIF_F_LRO;
> +		netdev_update_features(lower);
> +		if (unlikely(lower->features & NETIF_F_LRO))
> +			netdev_WARN(upper, "failed to disable LRO on %s!\n",
> +				    lower->name);
> +	} else if ((want & NETIF_F_LRO) && !(lower->features & NETIF_F_LRO)) {
> +		netdev_info(upper, "Enabling LRO on lower dev %s.\n",
> +			   lower->name);
> +		upper->wanted_features |= NETIF_F_LRO;
> +		lower->wanted_features |= NETIF_F_LRO;
> +		netdev_update_features(lower);
> +		if (unlikely(!(lower->features & NETIF_F_LRO)))
> +			netdev_WARN(upper, "failed to enable LRO on %s!\n",
> +				    lower->name);
> +	}
> +}
> +

Same thing here.  If a lower dev has it disabled then leave it disabled. 
  I believe your goal is to make it so that dev_disable_lro() can shut 
down LRO when it is making packets in the data-path unusable.  There is 
no need to make this an all or nothing scenario.  We can let the stack 
slam things down with dev_disable_lro() and then if a user so desires 
they can come back through and enable LRO more selectively if they for 
instance have an interface that can do a smarter job of putting together 
frames that could be routed.

You could probably look at doing something like this for RXCSUM as well. 
  The general idea is that if an upper device has it off then the value 
has to be off.  For example if RXCSUM is off in a upper device and LRO 
is enabled on the lower device there is a good chance that the upper 
device will report checksum errors since most LRO implementations don't 
recalculate the checksum.  If RXCSUM is forced down to the lower device 
hopefully its fix_features will know this and disable LRO on that device 
when the RXCSUM is disabled on it.

>   static netdev_features_t netdev_fix_features(struct net_device *dev,
>   	netdev_features_t features)
>   {
> +	struct net_device *upper, *lower;
> +	struct list_head *iter;
> +
>   	/* Fix illegal checksum combinations */
>   	if ((features & NETIF_F_HW_CSUM) &&
>   	    (features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))) {
> @@ -6318,6 +6366,15 @@ static netdev_features_t netdev_fix_features(struct net_device *dev,
>   		}
>   	}
>
> +	/* some features should be kept in sync with upper devices */
> +	upper = netdev_master_upper_dev_get(dev);
> +	if (upper)
> +		features = netdev_sync_upper_features(dev, upper, features);
> +
> +	/* lower devices need some features altered to match upper devices */
> +	netdev_for_each_lower_dev(dev, lower, iter)
> +		netdev_sync_lower_features(dev, lower, features);
> +
>   #ifdef CONFIG_NET_RX_BUSY_POLL
>   	if (dev->netdev_ops->ndo_busy_poll)
>   		features |= NETIF_F_BUSY_POLL;
>
