From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6.17 2/9] NetXen: Hardware access routines
Date: Fri, 18 Aug 2006 08:16:59 -0700
Message-ID: <20060818081659.7c515bbf@dxpl.pdx.osdl.net>
References: <Pine.LNX.4.64.0608180713480.6875@dut39>
	<Pine.LNX.4.64.0608180739290.6875@dut39>
	<Pine.LNX.4.64.0608180746090.6875@dut39>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, sanjeev@netxen.com,
	unmproj@linsyssoft.com, rob@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:30385 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161011AbWHRPRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 11:17:55 -0400
To: "Amit S. Kale" <amitkale@netxen.com>
In-Reply-To: <Pine.LNX.4.64.0608180746090.6875@dut39>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Way to many DPRINTK()'s 

> +
> +int is_flash_supported(struct netxen_adapter *adapter)

needs to be static or prefixed.

> +{
> +	int locs[] = { 0, 0x4, 0x100, 0x4000, 0x4128 };

use const

> +	int addr, val01, val02, i, j;
> +
> +	/* if the flash size less than 4Mb, make huge war cry and die */
> +	for (j = 1; j < 4; j++) {
> +		addr = j * 0x100000;
> +		for (i = 0; i < (sizeof(locs) / sizeof(locs[0])); i++) {
> +			if (netxen_rom_fast_read(adapter, locs[i], &val01) == 0
> +			    && netxen_rom_fast_read(adapter, (addr + locs[i]),
> +						    &val02) == 0) {
> +				if (val01 == val02)
> +					return -1;
> +			} else
> +				return -1;
> +		}
> +	}
> +
> +	return 0;
> +}
> +
> +static int netxen_get_flash_block(struct netxen_adapter *adapter, int base,
> +				  int size, u32 * buf)
> +{
> +	int i, addr;
> +	u32 *ptr32;
> +
> +	addr = base;
> +	ptr32 = buf;
> +	for (i = 0; i < size / sizeof(u32); i++) {
> +		if (netxen_rom_fast_read(adapter, addr, ptr32) == -1)
> +			return -1;
> +		ptr32++;
> +		addr += sizeof(u32);
> +	}
> +	if ((char *)buf + size > (char *)ptr32) {
> +		u32 local;
> +
> +		if (netxen_rom_fast_read(adapter, addr, &local) == -1)
> +			return -1;
> +		memcpy(ptr32, &local, (char *)buf + size - (char *)ptr32);
> +	}
> +
> +	return 0;
> +}
> +
> +int get_flash_mac_addr(struct netxen_adapter *adapter, u64 mac[])

static int get_flash_mac_addr()..
+
> +void load_firmware(struct netxen_adapter *adapter)

also must be static

> +{
> +	int i;
> +	long data, size = 0;
> +	long flashaddr = NETXEN_FLASH_BASE, memaddr = NETXEN_PHANTOM_MEM_BASE;
> +	u64 off;
> +	ptrdiff_t addr;
> +
> +	size = (16 * 1024) / 4;
> +	writel(1, NETXEN_CRB_NORMALIZE(adapter, NETXEN_ROMUSB_GLB_CAS_RST));
> +
> +	for (i = 0; i < size; i++) {
> +		if (netxen_rom_fast_read(adapter, flashaddr, (int *)&data) != 0) {
> +			DPRINTK(ERR,
> +				"Error in netxen_rom_fast_read(). Will skip"
> +				"loading flash image\n");
> +			return;
> +		}
> +		off = netxen_nic_pci_set_window(adapter->ahw.pci_base, memaddr);
> +		addr = (ptrdiff_t) (adapter->ahw.pci_base + off);
> +		writel(data, (void __iomem *)addr);
> +		flashaddr += 4;
> +		memaddr += 4;
> +	}
> +	udelay(100);
> +	/* make sure Casper is powered on */
> +	writel(0x3fff,
> +	       NETXEN_CRB_NORMALIZE(adapter, NETXEN_ROMUSB_GLB_CHIP_CLK_CTRL));
> +	writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_ROMUSB_GLB_CAS_RST));
> +
> +	udelay(10000);
> +}
> +
> +int
> +netxen_nic_hw_write_wx(struct netxen_adapter *adapter, u64 off, void *data,
> +		       int len)
> +{
> +	void __iomem * addr;
> +
> +	if (ADDR_IN_WINDOW1(off)) {
> +		addr = NETXEN_CRB_NORMALIZE(adapter, off);
> +	} else {		/* Window 0 */
> +		addr = (void *)(ptrdiff_t) (adapter->ahw.pci_base + off);
> +		netxen_nic_pci_change_crbwindow(adapter, 0);
> +	}
> +
> +	DPRINTK(INFO, "writing to base %lx offset %llx addr %p"
> +		" data %llx len %d\n",
> +		adapter->ahw.pci_base, off, addr,
> +		*(unsigned long long *)data, len);
> +	switch (len) {
> +	case 1:
> +		writeb(*(u8 *) data, addr);
> +		break;
> +	case 2:
> +		writew(*(u16 *) data, addr);
> +		break;
> +	case 4:
> +		writel(*(u32 *) data, addr);
> +		break;
> +	case 8:
> +		writeq(*(u64 *) data, addr);
> +		break;
> +	default:
> +		DPRINTK(INFO,
> +			"writing data %lx to offset %llx, num words=%d\n",
> +			*(unsigned long *)data, off, (len >> 3));
> +
> +		NETXEN_NIC_HW_BLOCK_WRITE_64(data, addr, (len >> 3));
> +		break;
> +	}
> +	if (!ADDR_IN_WINDOW1(off))
> +		netxen_nic_pci_change_crbwindow(adapter, 1);
> +
> +	return 0;
> +}
> +
> +int
> +netxen_nic_hw_read_wx(struct netxen_adapter *adapter, u64 off, void *data,
> +		      int len)

