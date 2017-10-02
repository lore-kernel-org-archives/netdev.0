From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: [PATCH v3 00/19] Thunderbolt networking
Date: Mon,  2 Oct 2017 13:38:27 +0300
Message-ID: <20171002103846.64602-1-mika.westerberg@linux.intel.com>
Cc: Andreas Noever <andreas.noever@gmail.com>,
        Michael Jamet <michael.jamet@intel.com>,
        Yehezkel Bernat <yehezkel.bernat@intel.com>,
        Amir Levy <amir.jer.levy@intel.com>,
        Mario.Limonciello@dell.com, Lukas Wunner <lukas@wunner.de>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Mika Westerberg <mika.westerberg@linux.intel.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

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
be used for creating other future Thunderbolt services, such as tunneling
SCSI over Thunderbolt, for example.

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

This is third version of the patch series. The previous versions can be
be found here:

  v2: https://lkml.org/lkml/2017/9/25/225
  v1: https://lwn.net/Articles/734019/

Changes from the v2:

  * Add comment regarding calculation of interrupt throttling value
  * Add UUIDs as strings in comments on top of each declaration
  * Add a patch removing __packed from existing ICM messages. They are all
    32-bit aligned and should pack fine without the __packed.
  * Move adding MAINTAINERS entries to a separate patches
  * Added Michael and Yehezkel to be maintainers of the network driver
  * Remove __packed from the new ICM messages. They should pack fine as
    well without it.
  * Call register_netdev() after all other initialization is done in the
    network driver.
  * Use build_skb() instead of copying. We allocate order 1 page here to
    leave room for SKB shared info required by build_skb(). However, we do
    not leave room for full NET_SKB_PAD because the NHI hardware does not
    cope well if a frame crosses 4kB boundary. According comments in
    __build_skb() that should still be fine.
  * Added Reviewed-by tag from Andy.

Changes from the v1:

  * Add include/linux/thunderbolt.h to MAINTAINERS
  * Correct Linux version and date of new sysfs entries in
    Documentation/ABI/testing/sysfs-bus-thunderbolt
  * Move network driver from drivers/thunderbolt/net.c to
    drivers/net/thunderbolt.c and update it to follow coding style in
    drivers/net/*.
  * Add MAINTAINERS entry for the network driver
  * Minor cleanups

In case someone wants to try this out, the last patch adds documentation
how the networking driver can be used. In short, if you connect Linux to a
macOS or Windows, everything is done automatically (as those systems have
the networking service enabled by default). For Linux to Linux connection
one host needs to load the networking driver first (so that the other side
can locate the networking service and load the corresponding driver).

Amir Levy (1):
  net: Add support for networking over Thunderbolt cable

Mika Westerberg (18):
  byteorder: Move {cpu_to_be32,be32_to_cpu}_array() from Thunderbolt to core
  thunderbolt: Remove __packed from ICM message structures
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
  MAINTAINERS: Add thunderbolt.h to the Thunderbolt driver entry
  MAINTAINERS: Add entry for Thunderbolt network driver

 Documentation/ABI/testing/sysfs-bus-thunderbolt |   48 +
 Documentation/admin-guide/thunderbolt.rst       |   24 +
 MAINTAINERS                                     |    9 +
 drivers/net/Kconfig                             |   12 +
 drivers/net/Makefile                            |    3 +
 drivers/net/thunderbolt.c                       | 1362 ++++++++++++++++++++
 drivers/thunderbolt/Makefile                    |    2 +-
 drivers/thunderbolt/ctl.c                       |   46 +-
 drivers/thunderbolt/ctl.h                       |    3 +-
 drivers/thunderbolt/domain.c                    |  197 ++-
 drivers/thunderbolt/icm.c                       |  218 +++-
 drivers/thunderbolt/nhi.c                       |  410 ++++--
 drivers/thunderbolt/nhi.h                       |  141 +-
 drivers/thunderbolt/nhi_regs.h                  |   11 +-
 drivers/thunderbolt/property.c                  |  670 ++++++++++
 drivers/thunderbolt/switch.c                    |    7 +-
 drivers/thunderbolt/tb.h                        |   88 +-
 drivers/thunderbolt/tb_msgs.h                   |  168 ++-
 drivers/thunderbolt/xdomain.c                   | 1576 +++++++++++++++++++++++
 include/linux/byteorder/generic.h               |   16 +
 include/linux/mod_devicetable.h                 |   26 +
 include/linux/thunderbolt.h                     |  598 +++++++++
 scripts/mod/devicetable-offsets.c               |    7 +
 scripts/mod/file2alias.c                        |   25 +
 24 files changed, 5304 insertions(+), 363 deletions(-)
 create mode 100644 drivers/net/thunderbolt.c
 create mode 100644 drivers/thunderbolt/property.c
 create mode 100644 drivers/thunderbolt/xdomain.c
 create mode 100644 include/linux/thunderbolt.h

-- 
2.14.2
