From: Rajat Jain <rajatja@google.com>
Subject: Re: [PATCH v2 2/3] Bluetooth: btusb: Add out-of-band wakeup support
Date: Mon, 19 Dec 2016 17:46:19 -0800
Message-ID: <CACK8Z6FteRYmrNq5Oq9LpHOUOYg49XrL0WsxD8G45pTw_cwaSg@mail.gmail.com>
References: <1481916604-114279-1-git-send-email-rajatja@google.com>
 <1481916604-114279-2-git-send-email-rajatja@google.com> <20161219231021.GA142074@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        Amitkumar Karwar <akarwar@marvell.com>,
        Wei-Ning Huang <wnhuang@chromium.org>,
        Xinming Hu <huxm@marvell.com>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        linux-kernel@vger.kernel.org, Rajat Jain <rajatxjain@gmail.com>
To: Brian Norris <briannorris@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161219231021.GA142074@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Brian,


On Mon, Dec 19, 2016 at 3:10 PM, Brian Norris <briannorris@chromium.org> wrote:
> Hi Rajat,
>
> On Fri, Dec 16, 2016 at 11:30:03AM -0800, Rajat Jain wrote:
>> Some onboard BT chips (e.g. Marvell 8997) contain a wakeup pin that
>> can be connected to a gpio on the CPU side, and can be used to wakeup
>> the host out-of-band. This can be useful in situations where the
>> in-band wakeup is not possible or not preferable (e.g. the in-band
>> wakeup may require the USB host controller to remain active, and
>> hence consuming more system power during system sleep).
>>
>> The oob gpio interrupt to be used for wakeup on the CPU side, is
>> read from the device tree node, (using standard interrupt descriptors).
>> A devcie tree binding document is also added for the driver. The
>> compatible string is in compliance with
>> Documentation/devicetree/bindings/usb/usb-device.txt
>>
>> Signed-off-by: Rajat Jain <rajatja@google.com>
>
> A few small comments below, but other than those, for the whole series:
>
> Reviewed-by: Brian Norris <briannorris@chromium.org>
>
>> ---
>> v2: * Use interrupt-names ("wakeup") instead of assuming first interrupt.
>>     * Leave it on device tree to specify IRQ flags (level /edge triggered)
>>     * Mark the device as non wakeable on exit.
>>
>>  Documentation/devicetree/bindings/net/btusb.txt | 40 ++++++++++++
>>  drivers/bluetooth/btusb.c                       | 84 +++++++++++++++++++++++++
>>  2 files changed, 124 insertions(+)
>>  create mode 100644 Documentation/devicetree/bindings/net/btusb.txt
>>
>> diff --git a/Documentation/devicetree/bindings/net/btusb.txt b/Documentation/devicetree/bindings/net/btusb.txt
>> new file mode 100644
>> index 0000000..2c0355c
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/btusb.txt
>> @@ -0,0 +1,40 @@
>> +Generic Bluetooth controller over USB (btusb driver)
>> +---------------------------------------------------
>> +
>> +Required properties:
>> +
>> +  - compatible : should comply with the format "usbVID,PID" specified in
>> +              Documentation/devicetree/bindings/usb/usb-device.txt
>> +              At the time of writing, the only OF supported devices
>> +              (more may be added later) are:
>> +
>> +               "usb1286,204e" (Marvell 8997)
>
> I don't know if anyone cares about these sort of organizational aspects,
> but in patch 3 you're extending this binding with device-specific
> Marvell bindings. Seems like it'd be good to have some clear way to
> correlate those 2. e.g., add a reference to marvell-bt-sd8xxx.txt (or
> marvell-bt-8xxx.txt, once you rename it) in patch 3.

Good idea, I'll do it. (I'll add a reference to marvell-bt-8xxx.txt in
btusb.txt).

