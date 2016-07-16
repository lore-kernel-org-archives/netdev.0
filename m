From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v0 06/10] arm: orion5x: Add DT-based support for Netgear WNR854T
Date: Sat, 16 Jul 2016 21:10:38 +0200
Message-ID: <4290281.AD5Bhg23o6@wuerfel>
References: <1468679348-10522-1-git-send-email-jm@lentin.co.uk> <1468679348-10522-7-git-send-email-jm@lentin.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Jamie Lentin <jm@lentin.co.uk>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Imre Kaloz <kaloz@openwrt.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:49474 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751685AbcGPTLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2016 15:11:43 -0400
In-Reply-To: <1468679348-10522-7-git-send-email-jm@lentin.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday, July 16, 2016 3:29:04 PM CEST Jamie Lentin wrote:
> +
> +#define WNR854T_PCI_SLOT0_OFFS	7
> +#define WNR854T_PCI_SLOT0_IRQ_PIN	4
> +
> +static void __init wnr854t_pci_preinit(void)
> +{
> +	int pin;
> +
> +	/*
> +	 * Configure PCI GPIO IRQ pins
> +	 */
> +	pin = WNR854T_PCI_SLOT0_IRQ_PIN;
> +	if (gpio_request(pin, "PCI Int") == 0) {
> +		if (gpio_direction_input(pin) == 0) {
> +			irq_set_irq_type(gpio_to_irq(pin), IRQ_TYPE_LEVEL_LOW);
> +		} else {
> +			pr_err("wnr854t_pci_preinit failed to set_irq_type pin %d\n",
> +				pin);
> +			gpio_free(pin);
> +		}
> +	} else {
> +		pr_err("wnr854t_pci_preinit failed to request gpio %d\n", pin);
> +	}
> +}
> +
> +static int __init wnr854t_pci_map_irq(const struct pci_dev *dev, u8 slot,
> +	u8 pin)
> +{
> +	int irq;
> +
> +	/*
> +	 * Check for devices with hard-wired IRQs.
> +	 */
> +	irq = orion5x_pci_map_irq(dev, slot, pin);
> +	if (irq != -1)
> +		return irq;
> +
> +	/*
> +	 * PCI IRQs are connected via GPIOs
> +	 */
> +	switch (slot - WNR854T_PCI_SLOT0_OFFS) {
> +	case 0:
> +		return gpio_to_irq(WNR854T_PCI_SLOT0_IRQ_PIN);
> +	default:
> +		return -1;
> +	}
> +}

The other patches all appear good to me, but I find this one suspicious.

Why are you not using the device tree for probing PCI? Is there anything
missing in drivers/pci/host/pci-mvebu.c, or do you just need help
describing it in DT?

	Arnd
