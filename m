From: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
Subject: [PATCH 01/10] mfd: Add Juniper SAM FPGA MFD driver
Date: Fri,  7 Oct 2016 18:18:29 +0300
Message-ID: <1475853518-22264-2-git-send-email-pantelis.antoniou@konsulko.com>
References: <1475853518-22264-1-git-send-email-pantelis.antoniou@konsulko.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, Wolfram Sang <wsa@the-dreams.de>,
 Linus Walleij <linus.walleij@linaro.org>,
 Pantelis Antoniou <pantelis.antoniou@konsulko.com>,
 Wim Van Sebroeck <wim@iguana.be>, linux-mtd@lists.infradead.org,
 linux-i2c@vger.kernel.org, Frank Rowand <frowand.list@gmail.com>,
 Alexandre Courbot <gnurou@gmail.com>, Florian Fainelli <f.fainelli@gmail.com>,
 Maryam Seraj <mseraj@juniper.net>, Guenter Roeck <linux@roeck-us.net>,
 devicetree@vger.kernel.org, linux-watchdog@vger.kernel.org,
 linux-gpio@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
 Debjit Ghosh <dghosh@juniper.net>, Georgi Vlaev <gvlaev@juniper.net>,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 Brian Norris <computersforpeace@gmail.com>,
 David Woodhouse <dwmw2@infradead.org>, Peter Rosin <peda@axentia.se>
To: Lee Jones <lee.jones@linaro.org>
Return-path: <linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org>
In-Reply-To: <1475853518-22264-1-git-send-email-pantelis.antoniou@konsulko.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mtd>,
 <mailto:linux-mtd-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mtd/>
List-Post: <mailto:linux-mtd@lists.infradead.org>
List-Help: <mailto:linux-mtd-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mtd>,
 <mailto:linux-mtd-request@lists.infradead.org?subject=subscribe>
Sender: "linux-mtd" <linux-mtd-bounces@lists.infradead.org>
Errors-To: linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Maryam Seraj <mseraj@juniper.net>

Add Juniper's SAM FPGA multi-function driver.

The SAM FPGAs are present on different FPC/SIB cards from the Juniper's
PTX series of routers. Depending on the card type and FPGA revision,
they include the following functional blocks:

* I2C SAM accelerator - multiple I2C masters and multiplexers
* GPIO
* Flash - hardware wrapper interface for the Altera's EPCS flashes
	(used for configuration flash updates)
* MDIO - multiple MDIO masters

Signed-off-by: Maryam Seraj <mseraj@juniper.net>
Signed-off-by: Debjit Ghosh <dghosh@juniper.net>
Signed-off-by: Georgi Vlaev <gvlaev@juniper.net>
Signed-off-by: Guenter Roeck <groeck@juniper.net>
Signed-off-by: Rajat Jain <rajatjain@juniper.net>
[Ported from Juniper kernel]
Signed-off-by: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
---
 drivers/mfd/Kconfig     |  16 +
 drivers/mfd/Makefile    |   1 +
 drivers/mfd/sam-core.c  | 997 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mfd/sam.h |  30 ++
 4 files changed, 1044 insertions(+)
 create mode 100644 drivers/mfd/sam-core.c
 create mode 100644 include/linux/mfd/sam.h

diff --git a/drivers/mfd/Kconfig b/drivers/mfd/Kconfig
index 438666a..75b46a1 100644
--- a/drivers/mfd/Kconfig
+++ b/drivers/mfd/Kconfig
@@ -1355,6 +1355,22 @@ config MFD_JUNIPER_CPLD
 	  This driver can be built as a module. If built as a module it will be
 	  called "ptxpmb-cpld"
 
+config MFD_JUNIPER_SAM
+	tristate "Juniper SAM FPGA"
+	depends on (PTXPMB_COMMON || JNX_PTX_NGPMB)
+	default y if (PTXPMB_COMMON || JNX_PTX_NGPMB)
+	select MFD_CORE
+	select I2C_SAM
+	select GPIO_SAM
+	select MTD_SAM_FLASH
+	select MDIO_SAM
+	help
+	  Select this to enable the SAM FPGA multi-function kernel driver.
+	  This FPGA is used on the PTX FPC board.
+
+	  This driver can be built as a module. If built as a module it will be
+	  called "sam-core"
+
 config MFD_TWL4030_AUDIO
 	bool "TI TWL4030 Audio"
 	depends on TWL4030_CORE
diff --git a/drivers/mfd/Makefile b/drivers/mfd/Makefile
index 62decc9..71a8ba6 100644
--- a/drivers/mfd/Makefile
+++ b/drivers/mfd/Makefile
@@ -149,6 +149,7 @@ obj-$(CONFIG_AB3100_OTP)	+= ab3100-otp.o
 obj-$(CONFIG_AB8500_DEBUG)	+= ab8500-debugfs.o
 obj-$(CONFIG_AB8500_GPADC)	+= ab8500-gpadc.o
 obj-$(CONFIG_MFD_JUNIPER_CPLD)	+= ptxpmb-cpld-core.o
+obj-$(CONFIG_MFD_JUNIPER_SAM)	+= sam-core.o
 obj-$(CONFIG_MFD_DB8500_PRCMU)	+= db8500-prcmu.o
 # ab8500-core need to come after db8500-prcmu (which provides the channel)
 obj-$(CONFIG_AB8500_CORE)	+= ab8500-core.o ab8500-sysctrl.o
