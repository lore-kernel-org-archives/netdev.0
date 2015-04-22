From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH v2 1/3] mpls: Per-device MPLS state
Date: Wed, 22 Apr 2015 10:25:48 -0500
Message-ID: <877ft4mbgj.fsf@x220.int.ebiederm.org>
References: <1429648467-8449-1-git-send-email-rshearma@brocade.com>
	<1429697679-13767-1-git-send-email-rshearma@brocade.com>
	<1429697679-13767-2-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:44075 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756598AbbDVPaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 11:30:07 -0400
In-Reply-To: <1429697679-13767-2-git-send-email-rshearma@brocade.com> (Robert
	Shearman's message of "Wed, 22 Apr 2015 11:14:37 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> Add per-device MPLS state to supported interfaces. Use the presence of
> this state in mpls_route_add to determine that this is a supported
> interface.
>
> Use the presence of mpls_dev to drop packets that arrived on an
> unsupported interface - previously they were allowed through.

Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>

>
> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
>  include/linux/netdevice.h |  4 ++++
>  net/mpls/af_mpls.c        | 50 +++++++++++++++++++++++++++++++++++++++++++++--
>  net/mpls/internal.h       |  3 +++
>  3 files changed, 55 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index bcbde799ec69..dae106a3a998 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -60,6 +60,7 @@ struct phy_device;
>  struct wireless_dev;
>  /* 802.15.4 specific */
>  struct wpan_dev;
> +struct mpls_dev;
>  
>  void netdev_set_default_ethtool_ops(struct net_device *dev,
>  				    const struct ethtool_ops *ops);
> @@ -1627,6 +1628,9 @@ struct net_device {
>  	void			*ax25_ptr;
>  	struct wireless_dev	*ieee80211_ptr;
>  	struct wpan_dev		*ieee802154_ptr;
> +#if IS_ENABLED(CONFIG_MPLS_ROUTING)
> +	struct mpls_dev __rcu	*mpls_ptr;
> +#endif
>  
>  /*
>   * Cache lines mostly used on receive path (including eth_type_trans())
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index db8a2ea6d4de..ad45017eed99 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
> @@ -53,6 +53,11 @@ static struct mpls_route *mpls_route_input_rcu(struct net *net, unsigned index)
>  	return rt;
>  }
>  
> +static inline struct mpls_dev *mpls_dev_get(const struct net_device *dev)
> +{
> +	return rcu_dereference_rtnl(dev->mpls_ptr);
> +}
> +
>  static bool mpls_output_possible(const struct net_device *dev)
>  {
>  	return dev && (dev->flags & IFF_UP) && netif_carrier_ok(dev);
> @@ -136,6 +141,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
>  	struct mpls_route *rt;
>  	struct mpls_entry_decoded dec;
>  	struct net_device *out_dev;
> +	struct mpls_dev *mdev;
>  	unsigned int hh_len;
>  	unsigned int new_header_size;
>  	unsigned int mtu;
> @@ -143,6 +149,10 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
>  
>  	/* Careful this entire function runs inside of an rcu critical section */
>  
> +	mdev = mpls_dev_get(dev);
> +	if (!mdev)
> +		goto drop;
> +
>  	if (skb->pkt_type != PACKET_HOST)
>  		goto drop;
>  
> @@ -352,9 +362,9 @@ static int mpls_route_add(struct mpls_route_config *cfg)
>  	if (!dev)
>  		goto errout;
>  
> -	/* For now just support ethernet devices */
> +	/* Ensure this is a supported device */
>  	err = -EINVAL;
> -	if ((dev->type != ARPHRD_ETHER) && (dev->type != ARPHRD_LOOPBACK))
> +	if (!mpls_dev_get(dev))
>  		goto errout;
>  
>  	err = -EINVAL;
> @@ -428,10 +438,27 @@ errout:
>  	return err;
>  }
>  
> +static struct mpls_dev *mpls_add_dev(struct net_device *dev)
> +{
> +	struct mpls_dev *mdev;
> +	int err = -ENOMEM;
> +
> +	ASSERT_RTNL();
> +
> +	mdev = kzalloc(sizeof(*mdev), GFP_KERNEL);
> +	if (!mdev)
> +		return ERR_PTR(err);
> +
> +	rcu_assign_pointer(dev->mpls_ptr, mdev);
> +
> +	return mdev;
> +}
> +
>  static void mpls_ifdown(struct net_device *dev)
>  {
>  	struct mpls_route __rcu **platform_label;
>  	struct net *net = dev_net(dev);
> +	struct mpls_dev *mdev;
>  	unsigned index;
>  
>  	platform_label = rtnl_dereference(net->mpls.platform_label);
> @@ -443,14 +470,33 @@ static void mpls_ifdown(struct net_device *dev)
>  			continue;
>  		rt->rt_dev = NULL;
>  	}
> +
> +	mdev = mpls_dev_get(dev);
> +	if (!mdev)
> +		return;
> +
> +	RCU_INIT_POINTER(dev->mpls_ptr, NULL);
> +
> +	kfree(mdev);
>  }
>  
>  static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
>  			   void *ptr)
>  {
>  	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
> +	struct mpls_dev *mdev;
>  
>  	switch(event) {
> +	case NETDEV_REGISTER:
> +		/* For now just support ethernet devices */
> +		if ((dev->type == ARPHRD_ETHER) ||
> +		    (dev->type == ARPHRD_LOOPBACK)) {
> +			mdev = mpls_add_dev(dev);
> +			if (IS_ERR(mdev))
> +				return notifier_from_errno(PTR_ERR(mdev));
> +		}
> +		break;
> +
>  	case NETDEV_UNREGISTER:
>  		mpls_ifdown(dev);
>  		break;
> diff --git a/net/mpls/internal.h b/net/mpls/internal.h
> index fb6de92052c4..8090cb3099b4 100644
> --- a/net/mpls/internal.h
> +++ b/net/mpls/internal.h
> @@ -22,6 +22,9 @@ struct mpls_entry_decoded {
>  	u8 bos;
>  };
>  
> +struct mpls_dev {
> +};
> +
>  struct sk_buff;
>  
>  static inline struct mpls_shim_hdr *mpls_hdr(const struct sk_buff *skb)
