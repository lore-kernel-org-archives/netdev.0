From: Mark Lord <kernel@teksavvy.com>
Subject: Re: [PATCH v2] drivers/net/usb/asix:  resync from vendor's copy
Date: Wed, 09 Nov 2011 12:43:06 -0500
Message-ID: <4EBABBAA.5010406@teksavvy.com>
References: <4EA89972.5060101@teksavvy.com> <20111026.194045.2019668159403582571.davem@davemloft.net> <4EA8B283.3010105@teksavvy.com> <20111026.221719.2216112919297458522.davem@davemloft.net> <4EB19BBE.5050602@teksavvy.com> <4EBAB8F5.1010101@teksavvy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	Michal Marek <mmarek@suse.cz>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EBAB8F5.1010101@teksavvy.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11-11-09 12:31 PM, Mark Lord wrote:
> Second pass (for review) at updating the in-kernel asix usb/network driver
> from the v4.1.0 vendor GPL version of the driver, obtained from here:
>
>   http://www.asix.com.tw/download.php?sub=searchresult&PItemID=84&download=driver
>
> The original vendor copy used a local "axusbnet" middleware (rather than "usbnet").
> I've converted it back to using "usbnet", made a ton of cosmetic changes
> to get it to pass checkpatch.pl, and removed a small amount of code duplication.
>
> The tx/rx checksum code has been updated per Ben's comments,
> and the duplicated MII_* definitions have been removed.
> I've changed the version string to be "4.1.0-kernel",
> to reflect the vendor's code version while also distinguishing
> this port from the original vendor code.
>
> It can use more work going forward, but it is important to get it upstream
> sooner than later -- the current in-kernel driver fails with many devices,
> both old and new.  This updated version works with everything I have available
> to test with, and also handles suspend / resume (unlike the in-kernel one).
>
> Signed-off-by: Mark Lord <mlord@pobox.com>
> ---
> Note that the vendor now has a v4.2.0 version available,
> but for now I'm concentrating on the original v4.1.0 code.
>
> After review/discussion of this patch, I will update for Linux-3.2-rc
> and resubmit for inclusion in the eventual linux-3.3 kernel.
..

And again, for ease of reviewing, the entire patched asix.c file is here:



/*
 * ASIX AX8817X based USB 2.0 Ethernet Devices
 * Copyright (C) 2003-2006 David Hollis <dhollis@davehollis.com>
 * Copyright (C) 2005 Phil Chang <pchang23@sbcglobal.net>
 * Copyright (C) 2006 James Painter <jamie.painter@iname.com>
 * Copyright (c) 2002-2003 TiVo Inc.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <linux/module.h>
#include <linux/kmod.h>
#include <linux/sched.h>
#include <linux/init.h>
#include <linux/netdevice.h>
#include <linux/etherdevice.h>
#include <linux/ethtool.h>
#include <linux/workqueue.h>
#include <linux/mii.h>
#include <linux/usb.h>
#include <linux/crc32.h>
#include <linux/usb/usbnet.h>
#include "asix.h"

#define DRIVER_VERSION	"4.1.0-kernel"
static const char driver_name[] = "asix";

static char driver_version[] =
	"ASIX USB Ethernet Adapter: v" DRIVER_VERSION "\n";

/* configuration of maximum bulk in size */
static int bsize = AX88772B_MAX_BULKIN_16K;
module_param(bsize, int, 0);
MODULE_PARM_DESC(bsize, "Maximum transfer size per bulk");

static void ax88772b_link_reset(struct work_struct *work);
static void ax88772a_link_reset(struct work_struct *work);
static void ax88772_link_reset(struct work_struct *work);
static int ax88772a_phy_powerup(struct usbnet *dev);

/* ASIX AX8817X based USB 2.0 Ethernet Devices */

static int ax8817x_read_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
			    u16 size, void *data)
{
	return usb_control_msg(
		dev->udev,
		usb_rcvctrlpipe(dev->udev, 0),
		cmd,
		USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
		value,
		index,
		data,
		size,
		USB_CTRL_GET_TIMEOUT);
}

static int ax8817x_write_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
			     u16 size, void *data)
{
	return usb_control_msg(
		dev->udev,
		usb_sndctrlpipe(dev->udev, 0),
		cmd,
		USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
		value,
		index,
		data,
		size,
		USB_CTRL_SET_TIMEOUT);
}

static void ax8817x_async_cmd_callback(struct urb *urb)
{
	struct usb_ctrlrequest *req = (struct usb_ctrlrequest *)urb->context;

	if (urb->status < 0)
		printk(KERN_DEBUG "ax8817x_async_cmd_callback() failed with %d",
			urb->status);

	kfree(req);
	usb_free_urb(urb);
}

static int ax8817x_set_mac_addr(struct net_device *net, void *p)
{
	struct usbnet *dev = netdev_priv(net);
	struct sockaddr *addr = p;

	memcpy(net->dev_addr, addr->sa_data, ETH_ALEN);

	/* Set the MAC address */
	return ax8817x_write_cmd(dev, AX88772_CMD_WRITE_NODE_ID,
			   0, 0, ETH_ALEN, net->dev_addr);

}

static void ax8817x_status(struct usbnet *dev, struct urb *urb)
{
	struct ax88172_int_data *event;
	int link;

	if (urb->actual_length < 8)
		return;

	event = urb->transfer_buffer;
	link = event->link & 0x01;

	if (netif_carrier_ok(dev->net) != link) {
		if (link) {
			netif_carrier_on(dev->net);
			usbnet_defer_kevent(dev, EVENT_LINK_RESET);
		} else
			netif_carrier_off(dev->net);
		netdev_warn(dev->net, "%s: link status is: %d\n",
						__func__, link);
	}
}

static void ax88178_status(struct usbnet *dev, struct urb *urb)
{
	struct ax88178_data *priv = (struct ax88178_data *)dev->driver_priv;

	if (priv->EepromData == PHY_MODE_MAC_TO_MAC_GMII)
		return;
	ax8817x_status(dev, urb);
}

static void ax88772_status(struct usbnet *dev, struct urb *urb)
{
	struct ax88172_int_data *event;
	struct ax88772_data *priv = (struct ax88772_data *)dev->driver_priv;
	int link;

	if (urb->actual_length < 8)
		return;

	event = urb->transfer_buffer;
	link = event->link & 0x01;

	if (netif_carrier_ok(dev->net) != link) {
		if (link) {
			netif_carrier_on(dev->net);
			priv->Event = AX_SET_RX_CFG;
		} else {
			netif_carrier_off(dev->net);
			if (priv->Event == AX_NOP) {
				priv->Event = PHY_POWER_DOWN;
				priv->TickToExpire = 25;
			}
		}
		netdev_warn(dev->net, "%s: link status is: %d\n",
						__func__, link);
	}

	if (priv->Event)
		queue_work(priv->ax_work, &priv->check_link);
}

static void ax88772a_status(struct usbnet *dev, struct urb *urb)
{
	struct ax88172_int_data *event;
	struct ax88772a_data *priv = (struct ax88772a_data *)dev->driver_priv;
	int link;
	int PowSave = (priv->EepromData >> 14);

	if (urb->actual_length < 8)
		return;

	event = urb->transfer_buffer;
	link = event->link & 0x01;

	if (netif_carrier_ok(dev->net) != link) {

		if (link) {
			netif_carrier_on(dev->net);
			priv->Event = AX_SET_RX_CFG;
		} else if ((PowSave == 0x3) || (PowSave == 0x1)) {
			netif_carrier_off(dev->net);
			if (priv->Event == AX_NOP) {
				priv->Event = CHK_CABLE_EXIST;
				priv->TickToExpire = 14;
			}
		} else {
			netif_carrier_off(dev->net);
			priv->Event = AX_NOP;
		}
		netdev_warn(dev->net, "%s: link status is: %d\n",
						__func__, link);
	}

	if (priv->Event)
		queue_work(priv->ax_work, &priv->check_link);
}

static void ax88772b_status(struct usbnet *dev, struct urb *urb)
{
	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
	struct ax88172_int_data *event;
	int link;

	if (urb->actual_length < 8)
		return;

	event = urb->transfer_buffer;
	link = event->link & AX_INT_PPLS_LINK;
	if (netif_carrier_ok(dev->net) != link) {
		if (link) {
			netif_carrier_on(dev->net);
			priv->Event = AX_SET_RX_CFG;
		} else {
			netif_carrier_off(dev->net);
			priv->time_to_chk = jiffies;
		}
		netdev_warn(dev->net, "%s: link status is: %d\n",
						__func__, link);
	}

	if (!link) {
		int no_cable = (event->link & AX_INT_CABOFF_UNPLUG) ? 1 : 0;

		if (no_cable) {
			if ((priv->psc &
			    (AX_SWRESET_IPPSL_0 | AX_SWRESET_IPPSL_1)) &&
			     !priv->pw_enabled) {
				/*
				 * AX88772B already entered power saving state
				 */
				priv->pw_enabled = 1;
			}

		} else {
			/* AX88772B resumed from power saving state */
			if (priv->pw_enabled ||
				(jiffies >
				   (priv->time_to_chk + AX88772B_WATCHDOG))) {
				if (priv->pw_enabled)
					priv->pw_enabled = 0;
				priv->Event = PHY_POWER_UP;
				priv->time_to_chk = jiffies;
			}
		}
	}

	if (priv->Event)
		queue_work(priv->ax_work, &priv->check_link);
}

static void
ax8817x_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value, u16 index,
				    u16 size, void *data)
{
	struct usb_ctrlrequest *req;
	int status;
	struct urb *urb;

	urb = usb_alloc_urb(0, GFP_ATOMIC);
	if (urb == NULL) {
		netdev_err(dev->net, "%s: usb_alloc_urb() failed\n", __func__);
		return;
	}

	req = kmalloc(sizeof(struct usb_ctrlrequest), GFP_ATOMIC);
	if (req == NULL) {
		netdev_err(dev->net, "%s: kmalloc() failed\n", __func__);
		usb_free_urb(urb);
		return;
	}

	req->bRequestType = USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE;
	req->bRequest = cmd;
	req->wValue = cpu_to_le16(value);
	req->wIndex = cpu_to_le16(index);
	req->wLength = cpu_to_le16(size);

	usb_fill_control_urb(urb, dev->udev,
			     usb_sndctrlpipe(dev->udev, 0),
			     (void *)req, data, size,
			     ax8817x_async_cmd_callback, req);

	status = usb_submit_urb(urb, GFP_ATOMIC);
	if (status < 0) {
		netdev_err(dev->net, "%s: usb_submit_urb() failed, err=%d\n",
						__func__, status);
		kfree(req);
		usb_free_urb(urb);
	}
}

static void ax8817x_set_multicast(struct net_device *net)
{
	struct usbnet *dev = netdev_priv(net);
	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;
	u8 rx_ctl = AX_RX_CTL_START | AX_RX_CTL_AB;
	int mc_count;

	mc_count = netdev_mc_count(net);

	if (net->flags & IFF_PROMISC) {
		rx_ctl |= AX_RX_CTL_PRO;
	} else if (net->flags & IFF_ALLMULTI
		   || mc_count > AX_MAX_MCAST) {
		rx_ctl |= AX_RX_CTL_AMALL;
	} else if (mc_count == 0) {
		/* just broadcast and directed */
	} else {
		/* We use the 20 byte dev->data
		 * for our 8 byte filter buffer
		 * to avoid allocating memory that
		 * is tricky to free later */
		u32 crc_bits;
		struct netdev_hw_addr *ha;
		memset(data->multi_filter, 0, AX_MCAST_FILTER_SIZE);
		netdev_for_each_mc_addr(ha, net) {
			crc_bits = ether_crc(ETH_ALEN, ha->addr) >> 26;
			data->multi_filter[crc_bits >> 3] |=
				1 << (crc_bits & 7);
		}
		ax8817x_write_cmd_async(dev, AX_CMD_WRITE_MULTI_FILTER, 0, 0,
				   AX_MCAST_FILTER_SIZE, data->multi_filter);

		rx_ctl |= AX_RX_CTL_AM;
	}

	ax8817x_write_cmd_async(dev, AX_CMD_WRITE_RX_CTL, rx_ctl, 0, 0, NULL);
}

static void ax88772b_set_multicast(struct net_device *net)
{
	struct usbnet *dev = netdev_priv(net);
	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;
	u16 rx_ctl = (AX_RX_CTL_START | AX_RX_CTL_AB | AX_RX_HEADER_DEFAULT);
	int mc_count;

	mc_count = netdev_mc_count(net);

	if (net->flags & IFF_PROMISC) {
		rx_ctl |= AX_RX_CTL_PRO;
	} else if (net->flags & IFF_ALLMULTI
		   || mc_count > AX_MAX_MCAST) {
		rx_ctl |= AX_RX_CTL_AMALL;
	} else if (mc_count == 0) {
		/* just broadcast and directed */
	} else {
		/* We use the 20 byte dev->data
		 * for our 8 byte filter buffer
		 * to avoid allocating memory that
		 * is tricky to free later */
		u32 crc_bits;

		struct netdev_hw_addr *ha;
		memset(data->multi_filter, 0, AX_MCAST_FILTER_SIZE);
		netdev_for_each_mc_addr(ha, net) {
			crc_bits = ether_crc(ETH_ALEN, ha->addr) >> 26;
			data->multi_filter[crc_bits >> 3] |=
				1 << (crc_bits & 7);
		}
		ax8817x_write_cmd_async(dev, AX_CMD_WRITE_MULTI_FILTER, 0, 0,
				   AX_MCAST_FILTER_SIZE, data->multi_filter);

		rx_ctl |= AX_RX_CTL_AM;
	}

	ax8817x_write_cmd_async(dev, AX_CMD_WRITE_RX_CTL, rx_ctl, 0, 0, NULL);
}

