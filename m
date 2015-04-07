From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next v3 3/4] mpls: Per-device enabling of packet input
Date: Tue, 07 Apr 2015 12:02:37 -0500
Message-ID: <877ftnkh1u.fsf@x220.int.ebiederm.org>
References: <1426866170-28739-1-git-send-email-rshearma@brocade.com>
	<1427739356-28113-1-git-send-email-rshearma@brocade.com>
	<1427739356-28113-4-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:50023 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752891AbbDGRGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 13:06:41 -0400
In-Reply-To: <1427739356-28113-4-git-send-email-rshearma@brocade.com> (Robert
	Shearman's message of "Mon, 30 Mar 2015 19:15:55 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> An MPLS network is a single trust domain where the edges must be in
> control of what labels make their way into the core. The simplest way
> of ensuring for the edge device to always impose the labels, and not
> allow forward labeled traffic from untrusted neighbours. This is
> achieved by allowing a per-device configuration of whether MPLS
> traffic input from that interface should be processed or not.
>
> To be secure by default, MPLS is now intially disabled on all
> interfaces (except the loopback) until explicitly enabled and no
> global option is provided to change the default. Whilst this differs
> from other protocols (e.g. IPv6), network operators are used to
> explicitly enabling MPLS forwarding on interfaces, and with the number
> of links to the MPLS core typically fairly low this doesn't present
> too much of a burden on operators.

This really could use breaking up into two patches.

1 patch that implements mpls_add_dev,
and a second patch that uses the struct mpls_dev to implement
the input bit.

As it stands we are currently allowing mpls attributes on devices that
we do not support the transport of mpls over.  And simply not being able
to find an mpls_dev would be a faster was to discard packets on those
devices.

Naming the attribute input clears up all of the semantic issues that I
had with the previous version of this patch.

> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
>  Documentation/networking/mpls-sysctl.txt |   9 +++
>  include/linux/netdevice.h                |   4 ++
>  net/mpls/af_mpls.c                       | 115 ++++++++++++++++++++++++++++++-
>  net/mpls/internal.h                      |   6 ++
>  4 files changed, 133 insertions(+), 1 deletion(-)
>
> diff --git a/Documentation/networking/mpls-sysctl.txt b/Documentation/networking/mpls-sysctl.txt
> index 639ddf0ece9b..9ed15f86c17c 100644
> --- a/Documentation/networking/mpls-sysctl.txt
> +++ b/Documentation/networking/mpls-sysctl.txt
> @@ -18,3 +18,12 @@ platform_labels - INTEGER
>  
>  	Possible values: 0 - 1048575
>  	Default: 0
> +
> +conf/<interface>/input - BOOL
> +	Control whether packets can be input on this interface.
> +
> +	If disabled, packets will be discarded without further
> +	processing.
> +
> +	0 - disabled (default)
> +	not 0 - enabled
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 76951c5fbedf..ee4ca06375c8 100644
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
> @@ -1615,6 +1616,9 @@ struct net_device {
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
> index 7f5f30d29f73..0b0420bf110d 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
> @@ -54,6 +54,11 @@ static struct mpls_route *mpls_route_input_rcu(struct net *net, unsigned index)
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
> @@ -137,6 +142,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
>  	struct mpls_route *rt;
>  	struct mpls_entry_decoded dec;
>  	struct net_device *out_dev;
> +	struct mpls_dev *mdev;
>  	unsigned int hh_len;
>  	unsigned int new_header_size;
>  	unsigned int mtu;
> @@ -144,6 +150,10 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
>  
>  	/* Careful this entire function runs inside of an rcu critical section */
>  
> +	mdev = mpls_dev_get(dev);
> +	if (!mdev || !mdev->input_enabled)
> +		goto drop;
> +
>  	if (skb->pkt_type != PACKET_HOST)
>  		goto drop;
>  
> @@ -441,10 +451,96 @@ errout:
>  	return err;
>  }
>  
> +#define MPLS_PERDEV_SYSCTL_OFFSET(field)	\
> +	(&((struct mpls_dev *)0)->field)
> +
> +static const struct ctl_table mpls_dev_table[] = {
> +	{
> +		.procname	= "input",
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +		.data		= MPLS_PERDEV_SYSCTL_OFFSET(input_enabled),
> +	},
> +	{ }
> +};
> +
> +static int mpls_dev_sysctl_register(struct net_device *dev,
> +				    struct mpls_dev *mdev)
> +{
> +	char path[sizeof("net/mpls/conf/") + IFNAMSIZ];
> +	struct ctl_table *table;
> +	int i;
> +
> +	table = kmemdup(&mpls_dev_table, sizeof(mpls_dev_table), GFP_KERNEL);
> +	if (!table)
> +		goto out;
> +
> +	/* Table data contains only offsets relative to the base of
> +	 * the mdev at this point, so make them absolute.
> +	 */
> +	for (i = 0; i < ARRAY_SIZE(mpls_dev_table); i++)
> +		table[i].data = (char *)mdev + (uintptr_t)table[i].data;
> +
> +	snprintf(path, sizeof(path), "net/mpls/conf/%s", dev->name);
> +
> +	mdev->sysctl = register_net_sysctl(dev_net(dev), path, table);
> +	if (!mdev->sysctl)
> +		goto free;
> +
> +	return 0;
> +
> +free:
> +	kfree(table);
> +out:
> +	return -ENOBUFS;
> +}
> +
> +static void mpls_dev_sysctl_unregister(struct mpls_dev *mdev)
> +{
> +	struct ctl_table *table;
> +
> +	table = mdev->sysctl->ctl_table_arg;
> +	unregister_net_sysctl_table(mdev->sysctl);
> +	kfree(table);
> +}
> +
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
> +	/* Enable MPLS by default on loopback devices, since this
> +	 * doesn't represent a security boundary and is required for the
> +	 * lookup of inner labels for LSPs terminating on this router.
> +	 */
> +	if (dev->flags & IFF_LOOPBACK)
> +		mdev->input_enabled = 1;
> +
> +	err = mpls_dev_sysctl_register(dev, mdev);
> +	if (err)
> +		goto free;
> +
> +	rcu_assign_pointer(dev->mpls_ptr, mdev);
> +
> +	return mdev;
> +
> +free:
> +	kfree(mdev);
> +	return ERR_PTR(err);
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
> @@ -456,14 +552,31 @@ static void mpls_ifdown(struct net_device *dev)
>  			continue;
>  		rt->rt_dev = NULL;
>  	}
> +
> +	mdev = mpls_dev_get(dev);
> +	if (!mdev)
> +		return;
> +
> +	mpls_dev_sysctl_unregister(mdev);
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
> +		mdev = mpls_add_dev(dev);
> +		if (IS_ERR(mdev))
> +			return notifier_from_errno(PTR_ERR(mdev));
> +		break;
> +
>  	case NETDEV_UNREGISTER:
>  		mpls_ifdown(dev);
>  		break;
> @@ -925,7 +1038,7 @@ static int mpls_platform_labels(struct ctl_table *table, int write,
>  	return ret;
>  }
>  
> -static struct ctl_table mpls_table[] = {
> +static const struct ctl_table mpls_table[] = {
>  	{
>  		.procname	= "platform_labels",
>  		.data		= NULL,
> diff --git a/net/mpls/internal.h b/net/mpls/internal.h
> index 5732283ee1b9..d0aad5e9a2c9 100644
> --- a/net/mpls/internal.h
> +++ b/net/mpls/internal.h
> @@ -23,6 +23,12 @@ struct mpls_entry_decoded {
>  	u8 bos;
>  };
>  
> +struct mpls_dev {
> +	int			input_enabled;
> +
> +	struct ctl_table_header *sysctl;
> +};
> +
>  struct sk_buff;
>  
>  static inline struct mpls_shim_hdr *mpls_hdr(const struct sk_buff *skb)
