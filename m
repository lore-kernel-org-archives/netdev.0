From: Jie Deng <Jie.Deng1@synopsys.com>
Subject: [PATCH net-next 2/2] net: ethernet: Initial driver for Synopsys DWC XLGMAC
Date: Wed, 7 Dec 2016 11:57:39 +0800
Message-ID: <3fe82457c51f8437797eae27d03cdb0dcbef039b.1481075763.git.jiedeng@synopsys.com>
References: <cover.1481075763.git.jiedeng@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <CARLOS.PALMINHA@synopsys.com>,
        <lars.persson@axis.com>, <thomas.lendacky@amd.com>,
        Jie Deng <Jie.Deng1@synopsys.com>
To: <davem@davemloft.net>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1481075763.git.jiedeng@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch provides the initial driver for 25/40/50/100 GbE
devices using Synopsys DWC Enterprise Ethernet (XLGMAC)

Signed-off-by: Jie Deng <jiedeng@synopsys.com>
---
 MAINTAINERS                                        |    6 +
 drivers/net/ethernet/synopsys/Kconfig              |    2 +
 drivers/net/ethernet/synopsys/Makefile             |    1 +
 drivers/net/ethernet/synopsys/dwc/Kconfig          |   37 +
 drivers/net/ethernet/synopsys/dwc/Makefile         |    9 +
 drivers/net/ethernet/synopsys/dwc/dwc-eth-dcb.c    |  228 ++
 .../net/ethernet/synopsys/dwc/dwc-eth-debugfs.c    |  328 +++
 drivers/net/ethernet/synopsys/dwc/dwc-eth-desc.c   |  715 +++++
 .../net/ethernet/synopsys/dwc/dwc-eth-ethtool.c    |  567 ++++
 drivers/net/ethernet/synopsys/dwc/dwc-eth-hw.c     | 3098 ++++++++++++++++++++
 drivers/net/ethernet/synopsys/dwc/dwc-eth-mdio.c   |  252 ++
 drivers/net/ethernet/synopsys/dwc/dwc-eth-net.c    | 2319 +++++++++++++++
 drivers/net/ethernet/synopsys/dwc/dwc-eth-ptp.c    |  216 ++
 drivers/net/ethernet/synopsys/dwc/dwc-eth-regacc.h | 1115 +++++++
 drivers/net/ethernet/synopsys/dwc/dwc-eth.h        |  738 +++++
 drivers/net/ethernet/synopsys/dwc/dwc-xlgmac-pci.c |  538 ++++
 drivers/net/ethernet/synopsys/dwc/dwc-xlgmac.c     |  135 +
 drivers/net/ethernet/synopsys/dwc/dwc-xlgmac.h     |   85 +
 18 files changed, 10389 insertions(+)
 create mode 100644 drivers/net/ethernet/synopsys/dwc/Kconfig
 create mode 100644 drivers/net/ethernet/synopsys/dwc/Makefile
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-eth-dcb.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-eth-debugfs.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-eth-desc.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-eth-ethtool.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-eth-hw.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-eth-mdio.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-eth-net.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-eth-ptp.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-eth-regacc.h
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-eth.h
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-xlgmac-pci.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-xlgmac.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc/dwc-xlgmac.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 331f6af..738f818 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -10639,6 +10639,12 @@ S: Supported
 F: Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
 F: drivers/net/ethernet/synopsys/dwc_eth_qos.c
 
+SYNOPSYS DESIGNWARE ENTERPRISE ETHERNET (XLGMAC) DRIVER
+M:	jiedeng <jiedeng@synopsys.com>
+L:	netdev@vger.kernel.org
+S:	Supported
+F:	drivers/net/ethernet/synopsys/dwc
+
 SYNOPSYS DESIGNWARE I2C DRIVER
 M:	Jarkko Nikula <jarkko.nikula@linux.intel.com>
 R:	Andy Shevchenko <andriy.shevchenko@linux.intel.com>
diff --git a/drivers/net/ethernet/synopsys/Kconfig b/drivers/net/ethernet/synopsys/Kconfig
index 8276ee5..a81ce47 100644
--- a/drivers/net/ethernet/synopsys/Kconfig
+++ b/drivers/net/ethernet/synopsys/Kconfig
@@ -24,4 +24,6 @@ config SYNOPSYS_DWC_ETH_QOS
 	---help---
 	  This driver supports the DWC Ethernet QoS from Synopsys
 
+source "drivers/net/ethernet/synopsys/dwc/Kconfig"
+
 endif # NET_VENDOR_SYNOPSYS
diff --git a/drivers/net/ethernet/synopsys/Makefile b/drivers/net/ethernet/synopsys/Makefile
index 7a37572..97cf97a 100644
--- a/drivers/net/ethernet/synopsys/Makefile
+++ b/drivers/net/ethernet/synopsys/Makefile
@@ -3,3 +3,4 @@
 #
 
 obj-$(CONFIG_SYNOPSYS_DWC_ETH_QOS) += dwc_eth_qos.o
+obj-y += dwc/
diff --git a/drivers/net/ethernet/synopsys/dwc/Kconfig b/drivers/net/ethernet/synopsys/dwc/Kconfig
new file mode 100644
index 0000000..0ec4b27
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc/Kconfig
@@ -0,0 +1,37 @@
+#
+# Synopsys DWC ethernet drivers configuration
+#
+
+config DWC_ETH
+	bool
+	depends on HAS_IOMEM && HAS_DMA
+	select BITREVERSE
+        select CRC32
+        select PTP_1588_CLOCK
+        select PHYLIB
+
+config DWC_XLGMAC_PCI
+	tristate "Synopsys DWC Enterprise Ethernet (XLGMAC) driver PCI support"
+        depends on HAS_IOMEM && HAS_DMA
+	depends on PCI
+        select BITREVERSE
+        select CRC32
+        select PTP_1588_CLOCK
+        select PHYLIB
+	select DWC_ETH
+	---help---
+	  This driver supports the Synopsys DWC Enterprise Ethernet (XLGMAC)
+	  for PCI platform
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called snps-dwc-xlgmac.
+
+config DWC_ETH_DCB
+	bool "Data Center Bridging (DCB) support"
+	default n
+	depends on DWC_ETH && DCB
+	---help---
+	  Say Y here to enable Data Center Bridging (DCB) support in the
+	  driver.
+
+	  If unsure, say N.
diff --git a/drivers/net/ethernet/synopsys/dwc/Makefile b/drivers/net/ethernet/synopsys/dwc/Makefile
new file mode 100644
index 0000000..afd55a1
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc/Makefile
@@ -0,0 +1,9 @@
+obj-$(CONFIG_DWC_XLGMAC_PCI) += snps-dwc-xlgmac.o
+
+snps-dwc-xlgmac-objs := dwc-xlgmac-pci.o dwc-xlgmac.o
+
+snps-dwc-xlgmac-$(CONFIG_DWC_ETH) += dwc-eth-net.o dwc-eth-desc.o \
+				     dwc-eth-hw.o dwc-eth-mdio.o \
+				     dwc-eth-ethtool.o dwc-eth-ptp.o
+snps-dwc-xlgmac-$(CONFIG_DWC_ETH_DCB) += dwc-eth-dcb.o
+snps-dwc-xlgmac-$(CONFIG_DEBUG_FS) += dwc-eth-debugfs.o
diff --git a/drivers/net/ethernet/synopsys/dwc/dwc-eth-dcb.c b/drivers/net/ethernet/synopsys/dwc/dwc-eth-dcb.c
new file mode 100644
index 0000000..6e39eb0
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc/dwc-eth-dcb.c
@@ -0,0 +1,228 @@
+/*
+ * Synopsys DesignWare Ethernet Driver
+ *
+ * Copyright (c) 2014-2016 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This file is free software; you may copy, redistribute and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, either version 2 of the License, or (at
+ * your option) any later version.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/netdevice.h>
+#include <net/dcbnl.h>
+
+#include "dwc-eth.h"
+#include "dwc-eth-regacc.h"
+
+static int dwc_eth_dcb_ieee_getets(struct net_device *netdev,
+				   struct ieee_ets *ets)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+
+	/* Set number of supported traffic classes */
+	ets->ets_cap = pdata->hw_feat.tc_cnt;
+
+	if (pdata->ets) {
+		ets->cbs = pdata->ets->cbs;
+		memcpy(ets->tc_tx_bw, pdata->ets->tc_tx_bw,
+		       sizeof(ets->tc_tx_bw));
+		memcpy(ets->tc_tsa, pdata->ets->tc_tsa,
+		       sizeof(ets->tc_tsa));
+		memcpy(ets->prio_tc, pdata->ets->prio_tc,
+		       sizeof(ets->prio_tc));
+	}
+
+	return 0;
+}
+
+static int dwc_eth_dcb_ieee_setets(struct net_device *netdev,
+				   struct ieee_ets *ets)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	unsigned int i, tc_ets, tc_ets_weight;
+	u8 max_tc = 0;
+
+	tc_ets = 0;
+	tc_ets_weight = 0;
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		netif_dbg(pdata, drv, netdev,
+			  "TC%u: tx_bw=%hhu, rx_bw=%hhu, tsa=%hhu\n", i,
+			  ets->tc_tx_bw[i], ets->tc_rx_bw[i],
+			  ets->tc_tsa[i]);
+		netif_dbg(pdata, drv, netdev, "PRIO%u: TC=%hhu\n", i,
+			  ets->prio_tc[i]);
+
+		max_tc = max_t(u8, max_tc, ets->prio_tc[i]);
+		if ((ets->tc_tx_bw[i] || ets->tc_tsa[i]))
+			max_tc = max_t(u8, max_tc, i);
+
+		switch (ets->tc_tsa[i]) {
+		case IEEE_8021QAZ_TSA_STRICT:
+			break;
+		case IEEE_8021QAZ_TSA_ETS:
+			tc_ets = 1;
+			tc_ets_weight += ets->tc_tx_bw[i];
+			break;
+		default:
+			netif_err(pdata, drv, netdev,
+				  "unsupported TSA algorithm (%hhu)\n",
+				  ets->tc_tsa[i]);
+			return -EINVAL;
+		}
+	}
+
+	/* Check maximum traffic class requested */
+	if (max_tc >= pdata->hw_feat.tc_cnt) {
+		netif_err(pdata, drv, netdev,
+			  "exceeded number of supported traffic classes\n");
+		return -EINVAL;
+	}
+
+	/* Weights must add up to 100% */
+	if (tc_ets && (tc_ets_weight != 100)) {
+		netif_err(pdata, drv, netdev,
+			  "sum of ETS algorithm weights is not 100 (%u)\n",
+			  tc_ets_weight);
+		return -EINVAL;
+	}
+
+	if (!pdata->ets) {
+		pdata->ets = devm_kzalloc(pdata->dev, sizeof(*pdata->ets),
+					  GFP_KERNEL);
+		if (!pdata->ets)
+			return -ENOMEM;
+	}
+
+	pdata->num_tcs = max_tc + 1;
+	memcpy(pdata->ets, ets, sizeof(*pdata->ets));
+
+	pdata->hw_ops.config_dcb_tc(pdata);
+
+	return 0;
+}
+
+static int dwc_eth_dcb_ieee_getpfc(struct net_device *netdev,
+				   struct ieee_pfc *pfc)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+
+	/* Set number of supported PFC traffic classes */
+	pfc->pfc_cap = pdata->hw_feat.tc_cnt;
+
+	if (pdata->pfc) {
+		pfc->pfc_en = pdata->pfc->pfc_en;
+		pfc->mbc = pdata->pfc->mbc;
+		pfc->delay = pdata->pfc->delay;
+	}
+
+	return 0;
+}
+
+static int dwc_eth_dcb_ieee_setpfc(struct net_device *netdev,
+				   struct ieee_pfc *pfc)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+
+	netif_dbg(pdata, drv, netdev,
+		  "cap=%hhu, en=%#hhx, mbc=%hhu, delay=%hhu\n",
+		  pfc->pfc_cap, pfc->pfc_en, pfc->mbc, pfc->delay);
+
+	/* Check PFC for supported number of traffic classes */
+	if (pfc->pfc_en & ~((1 << pdata->hw_feat.tc_cnt) - 1)) {
+		netif_err(pdata, drv, netdev,
+			  "PFC requested for unsupported traffic class\n");
+		return -EINVAL;
+	}
+
+	if (!pdata->pfc) {
+		pdata->pfc = devm_kzalloc(pdata->dev, sizeof(*pdata->pfc),
+					  GFP_KERNEL);
+		if (!pdata->pfc)
+			return -ENOMEM;
+	}
+
+	memcpy(pdata->pfc, pfc, sizeof(*pdata->pfc));
+
+	pdata->hw_ops.config_dcb_pfc(pdata);
+
+	return 0;
+}
+
+static u8 dwc_eth_dcb_getdcbx(struct net_device *netdev)
+{
+	return DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_IEEE;
+}
+
+static u8 dwc_eth_dcb_setdcbx(struct net_device *netdev, u8 dcbx)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	u8 support = dwc_eth_dcb_getdcbx(netdev);
+
+	netif_dbg(pdata, drv, netdev, "DCBX=%#hhx\n", dcbx);
+
+	if (dcbx & ~support)
+		return 1;
+
+	if ((dcbx & support) != support)
+		return 1;
+
+	return 0;
+}
+
+static const struct dcbnl_rtnl_ops dwc_eth_dcbnl_ops = {
+	/* IEEE 802.1Qaz std */
+	.ieee_getets = dwc_eth_dcb_ieee_getets,
+	.ieee_setets = dwc_eth_dcb_ieee_setets,
+	.ieee_getpfc = dwc_eth_dcb_ieee_getpfc,
+	.ieee_setpfc = dwc_eth_dcb_ieee_setpfc,
+
+	/* DCBX configuration */
+	.getdcbx     = dwc_eth_dcb_getdcbx,
+	.setdcbx     = dwc_eth_dcb_setdcbx,
+};
+
+const struct dcbnl_rtnl_ops *dwc_eth_get_dcbnl_ops(void)
+{
+	return &dwc_eth_dcbnl_ops;
+}
diff --git a/drivers/net/ethernet/synopsys/dwc/dwc-eth-debugfs.c b/drivers/net/ethernet/synopsys/dwc/dwc-eth-debugfs.c
new file mode 100644
index 0000000..b104ff6
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc/dwc-eth-debugfs.c
@@ -0,0 +1,328 @@
+/*
+ * Synopsys DesignWare Ethernet Driver
+ *
+ * Copyright (c) 2014-2016 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This file is free software; you may copy, redistribute and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, either version 2 of the License, or (at
+ * your option) any later version.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/debugfs.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+
+#include "dwc-eth.h"
+#include "dwc-eth-regacc.h"
+
+static ssize_t dwc_eth_common_read(char __user *buffer,
+				   size_t count, loff_t *ppos,
+				   unsigned int value)
+{
+	char *buf;
+	ssize_t len;
+
+	if (*ppos != 0)
+		return 0;
+
+	buf = kasprintf(GFP_KERNEL, "0x%08x\n", value);
+	if (!buf)
+		return -ENOMEM;
+
+	if (count < strlen(buf)) {
+		kfree(buf);
+		return -ENOSPC;
+	}
+
+	len = simple_read_from_buffer(buffer, count, ppos, buf, strlen(buf));
+	kfree(buf);
+
+	return len;
+}
+
+static ssize_t dwc_eth_common_write(const char __user *buffer,
+				    size_t count, loff_t *ppos,
+				    unsigned int *value)
+{
+	char workarea[32];
+	ssize_t len;
+	int ret;
+
+	if (*ppos != 0)
+		return 0;
+
+	if (count >= sizeof(workarea))
+		return -ENOSPC;
+
+	len = simple_write_to_buffer(workarea, sizeof(workarea) - 1, ppos,
+				     buffer, count);
+	if (len < 0)
+		return len;
+
+	workarea[len] = '\0';
+	ret = kstrtouint(workarea, 16, value);
+	if (ret)
+		return -EIO;
+
+	return len;
+}
+
+static ssize_t xlgmac_reg_addr_read(struct file *filp,
+				    char __user *buffer,
+				    size_t count, loff_t *ppos)
+{
+	struct dwc_eth_pdata *pdata = filp->private_data;
+
+	return dwc_eth_common_read(buffer, count, ppos,
+				pdata->debugfs_xlgmac_reg);
+}
+
+static ssize_t xlgmac_reg_addr_write(struct file *filp,
+				     const char __user *buffer,
+				     size_t count, loff_t *ppos)
+{
+	struct dwc_eth_pdata *pdata = filp->private_data;
+
+	return dwc_eth_common_write(buffer, count, ppos,
+				&pdata->debugfs_xlgmac_reg);
+}
+
+static ssize_t xlgmac_reg_value_read(struct file *filp,
+				     char __user *buffer,
+				     size_t count, loff_t *ppos)
+{
+	struct dwc_eth_pdata *pdata = filp->private_data;
+	unsigned int value;
+
+	value = DWC_ETH_IOREAD(pdata, pdata->debugfs_xlgmac_reg);
+
+	return dwc_eth_common_read(buffer, count, ppos, value);
+}
+
+static ssize_t xlgmac_reg_value_write(struct file *filp,
+				      const char __user *buffer,
+				      size_t count, loff_t *ppos)
+{
+	struct dwc_eth_pdata *pdata = filp->private_data;
+	unsigned int value;
+	ssize_t len;
+
+	len = dwc_eth_common_write(buffer, count, ppos, &value);
+	if (len < 0)
+		return len;
+
+	DWC_ETH_IOWRITE(pdata, pdata->debugfs_xlgmac_reg, value);
+
+	return len;
+}
+
+static const struct file_operations xlgmac_reg_addr_fops = {
+	.owner = THIS_MODULE,
+	.open = simple_open,
+	.read =  xlgmac_reg_addr_read,
+	.write = xlgmac_reg_addr_write,
+};
+
+static const struct file_operations xlgmac_reg_value_fops = {
+	.owner = THIS_MODULE,
+	.open = simple_open,
+	.read =  xlgmac_reg_value_read,
+	.write = xlgmac_reg_value_write,
+};
+
+static ssize_t xlgpcs_mmd_read(struct file *filp,
+			       char __user *buffer,
+			       size_t count, loff_t *ppos)
+{
+	struct dwc_eth_pdata *pdata = filp->private_data;
+
+	return dwc_eth_common_read(buffer, count, ppos,
+				pdata->debugfs_xlgpcs_mmd);
+}
+
+static ssize_t xlgpcs_mmd_write(struct file *filp,
+				const char __user *buffer,
+				size_t count, loff_t *ppos)
+{
+	struct dwc_eth_pdata *pdata = filp->private_data;
+
+	return dwc_eth_common_write(buffer, count, ppos,
+				&pdata->debugfs_xlgpcs_mmd);
+}
+
+static ssize_t xlgpcs_reg_addr_read(struct file *filp,
+				    char __user *buffer,
+				    size_t count, loff_t *ppos)
+{
+	struct dwc_eth_pdata *pdata = filp->private_data;
+
+	return dwc_eth_common_read(buffer, count, ppos,
+				pdata->debugfs_xlgpcs_reg);
+}
+
+static ssize_t xlgpcs_reg_addr_write(struct file *filp,
+				     const char __user *buffer,
+				     size_t count, loff_t *ppos)
+{
+	struct dwc_eth_pdata *pdata = filp->private_data;
+
+	return dwc_eth_common_write(buffer, count, ppos,
+				&pdata->debugfs_xlgpcs_reg);
+}
+
+static ssize_t xlgpcs_reg_value_read(struct file *filp,
+				     char __user *buffer,
+				     size_t count, loff_t *ppos)
+{
+	struct dwc_eth_pdata *pdata = filp->private_data;
+	unsigned int value;
+
+	value = DWC_ETH_MDIO_READ(pdata, pdata->debugfs_xlgpcs_mmd,
+				  pdata->debugfs_xlgpcs_reg);
+
+	return dwc_eth_common_read(buffer, count, ppos, value);
+}
+
+static ssize_t xlgpcs_reg_value_write(struct file *filp,
+				      const char __user *buffer,
+				      size_t count, loff_t *ppos)
+{
+	struct dwc_eth_pdata *pdata = filp->private_data;
+	unsigned int value;
+	ssize_t len;
+
+	len = dwc_eth_common_write(buffer, count, ppos, &value);
+	if (len < 0)
+		return len;
+
+	DWC_ETH_MDIO_WRITE(pdata, pdata->debugfs_xlgpcs_mmd,
+			   pdata->debugfs_xlgpcs_reg, value);
+
+	return len;
+}
+
+static const struct file_operations xlgpcs_mmd_fops = {
+	.owner = THIS_MODULE,
+	.open = simple_open,
+	.read =  xlgpcs_mmd_read,
+	.write = xlgpcs_mmd_write,
+};
+
+static const struct file_operations xlgpcs_reg_addr_fops = {
+	.owner = THIS_MODULE,
+	.open = simple_open,
+	.read =  xlgpcs_reg_addr_read,
+	.write = xlgpcs_reg_addr_write,
+};
+
+static const struct file_operations xlgpcs_reg_value_fops = {
+	.owner = THIS_MODULE,
+	.open = simple_open,
+	.read =  xlgpcs_reg_value_read,
+	.write = xlgpcs_reg_value_write,
+};
+
+void xlgmac_debugfs_init(struct dwc_eth_pdata *pdata)
+{
+	struct dentry *pfile;
+	char *buf;
+
+	TRACE("-->");
+
+	/* Set defaults */
+	pdata->debugfs_xlgmac_reg = 0;
+	pdata->debugfs_xlgpcs_mmd = 1;
+	pdata->debugfs_xlgpcs_reg = 0;
+
+	buf = kasprintf(GFP_KERNEL, "dwc-%s", pdata->netdev->name);
+	if (!buf)
+		return;
+
+	pdata->dwc_eth_debugfs = debugfs_create_dir(buf, NULL);
+	if (!pdata->dwc_eth_debugfs) {
+		netdev_err(pdata->netdev, "debugfs_create_dir failed\n");
+		kfree(buf);
+		return;
+	}
+
+	pfile = debugfs_create_file("xlgmac_register", 0600,
+				    pdata->dwc_eth_debugfs, pdata,
+				    &xlgmac_reg_addr_fops);
+	if (!pfile)
+		netdev_err(pdata->netdev, "debugfs_create_file failed\n");
+
+	pfile = debugfs_create_file("xlgmac_register_value", 0600,
+				    pdata->dwc_eth_debugfs, pdata,
+				    &xlgmac_reg_value_fops);
+	if (!pfile)
+		netdev_err(pdata->netdev, "debugfs_create_file failed\n");
+
+	pfile = debugfs_create_file("xlgpcs_mmd", 0600,
+				    pdata->dwc_eth_debugfs, pdata,
+				    &xlgpcs_mmd_fops);
+	if (!pfile)
+		netdev_err(pdata->netdev, "debugfs_create_file failed\n");
+
+	pfile = debugfs_create_file("xlgpcs_register", 0600,
+				    pdata->dwc_eth_debugfs, pdata,
+				    &xlgpcs_reg_addr_fops);
+	if (!pfile)
+		netdev_err(pdata->netdev, "debugfs_create_file failed\n");
+
+	pfile = debugfs_create_file("xlgpcs_register_value", 0600,
+				    pdata->dwc_eth_debugfs, pdata,
+				    &xlgpcs_reg_value_fops);
+	if (!pfile)
+		netdev_err(pdata->netdev, "debugfs_create_file failed\n");
+
+	kfree(buf);
+
+	TRACE("<--");
+}
+
+void xlgmac_debugfs_exit(struct dwc_eth_pdata *pdata)
+{
+	debugfs_remove_recursive(pdata->dwc_eth_debugfs);
+	pdata->dwc_eth_debugfs = NULL;
+}
diff --git a/drivers/net/ethernet/synopsys/dwc/dwc-eth-desc.c b/drivers/net/ethernet/synopsys/dwc/dwc-eth-desc.c
new file mode 100644
index 0000000..55acea0
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc/dwc-eth-desc.c
@@ -0,0 +1,715 @@
+/*
+ * Synopsys DesignWare Ethernet Driver
+ *
+ * Copyright (c) 2014-2016 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This file is free software; you may copy, redistribute and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, either version 2 of the License, or (at
+ * your option) any later version.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "dwc-eth.h"
+#include "dwc-eth-regacc.h"
+
+static void dwc_eth_unmap_desc_data(struct dwc_eth_pdata *pdata,
+				    struct dwc_eth_desc_data *desc_data)
+{
+	if (desc_data->skb_dma) {
+		if (desc_data->mapped_as_page) {
+			dma_unmap_page(pdata->dev, desc_data->skb_dma,
+				       desc_data->skb_dma_len, DMA_TO_DEVICE);
+		} else {
+			dma_unmap_single(pdata->dev, desc_data->skb_dma,
+					 desc_data->skb_dma_len, DMA_TO_DEVICE);
+		}
+		desc_data->skb_dma = 0;
+		desc_data->skb_dma_len = 0;
+	}
+
+	if (desc_data->skb) {
+		dev_kfree_skb_any(desc_data->skb);
+		desc_data->skb = NULL;
+	}
+
+	if (desc_data->rx.hdr.pa.pages)
+		put_page(desc_data->rx.hdr.pa.pages);
+
+	if (desc_data->rx.hdr.pa_unmap.pages) {
+		dma_unmap_page(pdata->dev, desc_data->rx.hdr.pa_unmap.pages_dma,
+			       desc_data->rx.hdr.pa_unmap.pages_len,
+			       DMA_FROM_DEVICE);
+		put_page(desc_data->rx.hdr.pa_unmap.pages);
+	}
+
+	if (desc_data->rx.buf.pa.pages)
+		put_page(desc_data->rx.buf.pa.pages);
+
+	if (desc_data->rx.buf.pa_unmap.pages) {
+		dma_unmap_page(pdata->dev, desc_data->rx.buf.pa_unmap.pages_dma,
+			       desc_data->rx.buf.pa_unmap.pages_len,
+			       DMA_FROM_DEVICE);
+		put_page(desc_data->rx.buf.pa_unmap.pages);
+	}
+
+	memset(&desc_data->tx, 0, sizeof(desc_data->tx));
+	memset(&desc_data->rx, 0, sizeof(desc_data->rx));
+
+	desc_data->mapped_as_page = 0;
+
+	if (desc_data->state_saved) {
+		desc_data->state_saved = 0;
+		desc_data->state.skb = NULL;
+		desc_data->state.len = 0;
+		desc_data->state.error = 0;
+	}
+}
+
+static void dwc_eth_free_ring(struct dwc_eth_pdata *pdata,
+			      struct dwc_eth_ring *ring)
+{
+	struct dwc_eth_desc_data *desc_data;
+	unsigned int i;
+
+	TRACE("-->");
+
+	if (!ring)
+		return;
+
+	if (ring->desc_data_head) {
+		for (i = 0; i < ring->dma_desc_count; i++) {
+			desc_data = DWC_ETH_GET_DESC_DATA(ring, i);
+			dwc_eth_unmap_desc_data(pdata, desc_data);
+		}
+
+		kfree(ring->desc_data_head);
+		ring->desc_data_head = NULL;
+	}
+
+	if (ring->rx_hdr_pa.pages) {
+		dma_unmap_page(pdata->dev, ring->rx_hdr_pa.pages_dma,
+			       ring->rx_hdr_pa.pages_len, DMA_FROM_DEVICE);
+		put_page(ring->rx_hdr_pa.pages);
+
+		ring->rx_hdr_pa.pages = NULL;
+		ring->rx_hdr_pa.pages_len = 0;
+		ring->rx_hdr_pa.pages_offset = 0;
+		ring->rx_hdr_pa.pages_dma = 0;
+	}
+
+	if (ring->rx_buf_pa.pages) {
+		dma_unmap_page(pdata->dev, ring->rx_buf_pa.pages_dma,
+			       ring->rx_buf_pa.pages_len, DMA_FROM_DEVICE);
+		put_page(ring->rx_buf_pa.pages);
+
+		ring->rx_buf_pa.pages = NULL;
+		ring->rx_buf_pa.pages_len = 0;
+		ring->rx_buf_pa.pages_offset = 0;
+		ring->rx_buf_pa.pages_dma = 0;
+	}
+
+	if (ring->dma_desc_head) {
+		dma_free_coherent(pdata->dev,
+				  (sizeof(struct dwc_eth_dma_desc) *
+				  ring->dma_desc_count),
+				  ring->dma_desc_head,
+				  ring->dma_desc_head_addr);
+		ring->dma_desc_head = NULL;
+	}
+
+	TRACE("<--");
+}
+
+static int dwc_eth_init_ring(struct dwc_eth_pdata *pdata,
+			     struct dwc_eth_ring *ring,
+			     unsigned int dma_desc_count)
+{
+	TRACE("-->");
+
+	if (!ring)
+		return 0;
+
+	/* Descriptors */
+	ring->dma_desc_count = dma_desc_count;
+	ring->dma_desc_head = dma_alloc_coherent(pdata->dev,
+					(sizeof(struct dwc_eth_dma_desc) *
+					 dma_desc_count),
+					&ring->dma_desc_head_addr,
+					GFP_KERNEL);
+	if (!ring->dma_desc_head)
+		return -ENOMEM;
+
+	/* Array of descriptor data */
+	ring->desc_data_head = kcalloc(dma_desc_count,
+					sizeof(struct dwc_eth_desc_data),
+					GFP_KERNEL);
+	if (!ring->desc_data_head)
+		return -ENOMEM;
+
+	netif_dbg(pdata, drv, pdata->netdev,
+		  "dma_desc_head=%p, dma_desc_head_addr=%pad, desc_data_head=%p\n",
+		ring->dma_desc_head,
+		&ring->dma_desc_head_addr,
+		ring->desc_data_head);
+
+	TRACE("<--");
+
+	return 0;
+}
+
+static void dwc_eth_free_rings(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int i;
+
+	TRACE("-->");
+
+	if (!pdata->channel_head)
+		return;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		dwc_eth_free_ring(pdata, channel->tx_ring);
+		dwc_eth_free_ring(pdata, channel->rx_ring);
+	}
+
+	TRACE("<--");
+}
+
+static int dwc_eth_alloc_rings(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int i;
+	int ret;
+
+	TRACE("-->");
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		netif_dbg(pdata, drv, pdata->netdev, "%s - Tx ring:\n",
+			  channel->name);
+
+		ret = dwc_eth_init_ring(pdata, channel->tx_ring,
+					pdata->tx_desc_count);
+
+		if (ret) {
+			netdev_alert(pdata->netdev,
+				     "error initializing Tx ring");
+			goto err_ring;
+		}
+
+		netif_dbg(pdata, drv, pdata->netdev, "%s - Rx ring:\n",
+			  channel->name);
+
+		ret = dwc_eth_init_ring(pdata, channel->rx_ring,
+					pdata->rx_desc_count);
+		if (ret) {
+			netdev_alert(pdata->netdev,
+				     "error initializing Rx ring\n");
+			goto err_ring;
+		}
+	}
+
+	TRACE("<--");
+
+	return 0;
+
+err_ring:
+	dwc_eth_free_rings(pdata);
+
+	return ret;
+}
+
+static void dwc_eth_free_channels(struct dwc_eth_pdata *pdata)
+{
+	if (!pdata->channel_head)
+		return;
+
+	kfree(pdata->channel_head->tx_ring);
+	pdata->channel_head->tx_ring = NULL;
+
+	kfree(pdata->channel_head->rx_ring);
+	pdata->channel_head->rx_ring = NULL;
+
+	kfree(pdata->channel_head);
+
+	pdata->channel_head = NULL;
+	pdata->channel_count = 0;
+}
+
+static int dwc_eth_alloc_channels(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel_head, *channel;
+	struct dwc_eth_ring *tx_ring, *rx_ring;
+	unsigned int i;
+	int ret = -ENOMEM;
+
+	TRACE("-->");
+
+	channel_head = kcalloc(pdata->channel_count,
+			       sizeof(struct dwc_eth_channel), GFP_KERNEL);
+	if (!channel_head)
+		goto err_channel;
+
+	netif_dbg(pdata, drv, pdata->netdev,
+		  "channel_head=%p\n", channel_head);
+
+	tx_ring = kcalloc(pdata->tx_ring_count, sizeof(struct dwc_eth_ring),
+			  GFP_KERNEL);
+	if (!tx_ring)
+		goto err_tx_ring;
+
+	rx_ring = kcalloc(pdata->rx_ring_count, sizeof(struct dwc_eth_ring),
+			  GFP_KERNEL);
+	if (!rx_ring)
+		goto err_rx_ring;
+
+	for (i = 0, channel = channel_head; i < pdata->channel_count;
+		i++, channel++) {
+		snprintf(channel->name, sizeof(channel->name), "channel-%u", i);
+		channel->pdata = pdata;
+		channel->queue_index = i;
+		channel->dma_regs = pdata->mac_regs + DMA_CH_BASE +
+				    (DMA_CH_INC * i);
+
+		if (pdata->per_channel_irq) {
+			/* Get the per DMA interrupt */
+			ret = pdata->channel_irq[i];
+			if (ret < 0) {
+				netdev_err(pdata->netdev,
+					   "get_irq %u failed\n",
+					   i + 1);
+				goto err_irq;
+			}
+			channel->dma_irq = ret;
+		}
+
+		if (i < pdata->tx_ring_count)
+			channel->tx_ring = tx_ring++;
+
+		if (i < pdata->rx_ring_count)
+			channel->rx_ring = rx_ring++;
+
+		netif_dbg(pdata, drv, pdata->netdev,
+			  "%s: dma_regs=%p, tx_ring=%p, rx_ring=%p\n",
+			  channel->name, channel->dma_regs,
+			  channel->tx_ring, channel->rx_ring);
+	}
+
+	pdata->channel_head = channel_head;
+
+	TRACE("<--");
+
+	return 0;
+
+err_irq:
+	kfree(rx_ring);
+
+err_rx_ring:
+	kfree(tx_ring);
+
+err_tx_ring:
+	kfree(channel_head);
+
+err_channel:
+	return ret;
+}
+
+static void dwc_eth_free_channels_and_rings(struct dwc_eth_pdata *pdata)
+{
+	dwc_eth_free_rings(pdata);
+
+	dwc_eth_free_channels(pdata);
+}
+
+static int dwc_eth_alloc_channels_and_rings(struct dwc_eth_pdata *pdata)
+{
+	int ret;
+
+	ret = dwc_eth_alloc_channels(pdata);
+	if (ret)
+		goto err_alloc;
+
+	ret = dwc_eth_alloc_rings(pdata);
+	if (ret)
+		goto err_alloc;
+
+	return 0;
+
+err_alloc:
+	dwc_eth_free_channels_and_rings(pdata);
+
+	return ret;
+}
+
+static int dwc_eth_alloc_pages(struct dwc_eth_pdata *pdata,
+			       struct dwc_eth_page_alloc *pa,
+			       gfp_t gfp, int order)
+{
+	struct page *pages = NULL;
+	dma_addr_t pages_dma;
+	int ret;
+
+	/* Try to obtain pages, decreasing order if necessary */
+	gfp |= __GFP_COLD | __GFP_COMP | __GFP_NOWARN;
+	while (order >= 0) {
+		pages = alloc_pages(gfp, order);
+		if (pages)
+			break;
+
+		order--;
+	}
+	if (!pages)
+		return -ENOMEM;
+
+	/* Map the pages */
+	pages_dma = dma_map_page(pdata->dev, pages, 0,
+				 PAGE_SIZE << order, DMA_FROM_DEVICE);
+	ret = dma_mapping_error(pdata->dev, pages_dma);
+	if (ret) {
+		put_page(pages);
+		return ret;
+	}
+
+	pa->pages = pages;
+	pa->pages_len = PAGE_SIZE << order;
+	pa->pages_offset = 0;
+	pa->pages_dma = pages_dma;
+
+	return 0;
+}
+
+static void dwc_eth_set_buffer_data(struct dwc_eth_buffer_data *bd,
+				    struct dwc_eth_page_alloc *pa,
+				    unsigned int len)
+{
+	get_page(pa->pages);
+	bd->pa = *pa;
+
+	bd->dma_base = pa->pages_dma;
+	bd->dma_off = pa->pages_offset;
+	bd->dma_len = len;
+
+	pa->pages_offset += len;
+	if ((pa->pages_offset + len) > pa->pages_len) {
+		/* This data descriptor is responsible for unmapping page(s) */
+		bd->pa_unmap = *pa;
+
+		/* Get a new allocation next time */
+		pa->pages = NULL;
+		pa->pages_len = 0;
+		pa->pages_offset = 0;
+		pa->pages_dma = 0;
+	}
+}
+
+static int dwc_eth_map_rx_buffer(struct dwc_eth_pdata *pdata,
+				 struct dwc_eth_ring *ring,
+				 struct dwc_eth_desc_data *desc_data)
+{
+	int order, ret;
+
+	if (!ring->rx_hdr_pa.pages) {
+		ret = dwc_eth_alloc_pages(pdata, &ring->rx_hdr_pa,
+					  GFP_ATOMIC, 0);
+		if (ret)
+			return ret;
+	}
+
+	if (!ring->rx_buf_pa.pages) {
+		order = max_t(int, PAGE_ALLOC_COSTLY_ORDER - 1, 0);
+		ret = dwc_eth_alloc_pages(pdata, &ring->rx_buf_pa,
+					  GFP_ATOMIC, order);
+		if (ret)
+			return ret;
+	}
+
+	/* Set up the header page info */
+	dwc_eth_set_buffer_data(&desc_data->rx.hdr, &ring->rx_hdr_pa,
+				pdata->skb_alloc_size);
+
+	/* Set up the buffer page info */
+	dwc_eth_set_buffer_data(&desc_data->rx.buf, &ring->rx_buf_pa,
+				pdata->rx_buf_size);
+
+	return 0;
+}
+
+static void dwc_eth_tx_desc_init(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+	struct dwc_eth_channel *channel;
+	struct dwc_eth_ring *ring;
+	struct dwc_eth_dma_desc *dma_desc;
+	struct dwc_eth_desc_data *desc_data;
+	dma_addr_t dma_desc_addr;
+	unsigned int i, j;
+
+	TRACE("-->");
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		ring = channel->tx_ring;
+		if (!ring)
+			break;
+
+		dma_desc = ring->dma_desc_head;
+		dma_desc_addr = ring->dma_desc_head_addr;
+
+		for (j = 0; j < ring->dma_desc_count; j++) {
+			desc_data = DWC_ETH_GET_DESC_DATA(ring, j);
+
+			desc_data->dma_desc = dma_desc;
+			desc_data->dma_desc_addr = dma_desc_addr;
+
+			dma_desc++;
+			dma_desc_addr += sizeof(struct dwc_eth_dma_desc);
+		}
+
+		ring->cur = 0;
+		ring->dirty = 0;
+		memset(&ring->tx, 0, sizeof(ring->tx));
+
+		hw_ops->tx_desc_init(channel);
+	}
+
+	TRACE("<--");
+}
+
+static void dwc_eth_rx_desc_init(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+	struct dwc_eth_channel *channel;
+	struct dwc_eth_ring *ring;
+	struct dwc_eth_dma_desc *dma_desc;
+	struct dwc_eth_desc_data *desc_data;
+	dma_addr_t dma_desc_addr;
+	unsigned int i, j;
+
+	TRACE("-->");
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		ring = channel->rx_ring;
+		if (!ring)
+			break;
+
+		dma_desc = ring->dma_desc_head;
+		dma_desc_addr = ring->dma_desc_head_addr;
+
+		for (j = 0; j < ring->dma_desc_count; j++) {
+			desc_data = DWC_ETH_GET_DESC_DATA(ring, j);
+
+			desc_data->dma_desc = dma_desc;
+			desc_data->dma_desc_addr = dma_desc_addr;
+
+			if (dwc_eth_map_rx_buffer(pdata, ring, desc_data))
+				break;
+
+			dma_desc++;
+			dma_desc_addr += sizeof(struct dwc_eth_dma_desc);
+		}
+
+		ring->cur = 0;
+		ring->dirty = 0;
+
+		hw_ops->rx_desc_init(channel);
+	}
+
+	TRACE("<--");
+}
+
+static int dwc_eth_map_tx_skb(struct dwc_eth_channel *channel,
+			      struct sk_buff *skb)
+{
+	struct dwc_eth_pdata *pdata = channel->pdata;
+	struct dwc_eth_ring *ring = channel->tx_ring;
+	struct dwc_eth_desc_data *desc_data;
+	struct dwc_eth_pkt_info *pkt_info;
+	struct skb_frag_struct *frag;
+	dma_addr_t skb_dma;
+	unsigned int start_index, cur_index;
+	unsigned int offset, tso, vlan, datalen, len;
+	unsigned int i;
+
+	TRACE("-->");
+	DBGPR("  cur = %d\n", ring->cur);
+
+	offset = 0;
+	start_index = ring->cur;
+	cur_index = ring->cur;
+
+	pkt_info = &ring->pkt_info;
+	pkt_info->desc_count = 0;
+	pkt_info->length = 0;
+
+	tso = DWC_ETH_GET_BITS(pkt_info->attributes, TX_PACKET_ATTRIBUTES,
+			       TSO_ENABLE);
+	vlan = DWC_ETH_GET_BITS(pkt_info->attributes, TX_PACKET_ATTRIBUTES,
+				VLAN_CTAG);
+
+	/* Save space for a context descriptor if needed */
+	if ((tso && (pkt_info->mss != ring->tx.cur_mss)) ||
+	    (vlan && (pkt_info->vlan_ctag != ring->tx.cur_vlan_ctag)))
+		cur_index++;
+	desc_data = DWC_ETH_GET_DESC_DATA(ring, cur_index);
+
+	if (tso) {
+		/* Map the TSO header */
+		skb_dma = dma_map_single(pdata->dev, skb->data,
+					 pkt_info->header_len, DMA_TO_DEVICE);
+		if (dma_mapping_error(pdata->dev, skb_dma)) {
+			netdev_alert(pdata->netdev, "dma_map_single failed\n");
+			goto err_out;
+		}
+		desc_data->skb_dma = skb_dma;
+		desc_data->skb_dma_len = pkt_info->header_len;
+		netif_dbg(pdata, tx_queued, pdata->netdev,
+			  "skb header: index=%u, dma=%pad, len=%u\n",
+			  cur_index, &skb_dma, pkt_info->header_len);
+
+		offset = pkt_info->header_len;
+
+		pkt_info->length += pkt_info->header_len;
+
+		cur_index++;
+		desc_data = DWC_ETH_GET_DESC_DATA(ring, cur_index);
+	}
+
+	/* Map the (remainder of the) packet */
+	for (datalen = skb_headlen(skb) - offset; datalen; ) {
+		len = min_t(unsigned int, datalen, pdata->tx_max_buf_size);
+
+		skb_dma = dma_map_single(pdata->dev, skb->data + offset, len,
+					 DMA_TO_DEVICE);
+		if (dma_mapping_error(pdata->dev, skb_dma)) {
+			netdev_alert(pdata->netdev, "dma_map_single failed\n");
+			goto err_out;
+		}
+		desc_data->skb_dma = skb_dma;
+		desc_data->skb_dma_len = len;
+		netif_dbg(pdata, tx_queued, pdata->netdev,
+			  "skb data: index=%u, dma=%pad, len=%u\n",
+			  cur_index, &skb_dma, len);
+
+		datalen -= len;
+		offset += len;
+
+		pkt_info->length += len;
+
+		cur_index++;
+		desc_data = DWC_ETH_GET_DESC_DATA(ring, cur_index);
+	}
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		netif_dbg(pdata, tx_queued, pdata->netdev,
+			  "mapping frag %u\n", i);
+
+		frag = &skb_shinfo(skb)->frags[i];
+		offset = 0;
+
+		for (datalen = skb_frag_size(frag); datalen; ) {
+			len = min_t(unsigned int, datalen,
+				    pdata->tx_max_buf_size);
+
+			skb_dma = skb_frag_dma_map(pdata->dev, frag, offset,
+						   len, DMA_TO_DEVICE);
+			if (dma_mapping_error(pdata->dev, skb_dma)) {
+				netdev_alert(pdata->netdev,
+					     "skb_frag_dma_map failed\n");
+				goto err_out;
+			}
+			desc_data->skb_dma = skb_dma;
+			desc_data->skb_dma_len = len;
+			desc_data->mapped_as_page = 1;
+			netif_dbg(pdata, tx_queued, pdata->netdev,
+				  "skb frag: index=%u, dma=%pad, len=%u\n",
+				  cur_index, &skb_dma, len);
+
+			datalen -= len;
+			offset += len;
+
+			pkt_info->length += len;
+
+			cur_index++;
+			desc_data = DWC_ETH_GET_DESC_DATA(ring, cur_index);
+		}
+	}
+
+	/* Save the skb address in the last entry. We always have some data
+	 * that has been mapped so desc_data is always advanced past the last
+	 * piece of mapped data - use the entry pointed to by cur_index - 1.
+	 */
+	desc_data = DWC_ETH_GET_DESC_DATA(ring, cur_index - 1);
+	desc_data->skb = skb;
+
+	/* Save the number of descriptor entries used */
+	pkt_info->desc_count = cur_index - start_index;
+
+	DBGPR("  count=%u\n", pkt_info->desc_count);
+	TRACE("<--");
+
+	return pkt_info->desc_count;
+
+err_out:
+	while (start_index < cur_index) {
+		desc_data = DWC_ETH_GET_DESC_DATA(ring, start_index++);
+		dwc_eth_unmap_desc_data(pdata, desc_data);
+	}
+
+	DBGPR("  count=0\n");
+	TRACE("<--");
+
+	return 0;
+}
+
+void dwc_eth_init_desc_ops(struct dwc_eth_desc_ops *desc_ops)
+{
+	desc_ops->alloc_channles_and_rings = dwc_eth_alloc_channels_and_rings;
+	desc_ops->free_channels_and_rings = dwc_eth_free_channels_and_rings;
+	desc_ops->map_tx_skb = dwc_eth_map_tx_skb;
+	desc_ops->map_rx_buffer = dwc_eth_map_rx_buffer;
+	desc_ops->unmap_desc_data = dwc_eth_unmap_desc_data;
+	desc_ops->tx_desc_init = dwc_eth_tx_desc_init;
+	desc_ops->rx_desc_init = dwc_eth_rx_desc_init;
+}
diff --git a/drivers/net/ethernet/synopsys/dwc/dwc-eth-ethtool.c b/drivers/net/ethernet/synopsys/dwc/dwc-eth-ethtool.c
new file mode 100644
index 0000000..b11fed3
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc/dwc-eth-ethtool.c
@@ -0,0 +1,567 @@
+/*
+ * Synopsys DesignWare Ethernet Driver
+ *
+ * Copyright (c) 2014-2016 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This file is free software; you may copy, redistribute and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, either version 2 of the License, or (at
+ * your option) any later version.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/spinlock.h>
+#include <linux/phy.h>
+#include <linux/net_tstamp.h>
+
+#include "dwc-eth.h"
+#include "dwc-eth-regacc.h"
+
+struct dwc_eth_stats_desc {
+	char stat_string[ETH_GSTRING_LEN];
+	int stat_size;
+	int stat_offset;
+};
+
+#define DWC_ETH_STAT(_name, _var) \
+	{\
+		_name,						\
+		FIELD_SIZEOF(struct dwc_eth_stats, _var),	\
+		offsetof(struct dwc_eth_pdata, stats._var),	\
+	}
+
+static const struct dwc_eth_stats_desc dwc_eth_gstring_stats[] = {
+	DWC_ETH_STAT("tx_bytes", txoctetcount_gb),
+	DWC_ETH_STAT("tx_packets", txframecount_gb),
+	DWC_ETH_STAT("tx_unicast_packets", txunicastframes_gb),
+	DWC_ETH_STAT("tx_broadcast_packets", txbroadcastframes_gb),
+	DWC_ETH_STAT("tx_multicast_packets", txmulticastframes_gb),
+	DWC_ETH_STAT("tx_vlan_packets", txvlanframes_g),
+	DWC_ETH_STAT("tx_tso_packets", tx_tso_packets),
+	DWC_ETH_STAT("tx_64_byte_packets", tx64octets_gb),
+	DWC_ETH_STAT("tx_65_to_127_byte_packets", tx65to127octets_gb),
+	DWC_ETH_STAT("tx_128_to_255_byte_packets", tx128to255octets_gb),
+	DWC_ETH_STAT("tx_256_to_511_byte_packets", tx256to511octets_gb),
+	DWC_ETH_STAT("tx_512_to_1023_byte_packets", tx512to1023octets_gb),
+	DWC_ETH_STAT("tx_1024_to_max_byte_packets", tx1024tomaxoctets_gb),
+	DWC_ETH_STAT("tx_underflow_errors", txunderflowerror),
+	DWC_ETH_STAT("tx_pause_frames", txpauseframes),
+
+	DWC_ETH_STAT("rx_bytes", rxoctetcount_gb),
+	DWC_ETH_STAT("rx_packets", rxframecount_gb),
+	DWC_ETH_STAT("rx_unicast_packets", rxunicastframes_g),
+	DWC_ETH_STAT("rx_broadcast_packets", rxbroadcastframes_g),
+	DWC_ETH_STAT("rx_multicast_packets", rxmulticastframes_g),
+	DWC_ETH_STAT("rx_vlan_packets", rxvlanframes_gb),
+	DWC_ETH_STAT("rx_64_byte_packets", rx64octets_gb),
+	DWC_ETH_STAT("rx_65_to_127_byte_packets", rx65to127octets_gb),
+	DWC_ETH_STAT("rx_128_to_255_byte_packets", rx128to255octets_gb),
+	DWC_ETH_STAT("rx_256_to_511_byte_packets", rx256to511octets_gb),
+	DWC_ETH_STAT("rx_512_to_1023_byte_packets", rx512to1023octets_gb),
+	DWC_ETH_STAT("rx_1024_to_max_byte_packets", rx1024tomaxoctets_gb),
+	DWC_ETH_STAT("rx_undersize_packets", rxundersize_g),
+	DWC_ETH_STAT("rx_oversize_packets", rxoversize_g),
+	DWC_ETH_STAT("rx_crc_errors", rxcrcerror),
+	DWC_ETH_STAT("rx_crc_errors_small_packets", rxrunterror),
+	DWC_ETH_STAT("rx_crc_errors_giant_packets", rxjabbererror),
+	DWC_ETH_STAT("rx_length_errors", rxlengtherror),
+	DWC_ETH_STAT("rx_out_of_range_errors", rxoutofrangetype),
+	DWC_ETH_STAT("rx_fifo_overflow_errors", rxfifooverflow),
+	DWC_ETH_STAT("rx_watchdog_errors", rxwatchdogerror),
+	DWC_ETH_STAT("rx_pause_frames", rxpauseframes),
+	DWC_ETH_STAT("rx_split_header_packets", rx_split_header_packets),
+	DWC_ETH_STAT("rx_buffer_unavailable", rx_buffer_unavailable),
+};
+
+#define DWC_ETH_STATS_COUNT	ARRAY_SIZE(dwc_eth_gstring_stats)
+
+static void dwc_eth_get_strings(struct net_device *netdev,
+				u32 stringset, u8 *data)
+{
+	int i;
+
+	TRACE("-->");
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i = 0; i < DWC_ETH_STATS_COUNT; i++) {
+			memcpy(data, dwc_eth_gstring_stats[i].stat_string,
+			       ETH_GSTRING_LEN);
+			data += ETH_GSTRING_LEN;
+		}
+		break;
+	}
+
+	TRACE("<--");
+}
+
+static void dwc_eth_get_ethtool_stats(struct net_device *netdev,
+				      struct ethtool_stats *stats,
+				      u64 *data)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	u8 *stat;
+	int i;
+
+	TRACE("-->");
+
+	pdata->hw_ops.read_mmc_stats(pdata);
+	for (i = 0; i < DWC_ETH_STATS_COUNT; i++) {
+		stat = (u8 *)pdata + dwc_eth_gstring_stats[i].stat_offset;
+		*data++ = *(u64 *)stat;
+	}
+
+	TRACE("<--");
+}
+
+static int dwc_eth_get_sset_count(struct net_device *netdev, int stringset)
+{
+	int ret;
+
+	TRACE("-->");
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		ret = DWC_ETH_STATS_COUNT;
+		break;
+
+	default:
+		ret = -EOPNOTSUPP;
+	}
+
+	TRACE("<--");
+
+	return ret;
+}
+
+static void dwc_eth_get_pauseparam(struct net_device *netdev,
+				   struct ethtool_pauseparam *pause)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+
+	TRACE("-->");
+
+	pause->autoneg = pdata->pause_autoneg;
+	pause->tx_pause = pdata->tx_pause;
+	pause->rx_pause = pdata->rx_pause;
+
+	TRACE("<--");
+}
+
+static int dwc_eth_set_pauseparam(struct net_device *netdev,
+				  struct ethtool_pauseparam *pause)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	struct phy_device *phydev = pdata->phydev;
+	int ret = 0;
+
+	TRACE("-->");
+	DBGPR("  autoneg = %d, tx_pause = %d, rx_pause = %d\n",
+	      pause->autoneg, pause->tx_pause, pause->rx_pause);
+
+	pdata->pause_autoneg = pause->autoneg;
+	if (pause->autoneg) {
+		phydev->advertising |= ADVERTISED_Pause;
+		phydev->advertising |= ADVERTISED_Asym_Pause;
+
+	} else {
+		phydev->advertising &= ~ADVERTISED_Pause;
+		phydev->advertising &= ~ADVERTISED_Asym_Pause;
+
+		pdata->tx_pause = pause->tx_pause;
+		pdata->rx_pause = pause->rx_pause;
+	}
+
+	if (netif_running(netdev))
+		ret = phy_start_aneg(phydev);
+
+	TRACE("<--");
+
+	return ret;
+}
+
+static int dwc_eth_get_settings(struct net_device *netdev,
+				struct ethtool_cmd *cmd)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	int ret;
+
+	TRACE("-->");
+
+	if (!pdata->phydev)
+		return -ENODEV;
+
+	ret = phy_ethtool_gset(pdata->phydev, cmd);
+
+	TRACE("<--");
+
+	return ret;
+}
+
+static int dwc_eth_set_settings(struct net_device *netdev,
+				struct ethtool_cmd *cmd)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	struct phy_device *phydev = pdata->phydev;
+	u32 speed;
+	int ret;
+
+	TRACE("-->");
+
+	if (!pdata->phydev)
+		return -ENODEV;
+
+	speed = ethtool_cmd_speed(cmd);
+
+	if (cmd->phy_address != phydev->mdio.addr)
+		return -EINVAL;
+
+	if ((cmd->autoneg != AUTONEG_ENABLE) &&
+	    (cmd->autoneg != AUTONEG_DISABLE))
+		return -EINVAL;
+
+	if (cmd->autoneg == AUTONEG_DISABLE) {
+		switch (speed) {
+		case SPEED_100000:
+		case SPEED_50000:
+		case SPEED_40000:
+		case SPEED_25000:
+		case SPEED_10000:
+		case SPEED_2500:
+		case SPEED_1000:
+			break;
+		default:
+			return -EINVAL;
+		}
+
+		if (cmd->duplex != DUPLEX_FULL)
+			return -EINVAL;
+	}
+
+	cmd->advertising &= phydev->supported;
+	if ((cmd->autoneg == AUTONEG_ENABLE) && !cmd->advertising)
+		return -EINVAL;
+
+	ret = 0;
+	phydev->autoneg = cmd->autoneg;
+	phydev->speed = speed;
+	phydev->duplex = cmd->duplex;
+	phydev->advertising = cmd->advertising;
+
+	if (cmd->autoneg == AUTONEG_ENABLE)
+		phydev->advertising |= ADVERTISED_Autoneg;
+	else
+		phydev->advertising &= ~ADVERTISED_Autoneg;
+
+	if (netif_running(netdev))
+		ret = phy_start_aneg(phydev);
+
+	TRACE("<--");
+
+	return ret;
+}
+
+static u32 dwc_eth_get_msglevel(struct net_device *netdev)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+
+	return pdata->msg_enable;
+}
+
+static void dwc_eth_set_msglevel(struct net_device *netdev, u32 msglevel)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+
+	pdata->msg_enable = msglevel;
+}
+
+static void dwc_eth_get_drvinfo(struct net_device *netdev,
+				struct ethtool_drvinfo *drvinfo)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	struct dwc_eth_hw_features *hw_feat = &pdata->hw_feat;
+
+	TRACE("-->");
+
+	strlcpy(drvinfo->driver, pdata->drv_name,
+		sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, pdata->drv_ver,
+		sizeof(drvinfo->version));
+	strlcpy(drvinfo->bus_info, dev_name(pdata->dev),
+		sizeof(drvinfo->bus_info));
+	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version), "%d.%d.%d",
+		 DWC_ETH_GET_BITS(hw_feat->version, MAC_VR, USERVER),
+		 DWC_ETH_GET_BITS(hw_feat->version, MAC_VR, DEVID),
+		 DWC_ETH_GET_BITS(hw_feat->version, MAC_VR, SNPSVER));
+	drvinfo->n_stats = DWC_ETH_STATS_COUNT;
+
+	TRACE("<--");
+}
+
+static int dwc_eth_get_coalesce(struct net_device *netdev,
+				struct ethtool_coalesce *ec)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+
+	TRACE("-->");
+
+	memset(ec, 0, sizeof(struct ethtool_coalesce));
+
+	ec->rx_coalesce_usecs = pdata->rx_usecs;
+	ec->rx_max_coalesced_frames = pdata->rx_frames;
+
+	ec->tx_max_coalesced_frames = pdata->tx_frames;
+
+	TRACE("<--");
+
+	return 0;
+}
+
+static int dwc_eth_set_coalesce(struct net_device *netdev,
+				struct ethtool_coalesce *ec)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+	unsigned int rx_frames, rx_riwt, rx_usecs;
+	unsigned int tx_frames;
+
+	TRACE("-->");
+
+	/* Check for not supported parameters  */
+	if ((ec->rx_coalesce_usecs_irq) ||
+	    (ec->rx_max_coalesced_frames_irq) ||
+	    (ec->tx_coalesce_usecs) ||
+	    (ec->tx_coalesce_usecs_irq) ||
+	    (ec->tx_max_coalesced_frames_irq) ||
+	    (ec->stats_block_coalesce_usecs) ||
+	    (ec->use_adaptive_rx_coalesce) ||
+	    (ec->use_adaptive_tx_coalesce) ||
+	    (ec->pkt_rate_low) ||
+	    (ec->rx_coalesce_usecs_low) ||
+	    (ec->rx_max_coalesced_frames_low) ||
+	    (ec->tx_coalesce_usecs_low) ||
+	    (ec->tx_max_coalesced_frames_low) ||
+	    (ec->pkt_rate_high) ||
+	    (ec->rx_coalesce_usecs_high) ||
+	    (ec->rx_max_coalesced_frames_high) ||
+	    (ec->tx_coalesce_usecs_high) ||
+	    (ec->tx_max_coalesced_frames_high) ||
+	    (ec->rate_sample_interval))
+		return -EOPNOTSUPP;
+
+	rx_riwt = hw_ops->usec_to_riwt(pdata, ec->rx_coalesce_usecs);
+	rx_usecs = ec->rx_coalesce_usecs;
+	rx_frames = ec->rx_max_coalesced_frames;
+
+	/* Use smallest possible value if conversion resulted in zero */
+	if (rx_usecs && !rx_riwt)
+		rx_riwt = 1;
+
+	/* Check the bounds of values for Rx */
+	if (rx_riwt > pdata->max_dma_riwt) {
+		netdev_alert(netdev, "rx-usec is limited to %d usecs\n",
+			     hw_ops->riwt_to_usec(pdata, pdata->max_dma_riwt));
+		return -EINVAL;
+	}
+	if (rx_frames > pdata->rx_desc_count) {
+		netdev_alert(netdev, "rx-frames is limited to %d frames\n",
+			     pdata->rx_desc_count);
+		return -EINVAL;
+	}
+
+	tx_frames = ec->tx_max_coalesced_frames;
+
+	/* Check the bounds of values for Tx */
+	if (tx_frames > pdata->tx_desc_count) {
+		netdev_alert(netdev, "tx-frames is limited to %d frames\n",
+			     pdata->tx_desc_count);
+		return -EINVAL;
+	}
+
+	pdata->rx_riwt = rx_riwt;
+	pdata->rx_usecs = rx_usecs;
+	pdata->rx_frames = rx_frames;
+	hw_ops->config_rx_coalesce(pdata);
+
+	pdata->tx_frames = tx_frames;
+	hw_ops->config_tx_coalesce(pdata);
+
+	TRACE("<--");
+
+	return 0;
+}
+
+static int dwc_eth_get_rxnfc(struct net_device *netdev,
+			     struct ethtool_rxnfc *rxnfc, u32 *rule_locs)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+
+	switch (rxnfc->cmd) {
+	case ETHTOOL_GRXRINGS:
+		rxnfc->data = pdata->rx_ring_count;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+static u32 dwc_eth_get_rxfh_key_size(struct net_device *netdev)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+
+	return sizeof(pdata->rss_key);
+}
+
+static u32 dwc_eth_get_rxfh_indir_size(struct net_device *netdev)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+
+	return ARRAY_SIZE(pdata->rss_table);
+}
+
+static int dwc_eth_get_rxfh(struct net_device *netdev, u32 *indir,
+			    u8 *key, u8 *hfunc)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	unsigned int i;
+
+	if (indir) {
+		for (i = 0; i < ARRAY_SIZE(pdata->rss_table); i++)
+			indir[i] = DWC_ETH_GET_BITS(pdata->rss_table[i],
+						   MAC_RSSDR, DMCH);
+	}
+
+	if (key)
+		memcpy(key, pdata->rss_key, sizeof(pdata->rss_key));
+
+	if (hfunc)
+		*hfunc = ETH_RSS_HASH_TOP;
+
+	return 0;
+}
+
+static int dwc_eth_set_rxfh(struct net_device *netdev, const u32 *indir,
+			    const u8 *key, const u8 hfunc)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+	unsigned int ret;
+
+	if (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP)
+		return -EOPNOTSUPP;
+
+	if (indir) {
+		ret = hw_ops->set_rss_lookup_table(pdata, indir);
+		if (ret)
+			return ret;
+	}
+
+	if (key) {
+		ret = hw_ops->set_rss_hash_key(pdata, key);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int dwc_eth_get_ts_info(struct net_device *netdev,
+			       struct ethtool_ts_info *ts_info)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+
+	ts_info->so_timestamping = SOF_TIMESTAMPING_TX_SOFTWARE |
+				   SOF_TIMESTAMPING_RX_SOFTWARE |
+				   SOF_TIMESTAMPING_SOFTWARE |
+				   SOF_TIMESTAMPING_TX_HARDWARE |
+				   SOF_TIMESTAMPING_RX_HARDWARE |
+				   SOF_TIMESTAMPING_RAW_HARDWARE;
+
+	if (pdata->ptp_clock)
+		ts_info->phc_index = ptp_clock_index(pdata->ptp_clock);
+	else
+		ts_info->phc_index = -1;
+
+	ts_info->tx_types = (1 << HWTSTAMP_TX_OFF) | (1 << HWTSTAMP_TX_ON);
+	ts_info->rx_filters = (1 << HWTSTAMP_FILTER_NONE) |
+			      (1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT) |
+			      (1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
+			      (1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
+			      (1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT) |
+			      (1 << HWTSTAMP_FILTER_PTP_V2_L4_SYNC) |
+			      (1 << HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ) |
+			      (1 << HWTSTAMP_FILTER_PTP_V2_EVENT) |
+			      (1 << HWTSTAMP_FILTER_PTP_V2_SYNC) |
+			      (1 << HWTSTAMP_FILTER_PTP_V2_DELAY_REQ) |
+			      (1 << HWTSTAMP_FILTER_ALL);
+
+	return 0;
+}
+
+static const struct ethtool_ops dwc_eth_ethtool_ops = {
+	.get_settings = dwc_eth_get_settings,
+	.set_settings = dwc_eth_set_settings,
+	.get_drvinfo = dwc_eth_get_drvinfo,
+	.get_msglevel = dwc_eth_get_msglevel,
+	.set_msglevel = dwc_eth_set_msglevel,
+	.get_link = ethtool_op_get_link,
+	.get_coalesce = dwc_eth_get_coalesce,
+	.set_coalesce = dwc_eth_set_coalesce,
+	.get_pauseparam = dwc_eth_get_pauseparam,
+	.set_pauseparam = dwc_eth_set_pauseparam,
+	.get_strings = dwc_eth_get_strings,
+	.get_ethtool_stats = dwc_eth_get_ethtool_stats,
+	.get_sset_count = dwc_eth_get_sset_count,
+	.get_rxnfc = dwc_eth_get_rxnfc,
+	.get_rxfh_key_size = dwc_eth_get_rxfh_key_size,
+	.get_rxfh_indir_size = dwc_eth_get_rxfh_indir_size,
+	.get_rxfh = dwc_eth_get_rxfh,
+	.set_rxfh = dwc_eth_set_rxfh,
+	.get_ts_info = dwc_eth_get_ts_info,
+};
+
+const struct ethtool_ops *dwc_eth_get_ethtool_ops(void)
+{
+	return &dwc_eth_ethtool_ops;
+}
diff --git a/drivers/net/ethernet/synopsys/dwc/dwc-eth-hw.c b/drivers/net/ethernet/synopsys/dwc/dwc-eth-hw.c
new file mode 100644
index 0000000..1d721d5
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc/dwc-eth-hw.c
@@ -0,0 +1,3098 @@
+/*
+ * Synopsys DesignWare Ethernet Driver
+ *
+ * Copyright (c) 2014-2016 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This file is free software; you may copy, redistribute and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, either version 2 of the License, or (at
+ * your option) any later version.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/phy.h>
+#include <linux/mdio.h>
+#include <linux/clk.h>
+#include <linux/bitrev.h>
+#include <linux/crc32.h>
+
+#include "dwc-eth.h"
+#include "dwc-eth-regacc.h"
+
+static int dwc_eth_tx_complete(struct dwc_eth_dma_desc *dma_desc)
+{
+	return !DWC_ETH_GET_BITS_LE(dma_desc->desc3, TX_NORMAL_DESC3, OWN);
+}
+
+static int dwc_eth_disable_rx_csum(struct dwc_eth_pdata *pdata)
+{
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_RCR, IPC, 0);
+
+	return 0;
+}
+
+static int dwc_eth_enable_rx_csum(struct dwc_eth_pdata *pdata)
+{
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_RCR, IPC, 1);
+
+	return 0;
+}
+
+static int dwc_eth_set_mac_address(struct dwc_eth_pdata *pdata, u8 *addr)
+{
+	unsigned int mac_addr_hi, mac_addr_lo;
+
+	mac_addr_hi = (addr[5] <<  8) | (addr[4] <<  0);
+	mac_addr_lo = (addr[3] << 24) | (addr[2] << 16) |
+		      (addr[1] <<  8) | (addr[0] <<  0);
+
+	DWC_ETH_IOWRITE(pdata, MAC_MACA0HR, mac_addr_hi);
+	DWC_ETH_IOWRITE(pdata, MAC_MACA0LR, mac_addr_lo);
+
+	return 0;
+}
+
+static void dwc_eth_set_mac_reg(struct dwc_eth_pdata *pdata,
+				struct netdev_hw_addr *ha,
+				unsigned int *mac_reg)
+{
+	unsigned int mac_addr_hi, mac_addr_lo;
+	u8 *mac_addr;
+
+	mac_addr_lo = 0;
+	mac_addr_hi = 0;
+
+	if (ha) {
+		mac_addr = (u8 *)&mac_addr_lo;
+		mac_addr[0] = ha->addr[0];
+		mac_addr[1] = ha->addr[1];
+		mac_addr[2] = ha->addr[2];
+		mac_addr[3] = ha->addr[3];
+		mac_addr = (u8 *)&mac_addr_hi;
+		mac_addr[0] = ha->addr[4];
+		mac_addr[1] = ha->addr[5];
+
+		netif_dbg(pdata, drv, pdata->netdev,
+			  "adding mac address %pM at %#x\n",
+			  ha->addr, *mac_reg);
+
+		DWC_ETH_SET_BITS(mac_addr_hi, MAC_MACA1HR, AE, 1);
+	}
+
+	DWC_ETH_IOWRITE(pdata, *mac_reg, mac_addr_hi);
+	*mac_reg += MAC_MACA_INC;
+	DWC_ETH_IOWRITE(pdata, *mac_reg, mac_addr_lo);
+	*mac_reg += MAC_MACA_INC;
+}
+
+static int dwc_eth_enable_rx_vlan_stripping(struct dwc_eth_pdata *pdata)
+{
+	/* Put the VLAN tag in the Rx descriptor */
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_VLANTR, EVLRXS, 1);
+
+	/* Don't check the VLAN type */
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_VLANTR, DOVLTC, 1);
+
+	/* Check only C-TAG (0x8100) packets */
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_VLANTR, ERSVLM, 0);
+
+	/* Don't consider an S-TAG (0x88A8) packet as a VLAN packet */
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_VLANTR, ESVL, 0);
+
+	/* Enable VLAN tag stripping */
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_VLANTR, EVLS, 0x3);
+
+	return 0;
+}
+
+static int dwc_eth_disable_rx_vlan_stripping(struct dwc_eth_pdata *pdata)
+{
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_VLANTR, EVLS, 0);
+
+	return 0;
+}
+
+static int dwc_eth_enable_rx_vlan_filtering(struct dwc_eth_pdata *pdata)
+{
+	/* Enable VLAN filtering */
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_PFR, VTFE, 1);
+
+	/* Enable VLAN Hash Table filtering */
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_VLANTR, VTHM, 1);
+
+	/* Disable VLAN tag inverse matching */
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_VLANTR, VTIM, 0);
+
+	/* Only filter on the lower 12-bits of the VLAN tag */
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_VLANTR, ETV, 1);
+
+	/* In order for the VLAN Hash Table filtering to be effective,
+	 * the VLAN tag identifier in the VLAN Tag Register must not
+	 * be zero.  Set the VLAN tag identifier to "1" to enable the
+	 * VLAN Hash Table filtering.  This implies that a VLAN tag of
+	 * 1 will always pass filtering.
+	 */
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_VLANTR, VL, 1);
+
+	return 0;
+}
+
+static int dwc_eth_disable_rx_vlan_filtering(struct dwc_eth_pdata *pdata)
+{
+	/* Disable VLAN filtering */
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_PFR, VTFE, 0);
+
+	return 0;
+}
+
+static u32 dwc_eth_vid_crc32_le(__le16 vid_le)
+{
+	u32 poly = 0xedb88320;	/* CRCPOLY_LE */
+	u32 crc = ~0;
+	u32 temp = 0;
+	unsigned char *data = (unsigned char *)&vid_le;
+	unsigned char data_byte = 0;
+	int i, bits;
+
+	bits = get_bitmask_order(VLAN_VID_MASK);
+	for (i = 0; i < bits; i++) {
+		if ((i % 8) == 0)
+			data_byte = data[i / 8];
+
+		temp = ((crc & 1) ^ data_byte) & 1;
+		crc >>= 1;
+		data_byte >>= 1;
+
+		if (temp)
+			crc ^= poly;
+	}
+
+	return crc;
+}
+
+static int dwc_eth_update_vlan_hash_table(struct dwc_eth_pdata *pdata)
+{
+	u32 crc;
+	u16 vid;
+	__le16 vid_le;
+	u16 vlan_hash_table = 0;
+
+	/* Generate the VLAN Hash Table value */
+	for_each_set_bit(vid, pdata->active_vlans, VLAN_N_VID) {
+		/* Get the CRC32 value of the VLAN ID */
+		vid_le = cpu_to_le16(vid);
+		crc = bitrev32(~dwc_eth_vid_crc32_le(vid_le)) >> 28;
+
+		vlan_hash_table |= (1 << crc);
+	}
+
+	/* Set the VLAN Hash Table filtering register */
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_VLANHTR, VLHT, vlan_hash_table);
+
+	return 0;
+}
+
+static int dwc_eth_set_promiscuous_mode(struct dwc_eth_pdata *pdata,
+					unsigned int enable)
+{
+	unsigned int val = enable ? 1 : 0;
+
+	if (DWC_ETH_IOREAD_BITS(pdata, MAC_PFR, PR) == val)
+		return 0;
+
+	netif_dbg(pdata, drv, pdata->netdev, "%s promiscuous mode\n",
+		  enable ? "entering" : "leaving");
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_PFR, PR, val);
+
+	/* Hardware will still perform VLAN filtering in promiscuous mode */
+	if (enable) {
+		dwc_eth_disable_rx_vlan_filtering(pdata);
+	} else {
+		if (pdata->netdev->features & NETIF_F_HW_VLAN_CTAG_FILTER)
+			dwc_eth_enable_rx_vlan_filtering(pdata);
+	}
+
+	return 0;
+}
+
+static int dwc_eth_set_all_multicast_mode(struct dwc_eth_pdata *pdata,
+					  unsigned int enable)
+{
+	unsigned int val = enable ? 1 : 0;
+
+	if (DWC_ETH_IOREAD_BITS(pdata, MAC_PFR, PM) == val)
+		return 0;
+
+	netif_dbg(pdata, drv, pdata->netdev, "%s allmulti mode\n",
+		  enable ? "entering" : "leaving");
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_PFR, PM, val);
+
+	return 0;
+}
+
+static void dwc_eth_set_mac_addn_addrs(struct dwc_eth_pdata *pdata)
+{
+	struct net_device *netdev = pdata->netdev;
+	struct netdev_hw_addr *ha;
+	unsigned int mac_reg;
+	unsigned int addn_macs;
+
+	mac_reg = MAC_MACA1HR;
+	addn_macs = pdata->hw_feat.addn_mac;
+
+	if (netdev_uc_count(netdev) > addn_macs) {
+		dwc_eth_set_promiscuous_mode(pdata, 1);
+	} else {
+		netdev_for_each_uc_addr(ha, netdev) {
+			dwc_eth_set_mac_reg(pdata, ha, &mac_reg);
+			addn_macs--;
+		}
+
+		if (netdev_mc_count(netdev) > addn_macs) {
+			dwc_eth_set_all_multicast_mode(pdata, 1);
+		} else {
+			netdev_for_each_mc_addr(ha, netdev) {
+				dwc_eth_set_mac_reg(pdata, ha, &mac_reg);
+				addn_macs--;
+			}
+		}
+	}
+
+	/* Clear remaining additional MAC address entries */
+	while (addn_macs--)
+		dwc_eth_set_mac_reg(pdata, NULL, &mac_reg);
+}
+
+static void dwc_eth_set_mac_hash_table(struct dwc_eth_pdata *pdata)
+{
+	struct net_device *netdev = pdata->netdev;
+	struct netdev_hw_addr *ha;
+	unsigned int hash_reg;
+	unsigned int hash_table_shift, hash_table_count;
+	u32 hash_table[DWC_ETH_MAC_HASH_TABLE_SIZE];
+	u32 crc;
+	unsigned int i;
+
+	hash_table_shift = 26 - (pdata->hw_feat.hash_table_size >> 7);
+	hash_table_count = pdata->hw_feat.hash_table_size / 32;
+	memset(hash_table, 0, sizeof(hash_table));
+
+	/* Build the MAC Hash Table register values */
+	netdev_for_each_uc_addr(ha, netdev) {
+		crc = bitrev32(~crc32_le(~0, ha->addr, ETH_ALEN));
+		crc >>= hash_table_shift;
+		hash_table[crc >> 5] |= (1 << (crc & 0x1f));
+	}
+
+	netdev_for_each_mc_addr(ha, netdev) {
+		crc = bitrev32(~crc32_le(~0, ha->addr, ETH_ALEN));
+		crc >>= hash_table_shift;
+		hash_table[crc >> 5] |= (1 << (crc & 0x1f));
+	}
+
+	/* Set the MAC Hash Table registers */
+	hash_reg = MAC_HTR0;
+	for (i = 0; i < hash_table_count; i++) {
+		DWC_ETH_IOWRITE(pdata, hash_reg, hash_table[i]);
+		hash_reg += MAC_HTR_INC;
+	}
+}
+
+static int dwc_eth_add_mac_addresses(struct dwc_eth_pdata *pdata)
+{
+	if (pdata->hw_feat.hash_table_size)
+		dwc_eth_set_mac_hash_table(pdata);
+	else
+		dwc_eth_set_mac_addn_addrs(pdata);
+
+	return 0;
+}
+
+static void dwc_eth_config_mac_address(struct dwc_eth_pdata *pdata)
+{
+	dwc_eth_set_mac_address(pdata, pdata->netdev->dev_addr);
+
+	/* Filtering is done using perfect filtering and hash filtering */
+	if (pdata->hw_feat.hash_table_size) {
+		DWC_ETH_IOWRITE_BITS(pdata, MAC_PFR, HPF, 1);
+		DWC_ETH_IOWRITE_BITS(pdata, MAC_PFR, HUC, 1);
+		DWC_ETH_IOWRITE_BITS(pdata, MAC_PFR, HMC, 1);
+	}
+}
+
+static void dwc_eth_config_jumbo_enable(struct dwc_eth_pdata *pdata)
+{
+	unsigned int val;
+
+	val = (pdata->netdev->mtu > DWC_ETH_STD_PACKET_MTU) ? 1 : 0;
+
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_RCR, JE, val);
+}
+
+static void dwc_eth_config_checksum_offload(struct dwc_eth_pdata *pdata)
+{
+	if (pdata->netdev->features & NETIF_F_RXCSUM)
+		dwc_eth_enable_rx_csum(pdata);
+	else
+		dwc_eth_disable_rx_csum(pdata);
+}
+
+static void dwc_eth_config_vlan_support(struct dwc_eth_pdata *pdata)
+{
+	/* Indicate that VLAN Tx CTAGs come from context descriptors */
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_VLANIR, CSVL, 0);
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_VLANIR, VLTI, 1);
+
+	/* Set the current VLAN Hash Table register value */
+	dwc_eth_update_vlan_hash_table(pdata);
+
+	if (pdata->netdev->features & NETIF_F_HW_VLAN_CTAG_FILTER)
+		dwc_eth_enable_rx_vlan_filtering(pdata);
+	else
+		dwc_eth_disable_rx_vlan_filtering(pdata);
+
+	if (pdata->netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
+		dwc_eth_enable_rx_vlan_stripping(pdata);
+	else
+		dwc_eth_disable_rx_vlan_stripping(pdata);
+}
+
+static int dwc_eth_config_rx_mode(struct dwc_eth_pdata *pdata)
+{
+	struct net_device *netdev = pdata->netdev;
+	unsigned int pr_mode, am_mode;
+
+	pr_mode = ((netdev->flags & IFF_PROMISC) != 0);
+	am_mode = ((netdev->flags & IFF_ALLMULTI) != 0);
+
+	dwc_eth_set_promiscuous_mode(pdata, pr_mode);
+	dwc_eth_set_all_multicast_mode(pdata, am_mode);
+
+	dwc_eth_add_mac_addresses(pdata);
+
+	return 0;
+}
+
+static void dwc_eth_prepare_tx_stop(struct dwc_eth_pdata *pdata,
+				    struct dwc_eth_channel *channel)
+{
+	unsigned int tx_dsr, tx_pos, tx_qidx;
+	unsigned int tx_status;
+	unsigned long tx_timeout;
+
+	/* Calculate the status register to read and the position within */
+	if (channel->queue_index < DMA_DSRX_FIRST_QUEUE) {
+		tx_dsr = DMA_DSR0;
+		tx_pos = (channel->queue_index * DMA_DSR_Q_LEN) +
+			 DMA_DSR0_TPS_START;
+	} else {
+		tx_qidx = channel->queue_index - DMA_DSRX_FIRST_QUEUE;
+
+		tx_dsr = DMA_DSR1 + ((tx_qidx / DMA_DSRX_QPR) * DMA_DSRX_INC);
+		tx_pos = ((tx_qidx % DMA_DSRX_QPR) * DMA_DSR_Q_LEN) +
+			 DMA_DSRX_TPS_START;
+	}
+
+	/* The Tx engine cannot be stopped if it is actively processing
+	 * descriptors. Wait for the Tx engine to enter the stopped or
+	 * suspended state.  Don't wait forever though...
+	 */
+	tx_timeout = jiffies + (pdata->dma_stop_timeout * HZ);
+	while (time_before(jiffies, tx_timeout)) {
+		tx_status = DWC_ETH_IOREAD(pdata, tx_dsr);
+		tx_status = GET_BITS(tx_status, tx_pos, DMA_DSR_TPS_LEN);
+		if ((tx_status == DMA_TPS_STOPPED) ||
+		    (tx_status == DMA_TPS_SUSPENDED))
+			break;
+
+		usleep_range(500, 1000);
+	}
+
+	if (!time_before(jiffies, tx_timeout))
+		netdev_info(pdata->netdev,
+			    "timed out waiting for Tx DMA channel %u to stop\n",
+			    channel->queue_index);
+}
+
+static void dwc_eth_enable_tx(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int i;
+
+	/* Enable each Tx DMA channel */
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		DWC_ETH_DMA_IOWRITE_BITS(channel, DMA_CH_TCR, ST, 1);
+	}
+
+	/* Enable each Tx queue */
+	for (i = 0; i < pdata->tx_q_count; i++)
+		DWC_ETH_MTL_IOWRITE_BITS(pdata, i, MTL_Q_TQOMR, TXQEN,
+					 MTL_Q_ENABLED);
+
+	/* Enable MAC Tx */
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_TCR, TE, 1);
+}
+
+static void dwc_eth_disable_tx(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int i;
+
+	/* Prepare for Tx DMA channel stop */
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		dwc_eth_prepare_tx_stop(pdata, channel);
+	}
+
+	/* Disable MAC Tx */
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_TCR, TE, 0);
+
+	/* Disable each Tx queue */
+	for (i = 0; i < pdata->tx_q_count; i++)
+		DWC_ETH_MTL_IOWRITE_BITS(pdata, i, MTL_Q_TQOMR, TXQEN, 0);
+
+	/* Disable each Tx DMA channel */
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		DWC_ETH_DMA_IOWRITE_BITS(channel, DMA_CH_TCR, ST, 0);
+	}
+}
+
+static void dwc_eth_prepare_rx_stop(struct dwc_eth_pdata *pdata,
+				    unsigned int queue)
+{
+	unsigned int rx_status;
+	unsigned long rx_timeout;
+
+	/* The Rx engine cannot be stopped if it is actively processing
+	 * packets. Wait for the Rx queue to empty the Rx fifo.  Don't
+	 * wait forever though...
+	 */
+	rx_timeout = jiffies + (pdata->dma_stop_timeout * HZ);
+	while (time_before(jiffies, rx_timeout)) {
+		rx_status = DWC_ETH_MTL_IOREAD(pdata, queue, MTL_Q_RQDR);
+		if ((DWC_ETH_GET_BITS(rx_status, MTL_Q_RQDR, PRXQ) == 0) &&
+		    (DWC_ETH_GET_BITS(rx_status, MTL_Q_RQDR, RXQSTS) == 0))
+			break;
+
+		usleep_range(500, 1000);
+	}
+
+	if (!time_before(jiffies, rx_timeout))
+		netdev_info(pdata->netdev,
+			    "timed out waiting for Rx queue %u to empty\n",
+			    queue);
+}
+
+static void dwc_eth_enable_rx(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int reg_val, i;
+
+	/* Enable each Rx DMA channel */
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->rx_ring)
+			break;
+
+		DWC_ETH_DMA_IOWRITE_BITS(channel, DMA_CH_RCR, SR, 1);
+	}
+
+	/* Enable each Rx queue */
+	reg_val = 0;
+	for (i = 0; i < pdata->rx_q_count; i++)
+		reg_val |= (0x02 << (i << 1));
+	DWC_ETH_IOWRITE(pdata, MAC_RQC0R, reg_val);
+
+	/* Enable MAC Rx */
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_RCR, DCRCC, 1);
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_RCR, CST, 1);
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_RCR, ACS, 1);
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_RCR, RE, 1);
+}
+
+static void dwc_eth_disable_rx(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int i;
+
+	/* Disable MAC Rx */
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_RCR, DCRCC, 0);
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_RCR, CST, 0);
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_RCR, ACS, 0);
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_RCR, RE, 0);
+
+	/* Prepare for Rx DMA channel stop */
+	for (i = 0; i < pdata->rx_q_count; i++)
+		dwc_eth_prepare_rx_stop(pdata, i);
+
+	/* Disable each Rx queue */
+	DWC_ETH_IOWRITE(pdata, MAC_RQC0R, 0);
+
+	/* Disable each Rx DMA channel */
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->rx_ring)
+			break;
+
+		DWC_ETH_DMA_IOWRITE_BITS(channel, DMA_CH_RCR, SR, 0);
+	}
+}
+
+static void dwc_eth_powerup_tx(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int i;
+
+	/* Enable each Tx DMA channel */
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		DWC_ETH_DMA_IOWRITE_BITS(channel, DMA_CH_TCR, ST, 1);
+	}
+
+	/* Enable MAC Tx */
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_TCR, TE, 1);
+}
+
+static void dwc_eth_powerdown_tx(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int i;
+
+	/* Prepare for Tx DMA channel stop */
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		dwc_eth_prepare_tx_stop(pdata, channel);
+	}
+
+	/* Disable MAC Tx */
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_TCR, TE, 0);
+
+	/* Disable each Tx DMA channel */
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		DWC_ETH_DMA_IOWRITE_BITS(channel, DMA_CH_TCR, ST, 0);
+	}
+}
+
+static void dwc_eth_powerup_rx(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int i;
+
+	/* Enable each Rx DMA channel */
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->rx_ring)
+			break;
+
+		DWC_ETH_DMA_IOWRITE_BITS(channel, DMA_CH_RCR, SR, 1);
+	}
+}
+
+static void dwc_eth_powerdown_rx(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int i;
+
+	/* Disable each Rx DMA channel */
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->rx_ring)
+			break;
+
+		DWC_ETH_DMA_IOWRITE_BITS(channel, DMA_CH_RCR, SR, 0);
+	}
+}
+
+static void dwc_eth_tx_start_xmit(struct dwc_eth_channel *channel,
+				  struct dwc_eth_ring *ring)
+{
+	struct dwc_eth_pdata *pdata = channel->pdata;
+	struct dwc_eth_desc_data *desc_data;
+
+	/* Make sure everything is written before the register write */
+	wmb();
+
+	/* Issue a poll command to Tx DMA by writing address
+	 * of next immediate free descriptor
+	 */
+	desc_data = DWC_ETH_GET_DESC_DATA(ring, ring->cur);
+	DWC_ETH_DMA_IOWRITE(channel, DMA_CH_TDTR_LO,
+			    lower_32_bits(desc_data->dma_desc_addr));
+
+	/* Start the Tx timer */
+	if (pdata->tx_usecs && !channel->tx_timer_active) {
+		channel->tx_timer_active = 1;
+		mod_timer(&channel->tx_timer,
+			  jiffies + usecs_to_jiffies(pdata->tx_usecs));
+	}
+
+	ring->tx.xmit_more = 0;
+}
+
+static void dwc_eth_dev_xmit(struct dwc_eth_channel *channel)
+{
+	struct dwc_eth_pdata *pdata = channel->pdata;
+	struct dwc_eth_ring *ring = channel->tx_ring;
+	struct dwc_eth_desc_data *desc_data;
+	struct dwc_eth_dma_desc *dma_desc;
+	struct dwc_eth_pkt_info *pkt_info = &ring->pkt_info;
+	unsigned int csum, tso, vlan;
+	unsigned int tso_context, vlan_context;
+	unsigned int tx_set_ic;
+	int start_index = ring->cur;
+	int cur_index = ring->cur;
+	int i;
+
+	TRACE("-->");
+
+	csum = DWC_ETH_GET_BITS(pkt_info->attributes, TX_PACKET_ATTRIBUTES,
+				CSUM_ENABLE);
+	tso = DWC_ETH_GET_BITS(pkt_info->attributes, TX_PACKET_ATTRIBUTES,
+			       TSO_ENABLE);
+	vlan = DWC_ETH_GET_BITS(pkt_info->attributes, TX_PACKET_ATTRIBUTES,
+				VLAN_CTAG);
+
+	if (tso && (pkt_info->mss != ring->tx.cur_mss))
+		tso_context = 1;
+	else
+		tso_context = 0;
+
+	if (vlan && (pkt_info->vlan_ctag != ring->tx.cur_vlan_ctag))
+		vlan_context = 1;
+	else
+		vlan_context = 0;
+
+	/* Determine if an interrupt should be generated for this Tx:
+	 *   Interrupt:
+	 *     - Tx frame count exceeds the frame count setting
+	 *     - Addition of Tx frame count to the frame count since the
+	 *       last interrupt was set exceeds the frame count setting
+	 *   No interrupt:
+	 *     - No frame count setting specified (ethtool -C ethX tx-frames 0)
+	 *     - Addition of Tx frame count to the frame count since the
+	 *       last interrupt was set does not exceed the frame count setting
+	 */
+	ring->coalesce_count += pkt_info->tx_packets;
+	if (!pdata->tx_frames)
+		tx_set_ic = 0;
+	else if (pkt_info->tx_packets > pdata->tx_frames)
+		tx_set_ic = 1;
+	else if ((ring->coalesce_count % pdata->tx_frames) <
+		 pkt_info->tx_packets)
+		tx_set_ic = 1;
+	else
+		tx_set_ic = 0;
+
+	desc_data = DWC_ETH_GET_DESC_DATA(ring, cur_index);
+	dma_desc = desc_data->dma_desc;
+
+	/* Create a context descriptor if this is a TSO pkt_info */
+	if (tso_context || vlan_context) {
+		if (tso_context) {
+			netif_dbg(pdata, tx_queued, pdata->netdev,
+				  "TSO context descriptor, mss=%u\n",
+				  pkt_info->mss);
+
+			/* Set the MSS size */
+			DWC_ETH_SET_BITS_LE(dma_desc->desc2, TX_CONTEXT_DESC2,
+					    MSS, pkt_info->mss);
+
+			/* Mark it as a CONTEXT descriptor */
+			DWC_ETH_SET_BITS_LE(dma_desc->desc3, TX_CONTEXT_DESC3,
+					    CTXT, 1);
+
+			/* Indicate this descriptor contains the MSS */
+			DWC_ETH_SET_BITS_LE(dma_desc->desc3, TX_CONTEXT_DESC3,
+					    TCMSSV, 1);
+
+			ring->tx.cur_mss = pkt_info->mss;
+		}
+
+		if (vlan_context) {
+			netif_dbg(pdata, tx_queued, pdata->netdev,
+				  "VLAN context descriptor, ctag=%u\n",
+				  pkt_info->vlan_ctag);
+
+			/* Mark it as a CONTEXT descriptor */
+			DWC_ETH_SET_BITS_LE(dma_desc->desc3, TX_CONTEXT_DESC3,
+					    CTXT, 1);
+
+			/* Set the VLAN tag */
+			DWC_ETH_SET_BITS_LE(dma_desc->desc3, TX_CONTEXT_DESC3,
+					    VT, pkt_info->vlan_ctag);
+
+			/* Indicate this descriptor contains the VLAN tag */
+			DWC_ETH_SET_BITS_LE(dma_desc->desc3, TX_CONTEXT_DESC3,
+					    VLTV, 1);
+
+			ring->tx.cur_vlan_ctag = pkt_info->vlan_ctag;
+		}
+
+		cur_index++;
+		desc_data = DWC_ETH_GET_DESC_DATA(ring, cur_index);
+		dma_desc = desc_data->dma_desc;
+	}
+
+	/* Update buffer address (for TSO this is the header) */
+	dma_desc->desc0 =  cpu_to_le32(lower_32_bits(desc_data->skb_dma));
+	dma_desc->desc1 =  cpu_to_le32(upper_32_bits(desc_data->skb_dma));
+
+	/* Update the buffer length */
+	DWC_ETH_SET_BITS_LE(dma_desc->desc2, TX_NORMAL_DESC2, HL_B1L,
+			    desc_data->skb_dma_len);
+
+	/* VLAN tag insertion check */
+	if (vlan)
+		DWC_ETH_SET_BITS_LE(dma_desc->desc2, TX_NORMAL_DESC2, VTIR,
+				    TX_NORMAL_DESC2_VLAN_INSERT);
+
+	/* Timestamp enablement check */
+	if (DWC_ETH_GET_BITS(pkt_info->attributes, TX_PACKET_ATTRIBUTES, PTP))
+		DWC_ETH_SET_BITS_LE(dma_desc->desc2, TX_NORMAL_DESC2, TTSE, 1);
+
+	/* Mark it as First Descriptor */
+	DWC_ETH_SET_BITS_LE(dma_desc->desc3, TX_NORMAL_DESC3, FD, 1);
+
+	/* Mark it as a NORMAL descriptor */
+	DWC_ETH_SET_BITS_LE(dma_desc->desc3, TX_NORMAL_DESC3, CTXT, 0);
+
+	/* Set OWN bit if not the first descriptor */
+	if (cur_index != start_index)
+		DWC_ETH_SET_BITS_LE(dma_desc->desc3, TX_NORMAL_DESC3, OWN, 1);
+
+	if (tso) {
+		/* Enable TSO */
+		DWC_ETH_SET_BITS_LE(dma_desc->desc3, TX_NORMAL_DESC3, TSE, 1);
+		DWC_ETH_SET_BITS_LE(dma_desc->desc3, TX_NORMAL_DESC3, TCPPL,
+				    pkt_info->tcp_payload_len);
+		DWC_ETH_SET_BITS_LE(dma_desc->desc3, TX_NORMAL_DESC3, TCPHDRLEN,
+				    pkt_info->tcp_header_len / 4);
+
+		pdata->stats.tx_tso_packets++;
+	} else {
+		/* Enable CRC and Pad Insertion */
+		DWC_ETH_SET_BITS_LE(dma_desc->desc3, TX_NORMAL_DESC3, CPC, 0);
+
+		/* Enable HW CSUM */
+		if (csum)
+			DWC_ETH_SET_BITS_LE(dma_desc->desc3, TX_NORMAL_DESC3,
+					    CIC, 0x3);
+
+		/* Set the total length to be transmitted */
+		DWC_ETH_SET_BITS_LE(dma_desc->desc3, TX_NORMAL_DESC3, FL,
+				    pkt_info->length);
+	}
+
+	for (i = cur_index - start_index + 1; i < pkt_info->desc_count; i++) {
+		cur_index++;
+		desc_data = DWC_ETH_GET_DESC_DATA(ring, cur_index);
+		dma_desc = desc_data->dma_desc;
+
+		/* Update buffer address */
+		dma_desc->desc0 =
+			cpu_to_le32(lower_32_bits(desc_data->skb_dma));
+		dma_desc->desc1 =
+			cpu_to_le32(upper_32_bits(desc_data->skb_dma));
+
+		/* Update the buffer length */
+		DWC_ETH_SET_BITS_LE(dma_desc->desc2, TX_NORMAL_DESC2, HL_B1L,
+				    desc_data->skb_dma_len);
+
+		/* Set OWN bit */
+		DWC_ETH_SET_BITS_LE(dma_desc->desc3, TX_NORMAL_DESC3, OWN, 1);
+
+		/* Mark it as NORMAL descriptor */
+		DWC_ETH_SET_BITS_LE(dma_desc->desc3, TX_NORMAL_DESC3, CTXT, 0);
+
+		/* Enable HW CSUM */
+		if (csum)
+			DWC_ETH_SET_BITS_LE(dma_desc->desc3, TX_NORMAL_DESC3,
+					    CIC, 0x3);
+	}
+
+	/* Set LAST bit for the last descriptor */
+	DWC_ETH_SET_BITS_LE(dma_desc->desc3, TX_NORMAL_DESC3, LD, 1);
+
+	/* Set IC bit based on Tx coalescing settings */
+	if (tx_set_ic)
+		DWC_ETH_SET_BITS_LE(dma_desc->desc2, TX_NORMAL_DESC2, IC, 1);
+
+	/* Save the Tx info to report back during cleanup */
+	desc_data->tx.packets = pkt_info->tx_packets;
+	desc_data->tx.bytes = pkt_info->tx_bytes;
+
+	/* In case the Tx DMA engine is running, make sure everything
+	 * is written to the descriptor(s) before setting the OWN bit
+	 * for the first descriptor
+	 */
+	dma_wmb();
+
+	/* Set OWN bit for the first descriptor */
+	desc_data = DWC_ETH_GET_DESC_DATA(ring, start_index);
+	dma_desc = desc_data->dma_desc;
+	DWC_ETH_SET_BITS_LE(dma_desc->desc3, TX_NORMAL_DESC3, OWN, 1);
+
+	if (netif_msg_tx_queued(pdata))
+		dwc_eth_dump_tx_desc(pdata, ring, start_index,
+				     pkt_info->desc_count, 1);
+
+	/* Make sure ownership is written to the descriptor */
+	smp_wmb();
+
+	ring->cur = cur_index + 1;
+	if (!pkt_info->skb->xmit_more ||
+	    netif_xmit_stopped(netdev_get_tx_queue(pdata->netdev,
+						   channel->queue_index)))
+		dwc_eth_tx_start_xmit(channel, ring);
+	else
+		ring->tx.xmit_more = 1;
+
+	DBGPR("  %s: descriptors %u to %u written\n",
+	      channel->name, start_index & (ring->dma_desc_count - 1),
+	      (ring->cur - 1) & (ring->dma_desc_count - 1));
+	TRACE("<--");
+}
+
+static void dwc_eth_update_tstamp_addend(struct dwc_eth_pdata *pdata,
+					 unsigned int addend)
+{
+	/* Set the addend register value and tell the device */
+	DWC_ETH_IOWRITE(pdata, MAC_TSAR, addend);
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_TSCR, TSADDREG, 1);
+
+	/* Wait for addend update to complete */
+	while (DWC_ETH_IOREAD_BITS(pdata, MAC_TSCR, TSADDREG))
+		udelay(5);
+}
+
+static void dwc_eth_set_tstamp_time(struct dwc_eth_pdata *pdata,
+				    unsigned int sec,
+				    unsigned int nsec)
+{
+	/* Set the time values and tell the device */
+	DWC_ETH_IOWRITE(pdata, MAC_STSUR, sec);
+	DWC_ETH_IOWRITE(pdata, MAC_STNUR, nsec);
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_TSCR, TSINIT, 1);
+
+	/* Wait for time update to complete */
+	while (DWC_ETH_IOREAD_BITS(pdata, MAC_TSCR, TSINIT))
+		udelay(5);
+}
+
+static u64 dwc_eth_get_tstamp_time(struct dwc_eth_pdata *pdata)
+{
+	u64 nsec;
+
+	nsec = DWC_ETH_IOREAD(pdata, MAC_STSR);
+	nsec *= NSEC_PER_SEC;
+	nsec += DWC_ETH_IOREAD(pdata, MAC_STNR);
+
+	return nsec;
+}
+
+static u64 dwc_eth_get_tx_tstamp(struct dwc_eth_pdata *pdata)
+{
+	unsigned int tx_snr;
+	u64 nsec;
+
+	tx_snr = DWC_ETH_IOREAD(pdata, MAC_TXSNR);
+	if (DWC_ETH_GET_BITS(tx_snr, MAC_TXSNR, TXTSSTSMIS))
+		return 0;
+
+	nsec = DWC_ETH_IOREAD(pdata, MAC_TXSSR);
+	nsec *= NSEC_PER_SEC;
+	nsec += tx_snr;
+
+	return nsec;
+}
+
+static void dwc_eth_get_rx_tstamp(struct dwc_eth_pkt_info *pkt_info,
+				  struct dwc_eth_dma_desc *dma_desc)
+{
+	u64 nsec;
+
+	if (DWC_ETH_GET_BITS_LE(dma_desc->desc3, RX_CONTEXT_DESC3, TSA) &&
+	    !DWC_ETH_GET_BITS_LE(dma_desc->desc3, RX_CONTEXT_DESC3, TSD)) {
+		nsec = le32_to_cpu(dma_desc->desc1);
+		nsec <<= 32;
+		nsec |= le32_to_cpu(dma_desc->desc0);
+		if (nsec != 0xffffffffffffffffULL) {
+			pkt_info->rx_tstamp = nsec;
+			DWC_ETH_SET_BITS(pkt_info->attributes,
+					 RX_PACKET_ATTRIBUTES,
+					RX_TSTAMP, 1);
+		}
+	}
+}
+
+static int dwc_eth_config_tstamp(struct dwc_eth_pdata *pdata,
+				 unsigned int mac_tscr)
+{
+	/* Set one nano-second accuracy */
+	DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSCTRLSSR, 1);
+
+	/* Set fine timestamp update */
+	DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSCFUPDT, 1);
+
+	/* Overwrite earlier timestamps */
+	DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TXTSSTSM, 1);
+
+	DWC_ETH_IOWRITE(pdata, MAC_TSCR, mac_tscr);
+
+	/* Exit if timestamping is not enabled */
+	if (!DWC_ETH_GET_BITS(mac_tscr, MAC_TSCR, TSENA))
+		return 0;
+
+	/* Initialize time registers */
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_SSIR, SSINC, pdata->tstamp_ssinc);
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_SSIR, SNSINC, pdata->tstamp_snsinc);
+	dwc_eth_update_tstamp_addend(pdata, pdata->tstamp_addend);
+	dwc_eth_set_tstamp_time(pdata, 0, 0);
+
+	/* Initialize the timecounter */
+	timecounter_init(&pdata->tstamp_tc, &pdata->tstamp_cc,
+			 ktime_to_ns(ktime_get_real()));
+
+	return 0;
+}
+
+static void dwc_eth_tx_desc_reset(struct dwc_eth_desc_data *desc_data)
+{
+	struct dwc_eth_dma_desc *dma_desc = desc_data->dma_desc;
+
+	/* Reset the Tx descriptor
+	 *   Set buffer 1 (lo) address to zero
+	 *   Set buffer 1 (hi) address to zero
+	 *   Reset all other control bits (IC, TTSE, B2L & B1L)
+	 *   Reset all other control bits (OWN, CTXT, FD, LD, CPC, CIC, etc)
+	 */
+	dma_desc->desc0 = 0;
+	dma_desc->desc1 = 0;
+	dma_desc->desc2 = 0;
+	dma_desc->desc3 = 0;
+
+	/* Make sure ownership is written to the descriptor */
+	dma_wmb();
+}
+
+static void dwc_eth_tx_desc_init(struct dwc_eth_channel *channel)
+{
+	struct dwc_eth_ring *ring = channel->tx_ring;
+	struct dwc_eth_desc_data *desc_data;
+	int i;
+	int start_index = ring->cur;
+
+	TRACE("-->");
+
+	/* Initialze all descriptors */
+	for (i = 0; i < ring->dma_desc_count; i++) {
+		desc_data = DWC_ETH_GET_DESC_DATA(ring, i);
+
+		/* Initialize Tx descriptor */
+		dwc_eth_tx_desc_reset(desc_data);
+	}
+
+	/* Update the total number of Tx descriptors */
+	DWC_ETH_DMA_IOWRITE(channel, DMA_CH_TDRLR, ring->dma_desc_count - 1);
+
+	/* Update the starting address of descriptor ring */
+	desc_data = DWC_ETH_GET_DESC_DATA(ring, start_index);
+	DWC_ETH_DMA_IOWRITE(channel, DMA_CH_TDLR_HI,
+			    upper_32_bits(desc_data->dma_desc_addr));
+	DWC_ETH_DMA_IOWRITE(channel, DMA_CH_TDLR_LO,
+			    lower_32_bits(desc_data->dma_desc_addr));
+
+	TRACE("<--");
+}
+
+static void dwc_eth_rx_desc_reset(struct dwc_eth_pdata *pdata,
+				  struct dwc_eth_desc_data *desc_data,
+				  unsigned int index)
+{
+	struct dwc_eth_dma_desc *dma_desc = desc_data->dma_desc;
+	unsigned int rx_usecs = pdata->rx_usecs;
+	unsigned int rx_frames = pdata->rx_frames;
+	unsigned int inte;
+	dma_addr_t hdr_dma, buf_dma;
+
+	if (!rx_usecs && !rx_frames) {
+		/* No coalescing, interrupt for every descriptor */
+		inte = 1;
+	} else {
+		/* Set interrupt based on Rx frame coalescing setting */
+		if (rx_frames && !((index + 1) % rx_frames))
+			inte = 1;
+		else
+			inte = 0;
+	}
+
+	/* Reset the Rx descriptor
+	 *   Set buffer 1 (lo) address to header dma address (lo)
+	 *   Set buffer 1 (hi) address to header dma address (hi)
+	 *   Set buffer 2 (lo) address to buffer dma address (lo)
+	 *   Set buffer 2 (hi) address to buffer dma address (hi) and
+	 *     set control bits OWN and INTE
+	 */
+	hdr_dma = desc_data->rx.hdr.dma_base + desc_data->rx.hdr.dma_off;
+	buf_dma = desc_data->rx.buf.dma_base + desc_data->rx.buf.dma_off;
+	dma_desc->desc0 = cpu_to_le32(lower_32_bits(hdr_dma));
+	dma_desc->desc1 = cpu_to_le32(upper_32_bits(hdr_dma));
+	dma_desc->desc2 = cpu_to_le32(lower_32_bits(buf_dma));
+	dma_desc->desc3 = cpu_to_le32(upper_32_bits(buf_dma));
+
+	DWC_ETH_SET_BITS_LE(dma_desc->desc3, RX_NORMAL_DESC3, INTE, inte);
+
+	/* Since the Rx DMA engine is likely running, make sure everything
+	 * is written to the descriptor(s) before setting the OWN bit
+	 * for the descriptor
+	 */
+	dma_wmb();
+
+	DWC_ETH_SET_BITS_LE(dma_desc->desc3, RX_NORMAL_DESC3, OWN, 1);
+
+	/* Make sure ownership is written to the descriptor */
+	dma_wmb();
+}
+
+static void dwc_eth_rx_desc_init(struct dwc_eth_channel *channel)
+{
+	struct dwc_eth_pdata *pdata = channel->pdata;
+	struct dwc_eth_ring *ring = channel->rx_ring;
+	struct dwc_eth_desc_data *desc_data;
+	unsigned int start_index = ring->cur;
+	unsigned int i;
+
+	TRACE("-->");
+
+	/* Initialize all descriptors */
+	for (i = 0; i < ring->dma_desc_count; i++) {
+		desc_data = DWC_ETH_GET_DESC_DATA(ring, i);
+
+		/* Initialize Rx descriptor */
+		dwc_eth_rx_desc_reset(pdata, desc_data, i);
+	}
+
+	/* Update the total number of Rx descriptors */
+	DWC_ETH_DMA_IOWRITE(channel, DMA_CH_RDRLR, ring->dma_desc_count - 1);
+
+	/* Update the starting address of descriptor ring */
+	desc_data = DWC_ETH_GET_DESC_DATA(ring, start_index);
+	DWC_ETH_DMA_IOWRITE(channel, DMA_CH_RDLR_HI,
+			    upper_32_bits(desc_data->dma_desc_addr));
+	DWC_ETH_DMA_IOWRITE(channel, DMA_CH_RDLR_LO,
+			    lower_32_bits(desc_data->dma_desc_addr));
+
+	/* Update the Rx Descriptor Tail Pointer */
+	desc_data = DWC_ETH_GET_DESC_DATA(ring, start_index +
+					  ring->dma_desc_count - 1);
+	DWC_ETH_DMA_IOWRITE(channel, DMA_CH_RDTR_LO,
+			    lower_32_bits(desc_data->dma_desc_addr));
+
+	TRACE("<--");
+}
+
+static int dwc_eth_is_context_desc(struct dwc_eth_dma_desc *dma_desc)
+{
+	/* Rx and Tx share CTXT bit, so check TDES3.CTXT bit */
+	return DWC_ETH_GET_BITS_LE(dma_desc->desc3, TX_NORMAL_DESC3, CTXT);
+}
+
+static int dwc_eth_is_last_desc(struct dwc_eth_dma_desc *dma_desc)
+{
+	/* Rx and Tx share LD bit, so check TDES3.LD bit */
+	return DWC_ETH_GET_BITS_LE(dma_desc->desc3, TX_NORMAL_DESC3, LD);
+}
+
+static int dwc_eth_disable_tx_flow_control(struct dwc_eth_pdata *pdata)
+{
+	unsigned int max_q_count, q_count;
+	unsigned int reg, reg_val;
+	unsigned int i;
+
+	/* Clear MTL flow control */
+	for (i = 0; i < pdata->rx_q_count; i++)
+		DWC_ETH_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, EHFC, 0);
+
+	/* Clear MAC flow control */
+	max_q_count = pdata->max_flow_control_queues;
+	q_count = min_t(unsigned int, pdata->tx_q_count, max_q_count);
+	reg = MAC_Q0TFCR;
+	for (i = 0; i < q_count; i++) {
+		reg_val = DWC_ETH_IOREAD(pdata, reg);
+		DWC_ETH_SET_BITS(reg_val, MAC_Q0TFCR, TFE, 0);
+		DWC_ETH_IOWRITE(pdata, reg, reg_val);
+
+		reg += MAC_QTFCR_INC;
+	}
+
+	return 0;
+}
+
+static int dwc_eth_enable_tx_flow_control(struct dwc_eth_pdata *pdata)
+{
+	struct ieee_pfc *pfc = pdata->pfc;
+	struct ieee_ets *ets = pdata->ets;
+	unsigned int max_q_count, q_count;
+	unsigned int reg, reg_val;
+	unsigned int i;
+
+	/* Set MTL flow control */
+	for (i = 0; i < pdata->rx_q_count; i++) {
+		unsigned int ehfc = 0;
+
+		if (pfc && ets) {
+			unsigned int prio;
+
+			for (prio = 0; prio < IEEE_8021QAZ_MAX_TCS; prio++) {
+				unsigned int tc;
+
+				/* Does this queue handle the priority? */
+				if (pdata->prio2q_map[prio] != i)
+					continue;
+
+				/* Get the Traffic Class for this priority */
+				tc = ets->prio_tc[prio];
+
+				/* Check if flow control should be enabled */
+				if (pfc->pfc_en & (1 << tc)) {
+					ehfc = 1;
+					break;
+				}
+			}
+		} else {
+			ehfc = 1;
+		}
+
+		DWC_ETH_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, EHFC, ehfc);
+
+		netif_dbg(pdata, drv, pdata->netdev,
+			  "flow control %s for RXq%u\n",
+			  ehfc ? "enabled" : "disabled", i);
+	}
+
+	/* Set MAC flow control */
+	max_q_count = pdata->max_flow_control_queues;
+	q_count = min_t(unsigned int, pdata->tx_q_count, max_q_count);
+	reg = MAC_Q0TFCR;
+	for (i = 0; i < q_count; i++) {
+		reg_val = DWC_ETH_IOREAD(pdata, reg);
+
+		/* Enable transmit flow control */
+		DWC_ETH_SET_BITS(reg_val, MAC_Q0TFCR, TFE, 1);
+		/* Set pause time */
+		DWC_ETH_SET_BITS(reg_val, MAC_Q0TFCR, PT, 0xffff);
+
+		DWC_ETH_IOWRITE(pdata, reg, reg_val);
+
+		reg += MAC_QTFCR_INC;
+	}
+
+	return 0;
+}
+
+static int dwc_eth_disable_rx_flow_control(struct dwc_eth_pdata *pdata)
+{
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_RFCR, RFE, 0);
+
+	return 0;
+}
+
+static int dwc_eth_enable_rx_flow_control(struct dwc_eth_pdata *pdata)
+{
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_RFCR, RFE, 1);
+
+	return 0;
+}
+
+static int dwc_eth_config_tx_flow_control(struct dwc_eth_pdata *pdata)
+{
+	struct ieee_pfc *pfc = pdata->pfc;
+
+	if (pdata->tx_pause || (pfc && pfc->pfc_en))
+		dwc_eth_enable_tx_flow_control(pdata);
+	else
+		dwc_eth_disable_tx_flow_control(pdata);
+
+	return 0;
+}
+
+static int dwc_eth_config_rx_flow_control(struct dwc_eth_pdata *pdata)
+{
+	struct ieee_pfc *pfc = pdata->pfc;
+
+	if (pdata->rx_pause || (pfc && pfc->pfc_en))
+		dwc_eth_enable_rx_flow_control(pdata);
+	else
+		dwc_eth_disable_rx_flow_control(pdata);
+
+	return 0;
+}
+
+static int dwc_eth_config_rx_coalesce(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int i;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->rx_ring)
+			break;
+
+		DWC_ETH_DMA_IOWRITE_BITS(channel, DMA_CH_RIWT, RWT,
+					 pdata->rx_riwt);
+	}
+
+	return 0;
+}
+
+static void dwc_eth_config_flow_control(struct dwc_eth_pdata *pdata)
+{
+	struct ieee_pfc *pfc = pdata->pfc;
+
+	dwc_eth_config_tx_flow_control(pdata);
+	dwc_eth_config_rx_flow_control(pdata);
+
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_RFCR, PFCE,
+			     (pfc && pfc->pfc_en) ? 1 : 0);
+}
+
+static void dwc_eth_config_tc(struct dwc_eth_pdata *pdata)
+{
+	unsigned int offset, queue, prio;
+	u8 i;
+
+	netdev_reset_tc(pdata->netdev);
+	if (!pdata->num_tcs)
+		return;
+
+	netdev_set_num_tc(pdata->netdev, pdata->num_tcs);
+
+	for (i = 0, queue = 0, offset = 0; i < pdata->num_tcs; i++) {
+		while ((queue < pdata->tx_q_count) &&
+		       (pdata->q2tc_map[queue] == i))
+			queue++;
+
+		netif_dbg(pdata, drv, pdata->netdev, "TC%u using TXq%u-%u\n",
+			  i, offset, queue - 1);
+		netdev_set_tc_queue(pdata->netdev, i, queue - offset, offset);
+		offset = queue;
+	}
+
+	if (!pdata->ets)
+		return;
+
+	for (prio = 0; prio < IEEE_8021QAZ_MAX_TCS; prio++)
+		netdev_set_prio_tc_map(pdata->netdev, prio,
+				       pdata->ets->prio_tc[prio]);
+}
+
+static void dwc_eth_config_rx_fep_enable(struct dwc_eth_pdata *pdata)
+{
+	unsigned int i;
+
+	for (i = 0; i < pdata->rx_q_count; i++)
+		DWC_ETH_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, FEP, 1);
+}
+
+static void dwc_eth_config_rx_fup_enable(struct dwc_eth_pdata *pdata)
+{
+	unsigned int i;
+
+	for (i = 0; i < pdata->rx_q_count; i++)
+		DWC_ETH_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, FUP, 1);
+}
+
+static void dwc_eth_config_dcb_tc(struct dwc_eth_pdata *pdata)
+{
+	struct ieee_ets *ets = pdata->ets;
+	unsigned int total_weight, min_weight, weight;
+	unsigned int mask, reg, reg_val;
+	unsigned int i, prio;
+
+	if (!ets)
+		return;
+
+	/* Set Tx to deficit weighted round robin scheduling algorithm (when
+	 * traffic class is using ETS algorithm)
+	 */
+	DWC_ETH_IOWRITE_BITS(pdata, MTL_OMR, ETSALG, MTL_ETSALG_DWRR);
+
+	/* Set Traffic Class algorithms */
+	total_weight = pdata->netdev->mtu * pdata->hw_feat.tc_cnt;
+	min_weight = total_weight / 100;
+	if (!min_weight)
+		min_weight = 1;
+
+	for (i = 0; i < pdata->hw_feat.tc_cnt; i++) {
+		/* Map the priorities to the traffic class */
+		mask = 0;
+		for (prio = 0; prio < IEEE_8021QAZ_MAX_TCS; prio++) {
+			if (ets->prio_tc[prio] == i)
+				mask |= (1 << prio);
+		}
+		mask &= 0xff;
+
+		netif_dbg(pdata, drv, pdata->netdev, "TC%u PRIO mask=%#x\n",
+			  i, mask);
+		reg = MTL_TCPM0R + (MTL_TCPM_INC * (i / MTL_TCPM_TC_PER_REG));
+		reg_val = DWC_ETH_IOREAD(pdata, reg);
+
+		reg_val &= ~(0xff << ((i % MTL_TCPM_TC_PER_REG) << 3));
+		reg_val |= (mask << ((i % MTL_TCPM_TC_PER_REG) << 3));
+
+		DWC_ETH_IOWRITE(pdata, reg, reg_val);
+
+		/* Set the traffic class algorithm */
+		switch (ets->tc_tsa[i]) {
+		case IEEE_8021QAZ_TSA_STRICT:
+			netif_dbg(pdata, drv, pdata->netdev,
+				  "TC%u using SP\n", i);
+			DWC_ETH_MTL_IOWRITE_BITS(pdata, i, MTL_TC_ETSCR, TSA,
+						 MTL_TSA_SP);
+			break;
+		case IEEE_8021QAZ_TSA_ETS:
+			weight = total_weight * ets->tc_tx_bw[i] / 100;
+			weight = clamp(weight, min_weight, total_weight);
+
+			netif_dbg(pdata, drv, pdata->netdev,
+				  "TC%u using DWRR (weight %u)\n", i, weight);
+			DWC_ETH_MTL_IOWRITE_BITS(pdata, i, MTL_TC_ETSCR, TSA,
+						 MTL_TSA_ETS);
+			DWC_ETH_MTL_IOWRITE_BITS(pdata, i, MTL_TC_QWR, QW,
+						 weight);
+			break;
+		}
+	}
+
+	dwc_eth_config_tc(pdata);
+}
+
+static void dwc_eth_config_dcb_pfc(struct dwc_eth_pdata *pdata)
+{
+	dwc_eth_config_flow_control(pdata);
+}
+
+static int dwc_eth_config_tx_coalesce(struct dwc_eth_pdata *pdata)
+{
+	return 0;
+}
+
+static void dwc_eth_config_rx_buffer_size(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int i;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->rx_ring)
+			break;
+
+		DWC_ETH_DMA_IOWRITE_BITS(channel, DMA_CH_RCR, RBSZ,
+					 pdata->rx_buf_size);
+	}
+}
+
+static void dwc_eth_config_tso_mode(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int i;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		if (pdata->hw_feat.tso)
+			DWC_ETH_DMA_IOWRITE_BITS(channel, DMA_CH_TCR, TSE, 1);
+	}
+}
+
+static void dwc_eth_config_sph_mode(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int i;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->rx_ring)
+			break;
+
+		DWC_ETH_DMA_IOWRITE_BITS(channel, DMA_CH_CR, SPH, 1);
+	}
+
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_RCR, HDSMS, pdata->sph_hdsms_size);
+}
+
+static unsigned int dwc_eth_usec_to_riwt(struct dwc_eth_pdata *pdata,
+					 unsigned int usec)
+{
+	unsigned long rate;
+	unsigned int ret;
+
+	TRACE("-->");
+
+	rate = pdata->sysclk_rate;
+
+	/* Convert the input usec value to the watchdog timer value. Each
+	 * watchdog timer value is equivalent to 256 clock cycles.
+	 * Calculate the required value as:
+	 *   ( usec * ( system_clock_mhz / 10^6 ) / 256
+	 */
+	ret = (usec * (rate / 1000000)) / 256;
+
+	TRACE("<--");
+
+	return ret;
+}
+
+static unsigned int dwc_eth_riwt_to_usec(struct dwc_eth_pdata *pdata,
+					 unsigned int riwt)
+{
+	unsigned long rate;
+	unsigned int ret;
+
+	TRACE("-->");
+
+	rate = pdata->sysclk_rate;
+
+	/* Convert the input watchdog timer value to the usec value. Each
+	 * watchdog timer value is equivalent to 256 clock cycles.
+	 * Calculate the required value as:
+	 *   ( riwt * 256 ) / ( system_clock_mhz / 10^6 )
+	 */
+	ret = (riwt * 256) / (rate / 1000000);
+
+	TRACE("<--");
+
+	return ret;
+}
+
+static int dwc_eth_config_rx_threshold(struct dwc_eth_pdata *pdata,
+				       unsigned int val)
+{
+	unsigned int i;
+
+	for (i = 0; i < pdata->rx_q_count; i++)
+		DWC_ETH_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, RTC, val);
+
+	return 0;
+}
+
+static void dwc_eth_config_mtl_mode(struct dwc_eth_pdata *pdata)
+{
+	unsigned int i;
+
+	/* Set Tx to weighted round robin scheduling algorithm */
+	DWC_ETH_IOWRITE_BITS(pdata, MTL_OMR, ETSALG, MTL_ETSALG_WRR);
+
+	/* Set Tx traffic classes to use WRR algorithm with equal weights */
+	for (i = 0; i < pdata->hw_feat.tc_cnt; i++) {
+		DWC_ETH_MTL_IOWRITE_BITS(pdata, i, MTL_TC_ETSCR, TSA,
+					 MTL_TSA_ETS);
+		DWC_ETH_MTL_IOWRITE_BITS(pdata, i, MTL_TC_QWR, QW, 1);
+	}
+
+	/* Set Rx to strict priority algorithm */
+	DWC_ETH_IOWRITE_BITS(pdata, MTL_OMR, RAA, MTL_RAA_SP);
+}
+
+static void dwc_eth_config_queue_mapping(struct dwc_eth_pdata *pdata)
+{
+	unsigned int qptc, qptc_extra, queue;
+	unsigned int prio_queues;
+	unsigned int ppq, ppq_extra, prio;
+	unsigned int mask;
+	unsigned int i, j, reg, reg_val;
+
+	/* Map the MTL Tx Queues to Traffic Classes
+	 *   Note: Tx Queues >= Traffic Classes
+	 */
+	qptc = pdata->tx_q_count / pdata->hw_feat.tc_cnt;
+	qptc_extra = pdata->tx_q_count % pdata->hw_feat.tc_cnt;
+
+	for (i = 0, queue = 0; i < pdata->hw_feat.tc_cnt; i++) {
+		for (j = 0; j < qptc; j++) {
+			netif_dbg(pdata, drv, pdata->netdev,
+				  "TXq%u mapped to TC%u\n", queue, i);
+			DWC_ETH_MTL_IOWRITE_BITS(pdata, queue, MTL_Q_TQOMR,
+						 Q2TCMAP, i);
+			pdata->q2tc_map[queue++] = i;
+		}
+
+		if (i < qptc_extra) {
+			netif_dbg(pdata, drv, pdata->netdev,
+				  "TXq%u mapped to TC%u\n", queue, i);
+			DWC_ETH_MTL_IOWRITE_BITS(pdata, queue, MTL_Q_TQOMR,
+						 Q2TCMAP, i);
+			pdata->q2tc_map[queue++] = i;
+		}
+	}
+
+	/* Map the 8 VLAN priority values to available MTL Rx queues */
+	prio_queues = min_t(unsigned int, IEEE_8021QAZ_MAX_TCS,
+			    pdata->rx_q_count);
+	ppq = IEEE_8021QAZ_MAX_TCS / prio_queues;
+	ppq_extra = IEEE_8021QAZ_MAX_TCS % prio_queues;
+
+	reg = MAC_RQC2R;
+	reg_val = 0;
+	for (i = 0, prio = 0; i < prio_queues;) {
+		mask = 0;
+		for (j = 0; j < ppq; j++) {
+			netif_dbg(pdata, drv, pdata->netdev,
+				  "PRIO%u mapped to RXq%u\n", prio, i);
+			mask |= (1 << prio);
+			pdata->prio2q_map[prio++] = i;
+		}
+
+		if (i < ppq_extra) {
+			netif_dbg(pdata, drv, pdata->netdev,
+				  "PRIO%u mapped to RXq%u\n", prio, i);
+			mask |= (1 << prio);
+			pdata->prio2q_map[prio++] = i;
+		}
+
+		reg_val |= (mask << ((i++ % MAC_RQC2_Q_PER_REG) << 3));
+
+		if ((i % MAC_RQC2_Q_PER_REG) && (i != prio_queues))
+			continue;
+
+		DWC_ETH_IOWRITE(pdata, reg, reg_val);
+		reg += MAC_RQC2_INC;
+		reg_val = 0;
+	}
+
+	/* Select dynamic mapping of MTL Rx queue to DMA Rx channel */
+	reg = MTL_RQDCM0R;
+	reg_val = 0;
+	for (i = 0; i < pdata->rx_q_count;) {
+		reg_val |= (0x80 << ((i++ % MTL_RQDCM_Q_PER_REG) << 3));
+
+		if ((i % MTL_RQDCM_Q_PER_REG) && (i != pdata->rx_q_count))
+			continue;
+
+		DWC_ETH_IOWRITE(pdata, reg, reg_val);
+
+		reg += MTL_RQDCM_INC;
+		reg_val = 0;
+	}
+}
+
+static unsigned int dwc_eth_calculate_per_queue_fifo(
+					unsigned int fifo_size,
+					unsigned int queue_count)
+{
+	unsigned int q_fifo_size;
+	unsigned int p_fifo;
+
+	/* Calculate the configured fifo size */
+	q_fifo_size = 1 << (fifo_size + 7);
+
+	/* The configured value may not be the actual amount of fifo RAM */
+	q_fifo_size = min_t(unsigned int, DWC_ETH_MAX_FIFO, q_fifo_size);
+
+	q_fifo_size = q_fifo_size / queue_count;
+
+	/* Each increment in the queue fifo size represents 256 bytes of
+	 * fifo, with 0 representing 256 bytes. Distribute the fifo equally
+	 * between the queues.
+	 */
+	p_fifo = q_fifo_size / 256;
+	if (p_fifo)
+		p_fifo--;
+
+	return p_fifo;
+}
+
+static void dwc_eth_config_tx_fifo_size(struct dwc_eth_pdata *pdata)
+{
+	unsigned int fifo_size;
+	unsigned int i;
+
+	fifo_size = dwc_eth_calculate_per_queue_fifo(
+				pdata->hw_feat.tx_fifo_size,
+				pdata->tx_q_count);
+
+	for (i = 0; i < pdata->tx_q_count; i++)
+		DWC_ETH_MTL_IOWRITE_BITS(pdata, i, MTL_Q_TQOMR, TQS, fifo_size);
+
+	netif_info(pdata, drv, pdata->netdev,
+		   "%d Tx hardware queues, %d byte fifo per queue\n",
+		   pdata->tx_q_count, ((fifo_size + 1) * 256));
+}
+
+static void dwc_eth_config_rx_fifo_size(struct dwc_eth_pdata *pdata)
+{
+	unsigned int fifo_size;
+	unsigned int i;
+
+	fifo_size = dwc_eth_calculate_per_queue_fifo(
+					pdata->hw_feat.rx_fifo_size,
+					pdata->rx_q_count);
+
+	for (i = 0; i < pdata->rx_q_count; i++)
+		DWC_ETH_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, RQS, fifo_size);
+
+	netif_info(pdata, drv, pdata->netdev,
+		   "%d Rx hardware queues, %d byte fifo per queue\n",
+		   pdata->rx_q_count, ((fifo_size + 1) * 256));
+}
+
+static void dwc_eth_config_flow_control_threshold(struct dwc_eth_pdata *pdata)
+{
+	unsigned int i;
+
+	for (i = 0; i < pdata->rx_q_count; i++) {
+		/* Activate flow control when less than 4k left in fifo */
+		DWC_ETH_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQFCR, RFA, 2);
+
+		/* De-activate flow control when more than 6k left in fifo */
+		DWC_ETH_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQFCR, RFD, 4);
+	}
+}
+
+static int dwc_eth_config_tx_threshold(struct dwc_eth_pdata *pdata,
+				       unsigned int val)
+{
+	unsigned int i;
+
+	for (i = 0; i < pdata->tx_q_count; i++)
+		DWC_ETH_MTL_IOWRITE_BITS(pdata, i, MTL_Q_TQOMR, TTC, val);
+
+	return 0;
+}
+
+static int dwc_eth_config_rsf_mode(struct dwc_eth_pdata *pdata,
+				   unsigned int val)
+{
+	unsigned int i;
+
+	for (i = 0; i < pdata->rx_q_count; i++)
+		DWC_ETH_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, RSF, val);
+
+	return 0;
+}
+
+static int dwc_eth_config_tsf_mode(struct dwc_eth_pdata *pdata,
+				   unsigned int val)
+{
+	unsigned int i;
+
+	for (i = 0; i < pdata->tx_q_count; i++)
+		DWC_ETH_MTL_IOWRITE_BITS(pdata, i, MTL_Q_TQOMR, TSF, val);
+
+	return 0;
+}
+
+static int dwc_eth_config_osp_mode(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int i;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		DWC_ETH_DMA_IOWRITE_BITS(channel, DMA_CH_TCR, OSP,
+					 pdata->tx_osp_mode);
+	}
+
+	return 0;
+}
+
+static int dwc_eth_config_pblx8(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int i;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++)
+		DWC_ETH_DMA_IOWRITE_BITS(channel, DMA_CH_CR, PBLX8,
+					 pdata->pblx8);
+
+	return 0;
+}
+
+static int dwc_eth_get_tx_pbl_val(struct dwc_eth_pdata *pdata)
+{
+	return DWC_ETH_DMA_IOREAD_BITS(pdata->channel_head, DMA_CH_TCR, PBL);
+}
+
+static int dwc_eth_config_tx_pbl_val(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int i;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		DWC_ETH_DMA_IOWRITE_BITS(channel, DMA_CH_TCR, PBL,
+					 pdata->tx_pbl);
+	}
+
+	return 0;
+}
+
+static int dwc_eth_get_rx_pbl_val(struct dwc_eth_pdata *pdata)
+{
+	return DWC_ETH_DMA_IOREAD_BITS(pdata->channel_head, DMA_CH_RCR, PBL);
+}
+
+static int dwc_eth_config_rx_pbl_val(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int i;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->rx_ring)
+			break;
+
+		DWC_ETH_DMA_IOWRITE_BITS(channel, DMA_CH_RCR, PBL,
+					 pdata->rx_pbl);
+	}
+
+	return 0;
+}
+
+static u64 dwc_eth_mmc_read(struct dwc_eth_pdata *pdata, unsigned int reg_lo)
+{
+	bool read_hi;
+	u64 val;
+
+	switch (reg_lo) {
+	/* These registers are always 64 bit */
+	case MMC_TXOCTETCOUNT_GB_LO:
+	case MMC_TXOCTETCOUNT_G_LO:
+	case MMC_RXOCTETCOUNT_GB_LO:
+	case MMC_RXOCTETCOUNT_G_LO:
+		read_hi = true;
+		break;
+
+	default:
+		read_hi = false;
+	}
+
+	val = DWC_ETH_IOREAD(pdata, reg_lo);
+
+	if (read_hi)
+		val |= ((u64)DWC_ETH_IOREAD(pdata, reg_lo + 4) << 32);
+
+	return val;
+}
+
+static void dwc_eth_tx_mmc_int(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_stats *stats = &pdata->stats;
+	unsigned int mmc_isr = DWC_ETH_IOREAD(pdata, MMC_TISR);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_TISR, TXOCTETCOUNT_GB))
+		stats->txoctetcount_gb +=
+			dwc_eth_mmc_read(pdata, MMC_TXOCTETCOUNT_GB_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_TISR, TXFRAMECOUNT_GB))
+		stats->txframecount_gb +=
+			dwc_eth_mmc_read(pdata, MMC_TXFRAMECOUNT_GB_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_TISR, TXBROADCASTFRAMES_G))
+		stats->txbroadcastframes_g +=
+			dwc_eth_mmc_read(pdata, MMC_TXBROADCASTFRAMES_G_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_TISR, TXMULTICASTFRAMES_G))
+		stats->txmulticastframes_g +=
+			dwc_eth_mmc_read(pdata, MMC_TXMULTICASTFRAMES_G_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_TISR, TX64OCTETS_GB))
+		stats->tx64octets_gb +=
+			dwc_eth_mmc_read(pdata, MMC_TX64OCTETS_GB_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_TISR, TX65TO127OCTETS_GB))
+		stats->tx65to127octets_gb +=
+			dwc_eth_mmc_read(pdata, MMC_TX65TO127OCTETS_GB_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_TISR, TX128TO255OCTETS_GB))
+		stats->tx128to255octets_gb +=
+			dwc_eth_mmc_read(pdata, MMC_TX128TO255OCTETS_GB_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_TISR, TX256TO511OCTETS_GB))
+		stats->tx256to511octets_gb +=
+			dwc_eth_mmc_read(pdata, MMC_TX256TO511OCTETS_GB_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_TISR, TX512TO1023OCTETS_GB))
+		stats->tx512to1023octets_gb +=
+			dwc_eth_mmc_read(pdata, MMC_TX512TO1023OCTETS_GB_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_TISR, TX1024TOMAXOCTETS_GB))
+		stats->tx1024tomaxoctets_gb +=
+			dwc_eth_mmc_read(pdata, MMC_TX1024TOMAXOCTETS_GB_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_TISR, TXUNICASTFRAMES_GB))
+		stats->txunicastframes_gb +=
+			dwc_eth_mmc_read(pdata, MMC_TXUNICASTFRAMES_GB_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_TISR, TXMULTICASTFRAMES_GB))
+		stats->txmulticastframes_gb +=
+			dwc_eth_mmc_read(pdata, MMC_TXMULTICASTFRAMES_GB_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_TISR, TXBROADCASTFRAMES_GB))
+		stats->txbroadcastframes_g +=
+			dwc_eth_mmc_read(pdata, MMC_TXBROADCASTFRAMES_GB_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_TISR, TXUNDERFLOWERROR))
+		stats->txunderflowerror +=
+			dwc_eth_mmc_read(pdata, MMC_TXUNDERFLOWERROR_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_TISR, TXOCTETCOUNT_G))
+		stats->txoctetcount_g +=
+			dwc_eth_mmc_read(pdata, MMC_TXOCTETCOUNT_G_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_TISR, TXFRAMECOUNT_G))
+		stats->txframecount_g +=
+			dwc_eth_mmc_read(pdata, MMC_TXFRAMECOUNT_G_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_TISR, TXPAUSEFRAMES))
+		stats->txpauseframes +=
+			dwc_eth_mmc_read(pdata, MMC_TXPAUSEFRAMES_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_TISR, TXVLANFRAMES_G))
+		stats->txvlanframes_g +=
+			dwc_eth_mmc_read(pdata, MMC_TXVLANFRAMES_G_LO);
+}
+
+static void dwc_eth_rx_mmc_int(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_stats *stats = &pdata->stats;
+	unsigned int mmc_isr = DWC_ETH_IOREAD(pdata, MMC_RISR);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_RISR, RXFRAMECOUNT_GB))
+		stats->rxframecount_gb +=
+			dwc_eth_mmc_read(pdata, MMC_RXFRAMECOUNT_GB_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_RISR, RXOCTETCOUNT_GB))
+		stats->rxoctetcount_gb +=
+			dwc_eth_mmc_read(pdata, MMC_RXOCTETCOUNT_GB_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_RISR, RXOCTETCOUNT_G))
+		stats->rxoctetcount_g +=
+			dwc_eth_mmc_read(pdata, MMC_RXOCTETCOUNT_G_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_RISR, RXBROADCASTFRAMES_G))
+		stats->rxbroadcastframes_g +=
+			dwc_eth_mmc_read(pdata, MMC_RXBROADCASTFRAMES_G_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_RISR, RXMULTICASTFRAMES_G))
+		stats->rxmulticastframes_g +=
+			dwc_eth_mmc_read(pdata, MMC_RXMULTICASTFRAMES_G_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_RISR, RXCRCERROR))
+		stats->rxcrcerror +=
+			dwc_eth_mmc_read(pdata, MMC_RXCRCERROR_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_RISR, RXRUNTERROR))
+		stats->rxrunterror +=
+			dwc_eth_mmc_read(pdata, MMC_RXRUNTERROR);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_RISR, RXJABBERERROR))
+		stats->rxjabbererror +=
+			dwc_eth_mmc_read(pdata, MMC_RXJABBERERROR);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_RISR, RXUNDERSIZE_G))
+		stats->rxundersize_g +=
+			dwc_eth_mmc_read(pdata, MMC_RXUNDERSIZE_G);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_RISR, RXOVERSIZE_G))
+		stats->rxoversize_g +=
+			dwc_eth_mmc_read(pdata, MMC_RXOVERSIZE_G);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_RISR, RX64OCTETS_GB))
+		stats->rx64octets_gb +=
+			dwc_eth_mmc_read(pdata, MMC_RX64OCTETS_GB_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_RISR, RX65TO127OCTETS_GB))
+		stats->rx65to127octets_gb +=
+			dwc_eth_mmc_read(pdata, MMC_RX65TO127OCTETS_GB_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_RISR, RX128TO255OCTETS_GB))
+		stats->rx128to255octets_gb +=
+			dwc_eth_mmc_read(pdata, MMC_RX128TO255OCTETS_GB_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_RISR, RX256TO511OCTETS_GB))
+		stats->rx256to511octets_gb +=
+			dwc_eth_mmc_read(pdata, MMC_RX256TO511OCTETS_GB_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_RISR, RX512TO1023OCTETS_GB))
+		stats->rx512to1023octets_gb +=
+			dwc_eth_mmc_read(pdata, MMC_RX512TO1023OCTETS_GB_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_RISR, RX1024TOMAXOCTETS_GB))
+		stats->rx1024tomaxoctets_gb +=
+			dwc_eth_mmc_read(pdata, MMC_RX1024TOMAXOCTETS_GB_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_RISR, RXUNICASTFRAMES_G))
+		stats->rxunicastframes_g +=
+			dwc_eth_mmc_read(pdata, MMC_RXUNICASTFRAMES_G_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_RISR, RXLENGTHERROR))
+		stats->rxlengtherror +=
+			dwc_eth_mmc_read(pdata, MMC_RXLENGTHERROR_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_RISR, RXOUTOFRANGETYPE))
+		stats->rxoutofrangetype +=
+			dwc_eth_mmc_read(pdata, MMC_RXOUTOFRANGETYPE_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_RISR, RXPAUSEFRAMES))
+		stats->rxpauseframes +=
+			dwc_eth_mmc_read(pdata, MMC_RXPAUSEFRAMES_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_RISR, RXFIFOOVERFLOW))
+		stats->rxfifooverflow +=
+			dwc_eth_mmc_read(pdata, MMC_RXFIFOOVERFLOW_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_RISR, RXVLANFRAMES_GB))
+		stats->rxvlanframes_gb +=
+			dwc_eth_mmc_read(pdata, MMC_RXVLANFRAMES_GB_LO);
+
+	if (DWC_ETH_GET_BITS(mmc_isr, MMC_RISR, RXWATCHDOGERROR))
+		stats->rxwatchdogerror +=
+			dwc_eth_mmc_read(pdata, MMC_RXWATCHDOGERROR);
+}
+
+static void dwc_eth_read_mmc_stats(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_stats *stats = &pdata->stats;
+
+	/* Freeze counters */
+	DWC_ETH_IOWRITE_BITS(pdata, MMC_CR, MCF, 1);
+
+	stats->txoctetcount_gb +=
+		dwc_eth_mmc_read(pdata, MMC_TXOCTETCOUNT_GB_LO);
+
+	stats->txframecount_gb +=
+		dwc_eth_mmc_read(pdata, MMC_TXFRAMECOUNT_GB_LO);
+
+	stats->txbroadcastframes_g +=
+		dwc_eth_mmc_read(pdata, MMC_TXBROADCASTFRAMES_G_LO);
+
+	stats->txmulticastframes_g +=
+		dwc_eth_mmc_read(pdata, MMC_TXMULTICASTFRAMES_G_LO);
+
+	stats->tx64octets_gb +=
+		dwc_eth_mmc_read(pdata, MMC_TX64OCTETS_GB_LO);
+
+	stats->tx65to127octets_gb +=
+		dwc_eth_mmc_read(pdata, MMC_TX65TO127OCTETS_GB_LO);
+
+	stats->tx128to255octets_gb +=
+		dwc_eth_mmc_read(pdata, MMC_TX128TO255OCTETS_GB_LO);
+
+	stats->tx256to511octets_gb +=
+		dwc_eth_mmc_read(pdata, MMC_TX256TO511OCTETS_GB_LO);
+
+	stats->tx512to1023octets_gb +=
+		dwc_eth_mmc_read(pdata, MMC_TX512TO1023OCTETS_GB_LO);
+
+	stats->tx1024tomaxoctets_gb +=
+		dwc_eth_mmc_read(pdata, MMC_TX1024TOMAXOCTETS_GB_LO);
+
+	stats->txunicastframes_gb +=
+		dwc_eth_mmc_read(pdata, MMC_TXUNICASTFRAMES_GB_LO);
+
+	stats->txmulticastframes_gb +=
+		dwc_eth_mmc_read(pdata, MMC_TXMULTICASTFRAMES_GB_LO);
+
+	stats->txbroadcastframes_g +=
+		dwc_eth_mmc_read(pdata, MMC_TXBROADCASTFRAMES_GB_LO);
+
+	stats->txunderflowerror +=
+		dwc_eth_mmc_read(pdata, MMC_TXUNDERFLOWERROR_LO);
+
+	stats->txoctetcount_g +=
+		dwc_eth_mmc_read(pdata, MMC_TXOCTETCOUNT_G_LO);
+
+	stats->txframecount_g +=
+		dwc_eth_mmc_read(pdata, MMC_TXFRAMECOUNT_G_LO);
+
+	stats->txpauseframes +=
+		dwc_eth_mmc_read(pdata, MMC_TXPAUSEFRAMES_LO);
+
+	stats->txvlanframes_g +=
+		dwc_eth_mmc_read(pdata, MMC_TXVLANFRAMES_G_LO);
+
+	stats->rxframecount_gb +=
+		dwc_eth_mmc_read(pdata, MMC_RXFRAMECOUNT_GB_LO);
+
+	stats->rxoctetcount_gb +=
+		dwc_eth_mmc_read(pdata, MMC_RXOCTETCOUNT_GB_LO);
+
+	stats->rxoctetcount_g +=
+		dwc_eth_mmc_read(pdata, MMC_RXOCTETCOUNT_G_LO);
+
+	stats->rxbroadcastframes_g +=
+		dwc_eth_mmc_read(pdata, MMC_RXBROADCASTFRAMES_G_LO);
+
+	stats->rxmulticastframes_g +=
+		dwc_eth_mmc_read(pdata, MMC_RXMULTICASTFRAMES_G_LO);
+
+	stats->rxcrcerror +=
+		dwc_eth_mmc_read(pdata, MMC_RXCRCERROR_LO);
+
+	stats->rxrunterror +=
+		dwc_eth_mmc_read(pdata, MMC_RXRUNTERROR);
+
+	stats->rxjabbererror +=
+		dwc_eth_mmc_read(pdata, MMC_RXJABBERERROR);
+
+	stats->rxundersize_g +=
+		dwc_eth_mmc_read(pdata, MMC_RXUNDERSIZE_G);
+
+	stats->rxoversize_g +=
+		dwc_eth_mmc_read(pdata, MMC_RXOVERSIZE_G);
+
+	stats->rx64octets_gb +=
+		dwc_eth_mmc_read(pdata, MMC_RX64OCTETS_GB_LO);
+
+	stats->rx65to127octets_gb +=
+		dwc_eth_mmc_read(pdata, MMC_RX65TO127OCTETS_GB_LO);
+
+	stats->rx128to255octets_gb +=
+		dwc_eth_mmc_read(pdata, MMC_RX128TO255OCTETS_GB_LO);
+
+	stats->rx256to511octets_gb +=
+		dwc_eth_mmc_read(pdata, MMC_RX256TO511OCTETS_GB_LO);
+
+	stats->rx512to1023octets_gb +=
+		dwc_eth_mmc_read(pdata, MMC_RX512TO1023OCTETS_GB_LO);
+
+	stats->rx1024tomaxoctets_gb +=
+		dwc_eth_mmc_read(pdata, MMC_RX1024TOMAXOCTETS_GB_LO);
+
+	stats->rxunicastframes_g +=
+		dwc_eth_mmc_read(pdata, MMC_RXUNICASTFRAMES_G_LO);
+
+	stats->rxlengtherror +=
+		dwc_eth_mmc_read(pdata, MMC_RXLENGTHERROR_LO);
+
+	stats->rxoutofrangetype +=
+		dwc_eth_mmc_read(pdata, MMC_RXOUTOFRANGETYPE_LO);
+
+	stats->rxpauseframes +=
+		dwc_eth_mmc_read(pdata, MMC_RXPAUSEFRAMES_LO);
+
+	stats->rxfifooverflow +=
+		dwc_eth_mmc_read(pdata, MMC_RXFIFOOVERFLOW_LO);
+
+	stats->rxvlanframes_gb +=
+		dwc_eth_mmc_read(pdata, MMC_RXVLANFRAMES_GB_LO);
+
+	stats->rxwatchdogerror +=
+		dwc_eth_mmc_read(pdata, MMC_RXWATCHDOGERROR);
+
+	/* Un-freeze counters */
+	DWC_ETH_IOWRITE_BITS(pdata, MMC_CR, MCF, 0);
+}
+
+static void dwc_eth_config_mmc(struct dwc_eth_pdata *pdata)
+{
+	/* Set counters to reset on read */
+	DWC_ETH_IOWRITE_BITS(pdata, MMC_CR, ROR, 1);
+
+	/* Reset the counters */
+	DWC_ETH_IOWRITE_BITS(pdata, MMC_CR, CR, 1);
+}
+
+static int dwc_eth_write_rss_reg(struct dwc_eth_pdata *pdata, unsigned int type,
+				 unsigned int index, unsigned int val)
+{
+	unsigned int wait;
+	int ret = 0;
+
+	mutex_lock(&pdata->rss_mutex);
+
+	if (DWC_ETH_IOREAD_BITS(pdata, MAC_RSSAR, OB)) {
+		ret = -EBUSY;
+		goto unlock;
+	}
+
+	DWC_ETH_IOWRITE(pdata, MAC_RSSDR, val);
+
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_RSSAR, RSSIA, index);
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_RSSAR, ADDRT, type);
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_RSSAR, CT, 0);
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_RSSAR, OB, 1);
+
+	wait = 1000;
+	while (wait--) {
+		if (!DWC_ETH_IOREAD_BITS(pdata, MAC_RSSAR, OB))
+			goto unlock;
+
+		usleep_range(1000, 1500);
+	}
+
+	ret = -EBUSY;
+
+unlock:
+	mutex_unlock(&pdata->rss_mutex);
+
+	return ret;
+}
+
+static int dwc_eth_write_rss_hash_key(struct dwc_eth_pdata *pdata)
+{
+	unsigned int key_regs = sizeof(pdata->rss_key) / sizeof(u32);
+	unsigned int *key = (unsigned int *)&pdata->rss_key;
+	int ret;
+
+	while (key_regs--) {
+		ret = dwc_eth_write_rss_reg(pdata, DWC_ETH_RSS_HASH_KEY_TYPE,
+					    key_regs, *key++);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int dwc_eth_write_rss_lookup_table(struct dwc_eth_pdata *pdata)
+{
+	unsigned int i;
+	int ret;
+
+	for (i = 0; i < ARRAY_SIZE(pdata->rss_table); i++) {
+		ret = dwc_eth_write_rss_reg(pdata,
+					    DWC_ETH_RSS_LOOKUP_TABLE_TYPE, i,
+					 pdata->rss_table[i]);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int dwc_eth_set_rss_hash_key(struct dwc_eth_pdata *pdata, const u8 *key)
+{
+	memcpy(pdata->rss_key, key, sizeof(pdata->rss_key));
+
+	return dwc_eth_write_rss_hash_key(pdata);
+}
+
+static int dwc_eth_set_rss_lookup_table(struct dwc_eth_pdata *pdata,
+					const u32 *table)
+{
+	unsigned int i;
+
+	for (i = 0; i < ARRAY_SIZE(pdata->rss_table); i++)
+		DWC_ETH_SET_BITS(pdata->rss_table[i], MAC_RSSDR,
+				 DMCH, table[i]);
+
+	return dwc_eth_write_rss_lookup_table(pdata);
+}
+
+static int dwc_eth_enable_rss(struct dwc_eth_pdata *pdata)
+{
+	int ret;
+
+	if (!pdata->hw_feat.rss)
+		return -EOPNOTSUPP;
+
+	/* Program the hash key */
+	ret = dwc_eth_write_rss_hash_key(pdata);
+	if (ret)
+		return ret;
+
+	/* Program the lookup table */
+	ret = dwc_eth_write_rss_lookup_table(pdata);
+	if (ret)
+		return ret;
+
+	/* Set the RSS options */
+	DWC_ETH_IOWRITE(pdata, MAC_RSSCR, pdata->rss_options);
+
+	/* Enable RSS */
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_RSSCR, RSSE, 1);
+
+	return 0;
+}
+
+static int dwc_eth_disable_rss(struct dwc_eth_pdata *pdata)
+{
+	if (!pdata->hw_feat.rss)
+		return -EOPNOTSUPP;
+
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_RSSCR, RSSE, 0);
+
+	return 0;
+}
+
+static void dwc_eth_config_rss(struct dwc_eth_pdata *pdata)
+{
+	int ret;
+
+	if (!pdata->hw_feat.rss)
+		return;
+
+	if (pdata->netdev->features & NETIF_F_RXHASH)
+		ret = dwc_eth_enable_rss(pdata);
+	else
+		ret = dwc_eth_disable_rss(pdata);
+
+	if (ret)
+		netdev_err(pdata->netdev,
+			   "error configuring RSS, RSS disabled\n");
+}
+
+static void dwc_eth_enable_dma_interrupts(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int dma_ch_isr, dma_ch_ier;
+	unsigned int i;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		/* Clear all the interrupts which are set */
+		dma_ch_isr = DWC_ETH_DMA_IOREAD(channel, DMA_CH_SR);
+		DWC_ETH_DMA_IOWRITE(channel, DMA_CH_SR, dma_ch_isr);
+
+		/* Clear all interrupt enable bits */
+		dma_ch_ier = 0;
+
+		/* Enable following interrupts
+		 *   NIE  - Normal Interrupt Summary Enable
+		 *   AIE  - Abnormal Interrupt Summary Enable
+		 *   FBEE - Fatal Bus Error Enable
+		 */
+		DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER, NIE, 1);
+		DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER, AIE, 1);
+		DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER, FBEE, 1);
+
+		if (channel->tx_ring) {
+			/* Enable the following Tx interrupts
+			 *   TIE  - Transmit Interrupt Enable (unless using
+			 *          per channel interrupts)
+			 */
+			if (!pdata->per_channel_irq)
+				DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER,
+						 TIE, 1);
+		}
+		if (channel->rx_ring) {
+			/* Enable following Rx interrupts
+			 *   RBUE - Receive Buffer Unavailable Enable
+			 *   RIE  - Receive Interrupt Enable (unless using
+			 *          per channel interrupts)
+			 */
+			DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER, RBUE, 1);
+			if (!pdata->per_channel_irq)
+				DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER,
+						 RIE, 1);
+		}
+
+		DWC_ETH_DMA_IOWRITE(channel, DMA_CH_IER, dma_ch_ier);
+	}
+}
+
+static void dwc_eth_enable_mtl_interrupts(struct dwc_eth_pdata *pdata)
+{
+	unsigned int mtl_q_isr;
+	unsigned int q_count, i;
+
+	q_count = max(pdata->hw_feat.tx_q_cnt, pdata->hw_feat.rx_q_cnt);
+	for (i = 0; i < q_count; i++) {
+		/* Clear all the interrupts which are set */
+		mtl_q_isr = DWC_ETH_MTL_IOREAD(pdata, i, MTL_Q_ISR);
+		DWC_ETH_MTL_IOWRITE(pdata, i, MTL_Q_ISR, mtl_q_isr);
+
+		/* No MTL interrupts to be enabled */
+		DWC_ETH_MTL_IOWRITE(pdata, i, MTL_Q_IER, 0);
+	}
+}
+
+static void dwc_eth_enable_mac_interrupts(struct dwc_eth_pdata *pdata)
+{
+	unsigned int mac_ier = 0;
+
+	/* Enable Timestamp interrupt */
+	DWC_ETH_SET_BITS(mac_ier, MAC_IER, TSIE, 1);
+
+	DWC_ETH_IOWRITE(pdata, MAC_IER, mac_ier);
+
+	/* Enable all counter interrupts */
+	DWC_ETH_IOWRITE_BITS(pdata, MMC_RIER, ALL_INTERRUPTS, 0xffffffff);
+	DWC_ETH_IOWRITE_BITS(pdata, MMC_TIER, ALL_INTERRUPTS, 0xffffffff);
+}
+
+static int dwc_eth_set_gmii_1000_speed(struct dwc_eth_pdata *pdata)
+{
+	if (pdata->hw2_ops->set_gmii_1000_speed)
+		return pdata->hw2_ops->set_gmii_1000_speed(pdata);
+
+	TRACE("-->");
+
+	if (DWC_ETH_IOREAD_BITS(pdata, MAC_TCR, SS) == 0x7)
+		return 0;
+
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_TCR, SS, 0x7);
+
+	TRACE("<--");
+
+	return 0;
+}
+
+static int dwc_eth_set_gmii_2500_speed(struct dwc_eth_pdata *pdata)
+{
+	if (pdata->hw2_ops->set_gmii_2500_speed)
+		return pdata->hw2_ops->set_gmii_2500_speed(pdata);
+
+	TRACE("-->");
+
+	if (DWC_ETH_IOREAD_BITS(pdata, MAC_TCR, SS) == 0x6)
+		return 0;
+
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_TCR, SS, 0x6);
+
+	TRACE("<--");
+
+	return 0;
+}
+
+static int dwc_eth_set_xgmii_10000_speed(struct dwc_eth_pdata *pdata)
+{
+	if (pdata->hw2_ops->set_xgmii_10000_speed)
+		return pdata->hw2_ops->set_xgmii_10000_speed(pdata);
+
+	TRACE("-->");
+
+	if (DWC_ETH_IOREAD_BITS(pdata, MAC_TCR, SS) == 0x4)
+		return 0;
+
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_TCR, SS, 0x4);
+
+	TRACE("<--");
+
+	return 0;
+}
+
+static int dwc_eth_set_xlgmii_25000_speed(struct dwc_eth_pdata *pdata)
+{
+	if (DWC_ETH_IOREAD_BITS(pdata, MAC_TCR, SS) == 0x1)
+		return 0;
+
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_TCR, SS, 0x1);
+
+	return 0;
+}
+
+static int dwc_eth_set_xlgmii_40000_speed(struct dwc_eth_pdata *pdata)
+{
+	if (DWC_ETH_IOREAD_BITS(pdata, MAC_TCR, SS) == 0)
+		return 0;
+
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_TCR, SS, 0);
+
+	return 0;
+}
+
+static int dwc_eth_set_xlgmii_50000_speed(struct dwc_eth_pdata *pdata)
+{
+	if (DWC_ETH_IOREAD_BITS(pdata, MAC_TCR, SS) == 0x2)
+		return 0;
+
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_TCR, SS, 0x2);
+
+	return 0;
+}
+
+static int dwc_eth_set_xlgmii_100000_speed(struct dwc_eth_pdata *pdata)
+{
+	if (DWC_ETH_IOREAD_BITS(pdata, MAC_TCR, SS) == 0x3)
+		return 0;
+
+	DWC_ETH_IOWRITE_BITS(pdata, MAC_TCR, SS, 0x3);
+
+	return 0;
+}
+
+static void dwc_eth_config_mac_speed(struct dwc_eth_pdata *pdata)
+{
+	TRACE("-->");
+
+	switch (pdata->phy_speed) {
+	case SPEED_100000:
+		dwc_eth_set_xlgmii_100000_speed(pdata);
+		break;
+
+	case SPEED_50000:
+		dwc_eth_set_xlgmii_50000_speed(pdata);
+		break;
+
+	case SPEED_40000:
+		dwc_eth_set_xlgmii_40000_speed(pdata);
+		break;
+
+	case SPEED_25000:
+		dwc_eth_set_xlgmii_25000_speed(pdata);
+		break;
+
+	case SPEED_10000:
+		dwc_eth_set_xgmii_10000_speed(pdata);
+		break;
+
+	case SPEED_2500:
+		dwc_eth_set_gmii_2500_speed(pdata);
+		break;
+
+	case SPEED_1000:
+		dwc_eth_set_gmii_1000_speed(pdata);
+		break;
+	}
+
+	TRACE("<--");
+}
+
+static int dwc_eth_mdio_wait_until_free(struct dwc_eth_pdata *pdata)
+{
+	unsigned int timeout;
+
+	/* Wait till the bus is free */
+	timeout = DWC_ETH_MDIO_RD_TIMEOUT;
+	while (DWC_ETH_IOREAD_BITS(pdata, MAC_MDIOSCCDR, BUSY) && timeout) {
+		cpu_relax();
+		timeout--;
+	}
+
+	if (!timeout) {
+		dev_err(pdata->dev, "timeout waiting for bus to be free\n");
+		return -ETIMEDOUT;
+	}
+
+	return 0;
+}
+
+static int dwc_eth_read_mmd_regs(struct dwc_eth_pdata *pdata,
+				 int prtad, int mmd_reg)
+{
+	int mmd_data;
+	int ret;
+	unsigned int scar;
+	unsigned int sccdr = 0;
+
+	if (pdata->hw2_ops->read_mmd_regs)
+		return pdata->hw2_ops->read_mmd_regs(pdata,
+						prtad, mmd_reg);
+
+	TRACE("-->");
+
+	mutex_lock(&pdata->pcs_mutex);
+
+	ret = dwc_eth_mdio_wait_until_free(pdata);
+	if (ret)
+		return ret;
+
+	/* Updating desired bits for read operation */
+	scar = DWC_ETH_IOREAD(pdata, MAC_MDIOSCAR);
+	scar = scar & (0x3e00000UL);
+	scar = scar | ((prtad) << MAC_MDIOSCAR_PA_POS) |
+		((mmd_reg) << MAC_MDIOSCAR_RA_POS);
+	DWC_ETH_IOWRITE(pdata, MAC_MDIOSCAR, scar);
+
+	/* Initiate the read */
+	sccdr = sccdr | ((0x1) << MAC_MDIOSCCDR_BUSY_POS) |
+		((0x5) << MAC_MDIOSCCDR_CR_POS) |
+		((0x1) << MAC_MDIOSCCDR_SADDR_POS) |
+		((0x3) << MAC_MDIOSCCDR_CMD_POS);
+	DWC_ETH_IOWRITE(pdata, MAC_MDIOSCCDR, sccdr);
+
+	ret = dwc_eth_mdio_wait_until_free(pdata);
+	if (ret)
+		return ret;
+
+	/* Read the data */
+	mmd_data = DWC_ETH_IOREAD_BITS(pdata, MAC_MDIOSCCDR, SDATA);
+
+	mutex_unlock(&pdata->pcs_mutex);
+
+	TRACE("<--");
+
+	return mmd_data;
+}
+
+static int dwc_eth_write_mmd_regs(struct dwc_eth_pdata *pdata,
+				  int prtad, int mmd_reg, int mmd_data)
+{
+	int ret;
+	unsigned int scar;
+	unsigned int sccdr = 0;
+
+	if (pdata->hw2_ops->write_mmd_regs)
+		return pdata->hw2_ops->write_mmd_regs(pdata,
+						      prtad,
+						      mmd_reg,
+						      mmd_data);
+
+	TRACE("-->");
+
+	mutex_lock(&pdata->pcs_mutex);
+
+	ret = dwc_eth_mdio_wait_until_free(pdata);
+	if (ret)
+		return ret;
+
+	/* Updating desired bits for write operation */
+	scar = DWC_ETH_IOREAD(pdata, MAC_MDIOSCAR);
+	scar = scar & (0x3e00000UL);
+	scar = scar | ((prtad) << MAC_MDIOSCAR_PA_POS) |
+		((mmd_reg) << MAC_MDIOSCAR_RA_POS);
+	DWC_ETH_IOWRITE(pdata, MAC_MDIOSCAR, scar);
+
+	/* Initiate Write */
+	sccdr = sccdr | ((0x1) << MAC_MDIOSCCDR_BUSY_POS) |
+		((0x5) << MAC_MDIOSCCDR_CR_POS) |
+		((0x1) << MAC_MDIOSCCDR_SADDR_POS) |
+		((0x1) << MAC_MDIOSCCDR_CMD_POS) |
+		((mmd_data) << MAC_MDIOSCCDR_SDATA_POS);
+	DWC_ETH_IOWRITE(pdata, MAC_MDIOSCCDR, sccdr);
+
+	ret = dwc_eth_mdio_wait_until_free(pdata);
+	if (ret)
+		return ret;
+
+	mutex_unlock(&pdata->pcs_mutex);
+
+	TRACE("<--");
+
+	return 0;
+}
+
+static int dwc_eth_dev_read(struct dwc_eth_channel *channel)
+{
+	struct dwc_eth_pdata *pdata = channel->pdata;
+	struct dwc_eth_ring *ring = channel->rx_ring;
+	struct dwc_eth_desc_data *desc_data;
+	struct dwc_eth_dma_desc *dma_desc;
+	struct dwc_eth_pkt_info *pkt_info = &ring->pkt_info;
+	struct net_device *netdev = pdata->netdev;
+	unsigned int err, etlt, l34t;
+
+	TRACE("-->");
+	DBGPR("  cur = %d\n", ring->cur);
+
+	desc_data = DWC_ETH_GET_DESC_DATA(ring, ring->cur);
+	dma_desc = desc_data->dma_desc;
+
+	/* Check for data availability */
+	if (DWC_ETH_GET_BITS_LE(dma_desc->desc3, RX_NORMAL_DESC3, OWN))
+		return 1;
+
+	/* Make sure descriptor fields are read after reading the OWN bit */
+	dma_rmb();
+
+	if (netif_msg_rx_status(pdata))
+		dwc_eth_dump_rx_desc(pdata, ring, ring->cur);
+
+	if (DWC_ETH_GET_BITS_LE(dma_desc->desc3, RX_NORMAL_DESC3, CTXT)) {
+		/* Timestamp Context Descriptor */
+		dwc_eth_get_rx_tstamp(pkt_info, dma_desc);
+
+		DWC_ETH_SET_BITS(pkt_info->attributes, RX_PACKET_ATTRIBUTES,
+				 CONTEXT, 1);
+		DWC_ETH_SET_BITS(pkt_info->attributes, RX_PACKET_ATTRIBUTES,
+				 CONTEXT_NEXT, 0);
+		return 0;
+	}
+
+	/* Normal Descriptor, be sure Context Descriptor bit is off */
+	DWC_ETH_SET_BITS(pkt_info->attributes, RX_PACKET_ATTRIBUTES,
+			 CONTEXT, 0);
+
+	/* Indicate if a Context Descriptor is next */
+	if (DWC_ETH_GET_BITS_LE(dma_desc->desc3, RX_NORMAL_DESC3, CDA))
+		DWC_ETH_SET_BITS(pkt_info->attributes, RX_PACKET_ATTRIBUTES,
+				 CONTEXT_NEXT, 1);
+
+	/* Get the header length */
+	if (DWC_ETH_GET_BITS_LE(dma_desc->desc3, RX_NORMAL_DESC3, FD)) {
+		desc_data->rx.hdr_len = DWC_ETH_GET_BITS_LE(dma_desc->desc2,
+							RX_NORMAL_DESC2, HL);
+		if (desc_data->rx.hdr_len)
+			pdata->stats.rx_split_header_packets++;
+	}
+
+	/* Get the RSS hash */
+	if (DWC_ETH_GET_BITS_LE(dma_desc->desc3, RX_NORMAL_DESC3, RSV)) {
+		DWC_ETH_SET_BITS(pkt_info->attributes, RX_PACKET_ATTRIBUTES,
+				 RSS_HASH, 1);
+
+		pkt_info->rss_hash = le32_to_cpu(dma_desc->desc1);
+
+		l34t = DWC_ETH_GET_BITS_LE(dma_desc->desc3,
+					   RX_NORMAL_DESC3, L34T);
+		switch (l34t) {
+		case RX_DESC3_L34T_IPV4_TCP:
+		case RX_DESC3_L34T_IPV4_UDP:
+		case RX_DESC3_L34T_IPV6_TCP:
+		case RX_DESC3_L34T_IPV6_UDP:
+			pkt_info->rss_hash_type = PKT_HASH_TYPE_L4;
+			break;
+		default:
+			pkt_info->rss_hash_type = PKT_HASH_TYPE_L3;
+		}
+	}
+
+	/* Get the pkt_info length */
+	desc_data->rx.len = DWC_ETH_GET_BITS_LE(dma_desc->desc3,
+					RX_NORMAL_DESC3, PL);
+
+	if (!DWC_ETH_GET_BITS_LE(dma_desc->desc3, RX_NORMAL_DESC3, LD)) {
+		/* Not all the data has been transferred for this pkt_info */
+		DWC_ETH_SET_BITS(pkt_info->attributes, RX_PACKET_ATTRIBUTES,
+				 INCOMPLETE, 1);
+		return 0;
+	}
+
+	/* This is the last of the data for this pkt_info */
+	DWC_ETH_SET_BITS(pkt_info->attributes, RX_PACKET_ATTRIBUTES,
+			 INCOMPLETE, 0);
+
+	/* Set checksum done indicator as appropriate */
+	if (netdev->features & NETIF_F_RXCSUM)
+		DWC_ETH_SET_BITS(pkt_info->attributes, RX_PACKET_ATTRIBUTES,
+				 CSUM_DONE, 1);
+
+	/* Check for errors (only valid in last descriptor) */
+	err = DWC_ETH_GET_BITS_LE(dma_desc->desc3, RX_NORMAL_DESC3, ES);
+	etlt = DWC_ETH_GET_BITS_LE(dma_desc->desc3, RX_NORMAL_DESC3, ETLT);
+	netif_dbg(pdata, rx_status, netdev, "err=%u, etlt=%#x\n", err, etlt);
+
+	if (!err || !etlt) {
+		/* No error if err is 0 or etlt is 0 */
+		if ((etlt == 0x09) &&
+		    (netdev->features & NETIF_F_HW_VLAN_CTAG_RX)) {
+			DWC_ETH_SET_BITS(pkt_info->attributes,
+					 RX_PACKET_ATTRIBUTES,
+					VLAN_CTAG, 1);
+			pkt_info->vlan_ctag =
+				DWC_ETH_GET_BITS_LE(dma_desc->desc0,
+						    RX_NORMAL_DESC0, OVT);
+			netif_dbg(pdata, rx_status, netdev, "vlan-ctag=%#06x\n",
+				  pkt_info->vlan_ctag);
+		}
+	} else {
+		if ((etlt == 0x05) || (etlt == 0x06))
+			DWC_ETH_SET_BITS(pkt_info->attributes,
+					 RX_PACKET_ATTRIBUTES,
+					CSUM_DONE, 0);
+		else
+			DWC_ETH_SET_BITS(pkt_info->errors, RX_PACKET_ERRORS,
+					 FRAME, 1);
+	}
+
+	DBGPR("  %s - descriptor=%u (cur=%d)\n", channel->name,
+	      ring->cur & (ring->dma_desc_count - 1), ring->cur);
+	TRACE("<--");
+
+	return 0;
+}
+
+static int dwc_eth_enable_int(struct dwc_eth_channel *channel,
+			      enum dwc_eth_int int_id)
+{
+	unsigned int dma_ch_ier;
+
+	dma_ch_ier = DWC_ETH_DMA_IOREAD(channel, DMA_CH_IER);
+
+	switch (int_id) {
+	case DWC_ETH_INT_DMA_CH_SR_TI:
+		DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER, TIE, 1);
+		break;
+	case DWC_ETH_INT_DMA_CH_SR_TPS:
+		DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER, TXSE, 1);
+		break;
+	case DWC_ETH_INT_DMA_CH_SR_TBU:
+		DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER, TBUE, 1);
+		break;
+	case DWC_ETH_INT_DMA_CH_SR_RI:
+		DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER, RIE, 1);
+		break;
+	case DWC_ETH_INT_DMA_CH_SR_RBU:
+		DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER, RBUE, 1);
+		break;
+	case DWC_ETH_INT_DMA_CH_SR_RPS:
+		DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER, RSE, 1);
+		break;
+	case DWC_ETH_INT_DMA_CH_SR_TI_RI:
+		DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER, TIE, 1);
+		DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER, RIE, 1);
+		break;
+	case DWC_ETH_INT_DMA_CH_SR_FBE:
+		DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER, FBEE, 1);
+		break;
+	case DWC_ETH_INT_DMA_ALL:
+		dma_ch_ier |= channel->saved_ier;
+		break;
+	default:
+		return -1;
+	}
+
+	DWC_ETH_DMA_IOWRITE(channel, DMA_CH_IER, dma_ch_ier);
+
+	return 0;
+}
+
+static int dwc_eth_disable_int(struct dwc_eth_channel *channel,
+			       enum dwc_eth_int int_id)
+{
+	unsigned int dma_ch_ier;
+
+	dma_ch_ier = DWC_ETH_DMA_IOREAD(channel, DMA_CH_IER);
+
+	switch (int_id) {
+	case DWC_ETH_INT_DMA_CH_SR_TI:
+		DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER, TIE, 0);
+		break;
+	case DWC_ETH_INT_DMA_CH_SR_TPS:
+		DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER, TXSE, 0);
+		break;
+	case DWC_ETH_INT_DMA_CH_SR_TBU:
+		DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER, TBUE, 0);
+		break;
+	case DWC_ETH_INT_DMA_CH_SR_RI:
+		DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER, RIE, 0);
+		break;
+	case DWC_ETH_INT_DMA_CH_SR_RBU:
+		DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER, RBUE, 0);
+		break;
+	case DWC_ETH_INT_DMA_CH_SR_RPS:
+		DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER, RSE, 0);
+		break;
+	case DWC_ETH_INT_DMA_CH_SR_TI_RI:
+		DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER, TIE, 0);
+		DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER, RIE, 0);
+		break;
+	case DWC_ETH_INT_DMA_CH_SR_FBE:
+		DWC_ETH_SET_BITS(dma_ch_ier, DMA_CH_IER, FBEE, 0);
+		break;
+	case DWC_ETH_INT_DMA_ALL:
+		channel->saved_ier = dma_ch_ier & DWC_ETH_DMA_INTERRUPT_MASK;
+		dma_ch_ier &= ~DWC_ETH_DMA_INTERRUPT_MASK;
+		break;
+	default:
+		return -1;
+	}
+
+	DWC_ETH_DMA_IOWRITE(channel, DMA_CH_IER, dma_ch_ier);
+
+	return 0;
+}
+
+static int dwc_eth_flush_tx_queues(struct dwc_eth_pdata *pdata)
+{
+	unsigned int i, count;
+
+	if (DWC_ETH_GET_BITS(pdata->hw_feat.version, MAC_VR, SNPSVER) < 0x21)
+		return 0;
+
+	for (i = 0; i < pdata->tx_q_count; i++)
+		DWC_ETH_MTL_IOWRITE_BITS(pdata, i, MTL_Q_TQOMR, FTQ, 1);
+
+	/* Poll Until Poll Condition */
+	for (i = 0; i < pdata->tx_q_count; i++) {
+		count = 2000;
+		while (--count && DWC_ETH_MTL_IOREAD_BITS(pdata, i,
+							  MTL_Q_TQOMR, FTQ))
+			usleep_range(500, 600);
+
+		if (!count)
+			return -EBUSY;
+	}
+
+	return 0;
+}
+
+static void dwc_eth_config_dma_bus(struct dwc_eth_pdata *pdata)
+{
+	/* Set enhanced addressing mode */
+	DWC_ETH_IOWRITE_BITS(pdata, DMA_SBMR, EAME, 1);
+
+	/* Set the System Bus mode */
+	DWC_ETH_IOWRITE_BITS(pdata, DMA_SBMR, UNDEF, 1);
+	DWC_ETH_IOWRITE_BITS(pdata, DMA_SBMR, BLEN_256, 1);
+}
+
+static void dwc_eth_config_dma_cache(struct dwc_eth_pdata *pdata)
+{
+	unsigned int arcache, awcache;
+
+	arcache = 0;
+	DWC_ETH_SET_BITS(arcache, DMA_AXIARCR, DRC, pdata->arcache);
+	DWC_ETH_SET_BITS(arcache, DMA_AXIARCR, DRD, pdata->axdomain);
+	DWC_ETH_SET_BITS(arcache, DMA_AXIARCR, TEC, pdata->arcache);
+	DWC_ETH_SET_BITS(arcache, DMA_AXIARCR, TED, pdata->axdomain);
+	DWC_ETH_SET_BITS(arcache, DMA_AXIARCR, THC, pdata->arcache);
+	DWC_ETH_SET_BITS(arcache, DMA_AXIARCR, THD, pdata->axdomain);
+	DWC_ETH_IOWRITE(pdata, DMA_AXIARCR, arcache);
+
+	awcache = 0;
+	DWC_ETH_SET_BITS(awcache, DMA_AXIAWCR, DWC, pdata->awcache);
+	DWC_ETH_SET_BITS(awcache, DMA_AXIAWCR, DWD, pdata->axdomain);
+	DWC_ETH_SET_BITS(awcache, DMA_AXIAWCR, RPC, pdata->awcache);
+	DWC_ETH_SET_BITS(awcache, DMA_AXIAWCR, RPD, pdata->axdomain);
+	DWC_ETH_SET_BITS(awcache, DMA_AXIAWCR, RHC, pdata->awcache);
+	DWC_ETH_SET_BITS(awcache, DMA_AXIAWCR, RHD, pdata->axdomain);
+	DWC_ETH_SET_BITS(awcache, DMA_AXIAWCR, TDC, pdata->awcache);
+	DWC_ETH_SET_BITS(awcache, DMA_AXIAWCR, TDD, pdata->axdomain);
+	DWC_ETH_IOWRITE(pdata, DMA_AXIAWCR, awcache);
+}
+
+static int dwc_eth_init(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_desc_ops *desc_ops = &pdata->desc_ops;
+	int ret;
+
+	TRACE("-->");
+
+	/* Flush Tx queues */
+	ret = dwc_eth_flush_tx_queues(pdata);
+	if (ret)
+		return ret;
+
+	/* Initialize DMA related features */
+	dwc_eth_config_dma_bus(pdata);
+	dwc_eth_config_dma_cache(pdata);
+	dwc_eth_config_osp_mode(pdata);
+	dwc_eth_config_pblx8(pdata);
+	dwc_eth_config_tx_pbl_val(pdata);
+	dwc_eth_config_rx_pbl_val(pdata);
+	dwc_eth_config_rx_coalesce(pdata);
+	dwc_eth_config_tx_coalesce(pdata);
+	dwc_eth_config_rx_buffer_size(pdata);
+	dwc_eth_config_tso_mode(pdata);
+	dwc_eth_config_sph_mode(pdata);
+	dwc_eth_config_rss(pdata);
+	desc_ops->tx_desc_init(pdata);
+	desc_ops->rx_desc_init(pdata);
+	dwc_eth_enable_dma_interrupts(pdata);
+
+	/* Initialize MTL related features */
+	dwc_eth_config_mtl_mode(pdata);
+	dwc_eth_config_queue_mapping(pdata);
+	dwc_eth_config_tsf_mode(pdata, pdata->tx_sf_mode);
+	dwc_eth_config_rsf_mode(pdata, pdata->rx_sf_mode);
+	dwc_eth_config_tx_threshold(pdata, pdata->tx_threshold);
+	dwc_eth_config_rx_threshold(pdata, pdata->rx_threshold);
+	dwc_eth_config_tx_fifo_size(pdata);
+	dwc_eth_config_rx_fifo_size(pdata);
+	dwc_eth_config_flow_control_threshold(pdata);
+	dwc_eth_config_rx_fep_enable(pdata);
+	dwc_eth_config_rx_fup_enable(pdata);
+	dwc_eth_config_dcb_tc(pdata);
+	dwc_eth_config_dcb_pfc(pdata);
+	dwc_eth_enable_mtl_interrupts(pdata);
+
+	/* Initialize MAC related features */
+	dwc_eth_config_mac_address(pdata);
+	dwc_eth_config_rx_mode(pdata);
+	dwc_eth_config_jumbo_enable(pdata);
+	dwc_eth_config_flow_control(pdata);
+	dwc_eth_config_mac_speed(pdata);
+	dwc_eth_config_checksum_offload(pdata);
+	dwc_eth_config_vlan_support(pdata);
+	dwc_eth_config_mmc(pdata);
+	dwc_eth_enable_mac_interrupts(pdata);
+
+	TRACE("<--");
+
+	return 0;
+}
+
+static int dwc_eth_exit(struct dwc_eth_pdata *pdata)
+{
+	unsigned int count = 2000;
+
+	TRACE("-->");
+
+	/* Issue a software reset */
+	DWC_ETH_IOWRITE_BITS(pdata, DMA_MR, SWR, 1);
+	usleep_range(10, 15);
+
+	/* Poll Until Poll Condition */
+	while (--count && DWC_ETH_IOREAD_BITS(pdata, DMA_MR, SWR))
+		usleep_range(500, 600);
+
+	if (!count)
+		return -EBUSY;
+
+	TRACE("<--");
+
+	return 0;
+}
+
+void dwc_eth_init_hw_ops(struct dwc_eth_hw_ops *hw_ops)
+{
+	TRACE("-->");
+
+	hw_ops->tx_complete = dwc_eth_tx_complete;
+
+	hw_ops->set_mac_address = dwc_eth_set_mac_address;
+	hw_ops->config_rx_mode = dwc_eth_config_rx_mode;
+
+	hw_ops->enable_rx_csum = dwc_eth_enable_rx_csum;
+	hw_ops->disable_rx_csum = dwc_eth_disable_rx_csum;
+
+	hw_ops->enable_rx_vlan_stripping = dwc_eth_enable_rx_vlan_stripping;
+	hw_ops->disable_rx_vlan_stripping = dwc_eth_disable_rx_vlan_stripping;
+	hw_ops->enable_rx_vlan_filtering = dwc_eth_enable_rx_vlan_filtering;
+	hw_ops->disable_rx_vlan_filtering = dwc_eth_disable_rx_vlan_filtering;
+	hw_ops->update_vlan_hash_table = dwc_eth_update_vlan_hash_table;
+
+	hw_ops->read_mmd_regs = dwc_eth_read_mmd_regs;
+	hw_ops->write_mmd_regs = dwc_eth_write_mmd_regs;
+
+	hw_ops->set_gmii_1000_speed = dwc_eth_set_gmii_1000_speed;
+	hw_ops->set_gmii_2500_speed = dwc_eth_set_gmii_2500_speed;
+	hw_ops->set_xgmii_10000_speed = dwc_eth_set_xgmii_10000_speed;
+	hw_ops->set_xlgmii_25000_speed = dwc_eth_set_xlgmii_25000_speed;
+	hw_ops->set_xlgmii_40000_speed = dwc_eth_set_xlgmii_40000_speed;
+	hw_ops->set_xlgmii_50000_speed = dwc_eth_set_xlgmii_50000_speed;
+	hw_ops->set_xlgmii_100000_speed = dwc_eth_set_xlgmii_100000_speed;
+
+	hw_ops->enable_tx = dwc_eth_enable_tx;
+	hw_ops->disable_tx = dwc_eth_disable_tx;
+	hw_ops->enable_rx = dwc_eth_enable_rx;
+	hw_ops->disable_rx = dwc_eth_disable_rx;
+
+	hw_ops->powerup_tx = dwc_eth_powerup_tx;
+	hw_ops->powerdown_tx = dwc_eth_powerdown_tx;
+	hw_ops->powerup_rx = dwc_eth_powerup_rx;
+	hw_ops->powerdown_rx = dwc_eth_powerdown_rx;
+
+	hw_ops->dev_xmit = dwc_eth_dev_xmit;
+	hw_ops->dev_read = dwc_eth_dev_read;
+	hw_ops->enable_int = dwc_eth_enable_int;
+	hw_ops->disable_int = dwc_eth_disable_int;
+
+	hw_ops->init = dwc_eth_init;
+	hw_ops->exit = dwc_eth_exit;
+
+	/* Descriptor related Sequences have to be initialized here */
+	hw_ops->tx_desc_init = dwc_eth_tx_desc_init;
+	hw_ops->rx_desc_init = dwc_eth_rx_desc_init;
+	hw_ops->tx_desc_reset = dwc_eth_tx_desc_reset;
+	hw_ops->rx_desc_reset = dwc_eth_rx_desc_reset;
+	hw_ops->is_last_desc = dwc_eth_is_last_desc;
+	hw_ops->is_context_desc = dwc_eth_is_context_desc;
+	hw_ops->tx_start_xmit = dwc_eth_tx_start_xmit;
+
+	/* For FLOW ctrl */
+	hw_ops->config_tx_flow_control = dwc_eth_config_tx_flow_control;
+	hw_ops->config_rx_flow_control = dwc_eth_config_rx_flow_control;
+
+	/* For RX coalescing */
+	hw_ops->config_rx_coalesce = dwc_eth_config_rx_coalesce;
+	hw_ops->config_tx_coalesce = dwc_eth_config_tx_coalesce;
+	hw_ops->usec_to_riwt = dwc_eth_usec_to_riwt;
+	hw_ops->riwt_to_usec = dwc_eth_riwt_to_usec;
+
+	/* For RX and TX threshold config */
+	hw_ops->config_rx_threshold = dwc_eth_config_rx_threshold;
+	hw_ops->config_tx_threshold = dwc_eth_config_tx_threshold;
+
+	/* For RX and TX Store and Forward Mode config */
+	hw_ops->config_rsf_mode = dwc_eth_config_rsf_mode;
+	hw_ops->config_tsf_mode = dwc_eth_config_tsf_mode;
+
+	/* For TX DMA Operating on Second Frame config */
+	hw_ops->config_osp_mode = dwc_eth_config_osp_mode;
+
+	/* For RX and TX PBL config */
+	hw_ops->config_rx_pbl_val = dwc_eth_config_rx_pbl_val;
+	hw_ops->get_rx_pbl_val = dwc_eth_get_rx_pbl_val;
+	hw_ops->config_tx_pbl_val = dwc_eth_config_tx_pbl_val;
+	hw_ops->get_tx_pbl_val = dwc_eth_get_tx_pbl_val;
+	hw_ops->config_pblx8 = dwc_eth_config_pblx8;
+
+	/* For MMC statistics support */
+	hw_ops->tx_mmc_int = dwc_eth_tx_mmc_int;
+	hw_ops->rx_mmc_int = dwc_eth_rx_mmc_int;
+	hw_ops->read_mmc_stats = dwc_eth_read_mmc_stats;
+
+	/* For PTP config */
+	hw_ops->config_tstamp = dwc_eth_config_tstamp;
+	hw_ops->update_tstamp_addend = dwc_eth_update_tstamp_addend;
+	hw_ops->set_tstamp_time = dwc_eth_set_tstamp_time;
+	hw_ops->get_tstamp_time = dwc_eth_get_tstamp_time;
+	hw_ops->get_tx_tstamp = dwc_eth_get_tx_tstamp;
+
+	/* For Data Center Bridging config */
+	hw_ops->config_tc = dwc_eth_config_tc;
+	hw_ops->config_dcb_tc = dwc_eth_config_dcb_tc;
+	hw_ops->config_dcb_pfc = dwc_eth_config_dcb_pfc;
+
+	/* For Receive Side Scaling */
+	hw_ops->enable_rss = dwc_eth_enable_rss;
+	hw_ops->disable_rss = dwc_eth_disable_rss;
+	hw_ops->set_rss_hash_key = dwc_eth_set_rss_hash_key;
+	hw_ops->set_rss_lookup_table = dwc_eth_set_rss_lookup_table;
+
+	TRACE("<--");
+}
diff --git a/drivers/net/ethernet/synopsys/dwc/dwc-eth-mdio.c b/drivers/net/ethernet/synopsys/dwc/dwc-eth-mdio.c
new file mode 100644
index 0000000..d999eb1
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc/dwc-eth-mdio.c
@@ -0,0 +1,252 @@
+/*
+ * Synopsys DesignWare Ethernet Driver
+ *
+ * Copyright (c) 2014-2016 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This file is free software; you may copy, redistribute and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, either version 2 of the License, or (at
+ * your option) any later version.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/module.h>
+#include <linux/kmod.h>
+#include <linux/mdio.h>
+#include <linux/phy.h>
+#include <linux/of.h>
+
+#include "dwc-eth.h"
+#include "dwc-eth-regacc.h"
+
+static int dwc_eth_mdio_read(struct mii_bus *mii, int prtad, int mmd_reg)
+{
+	struct dwc_eth_pdata *pdata = mii->priv;
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+	int mmd_data;
+
+	TRACE("-->");
+	DBGPR("  prtad=%#x mmd_reg=%#x\n", prtad, mmd_reg);
+
+	mmd_data = hw_ops->read_mmd_regs(pdata, prtad, mmd_reg);
+
+	DBGPR("  mmd_data=%#x\n", mmd_data);
+	TRACE("<--");
+
+	return mmd_data;
+}
+
+static int dwc_eth_mdio_write(struct mii_bus *mii, int prtad, int mmd_reg,
+			      u16 mmd_val)
+{
+	struct dwc_eth_pdata *pdata = mii->priv;
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+	int mmd_data = mmd_val;
+
+	TRACE("-->");
+	DBGPR("  prtad=%#x mmd_reg=%#x mmd_data=%#x\n",
+	      prtad, mmd_reg, mmd_data);
+
+	hw_ops->write_mmd_regs(pdata, prtad, mmd_reg, mmd_data);
+
+	TRACE("<--");
+
+	return 0;
+}
+
+static void dwc_eth_dump_phy_registers(struct dwc_eth_pdata *pdata)
+{
+	struct device *dev = pdata->dev;
+	struct phy_device *phydev = pdata->phydev;
+	int i;
+
+	dev_dbg(dev, "\n************* PHY Reg dump **********************\n");
+
+	dev_dbg(dev, "PCS Control Reg (%#04x) = %#04x\n", MDIO_CTRL1,
+		DWC_ETH_MDIO_READ(pdata, MDIO_MMD_PCS, MDIO_CTRL1));
+	dev_dbg(dev, "PCS Status Reg (%#04x) = %#04x\n", MDIO_STAT1,
+		DWC_ETH_MDIO_READ(pdata, MDIO_MMD_PCS, MDIO_STAT1));
+	dev_dbg(dev, "Phy Id (PHYS ID 1 %#04x)= %#04x\n", MDIO_DEVID1,
+		DWC_ETH_MDIO_READ(pdata, MDIO_MMD_PCS, MDIO_DEVID1));
+	dev_dbg(dev, "Phy Id (PHYS ID 2 %#04x)= %#04x\n", MDIO_DEVID2,
+		DWC_ETH_MDIO_READ(pdata, MDIO_MMD_PCS, MDIO_DEVID2));
+	dev_dbg(dev, "Devices in Package (%#04x)= %#04x\n", MDIO_DEVS1,
+		DWC_ETH_MDIO_READ(pdata, MDIO_MMD_PCS, MDIO_DEVS1));
+	dev_dbg(dev, "Devices in Package (%#04x)= %#04x\n", MDIO_DEVS2,
+		DWC_ETH_MDIO_READ(pdata, MDIO_MMD_PCS, MDIO_DEVS2));
+
+	dev_dbg(dev, "Auto-Neg Control Reg (%#04x) = %#04x\n", MDIO_CTRL1,
+		DWC_ETH_MDIO_READ(pdata, MDIO_MMD_AN, MDIO_CTRL1));
+	dev_dbg(dev, "Auto-Neg Status Reg (%#04x) = %#04x\n", MDIO_STAT1,
+		DWC_ETH_MDIO_READ(pdata, MDIO_MMD_AN, MDIO_STAT1));
+	dev_dbg(dev, "Auto-Neg Ad Reg 1 (%#04x) = %#04x\n",
+		MDIO_AN_ADVERTISE,
+		DWC_ETH_MDIO_READ(pdata, MDIO_MMD_AN, MDIO_AN_ADVERTISE));
+	dev_dbg(dev, "Auto-Neg Ad Reg 2 (%#04x) = %#04x\n",
+		MDIO_AN_ADVERTISE + 1,
+		DWC_ETH_MDIO_READ(pdata, MDIO_MMD_AN, MDIO_AN_ADVERTISE + 1));
+	dev_dbg(dev, "Auto-Neg Ad Reg 3 (%#04x) = %#04x\n",
+		MDIO_AN_ADVERTISE + 2,
+		DWC_ETH_MDIO_READ(pdata, MDIO_MMD_AN, MDIO_AN_ADVERTISE + 2));
+	dev_dbg(dev, "Auto-Neg Completion Reg (%#04x) = %#04x\n",
+		MDIO_AN_COMP_STAT,
+		DWC_ETH_MDIO_READ(pdata, MDIO_MMD_AN, MDIO_AN_COMP_STAT));
+
+	dev_dbg(dev, "MMD Device Mask = %#x\n",
+		phydev->c45_ids.devices_in_package);
+	for (i = 0; i < ARRAY_SIZE(phydev->c45_ids.device_ids); i++)
+		dev_dbg(dev, "  MMD %d: ID = %#08x\n", i,
+			phydev->c45_ids.device_ids[i]);
+
+	dev_dbg(dev, "\n*************************************************\n");
+}
+
+int dwc_eth_mdio_register(struct dwc_eth_pdata *pdata)
+{
+	struct mii_bus *mii;
+	struct phy_device *phydev;
+	int ret = 0;
+
+	TRACE("-->");
+
+	mii = mdiobus_alloc();
+	if (!mii) {
+		dev_err(pdata->dev, "mdiobus_alloc failed\n");
+		return -ENOMEM;
+	}
+
+	/* Register on the MDIO bus (don't probe any PHYs) */
+	mii->name = DWC_ETH_PHY_NAME;
+	mii->read = dwc_eth_mdio_read;
+	mii->write = dwc_eth_mdio_write;
+	snprintf(mii->id, sizeof(mii->id), "%s", pdata->mii_bus_id);
+	mii->priv = pdata;
+	mii->phy_mask = ~0;
+	mii->parent = pdata->dev;
+	ret = mdiobus_register(mii);
+	if (ret) {
+		dev_err(pdata->dev, "mdiobus_register failed\n");
+		goto err_mdiobus_alloc;
+	}
+	if (netif_msg_drv(pdata))
+		dev_dbg(pdata->dev, "mdiobus_register succeeded for %s\n",
+			pdata->mii_bus_id);
+
+	/* Probe the PCS using Clause 45 */
+	phydev = get_phy_device(mii, DWC_ETH_PRTAD, true);
+	if (IS_ERR(phydev) || !phydev ||
+	    !phydev->c45_ids.device_ids[MDIO_MMD_PCS]) {
+		dev_err(pdata->dev, "get_phy_device failed\n");
+		ret = phydev ? PTR_ERR(phydev) : -ENOLINK;
+		goto err_mdiobus_register;
+	}
+	request_module(MDIO_MODULE_PREFIX MDIO_ID_FMT,
+		       MDIO_ID_ARGS(phydev->c45_ids.device_ids[MDIO_MMD_PCS]));
+
+	ret = phy_device_register(phydev);
+	if (ret) {
+		dev_err(pdata->dev, "phy_device_register failed\n");
+		goto err_phy_device;
+	}
+	if (!phydev->mdio.dev.driver) {
+		dev_err(pdata->dev, "phy driver probe failed\n");
+		ret = -EIO;
+		goto err_phy_device;
+	}
+
+	/* Add a reference to the PHY driver so it can't be unloaded */
+	pdata->phy_module = phydev->mdio.dev.driver->owner;
+	if (!try_module_get(pdata->phy_module)) {
+		dev_err(pdata->dev, "try_module_get failed\n");
+		ret = -EIO;
+		goto err_phy_device;
+	}
+
+	pdata->mii = mii;
+	pdata->mdio_mmd = MDIO_MMD_PCS;
+
+	phydev->autoneg = pdata->default_autoneg;
+	if (phydev->autoneg == AUTONEG_DISABLE) {
+		phydev->speed = pdata->default_speed;
+		phydev->duplex = DUPLEX_FULL;
+
+		phydev->advertising &= ~ADVERTISED_Autoneg;
+	}
+
+	pdata->phydev = phydev;
+
+	if (netif_msg_drv(pdata))
+		dwc_eth_dump_phy_registers(pdata);
+
+	TRACE("<--");
+
+	return 0;
+
+err_phy_device:
+	phy_device_free(phydev);
+
+err_mdiobus_register:
+	mdiobus_unregister(mii);
+
+err_mdiobus_alloc:
+	mdiobus_free(mii);
+
+	return ret;
+}
+
+void dwc_eth_mdio_unregister(struct dwc_eth_pdata *pdata)
+{
+	TRACE("-->");
+
+	pdata->phydev = NULL;
+
+	module_put(pdata->phy_module);
+	pdata->phy_module = NULL;
+
+	mdiobus_unregister(pdata->mii);
+	pdata->mii->priv = NULL;
+
+	mdiobus_free(pdata->mii);
+	pdata->mii = NULL;
+
+	TRACE("<--");
+}
diff --git a/drivers/net/ethernet/synopsys/dwc/dwc-eth-net.c b/drivers/net/ethernet/synopsys/dwc/dwc-eth-net.c
new file mode 100644
index 0000000..19e5003
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc/dwc-eth-net.c
@@ -0,0 +1,2319 @@
+/*
+ * Synopsys DesignWare Ethernet Driver
+ *
+ * Copyright (c) 2014-2016 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This file is free software; you may copy, redistribute and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, either version 2 of the License, or (at
+ * your option) any later version.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/netdevice.h>
+#include <linux/tcp.h>
+
+#include "dwc-eth.h"
+#include "dwc-eth-regacc.h"
+
+static int dwc_eth_one_poll(struct napi_struct *, int);
+static int dwc_eth_all_poll(struct napi_struct *, int);
+
+static inline unsigned int dwc_eth_tx_avail_desc(struct dwc_eth_ring *ring)
+{
+	return (ring->dma_desc_count - (ring->cur - ring->dirty));
+}
+
+static inline unsigned int dwc_eth_rx_dirty_desc(struct dwc_eth_ring *ring)
+{
+	return (ring->cur - ring->dirty);
+}
+
+static int dwc_eth_maybe_stop_tx_queue(
+			struct dwc_eth_channel *channel,
+			struct dwc_eth_ring *ring,
+			unsigned int count)
+{
+	struct dwc_eth_pdata *pdata = channel->pdata;
+
+	if (count > dwc_eth_tx_avail_desc(ring)) {
+		netif_info(pdata, drv, pdata->netdev,
+			   "Tx queue stopped, not enough descriptors available\n");
+		netif_stop_subqueue(pdata->netdev, channel->queue_index);
+		ring->tx.queue_stopped = 1;
+
+		/* If we haven't notified the hardware because of xmit_more
+		 * support, tell it now
+		 */
+		if (ring->tx.xmit_more)
+			pdata->hw_ops.tx_start_xmit(channel, ring);
+
+		return NETDEV_TX_BUSY;
+	}
+
+	return 0;
+}
+
+static void dwc_eth_prep_tx_tstamp(struct dwc_eth_pdata *pdata,
+				   struct sk_buff *skb,
+				   struct dwc_eth_pkt_info *pkt_info)
+{
+	unsigned long flags;
+
+	if (DWC_ETH_GET_BITS(pkt_info->attributes, TX_PACKET_ATTRIBUTES, PTP)) {
+		spin_lock_irqsave(&pdata->tstamp_lock, flags);
+		if (pdata->tx_tstamp_skb) {
+			/* Another timestamp in progress, ignore this one */
+			DWC_ETH_SET_BITS(pkt_info->attributes,
+					 TX_PACKET_ATTRIBUTES, PTP, 0);
+		} else {
+			pdata->tx_tstamp_skb = skb_get(skb);
+			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+		}
+		spin_unlock_irqrestore(&pdata->tstamp_lock, flags);
+	}
+
+	if (!DWC_ETH_GET_BITS(pkt_info->attributes, TX_PACKET_ATTRIBUTES, PTP))
+		skb_tx_timestamp(skb);
+}
+
+static void dwc_eth_prep_vlan(struct sk_buff *skb,
+			      struct dwc_eth_pkt_info *pkt_info)
+{
+	if (skb_vlan_tag_present(skb))
+		pkt_info->vlan_ctag = skb_vlan_tag_get(skb);
+}
+
+static int dwc_eth_prep_tso(struct sk_buff *skb,
+			    struct dwc_eth_pkt_info *pkt_info)
+{
+	int ret;
+
+	if (!DWC_ETH_GET_BITS(pkt_info->attributes,
+			      TX_PACKET_ATTRIBUTES, TSO_ENABLE))
+		return 0;
+
+	ret = skb_cow_head(skb, 0);
+	if (ret)
+		return ret;
+
+	pkt_info->header_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+	pkt_info->tcp_header_len = tcp_hdrlen(skb);
+	pkt_info->tcp_payload_len = skb->len - pkt_info->header_len;
+	pkt_info->mss = skb_shinfo(skb)->gso_size;
+	DBGPR("  pkt_info->header_len=%u\n", pkt_info->header_len);
+	DBGPR("  pkt_info->tcp_header_len=%u, pkt_info->tcp_payload_len=%u\n",
+	      pkt_info->tcp_header_len, pkt_info->tcp_payload_len);
+	DBGPR("  pkt_info->mss=%u\n", pkt_info->mss);
+
+	/* Update the number of packets that will ultimately be transmitted
+	 * along with the extra bytes for each extra packet
+	 */
+	pkt_info->tx_packets = skb_shinfo(skb)->gso_segs;
+	pkt_info->tx_bytes += (pkt_info->tx_packets - 1) * pkt_info->header_len;
+
+	return 0;
+}
+
+static int dwc_eth_is_tso(struct sk_buff *skb)
+{
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return 0;
+
+	if (!skb_is_gso(skb))
+		return 0;
+
+	DBGPR("  TSO packet to be processed\n");
+
+	return 1;
+}
+
+static void dwc_eth_prep_tx_pkt(struct dwc_eth_pdata *pdata,
+				struct dwc_eth_ring *ring,
+				struct sk_buff *skb,
+				struct dwc_eth_pkt_info *pkt_info)
+{
+	struct skb_frag_struct *frag;
+	unsigned int context_desc;
+	unsigned int len;
+	unsigned int i;
+
+	pkt_info->skb = skb;
+
+	context_desc = 0;
+	pkt_info->desc_count = 0;
+
+	pkt_info->tx_packets = 1;
+	pkt_info->tx_bytes = skb->len;
+
+	if (dwc_eth_is_tso(skb)) {
+		/* TSO requires an extra descriptor if mss is different */
+		if (skb_shinfo(skb)->gso_size != ring->tx.cur_mss) {
+			context_desc = 1;
+			pkt_info->desc_count++;
+		}
+
+		/* TSO requires an extra descriptor for TSO header */
+		pkt_info->desc_count++;
+
+		DWC_ETH_SET_BITS(pkt_info->attributes, TX_PACKET_ATTRIBUTES,
+				 TSO_ENABLE, 1);
+		DWC_ETH_SET_BITS(pkt_info->attributes, TX_PACKET_ATTRIBUTES,
+				 CSUM_ENABLE, 1);
+	} else if (skb->ip_summed == CHECKSUM_PARTIAL)
+		DWC_ETH_SET_BITS(pkt_info->attributes, TX_PACKET_ATTRIBUTES,
+				 CSUM_ENABLE, 1);
+
+	if (skb_vlan_tag_present(skb)) {
+		/* VLAN requires an extra descriptor if tag is different */
+		if (skb_vlan_tag_get(skb) != ring->tx.cur_vlan_ctag)
+			/* We can share with the TSO context descriptor */
+			if (!context_desc) {
+				context_desc = 1;
+				pkt_info->desc_count++;
+			}
+
+		DWC_ETH_SET_BITS(pkt_info->attributes, TX_PACKET_ATTRIBUTES,
+				 VLAN_CTAG, 1);
+	}
+
+	if ((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
+	    (pdata->tstamp_config.tx_type == HWTSTAMP_TX_ON))
+		DWC_ETH_SET_BITS(pkt_info->attributes, TX_PACKET_ATTRIBUTES,
+				 PTP, 1);
+
+	for (len = skb_headlen(skb); len;) {
+		pkt_info->desc_count++;
+		len -= min_t(unsigned int, len, pdata->tx_max_buf_size);
+	}
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		frag = &skb_shinfo(skb)->frags[i];
+		for (len = skb_frag_size(frag); len; ) {
+			pkt_info->desc_count++;
+			len -= min_t(unsigned int, len, pdata->tx_max_buf_size);
+		}
+	}
+}
+
+static int dwc_eth_calc_rx_buf_size(struct net_device *netdev, unsigned int mtu)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	unsigned int rx_buf_size;
+
+	if (mtu > DWC_ETH_JUMBO_PACKET_MTU) {
+		netdev_alert(netdev, "MTU exceeds maximum supported value\n");
+		return -EINVAL;
+	}
+
+	rx_buf_size = mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
+	rx_buf_size = clamp_val(rx_buf_size, pdata->rx_min_buf_size, PAGE_SIZE);
+
+	rx_buf_size = (rx_buf_size + pdata->rx_buf_align - 1) &
+		      ~(pdata->rx_buf_align - 1);
+
+	return rx_buf_size;
+}
+
+static void dwc_eth_enable_rx_tx_ints(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+	struct dwc_eth_channel *channel;
+	enum dwc_eth_int int_id;
+	unsigned int i;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (channel->tx_ring && channel->rx_ring)
+			int_id = DWC_ETH_INT_DMA_CH_SR_TI_RI;
+		else if (channel->tx_ring)
+			int_id = DWC_ETH_INT_DMA_CH_SR_TI;
+		else if (channel->rx_ring)
+			int_id = DWC_ETH_INT_DMA_CH_SR_RI;
+		else
+			continue;
+
+		hw_ops->enable_int(channel, int_id);
+	}
+}
+
+static void dwc_eth_disable_rx_tx_ints(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+	struct dwc_eth_channel *channel;
+	enum dwc_eth_int int_id;
+	unsigned int i;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (channel->tx_ring && channel->rx_ring)
+			int_id = DWC_ETH_INT_DMA_CH_SR_TI_RI;
+		else if (channel->tx_ring)
+			int_id = DWC_ETH_INT_DMA_CH_SR_TI;
+		else if (channel->rx_ring)
+			int_id = DWC_ETH_INT_DMA_CH_SR_RI;
+		else
+			continue;
+
+		hw_ops->disable_int(channel, int_id);
+	}
+}
+
+static irqreturn_t dwc_eth_isr(int irq, void *data)
+{
+	struct dwc_eth_pdata *pdata = data;
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+	struct dwc_eth_channel *channel;
+	unsigned int dma_isr, dma_ch_isr;
+	unsigned int mac_isr, mac_tssr;
+	unsigned int i;
+
+	/* The DMA interrupt status register also reports MAC and MTL
+	 * interrupts. So for polling mode, we just need to check for
+	 * this register to be non-zero
+	 */
+	dma_isr = DWC_ETH_IOREAD(pdata, DMA_ISR);
+	if (!dma_isr)
+		goto isr_done;
+
+	netif_dbg(pdata, intr, pdata->netdev, "DMA_ISR=%#010x\n", dma_isr);
+
+	for (i = 0; i < pdata->channel_count; i++) {
+		if (!(dma_isr & (1 << i)))
+			continue;
+
+		channel = pdata->channel_head + i;
+
+		dma_ch_isr = DWC_ETH_DMA_IOREAD(channel, DMA_CH_SR);
+		netif_dbg(pdata, intr, pdata->netdev, "DMA_CH%u_ISR=%#010x\n",
+			  i, dma_ch_isr);
+
+		/* The TI or RI interrupt bits may still be set even if using
+		 * per channel DMA interrupts. Check to be sure those are not
+		 * enabled before using the private data napi structure.
+		 */
+		if (!pdata->per_channel_irq &&
+		    (DWC_ETH_GET_BITS(dma_ch_isr, DMA_CH_SR, TI) ||
+		     DWC_ETH_GET_BITS(dma_ch_isr, DMA_CH_SR, RI))) {
+			if (napi_schedule_prep(&pdata->napi)) {
+				/* Disable Tx and Rx interrupts */
+				dwc_eth_disable_rx_tx_ints(pdata);
+
+				/* Turn on polling */
+				__napi_schedule_irqoff(&pdata->napi);
+			}
+		}
+
+		if (DWC_ETH_GET_BITS(dma_ch_isr, DMA_CH_SR, RBU))
+			pdata->stats.rx_buffer_unavailable++;
+
+		/* Restart the device on a Fatal Bus Error */
+		if (DWC_ETH_GET_BITS(dma_ch_isr, DMA_CH_SR, FBE))
+			schedule_work(&pdata->restart_work);
+
+		/* Clear all interrupt signals */
+		DWC_ETH_DMA_IOWRITE(channel, DMA_CH_SR, dma_ch_isr);
+	}
+
+	if (DWC_ETH_GET_BITS(dma_isr, DMA_ISR, MACIS)) {
+		mac_isr = DWC_ETH_IOREAD(pdata, MAC_ISR);
+
+		if (DWC_ETH_GET_BITS(mac_isr, MAC_ISR, MMCTXIS))
+			hw_ops->tx_mmc_int(pdata);
+
+		if (DWC_ETH_GET_BITS(mac_isr, MAC_ISR, MMCRXIS))
+			hw_ops->rx_mmc_int(pdata);
+
+		if (DWC_ETH_GET_BITS(mac_isr, MAC_ISR, TSIS)) {
+			mac_tssr = DWC_ETH_IOREAD(pdata, MAC_TSSR);
+
+			if (DWC_ETH_GET_BITS(mac_tssr, MAC_TSSR, TXTSC)) {
+				/* Read Tx Timestamp to clear interrupt */
+				pdata->tx_tstamp =
+					hw_ops->get_tx_tstamp(pdata);
+				queue_work(pdata->dev_workqueue,
+					   &pdata->tx_tstamp_work);
+			}
+		}
+	}
+
+isr_done:
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t dwc_eth_dma_isr(int irq, void *data)
+{
+	struct dwc_eth_channel *channel = data;
+
+	/* Per channel DMA interrupts are enabled, so we use the per
+	 * channel napi structure and not the private data napi structure
+	 */
+	if (napi_schedule_prep(&channel->napi)) {
+		/* Disable Tx and Rx interrupts */
+		disable_irq_nosync(channel->dma_irq);
+
+		/* Turn on polling */
+		__napi_schedule_irqoff(&channel->napi);
+	}
+
+	return IRQ_HANDLED;
+}
+
+static void dwc_eth_tx_timer(unsigned long data)
+{
+	struct dwc_eth_channel *channel = (struct dwc_eth_channel *)data;
+	struct dwc_eth_pdata *pdata = channel->pdata;
+	struct napi_struct *napi;
+
+	TRACE("-->");
+
+	napi = (pdata->per_channel_irq) ? &channel->napi : &pdata->napi;
+
+	if (napi_schedule_prep(napi)) {
+		/* Disable Tx and Rx interrupts */
+		if (pdata->per_channel_irq)
+			disable_irq_nosync(channel->dma_irq);
+		else
+			dwc_eth_disable_rx_tx_ints(pdata);
+
+		/* Turn on polling */
+		__napi_schedule(napi);
+	}
+
+	channel->tx_timer_active = 0;
+
+	TRACE("<--");
+}
+
+static void dwc_eth_init_timers(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int i;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		setup_timer(&channel->tx_timer, dwc_eth_tx_timer,
+			    (unsigned long)channel);
+	}
+}
+
+static void dwc_eth_stop_timers(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int i;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		del_timer_sync(&channel->tx_timer);
+	}
+}
+
+static void dwc_eth_napi_enable(struct dwc_eth_pdata *pdata, unsigned int add)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int i;
+
+	if (pdata->per_channel_irq) {
+		channel = pdata->channel_head;
+		for (i = 0; i < pdata->channel_count; i++, channel++) {
+			if (add)
+				netif_napi_add(pdata->netdev, &channel->napi,
+					       dwc_eth_one_poll,
+					       NAPI_POLL_WEIGHT);
+
+			napi_enable(&channel->napi);
+		}
+	} else {
+		if (add)
+			netif_napi_add(pdata->netdev, &pdata->napi,
+				       dwc_eth_all_poll, NAPI_POLL_WEIGHT);
+
+		napi_enable(&pdata->napi);
+	}
+}
+
+static void dwc_eth_napi_disable(struct dwc_eth_pdata *pdata, unsigned int del)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int i;
+
+	if (pdata->per_channel_irq) {
+		channel = pdata->channel_head;
+		for (i = 0; i < pdata->channel_count; i++, channel++) {
+			napi_disable(&channel->napi);
+
+			if (del)
+				netif_napi_del(&channel->napi);
+		}
+	} else {
+		napi_disable(&pdata->napi);
+
+		if (del)
+			netif_napi_del(&pdata->napi);
+	}
+}
+
+static int dwc_eth_request_irqs(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel;
+	struct net_device *netdev = pdata->netdev;
+	unsigned int i;
+	int ret;
+
+	ret = devm_request_irq(pdata->dev, pdata->dev_irq, dwc_eth_isr,
+			       IRQF_SHARED, netdev->name, pdata);
+	if (ret) {
+		netdev_alert(netdev, "error requesting irq %d\n",
+			     pdata->dev_irq);
+		return ret;
+	}
+
+	if (!pdata->per_channel_irq)
+		return 0;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		snprintf(channel->dma_irq_name,
+			 sizeof(channel->dma_irq_name) - 1,
+			 "%s-TxRx-%u", netdev_name(netdev),
+			 channel->queue_index);
+
+		ret = devm_request_irq(pdata->dev, channel->dma_irq,
+				       dwc_eth_dma_isr, 0,
+				       channel->dma_irq_name, channel);
+		if (ret) {
+			netdev_alert(netdev, "error requesting irq %d\n",
+				     channel->dma_irq);
+			goto err_irq;
+		}
+	}
+
+	return 0;
+
+err_irq:
+	/* Using an unsigned int, 'i' will go to UINT_MAX and exit */
+	for (i--, channel--; i < pdata->channel_count; i--, channel--)
+		devm_free_irq(pdata->dev, channel->dma_irq, channel);
+
+	devm_free_irq(pdata->dev, pdata->dev_irq, pdata);
+
+	return ret;
+}
+
+static void dwc_eth_free_irqs(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_channel *channel;
+	unsigned int i;
+
+	devm_free_irq(pdata->dev, pdata->dev_irq, pdata);
+
+	if (!pdata->per_channel_irq)
+		return;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++)
+		devm_free_irq(pdata->dev, channel->dma_irq, channel);
+}
+
+static void dwc_eth_free_tx_data(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_desc_ops *desc_ops = &pdata->desc_ops;
+	struct dwc_eth_channel *channel;
+	struct dwc_eth_ring *ring;
+	struct dwc_eth_desc_data *desc_data;
+	unsigned int i, j;
+
+	TRACE("-->");
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		ring = channel->tx_ring;
+		if (!ring)
+			break;
+
+		for (j = 0; j < ring->dma_desc_count; j++) {
+			desc_data = DWC_ETH_GET_DESC_DATA(ring, j);
+			desc_ops->unmap_desc_data(pdata, desc_data);
+		}
+	}
+
+	TRACE("<--");
+}
+
+static void dwc_eth_free_rx_data(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_desc_ops *desc_ops = &pdata->desc_ops;
+	struct dwc_eth_channel *channel;
+	struct dwc_eth_ring *ring;
+	struct dwc_eth_desc_data *desc_data;
+	unsigned int i, j;
+
+	TRACE("-->");
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		ring = channel->rx_ring;
+		if (!ring)
+			break;
+
+		for (j = 0; j < ring->dma_desc_count; j++) {
+			desc_data = DWC_ETH_GET_DESC_DATA(ring, j);
+			desc_ops->unmap_desc_data(pdata, desc_data);
+		}
+	}
+
+	TRACE("<--");
+}
+
+static void dwc_eth_adjust_link(struct net_device *netdev)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+	struct phy_device *phydev = pdata->phydev;
+	int new_state = 0;
+
+	if (!phydev)
+		return;
+
+	if (phydev->link) {
+		/* Flow control support */
+		if (pdata->pause_autoneg) {
+			if (phydev->pause || phydev->asym_pause) {
+				pdata->tx_pause = 1;
+				pdata->rx_pause = 1;
+			} else {
+				pdata->tx_pause = 0;
+				pdata->rx_pause = 0;
+			}
+		}
+
+		if (pdata->tx_pause != pdata->phy_tx_pause) {
+			hw_ops->config_tx_flow_control(pdata);
+			pdata->phy_tx_pause = pdata->tx_pause;
+		}
+
+		if (pdata->rx_pause != pdata->phy_rx_pause) {
+			hw_ops->config_rx_flow_control(pdata);
+			pdata->phy_rx_pause = pdata->rx_pause;
+		}
+
+		/* Speed support */
+		if (phydev->speed != pdata->phy_speed) {
+			new_state = 1;
+
+			switch (phydev->speed) {
+			case SPEED_100000:
+				hw_ops->set_xlgmii_100000_speed(pdata);
+				break;
+
+			case SPEED_50000:
+				hw_ops->set_xlgmii_50000_speed(pdata);
+				break;
+
+			case SPEED_40000:
+				hw_ops->set_xlgmii_40000_speed(pdata);
+				break;
+
+			case SPEED_25000:
+				hw_ops->set_xlgmii_25000_speed(pdata);
+				break;
+
+			case SPEED_10000:
+				hw_ops->set_xgmii_10000_speed(pdata);
+				break;
+
+			case SPEED_2500:
+				hw_ops->set_gmii_2500_speed(pdata);
+				break;
+
+			case SPEED_1000:
+				hw_ops->set_gmii_1000_speed(pdata);
+				break;
+			}
+			pdata->phy_speed = phydev->speed;
+		}
+
+		if (phydev->link != pdata->phy_link) {
+			new_state = 1;
+			pdata->phy_link = 1;
+		}
+	} else if (pdata->phy_link) {
+		new_state = 1;
+		pdata->phy_link = 0;
+		pdata->phy_speed = SPEED_UNKNOWN;
+	}
+
+	if (new_state && netif_msg_link(pdata))
+		phy_print_status(phydev);
+}
+
+static int dwc_eth_phy_init(struct dwc_eth_pdata *pdata)
+{
+	struct net_device *netdev = pdata->netdev;
+	struct phy_device *phydev = pdata->phydev;
+	int ret;
+
+	if (!pdata->phydev)
+		return -ENODEV;
+
+	pdata->phy_link = -1;
+	pdata->phy_speed = SPEED_UNKNOWN;
+	pdata->phy_tx_pause = pdata->tx_pause;
+	pdata->phy_rx_pause = pdata->rx_pause;
+
+	ret = phy_connect_direct(netdev, phydev, &dwc_eth_adjust_link,
+				 pdata->phy_mode);
+	if (ret) {
+		netdev_err(netdev, "phy_connect_direct failed\n");
+		return ret;
+	}
+
+	if (!phydev->drv || (phydev->drv->phy_id == 0)) {
+		netdev_err(netdev, "phy_id not valid\n");
+		ret = -ENODEV;
+		goto err_phy_connect;
+	}
+	netif_dbg(pdata, ifup, pdata->netdev,
+		  "phy_connect_direct succeeded for PHY %s\n",
+		  dev_name(&phydev->mdio.dev));
+
+	return 0;
+
+err_phy_connect:
+	phy_disconnect(phydev);
+
+	return ret;
+}
+
+static void dwc_eth_phy_exit(struct dwc_eth_pdata *pdata)
+{
+	if (!pdata->phydev)
+		return;
+
+	phy_disconnect(pdata->phydev);
+}
+
+static int dwc_eth_start(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+	struct net_device *netdev = pdata->netdev;
+	int ret;
+
+	TRACE("-->");
+
+	hw_ops->init(pdata);
+
+	if (pdata->phydev)
+		phy_start(pdata->phydev);
+
+	dwc_eth_napi_enable(pdata, 1);
+
+	ret = dwc_eth_request_irqs(pdata);
+	if (ret)
+		goto err_napi;
+
+	hw_ops->enable_tx(pdata);
+	hw_ops->enable_rx(pdata);
+
+	netif_tx_start_all_queues(netdev);
+
+	TRACE("<--");
+
+	return 0;
+
+err_napi:
+	dwc_eth_napi_disable(pdata, 1);
+
+	if (pdata->phydev)
+		phy_stop(pdata->phydev);
+
+	hw_ops->exit(pdata);
+
+	return ret;
+}
+
+static void dwc_eth_stop(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+	struct dwc_eth_channel *channel;
+	struct net_device *netdev = pdata->netdev;
+	struct netdev_queue *txq;
+	unsigned int i;
+
+	TRACE("-->");
+
+	netif_tx_stop_all_queues(netdev);
+
+	dwc_eth_stop_timers(pdata);
+	flush_workqueue(pdata->dev_workqueue);
+
+	hw_ops->disable_tx(pdata);
+	hw_ops->disable_rx(pdata);
+
+	dwc_eth_free_irqs(pdata);
+
+	dwc_eth_napi_disable(pdata, 1);
+
+	if (pdata->phydev)
+		phy_stop(pdata->phydev);
+
+	hw_ops->exit(pdata);
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			continue;
+
+		txq = netdev_get_tx_queue(netdev, channel->queue_index);
+		netdev_tx_reset_queue(txq);
+	}
+
+	TRACE("<--");
+}
+
+static void dwc_eth_restart_dev(struct dwc_eth_pdata *pdata)
+{
+	TRACE("-->");
+
+	/* If not running, "restart" will happen on open */
+	if (!netif_running(pdata->netdev))
+		return;
+
+	dwc_eth_stop(pdata);
+
+	dwc_eth_free_tx_data(pdata);
+	dwc_eth_free_rx_data(pdata);
+
+	dwc_eth_start(pdata);
+
+	TRACE("<--");
+}
+
+static void dwc_eth_restart(struct work_struct *work)
+{
+	struct dwc_eth_pdata *pdata = container_of(work,
+						   struct dwc_eth_pdata,
+						   restart_work);
+
+	rtnl_lock();
+
+	dwc_eth_restart_dev(pdata);
+
+	rtnl_unlock();
+}
+
+static void dwc_eth_tx_tstamp(struct work_struct *work)
+{
+	struct dwc_eth_pdata *pdata = container_of(work,
+						   struct dwc_eth_pdata,
+						   tx_tstamp_work);
+	struct skb_shared_hwtstamps hwtstamps;
+	u64 nsec;
+	unsigned long flags;
+
+	if (pdata->tx_tstamp) {
+		nsec = timecounter_cyc2time(&pdata->tstamp_tc,
+					    pdata->tx_tstamp);
+
+		memset(&hwtstamps, 0, sizeof(hwtstamps));
+		hwtstamps.hwtstamp = ns_to_ktime(nsec);
+		skb_tstamp_tx(pdata->tx_tstamp_skb, &hwtstamps);
+	}
+
+	dev_kfree_skb_any(pdata->tx_tstamp_skb);
+
+	spin_lock_irqsave(&pdata->tstamp_lock, flags);
+	pdata->tx_tstamp_skb = NULL;
+	spin_unlock_irqrestore(&pdata->tstamp_lock, flags);
+}
+
+static int dwc_eth_get_hwtstamp_settings(struct dwc_eth_pdata *pdata,
+					 struct ifreq *ifreq)
+{
+	if (copy_to_user(ifreq->ifr_data, &pdata->tstamp_config,
+			 sizeof(pdata->tstamp_config)))
+		return -EFAULT;
+
+	return 0;
+}
+
+static int dwc_eth_set_hwtstamp_settings(struct dwc_eth_pdata *pdata,
+					 struct ifreq *ifreq)
+{
+	struct hwtstamp_config config;
+	unsigned int mac_tscr;
+
+	if (copy_from_user(&config, ifreq->ifr_data, sizeof(config)))
+		return -EFAULT;
+
+	if (config.flags)
+		return -EINVAL;
+
+	mac_tscr = 0;
+
+	switch (config.tx_type) {
+	case HWTSTAMP_TX_OFF:
+		break;
+
+	case HWTSTAMP_TX_ON:
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSENA, 1);
+		break;
+
+	default:
+		return -ERANGE;
+	}
+
+	switch (config.rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		break;
+
+	case HWTSTAMP_FILTER_ALL:
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSENALL, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSENA, 1);
+		break;
+
+	/* PTP v2, UDP, any kind of event packet */
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSVER2ENA, 1);
+	/* PTP v1, UDP, any kind of event packet */
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSIPV4ENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSIPV6ENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, SNAPTYPSEL, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSENA, 1);
+		break;
+
+	/* PTP v2, UDP, Sync packet */
+	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSVER2ENA, 1);
+	/* PTP v1, UDP, Sync packet */
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSIPV4ENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSIPV6ENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSEVNTENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSENA, 1);
+		break;
+
+	/* PTP v2, UDP, Delay_req packet */
+	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSVER2ENA, 1);
+	/* PTP v1, UDP, Delay_req packet */
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSIPV4ENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSIPV6ENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSEVNTENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSMSTRENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSENA, 1);
+		break;
+
+	/* 802.AS1, Ethernet, any kind of event packet */
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, AV8021ASMEN, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, SNAPTYPSEL, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSENA, 1);
+		break;
+
+	/* 802.AS1, Ethernet, Sync packet */
+	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, AV8021ASMEN, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSEVNTENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSENA, 1);
+		break;
+
+	/* 802.AS1, Ethernet, Delay_req packet */
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, AV8021ASMEN, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSMSTRENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSEVNTENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSENA, 1);
+		break;
+
+	/* PTP v2/802.AS1, any layer, any kind of event packet */
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSVER2ENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSIPENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSIPV4ENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSIPV6ENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, SNAPTYPSEL, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSENA, 1);
+		break;
+
+	/* PTP v2/802.AS1, any layer, Sync packet */
+	case HWTSTAMP_FILTER_PTP_V2_SYNC:
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSVER2ENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSIPENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSIPV4ENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSIPV6ENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSEVNTENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSENA, 1);
+		break;
+
+	/* PTP v2/802.AS1, any layer, Delay_req packet */
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSVER2ENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSIPENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSIPV4ENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSIPV6ENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSMSTRENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSEVNTENA, 1);
+		DWC_ETH_SET_BITS(mac_tscr, MAC_TSCR, TSENA, 1);
+		break;
+
+	default:
+		return -ERANGE;
+	}
+
+	pdata->hw_ops.config_tstamp(pdata, mac_tscr);
+
+	memcpy(&pdata->tstamp_config, &config, sizeof(config));
+
+	return 0;
+}
+
+static int dwc_eth_open(struct net_device *netdev)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	struct dwc_eth_desc_ops *desc_ops = &pdata->desc_ops;
+	int ret;
+
+	TRACE("-->");
+
+	/* Initialize the phy */
+	if (pdata->mdio_en) {
+		ret = dwc_eth_phy_init(pdata);
+		if (ret)
+			return ret;
+	}
+
+	/* Calculate the Rx buffer size before allocating rings */
+	ret = dwc_eth_calc_rx_buf_size(netdev, netdev->mtu);
+	if (ret < 0)
+		goto err_phy_init;
+	pdata->rx_buf_size = ret;
+
+	/* Allocate the channels and rings */
+	ret = desc_ops->alloc_channles_and_rings(pdata);
+	if (ret)
+		goto err_phy_init;
+
+	INIT_WORK(&pdata->restart_work, dwc_eth_restart);
+	INIT_WORK(&pdata->tx_tstamp_work, dwc_eth_tx_tstamp);
+	dwc_eth_init_timers(pdata);
+
+	ret = dwc_eth_start(pdata);
+	if (ret)
+		goto err_channels_and_rings;
+
+	TRACE("<--");
+
+	return 0;
+
+err_channels_and_rings:
+	desc_ops->free_channels_and_rings(pdata);
+
+err_phy_init:
+	dwc_eth_phy_exit(pdata);
+
+	return ret;
+}
+
+static int dwc_eth_close(struct net_device *netdev)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	struct dwc_eth_desc_ops *desc_ops = &pdata->desc_ops;
+
+	TRACE("-->");
+
+	/* Stop the device */
+	dwc_eth_stop(pdata);
+
+	/* Free the channels and rings */
+	desc_ops->free_channels_and_rings(pdata);
+
+	/* Release the phy */
+	dwc_eth_phy_exit(pdata);
+
+	TRACE("<--");
+
+	return 0;
+}
+
+static void dwc_eth_tx_timeout(struct net_device *netdev)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+
+	netdev_warn(netdev, "tx timeout, device restarting\n");
+	schedule_work(&pdata->restart_work);
+}
+
+static int dwc_eth_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	struct dwc_eth_desc_ops *desc_ops = &pdata->desc_ops;
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+	struct dwc_eth_channel *channel;
+	struct dwc_eth_ring *ring;
+	struct dwc_eth_pkt_info *tx_pkt_info;
+	struct netdev_queue *txq;
+	int ret;
+
+	TRACE("-->");
+	DBGPR("  skb->len = %d\n", skb->len);
+
+	channel = pdata->channel_head + skb->queue_mapping;
+	txq = netdev_get_tx_queue(netdev, channel->queue_index);
+	ring = channel->tx_ring;
+	tx_pkt_info = &ring->pkt_info;
+
+	ret = NETDEV_TX_OK;
+
+	if (skb->len == 0) {
+		netif_err(pdata, tx_err, netdev,
+			  "empty skb received from stack\n");
+		dev_kfree_skb_any(skb);
+		goto tx_return;
+	}
+
+	/* Prepare preliminary packet info for TX */
+	memset(tx_pkt_info, 0, sizeof(*tx_pkt_info));
+	dwc_eth_prep_tx_pkt(pdata, ring, skb, tx_pkt_info);
+
+	/* Check that there are enough descriptors available */
+	ret = dwc_eth_maybe_stop_tx_queue(channel, ring,
+					  tx_pkt_info->desc_count);
+	if (ret)
+		goto tx_return;
+
+	ret = dwc_eth_prep_tso(skb, tx_pkt_info);
+	if (ret) {
+		netif_err(pdata, tx_err, netdev,
+			  "error processing TSO packet\n");
+		dev_kfree_skb_any(skb);
+		goto tx_return;
+	}
+	dwc_eth_prep_vlan(skb, tx_pkt_info);
+
+	if (!desc_ops->map_tx_skb(channel, skb)) {
+		dev_kfree_skb_any(skb);
+		goto tx_return;
+	}
+
+	dwc_eth_prep_tx_tstamp(pdata, skb, tx_pkt_info);
+
+	/* Report on the actual number of bytes (to be) sent */
+	netdev_tx_sent_queue(txq, tx_pkt_info->tx_bytes);
+
+	/* Configure required descriptor fields for transmission */
+	hw_ops->dev_xmit(channel);
+
+	if (netif_msg_pktdata(pdata))
+		dwc_eth_print_pkt(netdev, skb, true);
+
+	/* Stop the queue in advance if there may not be enough descriptors */
+	dwc_eth_maybe_stop_tx_queue(channel, ring, pdata->tx_max_desc_nr);
+
+	ret = NETDEV_TX_OK;
+
+tx_return:
+	return ret;
+}
+
+static struct rtnl_link_stats64 *dwc_eth_get_stats64(
+				struct net_device *netdev,
+				struct rtnl_link_stats64 *s)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	struct dwc_eth_stats *pstats = &pdata->stats;
+
+	TRACE("-->");
+
+	pdata->hw_ops.read_mmc_stats(pdata);
+
+	s->rx_packets = pstats->rxframecount_gb;
+	s->rx_bytes = pstats->rxoctetcount_gb;
+	s->rx_errors = pstats->rxframecount_gb -
+		       pstats->rxbroadcastframes_g -
+		       pstats->rxmulticastframes_g -
+		       pstats->rxunicastframes_g;
+	s->multicast = pstats->rxmulticastframes_g;
+	s->rx_length_errors = pstats->rxlengtherror;
+	s->rx_crc_errors = pstats->rxcrcerror;
+	s->rx_fifo_errors = pstats->rxfifooverflow;
+
+	s->tx_packets = pstats->txframecount_gb;
+	s->tx_bytes = pstats->txoctetcount_gb;
+	s->tx_errors = pstats->txframecount_gb - pstats->txframecount_g;
+	s->tx_dropped = netdev->stats.tx_dropped;
+
+	TRACE("<--");
+
+	return s;
+}
+
+static int dwc_eth_set_mac_address(struct net_device *netdev, void *addr)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+	struct sockaddr *saddr = addr;
+
+	TRACE("-->");
+
+	if (!is_valid_ether_addr(saddr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(netdev->dev_addr, saddr->sa_data, netdev->addr_len);
+
+	hw_ops->set_mac_address(pdata, netdev->dev_addr);
+
+	TRACE("<--");
+
+	return 0;
+}
+
+static int dwc_eth_ioctl(struct net_device *netdev,
+			 struct ifreq *ifreq, int cmd)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	int ret;
+
+	TRACE("-->");
+
+	if (!netif_running(netdev))
+		return -ENODEV;
+
+	switch (cmd) {
+	case SIOCGHWTSTAMP:
+		ret = dwc_eth_get_hwtstamp_settings(pdata, ifreq);
+		break;
+
+	case SIOCSHWTSTAMP:
+		ret = dwc_eth_set_hwtstamp_settings(pdata, ifreq);
+		break;
+
+	default:
+		ret = -EOPNOTSUPP;
+	}
+
+	TRACE("<--");
+
+	return ret;
+}
+
+static int dwc_eth_change_mtu(struct net_device *netdev, int mtu)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	int ret;
+
+	TRACE("-->");
+
+	ret = dwc_eth_calc_rx_buf_size(netdev, mtu);
+	if (ret < 0)
+		return ret;
+
+	pdata->rx_buf_size = ret;
+	netdev->mtu = mtu;
+
+	dwc_eth_restart_dev(pdata);
+
+	TRACE("<--");
+
+	return 0;
+}
+
+static int dwc_eth_vlan_rx_add_vid(struct net_device *netdev,
+				   __be16 proto,
+				   u16 vid)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+
+	TRACE("-->");
+
+	set_bit(vid, pdata->active_vlans);
+	hw_ops->update_vlan_hash_table(pdata);
+
+	TRACE("<--");
+
+	return 0;
+}
+
+static int dwc_eth_vlan_rx_kill_vid(struct net_device *netdev,
+				    __be16 proto,
+				    u16 vid)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+
+	TRACE("-->");
+
+	clear_bit(vid, pdata->active_vlans);
+	hw_ops->update_vlan_hash_table(pdata);
+
+	TRACE("<--");
+
+	return 0;
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void dwc_eth_poll_controller(struct net_device *netdev)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	struct dwc_eth_channel *channel;
+	unsigned int i;
+
+	TRACE("-->");
+
+	if (pdata->per_channel_irq) {
+		channel = pdata->channel_head;
+		for (i = 0; i < pdata->channel_count; i++, channel++)
+			dwc_eth_dma_isr(channel->dma_irq, channel);
+	} else {
+		disable_irq(pdata->dev_irq);
+		dwc_eth_isr(pdata->dev_irq, pdata);
+		enable_irq(pdata->dev_irq);
+	}
+
+	TRACE("<--");
+}
+#endif /* CONFIG_NET_POLL_CONTROLLER */
+
+static int dwc_eth_setup_tc(struct net_device *netdev,
+			    u32 handle, __be16 proto,
+			    struct tc_to_netdev *tc_to_netdev)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	u8 tc;
+
+	if (tc_to_netdev->type != TC_SETUP_MQPRIO)
+		return -EINVAL;
+
+	tc = tc_to_netdev->tc;
+
+	if (tc > pdata->hw_feat.tc_cnt)
+		return -EINVAL;
+
+	pdata->num_tcs = tc;
+	pdata->hw_ops.config_tc(pdata);
+
+	return 0;
+}
+
+static int dwc_eth_set_features(struct net_device *netdev,
+				netdev_features_t features)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+	netdev_features_t rxhash, rxcsum, rxvlan, rxvlan_filter;
+	int ret = 0;
+
+	TRACE("-->");
+
+	rxhash = pdata->netdev_features & NETIF_F_RXHASH;
+	rxcsum = pdata->netdev_features & NETIF_F_RXCSUM;
+	rxvlan = pdata->netdev_features & NETIF_F_HW_VLAN_CTAG_RX;
+	rxvlan_filter = pdata->netdev_features & NETIF_F_HW_VLAN_CTAG_FILTER;
+
+	if ((features & NETIF_F_RXHASH) && !rxhash)
+		ret = hw_ops->enable_rss(pdata);
+	else if (!(features & NETIF_F_RXHASH) && rxhash)
+		ret = hw_ops->disable_rss(pdata);
+	if (ret)
+		return ret;
+
+	if ((features & NETIF_F_RXCSUM) && !rxcsum)
+		hw_ops->enable_rx_csum(pdata);
+	else if (!(features & NETIF_F_RXCSUM) && rxcsum)
+		hw_ops->disable_rx_csum(pdata);
+
+	if ((features & NETIF_F_HW_VLAN_CTAG_RX) && !rxvlan)
+		hw_ops->enable_rx_vlan_stripping(pdata);
+	else if (!(features & NETIF_F_HW_VLAN_CTAG_RX) && rxvlan)
+		hw_ops->disable_rx_vlan_stripping(pdata);
+
+	if ((features & NETIF_F_HW_VLAN_CTAG_FILTER) && !rxvlan_filter)
+		hw_ops->enable_rx_vlan_filtering(pdata);
+	else if (!(features & NETIF_F_HW_VLAN_CTAG_FILTER) && rxvlan_filter)
+		hw_ops->disable_rx_vlan_filtering(pdata);
+
+	pdata->netdev_features = features;
+
+	TRACE("<--");
+
+	return 0;
+}
+
+static void dwc_eth_set_rx_mode(struct net_device *netdev)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+
+	TRACE("-->");
+
+	hw_ops->config_rx_mode(pdata);
+
+	TRACE("<--");
+}
+
+static const struct net_device_ops dwc_eth_netdev_ops = {
+	.ndo_open		= dwc_eth_open,
+	.ndo_stop		= dwc_eth_close,
+	.ndo_start_xmit		= dwc_eth_xmit,
+	.ndo_tx_timeout		= dwc_eth_tx_timeout,
+	.ndo_get_stats64	= dwc_eth_get_stats64,
+	.ndo_change_mtu		= dwc_eth_change_mtu,
+	.ndo_set_mac_address	= dwc_eth_set_mac_address,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl		= dwc_eth_ioctl,
+	.ndo_vlan_rx_add_vid	= dwc_eth_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= dwc_eth_vlan_rx_kill_vid,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= dwc_eth_poll_controller,
+#endif
+	.ndo_setup_tc		= dwc_eth_setup_tc,
+	.ndo_set_features	= dwc_eth_set_features,
+	.ndo_set_rx_mode	= dwc_eth_set_rx_mode,
+};
+
+const struct net_device_ops *dwc_eth_get_netdev_ops(void)
+{
+	return &dwc_eth_netdev_ops;
+}
+
+static void dwc_eth_rx_refresh(struct dwc_eth_channel *channel)
+{
+	struct dwc_eth_pdata *pdata = channel->pdata;
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+	struct dwc_eth_desc_ops *desc_ops = &pdata->desc_ops;
+	struct dwc_eth_ring *ring = channel->rx_ring;
+	struct dwc_eth_desc_data *desc_data;
+
+	while (ring->dirty != ring->cur) {
+		desc_data = DWC_ETH_GET_DESC_DATA(ring, ring->dirty);
+
+		/* Reset desc_data values */
+		desc_ops->unmap_desc_data(pdata, desc_data);
+
+		if (desc_ops->map_rx_buffer(pdata, ring, desc_data))
+			break;
+
+		hw_ops->rx_desc_reset(pdata, desc_data, ring->dirty);
+
+		ring->dirty++;
+	}
+
+	/* Make sure everything is written before the register write */
+	wmb();
+
+	/* Update the Rx Tail Pointer Register with address of
+	 * the last cleaned entry
+	 */
+	desc_data = DWC_ETH_GET_DESC_DATA(ring, ring->dirty - 1);
+	DWC_ETH_DMA_IOWRITE(channel, DMA_CH_RDTR_LO,
+			    lower_32_bits(desc_data->dma_desc_addr));
+}
+
+static struct sk_buff *dwc_eth_create_skb(struct dwc_eth_pdata *pdata,
+					  struct napi_struct *napi,
+					  struct dwc_eth_desc_data *desc_data,
+					  unsigned int len)
+{
+	struct sk_buff *skb;
+	u8 *packet;
+	unsigned int copy_len;
+
+	skb = napi_alloc_skb(napi, desc_data->rx.hdr.dma_len);
+	if (!skb)
+		return NULL;
+
+	/* Start with the header buffer which may contain just the header
+	 * or the header plus data
+	 */
+	dma_sync_single_range_for_cpu(pdata->dev, desc_data->rx.hdr.dma_base,
+				      desc_data->rx.hdr.dma_off,
+				      desc_data->rx.hdr.dma_len,
+				      DMA_FROM_DEVICE);
+
+	packet = page_address(desc_data->rx.hdr.pa.pages) +
+		 desc_data->rx.hdr.pa.pages_offset;
+	copy_len = (desc_data->rx.hdr_len) ? desc_data->rx.hdr_len : len;
+	copy_len = min(desc_data->rx.hdr.dma_len, copy_len);
+	skb_copy_to_linear_data(skb, packet, copy_len);
+	skb_put(skb, copy_len);
+
+	len -= copy_len;
+	if (len) {
+		/* Add the remaining data as a frag */
+		dma_sync_single_range_for_cpu(pdata->dev,
+					      desc_data->rx.buf.dma_base,
+					      desc_data->rx.buf.dma_off,
+					      desc_data->rx.buf.dma_len,
+					      DMA_FROM_DEVICE);
+
+		skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
+				desc_data->rx.buf.pa.pages,
+				desc_data->rx.buf.pa.pages_offset,
+				len, desc_data->rx.buf.dma_len);
+		desc_data->rx.buf.pa.pages = NULL;
+	}
+
+	return skb;
+}
+
+static int dwc_eth_tx_poll(struct dwc_eth_channel *channel)
+{
+	struct dwc_eth_pdata *pdata = channel->pdata;
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+	struct dwc_eth_desc_ops *desc_ops = &pdata->desc_ops;
+	struct dwc_eth_ring *ring = channel->tx_ring;
+	struct dwc_eth_desc_data *desc_data;
+	struct dwc_eth_dma_desc *dma_desc;
+	struct net_device *netdev = pdata->netdev;
+	struct netdev_queue *txq;
+	int processed = 0;
+	unsigned int tx_packets = 0, tx_bytes = 0;
+	unsigned int cur;
+
+	TRACE("-->");
+
+	/* Nothing to do if there isn't a Tx ring for this channel */
+	if (!ring)
+		return 0;
+
+	cur = ring->cur;
+
+	/* Be sure we get ring->cur before accessing descriptor data */
+	smp_rmb();
+
+	txq = netdev_get_tx_queue(netdev, channel->queue_index);
+
+	while ((processed < pdata->tx_desc_max_proc) &&
+	       (ring->dirty != cur)) {
+		desc_data = DWC_ETH_GET_DESC_DATA(ring, ring->dirty);
+		dma_desc = desc_data->dma_desc;
+
+		if (!hw_ops->tx_complete(dma_desc))
+			break;
+
+		/* Make sure descriptor fields are read after reading
+		 * the OWN bit
+		 */
+		dma_rmb();
+
+		if (netif_msg_tx_done(pdata))
+			dwc_eth_dump_tx_desc(pdata, ring, ring->dirty, 1, 0);
+
+		if (hw_ops->is_last_desc(dma_desc)) {
+			tx_packets += desc_data->tx.packets;
+			tx_bytes += desc_data->tx.bytes;
+		}
+
+		/* Free the SKB and reset the descriptor for re-use */
+		desc_ops->unmap_desc_data(pdata, desc_data);
+		hw_ops->tx_desc_reset(desc_data);
+
+		processed++;
+		ring->dirty++;
+	}
+
+	if (!processed)
+		return 0;
+
+	netdev_tx_completed_queue(txq, tx_packets, tx_bytes);
+
+	if ((ring->tx.queue_stopped == 1) &&
+	    (dwc_eth_tx_avail_desc(ring) > pdata->tx_desc_min_free)) {
+		ring->tx.queue_stopped = 0;
+		netif_tx_wake_queue(txq);
+	}
+
+	DBGPR("  processed=%d\n", processed);
+	TRACE("<--");
+
+	return processed;
+}
+
+static int dwc_eth_rx_poll(struct dwc_eth_channel *channel, int budget)
+{
+	struct dwc_eth_pdata *pdata = channel->pdata;
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+	struct dwc_eth_ring *ring = channel->rx_ring;
+	struct dwc_eth_desc_data *desc_data;
+	struct dwc_eth_pkt_info *pkt_info;
+	struct net_device *netdev = pdata->netdev;
+	struct napi_struct *napi;
+	struct sk_buff *skb;
+	struct skb_shared_hwtstamps *hwtstamps;
+	unsigned int incomplete, error, context_next, context;
+	unsigned int len, dma_desc_len, max_len;
+	unsigned int received = 0;
+	int packet_count = 0;
+
+	TRACE("-->");
+	DBGPR("  budget=%d\n", budget);
+
+	/* Nothing to do if there isn't a Rx ring for this channel */
+	if (!ring)
+		return 0;
+
+	incomplete = 0;
+	context_next = 0;
+
+	napi = (pdata->per_channel_irq) ? &channel->napi : &pdata->napi;
+
+	desc_data = DWC_ETH_GET_DESC_DATA(ring, ring->cur);
+	pkt_info = &ring->pkt_info;
+	while (packet_count < budget) {
+		DBGPR("  cur = %d\n", ring->cur);
+
+		/* First time in loop see if we need to restore state */
+		if (!received && desc_data->state_saved) {
+			skb = desc_data->state.skb;
+			error = desc_data->state.error;
+			len = desc_data->state.len;
+		} else {
+			memset(pkt_info, 0, sizeof(*pkt_info));
+			skb = NULL;
+			error = 0;
+			len = 0;
+		}
+
+read_again:
+		desc_data = DWC_ETH_GET_DESC_DATA(ring, ring->cur);
+
+		if (dwc_eth_rx_dirty_desc(ring) > pdata->rx_desc_max_dirty)
+			dwc_eth_rx_refresh(channel);
+
+		if (hw_ops->dev_read(channel))
+			break;
+
+		received++;
+		ring->cur++;
+
+		incomplete = DWC_ETH_GET_BITS(pkt_info->attributes,
+					      RX_PACKET_ATTRIBUTES,
+					      INCOMPLETE);
+		context_next = DWC_ETH_GET_BITS(pkt_info->attributes,
+						RX_PACKET_ATTRIBUTES,
+						CONTEXT_NEXT);
+		context = DWC_ETH_GET_BITS(pkt_info->attributes,
+					   RX_PACKET_ATTRIBUTES,
+					   CONTEXT);
+
+		/* Earlier error, just drain the remaining data */
+		if ((incomplete || context_next) && error)
+			goto read_again;
+
+		if (error || pkt_info->errors) {
+			if (pkt_info->errors)
+				netif_err(pdata, rx_err, netdev,
+					  "error in received packet\n");
+			dev_kfree_skb(skb);
+			goto next_packet;
+		}
+
+		if (!context) {
+			/* Length is cumulative, get this descriptor's length */
+			dma_desc_len = desc_data->rx.len - len;
+			len += dma_desc_len;
+
+			if (dma_desc_len && !skb) {
+				skb = dwc_eth_create_skb(pdata, napi, desc_data,
+							 dma_desc_len);
+				if (!skb)
+					error = 1;
+			} else if (dma_desc_len) {
+				dma_sync_single_range_for_cpu(
+						pdata->dev,
+						desc_data->rx.buf.dma_base,
+						desc_data->rx.buf.dma_off,
+						desc_data->rx.buf.dma_len,
+						DMA_FROM_DEVICE);
+
+				skb_add_rx_frag(
+					skb, skb_shinfo(skb)->nr_frags,
+					desc_data->rx.buf.pa.pages,
+					desc_data->rx.buf.pa.pages_offset,
+					dma_desc_len,
+					desc_data->rx.buf.dma_len);
+				desc_data->rx.buf.pa.pages = NULL;
+			}
+		}
+
+		if (incomplete || context_next)
+			goto read_again;
+
+		if (!skb)
+			goto next_packet;
+
+		/* Be sure we don't exceed the configured MTU */
+		max_len = netdev->mtu + ETH_HLEN;
+		if (!(netdev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
+		    (skb->protocol == htons(ETH_P_8021Q)))
+			max_len += VLAN_HLEN;
+
+		if (skb->len > max_len) {
+			netif_err(pdata, rx_err, netdev,
+				  "packet length exceeds configured MTU\n");
+			dev_kfree_skb(skb);
+			goto next_packet;
+		}
+
+		if (netif_msg_pktdata(pdata))
+			dwc_eth_print_pkt(netdev, skb, false);
+
+		skb_checksum_none_assert(skb);
+		if (DWC_ETH_GET_BITS(pkt_info->attributes,
+				     RX_PACKET_ATTRIBUTES, CSUM_DONE))
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+		if (DWC_ETH_GET_BITS(pkt_info->attributes,
+				     RX_PACKET_ATTRIBUTES, VLAN_CTAG))
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
+					       pkt_info->vlan_ctag);
+
+		if (DWC_ETH_GET_BITS(pkt_info->attributes,
+				     RX_PACKET_ATTRIBUTES, RX_TSTAMP)) {
+			u64 nsec;
+
+			nsec = timecounter_cyc2time(&pdata->tstamp_tc,
+						    pkt_info->rx_tstamp);
+			hwtstamps = skb_hwtstamps(skb);
+			hwtstamps->hwtstamp = ns_to_ktime(nsec);
+		}
+
+		if (DWC_ETH_GET_BITS(pkt_info->attributes,
+				     RX_PACKET_ATTRIBUTES, RSS_HASH))
+			skb_set_hash(skb, pkt_info->rss_hash,
+				     pkt_info->rss_hash_type);
+
+		skb->dev = netdev;
+		skb->protocol = eth_type_trans(skb, netdev);
+		skb_record_rx_queue(skb, channel->queue_index);
+
+		napi_gro_receive(napi, skb);
+
+next_packet:
+		packet_count++;
+	}
+
+	/* Check if we need to save state before leaving */
+	if (received && (incomplete || context_next)) {
+		desc_data = DWC_ETH_GET_DESC_DATA(ring, ring->cur);
+		desc_data->state_saved = 1;
+		desc_data->state.skb = skb;
+		desc_data->state.len = len;
+		desc_data->state.error = error;
+	}
+
+	DBGPR("  packet_count = %d\n", packet_count);
+	TRACE("<--");
+
+	return packet_count;
+}
+
+static int dwc_eth_one_poll(struct napi_struct *napi, int budget)
+{
+	struct dwc_eth_channel *channel = container_of(napi,
+						struct dwc_eth_channel,
+						napi);
+	int processed = 0;
+
+	TRACE("-->");
+	DBGPR("  budget=%d\n", budget);
+
+	/* Cleanup Tx ring first */
+	dwc_eth_tx_poll(channel);
+
+	/* Process Rx ring next */
+	processed = dwc_eth_rx_poll(channel, budget);
+
+	/* If we processed everything, we are done */
+	if (processed < budget) {
+		/* Turn off polling */
+		napi_complete_done(napi, processed);
+
+		/* Enable Tx and Rx interrupts */
+		enable_irq(channel->dma_irq);
+	}
+
+	DBGPR("  received = %d\n", processed);
+	TRACE("<--");
+
+	return processed;
+}
+
+static int dwc_eth_all_poll(struct napi_struct *napi, int budget)
+{
+	struct dwc_eth_pdata *pdata = container_of(napi,
+						   struct dwc_eth_pdata,
+						   napi);
+	struct dwc_eth_channel *channel;
+	int ring_budget;
+	int processed, last_processed;
+	unsigned int i;
+
+	TRACE("-->");
+	DBGPR("  budget=%d\n", budget);
+
+	processed = 0;
+	ring_budget = budget / pdata->rx_ring_count;
+	do {
+		last_processed = processed;
+
+		channel = pdata->channel_head;
+		for (i = 0; i < pdata->channel_count; i++, channel++) {
+			/* Cleanup Tx ring first */
+			dwc_eth_tx_poll(channel);
+
+			/* Process Rx ring next */
+			if (ring_budget > (budget - processed))
+				ring_budget = budget - processed;
+			processed += dwc_eth_rx_poll(channel, ring_budget);
+		}
+	} while ((processed < budget) && (processed != last_processed));
+
+	/* If we processed everything, we are done */
+	if (processed < budget) {
+		/* Turn off polling */
+		napi_complete_done(napi, processed);
+
+		/* Enable Tx and Rx interrupts */
+		dwc_eth_enable_rx_tx_ints(pdata);
+	}
+
+	DBGPR("  received = %d\n", processed);
+	TRACE("<--");
+
+	return processed;
+}
+
+void dwc_eth_dump_tx_desc(struct dwc_eth_pdata *pdata,
+			  struct dwc_eth_ring *ring,
+			  unsigned int idx,
+			  unsigned int count,
+			  unsigned int flag)
+{
+	struct dwc_eth_desc_data *desc_data;
+	struct dwc_eth_dma_desc *dma_desc;
+
+	while (count--) {
+		desc_data = DWC_ETH_GET_DESC_DATA(ring, idx);
+		dma_desc = desc_data->dma_desc;
+
+		netdev_dbg(pdata->netdev, "TX: dma_desc=%p, dma_desc_addr=%pad\n",
+			   desc_data->dma_desc, &desc_data->dma_desc_addr);
+		netdev_dbg(pdata->netdev,
+			   "TX_NORMAL_DESC[%d %s] = %08x:%08x:%08x:%08x\n", idx,
+			   (flag == 1) ? "QUEUED FOR TX" : "TX BY DEVICE",
+			   le32_to_cpu(dma_desc->desc0),
+			   le32_to_cpu(dma_desc->desc1),
+			   le32_to_cpu(dma_desc->desc2),
+			   le32_to_cpu(dma_desc->desc3));
+
+		idx++;
+	}
+}
+
+void dwc_eth_dump_rx_desc(struct dwc_eth_pdata *pdata,
+			  struct dwc_eth_ring *ring,
+			  unsigned int idx)
+{
+	struct dwc_eth_desc_data *desc_data;
+	struct dwc_eth_dma_desc *dma_desc;
+
+	desc_data = DWC_ETH_GET_DESC_DATA(ring, idx);
+	dma_desc = desc_data->dma_desc;
+
+	netdev_dbg(pdata->netdev, "RX: dma_desc=%p, dma_desc_addr=%pad\n",
+		   desc_data->dma_desc, &desc_data->dma_desc_addr);
+	netdev_dbg(pdata->netdev,
+		   "RX_NORMAL_DESC[%d RX BY DEVICE] = %08x:%08x:%08x:%08x\n",
+		   idx,
+		   le32_to_cpu(dma_desc->desc0),
+		   le32_to_cpu(dma_desc->desc1),
+		   le32_to_cpu(dma_desc->desc2),
+		   le32_to_cpu(dma_desc->desc3));
+}
+
+void dwc_eth_print_pkt(struct net_device *netdev,
+		       struct sk_buff *skb, bool tx_rx)
+{
+	struct ethhdr *eth = (struct ethhdr *)skb->data;
+	unsigned char *buf = skb->data;
+	unsigned char buffer[128];
+	unsigned int i, j;
+
+	netdev_dbg(netdev, "\n************** SKB dump ****************\n");
+
+	netdev_dbg(netdev, "%s packet of %d bytes\n",
+		   (tx_rx ? "TX" : "RX"), skb->len);
+
+	netdev_dbg(netdev, "Dst MAC addr: %pM\n", eth->h_dest);
+	netdev_dbg(netdev, "Src MAC addr: %pM\n", eth->h_source);
+	netdev_dbg(netdev, "Protocol: %#06hx\n", ntohs(eth->h_proto));
+
+	for (i = 0, j = 0; i < skb->len;) {
+		j += snprintf(buffer + j, sizeof(buffer) - j, "%02hhx",
+			      buf[i++]);
+
+		if ((i % 32) == 0) {
+			netdev_dbg(netdev, "  %#06x: %s\n", i - 32, buffer);
+			j = 0;
+		} else if ((i % 16) == 0) {
+			buffer[j++] = ' ';
+			buffer[j++] = ' ';
+		} else if ((i % 4) == 0) {
+			buffer[j++] = ' ';
+		}
+	}
+	if (i % 32)
+		netdev_dbg(netdev, "  %#06x: %s\n", i - (i % 32), buffer);
+
+	netdev_dbg(netdev, "\n************** SKB dump ****************\n");
+}
+
+void dwc_eth_get_all_hw_features(struct dwc_eth_pdata *pdata)
+{
+	unsigned int mac_hfr0, mac_hfr1, mac_hfr2;
+	struct dwc_eth_hw_features *hw_feat = &pdata->hw_feat;
+
+	TRACE("-->");
+
+	mac_hfr0 = DWC_ETH_IOREAD(pdata, MAC_HWF0R);
+	mac_hfr1 = DWC_ETH_IOREAD(pdata, MAC_HWF1R);
+	mac_hfr2 = DWC_ETH_IOREAD(pdata, MAC_HWF2R);
+
+	memset(hw_feat, 0, sizeof(*hw_feat));
+
+	hw_feat->version = DWC_ETH_IOREAD(pdata, MAC_VR);
+
+	/* Hardware feature register 0 */
+	hw_feat->phyifsel    = DWC_ETH_GET_BITS(mac_hfr0, MAC_HWF0R, PHYIFSEL);
+	hw_feat->vlhash      = DWC_ETH_GET_BITS(mac_hfr0, MAC_HWF0R, VLHASH);
+	hw_feat->sma         = DWC_ETH_GET_BITS(mac_hfr0, MAC_HWF0R, SMASEL);
+	hw_feat->rwk         = DWC_ETH_GET_BITS(mac_hfr0, MAC_HWF0R, RWKSEL);
+	hw_feat->mgk         = DWC_ETH_GET_BITS(mac_hfr0, MAC_HWF0R, MGKSEL);
+	hw_feat->mmc         = DWC_ETH_GET_BITS(mac_hfr0, MAC_HWF0R, MMCSEL);
+	hw_feat->aoe         = DWC_ETH_GET_BITS(mac_hfr0, MAC_HWF0R, ARPOFFSEL);
+	hw_feat->ts          = DWC_ETH_GET_BITS(mac_hfr0, MAC_HWF0R, TSSEL);
+	hw_feat->eee         = DWC_ETH_GET_BITS(mac_hfr0, MAC_HWF0R, EEESEL);
+	hw_feat->tx_coe      = DWC_ETH_GET_BITS(mac_hfr0, MAC_HWF0R, TXCOESEL);
+	hw_feat->rx_coe      = DWC_ETH_GET_BITS(mac_hfr0, MAC_HWF0R, RXCOESEL);
+	hw_feat->addn_mac    = DWC_ETH_GET_BITS(mac_hfr0, MAC_HWF0R,
+						ADDMACADRSEL);
+	hw_feat->ts_src      = DWC_ETH_GET_BITS(mac_hfr0, MAC_HWF0R, TSSTSSEL);
+	hw_feat->sa_vlan_ins = DWC_ETH_GET_BITS(mac_hfr0, MAC_HWF0R, SAVLANINS);
+
+	/* Hardware feature register 1 */
+	hw_feat->rx_fifo_size  = DWC_ETH_GET_BITS(mac_hfr1, MAC_HWF1R,
+						  RXFIFOSIZE);
+	hw_feat->tx_fifo_size  = DWC_ETH_GET_BITS(mac_hfr1, MAC_HWF1R,
+						  TXFIFOSIZE);
+	hw_feat->adv_ts_hi     = DWC_ETH_GET_BITS(mac_hfr1, MAC_HWF1R,
+						  ADVTHWORD);
+	hw_feat->dma_width     = DWC_ETH_GET_BITS(mac_hfr1, MAC_HWF1R, ADDR64);
+	hw_feat->dcb           = DWC_ETH_GET_BITS(mac_hfr1, MAC_HWF1R, DCBEN);
+	hw_feat->sph           = DWC_ETH_GET_BITS(mac_hfr1, MAC_HWF1R, SPHEN);
+	hw_feat->tso           = DWC_ETH_GET_BITS(mac_hfr1, MAC_HWF1R, TSOEN);
+	hw_feat->dma_debug     = DWC_ETH_GET_BITS(mac_hfr1, MAC_HWF1R, DBGMEMA);
+	hw_feat->rss           = DWC_ETH_GET_BITS(mac_hfr1, MAC_HWF1R, RSSEN);
+	hw_feat->tc_cnt	       = DWC_ETH_GET_BITS(mac_hfr1, MAC_HWF1R, NUMTC);
+	hw_feat->hash_table_size = DWC_ETH_GET_BITS(mac_hfr1, MAC_HWF1R,
+						    HASHTBLSZ);
+	hw_feat->l3l4_filter_num = DWC_ETH_GET_BITS(mac_hfr1, MAC_HWF1R,
+						    L3L4FNUM);
+
+	/* Hardware feature register 2 */
+	hw_feat->rx_q_cnt     = DWC_ETH_GET_BITS(mac_hfr2, MAC_HWF2R, RXQCNT);
+	hw_feat->tx_q_cnt     = DWC_ETH_GET_BITS(mac_hfr2, MAC_HWF2R, TXQCNT);
+	hw_feat->rx_ch_cnt    = DWC_ETH_GET_BITS(mac_hfr2, MAC_HWF2R, RXCHCNT);
+	hw_feat->tx_ch_cnt    = DWC_ETH_GET_BITS(mac_hfr2, MAC_HWF2R, TXCHCNT);
+	hw_feat->pps_out_num  = DWC_ETH_GET_BITS(mac_hfr2, MAC_HWF2R,
+						 PPSOUTNUM);
+	hw_feat->aux_snap_num = DWC_ETH_GET_BITS(mac_hfr2, MAC_HWF2R,
+						 AUXSNAPNUM);
+
+	/* Translate the Hash Table size into actual number */
+	switch (hw_feat->hash_table_size) {
+	case 0:
+		break;
+	case 1:
+		hw_feat->hash_table_size = 64;
+		break;
+	case 2:
+		hw_feat->hash_table_size = 128;
+		break;
+	case 3:
+		hw_feat->hash_table_size = 256;
+		break;
+	}
+
+	/* Translate the address width setting into actual number */
+	switch (hw_feat->dma_width) {
+	case 0:
+		hw_feat->dma_width = 32;
+		break;
+	case 1:
+		hw_feat->dma_width = 40;
+		break;
+	case 2:
+		hw_feat->dma_width = 48;
+		break;
+	default:
+		hw_feat->dma_width = 32;
+	}
+
+	/* The Queue, Channel and TC counts are zero based so increment them
+	 * to get the actual number
+	 */
+	hw_feat->rx_q_cnt++;
+	hw_feat->tx_q_cnt++;
+	hw_feat->rx_ch_cnt++;
+	hw_feat->tx_ch_cnt++;
+	hw_feat->tc_cnt++;
+
+	TRACE("<--");
+}
+
+void dwc_eth_print_all_hw_features(struct dwc_eth_pdata *pdata)
+{
+	char *str = NULL;
+
+	TRACE("-->");
+
+	DBGPR("\n");
+	DBGPR("=====================================================\n");
+	DBGPR("\n");
+	DBGPR("HW support following features\n");
+	DBGPR("\n");
+	/* HW Feature Register0 */
+	DBGPR("VLAN Hash Filter Selected                   : %s\n",
+	      pdata->hw_feat.vlhash ? "YES" : "NO");
+	DBGPR("SMA (MDIO) Interface                        : %s\n",
+	      pdata->hw_feat.sma ? "YES" : "NO");
+	DBGPR("PMT Remote Wake-up Packet Enable            : %s\n",
+	      pdata->hw_feat.rwk ? "YES" : "NO");
+	DBGPR("PMT Magic Packet Enable                     : %s\n",
+	      pdata->hw_feat.mgk ? "YES" : "NO");
+	DBGPR("RMON/MMC Module Enable                      : %s\n",
+	      pdata->hw_feat.mmc ? "YES" : "NO");
+	DBGPR("ARP Offload Enabled                         : %s\n",
+	      pdata->hw_feat.aoe ? "YES" : "NO");
+	DBGPR("IEEE 1588-2008 Timestamp Enabled            : %s\n",
+	      pdata->hw_feat.ts ? "YES" : "NO");
+	DBGPR("Energy Efficient Ethernet Enabled           : %s\n",
+	      pdata->hw_feat.eee ? "YES" : "NO");
+	DBGPR("Transmit Checksum Offload Enabled           : %s\n",
+	      pdata->hw_feat.tx_coe ? "YES" : "NO");
+	DBGPR("Receive Checksum Offload Enabled            : %s\n",
+	      pdata->hw_feat.rx_coe ? "YES" : "NO");
+	DBGPR("Additional MAC Addresses 1-31 Selected      : %s\n",
+	      pdata->hw_feat.addn_mac ? "YES" : "NO");
+
+	switch (pdata->hw_feat.ts_src) {
+	case 0:
+		str = "RESERVED";
+		break;
+	case 1:
+		str = "INTERNAL";
+		break;
+	case 2:
+		str = "EXTERNAL";
+		break;
+	case 3:
+		str = "BOTH";
+		break;
+	}
+	DBGPR("Timestamp System Time Source                : %s\n", str);
+
+	DBGPR("Source Address or VLAN Insertion Enable     : %s\n",
+	      pdata->hw_feat.sa_vlan_ins ? "YES" : "NO");
+
+	/* HW Feature Register1 */
+	switch (pdata->hw_feat.rx_fifo_size) {
+	case 0:
+		str = "128 bytes";
+		break;
+	case 1:
+		str = "256 bytes";
+		break;
+	case 2:
+		str = "512 bytes";
+		break;
+	case 3:
+		str = "1 KBytes";
+		break;
+	case 4:
+		str = "2 KBytes";
+		break;
+	case 5:
+		str = "4 KBytes";
+		break;
+	case 6:
+		str = "8 KBytes";
+		break;
+	case 7:
+		str = "16 KBytes";
+		break;
+	case 8:
+		str = "32 kBytes";
+		break;
+	case 9:
+		str = "64 KBytes";
+		break;
+	case 10:
+		str = "128 KBytes";
+		break;
+	case 11:
+		str = "256 KBytes";
+		break;
+	default:
+		str = "RESERVED";
+	}
+	DBGPR("MTL Receive FIFO Size                       : %s\n", str);
+
+	switch (pdata->hw_feat.tx_fifo_size) {
+	case 0:
+		str = "128 bytes";
+		break;
+	case 1:
+		str = "256 bytes";
+		break;
+	case 2:
+		str = "512 bytes";
+		break;
+	case 3:
+		str = "1 KBytes";
+		break;
+	case 4:
+		str = "2 KBytes";
+		break;
+	case 5:
+		str = "4 KBytes";
+		break;
+	case 6:
+		str = "8 KBytes";
+		break;
+	case 7:
+		str = "16 KBytes";
+		break;
+	case 8:
+		str = "32 kBytes";
+		break;
+	case 9:
+		str = "64 KBytes";
+		break;
+	case 10:
+		str = "128 KBytes";
+		break;
+	case 11:
+		str = "256 KBytes";
+		break;
+	default:
+		str = "RESERVED";
+	}
+	DBGPR("MTL Transmit FIFO Size                      : %s\n", str);
+
+	DBGPR("IEEE 1588 High Word Register Enable         : %s\n",
+	      pdata->hw_feat.adv_ts_hi ? "YES" : "NO");
+	DBGPR("Address width                               : %u\n",
+	      pdata->hw_feat.dma_width);
+	DBGPR("DCB Feature Enable                          : %s\n",
+	      pdata->hw_feat.dcb ? "YES" : "NO");
+	DBGPR("Split Header Feature Enable                 : %s\n",
+	      pdata->hw_feat.sph ? "YES" : "NO");
+	DBGPR("TCP Segmentation Offload Enable             : %s\n",
+	      pdata->hw_feat.tso ? "YES" : "NO");
+	DBGPR("DMA Debug Registers Enabled                 : %s\n",
+	      pdata->hw_feat.dma_debug ? "YES" : "NO");
+	DBGPR("RSS Feature Enabled                         : %s\n",
+	      pdata->hw_feat.rss ? "YES" : "NO");
+	DBGPR("Number of Traffic classes                   : %u\n",
+	      (pdata->hw_feat.tc_cnt));
+	DBGPR("Hash Table Size                             : %u\n",
+	      pdata->hw_feat.hash_table_size);
+	DBGPR("Total number of L3 or L4 Filters            : %u L3/L4 Filter\n",
+	      pdata->hw_feat.l3l4_filter_num);
+
+	/* HW Feature Register2 */
+	DBGPR("Number of MTL Receive Queues                : %u\n",
+	      pdata->hw_feat.rx_q_cnt);
+	DBGPR("Number of MTL Transmit Queues               : %u\n",
+	      pdata->hw_feat.tx_q_cnt);
+	DBGPR("Number of DMA Receive Channels              : %u\n",
+	      pdata->hw_feat.rx_ch_cnt);
+	DBGPR("Number of DMA Transmit Channels             : %u\n",
+	      pdata->hw_feat.tx_ch_cnt);
+
+	switch (pdata->hw_feat.pps_out_num) {
+	case 0:
+		str = "No PPS output";
+		break;
+	case 1:
+		str = "1 PPS output";
+		break;
+	case 2:
+		str = "2 PPS output";
+		break;
+	case 3:
+		str = "3 PPS output";
+		break;
+	case 4:
+		str = "4 PPS output";
+		break;
+	default:
+		str = "RESERVED";
+	}
+	DBGPR("Number of PPS Outputs                       : %s\n", str);
+
+	switch (pdata->hw_feat.aux_snap_num) {
+	case 0:
+		str = "No auxiliary input";
+		break;
+	case 1:
+		str = "1 auxiliary input";
+		break;
+	case 2:
+		str = "2 auxiliary input";
+		break;
+	case 3:
+		str = "3 auxiliary input";
+		break;
+	case 4:
+		str = "4 auxiliary input";
+		break;
+	default:
+		str = "RESERVED";
+	}
+	DBGPR("Number of Auxiliary Snapshot Inputs         : %s", str);
+
+	DBGPR("\n");
+	DBGPR("=====================================================\n");
+	DBGPR("\n");
+
+	TRACE("<--");
+}
+
+int dwc_eth_powerdown(struct net_device *netdev, unsigned int caller)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+	unsigned long flags;
+
+	TRACE("-->");
+
+	if (!netif_running(netdev) ||
+	    (caller == DWC_ETH_IOCTL_CONTEXT && pdata->power_down)) {
+		netdev_alert(netdev, "Device is already powered down\n");
+		return -EINVAL;
+	}
+
+	if (pdata->phydev)
+		phy_stop(pdata->phydev);
+
+	spin_lock_irqsave(&pdata->lock, flags);
+
+	if (caller == DWC_ETH_DRIVER_CONTEXT)
+		netif_device_detach(netdev);
+
+	netif_tx_stop_all_queues(netdev);
+
+	dwc_eth_stop_timers(pdata);
+	flush_workqueue(pdata->dev_workqueue);
+
+	hw_ops->powerdown_tx(pdata);
+	hw_ops->powerdown_rx(pdata);
+
+	dwc_eth_napi_disable(pdata, 0);
+
+	pdata->power_down = 1;
+
+	spin_unlock_irqrestore(&pdata->lock, flags);
+
+	TRACE("<--");
+
+	return 0;
+}
+
+int dwc_eth_powerup(struct net_device *netdev, unsigned int caller)
+{
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+	unsigned long flags;
+
+	TRACE("-->");
+
+	if (!netif_running(netdev) ||
+	    (caller == DWC_ETH_IOCTL_CONTEXT && !pdata->power_down)) {
+		netdev_alert(netdev, "Device is already powered up\n");
+		return -EINVAL;
+	}
+
+	spin_lock_irqsave(&pdata->lock, flags);
+
+	pdata->power_down = 0;
+
+	if (pdata->phydev)
+		phy_start(pdata->phydev);
+
+	dwc_eth_napi_enable(pdata, 0);
+
+	hw_ops->powerup_tx(pdata);
+	hw_ops->powerup_rx(pdata);
+
+	if (caller == DWC_ETH_DRIVER_CONTEXT)
+		netif_device_attach(netdev);
+
+	netif_tx_start_all_queues(netdev);
+
+	spin_unlock_irqrestore(&pdata->lock, flags);
+
+	TRACE("<--");
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/synopsys/dwc/dwc-eth-ptp.c b/drivers/net/ethernet/synopsys/dwc/dwc-eth-ptp.c
new file mode 100644
index 0000000..40161ac
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc/dwc-eth-ptp.c
@@ -0,0 +1,216 @@
+/*
+ * Synopsys DesignWare Ethernet Driver
+ *
+ * Copyright (c) 2014-2016 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This file is free software; you may copy, redistribute and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, either version 2 of the License, or (at
+ * your option) any later version.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/clk.h>
+#include <linux/clocksource.h>
+#include <linux/ptp_clock_kernel.h>
+#include <linux/net_tstamp.h>
+
+#include "dwc-eth.h"
+#include "dwc-eth-regacc.h"
+
+static cycle_t dwc_eth_cc_read(const struct cyclecounter *cc)
+{
+	struct dwc_eth_pdata *pdata = container_of(cc,
+						   struct dwc_eth_pdata,
+						   tstamp_cc);
+	u64 nsec;
+
+	nsec = pdata->hw_ops.get_tstamp_time(pdata);
+
+	return nsec;
+}
+
+static int dwc_eth_adjfreq(struct ptp_clock_info *info, s32 delta)
+{
+	struct dwc_eth_pdata *pdata = container_of(info,
+						   struct dwc_eth_pdata,
+						   ptp_clock_info);
+	unsigned long flags;
+	u64 adjust;
+	u32 addend, diff;
+	unsigned int neg_adjust = 0;
+
+	if (delta < 0) {
+		neg_adjust = 1;
+		delta = -delta;
+	}
+
+	adjust = pdata->tstamp_addend;
+	adjust *= delta;
+	diff = div_u64(adjust, 1000000000UL);
+
+	addend = (neg_adjust) ? pdata->tstamp_addend - diff :
+				pdata->tstamp_addend + diff;
+
+	spin_lock_irqsave(&pdata->tstamp_lock, flags);
+
+	pdata->hw_ops.update_tstamp_addend(pdata, addend);
+
+	spin_unlock_irqrestore(&pdata->tstamp_lock, flags);
+
+	return 0;
+}
+
+static int dwc_eth_adjtime(struct ptp_clock_info *info, s64 delta)
+{
+	struct dwc_eth_pdata *pdata = container_of(info,
+						   struct dwc_eth_pdata,
+						   ptp_clock_info);
+	unsigned long flags;
+
+	spin_lock_irqsave(&pdata->tstamp_lock, flags);
+
+	timecounter_adjtime(&pdata->tstamp_tc, delta);
+
+	spin_unlock_irqrestore(&pdata->tstamp_lock, flags);
+
+	return 0;
+}
+
+static int dwc_eth_gettime(struct ptp_clock_info *info, struct timespec64 *ts)
+{
+	struct dwc_eth_pdata *pdata = container_of(info,
+						   struct dwc_eth_pdata,
+						   ptp_clock_info);
+	unsigned long flags;
+	u64 nsec;
+
+	spin_lock_irqsave(&pdata->tstamp_lock, flags);
+
+	nsec = timecounter_read(&pdata->tstamp_tc);
+
+	spin_unlock_irqrestore(&pdata->tstamp_lock, flags);
+
+	*ts = ns_to_timespec64(nsec);
+
+	return 0;
+}
+
+static int dwc_eth_settime(struct ptp_clock_info *info,
+			   const struct timespec64 *ts)
+{
+	struct dwc_eth_pdata *pdata = container_of(info,
+						   struct dwc_eth_pdata,
+						   ptp_clock_info);
+	unsigned long flags;
+	u64 nsec;
+
+	nsec = timespec64_to_ns(ts);
+
+	spin_lock_irqsave(&pdata->tstamp_lock, flags);
+
+	timecounter_init(&pdata->tstamp_tc, &pdata->tstamp_cc, nsec);
+
+	spin_unlock_irqrestore(&pdata->tstamp_lock, flags);
+
+	return 0;
+}
+
+static int dwc_eth_enable(struct ptp_clock_info *info,
+			  struct ptp_clock_request *request, int on)
+{
+	return -EOPNOTSUPP;
+}
+
+void dwc_eth_ptp_register(struct dwc_eth_pdata *pdata)
+{
+	struct ptp_clock_info *info = &pdata->ptp_clock_info;
+	struct ptp_clock *clock;
+	struct cyclecounter *cc = &pdata->tstamp_cc;
+	u64 dividend;
+
+	snprintf(info->name, sizeof(info->name), "%s",
+		 netdev_name(pdata->netdev));
+	info->owner = THIS_MODULE;
+	info->max_adj = pdata->ptpclk_rate;
+	info->adjfreq = dwc_eth_adjfreq;
+	info->adjtime = dwc_eth_adjtime;
+	info->gettime64 = dwc_eth_gettime;
+	info->settime64 = dwc_eth_settime;
+	info->enable = dwc_eth_enable;
+
+	clock = ptp_clock_register(info, pdata->dev);
+	if (IS_ERR(clock)) {
+		dev_err(pdata->dev, "ptp_clock_register failed\n");
+		return;
+	}
+
+	pdata->ptp_clock = clock;
+
+	/* Calculate the addend:
+	 *   addend = 2^32 / (PTP ref clock / 50Mhz)
+	 *          = (2^32 * 50Mhz) / PTP ref clock
+	 */
+	dividend = 50000000;
+	dividend <<= 32;
+	pdata->tstamp_addend = div_u64(dividend, pdata->ptpclk_rate);
+
+	/* Setup the timecounter */
+	cc->read = dwc_eth_cc_read;
+	cc->mask = CLOCKSOURCE_MASK(64);
+	cc->mult = 1;
+	cc->shift = 0;
+
+	timecounter_init(&pdata->tstamp_tc, &pdata->tstamp_cc,
+			 ktime_to_ns(ktime_get_real()));
+
+	/* Disable all timestamping to start */
+	DWC_ETH_IOWRITE(pdata, MAC_TCR, 0);
+	pdata->tstamp_config.tx_type = HWTSTAMP_TX_OFF;
+	pdata->tstamp_config.rx_filter = HWTSTAMP_FILTER_NONE;
+}
+
+void dwc_eth_ptp_unregister(struct dwc_eth_pdata *pdata)
+{
+	if (pdata->ptp_clock)
+		ptp_clock_unregister(pdata->ptp_clock);
+}
diff --git a/drivers/net/ethernet/synopsys/dwc/dwc-eth-regacc.h b/drivers/net/ethernet/synopsys/dwc/dwc-eth-regacc.h
new file mode 100644
index 0000000..0fbbfb9
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc/dwc-eth-regacc.h
@@ -0,0 +1,1115 @@
+/*
+ * Synopsys DesignWare Ethernet Driver
+ *
+ * Copyright (c) 2014-2016 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This file is free software; you may copy, redistribute and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, either version 2 of the License, or (at
+ * your option) any later version.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __DWC_ETH_REGACC_H__
+#define __DWC_ETH_REGACC_H__
+
+/* DMA register offsets */
+#define DMA_MR				0x3000
+#define DMA_SBMR			0x3004
+#define DMA_ISR				0x3008
+#define DMA_AXIARCR			0x3010
+#define DMA_AXIAWCR			0x3018
+#define DMA_DSR0			0x3020
+#define DMA_DSR1			0x3024
+#define DMA_TXEDMACR			0x3040
+#define DMA_RXEDMACR			0x3044
+
+/* DMA register entry bit positions and sizes */
+#define DMA_AXIARCR_DRC_POS		0
+#define DMA_AXIARCR_DRC_LEN		4
+#define DMA_AXIARCR_DRD_POS		4
+#define DMA_AXIARCR_DRD_LEN		2
+#define DMA_AXIARCR_TEC_POS		8
+#define DMA_AXIARCR_TEC_LEN		4
+#define DMA_AXIARCR_TED_POS		12
+#define DMA_AXIARCR_TED_LEN		2
+#define DMA_AXIARCR_THC_POS		16
+#define DMA_AXIARCR_THC_LEN		4
+#define DMA_AXIARCR_THD_POS		20
+#define DMA_AXIARCR_THD_LEN		2
+#define DMA_AXIAWCR_DWC_POS		0
+#define DMA_AXIAWCR_DWC_LEN		4
+#define DMA_AXIAWCR_DWD_POS		4
+#define DMA_AXIAWCR_DWD_LEN		2
+#define DMA_AXIAWCR_RPC_POS		8
+#define DMA_AXIAWCR_RPC_LEN		4
+#define DMA_AXIAWCR_RPD_POS		12
+#define DMA_AXIAWCR_RPD_LEN		2
+#define DMA_AXIAWCR_RHC_POS		16
+#define DMA_AXIAWCR_RHC_LEN		4
+#define DMA_AXIAWCR_RHD_POS		20
+#define DMA_AXIAWCR_RHD_LEN		2
+#define DMA_AXIAWCR_TDC_POS		24
+#define DMA_AXIAWCR_TDC_LEN		4
+#define DMA_AXIAWCR_TDD_POS		28
+#define DMA_AXIAWCR_TDD_LEN		2
+#define DMA_ISR_MACIS_POS		17
+#define DMA_ISR_MACIS_LEN		1
+#define DMA_ISR_MTLIS_POS		16
+#define DMA_ISR_MTLIS_LEN		1
+#define DMA_MR_SWR_POS			0
+#define DMA_MR_SWR_LEN			1
+#define DMA_SBMR_EAME_POS		11
+#define DMA_SBMR_EAME_LEN		1
+#define DMA_SBMR_BLEN_64_POS		5
+#define DMA_SBMR_BLEN_64_LEN		1
+#define DMA_SBMR_BLEN_128_POS		6
+#define DMA_SBMR_BLEN_128_LEN		1
+#define DMA_SBMR_BLEN_256_POS		7
+#define DMA_SBMR_BLEN_256_LEN		1
+#define DMA_SBMR_UNDEF_POS		0
+#define DMA_SBMR_UNDEF_LEN		1
+#define DMA_TXEDMACR_TDPS_POS		0
+#define DMA_TXEDMACR_TDPS_LEN		3
+#define DMA_TXEDMACR_TEDM_POS		30
+#define DMA_TXEDMACR_TEDM_LEN		2
+#define DMA_RXEDMACR_RDPS_POS		0
+#define DMA_RXEDMACR_RDPS_LEN		3
+#define DMA_RXEDMACR_REDM_POS		30
+#define DMA_RXEDMACR_REDM_LEN		2
+
+/* DMA register values */
+#define DMA_DSR_RPS_LEN			4
+#define DMA_DSR_TPS_LEN			4
+#define DMA_DSR_Q_LEN			(DMA_DSR_RPS_LEN + DMA_DSR_TPS_LEN)
+#define DMA_DSR0_RPS_START		8
+#define DMA_DSR0_TPS_START		12
+#define DMA_DSRX_FIRST_QUEUE		3
+#define DMA_DSRX_INC			4
+#define DMA_DSRX_QPR			4
+#define DMA_DSRX_RPS_START		0
+#define DMA_DSRX_TPS_START		4
+#define DMA_TPS_STOPPED			0x00
+#define DMA_TPS_SUSPENDED		0x06
+
+/* DMA channel register offsets
+ *   Multiple channels can be active.  The first channel has registers
+ *   that begin at 0x3100.  Each subsequent channel has registers that
+ *   are accessed using an offset of 0x80 from the previous channel.
+ */
+#define DMA_CH_BASE			0x3100
+#define DMA_CH_INC			0x80
+
+#define DMA_CH_CR			0x00
+#define DMA_CH_TCR			0x04
+#define DMA_CH_RCR			0x08
+#define DMA_CH_TDLR_HI			0x10
+#define DMA_CH_TDLR_LO			0x14
+#define DMA_CH_RDLR_HI			0x18
+#define DMA_CH_RDLR_LO			0x1c
+#define DMA_CH_TDTR_LO			0x24
+#define DMA_CH_RDTR_LO			0x2c
+#define DMA_CH_TDRLR			0x30
+#define DMA_CH_RDRLR			0x34
+#define DMA_CH_IER			0x38
+#define DMA_CH_RIWT			0x3c
+#define DMA_CH_CATDR_LO			0x44
+#define DMA_CH_CARDR_LO			0x4c
+#define DMA_CH_CATBR_HI			0x50
+#define DMA_CH_CATBR_LO			0x54
+#define DMA_CH_CARBR_HI			0x58
+#define DMA_CH_CARBR_LO			0x5c
+#define DMA_CH_SR			0x60
+
+/* DMA channel register entry bit positions and sizes */
+#define DMA_CH_CR_PBLX8_POS		16
+#define DMA_CH_CR_PBLX8_LEN		1
+#define DMA_CH_CR_SPH_POS		24
+#define DMA_CH_CR_SPH_LEN		1
+#define DMA_CH_IER_AIE_POS		15
+#define DMA_CH_IER_AIE_LEN		1
+#define DMA_CH_IER_FBEE_POS		12
+#define DMA_CH_IER_FBEE_LEN		1
+#define DMA_CH_IER_NIE_POS		16
+#define DMA_CH_IER_NIE_LEN		1
+#define DMA_CH_IER_RBUE_POS		7
+#define DMA_CH_IER_RBUE_LEN		1
+#define DMA_CH_IER_RIE_POS		6
+#define DMA_CH_IER_RIE_LEN		1
+#define DMA_CH_IER_RSE_POS		8
+#define DMA_CH_IER_RSE_LEN		1
+#define DMA_CH_IER_TBUE_POS		2
+#define DMA_CH_IER_TBUE_LEN		1
+#define DMA_CH_IER_TIE_POS		0
+#define DMA_CH_IER_TIE_LEN		1
+#define DMA_CH_IER_TXSE_POS		1
+#define DMA_CH_IER_TXSE_LEN		1
+#define DMA_CH_RCR_PBL_POS		16
+#define DMA_CH_RCR_PBL_LEN		6
+#define DMA_CH_RCR_RBSZ_POS		1
+#define DMA_CH_RCR_RBSZ_LEN		14
+#define DMA_CH_RCR_SR_POS		0
+#define DMA_CH_RCR_SR_LEN		1
+#define DMA_CH_RIWT_RWT_POS		0
+#define DMA_CH_RIWT_RWT_LEN		8
+#define DMA_CH_SR_FBE_POS		12
+#define DMA_CH_SR_FBE_LEN		1
+#define DMA_CH_SR_RBU_POS		7
+#define DMA_CH_SR_RBU_LEN		1
+#define DMA_CH_SR_RI_POS		6
+#define DMA_CH_SR_RI_LEN		1
+#define DMA_CH_SR_RPS_POS		8
+#define DMA_CH_SR_RPS_LEN		1
+#define DMA_CH_SR_TBU_POS		2
+#define DMA_CH_SR_TBU_LEN		1
+#define DMA_CH_SR_TI_POS		0
+#define DMA_CH_SR_TI_LEN		1
+#define DMA_CH_SR_TPS_POS		1
+#define DMA_CH_SR_TPS_LEN		1
+#define DMA_CH_TCR_OSP_POS		4
+#define DMA_CH_TCR_OSP_LEN		1
+#define DMA_CH_TCR_PBL_POS		16
+#define DMA_CH_TCR_PBL_LEN		6
+#define DMA_CH_TCR_ST_POS		0
+#define DMA_CH_TCR_ST_LEN		1
+#define DMA_CH_TCR_TSE_POS		12
+#define DMA_CH_TCR_TSE_LEN		1
+
+/* DMA channel register values */
+#define DMA_OSP_DISABLE			0x00
+#define DMA_OSP_ENABLE			0x01
+#define DMA_PBL_1			1
+#define DMA_PBL_2			2
+#define DMA_PBL_4			4
+#define DMA_PBL_8			8
+#define DMA_PBL_16			16
+#define DMA_PBL_32			32
+#define DMA_PBL_64			64      /* 8 x 8 */
+#define DMA_PBL_128			128     /* 8 x 16 */
+#define DMA_PBL_256			256     /* 8 x 32 */
+#define DMA_PBL_X8_DISABLE		0x00
+#define DMA_PBL_X8_ENABLE		0x01
+
+/* MAC register offsets */
+#define MAC_TCR				0x0000
+#define MAC_RCR				0x0004
+#define MAC_PFR				0x0008
+#define MAC_WTR				0x000c
+#define MAC_HTR0			0x0010
+#define MAC_VLANTR			0x0050
+#define MAC_VLANHTR			0x0058
+#define MAC_VLANIR			0x0060
+#define MAC_IVLANIR			0x0064
+#define MAC_RETMR			0x006c
+#define MAC_Q0TFCR			0x0070
+#define MAC_RFCR			0x0090
+#define MAC_RQC0R			0x00a0
+#define MAC_RQC1R			0x00a4
+#define MAC_RQC2R			0x00a8
+#define MAC_RQC3R			0x00ac
+#define MAC_ISR				0x00b0
+#define MAC_IER				0x00b4
+#define MAC_RTSR			0x00b8
+#define MAC_PMTCSR			0x00c0
+#define MAC_RWKPFR			0x00c4
+#define MAC_LPICSR			0x00d0
+#define MAC_LPITCR			0x00d4
+#define MAC_VR				0x0110
+#define MAC_DR				0x0114
+#define MAC_HWF0R			0x011c
+#define MAC_HWF1R			0x0120
+#define MAC_HWF2R			0x0124
+#define MAC_MDIOSCAR			0x0200
+#define MAC_MDIOSCCDR			0x0204
+#define MAC_GPIOCR			0x0278
+#define MAC_GPIOSR			0x027c
+#define MAC_MACA0HR			0x0300
+#define MAC_MACA0LR			0x0304
+#define MAC_MACA1HR			0x0308
+#define MAC_MACA1LR			0x030c
+#define MAC_RSSCR			0x0c80
+#define MAC_RSSAR			0x0c88
+#define MAC_RSSDR			0x0c8c
+#define MAC_TSCR			0x0d00
+#define MAC_SSIR			0x0d04
+#define MAC_STSR			0x0d08
+#define MAC_STNR			0x0d0c
+#define MAC_STSUR			0x0d10
+#define MAC_STNUR			0x0d14
+#define MAC_TSAR			0x0d18
+#define MAC_TSSR			0x0d20
+#define MAC_TXSNR			0x0d30
+#define MAC_TXSSR			0x0d34
+
+#define MAC_QTFCR_INC			4
+#define MAC_MACA_INC			4
+#define MAC_HTR_INC			4
+
+#define MAC_RQC2_INC			4
+#define MAC_RQC2_Q_PER_REG		4
+
+/* MAC register entry bit positions and sizes */
+#define MAC_HWF0R_ADDMACADRSEL_POS	18
+#define MAC_HWF0R_ADDMACADRSEL_LEN	5
+#define MAC_HWF0R_ARPOFFSEL_POS		9
+#define MAC_HWF0R_ARPOFFSEL_LEN		1
+#define MAC_HWF0R_EEESEL_POS		13
+#define MAC_HWF0R_EEESEL_LEN		1
+#define MAC_HWF0R_PHYIFSEL_POS		1
+#define MAC_HWF0R_PHYIFSEL_LEN		2
+#define MAC_HWF0R_MGKSEL_POS		7
+#define MAC_HWF0R_MGKSEL_LEN		1
+#define MAC_HWF0R_MMCSEL_POS		8
+#define MAC_HWF0R_MMCSEL_LEN		1
+#define MAC_HWF0R_RWKSEL_POS		6
+#define MAC_HWF0R_RWKSEL_LEN		1
+#define MAC_HWF0R_RXCOESEL_POS		16
+#define MAC_HWF0R_RXCOESEL_LEN		1
+#define MAC_HWF0R_SAVLANINS_POS		27
+#define MAC_HWF0R_SAVLANINS_LEN		1
+#define MAC_HWF0R_SMASEL_POS		5
+#define MAC_HWF0R_SMASEL_LEN		1
+#define MAC_HWF0R_TSSEL_POS		12
+#define MAC_HWF0R_TSSEL_LEN		1
+#define MAC_HWF0R_TSSTSSEL_POS		25
+#define MAC_HWF0R_TSSTSSEL_LEN		2
+#define MAC_HWF0R_TXCOESEL_POS		14
+#define MAC_HWF0R_TXCOESEL_LEN		1
+#define MAC_HWF0R_VLHASH_POS		4
+#define MAC_HWF0R_VLHASH_LEN		1
+#define MAC_HWF1R_ADDR64_POS		14
+#define MAC_HWF1R_ADDR64_LEN		2
+#define MAC_HWF1R_ADVTHWORD_POS		13
+#define MAC_HWF1R_ADVTHWORD_LEN		1
+#define MAC_HWF1R_DBGMEMA_POS		19
+#define MAC_HWF1R_DBGMEMA_LEN		1
+#define MAC_HWF1R_DCBEN_POS		16
+#define MAC_HWF1R_DCBEN_LEN		1
+#define MAC_HWF1R_HASHTBLSZ_POS		24
+#define MAC_HWF1R_HASHTBLSZ_LEN		3
+#define MAC_HWF1R_L3L4FNUM_POS		27
+#define MAC_HWF1R_L3L4FNUM_LEN		4
+#define MAC_HWF1R_NUMTC_POS		21
+#define MAC_HWF1R_NUMTC_LEN		3
+#define MAC_HWF1R_RSSEN_POS		20
+#define MAC_HWF1R_RSSEN_LEN		1
+#define MAC_HWF1R_RXFIFOSIZE_POS	0
+#define MAC_HWF1R_RXFIFOSIZE_LEN	5
+#define MAC_HWF1R_SPHEN_POS		17
+#define MAC_HWF1R_SPHEN_LEN		1
+#define MAC_HWF1R_TSOEN_POS		18
+#define MAC_HWF1R_TSOEN_LEN		1
+#define MAC_HWF1R_TXFIFOSIZE_POS	6
+#define MAC_HWF1R_TXFIFOSIZE_LEN	5
+#define MAC_HWF2R_AUXSNAPNUM_POS	28
+#define MAC_HWF2R_AUXSNAPNUM_LEN	3
+#define MAC_HWF2R_PPSOUTNUM_POS		24
+#define MAC_HWF2R_PPSOUTNUM_LEN		3
+#define MAC_HWF2R_RXCHCNT_POS		12
+#define MAC_HWF2R_RXCHCNT_LEN		4
+#define MAC_HWF2R_RXQCNT_POS		0
+#define MAC_HWF2R_RXQCNT_LEN		4
+#define MAC_HWF2R_TXCHCNT_POS		18
+#define MAC_HWF2R_TXCHCNT_LEN		4
+#define MAC_HWF2R_TXQCNT_POS		6
+#define MAC_HWF2R_TXQCNT_LEN		4
+#define MAC_IER_TSIE_POS		12
+#define MAC_IER_TSIE_LEN		1
+#define MAC_ISR_MMCRXIS_POS		9
+#define MAC_ISR_MMCRXIS_LEN		1
+#define MAC_ISR_MMCTXIS_POS		10
+#define MAC_ISR_MMCTXIS_LEN		1
+#define MAC_ISR_PMTIS_POS		4
+#define MAC_ISR_PMTIS_LEN		1
+#define MAC_ISR_TSIS_POS		12
+#define MAC_ISR_TSIS_LEN		1
+#define MAC_MACA1HR_AE_POS		31
+#define MAC_MACA1HR_AE_LEN		1
+#define MAC_PFR_HMC_POS			2
+#define MAC_PFR_HMC_LEN			1
+#define MAC_PFR_HPF_POS			10
+#define MAC_PFR_HPF_LEN			1
+#define MAC_PFR_HUC_POS			1
+#define MAC_PFR_HUC_LEN			1
+#define MAC_PFR_PM_POS			4
+#define MAC_PFR_PM_LEN			1
+#define MAC_PFR_PR_POS			0
+#define MAC_PFR_PR_LEN			1
+#define MAC_PFR_VTFE_POS		16
+#define MAC_PFR_VTFE_LEN		1
+#define MAC_PMTCSR_MGKPKTEN_POS		1
+#define MAC_PMTCSR_MGKPKTEN_LEN		1
+#define MAC_PMTCSR_PWRDWN_POS		0
+#define MAC_PMTCSR_PWRDWN_LEN		1
+#define MAC_PMTCSR_RWKFILTRST_POS	31
+#define MAC_PMTCSR_RWKFILTRST_LEN	1
+#define MAC_PMTCSR_RWKPKTEN_POS		2
+#define MAC_PMTCSR_RWKPKTEN_LEN		1
+#define MAC_Q0TFCR_PT_POS		16
+#define MAC_Q0TFCR_PT_LEN		16
+#define MAC_Q0TFCR_TFE_POS		1
+#define MAC_Q0TFCR_TFE_LEN		1
+#define MAC_RCR_ACS_POS			1
+#define MAC_RCR_ACS_LEN			1
+#define MAC_RCR_CST_POS			2
+#define MAC_RCR_CST_LEN			1
+#define MAC_RCR_DCRCC_POS		3
+#define MAC_RCR_DCRCC_LEN		1
+#define MAC_RCR_HDSMS_POS		12
+#define MAC_RCR_HDSMS_LEN		3
+#define MAC_RCR_IPC_POS			9
+#define MAC_RCR_IPC_LEN			1
+#define MAC_RCR_JE_POS			8
+#define MAC_RCR_JE_LEN			1
+#define MAC_RCR_LM_POS			10
+#define MAC_RCR_LM_LEN			1
+#define MAC_RCR_RE_POS			0
+#define MAC_RCR_RE_LEN			1
+#define MAC_RFCR_PFCE_POS		8
+#define MAC_RFCR_PFCE_LEN		1
+#define MAC_RFCR_RFE_POS		0
+#define MAC_RFCR_RFE_LEN		1
+#define MAC_RFCR_UP_POS			1
+#define MAC_RFCR_UP_LEN			1
+#define MAC_RQC0R_RXQ0EN_POS		0
+#define MAC_RQC0R_RXQ0EN_LEN		2
+#define MAC_RSSAR_ADDRT_POS		2
+#define MAC_RSSAR_ADDRT_LEN		1
+#define MAC_RSSAR_CT_POS		1
+#define MAC_RSSAR_CT_LEN		1
+#define MAC_RSSAR_OB_POS		0
+#define MAC_RSSAR_OB_LEN		1
+#define MAC_RSSAR_RSSIA_POS		8
+#define MAC_RSSAR_RSSIA_LEN		8
+#define MAC_RSSCR_IP2TE_POS		1
+#define MAC_RSSCR_IP2TE_LEN		1
+#define MAC_RSSCR_RSSE_POS		0
+#define MAC_RSSCR_RSSE_LEN		1
+#define MAC_RSSCR_TCP4TE_POS		2
+#define MAC_RSSCR_TCP4TE_LEN		1
+#define MAC_RSSCR_UDP4TE_POS		3
+#define MAC_RSSCR_UDP4TE_LEN		1
+#define MAC_RSSDR_DMCH_POS		0
+#define MAC_RSSDR_DMCH_LEN		4
+#define MAC_SSIR_SNSINC_POS		8
+#define MAC_SSIR_SNSINC_LEN		8
+#define MAC_SSIR_SSINC_POS		16
+#define MAC_SSIR_SSINC_LEN		8
+#define MAC_TCR_SS_POS			28
+#define MAC_TCR_SS_LEN			3
+#define MAC_TCR_TE_POS			0
+#define MAC_TCR_TE_LEN			1
+#define MAC_TSCR_AV8021ASMEN_POS	28
+#define MAC_TSCR_AV8021ASMEN_LEN	1
+#define MAC_TSCR_SNAPTYPSEL_POS		16
+#define MAC_TSCR_SNAPTYPSEL_LEN		2
+#define MAC_TSCR_TSADDREG_POS		5
+#define MAC_TSCR_TSADDREG_LEN		1
+#define MAC_TSCR_TSCFUPDT_POS		1
+#define MAC_TSCR_TSCFUPDT_LEN		1
+#define MAC_TSCR_TSCTRLSSR_POS		9
+#define MAC_TSCR_TSCTRLSSR_LEN		1
+#define MAC_TSCR_TSENA_POS		0
+#define MAC_TSCR_TSENA_LEN		1
+#define MAC_TSCR_TSENALL_POS		8
+#define MAC_TSCR_TSENALL_LEN		1
+#define MAC_TSCR_TSEVNTENA_POS		14
+#define MAC_TSCR_TSEVNTENA_LEN		1
+#define MAC_TSCR_TSINIT_POS		2
+#define MAC_TSCR_TSINIT_LEN		1
+#define MAC_TSCR_TSIPENA_POS		11
+#define MAC_TSCR_TSIPENA_LEN		1
+#define MAC_TSCR_TSIPV4ENA_POS		13
+#define MAC_TSCR_TSIPV4ENA_LEN		1
+#define MAC_TSCR_TSIPV6ENA_POS		12
+#define MAC_TSCR_TSIPV6ENA_LEN		1
+#define MAC_TSCR_TSMSTRENA_POS		15
+#define MAC_TSCR_TSMSTRENA_LEN		1
+#define MAC_TSCR_TSVER2ENA_POS		10
+#define MAC_TSCR_TSVER2ENA_LEN		1
+#define MAC_TSCR_TXTSSTSM_POS		24
+#define MAC_TSCR_TXTSSTSM_LEN		1
+#define MAC_TSSR_TXTSC_POS		15
+#define MAC_TSSR_TXTSC_LEN		1
+#define MAC_TXSNR_TXTSSTSMIS_POS	31
+#define MAC_TXSNR_TXTSSTSMIS_LEN	1
+#define MAC_VLANHTR_VLHT_POS		0
+#define MAC_VLANHTR_VLHT_LEN		16
+#define MAC_VLANIR_VLTI_POS		20
+#define MAC_VLANIR_VLTI_LEN		1
+#define MAC_VLANIR_CSVL_POS		19
+#define MAC_VLANIR_CSVL_LEN		1
+#define MAC_VLANTR_DOVLTC_POS		20
+#define MAC_VLANTR_DOVLTC_LEN		1
+#define MAC_VLANTR_ERSVLM_POS		19
+#define MAC_VLANTR_ERSVLM_LEN		1
+#define MAC_VLANTR_ESVL_POS		18
+#define MAC_VLANTR_ESVL_LEN		1
+#define MAC_VLANTR_ETV_POS		16
+#define MAC_VLANTR_ETV_LEN		1
+#define MAC_VLANTR_EVLS_POS		21
+#define MAC_VLANTR_EVLS_LEN		2
+#define MAC_VLANTR_EVLRXS_POS		24
+#define MAC_VLANTR_EVLRXS_LEN		1
+#define MAC_VLANTR_VL_POS		0
+#define MAC_VLANTR_VL_LEN		16
+#define MAC_VLANTR_VTHM_POS		25
+#define MAC_VLANTR_VTHM_LEN		1
+#define MAC_VLANTR_VTIM_POS		17
+#define MAC_VLANTR_VTIM_LEN		1
+#define MAC_VR_DEVID_POS		8
+#define MAC_VR_DEVID_LEN		8
+#define MAC_VR_SNPSVER_POS		0
+#define MAC_VR_SNPSVER_LEN		8
+#define MAC_VR_USERVER_POS		16
+#define MAC_VR_USERVER_LEN		8
+#define MAC_MDIOSCAR_DA_POS		21
+#define MAC_MDIOSCAR_DA_LEN		5
+#define MAC_MDIOSCAR_PA_POS		16
+#define MAC_MDIOSCAR_PA_LEN		5
+#define MAC_MDIOSCAR_RA_POS		0
+#define MAC_MDIOSCAR_RA_LEN		16
+#define MAC_MDIOSCCDR_BUSY_POS		22
+#define MAC_MDIOSCCDR_BUSY_LEN		1
+#define MAC_MDIOSCCDR_CR_POS		19
+#define MAC_MDIOSCCDR_CR_LEN		3
+#define MAC_MDIOSCCDR_SADDR_POS		18
+#define MAC_MDIOSCCDR_SADDR_LEN		1
+#define MAC_MDIOSCCDR_CMD_POS		16
+#define MAC_MDIOSCCDR_CMD_LEN		2
+#define MAC_MDIOSCCDR_SDATA_POS		0
+#define MAC_MDIOSCCDR_SDATA_LEN		16
+
+/* MMC register offsets */
+#define MMC_CR				0x0800
+#define MMC_RISR			0x0804
+#define MMC_TISR			0x0808
+#define MMC_RIER			0x080c
+#define MMC_TIER			0x0810
+#define MMC_TXOCTETCOUNT_GB_LO		0x0814
+#define MMC_TXOCTETCOUNT_GB_HI		0x0818
+#define MMC_TXFRAMECOUNT_GB_LO		0x081c
+#define MMC_TXFRAMECOUNT_GB_HI		0x0820
+#define MMC_TXBROADCASTFRAMES_G_LO	0x0824
+#define MMC_TXBROADCASTFRAMES_G_HI	0x0828
+#define MMC_TXMULTICASTFRAMES_G_LO	0x082c
+#define MMC_TXMULTICASTFRAMES_G_HI	0x0830
+#define MMC_TX64OCTETS_GB_LO		0x0834
+#define MMC_TX64OCTETS_GB_HI		0x0838
+#define MMC_TX65TO127OCTETS_GB_LO	0x083c
+#define MMC_TX65TO127OCTETS_GB_HI	0x0840
+#define MMC_TX128TO255OCTETS_GB_LO	0x0844
+#define MMC_TX128TO255OCTETS_GB_HI	0x0848
+#define MMC_TX256TO511OCTETS_GB_LO	0x084c
+#define MMC_TX256TO511OCTETS_GB_HI	0x0850
+#define MMC_TX512TO1023OCTETS_GB_LO	0x0854
+#define MMC_TX512TO1023OCTETS_GB_HI	0x0858
+#define MMC_TX1024TOMAXOCTETS_GB_LO	0x085c
+#define MMC_TX1024TOMAXOCTETS_GB_HI	0x0860
+#define MMC_TXUNICASTFRAMES_GB_LO	0x0864
+#define MMC_TXUNICASTFRAMES_GB_HI	0x0868
+#define MMC_TXMULTICASTFRAMES_GB_LO	0x086c
+#define MMC_TXMULTICASTFRAMES_GB_HI	0x0870
+#define MMC_TXBROADCASTFRAMES_GB_LO	0x0874
+#define MMC_TXBROADCASTFRAMES_GB_HI	0x0878
+#define MMC_TXUNDERFLOWERROR_LO		0x087c
+#define MMC_TXUNDERFLOWERROR_HI		0x0880
+#define MMC_TXOCTETCOUNT_G_LO		0x0884
+#define MMC_TXOCTETCOUNT_G_HI		0x0888
+#define MMC_TXFRAMECOUNT_G_LO		0x088c
+#define MMC_TXFRAMECOUNT_G_HI		0x0890
+#define MMC_TXPAUSEFRAMES_LO		0x0894
+#define MMC_TXPAUSEFRAMES_HI		0x0898
+#define MMC_TXVLANFRAMES_G_LO		0x089c
+#define MMC_TXVLANFRAMES_G_HI		0x08a0
+#define MMC_RXFRAMECOUNT_GB_LO		0x0900
+#define MMC_RXFRAMECOUNT_GB_HI		0x0904
+#define MMC_RXOCTETCOUNT_GB_LO		0x0908
+#define MMC_RXOCTETCOUNT_GB_HI		0x090c
+#define MMC_RXOCTETCOUNT_G_LO		0x0910
+#define MMC_RXOCTETCOUNT_G_HI		0x0914
+#define MMC_RXBROADCASTFRAMES_G_LO	0x0918
+#define MMC_RXBROADCASTFRAMES_G_HI	0x091c
+#define MMC_RXMULTICASTFRAMES_G_LO	0x0920
+#define MMC_RXMULTICASTFRAMES_G_HI	0x0924
+#define MMC_RXCRCERROR_LO		0x0928
+#define MMC_RXCRCERROR_HI		0x092c
+#define MMC_RXRUNTERROR			0x0930
+#define MMC_RXJABBERERROR		0x0934
+#define MMC_RXUNDERSIZE_G		0x0938
+#define MMC_RXOVERSIZE_G		0x093c
+#define MMC_RX64OCTETS_GB_LO		0x0940
+#define MMC_RX64OCTETS_GB_HI		0x0944
+#define MMC_RX65TO127OCTETS_GB_LO	0x0948
+#define MMC_RX65TO127OCTETS_GB_HI	0x094c
+#define MMC_RX128TO255OCTETS_GB_LO	0x0950
+#define MMC_RX128TO255OCTETS_GB_HI	0x0954
+#define MMC_RX256TO511OCTETS_GB_LO	0x0958
+#define MMC_RX256TO511OCTETS_GB_HI	0x095c
+#define MMC_RX512TO1023OCTETS_GB_LO	0x0960
+#define MMC_RX512TO1023OCTETS_GB_HI	0x0964
+#define MMC_RX1024TOMAXOCTETS_GB_LO	0x0968
+#define MMC_RX1024TOMAXOCTETS_GB_HI	0x096c
+#define MMC_RXUNICASTFRAMES_G_LO	0x0970
+#define MMC_RXUNICASTFRAMES_G_HI	0x0974
+#define MMC_RXLENGTHERROR_LO		0x0978
+#define MMC_RXLENGTHERROR_HI		0x097c
+#define MMC_RXOUTOFRANGETYPE_LO		0x0980
+#define MMC_RXOUTOFRANGETYPE_HI		0x0984
+#define MMC_RXPAUSEFRAMES_LO		0x0988
+#define MMC_RXPAUSEFRAMES_HI		0x098c
+#define MMC_RXFIFOOVERFLOW_LO		0x0990
+#define MMC_RXFIFOOVERFLOW_HI		0x0994
+#define MMC_RXVLANFRAMES_GB_LO		0x0998
+#define MMC_RXVLANFRAMES_GB_HI		0x099c
+#define MMC_RXWATCHDOGERROR		0x09a0
+
+/* MMC register entry bit positions and sizes */
+#define MMC_CR_CR_POS				0
+#define MMC_CR_CR_LEN				1
+#define MMC_CR_CSR_POS				1
+#define MMC_CR_CSR_LEN				1
+#define MMC_CR_ROR_POS				2
+#define MMC_CR_ROR_LEN				1
+#define MMC_CR_MCF_POS				3
+#define MMC_CR_MCF_LEN				1
+#define MMC_CR_MCT_POS				4
+#define MMC_CR_MCT_LEN				2
+#define MMC_RIER_ALL_INTERRUPTS_POS		0
+#define MMC_RIER_ALL_INTERRUPTS_LEN		23
+#define MMC_RISR_RXFRAMECOUNT_GB_POS		0
+#define MMC_RISR_RXFRAMECOUNT_GB_LEN		1
+#define MMC_RISR_RXOCTETCOUNT_GB_POS		1
+#define MMC_RISR_RXOCTETCOUNT_GB_LEN		1
+#define MMC_RISR_RXOCTETCOUNT_G_POS		2
+#define MMC_RISR_RXOCTETCOUNT_G_LEN		1
+#define MMC_RISR_RXBROADCASTFRAMES_G_POS	3
+#define MMC_RISR_RXBROADCASTFRAMES_G_LEN	1
+#define MMC_RISR_RXMULTICASTFRAMES_G_POS	4
+#define MMC_RISR_RXMULTICASTFRAMES_G_LEN	1
+#define MMC_RISR_RXCRCERROR_POS			5
+#define MMC_RISR_RXCRCERROR_LEN			1
+#define MMC_RISR_RXRUNTERROR_POS		6
+#define MMC_RISR_RXRUNTERROR_LEN		1
+#define MMC_RISR_RXJABBERERROR_POS		7
+#define MMC_RISR_RXJABBERERROR_LEN		1
+#define MMC_RISR_RXUNDERSIZE_G_POS		8
+#define MMC_RISR_RXUNDERSIZE_G_LEN		1
+#define MMC_RISR_RXOVERSIZE_G_POS		9
+#define MMC_RISR_RXOVERSIZE_G_LEN		1
+#define MMC_RISR_RX64OCTETS_GB_POS		10
+#define MMC_RISR_RX64OCTETS_GB_LEN		1
+#define MMC_RISR_RX65TO127OCTETS_GB_POS		11
+#define MMC_RISR_RX65TO127OCTETS_GB_LEN		1
+#define MMC_RISR_RX128TO255OCTETS_GB_POS	12
+#define MMC_RISR_RX128TO255OCTETS_GB_LEN	1
+#define MMC_RISR_RX256TO511OCTETS_GB_POS	13
+#define MMC_RISR_RX256TO511OCTETS_GB_LEN	1
+#define MMC_RISR_RX512TO1023OCTETS_GB_POS	14
+#define MMC_RISR_RX512TO1023OCTETS_GB_LEN	1
+#define MMC_RISR_RX1024TOMAXOCTETS_GB_POS	15
+#define MMC_RISR_RX1024TOMAXOCTETS_GB_LEN	1
+#define MMC_RISR_RXUNICASTFRAMES_G_POS		16
+#define MMC_RISR_RXUNICASTFRAMES_G_LEN		1
+#define MMC_RISR_RXLENGTHERROR_POS		17
+#define MMC_RISR_RXLENGTHERROR_LEN		1
+#define MMC_RISR_RXOUTOFRANGETYPE_POS		18
+#define MMC_RISR_RXOUTOFRANGETYPE_LEN		1
+#define MMC_RISR_RXPAUSEFRAMES_POS		19
+#define MMC_RISR_RXPAUSEFRAMES_LEN		1
+#define MMC_RISR_RXFIFOOVERFLOW_POS		20
+#define MMC_RISR_RXFIFOOVERFLOW_LEN		1
+#define MMC_RISR_RXVLANFRAMES_GB_POS		21
+#define MMC_RISR_RXVLANFRAMES_GB_LEN		1
+#define MMC_RISR_RXWATCHDOGERROR_POS		22
+#define MMC_RISR_RXWATCHDOGERROR_LEN		1
+#define MMC_TIER_ALL_INTERRUPTS_POS		0
+#define MMC_TIER_ALL_INTERRUPTS_LEN		18
+#define MMC_TISR_TXOCTETCOUNT_GB_POS		0
+#define MMC_TISR_TXOCTETCOUNT_GB_LEN		1
+#define MMC_TISR_TXFRAMECOUNT_GB_POS		1
+#define MMC_TISR_TXFRAMECOUNT_GB_LEN		1
+#define MMC_TISR_TXBROADCASTFRAMES_G_POS	2
+#define MMC_TISR_TXBROADCASTFRAMES_G_LEN	1
+#define MMC_TISR_TXMULTICASTFRAMES_G_POS	3
+#define MMC_TISR_TXMULTICASTFRAMES_G_LEN	1
+#define MMC_TISR_TX64OCTETS_GB_POS		4
+#define MMC_TISR_TX64OCTETS_GB_LEN		1
+#define MMC_TISR_TX65TO127OCTETS_GB_POS		5
+#define MMC_TISR_TX65TO127OCTETS_GB_LEN		1
+#define MMC_TISR_TX128TO255OCTETS_GB_POS	6
+#define MMC_TISR_TX128TO255OCTETS_GB_LEN	1
+#define MMC_TISR_TX256TO511OCTETS_GB_POS	7
+#define MMC_TISR_TX256TO511OCTETS_GB_LEN	1
+#define MMC_TISR_TX512TO1023OCTETS_GB_POS	8
+#define MMC_TISR_TX512TO1023OCTETS_GB_LEN	1
+#define MMC_TISR_TX1024TOMAXOCTETS_GB_POS	9
+#define MMC_TISR_TX1024TOMAXOCTETS_GB_LEN	1
+#define MMC_TISR_TXUNICASTFRAMES_GB_POS		10
+#define MMC_TISR_TXUNICASTFRAMES_GB_LEN		1
+#define MMC_TISR_TXMULTICASTFRAMES_GB_POS	11
+#define MMC_TISR_TXMULTICASTFRAMES_GB_LEN	1
+#define MMC_TISR_TXBROADCASTFRAMES_GB_POS	12
+#define MMC_TISR_TXBROADCASTFRAMES_GB_LEN	1
+#define MMC_TISR_TXUNDERFLOWERROR_POS		13
+#define MMC_TISR_TXUNDERFLOWERROR_LEN		1
+#define MMC_TISR_TXOCTETCOUNT_G_POS		14
+#define MMC_TISR_TXOCTETCOUNT_G_LEN		1
+#define MMC_TISR_TXFRAMECOUNT_G_POS		15
+#define MMC_TISR_TXFRAMECOUNT_G_LEN		1
+#define MMC_TISR_TXPAUSEFRAMES_POS		16
+#define MMC_TISR_TXPAUSEFRAMES_LEN		1
+#define MMC_TISR_TXVLANFRAMES_G_POS		17
+#define MMC_TISR_TXVLANFRAMES_G_LEN		1
+
+/* MTL register offsets */
+#define MTL_OMR				0x1000
+#define MTL_FDCR			0x1008
+#define MTL_FDSR			0x100c
+#define MTL_FDDR			0x1010
+#define MTL_ISR				0x1020
+#define MTL_RQDCM0R			0x1030
+#define MTL_TCPM0R			0x1040
+#define MTL_TCPM1R			0x1044
+
+#define MTL_RQDCM_INC			4
+#define MTL_RQDCM_Q_PER_REG		4
+#define MTL_TCPM_INC			4
+#define MTL_TCPM_TC_PER_REG		4
+
+/* MTL register entry bit positions and sizes */
+#define MTL_OMR_ETSALG_POS		5
+#define MTL_OMR_ETSALG_LEN		2
+#define MTL_OMR_RAA_POS			2
+#define MTL_OMR_RAA_LEN			1
+
+/* MTL queue register offsets
+ *   Multiple queues can be active.  The first queue has registers
+ *   that begin at 0x1100.  Each subsequent queue has registers that
+ *   are accessed using an offset of 0x80 from the previous queue.
+ */
+#define MTL_Q_BASE			0x1100
+#define MTL_Q_INC			0x80
+
+#define MTL_Q_TQOMR			0x00
+#define MTL_Q_TQUR			0x04
+#define MTL_Q_TQDR			0x08
+#define MTL_Q_RQOMR			0x40
+#define MTL_Q_RQMPOCR			0x44
+#define MTL_Q_RQDR			0x48
+#define MTL_Q_RQFCR			0x50
+#define MTL_Q_IER			0x70
+#define MTL_Q_ISR			0x74
+
+/* MTL queue register entry bit positions and sizes */
+#define MTL_Q_RQDR_PRXQ_POS		16
+#define MTL_Q_RQDR_PRXQ_LEN		14
+#define MTL_Q_RQDR_RXQSTS_POS		4
+#define MTL_Q_RQDR_RXQSTS_LEN		2
+#define MTL_Q_RQFCR_RFA_POS		1
+#define MTL_Q_RQFCR_RFA_LEN		6
+#define MTL_Q_RQFCR_RFD_POS		17
+#define MTL_Q_RQFCR_RFD_LEN		6
+#define MTL_Q_RQOMR_EHFC_POS		7
+#define MTL_Q_RQOMR_EHFC_LEN		1
+#define MTL_Q_RQOMR_RQS_POS		16
+#define MTL_Q_RQOMR_RQS_LEN		9
+#define MTL_Q_RQOMR_RSF_POS		5
+#define MTL_Q_RQOMR_RSF_LEN		1
+#define MTL_Q_RQOMR_FEP_POS		4
+#define MTL_Q_RQOMR_FEP_LEN		1
+#define MTL_Q_RQOMR_FUP_POS		3
+#define MTL_Q_RQOMR_FUP_LEN		1
+#define MTL_Q_RQOMR_RTC_POS		0
+#define MTL_Q_RQOMR_RTC_LEN		2
+#define MTL_Q_TQOMR_FTQ_POS		0
+#define MTL_Q_TQOMR_FTQ_LEN		1
+#define MTL_Q_TQOMR_Q2TCMAP_POS		8
+#define MTL_Q_TQOMR_Q2TCMAP_LEN		3
+#define MTL_Q_TQOMR_TQS_POS		16
+#define MTL_Q_TQOMR_TQS_LEN		10
+#define MTL_Q_TQOMR_TSF_POS		1
+#define MTL_Q_TQOMR_TSF_LEN		1
+#define MTL_Q_TQOMR_TTC_POS		4
+#define MTL_Q_TQOMR_TTC_LEN		3
+#define MTL_Q_TQOMR_TXQEN_POS		2
+#define MTL_Q_TQOMR_TXQEN_LEN		2
+
+/* MTL queue register value */
+#define MTL_RSF_DISABLE			0x00
+#define MTL_RSF_ENABLE			0x01
+#define MTL_TSF_DISABLE			0x00
+#define MTL_TSF_ENABLE			0x01
+
+#define MTL_RX_THRESHOLD_64		0x00
+#define MTL_RX_THRESHOLD_96		0x02
+#define MTL_RX_THRESHOLD_128		0x03
+#define MTL_TX_THRESHOLD_32		0x01
+#define MTL_TX_THRESHOLD_64		0x00
+#define MTL_TX_THRESHOLD_96		0x02
+#define MTL_TX_THRESHOLD_128		0x03
+#define MTL_TX_THRESHOLD_192		0x04
+#define MTL_TX_THRESHOLD_256		0x05
+#define MTL_TX_THRESHOLD_384		0x06
+#define MTL_TX_THRESHOLD_512		0x07
+
+#define MTL_ETSALG_WRR			0x00
+#define MTL_ETSALG_WFQ			0x01
+#define MTL_ETSALG_DWRR			0x02
+#define MTL_RAA_SP			0x00
+#define MTL_RAA_WSP			0x01
+
+#define MTL_Q_DISABLED			0x00
+#define MTL_Q_ENABLED			0x02
+
+#define MTL_RQDCM0R_Q0MDMACH		0x0
+#define MTL_RQDCM0R_Q1MDMACH		0x00000100
+#define MTL_RQDCM0R_Q2MDMACH		0x00020000
+#define MTL_RQDCM0R_Q3MDMACH		0x03000000
+#define MTL_RQDCM1R_Q4MDMACH		0x00000004
+#define MTL_RQDCM1R_Q5MDMACH		0x00000500
+#define MTL_RQDCM1R_Q6MDMACH		0x00060000
+#define MTL_RQDCM1R_Q7MDMACH		0x07000000
+#define MTL_RQDCM2R_Q8MDMACH		0x00000008
+#define MTL_RQDCM2R_Q9MDMACH		0x00000900
+#define MTL_RQDCM2R_Q10MDMACH		0x000A0000
+#define MTL_RQDCM2R_Q11MDMACH		0x0B000000
+
+/* MTL traffic class register offsets
+ *   Multiple traffic classes can be active.  The first class has registers
+ *   that begin at 0x1100.  Each subsequent queue has registers that
+ *   are accessed using an offset of 0x80 from the previous queue.
+ */
+#define MTL_TC_BASE			MTL_Q_BASE
+#define MTL_TC_INC			MTL_Q_INC
+
+#define MTL_TC_ETSCR			0x10
+#define MTL_TC_ETSSR			0x14
+#define MTL_TC_QWR			0x18
+
+/* MTL traffic class register entry bit positions and sizes */
+#define MTL_TC_ETSCR_TSA_POS		0
+#define MTL_TC_ETSCR_TSA_LEN		2
+#define MTL_TC_QWR_QW_POS		0
+#define MTL_TC_QWR_QW_LEN		21
+
+/* MTL traffic class register value */
+#define MTL_TSA_SP			0x00
+#define MTL_TSA_ETS			0x02
+
+/* Descriptor/Packet entry bit positions and sizes */
+#define RX_PACKET_ERRORS_CRC_POS		2
+#define RX_PACKET_ERRORS_CRC_LEN		1
+#define RX_PACKET_ERRORS_FRAME_POS		3
+#define RX_PACKET_ERRORS_FRAME_LEN		1
+#define RX_PACKET_ERRORS_LENGTH_POS		0
+#define RX_PACKET_ERRORS_LENGTH_LEN		1
+#define RX_PACKET_ERRORS_OVERRUN_POS		1
+#define RX_PACKET_ERRORS_OVERRUN_LEN		1
+
+#define RX_PACKET_ATTRIBUTES_CSUM_DONE_POS	0
+#define RX_PACKET_ATTRIBUTES_CSUM_DONE_LEN	1
+#define RX_PACKET_ATTRIBUTES_VLAN_CTAG_POS	1
+#define RX_PACKET_ATTRIBUTES_VLAN_CTAG_LEN	1
+#define RX_PACKET_ATTRIBUTES_INCOMPLETE_POS	2
+#define RX_PACKET_ATTRIBUTES_INCOMPLETE_LEN	1
+#define RX_PACKET_ATTRIBUTES_CONTEXT_NEXT_POS	3
+#define RX_PACKET_ATTRIBUTES_CONTEXT_NEXT_LEN	1
+#define RX_PACKET_ATTRIBUTES_CONTEXT_POS	4
+#define RX_PACKET_ATTRIBUTES_CONTEXT_LEN	1
+#define RX_PACKET_ATTRIBUTES_RX_TSTAMP_POS	5
+#define RX_PACKET_ATTRIBUTES_RX_TSTAMP_LEN	1
+#define RX_PACKET_ATTRIBUTES_RSS_HASH_POS	6
+#define RX_PACKET_ATTRIBUTES_RSS_HASH_LEN	1
+
+#define RX_NORMAL_DESC0_OVT_POS			0
+#define RX_NORMAL_DESC0_OVT_LEN			16
+#define RX_NORMAL_DESC2_HL_POS			0
+#define RX_NORMAL_DESC2_HL_LEN			10
+#define RX_NORMAL_DESC3_CDA_POS			27
+#define RX_NORMAL_DESC3_CDA_LEN			1
+#define RX_NORMAL_DESC3_CTXT_POS		30
+#define RX_NORMAL_DESC3_CTXT_LEN		1
+#define RX_NORMAL_DESC3_ES_POS			15
+#define RX_NORMAL_DESC3_ES_LEN			1
+#define RX_NORMAL_DESC3_ETLT_POS		16
+#define RX_NORMAL_DESC3_ETLT_LEN		4
+#define RX_NORMAL_DESC3_FD_POS			29
+#define RX_NORMAL_DESC3_FD_LEN			1
+#define RX_NORMAL_DESC3_INTE_POS		30
+#define RX_NORMAL_DESC3_INTE_LEN		1
+#define RX_NORMAL_DESC3_L34T_POS		20
+#define RX_NORMAL_DESC3_L34T_LEN		4
+#define RX_NORMAL_DESC3_LD_POS			28
+#define RX_NORMAL_DESC3_LD_LEN			1
+#define RX_NORMAL_DESC3_OWN_POS			31
+#define RX_NORMAL_DESC3_OWN_LEN			1
+#define RX_NORMAL_DESC3_PL_POS			0
+#define RX_NORMAL_DESC3_PL_LEN			14
+#define RX_NORMAL_DESC3_RSV_POS			26
+#define RX_NORMAL_DESC3_RSV_LEN			1
+
+#define RX_DESC3_L34T_IPV4_TCP			1
+#define RX_DESC3_L34T_IPV4_UDP			2
+#define RX_DESC3_L34T_IPV4_ICMP			3
+#define RX_DESC3_L34T_IPV6_TCP			9
+#define RX_DESC3_L34T_IPV6_UDP			10
+#define RX_DESC3_L34T_IPV6_ICMP			11
+
+#define RX_CONTEXT_DESC3_TSA_POS		4
+#define RX_CONTEXT_DESC3_TSA_LEN		1
+#define RX_CONTEXT_DESC3_TSD_POS		6
+#define RX_CONTEXT_DESC3_TSD_LEN		1
+
+#define TX_PACKET_ATTRIBUTES_CSUM_ENABLE_POS	0
+#define TX_PACKET_ATTRIBUTES_CSUM_ENABLE_LEN	1
+#define TX_PACKET_ATTRIBUTES_TSO_ENABLE_POS	1
+#define TX_PACKET_ATTRIBUTES_TSO_ENABLE_LEN	1
+#define TX_PACKET_ATTRIBUTES_VLAN_CTAG_POS	2
+#define TX_PACKET_ATTRIBUTES_VLAN_CTAG_LEN	1
+#define TX_PACKET_ATTRIBUTES_PTP_POS		3
+#define TX_PACKET_ATTRIBUTES_PTP_LEN		1
+
+#define TX_CONTEXT_DESC2_MSS_POS		0
+#define TX_CONTEXT_DESC2_MSS_LEN		15
+#define TX_CONTEXT_DESC3_CTXT_POS		30
+#define TX_CONTEXT_DESC3_CTXT_LEN		1
+#define TX_CONTEXT_DESC3_TCMSSV_POS		26
+#define TX_CONTEXT_DESC3_TCMSSV_LEN		1
+#define TX_CONTEXT_DESC3_VLTV_POS		16
+#define TX_CONTEXT_DESC3_VLTV_LEN		1
+#define TX_CONTEXT_DESC3_VT_POS			0
+#define TX_CONTEXT_DESC3_VT_LEN			16
+
+#define TX_NORMAL_DESC2_HL_B1L_POS		0
+#define TX_NORMAL_DESC2_HL_B1L_LEN		14
+#define TX_NORMAL_DESC2_IC_POS			31
+#define TX_NORMAL_DESC2_IC_LEN			1
+#define TX_NORMAL_DESC2_TTSE_POS		30
+#define TX_NORMAL_DESC2_TTSE_LEN		1
+#define TX_NORMAL_DESC2_VTIR_POS		14
+#define TX_NORMAL_DESC2_VTIR_LEN		2
+#define TX_NORMAL_DESC3_CIC_POS			16
+#define TX_NORMAL_DESC3_CIC_LEN			2
+#define TX_NORMAL_DESC3_CPC_POS			26
+#define TX_NORMAL_DESC3_CPC_LEN			2
+#define TX_NORMAL_DESC3_CTXT_POS		30
+#define TX_NORMAL_DESC3_CTXT_LEN		1
+#define TX_NORMAL_DESC3_FD_POS			29
+#define TX_NORMAL_DESC3_FD_LEN			1
+#define TX_NORMAL_DESC3_FL_POS			0
+#define TX_NORMAL_DESC3_FL_LEN			15
+#define TX_NORMAL_DESC3_LD_POS			28
+#define TX_NORMAL_DESC3_LD_LEN			1
+#define TX_NORMAL_DESC3_OWN_POS			31
+#define TX_NORMAL_DESC3_OWN_LEN			1
+#define TX_NORMAL_DESC3_TCPHDRLEN_POS		19
+#define TX_NORMAL_DESC3_TCPHDRLEN_LEN		4
+#define TX_NORMAL_DESC3_TCPPL_POS		0
+#define TX_NORMAL_DESC3_TCPPL_LEN		18
+#define TX_NORMAL_DESC3_TSE_POS			18
+#define TX_NORMAL_DESC3_TSE_LEN			1
+
+#define TX_NORMAL_DESC2_VLAN_INSERT		0x2
+
+/* MDIO undefined or vendor specific registers */
+#ifndef MDIO_AN_COMP_STAT
+#define MDIO_AN_COMP_STAT			0x0030
+#endif
+
+/* Bit setting and getting macros
+ *  The get macro will extract the current bit field value from within
+ *  the variable
+ *
+ *  The set macro will clear the current bit field value within the
+ *  variable and then set the bit field of the variable to the
+ *  specified value
+ */
+#define GET_BITS(_var, _pos, _len) \
+	(((_var) >> (_pos)) & ((0x1 << (_len)) - 1))
+
+#define SET_BITS(_var, _pos, _len, _val) \
+do {									\
+	(_var) &= ~(((0x1 << (_len)) - 1) << (_pos));			\
+	(_var) |= (((_val) & ((0x1 << (_len)) - 1)) << (_pos));	\
+} while (0)
+
+#define GET_BITS_LE(_var, _pos, _len) \
+	((le32_to_cpu((_var)) >> (_pos)) & ((0x1 << (_len)) - 1))
+
+#define SET_BITS_LE(_var, _pos, _len, _val) \
+do {									\
+	(_var) &= cpu_to_le32(~(((0x1 << (_len)) - 1) << (_pos)));	\
+	(_var) |= cpu_to_le32((((_val) &				\
+			      ((0x1 << (_len)) - 1)) << (_pos)));	\
+} while (0)
+
+/* Bit setting and getting macros based on register fields
+ *  The get macro uses the bit field definitions formed using the input
+ *  names to extract the current bit field value from within the
+ *  variable
+ *
+ *  The set macro uses the bit field definitions formed using the input
+ *  names to set the bit field of the variable to the specified value
+ */
+#define DWC_ETH_GET_BITS(_var, _prefix, _field)	\
+	GET_BITS((_var),						\
+		 _prefix##_##_field##_POS,				\
+		 _prefix##_##_field##_LEN)
+
+#define DWC_ETH_SET_BITS(_var, _prefix, _field, _val)			\
+	SET_BITS((_var),						\
+		 _prefix##_##_field##_POS,				\
+		 _prefix##_##_field##_LEN, (_val))
+
+#define DWC_ETH_GET_BITS_LE(_var, _prefix, _field)			\
+	GET_BITS_LE((_var),						\
+		 _prefix##_##_field##_POS,				\
+		 _prefix##_##_field##_LEN)
+
+#define DWC_ETH_SET_BITS_LE(_var, _prefix, _field, _val)		\
+	SET_BITS_LE((_var),						\
+		 _prefix##_##_field##_POS,				\
+		 _prefix##_##_field##_LEN, (_val))
+
+/* Macros for reading or writing registers
+ *  The ioread macros will get bit fields or full values using the
+ *  register definitions formed using the input names
+ *
+ *  The iowrite macros will set bit fields or full values using the
+ *  register definitions formed using the input names
+ */
+#define DWC_ETH_IOREAD(_pdata, _reg)					\
+	ioread32((_pdata)->mac_regs + (_reg))
+
+#define DWC_ETH_IOREAD_BITS(_pdata, _reg, _field)			\
+	GET_BITS(DWC_ETH_IOREAD((_pdata), _reg),			\
+		 _reg##_##_field##_POS,					\
+		 _reg##_##_field##_LEN)
+
+#define DWC_ETH_IOWRITE(_pdata, _reg, _val)				\
+	iowrite32((_val), (_pdata)->mac_regs + (_reg))
+
+#define DWC_ETH_IOWRITE_BITS(_pdata, _reg, _field, _val)		\
+do {									\
+	u32 reg_val = DWC_ETH_IOREAD((_pdata), _reg);			\
+	SET_BITS(reg_val,						\
+		 _reg##_##_field##_POS,					\
+		 _reg##_##_field##_LEN, (_val));			\
+	DWC_ETH_IOWRITE((_pdata), _reg, reg_val);			\
+} while (0)
+
+/* Macros for reading or writing MTL queue or traffic class registers
+ *  Similar to the standard read and write macros except that the
+ *  base register value is calculated by the queue or traffic class number
+ */
+#define DWC_ETH_MTL_IOREAD(_pdata, _n, _reg)				\
+	ioread32((_pdata)->mac_regs +					\
+		 MTL_Q_BASE + ((_n) * MTL_Q_INC) + (_reg))
+
+#define DWC_ETH_MTL_IOREAD_BITS(_pdata, _n, _reg, _field)		\
+	GET_BITS(DWC_ETH_MTL_IOREAD((_pdata), (_n), _reg),		\
+		 _reg##_##_field##_POS,					\
+		 _reg##_##_field##_LEN)
+
+#define DWC_ETH_MTL_IOWRITE(_pdata, _n, _reg, _val)			\
+	iowrite32((_val), (_pdata)->mac_regs +				\
+		  MTL_Q_BASE + ((_n) * MTL_Q_INC) + (_reg))
+
+#define DWC_ETH_MTL_IOWRITE_BITS(_pdata, _n, _reg, _field, _val)	\
+do {									\
+	u32 reg_val = DWC_ETH_MTL_IOREAD((_pdata), (_n), _reg);		\
+	SET_BITS(reg_val,						\
+		 _reg##_##_field##_POS,					\
+		 _reg##_##_field##_LEN, (_val));			\
+	DWC_ETH_MTL_IOWRITE((_pdata), (_n), _reg, reg_val);		\
+} while (0)
+
+/* Macros for reading or writing DMA channel registers
+ *  Similar to the standard read and write macros except that the
+ *  base register value is obtained from the ring
+ */
+#define DWC_ETH_DMA_IOREAD(_channel, _reg)				\
+	ioread32((_channel)->dma_regs + (_reg))
+
+#define DWC_ETH_DMA_IOREAD_BITS(_channel, _reg, _field)			\
+	GET_BITS(DWC_ETH_DMA_IOREAD((_channel), _reg),			\
+		 _reg##_##_field##_POS,					\
+		 _reg##_##_field##_LEN)
+
+#define DWC_ETH_DMA_IOWRITE(_channel, _reg, _val)			\
+	iowrite32((_val), (_channel)->dma_regs + (_reg))
+
+#define DWC_ETH_DMA_IOWRITE_BITS(_channel, _reg, _field, _val)		\
+do {									\
+	u32 reg_val = DWC_ETH_DMA_IOREAD((_channel), _reg);		\
+	SET_BITS(reg_val,						\
+		 _reg##_##_field##_POS,					\
+		 _reg##_##_field##_LEN, (_val));			\
+	DWC_ETH_DMA_IOWRITE((_channel), _reg, reg_val);			\
+} while (0)
+
+/* Macros for building, reading or writing register values or bits
+ * using MDIO.  Different from above because of the use of standardized
+ * Linux include values.  No shifting is performed with the bit
+ * operations, everything works on mask values.
+ */
+#define DWC_ETH_MDIO_READ(_pdata, _mmd, _reg)				\
+	((_pdata)->hw_ops.read_mmd_regs((_pdata), 0,			\
+	MII_ADDR_C45 | ((_mmd) << 16) | ((_reg) & 0xffff)))
+
+#define DWC_ETH_MDIO_READ_BITS(_pdata, _mmd, _reg, _mask)		\
+	(DWC_ETH_MDIO_READ((_pdata), _mmd, _reg) & (_mask))
+
+#define DWC_ETH_MDIO_WRITE(_pdata, _mmd, _reg, _val)			\
+	((_pdata)->hw_ops.write_mmd_regs((_pdata), 0,			\
+	MII_ADDR_C45 | ((_mmd) << 16) | ((_reg) & 0xffff), (_val)))
+
+#define DWC_ETH_MDIO_WRITE_BITS(_pdata, _mmd, _reg, _mask, _val)	\
+do {									\
+	u32 mmd_val = DWC_ETH_MDIO_READ((_pdata), _mmd, _reg);		\
+	mmd_val &= ~(_mask);						\
+	mmd_val |= (_val);						\
+	DWC_ETH_MDIO_WRITE((_pdata), _mmd, _reg, mmd_val);		\
+} while (0)
+
+#endif /* __DWC_ETH_REGACC_H__ */
diff --git a/drivers/net/ethernet/synopsys/dwc/dwc-eth.h b/drivers/net/ethernet/synopsys/dwc/dwc-eth.h
new file mode 100644
index 0000000..ec6c92c
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc/dwc-eth.h
@@ -0,0 +1,738 @@
+/*
+ * Synopsys DesignWare Ethernet Driver
+ *
+ * Copyright (c) 2014-2016 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This file is free software; you may copy, redistribute and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, either version 2 of the License, or (at
+ * your option) any later version.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __DWC_ETH_H__
+#define __DWC_ETH_H__
+
+#include <linux/dma-mapping.h>
+#include <linux/netdevice.h>
+#include <linux/workqueue.h>
+#include <linux/phy.h>
+#include <linux/if_vlan.h>
+#include <linux/bitops.h>
+#include <linux/ptp_clock_kernel.h>
+#include <linux/timecounter.h>
+#include <linux/net_tstamp.h>
+
+#define DWC_ETH_MDIO_RD_TIMEOUT		1000
+
+/* Maximum MAC address hash table size (256 bits = 8 bytes) */
+#define DWC_ETH_MAC_HASH_TABLE_SIZE	8
+
+#define DWC_ETH_MAX_DMA_CHANNELS	16
+#define DWC_ETH_MAX_QUEUES		16
+#define DWC_ETH_MAX_FIFO		81920
+
+#define DWC_ETH_DMA_INTERRUPT_MASK	0x31c7
+
+/* Receive Side Scaling */
+#define DWC_ETH_RSS_HASH_KEY_SIZE	40
+#define DWC_ETH_RSS_MAX_TABLE_SIZE	256
+#define DWC_ETH_RSS_LOOKUP_TABLE_TYPE	0
+#define DWC_ETH_RSS_HASH_KEY_TYPE	1
+
+#define DWC_ETH_MIN_PACKET		60
+#define DWC_ETH_STD_PACKET_MTU		1500
+#define DWC_ETH_MAX_STD_PACKET		1518
+#define DWC_ETH_JUMBO_PACKET_MTU	9000
+#define DWC_ETH_MAX_JUMBO_PACKET	9018
+
+/* MDIO bus phy name */
+#define DWC_ETH_PHY_NAME		"dwc_eth_phy"
+#define DWC_ETH_PRTAD			0
+
+/* Driver PMT macros */
+#define DWC_ETH_DRIVER_CONTEXT		1
+#define DWC_ETH_IOCTL_CONTEXT		2
+
+/* Helper macro for descriptor handling
+ *  Always use DWC_ETH_GET_DESC_DATA to access the descriptor data
+ */
+#define DWC_ETH_GET_DESC_DATA(_ring, _idx)			\
+	((_ring)->desc_data_head +				\
+	 ((_idx) & ((_ring)->dma_desc_count - 1)))
+
+struct dwc_eth_pdata;
+
+enum dwc_eth_int {
+	DWC_ETH_INT_DMA_CH_SR_TI,
+	DWC_ETH_INT_DMA_CH_SR_TPS,
+	DWC_ETH_INT_DMA_CH_SR_TBU,
+	DWC_ETH_INT_DMA_CH_SR_RI,
+	DWC_ETH_INT_DMA_CH_SR_RBU,
+	DWC_ETH_INT_DMA_CH_SR_RPS,
+	DWC_ETH_INT_DMA_CH_SR_TI_RI,
+	DWC_ETH_INT_DMA_CH_SR_FBE,
+	DWC_ETH_INT_DMA_ALL,
+};
+
+struct dwc_eth_stats {
+	/* MMC TX counters */
+	u64 txoctetcount_gb;
+	u64 txframecount_gb;
+	u64 txbroadcastframes_g;
+	u64 txmulticastframes_g;
+	u64 tx64octets_gb;
+	u64 tx65to127octets_gb;
+	u64 tx128to255octets_gb;
+	u64 tx256to511octets_gb;
+	u64 tx512to1023octets_gb;
+	u64 tx1024tomaxoctets_gb;
+	u64 txunicastframes_gb;
+	u64 txmulticastframes_gb;
+	u64 txbroadcastframes_gb;
+	u64 txunderflowerror;
+	u64 txoctetcount_g;
+	u64 txframecount_g;
+	u64 txpauseframes;
+	u64 txvlanframes_g;
+
+	/* MMC RX counters */
+	u64 rxframecount_gb;
+	u64 rxoctetcount_gb;
+	u64 rxoctetcount_g;
+	u64 rxbroadcastframes_g;
+	u64 rxmulticastframes_g;
+	u64 rxcrcerror;
+	u64 rxrunterror;
+	u64 rxjabbererror;
+	u64 rxundersize_g;
+	u64 rxoversize_g;
+	u64 rx64octets_gb;
+	u64 rx65to127octets_gb;
+	u64 rx128to255octets_gb;
+	u64 rx256to511octets_gb;
+	u64 rx512to1023octets_gb;
+	u64 rx1024tomaxoctets_gb;
+	u64 rxunicastframes_g;
+	u64 rxlengtherror;
+	u64 rxoutofrangetype;
+	u64 rxpauseframes;
+	u64 rxfifooverflow;
+	u64 rxvlanframes_gb;
+	u64 rxwatchdogerror;
+
+	/* Extra counters */
+	u64 tx_tso_packets;
+	u64 rx_split_header_packets;
+	u64 rx_buffer_unavailable;
+};
+
+struct dwc_eth_ring_buf {
+	struct sk_buff *skb;
+	dma_addr_t skb_dma;
+	unsigned int skb_len;
+};
+
+/* Common Tx and Rx DMA hardware descriptor */
+struct dwc_eth_dma_desc {
+	__le32 desc0;
+	__le32 desc1;
+	__le32 desc2;
+	__le32 desc3;
+};
+
+/* Page allocation related values */
+struct dwc_eth_page_alloc {
+	struct page *pages;
+	unsigned int pages_len;
+	unsigned int pages_offset;
+
+	dma_addr_t pages_dma;
+};
+
+/* Ring entry buffer data */
+struct dwc_eth_buffer_data {
+	struct dwc_eth_page_alloc pa;
+	struct dwc_eth_page_alloc pa_unmap;
+
+	dma_addr_t dma_base;
+	unsigned long dma_off;
+	unsigned int dma_len;
+};
+
+/* Tx-related desc data */
+struct dwc_eth_tx_desc_data {
+	unsigned int packets;		/* BQL packet count */
+	unsigned int bytes;		/* BQL byte count */
+};
+
+/* Rx-related desc data */
+struct dwc_eth_rx_desc_data {
+	struct dwc_eth_buffer_data hdr;	/* Header locations */
+	struct dwc_eth_buffer_data buf;	/* Payload locations */
+
+	unsigned short hdr_len;		/* Length of received header */
+	unsigned short len;		/* Length of received packet */
+};
+
+struct dwc_eth_pkt_info {
+	struct sk_buff *skb;
+
+	unsigned int attributes;
+
+	unsigned int errors;
+
+	/* descriptors needed for this packet */
+	unsigned int desc_count;
+	unsigned int length;
+
+	unsigned int tx_packets;
+	unsigned int tx_bytes;
+
+	unsigned int header_len;
+	unsigned int tcp_header_len;
+	unsigned int tcp_payload_len;
+	unsigned short mss;
+
+	unsigned short vlan_ctag;
+
+	u64 rx_tstamp;
+
+	u32 rss_hash;
+	enum pkt_hash_types rss_hash_type;
+};
+
+struct dwc_eth_desc_data {
+	/* dma_desc: Virtual address of descriptor
+	 *  dma_desc_addr: DMA address of descriptor
+	 */
+	struct dwc_eth_dma_desc *dma_desc;
+	dma_addr_t dma_desc_addr;
+
+	/* skb: Virtual address of SKB
+	 *  skb_dma: DMA address of SKB data
+	 *  skb_dma_len: Length of SKB DMA area
+	 */
+	struct sk_buff *skb;
+	dma_addr_t skb_dma;
+	unsigned int skb_dma_len;
+
+	/* Tx/Rx -related data */
+	struct dwc_eth_tx_desc_data tx;
+	struct dwc_eth_rx_desc_data rx;
+
+	unsigned int mapped_as_page;
+
+	/* Incomplete receive save location.  If the budget is exhausted
+	 * or the last descriptor (last normal descriptor or a following
+	 * context descriptor) has not been DMA'd yet the current state
+	 * of the receive processing needs to be saved.
+	 */
+	unsigned int state_saved;
+	struct {
+		struct sk_buff *skb;
+		unsigned int len;
+		unsigned int error;
+	} state;
+};
+
+struct dwc_eth_ring {
+	/* Per packet related information */
+	struct dwc_eth_pkt_info pkt_info;
+
+	/* Virtual/DMA addresses of DMA descriptor list and the total count */
+	struct dwc_eth_dma_desc *dma_desc_head;
+	dma_addr_t dma_desc_head_addr;
+	unsigned int dma_desc_count;
+
+	/* Array of descriptor data corresponding the DMA descriptor
+	 * (always use the DWC_ETH_GET_DESC_DATA macro to access this data)
+	 */
+	struct dwc_eth_desc_data *desc_data_head;
+
+	/* Page allocation for RX buffers */
+	struct dwc_eth_page_alloc rx_hdr_pa;
+	struct dwc_eth_page_alloc rx_buf_pa;
+
+	/* Ring index values
+	 *  cur   - Tx: index of descriptor to be used for current transfer
+	 *          Rx: index of descriptor to check for packet availability
+	 *  dirty - Tx: index of descriptor to check for transfer complete
+	 *          Rx: index of descriptor to check for buffer reallocation
+	 */
+	unsigned int cur;
+	unsigned int dirty;
+
+	/* Coalesce frame count used for interrupt bit setting */
+	unsigned int coalesce_count;
+
+	union {
+		struct {
+			unsigned int xmit_more;
+			unsigned int queue_stopped;
+			unsigned short cur_mss;
+			unsigned short cur_vlan_ctag;
+		} tx;
+	};
+} ____cacheline_aligned;
+
+struct dwc_eth_channel {
+	char name[16];
+
+	/* Address of private data area for device */
+	struct dwc_eth_pdata *pdata;
+
+	/* Queue index and base address of queue's DMA registers */
+	unsigned int queue_index;
+	void __iomem *dma_regs;
+
+	/* Per channel interrupt irq number */
+	int dma_irq;
+	char dma_irq_name[IFNAMSIZ + 32];
+
+	/* Netdev related settings */
+	struct napi_struct napi;
+
+	unsigned int saved_ier;
+
+	unsigned int tx_timer_active;
+	struct timer_list tx_timer;
+
+	struct dwc_eth_ring *tx_ring;
+	struct dwc_eth_ring *rx_ring;
+} ____cacheline_aligned;
+
+struct dwc_eth_desc_ops {
+	int (*alloc_channles_and_rings)(struct dwc_eth_pdata *pdata);
+	void (*free_channels_and_rings)(struct dwc_eth_pdata *pdata);
+	int (*map_tx_skb)(struct dwc_eth_channel *channel,
+			  struct sk_buff *skb);
+	int (*map_rx_buffer)(struct dwc_eth_pdata *pdata,
+			     struct dwc_eth_ring *ring,
+			struct dwc_eth_desc_data *desc_data);
+	void (*unmap_desc_data)(struct dwc_eth_pdata *pdata,
+				struct dwc_eth_desc_data *desc_data);
+	void (*tx_desc_init)(struct dwc_eth_pdata *pdata);
+	void (*rx_desc_init)(struct dwc_eth_pdata *pdata);
+};
+
+struct dwc_eth_hw_ops {
+	int (*tx_complete)(struct dwc_eth_dma_desc *dma_desc);
+
+	int (*set_mac_address)(struct dwc_eth_pdata *pdata, u8 *addr);
+	int (*config_rx_mode)(struct dwc_eth_pdata *pdata);
+
+	int (*enable_rx_csum)(struct dwc_eth_pdata *pdata);
+	int (*disable_rx_csum)(struct dwc_eth_pdata *pdata);
+
+	int (*enable_rx_vlan_stripping)(struct dwc_eth_pdata *pdata);
+	int (*disable_rx_vlan_stripping)(struct dwc_eth_pdata *pdata);
+	int (*enable_rx_vlan_filtering)(struct dwc_eth_pdata *pdata);
+	int (*disable_rx_vlan_filtering)(struct dwc_eth_pdata *pdata);
+	int (*update_vlan_hash_table)(struct dwc_eth_pdata *pdata);
+
+	int (*read_mmd_regs)(struct dwc_eth_pdata *pdata,
+			     int prtad, int mmd_reg);
+	int (*write_mmd_regs)(struct dwc_eth_pdata *pdata,
+			      int prtad, int mmd_reg, int mmd_data);
+
+	int (*set_gmii_1000_speed)(struct dwc_eth_pdata *pdata);
+	int (*set_gmii_2500_speed)(struct dwc_eth_pdata *pdata);
+	int (*set_xgmii_10000_speed)(struct dwc_eth_pdata *pdata);
+	int (*set_xlgmii_25000_speed)(struct dwc_eth_pdata *pdata);
+	int (*set_xlgmii_40000_speed)(struct dwc_eth_pdata *pdata);
+	int (*set_xlgmii_50000_speed)(struct dwc_eth_pdata *pdata);
+	int (*set_xlgmii_100000_speed)(struct dwc_eth_pdata *pdata);
+
+	void (*enable_tx)(struct dwc_eth_pdata *pdata);
+	void (*disable_tx)(struct dwc_eth_pdata *pdata);
+	void (*enable_rx)(struct dwc_eth_pdata *pdata);
+	void (*disable_rx)(struct dwc_eth_pdata *pdata);
+
+	void (*powerup_tx)(struct dwc_eth_pdata *pdata);
+	void (*powerdown_tx)(struct dwc_eth_pdata *pdata);
+	void (*powerup_rx)(struct dwc_eth_pdata *pdata);
+	void (*powerdown_rx)(struct dwc_eth_pdata *pdata);
+
+	int (*init)(struct dwc_eth_pdata *pdata);
+	int (*exit)(struct dwc_eth_pdata *pdata);
+
+	int (*enable_int)(struct dwc_eth_channel *channel,
+			  enum dwc_eth_int int_id);
+	int (*disable_int)(struct dwc_eth_channel *channel,
+			   enum dwc_eth_int int_id);
+	void (*dev_xmit)(struct dwc_eth_channel *channel);
+	int (*dev_read)(struct dwc_eth_channel *channel);
+
+	void (*tx_desc_init)(struct dwc_eth_channel *channel);
+	void (*rx_desc_init)(struct dwc_eth_channel *channel);
+	void (*tx_desc_reset)(struct dwc_eth_desc_data *desc_data);
+	void (*rx_desc_reset)(struct dwc_eth_pdata *pdata,
+			      struct dwc_eth_desc_data *desc_data,
+			unsigned int index);
+	int (*is_last_desc)(struct dwc_eth_dma_desc *dma_desc);
+	int (*is_context_desc)(struct dwc_eth_dma_desc *dma_desc);
+	void (*tx_start_xmit)(struct dwc_eth_channel *channel,
+			      struct dwc_eth_ring *ring);
+
+	/* For FLOW ctrl */
+	int (*config_tx_flow_control)(struct dwc_eth_pdata *pdata);
+	int (*config_rx_flow_control)(struct dwc_eth_pdata *pdata);
+
+	/* For RX coalescing */
+	int (*config_rx_coalesce)(struct dwc_eth_pdata *pdata);
+	int (*config_tx_coalesce)(struct dwc_eth_pdata *pdata);
+	unsigned int (*usec_to_riwt)(struct dwc_eth_pdata *pdata,
+				     unsigned int usec);
+	unsigned int (*riwt_to_usec)(struct dwc_eth_pdata *pdata,
+				     unsigned int riwt);
+
+	/* For RX and TX threshold config */
+	int (*config_rx_threshold)(struct dwc_eth_pdata *pdata,
+				   unsigned int val);
+	int (*config_tx_threshold)(struct dwc_eth_pdata *pdata,
+				   unsigned int val);
+
+	/* For RX and TX Store and Forward Mode config */
+	int (*config_rsf_mode)(struct dwc_eth_pdata *pdata,
+			       unsigned int val);
+	int (*config_tsf_mode)(struct dwc_eth_pdata *pdata,
+			       unsigned int val);
+
+	/* For TX DMA Operate on Second Frame config */
+	int (*config_osp_mode)(struct dwc_eth_pdata *pdata);
+
+	/* For RX and TX PBL config */
+	int (*config_rx_pbl_val)(struct dwc_eth_pdata *pdata);
+	int (*get_rx_pbl_val)(struct dwc_eth_pdata *pdata);
+	int (*config_tx_pbl_val)(struct dwc_eth_pdata *pdata);
+	int (*get_tx_pbl_val)(struct dwc_eth_pdata *pdata);
+	int (*config_pblx8)(struct dwc_eth_pdata *pdata);
+
+	/* For MMC statistics */
+	void (*rx_mmc_int)(struct dwc_eth_pdata *pdata);
+	void (*tx_mmc_int)(struct dwc_eth_pdata *pdata);
+	void (*read_mmc_stats)(struct dwc_eth_pdata *pdata);
+
+	/* For Timestamp config */
+	int (*config_tstamp)(struct dwc_eth_pdata *pdata,
+			     unsigned int mac_tscr);
+	void (*update_tstamp_addend)(struct dwc_eth_pdata *pdata,
+				     unsigned int addend);
+	void (*set_tstamp_time)(struct dwc_eth_pdata *pdata,
+				unsigned int sec,
+				unsigned int nsec);
+	u64 (*get_tstamp_time)(struct dwc_eth_pdata *pdata);
+	u64 (*get_tx_tstamp)(struct dwc_eth_pdata *pdata);
+
+	/* For Data Center Bridging config */
+	void (*config_tc)(struct dwc_eth_pdata *pdata);
+	void (*config_dcb_tc)(struct dwc_eth_pdata *pdata);
+	void (*config_dcb_pfc)(struct dwc_eth_pdata *pdata);
+
+	/* For Receive Side Scaling */
+	int (*enable_rss)(struct dwc_eth_pdata *pdata);
+	int (*disable_rss)(struct dwc_eth_pdata *pdata);
+	int (*set_rss_hash_key)(struct dwc_eth_pdata *pdata,
+				const u8 *key);
+	int (*set_rss_lookup_table)(struct dwc_eth_pdata *pdata,
+				    const u32 *table);
+};
+
+/* This structure contains flags that indicate what hardware features
+ * or configurations are present in the device.
+ */
+struct dwc_eth_hw_features {
+	/* HW Version */
+	unsigned int version;
+
+	/* HW Feature Register0 */
+	unsigned int phyifsel;		/* PHY interface support */
+	unsigned int vlhash;		/* VLAN Hash Filter */
+	unsigned int sma;		/* SMA(MDIO) Interface */
+	unsigned int rwk;		/* PMT remote wake-up packet */
+	unsigned int mgk;		/* PMT magic packet */
+	unsigned int mmc;		/* RMON module */
+	unsigned int aoe;		/* ARP Offload */
+	unsigned int ts;		/* IEEE 1588-2008 Advanced Timestamp */
+	unsigned int eee;		/* Energy Efficient Ethernet */
+	unsigned int tx_coe;		/* Tx Checksum Offload */
+	unsigned int rx_coe;		/* Rx Checksum Offload */
+	unsigned int addn_mac;		/* Additional MAC Addresses */
+	unsigned int ts_src;		/* Timestamp Source */
+	unsigned int sa_vlan_ins;	/* Source Address or VLAN Insertion */
+
+	/* HW Feature Register1 */
+	unsigned int rx_fifo_size;	/* MTL Receive FIFO Size */
+	unsigned int tx_fifo_size;	/* MTL Transmit FIFO Size */
+	unsigned int adv_ts_hi;		/* Advance Timestamping High Word */
+	unsigned int dma_width;		/* DMA width */
+	unsigned int dcb;		/* DCB Feature */
+	unsigned int sph;		/* Split Header Feature */
+	unsigned int tso;		/* TCP Segmentation Offload */
+	unsigned int dma_debug;		/* DMA Debug Registers */
+	unsigned int rss;		/* Receive Side Scaling */
+	unsigned int tc_cnt;		/* Number of Traffic Classes */
+	unsigned int hash_table_size;	/* Hash Table Size */
+	unsigned int l3l4_filter_num;	/* Number of L3-L4 Filters */
+
+	/* HW Feature Register2 */
+	unsigned int rx_q_cnt;		/* Number of MTL Receive Queues */
+	unsigned int tx_q_cnt;		/* Number of MTL Transmit Queues */
+	unsigned int rx_ch_cnt;		/* Number of DMA Receive Channels */
+	unsigned int tx_ch_cnt;		/* Number of DMA Transmit Channels */
+	unsigned int pps_out_num;	/* Number of PPS outputs */
+	unsigned int aux_snap_num;	/* Number of Aux snapshot inputs */
+};
+
+struct dwc_eth_pdata {
+	struct net_device *netdev;
+	struct pci_dev *pcidev;
+	struct device *dev;
+
+	struct dwc_eth_hw_ops hw_ops;
+	struct dwc_eth_hw_ops *hw2_ops;
+	struct dwc_eth_desc_ops desc_ops;
+
+	/* Device statistics */
+	struct dwc_eth_stats stats;
+
+	u32 msg_enable;
+
+	/* MAC registers base */
+	void __iomem *mac_regs;
+
+	/* Hardware features of the device */
+	struct dwc_eth_hw_features hw_feat;
+
+	struct workqueue_struct *dev_workqueue;
+	struct work_struct restart_work;
+
+	/* AXI DMA settings */
+	unsigned int coherent;
+	unsigned int axdomain;
+	unsigned int arcache;
+	unsigned int awcache;
+
+	/* Rings for Tx/Rx on a DMA channel */
+	struct dwc_eth_channel *channel_head;
+	unsigned int channel_count;
+	unsigned int tx_ring_count;
+	unsigned int rx_ring_count;
+	unsigned int tx_desc_count;
+	unsigned int rx_desc_count;
+	unsigned int tx_q_count;
+	unsigned int rx_q_count;
+
+	/* Tx/Rx common settings */
+	unsigned int pblx8;
+
+	/* Tx settings */
+	unsigned int tx_sf_mode;
+	unsigned int tx_threshold;
+	unsigned int tx_pbl;
+	unsigned int tx_osp_mode;
+
+	/* Rx settings */
+	unsigned int rx_sf_mode;
+	unsigned int rx_threshold;
+	unsigned int rx_pbl;
+
+	/* Tx coalescing settings */
+	unsigned int tx_usecs;
+	unsigned int tx_frames;
+
+	/* Rx coalescing settings */
+	unsigned int rx_riwt;
+	unsigned int rx_usecs;
+	unsigned int rx_frames;
+
+	/* Current Rx buffer size */
+	unsigned int rx_buf_size;
+
+	/* Flow control settings */
+	unsigned int pause_autoneg;
+	unsigned int tx_pause;
+	unsigned int rx_pause;
+
+	/* Device interrupt number */
+	int dev_irq;
+	unsigned int per_channel_irq;
+	int channel_irq[DWC_ETH_MAX_DMA_CHANNELS];
+
+	/* Netdev related settings */
+	unsigned char mac_addr[ETH_ALEN];
+	netdev_features_t netdev_features;
+	struct napi_struct napi;
+
+	/* Filtering support */
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
+
+	/* Device clocks */
+	unsigned long sysclk_rate;
+	unsigned long ptpclk_rate;
+
+	/* Keeps track of power mode */
+	unsigned int power_down;
+
+	/* Overall device lock */
+	spinlock_t lock;
+	/* RSS addressing mutex */
+	struct mutex rss_mutex;
+	/* XPCS indirect addressing mutex */
+	struct mutex pcs_mutex;
+
+	/* Receive Side Scaling settings */
+	u8 rss_key[DWC_ETH_RSS_HASH_KEY_SIZE];
+	u32 rss_table[DWC_ETH_RSS_MAX_TABLE_SIZE];
+	u32 rss_options;
+
+	/* MDIO settings */
+	int mdio_en;
+	struct module *phy_module;
+	char *mii_bus_id;
+	struct mii_bus *mii;
+	int mdio_mmd;
+	struct phy_device *phydev;
+	int default_autoneg;
+	int default_speed;
+
+	/* Current PHY settings */
+	phy_interface_t phy_mode;
+	int phy_link;
+	int phy_speed;
+	unsigned int phy_tx_pause;
+	unsigned int phy_rx_pause;
+
+	/* Timestamp support */
+	spinlock_t tstamp_lock;
+	struct ptp_clock_info ptp_clock_info;
+	struct ptp_clock *ptp_clock;
+	struct hwtstamp_config tstamp_config;
+	struct cyclecounter tstamp_cc;
+	struct timecounter tstamp_tc;
+	unsigned int tstamp_addend;
+	struct work_struct tx_tstamp_work;
+	struct sk_buff *tx_tstamp_skb;
+	u64 tx_tstamp;
+
+	/* DCB support */
+	struct ieee_ets *ets;
+	struct ieee_pfc *pfc;
+	unsigned int q2tc_map[DWC_ETH_MAX_QUEUES];
+	unsigned int prio2q_map[IEEE_8021QAZ_MAX_TCS];
+	u8 num_tcs;
+
+	/* Device control parameters */
+	unsigned int tx_max_buf_size;
+	unsigned int rx_min_buf_size;
+	unsigned int rx_buf_align;
+	unsigned int tx_max_desc_nr;
+	unsigned int skb_alloc_size;
+	unsigned int tx_desc_max_proc;
+	unsigned int tx_desc_min_free;
+	unsigned int rx_desc_max_dirty;
+	unsigned int dma_stop_timeout;
+	unsigned int max_flow_control_queues;
+	unsigned int max_dma_riwt;
+	unsigned int tstamp_ssinc;
+	unsigned int tstamp_snsinc;
+	unsigned int sph_hdsms_size;
+
+	char drv_name[32];
+	char drv_ver[32];
+
+#ifdef CONFIG_DEBUG_FS
+	struct dentry *dwc_eth_debugfs;
+
+	unsigned int debugfs_xlgmac_reg;
+	unsigned int debugfs_xlgpcs_mmd;
+	unsigned int debugfs_xlgpcs_reg;
+#endif
+};
+
+void dwc_eth_ptp_register(struct dwc_eth_pdata *pdata);
+void dwc_eth_ptp_unregister(struct dwc_eth_pdata *pdata);
+void dwc_eth_init_desc_ops(struct dwc_eth_desc_ops *desc_ops);
+void dwc_eth_init_hw_ops(struct dwc_eth_hw_ops *hw_ops);
+const struct net_device_ops *dwc_eth_get_netdev_ops(void);
+const struct ethtool_ops *dwc_eth_get_ethtool_ops(void);
+#ifdef CONFIG_DWC_ETH_DCB
+const struct dcbnl_rtnl_ops *dwc_eth_get_dcbnl_ops(void);
+#endif
+void dwc_eth_dump_tx_desc(struct dwc_eth_pdata *pdata,
+			  struct dwc_eth_ring *ring,
+				unsigned int idx,
+				unsigned int count,
+				unsigned int flag);
+void dwc_eth_dump_rx_desc(struct dwc_eth_pdata *pdata,
+			  struct dwc_eth_ring *ring,
+				unsigned int idx);
+void dwc_eth_print_pkt(struct net_device *netdev,
+		       struct sk_buff *skb, bool tx_rx);
+void dwc_eth_get_all_hw_features(struct dwc_eth_pdata *pdata);
+void dwc_eth_print_all_hw_features(struct dwc_eth_pdata *pdata);
+int dwc_eth_powerup(struct net_device *netdev, unsigned int caller);
+int dwc_eth_powerdown(struct net_device *netdev, unsigned int caller);
+int dwc_eth_mdio_register(struct dwc_eth_pdata *pdata);
+void dwc_eth_mdio_unregister(struct dwc_eth_pdata *pdata);
+
+#ifdef CONFIG_DEBUG_FS
+void xlgmac_debugfs_init(struct dwc_eth_pdata *pdata);
+void xlgmac_debugfs_exit(struct dwc_eth_pdata *pdata);
+#else
+static inline void xlgmac_debugfs_init(struct dwc_eth_pdata *pdata) {}
+static inline void xlgmac_debugfs_exit(struct dwc_eth_pdata *pdata) {}
+#endif
+
+/* For debug prints */
+#ifdef DWC_ETH_DEBUG
+#define DBGPR(fmt, args...) \
+	pr_alert("[%s,%d]:" fmt, __func__, __LINE__, ## args)
+#define TRACE(fmt, args...) \
+	pr_alert(fmt "%s\n", ## args, __func__)
+#else
+#define DBGPR(x...)		do { } while (0)
+#define TRACE(fmt, args...)	do { } while (0)
+#endif
+
+#endif /* __DWC_ETH_H__ */
diff --git a/drivers/net/ethernet/synopsys/dwc/dwc-xlgmac-pci.c b/drivers/net/ethernet/synopsys/dwc/dwc-xlgmac-pci.c
new file mode 100644
index 0000000..685d050
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc/dwc-xlgmac-pci.c
@@ -0,0 +1,538 @@
+/*
+ * Synopsys DesignWare Core Enterprise Ethernet (XLGMAC) Driver
+ *
+ * Copyright (C) 2015-2016 Synopsys, Inc. (www.synopsys.com)
+ *
+ * Author: Jie Deng <jiedeng@synopsys.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/pci.h>
+
+#include "dwc-eth.h"
+#include "dwc-eth-regacc.h"
+#include "dwc-xlgmac.h"
+
+static int debug = -1;
+module_param(debug, int, 0644);
+MODULE_PARM_DESC(debug, "DWC ethernet debug level (0=none,...,16=all)");
+static const u32 default_msg_level = (NETIF_MSG_LINK | NETIF_MSG_IFDOWN |
+				      NETIF_MSG_IFUP);
+
+/* Currently it does not support MDIO */
+static int mdio_en;
+module_param(mdio_en, int, 0644);
+MODULE_PARM_DESC(mdio_en, "Enable MDIO. Disable it when using FPGA for test");
+
+static unsigned char dev_addr[6] = {0, 0x55, 0x7b, 0xb5, 0x7d, 0xf7};
+static unsigned long dwc_xlgmac_pci_base_addr;
+
+static void xlgmac_read_mac_addr(struct dwc_eth_pdata *pdata)
+{
+	struct net_device *netdev = pdata->netdev;
+
+	/* Currently it uses a static mac address for test */
+	memcpy(pdata->mac_addr, dev_addr, netdev->addr_len);
+}
+
+static void xlgmac_init_tx_coalesce(struct dwc_eth_pdata *pdata)
+{
+	TRACE("-->");
+
+	pdata->tx_usecs = XLGMAC_INIT_DMA_TX_USECS;
+	pdata->tx_frames = XLGMAC_INIT_DMA_TX_FRAMES;
+
+	TRACE("<--");
+}
+
+static void xlgmac_init_rx_coalesce(struct dwc_eth_pdata *pdata)
+{
+	struct dwc_eth_hw_ops *hw_ops = &pdata->hw_ops;
+
+	TRACE("-->");
+
+	pdata->rx_riwt = hw_ops->usec_to_riwt(pdata, XLGMAC_INIT_DMA_RX_USECS);
+	pdata->rx_usecs = XLGMAC_INIT_DMA_RX_USECS;
+	pdata->rx_frames = XLGMAC_INIT_DMA_RX_FRAMES;
+
+	TRACE("<--");
+}
+
+static void xlgmac_init_coalesce(struct dwc_eth_pdata *pdata)
+{
+	xlgmac_init_tx_coalesce(pdata);
+	xlgmac_init_rx_coalesce(pdata);
+}
+
+static void xlgmac_default_config(struct dwc_eth_pdata *pdata)
+{
+	TRACE("-->");
+
+	pdata->pblx8 = DMA_PBL_X8_ENABLE;
+	pdata->tx_sf_mode = MTL_TSF_ENABLE;
+	pdata->tx_threshold = MTL_TX_THRESHOLD_64;
+	pdata->tx_pbl = DMA_PBL_16;
+	pdata->tx_osp_mode = DMA_OSP_ENABLE;
+	pdata->rx_sf_mode = MTL_RSF_DISABLE;
+	pdata->rx_threshold = MTL_RX_THRESHOLD_64;
+	pdata->rx_pbl = DMA_PBL_16;
+	pdata->pause_autoneg = 1;
+	pdata->tx_pause = 1;
+	pdata->rx_pause = 1;
+	pdata->phy_speed = SPEED_UNKNOWN;
+	pdata->power_down = 0;
+	pdata->default_autoneg = AUTONEG_ENABLE;
+	pdata->default_speed = SPEED_100000;
+	pdata->coherent = 1;
+	pdata->mdio_en = mdio_en;
+
+	pdata->sysclk_rate		= XLGMAC_SYSCLOCK;
+	pdata->ptpclk_rate		= XLGMAC_SYSCLOCK;
+	pdata->tx_max_buf_size		= XLGMAC_TX_MAX_BUF_SIZE;
+	pdata->rx_min_buf_size		= XLGMAC_RX_MIN_BUF_SIZE;
+	pdata->rx_buf_align		= XLGMAC_RX_BUF_ALIGN;
+	pdata->tx_max_desc_nr		= XLGMAC_TX_MAX_DESC_NR;
+	pdata->skb_alloc_size		= XLGMAC_SKB_ALLOC_SIZE;
+	pdata->tx_desc_max_proc		= XLGMAC_TX_DESC_MAX_PROC;
+	pdata->tx_desc_min_free		= XLGMAC_TX_DESC_MIN_FREE;
+	pdata->rx_desc_max_dirty	= XLGMAC_RX_DESC_MAX_DIRTY;
+	pdata->dma_stop_timeout		= XLGMAC_DMA_STOP_TIMEOUT;
+	pdata->max_flow_control_queues	= XLGMAC_MAX_FLOW_CONTROL_QUEUES;
+	pdata->max_dma_riwt		= XLGMAC_MAX_DMA_RIWT;
+	pdata->tstamp_ssinc		= XLGMAC_TSTAMP_SSINC;
+	pdata->tstamp_snsinc		= XLGMAC_TSTAMP_SNSINC;
+	pdata->sph_hdsms_size		= XLGMAC_SPH_HDSMS_SIZE;
+
+	strlcpy(pdata->drv_name, XLGMAC_DRV_NAME, sizeof(pdata->drv_name));
+	strlcpy(pdata->drv_ver, XLGMAC_DRV_VERSION, sizeof(pdata->drv_ver));
+
+	TRACE("<--");
+}
+
+static void xlgmac_init_all_ops(struct dwc_eth_pdata *pdata)
+{
+	dwc_eth_init_desc_ops(&pdata->desc_ops);
+	dwc_eth_init_hw_ops(&pdata->hw_ops);
+	xlgmac_init_hw_ops(pdata->hw2_ops);
+}
+
+static int xlgmac_get_resources(struct dwc_eth_pdata *pdata)
+{
+	struct pci_dev *pcidev = pdata->pcidev;
+	resource_size_t bar_length;
+	unsigned int i;
+	int ret = 0;
+
+	pdata->dev_irq = pcidev->irq;
+
+	for (i = 0; i < 6; i++) {
+		bar_length = pci_resource_len(pcidev, i);
+		if (bar_length == 0)
+			continue;
+
+		pdata->mac_regs = pci_iomap(pcidev, i, bar_length);
+		dwc_xlgmac_pci_base_addr = (unsigned long)(pdata->mac_regs);
+		if (!pdata->mac_regs) {
+			dev_err(pdata->dev, "cannot map register memory\n");
+			ret = -EIO;
+		}
+		break;
+	}
+
+	return ret;
+}
+
+static int xlgmac_init(struct dwc_eth_pdata *pdata)
+{
+	struct net_device *netdev = pdata->netdev;
+	unsigned int i;
+	int ret;
+
+	/* Set default configuration data */
+	xlgmac_default_config(pdata);
+
+	/* Set irq, base_addr, MAC address, */
+	netdev->irq = pdata->dev_irq;
+	netdev->base_addr = (unsigned long)pdata->mac_regs;
+	xlgmac_read_mac_addr(pdata);
+	memcpy(netdev->dev_addr, pdata->mac_addr, netdev->addr_len);
+
+	/* Set the DMA coherency values */
+	if (pdata->coherent) {
+		pdata->axdomain = XLGMAC_DMA_OS_AXDOMAIN;
+		pdata->arcache = XLGMAC_DMA_OS_ARCACHE;
+		pdata->awcache = XLGMAC_DMA_OS_AWCACHE;
+	} else {
+		pdata->axdomain = XLGMAC_DMA_SYS_AXDOMAIN;
+		pdata->arcache = XLGMAC_DMA_SYS_ARCACHE;
+		pdata->awcache = XLGMAC_DMA_SYS_AWCACHE;
+	}
+
+	/* Set all the function pointers */
+	xlgmac_init_all_ops(pdata);
+
+	/* Issue software reset to device */
+	pdata->hw_ops.exit(pdata);
+
+	/* Populate the hardware features */
+	dwc_eth_get_all_hw_features(pdata);
+	dwc_eth_print_all_hw_features(pdata);
+
+	/* Get the PHY mode */
+	pdata->phy_mode = PHY_INTERFACE_MODE_XLGMII;
+
+	/* Set the DMA mask */
+	ret = dma_set_mask_and_coherent(pdata->dev,
+					DMA_BIT_MASK(pdata->hw_feat.dma_width));
+	if (ret) {
+		dev_err(pdata->dev, "dma_set_mask_and_coherent failed\n");
+		goto err_out;
+	}
+
+	/* Channel and ring params initializtion
+	 *  pdata->channel_count;
+	 *  pdata->tx_ring_count;
+	 *  pdata->rx_ring_count;
+	 *  pdata->tx_desc_count;
+	 *  pdata->rx_desc_count;
+	 */
+	BUILD_BUG_ON_NOT_POWER_OF_2(XLGMAC_TX_DESC_CNT);
+	pdata->tx_desc_count = XLGMAC_TX_DESC_CNT;
+	if (pdata->tx_desc_count & (pdata->tx_desc_count - 1)) {
+		dev_err(pdata->dev, "tx descriptor count (%d) is not valid\n",
+			pdata->tx_desc_count);
+		ret = -EINVAL;
+		goto err_out;
+	}
+	BUILD_BUG_ON_NOT_POWER_OF_2(XLGMAC_RX_DESC_CNT);
+	pdata->rx_desc_count = XLGMAC_RX_DESC_CNT;
+	if (pdata->rx_desc_count & (pdata->rx_desc_count - 1)) {
+		dev_err(pdata->dev, "rx descriptor count (%d) is not valid\n",
+			pdata->rx_desc_count);
+		ret = -EINVAL;
+		goto err_out;
+	}
+
+	/* Calculate the number of Tx and Rx rings to be created
+	 *  -Tx (DMA) Channels map 1-to-1 to Tx Queues so set
+	 *   the number of Tx queues to the number of Tx channels
+	 *   enabled
+	 *  -Rx (DMA) Channels do not map 1-to-1 so use the actual
+	 *   number of Rx queues
+	 */
+	pdata->tx_ring_count = min_t(unsigned int, num_online_cpus(),
+				     pdata->hw_feat.tx_ch_cnt);
+	pdata->tx_q_count = pdata->tx_ring_count;
+	ret = netif_set_real_num_tx_queues(netdev, pdata->tx_ring_count);
+	if (ret) {
+		dev_err(pdata->dev, "error setting real tx queue count\n");
+		goto err_out;
+	}
+
+	pdata->rx_ring_count = min_t(unsigned int,
+				     netif_get_num_default_rss_queues(),
+				     pdata->hw_feat.rx_ch_cnt);
+	pdata->rx_q_count = pdata->hw_feat.rx_q_cnt;
+	ret = netif_set_real_num_rx_queues(netdev, pdata->rx_ring_count);
+	if (ret) {
+		dev_err(pdata->dev, "error setting real rx queue count\n");
+		goto err_out;
+	}
+
+	pdata->channel_count =
+		max_t(unsigned int, pdata->tx_ring_count, pdata->rx_ring_count);
+
+	DBGPR("  channel_count=%u\n", pdata->channel_count);
+	DBGPR("  tx_ring_count=%u, tx_q_count=%u\n",
+	      pdata->tx_ring_count, pdata->tx_q_count);
+	DBGPR("  rx_ring_count=%u, rx_q_count=%u\n",
+	      pdata->rx_ring_count, pdata->rx_q_count);
+
+	/* Initialize RSS hash key and lookup table */
+	netdev_rss_key_fill(pdata->rss_key, sizeof(pdata->rss_key));
+
+	for (i = 0; i < DWC_ETH_RSS_MAX_TABLE_SIZE; i++)
+		DWC_ETH_SET_BITS(pdata->rss_table[i], MAC_RSSDR, DMCH,
+				 i % pdata->rx_ring_count);
+
+	DWC_ETH_SET_BITS(pdata->rss_options, MAC_RSSCR, IP2TE, 1);
+	DWC_ETH_SET_BITS(pdata->rss_options, MAC_RSSCR, TCP4TE, 1);
+	DWC_ETH_SET_BITS(pdata->rss_options, MAC_RSSCR, UDP4TE, 1);
+
+	/* Set device operations */
+	netdev->netdev_ops = dwc_eth_get_netdev_ops();
+	netdev->ethtool_ops = dwc_eth_get_ethtool_ops();
+#ifdef CONFIG_DWC_ETH_DCB
+	netdev->dcbnl_ops = dwc_eth_get_dcbnl_ops();
+#endif
+
+	/* Set device features */
+	if (pdata->hw_feat.tso) {
+		netdev->hw_features = NETIF_F_TSO;
+		netdev->hw_features |= NETIF_F_TSO6;
+		netdev->hw_features |= NETIF_F_SG;
+		netdev->hw_features |= NETIF_F_IP_CSUM;
+		netdev->hw_features |= NETIF_F_IPV6_CSUM;
+	} else if (pdata->hw_feat.tx_coe) {
+		netdev->hw_features = NETIF_F_IP_CSUM;
+		netdev->hw_features |= NETIF_F_IPV6_CSUM;
+	}
+
+	if (pdata->hw_feat.rx_coe) {
+		netdev->hw_features |= NETIF_F_RXCSUM;
+		netdev->hw_features |= NETIF_F_GRO;
+	}
+
+	if (pdata->hw_feat.rss)
+		netdev->hw_features |= NETIF_F_RXHASH;
+
+	netdev->vlan_features |= netdev->hw_features;
+
+	netdev->hw_features |= NETIF_F_HW_VLAN_CTAG_RX;
+	if (pdata->hw_feat.sa_vlan_ins)
+		netdev->hw_features |= NETIF_F_HW_VLAN_CTAG_TX;
+	if (pdata->hw_feat.vlhash)
+		netdev->hw_features |= NETIF_F_HW_VLAN_CTAG_FILTER;
+
+	netdev->features |= netdev->hw_features;
+	pdata->netdev_features = netdev->features;
+
+	netdev->priv_flags |= IFF_UNICAST_FLT;
+
+	/* Use default watchdog timeout */
+	netdev->watchdog_timeo = 0;
+
+	xlgmac_init_coalesce(pdata);
+
+	return 0;
+
+err_out:
+
+	return ret;
+}
+
+#ifdef CONFIG_PM
+
+static int xlgmac_suspend(struct device *dev)
+{
+	struct net_device *netdev = dev_get_drvdata(dev);
+	int ret = 0;
+
+	TRACE("-->");
+
+	if (netif_running(netdev))
+		ret = dwc_eth_powerdown(netdev, DWC_ETH_DRIVER_CONTEXT);
+
+	TRACE("<--");
+
+	return ret;
+}
+
+static int xlgmac_resume(struct device *dev)
+{
+	struct net_device *netdev = dev_get_drvdata(dev);
+	int ret = 0;
+
+	TRACE("-->");
+
+	if (netif_running(netdev))
+		ret = dwc_eth_powerup(netdev, DWC_ETH_DRIVER_CONTEXT);
+
+	TRACE("<--");
+
+	return ret;
+}
+
+static const struct dev_pm_ops xlgmac_pm_ops = {
+	.suspend		= xlgmac_suspend,
+	.resume			= xlgmac_resume,
+};
+
+#define XLGMAC_PM_OPS	(&xlgmac_pm_ops)
+
+#else /* CONFIG_PM */
+
+#define XLGMAC_PM_OPS	NULL
+
+#endif /* CONFIG_PM */
+
+static int xlgmac_probe(struct pci_dev *pcidev, const struct pci_device_id *id)
+{
+	struct net_device *netdev;
+	struct dwc_eth_pdata *pdata;
+	struct device *dev = &pcidev->dev;
+	int ret;
+
+	TRACE("-->");
+
+	ret = pci_enable_device(pcidev);
+	if (ret) {
+		dev_err(dev, "fail to enable device\n");
+		goto err_enable_fail;
+	}
+
+	ret = pci_request_regions(pcidev, XLGMAC_DRV_NAME);
+	if (ret) {
+		dev_err(dev, "fail to get pci regions\n");
+		goto err_request_regions_fail;
+	}
+	pci_set_master(pcidev);
+
+	netdev = alloc_etherdev_mq(sizeof(struct dwc_eth_pdata),
+				   DWC_ETH_MAX_DMA_CHANNELS);
+
+	if (!netdev) {
+		dev_err(dev, "alloc_etherdev failed\n");
+		ret = -ENOMEM;
+		goto err_alloc_eth;
+	}
+	SET_NETDEV_DEV(netdev, dev);
+	pdata = netdev_priv(netdev);
+	pdata->netdev = netdev;
+	pdata->pcidev = pcidev;
+	pdata->dev = dev;
+	pci_set_drvdata(pcidev, netdev);
+
+	spin_lock_init(&pdata->lock);
+	mutex_init(&pdata->pcs_mutex);
+	mutex_init(&pdata->rss_mutex);
+	spin_lock_init(&pdata->tstamp_lock);
+
+	pdata->msg_enable = netif_msg_init(debug, default_msg_level);
+
+	/* Get the reg base and irq */
+	ret = xlgmac_get_resources(pdata);
+	if (ret) {
+		dev_err(dev, "xlgmac can not get resources\n");
+		goto err_resources;
+	}
+
+	ret = xlgmac_init(pdata);
+	if (ret) {
+		dev_err(dev, "xlgmac init failed\n");
+		goto err_init;
+	}
+
+	if (pdata->mdio_en) {
+		/* Prepare to regsiter with MDIO */
+		pdata->mii_bus_id = kasprintf(GFP_KERNEL, "%s",
+					      pci_name(pcidev));
+		if (!pdata->mii_bus_id) {
+			dev_err(dev, "failed to allocate mii bus id\n");
+			ret = -ENOMEM;
+			goto err_mii_bus_id;
+		}
+		ret = dwc_eth_mdio_register(pdata);
+		if (ret)
+			goto err_mdio_register;
+
+		netif_carrier_off(netdev);
+	}
+
+	ret = register_netdev(netdev);
+	if (ret) {
+		dev_err(dev, "net device registration failed\n");
+		goto err_netdev;
+	}
+
+	/* Create workqueues */
+	pdata->dev_workqueue =
+		create_singlethread_workqueue(netdev_name(netdev));
+	if (!pdata->dev_workqueue) {
+		dev_err(dev, "device workqueue creation failed\n");
+		ret = -ENOMEM;
+		goto err_wq;
+	}
+
+	dwc_eth_ptp_register(pdata);
+
+	xlgmac_debugfs_init(pdata);
+
+	netdev_notice(netdev, "net device enabled\n");
+
+	TRACE("<--");
+
+	return 0;
+
+err_wq:
+	unregister_netdev(netdev);
+
+err_netdev:
+	if (pdata->mdio_en)
+		dwc_eth_mdio_unregister(pdata);
+
+err_mdio_register:
+	if (pdata->mdio_en)
+		kfree(pdata->mii_bus_id);
+
+err_mii_bus_id:
+err_resources:
+err_init:
+	free_netdev(netdev);
+
+err_alloc_eth:
+	pci_release_regions(pcidev);
+
+err_request_regions_fail:
+	pci_disable_device(pcidev);
+
+err_enable_fail:
+	return ret;
+}
+
+static void xlgmac_remove(struct pci_dev *pcidev)
+{
+	struct net_device *netdev = pci_get_drvdata(pcidev);
+	struct dwc_eth_pdata *pdata = netdev_priv(netdev);
+
+	TRACE("-->");
+
+	xlgmac_debugfs_exit(pdata);
+
+	dwc_eth_ptp_unregister(pdata);
+
+	flush_workqueue(pdata->dev_workqueue);
+	destroy_workqueue(pdata->dev_workqueue);
+
+	unregister_netdev(netdev);
+
+	if (pdata->mdio_en) {
+		dwc_eth_mdio_unregister(pdata);
+		kfree(pdata->mii_bus_id);
+	}
+
+	free_netdev(netdev);
+
+	pci_set_drvdata(pcidev, NULL);
+	pci_iounmap(pcidev, (void __iomem *)dwc_xlgmac_pci_base_addr);
+	pci_release_regions(pcidev);
+	pci_disable_device(pcidev);
+
+	TRACE("<--");
+}
+
+static const struct pci_device_id xlgmac_pci_tbl[] = {
+	{ PCI_DEVICE(PCI_VENDOR_ID_SYNOPSYS, 0x1018) },
+	{ 0 }
+};
+MODULE_DEVICE_TABLE(pci, xlgmac_pci_tbl);
+
+static struct pci_driver xlgmac_pci_driver = {
+	.name		= XLGMAC_DRV_NAME,
+	.id_table	= xlgmac_pci_tbl,
+	.probe		= xlgmac_probe,
+	.remove		= xlgmac_remove,
+	.driver.pm	= XLGMAC_PM_OPS,
+};
+
+module_pci_driver(xlgmac_pci_driver);
+
+MODULE_DESCRIPTION("PCI driver for Synopsys XLGMAC");
+MODULE_VERSION(XLGMAC_DRV_VERSION);
+MODULE_AUTHOR("Jie Deng <jiedeng@synopsys.com>");
+MODULE_LICENSE("GPL v2");
diff --git a/drivers/net/ethernet/synopsys/dwc/dwc-xlgmac.c b/drivers/net/ethernet/synopsys/dwc/dwc-xlgmac.c
new file mode 100644
index 0000000..bcf79b9
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc/dwc-xlgmac.c
@@ -0,0 +1,135 @@
+/*
+ * Synopsys DesignWare Core Enterprise Ethernet (XLGMAC) Driver
+ *
+ * Copyright (C) 2015-2016 Synopsys, Inc. (www.synopsys.com)
+ *
+ * Author: Jie Deng <jiedeng@synopsys.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include "dwc-eth.h"
+#include "dwc-eth-regacc.h"
+#include "dwc-xlgmac.h"
+
+static int xlgmac_mdio_wait_until_free(struct dwc_eth_pdata *pdata)
+{
+	unsigned int timeout;
+
+	TRACE("-->");
+
+	/* Wait till the bus is free */
+	timeout = XLGMAC_MDIO_RD_TIMEOUT;
+	while (DWC_ETH_IOREAD_BITS(pdata, MAC_MDIOSCCDR, BUSY) && timeout) {
+		cpu_relax();
+		timeout--;
+	}
+
+	DBGPR("  mido_rd_time=%#x\n", (XLGMAC_MDIO_RD_TIMEOUT - timeout));
+
+	if (!timeout) {
+		dev_err(pdata->dev, "timeout waiting for bus to be free\n");
+		return -ETIMEDOUT;
+	}
+
+	TRACE("<--");
+
+	return 0;
+}
+
+static int xlgmac_read_mmd_regs(struct dwc_eth_pdata *pdata,
+				int prtad, int mmd_reg)
+{
+	int mmd_data;
+	int ret;
+	unsigned int scar;
+	unsigned int sccdr = 0;
+
+	TRACE("-->");
+
+	mutex_lock(&pdata->pcs_mutex);
+
+	ret = xlgmac_mdio_wait_until_free(pdata);
+	if (ret)
+		return ret;
+
+	/* Updating desired bits for read operation */
+	scar = DWC_ETH_IOREAD(pdata, MAC_MDIOSCAR);
+	scar = scar & (0x3e00000UL);
+	scar = scar | ((prtad) << MAC_MDIOSCAR_PA_POS) |
+		((mmd_reg) << MAC_MDIOSCAR_RA_POS);
+	DWC_ETH_IOWRITE(pdata, MAC_MDIOSCAR, scar);
+
+	/* Initiate the read */
+	sccdr = sccdr | ((0x1) << MAC_MDIOSCCDR_BUSY_POS) |
+		((0x5) << MAC_MDIOSCCDR_CR_POS) |
+		((0x1) << MAC_MDIOSCCDR_SADDR_POS) |
+		((0x3) << MAC_MDIOSCCDR_CMD_POS);
+	DWC_ETH_IOWRITE(pdata, MAC_MDIOSCCDR, sccdr);
+
+	ret = xlgmac_mdio_wait_until_free(pdata);
+	if (ret)
+		return ret;
+
+	/* Read the data */
+	mmd_data = DWC_ETH_IOREAD_BITS(pdata, MAC_MDIOSCCDR, SDATA);
+
+	mutex_unlock(&pdata->pcs_mutex);
+
+	TRACE("<--");
+
+	return mmd_data;
+}
+
+static int xlgmac_write_mmd_regs(struct dwc_eth_pdata *pdata,
+				 int prtad, int mmd_reg, int mmd_data)
+{
+	int ret;
+	unsigned int scar;
+	unsigned int sccdr = 0;
+
+	TRACE("-->");
+
+	mutex_lock(&pdata->pcs_mutex);
+
+	ret = xlgmac_mdio_wait_until_free(pdata);
+	if (ret)
+		return ret;
+
+	/* Updating desired bits for write operation */
+	scar = DWC_ETH_IOREAD(pdata, MAC_MDIOSCAR);
+	scar = scar & (0x3e00000UL);
+	scar = scar | ((prtad) << MAC_MDIOSCAR_PA_POS) |
+		((mmd_reg) << MAC_MDIOSCAR_RA_POS);
+	DWC_ETH_IOWRITE(pdata, MAC_MDIOSCAR, scar);
+
+	/* Initiate Write */
+	sccdr = sccdr | ((0x1) << MAC_MDIOSCCDR_BUSY_POS) |
+		((0x5) << MAC_MDIOSCCDR_CR_POS) |
+		((0x1) << MAC_MDIOSCCDR_SADDR_POS) |
+		((0x1) << MAC_MDIOSCCDR_CMD_POS) |
+		((mmd_data) << MAC_MDIOSCCDR_SDATA_POS);
+	DWC_ETH_IOWRITE(pdata, MAC_MDIOSCCDR, sccdr);
+
+	ret = xlgmac_mdio_wait_until_free(pdata);
+	if (ret)
+		return ret;
+
+	mutex_unlock(&pdata->pcs_mutex);
+
+	TRACE("<--");
+
+	return 0;
+}
+
+static struct dwc_eth_hw_ops xlgmac_hw_ops = {
+	.read_mmd_regs = xlgmac_read_mmd_regs,
+	.write_mmd_regs = xlgmac_write_mmd_regs,
+};
+
+void xlgmac_init_hw_ops(struct dwc_eth_hw_ops *hw_ops)
+{
+	hw_ops = &xlgmac_hw_ops;
+}
diff --git a/drivers/net/ethernet/synopsys/dwc/dwc-xlgmac.h b/drivers/net/ethernet/synopsys/dwc/dwc-xlgmac.h
new file mode 100644
index 0000000..44be317
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc/dwc-xlgmac.h
@@ -0,0 +1,85 @@
+/*
+ * Synopsys DesignWare Core Enterprise Ethernet (XLGMAC) Driver
+ *
+ * Copyright (C) 2015-2016 Synopsys, Inc. (www.synopsys.com)
+ *
+ * Author: Jie Deng <jiedeng@synopsys.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef __DWC_XLGMAC_H__
+#define __DWC_XLGMAC_H__
+
+#include "dwc-eth.h"
+
+#define XLGMAC_DRV_NAME			"dwc-xlgmac"
+#define XLGMAC_DRV_VERSION		"1.0.0"
+#define XLGMAC_DRV_DESC			"Synopsys DWC XLGMAC Driver"
+
+/* Descriptor related defines */
+#define XLGMAC_TX_DESC_CNT		512
+#define XLGMAC_TX_DESC_MIN_FREE		(XLGMAC_TX_DESC_CNT >> 3)
+#define XLGMAC_TX_DESC_MAX_PROC		(XLGMAC_TX_DESC_CNT >> 1)
+#define XLGMAC_RX_DESC_CNT		512
+#define XLGMAC_RX_DESC_MAX_DIRTY	(XLGMAC_RX_DESC_CNT >> 3)
+
+#define XLGMAC_TX_MAX_BUF_SIZE		(0x3fff & ~(64 - 1))
+
+/* Descriptors required for maximum contiguous TSO/GSO packet */
+#define XLGMAC_TX_MAX_SPLIT	((GSO_MAX_SIZE / XLGMAC_TX_MAX_BUF_SIZE) + 1)
+
+/* Maximum possible descriptors needed for an SKB:
+ * - Maximum number of SKB frags
+ * - Maximum descriptors for contiguous TSO/GSO packet
+ * - Possible context descriptor
+ * - Possible TSO header descriptor
+ */
+#define XLGMAC_TX_MAX_DESC_NR	(MAX_SKB_FRAGS + XLGMAC_TX_MAX_SPLIT + 2)
+
+#define XLGMAC_RX_MIN_BUF_SIZE	(ETH_FRAME_LEN + ETH_FCS_LEN + VLAN_HLEN)
+#define XLGMAC_RX_BUF_ALIGN	64
+#define XLGMAC_SKB_ALLOC_SIZE	256
+#define XLGMAC_SPH_HDSMS_SIZE	2	/* Keep in sync with SKB_ALLOC_SIZE */
+
+#define XLGMAC_DMA_STOP_TIMEOUT	5
+
+/* DMA cache settings - Outer sharable, write-back, write-allocate */
+#define XLGMAC_DMA_OS_AXDOMAIN		0x2
+#define XLGMAC_DMA_OS_ARCACHE		0xb
+#define XLGMAC_DMA_OS_AWCACHE		0xf
+
+/* DMA cache settings - System, no caches used */
+#define XLGMAC_DMA_SYS_AXDOMAIN		0x3
+#define XLGMAC_DMA_SYS_ARCACHE		0x0
+#define XLGMAC_DMA_SYS_AWCACHE		0x0
+
+/* Default coalescing parameters */
+#define XLGMAC_INIT_DMA_TX_USECS	1000
+#define XLGMAC_INIT_DMA_TX_FRAMES	25
+
+#define XLGMAC_MAX_DMA_RIWT		0xff
+#define XLGMAC_INIT_DMA_RX_USECS	30
+#define XLGMAC_INIT_DMA_RX_FRAMES	25
+
+/* Flow control queue count */
+#define XLGMAC_MAX_FLOW_CONTROL_QUEUES	8
+
+/* Maximum MAC address hash table size (256 bits = 8 bytes) */
+#define XLGMAC_MAC_HASH_TABLE_SIZE	8
+
+/* Timestamp support - values based on 50MHz PTP clock
+ *   50MHz => 20 nsec
+ */
+#define XLGMAC_TSTAMP_SSINC		20
+#define XLGMAC_TSTAMP_SNSINC		0
+
+#define XLGMAC_MDIO_RD_TIMEOUT		10000
+
+#define XLGMAC_SYSCLOCK			62500000 /* System clock is 62.5MHz */
+
+void xlgmac_init_hw_ops(struct dwc_eth_hw_ops *hw_ops);
+
+#endif /* __DWC_XLGMAC_H__ */
-- 
1.9.1
