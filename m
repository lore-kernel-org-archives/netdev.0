From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH V2 2/2] ems_usb: Added support for EMS CPC-USB/ARM7 CAN/USB
	interface
Date: Wed, 16 Sep 2009 11:26:27 +0200
Message-ID: <4AB0AF43.6090605@grandegger.com>
References: <20090916090408.12370.94680.stgit@localhost.localdomain>
	<20090916090418.12370.16510.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org,
	greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Sebastian Haas <haas-zsNKPWJ8Pib6hrUXjxyGrA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20090916090418.12370.16510.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Sebastian Haas wrote:
> This patch adds support for one channel CAN/USB interace CPC-USB/ARM7 from
> EMS Dr. Thomas Wuensche (http://www.ems-wuensche.com).
> 
> Signed-off-by: Sebastian Haas <haas-zsNKPWJ8Pib6hrUXjxyGrA@public.gmane.org>

The cleanup in the probe function is still not OK :-(.

> ---
> 
>  drivers/net/can/Kconfig       |    7 
>  drivers/net/can/Makefile      |    2 
>  drivers/net/can/usb/Makefile  |    5 
>  drivers/net/can/usb/ems_usb.c | 1151 +++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 1165 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/usb/Makefile
>  create mode 100644 drivers/net/can/usb/ems_usb.c
> 
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index 0900743..6ac5aa5 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -75,6 +75,13 @@ config CAN_EMS_PCI
>  	  CPC-PCIe and CPC-104P cards from EMS Dr. Thomas Wuensche
>  	  (http://www.ems-wuensche.de).
>  
> +config CAN_EMS_USB
> +	tristate "EMS CPC-USB/ARM7 CAN/USB interface"
> +	depends on USB && CAN_DEV
> +	---help---
> +	  This driver is for the one channel CPC-USB/ARM7 CAN/USB interface
> +	  from from EMS Dr. Thomas Wuensche (http://www.ems-wuensche.de).
> +
>  config CAN_KVASER_PCI
>  	tristate "Kvaser PCIcanx and Kvaser PCIcan PCI Cards"
>  	depends on PCI && CAN_SJA1000
> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> index 523a941..9b035ec 100644
> --- a/drivers/net/can/Makefile
> +++ b/drivers/net/can/Makefile
> @@ -7,6 +7,8 @@ obj-$(CONFIG_CAN_VCAN)		+= vcan.o
>  obj-$(CONFIG_CAN_DEV)		+= can-dev.o
>  can-dev-y			:= dev.o
>  
> +obj-y				+= usb/
> +
>  obj-$(CONFIG_CAN_SJA1000)	+= sja1000/
>  
>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
> diff --git a/drivers/net/can/usb/Makefile b/drivers/net/can/usb/Makefile
> new file mode 100644
> index 0000000..c3f75ba
> --- /dev/null
> +++ b/drivers/net/can/usb/Makefile
> @@ -0,0 +1,5 @@
> +#
> +#  Makefile for the Linux Controller Area Network USB drivers.
> +#
> +
> +obj-$(CONFIG_CAN_EMS_USB) += ems_usb.o
> diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
[snip]
> +/*
> + * probe function for new CPC-USB devices
> + */
> +static int ems_usb_probe(struct usb_interface *intf,
> +			 const struct usb_device_id *id)
> +{
> +	struct net_device *netdev;
> +	struct ems_usb *dev;
> +	int i, err;
> +	int retval = -ENOMEM;

Why do you need an extra variable here.

	int err = -ENOMEM;

Should work fine!?

> +
> +	netdev = alloc_candev(sizeof(struct ems_usb));
> +	if (!netdev) {
> +		dev_err(netdev->dev.parent, "Couldn't alloc candev\n");
> +		return -ENOMEM;
> +	}
> +
> +	dev = netdev_priv(netdev);
> +
> +	dev->udev = interface_to_usbdev(intf);
> +	dev->netdev = netdev;
> +
> +	dev->can.state = CAN_STATE_STOPPED;
> +	dev->can.clock.freq = EMS_USB_ARM7_CLOCK;
> +	dev->can.bittiming_const = &ems_usb_bittiming_const;
> +	dev->can.do_set_bittiming = ems_usb_set_bittiming;
> +	dev->can.do_set_mode = ems_usb_set_mode;
> +
> +	netdev->flags |= IFF_ECHO; /* we support local echo */
> +
> +	/*
> +	 * The device actually uses a 16MHz clock to generate the CAN clock
> +	 * but it expects SJA1000 bit settings based on 8MHz (is internally
> +	 * converted).
> +	 */
> +
> +	netdev->netdev_ops = &ems_usb_netdev_ops;
> +
> +	netdev->flags |= IFF_ECHO; /* we support local echo */
> +
> +	init_usb_anchor(&dev->rx_submitted);
> +
> +	init_usb_anchor(&dev->tx_submitted);
> +	atomic_set(&dev->active_tx_urbs, 0);
> +
> +	for (i = 0; i < MAX_TX_URBS; i++)
> +		dev->tx_contexts[i].echo_index = MAX_TX_URBS;
> +
> +	dev->intr_urb = usb_alloc_urb(0, GFP_KERNEL);
> +	if (!dev->intr_urb) {
> +		dev_err(netdev->dev.parent, "Couldn't alloc intr URB\n");
> +		goto cleanup_candev;
> +	}
> +
> +	dev->intr_in_buffer = kzalloc(INTR_IN_BUFFER_SIZE, GFP_KERNEL);
> +	if (!dev->intr_in_buffer) {
> +		dev_err(netdev->dev.parent, "Couldn't alloc Intr buffer\n");
> +		goto cleanup_intr_urb;
> +	}
> +
> +	dev->tx_msg_buffer = kzalloc(CPC_HEADER_SIZE +
> +				     sizeof(struct ems_cpc_msg), GFP_KERNEL);
> +	if (!dev->tx_msg_buffer) {
> +		dev_err(netdev->dev.parent, "Couldn't alloc Tx buffer\n");
> +		goto cleanup_intr_in_buffer;
> +	}
> +
> +	usb_set_intfdata(intf, dev);
> +
> +	SET_NETDEV_DEV(netdev, &intf->dev);
> +
> +	init_params_sja1000(&dev->active_params);
> +
> +	err = ems_usb_command_msg(dev, &dev->active_params);
> +	if (err) {
> +		dev_err(netdev->dev.parent,
> +			"couldn't initialize controller: %d\n", err);
> +		retval = err;

Could be removed then.

> +		goto cleanup_tx_msg_buffer;
> +	}
> +
> +	return register_candev(netdev);

Cleanup is missing if register_candev() fails!

> +
> +cleanup_tx_msg_buffer:
> +	kfree(dev->tx_msg_buffer);
> +
> +cleanup_intr_in_buffer:
> +	kfree(dev->intr_in_buffer);
> +
> +cleanup_intr_urb:
> +	usb_free_urb(dev->intr_urb);
> +
> +cleanup_candev:
> +	free_candev(netdev);
> +
> +	return retval;
> +}

Wolfgang.