diff --git a/drivers/mfd/sam-core.c b/drivers/mfd/sam-core.c
new file mode 100644
index 0000000..2ea2b1b
--- /dev/null
+++ b/drivers/mfd/sam-core.c
@@ -0,0 +1,997 @@
+#include <linux/device.h>
+#include <linux/module.h>
+#include <linux/pci.h>
+#include <linux/delay.h>
+#include <linux/io.h>
+#include <linux/interrupt.h>
+#include <linux/mfd/core.h>
+#include <linux/mfd/sam.h>
+#include <linux/jnx/pci_ids.h>
+#include <linux/of.h>
+
+#define DRIVER_DESC			"SAM FPGA MFD core driver"
+#define DRIVER_VERSION			"0.02.2"
+#define DRIVER_AUTHOR			"Maryam Seraj <mseraj@juniper.net>"
+
+#define SAM_FPGA_MODULE_NAME		"sam-mfd-core"
+#define FPGA_MEM_SIZE			0x20000
+
+#define SAM_NUM_IRQ			2
+#define SAM_NUM_MFD_CELLS		3
+#define SAM_NUM_RESOURCES		2
+#define SAM_NUM_RESOURCES_NOIRQ		1
+
+/* Minimum SAM revisions needed for i2c irq and PMA support */
+#define SAM_REVISION_I2C_IRQ_MIN	0x0065
+#define SAM_REVISION_PMA_MIN		0x004d
+#define SAM_REVISION_MASK		0x0000ffff
+#define SAM_REVISION(s)			((s)->fpga_rev & SAM_REVISION_MASK)
+
+#define SAM_BOARD_ID_MASK		0x000000ff
+#define SAM_BOARD_ID(s)			((s)->board_id & SAM_BOARD_ID_MASK)
+#define SAM_BOARD_ID_HENDRICKS_FPC	0x00
+#define SAM_BOARD_ID_CFP4		0x00
+#define SAM_BOARD_ID_QSFPP		0x00
+#define SAM_BOARD_ID_GPCAM		0x01
+#define SAM_BOARD_ID_SANGRIA_FPC	0x03
+#define SAM_BOARD_ID_QSFPP_OLD		0x03
+#define SAM_BOARD_ID_24x10GE_PIC	0x0B
+#define SAM_BOARD_ID_GLADIATOR_3T	0x11
+#define SAM_BOARD_ID_MLC		0x21
+
+#define SAM_IMG_ID_MASK			0x000000ff
+#define SAM_IMG_ID_SHIFT		16
+#define SAM_IMG_ID(s)			(((s)->board_id >> SAM_IMG_ID_SHIFT) & \
+					 SAM_IMG_ID_MASK)
+
+#define SAM_IMG_ID_QSFPP		0x00
+#define SAM_IMG_ID_GPCAM		0x01
+#define SAM_IMG_ID_SANGRIA_FPC		0x03
+#define SAM_IMG_ID_QSFPP_OLD		0x03
+#define SAM_IMG_ID_GLADIATOR_3T		0x03
+#define SAM_IMG_ID_HENDRICKS_FPC	0x05
+#define SAM_IMG_ID_24x10GE_PIC		0x0B
+#define SAM_IMG_ID_MLC			0x21
+#define SAM_IMG_ID_CFP4			0x22
+
+#define SANGRIA_FPC_PCIE_BUS		0x20
+
+struct sam_fpga_data {
+	void __iomem *membase;
+	struct pci_dev *pdev;
+	u32 fpga_rev;
+	u32 board_id;
+	u32 pma_lanes;
+	u32 pma_coefficients;
+	int irq_base;
+	u32 i2c_irq_mask;
+	u32 gpio_irq_mask;
+	int gpio_irq_shift;
+	spinlock_t irq_lock;
+	struct mfd_cell mfd_cells[SAM_NUM_MFD_CELLS];
+	struct resource mfd_i2c_resources[SAM_NUM_RESOURCES];
+	struct resource mfd_gpio_resources[SAM_NUM_RESOURCES];
+	struct resource mfd_mtd_resources[SAM_NUM_RESOURCES_NOIRQ];
+};
+
+#define VERSION_ADDR(s)		((s)->membase + 0x000)
+#define BOARD_ID_ADDR(s)	((s)->membase + 0x004)
+#define ICTRL_ADDR(s)		((s)->membase + 0x104)
+#define ISTAT_ADDR(s)		((s)->membase + 0x108)
+
+/* PMA */
+#define SAM_PMA_CONTROL_REG(s)	((s)->membase + 0x40)
+#define SAM_PMA_STATUS_REG(s)	((s)->membase + 0x44)
+
+#define SAM_PMA_CONTROL_WRITE	(1 << 31)
+#define SAM_PMA_CONTROL_READ	(1 << 30)
+#define SAM_PMA_LANE(lane)	(((lane) & 0x07) << 25)
+#define SAM_PMA_COEFF_MASK	((1 << 25) - 1)
+
+#define SAM_PMA_STATUS_BUSY	(1 << 31)
+#define SAM_PMA_STATUS_VALID	(1 << 30)
+
+#define SAM_PMA_RETRIES		40	/* observed to take 20 - 40 uS typ. */
+#define SAM_PMA_WAIT_TIME	10	/* uS */
+
+/* Constants used for FPGA upgrades */
+
+#define SAM_FPGA_FLASH_VALID_BIT		0xA5A5A5A5
+#define SAM_FPGA_FLASH_VALID_BIT_ADDR		0x7F0000
+
+/* FPGA remote upgrade registers */
+#define SAM_FPGA_REMOTE_UPGRADE_TRIG_BIT	0x08000000
+#define SAM_FPGA_REMOTE_UPGRADE_STATUS_BUSY	0x01000000
+#define SAM_FPGA_REMOTE_UPGRADE_READ_PARAM	0x80000000
+#define SAM_FPGA_REMOTE_UPGRADE_WRITE_PARAM	0x40000000
+#define SAM_FPGA_REMOTE_UPGRADE_CONTROL_RESET	0x10000000
+
+#define SAM_FPGA_REMOTE_UPGRADE_PAGE_SEL	(0x04 << 24)
+#define SAM_FPGA_REMOTE_UPGRADE_ANF		(0x05 << 24)
+#define SAM_FPGA_USER_IMAGE_BASE		0x400000
+
+#define SAM_FLASH_BASE				0x0300
+
+#define FLASH_ADDR_REG(x)	((x)->membase + SAM_FLASH_BASE + 0x000)
+#define FLASH_COUNTER_REG(x)	((x)->membase + SAM_FLASH_BASE + 0x004)
+#define FLASH_CONTROL_REG(x)	((x)->membase + SAM_FLASH_BASE + 0x008)
+#define FLASH_STATUS_REG(x)	((x)->membase + SAM_FLASH_BASE + 0x00c)
+#define FLASH_WRITE_DATA_REG(x)	((x)->membase + SAM_FLASH_BASE + 0x100)
+#define FLASH_READ_DATA_REG(x)	((x)->membase + SAM_FLASH_BASE + 0x200)
+
+#define FLASH_STATUS_BUSY	0x01
+
+#define SAM_FLASH_IF_CONTROL_READ	0x00000001
+
+/* Upgrade control and management */
+#define SAM_UPGRADE_BASE	0x0200
+#define UPGRADE_CONTROL_REG(x)	((x)->membase + SAM_UPGRADE_BASE)
+#define UPGRADE_STATUS_REG(x)	((x)->membase + SAM_UPGRADE_BASE + 0x0004)
+
+/* List of discovered SAM devices */
+struct sam_core_list {
+	struct list_head node;
+	unsigned long insertion_time;
+	int bus;
+	int devfn;
+	u32 rev;
+	u32 id;
+};
+
+LIST_HEAD(sam_core_list);
+DEFINE_MUTEX(sam_core_list_mutex);
+
+static int sam_core_update_entry(struct sam_fpga_data *sam)
+{
+	struct sam_core_list *entry = NULL, *e;
+	int ret = 0;
+
+	mutex_lock(&sam_core_list_mutex);
+	list_for_each_entry(e, &sam_core_list, node) {
+		if (e->devfn == sam->pdev->devfn &&
+		    e->bus == sam->pdev->bus->number) {
+			entry = e;
+			break;
+		}
+	}
+
+	if (!entry) {
+		entry = kzalloc(sizeof(*entry), GFP_KERNEL);
+		if (!entry) {
+			ret = -ENOMEM;
+			goto abort;
+		}
+		list_add(&entry->node, &sam_core_list);
+	}
+
+	entry->bus = sam->pdev->bus->number;
+	entry->devfn = sam->pdev->devfn;
+	entry->rev = sam->fpga_rev;
+	entry->id = sam->board_id;
+	entry->insertion_time = jiffies;
+abort:
+	mutex_unlock(&sam_core_list_mutex);
+	return ret;
+}
+
+static bool sam_supports_i2c_irq(struct sam_fpga_data *sam)
+{
+	switch (sam->pdev->device) {
+	case PCI_DEVICE_ID_JNX_SAM_OMEGA:
+		/* Sochu SHAM, Gladiator SIB, Omega SIB */
+		return true;
+	case PCI_DEVICE_ID_JNX_SAM_X:
+		/* Gladiator 3T FPC */
+		return true;
+	case PCI_DEVICE_ID_JNX_PAM:
+		if (SAM_REVISION(sam) >= SAM_REVISION_I2C_IRQ_MIN)
+			return true;
+		return false;
+	case PCI_DEVICE_ID_JNX_SAM:
+	default:
+		/* others depend on image/board ID and FPGA version */
+		break;
+	}
+
+	switch (SAM_IMG_ID(sam)) {
+	case SAM_IMG_ID_QSFPP:
+		/* QSFPP, GPQAM */
+		if (SAM_BOARD_ID(sam) == SAM_BOARD_ID_QSFPP)
+			return true;
+		break;
+	case SAM_IMG_ID_GPCAM:
+		/* GPCAM, GPQ28 */
+		if (SAM_BOARD_ID(sam) == SAM_BOARD_ID_GPCAM)
+			return true;
+		break;
+	case SAM_IMG_ID_HENDRICKS_FPC:
+		/* Hendricks SAM FPGA version 15 still fails */
+		if (SAM_BOARD_ID(sam) == SAM_BOARD_ID_HENDRICKS_FPC)
+			return false;
+		break;
+	case SAM_IMG_ID_24x10GE_PIC:
+		if (SAM_BOARD_ID(sam) == SAM_BOARD_ID_24x10GE_PIC &&
+		    SAM_REVISION(sam) >= SAM_REVISION_I2C_IRQ_MIN)
+			return true;
+		break;
+	case SAM_IMG_ID_SANGRIA_FPC:
+		/*
+		 * Image and board IDs for Sangria FPC and QSFPP are the same.
+		 * Use PCIe bus number for disambiguation.
+		 * Bus number for QSFPP would be 0x10 or 0x30 (PIC bus numbers).
+		 */
+		if (SAM_BOARD_ID(sam) == SAM_BOARD_ID_SANGRIA_FPC &&
+		    SAM_REVISION(sam) >= SAM_REVISION_I2C_IRQ_MIN &&
+		    sam->pdev->bus->number == SANGRIA_FPC_PCIE_BUS)
+			return true;
+		break;
+	default:
+		/*
+		 * For all others, play safe and assume that i2c interrupts
+		 * don't work.
+		 */
+		break;
+	}
+	return false;
+}
+
+static bool sam_supports_msi(struct sam_fpga_data *sam)
+{
+	switch (sam->pdev->device) {
+	case PCI_DEVICE_ID_JNX_SAM_OMEGA:
+		/* Sochu SHAM, Gladiator SIB, Omega SIB */
+		return true;
+	case PCI_DEVICE_ID_JNX_SAM_X:
+		/* Gladiator 3T FPC */
+		return true;
+	case PCI_DEVICE_ID_JNX_PAM:
+		/* unknown */
+		return false;
+	case PCI_DEVICE_ID_JNX_SAM:
+	default:
+		break;
+	}
+
+	switch (SAM_IMG_ID(sam)) {
+	case SAM_IMG_ID_HENDRICKS_FPC:
+		if (SAM_BOARD_ID(sam) == SAM_BOARD_ID_HENDRICKS_FPC)
+			return false;
+		break;
+	case SAM_IMG_ID_24x10GE_PIC:
+		if (SAM_BOARD_ID(sam) == SAM_BOARD_ID_24x10GE_PIC)
+			return false;
+		break;
+	case SAM_IMG_ID_SANGRIA_FPC:
+		/*
+		 * Image and board IDs for Sangria FPC and QSFPP are the same.
+		 * Use PCIe bus number for disambiguation.
+		 */
+		if (SAM_BOARD_ID(sam) == SAM_BOARD_ID_SANGRIA_FPC
+		    && sam->pdev->bus->number == SANGRIA_FPC_PCIE_BUS)
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool sam_supports_pma(struct sam_fpga_data *sam)
+{
+	switch (sam->pdev->device) {
+	case PCI_DEVICE_ID_JNX_SAM_OMEGA:
+		/* Sochu SHAM, Gladiator SIB, Omega SIB */
+		/* Note: marked HW use only on SHAM */
+		return true;
+	case PCI_DEVICE_ID_JNX_SAM_X:
+		/* Gladiator 3T FPC */
+		return true;
+	case PCI_DEVICE_ID_JNX_PAM:
+		return false;
+	case PCI_DEVICE_ID_JNX_SAM:
+		break;
+	default:
+		/* play safe */
+		return false;
+	}
+
+	switch (SAM_IMG_ID(sam)) {
+	case SAM_IMG_ID_QSFPP:
+		if (SAM_BOARD_ID(sam) == SAM_BOARD_ID_QSFPP)
+			return true;
+		break;
+	case SAM_IMG_ID_CFP4:
+		if (SAM_BOARD_ID(sam) == SAM_BOARD_ID_CFP4)
+			return true;
+		break;
+	case SAM_IMG_ID_HENDRICKS_FPC:
+		break;
+	case SAM_IMG_ID_24x10GE_PIC:
+		if (SAM_BOARD_ID(sam) == SAM_BOARD_ID_24x10GE_PIC &&
+		    SAM_REVISION(sam) >= SAM_REVISION_PMA_MIN)
+			return true;
+		break;
+	case SAM_IMG_ID_SANGRIA_FPC:
+		/*
+		 * Image and board IDs for Sangria FPC and QSFPP (old)
+		 * are the same. Use PCIe bus number for disambiguation.
+		 */
+		if (SAM_BOARD_ID(sam) == SAM_BOARD_ID_SANGRIA_FPC &&
+		    SAM_REVISION(sam) >= SAM_REVISION_PMA_MIN &&
+		    sam->pdev->bus->number == SANGRIA_FPC_PCIE_BUS)
+			return true;
+		break;
+	default:
+		/* unknown, play safe */
+		break;
+	}
+
+	return false;
+}
+
+/*
+ * Flash access commands (simplified)
+ */
+static bool sam_flash_busy(struct sam_fpga_data *sam)
+{
+	return ioread32(FLASH_STATUS_REG(sam)) & FLASH_STATUS_BUSY;
+}
+
+static int
+sam_flash_read(struct sam_fpga_data *sam, u_int32_t offset, u32 *data)
+{
+	if (sam_flash_busy(sam))
+		return -ETIMEDOUT;
+
+	iowrite32(sizeof(u32) - 1, FLASH_COUNTER_REG(sam));
+	iowrite32(offset, FLASH_ADDR_REG(sam));
+
+	/* trigger the read */
+	iowrite32(SAM_FLASH_IF_CONTROL_READ, FLASH_CONTROL_REG(sam));
+	ioread32(FLASH_CONTROL_REG(sam));
+
+	udelay(50);
+
+	if (sam_flash_busy(sam))
+		return  -ETIMEDOUT;
+
+	*data = ioread32(FLASH_READ_DATA_REG(sam));
+	return 0;
+}
+
+static u32 sam_irq_mask(struct sam_fpga_data *sam, enum sam_irq_type type,
+			u32 mask)
+{
+	switch (type) {
+	case SAM_IRQ_I2C:
+		mask &= sam->i2c_irq_mask;
+		break;
+	case SAM_IRQ_GPIO:
+		mask <<= sam->gpio_irq_shift;
+		mask &= sam->gpio_irq_mask;
+		break;
+	}
+	return mask;
+}
+
+static void sam_enable_irq(struct device *dev, enum sam_irq_type type, int irq,
+			   u32 mask)
+{
+	struct sam_fpga_data *sam = dev_get_drvdata(dev);
+	unsigned long flags;
+	u32 s;
+
+	/* irq is one of the virqs passed to the driver */
+
+	mask = sam_irq_mask(sam, type, mask);
+
+	spin_lock_irqsave(&sam->irq_lock, flags);
+	s = ioread32(ICTRL_ADDR(sam));
+	s |= mask;
+	iowrite32(s, ICTRL_ADDR(sam));
+	ioread32(ICTRL_ADDR(sam));
+	spin_unlock_irqrestore(&sam->irq_lock, flags);
+}
+
+static void sam_disable_irq(struct device *dev, enum sam_irq_type type, int irq,
+			    u32 mask)
+{
+	struct sam_fpga_data *sam = dev_get_drvdata(dev);
+	unsigned long flags;
+	u32 s;
+
+	mask = sam_irq_mask(sam, type, mask);
+
+	spin_lock_irqsave(&sam->irq_lock, flags);
+	s = ioread32(ICTRL_ADDR(sam));
+	s &= ~mask;
+	iowrite32(s, ICTRL_ADDR(sam));
+	ioread32(ICTRL_ADDR(sam));
+	spin_unlock_irqrestore(&sam->irq_lock, flags);
+}
+
+static u32 sam_irq_status(struct device *dev, enum sam_irq_type type, int irq)
+{
+	struct sam_fpga_data *sam = dev_get_drvdata(dev);
+	u32 status;
+
+	status = ioread32(ISTAT_ADDR(sam));
+
+	switch (type) {
+	case SAM_IRQ_I2C:
+		status &= sam->i2c_irq_mask;
+		break;
+	case SAM_IRQ_GPIO:
+		status &= sam->gpio_irq_mask;
+		status >>= sam->gpio_irq_shift;
+		break;
+	}
+	return status;
+}
+
+static void sam_irq_status_clear(struct device *dev, enum sam_irq_type type,
+				 int irq, u32 mask)
+{
+	struct sam_fpga_data *sam = dev_get_drvdata(dev);
+
+	mask = sam_irq_mask(sam, type, mask);
+
+	iowrite32(mask, ISTAT_ADDR(sam));
+	ioread32(ISTAT_ADDR(sam));
+}
+
+static irqreturn_t sam_irq_handler(int irq, void *data)
+{
+	struct sam_fpga_data *sam = data;
+	u32 status, mask;
+	int ret = IRQ_NONE;
+
+	/*
+	 * Shared interrupt handlers are called from the interrupt release
+	 * function, so be careful not to access already released resources.
+	 */
+	if (sam->irq_base) {
+		mask = ioread32(ICTRL_ADDR(sam));
+		status = ioread32(ISTAT_ADDR(sam));
+		status &= mask;
+		if (status & sam->i2c_irq_mask) {	/* i2c interrupt */
+			handle_nested_irq(sam->irq_base);
+			ret = IRQ_HANDLED;
+		}
+		if (status & sam->gpio_irq_mask) {	/* gpio interrupt */
+			handle_nested_irq(sam->irq_base + 1);
+			ret = IRQ_HANDLED;
+		}
+	}
+	return ret;
+}
+
+static int sam_irq_set_affinity(struct irq_data *d,
+				const struct cpumask *affinity, bool force)
+{
+	return 0;
+}
+
+static void noop(struct irq_data *data) { }
+
+static struct irq_chip sam_irq_chip = {
+	.name = "sam-core",
+	.irq_mask = noop,
+	.irq_unmask = noop,
+	.irq_set_affinity = sam_irq_set_affinity,
+};
+
+static int sam_attach_irq(struct sam_fpga_data *sam)
+{
+	int irq_base = irq_alloc_descs(-1, 0, SAM_NUM_IRQ, 0);
+	int irq;
+
+	if (irq_base < 0)
+		return irq_base;
+
+	for (irq = irq_base; irq < irq_base + SAM_NUM_IRQ; irq++) {
+		irq_set_noprobe(irq);
+		irq_set_chip_and_handler(irq, &sam_irq_chip, handle_level_irq);
+		irq_set_chip_data(irq, sam);
+		irq_set_status_flags(irq, IRQ_LEVEL);
+		irq_clear_status_flags(irq, IRQ_NOREQUEST);
+		irq_set_nested_thread(irq, true);
+	}
+	if (sam_supports_i2c_irq(sam)) {
+		sam->mfd_i2c_resources[1].start
+		  = sam->mfd_i2c_resources[1].end = irq_base;
+		sam->mfd_cells[0].num_resources = SAM_NUM_RESOURCES;
+	}
+	sam->mfd_gpio_resources[1].start = sam->mfd_gpio_resources[1].end
+	  = irq_base + 1;
+	sam->mfd_cells[1].num_resources = SAM_NUM_RESOURCES;
+	sam->irq_base = irq_base;
+
+	return 0;
+}
+
+static void sam_detach_irq(struct sam_fpga_data *sam)
+{
+	int irq, irq_base = sam->irq_base;
+
+	if (irq_base) {
+		sam->irq_base = 0;
+		for (irq = irq_base; irq < irq_base + SAM_NUM_IRQ; irq++) {
+			irq_set_handler_data(irq, NULL);
+			irq_set_chip(irq, NULL);
+			irq_set_chip_data(irq, NULL);
+		}
+		irq_free_descs(irq_base, SAM_NUM_IRQ);
+	}
+}
+
+static int sam_fpga_load_wait(struct sam_fpga_data *sam)
+{
+	unsigned long start = jiffies;
+	unsigned long timeout = start + msecs_to_jiffies(2000);
+
+	/* wait for up to two seconds for the command to complete */
+	do {
+		u32 status = ioread32(UPGRADE_STATUS_REG(sam));
+
+		if (!(status & SAM_FPGA_REMOTE_UPGRADE_STATUS_BUSY))
+			return 0;
+
+		usleep_range(500, 1000);
+	} while (time_before(jiffies, timeout));
+
+	return -ETIMEDOUT;
+}
+
+/*
+ * FPGA image download
+ */
+static int sam_fpga_load_image(struct device *dev, struct sam_fpga_data *sam)
+{
+	int ret;
+	u32 valid;
+	struct sam_core_list *entry;
+
+	/*
+	 * If the node exists, we have seen this device before.
+	 * Don't try to re-load it again unless the FPGA version changed,
+	 * a different board was inserted, or the board was inserted
+	 * more than a minute ago.
+	 * This check is necessary to ensure that we don't end up
+	 * in endless attempts to re-load SAM.
+	 */
+	mutex_lock(&sam_core_list_mutex);
+	list_for_each_entry(entry, &sam_core_list, node) {
+		if (entry->devfn == sam->pdev->devfn &&
+		    entry->bus == sam->pdev->bus->number &&
+		    entry->id == sam->board_id &&
+		    entry->rev == sam->fpga_rev &&
+		    time_before(entry->insertion_time, jiffies + HZ * 60)) {
+			mutex_unlock(&sam_core_list_mutex);
+			return 0;
+		}
+	}
+	mutex_unlock(&sam_core_list_mutex);
+
+	ret = sam_flash_read(sam, SAM_FPGA_FLASH_VALID_BIT_ADDR, &valid);
+	if (ret < 0 || valid != SAM_FPGA_FLASH_VALID_BIT)
+		return 0;
+
+	/* reset state machine and request upgrade */
+	iowrite32(SAM_FPGA_REMOTE_UPGRADE_CONTROL_RESET,
+		  UPGRADE_CONTROL_REG(sam));
+	usleep_range(10000, 20000);
+
+	iowrite32(SAM_FPGA_REMOTE_UPGRADE_WRITE_PARAM |
+		  SAM_FPGA_REMOTE_UPGRADE_PAGE_SEL |
+		  SAM_FPGA_USER_IMAGE_BASE,
+		  UPGRADE_CONTROL_REG(sam));
+	ioread32(UPGRADE_CONTROL_REG(sam));
+
+	ret = sam_fpga_load_wait(sam);
+	if (ret)
+		return 0;
+
+#if 0
+	/*
+	 * Request fallback to golden image if upgrade fails
+	 * Commented out in Sangria code, kept for reference
+	 */
+	iowrite32(SAM_FPGA_REMOTE_UPGRADE_WRITE_PARAM |
+		  SAM_FPGA_REMOTE_UPGRADE_ANF | 1,
+		  UPGRADE_CONTROL_REG(sam));
+
+	ret = sam_fpga_load_wait(sam);
+	if (ret)
+		return ret;
+#endif
+
+	/* Trigger reconfiguration */
+	iowrite32(SAM_FPGA_REMOTE_UPGRADE_TRIG_BIT, UPGRADE_CONTROL_REG(sam));
+
+	sam_core_update_entry(sam);
+
+	/*
+	 * With a clean infrastructure, we could return -EPROBEDEFER here and
+	 * leave it up to the PCIe hotplug driver to detect that the device has
+	 * been removed and re-inserted. Without such a driver, user space
+	 * will have to take care of it.
+	 */
+	return -ENODEV;
+}
+
+static ssize_t version_show(struct device *dev, struct device_attribute *attr,
+			    char *buf)
+{
+	struct sam_fpga_data *sam = dev_get_drvdata(dev);
+
+	return sprintf(buf, "0x%x\n", sam->fpga_rev);
+}
+
+static ssize_t board_id_show(struct device *dev, struct device_attribute *attr,
+			     char *buf)
+{
+	struct sam_fpga_data *sam = dev_get_drvdata(dev);
+
+	return sprintf(buf, "0x%x\n", sam->board_id);
+}
+
+static DEVICE_ATTR(version, S_IRUGO, version_show, NULL);
+static DEVICE_ATTR(board_id, S_IRUGO, board_id_show, NULL);
+
+/* Initialize PMA coefficients */
+
+static int sam_pma_wait(struct sam_fpga_data *sam)
+{
+	int i;
+	u32 status;
+
+	for (i = 0; i < SAM_PMA_RETRIES; i++) {
+		udelay(SAM_PMA_WAIT_TIME);
+		status = ioread32(SAM_PMA_STATUS_REG(sam));
+		if (!(status & SAM_PMA_STATUS_BUSY))
+			return (status & SAM_PMA_STATUS_VALID) ? 0 : -EIO;
+	}
+	return -ETIMEDOUT;
+}
+
+static int sam_pma_write(struct sam_fpga_data *sam, u32 data, void *addr)
+{
+	iowrite32(data, addr);
+	ioread32(addr);
+	return sam_pma_wait(sam);
+}
+
+static int sam_pma_init(struct sam_fpga_data *sam)
+{
+	int lane;
+	int err;
+
+	for (lane = 0; lane < sam->pma_lanes; lane++) {
+		err = sam_pma_write(sam,
+				    SAM_PMA_CONTROL_READ | SAM_PMA_LANE(lane),
+				    SAM_PMA_CONTROL_REG(sam));
+		if (err)
+			return err;
+		err = sam_pma_write(sam,
+				    SAM_PMA_CONTROL_WRITE | SAM_PMA_LANE(lane) |
+				    sam->pma_coefficients,
+				    SAM_PMA_CONTROL_REG(sam));
+		if (err)
+			return err;
+	}
+	return 0;
+}
+
+static int sam_fpga_of_init(struct device *dev, struct sam_fpga_data *sam)
+{
+	int len;
+	const __be32 *pma_coefficients;
+
+	if (!dev->of_node) {
+		dev_warn(dev, "No SAM FDT node\n");
+		return of_have_populated_dt() ? -ENODEV : 0;
+	}
+
+	pma_coefficients = of_get_property(of_get_parent(dev->of_node),
+					   "pma-coefficients", &len);
+	if (pma_coefficients) {
+		if (len != 2 * sizeof(u32))
+			return -EINVAL;
+		sam->pma_lanes = be32_to_cpu(pma_coefficients[0]);
+		sam->pma_coefficients = be32_to_cpu(pma_coefficients[1]);
+
+		if (sam->pma_lanes > 7 ||
+		    (sam->pma_coefficients & ~SAM_PMA_COEFF_MASK))
+			return -EINVAL;
+	}
+	return 0;
+}
+
+/* SAM drivers interrupt handling */
+static struct sam_platform_data sam_plat_data = {
+	.enable_irq = sam_enable_irq,
+	.disable_irq = sam_disable_irq,
+	.irq_status = sam_irq_status,
+	.irq_status_clear = sam_irq_status_clear,
+	.i2c_mux_channels = 2,		/* MLC default */
+};
+
+/* Add a single cell from OF */
+static int sam_mfd_of_add_cell(struct device *dev, const char *compatible,
+				int id, struct resource *base)
+{
+	struct device_node *np;
+	struct mfd_cell cell = {0};
+	struct resource res = {0};
+	u32 reg;
+	int ret;
+
+	/* Note:
+	 * Due to limitations in the MFD core, we can't have more
+	 * than one compatible node - we can't match properly and bind
+	 * the of_nodes to mfd cells.
+	 */
+	np = of_find_compatible_node(dev->of_node, NULL, compatible);
+	if (!np)
+		return -ENODEV;
+
+	ret = of_property_read_u32(np, "reg", &reg);
+	if (ret)
+		return ret;
+
+	res.start = reg;
+	res.end = resource_size(base) - 1 - reg;
+	res.flags = IORESOURCE_MEM;
+	cell.name = np->name;
+	cell.of_compatible = compatible;
+	cell.resources = &res;
+	cell.num_resources = 1;
+
+	return mfd_add_devices(dev, id, &cell, 1, base, 0, NULL);
+}
+
+static void sam_init_irq_masks(struct sam_fpga_data *sam)
+{
+	if ((SAM_IMG_ID(sam) == SAM_IMG_ID_HENDRICKS_FPC &&
+	     SAM_BOARD_ID(sam) == SAM_BOARD_ID_HENDRICKS_FPC) ||
+	    (SAM_IMG_ID(sam) == SAM_IMG_ID_24x10GE_PIC &&
+	     SAM_BOARD_ID(sam) == SAM_BOARD_ID_24x10GE_PIC) ||
+	    (SAM_IMG_ID(sam) == SAM_IMG_ID_SANGRIA_FPC &&
+	     SAM_BOARD_ID(sam) == SAM_BOARD_ID_SANGRIA_FPC &&
+	     sam->pdev->bus->number == SANGRIA_FPC_PCIE_BUS)) {
+		sam->i2c_irq_mask = 0x000000ff;
+		sam->gpio_irq_mask = 0x1ffff000;
+		sam->gpio_irq_shift = 12;
+	} else {
+		sam->i2c_irq_mask = 0x0000ffff;
+		sam->gpio_irq_mask = 0xffff0000;
+		sam->gpio_irq_shift = 16;
+	}
+}
+
+static int sam_fpga_probe(struct pci_dev *pdev, const struct pci_device_id *id)
+{
+	int err;
+	struct sam_fpga_data *sam;
+	struct device *dev = &pdev->dev;
+
+	sam = devm_kzalloc(dev, sizeof(*sam), GFP_KERNEL);
+	if (sam == NULL)
+		return -ENOMEM;
+
+	err = sam_fpga_of_init(dev, sam);
+	if (err < 0)
+		return err;
+
+	err = pci_enable_device(pdev);
+	if (err < 0) {
+		dev_err(dev, "pci_enable_device() failed: %d\n", err);
+		return err;
+	}
+
+	err = pci_request_regions(pdev, SAM_FPGA_MODULE_NAME);
+	if (err < 0) {
+		dev_err(dev, "pci_request_regions() failed: %d\n",
+			err);
+		goto err_disable;
+	}
+
+	sam->membase = pci_ioremap_bar(pdev, 0);
+	if (!sam->membase) {
+		dev_err(dev, "pci_ioremap_bar() failed\n");
+		err = -ENOMEM;
+		goto err_release;
+	}
+
+	sam->pdev = pdev;
+	pci_set_drvdata(pdev, sam);
+
+	/*
+	 * Try to upgrade FPGA image to user image if revision is too old
+	 * to support I2C interrupts
+	 */
+	sam->fpga_rev = ioread32(VERSION_ADDR(sam));
+	sam->board_id = ioread32(BOARD_ID_ADDR(sam));
+
+	if (!sam_supports_i2c_irq(sam)) {
+		dev_info(dev,
+			 "FPGA revision %u.%u doesn't support I2C interrupts, attempting firmware download\n",
+			 (sam->fpga_rev >> 8) & 0xff, sam->fpga_rev & 0xff);
+		err = sam_fpga_load_image(dev, sam);
+		if (err)
+			goto err_unmap;
+	}
+
+	if (sam_supports_pma(sam) && sam->pma_lanes) {
+		err = sam_pma_init(sam);
+		if (err < 0)
+			goto err_unmap;
+	}
+
+	sam_init_irq_masks(sam);
+
+	spin_lock_init(&sam->irq_lock);
+
+	sam->mfd_cells[0].name = "i2c-sam";
+	sam->mfd_cells[0].num_resources = SAM_NUM_RESOURCES_NOIRQ;
+	sam->mfd_cells[0].resources = sam->mfd_i2c_resources;
+	sam->mfd_cells[0].of_compatible = "jnx,i2c-sam";
+	sam->mfd_cells[0].platform_data = &sam_plat_data;
+	sam->mfd_cells[0].pdata_size = sizeof(sam_plat_data);
+
+	sam->mfd_i2c_resources[0].end = FPGA_MEM_SIZE - 1;
+	sam->mfd_i2c_resources[0].flags = IORESOURCE_MEM;
+	sam->mfd_i2c_resources[1].flags = IORESOURCE_IRQ;
+
+	sam->mfd_cells[1].name = "gpio-sam";
+	sam->mfd_cells[1].num_resources = SAM_NUM_RESOURCES_NOIRQ;
+	sam->mfd_cells[1].resources = sam->mfd_gpio_resources;
+	sam->mfd_cells[1].of_compatible = "jnx,gpio-sam";
+	sam->mfd_cells[1].platform_data = &sam_plat_data;
+	sam->mfd_cells[1].pdata_size = sizeof(sam_plat_data);
+
+	sam->mfd_gpio_resources[0].end = FPGA_MEM_SIZE - 1;
+	sam->mfd_gpio_resources[0].flags = IORESOURCE_MEM;
+	sam->mfd_gpio_resources[1].flags = IORESOURCE_IRQ;
+
+	sam->mfd_cells[2].name = "flash-sam";
+	sam->mfd_cells[2].num_resources = SAM_NUM_RESOURCES_NOIRQ;
+	sam->mfd_cells[2].resources = sam->mfd_mtd_resources;
+	sam->mfd_cells[2].of_compatible = "jnx,flash-sam";
+
+	sam->mfd_mtd_resources[0].end = FPGA_MEM_SIZE - 1;
+	sam->mfd_mtd_resources[0].flags = IORESOURCE_MEM;
+
+	/* Enable MSI, if it is supported by this version of SAM */
+	if (sam_supports_msi(sam) && !pci_enable_msi(pdev))
+		pci_set_master(pdev);
+
+	if (pdev->irq) {
+		err = devm_request_threaded_irq(dev, pdev->irq, NULL,
+						sam_irq_handler,
+						IRQF_ONESHOT,
+						dev_driver_string(dev), sam);
+		if (err) {
+			dev_err(dev, "failed to request irq %d\n", pdev->irq);
+			goto err_unmap;
+		}
+		err = sam_attach_irq(sam);
+		if (err) {
+			dev_err(dev, "failed to attach irq %d\n", pdev->irq);
+			goto err_irq;
+		}
+	}
+
+	err = mfd_add_devices(dev, pdev->bus->number, sam->mfd_cells,
+			      ARRAY_SIZE(sam->mfd_cells), &pdev->resource[0],
+			      0, NULL);
+	if (err < 0)
+		goto err_irq_attach;
+
+	/*
+	 * We don't know if this SAM supports MDIO.
+	 * Add client only if compatible node exists.
+	 */
+	sam_mfd_of_add_cell(dev, "jnx,mdio-sam", pdev->bus->number,
+				&pdev->resource[0]);
+
+	err = device_create_file(&pdev->dev, &dev_attr_version);
+	if (err < 0)
+		goto err_remove;
+
+	err = device_create_file(&pdev->dev, &dev_attr_board_id);
+	if (err < 0)
+		goto err_remove_files;
+
+	dev_info(dev,
+		 "SAM Jspec version %u.%u FPGA version %u.%u image 0x%x board 0x%x inserted\n",
+		 (sam->fpga_rev >> 24) & 0xff, (sam->fpga_rev >> 16) & 0xff,
+		 (sam->fpga_rev >> 8) & 0xff, sam->fpga_rev & 0xff,
+		 (sam->board_id >> 16) & 0xff,
+		 sam->board_id & 0xff);
+
+	return 0;
+
+err_remove_files:
+	device_remove_file(&pdev->dev, &dev_attr_version);
+	device_remove_file(&pdev->dev, &dev_attr_board_id);
+err_remove:
+	mfd_remove_devices(dev);
+err_irq_attach:
+	if (pdev->irq)
+		sam_detach_irq(sam);
+err_irq:
+	/* Call free_irq() before pci_disable_msi() */
+	if (pdev->irq)
+		devm_free_irq(&pdev->dev, pdev->irq, sam);
+err_unmap:
+	pci_disable_msi(pdev);
+	pci_iounmap(pdev, sam->membase);
+err_release:
+	pci_release_regions(pdev);
+err_disable:
+	pci_disable_device(pdev);
+	return err;
+}
+
+static void sam_fpga_remove(struct pci_dev *pdev)
+{
+	struct sam_fpga_data *sam = pci_get_drvdata(pdev);
+
+	mfd_remove_devices(&pdev->dev);
+	device_remove_file(&pdev->dev, &dev_attr_version);
+	device_remove_file(&pdev->dev, &dev_attr_board_id);
+	sam_disable_irq(&pdev->dev, SAM_IRQ_I2C, sam->irq_base, 0xffffffff);
+	sam_disable_irq(&pdev->dev, SAM_IRQ_GPIO, sam->irq_base, 0xffffffff);
+	if (pdev->irq) {
+		sam_detach_irq(sam);
+		devm_free_irq(&pdev->dev, pdev->irq, sam);
+	}
+	pci_disable_msi(pdev);
+	pci_iounmap(pdev, sam->membase);
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+}
+
+static struct pci_device_id sam_fpga_ids[] = {
+	{ PCI_DEVICE(PCI_VENDOR_ID_JUNIPER, PCI_DEVICE_ID_JNX_SAM) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_JUNIPER, PCI_DEVICE_ID_JNX_SAM_X) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_JUNIPER, PCI_DEVICE_ID_JNX_SAM_OMEGA) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_JUNIPER, PCI_DEVICE_ID_JNX_PAM) },
+	{ }
+};
+MODULE_DEVICE_TABLE(pci, sam_fpga_ids);
+
+static struct pci_driver sam_fpga_driver = {
+	.name = SAM_FPGA_MODULE_NAME,
+	.id_table = sam_fpga_ids,
+	.probe = sam_fpga_probe,
+	.remove = sam_fpga_remove,
+};
+
+static int __init sam_fpga_init(void)
+{
+	pr_info(DRIVER_DESC " version: " DRIVER_VERSION "\n");
+
+	return pci_register_driver(&sam_fpga_driver);
+}
+
+static void __exit sam_fpga_exit(void)
+{
+	struct sam_core_list *entry, *t;
+
+	list_for_each_entry_safe(entry, t, &sam_core_list, node) {
+		list_del(&entry->node);
+		kfree(entry);
+	}
+	pci_unregister_driver(&sam_fpga_driver);
+}
+
+module_init(sam_fpga_init);
+module_exit(sam_fpga_exit);
+
+MODULE_DESCRIPTION(DRIVER_DESC);
+MODULE_VERSION(DRIVER_VERSION);
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR(DRIVER_AUTHOR);
diff --git a/include/linux/mfd/sam.h b/include/linux/mfd/sam.h
new file mode 100644
index 0000000..d41b9fb
--- /dev/null
+++ b/include/linux/mfd/sam.h
@@ -0,0 +1,30 @@
+/*
+ * Functions exported from SAM mfd driver
+ *     Copyright (c) 2013 Juniper Networks <groeck@juniper.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef SAM_H
+#define SAM_H
+
+struct device;
+
+enum sam_irq_type {
+	SAM_IRQ_I2C = 0,
+	SAM_IRQ_GPIO,
+};
+
+struct sam_platform_data {
+	void (*enable_irq)(struct device *dev, enum sam_irq_type, int irq,
+			   u32 mask);
+	void (*disable_irq)(struct device *dev, enum sam_irq_type, int irq,
+			    u32 mask);
+	u32 (*irq_status)(struct device *dev, enum sam_irq_type, int irq);
+	void (*irq_status_clear)(struct device *dev, enum sam_irq_type, int irq,
+				 u32 mask);
+	int i2c_mux_channels;
+};
+#endif /* SAM_H */
-- 
1.9.1


______________________________________________________
Linux MTD discussion mailing list
http://lists.infradead.org/mailman/listinfo/linux-mtd/
