From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH 3/8] can: CAN Network device driver and SYSFS interface
Date: Fri, 20 Feb 2009 09:39:54 +0100
Message-ID: <499E6C5A.5020505@grandegger.com>
References: <1235070082-7069-1-git-send-email-wg@grandegger.com>	<1235070082-7069-2-git-send-email-wg@grandegger.com>	<1235070082-7069-3-git-send-email-wg@grandegger.com>	<1235070082-7069-4-git-send-email-wg@grandegger.com> <20090219164932.63420915@bike.lwn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Jonathan Corbet <corbet@lwn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:37882 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141AbZBTIkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 03:40:00 -0500
In-Reply-To: <20090219164932.63420915@bike.lwn.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jonathan Corbet wrote:
> On Thu, 19 Feb 2009 20:01:17 +0100
> Wolfgang Grandegger <wg@grandegger.com> wrote:
> 
>> +/*
>> + * Bit-timing calculation derived from:
>> + *
>> + * Code based on LinCAN sources and H8S2638 project
>> + * Copyright 2004-2006 Pavel Pisa - DCE FELK CVUT cz
>> + * Copyright 2005      Stanislav Marek
>> + * email: pisa@cmp.felk.cvut.cz
>> + */
>> +static int can_update_spt(const struct can_bittiming_const *btc,
>> +			  int sampl_pt, int tseg, int *tseg1, int *tseg2)
>> +{
>> +	*tseg2 = tseg + 1 - (sampl_pt * (tseg + 1)) / 1000;
>> +	if (*tseg2 < btc->tseg2_min)
>> +		*tseg2 = btc->tseg2_min;
>> +	if (*tseg2 > btc->tseg2_max)
>> +		*tseg2 = btc->tseg2_max;
>> +	*tseg1 = tseg - *tseg2;
>> +	if (*tseg1 > btc->tseg1_max) {
>> +		*tseg1 = btc->tseg1_max;
>> +		*tseg2 = tseg - *tseg1;
>> +	}
>> +	return 1000 * (tseg + 1 - *tseg2) / (tseg + 1);
>> +}
> 
> I can only assume that this calculation means something to somebody.  I
> guess there's no hope for those of use too lazy to go read the Bosch spec,
> where, I assume, this kind of stuff is described.

The purpose and quirks of this bit-timing calculation are described
briefly in the Kconfig entry for CONFIG_CAN_CALC_BITTIMING and in
Documentation/networking/can.txt which I quote below:

 "6.5.2 Setting the CAN bit-timing

  The CAN bit-timing parameters can always be specified in a hardware
  independent format as proposed in the Bosch CAN 2.0 specification
  using the SYSFS files "tq", "prop_seg", "phase_seg1", "phase_seg2"
  and "sjw". The SYSFS files are described in the previous chapter.

  If the kernel option CONFIG_CAN_CALC_BITTIMING is enabled, CIA
  recommended CAN bit-timing parameters will be calculated for the bit-
  rate written to the SYSFS file "bitrate" when the device gets started.
  Note that this works fine for the most common CAN controllers with
  standard bit-rates but may *fail* for exotic bit-rates or CAN source
  clock frequencies. Disabling CONFIG_CAN_CALC_BITTIMING saves some
  space and allows user space tools to solely determine and set the
  bit-timing parameters. The CAN controller specific bit-timing
  constants can be used for that purpose. They are available in the
  SYSFS directory "can_bittiming" as well with the name prefix "hw_"."

The user just sets the bit-rate and this function will determine proper
bit-timing parameters.

>> +static int can_calc_bittiming(struct net_device *dev)
> 
> This function, too, is pretty well impenetrable.  I couldn't possibly try
> to tell you if it's even remotely correct.  Some comments might be nice.

