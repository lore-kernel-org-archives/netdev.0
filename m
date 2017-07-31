From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 0/4] netvsc: transparent SR-IOV VF support
Date: Mon, 31 Jul 2017 16:37:08 -0700
Message-ID: <20170731233712.12087-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: devel@linuxdriverproject.org, linux-doc@vger.kernel.org,
        netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
        corbet@lwn.net
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set changes how SR-IOV Virtual Function devices are managed
in the Hyper-V network driver. It was part of earlier bundle, but
is now updated.

Background
In Hyper-V SR-IOV can be enabled (and disabled) by changing guest settings
on host. When SR-IOV is enabled a matching PCI device is hot plugged and
visible on guest. The VF device is an add-on to an existing netvsc
device, and has the same MAC address.

How is this different?

The original support of VF relied on using bonding driver in active
standby mode to handle the VF device.

With the new netvsc VF logic, the Linux hyper-V network
virtual driver will directly manage the link to SR-IOV VF device.
When VF device is detected (hot plug) it is automatically made a
slave device of the netvsc device. The VF device state reflects
the state of the netvsc device; i.e. if netvsc is set down, then
VF is set down. If netvsc is set up, then VF is brought up.
 
Packet flow is independent of VF status; all packets are sent and
received as if they were associated with the netvsc device. If VF is
removed or link is down then the synthetic VMBUS path is used.
 
What was wrong with using bonding script?

A lot of work went into getting the bonding script to work on all
distributions, but it was a major struggle. Linux network devices
can be configured many, many ways and there is no one solution from
userspace to make it all work. What is really hard is when
configuration is attached to synthetic device during boot (eth0) and
then the same addresses and firewall rules needs to also work later if
doing bonding. The new code gets around all of this.
 
How does VF work during initialization?

Since all packets are sent and received through the logical netvsc
device, initialization is much easier. Just configure the regular
netvsc Ethernet device; when/if SR-IOV is enabled it just
works. Provisioning and cloud init only need to worry about setting up
netvsc device (eth0). If SR-IOV is enabled (even as a later step), the
address and rules stay the same.
 
What devices show up?

Both netvsc and PCI devices are visible in the system. The netvsc
device is active and named in usual manner (eth0). The PCI device is
visible to Linux and gets renamed by udev to a persistent name
(enP2p3s0). The PCI device name is now irrelevant now.

The logic also sets the PCI VF device SLAVE flag on the network
device so network tools can see the relationship if they are smart
enough to understand how layered devices work.
 
This is a lot like how I see Windows working.
The VF device is visible in Device Manager, but is not configured.
 
Is there any performance impact?
There is no visible change in performance. The bonding
and netvsc driver both have equivalent steps.
 
Is it compatible with old bonding script?

It turns out that if you use the old bonding script, then everything
still works but in a sub-optimum manner. What happens is that bonding
is unable to steal the VF from the netvsc device so it creates a one
legged bond.  Packet flow then is:
	bond0 <--> eth0 <- -> VF (enP2p3s0).
In other words, if you get it wrong it still works, just
awkward and slower.
 
What if I add address or firewall rule onto the VF?

Same problems occur with now as already occur with bonding, bridging,
teaming on Linux if user incorrectly does configuration onto
an underlying slave device. It will sort of work, packets will come in
and out but the Linux kernel gets confused and things like ARP don’t
work right.  There is no way to block manipulation of the slave
device, and I am sure someone will find some special use case where
they want it.


Stephen Hemminger (4):
  netvsc: transparent VF management
  netvsc: add documentation
  netvsc: remove bonding setup script
  pci-hyperv: do not sleep in compose_msi_msg

 Documentation/networking/netvsc.txt |  63 ++++++
 MAINTAINERS                         |   1 +
 drivers/net/hyperv/hyperv_net.h     |  12 ++
 drivers/net/hyperv/netvsc_drv.c     | 419 ++++++++++++++++++++++++++++--------
 drivers/pci/host/pci-hyperv.c       |   8 +-
 tools/hv/bondvf.sh                  | 255 ----------------------
 6 files changed, 413 insertions(+), 345 deletions(-)
 create mode 100644 Documentation/networking/netvsc.txt
 delete mode 100755 tools/hv/bondvf.sh

-- 
2.11.0
