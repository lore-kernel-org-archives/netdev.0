From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v5 05/11] drivers: net: phy: xgene: Add MDIO driver
Date: Thu, 07 Jul 2016 22:13:39 -0700
Message-ID: <6F6C72D6-7D9D-4C38-8949-E3E51E8821ED@gmail.com>
References: <1467932579-14320-1-git-send-email-isubramanian@apm.com> <1467932579-14320-6-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	matthias.bgg@gmail.com, andrew@lunn.ch, linux@armlinux.org.uk
To: Iyappan Subramanian <isubramanian@apm.com>, davem@davemloft.net,
	netdev@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34824 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751581AbcGHFNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 01:13:52 -0400
In-Reply-To: <1467932579-14320-6-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On July 7, 2016 4:02:53 PM MST, Iyappan Subramanian <isubramanian@apm.com> wrote:
>Currently, SGMII based 1G rely on the hardware registers for link state
>and sometimes it's not reliable.  To get most accurate link state, this
>interface has to use the MDIO bus to poll the PHY.
>
>In X-Gene SoC, MDIO bus is shared across RGMII and SGMII based 1G
>interfaces, so adding this driver to manage MDIO bus.  This driver
>registers the mdio bus and registers the PHYs connected to it.

This driver contains both too much register abstraction and still duplicates quite the same code between the RGMII and XFI variants of the code...


>
>Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
>Tested-by: Fushen Chen <fchen@apm.com>
>Tested-by: Toan Le <toanle@apm.com>
>Tested-by: Matthias Brugger <mbrugger@suse.com>
>---
 bool xgene_enet_rd_indirect(void __iomem *addr, void __iomem
>*rd,
>+				   void __iomem *cmd, void __iomem *cmd_done,
>+				   u32 rd_addr, u32 *rd_data)
>+{
>+	u32 done;
>+	u8 wait = 10;
>+
>+	iowrite32(rd_addr, addr);
>+	iowrite32(XGENE_ENET_RD_CMD, cmd);
>+
>+	/* wait for read command to complete */
>+	while (!(done = ioread32(cmd_done)) && wait--)
>+		udelay(1);

Instead of an udelay you should consider either an usleep or cpu_relax here. The loop would be a lot more readable with the done assignment taken out.

>+
>+	if (!done)
>+		return false;
>+
>+	*rd_data = ioread32(rd);
>+	iowrite32(0, cmd);
>+
>+	return true;
>+}
>+
>+static void xgene_enet_rd_mcx_mac(struct xgene_mdio_pdata *pdata,
>+				  u32 rd_addr, u32 *rd_data)
>+{
>+	void __iomem *addr, *rd, *cmd, *cmd_done;
>+
>+	addr = pdata->mac_csr_addr + MAC_ADDR_REG_OFFSET;
>+	rd = pdata->mac_csr_addr + MAC_READ_REG_OFFSET;
>+	cmd = pdata->mac_csr_addr + MAC_COMMAND_REG_OFFSET;
>+	cmd_done = pdata->mac_csr_addr + MAC_COMMAND_DONE_REG_OFFSET;
>+
>+	if (!xgene_enet_rd_indirect(addr, rd, cmd, cmd_done, rd_addr,
>rd_data))
>+		dev_err(pdata->dev, "MCX mac read failed, addr: 0x%04x\n",
>+			rd_addr);

What is the purpose of this indirection with pdata here, this really impairs the readability...

>+#ifdef CONFIG_ACPI
>+static acpi_status acpi_register_phy(acpi_handle handle, u32 lvl,
>+				     void *context, void **ret)
>+{
>+	struct mii_bus *mdio = context;
>+	struct acpi_device *adev;
>+	struct phy_device *phy_dev;
>+	const union acpi_object *obj;
>+	u32 phy_addr;
>+
>+	if (acpi_bus_get_device(handle, &adev))
>+		return AE_OK;
>+
>+	if (acpi_dev_get_property(adev, "phy-channel", ACPI_TYPE_INTEGER,
>&obj))
>+		return AE_OK;
>+	phy_addr = obj->integer.value;
>+
>+	phy_dev = get_phy_device(mdio, phy_addr, false);
>+	adev->driver_data = phy_dev;
>+	if (!phy_dev || IS_ERR(phy_dev))
>+		return AE_OK;
>+
>+	if (phy_device_register(phy_dev))
>+		phy_device_free(phy_dev);
>+
>+	return AE_OK;
>+}
>+#endif

That seems pretty generic to be extracted to a common location.
>+
>+bool xgene_mdio_probe_successful(void)
>+{
>+	return xgene_mdio_status;
>+}
>+EXPORT_SYMBOL(xgene_mdio_probe_successful);

Why do we need that and cannot you either return EPOBE_DEFER until this MDIO bus driver is available?


>+#endif
>+	}
>+
>+	if (!mdio_id)
>+		return -ENODEV;
>+
>+	pdata = devm_kzalloc(dev, sizeof(struct xgene_mdio_pdata),
>GFP_KERNEL);
>+	if (!pdata)
>+		return -ENOMEM;
>+	pdata->mdio_id = mdio_id;
>+	pdata->dev = dev;
>+
>+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>+	if (!res) {
>+		dev_err(dev, "Resource mac_ind_csr not defined\n");
>+		return -ENODEV;
>+	}
>+
>+	csr_addr = devm_ioremap(dev, res->start, resource_size(res));

