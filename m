From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 5/7] clocksource: Add flexcard support
Date: Tue, 13 Aug 2013 11:08:40 +0200
Message-ID: <1376384922-8519-7-git-send-email-b.spranger@linutronix.de>
References: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	Daniel Lezcano <daniel.lezcano@linaro.org>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:48291 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755919Ab3HMJI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 05:08:58 -0400
In-Reply-To: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the a clocksource and a clock event device which is
available on the FlexCard.

Cc: Daniel Lezcano <daniel.lezcano@linaro.org>
Cc: John Stultz <john.stultz@linaro.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
Signed-off-by: Holger Dengler <dengler@linutronix.de>
---
 drivers/clocksource/Kconfig        |  13 ++
 drivers/clocksource/Makefile       |   2 +
 drivers/clocksource/flexcard_clk.c | 297 +++++++++++++++++++++++++++++=
++++++++
 drivers/clocksource/flexcard_evt.c | 161 ++++++++++++++++++++
 drivers/mfd/Kconfig                |   2 +
 5 files changed, 475 insertions(+)
 create mode 100644 drivers/clocksource/flexcard_clk.c
 create mode 100644 drivers/clocksource/flexcard_evt.c

diff --git a/drivers/clocksource/Kconfig b/drivers/clocksource/Kconfig
index b7b9b04..0dd5ccf 100644
--- a/drivers/clocksource/Kconfig
+++ b/drivers/clocksource/Kconfig
@@ -70,6 +70,19 @@ config CLKSRC_DBX500_PRCMU_SCHED_CLOCK
 	help
 	  Use the always on PRCMU Timer as sched_clock
=20
+config FLEXCARD_CLK
+	tristate
+	select CLKSRC_MMIO
+	depends on MFD_EBEL_FLEXCARD
+	help
+	  Support for Ebersp=C3=A4cher Flexcard clock function.
+
+config FLEXCARD_EVT
+	tristate
+	depends on MFD_EBEL_FLEXCARD
+	help
+	  Support for Ebersp=C3=A4cher Flexcard timer function.
+
 config ARM_ARCH_TIMER
 	bool
 	select CLKSRC_OF if OF
diff --git a/drivers/clocksource/Makefile b/drivers/clocksource/Makefil=
e
index 8b00c5c..329e65a 100644
--- a/drivers/clocksource/Makefile
+++ b/drivers/clocksource/Makefile
@@ -12,6 +12,8 @@ obj-$(CONFIG_CLKBLD_I8253)	+=3D i8253.o
 obj-$(CONFIG_CLKSRC_MMIO)	+=3D mmio.o
 obj-$(CONFIG_DW_APB_TIMER)	+=3D dw_apb_timer.o
 obj-$(CONFIG_DW_APB_TIMER_OF)	+=3D dw_apb_timer_of.o
+obj-$(CONFIG_FLEXCARD_CLK)	+=3D flexcard_clk.o
+obj-$(CONFIG_FLEXCARD_EVT)	+=3D flexcard_evt.o
 obj-$(CONFIG_CLKSRC_NOMADIK_MTU)	+=3D nomadik-mtu.o
 obj-$(CONFIG_CLKSRC_DBX500_PRCMU)	+=3D clksrc-dbx500-prcmu.o
 obj-$(CONFIG_ARMADA_370_XP_TIMER)	+=3D time-armada-370-xp.o
