From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH 02/11] IB/ipoib: Return IPoIB devices matching connection
 parameters
Date: Mon, 15 Jun 2015 11:22:10 -0600
Message-ID: <20150615172210.GB14982@obsidianresearch.com>
References: <1434358036-15526-1-git-send-email-haggaie@mellanox.com>
 <1434358036-15526-3-git-send-email-haggaie@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1434358036-15526-3-git-send-email-haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 15, 2015 at 11:47:07AM +0300, Haggai Eran wrote:

> +/* Called with an RCU read lock taken */

Add _rcu to the name? That is the standard convention.

> +/* returns an IPoIB netdev on top a given ipoib device matching a pkey_index
> + * and address, if one exists. */
> +static struct net_device *ipoib_match_gid_pkey_addr(struct ipoib_dev_priv *priv,
> +						    const union ib_gid *gid,
> +						    u16 pkey_index,
> +						    const struct sockaddr *addr)
> +{
> +	struct ipoib_dev_priv *child_priv;
> +	struct net_device *net_dev = NULL;
> +
> +	if (priv->pkey_index == pkey_index &&
> +	    (!gid || !memcmp(gid, &priv->local_gid, sizeof(*gid)))) {
> +		net_dev = ipoib_get_net_dev_match_addr(addr, priv->dev);
> +		if (net_dev)
> +			return net_dev;

As I said already, this should not even look at the sockaddr unless
there are multiple possible hits on the other parameters, and there
should be a comment explaining the sockaddr is only a hack to make up
for having an incomplete LLADDR.

That way people not using same guid children do not get incorrect
functionality..

> +static struct net_device *ipoib_get_net_dev_by_params(
> +		struct ib_device *dev, u8 port, u16 pkey,
> +		const union ib_gid *gid, const struct sockaddr *addr)

[..]

> +	ret = ib_find_cached_pkey(dev, port, pkey, &pkey_index);
> +	if (ret)
> +		return NULL;
> +
> +	if (!rdma_protocol_ib(dev, port))
> +		return NULL;

This if should be first I'd think.


> +	dev_list = ib_get_client_data(dev, &ipoib_client);
> +	if (!dev_list)
> +		return NULL;

Is the locking OK here? This access protected by lists_rwsem -
but for instance ib_unregister_device holds only the device_mutex when
calling client->remove, which kfree's dev_list. Looks wrong to me.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
