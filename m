From: Patrick Mullaney <pmullaney@novell.com>
Subject: [PATCH 0/4] vbus: venet macvlan support
Date: Tue, 10 Nov 2009 17:27:42 -0500
Message-ID: <20091110222632.24100.14884.stgit@mimic.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kaber@trash.net, arnd@arndb.de,
	bridge@lists.linux-foundation.org, evb@yahoogroups.com,
	netdev@vger.kernel.org
To: alacrityvm-devel@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757875AbZKJW1q@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Applies to alacrityvm.git/master:34534534)

This patchset implements a vbus venet device with a
macvlan backend.

These patches allow an alacrityvm guest to send and receive
directly over a macvlan, avoiding the bridge entirely.
This driver inherits all of the benefits of the work done
to date on vbus/venet driver(SAR offloading, zero-copy
in the guest->host path, configurable tx-complete mitigation,
interrupt coalescing at the vbus level).  Some of the work to
re-factor and share the common code between venet-tap and
venet-macvlan was done prior because it should be generally
useful to anyone wanting to implement a venet type of device.

Once the driver is built and installed, you may use it
just like you would a venet-tap device. In order to
instantiate a venet-macvlan, there are just two differences
from the procedure to instantiating a venet-tap. In order
to create the venet-macvlan device, just:

echo venet-macvlan > /config/vbus/devices/<device-name>/type

and

echo "lower-devicename" > /sys/vbus/devices/<device-name>/ll_ifname

where lower-devicename is something like eth0, eth1, eth2 etc.

The second step associates the lower-devicename, usually
a physical device, with the venet-macvlan device being created.
This step must be perform prior to enabling the venet-macvlan
device.

After that, a guest can make use of the venet-macvlan in
exactly the same manner as a venet-tap. In fact, the guest
actually sees venet-tap and venet-macvlan as identical
types of the devices on the vbus.

Using the venet-macvlan driver will reduce some overhead by
eliminating the linux bridge from the send and receive
paths. For a lightly loaded network segment and system,
we have measured this to be aproximately 1-3 us per side
depending on what hardware is involved.

Since this driver layered over the macvlan driver, it will
have that same limitations as the macvlan driver. For example,
forwarding between macvlan devices on the same host is not
supported. This driver targeted toward VEPA environments as
described by the 'Edge Virtual Bridging' working group.

---

Patrick Mullaney (4):
      venet-macvlan: add new driver to connect a venet to a macvlan netdevice
      venetdev: support common venet netdev routines
      macvlan: allow in-kernel modules to create and manage macvlan devices
      macvlan:  derived from Arnd Bergmann's patch for macvtap


 drivers/net/macvlan.c                   |  105 +++--
 drivers/net/vbus-enet.c                 |    8 
 include/linux/macvlan.h                 |   43 ++
 include/linux/venet.h                   |    5 
 kernel/vbus/devices/venet/Kconfig       |   11 +
 kernel/vbus/devices/venet/Makefile      |   10 -
 kernel/vbus/devices/venet/device.c      |   53 ++-
 kernel/vbus/devices/venet/macvlan.c     |  598 +++++++++++++++++++++++++++++++
 kernel/vbus/devices/venet/venetdevice.h |   12 +
 9 files changed, 785 insertions(+), 60 deletions(-)
 create mode 100644 include/linux/macvlan.h
 create mode 100644 kernel/vbus/devices/venet/macvlan.c
