From: "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 1/2] mac802154: add a software MAC 802.15.4
	implementation
Date: Mon, 10 Aug 2009 10:28:43 -0700
Message-ID: <20090810172843.GD6791@linux.vnet.ibm.com>
References: <1249913800-10176-1-git-send-email-dbaryshkov@gmail.com> <1249913800-10176-2-git-send-email-dbaryshkov@gmail.com>
Reply-To: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
To: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1249913800-10176-2-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 10, 2009 at 06:16:39PM +0400, Dmitry Eremin-Solenikov wrote:
> Some of available devices are just dump radios implementing IEEE 802.15.4
> PHY layer. This commit adds a common library that acts like an intermediate
> layer between our socket family and drivers for those dumb devices.
> 
> Currently this is data-only part (no commands, no beacons). Control
> interfaces will follow up shortly.
> 
> Note this implementaion is neither certified, nor feature complete!

One question below, otherwise looks plausible.  (I am not entirely sure
which lists are which...)

							Thanx, Paul

> Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
> ---
>  MAINTAINERS               |    1 +
>  include/linux/mac802154.h |   35 ++
>  include/net/mac802154.h   |  106 ++++++
>  net/Kconfig               |    1 +
>  net/Makefile              |    1 +
>  net/mac802154/Kconfig     |   17 +
>  net/mac802154/Makefile    |    4 +
>  net/mac802154/dev.c       |  924 +++++++++++++++++++++++++++++++++++++++++++++
>  net/mac802154/mac802154.h |   85 +++++
>  net/mac802154/mac_cmd.c   |   99 +++++
>  net/mac802154/mdev.c      |  295 +++++++++++++++
>  net/mac802154/mib.h       |   32 ++
>  net/mac802154/rx.c        |   98 +++++
>  13 files changed, 1698 insertions(+), 0 deletions(-)
>  create mode 100644 include/linux/mac802154.h
>  create mode 100644 include/net/mac802154.h
>  create mode 100644 net/mac802154/Kconfig
>  create mode 100644 net/mac802154/Makefile
>  create mode 100644 net/mac802154/dev.c
>  create mode 100644 net/mac802154/mac802154.h
>  create mode 100644 net/mac802154/mac_cmd.c
>  create mode 100644 net/mac802154/mdev.c
>  create mode 100644 net/mac802154/mib.h
>  create mode 100644 net/mac802154/rx.c
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index d6befb2..5bdb64e 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -2529,6 +2529,7 @@ W:	http://apps.sourceforge.net/trac/linux-zigbee
>  T:	git git://git.kernel.org/pub/scm/linux/kernel/git/lowpan/lowpan.git
>  S:	Maintained
>  F:	net/ieee802154/
> +F:	net/mac802154/
>  F:	drivers/ieee802154/
> 
>  INTEGRITY MEASUREMENT ARCHITECTURE (IMA)
> diff --git a/include/linux/mac802154.h b/include/linux/mac802154.h
> new file mode 100644
> index 0000000..e95e38d
> --- /dev/null
> +++ b/include/linux/mac802154.h
> @@ -0,0 +1,35 @@
> +/*
> + * Copyright (C) 2007, 2008, 2009 Siemens AG
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License along
> + * with this program; if not, write to the Free Software Foundation, Inc.,
> + * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
> + *
> + */
> +
> +#ifndef LINUX_MAC802154_H
> +#define LINUX_MAC802154_H
> +
> +enum {
> +	IFLA_WPAN_UNSPEC,
> +	IFLA_WPAN_CHANNEL,
> +	IFLA_WPAN_PAN_ID,
> +	IFLA_WPAN_SHORT_ADDR,
> +	IFLA_WPAN_COORD_SHORT_ADDR,
> +	IFLA_WPAN_COORD_EXT_ADDR,
> +	__IFLA_WPAN_MAX,
> +};
> +
> +#define IFLA_WPAN_MAX	(__IFLA_WPAN_MAX - 1)
> +
> +#endif
> +
> diff --git a/include/net/mac802154.h b/include/net/mac802154.h
> new file mode 100644
> index 0000000..db76799
> --- /dev/null
> +++ b/include/net/mac802154.h
> @@ -0,0 +1,106 @@
> +/*
> + * IEEE802.15.4-2003 specification
> + *
> + * Copyright (C) 2007, 2008 Siemens AG
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License along
> + * with this program; if not, write to the Free Software Foundation, Inc.,
> + * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
> + *
> + * Written by:
> + */
> +#ifndef NET_MAC802154_H
> +#define NET_MAC802154_H
> +
> +struct ieee802154_dev {
> +	int	extra_tx_headroom; /* headroom to reserve for tx skb */
> +	void	*priv;		/* driver-specific data */
> +	u32	channel_mask;
> +	u8	current_channel;
> +	u32	flags; /* Flags for device to set */
> +	struct device *parent;
> +};
> +
> +/* Checksum is in hardware and is omitted from packet */
> +/**
> + * enum ieee802154_hw_flags - hardware flags
> + *
> + * These flags are used to indicate hardware capabilities to
> + * the stack. Generally, flags here should have their meaning
> + * done in a way that the simplest hardware doesn't need setting
> + * any particular flags. There are some exceptions to this rule,
> + * however, so you are advised to review these flags carefully.
> + *
> + * @IEEE802154_HW_OMIT_CKSUM:
> + *	Indicates that receiver omits FCS and transmitter will add
> + *	FCS on it's own.
> + *
> + * @IEEE802154_HW_AACK:
> + * 	Indicates that receiver will autorespond with ACK frames.
> + */
> +enum ieee802154_hw_flags {
> +	IEEE802154_HW_OMIT_CKSUM			= 1 << 0,
> +	IEEE802154_HW_AACK				= 1 << 1,
> +};
> +
> +struct sk_buff;
> +
> +/**
> + * struct ieee802154_ops - callbacks from mac802154 to the driver
> + *
> + * This structure contains various callbacks that the driver may
> + * handle or, in some cases, must handle, for example to transmit
> + * a frame.
> + *
> + * @start: Handler that 802.15.4 module calls for device initialisation.
> + * 	This function is called before the first interface is attached.
> + *
> + * @stop: Handler that 802.15.4 module calls for device cleanup
> + * 	This function is called after the last interface is removed.
> + *
> + * @tx: Handler that 802.15.4 module calls for each transmitted frame.
> + *      skb cntains the buffer starting from the IEEE 802.15.4 header.
> + *      The low-level driver should send the frame based on available
> + *      configuration.
> + *      This function should return zero or negative errno.
> + *
> + * @ed: Handler that 802.15.4 module calls for Energy Detection.
> + *      This function should place the value for detected energy
> + *      (usually device-dependant) in the level pointer and return
> + *      either zero or negative errno.
> + *
> + * @set_channel: Set radio for listening on specific channel.
> + *      Set the device for listening on specified channel.
> + *      Returns either zero, or negative errno.
> + */
> +struct ieee802154_ops {
> +	struct module	*owner;
> +	int		(*start)(struct ieee802154_dev *dev);
> +	void		(*stop)(struct ieee802154_dev *dev);
> +	int		(*xmit)(struct ieee802154_dev *dev,
> +						struct sk_buff *skb);
> +	int		(*ed)(struct ieee802154_dev *dev, u8 *level);
> +	int		(*set_channel)(struct ieee802154_dev *dev,
> +						int channel);
> +};
> +
> +struct ieee802154_dev *ieee802154_alloc_device(size_t priv_size,
> +						struct ieee802154_ops *ops);
> +int ieee802154_register_device(struct ieee802154_dev *dev);
> +void ieee802154_unregister_device(struct ieee802154_dev *dev);
> +void ieee802154_free_device(struct ieee802154_dev *dev);
> +
> +void ieee802154_rx(struct ieee802154_dev *dev, struct sk_buff *skb, u8 lqi);
> +void ieee802154_rx_irqsafe(struct ieee802154_dev *dev, struct sk_buff *skb,
> +		u8 lqi);
> +#endif
> +
> diff --git a/net/Kconfig b/net/Kconfig
> index 7051b97..b42d325 100644
> --- a/net/Kconfig
> +++ b/net/Kconfig
> @@ -180,6 +180,7 @@ source "net/econet/Kconfig"
>  source "net/wanrouter/Kconfig"
>  source "net/phonet/Kconfig"
>  source "net/ieee802154/Kconfig"
> +source "net/mac802154/Kconfig"
>  source "net/sched/Kconfig"
>  source "net/dcb/Kconfig"
> 
> diff --git a/net/Makefile b/net/Makefile
> index ba324ae..81115f6 100644
> --- a/net/Makefile
> +++ b/net/Makefile
> @@ -61,6 +61,7 @@ ifneq ($(CONFIG_DCB),)
>  obj-y				+= dcb/
>  endif
>  obj-y				+= ieee802154/
> +obj-y				+= mac802154/
> 
>  ifeq ($(CONFIG_NET),y)
>  obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
> diff --git a/net/mac802154/Kconfig b/net/mac802154/Kconfig
> new file mode 100644
> index 0000000..2dd7f99
> --- /dev/null
> +++ b/net/mac802154/Kconfig
> @@ -0,0 +1,17 @@
> +config MAC802154
> +	tristate "Generic IEEE 802.15.4 Soft Networking Stack (mac802154)"
> +	depends on IEEE802154 && EXPERIMENTAL
> +	select CRC_CCITT
> +	---help---
> +	  This option enables the hardware independent IEEE 802.15.4
> +	  networking stack for SoftMAC devices (the ones implementing
> +	  only PHY level of IEEE 802.15.4 standard).
> +
> +	  Note: this implementation is neither certified, nor feature
> +	  complete! We do not garantee that it is compatible w/ other
> +	  implementations, etc.
> +
> +	  If you plan to use HardMAC IEEE 802.15.4 devices, you can
> +          say N here. Alternatievly you can say M to compile it as
> +	  module.
> +
> diff --git a/net/mac802154/Makefile b/net/mac802154/Makefile
> new file mode 100644
> index 0000000..07b7821
> --- /dev/null
> +++ b/net/mac802154/Makefile
> @@ -0,0 +1,4 @@
> +obj-$(CONFIG_MAC802154) +=	mac802154.o
> +mac802154-objs		:= rx.o mdev.o dev.o mac_cmd.o
> +
> +EXTRA_CFLAGS += -Wall -DDEBUG
> diff --git a/net/mac802154/dev.c b/net/mac802154/dev.c
> new file mode 100644
> index 0000000..b40f6fd
> --- /dev/null
> +++ b/net/mac802154/dev.c
> @@ -0,0 +1,924 @@
> +/*
> + * Copyright 2007, 2008, 2009 Siemens AG
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License along
> + * with this program; if not, write to the Free Software Foundation, Inc.,
> + * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
> + *
> + * Written by:
> + * Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
> + * Maxim Gorbachyov <maxim.gorbachev-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org>
> + */
> +
> +#include <linux/net.h>
> +#include <linux/capability.h>
> +#include <linux/module.h>
> +#include <linux/if_arp.h>
> +#include <linux/rculist.h>
> +#include <linux/random.h>
> +#include <linux/crc-ccitt.h>
> +#include <linux/mac802154.h>
> +#include <net/rtnetlink.h>
> +
> +#include <net/af_ieee802154.h>
> +#include <net/mac802154.h>
> +#include <net/ieee802154_netdev.h>
> +#include <net/ieee802154.h>
> +
> +#include "mac802154.h"
> +#include "mib.h"
> +
> +static int ieee802154_net_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct ieee802154_sub_if_data *priv;
> +	priv = netdev_priv(dev);
> +
> +	if (!(priv->hw->hw.flags & IEEE802154_HW_OMIT_CKSUM)) {
> +		u16 crc = crc_ccitt(0, skb->data, skb->len);
> +		u8 *data = skb_put(skb, 2);
> +		data[0] = crc & 0xff;
> +		data[1] = crc >> 8;
> +	}
> +
> +	read_lock(&priv->mib_lock);
> +	phy_cb(skb)->chan = priv->chan;
> +	read_unlock(&priv->mib_lock);
> +
> +	skb->iif = dev->ifindex;
> +	skb->dev = priv->hw->netdev;
> +	dev->stats.tx_packets++;
> +	dev->stats.tx_bytes += skb->len;
> +
> +	dev->trans_start = jiffies;
> +	dev_queue_xmit(skb);
> +
> +	return 0;
> +}
> +
> +static int ieee802154_slave_open(struct net_device *dev)
> +{
> +	struct ieee802154_sub_if_data *priv = netdev_priv(dev);
> +	int res = 0;
> +
> +	if (priv->hw->open_count++ == 0) {
> +		res = dev_open(priv->hw->netdev);
> +		WARN_ON(res);
> +		if (res)
> +			goto err;
> +	}
> +
> +	netif_start_queue(dev);
> +	return 0;
> +err:
> +	priv->hw->open_count--;
> +
> +	return res;
> +}
> +
> +static int ieee802154_slave_close(struct net_device *dev)
> +{
> +	struct ieee802154_sub_if_data *priv = netdev_priv(dev);
> +
> +	netif_stop_queue(dev);
> +
> +	if ((--priv->hw->open_count) == 0) {
> +		if (netif_running(priv->hw->netdev))
> +			dev_close(priv->hw->netdev);
> +	}
> +
> +	return 0;
> +}
> +
> +
> +static int ieee802154_slave_ioctl(struct net_device *dev, struct ifreq *ifr,
> +		int cmd)
> +{
> +	struct ieee802154_sub_if_data *priv = netdev_priv(dev);
> +	struct sockaddr_ieee802154 *sa =
> +		(struct sockaddr_ieee802154 *)&ifr->ifr_addr;
> +	int err = -ENOIOCTLCMD;
> +
> +	read_lock(&priv->mib_lock);
> +
> +	switch (cmd) {
> +	case SIOCGIFADDR:
> +		if (priv->pan_id == IEEE802154_PANID_BROADCAST ||
> +		    priv->short_addr == IEEE802154_ADDR_BROADCAST) {
> +			err = -EADDRNOTAVAIL;
> +			break;
> +		}
> +
> +		sa->family = AF_IEEE802154;
> +		sa->addr.addr_type = IEEE802154_ADDR_SHORT;
> +		sa->addr.pan_id = priv->pan_id;
> +		sa->addr.short_addr = priv->short_addr;
> +
> +		err = 0;
> +		break;
> +	case SIOCSIFADDR:
> +		dev_warn(&dev->dev,
> +			"Using DEBUGing ioctl SIOCSIFADDR isn't recommened!\n");
> +		if (sa->family != AF_IEEE802154 ||
> +		    sa->addr.addr_type != IEEE802154_ADDR_SHORT ||
> +		    sa->addr.pan_id == IEEE802154_PANID_BROADCAST ||
> +		    sa->addr.short_addr == IEEE802154_ADDR_BROADCAST ||
> +		    sa->addr.short_addr == IEEE802154_ADDR_UNDEF) {
> +			err = -EINVAL;
> +			break;
> +		}
> +
> +		priv->pan_id = sa->addr.pan_id;
> +		priv->short_addr = sa->addr.short_addr;
> +		err = 0;
> +		break;
> +	}
> +	read_unlock(&priv->mib_lock);
> +	return err;
> +}
> +
> +static int ieee802154_slave_mac_addr(struct net_device *dev, void *p)
> +{
> +	struct sockaddr *addr = p;
> +
> +	if (netif_running(dev))
> +		return -EBUSY;
> +	/* FIXME: validate addr */
> +	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
> +	return 0;
> +}
> +
> +static void ieee802154_haddr_copy_swap(u8 *dest, const u8 *src)
> +{
> +	int i;
> +	for (i = 0; i < IEEE802154_ADDR_LEN; i++)
> +		dest[IEEE802154_ADDR_LEN - i - 1] = src[i];
> +}
> +
> +static int ieee802154_header_create(struct sk_buff *skb,
> +			   struct net_device *dev,
> +			   unsigned short type, const void *_daddr,
> +			   const void *_saddr, unsigned len)
> +{
> +	u8 head[24] = {};
> +	int pos = 0;
> +
> +	u16 fc;
> +	const struct ieee802154_addr *saddr = _saddr;
> +	const struct ieee802154_addr *daddr = _daddr;
> +	struct ieee802154_addr dev_addr;
> +	struct ieee802154_sub_if_data *priv = netdev_priv(dev);
> +
> +	fc = mac_cb_type(skb);
> +	if (mac_cb_is_ackreq(skb))
> +		fc |= IEEE802154_FC_ACK_REQ;
> +
> +	pos = 2;
> +
> +	head[pos++] = mac_cb(skb)->seq; /* DSN/BSN */
> +
> +	if (!daddr)
> +		return -EINVAL;
> +
> +	if (!saddr) {
> +		read_lock(&priv->mib_lock);
> +		if (priv->short_addr == IEEE802154_ADDR_BROADCAST ||
> +		    priv->short_addr == IEEE802154_ADDR_UNDEF ||
> +		    priv->pan_id == IEEE802154_PANID_BROADCAST) {
> +			dev_addr.addr_type = IEEE802154_ADDR_LONG;
> +			memcpy(dev_addr.hwaddr, dev->dev_addr,
> +					IEEE802154_ADDR_LEN);
> +		} else {
> +			dev_addr.addr_type = IEEE802154_ADDR_SHORT;
> +			dev_addr.short_addr = priv->short_addr;
> +		}
> +
> +		dev_addr.pan_id = priv->pan_id;
> +		saddr = &dev_addr;
> +
> +		read_unlock(&priv->mib_lock);
> +	}
> +
> +	if (daddr->addr_type != IEEE802154_ADDR_NONE) {
> +		fc |= (daddr->addr_type << IEEE802154_FC_DAMODE_SHIFT);
> +
> +		head[pos++] = daddr->pan_id & 0xff;
> +		head[pos++] = daddr->pan_id >> 8;
> +
> +		if (daddr->addr_type == IEEE802154_ADDR_SHORT) {
> +			head[pos++] = daddr->short_addr & 0xff;
> +			head[pos++] = daddr->short_addr >> 8;
> +		} else {
> +			ieee802154_haddr_copy_swap(head + pos, daddr->hwaddr);
> +			pos += IEEE802154_ADDR_LEN;
> +		}
> +	}
> +
> +	if (saddr->addr_type != IEEE802154_ADDR_NONE) {
> +		fc |= (saddr->addr_type << IEEE802154_FC_SAMODE_SHIFT);
> +
> +		if ((saddr->pan_id == daddr->pan_id) &&
> +		    (saddr->pan_id != IEEE802154_PANID_BROADCAST))
> +			/* PANID compression/ intra PAN */
> +			fc |= IEEE802154_FC_INTRA_PAN;
> +		else {
> +			head[pos++] = saddr->pan_id & 0xff;
> +			head[pos++] = saddr->pan_id >> 8;
> +		}
> +
> +		if (saddr->addr_type == IEEE802154_ADDR_SHORT) {
> +			head[pos++] = saddr->short_addr & 0xff;
> +			head[pos++] = saddr->short_addr >> 8;
> +		} else {
> +			ieee802154_haddr_copy_swap(head + pos, saddr->hwaddr);
> +			pos += IEEE802154_ADDR_LEN;
> +		}
> +	}
> +
> +	head[0] = fc;
> +	head[1] = fc >> 8;
> +
> +	memcpy(skb_push(skb, pos), head, pos);
> +
> +	return pos;
> +}
> +
> +static int ieee802154_header_parse(const struct sk_buff *skb,
> +		unsigned char *haddr)
> +{
> +	const u8 *hdr = skb_mac_header(skb), *tail = skb_tail_pointer(skb);
> +	struct ieee802154_addr *addr = (struct ieee802154_addr *)haddr;
> +	u16 fc;
> +	int da_type;
> +
> +	if (hdr + 3 > tail)
> +		goto malformed;
> +
> +	fc = hdr[0] | (hdr[1] << 8);
> +
> +	hdr += 3;
> +
> +	da_type = IEEE802154_FC_DAMODE(fc);
> +	addr->addr_type = IEEE802154_FC_SAMODE(fc);
> +
> +	switch (da_type) {
> +	case IEEE802154_ADDR_NONE:
> +		if (fc & IEEE802154_FC_INTRA_PAN)
> +			goto malformed;
> +		break;
> +
> +	case IEEE802154_ADDR_LONG:
> +		if (hdr + 2 > tail)
> +			goto malformed;
> +		if (fc & IEEE802154_FC_INTRA_PAN) {
> +			addr->pan_id = hdr[0] | (hdr[1] << 8);
> +			hdr += 2;
> +		}
> +
> +		if (hdr + IEEE802154_ADDR_LEN > tail)
> +			goto malformed;
> +		hdr += IEEE802154_ADDR_LEN;
> +		break;
> +
> +	case IEEE802154_ADDR_SHORT:
> +		if (hdr + 2 > tail)
> +			goto malformed;
> +		if (fc & IEEE802154_FC_INTRA_PAN) {
> +			addr->pan_id = hdr[0] | (hdr[1] << 8);
> +			hdr += 2;
> +		}
> +
> +		if (hdr + 2 > tail)
> +			goto malformed;
> +		hdr += 2;
> +		break;
> +
> +	default:
> +		goto malformed;
> +
> +	}
> +
> +	switch (addr->addr_type) {
> +	case IEEE802154_ADDR_NONE:
> +		break;
> +
> +	case IEEE802154_ADDR_LONG:
> +		if (hdr + 2 > tail)
> +			goto malformed;
> +		if (!(fc & IEEE802154_FC_INTRA_PAN)) {
> +			addr->pan_id = hdr[0] | (hdr[1] << 8);
> +			hdr += 2;
> +		}
> +
> +		if (hdr + IEEE802154_ADDR_LEN > tail)
> +			goto malformed;
> +		memcpy(addr->hwaddr, hdr, IEEE802154_ADDR_LEN);
> +		hdr += IEEE802154_ADDR_LEN;
> +		break;
> +
> +	case IEEE802154_ADDR_SHORT:
> +		if (hdr + 2 > tail)
> +			goto malformed;
> +		if (!(fc & IEEE802154_FC_INTRA_PAN)) {
> +			addr->pan_id = hdr[0] | (hdr[1] << 8);
> +			hdr += 2;
> +		}
> +
> +		if (hdr + 2 > tail)
> +			goto malformed;
> +		addr->short_addr = hdr[0] | (hdr[1] << 8);
> +		hdr += 2;
> +		break;
> +
> +	default:
> +		goto malformed;
> +
> +	}
> +
> +	return sizeof(struct ieee802154_addr);
> +
> +malformed:
> +	pr_debug("malformed packet\n");
> +	return 0;
> +}
> +
> +static struct header_ops ieee802154_header_ops = {
> +	.create		= ieee802154_header_create,
> +	.parse		= ieee802154_header_parse,
> +};
> +
> +static const struct net_device_ops ieee802154_slave_ops = {
> +	.ndo_open		= ieee802154_slave_open,
> +	.ndo_stop		= ieee802154_slave_close,
> +	.ndo_start_xmit		= ieee802154_net_xmit,
> +	.ndo_do_ioctl		= ieee802154_slave_ioctl,
> +	.ndo_set_mac_address	= ieee802154_slave_mac_addr,
> +};
> +
> +static void ieee802154_netdev_setup(struct net_device *dev)
> +{
> +	dev->addr_len		= IEEE802154_ADDR_LEN;
> +	memset(dev->broadcast, 0xff, IEEE802154_ADDR_LEN);
> +	dev->features		= NETIF_F_NO_CSUM;
> +	dev->hard_header_len	= 2 + 1 + 20 + 14;
> +	dev->header_ops		= &ieee802154_header_ops;
> +	dev->needed_tailroom	= 2; /* FCS */
> +	dev->mtu		= 127;
> +	dev->tx_queue_len	= 10;
> +	dev->type		= ARPHRD_IEEE802154;
> +	dev->flags		= IFF_NOARP | IFF_BROADCAST;
> +	dev->watchdog_timeo	= 0;
> +
> +	dev->destructor		= free_netdev;
> +	dev->netdev_ops		= &ieee802154_slave_ops;
> +	dev->ml_priv		= &mac802154_mlme;
> +}
> +
> +/*
> + * This is for hw unregistration only, as it doesn't do RCU locking

So this list is different than the RCU-protected one, and readers
always hold locks when traversing it?

I am not familiar with this code, so might be missing something, but
it looks to me like the same list that RCU readers traverse.  If so,
need list_del_rcu() and synchronize_rcu().

> + */
> +void ieee802154_drop_slaves(struct ieee802154_dev *hw)
> +{
> +	struct ieee802154_priv *priv = ieee802154_to_priv(hw);
> +	struct ieee802154_sub_if_data *sdata, *next;
> +
> +	ASSERT_RTNL();
> +
> +	list_for_each_entry_safe(sdata, next, &priv->slaves, list) {
> +		mutex_lock(&sdata->hw->slaves_mtx);
> +		list_del(&sdata->list);
> +		mutex_unlock(&sdata->hw->slaves_mtx);
> +
> +		dev_put(sdata->hw->netdev);
> +
> +		unregister_netdevice(sdata->dev);
> +	}
> +}
> +
> +static int ieee802154_netdev_validate(struct nlattr *tb[],
> +		struct nlattr *data[])
> +{
> +	if (tb[IFLA_ADDRESS])
> +		if (nla_len(tb[IFLA_ADDRESS]) != IEEE802154_ADDR_LEN)
> +			return -EINVAL;
> +
> +	if (tb[IFLA_BROADCAST])
> +		return -EINVAL;
> +
> +	return 0;
> +}
> +
> +static int ieee802154_netdev_newlink(struct net_device *dev,
> +					   struct nlattr *tb[],
> +					   struct nlattr *data[])
> +{
> +	struct net_device *mdev;
> +	struct ieee802154_sub_if_data *priv;
> +	struct ieee802154_priv *ipriv;
> +	int err;
> +
> +	if (!tb[IFLA_LINK])
> +		return -EOPNOTSUPP;
> +
> +	mdev = __dev_get_by_index(dev_net(dev), nla_get_u32(tb[IFLA_LINK]));
> +	if (!mdev)
> +		return -ENODEV;
> +
> +	if (mdev->type != ARPHRD_IEEE802154_PHY)
> +		return -EINVAL;
> +
> +	ipriv = netdev_priv(mdev);
> +
> +	priv = netdev_priv(dev);
> +	priv->dev = dev;
> +	priv->hw = ipriv;
> +
> +	rwlock_init(&priv->mib_lock);
> +
> +	get_random_bytes(&priv->bsn, 1);
> +	get_random_bytes(&priv->dsn, 1);
> +
> +	priv->pan_id = IEEE802154_PANID_BROADCAST;
> +	priv->short_addr = IEEE802154_ADDR_BROADCAST;
> +
> +	dev_hold(ipriv->netdev);
> +
> +	dev->needed_headroom = ipriv->hw.extra_tx_headroom;
> +
> +	SET_NETDEV_DEV(dev, &ipriv->netdev->dev);
> +
> +	err = register_netdevice(dev);
> +	if (err < 0)
> +		return err;
> +
> +	mutex_lock(&ipriv->slaves_mtx);
> +	list_add_tail_rcu(&priv->list, &ipriv->slaves);
> +	mutex_unlock(&ipriv->slaves_mtx);
> +
> +	return 0;
> +}
> +
> +static void ieee802154_netdev_dellink(struct net_device *dev)
> +{
> +	struct ieee802154_sub_if_data *sdata;
> +	ASSERT_RTNL();
> +
> +	BUG_ON(dev->type != ARPHRD_IEEE802154);
> +
> +	sdata = netdev_priv(dev);
> +
> +	mutex_lock(&sdata->hw->slaves_mtx);
> +	list_del_rcu(&sdata->list);
> +	mutex_unlock(&sdata->hw->slaves_mtx);
> +
> +	dev_put(sdata->hw->netdev);
> +
> +	synchronize_rcu();
> +	unregister_netdevice(sdata->dev);
> +}
> +
> +static size_t ieee802154_netdev_get_size(const struct net_device *dev)
> +{
> +	return	nla_total_size(2) +	/* IFLA_WPAN_CHANNEL */
> +		nla_total_size(2) +	/* IFLA_WPAN_PAN_ID */
> +		nla_total_size(2) +	/* IFLA_WPAN_SHORT_ADDR */
> +		nla_total_size(2) +	/* IFLA_WPAN_COORD_SHORT_ADDR */
> +		nla_total_size(8);	/* IFLA_WPAN_COORD_EXT_ADDR */
> +}
> +
> +static int ieee802154_netdev_fill_info(struct sk_buff *skb,
> +					const struct net_device *dev)
> +{
> +	struct ieee802154_sub_if_data *priv = netdev_priv(dev);
> +
> +	read_lock(&priv->mib_lock);
> +
> +	NLA_PUT_U16(skb, IFLA_WPAN_CHANNEL, priv->chan);
> +	NLA_PUT_U16(skb, IFLA_WPAN_PAN_ID, priv->pan_id);
> +	NLA_PUT_U16(skb, IFLA_WPAN_SHORT_ADDR, priv->short_addr);
> +	/* TODO: IFLA_WPAN_COORD_SHORT_ADDR */
> +	/* TODO: IFLA_WPAN_COORD_EXT_ADDR */
> +
> +	read_unlock(&priv->mib_lock);
> +
> +	return 0;
> +
> +nla_put_failure:
> +	read_unlock(&priv->mib_lock);
> +	return -EMSGSIZE;
> +}
> +
> +static struct rtnl_link_ops wpan_link_ops __read_mostly = {
> +	.kind		= "wpan",
> +	.priv_size	= sizeof(struct ieee802154_sub_if_data),
> +	.setup		= ieee802154_netdev_setup,
> +	.validate	= ieee802154_netdev_validate,
> +	.newlink	= ieee802154_netdev_newlink,
> +	.dellink	= ieee802154_netdev_dellink,
> +	.get_size	= ieee802154_netdev_get_size,
> +	.fill_info	= ieee802154_netdev_fill_info,
> +};
> +
> +static int ieee802154_process_beacon(struct net_device *dev,
> +		struct sk_buff *skb)
> +{
> +	pr_warning("ieee802154: beacon frames are not yet supported\n");
> +	kfree_skb(skb);
> +	return NET_RX_DROP;
> +}
> +
> +static int ieee802154_process_ack(struct net_device *dev, struct sk_buff *skb)
> +{
> +	pr_debug("got ACK for SEQ=%d\n", mac_cb(skb)->seq);
> +
> +	kfree_skb(skb);
> +	return NET_RX_SUCCESS;
> +}
> +
> +static int ieee802154_process_data(struct net_device *dev, struct sk_buff *skb)
> +{
> +	return netif_rx(skb);
> +}
> +
> +static int ieee802154_subif_frame(struct ieee802154_sub_if_data *sdata,
> +		struct sk_buff *skb)
> +{
> +	pr_debug("%s Getting packet via slave interface %s\n",
> +				__func__, sdata->dev->name);
> +
> +	read_lock(&sdata->mib_lock);
> +
> +	switch (mac_cb(skb)->da.addr_type) {
> +	case IEEE802154_ADDR_NONE:
> +		if (mac_cb(skb)->sa.addr_type != IEEE802154_ADDR_NONE)
> +			/* FIXME: check if we are PAN coordinator :) */
> +			skb->pkt_type = PACKET_OTHERHOST;
> +		else
> +			/* ACK comes with both addresses empty */
> +			skb->pkt_type = PACKET_HOST;
> +		break;
> +	case IEEE802154_ADDR_LONG:
> +		if (mac_cb(skb)->da.pan_id != sdata->pan_id &&
> +		    mac_cb(skb)->da.pan_id != IEEE802154_PANID_BROADCAST)
> +			skb->pkt_type = PACKET_OTHERHOST;
> +		else if (!memcmp(mac_cb(skb)->da.hwaddr, sdata->dev->dev_addr,
> +					IEEE802154_ADDR_LEN))
> +			skb->pkt_type = PACKET_HOST;
> +		else
> +			skb->pkt_type = PACKET_OTHERHOST;
> +		break;
> +	case IEEE802154_ADDR_SHORT:
> +		if (mac_cb(skb)->da.pan_id != sdata->pan_id &&
> +		    mac_cb(skb)->da.pan_id != IEEE802154_PANID_BROADCAST)
> +			skb->pkt_type = PACKET_OTHERHOST;
> +		else if (mac_cb(skb)->da.short_addr == sdata->short_addr)
> +			skb->pkt_type = PACKET_HOST;
> +		else if (mac_cb(skb)->da.short_addr ==
> +					IEEE802154_ADDR_BROADCAST)
> +			skb->pkt_type = PACKET_BROADCAST;
> +		else
> +			skb->pkt_type = PACKET_OTHERHOST;
> +		break;
> +	}
> +
> +	read_unlock(&sdata->mib_lock);
> +
> +	skb->dev = sdata->dev;
> +
> +	if (skb->pkt_type == PACKET_HOST && mac_cb_is_ackreq(skb) &&
> +			!(sdata->hw->hw.flags & IEEE802154_HW_AACK))
> +		dev_warn(&sdata->dev->dev,
> +			"ACK requested, however AACK not supported.\n");
> +
> +	switch (mac_cb_type(skb)) {
> +	case IEEE802154_FC_TYPE_BEACON:
> +		return ieee802154_process_beacon(sdata->dev, skb);
> +	case IEEE802154_FC_TYPE_ACK:
> +		return ieee802154_process_ack(sdata->dev, skb);
> +	case IEEE802154_FC_TYPE_MAC_CMD:
> +		return ieee802154_process_cmd(sdata->dev, skb);
> +	case IEEE802154_FC_TYPE_DATA:
> +		return ieee802154_process_data(sdata->dev, skb);
> +	default:
> +		pr_warning("ieee802154: Bad frame received (type = %d)\n",
> +				mac_cb_type(skb));
> +		kfree_skb(skb);
> +		return NET_RX_DROP;
> +	}
> +}
> +
> +static u8 fetch_skb_u8(struct sk_buff *skb)
> +{
> +	u8 ret;
> +
> +	BUG_ON(skb->len < 1);
> +
> +	ret = skb->data[0];
> +	skb_pull(skb, 1);
> +
> +	return ret;
> +}
> +
> +static u16 fetch_skb_u16(struct sk_buff *skb)
> +{
> +	u16 ret;
> +
> +	BUG_ON(skb->len < 2);
> +
> +	ret = skb->data[0] + (skb->data[1] * 256);
> +	skb_pull(skb, 2);
> +	return ret;
> +}
> +
> +static void fetch_skb_u64(struct sk_buff *skb, void *data)
> +{
> +	BUG_ON(skb->len < IEEE802154_ADDR_LEN);
> +
> +	memcpy(data, skb->data, IEEE802154_ADDR_LEN);
> +	skb_pull(skb, IEEE802154_ADDR_LEN);
> +}
> +
> +#define IEEE802154_FETCH_U8(skb, var)		\
> +	do {					\
> +		if (skb->len < 1)		\
> +			goto exit_error;	\
> +		var = fetch_skb_u8(skb);	\
> +	} while (0)
> +
> +#define IEEE802154_FETCH_U16(skb, var)		\
> +	do {					\
> +		if (skb->len < 2)		\
> +			goto exit_error;	\
> +		var = fetch_skb_u16(skb);	\
> +	} while (0)
> +
> +#define IEEE802154_FETCH_U64(skb, var)			\
> +	do {						\
> +		if (skb->len < IEEE802154_ADDR_LEN)	\
> +			goto exit_error;		\
> +		fetch_skb_u64(skb, &var);		\
> +	} while (0)
> +
> +static int parse_frame_start(struct sk_buff *skb)
> +{
> +	u8 *head = skb->data;
> +	u16 fc;
> +
> +	if (skb->len < 3) {
> +		pr_debug("frame size %d bytes is too short\n", skb->len);
> +		return -EINVAL;
> +	}
> +
> +	IEEE802154_FETCH_U16(skb, fc);
> +	IEEE802154_FETCH_U8(skb, mac_cb(skb)->seq);
> +
> +	pr_debug("%s: %04x dsn%02x\n", __func__, fc, head[2]);
> +
> +	mac_cb(skb)->flags = IEEE802154_FC_TYPE(fc);
> +
> +	if (fc & IEEE802154_FC_ACK_REQ) {
> +		pr_debug("%s(): ACKNOWLEDGE required\n", __func__);
> +		mac_cb(skb)->flags |= MAC_CB_FLAG_ACKREQ;
> +	}
> +
> +	if (fc & IEEE802154_FC_SECEN)
> +		mac_cb(skb)->flags |= MAC_CB_FLAG_SECEN;
> +
> +	if (fc & IEEE802154_FC_INTRA_PAN)
> +		mac_cb(skb)->flags |= MAC_CB_FLAG_INTRAPAN;
> +
> +	/* TODO */
> +	if (mac_cb_is_secen(skb)) {
> +		pr_info("security support is not implemented\n");
> +		return -EINVAL;
> +	}
> +
> +	mac_cb(skb)->sa.addr_type = IEEE802154_FC_SAMODE(fc);
> +	if (mac_cb(skb)->sa.addr_type == IEEE802154_ADDR_NONE)
> +		pr_debug("%s(): src addr_type is NONE\n", __func__);
> +
> +	mac_cb(skb)->da.addr_type = IEEE802154_FC_DAMODE(fc);
> +	if (mac_cb(skb)->da.addr_type == IEEE802154_ADDR_NONE)
> +		pr_debug("%s(): dst addr_type is NONE\n", __func__);
> +
> +	if (IEEE802154_FC_TYPE(fc) == IEEE802154_FC_TYPE_ACK) {
> +		/* ACK can only have NONE-type addresses */
> +		if (mac_cb(skb)->sa.addr_type != IEEE802154_ADDR_NONE ||
> +		    mac_cb(skb)->da.addr_type != IEEE802154_ADDR_NONE)
> +			return -EINVAL;
> +	}
> +
> +	if (mac_cb(skb)->da.addr_type != IEEE802154_ADDR_NONE) {
> +		IEEE802154_FETCH_U16(skb, mac_cb(skb)->da.pan_id);
> +
> +		if (mac_cb_is_intrapan(skb)) { /* ! panid compress */
> +			pr_debug("%s(): src IEEE802154_FC_INTRA_PAN\n",
> +					__func__);
> +			mac_cb(skb)->sa.pan_id = mac_cb(skb)->da.pan_id;
> +			pr_debug("%s(): src PAN address %04x\n",
> +					__func__, mac_cb(skb)->sa.pan_id);
> +		}
> +
> +		pr_debug("%s(): dst PAN address %04x\n",
> +				__func__, mac_cb(skb)->da.pan_id);
> +
> +		if (mac_cb(skb)->da.addr_type == IEEE802154_ADDR_SHORT) {
> +			IEEE802154_FETCH_U16(skb, mac_cb(skb)->da.short_addr);
> +			pr_debug("%s(): dst SHORT address %04x\n",
> +					__func__, mac_cb(skb)->da.short_addr);
> +
> +		} else {
> +			IEEE802154_FETCH_U64(skb, mac_cb(skb)->da.hwaddr);
> +			pr_debug("%s(): dst hardware addr\n", __func__);
> +		}
> +	}
> +
> +	if (mac_cb(skb)->sa.addr_type != IEEE802154_ADDR_NONE) {
> +		pr_debug("%s(): got src non-NONE address\n", __func__);
> +		if (!(mac_cb_is_intrapan(skb))) { /* ! panid compress */
> +			IEEE802154_FETCH_U16(skb, mac_cb(skb)->sa.pan_id);
> +			pr_debug("%s(): src IEEE802154_FC_INTRA_PAN\n",
> +					__func__);
> +		}
> +
> +		if (mac_cb(skb)->sa.addr_type == IEEE802154_ADDR_SHORT) {
> +			IEEE802154_FETCH_U16(skb, mac_cb(skb)->sa.short_addr);
> +			pr_debug("%s(): src IEEE802154_ADDR_SHORT\n",
> +					__func__);
> +		} else {
> +			IEEE802154_FETCH_U64(skb, mac_cb(skb)->sa.hwaddr);
> +			pr_debug("%s(): src hardware addr\n", __func__);
> +		}
> +	}
> +
> +	return 0;
> +
> +exit_error:
> +	return -EINVAL;
> +}
> +
> +void ieee802154_subif_rx(struct ieee802154_dev *hw, struct sk_buff *skb)
> +{
> +	struct ieee802154_priv *priv = ieee802154_to_priv(hw);
> +	struct ieee802154_sub_if_data *sdata, *prev = NULL;
> +	int ret;
> +
> +	BUILD_BUG_ON(sizeof(struct ieee802154_mac_cb) > sizeof(skb->cb));
> +	pr_debug("%s()\n", __func__);
> +
> +	if (!(priv->hw.flags & IEEE802154_HW_OMIT_CKSUM)) {
> +		u16 crc;
> +
> +		if (skb->len < 2) {
> +			pr_debug("%s(): Got invalid frame\n", __func__);
> +			goto out;
> +		}
> +		crc = crc_ccitt(0, skb->data, skb->len);
> +		if (crc) {
> +			pr_debug("%s(): CRC mismatch\n", __func__);
> +			goto out;
> +		}
> +		skb_trim(skb, skb->len - 2); /* CRC */
> +	}
> +
> +	ret = parse_frame_start(skb); /* 3 bytes pulled after this */
> +	if (ret) {
> +		pr_debug("%s(): Got invalid frame\n", __func__);
> +		goto out;
> +	}
> +
> +	pr_debug("%s() frame %d\n", __func__, mac_cb_type(skb));
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(sdata, &priv->slaves, list)
> +	{
> +		if (prev) {
> +			struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
> +			if (skb2)
> +				ieee802154_subif_frame(prev, skb2);
> +		}
> +
> +		prev = sdata;
> +	}
> +
> +	if (prev) {
> +		ieee802154_subif_frame(prev, skb);
> +		skb = NULL;
> +	}
> +
> +	rcu_read_unlock();
> +
> +out:
> +	dev_kfree_skb(skb);
> +	return;
> +}
> +
> +u16 ieee802154_dev_get_pan_id(struct net_device *dev)
> +{
> +	struct ieee802154_sub_if_data *priv = netdev_priv(dev);
> +	u16 ret;
> +
> +	BUG_ON(dev->type != ARPHRD_IEEE802154);
> +
> +	read_lock(&priv->mib_lock);
> +	ret = priv->pan_id;
> +	read_unlock(&priv->mib_lock);
> +
> +	return ret;
> +}
> +
> +u16 ieee802154_dev_get_short_addr(struct net_device *dev)
> +{
> +	struct ieee802154_sub_if_data *priv = netdev_priv(dev);
> +	u16 ret;
> +
> +	BUG_ON(dev->type != ARPHRD_IEEE802154);
> +
> +	read_lock(&priv->mib_lock);
> +	ret = priv->short_addr;
> +	read_unlock(&priv->mib_lock);
> +
> +	return ret;
> +}
> +
> +void ieee802154_dev_set_pan_id(struct net_device *dev, u16 val)
> +{
> +	struct ieee802154_sub_if_data *priv = netdev_priv(dev);
> +
> +	BUG_ON(dev->type != ARPHRD_IEEE802154);
> +
> +	write_lock(&priv->mib_lock);
> +	priv->pan_id = val;
> +	write_unlock(&priv->mib_lock);
> +}
> +void ieee802154_dev_set_short_addr(struct net_device *dev, u16 val)
> +{
> +	struct ieee802154_sub_if_data *priv = netdev_priv(dev);
> +
> +	BUG_ON(dev->type != ARPHRD_IEEE802154);
> +
> +	write_lock(&priv->mib_lock);
> +	priv->short_addr = val;
> +	write_unlock(&priv->mib_lock);
> +}
> +void ieee802154_dev_set_channel(struct net_device *dev, u8 val)
> +{
> +	struct ieee802154_sub_if_data *priv = netdev_priv(dev);
> +
> +	BUG_ON(dev->type != ARPHRD_IEEE802154);
> +
> +	write_lock(&priv->mib_lock);
> +	priv->chan = val;
> +	write_unlock(&priv->mib_lock);
> +}
> +
> +u8 ieee802154_dev_get_dsn(struct net_device *dev)
> +{
> +	struct ieee802154_sub_if_data *priv = netdev_priv(dev);
> +	u16 ret;
> +
> +	BUG_ON(dev->type != ARPHRD_IEEE802154);
> +
> +	write_lock(&priv->mib_lock);
> +	ret = priv->dsn++;
> +	write_unlock(&priv->mib_lock);
> +
> +	return ret;
> +}
> +
> +u8 ieee802154_dev_get_bsn(struct net_device *dev)
> +{
> +	struct ieee802154_sub_if_data *priv = netdev_priv(dev);
> +	u16 ret;
> +
> +	BUG_ON(dev->type != ARPHRD_IEEE802154);
> +
> +	write_lock(&priv->mib_lock);
> +	ret = priv->bsn++;
> +	write_unlock(&priv->mib_lock);
> +
> +	return ret;
> +}
> +
> +static int __init ieee802154_dev_init(void)
> +{
> +	return rtnl_link_register(&wpan_link_ops);
> +}
> +module_init(ieee802154_dev_init);
> +
> +static void __exit ieee802154_dev_exit(void)
> +{
> +	rtnl_link_unregister(&wpan_link_ops);
> +}
> +module_exit(ieee802154_dev_exit);
> +
> +MODULE_ALIAS_RTNL_LINK("wpan");
> +
> diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
> new file mode 100644
> index 0000000..f4e8d29
> --- /dev/null
> +++ b/net/mac802154/mac802154.h
> @@ -0,0 +1,85 @@
> +/*
> + * Copyright (C) 2007, 2008 Siemens AG
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License along
> + * with this program; if not, write to the Free Software Foundation, Inc.,
> + * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
> + *
> + * Written by:
> + * Pavel Smolenskiy <pavel.smolenskiy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> + * Maxim Gorbachyov <maxim.gorbachev-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org>
> + * Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> + */
> +#ifndef MAC802154_H
> +#define MAC802154_H
> +
> +#include <linux/spinlock.h>
> +struct ieee802154_priv {
> +	struct ieee802154_dev	hw;
> +	struct ieee802154_ops	*ops;
> +
> +	struct net_device *netdev; /* mwpanX device */
> +	int open_count;
> +	/* As in mac80211 slaves list is modified:
> +	 * 1) under the RTNL
> +	 * 2) protected by slaves_mtx;
> +	 * 3) in an RCU manner
> +	 *
> +	 * So atomic readers can use any of this protection methods
> +	 */
> +	struct list_head	slaves;
> +	struct mutex		slaves_mtx;
> +	/* This one is used for scanning and other
> +	 * jobs not to be interfered with serial driver */
> +	struct workqueue_struct	*dev_workqueue;
> +};
> +
> +#define ieee802154_to_priv(_hw)	container_of(_hw, struct ieee802154_priv, hw)
> +
> +struct ieee802154_sub_if_data {
> +	struct list_head list; /* the ieee802154_priv->slaves list */
> +
> +	struct ieee802154_priv *hw;
> +	struct net_device *dev;
> +
> +	rwlock_t mib_lock;
> +
> +	u16 pan_id;
> +	u16 short_addr;
> +
> +	u8 chan;
> +
> +	/* MAC BSN field */
> +	u8 bsn;
> +	/* MAC BSN field */
> +	u8 dsn;
> +};
> +
> +void ieee802154_drop_slaves(struct ieee802154_dev *hw);
> +
> +void ieee802154_subif_rx(struct ieee802154_dev *hw, struct sk_buff *skb);
> +
> +struct ieee802154_phy_cb {
> +	u8 lqi;
> +	u8 chan;
> +};
> +
> +static inline struct ieee802154_phy_cb *phy_cb(struct sk_buff *skb)
> +{
> +	return (struct ieee802154_phy_cb *)skb->cb;
> +}
> +
> +extern struct ieee802154_mlme_ops mac802154_mlme;
> +
> +int ieee802154_process_cmd(struct net_device *dev, struct sk_buff *skb);
> +
> +#endif
> diff --git a/net/mac802154/mac_cmd.c b/net/mac802154/mac_cmd.c
> new file mode 100644
> index 0000000..8941628
> --- /dev/null
> +++ b/net/mac802154/mac_cmd.c
> @@ -0,0 +1,99 @@
> +/*
> + * MAC commands interface
> + *
> + * Copyright 2007, 2008 Siemens AG
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License along
> + * with this program; if not, write to the Free Software Foundation, Inc.,
> + * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
> + *
> + * Written by:
> + * Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
> + * Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/skbuff.h>
> +#include <linux/if_arp.h>
> +#include <net/af_ieee802154.h>
> +#include <net/mac802154.h>
> +#include <net/ieee802154.h>
> +#include <net/ieee802154_netdev.h>
> +#include <net/nl802154.h>
> +
> +#include "mac802154.h"
> +#include "mib.h"
> +
> +int ieee802154_process_cmd(struct net_device *dev, struct sk_buff *skb)
> +{
> +	pr_warning("ieee802154: command frames are not yet supported\n");
> +	kfree_skb(skb);
> +	return NET_RX_DROP;
> +}
> +
> +
> +static int ieee802154_mlme_assoc_req(struct net_device *dev,
> +		struct ieee802154_addr *addr, u8 channel, u8 cap)
> +{
> +	/* We simply emulate it here */
> +	return ieee802154_nl_assoc_confirm(dev,
> +			ieee802154_dev_get_short_addr(dev),
> +			IEEE802154_SUCCESS);
> +}
> +
> +static int ieee802154_mlme_assoc_resp(struct net_device *dev,
> +		struct ieee802154_addr *addr, u16 short_addr, u8 status)
> +{
> +	return 0;
> +}
> +
> +static int ieee802154_mlme_disassoc_req(struct net_device *dev,
> +		struct ieee802154_addr *addr, u8 reason)
> +{
> +	return ieee802154_nl_disassoc_confirm(dev, IEEE802154_SUCCESS);
> +}
> +
> +static int ieee802154_mlme_start_req(struct net_device *dev,
> +				struct ieee802154_addr *addr,
> +				u8 channel,
> +				u8 bcn_ord, u8 sf_ord, u8 pan_coord, u8 blx,
> +				u8 coord_realign)
> +{
> +	/* We don't emulate beacons here at all, so START should fail */
> +	ieee802154_nl_start_confirm(dev, IEEE802154_INVALID_PARAMETER);
> +	return 0;
> +}
> +
> +static int ieee802154_mlme_scan_req(struct net_device *dev, u8 type,
> +		u32 channels,
> +		u8 duration)
> +{
> +	u8 edl[27] = {};
> +	return ieee802154_nl_scan_confirm(dev, IEEE802154_SUCCESS, type,
> +			channels,
> +			type == IEEE802154_MAC_SCAN_ED ? edl : NULL);
> +}
> +
> +
> +struct ieee802154_mlme_ops mac802154_mlme = {
> +	.assoc_req = ieee802154_mlme_assoc_req,
> +	.assoc_resp = ieee802154_mlme_assoc_resp,
> +	.disassoc_req = ieee802154_mlme_disassoc_req,
> +	.start_req = ieee802154_mlme_start_req,
> +	.scan_req = ieee802154_mlme_scan_req,
> +
> +	.get_pan_id = ieee802154_dev_get_pan_id,
> +	.get_short_addr = ieee802154_dev_get_short_addr,
> +	.get_dsn = ieee802154_dev_get_dsn,
> +	.get_bsn = ieee802154_dev_get_bsn,
> +};
> +
> diff --git a/net/mac802154/mdev.c b/net/mac802154/mdev.c
> new file mode 100644
> index 0000000..191e942
> --- /dev/null
> +++ b/net/mac802154/mdev.c
> @@ -0,0 +1,295 @@
> +/*
> + * Copyright (C) 2007, 2008 Siemens AG
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License along
> + * with this program; if not, write to the Free Software Foundation, Inc.,
> + * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
> + *
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/netdevice.h>
> +#include <linux/if_arp.h>
> +#include <net/route.h>
> +
> +#include <net/af_ieee802154.h>
> +#include <net/mac802154.h>
> +
> +#include "mac802154.h"
> +
> +struct xmit_work {
> +	struct sk_buff *skb;
> +	struct work_struct work;
> +	struct ieee802154_priv *priv;
> +};
> +
> +static void ieee802154_xmit_worker(struct work_struct *work)
> +{
> +	struct xmit_work *xw = container_of(work, struct xmit_work, work);
> +	int res;
> +
> +	if (xw->priv->hw.current_channel != phy_cb(xw->skb)->chan) {
> +		res = xw->priv->ops->set_channel(&xw->priv->hw,
> +				phy_cb(xw->skb)->chan);
> +		if (res) {
> +			pr_debug("set_channel failed\n");
> +			goto out;
> +		}
> +	}
> +
> +	res = xw->priv->ops->xmit(&xw->priv->hw, xw->skb);
> +
> +out:
> +	/* FIXME: result processing and/or requeue!!! */
> +	dev_kfree_skb(xw->skb);
> +
> +	kfree(xw);
> +}
> +
> +static int ieee802154_master_hard_start_xmit(struct sk_buff *skb,
> +		struct net_device *dev)
> +{
> +	struct ieee802154_priv *priv = netdev_priv(dev);
> +	struct xmit_work *work;
> +
> +	if (skb_cow_head(skb, priv->hw.extra_tx_headroom)) {
> +		dev_kfree_skb(skb);
> +		return NETDEV_TX_OK;
> +	}
> +
> +	work = kzalloc(sizeof(struct xmit_work), GFP_ATOMIC);
> +	if (!work)
> +		return NETDEV_TX_BUSY;
> +
> +	INIT_WORK(&work->work, ieee802154_xmit_worker);
> +	work->skb = skb;
> +	work->priv = priv;
> +
> +	queue_work(priv->dev_workqueue, &work->work);
> +
> +	return NETDEV_TX_OK;
> +}
> +
> +static int ieee802154_master_open(struct net_device *dev)
> +{
> +	int rc;
> +	struct ieee802154_priv *priv = netdev_priv(dev);
> +
> +	if (!priv) {
> +		pr_debug("%s:%s: unable to get master private data\n",
> +				__FILE__, __func__);
> +		return -ENODEV;
> +	}
> +
> +	if (!priv->open_count)
> +		return -EOPNOTSUPP;
> +
> +	rc = priv->ops->start(&priv->hw);
> +
> +	if (!rc)
> +		netif_tx_start_all_queues(dev);
> +
> +	return rc;
> +}
> +
> +static int ieee802154_master_close(struct net_device *dev)
> +{
> +	struct ieee802154_priv *priv = netdev_priv(dev);
> +	struct ieee802154_sub_if_data *sdata;
> +
> +	ASSERT_RTNL();
> +
> +	/* We are under RTNL, so it's fine to do this */
> +	list_for_each_entry(sdata, &priv->slaves, list)
> +		if (netif_running(sdata->dev))
> +			dev_close(sdata->dev);
> +
> +	priv->ops->stop(&priv->hw);
> +
> +	return 0;
> +}
> +
> +static ssize_t ieee802154_netdev_show(const struct device *dev,
> +		   struct device_attribute *attr, char *buf,
> +		   ssize_t (*format)(const struct net_device *, char *))
> +{
> +	struct net_device *netdev = to_net_dev(dev);
> +	ssize_t ret = -EINVAL;
> +
> +	if (netdev->reg_state <= NETREG_REGISTERED)
> +		ret = (*format)(netdev, buf);
> +
> +	return ret;
> +}
> +#define MASTER_SHOW(field, format_string)				\
> +static ssize_t format_##field(const struct net_device *dev, char *buf)	\
> +{									\
> +	struct ieee802154_priv *priv = netdev_priv(dev);		\
> +	return sprintf(buf, format_string, priv->hw.field);		\
> +}									\
> +static ssize_t show_##field(struct device *dev,				\
> +			    struct device_attribute *attr, char *buf)	\
> +{									\
> +	return ieee802154_netdev_show(dev, attr, buf, format_##field);	\
> +}									\
> +static DEVICE_ATTR(field, S_IRUGO, show_##field, NULL)
> +
> +static const char fmt_long_hex[] = "%#lx\n";
> +static const char fmt_hex[] = "%#x\n";
> +static const char fmt_dec[] = "%d\n";
> +
> +MASTER_SHOW(current_channel, fmt_dec);
> +MASTER_SHOW(channel_mask, fmt_hex);
> +
> +static struct attribute *pmib_attrs[] = {
> +	&dev_attr_current_channel.attr,
> +	&dev_attr_channel_mask.attr,
> +	NULL
> +};
> +
> +static struct attribute_group pmib_group = {
> +	.name  = "pib",
> +	.attrs  = pmib_attrs,
> +};
> +
> +static const struct net_device_ops ieee802154_master_ops = {
> +	.ndo_open		= ieee802154_master_open,
> +	.ndo_stop		= ieee802154_master_close,
> +	.ndo_start_xmit		= ieee802154_master_hard_start_xmit,
> +};
> +
> +static void ieee802154_netdev_setup_master(struct net_device *dev)
> +{
> +	dev->addr_len		= 0;
> +	dev->features		= NETIF_F_NO_CSUM;
> +	dev->hard_header_len	= 0;
> +	dev->mtu		= 127;
> +	dev->tx_queue_len	= 0;
> +	dev->type		= ARPHRD_IEEE802154_PHY;
> +	dev->flags		= IFF_NOARP | IFF_BROADCAST;
> +	dev->watchdog_timeo	= 0;
> +
> +	dev->netdev_ops = &ieee802154_master_ops;
> +}
> +
> +struct ieee802154_dev *ieee802154_alloc_device(size_t priv_size,
> +		struct ieee802154_ops *ops)
> +{
> +	struct net_device *dev;
> +	struct ieee802154_priv *priv;
> +
> +	dev = alloc_netdev(ALIGN(sizeof(*priv), NETDEV_ALIGN) + priv_size,
> +			"mwpan%d", ieee802154_netdev_setup_master);
> +	if (!dev) {
> +		printk(KERN_ERR
> +			"Failure to initialize master IEEE802154 device\n");
> +		return NULL;
> +	}
> +	priv = netdev_priv(dev);
> +	priv->netdev = dev;
> +	priv->hw.priv = (char *)priv + ALIGN(sizeof(*priv), NETDEV_ALIGN);
> +
> +	BUG_ON(!dev);
> +	BUG_ON(!ops);
> +	BUG_ON(!ops->xmit);
> +	BUG_ON(!ops->ed);
> +	BUG_ON(!ops->start);
> +	BUG_ON(!ops->stop);
> +
> +	if (!try_module_get(ops->owner)) {
> +		free_netdev(dev);
> +		return NULL;
> +	}
> +
> +	priv->ops = ops;
> +
> +	INIT_LIST_HEAD(&priv->slaves);
> +	mutex_init(&priv->slaves_mtx);
> +
> +	return &priv->hw;
> +}
> +EXPORT_SYMBOL(ieee802154_alloc_device);
> +
> +void ieee802154_free_device(struct ieee802154_dev *hw)
> +{
> +	struct ieee802154_priv *priv = ieee802154_to_priv(hw);
> +
> +	BUG_ON(!list_empty(&priv->slaves));
> +	BUG_ON(!priv->netdev);
> +
> +	module_put(priv->ops->owner);
> +
> +	free_netdev(priv->netdev);
> +}
> +EXPORT_SYMBOL(ieee802154_free_device);
> +
> +int ieee802154_register_device(struct ieee802154_dev *dev)
> +{
> +	struct ieee802154_priv *priv = ieee802154_to_priv(dev);
> +	struct net_device *ndev = priv->netdev;
> +
> +	int rc;
> +
> +	rtnl_lock();
> +	if (strchr(ndev->name, '%')) {
> +		rc = dev_alloc_name(ndev, ndev->name);
> +		if (rc < 0)
> +			goto out_unlock;
> +	}
> +
> +	priv->dev_workqueue =
> +		create_singlethread_workqueue(ndev->name);
> +	if (!priv->dev_workqueue) {
> +		rc = -ENOMEM;
> +		goto out_unlock;
> +	}
> +
> +	ndev->needed_headroom = priv->hw.extra_tx_headroom;
> +	SET_NETDEV_DEV(ndev, priv->hw.parent);
> +
> +	ndev->sysfs_groups[1] = &pmib_group;
> +
> +	rc = register_netdevice(ndev);
> +	if (rc < 0)
> +		goto out_wq;
> +
> +	rtnl_unlock();
> +
> +	return 0;
> +
> +out_wq:
> +	destroy_workqueue(priv->dev_workqueue);
> +out_unlock:
> +	rtnl_unlock();
> +	return rc;
> +}
> +EXPORT_SYMBOL(ieee802154_register_device);
> +
> +void ieee802154_unregister_device(struct ieee802154_dev *dev)
> +{
> +	struct ieee802154_priv *priv = ieee802154_to_priv(dev);
> +
> +	flush_workqueue(priv->dev_workqueue);
> +	destroy_workqueue(priv->dev_workqueue);
> +
> +	rtnl_lock();
> +
> +	ieee802154_drop_slaves(dev);
> +	unregister_netdevice(priv->netdev);
> +
> +	rtnl_unlock();
> +}
> +EXPORT_SYMBOL(ieee802154_unregister_device);
> +
> +MODULE_DESCRIPTION("IEEE 802.15.4 implementation");
> +MODULE_LICENSE("GPL v2");
> +
> diff --git a/net/mac802154/mib.h b/net/mac802154/mib.h
> new file mode 100644
> index 0000000..57bf03f
> --- /dev/null
> +++ b/net/mac802154/mib.h
> @@ -0,0 +1,32 @@
> +/*
> + * Copyright 2008 Siemens AG
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License along
> + * with this program; if not, write to the Free Software Foundation, Inc.,
> + * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
> + *
> + */
> +
> +#ifndef MIB802154_H
> +#define MIB802154_H
> +
> +/* FIXME: should be dropped in favour of generic MIB API */
> +u8 ieee802154_dev_get_dsn(struct net_device *dev);
> +u8 ieee802154_dev_get_bsn(struct net_device *dev);
> +u16 ieee802154_dev_get_pan_id(struct net_device *dev);
> +u16 ieee802154_dev_get_short_addr(struct net_device *dev);
> +void ieee802154_dev_set_pan_id(struct net_device *dev, u16 val);
> +void ieee802154_dev_set_short_addr(struct net_device *dev, u16 val);
> +void ieee802154_dev_set_channel(struct net_device *dev, u8 chan);
> +
> +
> +#endif
> diff --git a/net/mac802154/rx.c b/net/mac802154/rx.c
> new file mode 100644
> index 0000000..81a269e
> --- /dev/null
> +++ b/net/mac802154/rx.c
> @@ -0,0 +1,98 @@
> +/*
> + * Copyright (C) 2007, 2008, 2009 Siemens AG
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License along
> + * with this program; if not, write to the Free Software Foundation, Inc.,
> + * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
> + *
> + * Written by:
> + * Pavel Smolenskiy <pavel.smolenskiy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> + * Maxim Gorbachyov <maxim.gorbachev-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org>
> + * Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/workqueue.h>
> +#include <linux/netdevice.h>
> +
> +#include <net/mac802154.h>
> +
> +#include "mac802154.h"
> +
> +static void __ieee802154_rx_prepare(struct ieee802154_dev *dev,
> +		struct sk_buff *skb, u8 lqi)
> +{
> +	struct ieee802154_priv *priv = ieee802154_to_priv(dev);
> +
> +	BUG_ON(!skb);
> +
> +	phy_cb(skb)->lqi = lqi;
> +
> +	skb->dev = priv->netdev;
> +
> +	skb->iif = skb->dev->ifindex;
> +
> +	skb->protocol = htons(ETH_P_IEEE802154);
> +
> +	skb_reset_mac_header(skb);
> +}
> +
> +void ieee802154_rx(struct ieee802154_dev *dev, struct sk_buff *skb, u8 lqi)
> +{
> +	struct sk_buff *skb2;
> +
> +	__ieee802154_rx_prepare(dev, skb, lqi);
> +
> +	skb2 = skb_clone(skb, GFP_KERNEL);
> +	netif_rx(skb2);
> +
> +	ieee802154_subif_rx(dev, skb);
> +}
> +EXPORT_SYMBOL(ieee802154_rx);
> +
> +struct rx_work {
> +	struct sk_buff *skb;
> +	struct work_struct work;
> +	struct ieee802154_dev *dev;
> +};
> +
> +static void ieee802154_rx_worker(struct work_struct *work)
> +{
> +	struct rx_work *rw = container_of(work, struct rx_work, work);
> +	struct sk_buff *skb = rw->skb;
> +
> +	struct sk_buff *skb2 = skb_clone(skb, GFP_KERNEL);
> +	netif_rx(skb2);
> +
> +	ieee802154_subif_rx(rw->dev, skb);
> +	kfree(rw);
> +}
> +
> +void ieee802154_rx_irqsafe(struct ieee802154_dev *dev,
> +		struct sk_buff *skb, u8 lqi)
> +{
> +	struct ieee802154_priv *priv = ieee802154_to_priv(dev);
> +	struct rx_work *work = kzalloc(sizeof(struct rx_work), GFP_ATOMIC);
> +
> +	if (!work)
> +		return;
> +
> +	__ieee802154_rx_prepare(dev, skb, lqi);
> +
> +	INIT_WORK(&work->work, ieee802154_rx_worker);
> +	work->skb = skb;
> +	work->dev = dev;
> +
> +	queue_work(priv->dev_workqueue, &work->work);
> +}
> +EXPORT_SYMBOL(ieee802154_rx_irqsafe);
> -- 
> 1.6.3.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
