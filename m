From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] nl80211 + packet injection with it and d80211
Date: Mon, 21 Aug 2006 08:43:28 +0200
Message-ID: <1156142608.3669.9.camel@ux156>
References: <1155824008.3491.7.camel@ux156> <1155912565.5671.1.camel@ux156>
	 <20060820204709.2f46d8c8@logostar.upir.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:5764 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S964993AbWHUGnR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 02:43:17 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060820204709.2f46d8c8@logostar.upir.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri,

> thanks a lot for your work on nl80211! New netlink interface is
> one of the most important things regarding 802.11 stack now.

Wait till you see my weekend patch series ;)

> Seems ineffective to me. Couldn't you require users of nl80211 to fill
> ieee80211_ptr field in all of their net_devices and use that to find out
> owner of the device? Then you don't need to call into every registered
> nl80211 user for each message.

What about non-d80211 fullmac drivers?

> Maybe put_priv would be better name for release_priv?

Yeah, ok.

> > [...]
> > +static int nl80211_drvpriv_by_ifidx(int ifindex, void **priv, struct nl80211_driver **drv)
> 
> Cut long lines, please.

Oops.

> > +	/* unconditionally allow NL80211_CMD_GET_COMMANDS */
> > +	skb_put(skb, 1);
> 
> Shouldn't this be skb_put(msg, 1)? And in several other cases below too?

Woah, yes. I really should've tested that code as well.

> > +#define CHECK_CMD(ptr, cmd)			\
> > +	if (drv->ptr) {				\
> > +		skb_put(skb, 1);		\
> > +		*data++ = NL80211_CMD_##cmd;	\
> > +	}
> 
> Could you move this define out of the function?

Sure. I'll also undef it afterwards.

> void nl80211_put_drvpriv(struct nl80211_driver *drv, void *priv)
> {
>         if (drv->release_priv)
>                 drv->release_priv(priv);
> }
> 
> And rename nl80211_drvpriv_by_ifidx to nl80211_get_drvpriv_by_ifidx, too.

Sure.

> Don't modify passed nl80211_driver. This way drivers cannot pass a static
> structure. Allocate you own structure and store a pointer to passed
> nl80211_driver there (or copy it into that your structure if you don't like
> dereferencing two pointers when calling callbacks).

Hmm, ok. I don't really like that too much either, but yeah, probably a
good idea. OTOH, if we make a copy anyway we could just as well require
drivers to make a copy, no? (And allocating just 12 bytes for three
pointers for the linked list feels stupid)

> > [...]
> > +void *nl80211hdr_put(struct sk_buff *skb, u32 pid, u32 seq, int flags, u8 cmd)
> > +{
> > +	/* since there is no private header just add the generic one */
> > +	return genlmsg_put(skb, pid, seq, nl80211_fam.id, 0,
> > +			   flags, cmd, nl80211_fam.version);
> > +}
> > +EXPORT_SYMBOL_GPL(nl80211hdr_put);
> 
> Why is this exported? It should be used by nl80211msg_new only, shouldn't
> it?

No, for dumpit() callbacks you need this. Not sure if we'll ever have
any of those, but...

> Currently, master device is represented by a special net_device in d80211.
> It's not nice, "wiphy" device should be represented in some other way.
> Although I don't expect this would change (at least not in a foreseeable
> future) as it would require rewriting of great part of networking core, we
> should be prepared for it, so we would not be forced to change ABI or
> inventing workarounds if that eventually would happen.
> 
> Also, d80211 allows some operations even without having any network
> interface present (of course, master interface is still present, but it's
> not nice to use its ifindex, especially in the light of previous paragraph).
> 
> I propose this:
> - add NL80211_ATTR_WIPHY_INDEX attributte

We can do that at any time we want.

> - add wiphy_index field to nl80211_driver and require non-d80211 users to
>   set it to -1

Woah, wait. Let's do it the other way around then, we give them a wiphy
index. That way, we have a central registry for it here in nl80211.

> - allow NL80211_ATTR_IFINDEX to be optional in some calls - the exact list
>   of these calls is independent of any driver and can be hardcoded in
>   nl80211

That's what I pretty much do already.

> - in such calls, specifying either NL80211_ATTR_IFINDEX or
>   NL80211_ATTR_WIPHY_INDEX is enough; of course, when corresponding driver
>   does not support wiphys (i.e. nl80211_driver.wiphy_index is -1), only
>   NL80211_ATTR_IFINDEX can be specified
> - in other calls, NL80211_ATTR_WIPHY_INDEX should not be present
> 
> Alternatively, you could introduce a flag to denote if NL80211_ATTR_IFINDEX
> field contains ifindex or wiphy index.

Ick, no flag. Let's just have two separate attributes, and on some calls
either one or both are valid.

johannes
