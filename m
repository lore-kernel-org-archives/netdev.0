From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH 0/3] Enable connecting DSA-based switch to the USB
 RMII interface.
Date: Tue, 21 Apr 2015 14:47:37 +0200
Message-ID: <20150421124737.GD32294@lunn.ch>
References: <1429622791-7195-1-git-send-email-kaisrja1@fel.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sojkam1@fel.cvut.cz, tkonecny@retia.cz, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Kaisrlik <ja.kaisrlik@gmail.com>
To: Jan Kaisrlik <kaisrja1@fel.cvut.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1429622791-7195-1-git-send-email-kaisrja1@fel.cvut.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jan

Interesting work, but i think the architecture is wrong.

DSA needs an Ethernet device, an MDIO bus, and information about ports
on the switch. The MDIO bus and the Ethernet need no knowledge of
DSA. So putting your DSA configuration code in the MDIO driver is
wrong.

The problem you have is where the put the configuration data. There
are the currently two choices, using a platform driver, which you can
find some examples of in arch/arm/mach-orion5x, or via device tree. Or
you need a new method.

Part of your problem is hotplug, since you have a USB device, and no
stable names for the ethernet device nor the MDIO device. Your
hardware is not fixed, you could hang any switch off the USB
device. So it does sound like you need a user space API.

I would however say that sysfs is the wrong API. The linux network
stack uses netlink for most configuration activities. So i would
suggest adding a netlink binding to DSA, and place the code in
net/dsa/, not within an MDIO driver.

Device tree overlays might be a solution, if you can dynamically load
a blob as part of a USB hotplug event. What makes it easier is that
both the Ethernet device and MDIO bus are on the same USB device, so
all your phandles are within the blob.

What is your long term goal? Is this just a development tool? Are you
thinking of making a product which integrates both the switch and the
USB ethernet onto a USB dongle? This could also change the
architecture, since it makes the configuration more fixed.

    Andrew
