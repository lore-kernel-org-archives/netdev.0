From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 00/29] merge request for WiMAX kernel stack and i2400m
	driver v6
Date: Mon, 15 Dec 2008 04:57:55 -0800
Message-ID: <cover.1229345769.git.inaky@linux.intel.com>
Cc: greg@kroah.com, wimax@linuxwimax.org
To: netdev@vger.kernel.org
Return-path: <wimax-bounces@linuxwimax.org>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org


Hi All

This patchset (or the linux-wimax GIT tree at git.kernel.org) merges
the WiMAX subsystem and driver for the Intel 2400m Wireless WiMAX
connection to the tree. We'd like to get it in for the 2.6.29 merge
window. 

[read on for changelog since previous submit]

[Note linux-wimax will have netdev as upstream, but there is a
 dependency for patches in gregkh's patches tree that forbid
 submitting against netdev for now -- so the base for this is said
 tree as of 11/19. See *2]

WiMAX is a new wireless boadband technology that differs significantly
from WiFi. It is also called 4G and resembles more the model of
cellular phones, where you sign up for service with a provider.

Your WiMAX card connects to a basestation, which is operated by a
certain Network Access Provider (NAP). The NAP leases (or might be the
same) connectivity to a Network Service Provider (NSP), which is your
ISP.

When you move around, your connectivity will be handed over from
basestation to basestation in a seamless way. As in cellphones, there
is the roaming case, where you could be are connecting to your service
plan through other provider.

WiMAX's main components have been standarized (some parts still in the
process) as in a set of 802.16 standards. The WiMAX Forum's members
drive the development of WiMAX features that end up in 802.16.

This code is broken up in a WiMAX subsystem and a driver for the Intel
2400m Wireless WiMAX Link. To be able to fully utilize WiMAX services,
you need extra pieces of device-specific user space software; for now,
there is a C level API (the Common API) to use/control it, but a high
level API over DBUS that should work for any device is in the
works. See details further below.

Support for other vendor's hardware would require a driver registering
with the WiMAX stack and a user space component implementing the high
level API.

Changes in v6:

 - Fix a couple of buglets in debug and error paths.

 - Add USB IDs to the USB driver.

Changes in v5:

 - (Johannes Berg, Thomas Graf) Move away from using a generic netlink
   family per interface; address interfaces using an interface index
   attribute.

Changes in v4:

 - (David Miller) Fix patch dependencies and compact them to reduce
   the patchset size.

Changes in v3:

 - Implement feedback from the mailing list for the merge request
   (from Johaness, Thomas, Patrick and Evgeniy)

 - Moved all the sysfs controls and knobs to be debugfs based.

 - Remove kernel/user op-open and instead use the generic netlink
   controller.

 - Many improvements and optimizations on the usage of generic
   netlink.

 - Use generic netlink facilities for permission checking.
 
 - Properly use the netlink ack/nlerr instead of relying on home-grown
   system. 

 - Fix a deadlock in wimax_reset().

 - When i2400m reset completes ok, mark the device as active again
   (or the device gets confused).

 - Relicense linux/wimax.h as BSD (mistakenly didn't)

 - Add rationales on design and clarifications/fixes in the
   documentation.

Changes in v2:

 - (Stephen Hemminger) don't use bitfields in struct wimax_dev 

 - (Stephen Hemminger) don't use the interface name for the generic
   netlink family, as it might change on if rename. Change to use the
   interface index.

 - (David Miller) move the WiMAX stack to net/wimax

 - misc checkpatch fixes, kconfig cleanups. 

 - use DEFINE_SPINLOCK


Details follow:

* The WiMAX kernel stack

The (kernel) WiMAX stack is (as of now) very basic; it conforms a
"control plane", in a similar fashion to cfg80211. 

We still don't know what's going to be a good abstraction layer
because so far, we have only see one WiMAX device for which we could
implement support. 

So the current abstraction layer provides a low-level WiMAX API with
means for resetting, monitoring state changes, controlling rfkill and
sending messages to the driver (in a driver specific format) back and
forth (more on this below). The documentation in include/net/wimax.h
provides more information.

The functional API provided by the kernel stack is exported to user
space via generic netlink. For convenience, libwimaxll, a shim library
is provided in the user space package wimax-tools, but direct access
and parsing of the generic protocol is possible. All the bits and
pieces needed to operate from user space are declared in
include/linux/wimax.h, which is marked for system-wide installation
with headers_install.

Implementation of drivers for other hardware using this model should
be more or less straightforward.

* The i2400m driver

The driver for the 2400m sits below the stack, providing the back end
operations to drive control (reset, rfkill, message passing) and
feeding it state change information. On the other side, the 2400m
driver connects to netdev, where it emulates an ethernet device (*1).

The driver itself is broken in two main parts: bus-generic and
bus-specific. The bus-generic (driver) speaks the device protocol and
uses hooks provided by the bus-specific driver to talk to the device
via whichever bus it happens to be connected through.

More information about the driver can be found in
drivers/net/wimax/i2400m/i2400m.h.


* The high level WiMAX API (user space)

This part is not implemented by the code in these patches, but
available for download at http://linuxwimax.org/Download (use release
1.3 components); that implementation is specific to the Intel
2400. Other vendor's might be similar or very different.