diff --git a/drivers/clocksource/flexcard_clk.c b/drivers/clocksource/f=
lexcard_clk.c
new file mode 100644
index 0000000..09f5ecb
--- /dev/null
+++ b/drivers/clocksource/flexcard_clk.c
@@ -0,0 +1,297 @@
+/*
+ * Copyright 2012 Ebersp=C3=A4cher Electronics GmbH & Co. KG. All Righ=
ts Reserved.
+ */
+
+#include <linux/init.h>
+#include <linux/platform_device.h>
+#include <linux/spinlock.h>
+#include <linux/interrupt.h>
+#include <linux/irq.h>
+#include <linux/posix-clock.h>
+#include <linux/slab.h>
+#include <linux/flexcard.h>
+#include <linux/io.h>
+#include <linux/export.h>
+#include <linux/module.h>
+
+#define FC_MAX_CLOCKS	16
+#define FC_CLKSEL_OFF	0x10
+
+static DECLARE_BITMAP(fc_clocks_map, FC_MAX_CLOCKS);
+static DEFINE_MUTEX(fc_clocks_mutex);
+static dev_t fc_devt;
+static struct class *fc_class;
+
+struct fc_clock {
+	struct posix_clock clock;
+	struct fc_clksrc src;
+	struct device *dev;
+	void __iomem *reg;
+	unsigned long ovr;
+	dev_t devid;
+	int index;
+	u64 old;
+};
+
+static int fc_clock_gettime(struct posix_clock *pc, struct timespec *t=
p)
+{
+	struct fc_clock *clk =3D container_of(pc, struct fc_clock, clock);
+	u64 val;
+	u64 now;
+
+	now =3D (u64)readl(clk->reg) << 32;
+	now |=3D readl(clk->reg + 0x4);
+
+	if (now < clk->old)
+		clk->ovr++;
+	clk->old =3D now;
+
+	val =3D clk->ovr * 0xffffffff + now;
+
+	tp->tv_nsec =3D do_div(val, clk->src.freq) * clk->src.mul;
+	tp->tv_sec =3D val;
+
+	return 0;
+}
+
+static int fc_clock_getres(struct posix_clock *pc, struct timespec *tp=
)
+{
+	struct fc_clock *clk =3D container_of(pc, struct fc_clock, clock);
+	tp->tv_sec =3D 0;
+	tp->tv_nsec =3D clk->src.mul;
+	return 0;
+}
+
+static int fc_clock_settime(struct posix_clock *pc, const struct times=
pec *tp)
+{
+	struct fc_clock *clk =3D container_of(pc, struct fc_clock, clock);
+
+	/* The FlexCard clock could only be reset to 0 and not set */
+	if (tp->tv_sec || tp->tv_nsec)
+		return -EINVAL;
+
+	clk->ovr =3D 0;
+	clk->old =3D 0;
+
+	/* Reset Timestamp Bit 15 (RST_TS), 0x700-0x5BC=3D0x144 (FC_RESET) */
+	writel(FC_RST_TS, clk->reg - FC_FC_RESET_OFF);
+
+	return 0;
+}
+
+static long fc_clock_ioctl(struct posix_clock *pc, unsigned int cmd,
+		    unsigned long arg)
+{
+	struct fc_clock *clk =3D container_of(pc, struct fc_clock, clock);
+	struct fc_clksrc clk_src;
+	int ret =3D 0;
+
+	switch (cmd) {
+	case FCGCLKSRC:
+		memset(&clk_src, 0, sizeof(clk_src));
+		clk_src.type =3D clk->src.type;
+		clk_src.freq =3D clk->src.freq;
+
+		if (copy_to_user((void __user *)arg, &clk_src,
+				 sizeof(clk_src)))
+			ret =3D -EFAULT;
+		break;
+	case FCSCLKSRC:
+		if (copy_from_user(&clk_src, (void __user *)arg,
+				   sizeof(clk_src))) {
+			ret =3D -EFAULT;
+			break;
+		}
+
+		switch (clk_src.type) {
+		case FC_CLK_INTERNAL_1MHZ:
+			clk->src.freq =3D 1000000;
+			clk->src.mul =3D NSEC_PER_USEC;
+			break;
+
+		case FC_CLK_INTERNAL_10MHZ:
+			clk->src.freq =3D 10000000;
+			clk->src.mul =3D 100;
+			break;
+
+		case FC_CLK_INTERNAL_100MHZ:
+			clk->src.freq =3D 100000000;
+			clk->src.mul =3D 10;
+			break;
+
+		case FC_CLK_INTERNAL_TRIGGER1:
+		case FC_CLK_INTERNAL_TRIGGER2:
+			if (clk_src.freq < 100000 ||
+			    clk_src.freq > NSEC_PER_SEC) {
+				ret =3D -EINVAL;
+				break;
+			}
+			clk->src.freq =3D clk_src.freq;
+			clk->src.mul =3D NSEC_PER_SEC/clk_src.freq;
+
+			break;
+		default:
+			ret =3D -EINVAL;
+		}
+
+		clk->src.type =3D clk_src.type;
+		writel(clk_src.type, clk->reg + FC_CLKSEL_OFF);
+		break;
+	default:
+		ret =3D -ENOTTY;
+		break;
+	}
+	return ret;
+}
+
+static struct posix_clock_operations fc_clock_ops =3D {
+	.owner		=3D THIS_MODULE,
+	.clock_gettime	=3D fc_clock_gettime,
+	.clock_getres	=3D fc_clock_getres,
+	.clock_settime	=3D fc_clock_settime,
+	.ioctl		=3D fc_clock_ioctl,
+};
+
+static int fc_clksrc_probe(struct platform_device *pdev)
+{
+	struct fc_clock *clk;
+	struct resource *res;
+	int index, major, ret =3D -ENXIO;
+
+	res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res) {
+		dev_err(&pdev->dev, "failed to get I/O memory\n");
+		goto out;
+	}
+
+	mutex_lock(&fc_clocks_mutex);
+	major =3D MAJOR(fc_devt);
+	ret =3D -EBUSY;
+	index =3D find_first_zero_bit(fc_clocks_map, FC_MAX_CLOCKS);
+	if (index >=3D FC_MAX_CLOCKS) {
+		dev_err(&pdev->dev, "failed to request clock\n");
+		goto out_unlock;
+	}
+	set_bit(index, fc_clocks_map);
+
+	clk =3D kzalloc(sizeof(struct fc_clock), GFP_KERNEL);
+	if (!clk) {
+		dev_err(&pdev->dev, "out of memory\n");
+		goto out_clear;
+	}
+
+	clk->reg =3D ioremap_nocache(res->start, resource_size(res));
+	if (!clk->reg) {
+		dev_err(&pdev->dev, "failed to remap I/O memory\n");
+		goto out_free;
+	}
+
+	clk->clock.ops =3D fc_clock_ops;
+	clk->devid =3D MKDEV(major, index);
+	clk->index =3D index;
+
+	clk->src.type =3D FC_CLK_INTERNAL_1MHZ;
+	clk->src.freq =3D 1000000;
+	clk->src.mul =3D NSEC_PER_USEC;
+	writel(clk->src.type, clk->reg + FC_CLKSEL_OFF);
+
+	clk->dev =3D device_create(fc_class, &pdev->dev, clk->devid, clk,
+				 "fc_clk%d", clk->index);
+	if (IS_ERR(clk->dev))
+		goto out_unmap;
+
+	platform_set_drvdata(pdev, clk);
+
+	ret =3D posix_clock_register(&clk->clock, clk->devid);
+	if (ret) {
+		dev_err(&pdev->dev, "failed to create posix clock\n");
+		goto out_destroy;
+	}
+
+	mutex_unlock(&fc_clocks_mutex);
+
+	dev_info(&pdev->dev, "Flexcard clocksource registered");
+	return 0;
+
+out_destroy:
+	device_destroy(fc_class, clk->devid);
+out_unmap:
+	iounmap(clk->reg);
+out_free:
+	kfree(clk);
+out_clear:
+	clear_bit(index, fc_clocks_map);
+out_unlock:
+	mutex_unlock(&fc_clocks_mutex);
+out:
+	return ret;
+}
+
+static int fc_clksrc_remove(struct platform_device *pdev)
+{
+	struct fc_clock *clk =3D platform_get_drvdata(pdev);
+
+	mutex_lock(&fc_clocks_mutex);
+	posix_clock_unregister(&clk->clock);
+	device_destroy(fc_class, clk->devid);
+	iounmap(clk->reg);
+	clear_bit(clk->index, fc_clocks_map);
+	platform_set_drvdata(pdev, NULL);
+	kfree(clk);
+	mutex_unlock(&fc_clocks_mutex);
+
+	return 0;
+}
+
+static struct platform_driver fc_clksrc_driver =3D {
+	.probe		=3D fc_clksrc_probe,
+	.remove		=3D fc_clksrc_remove,
+	.driver		=3D {
+		.name	=3D "flexcard-clksrc",
+		.owner	=3D THIS_MODULE,
+	}
+};
+MODULE_ALIAS("platform:flexcard-clksrc");
+
+static int __init fc_clock_init(void)
+{
+	int ret;
+
+	fc_class =3D class_create(THIS_MODULE, "fc_clk");
+	if (IS_ERR(fc_class)) {
+		pr_err("fc_clk: failed to allocate class\n");
+		return PTR_ERR(fc_class);
+	}
+
+	ret =3D alloc_chrdev_region(&fc_devt, 0, FC_MAX_CLOCKS,
+				  "flexcard_clk");
+	if (ret < 0) {
+		pr_err("failed to allocate device region\n");
+		goto out;
+	}
+
+	ret =3D platform_driver_register(&fc_clksrc_driver);
+	if (ret < 0)
+		goto out_unregister;
+
+	return 0;
+
+out_unregister:
+	unregister_chrdev_region(fc_devt, FC_MAX_CLOCKS);
+out:
+	class_destroy(fc_class);
+	return ret;
+}
+module_init(fc_clock_init);
+
+static void __exit fc_clock_exit(void)
+{
+	platform_driver_unregister(&fc_clksrc_driver);
+	unregister_chrdev_region(fc_devt, FC_MAX_CLOCKS);
+	class_destroy(fc_class);
+}
+module_exit(fc_clock_exit);
+
+MODULE_DESCRIPTION("Flexcard Clock Function Driver");
+MODULE_AUTHOR("Benedikt Spranger <b.spranger@linutronix.de>");
+MODULE_LICENSE("GPL v2");
diff --git a/drivers/clocksource/flexcard_evt.c b/drivers/clocksource/f=
lexcard_evt.c
new file mode 100644
index 0000000..2e11c35
--- /dev/null
+++ b/drivers/clocksource/flexcard_evt.c
@@ -0,0 +1,161 @@
+/*
+ * Copyright 2012 Ebersp=C3=A4cher Electronics GmbH & Co. KG. All Righ=
ts Reserved.
+ */
+
+#include <linux/init.h>
+#include <linux/platform_device.h>
+#include <linux/spinlock.h>
+#include <linux/interrupt.h>
+#include <linux/irq.h>
+#include <linux/clocksource.h>
+#include <linux/clockchips.h>
+#include <linux/slab.h>
+#include <linux/flexcard.h>
+#include <linux/module.h>
+
+struct fc_clkevt_device {
+	struct clock_event_device	clkevt;
+	void __iomem			*tirqir;
+	bool				oneshot;
+};
+
+static struct fc_clkevt_device *to_tc_clkevt(struct clock_event_device=
 *clkevt)
