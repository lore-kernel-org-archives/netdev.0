From: Rajat Jain <rajatja@google.com>
Subject: [PATCH v5 3/3] Bluetooth: btusb: Configure Marvell to use one of the pins for oob wakeup
Date: Thu, 12 Jan 2017 10:01:07 -0800
Message-ID: <20170112180107.63244-3-rajatja@google.com>
References: <20170112180107.63244-1-rajatja@google.com>
Cc: Rajat Jain <rajatja@google.com>, rajatxjain@gmail.com
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        Amitkumar Karwar <akarwar@marvell.com>,
        Wei-Ning Huang <wnhuang@chromium.org>,
        Xinming Hu <huxm@marvell.com>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        Brian Norris <briannorris@google.com>,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170112180107.63244-1-rajatja@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Marvell devices may have many gpio pins, and hence for wakeup
on these out-of-band pins, the chip needs to be told which pin is
to be used for wakeup, using an hci command.

Thus, we read the pin number etc from the device tree node and send
a command to the chip.

Signed-off-by: Rajat Jain <rajatja@google.com>
Reviewed-by: Brian Norris <briannorris@chromium.org>
Acked-by: Rob Herring <robh@kernel.org>
---
v5: same as v5
v4: same as v3
v3: * remove the Marvell specific id table and check
    * Add reference to marvell-bt-8xxx.txt in btusb.txt
    * Add "Reviewed-by" and "Acked-by"    
v2: Fix the binding document to specify to use "wakeup" interrupt-name

 Documentation/devicetree/bindings/net/btusb.txt    |  3 ++
 .../{marvell-bt-sd8xxx.txt => marvell-bt-8xxx.txt} | 46 +++++++++++++++----
 drivers/bluetooth/btusb.c                          | 51 ++++++++++++++++++++++
 3 files changed, 92 insertions(+), 8 deletions(-)
 rename Documentation/devicetree/bindings/net/{marvell-bt-sd8xxx.txt => marvell-bt-8xxx.txt} (50%)

diff --git a/Documentation/devicetree/bindings/net/btusb.txt b/Documentation/devicetree/bindings/net/btusb.txt
index 2c0355c85972..01fa2d4188d4 100644
--- a/Documentation/devicetree/bindings/net/btusb.txt
+++ b/Documentation/devicetree/bindings/net/btusb.txt
@@ -10,6 +10,9 @@ Required properties:
 
 		  "usb1286,204e" (Marvell 8997)
 
+Also, vendors that use btusb may have device additional properties, e.g:
+Documentation/devicetree/bindings/net/marvell-bt-8xxx.txt
+
 Optional properties:
 
   - interrupt-parent: phandle of the parent interrupt controller
diff --git a/Documentation/devicetree/bindings/net/marvell-bt-sd8xxx.txt b/Documentation/devicetree/bindings/net/marvell-bt-8xxx.txt
similarity index 50%
rename from Documentation/devicetree/bindings/net/marvell-bt-sd8xxx.txt
rename to Documentation/devicetree/bindings/net/marvell-bt-8xxx.txt
index 6a9a63cb0543..9be1059ff03f 100644
--- a/Documentation/devicetree/bindings/net/marvell-bt-sd8xxx.txt
+++ b/Documentation/devicetree/bindings/net/marvell-bt-8xxx.txt
@@ -1,16 +1,21 @@
-Marvell 8897/8997 (sd8897/sd8997) bluetooth SDIO devices
+Marvell 8897/8997 (sd8897/sd8997) bluetooth devices (SDIO or USB based)
 ------
+The 8997 devices supports multiple interfaces. When used on SDIO interfaces,
+the btmrvl driver is used and when used on USB interface, the btusb driver is
+used.
 
 Required properties:
 
   - compatible : should be one of the following:
-	* "marvell,sd8897-bt"
-	* "marvell,sd8997-bt"
+	* "marvell,sd8897-bt" (for SDIO)
+	* "marvell,sd8997-bt" (for SDIO)
+	* "usb1286,204e"      (for USB)
 
 Optional properties:
 
   - marvell,cal-data: Calibration data downloaded to the device during
 		      initialization. This is an array of 28 values(u8).
+		      This is only applicable to SDIO devices.
 
   - marvell,wakeup-pin: It represents wakeup pin number of the bluetooth chip.
 		        firmware will use the pin to wakeup host system (u16).
@@ -18,10 +23,15 @@ Optional properties:
 		      platform. The value will be configured to firmware. This
 		      is needed to work chip's sleep feature as expected (u16).
   - interrupt-parent: phandle of the parent interrupt controller
-  - interrupts : interrupt pin number to the cpu. Driver will request an irq based
-		 on this interrupt number. During system suspend, the irq will be
-		 enabled so that the bluetooth chip can wakeup host platform under
-		 certain condition. During system resume, the irq will be disabled
+  - interrupt-names: Used only for USB based devices (See below)
+  - interrupts : specifies the interrupt pin number to the cpu. For SDIO, the
+		 driver will use the first interrupt specified in the interrupt
+		 array. For USB based devices, the driver will use the interrupt
+		 named "wakeup" from the interrupt-names and interrupt arrays.
+		 The driver will request an irq based on this interrupt number.
+		 During system suspend, the irq will be enabled so that the
+		 bluetooth chip can wakeup host platform under certain
+		 conditions. During system resume, the irq will be disabled
 		 to make sure unnecessary interrupt is not received.
 
 Example:
@@ -29,7 +39,9 @@ Example:
 IRQ pin 119 is used as system wakeup source interrupt.
 wakeup pin 13 and gap 100ms are configured so that firmware can wakeup host
 using this device side pin and wakeup latency.
-calibration data is also available in below example.
+
+Example for SDIO device follows (calibration data is also available in
+below example).
 
 &mmc3 {
 	status = "okay";
@@ -54,3 +66,21 @@ calibration data is also available in below example.
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
+	interrupt-names = "wakeup";
+	interrupts = <119 IRQ_TYPE_LEVEL_LOW>;
+	marvell,wakeup-pin = /bits/ 16 <0x0d>;
+	marvell,wakeup-gap-ms = /bits/ 16 <0x64>;
+    };
+};
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index 0a777bb407b1..a1079c19b96f 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -2343,6 +2343,50 @@ static int btusb_shutdown_intel(struct hci_dev *hdev)
 	return 0;
 }
 
+#ifdef CONFIG_PM
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
+	/* Move on if no wakeup pin specified */
+	if (of_property_read_u16(dev->of_node, "marvell,wakeup-pin", &pin) ||
+	    of_property_read_u16(dev->of_node, "marvell,wakeup-gap-ms", &gap))
+		return 0;
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
@@ -2918,6 +2962,13 @@ static int btusb_probe(struct usb_interface *intf,
 	err = btusb_config_oob_wake(hdev);
 	if (err)
 		goto out_free_dev;
+
+	/* Marvell devices may need a specific chip configuration */
+	if (id->driver_info & BTUSB_MARVELL && data->oob_wake_irq) {
+		err = marvell_config_oob_wake(hdev);
+		if (err)
+			goto out_free_dev;
+	}
 #endif
 	if (id->driver_info & BTUSB_CW6622)
 		set_bit(HCI_QUIRK_BROKEN_STORED_LINK_KEY, &hdev->quirks);
-- 
2.11.0.390.gc69c2f50cf-goog