The "high level part" (scanning, connecting, disconnecting) in WiMAX
is quite more complex than in other technologies such as WiFi. In
general, a high level API is provided to allow for:

 - scanning for networks
 - connecting and disconnecting
 - controlling the radio (turn on / off)
 - other operations

This high level API is called the Common API and is being defined by a
set of participants in the WiMAX industry. It is a cross platform API,
meant to be vendor neutral; as such, it is very alien to Linux's
system level APIs and we are planning moving the API to D-BUS and
making it look "more native", but without loosing its spirit.

The implementation of this API aims to hide the user (connection
managers, to be more exact) from the common complexities of
WiMAX. Each vendor would implement what ever they need in user space
to expose said API (could be just a passthrough if the implementation
is in the driver or in the device).

Most of these complexities are related to scanning. Scanning in WiMAX
is expensive (power consumption wise and time wise), so it has to be
done carefully, and each device will have it's most optimal way to do
it.

Most (all?) WiMAX operators run on regulated channels. To connect to
an operator, you need to know the channels where to look and scan in
there for base stations; when found, you need to know which NAPs
(Network Access Providers, the infrastructure owner) they provide and
then the NAPs you find have to be mapped to NSPs (Network Service
Providers, the ISP).

Even if you did a scan on all the channels available in a country (for
example, the US channel plan) and found different base stations, all
that information is still not discoverable from them (the 802.16g
upcoming standard aims to fix that).

So a database that helps mapping all this information (base station
IDs vs NAPs vs NSPs) is needed; we call that the "provisioning"
information, and getting that information is not trivial. The
operators, as of now, provide it to you over the OMA-DM protocol--that
requires an OMA-DM client daemon running in your machine. Another way
to provision is manually, getting a provisioning file from either the
operator or someone that has an OMA-DM client daemon.

The problem is that, as of now, there is still no OMA-DM open source
client. In http://linuxwimax.org we provide one, but Intel does not
own it and it cannot be made open source. As we said above, it is
optional if you go with the manual mode.


Once there is a network, you can connect to it. 

For networks that require authentication (most), the Intel device
requires a supplicant in user space--because of a set of issues we are
working to resolve, it cannot be made open source yet, but it will. As
of now, it is provided as a shared library that is loaded dynamically.

When a network is connected, use a DHCP client to obtain an address
(this is how most WiMAX networks are configured). 

When you connect to a network/provider with whom you don't have a
service agreement, you will probably redirected to a landing page
where you will be able to sign up for service (in exchange for your
credit card number), much similar to some WiFi hotspots. This is known
as being "activated" for said provider and you only need to do it
once, as the provider will remember your MAC address.

When you are up and running, your connection will be handed over from
tower to tower as you move around without requiring a new connection
sequence or DHCP renegotiation.

Other operations provided by the "Common API" relate to obtain
provisioning information from the network, contact information for the
network operator, manipulating roaming modes, etc ...

Caveats:

 - the 2400 goes into idle power saving when connected if there is no
   network activity. It comes out of it automatically when traffic is
   sent to the network. But sometimes, to come out of it the network
   requests a DHCP renegotiation; the user space code still has a
   piece of code missing for doing it, so you need to manually restart
   your DHCP client.