static int ax8817x_mdio_read(struct net_device *netdev, int phy_id, int loc)
{
	struct usbnet *dev = netdev_priv(netdev);
	u16 *res;
	u16 ret;

	res = kmalloc(2, GFP_ATOMIC);
	if (!res)
		return 0;

	ax8817x_write_cmd(dev, AX_CMD_SET_SW_MII, 0, 0, 0, NULL);
	ax8817x_read_cmd(dev, AX_CMD_READ_MII_REG, phy_id, (__u16)loc, 2, res);
	ax8817x_write_cmd(dev, AX_CMD_SET_HW_MII, 0, 0, 0, NULL);

	ret = *res & 0xffff;
	kfree(res);

	return ret;
}

static int
ax8817x_swmii_mdio_read(struct net_device *netdev, int phy_id, int loc)
{
	struct usbnet *dev = netdev_priv(netdev);
	u16 *res;
	u16 ret;

	res = kmalloc(2, GFP_ATOMIC);
	if (!res)
		return 0;

	ax8817x_read_cmd(dev, AX_CMD_READ_MII_REG, phy_id,
				(__u16)loc, 2, res);

	ret = *res & 0xffff;
	kfree(res);

	return ret;
}

/* same as above, but converts resulting value to cpu byte order */
static int ax8817x_mdio_read_le(struct net_device *netdev, int phy_id, int loc)
{
	return le16_to_cpu(ax8817x_mdio_read(netdev, phy_id, loc));
}

static int
ax8817x_swmii_mdio_read_le(struct net_device *netdev, int phy_id, int loc)
{
	return le16_to_cpu(ax8817x_swmii_mdio_read(netdev, phy_id, loc));
}

static void
ax8817x_mdio_write(struct net_device *netdev, int phy_id, int loc, int val)
{
	struct usbnet *dev = netdev_priv(netdev);
	u16 *res;

	res = kmalloc(2, GFP_ATOMIC);
	if (!res)
		return;
	*res = val;

	ax8817x_write_cmd(dev, AX_CMD_SET_SW_MII, 0, 0, 0, NULL);
	ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id,
				(__u16)loc, 2, res);
	ax8817x_write_cmd(dev, AX_CMD_SET_HW_MII, 0, 0, 0, NULL);

	kfree(res);
}

static void ax8817x_swmii_mdio_write(struct net_device *netdev,
			int phy_id, int loc, int val)
{
	struct usbnet *dev = netdev_priv(netdev);
	u16 *res;

	res = kmalloc(2, GFP_ATOMIC);
	if (!res)
		return;
	*res = val;

	ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id,
				(__u16)loc, 2, res);

	kfree(res);
}

static void
ax88772b_mdio_write(struct net_device *netdev, int phy_id, int loc, int val)
{
	struct usbnet *dev = netdev_priv(netdev);
	u16 *res;

	res = kmalloc(2, GFP_ATOMIC);
	if (!res)
		return;
	*res = val;

	ax8817x_write_cmd(dev, AX_CMD_SET_SW_MII, 0, 0, 0, NULL);
	ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id,
				(__u16)loc, 2, res);

	if (loc == MII_ADVERTISE) {
		*res = cpu_to_le16(BMCR_ANENABLE | BMCR_ANRESTART);
		ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id,
				(__u16)MII_BMCR, 2, res);
	}

	ax8817x_write_cmd(dev, AX_CMD_SET_HW_MII, 0, 0, 0, NULL);

	kfree(res);
}

/* same as above, but converts new value to le16 byte order before writing */
static void
ax8817x_mdio_write_le(struct net_device *netdev, int phy_id, int loc, int val)
{
	ax8817x_mdio_write(netdev, phy_id, loc, cpu_to_le16(val));
}

static void ax8817x_swmii_mdio_write_le(struct net_device *netdev,
			int phy_id, int loc, int val)
{
	ax8817x_swmii_mdio_write(netdev, phy_id, loc, cpu_to_le16(val));
}

static void
ax88772b_mdio_write_le(struct net_device *netdev, int phy_id, int loc, int val)
{
	ax88772b_mdio_write(netdev, phy_id, loc, cpu_to_le16(val));
}

static int asix_write_medium_mode(struct usbnet *dev, u16 value)
{
	int ret;

	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_MEDIUM_MODE,
						value, 0, 0, NULL);
	if (ret < 0)
		netdev_err(dev->net, "%s (0x%04x) failed, err=%d\n",
						__func__, value, ret);
	return ret;
}

static int ax88772_suspend(struct usb_interface *intf,
			pm_message_t message)
{
	struct usbnet *dev = usb_get_intfdata(intf);
	u16 *medium;

	medium = kmalloc(2, GFP_ATOMIC);
	if (!medium)
		return usbnet_suspend(intf, message);

	ax8817x_read_cmd(dev, AX_CMD_READ_MEDIUM_MODE, 0, 0, 2, medium);
	asix_write_medium_mode(dev, *medium & ~AX88772_MEDIUM_RX_ENABLE);

	kfree(medium);
	return usbnet_suspend(intf, message);
}

static int ax88772b_suspend(struct usb_interface *intf,
			pm_message_t message)
{
	struct usbnet *dev = usb_get_intfdata(intf);
	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
	u16 *tmp16;
	u8 *opt;

	tmp16 = kmalloc(2, GFP_ATOMIC);
	if (!tmp16)
		return usbnet_suspend(intf, message);
	opt = (u8 *)tmp16;

	ax8817x_read_cmd(dev, AX_CMD_READ_MEDIUM_MODE, 0, 0, 2, tmp16);
	asix_write_medium_mode(dev, *tmp16 & ~AX88772_MEDIUM_RX_ENABLE);

	ax8817x_read_cmd(dev, AX_CMD_READ_MONITOR_MODE, 0, 0, 1, opt);
	if (!(*opt & AX_MONITOR_LINK) && !(*opt & AX_MONITOR_MAGIC)) {
		ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
			AX_SWRESET_IPRL | AX_SWRESET_IPPD, 0, 0, NULL);
	} else {

		if (priv->psc & AX_SWRESET_WOLLP) {
			*tmp16 = ax8817x_mdio_read_le(dev->net,
					dev->mii.phy_id, MII_BMCR);
			ax8817x_mdio_write_le(dev->net, dev->mii.phy_id,
					MII_BMCR, *tmp16 | BMCR_ANENABLE);

			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
				AX_SWRESET_IPRL | priv->psc, 0, 0, NULL);
		}

		if (priv->psc &
		    (AX_SWRESET_IPPSL_0 | AX_SWRESET_IPPSL_1)) {
			*opt |= AX_MONITOR_LINK;
			ax8817x_write_cmd(dev, AX_CMD_WRITE_MONITOR_MODE,
					*opt, 0, 0, NULL);
		}
	}

	kfree(tmp16);
	return usbnet_suspend(intf, message);
}

static int ax88772_resume(struct usb_interface *intf)
{
	struct usbnet *dev = usb_get_intfdata(intf);

	netif_carrier_off(dev->net);
	return usbnet_resume(intf);
}

static int ax88772b_resume(struct usb_interface *intf)
{
	struct usbnet *dev = usb_get_intfdata(intf);
	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;

	if (priv->psc & AX_SWRESET_WOLLP) {
		ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
				AX_SWRESET_IPRL | (priv->psc & 0x7FFF),
				0, 0, NULL);
	}
	if (priv->psc & (AX_SWRESET_IPPSL_0 | AX_SWRESET_IPPSL_1))
		ax88772a_phy_powerup(dev);
	netif_carrier_off(dev->net);
	return usbnet_resume(intf);
}

static int ax88172_link_reset(struct usbnet *dev)
{
	u16 lpa;
	u16 adv;
	u16 res;
	u8 mode;

	mode = AX_MEDIUM_TX_ABORT_ALLOW | AX_MEDIUM_FLOW_CONTROL_EN;
	lpa = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, MII_LPA);
	adv = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, MII_ADVERTISE);
	res = mii_nway_result(lpa|adv);
	if (res & LPA_DUPLEX)
		mode |= AX_MEDIUM_FULL_DUPLEX;
	asix_write_medium_mode(dev, mode);
	return 0;
}

static void
ax8817x_get_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
{
	struct usbnet *dev = netdev_priv(net);
	u8 *opt;

	wolinfo->supported = 0;
	wolinfo->wolopts = 0;

	opt = kmalloc(1, GFP_KERNEL);
	if (!opt)
		return;

	if (ax8817x_read_cmd(dev, AX_CMD_READ_MONITOR_MODE, 0, 0, 1, opt) < 0)
		return;

	wolinfo->supported = WAKE_PHY | WAKE_MAGIC;

	if (*opt & AX_MONITOR_LINK)
		wolinfo->wolopts |= WAKE_PHY;
	if (*opt & AX_MONITOR_MAGIC)
		wolinfo->wolopts |= WAKE_MAGIC;

	kfree(opt);
}

static int
ax8817x_set_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
{
	struct usbnet *dev = netdev_priv(net);
	u8 *opt;

	opt = kmalloc(1, GFP_KERNEL);
	if (!opt)
		return -ENOMEM;

	*opt = 0;
	if (wolinfo->wolopts & WAKE_PHY)
		*opt |= AX_MONITOR_LINK;
	if (wolinfo->wolopts & WAKE_MAGIC)
		*opt |= AX_MONITOR_MAGIC;

	ax8817x_write_cmd(dev, AX_CMD_WRITE_MONITOR_MODE, *opt, 0, 0, NULL);

	kfree(opt);
	return 0;
}

static int ax8817x_get_eeprom_len(struct net_device *net)
{
	return AX_EEPROM_LEN;
}

static int ax8817x_get_eeprom(struct net_device *net,
			      struct ethtool_eeprom *eeprom, u8 *data)
{
	struct usbnet *dev = netdev_priv(net);
	u16 *ebuf = (u16 *)data;
	int i;

	/* Crude hack to ensure that we don't overwrite memory
	 * if an odd length is supplied
	 */
	if (eeprom->len % 2)
		return -EINVAL;

	eeprom->magic = AX_EEPROM_MAGIC;

	/* ax8817x returns 2 bytes from eeprom on read */
	for (i = 0; i < eeprom->len / 2; i++) {
		if (ax8817x_read_cmd(dev, AX_CMD_READ_EEPROM,
			eeprom->offset + i, 0, 2, &ebuf[i]) < 0)
			return -EINVAL;
	}
	return 0;
}

static void ax8817x_get_drvinfo(struct net_device *net,
				 struct ethtool_drvinfo *info)
{
	/* Inherit standard device info */
	usbnet_get_drvinfo(net, info);
	info->eedump_len = 0x3e;
}

static int ax8817x_get_settings(struct net_device *net, struct ethtool_cmd *cmd)
{
	struct usbnet *dev = netdev_priv(net);
	return mii_ethtool_gset(&dev->mii, cmd);
}

static int ax8817x_set_settings(struct net_device *net, struct ethtool_cmd *cmd)
{
	struct usbnet *dev = netdev_priv(net);
	return mii_ethtool_sset(&dev->mii, cmd);
}

/*
 * We need to override some ethtool_ops so we require our
 * own structure so we don't interfere with other usbnet
 * devices that may be connected at the same time.
 */
static struct ethtool_ops ax8817x_ethtool_ops = {
	.get_drvinfo		= ax8817x_get_drvinfo,
	.get_link		= ethtool_op_get_link,
	.get_msglevel		= usbnet_get_msglevel,
	.set_msglevel		= usbnet_set_msglevel,
	.get_wol		= ax8817x_get_wol,
	.set_wol		= ax8817x_set_wol,
	.get_eeprom_len		= ax8817x_get_eeprom_len,
	.get_eeprom		= ax8817x_get_eeprom,
	.get_settings		= ax8817x_get_settings,
	.set_settings		= ax8817x_set_settings,
};

static int ax8817x_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
{
	struct usbnet *dev = netdev_priv(net);

	return generic_mii_ioctl(&dev->mii, if_mii(rq), cmd, NULL);
}

static const struct net_device_ops ax88x72_netdev_ops = {
	.ndo_open		= usbnet_open,
	.ndo_stop		= usbnet_stop,
	.ndo_start_xmit		= usbnet_start_xmit,
	.ndo_tx_timeout		= usbnet_tx_timeout,
	.ndo_change_mtu		= usbnet_change_mtu,
	.ndo_do_ioctl		= ax8817x_ioctl,
	.ndo_set_mac_address	= ax8817x_set_mac_addr,
	.ndo_validate_addr	= eth_validate_addr,
	.ndo_set_multicast_list	= ax8817x_set_multicast,
};

