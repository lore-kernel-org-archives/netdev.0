From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 2.6.33 1/3] net: Micrel KSZ8841/2 PCI Ethernet driver
Date: Sat, 16 Jan 2010 14:50:14 +0000
Message-ID: <20100116145014.172ad340@lxorguk.ukuu.org.uk>
References: <14385191E87B904DBD836449AA30269D021A4A@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Dave Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753598Ab0APOr0@vger.kernel.org>
In-Reply-To: <14385191E87B904DBD836449AA30269D021A4A@MORGANITE.micrel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +/*
> + * PCI Configuration Space Registers
> + */

We have existing standard defines for most of these that should be used
instead where relevant. The code appears not use most of these defines
for generic PCI stuff anyway.


> +#define PORT_CTRL_ADDR(port, addr)		\
> +	(addr = KS8842_PORT_1_CTRL_1 + port *	\
> +		(KS8842_PORT_2_CTRL_1 - KS8842_PORT_1_CTRL_1))

Brackets around port so that things like PORT_CTRL_ADDR(x + 1) work
as expected


> +/*
> + * Hardware register access macros
> + */
> +
> +#define hw_dis_intr_sync(hw)	hw_dis_intr(hw)
> +
> +#define HW_R8(hw, addr, data)	(*(data) = readb((hw)->ioaddr + (addr)))
> +#define HW_W8(hw, addr, data)	writeb((data), (hw)->ioaddr + (addr))
> +
> +#define HW_R16(hw, addr, data)	(*(data) = readw((hw)->ioaddr + (addr)))
> +#define HW_W16(hw, addr, data)	writew((data), (hw)->ioaddr + (addr))
> +
> +#define HW_R32(hw, addr, data)	(*(data) = readl((hw)->ioaddr + (addr)))
> +#define HW_W32(hw, addr, data)	writel((data), (hw)->ioaddr + (addr))
> +
> +#define HW_PCI_READ_BYTE(hw, addr, data)				\
> +	pci_read_config_byte((struct pci_dev *) (hw)->pdev, addr, data)
> +
> +#define HW_PCI_READ_WORD(hw, addr, data)				\
> +	pci_read_config_word((struct pci_dev *) (hw)->pdev, addr, data)
> +
> +#define HW_PCI_READ_DWORD(hw, addr, data)				\
> +	pci_read_config_dword((struct pci_dev *) (hw)->pdev, addr, data)
> +
> +#define HW_PCI_WRITE_BYTE(hw, addr, data)				\
> +	pci_write_config_byte((struct pci_dev *) (hw)->pdev, addr, data)
> +
> +#define HW_PCI_WRITE_WORD(hw, addr, data)				\
> +	pci_write_config_word((struct pci_dev *) (hw)->pdev, addr, data)
> +
> +#define HW_PCI_WRITE_DWORD(hw, addr, data)				\
> +	pci_write_config_dword((struct pci_dev *) (hw)->pdev, addr, data)

This sort of stuff just obfuscates things so the defines ought to get
removed so the code is more readable to all (remember the Linux kernel
code needs to be generally readable not just readable by Micrel people)


> + * delay_milli - delay in millisecond
> + * @millisec:	Number of milliseconds to delay.
> + *
> + * This routine delays in milliseconds.
> + */
> +static void delay_milli(uint millisec)
> +{
> +	unsigned long ticks = millisec * HZ / 1000;
> +
> +	if (!ticks || in_interrupt())
> +		mdelay(millisec);
> +	else {
> +		set_current_state(TASK_INTERRUPTIBLE);
> +		schedule_timeout(ticks);

msleep() is probably what you want for this part ? Note that you really
don't want to be spinning for milliseconds in the IRQ paths if at all
possible.

The DEBUG ioctl is a bit odd - you define it and it does nothing - just a
left over ?



> +
> +#define PCI_VENDOR_ID_KS884X		0x16C6
> +#define PCI_DEVICE_ID_KS8841		0x8841
> +#define PCI_DEVICE_ID_KS8842		0x8842

Those belong in the pci device id header.


In your pci init function you do the following

> +	hw->pdev = pdev;


If you make a private copy of pdev in your struct you should refcount it
and use pci_dev_get/pci_dev_put when you take and release the reference.


The proc stuff probably belongs in sysfs nowdays