If you can make this inline then the switch can be optimized.

> +{
> +	void __iomem * addr;
> +
> +	if (ADDR_IN_WINDOW1(off)) {	/* Window 1 */
> +		addr = NETXEN_CRB_NORMALIZE(adapter, off);
> +	} else {		/* Window 0 */
> +		addr = (void *)(ptrdiff_t) (adapter->ahw.pci_base + off);
> +		netxen_nic_pci_change_crbwindow(adapter, 0);
> +	}
> +
> +	DPRINTK(INFO, "reading from base %lx offset %llx addr %p\n",
> +		adapter->ahw.pci_base, off, addr);
> +	switch (len) {
> +	case 1:
> +		*(u8 *) data = readb(addr);
> +		break;
> +	case 2:
> +		*(u16 *) data = readw(addr);
> +		break;
> +	case 4:
> +		*(u32 *) data = readl(addr);
> +		break;
> +	case 8:
> +		*(u64 *) data = readq(addr);
> +		break;
> +	default:
> +		NETXEN_NIC_HW_BLOCK_READ_64(data, addr, (len >> 3));
> +		break;
> +	}
> +	DPRINTK(INFO, "read %lx\n", *(unsigned long *)data);
> +
> +	if (!ADDR_IN_WINDOW1(off))
> +		netxen_nic_pci_change_crbwindow(adapter, 1);
> +
> +	return 0;
> +}
> +
> +void netxen_nic_reg_write(struct netxen_adapter *adapter, u64 off, u32 val)
> +{				/* Only for window 1 */
> +	void __iomem * addr;
> +
> +	addr = NETXEN_CRB_NORMALIZE(adapter, off);
> +	DPRINTK(INFO, "writing to base %lx offset %llx addr %p data %x\n",
> +		adapter->ahw.pci_base, off, addr, val);
> +	writel(val, addr);
> +
> +}
> +

inline?

> +int netxen_nic_reg_read(struct netxen_adapter *adapter, u64 off)
> +{				/* Only for window 1 */
> +	void __iomem * addr;
> +	int val;
> +
> +	addr = NETXEN_CRB_NORMALIZE(adapter, off);
> +	DPRINTK(INFO, "reading from base %lx offset %llx addr %p\n",
> +		adapter->ahw.pci_base, off, addr);
> +	val = readl(addr);
> +	writel(val, addr);
> +
> +	return val;
> +}
inline?


> +	if (fw_major != _NETXEN_NIC_LINUX_MAJOR) {
> +		printk(KERN_ERR "The mismatch in driver version and firmware "
> +			"version major number\n"
> +			"Driver version major number = %d \t"
> +			"Firmware version major number = %d \n",
> +			_NETXEN_NIC_LINUX_MAJOR, fw_major);
> +		adapter->driver_mismatch = 1;
> +	}
> +	if (fw_minor != _NETXEN_NIC_LINUX_MINOR) {
> +		printk(KERN_ERR "The mismatch in driver version and firmware "
> +			"version minor number\n"
> +			"Driver version minor number = %d \t"
> +			"Firmware version minor number = %d \n",
> +			_NETXEN_NIC_LINUX_MINOR, fw_minor);
> +		adapter->driver_mismatch = 1;
> +	}
>

You might want a table for this?
