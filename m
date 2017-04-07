From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2 3/4] bluetooth: hci_uart: add LL protocol serdev driver support
Date: Fri,  7 Apr 2017 09:35:16 -0500
Message-ID: <20170407143516.9945-1-robh@kernel.org>
References: <20170405183005.20570-4-robh@kernel.org>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
        Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Wei Xu <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, Eyal Reizer <eyalr-l0cyMroinI0@public.gmane.org>,
        Satish Patel <satish.patel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
        linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170405183005.20570-4-robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Turns out that the LL protocol and the TI-ST are the same thing AFAICT.
The TI-ST adds firmware loading, GPIO control, and shared access for
NFC, FM radio, etc. For now, we're only implementing what is needed for
BT. This mirrors other drivers like BCM and Intel, but uses the new
serdev bus.

The firmware loading is greatly simplified by using existing
infrastructure to send commands. It may be a bit slower than the
original code using synchronous functions, but the real bottleneck is
likely doing firmware load at 115.2kbps.

Signed-off-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Cc: Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>
Cc: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
v2:
- Use IS_ENABLED() to fix module build

 drivers/bluetooth/hci_ll.c | 261 ++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 260 insertions(+), 1 deletion(-)

diff --git a/drivers/bluetooth/hci_ll.c b/drivers/bluetooth/hci_ll.c
index 02692fe30279..77648adfd5c9 100644
--- a/drivers/bluetooth/hci_ll.c
+++ b/drivers/bluetooth/hci_ll.c
@@ -34,20 +34,23 @@
 #include <linux/sched.h>
 #include <linux/types.h>
 #include <linux/fcntl.h>
+#include <linux/firmware.h>
 #include <linux/interrupt.h>
 #include <linux/ptrace.h>
 #include <linux/poll.h>
 
 #include <linux/slab.h>
-#include <linux/tty.h>
 #include <linux/errno.h>
 #include <linux/string.h>
 #include <linux/signal.h>
 #include <linux/ioctl.h>
+#include <linux/serdev.h>
 #include <linux/skbuff.h>
+#include <linux/ti_wilink_st.h>
 
 #include <net/bluetooth/bluetooth.h>
 #include <net/bluetooth/hci_core.h>
+#include <linux/gpio/consumer.h>
 
 #include "hci_uart.h"
 
@@ -76,6 +79,12 @@ struct hcill_cmd {
 	u8 cmd;
 } __packed;
 
+struct ll_device {
+	struct hci_uart hu;
+	struct serdev_device *serdev;
+	struct gpio_desc *enable_gpio;
+};
+
 struct ll_struct {
 	unsigned long rx_state;
 	unsigned long rx_count;
@@ -136,6 +145,9 @@ static int ll_open(struct hci_uart *hu)
 
 	hu->priv = ll;
 
+	if (hu->serdev)
+		serdev_device_open(hu->serdev);
+
 	return 0;
 }
 
@@ -164,6 +176,13 @@ static int ll_close(struct hci_uart *hu)
 
 	kfree_skb(ll->rx_skb);
 
+	if (hu->serdev) {
+		struct ll_device *lldev = serdev_device_get_drvdata(hu->serdev);
+		gpiod_set_value_cansleep(lldev->enable_gpio, 0);
+
+		serdev_device_close(hu->serdev);
+	}
+
 	hu->priv = NULL;
 
 	kfree(ll);
@@ -505,9 +524,245 @@ static struct sk_buff *ll_dequeue(struct hci_uart *hu)
 	return skb_dequeue(&ll->txq);
 }
 
