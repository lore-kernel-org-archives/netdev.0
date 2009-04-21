From: Gregory Haskins <ghaskins@novell.com>
Subject: [RFC PATCH v3 00/17] virtual-bus
Date: Tue, 21 Apr 2009 14:34:16 -0400
Message-ID: <20090421183341.12548.33393.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, alext@novell.com, anthony@codemonkey.ws,
	rusty@rustcorp.com.au, netdev@vger.kernel.org, avi@redhat.com,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	chrisw@sous-sol.org, shemminger@vyatta.com, alex.williamson@hp.com
To: linux-kernel@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RFC: Virtual-Bus (applies to v2.6.30-rc2)
----------------------

Virtual-Bus is a Linux-kernel based virtual IO resource container technology.
It allows you to declare virtualized device models directly within a host
kernel that can be uniformly accessed from a variety of environments, such
as KVM, userspace, lguest, Xen, etc. The goal is to reduce overhead while
still preserving proper isolation to achieve maximum throughput and latency
from your IO subsystem. It is installed on the host and configured using
simple filesystem operations like "mkdir" to create a new container, "ln -s"
to associate a device with a container, and "echo" to configure the device
thanks to integration with configfs/sysfs. Therefore, managing a virtual-bus
does not require special userspace tools.

Why would we want this?
----------------------

We believe that a combination of in-kernel models, coupled with optimizations
in various areas such as reducing the number of context switches and executing
the algorithms in parallel on modern multicore CPUs will result in the best
possible IO performance for technologies such as virtualization.  This
facility aims to provide the framework for building such constructs in
in software in the most efficient way we believe is possible.

Preliminary Results:
-----------------------

As a test, we wrote a virtual-ethernet backend and a Linux driver
(called venet) and tested the setup with v2.6.29 on two 8-core x86_64
boxes with Chelsio T3 10GE connected back to back via cross over.
We measured bare-metal performance, as well as a kvm guest (running the
same kernel) connected to the T3 via a linux-bridge+tap configuration with
a 1500 MTU.  The results are as follows:

Bare metal       : tput = 4078Mb/s, round-trip = 25593pps (39us rtt)
Virtio-net (PCI) : tput = 4003Mb/s, round-trip = 320pps (3125us rtt)
Venet      (VBUS): tput = 4050Mb/s, round-trip = 15255 (65us rtt)

When we jump to 9000 byte MTU, the situation looks similar

Bare metal       : tput = 9717Mb/s, round-trip = 30396pps (33us rtt)
Virtio-net (PCI) : tput = 4578Mb/s, round-trip = 249pps (4016us rtt)
Venet      (VBUS): tput = 5802Mb/s, round-trip = 15127 (66us rtt)

Note that to be fair, part of the latency response from virtio-pci is due to
the way that the driver/backend coalesces packets, and not a true limitation
of the userspace path as the results may imply.  Anthony Liguori is already
looking into improving this based on the results we presented here, and is
making good headway.

Also note that as of v2, we support a virtio-vbus transport, and therefore
will soon be able to compare "Virtio-net (VBUS)" as an additional target in
the near future once we have developed a virtio-net backend for the host.
This virtio-net(pci) to virtio-net(vbus) comparison is probably more
interesting than comparing to Venet as it would be more apples to apples.
Also it would be nice to only need one PV driver per IO subsystem in the
long term.

Changes v2->v3:
------------------

*) VBUS now renders as a PCI/MSI device instead of via cpuid/dynirq
*) Dropped dynirq (replaced with MSI facility)
*) Dropped "reset" patch in favor of more reliably detecting reset via BUSOPEN
*) Incorporated more review feedback from Stephen Hemminger on vbus-enet
 driver
*) Added support for setting the guests MAC during host config (Pat Mullaney)
*) Cleaned up documentation per feedback from Ben Hutchings
*) Numerous small tweaks to clean up things like warnings, comments, etc.
   (Alex Tsariounov, Greg Haskins)
*) Fixed Kconfig dependency problem with virtio-vbus with feedback from
   Peter Morreale.

Changes v1->v2:

*) Incorporated review feedback from Stephen Hemminger on vbus-enet driver
*) Added support for connecting to vbus devices from userspace
*) Added support for a virtio-vbus transport to allow virtio drivers to
   work with vbus (needs testing and backend models).

Todo:
*) Beef up the userspace event channel ABI to support different event types
*) Add memory-registration support
*) Develop some virtio backend devices.
*) Support ethtool_ops for venet.
*) Convert from MSI to MSIX to truely support multiple vectors

---------------------------------------

For more details, please see our Wiki at 

http://developer.novell.com/wiki/index.php/Virtual-bus





---

Gregory Haskins (16):
      virtio: add a vbus transport
      vbus: add a userspace connector
      kvm: Add guest-side support for VBUS
      kvm: Add VBUS support to the host
      venettap: add scatter-gather support
      venet: add scatter-gather support
      venet-tap: Adds a "venet" compatible "tap" device to VBUS
      net: Add vbus_enet driver
      venet: add the ABI definitions for an 802.x packet interface
      ioq: add vbus helpers
      ioq: Add basic definitions for a shared-memory, lockless queue
      vbus: add a "vbus-proxy" bus model for vbus_driver objects
      vbus: add bus-registration notifiers
      vbus: add connection-client helper infrastructure
      vbus: add virtual-bus definitions
      shm-signal: shared-memory signals