>
>> +
>> +Optional properties:
>> +
>> +  - interrupt-parent: phandle of the parent interrupt controller
>> +  - interrupt-names: (see below)
>> +  - interrupts : The interrupt specified by the name "wakeup" is the interrupt
>> +              that shall be used for out-of-band wake-on-bt. Driver will
>> +              request this interrupt for wakeup. During system suspend, the
>> +              irq will be enabled so that the bluetooth chip can wakeup host
>> +              platform out of band. During system resume, the irq will be
>> +              disabled to make sure unnecessary interrupt is not received.
>> +
>> +Example:
>> +
>> +Following example uses irq pin number 3 of gpio0 for out of band wake-on-bt:
>> +
>> +&usb_host1_ehci {
>> +    status = "okay";
>> +    #address-cells = <1>;
>> +    #size-cells = <0>;
>> +
>> +    mvl_bt1: bt@1 {
>> +     compatible = "usb1286,204e";
>> +     reg = <1>;
>> +     interrupt-parent = <&gpio0>;
>> +     interrupt-name = "wakeup";
>> +     interrupts = <3 IRQ_TYPE_LEVEL_LOW>;
>> +    };
>> +};
>> diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
>> index ce22cef..beca4e9 100644
>> --- a/drivers/bluetooth/btusb.c
>> +++ b/drivers/bluetooth/btusb.c
>> @@ -24,6 +24,8 @@
>>  #include <linux/module.h>
>>  #include <linux/usb.h>
>>  #include <linux/firmware.h>
>> +#include <linux/of_device.h>
>> +#include <linux/of_irq.h>
>>  #include <asm/unaligned.h>
>>
>>  #include <net/bluetooth/bluetooth.h>
>> @@ -369,6 +371,7 @@ static const struct usb_device_id blacklist_table[] = {
>>  #define BTUSB_BOOTING                9
>>  #define BTUSB_RESET_RESUME   10
>>  #define BTUSB_DIAG_RUNNING   11
>> +#define BTUSB_OOB_WAKE_DISABLED      12
>>
>>  struct btusb_data {
>>       struct hci_dev       *hdev;
>> @@ -416,6 +419,8 @@ struct btusb_data {
>>       int (*recv_bulk)(struct btusb_data *data, void *buffer, int count);
>>
>>       int (*setup_on_usb)(struct hci_dev *hdev);
>> +
>> +     int oob_wake_irq;   /* irq for out-of-band wake-on-bt */
>>  };
>>
>>  static inline void btusb_free_frags(struct btusb_data *data)
>> @@ -2728,6 +2733,65 @@ static int btusb_bcm_set_diag(struct hci_dev *hdev, bool enable)
>>  }
>>  #endif
>>
>> +#ifdef CONFIG_PM
>> +static irqreturn_t btusb_oob_wake_handler(int irq, void *priv)
>> +{
>> +     struct btusb_data *data = priv;
>> +
>> +     /* Disable only if not already disabled (keep it balanced) */
>> +     if (!test_and_set_bit(BTUSB_OOB_WAKE_DISABLED, &data->flags)) {
>> +             disable_irq_nosync(irq);
>> +             disable_irq_wake(irq);
>> +     }
>> +     pm_wakeup_event(&data->udev->dev, 0);
>> +     return IRQ_HANDLED;
>> +}
>> +
>> +static const struct of_device_id btusb_match_table[] = {
>> +     { .compatible = "usb1286,204e" },
>> +     { }
>> +};
>> +MODULE_DEVICE_TABLE(of, btusb_match_table);
>
> You define a match table here, but you also define essentially same
> table for Marvell-specific additions in patch 3. It looks like maybe
> it's legal to have more than one OF table in a module? But it seems like
> it would get confusing, besides being somewhat strange to maintain. It
> might also produce duplicate 'modinfo' output.
>
> If you really want to independently opt into device-tree-specified
> interrupts vs. Marvell-specific interrrupt configuration, then you
> should probably just merge the latter into the former table, and
> implement a Marvell/GPIO flag to stick in the .data field of this table.

The data we want to stick (The pin number on the chip) is board
specific rather than being chip specific, and hence .data may not be
useful here.

>
> Or it might be fine to drop one or both "match" checks. Particularly for
> the Marvell-specific stuff, it's probably fair just to check if it has
> an ->of_node and if 'id->driver_info & BTUSB_MARVELL'. Any other Marvell
> device-specific quirks could probably be keyed off of the
> (weirdly-named?) blacklist_table[], which already matches PID/VID.

Yup, I think I can remove the compatible string checks.

I'll be sending a V3.

>
>> +
>> +/* Use an oob wakeup pin? */
>> +static int btusb_config_oob_wake(struct hci_dev *hdev)
>> +{
>> +     struct btusb_data *data = hci_get_drvdata(hdev);
>> +     struct device *dev = &data->udev->dev;
>> +     int irq, ret;
>> +
>> +     if (!of_match_device(btusb_match_table, dev))
>> +             return 0;
>> +
>> +     /* Move on if no IRQ specified */
>> +     irq = of_irq_get_byname(dev->of_node, "wakeup");
>> +     if (irq <= 0) {
>> +             bt_dev_dbg(hdev, "%s: no OOB Wakeup IRQ in DT", __func__);
>> +             return 0;
>> +     }
>> +
>> +     set_bit(BTUSB_OOB_WAKE_DISABLED, &data->flags);
>> +
>> +     ret = devm_request_irq(&hdev->dev, irq, btusb_oob_wake_handler,
>> +                            0, "OOB Wake-on-BT", data);
>> +     if (ret) {
>> +             bt_dev_err(hdev, "%s: IRQ request failed", __func__);
>> +             return ret;
>> +     }
>> +
>> +     ret = device_init_wakeup(dev, true);
>> +     if (ret) {
>> +             bt_dev_err(hdev, "%s: failed to init_wakeup\n", __func__);
>> +             return ret;
>> +     }
>> +
>> +     data->oob_wake_irq = irq;
>> +     disable_irq(irq);
>> +     bt_dev_info(hdev, "OOB Wake-on-BT configured at IRQ %u\n", irq);
>> +     return 0;
>> +}
>> +#endif
>> +
>>  static int btusb_probe(struct usb_interface *intf,
>>                      const struct usb_device_id *id)
>>  {
>> @@ -2849,6 +2913,11 @@ static int btusb_probe(struct usb_interface *intf,
>>       hdev->send   = btusb_send_frame;
>>       hdev->notify = btusb_notify;
>>
>> +#ifdef CONFIG_PM
>> +     err = btusb_config_oob_wake(hdev);
>> +     if (err)
>> +             goto out_free_dev;
>> +#endif
>>       if (id->driver_info & BTUSB_CW6622)
>>               set_bit(HCI_QUIRK_BROKEN_STORED_LINK_KEY, &hdev->quirks);
>>
>> @@ -3061,6 +3130,9 @@ static void btusb_disconnect(struct usb_interface *intf)
>>                       usb_driver_release_interface(&btusb_driver, data->isoc);
>>       }
>>
>> +     if (data->oob_wake_irq)
>> +             device_init_wakeup(&data->udev->dev, false);
>> +
>>       hci_free_dev(hdev);
>>  }
>>
>> @@ -3089,6 +3161,12 @@ static int btusb_suspend(struct usb_interface *intf, pm_message_t message)
>>       btusb_stop_traffic(data);
>>       usb_kill_anchored_urbs(&data->tx_anchor);
>>
>> +     if (data->oob_wake_irq && device_may_wakeup(&data->udev->dev)) {
>> +             clear_bit(BTUSB_OOB_WAKE_DISABLED, &data->flags);
>> +             enable_irq_wake(data->oob_wake_irq);
>> +             enable_irq(data->oob_wake_irq);
>> +     }
>> +
>>       /* Optionally request a device reset on resume, but only when
>>        * wakeups are disabled. If wakeups are enabled we assume the
>>        * device will stay powered up throughout suspend.
>> @@ -3126,6 +3204,12 @@ static int btusb_resume(struct usb_interface *intf)
>>       if (--data->suspend_count)
>
> Not related to your patch exactly, but isn't this 'suspend_count' stuff
> useless? I'd send a patch, but it might conflict with yours. Just wanted
> to note it and see if I'm crazy...
>
> Brian
>
>>               return 0;
>>
>> +     /* Disable only if not already disabled (keep it balanced) */
>> +     if (!test_and_set_bit(BTUSB_OOB_WAKE_DISABLED, &data->flags)) {
>> +             disable_irq(data->oob_wake_irq);
>> +             disable_irq_wake(data->oob_wake_irq);
>> +     }
>> +
>>       if (!test_bit(HCI_RUNNING, &hdev->flags))
>>               goto done;
>>
>> --
>> 2.8.0.rc3.226.g39d4020
>>