devm_ioremap_resource()

>+	if (!csr_addr) {
>+		dev_err(dev, "Unable to retrieve mac CSR region\n");
>+		return -ENOMEM;
>+	}
>+	pdata->mac_csr_addr = csr_addr;
>+	pdata->mdio_csr_addr = csr_addr + BLOCK_XG_MDIO_CSR_OFFSET;
>+	pdata->diag_csr_addr = csr_addr + BLOCK_DIAG_CSR_OFFSET;
>+
>+	if (dev->of_node) {
>+		pdata->clk = devm_clk_get(dev, NULL);
>+		if (IS_ERR(pdata->clk)) {
>+			dev_err(dev, "Unable to retrieve clk\n");
>+			return -ENODEV;

return PTR_ERR(pdata->clk) so if this needs to wait until the provider is ready.

>+		}
>+	}
>+
>+	ret = xgene_mdio_reset(pdata);
>+	if (ret)
>+		return ret;
>+
>+	mdio_bus = mdiobus_alloc();
>+	if (!mdio_bus)
>+		return -ENOMEM;
>+
>+	mdio_bus->name = "APM X-Gene MDIO bus";
>+	snprintf(mdio_bus->id, MII_BUS_ID_SIZE, "%s-%d", "xgene-mii",
>+		 mdio_id);

Either give it name which indicates that this is the RGMII instance, or the XFI instance but don't use an arbitrary value from device tree here.


>+	}
>+
>+	if (ret)
>+		goto out;
>+
>+	xgene_mdio_status = true;
>+
>+	return 0;
>+out:
>+	if (mdio_bus->state == MDIOBUS_REGISTERED)
>+		mdiobus_unregister(mdio_bus);

Unnecessary, your error path should correctly unwind the probe path wherever it stopped.


>diff --git a/drivers/net/phy/mdio-xgene.h
>b/drivers/net/phy/mdio-xgene.h
>new file mode 100644
>index 0000000..08b4323
>--- /dev/null
>+++ b/drivers/net/phy/mdio-xgene.h
>@@ -0,0 +1,140 @@


>+static const struct acpi_device_id xgene_mdio_acpi_match[];
>+#endif
>+bool xgene_mdio_probe_successful(void);
>+

Except for this which clearly should not exist this header is probably unnecessary and everything can be contained in the source file directly.


>+#endif  /* __MDIO_XGENE_H__ */


-- 
Florian
