From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: [PATCH v2 00/16] Thunderbolt networking
Date: Mon, 25 Sep 2017 14:07:22 +0300
Message-ID: <20170925110738.68382-1-mika.westerberg@linux.intel.com>
Cc: Andreas Noever <andreas.noever@gmail.com>,
        Michael Jamet <michael.jamet@intel.com>,
        Yehezkel Bernat <yehezkel.bernat@intel.com>,
        Amir Levy <amir.jer.levy@intel.com>,
        Mario.Limonciello@dell.com, Lukas Wunner <lukas@wunner.de>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Mika Westerberg <mika.westerberg@linux.intel.com>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

In addition of tunneling PCIe, Display Port and USB traffic, Thunderbolt
allows connecting two hosts (domains) over a Thunderbolt cable. It is
possible to tunnel arbitrary data packets over such connection using
high-speed DMA rings available in the Thunderbolt host controller.

In order to discover Thunderbolt services the other host supports, there is
a software protocol running on top of the automatically configured control
channel (ring 0). This protocol is called XDomain discovery protocol and it
uses XDomain properties to describe the host (domain) and the services it
supports.

Once both sides have agreed what services are supported they can enable
high-speed DMA rings to transfer data over the cable.

This series adds support for the XDomain protocol so that we expose each
remote connection as Thunderbolt XDomain device and each service as
Thunderbolt service device. On top of that we create an API that allows
writing drivers for these services and finally we provide an example
Thunderbolt service driver that creates virtual ethernet inferface that
allows tunneling networking packets over Thunderbolt cable. The API could
be used for creating other Thunderbolt services, such as tunneling SCSI for
example.

The XDomain protocol and networking support is also available in macOS and
Windows so this makes it possible to connect Linux to macOS and Windows as
well.

The patches are based on previous Thunderbolt networking patch series by
Amir Levy and Michael Jamet, that can be found here:

  https://lwn.net/Articles/705998/

The main difference to that patch series is that we have the XDomain
protocol running in the kernel now so there is no need for a separate
userspace daemon.

Note this does not affect the existing functionality, so security levels
and NVM firmware upgrade continue to work as before (with the small
exception that now sysfs also shows the XDomain connections and services in
addition to normal Thunderbolt devices). It is also possible to connect up
to 5 Thunderbolt devices and then another host, and the network driver
works exactly the same.

This is second version of the patch series. The previous version (v1) can
be found here:

  https://lwn.net/Articles/734019/

Changes from the v1:

  * Add include/linux/thunderbolt.h to MAINTAINERS
  * Correct Linux version and date of new sysfs entries in
    Documentation/ABI/testing/sysfs-bus-thunderbolt
  * Move network driver from drivers/thunderbolt/net.c to
    drivers/net/thunderbolt.c and update it to follow coding style in
    drivers/net/*.
  * Add MAINTAINERS entry for the network driver
  * Minor cleanups

In case someone wants to try this out, patch [16/16] adds documentation how
the networking driver can be used. In short, if you connect Linux to a
macOS or Windows, everything is done automatically (as those systems have
the networking service enabled by default). For Linux to Linux connection
one host needs to load the networking driver first (so that the other side
can locate the networking service and load the corresponding driver).

Amir Levy (1):
  net: Add support for networking over Thunderbolt cable

Mika Westerberg (15):
  byteorder: Move {cpu_to_be32,be32_to_cpu}_array() from Thunderbolt to core
  thunderbolt: Add support for XDomain properties
  thunderbolt: Move enum tb_cfg_pkg_type to thunderbolt.h
  thunderbolt: Move thunderbolt domain structure to thunderbolt.h
  thunderbolt: Move tb_switch_phy_port_from_link() to thunderbolt.h
  thunderbolt: Add support for XDomain discovery protocol
  thunderbolt: Configure interrupt throttling for all interrupts
  thunderbolt: Add support for frame mode
  thunderbolt: Export ring handling functions to modules
  thunderbolt: Move ring descriptor flags to thunderbolt.h
  thunderbolt: Use spinlock in ring serialization
  thunderbolt: Use spinlock in NHI serialization
  thunderbolt: Add polling mode for rings
  thunderbolt: Add function to retrieve DMA device for the ring
  thunderbolt: Allocate ring HopID automatically if requested

 Documentation/ABI/testing/sysfs-bus-thunderbolt |   48 +
 Documentation/admin-guide/thunderbolt.rst       |   24 +
 MAINTAINERS                                     |    7 +
 drivers/net/Kconfig                             |   12 +
 drivers/net/Makefile                            |    3 +
 drivers/net/thunderbolt.c                       | 1379 ++++++++++++++++++++
 drivers/thunderbolt/Makefile                    |    2 +-
 drivers/thunderbolt/ctl.c                       |   46 +-
 drivers/thunderbolt/ctl.h                       |    3 +-
 drivers/thunderbolt/domain.c                    |  197 ++-
 drivers/thunderbolt/icm.c                       |  218 +++-
 drivers/thunderbolt/nhi.c                       |  409 ++++--
 drivers/thunderbolt/nhi.h                       |  141 +-
 drivers/thunderbolt/nhi_regs.h                  |   11 +-
 drivers/thunderbolt/property.c                  |  670 ++++++++++
 drivers/thunderbolt/switch.c                    |    7 +-
 drivers/thunderbolt/tb.h                        |   88 +-
 drivers/thunderbolt/tb_msgs.h                   |  140 +-
 drivers/thunderbolt/xdomain.c                   | 1576 +++++++++++++++++++++++
 include/linux/byteorder/generic.h               |   16 +
 include/linux/mod_devicetable.h                 |   26 +
 include/linux/thunderbolt.h                     |  598 +++++++++
 scripts/mod/devicetable-offsets.c               |    7 +
 scripts/mod/file2alias.c                        |   25 +
 24 files changed, 5304 insertions(+), 349 deletions(-)
 create mode 100644 drivers/net/thunderbolt.c
 create mode 100644 drivers/thunderbolt/property.c
 create mode 100644 drivers/thunderbolt/xdomain.c
 create mode 100644 include/linux/thunderbolt.h

-- 
2.14.1
