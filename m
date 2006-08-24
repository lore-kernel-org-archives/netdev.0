From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [RFC] add nl80211
Date: Thu, 24 Aug 2006 15:32:30 +0200
Message-ID: <20060824153230.5a54bb6a@griffin.suse.cz>
References: <1156254768.3825.1.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:21724 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1750752AbWHXNcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2006 09:32:33 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1156254768.3825.1.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Aug 2006 15:52:47 +0200, Johannes Berg wrote:
> [...]
> +	int	(*add_virtual_intf)(void *priv, char *name);

What about initial interface type? (Hm, maybe it can be fixed to a STA
mode, but it should be documented somewhere at least.)

> +	int	(*del_virtual_intf)(void *priv, int ifindex);
> +
> +	/* more things to be added...
> +	 *
> +	 * for a (*configure)(...) call I'd probably guess that the
> +	 * best bet would be to have one call that returns all
> +	 * possible options, one that sets them based on the
> +	 * struct genl_info *info, and one for that optimised
> +	 * set-at-once thing.
> +	 */
> +};
> +
> +/*
> + * register a given method structure with the nl80211 system
> + * and associate the 'priv' pointer with it.
> + * NOTE: for proper operation, this priv pointer MUST also be
> + * assigned to each &struct net_device's @ieee80211_ptr member!
> + */
> +extern int nl80211_register(struct nl80211_ops *ops, void *priv);

Could this function return the allocated wiphy index?

> [...]
> +struct nl80211_registered_driver {
> +	struct nl80211_ops *ops;
> +	int wiphy;
> +	void *priv;
> +	struct list_head list;
> +	/* we hold this mutex during any call so that
> +	 * we cannot do multiple calls at once, and also
> +	 * to avoid the deregister call to proceed while
> +	 * any call is in progress */
> +	struct mutex mtx;
> +};

Hm, most of drivers will need to take rtnl to stay compatible with WE.
(Not a reason to take rtnl in nl80211, just a remark.)

> [...]
> +static struct nl80211_registered_driver *nl80211_drv_by_priv_locked(void *priv)

Please use __ prefix instead of _locked suffix (e.g.
__nl80211_drv_by_priv). That's more common convention in the kernel.

> [...]
> +/* requires nl80211_drv_mutex to be held! */
> +static struct nl80211_registered_driver *
> +nl80211_drv_from_info_locked(struct genl_info *info)
> +{
> +	int ifindex;
> +	struct nl80211_registered_driver *result = NULL;
> +	struct net_device *dev;
> +	int err = -EINVAL;
> +
> +	if (info->attrs[NL80211_ATTR_WIPHY]) {
> +		result = nl80211_drv_by_wiphy_locked(
> +				nla_get_u32(info->attrs[NL80211_ATTR_WIPHY]));
> +		if (result)
> +			return result;
> +		err = -ENODEV;
> +	}
> +
> +	if (info->attrs[NL80211_ATTR_IFINDEX]) {
> +		ifindex = nla_get_u32(info->attrs[NL80211_ATTR_IFINDEX]);
> +		dev = dev_get_by_index(ifindex);
> +		result = nl80211_drv_by_priv_locked(dev->ieee80211_ptr);
> +		dev_put(dev);
> +		if (result)
> +			return result;
> +		err = -ENODEV;
> +	}

If both ifindex and wiphy index are set and they disagree with each
other, this should return an error.

> +
> +	return ERR_PTR(err);
> +}
> +
> [...]
> +static struct nl80211_registered_driver *
> +nl80211_drv_from_info_with_locking(struct genl_info *info)

nl80211_get_drv_from_info would be better. Also, introduce
a nl80211_put_drv function to ease tracking of locks.

> [...]
> +static int nl80211_dump_wiphys(struct sk_buff *skb, struct netlink_callback *cb)
> +{
> +	/* I think need professional netlink help with dumpit calls */

I'm not able to help you here :-(


Looks really good now, I think.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
