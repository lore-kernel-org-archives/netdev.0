From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH RFC v4 10/10] tty: serdev: add functions to retrieve common UART settings
Date: Mon, 27 Mar 2017 15:37:28 +0200
Message-ID: <1490621848-24828-11-git-send-email-stefan.wahren@i2se.com>
References: <1490621848-24828-1-git-send-email-stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Marcel Holtmann <marcel@holtmann.org>,
        Sebastian Reichel <sre@kernel.org>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490621848-24828-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently serdev core doesn't provide functions to retrieve common
UART settings like data bits, stop bits or parity. This patch adds
the interface to the core and the necessary implementation for
serdev-ttyport.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/tty/serdev/core.c           | 33 ++++++++++++++++++++++++++
 drivers/tty/serdev/serdev-ttyport.c | 47 +++++++++++++++++++++++++++++++++++++
 include/linux/serdev.h              | 22 +++++++++++++++++
 3 files changed, 102 insertions(+)

diff --git a/drivers/tty/serdev/core.c b/drivers/tty/serdev/core.c
index 531aa89..7b1e5bf 100644
--- a/drivers/tty/serdev/core.c
+++ b/drivers/tty/serdev/core.c
@@ -173,6 +173,39 @@ void serdev_device_set_flow_control(struct serdev_device *serdev, bool enable)
 }
 EXPORT_SYMBOL_GPL(serdev_device_set_flow_control);
 
+int serdev_device_get_data_bits(struct serdev_device *serdev)
+{
+	struct serdev_controller *ctrl = serdev->ctrl;
+
+	if (!ctrl || !ctrl->ops->get_data_bits)
+		return -EINVAL;
+
+	return ctrl->ops->get_data_bits(ctrl);
+}
+EXPORT_SYMBOL_GPL(serdev_device_get_data_bits);
+
+int serdev_device_get_parity(struct serdev_device *serdev)
+{
+	struct serdev_controller *ctrl = serdev->ctrl;
+
+	if (!ctrl || !ctrl->ops->get_parity)
+		return -EINVAL;
+
+	return ctrl->ops->get_parity(ctrl);
+}
+EXPORT_SYMBOL_GPL(serdev_device_get_parity);
+
+int serdev_device_get_stop_bits(struct serdev_device *serdev)
+{
+	struct serdev_controller *ctrl = serdev->ctrl;
+
+	if (!ctrl || !ctrl->ops->get_stop_bits)
+		return -EINVAL;
+
+	return ctrl->ops->get_stop_bits(ctrl);
+}
+EXPORT_SYMBOL_GPL(serdev_device_get_stop_bits);
+
 static int serdev_drv_probe(struct device *dev)
 {
 	const struct serdev_device_driver *sdrv = to_serdev_device_driver(dev->driver);
diff --git a/drivers/tty/serdev/serdev-ttyport.c b/drivers/tty/serdev/serdev-ttyport.c
index 8a30abe..5698682 100644
--- a/drivers/tty/serdev/serdev-ttyport.c
+++ b/drivers/tty/serdev/serdev-ttyport.c
@@ -167,6 +167,50 @@ static void ttyport_set_flow_control(struct serdev_controller *ctrl, bool enable
 	tty_set_termios(tty, &ktermios);
 }
 
+static int ttyport_get_data_bits(struct serdev_controller *ctrl)
+{
+	struct serport *serport = serdev_controller_get_drvdata(ctrl);
+	struct tty_struct *tty = serport->tty;
+	struct ktermios ktermios = tty->termios;
+
+	switch (ktermios.c_cflag & CSIZE) {
+	case CS5:
+		return 5;
+	case CS6:
+		return 6;
+	case CS7:
+		return 7;
+	case CS8:
+		return 8;
+	}
+
+	return 0;
+}
+
+static int ttyport_get_parity(struct serdev_controller *ctrl)
+{
+	struct serport *serport = serdev_controller_get_drvdata(ctrl);
+	struct tty_struct *tty = serport->tty;
+	struct ktermios ktermios = tty->termios;
+
+	if (!(ktermios.c_cflag & PARENB))
+		return SERDEV_PARITY_NONE;
+
+	if (ktermios.c_cflag & PARODD)
+		return SERDEV_PARITY_ODD;
+
+	return SERDEV_PARITY_EVEN;
+}
+
+static int ttyport_get_stop_bits(struct serdev_controller *ctrl)
+{
+	struct serport *serport = serdev_controller_get_drvdata(ctrl);
+	struct tty_struct *tty = serport->tty;
+	struct ktermios ktermios = tty->termios;
+
+	return (ktermios.c_cflag & CSTOPB) ? 2 : 1;
+}
+
 static const struct serdev_controller_ops ctrl_ops = {
 	.write_buf = ttyport_write_buf,
 	.write_flush = ttyport_write_flush,
@@ -175,6 +219,9 @@ static const struct serdev_controller_ops ctrl_ops = {
 	.close = ttyport_close,
 	.set_flow_control = ttyport_set_flow_control,
 	.set_baudrate = ttyport_set_baudrate,
+	.get_data_bits = ttyport_get_data_bits,
+	.get_parity = ttyport_get_parity,
+	.get_stop_bits = ttyport_get_stop_bits,
 };
 
 struct device *serdev_tty_port_register(struct tty_port *port,
diff --git a/include/linux/serdev.h b/include/linux/serdev.h
index 5176cdc..6180aa2 100644
--- a/include/linux/serdev.h
+++ b/include/linux/serdev.h
@@ -16,6 +16,10 @@
 #include <linux/types.h>
 #include <linux/device.h>
 
+#define SERDEV_PARITY_NONE	0
+#define SERDEV_PARITY_ODD	1
+#define SERDEV_PARITY_EVEN	2
+
 struct serdev_controller;
 struct serdev_device;
 
@@ -81,6 +85,9 @@ struct serdev_controller_ops {
 	void (*close)(struct serdev_controller *);
 	void (*set_flow_control)(struct serdev_controller *, bool);
 	unsigned int (*set_baudrate)(struct serdev_controller *, unsigned int);
+	int (*get_data_bits)(struct serdev_controller *);
+	int (*get_parity)(struct serdev_controller *);
+	int (*get_stop_bits)(struct serdev_controller *);
 };
 
 /**
@@ -189,6 +196,9 @@ void serdev_device_set_flow_control(struct serdev_device *, bool);
 int serdev_device_write_buf(struct serdev_device *, const unsigned char *, size_t);
 void serdev_device_write_flush(struct serdev_device *);
 int serdev_device_write_room(struct serdev_device *);
+int serdev_device_get_data_bits(struct serdev_device *);
+int serdev_device_get_parity(struct serdev_device *);
+int serdev_device_get_stop_bits(struct serdev_device *);
 
 /*
  * serdev device driver functions
@@ -232,6 +242,18 @@ static inline int serdev_device_write_room(struct serdev_device *sdev)
 {
 	return 0;
 }
+static inline int serdev_device_get_data_bits(struct serdev_device *sdev)
+{
+	return -ENODEV;
+}
+static inline int serdev_device_get_parity(struct serdev_device *sdev)
+{
+	return -ENODEV;
+}
+static inline int serdev_device_get_stop_bits(struct serdev_device *sdev)
+{
+	return -ENODEV;
+}
 
 #define serdev_device_driver_register(x)
 #define serdev_device_driver_unregister(x)
-- 
2.1.4
