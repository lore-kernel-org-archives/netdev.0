From: Brian Norris <briannorris-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 2/3] Bluetooth: btusb: Add out-of-band wakeup support
Date: Wed, 14 Dec 2016 19:21:06 -0800
Message-ID: <20161215032105.GA88921@google.com>
References: <1481742779-15105-1-git-send-email-rajatja@google.com>
 <1481742779-15105-2-git-send-email-rajatja@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
        Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
        Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Wei-Ning Huang <wnhuang-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Xinming Hu <huxm-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        rajatxjain-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Rajat Jain <rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1481742779-15105-2-git-send-email-rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Dec 14, 2016 at 11:12:58AM -0800, Rajat Jain wrote:
> Some BT chips (e.g. Marvell 8997) contain a wakeup pin that can be
> connected to a gpio on the CPU side, and can be used to wakeup
> the host out-of-band. This can be useful in situations where the
> in-band wakeup is not possible or not preferable (e.g. the in-band
> wakeup may require the USB host controller to remain active, and
> hence consuming more system power during system sleep).
> 
> The oob gpio interrupt to be used for wakeup on the CPU side, is
> read from the device tree node, (using standard interrupt descriptors).
> A devcie tree binding document is also added for the driver.
> 
> Signed-off-by: Rajat Jain <rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> ---
>  Documentation/devicetree/bindings/net/btusb.txt | 38 ++++++++++++
>  drivers/bluetooth/btusb.c                       | 82 +++++++++++++++++++++++++
>  2 files changed, 120 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/btusb.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/btusb.txt b/Documentation/devicetree/bindings/net/btusb.txt
> new file mode 100644
> index 0000000..bb27f92
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/btusb.txt
> @@ -0,0 +1,38 @@
> +Generic Bluetooth controller over USB (btusb driver)
> +---------------------------------------------------
> +
> +Required properties:
> +
> +  - compatible : should comply with the format "usbVID,PID" specified in
> +		 Documentation/devicetree/bindings/usb/usb-device.txt
> +		 At the time of writing, the only OF supported devices
> +		 (more may be added later) are:
> +
> +		  "usb1286,204e" (Marvell 8997)
> +
> +Optional properties:
> +
> +  - interrupt-parent: phandle of the parent interrupt controller
> +  - interrupts : The first interrupt specified is the interrupt that shall be
> +		 used for out-of-band wake-on-bt. Driver will request an irq
> +		 based on this interrupt number. During system suspend, the irq
> +		 will be enabled so that the bluetooth chip can wakeup host
> +		 platform out of band. During system resume, the irq will be
> +		 disabled to make sure unnecessary interrupt is not received.

Might it be worthwhile to define an 'interrupt-names' property (e.g., =
"wakeup") to help future-proof this?