static int asix_read_mac(struct usbnet *dev, u8 op)
{
	u8 *buf;
	int ret, len = ETH_ALEN;

	buf = kzalloc(len, GFP_KERNEL);
	if (!buf) {
		netdev_err(dev->net, "%s kzalloc failed\n", __func__);
		return -ENOMEM;
	}
	ret = ax8817x_read_cmd(dev, op, 0, 0, len, buf);
	if (ret < 0) {
		netdev_err(dev->net, "%s failed, err=%d\n", __func__, ret);
	} else {
		memcpy(dev->net->dev_addr, buf, len);
		ret = 0;
	}
	kfree(buf);
	return ret;
}

static int asix_read_phyid(struct usbnet *dev, u8 op)
{
	u8 *buf;
	int ret, len = 2;

	buf = kzalloc(len, GFP_KERNEL);
	if (!buf) {
		netdev_err(dev->net, "%s kzalloc failed\n", __func__);
		return -ENOMEM;
	}
	ret = ax8817x_read_cmd(dev, op, 0, 0, len, buf);
	if (ret < 0) {
		netdev_err(dev->net, "%s failed, err=%d\n", __func__, ret);
	} else if (ret < len) {
		netdev_err(dev->net, "%s read only %d/%d bytes\n",
						__func__, ret, len);
		ret = -EIO;
	} else {
		dev->mii.phy_id = buf[1];
		ret = 0;
	}
	kfree(buf);
	return ret;
}

static int asix_read_eeprom_le16(struct usbnet *dev, u8 offset, u16 *data)
{
	u16 *buf;
	int ret, len = 2;

	buf = kzalloc(len, GFP_KERNEL);
	if (!buf) {
		netdev_err(dev->net, "%s kzalloc failed\n", __func__);
		return -ENOMEM;
	}

	ret = ax8817x_read_cmd(dev, AX_CMD_READ_EEPROM, offset, 0, len, buf);
	if (ret != 2) {
		netdev_err(dev->net, "%s failed offset 0x%02x, err=%d\n",
						__func__, offset, ret);
	} else {
		le16_to_cpus(buf);
		*data = *buf;
		ret = 0;
	}
	kfree(buf);
	return ret;
}

static int asix_read_mac_from_eeprom(struct usbnet *dev)
{
	u16 buf[ETH_ALEN / 2];
	int i, ret;

	memset(buf, 0, sizeof(buf));
	for (i = 0; i < ETH_ALEN; i += 2) {
		ret = asix_read_eeprom_le16(dev, i + 4, buf + i);
		if (ret < 0) {
			netdev_err(dev->net, "%s failed\n", __func__);
			return ret;
		}
	}
	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
	return 0;
}

static int asix_phy_select(struct usbnet *dev, u16 physel)
{
	int ret;

	ret = ax8817x_write_cmd(dev, AX_CMD_SW_PHY_SELECT, physel, 0, 0, NULL);
	if (ret < 0)
		netdev_err(dev->net, "%s (0x%04x) failed, err=%d\n",
						__func__, physel, ret);
	return ret;
}

static int asix_write_gpio(struct usbnet *dev, unsigned int wait, u16 value)
{
	int ret;

	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_GPIOS, value, 0, 0, NULL);
	if (ret < 0) {
		netdev_err(dev->net, "%s (0x%x) failed\n", __func__, value);
		return ret;
	}
	if (!wait)
		wait = 5;
	if (wait < 20)
		usleep_range(wait * 1000, wait * (1000 * 2));
	else
		msleep(wait);
	return 0;
}

static int ax8817x_bind(struct usbnet *dev, struct usb_interface *intf)
{
	int ret = 0;
	int i;
	unsigned long gpio_bits = dev->driver_info->data;
	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;

	usbnet_get_endpoints(dev, intf);

	/* Toggle the GPIOs in a manufacturer/model specific way */
	for (i = 2; i >= 0; i--) {
		ret = asix_write_gpio(dev, 0, (gpio_bits >> (i * 8)) & 0xff);
		if (ret)
			goto err_out;
	}

	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL, 0x80, 0, 0, NULL);
	if (ret < 0) {
		netdev_err(dev->net, "%s: WRITE_RX_CTL failed, err=%d\n",
							__func__, ret);
		goto err_out;
	}

	/* Get the MAC address */
	ret = asix_read_mac(dev, AX_CMD_READ_NODE_ID);
	if (ret < 0)
		goto err_out;

	/* Get the PHY id */
	ret = asix_read_phyid(dev, AX_CMD_READ_PHY_ID);
	if (ret < 0)
		goto err_out;

	/* Initialize MII structure */
	dev->mii.dev = dev->net;
	dev->mii.mdio_read = ax8817x_mdio_read_le;
	dev->mii.mdio_write = ax8817x_mdio_write_le;
	dev->mii.phy_id_mask = 0x3f;
	dev->mii.reg_num_mask = 0x1f;
	dev->net->netdev_ops = &ax88x72_netdev_ops;
	dev->net->ethtool_ops = &ax8817x_ethtool_ops;

	/* Register suspend and resume functions */
	data->suspend = usbnet_suspend;
	data->resume = usbnet_resume;

	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_ADVERTISE,
		ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
	mii_nway_restart(&dev->mii);

	printk(KERN_INFO "%s\n", driver_version);
	return 0;

err_out:
	return ret;
}

static struct ethtool_ops ax88772_ethtool_ops = {
	.get_drvinfo		= ax8817x_get_drvinfo,
	.get_link		= ethtool_op_get_link,
	.get_msglevel		= usbnet_get_msglevel,
	.set_msglevel		= usbnet_set_msglevel,
	.get_wol		= ax8817x_get_wol,
	.set_wol		= ax8817x_set_wol,
	.get_eeprom_len		= ax8817x_get_eeprom_len,
	.get_eeprom		= ax8817x_get_eeprom,
	.get_settings		= ax8817x_get_settings,
	.set_settings		= ax8817x_set_settings,
};

static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
{
	int ret;
	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;
	struct ax88772_data *priv;

	usbnet_get_endpoints(dev, intf);

	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
	if (!priv) {
		netdev_err(dev->net, "%s: kzalloc(priv) failed\n", __func__);
		return -ENOMEM;
	}
	dev->driver_priv = priv;

	priv->ax_work = create_singlethread_workqueue("ax88772");
	if (!priv->ax_work) {
		netdev_err(dev->net, "%s: create workqueue failed\n", __func__);
		kfree(priv);
		return -ENOMEM;
	}

	priv->dev = dev;
	INIT_WORK(&priv->check_link, ax88772_link_reset);

	/* reload eeprom data */
	ret = asix_write_gpio(dev, 0, AXGPIOS_RSE|AXGPIOS_GPO2|AXGPIOS_GPO2EN);
	if (ret)
		goto err_out;

	/* Initialize MII structure */
	dev->mii.dev = dev->net;
	dev->mii.mdio_read = ax8817x_mdio_read_le;
	dev->mii.mdio_write = ax8817x_mdio_write_le;
	dev->mii.phy_id_mask = 0xff;
	dev->mii.reg_num_mask = 0xff;

	/* Get the PHY id */
	ret = asix_read_phyid(dev, AX_CMD_READ_PHY_ID);
	if (ret < 0)
		goto err_out;
	if (dev->mii.phy_id == 0x10) {
		ret = asix_phy_select(dev, 0x0001);
		if (ret < 0)
			goto err_out;

		ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
					AX_SWRESET_IPPD, 0, 0, NULL);
		if (ret < 0) {
			netdev_err(dev->net, "%s: Failed to power down PHY"
						", err=%d\n", __func__, ret);
			goto err_out;
		}

		msleep(150);
		ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
					AX_SWRESET_CLEAR, 0, 0, NULL);
		if (ret < 0) {
			netdev_err(dev->net, "%s: SW_RESET failed, err=%d\n",
								__func__, ret);
			goto err_out;
		}

		msleep(150);
		ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
				AX_SWRESET_IPRL | AX_SWRESET_PRL, 0, 0, NULL);
		if (ret < 0) {
			netdev_err(dev->net, "%s: Failed to set PHY reset "
					"control, err=%d\n", __func__, ret);
			goto err_out;
		}
	} else {
		ret = asix_phy_select(dev, 0x0000);
		if (ret < 0)
			goto err_out;

		ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
				AX_SWRESET_IPPD | AX_SWRESET_PRL, 0, 0, NULL);
		if (ret < 0) {
			netdev_err(dev->net, "%s: Failed to power down "
				"internal PHY, err=%d\n", __func__, ret);
			goto err_out;
		}
	}

	msleep(150);
	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL, 0x0000, 0, 0, NULL);
	if (ret < 0) {
		netdev_err(dev->net, "%s: Failed to reset RX_CTL, err=%d\n",
							__func__, ret);
		goto err_out;
	}

	/* Get the MAC address */
	ret = asix_read_mac(dev, AX88772_CMD_READ_NODE_ID);
	if (ret < 0)
		goto err_out;

	ret = ax8817x_write_cmd(dev, AX_CMD_SET_SW_MII, 0, 0, 0, NULL);
	if (ret < 0) {
		netdev_err(dev->net, "%s: Failed to enable software MII"
					", err=%d\n", __func__, ret);
		goto err_out;
	}

	if (dev->mii.phy_id == 0x10) {
		ret = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, 2);
		if (ret != 0x003b) {
			netdev_err(dev->net, "%s: PHY reg 2 not 0x3b00: 0x%x\n",
							__func__, ret);
			goto err_out;
		}

		ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
					AX_SWRESET_PRL, 0, 0, NULL);
		if (ret < 0) {
			netdev_err(dev->net, "%s: Failed to set "
				"external PHY reset pin level, err=%d\n",
				__func__, ret);
			goto err_out;
		}
		msleep(150);
		ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
				AX_SWRESET_IPRL | AX_SWRESET_PRL, 0, 0, NULL);
		if (ret < 0) {
			netdev_err(dev->net, "%s: Failed to set "
				"internal/external PHY reset control, err=%d\n",
				__func__, ret);
			goto err_out;
		}
		msleep(150);
	}

	dev->net->netdev_ops = &ax88x72_netdev_ops;
	dev->net->ethtool_ops = &ax88772_ethtool_ops;

	/* Register suspend and resume functions */
	data->suspend = ax88772_suspend;
	data->resume = ax88772_resume;

	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_ADVERTISE,
					ADVERTISE_ALL | ADVERTISE_CSMA);

	mii_nway_restart(&dev->mii);
	priv->autoneg_start = jiffies;
	priv->Event = WAIT_AUTONEG_COMPLETE;

	ret = asix_write_medium_mode(dev, AX88772_MEDIUM_DEFAULT);
	if (ret < 0)
		goto err_out;

	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_IPG0,
			AX88772_IPG0_DEFAULT | AX88772_IPG1_DEFAULT << 8,
			AX88772_IPG2_DEFAULT, 0, NULL);
	if (ret < 0) {
		netdev_err(dev->net, "%s: WRITE_IPG0/1/2 failed, err=%d\n",
							__func__, ret);
		goto err_out;
	}
	ret = ax8817x_write_cmd(dev, AX_CMD_SET_HW_MII, 0, 0, 0, NULL);
	if (ret < 0) {
		netdev_err(dev->net, "%s: SET_HW_MII failed, err=%d\n",
							__func__, ret);
		goto err_out;
	}

	/* Set RX_CTL to default values with 2k buffer, and enable cactus */
	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL, 0x0088, 0, 0, NULL);
	if (ret < 0) {
		netdev_err(dev->net, "%s: WRITE_RX_CTL failed, err=%d\n",
							__func__, ret);
		goto err_out;
	}

	/* Asix framing packs multiple eth frames into a 2K usb bulk transfer */
	if (dev->driver_info->flags & FLAG_FRAMING_AX) {
		/*
		 * hard_mtu  is still the default;
		 *  the device does not support jumbo eth frames
		 */
		dev->rx_urb_size = 2048;
	}

	printk(KERN_INFO "%s\n", driver_version);
	return 0;

err_out:
	destroy_workqueue(priv->ax_work);
	kfree(priv);
	return ret;
}

static void ax88772_unbind(struct usbnet *dev, struct usb_interface *intf)
{
	struct ax88772_data *priv = (struct ax88772_data *)dev->driver_priv;

	if (priv) {

		flush_workqueue(priv->ax_work);
		destroy_workqueue(priv->ax_work);

		/* stop MAC operation */
		ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
					AX_RX_CTL_STOP, 0, 0, NULL);

		/* Power down PHY */
		ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
					AX_SWRESET_IPPD, 0, 0, NULL);
		kfree(priv);
	}
}

static int ax88772a_phy_powerup(struct usbnet *dev)
{
	int ret;
	/* set the embedded Ethernet PHY in power-down state */
	ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
				AX_SWRESET_IPPD | AX_SWRESET_IPRL, 0, 0, NULL);
	if (ret < 0) {
		netdev_err(dev->net, "%s: power down PHY failed, err=%d\n",
							__func__, ret);
		return ret;
	}

	msleep(20); /* was 10ms */


	/* set the embedded Ethernet PHY in power-up state */
	ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET, AX_SWRESET_IPRL,
							0, 0, NULL);
	if (ret < 0) {
		netdev_err(dev->net, "%s: reset PHY failed, err=%d\n",
							__func__, ret);
		return ret;
	}

	msleep(600);

	/* set the embedded Ethernet PHY in reset state */
	ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET, AX_SWRESET_CLEAR,
							0, 0, NULL);
	if (ret < 0) {
		netdev_err(dev->net, "%s: power up PHY failed, err=%d\n",
							__func__, ret);
		return ret;
	}

	/* set the embedded Ethernet PHY in power-up state */
	ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET, AX_SWRESET_IPRL,
							0, 0, NULL);
	if (ret < 0) {
		netdev_err(dev->net, "%s: second reset PHY failed, err=%d\n",
							__func__, ret);
		return ret;
	}

	return 0;
}