Patrick Mullaney (1):
      venet-tap: add the ability to set the client's mac address via sysfs


 Documentation/vbus.txt           |  385 +++++++++
 arch/x86/Kconfig                 |   11 
 arch/x86/include/asm/kvm_para.h  |    1 
 arch/x86/kvm/Kconfig             |    9 
 arch/x86/kvm/Makefile            |    3 
 arch/x86/kvm/x86.c               |    6 
 arch/x86/kvm/x86.h               |   12 
 drivers/Makefile                 |    2 
 drivers/net/Kconfig              |   13 
 drivers/net/Makefile             |    1 
 drivers/net/vbus-enet.c          |  898 +++++++++++++++++++++
 drivers/vbus/devices/Kconfig     |   17 
 drivers/vbus/devices/Makefile    |    1 
 drivers/vbus/devices/venet-tap.c | 1641 ++++++++++++++++++++++++++++++++++++++
 drivers/vbus/proxy/Makefile      |    2 
 drivers/vbus/proxy/kvm.c         |  751 +++++++++++++++++
 drivers/virtio/Kconfig           |   15 
 drivers/virtio/Makefile          |    1 
 drivers/virtio/virtio_vbus.c     |  496 +++++++++++
 fs/proc/base.c                   |   96 ++
 include/linux/ioq.h              |  410 +++++++++
 include/linux/kvm.h              |    7 
 include/linux/kvm_host.h         |   26 +
 include/linux/kvm_para.h         |   58 +
 include/linux/sched.h            |    4 
 include/linux/shm_signal.h       |  188 ++++
 include/linux/vbus.h             |  166 ++++
 include/linux/vbus_client.h      |  115 +++
 include/linux/vbus_device.h      |  424 ++++++++++
 include/linux/vbus_driver.h      |   80 ++
 include/linux/vbus_userspace.h   |   48 +
 include/linux/venet.h            |   82 ++
 include/linux/virtio_vbus.h      |  163 ++++
 kernel/Makefile                  |    1 
 kernel/exit.c                    |    2 
 kernel/fork.c                    |    2 
 kernel/vbus/Kconfig              |   56 +
 kernel/vbus/Makefile             |   11 
 kernel/vbus/attribute.c          |   52 +
 kernel/vbus/client.c             |  543 +++++++++++++
 kernel/vbus/config.c             |  275 ++++++
 kernel/vbus/core.c               |  626 ++++++++++++++
 kernel/vbus/devclass.c           |  124 +++
 kernel/vbus/map.c                |   72 ++
 kernel/vbus/map.h                |   41 +
 kernel/vbus/proxy.c              |  216 +++++
 kernel/vbus/shm-ioq.c            |   89 ++
 kernel/vbus/userspace-client.c   |  485 +++++++++++
 kernel/vbus/vbus.h               |  117 +++
 kernel/vbus/virtio.c             |  627 +++++++++++++++
 lib/Kconfig                      |   21 
 lib/Makefile                     |    2 
 lib/ioq.c                        |  298 +++++++
 lib/shm_signal.c                 |  186 ++++
 virt/kvm/kvm_main.c              |   10 
 virt/kvm/vbus.c                  | 1392 ++++++++++++++++++++++++++++++++
 56 files changed, 11380 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/vbus.txt
 create mode 100644 drivers/net/vbus-enet.c
 create mode 100644 drivers/vbus/devices/Kconfig
 create mode 100644 drivers/vbus/devices/Makefile
 create mode 100644 drivers/vbus/devices/venet-tap.c
 create mode 100644 drivers/vbus/proxy/Makefile
 create mode 100644 drivers/vbus/proxy/kvm.c
 create mode 100644 drivers/virtio/virtio_vbus.c
 create mode 100644 include/linux/ioq.h
 create mode 100644 include/linux/shm_signal.h
 create mode 100644 include/linux/vbus.h
 create mode 100644 include/linux/vbus_client.h
 create mode 100644 include/linux/vbus_device.h
 create mode 100644 include/linux/vbus_driver.h
 create mode 100644 include/linux/vbus_userspace.h
 create mode 100644 include/linux/venet.h
 create mode 100644 include/linux/virtio_vbus.h
 create mode 100644 kernel/vbus/Kconfig
 create mode 100644 kernel/vbus/Makefile
 create mode 100644 kernel/vbus/attribute.c
 create mode 100644 kernel/vbus/client.c
 create mode 100644 kernel/vbus/config.c
 create mode 100644 kernel/vbus/core.c
 create mode 100644 kernel/vbus/devclass.c
 create mode 100644 kernel/vbus/map.c
 create mode 100644 kernel/vbus/map.h
 create mode 100644 kernel/vbus/proxy.c
 create mode 100644 kernel/vbus/shm-ioq.c
 create mode 100644 kernel/vbus/userspace-client.c
 create mode 100644 kernel/vbus/vbus.h
 create mode 100644 kernel/vbus/virtio.c
 create mode 100644 lib/ioq.c
 create mode 100644 lib/shm_signal.c
 create mode 100644 virt/kvm/vbus.c

-- 