Unfortunately, there are no simple speed settings like 100 bps FD for
Ethernet. Setting proper CAN bit-timing might be tricky and in rare
cases you even may need the help of a real CAN expert, including myself
:-(. Furthermore, setting the hardware bit-timing is very hardware
*dependent* and we tried to address this issue using a hardware
*independent* format as proposed by the Bosch specification. Well, maybe
I should document our approach in more detail.

>> +/*
>> + * Allocate and setup space for the CAN network device
>> + */
>> +struct net_device *alloc_candev(int sizeof_priv)
>> +{
>> +	struct net_device *dev;
>> +	struct can_priv *priv;
>> +
>> +	dev = alloc_netdev(sizeof_priv, "can%d", can_setup);
>> +	if (!dev)
>> +		return NULL;
>> +
>> +	priv = netdev_priv(dev);
>> +
>> +	priv->state = CAN_STATE_STOPPED;
>> +	spin_lock_init(&priv->irq_lock);
> 
> This is the first mention I see of a lock in this file.  What are your
> locking rules?  There doesn't seem to be a lot of locking going on...  In
> particular, nothing in this file uses irq_lock.

I see, the locking needs some more careful analysis. Thanks for pointing
that out.

> 
>> +	init_timer(&priv->timer);
>> +	priv->timer.expires = 0;
>> +
>> +	return dev;
>> +}
>> +EXPORT_SYMBOL_GPL(alloc_candev);
> 
>> +/*
>> + * Allocate space of the CAN network device
>> + */
>> +void free_candev(struct net_device *dev)
>> +{
>> +	free_netdev(dev);
>> +}
>> +EXPORT_SYMBOL_GPL(free_candev);
> 
> I do believe that function is *freeing* space...?  

Of course, will fix.

> The allocation function initializes a timer, but here we do nothing to
> ensure that the timer is not running.  Is there a rule somewhere that I
> missed?

If the device is freed when its still open, the network layer calls the
close function of the device, which will do to proper cleanup including
deleting the timer.

>> +/*
>> + * Local echo of CAN messages
>> + *
>> + * CAN network devices *should* support a local echo functionality
>> + * (see Documentation/networking/can.txt). To test the handling of CAN
>> + * interfaces that do not support the local echo both driver types are
>> + * implemented. In the case that the driver does not support the echo
>> + * the IFF_ECHO remains clear in dev->flags. This causes the PF_CAN core
>> + * to perform the echo as a fallback solution.
>> + */
>> +
>> +static void can_flush_echo_skb(struct net_device *dev)
>> +{
>> +	struct can_priv *priv = netdev_priv(dev);
>> +	struct net_device_stats *stats = &dev->stats;
>> +	int i;
>> +
>> +	for (i = 0; i < CAN_ECHO_SKB_MAX; i++) {
>> +		if (priv->echo_skb[i]) {
>> +			kfree_skb(priv->echo_skb[i]);
>> +			priv->echo_skb[i] = NULL;
>> +			stats->tx_dropped++;
>> +			stats->tx_aborted_errors++;
>> +		}
>> +	}
>> +}
> 
> What lock is protecting priv->echo_skb?

This code is called when the device is stopped, but I need to double-check.

> 
>> +/*
>> + * Put the skb on the stack to be looped backed locally lateron
>> + *
>> + * The function is typically called in the start_xmit function
>> + * of the device driver.
>> + */
>> +void can_put_echo_skb(struct sk_buff *skb, struct net_device *dev, int idx)
>> +{
>> +	struct can_priv *priv = netdev_priv(dev);
>> +
>> +	/* set flag whether this packet has to be looped back */
>> +	if (!(dev->flags & IFF_ECHO) || skb->pkt_type != PACKET_LOOPBACK) {
>> +		kfree_skb(skb);
>> +		return;
>> +	}
> 
> The comment says "set flag", but the code potentially frees the skb and aborts.

Will fix the comment.

> [...]
> 
>> +/*
>> + * CAN device restart for bus-off recovery
>> + */
>> +int can_restart_now(struct net_device *dev)
>> +{
>> +	struct can_priv *priv = netdev_priv(dev);
>> +	struct net_device_stats *stats = &dev->stats;
>> +	struct sk_buff *skb;
>> +	struct can_frame *cf;
>> +	int err;
>> +
>> +	if (netif_carrier_ok(dev))
>> +		netif_carrier_off(dev);
>> +
>> +	/* Cancel restart in progress */
>> +	if (priv->timer.expires) {
>> +		del_timer(&priv->timer);
>> +		priv->timer.expires = 0; /* mark inactive timer */
>> +	}
> 
> Are you sure you don't want del_timer_sync() there?  What keeps you from
> racing with the timer?

Right, will fix.

> [...]
> 
>> +/*
>> + * Cleanup function before the device gets closed.
>> + *
>> + * This functions should be called in the close function of the device
>> + * driver.
>> + */
>> +void can_close_cleanup(struct net_device *dev)
>> +{
>> +	struct can_priv *priv = netdev_priv(dev);
>> +
>> +	if (priv->timer.expires) {
>> +		del_timer(&priv->timer);
>> +		priv->timer.expires = 0;
>> +	}
>> +
>> +	can_flush_echo_skb(dev);
>> +}
>> +EXPORT_SYMBOL_GPL(can_close_cleanup);
> 
> You definitely want del_timer_sync() here.  You could potentially return
> with the timer still running.
> 
>> diff --git a/drivers/net/can/sysfs.c b/drivers/net/can/sysfs.c
>> new file mode 100644
>> index 0000000..746f641
>> --- /dev/null
>> +++ b/drivers/net/can/sysfs.c
> 
> Most of this file looks like typical sysfs cruft.  Again, though, I wonder
> about your locking...
> 
>> +/* use same locking rules as GIF* ioctl's */
>> +static ssize_t can_dev_show(struct device *d,
>> +			    struct device_attribute *attr, char *buf,
>> +			    ssize_t (*fmt)(struct net_device *, char *))
>> +{
>> +	struct net_device *dev = to_net_dev(d);
>> +	ssize_t ret = -EINVAL;
>> +
>> +	read_lock(&dev_base_lock);
>> +	if (dev_isalive(dev))
>> +		ret = (*fmt)(dev, buf);
>> +	read_unlock(&dev_base_lock);
>> +
>> +	return ret;
>> +}
> 
> I'm not sure what the GIF* ioctl() locking rules are, but do they really
> give you properly-serialized access to your device?  dev_base_lock seems
> like an unlikely choice, somehow, but maybe I'm missing something.

This locking code is from

http://lxr.linux.no/linux+v2.6.28.6/net/core/net-sysfs.c#L34

accessing SYSFS files for the network device in a similar way.

> [...]
> 
>> +/* use same locking and permission rules as SIF* ioctl's */
>> +static ssize_t can_dev_store(struct device *d, struct device_attribute *attr,
>> +			     const char *buf, size_t len,
>> +			     int (*set)(struct net_device *, unsigned long))
>> +{
>> +	struct net_device *dev = to_net_dev(d);
>> +	unsigned long new;
>> +	int ret = -EINVAL;
>> +
>> +	if (!capable(CAP_NET_ADMIN))
>> +		return -EPERM;
>> +
>> +	ret = strict_strtoul(buf, 0, &new);
>> +	if (ret)
>> +		goto out;
>> +
>> +	rtnl_lock();
>> +	if (dev_isalive(dev)) {
>> +		ret = (*set)(dev, new);
>> +		if (!ret)
>> +			ret = len;
>> +	}
>> +	rtnl_unlock();
>> +out:
>> +	return ret;
>> +}
> 
> Here we're using a different (global) lock?  Me confused...

See http://lxr.linux.no/linux+v2.6.28.6/net/core/net-sysfs.c#L63

> 
> [...]
> 
>> diff --git a/drivers/net/can/sysfs.h b/drivers/net/can/sysfs.h
>> new file mode 100644
>> index 0000000..e21f2fa
>> --- /dev/null
>> +++ b/drivers/net/can/sysfs.h
>> @@ -0,0 +1,24 @@
>> +/*
>> + * Copyright (C) 2007 Wolfgang Grandegger <wg@grandegger.com>
>> + *
>> + * This program is free software; you can redistribute it and/or modify
>> + * it under the terms of the version 2 of the GNU General Public License
>> + * as published by the Free Software Foundation
>> + *
>> + * This program is distributed in the hope that it will be useful,
>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
>> + * GNU General Public License for more details.
>> + *
>> + * You should have received a copy of the GNU General Public License
>> + * along with this program; if not, write to the Free Software
>> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
>> + */
>> +
>> +#ifndef CAN_SYSFS_H
>> +#define CAN_SYSFS_H
>> +
>> +void can_create_sysfs(struct net_device *dev);
>> +void can_remove_sysfs(struct net_device *dev);
>> +
>> +#endif /* CAN_SYSFS_H */
>> diff --git a/include/linux/can/dev.h b/include/linux/can/dev.h
>> new file mode 100644
>> index 0000000..078ac03
>> --- /dev/null
>> +++ b/include/linux/can/dev.h
>> @@ -0,0 +1,136 @@
>> +/*
>> + * linux/can/dev.h
>> + *
>> + * Definitions for the CAN network device driver interface
>> + *
>> + * Copyright (C) 2006 Andrey Volkov <avolkov@varma-el.com>
>> + *               Varma Electronics Oy
>> + *
>> + * Copyright (C) 2008 Wolfgang Grandegger <wg@grandegger.com>
> 
> Nothing in 2009? :)

Will fix.

> 
>> + *
>> + * Send feedback to <socketcan-users@lists.berlios.de>
>> + */
>> +
>> +#ifndef CAN_DEV_H
>> +#define CAN_DEV_H
>> +
>> +#include <linux/can/error.h>
>> +
>> +/*
>> + * CAN bitrate and bit-timing
>> + */
>> +struct can_bittiming {
>> +	u32 bitrate;
>> +	u32 sample_point;
>> +	u32 tq;
>> +	u32 prop_seg;
>> +	u32 phase_seg1;
>> +	u32 phase_seg2;
>> +	u32 sjw;
>> +	u32 clock;
>> +	u32 brp;
>> +};
> 
> It sure would be nice (again) to know what all these parameters are.
> 
>> +struct can_bittiming_const {
>> +	u32 tseg1_min;
>> +	u32 tseg1_max;
>> +	u32 tseg2_min;
>> +	u32 tseg2_max;
>> +	u32 sjw_max;
>> +	u32 brp_min;
>> +	u32 brp_max;
>> +	u32 brp_inc;
>> +};
> 
> Ditto.

OK, will add some documentation.

> [...]
> 
>> +/*
>> + * CAN common private data
>> + */
>> +#define CAN_ECHO_SKB_MAX  4
>> +
>> +struct can_priv {
>> +	struct can_device_stats can_stats;
>> +
>> +	struct can_bittiming bittiming;
>> +	struct can_bittiming_const *bittiming_const;
>> +
>> +	spinlock_t irq_lock;
> 
> ...protecting what...?

This is not OK, indeed. It is currently just used by the  SJA1000
driver. Either it can be moved to the SJA1000 private struct or it is
required for some missing locking. I will check.

>> +	enum can_state state;
>> +	u32 ctrlmode;
>> +
>> +	int restart_ms;
>> +	struct timer_list timer;
>> +
>> +	struct sk_buff *echo_skb[CAN_ECHO_SKB_MAX];
>> +
>> +	int (*do_set_bittiming)(struct net_device *dev);
>> +	int (*do_get_state)(struct net_device *dev, enum can_state *state);
>> +	int (*do_set_mode)(struct net_device *dev, enum can_mode mode);
>> +	int (*do_set_ctrlmode)(struct net_device *dev, u32 ctrlmode);
>> +	int (*do_get_ctrlmode)(struct net_device *dev, u32 *ctrlmode);
>> +};
>> +
>> +#define ND2D(_ndev)	(_ndev->dev.parent)
> 
> Does this macro really improve the clarity of the code?

IMO, yes, but a more descriptive name should be used, e.g. NDEV2DEV.

Thanks,

Wolfgang.
