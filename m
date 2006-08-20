From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [RFC] nl80211 + packet injection with it and d80211
Date: Sun, 20 Aug 2006 20:47:09 +0200
Message-ID: <20060820204709.2f46d8c8@logostar.upir.cz>
References: <1155824008.3491.7.camel@ux156>
	<1155912565.5671.1.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from r2u241.net.upc.cz ([62.245.84.241]:12708 "EHLO cela.cz")
	by vger.kernel.org with ESMTP id S1751144AbWHTSrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2006 14:47:19 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1155912565.5671.1.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes,

thanks a lot for your work on nl80211! New netlink interface is
one of the most important things regarding 802.11 stack now.

Fri, 18 Aug 2006 16:49:25 +0200, Johannes Berg wrote:
> [...]
> +/**
> + * struct nl80211_driver - backend description for wireless configuration
> + *
> + * This struct is registered by fullmac card drivers and/or wireless stacks
> + * in order to handle configuration requests on their interfaces.
> + *
> + * @get_priv_for_ifindex: return the private pointer that is then passed to
> + *			  the other calls as the first argument.
> + *			  Note that if this returns %NULL, then it is assumed
> + *			  that the driver doesn't handle that interface,
> + *			  hence priv is unused for some reason it still needs
> + *			  to return a non-%NULL pointer!
> + *
> + * @release_priv: release the private pointer if necessary. Note that for
> + *		  example if you used the ifindex and dev_get_by_index(),
> + *		  you have to dev_put() here.

Seems ineffective to me. Couldn't you require users of nl80211 to fill
ieee80211_ptr field in all of their net_devices and use that to find out
owner of the device? Then you don't need to call into every registered
nl80211 user for each message.

> + *
> + * @inject_packet: inject the given frame with the NL80211_FLAG_*
> + *		   flags onto the given queue.
> + */
> +struct nl80211_driver {
> +	void*	(*get_priv_for_ifindex)(int ifindex);
> +	void	(*release_priv)(void *priv);

Maybe put_priv would be better name for release_priv?

> [...]
> +static int nl80211_drvpriv_by_ifidx(int ifindex, void **priv, struct nl80211_driver **drv)

Cut long lines, please.

> [...]
> +static int nl80211_get_commands(struct sk_buff *skb, struct genl_info *info)
> [...]
> +
> +	/* unconditionally allow NL80211_CMD_GET_COMMANDS */
> +	skb_put(skb, 1);

Shouldn't this be skb_put(msg, 1)? And in several other cases below too?

> +	*data++ = NL80211_CMD_GET_COMMANDS;
> +
> +#define CHECK_CMD(ptr, cmd)			\
> +	if (drv->ptr) {				\
> +		skb_put(skb, 1);		\
> +		*data++ = NL80211_CMD_##cmd;	\
> +	}

Could you move this define out of the function?

> +
> +	CHECK_CMD(inject_packet, INJECT);
> +
> +	nla_nest_end(msg, start);
> +
> +	err = genlmsg_end(msg, hdr);
> +	if (err)
> +		goto msg_free;
> +
> +	err = genlmsg_unicast(msg, info->snd_pid);
> +	goto release;
> +
> + nla_put_failure:
> +	err = genlmsg_cancel(skb, hdr);
> + msg_free:
> +	nlmsg_free(skb);
> + release:
> +	if (drv->release_priv)
> +		drv->release_priv(priv);

If get_priv_for_ifindex turns out to be really necessary, please rename
nl80211_drvpriv_from_info to nl80211_get_drvpriv_from_info and introduce
a new nl80211_put_drvpriv function (so it's immediately clear that returned
pointers need some releasing):

void nl80211_put_drvpriv(struct nl80211_driver *drv, void *priv)
{
        if (drv->release_priv)
                drv->release_priv(priv);
}

And rename nl80211_drvpriv_by_ifidx to nl80211_get_drvpriv_by_ifidx, too.

> [...]
> +void nl80211_register_driver(struct nl80211_driver *drv)
> +{
> +	mutex_lock(&nl80211_drv_mutex);
> +	list_add(&drv->driver_list, &nl80211_drv_list);
> +	mutex_unlock(&nl80211_drv_mutex);
> +}

Don't modify passed nl80211_driver. This way drivers cannot pass a static
structure. Allocate you own structure and store a pointer to passed
nl80211_driver there (or copy it into that your structure if you don't like
dereferencing two pointers when calling callbacks).

> [...]
> +void *nl80211hdr_put(struct sk_buff *skb, u32 pid, u32 seq, int flags, u8 cmd)
> +{
> +	/* since there is no private header just add the generic one */
> +	return genlmsg_put(skb, pid, seq, nl80211_fam.id, 0,
> +			   flags, cmd, nl80211_fam.version);
> +}
> +EXPORT_SYMBOL_GPL(nl80211hdr_put);

Why is this exported? It should be used by nl80211msg_new only, shouldn't
it?

> [...]
> +/* currently supported attributes.
> + * don't change the order or add anything inbetween, this is ABI! */
> +enum {
> +	NL80211_ATTR_UNSPEC,
> +
> +	/* network device (ifindex) to operate on */
> +	NL80211_ATTR_IFINDEX,

Currently, master device is represented by a special net_device in d80211.
It's not nice, "wiphy" device should be represented in some other way.
Although I don't expect this would change (at least not in a foreseeable
future) as it would require rewriting of great part of networking core, we
should be prepared for it, so we would not be forced to change ABI or
inventing workarounds if that eventually would happen.

Also, d80211 allows some operations even without having any network
interface present (of course, master interface is still present, but it's
not nice to use its ifindex, especially in the light of previous paragraph).

I propose this:
- add NL80211_ATTR_WIPHY_INDEX attributte
- add wiphy_index field to nl80211_driver and require non-d80211 users to
  set it to -1
- allow NL80211_ATTR_IFINDEX to be optional in some calls - the exact list
  of these calls is independent of any driver and can be hardcoded in
  nl80211
- in such calls, specifying either NL80211_ATTR_IFINDEX or
  NL80211_ATTR_WIPHY_INDEX is enough; of course, when corresponding driver
  does not support wiphys (i.e. nl80211_driver.wiphy_index is -1), only
  NL80211_ATTR_IFINDEX can be specified
- in other calls, NL80211_ATTR_WIPHY_INDEX should not be present

Alternatively, you could introduce a flag to denote if NL80211_ATTR_IFINDEX
field contains ifindex or wiphy index.


Comments to the d80211 part later (probably on Tuesday).

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