+{
+	return container_of(clkevt, struct fc_clkevt_device, clkevt);
+}
+
+static void flexcard_mode(enum clock_event_mode mode,
+			  struct clock_event_device *evt)
+{
+	struct fc_clkevt_device *dev =3D to_tc_clkevt(evt);
+	void __iomem *tirqir =3D dev->tirqir;
+
+	switch (mode) {
+	case CLOCK_EVT_MODE_PERIODIC:
+		dev->oneshot =3D false;
+		writel(1000, tirqir);
+		break;
+
+	case CLOCK_EVT_MODE_SHUTDOWN:
+	case CLOCK_EVT_MODE_UNUSED:
+		writel(0, tirqir);
+		break;
+
+	case CLOCK_EVT_MODE_ONESHOT:
+		writel(0, tirqir);
+		dev->oneshot =3D true;
+		break;
+	case CLOCK_EVT_MODE_RESUME:
+		/* Nothing to do here */
+		break;
+	}
+}
+
+static int flexcard_next_event(unsigned long delta,
+			       struct clock_event_device *evt)
+{
+	struct fc_clkevt_device *dev =3D to_tc_clkevt(evt);
+	void __iomem *tirqir =3D dev->tirqir;
+
+	writel(delta, tirqir);
+
+	return 0;
+}
+
+static const struct fc_clkevt_device clkevt_templ =3D {
+	.clkevt =3D {
+		.name		=3D "flexcard_clkevt",
+		.features	=3D CLOCK_EVT_FEAT_PERIODIC |
+				  CLOCK_EVT_FEAT_ONESHOT,
+		.rating		=3D 300,
+		.set_next_event	=3D flexcard_next_event,
+		.set_mode       =3D flexcard_mode,
+	},
+};
+
+static irqreturn_t flexcard_evt_handler(int irq, void *dev_id)
+{
+	struct fc_clkevt_device *dev =3D dev_id;
+	void __iomem *tirqir =3D dev->tirqir;
+
+	if (dev->oneshot)
+		writel(0, tirqir);
+
+	dev->clkevt.event_handler(&dev->clkevt);
+
+	return IRQ_HANDLED;
+}
+
+static int flexcard_clkevt_probe(struct platform_device *pdev)
+{
+	struct fc_clkevt_device *clkevt =3D NULL;
+	struct resource *res;
+	int irq, ret =3D -ENXIO;
+
+	irq =3D platform_get_irq(pdev, 0);
+	if (irq < 0) {
+		dev_err(&pdev->dev, "failed to get IRQ number\n");
+		goto out;
+	}
+
+	res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res) {
+		dev_err(&pdev->dev, "failed to get I/O memory\n");
+		goto out;
+	}
+
+	if (!request_mem_region(res->start, resource_size(res), pdev->name)) =
{
+		dev_err(&pdev->dev, "failed to request memory region\n");
+		goto out;
+	}
+
+	clkevt =3D kmalloc(sizeof(*clkevt), GFP_KERNEL);
+	if (!clkevt)
+		goto out_release;
+	memcpy(clkevt, &clkevt_templ, sizeof(*clkevt));
+
+	clkevt->tirqir =3D ioremap_nocache(res->start, resource_size(res));
+	if (!clkevt->tirqir) {
+		dev_err(&pdev->dev, "failed to remap I/O memory\n");
+		goto out_release;
+	}
+
+	ret =3D request_irq(irq, flexcard_evt_handler, IRQF_TIMER,
+			  "flexcard_timer", clkevt);
+	if (ret < 0) {
+		dev_err(&pdev->dev, "failed to request IRQ\n");
+		goto out_unmap;
+	}
+
+	clockevents_config_and_register(&clkevt->clkevt, 1000000,
+				       0xF, 0xFFFFFF);
+	dev_info(&pdev->dev, "Flexcard clockevent registered");
+	return 0;
+
+out_unmap:
+	iounmap(clkevt->tirqir);
+out_release:
+	release_mem_region(res->start, resource_size(res));
+	kfree(clkevt);
+out:
+	return ret;
+}
+
+static struct platform_driver flexcard_clkevt_driver =3D {
+	.probe		=3D flexcard_clkevt_probe,
+	.driver		=3D {
+		.name	=3D "flexcard-clkevt",
+		.owner	=3D THIS_MODULE,
+	}
+};
+MODULE_ALIAS("platform:flexcard-clkevt");
+
+static int __init flexcard_evt_init(void)
+{
+	return platform_driver_register(&flexcard_clkevt_driver);
+}
+module_init(flexcard_evt_init);
+
+MODULE_DESCRIPTION("Flexcard Timer Function Driver");
+MODULE_AUTHOR("Benedikt Spranger <b.spranger@linutronix.de>");
+MODULE_LICENSE("GPL v2");
diff --git a/drivers/mfd/Kconfig b/drivers/mfd/Kconfig
index f847d52..12c60e7 100644
--- a/drivers/mfd/Kconfig
+++ b/drivers/mfd/Kconfig
@@ -226,6 +226,8 @@ config MFD_INTEL_MSIC
 config MFD_EBEL_FLEXCARD
 	tristate "Support for the Ebersp=C3=A4cher Electronic Flexcard"
 	select MFD_CORE
+	select FLEXCARD_CLK
+	select FLEXCARD_EVT
 	select UIO
 	select UIO_PDRV
 	select UIO_PDRV_GENIRQ
--=20
1.8.4.rc2