*1 Previous iterations of the driver provided a Pure IP device,
   without Ethernet wrapping but we gave up. 

   Most DHCP software in user space and in the network backends assume
   the world is Ethernet (anything that uses ISC DHCP's client and/or
   daemon). 

   We ended up registering a PureIP hw type with IANA and creating
   patches to support it to the ISC DHCP suite (at
   http://linuxwimax.org/Download) and modifying dhclient, server, and
   friends so the hardware type PureIP was recognized and thus, when
   the DHCP client sent a request, it was with hwtype ==
   purerip. 

   However, on the server end (they shall remain nameless), many
   configurations are set to take only Ethernet hwtypes and when asked
   to take the server patches for pureip, they cringed.

   It's kind of understandable -- so we assume it'll take time for
   those patches to trickle into deployment and just moved to behave
   like Ethernet. The easy path.

*2 To build in other trees, you will need the following patches
   against the USB stack.

   http://kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/usb/usb-change-interface-to-usb_lock_device_for_reset.patch
   http://kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/usb/usb-introduce-usb_queue_reset-to-do-resets-from-atomic-contexts-v7.patch

   2.6.28-rc5 has been tested.

   Or clone
   git.kernel.org/pub/scm/linux/kernel/inaky/git/linux-wimax.git; note
   that tree will be rebased when the code is accepted into mailine.

Inaky Perez-Gonzalez (29):
  wimax: documentation for the stack
  wimax: headers for kernel API and user space interaction
  wimax: internal API for the kernel space WiMAX stack
  wimax: debug macros and debug settings for the WiMAX stack
  wimax: generic device management (registration, deregistration,
    lookup)
  genetlink: export genl_unregister_mc_group()
  wimax: basic API: kernel/user messaging, rfkill and reset
  debugfs: add helpers for exporting a size_t simple value
  wimax: debugfs controls
  wimax: Makefile, Kconfig and docbook linkage for the stack
  i2400m: documentation and instructions for usage
  i2400m: host/device procotol and core driver definitions
  i2400m: Generic probe/disconnect, reset and message passing
  i2400m: linkage to the networking stack
  i2400m: firmware loading and bootrom initialization
  i2400m: RX and TX data/control paths
  i2400m: various functions for device management
  i2400m: debugfs controls
  i2400m/USB: header for the USB bus driver
  i2400m/USB: probe/disconnect, dev init/shutdown and reset backends
  i2400m/USB: firmware upload backend
  i2400m/USB: TX and RX path backends
  i2400m/SDIO: header for the SDIO subdriver
  i2400m/SDIO: probe/disconnect, dev init/shutdown and reset backends
  i2400m/SDIO: firmware upload backend
  i2400m/SDIO: TX and RX path backends
  i2400m: Makefile and Kconfig
  wimax: export linux/wimax.h and linux/wimax/i2400m.h with
    headers_install
  wimax/i2400m: add CREDITS and MAINTAINERS entries

 CREDITS                                      |   17 +
 Documentation/DocBook/networking.tmpl        |    8 +
 Documentation/wimax/README.i2400m            |  260 ++++++
 Documentation/wimax/README.wimax             |   81 ++
 MAINTAINERS                                  |   16 +
 drivers/net/Kconfig                          |    2 +
 drivers/net/Makefile                         |    1 +
 drivers/net/wimax/Kconfig                    |   17 +
 drivers/net/wimax/Makefile                   |    2 +
 drivers/net/wimax/i2400m/Kconfig             |   49 +
 drivers/net/wimax/i2400m/Makefile            |   29 +
 drivers/net/wimax/i2400m/control.c           | 1291 ++++++++++++++++++++++++++
 drivers/net/wimax/i2400m/debug-levels.h      |   45 +
 drivers/net/wimax/i2400m/debugfs.c           |  392 ++++++++
 drivers/net/wimax/i2400m/driver.c            |  728 +++++++++++++++
 drivers/net/wimax/i2400m/fw.c                | 1095 ++++++++++++++++++++++
 drivers/net/wimax/i2400m/i2400m-sdio.h       |  132 +++
 drivers/net/wimax/i2400m/i2400m-usb.h        |  264 ++++++
 drivers/net/wimax/i2400m/i2400m.h            |  755 +++++++++++++++
 drivers/net/wimax/i2400m/netdev.c            |  524 +++++++++++
 drivers/net/wimax/i2400m/op-rfkill.c         |  207 ++++
 drivers/net/wimax/i2400m/rx.c                |  534 +++++++++++
 drivers/net/wimax/i2400m/sdio-debug-levels.h |   22 +
 drivers/net/wimax/i2400m/sdio-fw.c           |  224 +++++
 drivers/net/wimax/i2400m/sdio-rx.c           |  255 +++++
 drivers/net/wimax/i2400m/sdio-tx.c           |  153 +++
 drivers/net/wimax/i2400m/sdio.c              |  511 ++++++++++
 drivers/net/wimax/i2400m/tx.c                |  817 ++++++++++++++++
 drivers/net/wimax/i2400m/usb-debug-levels.h  |   42 +
 drivers/net/wimax/i2400m/usb-fw.c            |  340 +++++++
 drivers/net/wimax/i2400m/usb-notif.c         |  269 ++++++
 drivers/net/wimax/i2400m/usb-rx.c            |  417 +++++++++
 drivers/net/wimax/i2400m/usb-tx.c            |  229 +++++
 drivers/net/wimax/i2400m/usb.c               |  591 ++++++++++++
 fs/debugfs/file.c                            |   32 +
 include/linux/Kbuild                         |    2 +
 include/linux/debugfs.h                      |    2 +
 include/linux/wimax.h                        |  234 +++++
 include/linux/wimax/Kbuild                   |    1 +
 include/linux/wimax/debug.h                  |  453 +++++++++
 include/linux/wimax/i2400m.h                 |  512 ++++++++++
 include/net/wimax.h                          |  520 +++++++++++
 net/Kconfig                                  |    2 +
 net/Makefile                                 |    1 +
 net/netlink/genetlink.c                      |    1 +
 net/wimax/Kconfig                            |   36 +
 net/wimax/Makefile                           |   13 +
 net/wimax/debug-levels.h                     |   42 +
 net/wimax/debugfs.c                          |   90 ++
 net/wimax/id-table.c                         |  142 +++
 net/wimax/op-msg.c                           |  421 +++++++++
 net/wimax/op-reset.c                         |  143 +++
 net/wimax/op-rfkill.c                        |  532 +++++++++++
 net/wimax/stack.c                            |  599 ++++++++++++
 net/wimax/wimax-internal.h                   |   91 ++
 55 files changed, 14188 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/wimax/README.i2400m
 create mode 100644 Documentation/wimax/README.wimax
 create mode 100644 drivers/net/wimax/Kconfig
 create mode 100644 drivers/net/wimax/Makefile
 create mode 100644 drivers/net/wimax/i2400m/Kconfig
 create mode 100644 drivers/net/wimax/i2400m/Makefile
 create mode 100644 drivers/net/wimax/i2400m/control.c
 create mode 100644 drivers/net/wimax/i2400m/debug-levels.h
 create mode 100644 drivers/net/wimax/i2400m/debugfs.c
 create mode 100644 drivers/net/wimax/i2400m/driver.c
 create mode 100644 drivers/net/wimax/i2400m/fw.c
 create mode 100644 drivers/net/wimax/i2400m/i2400m-sdio.h
 create mode 100644 drivers/net/wimax/i2400m/i2400m-usb.h
 create mode 100644 drivers/net/wimax/i2400m/i2400m.h
 create mode 100644 drivers/net/wimax/i2400m/netdev.c
 create mode 100644 drivers/net/wimax/i2400m/op-rfkill.c
 create mode 100644 drivers/net/wimax/i2400m/rx.c
 create mode 100644 drivers/net/wimax/i2400m/sdio-debug-levels.h
 create mode 100644 drivers/net/wimax/i2400m/sdio-fw.c
 create mode 100644 drivers/net/wimax/i2400m/sdio-rx.c
 create mode 100644 drivers/net/wimax/i2400m/sdio-tx.c
 create mode 100644 drivers/net/wimax/i2400m/sdio.c
 create mode 100644 drivers/net/wimax/i2400m/tx.c
 create mode 100644 drivers/net/wimax/i2400m/usb-debug-levels.h
 create mode 100644 drivers/net/wimax/i2400m/usb-fw.c
 create mode 100644 drivers/net/wimax/i2400m/usb-notif.c
 create mode 100644 drivers/net/wimax/i2400m/usb-rx.c
 create mode 100644 drivers/net/wimax/i2400m/usb-tx.c
 create mode 100644 drivers/net/wimax/i2400m/usb.c
 create mode 100644 include/linux/wimax.h
 create mode 100644 include/linux/wimax/Kbuild
 create mode 100644 include/linux/wimax/debug.h
 create mode 100644 include/linux/wimax/i2400m.h
 create mode 100644 include/net/wimax.h
 create mode 100644 net/wimax/Kconfig
 create mode 100644 net/wimax/Makefile
 create mode 100644 net/wimax/debug-levels.h
 create mode 100644 net/wimax/debugfs.c
 create mode 100644 net/wimax/id-table.c
 create mode 100644 net/wimax/op-msg.c
 create mode 100644 net/wimax/op-reset.c
 create mode 100644 net/wimax/op-rfkill.c
 create mode 100644 net/wimax/stack.c
 create mode 100644 net/wimax/wimax-internal.h
