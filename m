From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC v2 00/32] Make DSA switches linux devices.
Date: Thu, 3 Mar 2016 10:49:59 -0800
Message-ID: <56D88757.7050803@gmail.com>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35871 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753414AbcCCSvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 13:51:25 -0500
Received: by mail-pf0-f195.google.com with SMTP id q129so1788792pfb.3
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 10:51:25 -0800 (PST)
In-Reply-To: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On 28/02/16 08:41, Andrew Lunn wrote:
> This is the second RFC for rearchitecturing how DSA devices are
> probed. This patchset allows switches to be linux devices, probed by
> the ususal mechanism for whatever bus they hang off. They then
> register with the DSA core.
> 
> DSA has been limited to devices which hang off an MDIO bus, or with a
> bit of work, memory mapped devices. This refactoring generalizes DSA
> so that switches on other sorts of busses, eg. SPI can be supported.
> 
> The code should remain backwards compatible. The old device tree
> binding are still supported. It is extended with phandles to switch
> devices.

Still reviewing the individual patches, but there is still something
that seems awkward with this design, is that we still need the special
"dsa" platform device to be there, and this is a problem for many
different reasons:

- first of all, the original design around the special platform device
did not allow multiple switch trees within the same system to coexist
(dsa platform device were not numbered (id = -1)), but such a thing
could exist and is desirable, you could have a single switch hanging off
eth0, and more switches hanging off eth1 for instance, and not be part
of the same tree

- the direction we want to move people to is to make them use DSA for
their switch needs and get the proven benefits from having a consistent
per-port slave network device model along with a good binding for
representing ports within a switch (and all thedetails associated with
that), the next step is to make this available to not just MDIO drivers,
which you are addressing here, but then, being able to call
dsa_switch_register() just becomes a service from the network stack with
DSA support included, if we need the special dsa platform device again,
we are not way better than where we were before

- the dsa platform device was used as a single point of synchronization
which was known to have the entire knowledge about the switch tree, but
with modules being possible again now, this tree is going to see
switches come and go, and that should be the desired model for
developers working on this subsystem, and people making products might
decide to build everything in the kernel to get the same guarantees as
before

I still see the need for the dsa platform device more as an artifact
than something absolutely needed. The way I would see the probing logic
(simplified) is something along these lines:

- switch driver gets probed (from a bus subsystem)
- if it is the first one in the tree (thanks to the chip index telling
it so), it registers with dsa, locates the master netdev, and creates
the dst structure for it there in master netdev->dsa_ptr
- if not, then return EPROBE_DEFER until we get the first switch in tree
to be probed
- subsequent switches also locate their chip index, locate the master
netdev, fetch a valid netdev->dsa_ptr now, and add themselves there

and do to that, there is just resident code in the kernel, just waiting
for sucht hings to appear, which is already more or less the case, it
does not need to be a platform device though.

> 
> The changes also make it eaiser for the drivers to be kernel modules,
> and the patches contain cleanups and fixes so that the modules can be
> unloaded and loaded.
> 
> Patches can be found in
> 
> https://github.com/lunn/linux.git v4.5-rc2-net-next-dsa-proposal-4
> 
> 
> Andrew Lunn (30):
>   dsa: Rename mv88e6123_61_65 to mv88e6123 to be consistent
>   dsa: Make setup and finish more symmetrical
>   net: dsa: Pass the dsa device to the switch drivers
>   net: dsa: Have the switch driver allocate there own private memory
>   net: dsa: Remove allocation of driver private memory
>   net: dsa: Keep the mii bus and address in the private structure
>   net: dsa: dsa.c: Refactor to increase symmetry
>   driver: component: Add support for empty match table
>   net: dsa: Add basic support for component master support
>   net: dsa: Keep a reference to the switch device for component matching
>   net: dsa: Add slave component matches based on a phandle to the slave.
>   net: dsa: Make dsa,mii-bus optional
>   net: dsa: Add register/unregister functions for switch drivers
>   net: dsa: Rename DSA probe function.
>   dsa: mv88e6xxx: Use bus in mv88e6xxx_lookup_name()
>   dsa: mv88e6xxx: Add shared code for binding/unbinding a switch driver.
>   dsa: mv88e6xxx: Prepare for turning this into a library module
>   dsa: mv88e6xxx: Add macro for registering the drivers
>   dsa: Add mdio device support to Marvell switches
>   net: mdio: Add mdiodev_{read|write} helpers
>   net: dsa: Better integrate the drivers with mdio device
>   net: dsa: Add some debug prints for error cases
>   net: dsa: Setup the switches after all have been probed
>   net: dsa: Only setup platform switches, not device switches
>   net: dsa: If a switch fails to probe, defer probing
>   Documentation: DSA: Describe how probe of DSA and switches work.
>   dsa: slave: Don't reference NULL pointer during phy_disconnect
>   dsa: Destroy fixed link phys after the phy has been disconnected
>   dsa: dsa: Fix freeing of fixed-phys from user ports.
>   phy: fixed: Fix removal of phys.
> 
> Florian Fainelli (2):
>   net: dsa: Move platform data allocation for OF
>   net: dsa: bcm_sf2: make it a real platform driver
> 
>  .../devicetree/bindings/net/dsa/broadcom.txt       |  54 +++
>  Documentation/devicetree/bindings/net/dsa/dsa.txt  |   5 +-
>  .../devicetree/bindings/net/dsa/marvell.txt        |  29 ++
>  Documentation/networking/dsa/dsa.txt               |  48 +++
>  drivers/base/component.c                           |  33 +-
>  drivers/net/dsa/Kconfig                            |   2 +-
>  drivers/net/dsa/Makefile                           |  19 +-
>  drivers/net/dsa/bcm_sf2.c                          | 292 +++++++++-------
>  drivers/net/dsa/mv88e6060.c                        | 138 +++++++-
>  drivers/net/dsa/mv88e6060.h                        |  10 +
>  drivers/net/dsa/mv88e6123.c                        | 173 ++++++++++
>  drivers/net/dsa/mv88e6123_61_65.c                  | 124 -------
>  drivers/net/dsa/mv88e6131.c                        |  70 +++-
>  drivers/net/dsa/mv88e6171.c                        |  70 +++-
>  drivers/net/dsa/mv88e6352.c                        |  72 +++-
>  drivers/net/dsa/mv88e6xxx.c                        | 200 +++++++----
>  drivers/net/dsa/mv88e6xxx.h                        |  40 ++-
>  drivers/net/phy/fixed_phy.c                        |  10 +-
>  drivers/net/phy/mdio_device.c                      |  68 ++++
>  include/linux/mdio.h                               |   5 +
>  include/linux/phy_fixed.h                          |   2 +-
>  include/net/dsa.h                                  |  17 +-
>  net/dsa/dsa.c                                      | 372 ++++++++++++++-------
>  net/dsa/slave.c                                    |  12 +-
>  24 files changed, 1339 insertions(+), 526 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/dsa/broadcom.txt
>  create mode 100644 Documentation/devicetree/bindings/net/dsa/marvell.txt
>  create mode 100644 drivers/net/dsa/mv88e6123.c
>  delete mode 100644 drivers/net/dsa/mv88e6123_61_65.c
> 


-- 
Florian
