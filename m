From: Florian Fainelli <f.fainelli@gmail.com>
Subject: RFC: DSA device/driver model revamp
Date: Wed, 10 Sep 2014 15:11:50 -0700
Message-ID: <5410CCA6.8080506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net, jogo@openwrt.org,
	nbd@openwrt.org, alexander.duyck@gmail.com, jhs@mojatatu.com,
	kernel@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34107 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754AbaIJWL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 18:11:56 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so7829294pab.18
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 15:11:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This email is a DSA re-architecting proposal aiming at making it more
useful for non-MDIO managed switch drivers.

Problem statement:

DSA was mostly designed around MDIO-managed switches, and as such took a
lot of shortcuts in how these devices are discovered.

Whether we are using plain C structures or Device Tree, this all boils
down to instantiating a "dsa" platform_device that contains information
on how the switch ports are available, where the switch is sitting on
the attached Ethernet controller MDIO bus, and consequently which
Ethernet controller and MDIO bus to use.

For each DSA switch driver registered, the DSA platform device code will
call into the DSA switch driver with the probe() callback and pass it a
struct mii_bus, ultimately asking the switch driver to read the switch
device ID from the MDIO bus and telling it go/no-go with what it read.
This basically forces non-MDIO drivers to return something that just
makes the code happy, but does not match the truth.

Consequently, we never have a 'struct dsa_switch' backed by an actual
'struct device', which prevents proper Power Management, and other
goodies such as the device-managed helper functions from being used, it
also somehow violates the Device/driver layering.

The very fact that all the DSA registration is driven by the "dsa"
platform device also makes it hard to dynamically insert switch devices
and have something modular, since everything must be known at the time
this driver is registered.

Proposed solution:

Instead of evolving around this DSA platform_device/driver, we want
something that comes from the host interface driver. Whether that driver
is a PHY, SPI, I2C client, platform or PCI driver does not matter, what
matters is that we are backed by an actual struct device, and we follow
the Linux Device Driver model.

Moving forward, what we would be seeing is something like this:

- a given driver (PCI, SPI, PHY) gets probed
- allocates a struct dsa_switch
- assigns all relevant members:
	- dsa_switch_driver becomes dsa_switch_driver_ops
	- assigns a parent struct device pointer
	- declares the type of tagging protocol supported by this device
	- assigns the correct device_node pointers/platform configuration
pointers to communicate this down to the DSA core code

- registers the dsa_switch by calling dsa_switch_register()

very much like what a regular network device driver does.

Open questions:

There is some legacy code that will instantiate the special "dsa"
platform device in arch/arm/mach-orion5x/*, this code needs to be
transitioned one way or the other.

The switches used by these Orion5x platforms are MDIO-connected
switches, with the proposal above, these switch drivers will become PHY
drivers matching a particular PHY ID on the MDIO bus.

We currently do not have a way to attach platform specific data that is
not coming from Device Tree to these PHY devices, something potentially
not too intrusive could be to extend phy_register_fixup() with a void *
argument to pass specific platform data, or create
phy_register_fixup_with_data().

Comments welcome!
--
Florian
