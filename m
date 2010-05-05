From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] compat-wireless: updates for orinoco
Date: Tue, 4 May 2010 17:04:09 -0700
Message-ID: <20100504170409.46914a88@nehalam>
References: <1273012850-8359-1-git-send-email-hauke@hauke-m.de>
	<v2u43e72e891005041626n14deaca5z284f2472e909c923@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	David Miller <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, mcgrof@kernel.org,
	netdev@vger.kernel.org
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53720 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932705Ab0EEAEX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 May 2010 20:04:23 -0400
In-Reply-To: <v2u43e72e891005041626n14deaca5z284f2472e909c923@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 4 May 2010 16:26:53 -0700
"Luis R. Rodriguez" <lrodriguez@atheros.com> wrote:

> First of all, thanks a lot! Some comments below.
> 
> On Tue, May 4, 2010 at 3:40 PM, Hauke Mehrtens <hauke@hauke-m.de> wrote:
> > * Make all the patches apply again.
> > * rename read_pda to avoid conflicts with definitions in kernel <= 2.6.29
> 
> I'm going to apply these two changes, if you get time can you send a
> patch to rename read_pda upstream as well, that way we don't have to
> carry this?
> 
> > * add orinoco usb
> 
> Thanks for this but I've grown tired of updating these netdev ops and
> I think we can do better. I'll add a netdev_attach_ops() which would
> simply do all the backport stuff for us, this way for backporting
> purposes all we have to do is replace the old lines with a
> netdev_attach_ops() call. In fact if we *really* wanted to we could
> add a dummy netdev_attach_ops() upstream and just backport that on
> older kernels, this would mean 0 line changes to backport a newer
> driver.
> 
> Something like this maybe on the generic compat module, it builds for
> me, will commit soon.
> 
> /*
>  * Expand this as drivers require more ops, for now this
>  * only sets the ones we need.
>  */
> void netdev_attach_ops(struct net_device *dev,
>                       const struct net_device_ops *ops)
> {
> #define SET_NETDEVOP(_op) (_op ? _op : NULL)
>        dev->open = SET_NETDEVOP(ops->ndo_open);
>        dev->stop = SET_NETDEVOP(ops->ndo_stop);
>        dev->hard_start_xmit = SET_NETDEVOP(ops->ndo_start_xmit);
>        dev->set_multicast_list = SET_NETDEVOP(ops->ndo_set_multicast_list);
>        dev->change_mtu = SET_NETDEVOP(ops->ndo_change_mtu);
>        dev->set_mac_address = SET_NETDEVOP(ops->ndo_set_mac_address);
>        dev->tx_timeout = SET_NETDEVOP(ops->ndo_tx_timeout);
>        dev->get_stats = SET_NETDEVOP(ops->ndo_get_stats);
> #undef SET_NETDEVOP
> }
> EXPORT_SYMBOL(netdev_attach_ops);
> 
> For newer kernels then this would just be:
> 
> static inline void netdev_attach_ops(struct net_device *dev,
>                       const struct net_device_ops *ops)
> {
>        dev->netdev_ops = ops;
> }
> 
> Stephen, would the above be acceptable upstream on netdevice.h ? It
> would eliminate all needs from having to #ifdef network drivers when
> backporting. If so I can send a respective patch and spatch all the
> setters I think. An example of the nasty ifdef crap we have to do for
> the current backport of netdevop'able drivers is below.
> 

No. supporting backporting is not part of the upstream kernel
mission. Honestly, we try for forward compatibility but intentionally
ignore carrying extra backport baggage.