static int ax88772a_bind(struct usbnet *dev, struct usb_interface *intf)
{
	int ret = -EIO;
	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;
	struct ax88772a_data *priv;

	usbnet_get_endpoints(dev, intf);

	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
	if (!priv) {
		netdev_err(dev->net, "%s: kzalloc(priv) failed\n", __func__);
		return -ENOMEM;
	}
	dev->driver_priv = priv;

	priv->ax_work = create_singlethread_workqueue("ax88772a");
	if (!priv->ax_work) {
		netdev_err(dev->net, "%s: create workqueue failed\n", __func__);
		kfree(priv);
		return -ENOMEM;
	}

	priv->dev = dev;
	INIT_WORK(&priv->check_link, ax88772a_link_reset);

	/* Get the EEPROM data*/
	ret = asix_read_eeprom_le16(dev, 0x17, &priv->EepromData);
	if (ret < 0)
		goto err_out;

	/* reload eeprom data */
	ret = asix_write_gpio(dev, 0, AXGPIOS_RSE);
	if (ret)
		goto err_out;

	/* Initialize MII structure */
	dev->mii.dev = dev->net;
	dev->mii.mdio_read = ax8817x_mdio_read_le;
	dev->mii.mdio_write = ax8817x_mdio_write_le;
	dev->mii.phy_id_mask = 0xff;
	dev->mii.reg_num_mask = 0xff;

	/* Get the PHY id */
	ret = asix_read_phyid(dev, AX_CMD_READ_PHY_ID);
	if (ret < 0)
		goto err_out;
	if (dev->mii.phy_id != 0x10) {
		netdev_err(dev->net, "%s: Got wrong PHY_ID: 0x%02x\n",
						__func__, dev->mii.phy_id);
		ret = -EIO;
		goto err_out;
	}

	/* select the embedded 10/100 Ethernet PHY */
	ret = asix_phy_select(dev,
			AX_PHYSEL_SSEN | AX_PHYSEL_PSEL | AX_PHYSEL_SSMII);
	if (ret < 0)
		goto err_out;

	ret = ax88772a_phy_powerup(dev);
	if (ret < 0)
		goto err_out;

	/* stop MAC operation */
	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
				AX_RX_CTL_STOP, 0, 0, NULL);
	if (ret < 0) {
		netdev_err(dev->net, "%s: reset RX_CTL failed, err=%d\n",
							__func__, ret);
		goto err_out;
	}

	/* Get the MAC address */
	ret = asix_read_mac(dev, AX88772_CMD_READ_NODE_ID);
	if (ret < 0)
		goto err_out;

	/* make sure the driver can enable sw mii operation */
	ret = ax8817x_write_cmd(dev, AX_CMD_SET_SW_MII, 0, 0, 0, NULL);
	if (ret < 0) {
		netdev_err(dev->net, "%s: enable software MII failed, err=%d\n",
							__func__, ret);
		goto err_out;
	}

	dev->net->netdev_ops = &ax88x72_netdev_ops;
	dev->net->ethtool_ops = &ax88772_ethtool_ops;

	/* Register suspend and resume functions */
	data->suspend = ax88772_suspend;
	data->resume = ax88772_resume;

	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_ADVERTISE,
			ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);

	mii_nway_restart(&dev->mii);
	priv->autoneg_start = jiffies;
	priv->Event = WAIT_AUTONEG_COMPLETE;

	ret = asix_write_medium_mode(dev, AX88772_MEDIUM_DEFAULT);
	if (ret < 0)
		goto err_out;

	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_IPG0,
			AX88772A_IPG0_DEFAULT | AX88772A_IPG1_DEFAULT << 8,
			AX88772A_IPG2_DEFAULT, 0, NULL);
	if (ret < 0) {
		netdev_err(dev->net, "%s: write IPG,IPG1,IPG2 failed, err=%d\n",
							__func__, ret);
		goto err_out;
	}

	/* Set RX_CTL to default values with 2k buffer, and enable cactus */
	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
				AX_RX_CTL_START | AX_RX_CTL_AB, 0, 0, NULL);
	if (ret < 0) {
		netdev_err(dev->net, "%s: Reset RX_CTL failed, err=%d\n",
							__func__, ret);
		goto err_out;
	}

	/* Asix framing packs multiple eth frames into a 2K usb bulk transfer */
	if (dev->driver_info->flags & FLAG_FRAMING_AX) {
		/*
		 * hard_mtu  is still the default;
		 *  the device does not support jumbo eth frames
		 */
		dev->rx_urb_size = 2048;
	}

	printk(KERN_INFO "%s\n", driver_version);
	return ret;

err_out:
	destroy_workqueue(priv->ax_work);
	kfree(priv);
	return ret;
}

static void ax88772a_unbind(struct usbnet *dev, struct usb_interface *intf)
{
	struct ax88772a_data *priv = (struct ax88772a_data *)dev->driver_priv;

	if (priv) {

		flush_workqueue(priv->ax_work);
		destroy_workqueue(priv->ax_work);

		/* stop MAC operation */
		ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
					AX_RX_CTL_STOP, 0, 0, NULL);

		/* Power down PHY */
		ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
					AX_SWRESET_IPPD, 0, 0, NULL);
		kfree(priv);
	}
}

static int ax88772b_set_csums(struct usbnet *dev)
{
	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
	u16 checksum;

	if (priv->checksum & AX_RX_CHECKSUM)
		checksum = AX_RXCOE_DEF_CSUM;
	else
		checksum = 0;

	if (priv->checksum & AX_TX_CHECKSUM)
		checksum = AX_TXCOE_DEF_CSUM;
	else
		checksum = 0;
	ax8817x_write_cmd(dev, AX_CMD_WRITE_RXCOE_CTL,
				 checksum, 0, 0, NULL);
	ax8817x_write_cmd(dev, AX_CMD_WRITE_TXCOE_CTL,
				 checksum, 0, 0, NULL);

	return 0;
}

static int ax88772b_set_features(struct net_device *netdev, u32 features)
{
	struct usbnet *dev = netdev_priv(netdev);
	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
	unsigned long flags;
	u16 tx_csum = 0, rx_csum = 0;

	spin_lock_irqsave(&priv->checksum_lock, flags);
	if (features & NETIF_F_HW_CSUM) {
		priv->checksum |= AX_TX_CHECKSUM;
		tx_csum = AX_TXCOE_DEF_CSUM;
	} else
		priv->checksum &= ~AX_TX_CHECKSUM;
	if (features & NETIF_F_RXCSUM) {
		priv->checksum |= AX_RX_CHECKSUM;
		rx_csum = AX_RXCOE_DEF_CSUM;
	} else
		priv->checksum &= ~AX_RX_CHECKSUM;
	spin_unlock_irqrestore(&priv->checksum_lock, flags);

	ax8817x_write_cmd(dev, AX_CMD_WRITE_RXCOE_CTL,
				 rx_csum, 0, 0, NULL);
	ax8817x_write_cmd(dev, AX_CMD_WRITE_TXCOE_CTL,
				 tx_csum, 0, 0, NULL);
	return 0;
}

static struct ethtool_ops ax88772b_ethtool_ops = {
	.get_drvinfo		= ax8817x_get_drvinfo,
	.get_link		= ethtool_op_get_link,
	.get_msglevel		= usbnet_get_msglevel,
	.set_msglevel		= usbnet_set_msglevel,
	.get_wol		= ax8817x_get_wol,
	.set_wol		= ax8817x_set_wol,
	.get_eeprom_len		= ax8817x_get_eeprom_len,
	.get_eeprom		= ax8817x_get_eeprom,
	.get_settings		= ax8817x_get_settings,
	.set_settings		= ax8817x_set_settings,
};

static const struct net_device_ops ax88772b_netdev_ops = {
	.ndo_open		= usbnet_open,
	.ndo_stop		= usbnet_stop,
	.ndo_start_xmit		= usbnet_start_xmit,
	.ndo_tx_timeout		= usbnet_tx_timeout,
	.ndo_change_mtu		= usbnet_change_mtu,
	.ndo_do_ioctl		= ax8817x_ioctl,
	.ndo_set_mac_address	= ax8817x_set_mac_addr,
	.ndo_validate_addr	= eth_validate_addr,
	.ndo_set_multicast_list = ax88772b_set_multicast,
	.ndo_set_features	= ax88772b_set_features,
};

static int ax88772b_bind(struct usbnet *dev, struct usb_interface *intf)
{
	int ret;
	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;
	struct ax88772b_data *priv;
	int rx_size;
	u16 tmp16;

	usbnet_get_endpoints(dev, intf);

	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
	if (!priv) {
		netdev_err(dev->net, "%s: kzalloc(priv) failed\n", __func__);
		return -ENOMEM;
	}
	spin_lock_init(&priv->checksum_lock);
	dev->driver_priv = priv;

	priv->ax_work = create_singlethread_workqueue("ax88772b");
	if (!priv->ax_work) {
		netdev_err(dev->net, "%s: create workqueue failed\n", __func__);
		kfree(priv);
		return -ENOMEM;
	}

	priv->dev = dev;
	INIT_WORK(&priv->check_link, ax88772b_link_reset);

	/* reload eeprom data */
	ret = asix_write_gpio(dev, 0, AXGPIOS_RSE);
	if (ret)
		goto err_out;

	/* Get the EEPROM data*/
	ret = asix_read_eeprom_le16(dev, 0x18, &priv->psc);
	if (ret < 0)
		goto err_out;
	priv->psc &= 0xFF00;

	/* Get the MAC address from the eeprom */
	ret = asix_read_mac_from_eeprom(dev);
	if (ret < 0)
		goto err_out;

	/* Set the MAC address */
	ret = ax8817x_write_cmd(dev, AX88772_CMD_WRITE_NODE_ID,
			0, 0, ETH_ALEN, dev->net->dev_addr);
	if (ret < 0) {
		netdev_err(dev->net, "%s: set mac addr failed, err=%d\n",
							__func__, ret);
		goto err_out;
	}

	/* Initialize MII structure */
	dev->mii.dev = dev->net;
	dev->mii.mdio_read = ax8817x_mdio_read_le;
	dev->mii.mdio_write = ax88772b_mdio_write_le;
	dev->mii.phy_id_mask = 0xff;
	dev->mii.reg_num_mask = 0xff;

	/* Get the PHY id */
	ret = asix_read_phyid(dev, AX_CMD_READ_PHY_ID);
	if (ret < 0)
		goto err_out;
	if (dev->mii.phy_id != 0x10) {
		netdev_err(dev->net, "%s: Got wrong PHY_ID: 0x%02x\n",
						__func__, dev->mii.phy_id);
		ret = -EIO;
		goto err_out;
	}

	/* select the embedded 10/100 Ethernet PHY */
	ret = asix_phy_select(dev,
			AX_PHYSEL_SSEN | AX_PHYSEL_PSEL | AX_PHYSEL_SSMII);
	if (ret < 0)
		goto err_out;

	ret = ax88772a_phy_powerup(dev);
	if (ret < 0)
		goto err_out;

	/* stop MAC operation */
	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
				AX_RX_CTL_STOP, 0, 0, NULL);
	if (ret < 0) {
		netdev_err(dev->net, "%s: reset RX_CTL failed, err=%d\n",
							__func__, ret);
		goto err_out;
	}

	/* make sure the driver can enable sw mii operation */
	ret = ax8817x_write_cmd(dev, AX_CMD_SET_SW_MII, 0, 0, 0, NULL);
	if (ret < 0) {
		netdev_err(dev->net, "%s: enable software MII failed, err=%d\n",
							__func__, ret);
		goto err_out;
	}

	dev->net->netdev_ops = &ax88772b_netdev_ops;
	dev->net->ethtool_ops = &ax88772b_ethtool_ops;

	/* Register suspend and resume functions */
	data->suspend = ax88772b_suspend;
	data->resume = ax88772b_resume;

	tmp16 = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, 0x12);
	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, 0x12,
			((tmp16 & 0xFF9F) | 0x0040));
	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_ADVERTISE,
			ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
	mii_nway_restart(&dev->mii);

	ret = asix_write_medium_mode(dev, AX88772_MEDIUM_DEFAULT);
	if (ret < 0)
		goto err_out;

	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_IPG0,
			AX88772A_IPG0_DEFAULT | AX88772A_IPG1_DEFAULT << 8,
			AX88772A_IPG2_DEFAULT, 0, NULL);
	if (ret < 0) {
		netdev_err(dev->net, "%s: write interfram gap failed, err=%d\n",
							__func__, ret);
		goto err_out;
	}

	dev->net->features |= NETIF_F_IP_CSUM;
	dev->net->features |= NETIF_F_IPV6_CSUM;

	priv->checksum = AX_RX_CHECKSUM | AX_TX_CHECKSUM;
	ret = ax88772b_set_csums(dev);
	if (ret < 0) {
		netdev_err(dev->net, "%s: write RX_COE/TX_COE failed, err=%d\n",
							__func__, ret);
		goto err_out;
	}

	rx_size = bsize & 0x07;
	if (dev->udev->speed == USB_SPEED_HIGH) {
		ret = ax8817x_write_cmd(dev, 0x2A,
				AX88772B_BULKIN_SIZE[rx_size].byte_cnt,
				AX88772B_BULKIN_SIZE[rx_size].threshold,
				0, NULL);
		if (ret < 0) {
			netdev_err(dev->net, "%s: set rx_size failed, err=%d\n",
							__func__, ret);
			goto err_out;
		}
		dev->rx_urb_size = AX88772B_BULKIN_SIZE[rx_size].size;
	} else {
		ret = ax8817x_write_cmd(dev, 0x2A, 0x8000, 0x8001, 0, NULL);
		if (ret < 0) {
			netdev_err(dev->net, "%s: set rx_size failed, err=%d\n",
							__func__, ret);
			goto err_out;
		}
		dev->rx_urb_size = 2048;
	}

	/* Configure RX header type */
	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
		      (AX_RX_CTL_START | AX_RX_CTL_AB | AX_RX_HEADER_DEFAULT),
		      0, 0, NULL);
	if (ret < 0) {
		netdev_err(dev->net, "%s: reset RX_CTL failed, err=%d\n",
							__func__, ret);
		goto err_out;
	}

	/* Overwrite power saving configuration from eeprom */
	ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
	    AX_SWRESET_IPRL | (priv->psc & 0x7FFF), 0, 0, NULL);
	if (ret < 0) {
		netdev_err(dev->net, "%s: set phy power saving failed, err=%d\n",
							__func__, ret);
		goto err_out;
	}

	printk(KERN_INFO "%s\n", driver_version);
	return ret;

