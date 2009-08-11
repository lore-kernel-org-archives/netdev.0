From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2] mac802154: add a software MAC 802.15.4
 implementation
Date: Wed, 12 Aug 2009 00:23:04 +0400
Message-ID: <20090811202304.GA6303@doriath.ww600.siemens.net>
References: <1249913800-10176-1-git-send-email-dbaryshkov@gmail.com>
 <1249913800-10176-2-git-send-email-dbaryshkov@gmail.com>
 <1249914466.32614.13.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1249914466.32614.13.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 10, 2009 at 04:27:46PM +0200, Johannes Berg wrote:
> On Mon, 2009-08-10 at 18:16 +0400, Dmitry Eremin-Solenikov wrote:
> > + * @tx: Handler that 802.15.4 module calls for each transmitted frame.
> > + *      skb cntains the buffer starting from the IEEE 802.15.4 header.
> > + *      The low-level driver should send the frame based on available
> > + *      configuration.
> > + *      This function should return zero or negative errno.
> 
> That return value is strange.

The idea is that tx function can return info about errors during
transmit (busy channel, no ACK, etc).

> 
> > +++ b/net/Makefile
> > @@ -61,6 +61,7 @@ ifneq ($(CONFIG_DCB),)
> >  obj-y				+= dcb/
> >  endif
> >  obj-y				+= ieee802154/
> > +obj-y				+= mac802154/
> 
> I think you should use obj-$(CONFIG_MAC802154) as there's no need to
> recurse into the dir unless that's selected.

fixed.

> 
> But does it make sense to actually have this little code as a separate
> dir/module?

The submitted patch is only a part of written MAC code. And we still
aren't feature complete. Is there any sence in keeping mac80211
separate? IMHO yes. Same goes for mac802154.

> > +	struct net_device *netdev; /* mwpanX device */
> > +	int open_count;
> > +	/* As in mac80211 slaves list is modified:
> > +	 * 1) under the RTNL
> > +	 * 2) protected by slaves_mtx;
> > +	 * 3) in an RCU manner
> > +	 *
> > +	 * So atomic readers can use any of this protection methods
> > +	 */
> > +	struct list_head	slaves;
> 
> heh.

? C&p from mac80211 mostly :)

> 
> > +static int ieee802154_master_open(struct net_device *dev)
> > +{
> 
> We've had no end to trouble with the master netdev, I suggest you look
> into the current mac80211 code and see if you can get rid of it.

What troubles w/ master netdev did you have had? I do still see the
master devices in mac80211. IIUC, it's planned to replace (from
management point of view) the mdev with wiphy instance, isn't it?

> > +struct ieee802154_dev *ieee802154_alloc_device(size_t priv_size,
> > +		struct ieee802154_ops *ops)
> > +{
> 
> > +	if (!try_module_get(ops->owner)) {
> 
> That isn't necessary since the module is just calling your function. In
> fact, doing this removes the ability to rmmod any module using this
> which is bogus.

Hmm. I thought that one may be able to rmmod the module w/ ops while the
device is still hanging in the system. On the other hand, ops are
provided by the driver, so if one rmmods the driver and the device is
still there, it's a bug...
Removing now.

-- 
With best wishes
Dmitry

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
