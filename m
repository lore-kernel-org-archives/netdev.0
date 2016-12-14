From: Rajat Jain <rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/3] Bluetooth: btusb: Configure Marvel to use one of the pins for oob wakeup
Date: Wed, 14 Dec 2016 11:12:59 -0800
Message-ID: <1481742779-15105-3-git-send-email-rajatja@google.com>
References: <1481742779-15105-1-git-send-email-rajatja@google.com>
Cc: Rajat Jain <rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, rajatxjain-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
        Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
        Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Wei-Ning Huang <wnhuang-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Xinming Hu <huxm-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Brian Norris <briannorris-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1481742779-15105-1-git-send-email-rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The Marvell devices may have many gpio pins, and hence for wakeup
on these out-of-band pins, the chip needs to be told which pin is
to be used for wakeup, using an hci command.

Thus, we read the pin number etc from the device tree node and send
a command to the chip.

Signed-off-by: Rajat Jain <rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
Note that while I would have liked to name the compatible string as more
like "marvell, usb8997-bt", the devicetrees/bindings/usb/usb-device.txt
requires the compatible property to be of the form "usbVID,PID".

 .../{marvell-bt-sd8xxx.txt => marvell-bt-8xxx.txt} | 25 ++++++++-
 drivers/bluetooth/btusb.c                          | 59 ++++++++++++++++++++++
 2 files changed, 82 insertions(+), 2 deletions(-)
 rename Documentation/devicetree/bindings/net/{marvell-bt-sd8xxx.txt => marvell-bt-8xxx.txt} (76%)

diff --git a/Documentation/devicetree/bindings/net/marvell-bt-sd8xxx.txt b/Documentation/devicetree/bindings/net/marvell-bt-8xxx.txt
similarity index 76%
rename from Documentation/devicetree/bindings/net/marvell-bt-sd8xxx.txt
rename to Documentation/devicetree/bindings/net/marvell-bt-8xxx.txt
index 6a9a63c..471bef8 100644
--- a/Documentation/devicetree/bindings/net/marvell-bt-sd8xxx.txt
+++ b/Documentation/devicetree/bindings/net/marvell-bt-8xxx.txt
@@ -1,4 +1,4 @@
-Marvell 8897/8997 (sd8897/sd8997) bluetooth SDIO devices
+Marvell 8897/8997 (sd8897/sd8997) bluetooth devices (SDIO or USB based)
 ------
 
 Required properties:
@@ -6,11 +6,13 @@ Required properties:
   - compatible : should be one of the following:
 	* "marvell,sd8897-bt"
 	* "marvell,sd8997-bt"
+	* "usb1286,204e"
 
 Optional properties:
 
   - marvell,cal-data: Calibration data downloaded to the device during
 		      initialization. This is an array of 28 values(u8).
+		      This is only applicable to SDIO devices.
 
   - marvell,wakeup-pin: It represents wakeup pin number of the bluetooth chip.
 		        firmware will use the pin to wakeup host system (u16).
@@ -29,7 +31,9 @@ Example:
 IRQ pin 119 is used as system wakeup source interrupt.
 wakeup pin 13 and gap 100ms are configured so that firmware can wakeup host
 using this device side pin and wakeup latency.
-calibration data is also available in below example.
+
+Example for SDIO device follows (calibration data is also available in
+below example).
 
 &mmc3 {
 	status = "okay";
@@ -54,3 +58,20 @@ calibration data is also available in below example.
 		marvell,wakeup-gap-ms = /bits/ 16 <0x64>;
 	};
 };
+
+Example for USB device:
+
+&usb_host1_ohci {
+    status = "okay";
+    #address-cells = <1>;
+    #size-cells = <0>;
+
+    mvl_bt1: bt@1 {
+	compatible = "usb1286,204e";
+	reg = <1>;
+	interrupt-parent = <&gpio0>;
+	interrupts = <119 IRQ_TYPE_LEVEL_LOW>;
+	marvell,wakeup-pin = /bits/ 16 <0x0d>;
+	marvell,wakeup-gap-ms = /bits/ 16 <0x64>;
+    };
+};
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index 32a6f22..99d7f6d 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -2343,6 +2343,58 @@ static int btusb_shutdown_intel(struct hci_dev *hdev)
 	return 0;
 }
 
+#ifdef CONFIG_PM
+static const struct of_device_id mvl_oob_wake_match_table[] = {
+	{ .compatible = "usb1286,204e" },
+	{ }
+};
+MODULE_DEVICE_TABLE(of, mvl_oob_wake_match_table);
+
+/* Configure an out-of-band gpio as wake-up pin, if specified in device tree */
+static int marvell_config_oob_wake(struct hci_dev *hdev)
+{
+	struct sk_buff *skb;
+	struct btusb_data *data = hci_get_drvdata(hdev);
+	struct device *dev = &data->udev->dev;
+	u16 pin, gap, opcode;
+	int ret;
+	u8 cmd[5];
+
+	if (!of_match_device(mvl_oob_wake_match_table, dev))
+		return 0;
+
+	if (of_property_read_u16(dev->of_node, "marvell,wakeup-pin", &pin) ||
+	    of_property_read_u16(dev->of_node, "marvell,wakeup-gap-ms", &gap))
+		return -EINVAL;
+
+	/* Vendor specific command to configure a GPIO as wake-up pin */
+	opcode = hci_opcode_pack(0x3F, 0x59);
+	cmd[0] = opcode & 0xFF;
+	cmd[1] = opcode >> 8;
+	cmd[2] = 2; /* length of parameters that follow */
+	cmd[3] = pin;
+	cmd[4] = gap; /* time in ms, for which wakeup pin should be asserted */
+
+	skb = bt_skb_alloc(sizeof(cmd), GFP_KERNEL);
+	if (!skb) {
+		bt_dev_err(hdev, "%s: No memory\n", __func__);
+		return -ENOMEM;
+	}
+
+	memcpy(skb_put(skb, sizeof(cmd)), cmd, sizeof(cmd));
+	hci_skb_pkt_type(skb) = HCI_COMMAND_PKT;
+
+	ret = btusb_send_frame(hdev, skb);
+	if (ret) {
+		bt_dev_err(hdev, "%s: configuration failed\n", __func__);
+		kfree_skb(skb);
+		return ret;
+	}
+
+	return 0;
+}
+#endif
+
 static int btusb_set_bdaddr_marvell(struct hci_dev *hdev,
 				    const bdaddr_t *bdaddr)
 {
@@ -2917,6 +2969,13 @@ static int btusb_probe(struct usb_interface *intf,
 	err = btusb_config_oob_wake(hdev);
 	if (err)
 		goto out_free_dev;
+
+	/* Marvel devices may need a specific chip configuration */
+	if (id->driver_info & BTUSB_MARVELL && data->oob_wake_irq) {
+		err = marvell_config_oob_wake(hdev);
+		if (err)
+			goto out_free_dev;
+	}
 #endif
 	if (id->driver_info & BTUSB_CW6622)
 		set_bit(HCI_QUIRK_BROKEN_STORED_LINK_KEY, &hdev->quirks);
-- 
2.8.0.rc3.226.g39d4020