err_out:
	destroy_workqueue(priv->ax_work);
	kfree(priv);
	return ret;
}

static void ax88772b_unbind(struct usbnet *dev, struct usb_interface *intf)
{
	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;

	if (priv) {

		flush_workqueue(priv->ax_work);
		destroy_workqueue(priv->ax_work);

		/* stop MAC operation */
		ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
					AX_RX_CTL_STOP, 0, 0, NULL);

		/* Power down PHY */
		ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
					AX_SWRESET_IPPD, 0, 0, NULL);
		kfree(priv);
	}
}

static int
ax88178_media_check(struct usbnet *dev, struct ax88178_data *priv)
{
	int fullduplex;
	u16 tempshort = 0;
	u16 media;
	u16 advertise, lpa, result, stat1000;

	advertise = ax8817x_mdio_read_le(dev->net,
				dev->mii.phy_id, MII_ADVERTISE);
	lpa = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, MII_LPA);
	result = advertise & lpa;

	stat1000 = ax8817x_mdio_read_le(dev->net,
				dev->mii.phy_id, MII_STAT1000);

	if ((priv->PhyMode == PHY_MODE_MARVELL) &&
	    (priv->LedMode == 1)) {
		tempshort = ax8817x_mdio_read_le(dev->net,
				dev->mii.phy_id, MARVELL_MANUAL_LED) & 0xfc0f;
	}

	fullduplex = 1;
	if (stat1000 & LPA_1000FULL) {
		media = MEDIUM_GIGA_MODE | MEDIUM_FULL_DUPLEX_MODE |
			MEDIUM_ENABLE_125MHZ | MEDIUM_ENABLE_RECEIVE;
		if ((priv->PhyMode == PHY_MODE_MARVELL) &&
		    (priv->LedMode == 1))
			tempshort |= 0x3e0;
	} else if (result & LPA_100FULL) {
		media = MEDIUM_FULL_DUPLEX_MODE | MEDIUM_ENABLE_RECEIVE |
			MEDIUM_MII_100M_MODE;
		if ((priv->PhyMode == PHY_MODE_MARVELL) &&
		    (priv->LedMode == 1))
			tempshort |= 0x3b0;
	} else if (result & LPA_100HALF) {
		fullduplex = 0;
		media = MEDIUM_ENABLE_RECEIVE | MEDIUM_MII_100M_MODE;
		if ((priv->PhyMode == PHY_MODE_MARVELL) &&
		    (priv->LedMode == 1))
			tempshort |= 0x3b0;
	} else if (result & LPA_10FULL) {
		media = MEDIUM_FULL_DUPLEX_MODE | MEDIUM_ENABLE_RECEIVE;
		if ((priv->PhyMode == PHY_MODE_MARVELL) &&
		    (priv->LedMode == 1))
			tempshort |= 0x2f0;
	} else {
		media = MEDIUM_ENABLE_RECEIVE;
		fullduplex = 0;
		if ((priv->PhyMode == PHY_MODE_MARVELL) &&
		    (priv->LedMode == 1))
				tempshort |= 0x02f0;
	}

	if ((priv->PhyMode == PHY_MODE_MARVELL) &&
	    (priv->LedMode == 1)) {
		ax8817x_mdio_write_le(dev->net,
			dev->mii.phy_id, MARVELL_MANUAL_LED, tempshort);
	}

	media |= 0x0004;
	if (priv->UseRgmii)
		media |= 0x0008;
	if (fullduplex) {
		media |= 0x0020;  /* enable tx flow control as default */
		media |= 0x0010;  /* enable rx flow control as default */
	}

	return media;
}

static void Vitess_8601_Init(struct usbnet *dev, int State)
{
	u16 reg;

	switch (State) {
	case 0:	/* tx, rx clock skew */
		ax8817x_swmii_mdio_write_le(dev->net, dev->mii.phy_id, 31, 1);
		ax8817x_swmii_mdio_write_le(dev->net, dev->mii.phy_id, 28, 0);
		ax8817x_swmii_mdio_write_le(dev->net, dev->mii.phy_id, 31, 0);
		break;

	case 1:
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 31, 0x52B5);
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 18, 0x009E);
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 17, 0xDD39);
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 16, 0x87AA);

		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 16, 0xA7B4);

		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 18,
				ax8817x_swmii_mdio_read_le(dev->net,
						dev->mii.phy_id, 18));

		reg = (ax8817x_swmii_mdio_read_le(dev->net,
				dev->mii.phy_id, 17) & ~0x003f) | 0x003c;
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 17, reg);
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 16, 0x87B4);

		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 16, 0xa794);

		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 18,
				ax8817x_swmii_mdio_read_le(dev->net,
					dev->mii.phy_id, 18));

		reg = (ax8817x_swmii_mdio_read_le(dev->net,
				dev->mii.phy_id, 17) & ~0x003f) | 0x003e;
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 17, reg);
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 16, 0x8794);

		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 18, 0x00f7);
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 17, 0xbe36);
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 16, 0x879e);

		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 16, 0xa7a0);

		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 18,
				ax8817x_swmii_mdio_read_le(dev->net,
						dev->mii.phy_id, 18));

		reg = (ax8817x_swmii_mdio_read_le(dev->net,
				dev->mii.phy_id, 17) & ~0x003f) | 0x0034;
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 17, reg);
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 16, 0x87a0);

		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 18, 0x003c);
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 17, 0xf3cf);
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 16, 0x87a2);

		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 18, 0x003c);
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 17, 0xf3cf);
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 16, 0x87a4);

		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 18, 0x003c);
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 17, 0xd287);
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 16, 0x87a6);

		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 16, 0xa7a8);

		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 18,
				ax8817x_swmii_mdio_read_le(dev->net,
						dev->mii.phy_id, 18));

		reg = (ax8817x_swmii_mdio_read_le(dev->net,
				dev->mii.phy_id, 17) & ~0x0fff) | 0x0125;
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 17, reg);
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 16, 0x87a8);

		/* Enable Smart Pre-emphasis */
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 16, 0xa7fa);

		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 18,
				ax8817x_swmii_mdio_read_le(dev->net,
						dev->mii.phy_id, 18));

		reg = (ax8817x_swmii_mdio_read_le(dev->net,
				dev->mii.phy_id, 17) & ~0x0008) | 0x0008;

		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 17, reg);
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 16, 0x87fa);

		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 31, 0);

		break;
	}
}

