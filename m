From: "linux-os \(Dick Johnson\)" <linux-os@analogic.com>
Subject: Re: Router stops routing after changing MAC Address
Date: Mon, 13 Mar 2006 15:27:26 -0500
Message-ID: <Pine.LNX.4.61.0603131513380.5373@chaos.analogic.com>
References: <925A849792280C4E80C5461017A4B8A20321F2@mail733.InfraSupportEtc.com> <20060313100041.212cee08@localhost.localdomain>
Reply-To: "linux-os \(Dick Johnson\)" <linux-os@analogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Greg Scott" <GregScott@InfraSupportEtc.com>,
	"Chuck Ebbert" <76306.1226@compuserve.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Bart Samwel" <bart@samwel.tk>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	"Simon Mackinlay" <smackinlay@mail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751884AbWCMU1v@vger.kernel.org>
in-reply-to: <20060313100041.212cee08@localhost.localdomain>
Content-class: urn:content-classes:message
To: "Stephen Hemminger" <shemminger@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 13 Mar 2006, Stephen Hemminger wrote:

> There still is a bug in the 3c59x driver.  It doesn't include any code
> to handle changing the mac address.  It will work if you take the device
> down, change address, then bring it up. But you shouldn't have to do that.
>
> Also, if the driver handles setting mac address, it could have prevented
> you from using a multicast address.
>
> Something like this is needed (untested, I don't have that hardware).
>
>
> --- linux-2.6/drivers/net/3c59x.c.orig	2006-03-13 09:58:25.000000000 -0800
> +++ linux-2.6/drivers/net/3c59x.c	2006-03-13 09:52:47.000000000 -0800
> @@ -895,6 +895,7 @@ static void dump_tx_ring(struct net_devi
> static void update_stats(void __iomem *ioaddr, struct net_device *dev);
> static struct net_device_stats *vortex_get_stats(struct net_device *dev);
> static void set_rx_mode(struct net_device *dev);
> +static int set_rx_address(struct net_device *dev, void *addr);
> #ifdef CONFIG_PCI
> static int vortex_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
> #endif
> @@ -1563,6 +1564,7 @@ static int __devinit vortex_probe1(struc
> #endif
> 	dev->ethtool_ops = &vortex_ethtool_ops;
> 	dev->set_multicast_list = set_rx_mode;
> +	dev->set_mac_address = set_rx_address;
> 	dev->tx_timeout = vortex_tx_timeout;
> 	dev->watchdog_timeo = (watchdog * HZ) / 1000;
> #ifdef CONFIG_NET_POLL_CONTROLLER
> @@ -3150,6 +3152,27 @@ static void set_rx_mode(struct net_devic
> 	iowrite16(new_mode, ioaddr + EL3_CMD);
> }
>
> +
> +static int set_rx_address(struct net_device *dev, void *p)
> +{
> +	struct vortex_private *vp = netdev_priv(dev);
> +	void __iomem *ioaddr = vp->ioaddr;
> +	const struct sockaddr *addr = p;
> +
> +	if (!is_valid_ether_addr(addr->sa_data))
> +		return -EADDRNOTAVAIL;
> +
> +	spin_lock_bh(&vp->lock);
> +	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
> +
> +	EL3WINDOW(2);
> +	for (i = 0; i < ETH_ALEN; i++)
> +		iowrite8(dev->dev_addr[i], ioaddr + i);
> +	spin_unlock_bh(&vp->lock);
> +
> +	return 0;
> +}
> +
> #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
> /* Setup the card so that it can receive frames with an 802.1q VLAN tag.
>    Note that this must be done after each RxReset due to some backwards
> -

Actually, it doesn't make any difference. Changing the IEEE station
(physical) address is not an allowed procedure even though hooks are
available in many drivers to do this. According to the IEEE 802
physical media specification, this 48-bit address must be unique and
must be one of a group assigned by IEEE. Failure to follow this
simple protocol can (will) cause an entire network to fail. If
you don't care, then you certainly don't care about multicast
bits either, basically let them set it to all ones as well.

Cheers,
Dick Johnson
Penguin : Linux version 2.6.15.4 on an i686 machine (5589.54 BogoMips).
Warning : 98.36% of all statistics are fiction, book release in April.
_


****************************************************************
The information transmitted in this message is confidential and may be privileged.  Any review, retransmission, dissemination, or other use of this information by persons or entities other than the intended recipient is prohibited.  If you are not the intended recipient, please notify Analogic Corporation immediately - by replying to this message or by sending an email to DeliveryErrors@analogic.com - and destroy all copies of this information, including any attachments, without reading or disclosing them.

Thank you.
