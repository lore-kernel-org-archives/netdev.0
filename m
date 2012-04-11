From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next PATCH v1 1/7] net: add generic PF_BRIDGE:RTM_ FDB
 hooks
Date: Wed, 11 Apr 2012 04:23:19 +0100
Message-ID: <1334114599.7150.361.camel@deadeye>
References: <20120409215419.3288.50790.stgit@jf-dev1-dcblab>
	 <20120409220017.3288.13746.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <roprabhu@cisco.com>, <mst@redhat.com>,
	<stephen.hemminger@vyatta.com>, <davem@davemloft.net>,
	<hadi@cyberus.ca>, <jeffrey.t.kirsher@intel.com>,
	<netdev@vger.kernel.org>, <gregory.v.rose@intel.com>,
	<krkumar2@in.ibm.com>, <sri@us.ibm.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:46523 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760026Ab2DKDX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 23:23:26 -0400
In-Reply-To: <20120409220017.3288.13746.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-09 at 15:00 -0700, John Fastabend wrote:
[...]
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 1f77540..05822e5 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
[...]
> @@ -905,6 +906,19 @@ struct netdev_fcoe_hbainfo {
>   *	feature set might be less than what was returned by ndo_fix_features()).
>   *	Must return >0 or -errno if it changed dev->features itself.
>   *
> + * int (*ndo_fdb_add)(struct ndmsg *ndm, struct net_device *dev,
> + *		      unsigned char *addr, u16 flags)
> + *	Adds an FDB entry to dev for addr. The ndmsg contains flags to indicate
> + *	if the dev->master FDB should be updated or the devices internal FDB.

I don't think the second sentence is helpful, as rtnl_fdb_add() will
take care of those flags.

> + * int (*ndo_fdb_del)(struct ndmsg *ndm, struct net_device *dev,
> + *		      unsigned char *addr)
> + *	Deletes the FDB entry from dev coresponding to addr. The ndmsg
> + *	contains flags to indicate if the dev->master FDB should be
> + *	updated or the devices internal FDB.

Similarly here.

> + * int (*ndo_fdb_dump)(struct sk_buff *skb, struct netlink_callback *cb,
> + *		       struct net_device *dev, int idx)
> + *	Used to add FDB entries to dump requests. Implementers should add
> + *	entries to skb and update idx with the number of entries.
>   */
[...
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
[...]
> +static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
> +{
[...]
> +	err = -EOPNOTSUPP;

So if NTF_MASTER and NTF_SELF are both set, we can quietly fall back to
just setting one FDB?  Not sure that's really desirable though 

> +	/* Support fdb on master device the net/bridge default case */
> +	if ((!ndm->ndm_flags || ndm->ndm_flags & NTF_MASTER) &&
> +	    (dev->priv_flags & IFF_BRIDGE_PORT)) {
> +		struct net_device *master = dev->master;
> +
> +		if (master->netdev_ops->ndo_fdb_add)

This operation is surely going to be mandatory for bridge devices, so
this check should be omitted or changed to a BUG_ON().

> +			err = master->netdev_ops->ndo_fdb_add(ndm, dev, addr,
> +							      nlh->nlmsg_flags);

Shoudn't we return early on error?

> +	}
> +
> +	/* Embedded bridge, macvlan, and any other device support */
> +	if ((ndm->ndm_flags & NTF_SELF) &&
> +	    dev->netdev_ops->ndo_fdb_add)

Error if !dev->netdev_ops->ndo_fdb_add.

> +		err = dev->netdev_ops->ndo_fdb_add(ndm, dev, addr,
> +						   nlh->nlmsg_flags);

Wonder what we should do on error here if we've already successfully
called ndo_fdb_add on the master?  Should we try to roll back the first
addition?

> +	return err;
> +}
> +
> +static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
> +{
[...]
> +	err = -EOPNOTSUPP;
> +
> +	/* Support fdb on master device the net/bridge default case */
> +	if ((!ndm->ndm_flags || ndm->ndm_flags & NTF_MASTER) &&
> +	    (dev->priv_flags & IFF_BRIDGE_PORT)) {
> +		struct net_device *master = dev->master;
> +
> +		if (master->netdev_ops->ndo_fdb_del)
> +			err = master->netdev_ops->ndo_fdb_del(ndm, dev, addr);
> +	}
> +
> +	/* Embedded bridge, macvlan, and any other device support */
> +	if ((ndm->ndm_flags & NTF_SELF) &&
> +	    dev->netdev_ops->ndo_fdb_del)
> +		err = dev->netdev_ops->ndo_fdb_del(ndm, dev, addr);
> +	return err;
> +}
[...]

This has the same issues.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