static int
ax88178_phy_init(struct usbnet *dev, struct ax88178_data *priv)
{
	int i;
	u16 PhyAnar, PhyAuxCtrl, PhyCtrl, TempShort, PhyID1;
	u16 PhyReg = 0;

	/* Disable MII operation of AX88178 Hardware */
	ax8817x_write_cmd(dev, AX_CMD_SET_SW_MII, 0x0000, 0, 0, NULL);


	/* Read SROM - MiiPhy Address (ID) */
	ax8817x_read_cmd(dev, AX_CMD_READ_PHY_ID, 0, 0, 2, &dev->mii.phy_id);
	le16_to_cpus(&dev->mii.phy_id);

	/* Initialize MII structure */
	dev->mii.phy_id >>= 8;
	dev->mii.phy_id &= PHY_ID_MASK;
	dev->mii.dev = dev->net;
	dev->mii.mdio_read = ax8817x_mdio_read_le;
	dev->mii.mdio_write = ax8817x_mdio_write_le;
	dev->mii.phy_id_mask = 0x3f;
	dev->mii.reg_num_mask = 0x1f;
	dev->mii.supports_gmii = 1;

	if (priv->PhyMode == PHY_MODE_MAC_TO_MAC_GMII) {
		priv->UseRgmii = 0;
		priv->MediaLink = MEDIUM_GIGA_MODE |
					  MEDIUM_FULL_DUPLEX_MODE |
					  MEDIUM_ENABLE_125MHZ |
					  MEDIUM_ENABLE_RECEIVE |
					  MEDIUM_ENABLE_RX_FLOWCTRL |
					  MEDIUM_ENABLE_TX_FLOWCTRL;

		goto SkipPhySetting;
	}

	/* test read phy register 2 */
	if (!priv->UseGpio0) {
		i = 1000;
		while (i--) {
			PhyID1 = ax8817x_swmii_mdio_read_le(dev->net,
						dev->mii.phy_id, MII_PHYSID1);
			if ((PhyID1 == 0x000f) || (PhyID1 == 0x0141) ||
			    (PhyID1 == 0x0282) || (PhyID1 == 0x004d) ||
			    (PhyID1 == 0x0243) || (PhyID1 == 0x001C) ||
			    (PhyID1 == 0x0007))
				break;
			usleep_range(5, 20);
		}
		if (i < 0)
			return -EIO;
	}

	priv->UseRgmii = 0;
	if (priv->PhyMode == PHY_MODE_MARVELL) {
		PhyReg = ax8817x_swmii_mdio_read_le(dev->net,
					dev->mii.phy_id, 27);
		if (!(PhyReg & 4)) {
			priv->UseRgmii = 1;
			ax8817x_swmii_mdio_write_le(dev->net,
					dev->mii.phy_id, 20, 0x82);
			priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
		}
	} else if ((priv->PhyMode == PHY_MODE_AGERE_V0) ||
		 (priv->PhyMode == PHY_MODE_AGERE_V0_GMII)) {
		if (priv->PhyMode == PHY_MODE_AGERE_V0) {
			priv->UseRgmii = 1;
			priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
		}
	} else if (priv->PhyMode == PHY_MODE_CICADA_V1) {
		/* not Cameo */
		if (!priv->UseGpio0 || priv->LedMode) {
			priv->UseRgmii = 1;
			priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
		}

		for (i = 0; i < (sizeof(CICADA_FAMILY_HWINIT) /
				 sizeof(CICADA_FAMILY_HWINIT[0])); i++) {
			ax8817x_swmii_mdio_write_le(dev->net,
					dev->mii.phy_id,
					CICADA_FAMILY_HWINIT[i].offset,
					CICADA_FAMILY_HWINIT[i].value);
		}

	} else if (priv->PhyMode == PHY_MODE_CICADA_V2) {
		/* not Cameo */
		if (!priv->UseGpio0 || priv->LedMode) {
			priv->UseRgmii = 1;
			priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
		}

		for (i = 0; i < (sizeof(CICADA_V2_HWINIT) /
				 sizeof(CICADA_V2_HWINIT[0])); i++) {
			ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, CICADA_V2_HWINIT[i].offset,
				CICADA_V2_HWINIT[i].value);
		}
	} else if (priv->PhyMode == PHY_MODE_CICADA_V2_ASIX) {
		/* not Cameo */
		if (!priv->UseGpio0 || priv->LedMode) {
			priv->UseRgmii = 1;
			priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
		}

		for (i = 0; i < (sizeof(CICADA_V2_HWINIT) /
				 sizeof(CICADA_V2_HWINIT[0])); i++) {
			ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, CICADA_V2_HWINIT[i].offset,
				CICADA_V2_HWINIT[i].value);
		}
	} else if (priv->PhyMode == PHY_MODE_RTL8211CL) {
		priv->UseRgmii = 1;
		priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
	} else if (priv->PhyMode == PHY_MODE_RTL8211BN) {
		priv->UseRgmii = 1;
		priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
	} else if (priv->PhyMode == PHY_MODE_RTL8251CL) {
		priv->UseRgmii = 1;
		priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
	} else if (priv->PhyMode == PHY_MODE_VSC8601) {
		priv->UseRgmii = 1;
		priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
		/* Vitess_8601_Init(dev, 0); */
	}

	if (priv->PhyMode != PHY_MODE_ATTANSIC_V0) {
		/* software reset */
		ax8817x_swmii_mdio_write_le(
			dev->net, dev->mii.phy_id, MII_BMCR,
			ax8817x_swmii_mdio_read_le(
				dev->net, dev->mii.phy_id, MII_BMCR)
				| BMCR_RESET);
		usleep_range(1000, 2000);
	}

	if ((priv->PhyMode == PHY_MODE_AGERE_V0) ||
	    (priv->PhyMode == PHY_MODE_AGERE_V0_GMII)) {
		if (priv->PhyMode == PHY_MODE_AGERE_V0) {
			i = 1000;
			while (i--) {
				ax8817x_swmii_mdio_write_le(dev->net,
						dev->mii.phy_id, 21, 0x1001);

				PhyReg = ax8817x_swmii_mdio_read_le(dev->net,
						dev->mii.phy_id, 21);
				if ((PhyReg & 0xf00f) == 0x1001)
					break;
			}
			if (i < 0)
				return -EIO;
		}

		if (priv->LedMode == 4) {
			ax8817x_swmii_mdio_write_le(dev->net,
					dev->mii.phy_id, 28, 0x7417);
		} else if (priv->LedMode == 9) {
			ax8817x_swmii_mdio_write_le(dev->net,
					dev->mii.phy_id, 28, 0x7a10);
		} else if (priv->LedMode == 10) {
			ax8817x_swmii_mdio_write_le(dev->net,
					dev->mii.phy_id, 28, 0x7a13);
		}

		for (i = 0; i < (sizeof(AGERE_FAMILY_HWINIT) /
				 sizeof(AGERE_FAMILY_HWINIT[0])); i++) {
			ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, AGERE_FAMILY_HWINIT[i].offset,
				AGERE_FAMILY_HWINIT[i].value);
		}
	} else if (priv->PhyMode == PHY_MODE_RTL8211CL) {

		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 0x1f, 0x0005);
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 0x0c, 0);

		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 0x01,
				(ax8817x_swmii_mdio_read_le(dev->net,
					dev->mii.phy_id, 0x01) | 0x0080));
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 0x1f, 0);

		if (priv->LedMode == 12) {
			ax8817x_swmii_mdio_write_le(dev->net,
					dev->mii.phy_id, 0x1f, 0x0002);
			ax8817x_swmii_mdio_write_le(dev->net,
					dev->mii.phy_id, 0x1a, 0x00cb);
			ax8817x_swmii_mdio_write_le(dev->net,
					dev->mii.phy_id, 0x1f, 0);
		}
	} else if (priv->PhyMode == PHY_MODE_VSC8601) {
		Vitess_8601_Init(dev, 1);
	}

	/* read phy register 0 */
	PhyCtrl = ax8817x_swmii_mdio_read_le(dev->net,
				dev->mii.phy_id, MII_BMCR);
	TempShort = PhyCtrl;
	PhyCtrl &= ~(BMCR_PDOWN | BMCR_ISOLATE);
	if (PhyCtrl != TempShort) {
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, MII_BMCR, PhyCtrl);
	}

	/* led */
	if (priv->PhyMode == PHY_MODE_MARVELL) {
		if (priv->LedMode == 1) {

			PhyReg = (ax8817x_swmii_mdio_read_le(dev->net,
				dev->mii.phy_id, 24) & 0xf8ff) | (1 + 0x100);
			ax8817x_swmii_mdio_write_le(dev->net,
					dev->mii.phy_id, 24, PhyReg);
			PhyReg = ax8817x_swmii_mdio_read_le(dev->net,
					dev->mii.phy_id, 25) & 0xfc0f;

		} else if (priv->LedMode == 2) {

			PhyReg = (ax8817x_swmii_mdio_read_le(dev->net,
					dev->mii.phy_id, 24) & 0xf886) |
					(1 + 0x10 + 0x300);
			ax8817x_swmii_mdio_write_le(dev->net,
					dev->mii.phy_id, 24, PhyReg);

		} else if (priv->LedMode == 5) {

			PhyReg = (ax8817x_swmii_mdio_read_le(dev->net,
					dev->mii.phy_id, 24) & 0xf8be) |
					(1 + 0x40 + 0x300);
			ax8817x_swmii_mdio_write_le(dev->net,
					dev->mii.phy_id, 24, PhyReg);

		} else if (priv->LedMode == 7) {

			PhyReg = (ax8817x_swmii_mdio_read_le(dev->net,
						dev->mii.phy_id, 24) & 0xf8ff) |
						(1 + 0x100);
			ax8817x_swmii_mdio_write_le(dev->net,
					dev->mii.phy_id, 24, PhyReg);

		} else if (priv->LedMode == 8) {

			PhyReg = (ax8817x_swmii_mdio_read_le(dev->net,
					dev->mii.phy_id, 24) & 0xf8be) |
					(1 + 0x40 + 0x100);
			ax8817x_swmii_mdio_write_le(dev->net,
					dev->mii.phy_id, 24, PhyReg);

		} else if (priv->LedMode == 11) {

			PhyReg = ax8817x_swmii_mdio_read_le(dev->net,
					dev->mii.phy_id, 24) & 0x4106;
			ax8817x_swmii_mdio_write_le(dev->net,
					dev->mii.phy_id, 24, PhyReg);

		}
	} else if ((priv->PhyMode == PHY_MODE_CICADA_V1) ||
		   (priv->PhyMode == PHY_MODE_CICADA_V2) ||
		   (priv->PhyMode == PHY_MODE_CICADA_V2_ASIX)) {

		if (priv->LedMode == 3) {

			PhyReg = (ax8817x_swmii_mdio_read_le(dev->net,
					dev->mii.phy_id, 27) & 0xFCFF) | 0x0100;
			ax8817x_swmii_mdio_write_le(dev->net,
					dev->mii.phy_id, 27, PhyReg);
		}

	}

	if (priv->PhyMode == PHY_MODE_MARVELL) {
		if (priv->LedMode == 1)
			PhyReg |= 0x3f0;
	}
	PhyAnar = ADVERTISE_CSMA    | ADVERTISE_PAUSE_CAP |
		  ADVERTISE_100FULL | ADVERTISE_100HALF |
		  ADVERTISE_10FULL  | ADVERTISE_10HALF |
		  ADVERTISE_PAUSE_ASYM;
	ax8817x_swmii_mdio_write_le(dev->net,
			dev->mii.phy_id, MII_ADVERTISE, PhyAnar);
	PhyAuxCtrl = ADVERTISE_1000FULL;
	ax8817x_swmii_mdio_write_le(dev->net,
			dev->mii.phy_id, MII_CTRL1000, PhyAuxCtrl);

	if (priv->PhyMode == PHY_MODE_VSC8601) {
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 31, 0x52B5);
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 16, 0xA7F8);
		TempShort = ax8817x_swmii_mdio_read_le(dev->net,
					dev->mii.phy_id, 17) & (~0x0018);
		ax8817x_swmii_mdio_write_le(dev->net,
					dev->mii.phy_id, 17, TempShort);
		TempShort = ax8817x_swmii_mdio_read_le(dev->net,
					dev->mii.phy_id, 18);
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 18, TempShort);
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 16, 0x87F8);
		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, 31, 0);
	}

	if (priv->PhyMode == PHY_MODE_ATTANSIC_V0) {

		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, MII_BMCR, 0x9000);

	} else {
		PhyCtrl &= ~BMCR_LOOPBACK;
		PhyCtrl |= (BMCR_ANENABLE | BMCR_ANRESTART);

		ax8817x_swmii_mdio_write_le(dev->net,
				dev->mii.phy_id, MII_BMCR, PhyCtrl);
	}

	if (priv->PhyMode == PHY_MODE_MARVELL) {
		if (priv->LedMode == 1)
			ax8817x_swmii_mdio_write_le(dev->net,
					dev->mii.phy_id, 25, PhyReg);
	}

SkipPhySetting:

	asix_write_medium_mode(dev, priv->MediaLink);
	ax8817x_write_cmd(dev, AX_CMD_WRITE_IPG0,
			AX88772_IPG0_DEFAULT | (AX88772_IPG1_DEFAULT << 8),
			AX88772_IPG2_DEFAULT, 0, NULL);
	usleep_range(1000, 2000);
	ax8817x_write_cmd(dev, AX_CMD_SET_HW_MII, 0, 0, 0, NULL);
	return 0;
}

static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
{
	int ret;
	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;
	struct ax88178_data *priv;

	usbnet_get_endpoints(dev, intf);

	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
	if (!priv) {
		netdev_err(dev->net, "%s: kzalloc(priv) failed\n", __func__);
		return -ENOMEM;
	}
	dev->driver_priv = priv;

	/* Get the EEPROM data*/
	ret = asix_read_eeprom_le16(dev, 0x17, &priv->EepromData);
	if (ret < 0)
		goto err_out;

	if (priv->EepromData == 0xffff) {
		priv->PhyMode  = PHY_MODE_MARVELL;
		priv->LedMode  = 0;
		priv->UseGpio0 = 1;
	} else {
		priv->PhyMode = (u8)(priv->EepromData & EEPROMMASK);
		priv->LedMode = (u8)(priv->EepromData >> 8);
		if (priv->LedMode == 6)	/* for buffalo new (use gpio2) */
			priv->LedMode = 1;
		else if (priv->LedMode == 1)
			priv->BuffaloOld = 1;


		if (priv->EepromData & 0x80)
			priv->UseGpio0 = 0; /* MARVEL se and other */
		else
			priv->UseGpio0 = 1; /* cameo */
	}

	if (priv->UseGpio0) {

		if (priv->PhyMode == PHY_MODE_MARVELL) {

			ret = asix_write_gpio(dev, 25,
				AXGPIOS_GPO0EN | AXGPIOS_RSE);
			if (ret)
				goto err_out;
			ret = asix_write_gpio(dev, 15,
				AXGPIOS_GPO2 | AXGPIOS_GPO2EN |
				AXGPIOS_GPO0EN);
			if (ret)
				goto err_out;
			ret = asix_write_gpio(dev, 245,
				AXGPIOS_GPO2EN | AXGPIOS_GPO0EN);
			if (ret)
				goto err_out;
			ret = asix_write_gpio(dev, 0,
				AXGPIOS_GPO2 | AXGPIOS_GPO2EN |
				AXGPIOS_GPO0EN);
			if (ret)
				goto err_out;

		} else { /* vitesse */

			ret = asix_write_gpio(dev, 25,
				AXGPIOS_RSE | AXGPIOS_GPO0EN |
				AXGPIOS_GPO0);
			if (ret)
				goto err_out;
			ret = asix_write_gpio(dev, 25,
				AXGPIOS_GPO0EN | AXGPIOS_GPO0 |
				AXGPIOS_GPO2EN | AXGPIOS_GPO2);
			if (ret)
				goto err_out;
			ret = asix_write_gpio(dev, 245,
				AXGPIOS_GPO0EN | AXGPIOS_GPO0 |
				AXGPIOS_GPO2EN);
			if (ret)
				goto err_out;
			ret = asix_write_gpio(dev, 0,
				AXGPIOS_GPO0EN | AXGPIOS_GPO0 |
				AXGPIOS_GPO2EN | AXGPIOS_GPO2);
			if (ret)
				goto err_out;
		}

	} else { /* use gpio1 */

		if (priv->BuffaloOld) {
			ret = asix_write_gpio(dev, 350,
				AXGPIOS_GPO1 | AXGPIOS_GPO1EN |
				AXGPIOS_RSE);
			if (ret)
				goto err_out;
			ret = asix_write_gpio(dev, 350,
				AXGPIOS_GPO1EN);
			if (ret)
				goto err_out;
			ret = asix_write_gpio(dev, 0,
				AXGPIOS_GPO1EN | AXGPIOS_GPO1);
			if (ret)
				goto err_out;
		} else {
			ret = asix_write_gpio(dev, 25,
				AXGPIOS_GPO1 | AXGPIOS_GPO1EN |
				AXGPIOS_RSE);
			if (ret)
				goto err_out;
			ret = asix_write_gpio(dev, 25,
				AXGPIOS_GPO1EN | AXGPIOS_GPO1 |
				AXGPIOS_GPO2EN | AXGPIOS_GPO2);
			if (ret)
				goto err_out;
			ret = asix_write_gpio(dev, 245,
				AXGPIOS_GPO1EN | AXGPIOS_GPO1 |
				AXGPIOS_GPO2EN);
			if (ret)
				goto err_out;
			ret = asix_write_gpio(dev, 0,
				AXGPIOS_GPO1EN | AXGPIOS_GPO1 |
				AXGPIOS_GPO2EN | AXGPIOS_GPO2);
			if (ret)
				goto err_out;
		}
	}

	ret = asix_phy_select(dev, 0);
	if (ret < 0)
		goto err_out;

	ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
				AX_SWRESET_IPPD | AX_SWRESET_PRL, 0, 0, NULL);
	if (ret < 0) {
		netdev_err(dev->net, "%s: SW_RESET failed\n", __func__);
		goto err_out;
	}

	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL, 0, 0, 0, NULL);
	if (ret < 0) {
		netdev_err(dev->net, "%s: RX_CTL failed\n", __func__);
		goto err_out;
	}

	/* Get the MAC address */
	ret = asix_read_mac(dev, AX88772_CMD_READ_NODE_ID);
	if (ret < 0)
		goto err_out;

	ret = ax88178_phy_init(dev, priv);
	if (ret < 0)
		goto err_out;

	dev->net->netdev_ops = &ax88x72_netdev_ops;
	dev->net->ethtool_ops = &ax8817x_ethtool_ops;

	/* Register suspend and resume functions */
	data->suspend = ax88772_suspend;
	data->resume = ax88772_resume;

	if (dev->driver_info->flags & FLAG_FRAMING_AX)
		dev->rx_urb_size = 16384;

	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
			(AX_RX_CTL_MFB | AX_RX_CTL_START | AX_RX_CTL_AB),
			0, 0, NULL);
	if (ret < 0) {
		netdev_err(dev->net, "%s: RX_CTL failed\n", __func__);
		goto err_out;
	}

	printk(KERN_INFO "%s\n", driver_version);
	return ret;