> +
> +Example:
> +
> +Following example uses irq pin number 3 of gpio0 for out of band wake-on-bt:
> +
> +&usb_host1_ehci {
> +    status = "okay";
> +    #address-cells = <1>;
> +    #size-cells = <0>;
> +
> +    mvl_bt1: bt@1 {
> +	compatible = "usb1286,204e";
> +	reg = <1>;
> +	interrupt-parent = <&gpio0>;
> +	interrupts = <3 IRQ_TYPE_LEVEL_LOW>;
> +    };
> +};
> diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
> index ce22cef..32a6f22 100644
> --- a/drivers/bluetooth/btusb.c
> +++ b/drivers/bluetooth/btusb.c
> @@ -24,6 +24,8 @@
>  #include <linux/module.h>
>  #include <linux/usb.h>
>  #include <linux/firmware.h>
> +#include <linux/of_device.h>
> +#include <linux/of_irq.h>
>  #include <asm/unaligned.h>
>  
>  #include <net/bluetooth/bluetooth.h>
> @@ -369,6 +371,7 @@ static const struct usb_device_id blacklist_table[] = {
>  #define BTUSB_BOOTING		9
>  #define BTUSB_RESET_RESUME	10
>  #define BTUSB_DIAG_RUNNING	11
> +#define BTUSB_OOB_WAKE_DISABLED	12
>  
>  struct btusb_data {
>  	struct hci_dev       *hdev;
> @@ -416,6 +419,8 @@ struct btusb_data {
>  	int (*recv_bulk)(struct btusb_data *data, void *buffer, int count);
>  
>  	int (*setup_on_usb)(struct hci_dev *hdev);
> +
> +	int oob_wake_irq;   /* irq for out-of-band wake-on-bt */
>  };
>  
>  static inline void btusb_free_frags(struct btusb_data *data)
> @@ -2728,6 +2733,65 @@ static int btusb_bcm_set_diag(struct hci_dev *hdev, bool enable)
>  }
>  #endif
>  
> +#ifdef CONFIG_PM
> +static irqreturn_t btusb_oob_wake_handler(int irq, void *priv)
> +{
> +	struct btusb_data *data = priv;
> +
> +	/* Disable only if not already disabled (keep it balanced) */
> +	if (!test_and_set_bit(BTUSB_OOB_WAKE_DISABLED, &data->flags)) {
> +		disable_irq_wake(irq);
> +		disable_irq_nosync(irq);
> +	}
> +	pm_wakeup_event(&data->udev->dev, 0);
> +	return IRQ_HANDLED;
> +}
> +
> +static const struct of_device_id btusb_match_table[] = {
> +	{ .compatible = "usb1286,204e" },
> +	{ }
> +};
> +MODULE_DEVICE_TABLE(of, btusb_match_table);
> +
> +/* Use an oob wakeup pin? */
> +static int btusb_config_oob_wake(struct hci_dev *hdev)
> +{
> +	struct btusb_data *data = hci_get_drvdata(hdev);
> +	struct device *dev = &data->udev->dev;
> +	int irq, ret;
> +
> +	if (!of_match_device(btusb_match_table, dev))
> +		return 0;
> +
> +	/* Move on if no IRQ specified */
> +	irq = irq_of_parse_and_map(dev->of_node, 0);

Better to use of_irq_get{,_byname}(), no?

> +	if (!irq) {
> +		bt_dev_dbg(hdev, "%s: no oob wake irq in DT", __func__);
> +		return 0;
> +	}
> +
> +	set_bit(BTUSB_OOB_WAKE_DISABLED, &data->flags);
> +
> +	ret = devm_request_irq(&hdev->dev, irq, btusb_oob_wake_handler,
> +			       IRQF_TRIGGER_LOW, "oob wake-on-bt", data);

You're assuming this is level-triggered, and active-low? Can't this just
be specified in the device tree and just pass 0 here?

Also, it seems like it would be a lot more convenient if we could treat
this as edge-triggered, so we don't have to do the set/clear flags,
disable IRQ, etc., dance. You'd just have to change the device tree
definition. Is there any downside to doing that?

It would also then be a better candidate for using something like
dev_pm_set_dedicated_wake_irq() (although last time I tried using that,
it didn't do so great if you don't have autosuspend enabled -- but I
think there are patches outstanding for that; so maybe not yet).

> +	if (ret) {
> +		bt_dev_err(hdev, "%s: irq request failed", __func__);
> +		return ret;
> +	}
> +
> +	ret = device_init_wakeup(dev, true);
> +	if (ret) {
> +		bt_dev_err(hdev, "%s: failed to init_wakeup\n", __func__);
> +		return ret;
> +	}
> +
> +	data->oob_wake_irq = irq;
> +	disable_irq(irq);
> +	bt_dev_info(hdev, "oob wake-on-bt configured at irq %u\n", irq);

oob and bt are typically capitalized in strings. And maybe irq too.
Also, you declared irq as 'int', so %d instead of %u.

Brian

> +	return 0;
> +}
> +#endif
> +
>  static int btusb_probe(struct usb_interface *intf,
>  		       const struct usb_device_id *id)
>  {
> @@ -2849,6 +2913,11 @@ static int btusb_probe(struct usb_interface *intf,
>  	hdev->send   = btusb_send_frame;
>  	hdev->notify = btusb_notify;
>  
> +#ifdef CONFIG_PM
> +	err = btusb_config_oob_wake(hdev);
> +	if (err)
> +		goto out_free_dev;
> +#endif
>  	if (id->driver_info & BTUSB_CW6622)
>  		set_bit(HCI_QUIRK_BROKEN_STORED_LINK_KEY, &hdev->quirks);
>  
> @@ -3089,6 +3158,12 @@ static int btusb_suspend(struct usb_interface *intf, pm_message_t message)
>  	btusb_stop_traffic(data);
>  	usb_kill_anchored_urbs(&data->tx_anchor);
>  
> +	if (data->oob_wake_irq) {
> +		clear_bit(BTUSB_OOB_WAKE_DISABLED, &data->flags);
> +		enable_irq(data->oob_wake_irq);
> +		enable_irq_wake(data->oob_wake_irq);
> +	}
> +
>  	/* Optionally request a device reset on resume, but only when
>  	 * wakeups are disabled. If wakeups are enabled we assume the
>  	 * device will stay powered up throughout suspend.
> @@ -3126,6 +3201,13 @@ static int btusb_resume(struct usb_interface *intf)
>  	if (--data->suspend_count)
>  		return 0;
>  
> +	/* Disable only if not already disabled (keep it balanced) */
> +	if (data->oob_wake_irq &&
> +	    !test_and_set_bit(BTUSB_OOB_WAKE_DISABLED, &data->flags)) {
> +		disable_irq_wake(data->oob_wake_irq);
> +		disable_irq(data->oob_wake_irq);
> +	}
> +
>  	if (!test_bit(HCI_RUNNING, &hdev->flags))
>  		goto done;
>  
> -- 
> 2.8.0.rc3.226.g39d4020
> 
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
