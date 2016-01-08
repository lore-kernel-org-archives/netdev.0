From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: Support for non-HW interrupt devices
Date: Fri, 8 Jan 2016 16:51:11 +0100
Message-ID: <20160108155111.GF4389@lunn.ch>
References: <9235D6609DB808459E95D78E17F2E43D40493795@CHN-SV-EXMX02.mchp-main.com>
 <20160108004238.GD4389@lunn.ch>
 <568F1A1B.1040808@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D4049389F@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, davem@davemloft.net
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44082 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750860AbcAHPvP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 10:51:15 -0500
Content-Disposition: inline
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D4049389F@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> As you may already know, USB Interrupt Pipe is not actual interrupt and
> USB driver is beyond USB Host driver which deals with HW interrupt directly over
> request_irq(). So even we can put some code in USB Host driver to interface with 
> PHYLIB, it is more likely adding another USB stack to handle this pseudo interrupt.
> I don't think it's good approach to solve this problem.

You don't need any code in the USB irq handler.

I'm not too familiar with USB networking, but looking at usbnet.c, it
looks like intr_complete() gets called when there is a USB Interrupt
Pipe event. That calls into the drivers status() method.

In this status method, you need to trigger a Linux interrupt. By that,
i mean you need to call handle_nested_irq().

What i found useful was looking at how drivers/gpio/gpip-pca953x.c
works. That is an i2c GPIO expander, which supports GPIO
interrupts. When the device indicates an interrupt event, you need to
read an i2c register on the device to see which GPIO line has
triggered it, and then call handle_nestd_irq() for the corresponding
interrupt.

Humm, in fact, take a look at drivers/gpio/gpio-dln2.c It is a USB
GPIO expander, with interrupt support.

	Andrew