err_out:
	kfree(priv);
	return ret;
}

static void ax88178_unbind(struct usbnet *dev, struct usb_interface *intf)
{
	struct ax88178_data *priv = (struct ax88178_data *)dev->driver_priv;

	if (priv) {

		/* stop MAC operation */
		ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
					AX_RX_CTL_STOP, 0, 0, NULL);
		kfree(priv);
	}
}

static int ax88772_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
{
	u8  *head;
	u32  header;
	char *packet;
	struct sk_buff *ax_skb;
	u16 size;

	head = (u8 *) skb->data;
	memcpy(&header, head, sizeof(header));
	le32_to_cpus(&header);
	packet = head + sizeof(header);

	skb_pull(skb, 4);

	while (skb->len > 0) {
		if ((short)(header & 0x0000ffff) !=
		    ~((short)((header & 0xffff0000) >> 16))) {
			netdev_err(dev->net,
				"%s: header length data is error 0x%08x, %d\n",
				__func__, header, skb->len);
		}
		/* get the packet length */
		size = (u16) (header & 0x0000ffff);

		if ((skb->len) - ((size + 1) & 0xfffe) == 0) {

			/* Make sure ip header is aligned on 32-bit boundary */
			if (!((unsigned long)skb->data & 0x02)) {
				memmove(skb->data - 2, skb->data, size);
				skb->data -= 2;
				skb_set_tail_pointer(skb, size);
			}
			skb->truesize = size + sizeof(struct sk_buff);
			return 2;
		}

		if (size > ETH_FRAME_LEN) {
			netdev_err(dev->net, "%s: invalid rx length %d\n",
							__func__, size);
			return 0;
		}
		ax_skb = skb_clone(skb, GFP_ATOMIC);
		if (ax_skb) {

			/* Make sure ip header is aligned on 32-bit boundary */
			if (!((unsigned long)packet & 0x02)) {
				memmove(packet - 2, packet, size);
				packet -= 2;
			}
			ax_skb->data = packet;
			skb_set_tail_pointer(ax_skb, size);
			ax_skb->truesize = size + sizeof(struct sk_buff);
			usbnet_skb_return(dev, ax_skb);

		} else {
			return 0;
		}

		skb_pull(skb, (size + 1) & 0xfffe);

		if (skb->len == 0)
			break;

		head = (u8 *) skb->data;
		memcpy(&header, head, sizeof(header));
		le32_to_cpus(&header);
		packet = head + sizeof(header);
		skb_pull(skb, 4);
	}

	if (skb->len < 0) {
		netdev_err(dev->net, "%s: invalid rx length %d\n",
						__func__, skb->len);
		return 0;
	}
	return 1;
}

static struct sk_buff *ax88772_tx_fixup(struct usbnet *dev,
					struct sk_buff *skb, gfp_t flags)
{
	int padlen = ((skb->len + 4) % 512) ? 0 : 4;
	u32 packet_len;
	u32 padbytes = 0xffff0000;
	int headroom = skb_headroom(skb);
	int tailroom = skb_tailroom(skb);

	if ((!skb_cloned(skb))
	    && ((headroom + tailroom) >= (4 + padlen))) {
		if ((headroom < 4) || (tailroom < padlen)) {
			skb->data = memmove(skb->head + 4, skb->data, skb->len);
			skb_set_tail_pointer(skb, skb->len);
		}
	} else {
		struct sk_buff *skb2;
		skb2 = skb_copy_expand(skb, 4, padlen, flags);
		dev_kfree_skb_any(skb);
		skb = skb2;
		if (!skb)
			return NULL;
	}

	skb_push(skb, 4);
	packet_len = (((skb->len - 4) ^ 0x0000ffff) << 16) + (skb->len - 4);
	cpu_to_le32s(&packet_len);
	skb_copy_to_linear_data(skb, &packet_len, sizeof(packet_len));

	if ((skb->len % 512) == 0) {
		cpu_to_le32s(&padbytes);
		memcpy(skb_tail_pointer(skb), &padbytes, sizeof(padbytes));
		skb_put(skb, sizeof(padbytes));
	}
	return skb;
}

static void
ax88772b_rx_checksum(struct sk_buff *skb, struct ax88772b_rx_header *rx_hdr)
{
	skb->ip_summed = CHECKSUM_NONE;

	/* checksum error bit is set */
	if (rx_hdr->l3_csum_err || rx_hdr->l4_csum_err)
		return;

	/* It must be a TCP or UDP packet with a valid checksum */
	if ((rx_hdr->l4_type == AX_RXHDR_L4_TYPE_TCP) ||
	    (rx_hdr->l4_type == AX_RXHDR_L4_TYPE_UDP)) {
		skb->ip_summed = CHECKSUM_UNNECESSARY;
	}
}

static int ax88772b_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
{
	struct ax88772b_rx_header rx_hdr;
	struct sk_buff *ax_skb;
	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;

	while (skb->len > 0) {

		memcpy(&rx_hdr, skb->data, sizeof(struct ax88772b_rx_header));

		if ((short)rx_hdr.len != (~((short)rx_hdr.len_bar) & 0x7FF))
			return 0;
		if (rx_hdr.len > (ETH_FRAME_LEN + 4)) {
			netdev_err(dev->net, "%s: invalid rx length %d\n",
						__func__, rx_hdr.len);
			return 0;
		}

		if (skb->len - ((rx_hdr.len +
				 sizeof(struct ax88772b_rx_header) + 3) &
				 0xfffc) == 0) {
			skb_pull(skb, sizeof(struct ax88772b_rx_header));
			skb->len = rx_hdr.len;

			skb_set_tail_pointer(skb, rx_hdr.len);
			skb->truesize = rx_hdr.len + sizeof(struct sk_buff);

			if (priv->checksum & AX_RX_CHECKSUM)
				ax88772b_rx_checksum(skb, &rx_hdr);

			return 2;
		}

		ax_skb = skb_clone(skb, GFP_ATOMIC);
		if (ax_skb) {
			ax_skb->len = rx_hdr.len;
			ax_skb->data = skb->data +
				       sizeof(struct ax88772b_rx_header);
			skb_set_tail_pointer(ax_skb, rx_hdr.len);
			ax_skb->truesize = rx_hdr.len + sizeof(struct sk_buff);
			if (priv->checksum & AX_RX_CHECKSUM)
				ax88772b_rx_checksum(ax_skb, &rx_hdr);
			usbnet_skb_return(dev, ax_skb);

		} else {
			return 0;
		}

		skb_pull(skb, ((rx_hdr.len +
				sizeof(struct ax88772b_rx_header) + 3)
				& 0xfffc));
	}

	if (skb->len < 0) {
		netdev_err(dev->net, "%s: invalid rx length %d\n",
					__func__, skb->len);
		return 0;
	}
	return 1;
}

static struct sk_buff *
ax88772b_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
{
	int padlen = ((skb->len + 4) % 512) ? 0 : 4;
	u32 packet_len;
	u32 padbytes = 0xffff0000;
	int headroom = skb_headroom(skb);
	int tailroom = skb_tailroom(skb);

	if ((!skb_cloned(skb))
	    && ((headroom + tailroom) >= (4 + padlen))) {
		if ((headroom < 4) || (tailroom < padlen)) {
			skb->data = memmove(skb->head + 4, skb->data, skb->len);
			skb_set_tail_pointer(skb, skb->len);
		}
	} else {
		struct sk_buff *skb2;
		skb2 = skb_copy_expand(skb, 4, padlen, flags);
		dev_kfree_skb_any(skb);
		skb = skb2;
		if (!skb)
			return NULL;
	}

	skb_push(skb, 4);
	packet_len = (((skb->len - 4) ^ 0x0000ffff) << 16) + (skb->len - 4);

	cpu_to_le32s(&packet_len);
	skb_copy_to_linear_data(skb, &packet_len, sizeof(packet_len));

	if ((skb->len % 512) == 0) {
		cpu_to_le32s(&padbytes);
		memcpy(skb_tail_pointer(skb), &padbytes, sizeof(padbytes));
		skb_put(skb, sizeof(padbytes));
	}

	return skb;
}

static const u8 ChkCntSel[6][3] = {
	{12, 23, 31},
	{12, 31, 23},
	{23, 31, 12},
	{23, 12, 31},
	{31, 12, 23},
	{31, 23, 12}
};

static void ax88772_link_reset(struct work_struct *work)
{
	struct ax88772_data *priv = container_of(work,
					struct ax88772_data, check_link);
	struct usbnet *dev = priv->dev;

	if (priv->Event == AX_SET_RX_CFG) {
		u16 bmcr;
		u16 mode;

		priv->Event = AX_NOP;

		mode = AX88772_MEDIUM_DEFAULT;

		bmcr = ax8817x_mdio_read_le(dev->net,
				dev->mii.phy_id, MII_BMCR);
		if (!(bmcr & BMCR_FULLDPLX))
			mode &= ~AX88772_MEDIUM_FULL_DUPLEX;
		if (!(bmcr & BMCR_SPEED100))
			mode &= ~AX88772_MEDIUM_100MB;
		asix_write_medium_mode(dev, mode);
		return;
	}

	switch (priv->Event) {
	case WAIT_AUTONEG_COMPLETE:
		if (jiffies > (priv->autoneg_start + 5 * HZ)) {
			priv->Event = PHY_POWER_DOWN;
			priv->TickToExpire = 23;
		}
		break;
	case PHY_POWER_DOWN:
		if (priv->TickToExpire == 23) {
			/* Set Phy Power Down */
			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
					  AX_SWRESET_IPPD,
					  0, 0, NULL);
			--priv->TickToExpire;
		} else if (--priv->TickToExpire == 0) {
			/* Set Phy Power Up */
			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
				AX_SWRESET_IPRL, 0, 0, NULL);
			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
				AX_SWRESET_IPPD | AX_SWRESET_IPRL, 0, 0, NULL);
			usleep_range(10000, 20000);
			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
				AX_SWRESET_IPRL, 0, 0, NULL);
			msleep(60);
			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
				AX_SWRESET_CLEAR, 0, 0, NULL);
			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
				AX_SWRESET_IPRL, 0, 0, NULL);
			ax8817x_mdio_write_le(dev->net, dev->mii.phy_id,
				MII_ADVERTISE,
				ADVERTISE_ALL | ADVERTISE_CSMA |
				ADVERTISE_PAUSE_CAP);
			mii_nway_restart(&dev->mii);

			priv->Event = PHY_POWER_UP;
			priv->TickToExpire = 47;
		}
		break;
	case PHY_POWER_UP:
		if (--priv->TickToExpire == 0) {
			priv->Event = PHY_POWER_DOWN;
			priv->TickToExpire = 23;
		}
		break;
	default:
		break;
	}
	return;
}