+#if IS_ENABLED(CONFIG_SERIAL_DEV_BUS)
+static int read_local_version(struct hci_dev *hdev)
+{
+	int err = 0;
+	unsigned short version = 0;
+	struct sk_buff *skb;
+	struct hci_rp_read_local_version *ver;
+
+	skb = __hci_cmd_sync(hdev, HCI_OP_READ_LOCAL_VERSION, 0, NULL, HCI_INIT_TIMEOUT);
+	if (IS_ERR(skb)) {
+		bt_dev_err(hdev, "Reading TI version information failed (%ld)",
+			   PTR_ERR(skb));
+		err = PTR_ERR(skb);
+		goto out;
+	}
+	if (skb->len != sizeof(*ver)) {
+		err = -EILSEQ;
+		goto out;
+	}
+
+	ver = (struct hci_rp_read_local_version *)skb->data;
+	if (le16_to_cpu(ver->manufacturer) != 13) {
+		err = -ENODEV;
+		goto out;
+	}
+
+	version = le16_to_cpu(ver->lmp_subver);
+
+out:
+	if (err) bt_dev_err(hdev, "Failed to read TI version info: %d", err);
+	kfree_skb(skb);
+	return err ? err : version;
+}
+
+/**
+ * download_firmware -
+ *	internal function which parses through the .bts firmware
+ *	script file intreprets SEND, DELAY actions only as of now
+ */
+static int download_firmware(struct ll_device *lldev)
+{
+	unsigned short chip, min_ver, maj_ver;
+	int version, err, len;
+	unsigned char *ptr, *action_ptr;
+	unsigned char bts_scr_name[40];	/* 40 char long bts scr name? */
+	const struct firmware *fw;
+	struct sk_buff *skb;
+	struct hci_command *cmd;
+
+	version = read_local_version(lldev->hu.hdev);
+	if (version < 0)
+		return version;
+
+	chip = (version & 0x7C00) >> 10;
+	min_ver = (version & 0x007F);
+	maj_ver = (version & 0x0380) >> 7;
+	if (version & 0x8000)
+		maj_ver |= 0x0008;
+
+	snprintf(bts_scr_name, sizeof(bts_scr_name),
+		 "ti-connectivity/TIInit_%d.%d.%d.bts",
+		 chip, maj_ver, min_ver);
+
+	err = request_firmware(&fw, bts_scr_name, &lldev->serdev->dev);
+	if (err || !fw->data || !fw->size) {
+		bt_dev_err(lldev->hu.hdev, "request_firmware failed(errno %d) for %s",
+			   err, bts_scr_name);
+		return -EINVAL;
+	}
+	ptr = (void *)fw->data;
+	len = fw->size;
+	/* bts_header to remove out magic number and
+	 * version
+	 */
+	ptr += sizeof(struct bts_header);
+	len -= sizeof(struct bts_header);
+
+	while (len > 0 && ptr) {
+		bt_dev_dbg(lldev->hu.hdev, " action size %d, type %d ",
+			   ((struct bts_action *)ptr)->size,
+			   ((struct bts_action *)ptr)->type);
+
+		action_ptr = &(((struct bts_action *)ptr)->data[0]);
+
+		switch (((struct bts_action *)ptr)->type) {
+		case ACTION_SEND_COMMAND:	/* action send */
+			bt_dev_dbg(lldev->hu.hdev, "S");
+			cmd = (struct hci_command *)action_ptr;
+			if (cmd->opcode == 0xff36) {
+				/* ignore remote change
+				 * baud rate HCI VS command */
+				bt_dev_warn(lldev->hu.hdev, "change remote baud rate command in firmware");
+				break;
+			}
+			if (cmd->prefix != 1)
+				bt_dev_dbg(lldev->hu.hdev, "command type %d\n", cmd->prefix);
+
+			skb = __hci_cmd_sync(lldev->hu.hdev, cmd->opcode, cmd->plen, &cmd->speed, HCI_INIT_TIMEOUT);
+			if (IS_ERR(skb)) {
+				bt_dev_err(lldev->hu.hdev, "send command failed\n");
+				goto out_rel_fw;
+			}
+			kfree_skb(skb);
+			break;
+		case ACTION_WAIT_EVENT:  /* wait */
+			/* no need to wait as command was synchronous */
+			bt_dev_dbg(lldev->hu.hdev, "W");
+			break;
+		case ACTION_DELAY:	/* sleep */
+			bt_dev_info(lldev->hu.hdev, "sleep command in scr");
+			mdelay(((struct bts_action_delay *)action_ptr)->msec);
+			break;
+		}
+		len -= (sizeof(struct bts_action) +
+			((struct bts_action *)ptr)->size);
+		ptr += sizeof(struct bts_action) +
+			((struct bts_action *)ptr)->size;
+	}
+
+out_rel_fw:
+	/* fw download complete */
+	release_firmware(fw);
+	return err;
+}
+
+static int ll_setup(struct hci_uart *hu)
+{
+	int err, retry = 3;
+	struct ll_device *lldev;
+	struct serdev_device *serdev = hu->serdev;
+	u32 speed;
+
+	if (!serdev)
+		return 0;
+
+	lldev = serdev_device_get_drvdata(serdev);
+
+	serdev_device_set_flow_control(serdev, true);
+
+	do {
+		/* Configure BT_EN to HIGH state */
+		gpiod_set_value_cansleep(lldev->enable_gpio, 0);
+		msleep(5);
+		gpiod_set_value_cansleep(lldev->enable_gpio, 1);
+		msleep(100);
+
+		err = download_firmware(lldev);
+		if (!err)
+			break;
+
+		/* Toggle BT_EN and retry */
+		bt_dev_err(hu->hdev, "download firmware failed, retrying...");
+	} while (retry--);
+
+	if (err)
+		return err;
+
+	/* Operational speed if any */
+	if (hu->oper_speed)
+		speed = hu->oper_speed;
+	else if (hu->proto->oper_speed)
+		speed = hu->proto->oper_speed;
+	else
+		speed = 0;
+
+	if (speed) {
+		struct sk_buff *skb = __hci_cmd_sync(hu->hdev, 0xff36, sizeof(speed), &speed, HCI_INIT_TIMEOUT);
+		if (!IS_ERR(skb)) {
+			kfree_skb(skb);
+			serdev_device_set_baudrate(serdev, speed);
+		}
+	}
+
+	return 0;
+}
+
+static const struct hci_uart_proto llp;
+
+static int hci_ti_probe(struct serdev_device *serdev)
+{
+	struct hci_uart *hu;
+	struct ll_device *lldev;
+	u32 max_speed = 3000000;
+
+	lldev = devm_kzalloc(&serdev->dev, sizeof(struct ll_device), GFP_KERNEL);
+	if (!lldev)
+		return -ENOMEM;
+	hu = &lldev->hu;
+
+	serdev_device_set_drvdata(serdev, lldev);
+	lldev->serdev = hu->serdev = serdev;
+
+	lldev->enable_gpio = devm_gpiod_get_optional(&serdev->dev, "enable", GPIOD_OUT_LOW);
+	if (IS_ERR(lldev->enable_gpio))
+		return PTR_ERR(lldev->enable_gpio);
+
+	of_property_read_u32(serdev->dev.of_node, "max-speed", &max_speed);
+	hci_uart_set_speeds(hu, 115200, max_speed);
+
+	return hci_uart_register_device(hu, &llp);
+}
+
+static void hci_ti_remove(struct serdev_device *serdev)
+{
+	struct ll_device *lldev = serdev_device_get_drvdata(serdev);
+	struct hci_uart *hu = &lldev->hu;
+	struct hci_dev *hdev = hu->hdev;
+
+	cancel_work_sync(&hu->write_work);
+
+	hci_unregister_dev(hdev);
+	hci_free_dev(hdev);
+	hu->proto->close(hu);
+}
+
+static const struct of_device_id hci_ti_of_match[] = {
+	{ .compatible = "ti,wl1831-st" },
+	{ .compatible = "ti,wl1835-st" },
+	{ .compatible = "ti,wl1837-st" },
+	{},
+};
+MODULE_DEVICE_TABLE(of, hci_ti_of_match);
+
+static struct serdev_device_driver hci_ti_drv = {
+	.driver		= {
+		.name	= "hci-ti",
+		.of_match_table = of_match_ptr(hci_ti_of_match),
+	},
+	.probe	= hci_ti_probe,
+	.remove	= hci_ti_remove,
+};
+#else
+#define ll_setup NULL
+#endif
+
 static const struct hci_uart_proto llp = {
 	.id		= HCI_UART_LL,
 	.name		= "LL",
+	.setup		= ll_setup,
 	.open		= ll_open,
 	.close		= ll_close,
 	.recv		= ll_recv,
@@ -518,10 +773,14 @@ static const struct hci_uart_proto llp = {
 
 int __init ll_init(void)
 {
+	serdev_device_driver_register(&hci_ti_drv);
+
 	return hci_uart_register_proto(&llp);
 }
 
 int __exit ll_deinit(void)
 {
+	serdev_device_driver_unregister(&hci_ti_drv);
+
 	return hci_uart_unregister_proto(&llp);
 }
-- 
2.10.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
