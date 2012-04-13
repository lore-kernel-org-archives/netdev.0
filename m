From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 6/6] tilegx network driver: initial support
Date: Fri, 13 Apr 2012 10:34:03 +0000
Message-ID: <201204131034.03544.arnd@arndb.de>
References: <201204062059.q36KxjEO011317@farm-0027.internal.tilera.com> <201204101042.39877.arnd@arndb.de> <4F8763E1.1020605@tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F8763E1.1020605@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 12 April 2012, Chris Metcalf wrote:
> On 4/10/2012 6:42 AM, Arnd Bergmann wrote:
> > Ok, but please remove tile_net_devs then.
> > I think a better abstraction for tile_net_devs_for_channel would be
> > some interface that lets you add private data to a channel so when
> > you get data from a channel, you can extract that pointer from the driver
> > using the channel.

> I think what would be clearer is to document how and why we are using this
> additional data structure.  We do access via both arrays where it is
> efficient to do so, so getting rid of either of them doesn't seem right. 
> Let's keep the "normal" tile_net_devs[] as is, indexed by devno, and make
> the tile_net_devs_for_channel[] more abstracted by using the following code:

The tile_net_devs still feels dirty. You basically only
use it in tile_net_handle_egress_timer(), but there you don't
actually take the mutex that protects addition and removal from
the array, so it's racy in case of hotplug.

A more conservative way to do this is to have the timer per
device (or by channel, if you like), so it does not have to
iterate the array.

> /*
>  * Provide support for efficiently mapping a channel to the device
>  * that is using that channel, or NULL if none.  The pointers in this
>  * array are only non-NULL when pointing to active tilegx net_device
>  * structures, and they are cleared before the struture itself is
>  * released.
>  *
>  * HACK: We use "32", not TILE_NET_CHANNELS, because it is fairly
>  * subtle that the 5 bit "idesc.channel" field never exceeds
>  * TILE_NET_CHANNELS.
>  */
> static struct net_device *channel_to_dev[32];
> 
> static void bychannel_add(struct net_device *dev)
> {
>         struct tile_net_priv *priv = netdev_priv(dev);
>         BUG_ON(channel_to_dev[priv->channel] != NULL);
>         channel_to_dev[priv->channel] = dev;
> }
> 
> static void bychannel_delete(struct net_device *dev)
> {
>         struct tile_net_priv *priv = netdev_priv(dev);
>         channel_to_dev[priv->channel] = NULL;
> }
> 
> static inline struct net_device *bychannel_lookup(int channel)
> {
>         return channel_to_dev[channel];
> }
> 
> 
> We then call bychannel_add() in the open method, and bychannel_delete() in
> the close method, so it's clear that the pointers have appropriate lifetimes.

Ok.

	Arnd