static void ax88772a_link_reset(struct work_struct *work)
{
	struct ax88772a_data *priv = container_of(work,
					struct ax88772a_data, check_link);
	struct usbnet *dev = priv->dev;
	int PowSave = (priv->EepromData >> 14);
	u16 phy_reg;

	if (priv->Event == AX_SET_RX_CFG) {
		u16 bmcr;
		u16 mode;

		priv->Event = AX_NOP;

		mode = AX88772_MEDIUM_DEFAULT;

		bmcr = ax8817x_mdio_read_le(dev->net,
				dev->mii.phy_id, MII_BMCR);
		if (!(bmcr & BMCR_FULLDPLX))
			mode &= ~AX88772_MEDIUM_FULL_DUPLEX;
		if (!(bmcr & BMCR_SPEED100))
			mode &= ~AX88772_MEDIUM_100MB;
		asix_write_medium_mode(dev, mode);
		return;
	}

	switch (priv->Event) {
	case WAIT_AUTONEG_COMPLETE:
		if (jiffies > (priv->autoneg_start + 5 * HZ)) {
			priv->Event = CHK_CABLE_EXIST;
			priv->TickToExpire = 14;
		}
		break;
	case CHK_CABLE_EXIST:
		phy_reg = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, 0x12);
		if ((phy_reg != 0x8012) && (phy_reg != 0x8013)) {
			ax8817x_mdio_write_le(dev->net,
				dev->mii.phy_id, 0x16, 0x4040);
			mii_nway_restart(&dev->mii);
			priv->Event = CHK_CABLE_STATUS;
			priv->TickToExpire = 31;
		} else if (--priv->TickToExpire == 0) {
			mii_nway_restart(&dev->mii);
			priv->Event = CHK_CABLE_EXIST_AGAIN;
			if (PowSave == 0x03) {
				priv->TickToExpire = 47;
			} else if (PowSave == 0x01) {
				priv->DlyIndex = (u8)(jiffies % 6);
				priv->DlySel = 0;
				priv->TickToExpire =
				ChkCntSel[priv->DlyIndex][priv->DlySel];
			}
		}
		break;
	case CHK_CABLE_EXIST_AGAIN:
		/* if cable disconnected */
		phy_reg = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, 0x12);
		if ((phy_reg != 0x8012) && (phy_reg != 0x8013)) {
			mii_nway_restart(&dev->mii);
			priv->Event = CHK_CABLE_STATUS;
			priv->TickToExpire = 31;
		} else if (--priv->TickToExpire == 0) {
			/* Power down PHY */
			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
					  AX_SWRESET_IPPD,
					  0, 0, NULL);
			priv->Event = PHY_POWER_DOWN;
			if (PowSave == 0x03)
				priv->TickToExpire = 23;
			else if (PowSave == 0x01)
				priv->TickToExpire = 31;
		}
		break;
	case PHY_POWER_DOWN:
		if (--priv->TickToExpire == 0)
			priv->Event = PHY_POWER_UP;
		break;
	case CHK_CABLE_STATUS:
		if (--priv->TickToExpire == 0) {
			ax8817x_mdio_write_le(dev->net,
				dev->mii.phy_id, 0x16, 0x4040);
			mii_nway_restart(&dev->mii);
			priv->Event = CHK_CABLE_EXIST_AGAIN;
			if (PowSave == 0x03) {
				priv->TickToExpire = 47;
			} else if (PowSave == 0x01) {
				priv->DlyIndex = (u8)(jiffies % 6);
				priv->DlySel = 0;
				priv->TickToExpire =
				ChkCntSel[priv->DlyIndex][priv->DlySel];
			}
		}
		break;
	case PHY_POWER_UP:
		ax88772a_phy_powerup(dev);
		ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_ADVERTISE,
			ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
		mii_nway_restart(&dev->mii);
		priv->Event = CHK_CABLE_EXIST_AGAIN;
		if (PowSave == 0x03) {
			priv->TickToExpire = 47;
		} else if (PowSave == 0x01) {
			if (++priv->DlySel >= 3) {
				priv->DlyIndex = (u8)(jiffies % 6);
				priv->DlySel = 0;
			}
			priv->TickToExpire =
				ChkCntSel[priv->DlyIndex][priv->DlySel];
		}
		break;
	default:
		break;
	}

	return;
}

static void ax88772b_link_reset(struct work_struct *work)
{
	struct ax88772b_data *priv = container_of(work,
					struct ax88772b_data, check_link);
	struct usbnet *dev = priv->dev;

	switch (priv->Event) {
	case AX_SET_RX_CFG:
	{
		u16 bmcr = ax8817x_mdio_read_le(dev->net,
					dev->mii.phy_id, MII_BMCR);
		u16 mode = AX88772_MEDIUM_DEFAULT;

		if (!(bmcr & BMCR_FULLDPLX))
			mode &= ~AX88772_MEDIUM_FULL_DUPLEX;
		if (!(bmcr & BMCR_SPEED100))
			mode &= ~AX88772_MEDIUM_100MB;
		asix_write_medium_mode(dev, mode);
		break;
	}
	case PHY_POWER_UP:
	{
		u16 tmp16;

		ax88772a_phy_powerup(dev);
		tmp16 = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, 0x12);
		ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, 0x12,
				((tmp16 & 0xFF9F) | 0x0040));
		ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_ADVERTISE,
			ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
		break;
	}
	default:
		break;
	}

	priv->Event = AX_NOP;

	return;
}

static int ax88178_set_media(struct usbnet *dev)
{
	int	ret;
	struct ax88178_data *priv = (struct ax88178_data *)dev->driver_priv;
	int media;

	media = ax88178_media_check(dev, priv);
	if (media < 0)
		return media;
	ret = asix_write_medium_mode(dev, media);
	if (ret < 0)
		return ret;
	return 0;
}

static int ax88178_link_reset(struct usbnet *dev)
{
	return ax88178_set_media(dev);
}

static int ax_suspend(struct usb_interface *intf,
			pm_message_t message)
{
	struct usbnet *dev = usb_get_intfdata(intf);
	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;

	return data->suspend(intf, message);
}

static int ax_resume(struct usb_interface *intf)
{
	struct usbnet *dev = usb_get_intfdata(intf);
	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;

	return data->resume(intf);
}

static const struct driver_info ax88178_info = {
	.description = "ASIX AX88178 USB 2.0 Ethernet",
	.bind = ax88178_bind,
	.unbind = ax88178_unbind,
	.status = ax88178_status,
	.link_reset = ax88178_link_reset,
	.reset = ax88178_link_reset,
	.flags =  FLAG_ETHER | FLAG_FRAMING_AX,
	.rx_fixup = ax88772_rx_fixup,
	.tx_fixup = ax88772_tx_fixup,
};

static const struct driver_info belkin178_info = {
	.description = "Belkin Gigabit USB 2.0 Network Adapter",
	.bind = ax88178_bind,
	.unbind = ax88178_unbind,
	.status = ax8817x_status,
	.link_reset = ax88178_link_reset,
	.reset = ax88178_link_reset,
	.flags =  FLAG_ETHER | FLAG_FRAMING_AX,
	.rx_fixup = ax88772_rx_fixup,
	.tx_fixup = ax88772_tx_fixup,
};

static const struct driver_info ax8817x_info = {
	.description = "ASIX AX8817x USB 2.0 Ethernet",
	.bind = ax8817x_bind,
	.status = ax8817x_status,
	.link_reset = ax88172_link_reset,
	.reset = ax88172_link_reset,
	.flags =  FLAG_ETHER,
};

static const struct driver_info dlink_dub_e100_info = {
	.description = "DLink DUB-E100 USB Ethernet",
	.bind = ax8817x_bind,
	.status = ax8817x_status,
	.link_reset = ax88172_link_reset,
	.reset = ax88172_link_reset,
	.flags =  FLAG_ETHER,
};

static const struct driver_info netgear_fa120_info = {
	.description = "Netgear FA-120 USB Ethernet",
	.bind = ax8817x_bind,
	.status = ax8817x_status,
	.link_reset = ax88172_link_reset,
	.reset = ax88172_link_reset,
	.flags =  FLAG_ETHER,
};

static const struct driver_info hawking_uf200_info = {
	.description = "Hawking UF200 USB Ethernet",
	.bind = ax8817x_bind,
	.status = ax8817x_status,
	.link_reset = ax88172_link_reset,
	.reset = ax88172_link_reset,
	.flags =  FLAG_ETHER,
};

static const struct driver_info ax88772_info = {
	.description = "ASIX AX88772 USB 2.0 Ethernet",
	.bind = ax88772_bind,
	.unbind = ax88772_unbind,
	.status = ax88772_status,
	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
	.rx_fixup = ax88772_rx_fixup,
	.tx_fixup = ax88772_tx_fixup,
};

static const struct driver_info dlink_dub_e100b_info = {
	.description = "D-Link DUB-E100 USB 2.0 Fast Ethernet Adapter",
	.bind = ax88772_bind,
	.unbind = ax88772_unbind,
	.status = ax88772_status,
	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
	.rx_fixup = ax88772_rx_fixup,
	.tx_fixup = ax88772_tx_fixup,
};

static const struct driver_info ax88772a_info = {
	.description = "ASIX AX88772A USB 2.0 Ethernet",
	.bind = ax88772a_bind,
	.unbind = ax88772a_unbind,
	.status = ax88772a_status,
	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
	.rx_fixup = ax88772_rx_fixup,
	.tx_fixup = ax88772_tx_fixup,
};

static const struct driver_info ax88772b_info = {
	.description = "ASIX AX88772B USB 2.0 Ethernet",
	.bind = ax88772b_bind,
	.unbind = ax88772b_unbind,
	.status = ax88772b_status,
	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
	.rx_fixup = ax88772b_rx_fixup,
	.tx_fixup = ax88772b_tx_fixup,
};

static const struct usb_device_id	products[] = {
{
	/* 88178 */
	USB_DEVICE(0x0b95, 0x1780),
	.driver_info =	(unsigned long) &ax88178_info,
}, {
	/* 88178 for billianton linksys */
	USB_DEVICE(0x077b, 0x2226),
	.driver_info =	(unsigned long) &ax88178_info,
}, {
	/* ABOCOM for linksys */
	USB_DEVICE(0x1737, 0x0039),
	.driver_info =	(unsigned long) &ax88178_info,
}, {
	/* ABOCOM  for pci */
	USB_DEVICE(0x14ea, 0xab11),
	.driver_info =	(unsigned long) &ax88178_info,
}, {
	/* Belkin */
	USB_DEVICE(0x050d, 0x5055),
	.driver_info =	(unsigned long) &belkin178_info,
}, {
	/* Linksys USB200M */
	USB_DEVICE(0x077b, 0x2226),
	.driver_info =	(unsigned long) &ax8817x_info,
}, {
	/* Netgear FA120 */
	USB_DEVICE(0x0846, 0x1040),
	.driver_info =  (unsigned long) &netgear_fa120_info,
}, {
	/* DLink DUB-E100 */
	USB_DEVICE(0x2001, 0x1a00),
	.driver_info =  (unsigned long) &dlink_dub_e100_info,
}, {
	/* DLink DUB-E100B */
	USB_DEVICE(0x2001, 0x3c05),
	.driver_info =  (unsigned long) &dlink_dub_e100b_info,
}, {
	/* DLink DUB-E100B */
	USB_DEVICE(0x07d1, 0x3c05),
	.driver_info =  (unsigned long) &dlink_dub_e100b_info,
}, {
	/* Intellinet, ST Lab USB Ethernet */
	USB_DEVICE(0x0b95, 0x1720),
	.driver_info =  (unsigned long) &ax8817x_info,
}, {
	/* Hawking UF200, TrendNet TU2-ET100 */
	USB_DEVICE(0x07b8, 0x420a),
	.driver_info =  (unsigned long) &hawking_uf200_info,
}, {
	/* Billionton Systems, USB2AR */
	USB_DEVICE(0x08dd, 0x90ff),
	.driver_info =  (unsigned long) &ax8817x_info,
}, {
	/* ATEN UC210T */
	USB_DEVICE(0x0557, 0x2009),
	.driver_info =  (unsigned long) &ax8817x_info,
}, {
	/* Buffalo LUA-U2-KTX */
	USB_DEVICE(0x0411, 0x003d),
	.driver_info =  (unsigned long) &ax8817x_info,
}, {
	/* Sitecom LN-029 "USB 2.0 10/100 Ethernet adapter" */
	USB_DEVICE(0x6189, 0x182d),
	.driver_info =  (unsigned long) &ax8817x_info,
}, {
	/* corega FEther USB2-TX */
	USB_DEVICE(0x07aa, 0x0017),
	.driver_info =  (unsigned long) &ax8817x_info,
}, {
	/* Surecom EP-1427X-2 */
	USB_DEVICE(0x1189, 0x0893),
	.driver_info = (unsigned long) &ax8817x_info,
}, {
	/* goodway corp usb gwusb2e */
	USB_DEVICE(0x1631, 0x6200),
	.driver_info = (unsigned long) &ax8817x_info,
}, {
	/* ASIX AX88772 10/100 */
	USB_DEVICE(0x0b95, 0x7720),
	.driver_info = (unsigned long) &ax88772_info,
}, {
	/* ASIX AX88772 10/100 */
	USB_DEVICE(0x125E, 0x180D),
	.driver_info = (unsigned long) &ax88772_info,
}, {
	/* ASIX AX88772A 10/100 */
	USB_DEVICE(0x0b95, 0x772A),
	.driver_info = (unsigned long) &ax88772a_info,
}, {
	/* ASIX AX88772A 10/100 */
	USB_DEVICE(0x0db0, 0xA877),
	.driver_info = (unsigned long) &ax88772a_info,
}, {
	/* ASIX AX88772A 10/100 */
	USB_DEVICE(0x0421, 0x772A),
	.driver_info = (unsigned long) &ax88772a_info,
}, {
	/* Linksys 200M */
	USB_DEVICE(0x13B1, 0x0018),
	.driver_info = (unsigned long) &ax88772a_info,
}, {
	USB_DEVICE(0x05ac, 0x1402),
	.driver_info = (unsigned long) &ax88772a_info,
}, {
	/* ASIX AX88772B 10/100 */
	USB_DEVICE(0x0b95, 0x772B),
	.driver_info = (unsigned long) &ax88772b_info,
}, {
	/* ASIX AX88772B 10/100 */
	USB_DEVICE(0x0b95, 0x7E2B),
	.driver_info = (unsigned long) &ax88772b_info,
},
	{ },		/* END */
};
MODULE_DEVICE_TABLE(usb, products);

static struct usb_driver asix_driver = {
	.name =		driver_name,
	.id_table =	products,
	.probe =	usbnet_probe,
	.suspend =	ax_suspend,
	.resume =	ax_resume,
	.disconnect =	usbnet_disconnect,
};

static int __init asix_init(void)
{
	return usb_register(&asix_driver);
}
module_init(asix_init);

static void __exit asix_exit(void)
{
	usb_deregister(&asix_driver);
}
module_exit(asix_exit);

MODULE_AUTHOR("David Hollis");
MODULE_DESCRIPTION("ASIX AX8817X based USB 2.0 Ethernet Devices");
MODULE_LICENSE("GPL");
